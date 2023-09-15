// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Functions:
//    * Clock crossing PCIe TX bridge signals from FIM clock domain to PCIe clock domain
//
//-----------------------------------------------------------------------------

import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

module pcie_tx_bridge_cdc (
   input  logic pcie_clk,
   input  logic pcie_rst_n,

   ofs_fim_pcie_txs_axis_if.slave  fim_axis_tx_st,
   ofs_fim_pcie_txs_axis_if.master pcie_axis_tx_st
);

logic fim_clk;
logic fim_rst_n;

logic fifo_wrreq;
logic fifo_rdack;
logic fifo_full;
logic fifo_rvalid;

t_axis_pcie_txs fifo_dout;

/////////////////////////////////////////////////////////////////

assign fim_clk   = fim_axis_tx_st.clk;
assign fim_rst_n = fim_axis_tx_st.rst_n;

assign fim_axis_tx_st.tready = ~fifo_full;
assign fifo_rdack = pcie_axis_tx_st.tready;

// AXIS PCIe TX TLP FIFO
fim_rdack_dcfifo 
#(
   .DATA_WIDTH            (AXIS_PCIE_TXS_WIDTH),
   .DEPTH_LOG2            (8), // depth 256 
   .ALMOST_FULL_THRESHOLD (8),  // assert almfull when empty slots <= 8
   .READ_ACLR_SYNC        ("ON") // add aclr synchronizer on read side
) 
tx_axis_dcfifo
(
   .wclk      (fim_clk),
   .rclk      (pcie_clk),
   .aclr      (~fim_rst_n),
   .wdata     (fim_axis_tx_st.tx), 
   .wreq      (fifo_wrreq),
   .rdack     (fifo_rdack),
   .rdata     (fifo_dout),
   .wfull     (fifo_full),
   .rvalid    (fifo_rvalid)
);

// Write incoming AVL packets to FIFO when FIFO is not full
assign fifo_wrreq = ~fifo_full && fim_axis_tx_st.tx.tvalid;

// PCIE AXIS IF assignment
assign pcie_axis_tx_st.clk   = pcie_clk;
assign pcie_axis_tx_st.rst_n = pcie_rst_n;

always_comb begin
   pcie_axis_tx_st.tx = fifo_dout;
   pcie_axis_tx_st.tx.tvalid = fifo_rvalid;
end

endmodule
