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
//    H-TILE
//    -------
//    Extract header from the data channel and put onto the header field of the AXIS data channel
//    Data belongs to the same AVST TLP should be put contiguously onto the data field of the AXIS data channel
//    e.g. (Dn : 128-bit data)
//
//         AVST data
//            T0:  [CH0] (SOP) data:<128-bit header><D0> 
//                 [CH1] <D2,D1>
//            T1:  [CH0] (EOP) data:<D3>
//         
//         AXIS data
//            The bridge will move the packets from two transactions into 1 transaction on the AXIS channel
//               [TLP CH0] (SOP) header:<128-bit header>  data:<D1,D0>
//               [TLP CH1] (EOP) header:<Don't care>      data:<D3,D2>
//
//   ------- 
//   Clock domain 
//   ------- 
//   All the inputs and outputs are synchronous to input clock : avl_clk
//
//-----------------------------------------------------------------------------

import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

module pcie_rx_bridge_htile (
   input  logic                     avl_clk,
   input  logic                     avl_rst_n,
   input  t_avst_rxs                avl_rx_st,
   output logic                     avl_rx_ready,  
   
   ofs_fim_pcie_rxs_axis_if.master  axis_rx_st
);

import ofs_fim_pcie_hdr_def::*;

enum {CH0, CH1} e_channel;

localparam HDR_3DW = 3;
localparam HDR_4DW = 4;
localparam HDR_LWIDTH = $clog2(HDR_4DW) + 1;

localparam HDR_3DW_WIDTH = HDR_3DW*32;
localparam HDR_4DW_WIDTH = HDR_4DW*32;

t_avst_ch is_hdr_4dw;
logic     is_hdr_4dw_q;
logic     empty;
logic [NUM_AVST_CH-1:0] [HDR_LWIDTH-1:0] hdr_len;

t_avst_ch  in_tlp_valid;
logic      cur_tlp_valid, next_tlp_valid;
t_avst_rxs cur_tlp, next_tlp;

t_tlp_hdr_dw0 [NUM_AVST_CH-1:0] cur_tlp_hdr_dw0;
t_avst_ch cur_rx_sop, cur_rx_eop;
t_avst_ch next_rx_sop, next_rx_eop;
logic wait_for_data;

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
      next_tlp_valid <= 1'b0;
   end else if (rx_ready) begin
      next_tlp_valid <= |in_tlp_valid;
   end   
end

always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      cur_tlp_valid  <= 1'b0;
   end else if (rx_ready && (~wait_for_data || next_tlp_valid)) begin
      cur_tlp_valid  <= next_tlp_valid;
   end   
end

always_ff @(posedge avl_clk) begin
   if (rx_ready) begin
      next_tlp <= avl_rx_st;
      
      if (~wait_for_data || next_tlp_valid) begin
         cur_tlp      <= next_tlp;
      end
   end   
end

// SOP and EOP status
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      cur_rx_sop[ch] = cur_tlp[ch].valid && cur_tlp[ch].sop;
      cur_rx_eop[ch] = cur_tlp[ch].valid && cur_tlp[ch].eop;
      
      next_rx_sop[ch] = next_tlp[ch].valid && next_tlp[ch].sop;
      next_rx_eop[ch] = next_tlp[ch].valid && next_tlp[ch].eop;
   end
end

// Track if there is enough data payload to construct the output TLP packet
always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      wait_for_data <= 1'b0;
   end else if (next_tlp_valid) begin
      if (next_rx_sop[CH1]) begin
         wait_for_data <= ~next_rx_eop[CH1];
      end else if (next_rx_sop[CH0]) begin
         wait_for_data <= ~next_rx_eop[CH0] && ~next_rx_eop[CH1];
      end else if (~next_rx_eop[CH0] && ~next_rx_eop[CH1]) begin
         wait_for_data <= 1'b1;
      end else begin
         wait_for_data <= 1'b0;
      end
   end 
end

always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      // fmttype[5] bit is located at bit-29 of dw0 in the header
      // This bit tells if the header length is 3DW or 4DW 
      cur_tlp_hdr_dw0[ch] = t_tlp_hdr_dw0'(func_get_hdr_dw0(cur_tlp[ch]));
      is_hdr_4dw[ch]      = cur_rx_sop[ch] ? cur_tlp_hdr_dw0[ch].fmttype[5] : is_hdr_4dw_q;
      hdr_len[ch]         = is_hdr_4dw[ch] ? HDR_4DW : HDR_3DW;
   end
end

assign  rx_st_reg.tlast = 1'b1;

always_ff @(posedge avl_clk) begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (rx_ready) begin
         rx_st_reg.tuser[ch].ummio_rd       <= 1'b0;
         rx_st_reg.tuser[ch].mmio_req       <= cur_tlp[ch].mmio_req;
         rx_st_reg.tuser[ch].dest.vf_active <= cur_tlp[ch].vf_active;
         rx_st_reg.tuser[ch].dest.pfn       <= '0;
         rx_st_reg.tuser[ch].dest.vfn       <= '0;
         rx_st_reg.tuser[ch].dest.pfn       <= cur_tlp[ch].pfn;
         rx_st_reg.tuser[ch].dest.vfn       <= cur_tlp[ch].vfn;
         rx_st_reg.tuser[ch].dest.bar       <= cur_tlp[ch].bar;
         rx_st_reg.tdata[ch].hdr            <= func_get_hdr(cur_tlp[ch]);
         rx_st_reg.tdata[ch].sop            <= cur_tlp[ch].sop;
         rx_st_reg.tdata[ch].rsvd0          <= '0;
      end
   end

   if (NUM_AVST_CH == 1) begin
      if (rx_ready) begin
         empty <= 1'b0;
         rx_st_reg.tvalid             <= 1'b0;
         rx_st_reg.tdata[CH0].valid   <= 1'b0;
         rx_st_reg.tdata[CH0].eop     <= 1'b0;
         rx_st_reg.tdata[CH0].payload <= '0;

         if ((~wait_for_data || next_tlp_valid) && cur_tlp_valid)            
         begin
            if (~empty) begin
               rx_st_reg.tvalid <= 1'b1;
               rx_st_reg.tdata[CH0].valid <= 1'b1;
               
               // SOP
               if (cur_rx_sop[CH0]) begin
                  fill_payload_lsb(CH0, hdr_len[CH0], cur_tlp[CH0]);
                  // Start of single cycle TLP: SOP & EOP on the same cycle
                  if (cur_rx_eop[CH0]) begin
                     rx_st_reg.tdata[CH0].eop   <= 1'b1;
                  end 
                  // Start of multi-cycle TLP
                  else begin 
                     fill_payload_msb(CH0, hdr_len[CH0], next_tlp[CH0]);
                     if (next_rx_eop[CH0] && hdr_len[CH0] >= (AVST_DWORD_LEN - next_tlp[CH0].empty)) begin
                        rx_st_reg.tdata[CH0].eop <= 1'b1;
                        empty <= 1'b1;
                     end
                  end
               end 
               // Multi-cycle TLP, end of packet
               else if (cur_rx_eop[CH0]) begin
                  fill_payload_lsb(CH0, hdr_len[CH0], cur_tlp[CH0]);
                  rx_st_reg.tdata[CH0].eop   <= 1'b1;              
               end 
               // Multi-cycle TLP, data payload
               else if (cur_tlp[CH0].valid) begin
                  fill_payload_lsb(CH0, hdr_len[CH0], cur_tlp[CH0]);
                  fill_payload_msb(CH0, hdr_len[CH0], next_tlp[CH0]);
                  if (next_rx_eop[CH0] && hdr_len[CH0] >= (AVST_DWORD_LEN - next_tlp[CH0].empty)) begin
                     rx_st_reg.tdata[CH0].eop <= 1'b1;
                     empty <= 1'b1;
                  end
               end
            end
         end
      end
   end else begin
      if (rx_ready) begin
         empty            <= 1'b0;
         rx_st_reg.tvalid <= 1'b0;
         
         for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
            rx_st_reg.tdata[ch].valid   <= 1'b0;
            rx_st_reg.tdata[ch].eop     <= 1'b0;
            rx_st_reg.tdata[ch].payload <= '0;
         end

         if ((~wait_for_data || next_tlp_valid) && cur_tlp_valid) 
         begin
            if (~empty) begin
               rx_st_reg.tvalid <= 1'b1;
               
               // SOP on channel 0
               if (cur_rx_sop[CH0]) begin                
                  fill_payload_lsb(CH0, hdr_len[CH0], cur_tlp[CH0]);
                  // Start of single cycle TLP: SOP & EOP on channel 0
                  if (cur_rx_eop[CH0]) begin
                     rx_st_reg.tdata[CH0].valid <= 1'b1;
                     rx_st_reg.tdata[CH0].eop   <= 1'b1;
                  end 
                  // Start of single cycle TLP: SOP on channel 0 and EOP on channel 1
                  else if (cur_rx_eop[CH1]) begin
                     fill_payload_msb(CH0, hdr_len[CH0], cur_tlp[CH1]);
                     fill_payload_lsb(CH1, hdr_len[CH0], cur_tlp[CH1]);

                     rx_st_reg.tdata[CH0].valid <= 1'b1;
                     if (hdr_len[CH0] >= (AVST_DWORD_LEN - cur_tlp[CH1].empty)) begin
                        rx_st_reg.tdata[CH0].eop <= 1'b1;
                     end else begin
                        rx_st_reg.tdata[CH1].valid <= 1'b1;
                        rx_st_reg.tdata[CH1].eop   <= 1'b1;
                     end
                  end
                  // Start of multi-cycle TLP, SOP on channel 0 and channel 1 carries data payload
                  else begin
                     // H-tile PCIe HIP IP places packet on channel 1 when there is packet on channel 0 for a multi-cycle TLP
                     // i.e. when CH0.valid=1, then it is safe to assume CH1.valid=1
                     fill_payload_msb(CH0, hdr_len[CH0], cur_tlp[CH1]);
                     fill_payload_lsb(CH1, hdr_len[CH0], cur_tlp[CH1]);
                     fill_payload_msb(CH1, hdr_len[CH0], next_tlp[CH0]);
                     
                     rx_st_reg.tdata[CH0].valid <= 1'b1;
                     rx_st_reg.tdata[CH1].valid <= 1'b1;

                     if (next_rx_eop[CH0] && hdr_len[CH0] >= (AVST_DWORD_LEN - next_tlp[CH0].empty)) begin
                        rx_st_reg.tdata[CH1].eop <= 1'b1;
                        empty <= 1'b1;
                     end 
                  end
               end 
               // End of multi-cycle TLP on channel 0
               else if (cur_rx_eop[CH0]) begin
                  fill_payload_lsb(CH0, hdr_len[CH0], cur_tlp[CH0]);
                  rx_st_reg.tdata[CH0].valid <= 1'b1;
                  rx_st_reg.tdata[CH0].eop   <= 1'b1;
               end 
               // End of multi-cycle TLP on channel 1, channel 0 carries the data payload
               else if (cur_tlp[CH0].valid && cur_rx_eop[CH1]) begin
                  fill_payload_lsb(CH0, hdr_len[CH0], cur_tlp[CH0]);
                  fill_payload_msb(CH0, hdr_len[CH0], cur_tlp[CH1]);
                  fill_payload_lsb(CH1, hdr_len[CH0], cur_tlp[CH1]);

                  rx_st_reg.tdata[CH0].valid <= 1'b1;
                  if (hdr_len[CH0] >= (AVST_DWORD_LEN - cur_tlp[CH1].empty)) begin
                     rx_st_reg.tdata[CH0].eop  <= 1'b1;
                  end else begin
                     rx_st_reg.tdata[CH1].valid <= 1'b1;
                     rx_st_reg.tdata[CH1].eop   <= 1'b1;
                  end
               end
               // Mid of multi-cycle TLP: both channels carry the data payload
               else if (cur_tlp[CH0].valid) begin
                  // H-tile PCIe HIP IP places packet on channel 1 when there is packet on channel 0 for a multi-cycle TLP
                  // i.e. when CH0.valid=1, then it is safe to assume CH1.valid=1
                  fill_payload_lsb(CH0, hdr_len[CH0], cur_tlp[CH0]);
                  fill_payload_msb(CH0, hdr_len[CH0], cur_tlp[CH1]);
                  fill_payload_lsb(CH1, hdr_len[CH0], cur_tlp[CH1]);
                  fill_payload_msb(CH1, hdr_len[CH0], next_tlp[CH0]);
                  
                  rx_st_reg.tdata[CH0].valid <= 1'b1;
                  rx_st_reg.tdata[CH1].valid <= 1'b1;
                  if (next_rx_eop[CH0] && hdr_len[CH0] >= (AVST_DWORD_LEN - next_tlp[CH0].empty)) begin
                     rx_st_reg.tdata[CH1].eop <= 1'b1;
                     empty <= 1'b1;
                  end
               end
            end 

            // Channel 1
            if (cur_rx_sop[CH1]) begin
               rx_st_reg.tvalid <= 1'b1;
               rx_st_reg.tdata[CH1].valid <= 1'b1;
               
               fill_payload_lsb(CH1, hdr_len[CH1], cur_tlp[CH1]);
               // Start of single cycle TLP on channel 1
               if (cur_rx_eop[CH1]) begin
                  rx_st_reg.tdata[CH1].eop  <= 1'b1;
               end
               // Start of multi-cycle TLP on channel 1
               else begin
                  fill_payload_msb(CH1, hdr_len[CH1], next_tlp[CH0]);
                  if (next_rx_eop[CH0] && hdr_len[CH1] >= (AVST_DWORD_LEN - next_tlp[CH0].empty)) begin
                     rx_st_reg.tdata[CH1].eop <= 1'b1;
                     empty <= 1'b1;
                  end
               end
            end
         end
      end
   end

   if (~avl_rst_n) begin
      empty <= 1'b0;
      rx_st_reg.tvalid <= 1'b0;
      for (int ch=0; ch<FIM_PCIE_TLP_CH; ch=ch+1)
         rx_st_reg.tdata[ch].valid <= 1'b0;
   end
end

// Keep the header length information for multi-cycle TLP
always @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      is_hdr_4dw_q <= '0;
   end else if (rx_ready) begin
      if (NUM_AVST_CH == 1) begin
         if (cur_rx_sop[CH0]) 
            is_hdr_4dw_q <= is_hdr_4dw[CH0];
      end else begin
         if (cur_rx_sop[CH1])
            is_hdr_4dw_q <= is_hdr_4dw[CH1];
         else if (cur_rx_sop[CH0])
            is_hdr_4dw_q <= is_hdr_4dw[CH0];
      end
   end
end

//-------------------------------------------
// Tasks and Functions
//-------------------------------------------
task fill_payload_lsb;
   input integer ch;
   input logic [HDR_LWIDTH-1:0] hdr_len;
   input t_avst_pcie_rx rx_tlp;
begin
   if (ch == 0) begin
      if (~hdr_len[2]) // 3DW header
         rx_st_reg.tdata[CH0].payload[0+:(AVST_DW-HDR_3DW_WIDTH)] <= rx_tlp.data[AVST_DW-1:HDR_3DW_WIDTH];
      else
         rx_st_reg.tdata[CH0].payload[0+:(AVST_DW-HDR_4DW_WIDTH)] <= rx_tlp.data[AVST_DW-1:HDR_4DW_WIDTH];
   end else begin
      if (~hdr_len[2]) // 3DW header
         rx_st_reg.tdata[CH1].payload[0+:(AVST_DW-HDR_3DW_WIDTH)] <= rx_tlp.data[AVST_DW-1:HDR_3DW_WIDTH];
      else
         rx_st_reg.tdata[CH1].payload[0+:(AVST_DW-HDR_4DW_WIDTH)] <= rx_tlp.data[AVST_DW-1:HDR_4DW_WIDTH];
   end
end
endtask


task fill_payload_msb;
   input integer ch;
   input logic [HDR_LWIDTH-1:0] hdr_len;
   input t_avst_pcie_rx rx_tlp;
begin
   if (ch == 0) begin
      if (~hdr_len[2]) // 3DW header
         rx_st_reg.tdata[CH0].payload[(AVST_DW-HDR_3DW_WIDTH)+:HDR_3DW_WIDTH] <= rx_tlp.data[0+:HDR_3DW_WIDTH];
      else
         rx_st_reg.tdata[CH0].payload[(AVST_DW-HDR_4DW_WIDTH)+:HDR_4DW_WIDTH] <= rx_tlp.data[0+:HDR_4DW_WIDTH];
   end else begin
      if (~hdr_len[2]) // 3DW header
         rx_st_reg.tdata[CH1].payload[(AVST_DW-HDR_3DW_WIDTH)+:HDR_3DW_WIDTH] <= rx_tlp.data[0+:HDR_3DW_WIDTH];
      else
         rx_st_reg.tdata[CH1].payload[(AVST_DW-HDR_4DW_WIDTH)+:HDR_4DW_WIDTH] <= rx_tlp.data[0+:HDR_4DW_WIDTH];
   end
end
endtask

endmodule
