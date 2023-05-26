// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// The TX aligner module aligns the incoming TX packets on AXI-S TX channels
// before sending the packets upstream. 
//
// It does the following:
//
//    (1) Remove idle cycle(s) between packets of a multi-beat TLP so that
//        the packets are sent back-to-back upstream.
//
//-----------------------------------------------------------------------------

module tx_aligner (
   ofs_fim_pcie_txs_axis_if.slave   i_afu_tx_st,
   ofs_fim_pcie_txs_axis_if.master  o_afu_tx_st
);

import ofs_fim_if_pkg::*;
import ofs_fim_pcie_hdr_def::*;

logic clk;
logic rst_n;
logic tx_st_tready;

logic i_tx_tvalid;
logic [FIM_PCIE_TLP_CH-1:0] i_tx_valid;
logic [FIM_PCIE_TLP_CH-1:0] i_tx_eop;
logic [FIM_PCIE_TLP_CH-1:0] loose_tlp;
logic full_ch;
logic wait_data;
logic send_delayed_eop;

t_axis_pcie_tx  tx_st_delayed;
t_axis_pcie_txs tx_st;

//----------------------------------------------------------------------

assign clk   = i_afu_tx_st.clk;
assign rst_n = i_afu_tx_st.rst_n;
assign tx_st_tready = (~o_afu_tx_st.tx.tvalid || o_afu_tx_st.tready);

always_comb begin
   for (int ch=0; ch<FIM_PCIE_TLP_CH; ++ch) begin
      i_tx_valid[ch] = i_afu_tx_st.tx.tdata[ch].valid;
      i_tx_eop[ch]   = i_afu_tx_st.tx.tdata[ch].eop;
   end
   i_tx_tvalid = i_afu_tx_st.tx.tvalid && |i_tx_valid;
end

always_comb begin
   full_ch = 1'b1;
   for (int ch=0; ch<FIM_PCIE_TLP_CH; ++ch) begin
      full_ch = full_ch && i_afu_tx_st.tx.tdata[ch].valid;
   end
end

always_comb begin
   for (int ch=0; ch<FIM_PCIE_TLP_CH; ++ch) begin
      loose_tlp[ch] = i_afu_tx_st.tx.tvalid && ~full_ch && i_tx_valid[ch] && ~i_tx_eop[ch];
   end
end

always_ff @(posedge clk) begin
   if (~rst_n) begin
      wait_data <= 1'b0;
      send_delayed_eop <= 1'b0;
   end else if (tx_st_tready) begin
      send_delayed_eop <= 1'b0;

      if (i_tx_tvalid) begin
         wait_data <= wait_data ? &i_tx_valid : |loose_tlp;
         send_delayed_eop <= wait_data && &i_tx_valid && i_tx_eop[CH1];
      end else if (send_delayed_eop) begin
         wait_data <= 1'b0;
      end 
   end
end

always_ff @(posedge clk) begin
   if (FIM_PCIE_TLP_CH == 1) begin
      tx_st_delayed <= '0;
   end else begin
      if (tx_st_tready && i_tx_tvalid) begin
         tx_st_delayed.tdata <= i_afu_tx_st.tx.tdata[CH1];
         tx_st_delayed.tuser <= i_afu_tx_st.tx.tuser[CH1];
   
         if (~wait_data && i_tx_valid[CH0] && ~i_tx_eop[CH0]) 
         begin
            tx_st_delayed.tdata <= i_afu_tx_st.tx.tdata[CH0];
            tx_st_delayed.tuser <= i_afu_tx_st.tx.tuser[CH0];
         end
      end
   end
end

always_ff @(posedge clk) begin
   if (tx_st_tready) begin
      tx_st.tvalid <= 1'b0;
      
      if (FIM_PCIE_TLP_CH == 1) begin
         tx_st <= i_afu_tx_st.tx;
      end else begin
         if (wait_data) begin

            tx_st.tdata[CH0] <= tx_st_delayed.tdata;
            tx_st.tuser[CH0] <= tx_st_delayed.tuser;

            tx_st.tdata[CH1] <= i_tx_valid[CH0] ? i_afu_tx_st.tx.tdata[CH0] : i_afu_tx_st.tx.tdata[CH1]; 
            tx_st.tuser[CH1] <= i_tx_valid[CH0] ? i_afu_tx_st.tx.tuser[CH0] : i_afu_tx_st.tx.tuser[CH1]; 
            
            if (~i_tx_tvalid && send_delayed_eop) begin
               tx_st.tdata[CH1].valid <= 1'b0;
            end
            tx_st.tvalid <= (i_tx_tvalid || send_delayed_eop);
         end else begin 
            // Move packet from channel 1 to channel 0 if channel 0 is not occupied
            // Only EOP packet is expected to fall under this scenario
            tx_st <= i_afu_tx_st.tx;
            
            if (~i_tx_valid[CH0]) begin
               tx_st.tdata[CH0]       <= i_afu_tx_st.tx.tdata[CH1];
               tx_st.tuser[CH0]       <= i_afu_tx_st.tx.tuser[CH1];
               tx_st.tdata[CH0].valid <= i_tx_valid[CH1];
               tx_st.tdata[CH1].valid <= 1'b0;
            end

            tx_st.tvalid <= i_tx_tvalid && ~|loose_tlp;
         end 
      end
   end

   if (~rst_n) begin
      tx_st.tvalid <= 1'b0;
      for (int ch=0; ch<FIM_PCIE_TLP_CH; ++ch) begin
         tx_st.tdata[ch].valid <= 1'b0;
      end
   end 
end

// Output assignment
always_comb begin
   o_afu_tx_st.clk    = i_afu_tx_st.clk;
   o_afu_tx_st.rst_n  = i_afu_tx_st.rst_n;
   o_afu_tx_st.tx     = tx_st;
   i_afu_tx_st.tready = tx_st_tready;
end

// synopsys translate_off
   assert_ch0_no_idle_cycle:
      assert property (@(posedge clk) disable iff (~rst_n) ((o_afu_tx_st.tx.tvalid && !o_afu_tx_st.tx.tdata[CH0].valid) |-> !o_afu_tx_st.tx.tdata[CH1].valid))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, idle cycle detected on channel 0", $time));
   
   assert_ch1_no_idle_cycle:
      assert property (@(posedge clk) disable iff (~rst_n) ((o_afu_tx_st.tx.tvalid && o_afu_tx_st.tx.tdata[CH0].valid && !o_afu_tx_st.tx.tdata[CH0].eop) |-> o_afu_tx_st.tx.tdata[CH1].valid))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, idle cycle detected on channel 1", $time));
   
   assert_malformed_sop:
      assert property (@(posedge clk) disable iff (~rst_n) ((o_afu_tx_st.tx.tvalid && o_afu_tx_st.tx.tdata[CH0].valid && !o_afu_tx_st.tx.tdata[CH0].eop) |-> !o_afu_tx_st.tx.tdata[CH1].sop))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, missing end of packet", $time));

// synopsys translate_on

endmodule : tx_aligner
