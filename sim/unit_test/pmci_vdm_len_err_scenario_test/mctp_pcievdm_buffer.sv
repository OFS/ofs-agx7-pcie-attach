// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
// MCTP over PCIe VDM buffer module of MAX10 is used to store the received or 
// to be forwarded MCTP messaged of MCTP over PCIe VDM interface. 
//-----------------------------------------------------------------------------

module mctp_pcievdm_buffer #(
   parameter   NIOS_ADDR_WIDTH             = 10,
 //parameter   NIOS_BRST_WIDTH             = 9,
   parameter   INGR_SLV_ADDR_WIDTH         = 10,
   parameter   EGRS_MSTR_ADDR_WIDTH        = 11,
   parameter   EGRS_MSTR_BRST_WIDTH        = 9,
   parameter   DEBUG_REG_EN                = 0,
   parameter   DEBUG_REG_WIDTH             = 8

)(
   input  logic                            clk,
   input  logic                            reset,
   
   //Misc
   input  logic                            pulse_1ms,
   output logic                            pci_vdm_intr,
   output logic [31:0]                     pcie_vdm_sts1_dbg,
   output logic [31:0]                     pcie_vdm_sts2_dbg,
   
   //Nios AVMM Slave
   input  logic [NIOS_ADDR_WIDTH-1:0]      avmm_nios_addr,
   input  logic                            avmm_nios_write,
   input  logic                            avmm_nios_read,
 //input  logic [NIOS_BRST_WIDTH-1:0]      avmm_nios_burstcnt,
   input  logic [31:0]                     avmm_nios_wrdata,
   output logic [31:0]                     avmm_nios_rddata,
   output logic                            avmm_nios_rddvld,
   output logic                            avmm_nios_waitreq,

   //Ingress AVMM Slave (connected to SPI Slave)
   input  logic [INGR_SLV_ADDR_WIDTH-1:0]  avmm_ingr_slv_addr,
   input  logic                            avmm_ingr_slv_write,
   input  logic                            avmm_ingr_slv_read,
   input  logic [31:0]                     avmm_ingr_slv_wrdata,
   output logic [31:0]                     avmm_ingr_slv_rddata,
   output logic                            avmm_ingr_slv_rddvld,
   output logic                            avmm_ingr_slv_waitreq,
   
   //Egress AVMM Master (connected to SPI Master)
   output logic [EGRS_MSTR_ADDR_WIDTH-1:0] avmm_egrs_mstr_addr,
   output logic                            avmm_egrs_mstr_write,
   output logic                            avmm_egrs_mstr_read,
   output logic [EGRS_MSTR_BRST_WIDTH-1:0] avmm_egrs_mstr_burstcnt,
   output logic [31:0]                     avmm_egrs_mstr_wrdata,
   input  logic [31:0]                     avmm_egrs_mstr_rddata,
   input  logic                            avmm_egrs_mstr_rddvld,
   input  logic                            avmm_egrs_mstr_waitreq
);

localparam  INGR_CNS_REG_ADDR       = 10'h0;  //M10's Ingress Control and status register address
localparam  INGR_PH_REG_ADDR        = 10'h1;  //M10's Ingress Packet Header register address
localparam  EGRS_CNS_REG_ADDR       = 10'h4;  //M10's Egress Control and status register address
localparam  EGRS_PH_REG_ADDR        = 10'h5;  //M10's Egress Packet Header register address
localparam  VDM_TIMER_REG_ADDR      = 10'h8;  //M10's PCIe VDM Timer register address
localparam  PMCI_EGRS_CNS_REG_ADDR  = 11'h0;  //PMCI's Ingress Control and status register address
localparam  PMCI_EGRS_PH_REG_ADDR   = 11'h4;  //PMCI's Ingress Packet Headre register address
localparam  PMCI_EGRS_PKT_BFR_ADDR  = 11'h400;//PMCI's Ingress Packet Buffer address

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
enum {
   TX_RESET_BIT      = 0,
   TX_IDLE_BIT       = 1,
   TX_CHK_BUSY_BIT   = 2,
   TX_WR_PLOAD_BIT   = 3,
   TX_WR_HDR_BIT     = 4,
   TX_WR_CTRL_BIT    = 5
} tx_state_bit;

enum logic [5:0] {
   TX_RESET_ST       = 6'h1 << TX_RESET_BIT   ,
   TX_IDLE_ST        = 6'h1 << TX_IDLE_BIT    ,
   TX_CHK_BUSY_ST    = 6'h1 << TX_CHK_BUSY_BIT,
   TX_WR_PLOAD_ST    = 6'h1 << TX_WR_PLOAD_BIT,
   TX_WR_HDR_ST      = 6'h1 << TX_WR_HDR_BIT  ,
   TX_WR_CTRL_ST     = 6'h1 << TX_WR_CTRL_BIT 
} tx_state, tx_next, tx_state_r1;

logic          ingr_msg_avail_set   ;
logic          ingr_bdf_init_set    ;
logic [1:0]    ingr_pad_len_reg     ;
logic [8:0]    ingr_msg_len_reg     ;
logic [15:0]   ingr_pcie_reqid_reg  ;
logic [7:0]    ingr_src_eid_reg     ;
logic [3:0]    ingr_msg_tag_reg     ;
logic          ingr_mulitpkt_reg    ;
logic          ingr_pcie_route_reg  ;
logic [1:0]    ingr_dst_eid_reg     ;
logic          ingr_msg_avail_reg   ;
logic          ingr_bdf_init_reg    ;
logic          timer_intr_reg       ;
logic          ingr_nios_busy_reg   ;
logic          egrs_msg_avail_reg   ;
logic [1:0]    egrs_pad_len_reg     ;
logic [8:0]    egrs_msg_len_reg     ;
logic [15:0]   egrs_pcie_tarid_reg  ;
logic [7:0]    egrs_dst_eid_reg     ;
logic [3:0]    egrs_msg_tag_reg     ;
logic          egrs_src_neid_reg    ;
logic          egrs_pcie_route_reg  ;
logic          timer_en_reg         ;
logic          timer_en_reg_r1      ;
logic [7:0]    timer_value_reg      ;
logic          nios_ingr_bfr_read   ;
logic          nios_egrs_bfr_read   ;
logic          nios_ingr_bfr_rdvld  ;
logic          nios_egrs_bfr_rdvld  ;
logic [7:0]    vdm_timer            ;
logic          vdm_time_out         ;
logic [7:0]    ingr_bfr_a_addr      ;
logic [31:0]   ingr_bfr_a_wrdata    ;
logic          ingr_bfr_a_wren      ;
logic [8:0]    egrs_bfr_rdaddr      ;
logic [7:0]    egrs_bfr_a_addr      ;
logic          egrs_bfr_rddone      ;
logic          egrs_bfr_rden        ;
logic          egrs_bfr_rden_r1     ;
logic          egrs_bfr_rdvld       ;
logic [7:0]    ingr_bfr_b_addr      ;
logic [7:0]    egrs_bfr_b_addr      ;
logic [31:0]   egrs_bfr_b_wrdata    ;
logic          egrs_bfr_b_wren      ;
logic [31:0]   ingr_bfr_b_rddata    ;
logic [31:0]   egrs_bfr_a_rddata    ;
logic [31:0]   egrs_bfr_b_rddata    ;
logic          dly_busy_rechk       ;
logic [5:0]    dly_busy_rechk_cntr  ;

//-----------------------------------------------------------------------------
// Ingress (PMCI) AVMM slave register implementation
//-----------------------------------------------------------------------------
always @ (posedge clk or posedge reset)
begin : ingr_avmm_wr
   if(reset) begin
      ingr_msg_avail_set  <= 1'b0;
      ingr_bdf_init_set   <= 1'b0;
      ingr_pad_len_reg    <= 2'd0;
      ingr_msg_len_reg    <= 9'd0;
      ingr_pcie_reqid_reg <= 16'd0;
      ingr_src_eid_reg    <= 8'd0;
      ingr_msg_tag_reg    <= 4'd0;
      ingr_mulitpkt_reg   <= 1'b0;
      ingr_pcie_route_reg <= 1'b0;
      ingr_dst_eid_reg    <= 2'd0;
   end else begin
      if(avmm_ingr_slv_addr == INGR_CNS_REG_ADDR && avmm_ingr_slv_write) begin
         ingr_msg_avail_set   <= avmm_ingr_slv_wrdata[0];
         ingr_bdf_init_set    <= avmm_ingr_slv_wrdata[1];
         ingr_pad_len_reg     <= avmm_ingr_slv_wrdata[9:8];
         ingr_msg_len_reg     <= avmm_ingr_slv_wrdata[18:10];
      end else begin
         ingr_msg_avail_set   <= 1'b0;
         ingr_bdf_init_set    <= 1'b0;
      end
      
      if(avmm_ingr_slv_addr == INGR_PH_REG_ADDR && avmm_ingr_slv_write) begin
         ingr_pcie_reqid_reg <= avmm_ingr_slv_wrdata[15:0];
         ingr_src_eid_reg    <= avmm_ingr_slv_wrdata[23:16];
         ingr_msg_tag_reg    <= avmm_ingr_slv_wrdata[27:24];
         ingr_mulitpkt_reg   <= avmm_ingr_slv_wrdata[28];
         ingr_pcie_route_reg <= avmm_ingr_slv_wrdata[29];
         ingr_dst_eid_reg    <= avmm_ingr_slv_wrdata[31:30];
      end
   end 
end : ingr_avmm_wr

always_ff @(posedge clk, posedge reset)
begin : ingr_avmm_rd
   if(reset) begin
      avmm_ingr_slv_rddvld    <= 1'b0;
      avmm_ingr_slv_rddata    <= 32'd0;
      avmm_ingr_slv_waitreq   <= 1'b1;
   end else begin
      avmm_ingr_slv_rddvld    <= avmm_ingr_slv_read;
      avmm_ingr_slv_rddata    <= 32'd0;
      avmm_ingr_slv_rddata[4] <= ingr_nios_busy_reg | ingr_bdf_init_reg | ingr_msg_avail_reg;
      avmm_ingr_slv_waitreq   <= 1'b0;
   end
end : ingr_avmm_rd

//-----------------------------------------------------------------------------
// Nios AVMM slave register write implementation
//-----------------------------------------------------------------------------
always @ (posedge clk or posedge reset)
begin : nios_avmm_wr
   if(reset) begin
      ingr_msg_avail_reg   <= 1'b0;
      ingr_bdf_init_reg    <= 1'b0;
      timer_intr_reg       <= 1'b0;
      ingr_nios_busy_reg   <= 1'b0;
      egrs_msg_avail_reg   <= 1'b0;
      egrs_pad_len_reg     <= 2'd0;
      egrs_msg_len_reg     <= 9'd0;
      egrs_pcie_tarid_reg  <= 16'd0;
      egrs_dst_eid_reg     <= 8'd0;
      egrs_msg_tag_reg     <= 4'd0;
      egrs_src_neid_reg    <= 1'b0;
      egrs_pcie_route_reg  <= 1'b0;
      timer_value_reg      <= 8'd200;
      timer_en_reg         <= 1'b0;
   end else begin
      if(ingr_msg_avail_set)
         ingr_msg_avail_reg   <= 1'b1;
      else if(avmm_nios_addr == INGR_CNS_REG_ADDR && 
              avmm_nios_write && !avmm_nios_waitreq && avmm_nios_wrdata[0])
         ingr_msg_avail_reg   <= 1'b0;
      
      if(ingr_bdf_init_set)
         ingr_bdf_init_reg    <= 1'b1;
      else if(avmm_nios_addr == INGR_CNS_REG_ADDR && 
              avmm_nios_write && !avmm_nios_waitreq && avmm_nios_wrdata[1])
         ingr_bdf_init_reg    <= 1'b0;
      
      if(vdm_time_out)
         timer_intr_reg       <= 1'b1;
      else if(avmm_nios_addr == INGR_CNS_REG_ADDR && 
              avmm_nios_write && !avmm_nios_waitreq && avmm_nios_wrdata[2])
         timer_intr_reg       <= 1'b0;

      if(avmm_nios_addr == INGR_CNS_REG_ADDR && avmm_nios_write && 
                                               !avmm_nios_waitreq)
         ingr_nios_busy_reg   <= avmm_nios_wrdata[4];
         
      if(avmm_nios_addr == EGRS_CNS_REG_ADDR && avmm_nios_write && 
                                               !avmm_nios_waitreq) begin
         egrs_msg_avail_reg   <= avmm_nios_wrdata[0];
         egrs_pad_len_reg     <= avmm_nios_wrdata[5:4];
         egrs_msg_len_reg     <= avmm_nios_wrdata[14:6];
      end else
         egrs_msg_avail_reg   <= 1'b0;
         
      if(avmm_nios_addr == EGRS_PH_REG_ADDR && avmm_nios_write && 
                                               !avmm_nios_waitreq) begin
         egrs_pcie_tarid_reg  <= avmm_nios_wrdata[15:0];
         egrs_dst_eid_reg     <= avmm_nios_wrdata[23:16];
         egrs_msg_tag_reg     <= avmm_nios_wrdata[27:24];
         egrs_src_neid_reg    <= avmm_nios_wrdata[28];
         egrs_pcie_route_reg  <= avmm_nios_wrdata[29];
      end
         
      if(avmm_nios_addr == VDM_TIMER_REG_ADDR && avmm_nios_write && 
                                               !avmm_nios_waitreq) begin
         timer_value_reg      <= avmm_nios_wrdata[7:0];
         timer_en_reg         <= avmm_nios_wrdata[31];
      end else if(vdm_time_out)
         timer_en_reg         <= 1'b0;
   end 
end : nios_avmm_wr

assign pci_vdm_intr = ingr_msg_avail_reg | ingr_bdf_init_reg | timer_intr_reg;


//-----------------------------------------------------------------------------
// Nios AVMM slave register read implementation
//-----------------------------------------------------------------------------
always_ff @(posedge clk, posedge reset)
begin : nios_avmm_rd
   if(reset) begin
      nios_ingr_bfr_read     <= 1'b0;
      nios_egrs_bfr_read     <= 1'b0;
      nios_ingr_bfr_rdvld  <= 1'b0;
      nios_egrs_bfr_rdvld  <= 1'b0;
      avmm_nios_rddvld       <= 1'b0;
      avmm_nios_rddata       <= 32'd0;
      avmm_nios_waitreq      <= 1'b1;
   end else begin
      if(avmm_nios_read && avmm_nios_addr[9] && !avmm_nios_waitreq) begin
         avmm_nios_waitreq   <= 1'b1;
         nios_ingr_bfr_read  <= ~avmm_nios_addr[8];
         nios_egrs_bfr_read  <= avmm_nios_addr[8];
      end else begin
         avmm_nios_waitreq   <= 1'b0;
         nios_ingr_bfr_read  <= 1'b0;
         nios_egrs_bfr_read  <= 1'b0;
      end
      
      nios_ingr_bfr_rdvld    <= nios_ingr_bfr_read;
      nios_egrs_bfr_rdvld    <= nios_egrs_bfr_read;
      
      if(avmm_nios_read && !avmm_nios_waitreq && !avmm_nios_addr[9] || 
                                 nios_ingr_bfr_rdvld || nios_egrs_bfr_rdvld)
         avmm_nios_rddvld <= 1'b1;
      else
         avmm_nios_rddvld <= 1'b0;
      
      if(nios_ingr_bfr_rdvld)
         avmm_nios_rddata  <= ingr_bfr_b_rddata;
      else if(nios_egrs_bfr_rdvld)
         avmm_nios_rddata  <= egrs_bfr_b_rddata;
      else if (avmm_nios_read && !avmm_nios_waitreq && !avmm_nios_addr[9]) begin
         case(avmm_nios_addr)
            INGR_CNS_REG_ADDR : 
               avmm_nios_rddata  <= {12'd0,                  //[31:20]	Reserved
                                     1'b0, ingr_msg_len_reg, //[19:10]	Rx packet size in DWORDs
                                     ingr_pad_len_reg,       //[9:8]    Rx packet pad length
                                     3'd0,                   //[7:5]    Reserved
                                     ingr_nios_busy_reg,     //[4]      M10 Nios busy indication
                                     1'b0,                   //[3]      Reserved
                                     timer_intr_reg,         //[2]      PCIe VDM timer expired interrupt
                                     ingr_bdf_init_reg,      //[1]      PCIe BDF initialized/changed interrupt
                                     ingr_msg_avail_reg};    //[0]      Receive packet available interrupt

            INGR_PH_REG_ADDR  : 
               avmm_nios_rddata  <= {ingr_dst_eid_reg   , //[31:30]  Destination ID of Rx packet
                                     ingr_pcie_route_reg, //[29]     PCIe VDM route indication
                                     ingr_mulitpkt_reg  , //[28]     Multipacket message indication
                                     ingr_msg_tag_reg   , //[27:24]  TO & Message tag of Rx MCTP packet
                                     ingr_src_eid_reg   , //[23:16]   Source EID of Rx packet
                                     ingr_pcie_reqid_reg};//[15:0]   PCIe requester ID of Rx packet

            EGRS_CNS_REG_ADDR : 
               avmm_nios_rddata  <= {16'd0,                  //[31:16]  Reserved
                                     1'b0, egrs_msg_len_reg, //[15:6]   Tx packet size in DWORDs
                                     egrs_pad_len_reg,       //[5:4]    Tx packet pad length
                                     2'd0,                   //[3:2]    Reserved
                                     ~tx_state[TX_IDLE_BIT], //[1]      M10 PCIeVDM module (RTL module) is busy
                                     egrs_msg_avail_reg};    //[0]      Tx packet available in Tx buffer.

            EGRS_PH_REG_ADDR  : 
               avmm_nios_rddata  <= {2'd0,                //[31:30]  Reserved
                                     egrs_pcie_route_reg, //[29]     PCIe VDM routing
                                     egrs_src_neid_reg,   //[28]     Null Source EID
                                     egrs_msg_tag_reg,    //[27:24]  TO & Message tag of Tx MCTP packet
                                     egrs_dst_eid_reg,    //[23:16]  Destination EID of Tx packet
                                     egrs_pcie_tarid_reg};//[15:0]   PCIe target ID of Tx packet
            
            VDM_TIMER_REG_ADDR  : 
               avmm_nios_rddata  <= {timer_en_reg,        //[31]     PCIe VDM timer enable
                                     23'd0,               //[30:8]   Reserved
                                     timer_value_reg};    //[7:0]    PCIe VDM timer load value

            default           : avmm_nios_rddata  <= 32'hABADABAD;
         endcase
      end
   end
end : nios_avmm_rd


//-----------------------------------------------------------------------------
// PCIe VDM Timer implementation
//-----------------------------------------------------------------------------
always_ff @(posedge clk, posedge reset)
begin : vdm_timer_seq
   if (reset) begin
      vdm_timer         <= 8'd0;
      vdm_time_out      <= 1'b0;
      timer_en_reg_r1   <= 1'b0;
   end else begin
      timer_en_reg_r1   <= timer_en_reg;
      
      if(!timer_en_reg_r1)
         vdm_timer      <= timer_value_reg;
      else if(pulse_1ms)
         vdm_timer      <= vdm_timer - 1'b1;
      
      if(vdm_timer == 8'd1 && pulse_1ms)
         vdm_time_out   <= 1'b1;
      else 
         vdm_time_out   <= 1'b0;
   end
end : vdm_timer_seq


//-----------------------------------------------------------------------------
// Egress MCTP/PCIe-VDM message transmit FSM.
// This FSM reads the MCTP payload stored in the buffer and transmits
// or pushes it to PMCI's MCTP over PCIe VDM Controller module.
// Top "always_ff" simply switches the state of the state machine registers.
// Following "always_comb" contains all of the next-state decoding logic.
//-----------------------------------------------------------------------------
always_ff @(posedge clk, posedge reset)
begin : tx_fsm_seq
   if (reset) begin
      tx_state    <= TX_RESET_ST;
      tx_state_r1 <= TX_RESET_ST;
   end else begin
      tx_state    <= tx_next;
      tx_state_r1 <= tx_state;
   end   
end : tx_fsm_seq

always_comb
begin : tx_fsm_comb
   tx_next = tx_state;
   unique case (1'b1) //Reverse Case Statement
      tx_state[TX_RESET_BIT]:   //TX_RESET_ST
         if (reset)
            tx_next = TX_RESET_ST;
         else
            tx_next = TX_IDLE_ST;
      
      tx_state[TX_IDLE_BIT]:   //TX_IDLE_ST
         if (egrs_msg_avail_reg)
            tx_next = TX_CHK_BUSY_ST;
      
      tx_state[TX_CHK_BUSY_BIT]:   //TX_CHK_BUSY_ST
         if(avmm_egrs_mstr_rddvld && !avmm_egrs_mstr_rddata[1])
            tx_next = TX_WR_PLOAD_ST;
            
      tx_state[TX_WR_PLOAD_BIT]:   //TX_WR_PLOAD_ST
         if(egrs_bfr_rddone && !avmm_egrs_mstr_waitreq && avmm_egrs_mstr_write)
            tx_next = TX_WR_HDR_ST;

      tx_state[TX_WR_HDR_BIT]:   //TX_WR_HDR_ST  
         if(!avmm_egrs_mstr_waitreq && avmm_egrs_mstr_write)
            tx_next = TX_WR_CTRL_ST;

      tx_state[TX_WR_CTRL_BIT]:   //TX_WR_CTRL_ST 
         if(!avmm_egrs_mstr_waitreq && avmm_egrs_mstr_write)
            tx_next = TX_IDLE_ST;
   endcase
end : tx_fsm_comb


//-----------------------------------------------------------------------------
// Ingress PCIe VDM Buffer Port-A control (write only) logic
//-----------------------------------------------------------------------------
always_ff @(posedge clk, posedge reset)
begin : ingr_bfr_wr
   if (reset) begin
      ingr_bfr_a_addr   <= 8'd0;
      ingr_bfr_a_wrdata <= 32'd0;
      ingr_bfr_a_wren   <= 1'b0;
   end else begin
      ingr_bfr_a_addr   <= avmm_ingr_slv_addr[7:0];
      ingr_bfr_a_wrdata <= avmm_ingr_slv_wrdata;
      ingr_bfr_a_wren   <= avmm_ingr_slv_write & avmm_ingr_slv_addr[9] & 
                                                !avmm_ingr_slv_addr[8];
   end
end : ingr_bfr_wr 


//-----------------------------------------------------------------------------
// Egress PCIe VDM Buffer Port-A control (read only) logic
//-----------------------------------------------------------------------------
always_ff @(posedge clk, posedge reset)
begin : egrs_bfr_rd
   if (reset) begin
      egrs_bfr_rdaddr   <= 9'd0;
      egrs_bfr_rddone   <= 1'b0;
      egrs_bfr_rden     <= 1'b0;
      egrs_bfr_rden_r1  <= 1'b0;
      egrs_bfr_rdvld    <= 1'b0;
   end else begin
      //if(tx_state[TX_WR_PLOAD_BIT] && (egrs_bfr_rdaddr < egrs_msg_len_reg) && 
      //                        !avmm_egrs_mstr_waitreq && avmm_egrs_mstr_write) // && !egrs_bfr_rddone)
      //   egrs_bfr_rddone   <= 1'b1;
      //else 
      //   egrs_bfr_rddone   <= 1'b0;
      if(egrs_bfr_rdaddr == (egrs_msg_len_reg - 1'b1))
         egrs_bfr_rddone   <= 1'b1;
      else 
         egrs_bfr_rddone   <= 1'b0;
      
      if(!tx_state[TX_WR_PLOAD_BIT])
         egrs_bfr_rdaddr   <= 8'd0;
      else if(!egrs_bfr_rddone && !avmm_egrs_mstr_waitreq && avmm_egrs_mstr_write)
         egrs_bfr_rdaddr   <= egrs_bfr_rdaddr + 1'b1;
      
      if(!egrs_bfr_rddone && !avmm_egrs_mstr_waitreq && avmm_egrs_mstr_write)
         egrs_bfr_rden     <= 1'b1;
      else
         egrs_bfr_rden     <= 1'b0;
         
      egrs_bfr_rden_r1     <= egrs_bfr_rden;
      
      if(tx_state[TX_WR_PLOAD_BIT] && (!tx_state_r1[TX_WR_PLOAD_BIT] || egrs_bfr_rden_r1))
         egrs_bfr_rdvld    <= 1'b1;
      else 
         egrs_bfr_rdvld    <= 1'b0;
   end
end : egrs_bfr_rd

assign egrs_bfr_a_addr = egrs_bfr_rdaddr[7:0];


//-----------------------------------------------------------------------------
// Ingress and Egress Buffer Port-B control logic
//-----------------------------------------------------------------------------
always_comb
begin : bfr_portb_ctrl
   ingr_bfr_b_addr   = avmm_nios_addr[7:0];
   
   egrs_bfr_b_addr   = avmm_nios_addr[7:0];
   egrs_bfr_b_wrdata = avmm_nios_wrdata;
   egrs_bfr_b_wren   = avmm_nios_addr[9] & avmm_nios_addr[8] & avmm_nios_write;
end : bfr_portb_ctrl


//-----------------------------------------------------------------------------
// PCIe VDM Ingress Buffer : Stores Ingress MCTP message payloads
// Port-A is used by this module to write the Ingress MCTP message
// Port-B is used by MAX10 Nios to read the Ingress MCTP message
//-----------------------------------------------------------------------------
altsyncram ingress_buffer(
   .address_a        (ingr_bfr_a_addr  ),
   .address_b        (ingr_bfr_b_addr  ),
   .clock0           (clk              ),
   .data_a           (ingr_bfr_a_wrdata),
   .wren_a           (ingr_bfr_a_wren  ),
   .q_b              (ingr_bfr_b_rddata),
   .aclr0            (1'b0             ),
   .aclr1            (1'b0             ),
   .addressstall_a   (1'b0             ),
   .addressstall_b   (1'b0             ),
   .byteena_a        (1'b1             ),
   .byteena_b        (1'b1             ),
   .clock1           (1'b1             ),
   .clocken0         (1'b1             ),
   .clocken1         (1'b1             ),
   .clocken2         (1'b1             ),
   .clocken3         (1'b1             ),
   .data_b           ({32{1'b1}}       ),
   .eccstatus        (                 ),
   .q_a              (                 ),
   .rden_a           (1'b1             ),
   .rden_b           (1'b1             ),
   .wren_b           (1'b0             ));
   
defparam
   ingress_buffer.address_aclr_b = "NONE",
   ingress_buffer.address_reg_b = "CLOCK0",
   ingress_buffer.clock_enable_input_a = "BYPASS",
   ingress_buffer.clock_enable_input_b = "BYPASS",
   ingress_buffer.clock_enable_output_b = "BYPASS",
   ingress_buffer.intended_device_family = "MAX 10",
   ingress_buffer.lpm_type = "altsyncram",
   ingress_buffer.numwords_a = 256,
   ingress_buffer.numwords_b = 256,
   ingress_buffer.operation_mode = "DUAL_PORT",
   ingress_buffer.outdata_aclr_b = "NONE",
   ingress_buffer.outdata_reg_b = "CLOCK0",
   ingress_buffer.power_up_uninitialized = "FALSE",
   ingress_buffer.read_during_write_mode_mixed_ports = "DONT_CARE",
   ingress_buffer.widthad_a = 8,
   ingress_buffer.widthad_b = 8,
   ingress_buffer.width_a = 32,
   ingress_buffer.width_b = 32,
   ingress_buffer.width_byteena_a = 1;

//-----------------------------------------------------------------------------
// PCIe VDM Buffer : Stores Egress MCTP message payloads
// Port-A is used by this module to read the Egress MCTP message
// Port-B is used by MAX10 Nios to write (& read) the Egress MCTP message
//-----------------------------------------------------------------------------
altsyncram egress_buffer (
   .address_a        (egrs_bfr_a_addr  ),
   .address_b        (egrs_bfr_b_addr  ),
   .clock0           (clk              ),
   .data_a           ({32{1'b1}}       ),
   .data_b           (egrs_bfr_b_wrdata),
   .wren_a           (1'b0             ),
   .wren_b           (egrs_bfr_b_wren  ),
   .q_a              (egrs_bfr_a_rddata),
   .q_b              (egrs_bfr_b_rddata),
   .aclr0            (1'b0             ),
   .aclr1            (1'b0             ),
   .addressstall_a   (1'b0             ),
   .addressstall_b   (1'b0             ),
   .byteena_a        (1'b1             ),
   .byteena_b        (1'b1             ),
   .clock1           (1'b1             ),
   .clocken0         (1'b1             ),
   .clocken1         (1'b1             ),
   .clocken2         (1'b1             ),
   .clocken3         (1'b1             ),
   .eccstatus        (                 ),
   .rden_a           (1'b1             ),
   .rden_b           (1'b1             ));
   
defparam
   egress_buffer.address_reg_b = "CLOCK0",
   egress_buffer.clock_enable_input_a = "BYPASS",
   egress_buffer.clock_enable_input_b = "BYPASS",
   egress_buffer.clock_enable_output_a = "BYPASS",
   egress_buffer.clock_enable_output_b = "BYPASS",
   egress_buffer.indata_reg_b = "CLOCK0",
   egress_buffer.intended_device_family = "MAX 10",
   egress_buffer.lpm_type = "altsyncram",
   egress_buffer.numwords_a = 256,
   egress_buffer.numwords_b = 256,
   egress_buffer.operation_mode = "BIDIR_DUAL_PORT",
   egress_buffer.outdata_aclr_a = "NONE",
   egress_buffer.outdata_aclr_b = "NONE",
   egress_buffer.outdata_reg_a = "CLOCK0",
   egress_buffer.outdata_reg_b = "CLOCK0",
   egress_buffer.power_up_uninitialized = "FALSE",
   egress_buffer.read_during_write_mode_mixed_ports = "DONT_CARE",
   egress_buffer.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
   egress_buffer.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
   egress_buffer.widthad_a = 8,
   egress_buffer.widthad_b = 8,
   egress_buffer.width_a = 32,
   egress_buffer.width_b = 32,
   egress_buffer.width_byteena_a = 1,
   egress_buffer.width_byteena_b = 1,
   egress_buffer.wrcontrol_wraddress_reg_b = "CLOCK0";


//-----------------------------------------------------------------------------
// Egress AVMM master generation
//-----------------------------------------------------------------------------
always_ff @(posedge clk, posedge reset)
begin : egrs_avmm_mstr
   if (reset) begin
      avmm_egrs_mstr_addr     <= {EGRS_MSTR_ADDR_WIDTH{1'b0}};
      avmm_egrs_mstr_write    <= 1'b0;
      avmm_egrs_mstr_read     <= 1'b0;
      avmm_egrs_mstr_burstcnt <= {EGRS_MSTR_BRST_WIDTH{1'b0}};
      avmm_egrs_mstr_wrdata   <= 32'd0;
      dly_busy_rechk          <= 1'b0;
      dly_busy_rechk_cntr     <= 6'd0;
   end else begin
      if(tx_state[TX_WR_PLOAD_BIT] && egrs_bfr_rdvld || 
         tx_state[TX_WR_HDR_BIT]   && !tx_state_r1[TX_WR_HDR_BIT] ||
         tx_state[TX_WR_CTRL_BIT]  && !tx_state_r1[TX_WR_CTRL_BIT])
         avmm_egrs_mstr_write <= 1'b1;
      else if(!avmm_egrs_mstr_waitreq)
         avmm_egrs_mstr_write <= 1'b0;
      
      if(!tx_state[TX_CHK_BUSY_BIT] || avmm_egrs_mstr_read)
         dly_busy_rechk <= 1'b0;
      else if(avmm_egrs_mstr_rddvld && avmm_egrs_mstr_rddata[1])
         dly_busy_rechk <= 1'b1;
      
      if(!dly_busy_rechk)
         dly_busy_rechk_cntr <= 6'd0;
      else 
         dly_busy_rechk_cntr <= dly_busy_rechk_cntr - 1'b1;
      
      if(tx_state[TX_CHK_BUSY_BIT] && !tx_state_r1[TX_CHK_BUSY_BIT] ||
         //avmm_egrs_mstr_rddvld && !avmm_egrs_mstr_rddata[4]) //no delay
         dly_busy_rechk && dly_busy_rechk_cntr == 6'd1)
         avmm_egrs_mstr_read  <= 1'b1;
      else if(!avmm_egrs_mstr_waitreq)
         avmm_egrs_mstr_read  <= 1'b0;
      
      if(tx_state[TX_WR_PLOAD_BIT])
         avmm_egrs_mstr_addr  <= PMCI_EGRS_PKT_BFR_ADDR;
      else if(tx_state[TX_WR_HDR_BIT])
         avmm_egrs_mstr_addr  <= PMCI_EGRS_PH_REG_ADDR;
      else 
         avmm_egrs_mstr_addr  <= PMCI_EGRS_CNS_REG_ADDR;
      
      if(tx_state[TX_WR_PLOAD_BIT])
         avmm_egrs_mstr_burstcnt  <= egrs_msg_len_reg;
      else 
         avmm_egrs_mstr_burstcnt  <= 'd1;
      
      if(tx_state[TX_WR_PLOAD_BIT])
         avmm_egrs_mstr_wrdata <= egrs_bfr_a_rddata;
      else if(tx_state[TX_WR_HDR_BIT])
         avmm_egrs_mstr_wrdata <= {2'd0,                //[31:30]  Reserved
                                   egrs_pcie_route_reg, //[29]     PCIe VDM routing
                                   egrs_src_neid_reg,   //[28]     Null Source EID
                                   egrs_msg_tag_reg,    //[27:24]  TO & Message tag of Tx MCTP packet
                                   egrs_dst_eid_reg,    //[23:16]  Destination EID of Tx packet
                                   egrs_pcie_tarid_reg};//[15:0]   PCIe target ID of Tx packet
      else 
         avmm_egrs_mstr_wrdata <= {16'd0,                  //[31:16] Reserved
                                   1'b0, egrs_msg_len_reg, //[15:6]  Tx packet size in bytes
                                   egrs_pad_len_reg,       //[5:4]   Tx packet pad length
                                   2'd0,                   //[3:2]   Reserved
                                   1'b0,                   //[1]     PCIeVDM Tx (RTL) module  is busy
                                   1'b1};                  //[0]     Tx packet available in Tx buffer.
   end
end : egrs_avmm_mstr


//-----------------------------------------------------------------------------
// Debug registers
//-----------------------------------------------------------------------------
generate 
if (DEBUG_REG_EN == 1) begin
   logic [DEBUG_REG_WIDTH-2:0] msg_rx_cntr_dbg_i  ;
   logic                       msg_rx_of_dbg_i    ;
   logic [DEBUG_REG_WIDTH-2:0] msg_tx_cntr_dbg_i  ;
   logic                       msg_tx_of_dbg_i    ;
   
   always_ff @(posedge clk, posedge reset)
   begin : dbg_reg
      if (reset) begin
         msg_rx_cntr_dbg_i   <= 'd0;
         msg_rx_of_dbg_i     <= 1'b0;
         msg_tx_cntr_dbg_i   <= 'd0;
         msg_tx_of_dbg_i     <= 1'b0;
      end else begin
         //Total number of MCTP messages received
         if(ingr_msg_avail_set)
            msg_rx_cntr_dbg_i <= msg_rx_cntr_dbg_i + 1'b1;
         
         if(ingr_msg_avail_set && (&msg_rx_cntr_dbg_i))
            msg_rx_of_dbg_i   <= 1'b1;
         
         //Total number of TLPs transmitted
         if(tx_state[TX_WR_CTRL_BIT] &&
                               !avmm_egrs_mstr_waitreq && avmm_egrs_mstr_write)
            msg_tx_cntr_dbg_i <= msg_tx_cntr_dbg_i + 1'b1;
         
         if(tx_state[TX_WR_CTRL_BIT] && !avmm_egrs_mstr_waitreq && 
                                  avmm_egrs_mstr_write && (&msg_tx_cntr_dbg_i))
            msg_tx_of_dbg_i   <= 1'b1;
      end
   end : dbg_reg
   
   assign pcie_vdm_sts1_dbg       = {21'd0,
                                     ingr_nios_busy_reg, //[10]  - Nios busy
                                     ingr_bdf_init_reg,  //[9]   - BDF assigned interrupt
                                     ingr_msg_avail_reg, //[8]   - Ingress messsage avail
                                     2'd0,               //[7:6] - Reserved
                                     tx_state};          //[5:0] - Egress transmit FSM state
   
   assign pcie_vdm_sts2_dbg       = {msg_tx_of_dbg_i, {(16-DEBUG_REG_WIDTH){1'b0}}, msg_tx_cntr_dbg_i,
                                     msg_rx_of_dbg_i, {(16-DEBUG_REG_WIDTH){1'b0}}, msg_rx_cntr_dbg_i};
end else begin
   assign pcie_vdm_sts1_dbg       = 32'hABADABAD; //32'd0;
   assign pcie_vdm_sts2_dbg       = 32'hABADABAD; //32'd0;
end
endgenerate

endmodule