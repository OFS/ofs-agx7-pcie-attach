// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Top level module of PCIe subsystem.
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;

module pcie_top # (
   parameter            PCIE_LANES      = 16,
   parameter            NUM_PF          = 1,
   parameter            NUM_VF          = 1,
   parameter            MAX_NUM_VF      = 1,
   parameter            MM_ADDR_WIDTH   = 19,
   parameter            MM_DATA_WIDTH   = 64,
   parameter bit [11:0] FEAT_ID         = 12'h0,
   parameter bit [3:0]  FEAT_VER        = 4'h0,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit        END_OF_LIST     = 1'b0
) (
   input  logic                    fim_clk,
   input  logic                    fim_rst_n,
   input  logic                    csr_clk,
   input  logic                    csr_rst_n,
   input  logic                    ninit_done,
   output logic                    reset_status, 
   
   // PCIe pins
   input  logic                     pin_pcie_refclk0_p,
   input  logic                     pin_pcie_refclk1_p,
   input  logic                     pin_pcie_in_perst_n,   // connected to HIP
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_p,
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_n,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_p,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_n,

   pcie_ss_axis_if.source           axi_st_rxreq_if,
   pcie_ss_axis_if.sink             axi_st_txreq_if,

   pcie_ss_axis_if.source           axi_st_rx_if,
   pcie_ss_axis_if.sink             axi_st_tx_if,

   ofs_fim_axi_lite_if.slave        csr_lite_if,
   
   // FLR interface
   output t_axis_pcie_flr           flr_req_if,
   input  t_axis_pcie_flr           flr_rsp_if,

   // Completion Timeout interface
   output t_axis_pcie_cplto         cpl_timeout_if,

   output t_sideband_from_pcie      pcie_p2c_sideband
);

pcie_ss_axis_if #(
   .DATA_W (ofs_pcie_ss_cfg_pkg::TDATA_WIDTH),
   .USER_W (ofs_pcie_ss_cfg_pkg::TUSER_WIDTH)
) st_tx_arb [2] (.clk(fim_clk), .rst_n(fim_rst_n)),
  st_tx_if      (.clk(fim_clk), .rst_n(fim_rst_n));

always_comb begin
   st_tx_arb[0].tvalid       = axi_st_txreq_if.tvalid;
   st_tx_arb[0].tdata        = axi_st_txreq_if.tdata;
   st_tx_arb[0].tlast        = axi_st_txreq_if.tlast;
   st_tx_arb[0].tkeep        = axi_st_txreq_if.tkeep;
   st_tx_arb[0].tuser_vendor = axi_st_txreq_if.tuser_vendor;
   
   st_tx_arb[1].tvalid       = axi_st_tx_if.tvalid;
   st_tx_arb[1].tdata        = axi_st_tx_if.tdata;
   st_tx_arb[1].tlast        = axi_st_tx_if.tlast;
   st_tx_arb[1].tkeep        = axi_st_tx_if.tkeep;
   st_tx_arb[1].tuser_vendor = axi_st_tx_if.tuser_vendor;

   axi_st_txreq_if.tready    = st_tx_arb[0].tready;
   axi_st_tx_if.tready       = st_tx_arb[1].tready;
end

pcie_ss_axis_mux #(
   .NUM_CH ( 2 )
) st_tx_mux (
   .clk    ( fim_clk           ),
   .rst_n  ( fim_rst_n         ),
   .sink   ( st_tx_arb     ),
   .source ( st_tx_if      )
);
   
localparam PF_WIDTH = (NUM_PF > 1) ? $clog2(NUM_PF) : 1;
localparam VF_WIDTH = (NUM_VF > 1) ? $clog2(NUM_VF) : 1;

localparam TOTAL_AVST_EW = NUM_AVST_CH*AVST_EW;
localparam TOTAL_AVST_DW  = NUM_AVST_CH*AVST_DW;

//AXI EA Interface Related Parameters
localparam EA_CH         = 2;
localparam AXI_EA_DATA_W = 392;
localparam AXI_EA_USER_W = 22;

// Clock and reset
logic avl_clk;

// EA AXI RX Streaming Interface 
logic                     axi_ea_rx_tready;
logic                     axi_ea_rx_tvalid;
logic                     axi_ea_rx_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_rx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_rx_tdata [EA_CH-1:0];

// EA AXI TX Streaming Interface 
logic                     axi_ea_tx_tready;
logic                     axi_ea_tx_tvalid;
logic                     axi_ea_tx_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_tx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_tx_tdata [EA_CH-1:0];

ofs_fim_pcie_rxs_axis_if  axis_rx_st();
ofs_fim_pcie_txs_axis_if  axis_tx_st();
ofs_fim_pcie_rxs_axis_if  axis_rxreq_st();
ofs_fim_pcie_txs_axis_if  axis_tx_null_st();

// Separate host request interface (MMIO,VDM)
// EA AXI RX Streaming Interface 
logic                     axi_ea_rxreq_tready;
logic                     axi_ea_rxreq_tvalid;
logic                     axi_ea_rxreq_tlast;
logic [AXI_EA_USER_W-1:0] axi_ea_rxreq_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0] axi_ea_rxreq_tdata [EA_CH-1:0];

// Input RX TLP from upstream
t_avst_rxs             t2b_avl_rx_st;    // AVST RX channels carrying Rx TLP from upstream logic 
logic                  b2t_avl_rx_ready; // Backpressure signal to upstream logic

t_avst_txs             b2t_avl_tx_st;
logic                  t2b_avl_tx_ready;

// Input RX request TLP from upstream
t_avst_rxs             t2b_avl_rxreq_st;    // AVST RX channels carrying Rx request from upstream logic 
logic                  b2t_avl_rxreq_ready; // Backpressure signal to upstream logic

// Error sideband signals to upstream PCIe IP
logic                  b2t_app_err_valid;    // Error is detected in the incoming TLP
logic [31:0]           b2t_app_err_hdr;      // Header of the erroneous TLP
logic [10:0]           b2t_app_err_info;     // Info of the error
logic [1:0]            b2t_app_err_func_num; // Function number associated with the erroneous TLP

// Error signals to PCIe error status registers
logic                  b2t_chk_rx_err;           // Error is detected in the incoming TLP
logic                  b2t_chk_rx_err_vf_act;    // Indicates if error is associated with PF or VF
logic [PF_WIDTH-1:0]   b2t_chk_rx_err_pfn;       // PF associated with the erroneous TLP
logic [VF_WIDTH-1:0]   b2t_chk_rx_err_vfn;       // VF associated with the erroneous TLP
logic [31:0]           b2t_chk_rx_err_code;       // Error info

// FLR signals
logic [7:0]           flr_rcvd_pf;
logic                 flr_rcvd_vf;
logic [2:0]           flr_rcvd_pf_num;
logic [10:0]          flr_rcvd_vf_num;
logic [7:0]           flr_completed_pf;
logic                 flr_completed_vf;
logic [2:0]           flr_completed_pf_num;
logic [10:0]          flr_completed_vf_num;

//-----------------------------------------------------------------------------
// Tie off unused signals
assign csr_lite_if.awready = 1'b1;
assign csr_lite_if.wready  = 1'b1;
assign csr_lite_if.arready = 1'b1;
assign csr_lite_if.bvalid  = 1'b0;
assign csr_lite_if.rvalid  = 1'b0;

integer i;

//Connecting PCIe Bridge to AXI S Adapter
always_comb
begin
    axis_rx_st.tready      = axi_ea_rx_tready;
    axi_ea_rx_tvalid       = axis_rx_st.rx.tvalid;
    axi_ea_rx_tlast        = axis_rx_st.rx.tlast;
    axi_ea_rx_tuser[0]     = axis_rx_st.rx.tuser[0];
    axi_ea_rx_tuser[1]     = axis_rx_st.rx.tuser[1];
    axi_ea_rx_tdata[0]     = axis_rx_st.rx.tdata[0];
    axi_ea_rx_tdata[1]     = axis_rx_st.rx.tdata[1];

    axis_tx_st.clk         = fim_clk;
    axis_tx_st.rst_n       = fim_rst_n;

    axi_ea_tx_tready       = axis_tx_st.tready;
    axis_tx_st.tx.tvalid   = axi_ea_tx_tvalid;
    axis_tx_st.tx.tlast    = axi_ea_tx_tlast;
    axis_tx_st.tx.tuser[0] = axi_ea_tx_tuser[0][2:0];
    axis_tx_st.tx.tuser[1] = axi_ea_tx_tuser[1][2:0];
    axis_tx_st.tx.tdata[0] = axi_ea_tx_tdata[0];
    axis_tx_st.tx.tdata[1] = axi_ea_tx_tdata[1];
end

//Connecting PCIe Bridge to AXI S req Adapter
always_comb
begin
    axis_rxreq_st.tready      = axi_ea_rxreq_tready;
    axi_ea_rxreq_tvalid       = axis_rxreq_st.rx.tvalid;
    axi_ea_rxreq_tlast        = axis_rxreq_st.rx.tlast;
    axi_ea_rxreq_tuser[0]     = axis_rxreq_st.rx.tuser[0];
    axi_ea_rxreq_tuser[1]     = axis_rxreq_st.rx.tuser[1];
    axi_ea_rxreq_tdata[0]     = axis_rxreq_st.rx.tdata[0];
    axi_ea_rxreq_tdata[1]     = axis_rxreq_st.rx.tdata[1];
    axis_tx_null_st.tx.tvalid    = '0;
end

//-----------------------
// Main test driver and logger module
//-----------------------
tester tester (
   .avl_clk                (avl_clk),
   .avl_rst_n              (~reset_status),
   .fim_clk                (fim_clk),
   .fim_rst_n              (fim_rst_n),

   //--------------------------------------
   // To PCIE bridge 
   //--------------------------------------
   // Raw RX TLP
   .o_avl_rx_st            (t2b_avl_rx_st),
   .i_avl_rx_ready         (b2t_avl_rx_ready),
   .i_avl_tx_st            (b2t_avl_tx_st),
   .o_avl_tx_ready         (t2b_avl_tx_ready),
   
   // RX req TLP
   .o_avl_rxreq_st         (t2b_avl_rxreq_st),
   .i_avl_rxreq_ready      (b2t_avl_rxreq_ready),

   // Error reporting to PCIe IP
   .i_b2a_app_err_valid    (b2t_app_err_valid),
   .i_b2a_app_err_hdr      (b2t_app_err_hdr),
   .i_b2a_app_err_info     (b2t_app_err_info),
   .i_b2a_app_err_func_num (b2t_app_err_func_num),

   // Error reporting to PCIe feature CSR
   .i_chk_rx_err           (b2t_chk_rx_err),
   .i_chk_rx_err_vf_act    (b2t_chk_rx_err_vf_act),
   .i_chk_rx_err_pfn       (b2t_chk_rx_err_pfn),
   .i_chk_rx_err_vfn       (b2t_chk_rx_err_vfn),
   .i_chk_rx_err_code      (b2t_chk_rx_err_code),

   .i_pcie_p2c_sideband    (pcie_p2c_sideband),
   .i_flr_pf_done          (flr_completed_pf),
   .o_flr_pf_active        (flr_rcvd_pf),
   .o_flr_rcvd_vf          (flr_rcvd_vf),
   .o_flr_rcvd_pf_num      (flr_rcvd_pf_num),
   .o_flr_rcvd_vf_num      (flr_rcvd_vf_num),
   .i_flr_completed_vf     (flr_completed_vf),
   .i_flr_completed_pf_num (flr_completed_pf_num),
   .i_flr_completed_vf_num (flr_completed_vf_num)
);


//-----------------------
// PCIe bridge AVST <-> AXIS
//-----------------------
pcie_bridge pcie_bridge (
   .fim_clk               (fim_clk),
   .fim_rst_n             (fim_rst_n),

   .avl_clk               (avl_clk),
   .avl_rst_n             (~reset_status),

   .avl_rx_ready          (b2t_avl_rx_ready),
   .avl_rx_st             (t2b_avl_rx_st),
   .avl_tx_ready          (t2b_avl_tx_ready),
   .avl_tx_st             (b2t_avl_tx_st),

   .fim_axis_rx_st        (axis_rx_st),
   .fim_axis_tx_st        (axis_tx_st),

   .b2a_app_err_valid     (b2t_app_err_valid),
   .b2a_app_err_hdr       (b2t_app_err_hdr),
   .b2a_app_err_info      (b2t_app_err_info),
   .b2a_app_err_func_num  (b2t_app_err_func_num),

   .chk_rx_err            (b2t_chk_rx_err),
   .chk_rx_err_vf_act     (b2t_chk_rx_err_vf_act),
   .chk_rx_err_pfn        (b2t_chk_rx_err_pfn),
   .chk_rx_err_vfn        (b2t_chk_rx_err_vfn),
   .chk_rx_err_code       (b2t_chk_rx_err_code)
);

pcie_bridge pcie_req_bridge (
   .fim_clk               (fim_clk),
   .fim_rst_n             (fim_rst_n),

   .avl_clk               (avl_clk),
   .avl_rst_n             (~reset_status),

   .avl_rx_ready          (b2t_avl_rxreq_ready),
   .avl_rx_st             (t2b_avl_rxreq_st),
   .avl_tx_ready          ('1),
   .avl_tx_st             (),

   .fim_axis_rx_st        (axis_rxreq_st),
   .fim_axis_tx_st        (axis_tx_null_st),

   .b2a_app_err_valid     (),
   .b2a_app_err_hdr       (),
   .b2a_app_err_info      (),
   .b2a_app_err_func_num  (),

   .chk_rx_err            (),
   .chk_rx_err_vf_act     (),
   .chk_rx_err_pfn        (),
   .chk_rx_err_vfn        (),
   .chk_rx_err_code       ()
);

//AXI ST EA <-> AXI ST PCIe SS
axi_s_adapter axi_s_adapter (
   .clk                   (fim_clk), 
   .resetb                (fim_rst_n),
   
   .axi_ea_rx_tready      (axi_ea_rx_tready),  
   .axi_ea_rx_tvalid      (axi_ea_rx_tvalid),     
   .axi_ea_rx_tlast       (axi_ea_rx_tlast),        
   .axi_ea_rx_tuser       (axi_ea_rx_tuser),        
   .axi_ea_rx_tdata       (axi_ea_rx_tdata),         
    
   .axi_ea_tx_tready      (axi_ea_tx_tready),       
   .axi_ea_tx_tvalid      (axi_ea_tx_tvalid),         
   .axi_ea_tx_tlast       (axi_ea_tx_tlast),         
   .axi_ea_tx_tuser       (axi_ea_tx_tuser),             
   .axi_ea_tx_tdata       (axi_ea_tx_tdata),           
                               
   .st_rx_tready          (axi_st_rx_if.tready),          
   .st_rx_tvalid          (axi_st_rx_if.tvalid),               
   .st_rx_tlast           (axi_st_rx_if.tlast),              
   .st_rx_tuser_vendor    (axi_st_rx_if.tuser_vendor),                   
   .st_rx_tdata           (axi_st_rx_if.tdata),                   
   .st_rx_tkeep           (axi_st_rx_if.tkeep),               
   
   .st_tx_tready          (st_tx_if.tready),            
   .st_tx_tvalid          (st_tx_if.tvalid),               
   .st_tx_tlast           (st_tx_if.tlast),                
   .st_tx_tuser_vendor    (st_tx_if.tuser_vendor),              
   .st_tx_tdata           (st_tx_if.tdata),                 
   .st_tx_tkeep           (st_tx_if.tkeep)               
);

axi_s_adapter axi_s_req_adapter (
   .clk                   (fim_clk), 
   .resetb                (fim_rst_n),
   
   .axi_ea_rx_tready      (axi_ea_rxreq_tready),  
   .axi_ea_rx_tvalid      (axi_ea_rxreq_tvalid),     
   .axi_ea_rx_tlast       (axi_ea_rxreq_tlast),        
   .axi_ea_rx_tuser       (axi_ea_rxreq_tuser),        
   .axi_ea_rx_tdata       (axi_ea_rxreq_tdata),         
    
   .axi_ea_tx_tready      (),       
   .axi_ea_tx_tvalid      ('0),         
   .axi_ea_tx_tlast       (),         
   .axi_ea_tx_tuser       (),             
   .axi_ea_tx_tdata       (),           
                               
   .st_rx_tready          (axi_st_rxreq_if.tready),          
   .st_rx_tvalid          (axi_st_rxreq_if.tvalid),               
   .st_rx_tlast           (axi_st_rxreq_if.tlast),              
   .st_rx_tuser_vendor    (axi_st_rxreq_if.tuser_vendor),                   
   .st_rx_tdata           (axi_st_rxreq_if.tdata),                   
   .st_rx_tkeep           (axi_st_rxreq_if.tkeep),               
   
   .st_tx_tready          ('1),            
   .st_tx_tvalid          (),               
   .st_tx_tlast           (),                
   .st_tx_tuser_vendor    (),              
   .st_tx_tdata           (),                 
   .st_tx_tkeep           ()               
);


//-------------------------------------
// FLR
//-------------------------------------
pcie_flr_resync #(
   .NUM_PF     (NUM_PF),
   .NUM_VF     (NUM_VF),
   .MAX_NUM_VF (MAX_NUM_VF)
) pcie_flr_resync (
   .avl_clk                (avl_clk), 
   .avl_rst_n              (~reset_status),

   .clk                    (csr_clk),
   .rst_n                  (csr_rst_n),

   .flr_rcvd_pf            (flr_rcvd_pf),
   .flr_rcvd_vf            (flr_rcvd_vf),
   .flr_rcvd_pf_num        (flr_rcvd_pf_num),
   .flr_rcvd_vf_num        (flr_rcvd_vf_num),
   .flr_completed_pf       (flr_completed_pf),
   .flr_completed_vf       (flr_completed_vf),
   .flr_completed_pf_num   (flr_completed_pf_num),
   .flr_completed_vf_num   (flr_completed_vf_num),

   .flr_req_if             (flr_req_if),
   .flr_rsp_if             (flr_rsp_if)
);

//-------------------------------------
// todo: Completion timeout interface 
//-------------------------------------
always_comb begin
   cpl_timeout_if.tvalid = 1'b0;
   cpl_timeout_if.tdata  = '0;
end

//-------------------------------------
// CSR clock domain crossing
//-------------------------------------
logic [31:0] rx_err_code;
logic [31:0] rx_err_code_q0;
logic [31:0] rx_err_code_q1;

// Extend error code pulse for CDC
always_ff @(posedge avl_clk) begin
   rx_err_code_q1 <= rx_err_code_q0;
   rx_err_code_q0 <= b2t_chk_rx_err_code;
end

assign rx_err_code = (rx_err_code_q1 | rx_err_code_q0);

// Synchronizer
localparam CSR_STAT_SYNC_WIDTH = 33;
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(CSR_STAT_SYNC_WIDTH),
   .INIT_VALUE(0),
   .NO_CUT(1)
) csr_resync (
   .clk   (csr_clk),
   .reset (~csr_rst_n),
   .d     ({1'b1, rx_err_code}),
   .q     ({pcie_p2c_sideband.pcie_linkup, pcie_p2c_sideband.pcie_chk_rx_err_code})
);

initial 
begin
`ifdef VCS_S10  
   `ifndef VCD_OFF
        $vcdpluson;
        $vcdplusmemon();
   `endif 
`endif
end    

//-----------------------
// Tie off unused interface
//-----------------------
initial begin
   avl_clk = 1'b0;
   reset_status = 1'b1;
   wait (~pin_pcie_in_perst_n);
   wait (pin_pcie_in_perst_n);

   #10000;
   reset_status = 1'b0;
end

always #1250 avl_clk = ~avl_clk; // 400 MHz

endmodule
