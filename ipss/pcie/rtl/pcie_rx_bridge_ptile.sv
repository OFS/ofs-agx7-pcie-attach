// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Functions:
//    Adapt PCIe HIP IP AVST RX interface to AXI4-S RX streaming interface
//       * The AVST RX interface contains two 256-bit data channels
//       * The AXI4-S RX interface contains single AXI4-S channel with multiple TLP data streams
//         (See fim_if_pkg.sv for details)
//
//    -------
//    P-TILE
//    -------
//    Header and data from AVST channel are directly assigned to the header and data fields on AXIS channel
//    e.g. (Dn : 128-bit data)
//
//         AVST header and data
//            T0: [CH0] (SOP) header:<128-bit header> data:<D1,D0>
//                [CH1] (EOP} header:<Don't care>     data:<D3,D2>
//
//         AXIS header and data
//            [TLP CH0] (SOP) header:<128-bit header> data:<D1,D0>
//            [TLP CH1] (EOP} header:<Don't care>     data:<D3,D2>
// 
//   ------- 
//   Clock domain 
//   ------- 
//   All the inputs and outputs are synchronous to input clock : avl_clk
//
//-----------------------------------------------------------------------------

import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

module pcie_rx_bridge_ptile (
   input  logic                     avl_clk,
   input  logic                     avl_rst_n,
   
   input  t_avst_rxs                avl_rx_st,
   output logic                     avl_rx_ready,  

   ofs_fim_pcie_rxs_axis_if.master  axis_rx_st
);

t_avst_ch  in_tlp_valid;
logic      cur_tlp_valid;
t_avst_rxs cur_tlp;
t_avst_ch cur_rx_sop, cur_rx_eop;

logic           rx_ready;
t_axis_pcie_rxs rx_st_reg;

//////////////////////////////////////////////////////////////

// Interface assignment
assign axis_rx_st.clk   = avl_clk;
assign axis_rx_st.rst_n = avl_rst_n;
assign axis_rx_st.rx    = rx_st_reg;

// Load the pipeline if there is no pending transfer or the current transfer is acknowledged
assign rx_ready     = ~rx_st_reg.tvalid | axis_rx_st.tready;
assign avl_rx_ready = rx_ready;

//-----------------------------
// Register new TLP when bridge is ready to process the next TLP
// Otherwise, keep the current TLP in the register
//-----------------------------
// TLP valid
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1)
      in_tlp_valid[ch] = avl_rx_st[ch].valid;
end

// TLP
always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      cur_tlp_valid  <= 1'b0;
   end else if (rx_ready) begin
      cur_tlp_valid <= |in_tlp_valid;
   end   
end

always_ff @(posedge avl_clk) begin
   if (rx_ready) begin
      cur_tlp <= avl_rx_st;
   end   
end

// SOP and EOP status
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      cur_rx_sop[ch] = cur_tlp[ch].valid && cur_tlp[ch].sop;
      cur_rx_eop[ch] = cur_tlp[ch].valid && cur_tlp[ch].eop;
   end
end

assign rx_st_reg.tlast = 1'b1;

always_ff @(posedge avl_clk) begin
   if (rx_ready) begin
      rx_st_reg.tvalid <= cur_tlp_valid;

      for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
         rx_st_reg.tuser[ch].ummio_rd       <= 1'b0;
         rx_st_reg.tuser[ch].mmio_req       <= cur_tlp[ch].mmio_req;
         rx_st_reg.tuser[ch].dest.vf_active <= cur_tlp[ch].vf_active;
         rx_st_reg.tuser[ch].dest.pfn       <= '0;
         rx_st_reg.tuser[ch].dest.vfn       <= '0;
         rx_st_reg.tuser[ch].dest.pfn       <= cur_tlp[ch].pfn;
         rx_st_reg.tuser[ch].dest.vfn       <= cur_tlp[ch].vfn;
         rx_st_reg.tuser[ch].dest.bar       <= cur_tlp[ch].bar;
         rx_st_reg.tdata[ch].valid          <= cur_tlp[ch].valid;
         rx_st_reg.tdata[ch].sop            <= cur_rx_sop[ch];
         rx_st_reg.tdata[ch].eop            <= cur_rx_eop[ch];
         rx_st_reg.tdata[ch].hdr            <= func_get_hdr(cur_tlp[ch]);
         rx_st_reg.tdata[ch].payload        <= cur_tlp[ch].data;
         rx_st_reg.tdata[ch].rsvd0          <= '0;
      end
   end
   
   if (~avl_rst_n) begin
      rx_st_reg.tvalid <= 1'b0;
      for (int ch=0; ch<FIM_PCIE_TLP_CH; ch=ch+1)
         rx_st_reg.tdata[ch].valid <= 1'b0;
   end
end

endmodule
