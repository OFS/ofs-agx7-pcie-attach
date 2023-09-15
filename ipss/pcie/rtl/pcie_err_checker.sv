// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT


//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
//   PCIe error checker 
//
//      PCIe HAS section 3.1.6
//      PCIe HAS section 4.1.10
//-----------------------------------------------------------------------------


module pcie_err_checker 
import pcie_ss_hdr_pkg::*;
import pcie_ss_axis_pkg::*;
(
   // Inputs
   input  logic                       clk,
   input  logic                       rst_n,
   
   input  logic                       csr_clk,
   input  logic                       csr_rst_n,

   input  pcie_ss_axis_pkg::t_axis_pcie axis_tx,
   input  logic                       axis_tx_tready,

   // Completion Timeout interface
   input  pcie_ss_axis_pkg::t_axis_pcie_cplto    axis_cpl_timeout,

   // Error reporting
   output  logic                      o_err_valid,              
   output  logic [pcie_ss_hdr_pkg::PCIE_HDR_WIDTH-1:0] o_err_hdr,
   output  logic [pcie_ss_hdr_pkg::PF_WIDTH-1:0]       o_err_pf,
   output  logic [pcie_ss_hdr_pkg::VF_WIDTH-1:0]       o_err_vf,
   output  logic                      o_err_vf_active,
   output  logic [31:0]               o_err_code
);


//todo : tie off for now
always_comb begin
   o_err_valid = 1'b0;
   o_err_hdr   = '0;
   o_err_pf    = '0;
   o_err_vf    = '0;
   o_err_vf_active = 1'b0;
   o_err_code = '0;
end

endmodule :pcie_err_checker 
