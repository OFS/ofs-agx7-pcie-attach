// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT


//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
//   Interface to PCIe SS AXI-lite Interface 
//
//      * State machine arbitrates ss_csr_lite_if access between host indirect
//        CSR access and error reporting
//
//      * FIFO to store incoming errors. The state machine will read the error
//        from the FIFO and write to the ERROR_GEN_CTL and Header registers
//        in PCIe SS.
//
//      * Host indirect access interface connected to PCIe CSR module. 
//        PCIe CSR module implements handshaking with host SW via a bit 
//        for both write/read to PCIe SS CSR. Host SW should not issue new
//        CSR request until the bit indicates previous request is acknowledged.
//
//-----------------------------------------------------------------------------


module pcie_ss_csr_if #(
   parameter            ADDR_WIDTH      = 19,
   parameter            DATA_WIDTH      = 64,
   parameter bit [11:0] FEAT_ID         = 12'h0,
   parameter bit [3:0]  FEAT_VER        = 4'h0,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit        END_OF_LIST     = 1'b0
)(
   // Inputs
   input  logic                      clk,
   input  logic                      rst_n,

   // AXI4-lite interface
   ofs_fim_axi_lite_if.master        csr_lite_if,

   input  logic [1:0]                i_ss_ctrl_cmd,
   input  logic [DATA_WIDTH-1:0]     i_ss_ctrl_writedata,
   input  logic [ADDR_WIDTH-1:0]     i_ss_ctrl_addr,
   output logic                      o_ss_ack,
   output logic [1:0]                o_csr_rresp, 
   output logic [1:0]                o_csr_bresp, 
   output logic [DATA_WIDTH-1:0]     o_ss_readdata,

   // Error reporting
   input  logic                      i_err_valid,              
   input  logic [pcie_ss_hdr_pkg::PCIE_HDR_WIDTH-1:0] i_err_hdr,
   input  logic [pcie_ss_hdr_pkg::PF_WIDTH-1:0]       i_err_pf,
   input  logic [pcie_ss_hdr_pkg::VF_WIDTH-1:0]       i_err_vf,
   input  logic                      i_err_vf_active,
   input  logic [31:0]               i_err_code
);

axi4lite_indirect_csr_if #(
    .CMD_W         (16),   // Indirect CSR command width
    .CSR_ADDR_W    (ofs_fim_cfg_pkg::PCIE_LITE_CSR_WIDTH),   // Indirect CSR address width
    .AXI_ADDR_W    (ofs_fim_cfg_pkg::PCIE_LITE_CSR_WIDTH),   // AXI address width
    .DATA_W        (32)    // Data width
) axi4lite_indirect_csr_if (
   .i_csr_clk       (clk),
   .i_csr_rst_n     (rst_n),

   .i_csr_cmd       (i_ss_ctrl_cmd),
   .i_csr_addr      (i_ss_ctrl_addr),
   .i_csr_writedata (i_ss_ctrl_writedata),
   .o_csr_readdata  (o_ss_readdata),
   .o_csr_ack       (o_ss_ack),
   .o_csr_rresp     (o_csr_rresp),
   .o_csr_bresp     (o_csr_bresp),

   .csr_lite_if     (csr_lite_if)
);

import pcie_ss_hdr_pkg::*;

endmodule : pcie_ss_csr_if
