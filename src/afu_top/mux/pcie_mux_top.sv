// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Engineer     : Stephen Chang, Jitendra Bhamare, Matthew Deckard
// Create Date  : Mar 2021
// Module Name  : pcie_mux_top.sv
// Project      : IOFS
// -----------------------------------------------------------------------------
//
// Description: 
//
// Wrapper that connects host and pfvf|bar interface to switch ports + avst/axi conversion
// switch is M X N mux structures that allows any M port to target any N port, and
// any N port to target any M port.  Each M or N port has an arbitor to handle
// multiple inputs.  Switch is common for AXI and AVST streaming.  The protocol 
// signals of AXI/AVST pass the switch as data.  Only ready, valid, and last/end_of_packet
// are used to handshake.  User can define number of N and M ports which are 
// parameterized; however, the wider the bus, the more limits on number of ports, 
// due to the timing and routing contraints of FPGA. If necessary, multiple stages 
// of switch can be connected in hierarchical fasion.  The switch contains
// a fifo to handle handshake delays (such as ready), therefore capable of
// proper handshakes and data trasnfers between multiple stages.
//
// 
// ***************************************************************************
//  
// 
import ofs_fim_if_pkg::*; 
import pcie_ss_pkg::*;
import top_cfg_pkg::*;


//==============================================================================================================================================================
//                                     PF/VF/BAR Mux/Switch Main 
//==============================================================================================================================================================                                                                                 
module pcie_mux_top #(
          parameter              D_WIDTH    = DATA_WIDTH                            ,// Port Data Width
          parameter              M          = 1                                     ,// Number of Host/Upstream ports
          parameter              N          = 8                                     ,// Number of Function/Downstream ports
          parameter              USER_WIDTH = 10                                    ,// USER field width
          parameter              ERR_WIDTH  = 10                                    ,// ERROR field width
          parameter              DEPTH      = 1                                     ,// out_q fifo depth = 2**DEPTH
                                                                                     //
          parameter              NID_WIDTH  = $clog2(N)                             ,//  ID field for targeting N port
          parameter              MID_WIDTH  = $clog2(M)                             ,//  ID field for targeting M port
                                                                                     //-------------- AVST-----------------------
          parameter              DATA_LSB   = 0                                     ,//  if.data bit position of data LSB
          parameter              DATA_MSB   = D_WIDTH   - 1                         ,//  if.data bit position of data MSB
          parameter              VALID      = DATA_MSB  + 1                         ,//  if.data bit position of valid bit 
          parameter              END        = VALID     + 1                         ,//  if.data bit position of end of pakcet 
          parameter              START      = END       + 1                         ,//  if.data bit position of start of pakcet (for internal logic)
          parameter              ERR_LSB    = START     + 1                         ,//  if.data bit position of error LSB
          parameter              ERR_MSB    = START     + ERR_WIDTH                 ,//  if.data bit position of error MSB
          parameter              EMPTY_LSB  = ERR_MSB   + 1                         ,//  if.data bit position of empty LSB
          parameter              EMPTY_MSB  = ERR_MSB   + $clog2(D_WIDTH/8)         ,//  if.data bit position of empty MSB 
                                                                                     //------------- AXI ------------------------
          //                     DATA_LSB   = 0                                     ,//  if.data bit position of data LSB
          //                     DATA_MSB   = D_WIDTH   - 1                         ,//  if.data bit position of data MSB
          //                     VALID      = DATA_MSB  + 1                         ,//  if.data bit position of valid bit 
          parameter              LAST       = VALID     + 1                         ,//  if.data bit position of last
          //                     START      = LAST      + 1                         ,//  if.data bit position of start of pakcet 
          parameter              USER_LSB   = START     + 1                         ,//  if.data bit position of user LSB
          parameter              USER_MSB   = START     + USER_WIDTH                ,//  if.data bit position of user MSB
          parameter              KEEP_LSB   = USER_MSB  + 1                         ,//  if.data bit position of keep LSB 
          parameter              KEEP_MSB   = USER_MSB  + D_WIDTH/8                 ,//  if.data bit position of keep MSB 
          parameter              WIDTH      = KEEP_MSB  + 1                         ,//  if.data width
                                                                                     //                                                        
          parameter              VFPF_WIDTH = 14                                    ,//  virtual + physical function width
          parameter              VFPF_LSB   = 160                                   ,//  LSB postion of virtual/physical field
          parameter              VFPF_MSB   = VFPF_LSB + VFPF_WIDTH                 ,//  MSB postion of virtual/physical field
                                                                                     //
          parameter              BAR_WIDTH  = 4                                     ,//  virtual + physical function width
          parameter              BAR_LSB    = 175                                   ,//  LSB postion of virtual/physical field
          parameter              BAR_MSB    = BAR_LSB + BAR_WIDTH                    //  MSB postion of virtual/physical field
                                                                                     //  
        )(                                                                           // 1. assign each function with a specific pf/vf
          input                  clk                                                ,// 2. connect each pf/vf to one of mux ports (rx + tx) in afu_top
          input                  rst_n                                              ,// 3. modify pf/vf to port routing (M_TID_map function in this file)
                                                                                     // 4. format each port by instantiating axi/avst_port_map (in this file)
          pcie_ss_axis_if.sink   ho2mx_rx_port                                      ,// 
          pcie_ss_axis_if.source mx2ho_tx_port                                      ,//
          pcie_ss_axis_if.source mx2fn_rx_port  [N-1:0]                             ,//
          pcie_ss_axis_if.sink   fn2mx_tx_port  [N-1:0]                             ,//
          output logic           out_fifo_err                                       ,// output fifo error
          output logic           out_fifo_perr                                       // output fifo parity error
          );                                                                         //
                                                                                     //
          logic  [M-1:0][WIDTH-1:0]    M_in_data                                    ;//  M input  port data  
          logic  [M-1:0]               M_sop                                        ;//  M input  port start of packet
          logic  [M-1:0]               M_sop_en                                     ;//  M input  port start of packet
          logic  [M-1:0]               M_valid                                      ;//  M input  port valid
          logic  [M-1:0]               M_ready                                      ;//  M input  port ready/grant
          logic  [M-1:0][N-1:0]        M_in_sop                                     ;//  M input  port start of packet (decoded bit vector)
          logic  [M-1:0][N-1:0]        M_in_eop                                     ;//  M input  port end of packet (decoded bit vector)
          logic  [M-1:0][N-1:0]        M_in_valid                                   ;//  M input  port data valid (decoded bit vector)
          logic  [M-1:0]               M_out_ready                                  ;//  M output port ready from next stage logic
          logic  [M-1:0]               M_out_sop                                    ;//  M port out sop for dispaly message
          logic  [M-1:0][N-1:0]        M_in_ready                                   ;//  M input  port ready/grant 
          logic  [M-1:0]               M_out_valid                                  ;//  M output port data valid
          logic  [M-1:0][WIDTH-1:0]    M_out_data                                   ;//  M output port data
          logic  [N-1:0][WIDTH-1:0]    N_in_data                                    ;//  N input  port data  
          logic  [N-1:0]               N_sop                                        ;//  N input  port start of packet
          logic  [N-1:0]               N_sop_en                                     ;//  N input  port start of packet
          logic  [N-1:0]               N_valid                                      ;//  N input  port valid
          logic  [N-1:0]               N_valid_q                                    ;//  N input  port valid 1 clk delay
          logic  [N-1:0]               N_ready                                      ;//  N input  port ready/grant
          logic  [N-1:0][M-1:0]        N_in_sop                                     ;//  N input  start of packet (decoded bit vector)
          logic  [N-1:0][M-1:0]        N_in_eop                                     ;//  N input  end of packet (decoded bit vector)
          logic  [N-1:0][M-1:0]        N_in_valid                                   ;//  N input  port data valid (decoded bit vector)
          logic  [N-1:0]               N_out_ready                                  ;//  N output port ready from next stage logic
          logic  [N-1:0][M-1:0]        N_in_ready                                   ;//  N input  port ready/grant 
          logic  [N-1:0]               N_out_valid                                  ;//  N output port data valid
          logic  [N-1:0][WIDTH-1:0]    N_out_data                                   ;//  N output port data
          logic  [M-1:0][NID_WIDTH:0]  M_TID                                        ;//  M to N   port destination ID
          logic  [M-1:0][NID_WIDTH:0]  M_TID_q                                      ;//  M to N   port destination ID
          logic  [N-1:0][MID_WIDTH:0]  N_TID                                        ;//  N to M   port destination ID
          logic  [N-1:0][MID_WIDTH:0]  N_TID_q                                      ;//  N to M   port destination ID
          logic                        out_q_err                                    ;//
          logic                        out_q_perr                                   ;//
          integer                      p                                            ;//  port index
                                                                                     //  
    always @(*) begin                                                                //  
       for (p=0; p<M; p++) begin                                                     // sop detection using valid and eop signals:
           M_sop      [p]           =  M_in_data [p][VALID] & M_sop_en [p]          ;//
           M_TID      [p]           =  M_sop     [p]                                 // 
                                    ?  M_TID_map (M_in_data[p][VFPF_MSB:VFPF_LSB],   // VF_ACT[174]/VF_NUM[173:163]/PF_NUM[162:160]
                                                  M_in_data[p][BAR_MSB:BAR_LSB])     // BAR[187:185]
                                    :  M_TID_q                                      ;// target ID encoding based on PF/VF
           M_in_valid [p]           =  0                                            ;//(must match pv/vf port mapping to switch port)
           M_in_sop   [p]           =  0                                            ;// 
           M_in_eop   [p]           =  0                                            ;// decode target and assert bit-vector valid
           M_in_valid [p][M_TID[p]] =  M_in_data [p][VALID]                         ;// there are N valid bits.  1 for each target
           M_in_sop   [p][M_TID[p]] =  M_sop     [p]                                ;//
           M_in_eop   [p][M_TID[p]] =  M_in_data [p][VALID] & M_in_data[p][END]     ;// 
           M_ready    [p]           =  M_in_ready[p][M_TID[p]]                      ;// 
           M_out_sop  [p]           =  M_out_data[p][START]                         ;//
       end                                                                           // 
       for (p=0; p<N; p++) begin                                                     // sop detection using valid and eop signals:
           N_sop      [p]           =  N_in_data[p][VALID] & N_sop_en [p]           ;// 
           N_TID      [p]           =  0                                            ;//
           N_in_valid [p]           =  0                                            ;// decode target and assert bit-vector valid
           N_in_sop   [p]           =  0                                            ;// there are M valid bits.  1 for each target
           N_in_eop   [p]           =  0                                            ;//
           N_in_valid [p][N_TID[p]] =  N_in_data [p][VALID]                         ;//
           N_in_sop   [p][N_TID[p]] =  N_sop     [p]                                ;//
           N_in_eop   [p][N_TID[p]] =  N_in_data [p][VALID] & N_in_data[p][END]     ;//
           N_ready    [p]           =  N_in_ready[p][N_TID[p]]                      ;//
       end                                                                           //
    end                                                                              //
                                                                                     //
    always @(posedge clk) begin                                                      //
                                                                                     //
       out_fifo_err  <= out_q_err                                                   ;//
       out_fifo_perr <= out_q_perr                                                  ;//
                                                                                     //
       for (p=0; p<M; p++) begin                                                     // 
                        M_valid  [p]<= M_in_data[p][VALID]                          ;//
           if (M_sop[p])M_TID_q  [p]<= M_TID    [p]                                 ;// latch target ID upon sop and until eop
                                                                                     //
           if ( M_in_data[p][VALID]                                                  // enable sop detection
              & M_ready  [p]                                                         //
              )                                                                      //
              begin                                                                  //
                  if (  M_sop  [p])      M_sop_en [p] <= 0                          ;// enable detection between eop and sop
                  if (M_in_data[p][END]) M_sop_en [p] <= 1                          ;// 
              end                                                                    //
       end                                                                           //
                                                                                     //
       for (p=0; p<N; p++) begin                                                     // registers needed for sop detection
                        N_valid_q[p]<= N_in_data[p][VALID]                          ;// latch target ID upon sop and until eop
           if (N_sop[p])N_TID_q  [p]<= N_TID    [p]                                 ;//
                                                                                     //
           if ( N_in_data[p][VALID]                                                  // enable sop detection
              & N_ready  [p]                                                         //
              )                                                                      // 
              begin                                                                  //
                  if (  N_sop  [p])      N_sop_en [p] <= 0                          ;// enable detection between eop and sop
                  if (N_in_data[p][END]) N_sop_en [p] <= 1                          ;// 
              end                                                                    //
       end                                                                           //
                                                                                     //
       if (!rst_n) begin                                                             // 
                               N_sop_en   <= ~0                                     ;//
                               M_sop_en   <= ~0                                     ;//
           for (p=0; p<M; p++) M_TID_q[p] <=  0                                     ;// reset
           for (p=0; p<N; p++) N_TID_q[p] <=  0                                     ;// 
       end                                                                           // 
                                                                                     //
                                   /* synthesis translate_on */
    
    end                                                                              //
    //----------------------------------------------------------------------------------------------------------------------------------------------------------
    //                                  pv/vf mapping encoding function
    //----------------------------------------------------------------------------------------------------------------------------------------------------------
    localparam ST2MM_PF   = PG_SR_PORTS_PF_NUM[SR_PF0_PF0_PID_IDX];
    localparam ST2MM_VF   = PG_SR_PORTS_VF_NUM[SR_PF0_PF0_PID_IDX];
    localparam ST2MM_VA   = PG_SR_PORTS_VF_ACTIVE[SR_PF0_PF0_PID_IDX];

    function [ NID_WIDTH:0] M_TID_map                                               ;// Function: M port pf/vf maping to N port
    input    [VFPF_WIDTH:0] M_vf_pf                                                 ;// Input:    M port{vf_act[14], vf[13:3], pf[2:0] }
    input    [ BAR_WIDTH:0] M_bar                                                   ;//
    begin    
        casex({M_vf_pf[14],M_vf_pf[2:0], M_vf_pf[4:3]})/* synthesis parallel_case */              
              {ST2MM_VA  ,  ST2MM_PF[2:0],  ST2MM_VF[1:0]} : M_TID_map = 0    ;
              {1'h0      ,  3'h1         ,  2'h0         } : M_TID_map = 1    ; 
              {1'h0      ,  3'h2         ,  2'h0         } : M_TID_map = 2    ;
              {1'h0      ,  3'h3         ,  2'h0         } : M_TID_map = 3    ;
              {1'h0      ,  3'h4         ,  2'h0         } : M_TID_map = 4    ;
              {1'h1      ,  3'h0         ,  2'h0         } : M_TID_map = 5    ; 
              {1'h1      ,  3'h0         ,  2'h1         } : M_TID_map = 6    ;
              {1'h1      ,  3'h0         ,  2'h2         } : M_TID_map = 7    ;
               default                                     : M_TID_map = 0    ;
        endcase                                                                                                                                                      //           
    end                                                                              
    endfunction                                                                       
  //----------------------------------------------------------------------------------------------------------------------------------------------------------
  //                   port data      port ready    port valid/sop   interface       // interface to switch port mapping
  //----------------------------------------------------------------------------------------------------------------------------------------------------------

  axi_port_map_pcie M0 (M_in_data [0], M_ready    [0], M_sop      [0], ho2mx_rx_port     ,//  in M[0] port 
                   M_out_data[0], M_out_ready[0], M_out_valid[0], mx2ho_tx_port   ) ;// out
                                                                                     //   

  axi_port_map_pcie N0 (N_in_data [0], N_ready    [0], N_sop      [0], fn2mx_tx_port[0]  ,//  in N[0] port  
                   N_out_data[0], N_out_ready[0], N_out_valid[0], mx2fn_rx_port[0]) ;// out
  axi_port_map_pcie N1 (N_in_data [1], N_ready    [1], N_sop      [1], fn2mx_tx_port[1]  ,//  in N[1] port
                   N_out_data[1], N_out_ready[1], N_out_valid[1], mx2fn_rx_port[1]) ;// out
  axi_port_map_pcie N2 (N_in_data [2], N_ready    [2], N_sop      [2], fn2mx_tx_port[2]  ,//  in N[2] port
                   N_out_data[2], N_out_ready[2], N_out_valid[2], mx2fn_rx_port[2]) ;// out
  axi_port_map_pcie N3 (N_in_data [3], N_ready    [3], N_sop      [3], fn2mx_tx_port[3]  ,//  in N[3] port
                   N_out_data[3], N_out_ready[3], N_out_valid[3], mx2fn_rx_port[3]) ;// out

 axi_port_map_pcie N4 (N_in_data [4], N_ready    [4], N_sop      [4], fn2mx_tx_port[4]  ,//  in N[0] port  
                   N_out_data[4], N_out_ready[4], N_out_valid[4], mx2fn_rx_port[4]) ;// out
  axi_port_map_pcie N5 (N_in_data [5], N_ready    [5], N_sop      [5], fn2mx_tx_port[5]  ,//  in N[1] port
                   N_out_data[5], N_out_ready[5], N_out_valid[5], mx2fn_rx_port[5]) ;// out
  axi_port_map_pcie N6 (N_in_data [6], N_ready    [6], N_sop      [6], fn2mx_tx_port[6]  ,//  in N[2] port
                   N_out_data[6], N_out_ready[6], N_out_valid[6], mx2fn_rx_port[6]) ;// out
  axi_port_map_pcie N7 (N_in_data [7], N_ready    [7], N_sop      [7], fn2mx_tx_port[7]  ,//  in N[3] port
                   N_out_data[7], N_out_ready[7], N_out_valid[7], mx2fn_rx_port[7]) ;// out

                                                                                     //
   switch  # (                                            // M X N switch with output FIFO
             .WIDTH       (    WIDTH      )              ,// Port Data Width                              
             .M           (    M          )              ,// Number of M Ports 
             .N           (    N          )              ,// Number of N Ports 
             .DEPTH       (    DEPTH      )               // FIFO Depth=2**DEPTH 
             )                                            // 
   switch   (                                             // ----------- input -----------------------------------
              M_in_data                                  ,// Mux M to N ports data in 
              M_in_sop                                   ,// Mux M to N ports end of packet
              M_in_eop                                   ,// Mux M to N ports end of packet
              M_in_valid                                 ,// Mux M to N ports data in valid
              M_out_ready                                ,// Mux M to N ports data out ready from next stage logic
              N_in_data                                  ,// Mux N to M data in 
              N_in_sop                                   ,// Mux N to M data in end of packet
              N_in_eop                                   ,// Mux N to M data in end of packet
              N_in_valid                                 ,// Mux N to M data in valid
              N_out_ready                                ,// Mux N to M data out ready from next stage logic 
              rst_n                                      ,// reset low active
              clk                                        ,// clock
                                                          //----------  output ----------------------------------
              M_in_ready                                 ,// Mux M to N ready 
              M_out_valid                                ,// Mux M to N out valid
              M_out_data                                 ,// Mux M to N data out
              N_in_ready                                 ,// Mux N to M ready 
              N_out_valid                                ,// Mux N to M out valid
              N_out_data                                 ,// Mux N to M data out
              out_q_err                                  ,// N/M out_q FIFO error
              out_q_perr                                  // N/M out_q FIFO error
             )                                           ;//   
endmodule                                                                            //
//==============================================================================================================================================================
//                                         Port Mapping of AXI to switch port
//==============================================================================================================================================================
module axi_port_map_pcie #(
          parameter              D_WIDTH    = DATA_WIDTH                            ,// Port Data Width
          parameter              M          = 1                                     ,// Number of Host/Upstream ports
          parameter              N          = 2                                     ,// Number of Function/Downstream ports
          parameter              USER_WIDTH = 10                                    ,// USER field width
          parameter              ERR_WIDTH  = 10                                    ,// ERROR field width
          parameter              DEPTH      = 2                                     ,// out_q fifo depth = 2**DEPTH
                                                                                     //-------------- AVST-----------------------
          parameter              DATA_LSB   = 0                                     ,//  if.data bit position of data LSB
          parameter              DATA_MSB   = D_WIDTH   - 1                         ,//  if.data bit position of data MSB
          parameter              VALID      = DATA_MSB  + 1                         ,//  if.data bit position of valid bit 
          parameter              END        = VALID     + 1                         ,//  if.data bit position of end of pakcet 
          parameter              START      = END       + 1                         ,//  if.data bit position of start of pakcet (for internal logic)
          parameter              ERR_LSB    = START     + 1                         ,//  if.data bit position of error LSB
          parameter              ERR_MSB    = START     + ERR_WIDTH                 ,//  if.data bit position of error MSB
          parameter              EMPTY_LSB  = ERR_MSB   + 1                         ,//  if.data bit position of empty LSB
          parameter              EMPTY_MSB  = ERR_MSB   + $clog2(D_WIDTH/8)         ,//  if.data bit position of empty MSB 
                                                                                     //------------- AXI ------------------------
          //                     DATA_LSB   = 0                                     ,//  if.data bit position of data LSB
          //                     DATA_MSB   = D_WIDTH   - 1                         ,//  if.data bit position of data MSB
          //                     VALID      = DATA_MSB  + 1                         ,//  if.data bit position of valid bit 
          parameter              LAST       = VALID     + 1                         ,//  if.data bit position of last
          //                     START      = LAST      + 1                         ,//  if.data bit position of start of pakcet 
          parameter              USER_LSB   = START     + 1                         ,//  if.data bit position of user LSB
          parameter              USER_MSB   = START     + USER_WIDTH                ,//  if.data bit position of user MSB
          parameter              KEEP_LSB   = USER_MSB  + 1                         ,//  if.data bit position of keep LSB 
          parameter              KEEP_MSB   = USER_MSB  + D_WIDTH/8                 ,//  if.data bit position of keep MSB 
          parameter              WIDTH      = KEEP_MSB  + 1                          //  if.data width
        )(                                                                           //
                output  [WIDTH-1:0]               in_port_data                      ,// switch port in data
                input                             in_port_ready                     ,// switch port in ready
                input                             in_port_sop                       ,// swtich port in sop (header valid)
                pcie_ss_axis_if.sink              in_interface                      ,// axi in interface
                input   [WIDTH-1:0]               out_port_data                     ,// switch port out data
                output                            out_port_ready                    ,// switch port out ready
                input                             out_port_valid                    ,// switch port out valid
                pcie_ss_axis_if.source            out_interface                      // axi out interface
        )                                                                           ;// map interface signals to port data bits
        assign  in_port_data [KEEP_MSB:KEEP_LSB] = in_interface.tkeep                ;// only valid, ready, and last/eop are used for handshake 
        assign  in_port_data [USER_MSB:USER_LSB] = in_interface.tuser_vendor         ;//  
        assign  in_port_data [START            ] = in_port_sop                       ;//  
        assign  in_port_data [LAST             ] = in_interface.tlast                ;//  
        assign  in_port_data [VALID            ] = in_interface.tvalid               ;//  
        assign  in_port_data [DATA_MSB:DATA_LSB] = in_interface.tdata                ;//  
        assign  in_interface.tready              = in_port_ready                     ;//  
                                                                                      //  
        assign  out_interface.tkeep              = out_port_data[KEEP_MSB:KEEP_LSB]  ;//  
        assign  out_interface.tuser_vendor       = out_port_data[USER_MSB:USER_LSB]  ;//  
        assign  out_interface.tlast              = out_port_data[LAST]               ;//  
        assign  out_interface.tvalid             = out_port_valid                    ;//  
        assign  out_interface.tdata              = out_port_data[DATA_MSB:DATA_LSB]  ;//  
        assign  out_port_ready                   = out_interface.tready              ;//  
endmodule                                                                             //
//==============================================================================================================================================================
//                                         Port Mapping of AVST to AXI switch port
//==============================================================================================================================================================
module avst_port_map_pcie #(
          parameter              D_WIDTH    = DATA_WIDTH                            ,// Port Data Width
          parameter              M          = 1                                     ,// Number of Host/Upstream ports
          parameter              N          = 2                                     ,// Number of Function/Downstream ports
          parameter              USER_WIDTH = 10                                    ,// USER field width
          parameter              ERR_WIDTH  = 10                                    ,// ERROR field width
          parameter              DEPTH      = 2                                     ,// out_q fifo depth = 2**DEPTH
                                                                                     //-------------- AVST-----------------------
          parameter              DATA_LSB   = 0                                     ,//  if.data bit position of data LSB
          parameter              DATA_MSB   = D_WIDTH   - 1                         ,//  if.data bit position of data MSB
          parameter              VALID      = DATA_MSB  + 1                         ,//  if.data bit position of valid bit 
          parameter              END        = VALID     + 1                         ,//  if.data bit position of end of pakcet 
          parameter              START      = END       + 1                         ,//  if.data bit position of start of pakcet (for internal logic)
          parameter              ERR_LSB    = START     + 1                         ,//  if.data bit position of error LSB
          parameter              ERR_MSB    = START     + ERR_WIDTH                 ,//  if.data bit position of error MSB
          parameter              EMPTY_LSB  = ERR_MSB   + 1                         ,//  if.data bit position of empty LSB
          parameter              EMPTY_MSB  = ERR_MSB   + $clog2(D_WIDTH/8)         ,//  if.data bit position of empty MSB 
                                                                                     //------------- AXI ------------------------
          //                     DATA_LSB   = 0                                     ,//  if.data bit position of data LSB
          //                     DATA_MSB   = D_WIDTH   - 1                         ,//  if.data bit position of data MSB
          //                     VALID      = DATA_MSB  + 1                         ,//  if.data bit position of valid bit 
          parameter              LAST       = VALID     + 1                         ,//  if.data bit position of last
          //                     START      = LAST      + 1                         ,//  if.data bit position of start of pakcet 
          parameter              USER_LSB   = START     + 1                         ,//  if.data bit position of user LSB
          parameter              USER_MSB   = START     + USER_WIDTH                ,//  if.data bit position of user MSB
          parameter              KEEP_LSB   = USER_MSB  + 1                         ,//  if.data bit position of keep LSB 
          parameter              KEEP_MSB   = USER_MSB  + D_WIDTH/8                 ,//  if.data bit position of keep MSB 
          parameter              WIDTH      = KEEP_MSB  + 1                          //  if.data width
        )(                                                                           //
                output  [WIDTH-1:0]                in_port_data                     ,// switch port in data
                input                              in_port_ready                    ,// switch port in ready
                input                              in_port_sop                      ,// swtich port in sop (header valid)
                ofs_avst_if.sink                   in_interface                     ,// avst in interface
                input   [WIDTH-1:0]                out_port_data                    ,// switch port out data
                output                             out_port_ready                   ,// switch port out ready
                input                              out_port_valid                   ,// switch port out valid
                ofs_avst_if.source                 out_interface                     // avst out interface
        )                                                                           ;//
                                                                                      //
        assign  in_port_data [KEEP_MSB:KEEP_LSB]  = empty_2_keep(in_interface.empty) ;// map interface signals to port data bits  
        assign  in_port_data [USER_MSB:USER_LSB]  =              in_interface.error  ;// only valid, ready, and last/eop are used for handshake  
        assign  in_port_data [START            ]  =              in_port_sop         ;//  
        assign  in_port_data [LAST             ]  =              in_interface.eop    ;//  
        assign  in_port_data [VALID            ]  =              in_interface.valid  ;//  
        assign  in_port_data [DATA_MSB:DATA_LSB]  =              in_interface.data   ;//  
        assign  in_interface.ready                =              in_port_ready       ;//  
                                                                                      //  
        assign  out_interface.empty = keep_2_empty( out_port_data[KEEP_MSB:KEEP_LSB]);//  
        assign  out_interface.error               = out_port_data[USER_MSB:USER_LSB] ;//  
        assign  out_interface.sop                 = out_port_data[START]             ;//  
        assign  out_interface.eop                 = out_port_data[LAST]              ;//
        assign  out_interface.valid               = out_port_valid                   ;//  
        assign  out_interface.data                = out_port_data[DATA_MSB:DATA_LSB] ;// 
        assign  out_port_ready                    = out_interface.ready              ;//  
        //------------------------------------------------------------------------------------------------------------------------------------------------------
        function [       D_WIDTH/8-1:0] empty_2_keep                                 ;// Function: convert avst empty to axi keep
        input    [$clog2(D_WIDTH/8) :0] empty                                        ;// Input:    avst empty field
        integer                         k                                            ;//
                                               empty_2_keep              = ~0        ;// default to all 1s
                      for (k=1; k<=empty; k++) empty_2_keep[D_WIDTH/8-k] =  0        ;// set 0 top down until reach empty value
        endfunction                                                                   //
        //------------------------------------------------------------------------------------------------------------------------------------------------------
        function [$clog2(D_WIDTH/8) :0] keep_2_empty                                 ;// Function: convert axi keep to avst empty
        input    [       D_WIDTH/8-1:0] keep                                         ;// Input:    axi keep field
        integer                         k                                            ;//
                                                   keep_2_empty = 0                  ;// default empty to 0
              for (k=1; k<D_WIDTH/8-1; k++)                                           // assumes keep is always continguous 1s then 0s
                    if (keep[k]==0 & keep[k-1]==1) keep_2_empty = D_WIDTH/8-k        ;// search 1 to 0 transition and set empty
        endfunction                                                                   //
endmodule                                                                             //
