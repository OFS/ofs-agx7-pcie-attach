// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Functions:
//    * Clock crossing PCIe RX bridge signals from PCIe clock domain to FIM clock domain
//
//-----------------------------------------------------------------------------

import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

module pcie_rx_bridge_cdc (
   input  logic                   pcie_clk,
   input  logic                   pcie_rst_n,
   
   input  logic                   fim_clk,
   input  logic                   fim_rst_n,
   
   input  t_avst_rxs              pcie_avl_rx_st,
   output logic                   pcie_avl_rx_ready,  
   
   input  logic                   fim_avl_rx_ready,
   output t_avst_rxs              fim_avl_rx_st
);

// AVST interface signals
localparam RX_AVST_FIFO_WIDTH = NUM_AVST_CH * PCIE_RX_AVST_IF_WIDTH;

logic fifo_wreq;
logic fifo_rdack;
logic fifo_full, fifo_almfull;
logic fifo_rvalid;

t_avst_ch fifo_din_valid;
t_avst_rxs fifo_din;
t_avst_rxs fifo_dout_rx_st;

logic fim_avl_rx_valid;

/////////////////////////////////////////////////////////////////////////////////

assign fifo_rdack = ~fim_avl_rx_valid || fim_avl_rx_ready;

// AVL PCIE RX TLP FIFO
fim_rdack_dcfifo 
#(
   .DATA_WIDTH            (RX_AVST_FIFO_WIDTH),
   .DEPTH_LOG2            (6), // depth 64 
   .ALMOST_FULL_THRESHOLD (4),  // assert almfull when empty slots <= 8
   .WRITE_ACLR_SYNC       ("ON") // add aclr synchronizer on write side
) 
rx_avst_dcfifo
(
   .wclk      (pcie_clk),
   .rclk      (fim_clk),
   .aclr      (~fim_rst_n),
   .wdata     (fifo_din), 
   .wreq      (fifo_wreq),
   .rdack     (fifo_rdack),
   .rdata     (fifo_dout_rx_st),
   .wfull     (fifo_full),
   .almfull   (fifo_almfull),
   .rvalid    (fifo_rvalid)
);

// Write incoming AVL packets to FIFO when FIFO is not full
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      fifo_din_valid[ch] = pcie_avl_rx_st[ch].valid;
   end
end

always_ff @(posedge pcie_clk) begin
   fifo_din  <= pcie_avl_rx_st;
   fifo_wreq <= pcie_avl_rx_ready && |fifo_din_valid;

   if (~pcie_rst_n) fifo_wreq <= 1'b0;
end

// Output assignments
always_ff @(posedge pcie_clk) begin
   if (~pcie_rst_n) begin
      pcie_avl_rx_ready <= 1'b0;
   end else begin
      // Backpressure PCIe RX AVST channel when FIFO is almost full
      pcie_avl_rx_ready <= ~fifo_almfull; 
   end
end

always_ff @(posedge fim_clk) begin
   if (fifo_rdack) begin
      fim_avl_rx_st <= fifo_dout_rx_st;
      fim_avl_rx_valid <= fifo_rvalid;
   
      for (int ch=0; ch<NUM_AVST_CH; ++ch) begin
         fim_avl_rx_st[ch].valid <= fifo_rvalid && fifo_dout_rx_st[ch].valid;
         fim_avl_rx_st[ch].sop   <= fifo_rvalid && fifo_dout_rx_st[ch].sop;
         fim_avl_rx_st[ch].eop   <= fifo_rvalid && fifo_dout_rx_st[ch].eop;
      end
   end

   if (~fim_rst_n) begin
      fim_avl_rx_valid <= 1'b0;
      for (int ch=0; ch<NUM_AVST_CH; ++ch)
         fim_avl_rx_st[ch].valid <= 1'b0;
   end
end

endmodule

