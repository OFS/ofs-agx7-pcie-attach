// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   PCIe SS Interface  
//
//-----------------------------------------------------------------------------


module pcie_ss_if 
import pcie_ss_hdr_pkg::*;
import pcie_ss_axis_pkg::*;
#(
   parameter            MM_ADDR_WIDTH   = 19,
   parameter            MM_DATA_WIDTH   = 64,
   parameter bit [11:0] FEAT_ID         = 12'h0,
   parameter bit [3:0]  FEAT_VER        = 4'h0,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit        END_OF_LIST     = 1'b0
)(
   // Inputs
   input  logic                      fim_clk,
   input  logic                      fim_rst_n,

   input  logic                      csr_clk,
   input  logic                      csr_rst_n,

   // AXI-S interfaces for error checker
   input  pcie_ss_axis_pkg::t_axis_pcie      i_axis_tx,
   input  logic                      i_axis_tx_tready,

   // Completion Timeout interface
   input  pcie_ss_axis_pkg::t_axis_pcie_cplto i_axis_cpl_timeout,

   // Status
   input  logic                      i_pcie_linkup,

   // RX error
   input  logic [31:0]               i_rx_err_code,
  
   // AXI4-lite interfaces
   ofs_fim_axi_lite_if.slave         csr_lite_if,
   ofs_fim_axi_lite_if.master        ss_csr_lite_if
);

logic                      err_valid;              
logic [pcie_ss_hdr_pkg::PCIE_HDR_WIDTH-1:0] err_hdr;
logic [pcie_ss_hdr_pkg::PF_WIDTH-1:0]       err_pf;
logic [pcie_ss_hdr_pkg::VF_WIDTH-1:0]       err_vf;
logic                      err_vf_active;
logic [31:0]               err_code;

logic [1:0]                ss_ctrl_cmd;
logic [31:0]               ss_ctrl_writedata;
logic [31:0]               ss_readdata;
logic [ofs_fim_cfg_pkg::PCIE_LITE_CSR_WIDTH-1:0] ss_ctrl_addr;
logic                      ss_ack;
logic                      ss_csr_rresp;
logic                      ss_csr_bresp;
logic                      i_ss_error;

//----------------------
//  Check if any bit of ss_csr_rresp, ss_csr_bresp is high
//----------------------
assign i_ss_error = ({ss_csr_rresp, ss_csr_bresp} == 0) ? 0 : 1;


//----------------------
// CSRs
//----------------------
pcie_csr #( 
   .ADDR_WIDTH       (MM_ADDR_WIDTH),
   .DATA_WIDTH       (MM_DATA_WIDTH),
   .FEAT_ID          (FEAT_ID),
   .FEAT_VER         (FEAT_VER),
   .NEXT_DFH_OFFSET  (NEXT_DFH_OFFSET),
   .END_OF_LIST      (END_OF_LIST)  
) pcie_csr (
   .csr_lite_if        (csr_lite_if),

   // CSR input signals
   .clk                 (csr_clk),
   .rst_n               (csr_rst_n),

   .i_pcie_linkup       (i_pcie_linkup),
   .i_err_code          (i_rx_err_code),

   .i_axis_cpl_timeout  (i_axis_cpl_timeout),

   .o_ss_ctrl_cmd       (ss_ctrl_cmd),
   .o_ss_ctrl_addr      (ss_ctrl_addr),
   .o_ss_ctrl_writedata (ss_ctrl_writedata),

   .i_ss_readdata       (ss_readdata),
   .i_ss_ack            (ss_ack),
   .i_ss_error          (i_ss_error )
);

//----------------------
// Error reporting 
//   PCIe HAS section 3.1.6
//   PCIe HAS section 4.1.10
//----------------------
pcie_err_checker pcie_err_checker (
   .clk                 (fim_clk),
   .rst_n               (fim_rst_n),

   .csr_clk             (csr_clk),
   .csr_rst_n           (csr_rst_n),

   .axis_tx             (i_axis_tx),
   .axis_tx_tready      (i_axis_tx_tready),

   .axis_cpl_timeout    (i_axis_cpl_timeout),

   .o_err_valid         (err_valid),              
   .o_err_hdr           (err_hdr),
   .o_err_pf            (err_pf),
   .o_err_vf            (err_vf),
   .o_err_vf_active     (err_vf_active),
   .o_err_code          (err_code)
);

//-------------------------------------
// PCIe SS AXI-4 lite master interface for
//    * Host indirect access via CSR
//    * Error reporting
//-------------------------------------
pcie_ss_csr_if pcie_ss_csr_if (
   .clk                 (csr_clk),
   .rst_n               (csr_rst_n),

   .csr_lite_if         (ss_csr_lite_if),

   .i_err_valid         (err_valid),              
   .i_err_hdr           (err_hdr),
   .i_err_pf            (err_pf),
   .i_err_vf            (err_vf),
   .i_err_vf_active     (err_vf_active),
   .i_err_code          (err_code),

   .i_ss_ctrl_cmd       (ss_ctrl_cmd ), 
   .i_ss_ctrl_addr      (ss_ctrl_addr), 
   .i_ss_ctrl_writedata (ss_ctrl_writedata), 
      
   .o_ss_readdata       (ss_readdata ), 
   .o_ss_ack            (ss_ack),
   .o_csr_rresp         (ss_csr_rresp),
   .o_csr_bresp         (ss_csr_bresp)
);

endmodule : pcie_ss_if
