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

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import pcie_ss_axis_pkg::*;

module pcie_ss_top # (
   parameter PCIE_LANES = 16,
   parameter SOC_ATTACH = 0
)(

   input  logic                     fim_clk,
   input  logic                     fim_rst_n,
   input  logic                     csr_clk,
   input  logic                     csr_rst_n,
   input  logic                     ninit_done,
   output logic                     reset_status,

   input  logic                     p0_subsystem_cold_rst_n,  
   input  logic                     p0_subsystem_warm_rst_n,    
   output logic                     p0_subsystem_cold_rst_ack_n,
   output logic                     p0_subsystem_warm_rst_ack_n,

   // PCIe pins
   input  logic                     pin_pcie_refclk0_p,
   input  logic                     pin_pcie_refclk1_p,
   input  logic                     pin_pcie_in_perst_n,   // connected to HIP
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_p,
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_n,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_p,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_n,

   //TXREQ ports
   output logic                     p0_ss_app_st_txreq_tready,
   input  logic                     p0_app_ss_st_txreq_tvalid,
   input  logic [255:0]             p0_app_ss_st_txreq_tdata,
   input  logic                     p0_app_ss_st_txreq_tlast,

   //Ctrl Shadow ports
   output logic                     p0_ss_app_st_ctrlshadow_tvalid,
   output logic [39:0]              p0_ss_app_st_ctrlshadow_tdata,

   // Application to FPGA request port (MMIO/VDM)
   pcie_ss_axis_if.source           axi_st_rxreq_if,

   // FPGA to application request/response ports (DM req/rsp, MMIO rsp)
   pcie_ss_axis_if.source           axi_st_rx_if,
   pcie_ss_axis_if.sink             axi_st_tx_if,
   
   ofs_fim_axi_lite_if.slave        ss_csr_lite_if,
   ofs_fim_axi_lite_if.master       ss_init_lite_if,

   // FLR interface
   output t_axis_pcie_flr           flr_req_if,
   input  t_axis_pcie_flr           flr_rsp_if,

   // Completion Timeout interface
   output t_axis_pcie_cplto         cpl_timeout_if,

   output t_sideband_from_pcie      pcie_p2c_sideband
);

import ofs_fim_pcie_pkg::*;

// Clock & Reset
logic                             coreclkout_hip;
logic                             reset_status_n;

assign reset_status = ~reset_status_n;

// PCIe bridge AXIS interface
ofs_fim_pcie_rxs_axis_if          axis_rx_st();
ofs_fim_pcie_txs_axis_if          axis_tx_st();


//PCIE SS signals
logic                             p0_ss_app_st_rx_tvalid;      
logic                             p0_app_ss_st_rx_tready;      
logic [511:0]                     p0_ss_app_st_rx_tdata;       
logic [63:0]                      p0_ss_app_st_rx_tkeep;      
logic                             p0_ss_app_st_rx_tlast;      
logic [1:0]                       p0_ss_app_st_rx_tuser_vendor;
logic [7:0]                       p0_ss_app_st_rx_tuser; 

logic                             p0_app_ss_st_tx_tvalid;
logic                             p0_ss_app_st_tx_tready;     
logic [511:0]                     p0_app_ss_st_tx_tdata;     
logic [63:0]                      p0_app_ss_st_tx_tkeep;      
logic                             p0_app_ss_st_tx_tlast;      
logic [1:0]                       p0_app_ss_st_tx_tuser_vendor;
logic [7:0]                       p0_app_ss_st_tx_tuser;

//FLR Signals
logic                             p0_ss_app_st_flrrcvd_tvalid;
logic [19:0]                      p0_ss_app_st_flrrcvd_tdata;
logic                             p0_app_ss_st_flrcmpl_tvalid;
logic [19:0]                      p0_app_ss_st_flrcmpl_tdata;

//Completion Timeout
logic                             p0_ss_app_st_cplto_tvalid;
logic [29:0]                      p0_ss_app_st_cplto_tdata;

logic                             p0_ss_app_lite_csr_awready;
logic                             p0_ss_app_lite_csr_wready;
logic                             p0_ss_app_lite_csr_arready;
logic                             p0_ss_app_lite_csr_bvalid;
logic                             p0_ss_app_lite_csr_rvalid; 
logic                             p0_app_ss_lite_csr_awvalid;
logic [17:0]                      p0_app_ss_lite_csr_awaddr;
logic                             p0_app_ss_lite_csr_wvalid;
logic [31:0]                      p0_app_ss_lite_csr_wdata;
logic [3:0]                       p0_app_ss_lite_csr_wstrb;  
logic                             p0_app_ss_lite_csr_bready; 
logic [1:0]                       p0_ss_app_lite_csr_bresp;
logic                             p0_app_ss_lite_csr_arvalid;
logic [17:0]                      p0_app_ss_lite_csr_araddr; 
logic                             p0_app_ss_lite_csr_rready; 
logic [31:0]                      p0_ss_app_lite_csr_rdata;  
logic [1:0]                       p0_ss_app_lite_csr_rresp;  

logic                             p0_initiate_warmrst_req;
logic                             p0_ss_app_dlup;
logic                             p0_ss_app_serr;

logic                             p0_ss_app_lite_initatr_awvalid  ;
logic                             p0_app_ss_lite_initatr_awready  ;
logic [31:0]                      p0_ss_app_lite_initatr_awaddr   ;
logic                             p0_ss_app_lite_initatr_wvalid   ;
logic                             p0_app_ss_lite_initatr_wready   ;
logic [31:0]                      p0_ss_app_lite_initatr_wdata    ;
logic [3:0]                       p0_ss_app_lite_initatr_wstrb    ;
logic                             p0_app_ss_lite_initatr_bvalid   ;
logic                             p0_ss_app_lite_initatr_bready   ;
logic [1:0]                       p0_app_ss_lite_initatr_bresp    ;
logic                             p0_ss_app_lite_initatr_arvalid  ;
logic                             p0_app_ss_lite_initatr_arready  ;
logic [31:0]                      p0_ss_app_lite_initatr_araddr   ;
logic                             p0_app_ss_lite_initatr_rvalid   ;
logic                             p0_ss_app_lite_initatr_rready   ;
logic [31:0]                      p0_app_ss_lite_initatr_rdata    ;
logic [1:0]                       p0_app_ss_lite_initatr_rresp    ; 

//---------------------------------------------------------------
//Connecting the RX ST Interface
assign axi_st_rx_if.tvalid            = p0_ss_app_st_rx_tvalid ;     
assign p0_app_ss_st_rx_tready         = axi_st_rx_if.tready    ;
assign axi_st_rx_if.tdata             = p0_ss_app_st_rx_tdata  ;     
assign axi_st_rx_if.tkeep             = p0_ss_app_st_rx_tkeep  ;     
assign axi_st_rx_if.tlast             = p0_ss_app_st_rx_tlast  ;     
assign axi_st_rx_if.tuser_vendor[1:0] = p0_ss_app_st_rx_tuser_vendor;
assign axi_st_rx_if.tuser_vendor[9:2] = p0_ss_app_st_rx_tuser; 

//Connecting the TX ST Interface
assign p0_app_ss_st_tx_tvalid         = axi_st_tx_if.tvalid; 
assign axi_st_tx_if.tready            = p0_ss_app_st_tx_tready;
assign p0_app_ss_st_tx_tdata          = axi_st_tx_if.tdata;
assign p0_app_ss_st_tx_tkeep          = axi_st_tx_if.tkeep;
assign p0_app_ss_st_tx_tlast          = axi_st_tx_if.tlast;
assign p0_app_ss_st_tx_tuser_vendor   = axi_st_tx_if.tuser_vendor[1:0];
assign p0_app_ss_st_tx_tuser          = axi_st_tx_if.tuser_vendor[9:2];

//Connecting the FLR Interface
assign flr_req_if.tvalid = p0_ss_app_st_flrrcvd_tvalid;
assign flr_req_if.tdata  = p0_ss_app_st_flrrcvd_tdata;

assign p0_app_ss_st_flrcmpl_tvalid = flr_rsp_if.tvalid;
assign p0_app_ss_st_flrcmpl_tdata  = flr_rsp_if.tdata;


//Connecting the csr interface
assign ss_csr_lite_if.awready        = p0_ss_app_lite_csr_awready;
assign ss_csr_lite_if.wready         = p0_ss_app_lite_csr_wready;
assign ss_csr_lite_if.arready        = p0_ss_app_lite_csr_arready;
assign ss_csr_lite_if.bvalid         = p0_ss_app_lite_csr_bvalid;
assign ss_csr_lite_if.rvalid         = p0_ss_app_lite_csr_rvalid;
assign p0_app_ss_lite_csr_awvalid    = ss_csr_lite_if.awvalid; 
assign p0_app_ss_lite_csr_awaddr     = ss_csr_lite_if.awaddr;
assign p0_app_ss_lite_csr_wvalid     = ss_csr_lite_if.wvalid;
assign p0_app_ss_lite_csr_wdata      = ss_csr_lite_if.wdata;
assign p0_app_ss_lite_csr_wstrb      = ss_csr_lite_if.wstrb;
assign p0_app_ss_lite_csr_bready     = ss_csr_lite_if.bready;
assign ss_csr_lite_if.bresp          = p0_ss_app_lite_csr_bresp;
assign p0_app_ss_lite_csr_arvalid    = ss_csr_lite_if.arvalid;
assign p0_app_ss_lite_csr_araddr     = ss_csr_lite_if.araddr;
assign p0_app_ss_lite_csr_rready     = ss_csr_lite_if.rready;
assign ss_csr_lite_if.rdata          = p0_ss_app_lite_csr_rdata;
assign ss_csr_lite_if.rresp          = p0_ss_app_lite_csr_rresp;

//Connecting Initiator Interface
assign ss_init_lite_if.awvalid        = p0_ss_app_lite_initatr_awvalid;
assign p0_app_ss_lite_initatr_awready = ss_init_lite_if.awready;
assign ss_init_lite_if.awaddr         = p0_ss_app_lite_initatr_awaddr ; 
assign ss_init_lite_if.wvalid         = p0_ss_app_lite_initatr_wvalid ; 
assign p0_app_ss_lite_initatr_wready  = ss_init_lite_if.wready        ; 
assign ss_init_lite_if.wdata          = p0_ss_app_lite_initatr_wdata  ; 
assign ss_init_lite_if.wstrb          = p0_ss_app_lite_initatr_wstrb  ; 
assign p0_app_ss_lite_initatr_bvalid  = ss_init_lite_if.bvalid        ; 
assign ss_init_lite_if.bready         = p0_ss_app_lite_initatr_bready ; 
assign p0_app_ss_lite_initatr_bresp   = ss_init_lite_if.bresp         ; 
assign ss_init_lite_if.arvalid        = p0_ss_app_lite_initatr_arvalid; 
assign p0_app_ss_lite_initatr_arready = ss_init_lite_if.arready       ; 
assign ss_init_lite_if.araddr         = p0_ss_app_lite_initatr_araddr ; 
assign p0_app_ss_lite_initatr_rvalid  = ss_init_lite_if.rvalid        ; 
assign ss_init_lite_if.rready         = p0_ss_app_lite_initatr_rready ; 
assign p0_app_ss_lite_initatr_rdata   = ss_init_lite_if.rdata         ; 
assign p0_app_ss_lite_initatr_rresp   = ss_init_lite_if.rresp         ; 

//-------------------------------------
// Completion timeout interface 
//-------------------------------------
always_comb begin
   cpl_timeout_if.tvalid = p0_ss_app_st_cplto_tvalid;
   cpl_timeout_if.tdata  = p0_ss_app_st_cplto_tdata;
end


// PCIE stat signals clock crossing (fim_clk -> csr_clk)
localparam CSR_STAT_SYNC_WIDTH = 33;
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(CSR_STAT_SYNC_WIDTH),
   .INIT_VALUE(0),
   .NO_CUT(1)
) csr_resync (
   .clk   (csr_clk),
   .reset (~csr_rst_n),
   .d     ({p0_ss_app_dlup,32'b0}),
   .q     ({pcie_p2c_sideband.pcie_linkup, pcie_p2c_sideband.pcie_chk_rx_err_code})
);

//-------------------------------------
// PCIe SS
//-------------------------------------
`ifdef INCLUDE_SOC
generate if (SOC_ATTACH == 1) begin : soc_pcie
soc_pcie_ss pcie_ss(
.refclk0                        (pin_pcie_refclk0_p             ),               
.refclk1                        (pin_pcie_refclk1_p             ),
.pin_perst_n                    (pin_pcie_in_perst_n            ),
.coreclkout_hip_toapp           (coreclkout_hip                 ),
.p0_pin_perst_n                 (                               ), 
.p0_reset_status_n              (reset_status_n                 ),
.ninit_done                     (ninit_done                     ), 
.dummy_user_avmm_rst            (                               ), 
.p0_axi_st_clk                  (fim_clk                        ),
.p0_axi_lite_clk                (csr_clk                        ),  
.p0_axi_st_areset_n             (fim_rst_n                      ),       
.p0_axi_lite_areset_n           (csr_rst_n                      ),        
.p0_subsystem_cold_rst_n        (p0_subsystem_cold_rst_n        ),
.p0_subsystem_warm_rst_n        (p0_subsystem_warm_rst_n        ),
.p0_subsystem_cold_rst_ack_n    (p0_subsystem_cold_rst_ack_n    ),
.p0_subsystem_warm_rst_ack_n    (p0_subsystem_warm_rst_ack_n    ),
.p0_subsystem_rst_req           ('0                             ),
.p0_subsystem_rst_rdy           (                               ),      
.p0_initiate_warmrst_req        (p0_initiate_warmrst_req        ),
.p0_initiate_rst_req_rdy        (p0_initiate_warmrst_req        ),          
.p0_ss_app_st_rx_tvalid         (p0_ss_app_st_rx_tvalid         ),   
.p0_app_ss_st_rx_tready         (p0_app_ss_st_rx_tready         ),   
.p0_ss_app_st_rx_tdata          (p0_ss_app_st_rx_tdata          ), 
.p0_ss_app_st_rx_tkeep          (p0_ss_app_st_rx_tkeep          ),
.p0_ss_app_st_rx_tlast          (p0_ss_app_st_rx_tlast          ),
.p0_ss_app_st_rx_tuser          (p0_ss_app_st_rx_tuser          ),
.p0_ss_app_st_rx_tuser_vendor   (p0_ss_app_st_rx_tuser_vendor   ),
.p0_app_ss_st_tx_tvalid         (p0_app_ss_st_tx_tvalid         ),
.p0_ss_app_st_tx_tready         (p0_ss_app_st_tx_tready         ),
.p0_app_ss_st_tx_tdata          (p0_app_ss_st_tx_tdata          ),
.p0_app_ss_st_tx_tkeep          (p0_app_ss_st_tx_tkeep          ),
.p0_app_ss_st_tx_tlast          (p0_app_ss_st_tx_tlast          ),
.p0_app_ss_st_tx_tuser          (p0_app_ss_st_tx_tuser          ),
.p0_app_ss_st_tx_tuser_vendor   (p0_app_ss_st_tx_tuser_vendor   ),
.p0_ss_app_st_rxreq_tvalid      (axi_st_rxreq_if.tvalid         ),
.p0_app_ss_st_rxreq_tready      (axi_st_rxreq_if.tready         ),
.p0_ss_app_st_rxreq_tdata       (axi_st_rxreq_if.tdata          ),
.p0_ss_app_st_rxreq_tkeep       (axi_st_rxreq_if.tkeep          ),
.p0_ss_app_st_rxreq_tlast       (axi_st_rxreq_if.tlast          ),
.p0_ss_app_st_rxreq_tuser_vendor(axi_st_rxreq_if.tuser_vendor   ),
.p0_app_ss_st_txreq_tvalid      (p0_app_ss_st_txreq_tvalid      ),  
.p0_ss_app_st_txreq_tready      (p0_ss_app_st_txreq_tready      ),    
.p0_app_ss_st_txreq_tdata       (p0_app_ss_st_txreq_tdata       ), 
.p0_app_ss_st_txreq_tlast       (p0_app_ss_st_txreq_tlast       ),      
.p0_ss_app_st_flrrcvd_tvalid    (p0_ss_app_st_flrrcvd_tvalid    ),
.p0_ss_app_st_flrrcvd_tdata     (p0_ss_app_st_flrrcvd_tdata     ),
.p0_app_ss_st_flrcmpl_tvalid    (p0_app_ss_st_flrcmpl_tvalid    ),
.p0_app_ss_st_flrcmpl_tdata     (p0_app_ss_st_flrcmpl_tdata     ),
.p0_ss_app_st_ctrlshadow_tvalid (p0_ss_app_st_ctrlshadow_tvalid ),
.p0_ss_app_st_ctrlshadow_tdata  (p0_ss_app_st_ctrlshadow_tdata  ),
.p0_ss_app_st_txcrdt_tvalid     (                               ),
.p0_ss_app_st_txcrdt_tdata      (                               ),
.p0_ss_app_st_cplto_tvalid      (p0_ss_app_st_cplto_tvalid      ),    
.p0_ss_app_st_cplto_tdata       (p0_ss_app_st_cplto_tdata       ),
.p0_app_ss_lite_csr_awvalid     (p0_app_ss_lite_csr_awvalid     ),
.p0_ss_app_lite_csr_awready     (p0_ss_app_lite_csr_awready     ),
.p0_app_ss_lite_csr_awaddr      (p0_app_ss_lite_csr_awaddr      ),
.p0_app_ss_lite_csr_wvalid      (p0_app_ss_lite_csr_wvalid      ),
.p0_ss_app_lite_csr_wready      (p0_ss_app_lite_csr_wready      ),
.p0_app_ss_lite_csr_wdata       (p0_app_ss_lite_csr_wdata       ),
.p0_app_ss_lite_csr_wstrb       (p0_app_ss_lite_csr_wstrb       ),
.p0_ss_app_lite_csr_bvalid      (p0_ss_app_lite_csr_bvalid      ),
.p0_app_ss_lite_csr_bready      (p0_app_ss_lite_csr_bready      ),
.p0_ss_app_lite_csr_bresp       (p0_ss_app_lite_csr_bresp       ),
.p0_app_ss_lite_csr_arvalid     (p0_app_ss_lite_csr_arvalid     ),
.p0_ss_app_lite_csr_arready     (p0_ss_app_lite_csr_arready     ),
.p0_app_ss_lite_csr_araddr      (p0_app_ss_lite_csr_araddr      ),
.p0_ss_app_lite_csr_rvalid      (p0_ss_app_lite_csr_rvalid      ),
.p0_app_ss_lite_csr_rready      (p0_app_ss_lite_csr_rready      ),
.p0_ss_app_lite_csr_rdata       (p0_ss_app_lite_csr_rdata       ),
.p0_ss_app_lite_csr_rresp       (p0_ss_app_lite_csr_rresp       ),
.p0_ss_app_dlup                 (p0_ss_app_dlup                 ),
.tx_n_out0                      (pin_pcie_tx_n[0]               ),      
.tx_n_out1                      (pin_pcie_tx_n[1]               ),      
.tx_n_out2                      (pin_pcie_tx_n[2]               ),      
.tx_n_out3                      (pin_pcie_tx_n[3]               ),      
.tx_n_out4                      (pin_pcie_tx_n[4]               ),      
.tx_n_out5                      (pin_pcie_tx_n[5]               ),      
.tx_n_out6                      (pin_pcie_tx_n[6]               ),      
.tx_n_out7                      (pin_pcie_tx_n[7]               ),      
.tx_n_out8                      (pin_pcie_tx_n[8]               ),      
.tx_n_out9                      (pin_pcie_tx_n[9]               ),      
.tx_n_out10                     (pin_pcie_tx_n[10]              ),       
.tx_n_out11                     (pin_pcie_tx_n[11]              ),       
.tx_n_out12                     (pin_pcie_tx_n[12]              ),       
.tx_n_out13                     (pin_pcie_tx_n[13]              ),       
.tx_n_out14                     (pin_pcie_tx_n[14]              ),       
.tx_n_out15                     (pin_pcie_tx_n[15]              ),       
.tx_p_out0                      (pin_pcie_tx_p[0]               ),
.tx_p_out1                      (pin_pcie_tx_p[1]               ),
.tx_p_out2                      (pin_pcie_tx_p[2]               ),
.tx_p_out3                      (pin_pcie_tx_p[3]               ),
.tx_p_out4                      (pin_pcie_tx_p[4]               ),
.tx_p_out5                      (pin_pcie_tx_p[5]               ),
.tx_p_out6                      (pin_pcie_tx_p[6]               ),
.tx_p_out7                      (pin_pcie_tx_p[7]               ),
.tx_p_out8                      (pin_pcie_tx_p[8]               ),
.tx_p_out9                      (pin_pcie_tx_p[9]               ),
.tx_p_out10                     (pin_pcie_tx_p[10]              ), 
.tx_p_out11                     (pin_pcie_tx_p[11]              ), 
.tx_p_out12                     (pin_pcie_tx_p[12]              ), 
.tx_p_out13                     (pin_pcie_tx_p[13]              ), 
.tx_p_out14                     (pin_pcie_tx_p[14]              ), 
.tx_p_out15                     (pin_pcie_tx_p[15]              ), 
.rx_n_in0                       (pin_pcie_rx_n[0]               ),    
.rx_n_in1                       (pin_pcie_rx_n[1]               ),    
.rx_n_in2                       (pin_pcie_rx_n[2]               ),    
.rx_n_in3                       (pin_pcie_rx_n[3]               ),    
.rx_n_in4                       (pin_pcie_rx_n[4]               ),    
.rx_n_in5                       (pin_pcie_rx_n[5]               ),    
.rx_n_in6                       (pin_pcie_rx_n[6]               ),    
.rx_n_in7                       (pin_pcie_rx_n[7]               ),    
.rx_n_in8                       (pin_pcie_rx_n[8]               ),    
.rx_n_in9                       (pin_pcie_rx_n[9]               ),    
.rx_n_in10                      (pin_pcie_rx_n[10]              ),    
.rx_n_in11                      (pin_pcie_rx_n[11]              ),    
.rx_n_in12                      (pin_pcie_rx_n[12]              ),    
.rx_n_in13                      (pin_pcie_rx_n[13]              ),    
.rx_n_in14                      (pin_pcie_rx_n[14]              ),    
.rx_n_in15                      (pin_pcie_rx_n[15]              ),    
.rx_p_in0                       (pin_pcie_rx_p[0]               ),    
.rx_p_in1                       (pin_pcie_rx_p[1]               ),    
.rx_p_in2                       (pin_pcie_rx_p[2]               ),    
.rx_p_in3                       (pin_pcie_rx_p[3]               ),    
.rx_p_in4                       (pin_pcie_rx_p[4]               ),    
.rx_p_in5                       (pin_pcie_rx_p[5]               ),    
.rx_p_in6                       (pin_pcie_rx_p[6]               ),    
.rx_p_in7                       (pin_pcie_rx_p[7]               ),    
.rx_p_in8                       (pin_pcie_rx_p[8]               ),    
.rx_p_in9                       (pin_pcie_rx_p[9]               ),    
.rx_p_in10                      (pin_pcie_rx_p[10]              ),    
.rx_p_in11                      (pin_pcie_rx_p[11]              ),    
.rx_p_in12                      (pin_pcie_rx_p[12]              ),    
.rx_p_in13                      (pin_pcie_rx_p[13]              ),    
.rx_p_in14                      (pin_pcie_rx_p[14]              ),    
.rx_p_in15                      (pin_pcie_rx_p[15]              )
);
end : soc_pcie
else begin : host_pcie
`endif
pcie_ss pcie_ss(
.refclk0                        (pin_pcie_refclk0_p             ),               
.refclk1                        (pin_pcie_refclk1_p             ),
.pin_perst_n                    (pin_pcie_in_perst_n            ),
.coreclkout_hip_toapp           (coreclkout_hip                 ),
.p0_pin_perst_n                 (                               ), 
.p0_reset_status_n              (reset_status_n                 ),
.ninit_done                     (ninit_done                     ), 
.dummy_user_avmm_rst            (                               ), 
.p0_axi_st_clk                  (fim_clk                        ),
.p0_axi_lite_clk                (csr_clk                        ),  
.p0_axi_st_areset_n             (fim_rst_n                      ),       
.p0_axi_lite_areset_n           (csr_rst_n                      ),        
.p0_subsystem_cold_rst_n        (p0_subsystem_cold_rst_n        ),
.p0_subsystem_warm_rst_n        (p0_subsystem_warm_rst_n        ),
.p0_subsystem_cold_rst_ack_n    (p0_subsystem_cold_rst_ack_n    ),
.p0_subsystem_warm_rst_ack_n    (p0_subsystem_warm_rst_ack_n    ),
.p0_subsystem_rst_req           ('0                             ),
.p0_subsystem_rst_rdy           (                               ),      
.p0_initiate_warmrst_req        (p0_initiate_warmrst_req        ),
.p0_initiate_rst_req_rdy        (p0_initiate_warmrst_req        ),          
.p0_ss_app_st_rx_tvalid         (p0_ss_app_st_rx_tvalid         ),   
.p0_app_ss_st_rx_tready         (p0_app_ss_st_rx_tready         ),   
.p0_ss_app_st_rx_tdata          (p0_ss_app_st_rx_tdata          ), 
.p0_ss_app_st_rx_tkeep          (p0_ss_app_st_rx_tkeep          ),
.p0_ss_app_st_rx_tlast          (p0_ss_app_st_rx_tlast          ),
.p0_ss_app_st_rx_tuser          (p0_ss_app_st_rx_tuser          ),
.p0_ss_app_st_rx_tuser_vendor   (p0_ss_app_st_rx_tuser_vendor   ),
.p0_app_ss_st_tx_tvalid         (p0_app_ss_st_tx_tvalid         ),
.p0_ss_app_st_tx_tready         (p0_ss_app_st_tx_tready         ),
.p0_app_ss_st_tx_tdata          (p0_app_ss_st_tx_tdata          ),
.p0_app_ss_st_tx_tkeep          (p0_app_ss_st_tx_tkeep          ),
.p0_app_ss_st_tx_tlast          (p0_app_ss_st_tx_tlast          ),
.p0_app_ss_st_tx_tuser          (p0_app_ss_st_tx_tuser          ),
.p0_app_ss_st_tx_tuser_vendor   (p0_app_ss_st_tx_tuser_vendor   ),
.p0_ss_app_st_rxreq_tvalid      (axi_st_rxreq_if.tvalid),
.p0_app_ss_st_rxreq_tready      (axi_st_rxreq_if.tready),
.p0_ss_app_st_rxreq_tdata       (axi_st_rxreq_if.tdata),
.p0_ss_app_st_rxreq_tkeep       (axi_st_rxreq_if.tkeep),
.p0_ss_app_st_rxreq_tlast       (axi_st_rxreq_if.tlast),
.p0_ss_app_st_rxreq_tuser_vendor(axi_st_rxreq_if.tuser_vendor),
.p0_app_ss_st_txreq_tvalid      (p0_app_ss_st_txreq_tvalid      ),  
.p0_ss_app_st_txreq_tready      (p0_ss_app_st_txreq_tready      ),    
.p0_app_ss_st_txreq_tdata       (p0_app_ss_st_txreq_tdata       ), 
.p0_app_ss_st_txreq_tlast       (p0_app_ss_st_txreq_tlast       ),      
.p0_ss_app_st_flrrcvd_tvalid    (p0_ss_app_st_flrrcvd_tvalid    ),
.p0_ss_app_st_flrrcvd_tdata     (p0_ss_app_st_flrrcvd_tdata     ),
.p0_app_ss_st_flrcmpl_tvalid    (p0_app_ss_st_flrcmpl_tvalid    ),
.p0_app_ss_st_flrcmpl_tdata     (p0_app_ss_st_flrcmpl_tdata     ),
.p0_ss_app_st_ctrlshadow_tvalid (p0_ss_app_st_ctrlshadow_tvalid ),
.p0_ss_app_st_ctrlshadow_tdata  (p0_ss_app_st_ctrlshadow_tdata  ),
.p0_ss_app_st_txcrdt_tvalid     (                               ),
.p0_ss_app_st_txcrdt_tdata      (                               ),
.p0_ss_app_st_cplto_tvalid      (p0_ss_app_st_cplto_tvalid      ),    
.p0_ss_app_st_cplto_tdata       (p0_ss_app_st_cplto_tdata       ),
.p0_app_ss_lite_csr_awvalid     (p0_app_ss_lite_csr_awvalid     ),
.p0_ss_app_lite_csr_awready     (p0_ss_app_lite_csr_awready     ),
.p0_app_ss_lite_csr_awaddr      (p0_app_ss_lite_csr_awaddr      ),
.p0_app_ss_lite_csr_wvalid      (p0_app_ss_lite_csr_wvalid      ),
.p0_ss_app_lite_csr_wready      (p0_ss_app_lite_csr_wready      ),
.p0_app_ss_lite_csr_wdata       (p0_app_ss_lite_csr_wdata       ),
.p0_app_ss_lite_csr_wstrb       (p0_app_ss_lite_csr_wstrb       ),
.p0_ss_app_lite_csr_bvalid      (p0_ss_app_lite_csr_bvalid      ),
.p0_app_ss_lite_csr_bready      (p0_app_ss_lite_csr_bready      ),
.p0_ss_app_lite_csr_bresp       (p0_ss_app_lite_csr_bresp       ),
.p0_app_ss_lite_csr_arvalid     (p0_app_ss_lite_csr_arvalid     ),
.p0_ss_app_lite_csr_arready     (p0_ss_app_lite_csr_arready     ),
.p0_app_ss_lite_csr_araddr      (p0_app_ss_lite_csr_araddr      ),
.p0_ss_app_lite_csr_rvalid      (p0_ss_app_lite_csr_rvalid      ),
.p0_app_ss_lite_csr_rready      (p0_app_ss_lite_csr_rready      ),
.p0_ss_app_lite_csr_rdata       (p0_ss_app_lite_csr_rdata       ),
.p0_ss_app_lite_csr_rresp       (p0_ss_app_lite_csr_rresp       ),
.p0_ss_app_dlup                 (p0_ss_app_dlup                 ),
.tx_n_out0                      (pin_pcie_tx_n[0]               ),      
.tx_n_out1                      (pin_pcie_tx_n[1]               ),      
.tx_n_out2                      (pin_pcie_tx_n[2]               ),      
.tx_n_out3                      (pin_pcie_tx_n[3]               ),      
.tx_n_out4                      (pin_pcie_tx_n[4]               ),      
.tx_n_out5                      (pin_pcie_tx_n[5]               ),      
.tx_n_out6                      (pin_pcie_tx_n[6]               ),      
.tx_n_out7                      (pin_pcie_tx_n[7]               ),      
.tx_n_out8                      (pin_pcie_tx_n[8]               ),      
.tx_n_out9                      (pin_pcie_tx_n[9]               ),      
.tx_n_out10                     (pin_pcie_tx_n[10]              ),       
.tx_n_out11                     (pin_pcie_tx_n[11]              ),       
.tx_n_out12                     (pin_pcie_tx_n[12]              ),       
.tx_n_out13                     (pin_pcie_tx_n[13]              ),       
.tx_n_out14                     (pin_pcie_tx_n[14]              ),       
.tx_n_out15                     (pin_pcie_tx_n[15]              ),       
.tx_p_out0                      (pin_pcie_tx_p[0]               ),
.tx_p_out1                      (pin_pcie_tx_p[1]               ),
.tx_p_out2                      (pin_pcie_tx_p[2]               ),
.tx_p_out3                      (pin_pcie_tx_p[3]               ),
.tx_p_out4                      (pin_pcie_tx_p[4]               ),
.tx_p_out5                      (pin_pcie_tx_p[5]               ),
.tx_p_out6                      (pin_pcie_tx_p[6]               ),
.tx_p_out7                      (pin_pcie_tx_p[7]               ),
.tx_p_out8                      (pin_pcie_tx_p[8]               ),
.tx_p_out9                      (pin_pcie_tx_p[9]               ),
.tx_p_out10                     (pin_pcie_tx_p[10]              ), 
.tx_p_out11                     (pin_pcie_tx_p[11]              ), 
.tx_p_out12                     (pin_pcie_tx_p[12]              ), 
.tx_p_out13                     (pin_pcie_tx_p[13]              ), 
.tx_p_out14                     (pin_pcie_tx_p[14]              ), 
.tx_p_out15                     (pin_pcie_tx_p[15]              ), 
.rx_n_in0                       (pin_pcie_rx_n[0]               ),    
.rx_n_in1                       (pin_pcie_rx_n[1]               ),    
.rx_n_in2                       (pin_pcie_rx_n[2]               ),    
.rx_n_in3                       (pin_pcie_rx_n[3]               ),    
.rx_n_in4                       (pin_pcie_rx_n[4]               ),    
.rx_n_in5                       (pin_pcie_rx_n[5]               ),    
.rx_n_in6                       (pin_pcie_rx_n[6]               ),    
.rx_n_in7                       (pin_pcie_rx_n[7]               ),    
.rx_n_in8                       (pin_pcie_rx_n[8]               ),    
.rx_n_in9                       (pin_pcie_rx_n[9]               ),    
.rx_n_in10                      (pin_pcie_rx_n[10]              ),    
.rx_n_in11                      (pin_pcie_rx_n[11]              ),    
.rx_n_in12                      (pin_pcie_rx_n[12]              ),    
.rx_n_in13                      (pin_pcie_rx_n[13]              ),    
.rx_n_in14                      (pin_pcie_rx_n[14]              ),    
.rx_n_in15                      (pin_pcie_rx_n[15]              ),    
.rx_p_in0                       (pin_pcie_rx_p[0]               ),    
.rx_p_in1                       (pin_pcie_rx_p[1]               ),    
.rx_p_in2                       (pin_pcie_rx_p[2]               ),    
.rx_p_in3                       (pin_pcie_rx_p[3]               ),    
.rx_p_in4                       (pin_pcie_rx_p[4]               ),    
.rx_p_in5                       (pin_pcie_rx_p[5]               ),    
.rx_p_in6                       (pin_pcie_rx_p[6]               ),    
.rx_p_in7                       (pin_pcie_rx_p[7]               ),    
.rx_p_in8                       (pin_pcie_rx_p[8]               ),    
.rx_p_in9                       (pin_pcie_rx_p[9]               ),    
.rx_p_in10                      (pin_pcie_rx_p[10]              ),    
.rx_p_in11                      (pin_pcie_rx_p[11]              ),    
.rx_p_in12                      (pin_pcie_rx_p[12]              ),    
.rx_p_in13                      (pin_pcie_rx_p[13]              ),    
.rx_p_in14                      (pin_pcie_rx_p[14]              ),    
.rx_p_in15                      (pin_pcie_rx_p[15]              )
);
`ifdef INCLUDE_SOC
end : host_pcie
endgenerate
`endif
endmodule
