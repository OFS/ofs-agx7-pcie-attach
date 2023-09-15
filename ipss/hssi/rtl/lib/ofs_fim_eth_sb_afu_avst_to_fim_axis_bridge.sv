// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// Sideband FIM AVST <-> AFU AXIS bridge
//
//-----------------------------------------------------------------------------

module ofs_fim_eth_sb_afu_avst_to_fim_axis_bridge (
   // FIM-side AVST interfaces
   ofs_fim_eth_sideband_tx_avst_if.slave    avst_tx_st,
   ofs_fim_eth_sideband_rx_avst_if.master   avst_rx_st,

   // AFU-side AXI-S interfaces
   ofs_fim_eth_sideband_tx_axis_if.master   axi_tx_st,
   ofs_fim_eth_sideband_rx_axis_if.slave    axi_rx_st
);

   // ****************************************************
   // *-------------- FIM -> AFU Rx Bridge --------------*
   // ****************************************************
   assign avst_rx_st.clk       = axi_rx_st.clk;
   assign avst_rx_st.rst_n     = axi_rx_st.rst_n;
   assign avst_rx_st.sb.valid  = axi_rx_st.sb.tvalid;
   assign avst_rx_st.sb.data   = axi_rx_st.sb.tdata;

   // ****************************************************
   // *-------------- AFU -> FIM Tx Bridge --------------*
   // ****************************************************
   assign avst_tx_st.clk      = axi_tx_st.clk;
   assign avst_tx_st.rst_n    = axi_tx_st.rst_n;
   assign axi_tx_st.sb.tvalid = avst_tx_st.sb.valid;
   assign axi_tx_st.sb.tdata  = avst_tx_st.sb.data;

endmodule
