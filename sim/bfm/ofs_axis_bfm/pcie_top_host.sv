// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Top level module of PCIe subsystem.
//
//-----------------------------------------------------------------------------
`ifndef __PFVF_SWITCH_HOST__
`define __PFVF_SWITCH_HOST__
`endif

`include "fpga_defines.vh"
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;
import host_bfm_types_pkg::*;

module pcie_top_host # (
   parameter            PCIE_LANES           = 16,
   parameter            NUM_PF               = 1,
   parameter            NUM_VF               = 1,
   parameter            MAX_NUM_VF           = 1,
   parameter            SOC_ATTACH           = 0,
   parameter type       PF_ENABLED_VEC_T     = default_pfs,
   parameter PF_ENABLED_VEC_T PF_ENABLED_VEC = '{1'b1},
   parameter type       PF_NUM_VFS_VEC_T     = default_vfs,
   parameter PF_NUM_VFS_VEC_T PF_NUM_VFS_VEC = '{0},
   parameter            MM_ADDR_WIDTH        = 19,
   parameter            MM_DATA_WIDTH        = 64,
   parameter bit [11:0] FEAT_ID              = 12'h0,
   parameter bit [3:0]  FEAT_VER             = 4'h0,
   parameter bit [23:0] NEXT_DFH_OFFSET      = 24'h1000,
   parameter bit        END_OF_LIST          = 1'b0
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


//-----------------------------------------------------------------------------
// Tie off unused signals
assign csr_lite_if.awready = 1'b1;
assign csr_lite_if.wready  = 1'b1;
assign csr_lite_if.arready = 1'b1;
assign csr_lite_if.bvalid  = 1'b0;
assign csr_lite_if.rvalid  = 1'b0;
assign pin_pcie_tx_p = '0;
assign pin_pcie_tx_n = '1;

//-------------------------------------
// Completion timeout interface, Inactive.
//-------------------------------------
always_comb begin
   cpl_timeout_if.tvalid = 1'b0;
   cpl_timeout_if.tdata  = '0;
end

// Synchronizer for PCIe Sideband Interfaces
localparam CSR_STAT_SYNC_WIDTH = 33;
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(CSR_STAT_SYNC_WIDTH),
   .INIT_VALUE(0),
   .NO_CUT(1)
) csr_resync (
   .clk   (csr_clk),
   .reset (~csr_rst_n),
   .d     ({1'b1, {32{1'b1}}}),
   .q     ({pcie_p2c_sideband.pcie_linkup, pcie_p2c_sideband.pcie_chk_rx_err_code})
);

initial 
begin
  $vcdpluson;
  $vcdplusmemon();
end

initial
begin
   reset_status = 1'b1;
   #10000;
   reset_status = 1'b0;
end

// Connections to Host BFM via AXI-ST Streaming Interfaces
host_bfm_top host_bfm_top(
   .axis_rx_req(axi_st_rxreq_if),
   .axis_tx(axi_st_tx_if),
   .axis_rx(axi_st_rx_if),
   .axis_tx_req(axi_st_txreq_if)
);


// Connections to Function-Level Reset (FLR) Manager
host_flr_top host_flr_top(
   .clk(csr_clk),
   .rst_n(csr_rst_n),
   .flr_req_if(flr_req_if),
   .flr_rsp_if(flr_rsp_if)
);

// Instantiation of Unit Test
host_unit_test host_unit_test(
   .clk(fim_clk),
   .rst_n(fim_rst_n),
   .csr_clk(csr_clk),
   .csr_rst_n(csr_rst_n)
);



endmodule
