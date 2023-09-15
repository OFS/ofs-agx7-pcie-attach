// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Functions:
//    * Adapt PCIe HIP IP AVST RX interface to AXI4-S RX streaming interface
//    * Adapt AXI4-S TX streaming interface to PCIe HIP IP AVST TX interface
//    * Check TLP packets received on the AVST RX interface
//
//-----------------------------------------------------------------------------


module pcie_bridge (
   // FIM clock and reset
   input  logic                    fim_clk,
   input  logic                    fim_rst_n,

   // PCIE AVST Interface
   input  logic                    avl_clk,
   input  logic                    avl_rst_n,

   input  ofs_fim_pcie_pkg::t_avst_rxs               avl_rx_st,
   output logic                    avl_rx_ready,  
   output ofs_fim_pcie_pkg::t_avst_txs               avl_tx_st,
   input  logic                    avl_tx_ready,
   
   // FIM AXI-S channels
   ofs_fim_pcie_rxs_axis_if.master fim_axis_rx_st,
   ofs_fim_pcie_txs_axis_if.slave  fim_axis_tx_st,

   // Error sideband signals to upstream PCIe IP
   output logic                    b2a_app_err_valid,
   output logic [31:0]             b2a_app_err_hdr,
   output logic [10:0]             b2a_app_err_info,
   output logic [1:0]              b2a_app_err_func_num,

   // Error signals to PCIe error status registers
   output logic                    chk_rx_err,
   output logic                    chk_rx_err_vf_act,
   output logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]     chk_rx_err_pfn,
   output logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]     chk_rx_err_vfn,
   output logic [31:0]             chk_rx_err_code
);

import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

localparam MRW_TYPE = 5'b00000;
localparam CPL_TYPE = 5'b01010;

t_avst_ch  rx_st_valid;

logic      fifo_wreq;
logic      fifo_rdreq;
logic      fifo_almfull;
logic      fifo_full;
logic      fifo_empty;
logic      fifo_rvalid;

t_avst_rxs fifo_dout, fifo_dout_q;
t_avst_ch  fifo_rx_valid;
t_avst_ch  fifo_rx_sop;

t_avst_rxs fifo_avl_rx_st;
logic      fifo_avl_rx_ready;

t_avst_rxs chk_avl_rx_st;
logic      chk_avl_rx_ready;

t_avst_rxs fim_avl_rx_st;
logic      fim_avl_rx_ready;

logic                          tx_mrd_valid;
logic [PCIE_EP_TAG_WIDTH-1:0]  tx_mrd_tag;
logic [PCIE_MAX_LEN_WIDTH-1:0] tx_mrd_length;
logic [PF_WIDTH-1:0]           tx_mrd_pfn;
logic [VF_WIDTH-1:0]           tx_mrd_vfn;
logic                          tx_mrd_active;

logic                          cpl_pending_data_add;
logic [7:0]                    cpl_pending_data_add_val;
logic [CPL_CREDIT_WIDTH-1:0]   cpl_pending_data_cnt;

ofs_fim_pcie_txs_axis_if pcie_axis_tx_if();

t_tlp_err chk_tlp_err;
logic     rx_avst_fifo_overflow;

//-----------------------------------------------------------------------------
logic fifo_rdack;

assign avl_rx_ready = ~fifo_almfull;

always_comb begin
   for (int i=0; i<NUM_AVST_CH; i=i+1)
      rx_st_valid[i] = avl_rx_st[i].valid;
end

localparam RX_AVST_FIFO_DEPTH_LOG2        = 8;
localparam PCIE_RX_AVST_READY_LATENCY     = 20; // 18 clock cycles for Stratix 10 H-tile PCIe Gen3x16 and 17 for other variants
localparam RX_AVST_FIFO_ALMFULL_THRESHOLD = (1 << RX_AVST_FIFO_DEPTH_LOG2) - PCIE_RX_AVST_READY_LATENCY;

fim_rdack_scfifo #(
   .DATA_WIDTH            (PCIE_RX_AVST_IF_WIDTH*NUM_AVST_CH),
   .DEPTH_LOG2            (RX_AVST_FIFO_DEPTH_LOG2),
   .USE_EAB               ("ON"),
   .ALMOST_FULL_THRESHOLD (RX_AVST_FIFO_ALMFULL_THRESHOLD)
) rx_avst_fifo (
   .clk     (avl_clk),
   .sclr    (~avl_rst_n),
   .wdata   (avl_rx_st),
   .wreq    (fifo_wreq),
   .rdack   (fifo_rdack),
   .rdata   (fifo_dout),
   .wfull   (fifo_full),
   .wusedw  (),
   .rusedw  (),
   .almfull (fifo_almfull), 
   .rempty  (fifo_empty),
   .rvalid  (fifo_rvalid)
);

assign fifo_wreq = (|rx_st_valid & ~fifo_full);
assign fifo_rdack = fifo_avl_rx_ready;

always_comb begin
   fifo_avl_rx_st = fifo_dout;
   fifo_avl_rx_st[0].valid = fifo_rvalid && fifo_dout[0].valid;
   if (NUM_AVST_CH > 1) begin
      fifo_avl_rx_st[1].valid = fifo_rvalid && fifo_dout[1].valid;
   end
end

always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      rx_avst_fifo_overflow <= 1'b0;
   end else begin
      if (fifo_full && |rx_st_valid) begin
         rx_avst_fifo_overflow <= 1'b1;
      end
   end
end

// synthesis translate_off
   assert_rx_avst_fifo_overflow :
      assert property ( @(posedge avl_clk) disable iff (~avl_rst_n) (fifo_full |-> ~|rx_st_valid) )
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx_avst_fifo overflow", $time));   
// synthesis translate_on


//-----------------------------
// RX TLP checker and CPL timeout tracker
//-----------------------------
//    The checker doesn't backpressure the RX AVST FIFO.
//    Backpressuring is implemented in the downstream pcie_rx_bridge
//    The bridge makes sure there is enough "credit" to cover the latency 
//    along the packet datapath FIFO-checker-bridge
//

logic tx_mrd_vf_act;

pcie_checker #(
   .ENABLE_MALFORMED_TLP_CHECK      (1),
   .ENABLE_COMPLETION_TIMEOUT_CHECK (1)
) pcie_checker (    
   .avl_clk               (avl_clk),
   .avl_rst_n             (avl_rst_n),

   // Rx
   .i_avl_rx_st           (fifo_avl_rx_st),
   .o_avl_rx_ready        (fifo_avl_rx_ready),

   .o_avl_rx_st           (chk_avl_rx_st),
   .i_avl_rx_ready        (chk_avl_rx_ready),
   
   // TX MRd
   .tx_mrd_valid          (tx_mrd_valid),
   .tx_mrd_length         (tx_mrd_length),
   .tx_mrd_tag            (tx_mrd_tag),
   .tx_mrd_pfn            (tx_mrd_pfn),
   .tx_mrd_vfn            (tx_mrd_vfn),
   .tx_mrd_vf_act         (tx_mrd_vf_act),
   .cpl_pending_data_cnt  (cpl_pending_data_cnt),

   // Error reporting to PCIe IP
   .b2a_app_err_valid     (b2a_app_err_valid),
   .b2a_app_err_hdr       (b2a_app_err_hdr),
   .b2a_app_err_info      (b2a_app_err_info),
   .b2a_app_err_func_num  (b2a_app_err_func_num),

   // Error reporting to PCIe feature CSR
   .chk_rx_err            (chk_rx_err),
   .chk_rx_err_vf_act     (chk_rx_err_vf_act),
   .chk_rx_err_pfn        (chk_rx_err_pfn),
   .chk_rx_err_vfn        (chk_rx_err_vfn),
   .chk_rx_err_code       (chk_tlp_err)
);

// avl_clk - fim_clk clock domain crossing
pcie_bridge_cdc pcie_bridge_cdc (
   .pcie_clk          (avl_clk),
   .pcie_rst_n        (avl_rst_n),
   
   .fim_clk           (fim_clk),
   .fim_rst_n         (fim_rst_n),

   //----------------------
   // PCIe RX bridge 
   //----------------------
   // AVST sink interface
   .pcie_avl_rx_st    (chk_avl_rx_st),
   .pcie_avl_rx_ready (chk_avl_rx_ready),
   
   // AVST source interface
   .fim_avl_rx_st     (fim_avl_rx_st),
   .fim_avl_rx_ready  (fim_avl_rx_ready),

   //----------------------
   // PCIe TX bridge 
   //----------------------
   // AXIS slave interface
   .fim_axis_tx_st    (fim_axis_tx_st),
   
   // AXIS master interface
   .pcie_axis_tx_st   (pcie_axis_tx_if)
);

// AVST interface to AXIS interface adapter 
// (Both interfaces clocked by fim_clk)
pcie_rx_bridge pcie_rx_bridge (
   .avl_clk        (fim_clk),
   .avl_rst_n      (fim_rst_n),
   .avl_rx_st      (fim_avl_rx_st),
   .avl_rx_ready   (fim_avl_rx_ready),
   .axis_rx_st     (fim_axis_rx_st)
);

// AXIS interface to AVST interface adapter 
// (Both interfaces clocked by avl_clk)
pcie_tx_bridge pcie_tx_bridge (
   .avl_clk          (avl_clk),
   .avl_rst_n        (avl_rst_n),
   .avl_tx_ready     (avl_tx_ready),
   .avl_tx_st        (avl_tx_st),
   .axis_tx_st       (pcie_axis_tx_if),

   .tx_mrd_valid     (tx_mrd_valid),
   .tx_mrd_length    (tx_mrd_length),
   .tx_mrd_tag       (tx_mrd_tag),
   .tx_mrd_pfn       (tx_mrd_pfn),
   .tx_mrd_vfn       (tx_mrd_vfn),
   .tx_mrd_vf_act    (tx_mrd_vf_act),

   .cpl_pending_data_cnt (cpl_pending_data_cnt)
);

// Error output
assign chk_rx_err_code = {rx_avst_fifo_overflow, chk_tlp_err};

endmodule
