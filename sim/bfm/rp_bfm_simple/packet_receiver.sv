// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Receives packets on AVST interface and stores the packets in a buffer.
//   Routes MMIO response packets to o_cpl_st interface
//   Routes memory request packets to o_mem_st interface
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;

module packet_receiver #(
   parameter BUF_SIZE = 2,
   parameter READY_LATENCY = 3,

   // Derived
   parameter LOG2_BUF_SIZE = $clog2(BUF_SIZE) 
)(
   input logic clk,
   input logic rst_n,

   // Packet receiver interface
   input t_avst_pcie_tx [NUM_AVST_CH-1:0] i_tx_st,    
   output logic o_tx_st_ready,

   output t_avst_pcie_tx o_cpl_st,
   input logic i_cpl_st_ready,

   output t_avst_pcie_tx o_mem_st,
   input logic i_mem_st_ready
);

import ofs_fim_pcie_hdr_def::*;

// Rx buffer

t_avst_pcie_tx [NUM_AVST_CH-1:0] tx_st;
t_avst_pcie_tx [BUF_SIZE-1:0] tx_buffer;
t_avst_pcie_tx buf_dout;
logic buf_dout_valid;
logic read_ack;

logic write, read;
logic [LOG2_BUF_SIZE-1:0] wptr, wptr_next, rptr;
logic [LOG2_BUF_SIZE:0] usedw;
logic full, almfull;
logic empty;

assign tx_st = i_tx_st;

// Modeling PCIe IP latency requirement by de-asserting ready <READY_LATENCY> cycles earlier 
// before RX buffer becomes full, to allow <READY_LATENCY> cycles of packets after ready is de-asserted
assign o_tx_st_ready = ~almfull; 

// Write TLP packet into RX buffer
assign write = ~full && (tx_st[CH0].valid || tx_st[CH1].valid);

assign full    = (usedw == BUF_SIZE);
assign almfull = (usedw >= BUF_SIZE-READY_LATENCY*2-1); // *2 for two channels 
assign empty = (usedw == 0);

always_ff @(posedge clk) begin
   if (~rst_n) begin
      wptr <= '0;
      wptr_next <= 'h1;
   end else begin
      if (write) begin
         if (tx_st[CH0].valid && tx_st[CH1].valid) 
         begin
            tx_buffer[wptr]      <= tx_st[CH0];
            tx_buffer[wptr_next] <= tx_st[CH1];
            wptr <= wptr + 2;
            wptr_next <= wptr + 3;
         end else if (tx_st[CH0].valid)
         begin
            tx_buffer[wptr] <= tx_st[CH0];
            wptr <= wptr + 1;
            wptr_next <= wptr + 2;
         end else if (tx_st[CH1].valid)
         begin
            tx_buffer[wptr] <= tx_st[CH1];
            wptr <= wptr + 1;
            wptr_next <= wptr + 2;
         end
      end
   end
end

assign read = ~empty && (~buf_dout_valid || read_ack);

always_ff @(posedge clk) begin
   if (~rst_n) begin
      rptr <= '0;
      buf_dout_valid <= 1'b0;
   end else begin
      if (empty && read_ack) buf_dout_valid <= 1'b0;
      if (read) begin
         buf_dout_valid <= 1'b1;
         rptr <= rptr + 1'b1;
      end
   end
end

always_ff @(posedge clk) begin
   if (read) buf_dout <= tx_buffer[rptr];
end

always_ff @(posedge clk) begin
   if (~rst_n) begin
      usedw <= '0;
   end else begin
      if (write) begin
         if (tx_st[CH0].valid && tx_st[CH1].valid) begin
            usedw <= read ? (usedw + 2'h1) : (usedw + 2'h2);
         end else begin
            usedw <= read ? usedw : (usedw + 2'h1);
         end
      end else if (read) begin
         usedw <= (usedw - 2'h1);
      end
   end
end

// Reading from the buffer
logic cpl_ready;
logic mem_ready;

t_tlp_cpl_hdr hdr;
logic is_cpl;

assign cpl_ready = ~o_cpl_st.valid || i_cpl_st_ready;
assign mem_ready = ~o_mem_st.valid || i_mem_st_ready;
assign read_ack  = cpl_ready && mem_ready;

`ifdef HTILE
   assign hdr = to_big_endian(buf_dout.data[127:0]);
`else
   assign hdr = buf_dout.hdr;
`endif


always_ff @(posedge clk) begin
   if (~rst_n) begin
      o_cpl_st <= '0;
      o_mem_st  <= '0;
      is_cpl <= 1'b0;
   end else begin
      if (cpl_ready && mem_ready) begin
         o_cpl_st.valid <= 1'b0;
         o_mem_st.valid <= 1'b0;
         if (buf_dout_valid) begin
            if (buf_dout.sop) begin
               if (func_is_completion(hdr.dw0.fmttype)) begin
                  o_cpl_st <= buf_dout;
                  is_cpl <= 1'b1;
               end else begin
                  o_mem_st <= buf_dout;
                  is_cpl <= 1'b0;
               end
            end else begin
               if (is_cpl) o_cpl_st <= buf_dout;
               else o_mem_st <= buf_dout;
            end
         end
      end 
   end
end


endmodule

