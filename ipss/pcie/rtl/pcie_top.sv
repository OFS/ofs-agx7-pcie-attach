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
)(

   input  logic                     fim_clk,
   input  logic                     fim_rst_n,
   input  logic                     csr_clk,
   input  logic                     csr_rst_n,
   input  logic                     ninit_done,
   output logic                     reset_status, 
   
   // PCIe pins
   input  logic                     pin_pcie_refclk0_p,
   input  logic                     pin_pcie_refclk1_p,
   input  logic                     pin_pcie_in_perst_n,   // connected to HIP
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_p,
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_n,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_p,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_n,

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

import ofs_fim_pcie_pkg::*;

localparam PF_WIDTH = (NUM_PF > 1) ? $clog2(NUM_PF) : 1;
localparam VF_WIDTH = (MAX_NUM_VF > 1) ? $clog2(MAX_NUM_VF) : 1;

localparam TOTAL_AVST_EW = NUM_AVST_CH*AVST_EW;
localparam TOTAL_AVST_DW  = NUM_AVST_CH*AVST_DW;

//AXI EA Interface Related Parameters
localparam EA_CH         = 2;
localparam AXI_EA_DATA_W = 392;
localparam AXI_EA_USER_W = 22;

// Clock and reset
logic                             coreclkout_hip;
logic                             avl_clk;
logic                             reset_status_n;

// Config and status
logic [2:0]                       tl_cfg_func;//specifies the PF or VF to which tl_cfg* applies. (S10 only)
logic [4:0]                       tl_cfg_add;
logic [15:0]                      tl_cfg_ctl;
logic                             cfg_bd_done;
logic                             pcie_linkup;

// Error
logic                             b2a_app_err_valid;
logic [31:0]                      b2a_app_err_hdr;        
logic [10:0]                      b2a_app_err_info;         
logic [1:0]                       b2a_app_err_func_num;

// RX Avalon streaming interface
logic [NUM_AVST_CH-1:0]           rx_st_valid;
logic [NUM_AVST_CH-1:0]           rx_st_sop;
logic [NUM_AVST_CH-1:0]           rx_st_eop;
logic [NUM_AVST_CH*AVST_EW-1:0]   rx_st_empty;
logic [NUM_AVST_CH*AVST_HW-1:0]   rx_st_hdr;
logic [NUM_AVST_CH*AVST_DW-1:0]   rx_st_data;
logic [NUM_AVST_CH*3-1:0]         rx_st_bar;
logic [NUM_AVST_CH-1:0]           rx_st_vf_active;
logic [NUM_AVST_CH*3-1:0]         rx_st_func_num;
logic [NUM_AVST_CH*11-1:0]        rx_st_vf_num;

// TX Avalon streaming interface
logic [NUM_AVST_CH-1:0]           tx_st_valid;
logic [NUM_AVST_CH-1:0]           tx_st_sop;
logic [NUM_AVST_CH-1:0]           tx_st_eop;
logic [NUM_AVST_CH-1:0]           tx_st_err;
logic [NUM_AVST_CH-1:0]           tx_st_vf_active;
logic [NUM_AVST_CH*AVST_HW-1:0]   tx_st_hdr;
logic [NUM_AVST_CH*AVST_DW-1:0]   tx_st_data;

// PCIe bridge AVST interface
t_avst_rxs                        avl_rx_st;
t_avst_txs                        avl_tx_st;
logic                             avl_rx_ready;
logic                             avl_tx_ready;

// PCIe bridge AXIS interface
ofs_fim_pcie_rxs_axis_if          axis_rx_st();
ofs_fim_pcie_txs_axis_if          axis_tx_st();

// EA AXI RX Streaming Interface 
logic                             axi_ea_rx_tready;
logic                             axi_ea_rx_tvalid;
logic                             axi_ea_rx_tlast;
logic [AXI_EA_USER_W-1:0]         axi_ea_rx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0]         axi_ea_rx_tdata [EA_CH-1:0];

// EA AXI TX Streaming Interface 
logic                             axi_ea_tx_tready;
logic                             axi_ea_tx_tvalid;
logic                             axi_ea_tx_tlast;
logic [AXI_EA_USER_W-1:0]         axi_ea_tx_tuser [EA_CH-1:0];
logic [AXI_EA_DATA_W-1:0]         axi_ea_tx_tdata [EA_CH-1:0];

// RX checker
logic                             chk_rx_err;
logic                             chk_rx_err_vf_act;
logic [PF_WIDTH-1:0]              chk_rx_err_pfn;
logic [VF_WIDTH-1:0]              chk_rx_err_vfn;
logic [31:0]                      chk_rx_err_code;

// FLR signals
logic [7:0]                       flr_rcvd_pf;
logic                             flr_rcvd_vf;
logic [2:0]                       flr_rcvd_pf_num;
logic [10:0]                      flr_rcvd_vf_num;
logic [7:0]                       flr_completed_pf;
logic                             flr_completed_vf;
logic [2:0]                       flr_completed_pf_num;
logic [10:0]                      flr_completed_vf_num;

//-----------------------------------------------------------------------------

// Tie off unused signals
assign tx_st_err = '0;
assign csr_lite_if.awready = 1'b1;
assign csr_lite_if.wready  = 1'b1;
assign csr_lite_if.arready = 1'b1;
assign csr_lite_if.bvalid  = 1'b0;
assign csr_lite_if.rvalid  = 1'b0;

// Clock
assign avl_clk = coreclkout_hip;
assign reset_status = ~reset_status_n;

always_ff @(posedge avl_clk) begin : linkup_proc
   if (~reset_status_n) begin
      pcie_linkup <= 1'b0;
   end
   else begin
      if (cfg_bd_done) begin
         pcie_linkup <= 1'b1;
      end else begin
         pcie_linkup <= 1'b0;
      end
   end
end : linkup_proc

// Device control register configurations
always_ff @(posedge avl_clk) begin : cfg_ctl_proc
   if (~reset_status_n) begin
      cfg_bd_done <= 1'b0;
   end
   else begin
      cfg_bd_done <= 1'b1;
      
      if (tl_cfg_func == 3'h0) begin
         case (tl_cfg_add)
            5'h0 : begin
               pcie_p2c_sideband.cfg_ctl.max_payload_size    <= tl_cfg_ctl[2:0];
               pcie_p2c_sideband.cfg_ctl.max_read_req_size   <= tl_cfg_ctl[5:3];
               pcie_p2c_sideband.cfg_ctl.extended_tag_enable <= tl_cfg_ctl[6];
            end

            5'hc : begin
               //read capability register status bits
               pcie_p2c_sideband.cfg_ctl.msix_enable <= tl_cfg_ctl[5];
               pcie_p2c_sideband.cfg_ctl.msix_pf_mask_en  <= tl_cfg_ctl[6]; 
            end                      
         endcase
      end
   end
end : cfg_ctl_proc

integer i;
always_comb begin
   for (i=0; i<NUM_AVST_CH; i=i+1) begin
      avl_rx_st[i].valid             = rx_st_valid     [i];
      avl_rx_st[i].sop               = rx_st_sop       [i];
      avl_rx_st[i].eop               = rx_st_eop       [i];
      avl_rx_st[i].empty             = rx_st_empty     [i*AVST_EW+:AVST_EW];
      avl_rx_st[i].hdr               = rx_st_hdr       [i*AVST_HW+:AVST_HW];
      avl_rx_st[i].data              = rx_st_data      [i*AVST_DW+:AVST_DW];
      avl_rx_st[i].bar               = rx_st_bar       [i*3+:3];
      avl_rx_st[i].vf_active         = rx_st_vf_active [i];
      avl_rx_st[i].pfn               = rx_st_func_num  [i*3+:PF_WIDTH];
      avl_rx_st[i].vfn               = rx_st_vf_num    [i*11+:VF_WIDTH];
      avl_rx_st[i].mmio_req          = 1'b0;

      tx_st_valid[i]                 = avl_tx_st[i].valid;
      tx_st_sop[i]                   = avl_tx_st[i].sop;
      tx_st_eop[i]                   = avl_tx_st[i].eop;
      tx_st_vf_active[i]             = avl_tx_st[i].vf_active;
      tx_st_hdr[i*AVST_HW+:AVST_HW]  = avl_tx_st[i].hdr;
      tx_st_data[i*AVST_DW+:AVST_DW] = avl_tx_st[i].data;
   end  
end

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

//-------------------------------------
// PCIe bridge AVST <-> AXIS
//-------------------------------------
pcie_bridge pcie_bridge (
   .fim_clk               (fim_clk),
   .fim_rst_n             (fim_rst_n),

   .avl_clk               (avl_clk),
   .avl_rst_n             (reset_status_n),

   .avl_rx_ready          (avl_rx_ready),
   .avl_rx_st             (avl_rx_st),
   .avl_tx_ready          (avl_tx_ready),
   .avl_tx_st             (avl_tx_st),

   .fim_axis_rx_st        (axis_rx_st),
   .fim_axis_tx_st        (axis_tx_st),

   .b2a_app_err_valid     (b2a_app_err_valid),
   .b2a_app_err_hdr       (b2a_app_err_hdr),
   .b2a_app_err_info      (b2a_app_err_info),
   .b2a_app_err_func_num  (b2a_app_err_func_num),

   .chk_rx_err            (chk_rx_err),
   .chk_rx_err_vf_act     (chk_rx_err_vf_act),
   .chk_rx_err_pfn        (chk_rx_err_pfn),
   .chk_rx_err_vfn        (chk_rx_err_vfn),
   .chk_rx_err_code       (chk_rx_err_code)
);

//-------------------------------------
//AXI ST EA <-> AXI ST PCIe SS
//-------------------------------------
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
   
   .st_tx_tready          (axi_st_tx_if.tready),            
   .st_tx_tvalid          (axi_st_tx_if.tvalid),               
   .st_tx_tlast           (axi_st_tx_if.tlast),                
   .st_tx_tuser_vendor    (axi_st_tx_if.tuser_vendor),              
   .st_tx_tdata           (axi_st_tx_if.tdata),                 
   .st_tx_tkeep           (axi_st_tx_if.tkeep)               
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
   .avl_rst_n              (reset_status_n),

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
   rx_err_code_q0 <= chk_rx_err_code;
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
   .d     ({pcie_linkup, rx_err_code}),
   .q     ({pcie_p2c_sideband.pcie_linkup, pcie_p2c_sideband.pcie_chk_rx_err_code})
);

//-------------------------------------
// PCIe HIP IP
//-------------------------------------
pcie_ep_gen3x16 dut (
   .p0_rx_st_ready_i                 (avl_rx_ready),
   .p0_rx_st_sop_o                   (rx_st_sop),
   .p0_rx_st_eop_o                   (rx_st_eop),
   .p0_rx_st_data_o                  (rx_st_data),
   .p0_rx_st_valid_o                 (rx_st_valid),
   .p0_rx_st_empty_o                 (rx_st_empty),
   .p0_rx_st_vf_active_o             (rx_st_vf_active),
   .p0_rx_st_func_num_o              (rx_st_func_num),
   .p0_rx_st_vf_num_o                (rx_st_vf_num),
   .p0_rx_st_hdr_o                   (rx_st_hdr),
   .p0_rx_st_tlp_prfx_o              (/*Not used*/),
   .p0_rx_st_bar_range_o             (rx_st_bar),
   .p0_rx_st_tlp_abort_o             (/*Not used*/),
   .p0_rx_par_err_o                  (/*Not used*/),
   .p0_tx_st_sop_i                   (tx_st_sop),
   .p0_tx_st_eop_i                   (tx_st_eop),
   .p0_tx_st_data_i                  (tx_st_data),
   .p0_tx_st_valid_i                 (tx_st_valid),
   .p0_tx_st_err_i                   ('0),
   .p0_tx_st_ready_o                 (avl_tx_ready),
   .p0_tx_st_hdr_i                   (tx_st_hdr),
   .p0_tx_st_tlp_prfx_i              ('0),
   .p0_tx_par_err_o                  (/*Not used*/),
   .p0_tx_cdts_limit_o               (/*Not used*/),
   .p0_tx_cdts_limit_tdm_idx_o       (/*Not used*/),
   .p0_tl_cfg_func_o                 (tl_cfg_func),
   .p0_tl_cfg_add_o                  (tl_cfg_add),
   .p0_tl_cfg_ctl_o                  (tl_cfg_ctl),
   .p0_dl_timer_update_o             (/*Not used*/),
   .p0_vf_err_ur_posted_s0_o         (/*Not used*/),
   .p0_vf_err_ur_posted_s1_o         (/*Not used*/),
   .p0_vf_err_ur_posted_s2_o         (/*Not used*/),
   .p0_vf_err_ur_posted_s3_o         (/*Not used*/),
   .p0_vf_err_func_num_s0_o          (/*Not used*/),
   .p0_vf_err_func_num_s1_o          (/*Not used*/),
   .p0_vf_err_func_num_s2_o          (/*Not used*/),
   .p0_vf_err_func_num_s3_o          (/*Not used*/),
   .p0_vf_err_ca_postedreq_s0_o      (/*Not used*/),
   .p0_vf_err_ca_postedreq_s1_o      (/*Not used*/),
   .p0_vf_err_ca_postedreq_s2_o      (/*Not used*/),
   .p0_vf_err_ca_postedreq_s3_o      (/*Not used*/),
   .p0_vf_err_vf_num_s0_o            (/*Not used*/),
   .p0_vf_err_vf_num_s1_o            (/*Not used*/),
   .p0_vf_err_vf_num_s2_o            (/*Not used*/),
   .p0_vf_err_vf_num_s3_o            (/*Not used*/),
   .p0_vf_err_poisonedwrreq_s0_o     (/*Not used*/),
   .p0_vf_err_poisonedwrreq_s1_o     (/*Not used*/),
   .p0_vf_err_poisonedwrreq_s2_o     (/*Not used*/),
   .p0_vf_err_poisonedwrreq_s3_o     (/*Not used*/),
   .p0_vf_err_poisonedcompl_s0_o     (/*Not used*/),
   .p0_vf_err_poisonedcompl_s1_o     (/*Not used*/),
   .p0_vf_err_poisonedcompl_s2_o     (/*Not used*/),
   .p0_vf_err_poisonedcompl_s3_o     (/*Not used*/),
   .p0_user_vfnonfatalmsg_func_num_i ('0),
   .p0_user_vfnonfatalmsg_vfnum_i    ('0),
   .p0_user_sent_vfnonfatalmsg_i     ('0),
   .p0_vf_err_overflow_o             (/*Not used*/),
   .p0_flr_rcvd_pf_o                 (flr_rcvd_pf),
   .p0_flr_rcvd_vf_o                 (flr_rcvd_vf),
   .p0_flr_rcvd_pf_num_o             (flr_rcvd_pf_num),
   .p0_flr_rcvd_vf_num_o             (flr_rcvd_vf_num),
   .p0_flr_completed_pf_i            (flr_completed_pf),
   .p0_flr_completed_vf_i            (flr_completed_vf),
   .p0_flr_completed_pf_num_i        (flr_completed_pf_num),
   .p0_flr_completed_vf_num_i        (flr_completed_vf_num),
   .p0_reset_status_n                (reset_status_n),
   .p0_pin_perst_n                   (/*Not Used*/),
   .rx_n_in0                         (pin_pcie_rx_n[0]),
   .rx_n_in1                         (pin_pcie_rx_n[1]),
   .rx_n_in2                         (pin_pcie_rx_n[2]),
   .rx_n_in3                         (pin_pcie_rx_n[3]),
   .rx_n_in4                         (pin_pcie_rx_n[4]),
   .rx_n_in5                         (pin_pcie_rx_n[5]),
   .rx_n_in6                         (pin_pcie_rx_n[6]),
   .rx_n_in7                         (pin_pcie_rx_n[7]),
   .rx_n_in8                         (pin_pcie_rx_n[8]),
   .rx_n_in9                         (pin_pcie_rx_n[9]),
   .rx_n_in10                        (pin_pcie_rx_n[10]),
   .rx_n_in11                        (pin_pcie_rx_n[11]),
   .rx_n_in12                        (pin_pcie_rx_n[12]),
   .rx_n_in13                        (pin_pcie_rx_n[13]),
   .rx_n_in14                        (pin_pcie_rx_n[14]),
   .rx_n_in15                        (pin_pcie_rx_n[15]),
   .rx_p_in0                         (pin_pcie_rx_p[0]),
   .rx_p_in1                         (pin_pcie_rx_p[1]),
   .rx_p_in2                         (pin_pcie_rx_p[2]),
   .rx_p_in3                         (pin_pcie_rx_p[3]),
   .rx_p_in4                         (pin_pcie_rx_p[4]),
   .rx_p_in5                         (pin_pcie_rx_p[5]),
   .rx_p_in6                         (pin_pcie_rx_p[6]),
   .rx_p_in7                         (pin_pcie_rx_p[7]),
   .rx_p_in8                         (pin_pcie_rx_p[8]),
   .rx_p_in9                         (pin_pcie_rx_p[9]),
   .rx_p_in10                        (pin_pcie_rx_p[10]),
   .rx_p_in11                        (pin_pcie_rx_p[11]),
   .rx_p_in12                        (pin_pcie_rx_p[12]),
   .rx_p_in13                        (pin_pcie_rx_p[13]),
   .rx_p_in14                        (pin_pcie_rx_p[14]),
   .rx_p_in15                        (pin_pcie_rx_p[15]),
   .tx_n_out0                        (pin_pcie_tx_n[0]),
   .tx_n_out1                        (pin_pcie_tx_n[1]),
   .tx_n_out2                        (pin_pcie_tx_n[2]),
   .tx_n_out3                        (pin_pcie_tx_n[3]),
   .tx_n_out4                        (pin_pcie_tx_n[4]),
   .tx_n_out5                        (pin_pcie_tx_n[5]),
   .tx_n_out6                        (pin_pcie_tx_n[6]),
   .tx_n_out7                        (pin_pcie_tx_n[7]),
   .tx_n_out8                        (pin_pcie_tx_n[8]),
   .tx_n_out9                        (pin_pcie_tx_n[9]),
   .tx_n_out10                       (pin_pcie_tx_n[10]),
   .tx_n_out11                       (pin_pcie_tx_n[11]),
   .tx_n_out12                       (pin_pcie_tx_n[12]),
   .tx_n_out13                       (pin_pcie_tx_n[13]),
   .tx_n_out14                       (pin_pcie_tx_n[14]),
   .tx_n_out15                       (pin_pcie_tx_n[15]),
   .tx_p_out0                        (pin_pcie_tx_p[0]),
   .tx_p_out1                        (pin_pcie_tx_p[1]),
   .tx_p_out2                        (pin_pcie_tx_p[2]),
   .tx_p_out3                        (pin_pcie_tx_p[3]),
   .tx_p_out4                        (pin_pcie_tx_p[4]),
   .tx_p_out5                        (pin_pcie_tx_p[5]),
   .tx_p_out6                        (pin_pcie_tx_p[6]),
   .tx_p_out7                        (pin_pcie_tx_p[7]),
   .tx_p_out8                        (pin_pcie_tx_p[8]),
   .tx_p_out9                        (pin_pcie_tx_p[9]),
   .tx_p_out10                       (pin_pcie_tx_p[10]),
   .tx_p_out11                       (pin_pcie_tx_p[11]),
   .tx_p_out12                       (pin_pcie_tx_p[12]),
   .tx_p_out13                       (pin_pcie_tx_p[13]),
   .tx_p_out14                       (pin_pcie_tx_p[14]),
   .tx_p_out15                       (pin_pcie_tx_p[15]),
   .coreclkout_hip                   (coreclkout_hip),
   .refclk0                          (pin_pcie_refclk0_p),
   .refclk1                          (pin_pcie_refclk1_p),
   .pin_perst_n                      (pin_pcie_in_perst_n),
   .ninit_done                       (ninit_done)
);

endmodule
