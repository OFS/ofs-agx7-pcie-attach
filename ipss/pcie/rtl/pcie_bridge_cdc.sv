// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Functions:
//    * Clock crossing between PCIE clock domain and FIM clock domain
//
//-----------------------------------------------------------------------------

import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

module pcie_bridge_cdc (
   input  logic                    pcie_clk,
   input  logic                    pcie_rst_n,
   
   input  logic                    fim_clk,
   input  logic                    fim_rst_n,
   
   input  t_avst_rxs               pcie_avl_rx_st,
   output logic                    pcie_avl_rx_ready,  
   
   output t_avst_rxs               fim_avl_rx_st,
   input  logic                    fim_avl_rx_ready,

   ofs_fim_pcie_txs_axis_if.slave  fim_axis_tx_st,
   ofs_fim_pcie_txs_axis_if.master pcie_axis_tx_st
);

pcie_rx_bridge_cdc rx_cdc (
   .pcie_clk          (pcie_clk),
   .pcie_rst_n        (pcie_rst_n),
   .pcie_avl_rx_st    (pcie_avl_rx_st),
   .pcie_avl_rx_ready (pcie_avl_rx_ready),
   
   .fim_clk           (fim_clk),
   .fim_rst_n         (fim_rst_n),
   .fim_avl_rx_st     (fim_avl_rx_st),
   .fim_avl_rx_ready  (fim_avl_rx_ready)
);

pcie_tx_bridge_cdc tx_cdc (
   .pcie_clk        (pcie_clk),
   .pcie_rst_n      (pcie_rst_n),
   .fim_axis_tx_st  (fim_axis_tx_st),
   .pcie_axis_tx_st (pcie_axis_tx_st)
);

endmodule

