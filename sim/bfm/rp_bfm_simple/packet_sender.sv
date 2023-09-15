// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  Send packets from external TX buffer(s) to DUT.
//
//-----------------------------------------------------------------------------

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;

module packet_sender #(
   parameter BUF_SIZE = 2,
   parameter NUM_PKT_BUF = 1, // up-to 2

   // Derived
   parameter LOG2_BUF_SIZE = $clog2(BUF_SIZE) 
)(
   input logic  clk,
   input logic  rst_n,

   // Packet buffer interface
   input  logic [NUM_PKT_BUF-1:0][LOG2_BUF_SIZE:0]    i_buf_size, // Number of packets to be sent
   input  logic [NUM_PKT_BUF-1:0]                     i_send_req, // Send packet request
   output logic [NUM_PKT_BUF-1:0]                     o_send_ack, // Send packet ack

   output logic [NUM_PKT_BUF-1:0][LOG2_BUF_SIZE-1:0]  o_buf_idx,  // Index to packet buffer for next packets to be sent
   input  t_avst_rxs [NUM_PKT_BUF-1:0]                i_packet,   // Next packets

   // Packet sender interface
   output t_avst_rxs o_rx_st, // Sending the packet downstream to DUT
   input  logic i_ready
);

localparam SEL_WIDTH = $clog2(NUM_PKT_BUF);

logic [SEL_WIDTH-1:0]   buf_sel_next, buf_sel;
logic [NUM_PKT_BUF-1:0] buf_sel_1hot;

logic [LOG2_BUF_SIZE:0] num_tx_packet;
logic [LOG2_BUF_SIZE:0] tx_packet_cnt;
 t_avst_rxs tx_packet;

logic pkt_sender_busy;
logic pkt_sender_ack;
logic rx_ready;

////////////////////////////////////////////////////////////////////////////////

assign rx_ready = i_ready;

assign o_buf_idx   = {NUM_PKT_BUF{tx_packet_cnt[LOG2_BUF_SIZE-1:0]}};
assign o_send_ack = {NUM_PKT_BUF{pkt_sender_ack}} & buf_sel_1hot;

always_comb begin
   if (NUM_PKT_BUF > 1) begin
      buf_sel_next = buf_sel;
      casez ({buf_sel, i_send_req})
         3'b0_1? : buf_sel_next = 1'b1; 
         3'b0_01 : buf_sel_next = 1'b0;
         3'b1_?1 : buf_sel_next = 1'b0;
         3'b1_10 : buf_sel_next = 1'b1;
      endcase
   end else begin
      buf_sel_next = 1'b0;
   end
end

always_comb begin
   buf_sel_1hot = '0;
   buf_sel_1hot[buf_sel] = 1'b1;
end

assign tx_packet = i_packet[buf_sel];

always_ff @(posedge clk) begin
   if (~rst_n) begin
      buf_sel <= '0;
      pkt_sender_busy <= '0;
      pkt_sender_ack  <= '0;
      num_tx_packet   <= '0;
      tx_packet_cnt   <= '0;
      for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
         o_rx_st[ch].valid <= 1'b0;
      end
   end else begin
      pkt_sender_ack <= '0;
      o_rx_st[CH0].valid <= 1'b0;
      o_rx_st[CH1].valid <= 1'b0;
      
      if (pkt_sender_busy) begin
         if (tx_packet_cnt == num_tx_packet) begin
            pkt_sender_ack  <= 1'b1;
            pkt_sender_busy <= 1'b0;
         end else if (rx_ready) begin 
            if (tx_packet_cnt == num_tx_packet-1) begin
               o_rx_st[CH0]  <= tx_packet[CH0];
               o_rx_st[CH1]  <= 1'b0;
               tx_packet_cnt <= tx_packet_cnt+1;
            end
            else begin
               o_rx_st <= tx_packet;
               tx_packet_cnt <= tx_packet_cnt+2; 
            end            
         end
      end else if (~pkt_sender_ack && |i_send_req) begin
         buf_sel         <= buf_sel_next;
         num_tx_packet   <= i_buf_size[buf_sel_next];
         pkt_sender_busy <= 1'b1;
         tx_packet_cnt   <= '0;
      end
   end
end

endmodule
