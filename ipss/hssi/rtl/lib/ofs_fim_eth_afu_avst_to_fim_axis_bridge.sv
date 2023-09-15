// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// FIM AVST <-> AFU AXIS bridge
//
//-----------------------------------------------------------------------------

module ofs_fim_eth_afu_avst_to_fim_axis_bridge (
   // FIM-side AVST interfaces
   ofs_fim_eth_tx_avst_if.slave    avst_tx_st,
   ofs_fim_eth_rx_avst_if.master   avst_rx_st,

   // AFU-side AXI-S interfaces
   ofs_fim_eth_tx_axis_if.master   axi_tx_st,
   ofs_fim_eth_rx_axis_if.slave    axi_rx_st
);

   logic is_rx_sop;

   // ****************************************************
   // *-------------- FIM -> AFU Rx Bridge --------------*
   // ****************************************************
   assign avst_rx_st.clk   = axi_rx_st.clk;
   assign avst_rx_st.rst_n = axi_rx_st.rst_n;

   always_comb
   begin
      axi_rx_st.tready     = avst_rx_st.ready;
      avst_rx_st.rx.valid  = axi_rx_st.rx.tvalid;
      // AVST data is first Symbol In High Order Bits
      avst_rx_st.rx.data   = ofs_fim_eth_avst_if_pkg::eth_axi_to_avst_data(axi_rx_st.rx.tdata);
      avst_rx_st.rx.sop    = axi_rx_st.rx.tvalid & is_rx_sop;
      avst_rx_st.rx.eop    = axi_rx_st.rx.tvalid & axi_rx_st.rx.tlast;
      avst_rx_st.rx.user.error = axi_rx_st.rx.tuser.error;
      avst_rx_st.rx.empty = ofs_fim_eth_avst_if_pkg::eth_tkeep_to_empty(axi_rx_st.rx.tkeep);
   end

   // Rx SOP always follows a tlast AXI-S flit
   always_ff @(posedge axi_rx_st.clk)
   begin
      if (!axi_rx_st.rst_n)
         is_rx_sop <= 1'b1;
      else if (axi_rx_st.rx.tvalid && axi_rx_st.tready)
         is_rx_sop <= axi_rx_st.rx.tlast;
   end

   // ****************************************************
   // *-------------- AFU -> FIM Tx Bridge --------------*
   // ****************************************************
   assign avst_tx_st.clk   = axi_tx_st.clk;
   assign avst_tx_st.rst_n = axi_tx_st.rst_n;

   always_comb
   begin
      avst_tx_st.ready         = axi_tx_st.tready;
      axi_tx_st.tx.tvalid      = avst_tx_st.tx.valid;
      // AVST data is first Symbol In High Order Bits
      axi_tx_st.tx.tdata       = ofs_fim_eth_avst_if_pkg::eth_avst_to_axi_data(avst_tx_st.tx.data);
      axi_tx_st.tx.tlast       = avst_tx_st.tx.eop & avst_tx_st.tx.valid;
      axi_tx_st.tx.tuser.error = avst_tx_st.tx.user.error;
      axi_tx_st.tx.tkeep = ofs_fim_eth_avst_if_pkg::eth_empty_to_tkeep(avst_tx_st.tx.empty);
   end

endmodule
