// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   ------- 
//   Functions:
//   ------- 
//   Adapt AXI4-S TX streaming interface to PCIe HIP IP AVST TX interface 
//      * The AVST TX interface contains two 256-bit data channels
//      * The AXI4-S TX interface contains single AXI4-S channel with multiple TLP data streams
//        (See fim_if_pkg.sv for details)
//   Tracks cpl_pending_data_cnt from PCIe Checker and stalls MRd requests if RX buffer credit is low
//
//   ------- 
//   Clock domain 
//   ------- 
//   All the inputs and outputs are synchronous to input clock : avl_clk
//
//-----------------------------------------------------------------------------


module pcie_tx_bridge_htile (
   input  logic                           avl_clk,
   input  logic                           avl_rst_n, // Synchronous reset
   output t_avst_txs                      avl_tx_st,
   input  logic                           avl_tx_ready,

   ofs_fim_pcie_txs_axis_if.slave         axis_tx_st,

   output logic                           tx_mrd_valid,
   output logic [PCIE_MAX_LEN_WIDTH-1:0]  tx_mrd_length,
   output logic [PCIE_EP_TAG_WIDTH-1:0]   tx_mrd_tag,
   output logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]            tx_mrd_pfn,
   output logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]            tx_mrd_vfn,
   output logic                           tx_mrd_vf_act,

   input  logic [CPL_CREDIT_WIDTH-1:0]    cpl_pending_data_cnt
);

import ofs_fim_pcie_hdr_def::*;
import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

localparam AVST_WIDTH_DW = AVST_DW/(8*4); // 256/32=8DW

// In order to fit a max payload length TLP of 64DW + max header size of 4DW, we need space for 68DW
// One FIFO word can store up to 2 channels * 8DW per channel = 16DW
// Therefore we need 68DW/16DW = 5 FIFO words to buffer 1 max size TLP
// We want to maximize the throughput while minimizing the FIFO footprint
// At the very minimum, not considering PCIe HIP backpressure, we need to be able to store 2 full max size TLPs, making depth of 10 a minimum requirement
// Considering the latency between writes and reads as well as PCIe HIP backpressure, we want to be able to store at least 5 full max size TLPs, FIFO depth 25
// The main bottleneck in throughput becomes when we have back-to-back SOP_EOP_NOFIT packets on both channels because H-Tile bridge logic has to backpressure upstream logic 
localparam FIFO_DEPTH = 5*(ofs_fim_cfg_pkg::MAX_PAYLOAD_SIZE+4)/(ofs_fim_if_pkg::FIM_PCIE_TLP_CH*AVST_WIDTH_DW);
localparam FIFO_DEPTH_LOG2 = $clog2(FIFO_DEPTH); // allocate depth of 32
localparam logic [FIFO_DEPTH_LOG2-1:0] FIFO_FULL_DEPTH = '1;
localparam FIFO_AFULL_THRESHOLD = FIFO_FULL_DEPTH-2;

typedef enum {CH0, CH1, CH2} e_channel;
typedef enum {OFFSET_3DW, OFFSET_4DW, OFFSET_ERR} e_offset;

// Per-channel packet states
typedef enum logic [6:0] {
   SOP,
   SOP_EOP_FIT,
   SOP_EOP_NOFIT,
   EOP_FIT,
   EOP_NOFIT,
   NUL,
   CTND
} t_packet_state;

t_packet_state packet_state      [1:0];
t_packet_state packet_state_next [1:0];

typedef struct packed {
   logic                valid;
   logic [AVST_DW-1:0]  data;
   e_offset             offset;
   logic [2:0]          offset_eop;
   logic                vf_active;
} t_tx_buffer;

t_tx_buffer [2:0] tx_buffer;

t_avst_txs avl_tx_st_reg, avl_tx_st_reg2;
logic [2:0] avl_tx_ready_q;
logic rx_cpl_buffer_ready;
logic tlp_map_ready;
logic sop_on_ch1, generate_sop;
logic merge_axis_despite_map_not_ready;
logic [CPL_CREDIT_WIDTH-1:0] mrd_length [1:0]; // 1DW units
e_offset offset [1:0];
logic [1:0] packet_fit_comb, packet_fit_q;

logic [NUM_AVST_CH-1:0][127:0]          avl_tx_hdr;
logic [FIM_PCIE_TLP_CH-1:0]             sop;
logic [FIM_PCIE_TLP_CH-1:0]             mrd;
t_tlp_mem_req_hdr [FIM_PCIE_TLP_CH-1:0] mem_req_hdr;
logic [FIM_PCIE_TLP_CH-1:0][6:0]        fmttype;

logic [9:0] tlp_hdr_len  [1:0];
logic [9:0] tlp_pyld_len [1:0];
logic [2:0] offset_eop   [1:0];

logic fifo_forward_pkt;
logic [FIFO_DEPTH_LOG2:0] forward_pkt_cnt;
logic forward_pkt_cnt_incr, forward_pkt_cnt_decr;

logic fifo_wrreq, fifo_rdack;
logic fifo_full, fifo_afull, fifo_empty;
logic fifo_rvalid;
t_avst_txs fifo_din, fifo_dout;

logic fifo_flush_wr, fifo_flush_rd;
logic fifo_flush_wr_done, fifo_flush_rd_done;
logic [FIFO_DEPTH_LOG2-1:0] fifo_flush_cnt;

// Process two packets at the same time since there are 2 AVST channel, we may be able to send 2 TLP on the same cycle
// Allow one MRD per cycle, checker needs 1 cycle to update cpl pending counter and activate tag
// 
//       CPL + MRd
//       MWR + MRD
//       CPL + MWr (TLP size <= 256, sop&eop)
//       CPL + CPL
//       MWR + MWR

// The bridge needs to make sure no idle cycle in a multi-cycle TLP, except when tx_ready is de-asserted
// (use max-payload-size supported by the platform as the reference on when to start sending the TLP stream)
// Optional : Support breaking up the payload into multiple TLP based on max-payload-size supported by the platform (negotiated with rootport)

// Store & Forward FIFO
fim_rdack_scfifo #(
   .DATA_WIDTH            (PCIE_TX_AVST_IF_WIDTH*NUM_AVST_CH),
   .DEPTH_LOG2            (FIFO_DEPTH_LOG2),
   .USE_EAB               ("ON"),
   .ALMOST_FULL_THRESHOLD (FIFO_AFULL_THRESHOLD)
) tx_avst_fifo (
   .clk     (avl_clk),
   .sclr    (~avl_rst_n),
   .wdata   (fifo_din),
   .wreq    (fifo_wrreq),
   .rdack   (fifo_rdack),
   .rdata   (fifo_dout),
   .wfull   (fifo_full), // not used
   .wusedw  (),
   .rusedw  (),
   .almfull (fifo_afull),
   .rempty  (fifo_empty), // not used
   .rvalid  (fifo_rvalid)
);

// Store & forward FIFO reset flush
always_ff @(posedge avl_clk) begin : FLUSH_FIFO
   if (~avl_rst_n) begin
      fifo_flush_wr           <= 1'b1;
      fifo_flush_rd           <= 1'b1;
      fifo_flush_wr_done      <= 1'b0;
      fifo_flush_rd_done      <= 1'b0;
      fifo_flush_cnt          <= '0;
   end
   else begin
      // Flush write
      if (fifo_flush_wr_done) begin
         fifo_flush_wr        <= 1'b0;
      end
      else if (&fifo_flush_cnt) begin
         fifo_flush_wr_done   <= 1'b1;
      end
      else begin
         fifo_flush_wr        <= 1'b1;
         fifo_flush_cnt       <= fifo_flush_cnt + 1'b1;
      end
      // Flush read
      if (fifo_flush_rd_done) begin
         fifo_flush_rd        <= 1'b0;
      end
      else if (&fifo_flush_cnt & fifo_empty) begin
         fifo_flush_rd_done   <= 1'b1;
      end
      else begin
         fifo_flush_rd        <= 1'b1;
      end
   end
end : FLUSH_FIFO

// Store & forward FIFO write side control
always_comb begin
   fifo_din = avl_tx_st_reg2;
   if (NUM_AVST_CH == 1) begin
      fifo_wrreq = avl_tx_st_reg2[CH0].valid | fifo_flush_wr;
   end
   else begin
      fifo_wrreq = avl_tx_st_reg2[CH0].valid | avl_tx_st_reg2[CH1].valid | fifo_flush_wr;
   end
end

// Store & forward FIFO read side control
always_comb begin
   avl_tx_st = fifo_dout;
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      avl_tx_st[ch].valid = avl_tx_ready_q[2] && fifo_rvalid && fifo_dout[ch].valid && fifo_forward_pkt;
   end
   fifo_rdack = avl_tx_ready_q[2] & fifo_forward_pkt | fifo_flush_rd;
end

// TLP-level store & forward combinatorial control
always_comb begin
   if (NUM_AVST_CH == 1) begin
      forward_pkt_cnt_incr = fifo_wrreq  && fifo_din[CH0].valid  && fifo_din[CH0].eop;
      forward_pkt_cnt_decr = fifo_rvalid && fifo_dout[CH0].valid && fifo_dout[CH0].eop && avl_tx_ready_q[2];
   end
   else begin
      forward_pkt_cnt_incr = fifo_wrreq  && ((fifo_din[CH0].valid  && fifo_din[CH0].eop)  || (fifo_din[CH1].valid  && fifo_din[CH1].eop));
      forward_pkt_cnt_decr = fifo_rvalid && ((fifo_dout[CH0].valid && fifo_dout[CH0].eop) || (fifo_dout[CH1].valid && fifo_dout[CH1].eop)) && avl_tx_ready_q[2];
   end
   fifo_forward_pkt = |forward_pkt_cnt;
end

// TLP-level store & forward synchronous control
always_ff @(posedge avl_clk) begin : STORE_AND_FORWARD_TLP
   if (~avl_rst_n) begin
      forward_pkt_cnt  <= '0;
   end
   else begin
      case ({forward_pkt_cnt_incr, forward_pkt_cnt_decr})
         2'b10: begin   // Increment counter
            forward_pkt_cnt <= forward_pkt_cnt + 1'b1;
         end
         2'b01: begin   // Decrement counter
            forward_pkt_cnt <= forward_pkt_cnt - 1'b1;
         end
         default: begin // No change
            forward_pkt_cnt <= forward_pkt_cnt;
         end
      endcase
   end
end : STORE_AND_FORWARD_TLP

// Register output of PACKET_MAP state machine to help ease timing closure to the store & forward FIFO
always_ff @(posedge avl_clk) begin
   avl_tx_st_reg2 <= avl_tx_st_reg;
end

// PCIe IP has a readylatency=3 from the clock edge when ready asserts/deasserts
// Application layer can only assert valid on the 3rd clock edge after ready is asserted
// Application layer can de-assert valid on the 3rd clock edge after ready is de-asserted
// Register the ready signal with two stages of pipeline to meet the readylatency requirement
always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      avl_tx_ready_q <= '0;
   end else begin
      avl_tx_ready_q <= {avl_tx_ready_q[1], avl_tx_ready_q[0], avl_tx_ready};
   end
end

t_axis_pcie_txs axis_pcie_txs_in;
logic axis_in_pipeln_ready;
t_axis_pcie_txs axis_pcie_txs;
logic axis_pcie_txs_ready;

always_comb begin
   axis_pcie_txs_in = axis_tx_st.tx;
   // The axis_tx_st.tready signal comes from multiple sources, not just the
   // target skid buffer. Set the valid flag passed to the skid buffer to match
   // the true ready state.
   axis_pcie_txs_in.tvalid = axis_tx_st.tx.tvalid && axis_tx_st.tready;
end

axis_reg_pcie_txs #(
   .NUM_PIPELINES (1),
   .MODE (0) // 0: skid buffer 1: simple buffer 2: bypass
) axis_in_pipeln (
   .s_if_clk    (avl_clk),
   .s_if_rst_n  (avl_rst_n),
   .s_if        (axis_pcie_txs_in),
   .s_if_tready (axis_in_pipeln_ready),
   .m_if        (axis_pcie_txs),
   .m_if_tready (axis_pcie_txs_ready)
);

// Incoming AXIS ready control
assign axis_tx_st.tready = axis_in_pipeln_ready &&
                           ~fifo_flush_wr && ~fifo_flush_rd;

// AXIS ready leaving ingress skid buffer
assign axis_pcie_txs_ready = ~fifo_afull && rx_cpl_buffer_ready &&
                             (tlp_map_ready || merge_axis_despite_map_not_ready);

// Parse header and calculate header length
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      sop[ch]           = axis_pcie_txs.tdata[ch].valid && axis_pcie_txs.tdata[ch].sop;
      mem_req_hdr[ch]   = axis_pcie_txs.tdata[ch].hdr;
      fmttype[ch]       = mem_req_hdr[ch].dw0.fmttype;
      mrd[ch]           = sop[ch] && (fmttype[ch] == PCIE_FMTTYPE_MEM_READ32 || fmttype[ch] == PCIE_FMTTYPE_MEM_READ64);
      case (fmttype[ch])
         PCIE_FMTTYPE_MEM_READ32, PCIE_FMTTYPE_MEM_WRITE32, PCIE_FMTTYPE_CPL, PCIE_FMTTYPE_CPLD:
         begin
            tlp_hdr_len[ch] = 10'h3;
         end
         PCIE_FMTTYPE_MEM_READ64, PCIE_FMTTYPE_MEM_WRITE64:
         begin
            tlp_hdr_len[ch] = 10'h4;
         end
         default:
         begin
            tlp_hdr_len[ch] = '0;
         end
      endcase
   end
end

// Parse TLP payload length
always_comb begin
   if (NUM_AVST_CH == 1) begin
      case (fmttype[0])
         PCIE_FMTTYPE_MEM_READ32, PCIE_FMTTYPE_MEM_READ64:
         begin
            tlp_pyld_len[0] = '0;
         end
         default:
         begin
            tlp_pyld_len[0] = mem_req_hdr[0].dw0.length;
         end
      endcase
   end
   else begin // 2 channels
      case (sop)
         2'b01:
         begin
            case (fmttype[0])
               PCIE_FMTTYPE_MEM_READ32, PCIE_FMTTYPE_MEM_READ64:
               begin
                  tlp_pyld_len[0] = '0;
                  tlp_pyld_len[1] = '0;
               end
               default:
               begin
                  tlp_pyld_len[0] = mem_req_hdr[0].dw0.length;
                  tlp_pyld_len[1] = mem_req_hdr[0].dw0.length;
               end
            endcase
         end
         2'b10:
         begin
            case (fmttype[1])
               PCIE_FMTTYPE_MEM_READ32, PCIE_FMTTYPE_MEM_READ64:
               begin
                  tlp_pyld_len[0] = '0;
                  tlp_pyld_len[1] = '0;
               end
               default:
               begin
                  tlp_pyld_len[0] = mem_req_hdr[1].dw0.length;
                  tlp_pyld_len[1] = mem_req_hdr[1].dw0.length;
               end
            endcase
         end
         2'b11:
         begin
            for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
               case (fmttype[ch])
                  PCIE_FMTTYPE_MEM_READ32, PCIE_FMTTYPE_MEM_READ64:
                  begin
                     tlp_pyld_len[ch] = '0;
                  end
                  default:
                  begin
                     tlp_pyld_len[ch] = mem_req_hdr[ch].dw0.length;
                  end
               endcase
            end
         end
         default: // 2'b00:
         begin
            for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
               tlp_pyld_len[ch] = '0;
            end
         end
      endcase
   end
end

// Expect only 1 MRd per cycle
always_ff @(posedge avl_clk) begin
   tx_mrd_valid <= 1'b0;

   if (axis_pcie_txs.tvalid && axis_pcie_txs_ready) begin
      if (mrd[CH0]) begin
         // Register MRd to checker
         tx_mrd_valid      <= 1'b1;
         tx_mrd_length     <= {~(|mem_req_hdr[CH0].dw0.length), mem_req_hdr[CH0].dw0.length};
         tx_mrd_tag        <= mem_req_hdr[CH0].tag[PCIE_EP_TAG_WIDTH-1:0];
         tx_mrd_pfn        <= mem_req_hdr[CH0].requester_id[0+:PF_WIDTH];
         tx_mrd_vfn        <= mem_req_hdr[CH0].requester_id[3+:VF_WIDTH];
         tx_mrd_vf_act     <= axis_pcie_txs.tuser[CH0].vf_active;
      end else begin
         if (NUM_AVST_CH > 1) begin
            if (mrd[CH1]) begin
               // Register MRd to checker
               tx_mrd_valid      <= 1'b1;
               tx_mrd_length     <= {~(|mem_req_hdr[CH1].dw0.length), mem_req_hdr[CH1].dw0.length};
               tx_mrd_tag        <= mem_req_hdr[CH1].tag[PCIE_EP_TAG_WIDTH-1:0];
               tx_mrd_pfn        <= mem_req_hdr[CH1].requester_id[0+:PF_WIDTH];
               tx_mrd_vfn        <= mem_req_hdr[CH1].requester_id[3+:VF_WIDTH];
               tx_mrd_vf_act     <= axis_pcie_txs.tuser[CH1].vf_active;
            end
         end
      end
   end

   if (~avl_rst_n) begin
      tx_mrd_valid <= 1'b0;
   end
end

// track cpl_pending_data_cnt and stop sending MRd request if RX buffer credit is low
localparam logic [CPL_CREDIT_WIDTH-1:0] RX_BUFFER_LIMIT = CPL_CREDIT_DWORD; // 1DW units
logic [CPL_CREDIT_WIDTH-1:0] rx_buffer_credits;
logic [CPL_CREDIT_WIDTH-1:0] last_mrd_length;
logic [1:0] enough_credits_with_txmrd, enough_credits_without_txmrd;

always_comb begin
   rx_buffer_credits = RX_BUFFER_LIMIT - cpl_pending_data_cnt;

   mrd_length[CH0][PCIE_MAX_LEN_WIDTH-1:0]                    = {~(|mem_req_hdr[CH0].dw0.length), mem_req_hdr[CH0].dw0.length};
   mrd_length[CH0][CPL_CREDIT_WIDTH-1:PCIE_MAX_LEN_WIDTH]     = '0;
   if (NUM_AVST_CH > 1) begin
      mrd_length[CH1][PCIE_MAX_LEN_WIDTH-1:0]                 = {~(|mem_req_hdr[CH1].dw0.length), mem_req_hdr[CH1].dw0.length};
      mrd_length[CH1][CPL_CREDIT_WIDTH-1:PCIE_MAX_LEN_WIDTH]  = '0;
   end

   enough_credits_with_txmrd[CH0]         = ((mrd_length[CH0]     > rx_buffer_credits) ||
                                             (tx_mrd_length       > rx_buffer_credits) ||
                                             (last_mrd_length    >= rx_buffer_credits) ||
                                             (mrd_length[CH0]     > rx_buffer_credits - tx_mrd_length - last_mrd_length)) ? 1'b1 : 1'b0;
   enough_credits_without_txmrd[CH0]      = ((mrd_length[CH0]     > rx_buffer_credits) ||
                                             (last_mrd_length    >= rx_buffer_credits) ||
                                             (mrd_length[CH0]     > rx_buffer_credits - last_mrd_length)) ? 1'b1 : 1'b0;
   if (NUM_AVST_CH > 1) begin
      enough_credits_with_txmrd[CH1]      = ((mrd_length[CH1]     > rx_buffer_credits) ||
                                             (tx_mrd_length       > rx_buffer_credits) ||
                                             (last_mrd_length    >= rx_buffer_credits) ||
                                             (mrd_length[CH1]     > rx_buffer_credits - tx_mrd_length - last_mrd_length)) ? 1'b1 : 1'b0;
      enough_credits_without_txmrd[CH1]   = ((mrd_length[CH1]     > rx_buffer_credits) ||
                                             (last_mrd_length    >= rx_buffer_credits) ||
                                             (mrd_length[CH1]     > rx_buffer_credits - last_mrd_length)) ? 1'b1 : 1'b0;
   end
end

always_ff @(posedge avl_clk) begin
   // Capture the length of the last MRd that left 1 cycle ago for back-to-back MRd requests
   if (tx_mrd_valid) begin
      last_mrd_length[PCIE_MAX_LEN_WIDTH-1:0] <= tx_mrd_length;
   end
   else begin
      last_mrd_length <= '0;
   end

   // Drive rx_cpl_buffer_ready high by default
   rx_cpl_buffer_ready              <= 1'b1;

   // We are at most 2 cycles behind the latest copy of rx_buffer_credits when we send MRd requests back-to-back
   // It takes 1 cycle to generate tx_mrd_valid after rx_cpl_buffer_ready is asserted
   // It takes 1 cycle to update rx_buffer_credits after tx_mrd_valid is asserted
   if (axis_pcie_txs.tvalid && axis_pcie_txs_ready) begin // Normal operation mid-stream
      if (mrd[CH0]) begin // MRd on channel-0
         if (tx_mrd_valid) begin // MRd in flight during this cycle so rx_buffer_credits will decrement next cycle
            if (enough_credits_with_txmrd[CH0]) begin
               rx_cpl_buffer_ready  <= 1'b0;
            end
         end
         else begin // No MRd in flight during this cycle but use last_mrd_length in case MRd was sent 1 cycle ago
            if (enough_credits_without_txmrd[CH0]) begin
               rx_cpl_buffer_ready  <= 1'b0;
            end
         end
      end
      else if ((NUM_AVST_CH > 1) && mrd[CH1]) begin // MRd on channel-1
         if (tx_mrd_valid) begin // MRd in flight during this cycle so rx_buffer_credits will decrement next cycle
            if (enough_credits_with_txmrd[CH1]) begin
               rx_cpl_buffer_ready  <= 1'b0;
            end
         end
         else begin // No MRd in flight during this cycle but use last_mrd_length in case MRd was sent 1 cycle ago
            if (enough_credits_without_txmrd[CH1]) begin
               rx_cpl_buffer_ready  <= 1'b0;
            end
         end
      end
   end
   else if (tx_mrd_valid) begin // MRd in flight during this cycle but RX buffer credits ran out
      if (mrd[CH0]) begin // MRd on channel-0
         if (enough_credits_with_txmrd[CH0]) begin
            rx_cpl_buffer_ready     <= 1'b0;
         end
      end
      else if ((NUM_AVST_CH > 1) && mrd[CH1]) begin // MRd on channel-1
         if (enough_credits_with_txmrd[CH1]) begin
            rx_cpl_buffer_ready     <= 1'b0;
         end
      end
   end
   else if (axis_pcie_txs.tvalid) begin // Check if next TLP is a MRd after running out of RX buffer credits
      if (mrd[CH0]) begin // MRd on channel-0
         if (enough_credits_without_txmrd[CH0]) begin
            rx_cpl_buffer_ready     <= 1'b0;
         end
         else begin // Capture MRd length that we allowed to pass
            last_mrd_length         <= mrd_length[CH0];
         end
      end
      else if ((NUM_AVST_CH > 1) && mrd[CH1]) begin // MRd on channel-1
         if (enough_credits_without_txmrd[CH1]) begin
            rx_cpl_buffer_ready     <= 1'b0;
         end
         else begin // Capture MRd length that we allowed to pass
            last_mrd_length         <= mrd_length[CH1];
         end
      end
   end

   if (~avl_rst_n) begin
      rx_cpl_buffer_ready           <= 1'b1;
   end
end

// Expression that calculates whether a TLP header and payload fit onto AVST data bus
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      packet_fit_comb[ch] = (tlp_hdr_len[ch] + tlp_pyld_len[ch] < AVST_WIDTH_DW) ? 1'b1
                          : (tlp_pyld_len[ch] % AVST_WIDTH_DW == 0) || (tlp_pyld_len[ch] % AVST_WIDTH_DW > AVST_WIDTH_DW - tlp_hdr_len[ch]) ? 1'b0
                          : 1'b1;
   end
end

// When tlp_map_ready is false, the generated AVST packet typically comes only
// from buffered state remaining from previous AXI-S state. In some cases,
// the next incoming AXI-S payload can be merged into the buffered state while
// still not overflowing a single AVST payload. Often this is a MRd that gets
// tucked in at the end of a MWr. The resulting AVST signficantly improves
// throughput when the stream is interleaved reads and writes. (When the writes
// don't fit in their original containers.)
e_channel merge_axis_ch;
always_comb begin
   if (NUM_AVST_CH == 1) begin
      // Not relevant with a single outbound channel
      merge_axis_despite_map_not_ready = 1'b0;
   end
   else begin
      merge_axis_despite_map_not_ready =
         // Slot available at the end of AVST generated from buffer
         (packet_state_next[CH1] == NUL) &&
         // New AXI-S state consumes only one slot
         ((packet_state[CH0] == SOP_EOP_FIT) && (packet_state[CH1] == NUL) ||
          (packet_state[CH0] == NUL) && (packet_state[CH1] == SOP_EOP_FIT)) &&
         // Not in final stage of alignment to channel-0 for TLP that started on channel-1
         (tlp_map_ready || ~sop_on_ch1);
   end

   // Which channel has the payload?
   merge_axis_ch = (packet_state[CH0] != NUL) ? CH0 : CH1;
end

/*
Channel packet states:
   (1) SOP
   (2) SOP,EOP(fit)
   (3) SOP,EOP(nofit)
   (4) EOP(fit)
   (5) EOP(nofit)
   (6) NUL
   (7) --(continuing packet)
*/
always_ff @(posedge avl_clk) begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (axis_pcie_txs.tvalid && axis_pcie_txs_ready) begin
         if (axis_pcie_txs.tdata[ch].valid) begin
            case ({axis_pcie_txs.tdata[ch].sop, axis_pcie_txs.tdata[ch].eop})
               2'b10:   // (1) SOP
               begin
                  // Capture fit/nofit condition based on TLP header length, TLP length and AVST bus width
                  // Find what input channel packet ends on for large TLPs
                  if (NUM_AVST_CH == 1) begin
                     packet_fit_q[ch] <= packet_fit_comb[ch];
                  end
                  else begin // 2 channels
                     if (ch == CH0) begin
                        if ((tlp_pyld_len[ch] % (2*AVST_WIDTH_DW) == 0) || (tlp_pyld_len[ch] % (2*AVST_WIDTH_DW) > AVST_WIDTH_DW)) begin // TLP will end on CH1
                           packet_fit_q[CH1] <= packet_fit_comb[ch];
                        end
                        else begin // TLP will end on CH0
                           packet_fit_q[CH0] <= packet_fit_comb[ch];
                        end
                     end
                     else begin // CH1
                        if ((tlp_pyld_len[ch] % (2*AVST_WIDTH_DW) == 0) || (tlp_pyld_len[ch] % (2*AVST_WIDTH_DW) > AVST_WIDTH_DW)) begin // TLP will end on CH1
                           packet_fit_q[CH0] <= packet_fit_comb[ch];
                        end
                        else begin // TLP will end on CH1
                           packet_fit_q[CH1] <= packet_fit_comb[ch];
                        end
                     end
                  end
               end
            endcase
         end
      end
   end
   if(~avl_rst_n) begin
      for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
         packet_fit_q[ch] <= '0;
      end
   end
end

always_comb begin : PACKET_STATES
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (axis_pcie_txs.tvalid) begin
         if (axis_pcie_txs.tdata[ch].valid) begin
            case ({axis_pcie_txs.tdata[ch].sop, axis_pcie_txs.tdata[ch].eop})
               2'b10:   // (1) SOP
               begin
                  packet_state[ch]  = SOP;
                  offset_eop[ch]    = (tlp_hdr_len[ch] + tlp_pyld_len[ch]) % AVST_WIDTH_DW;
               end
               2'b11:   // (2) SOP,EOP(fit) & (3) SOP,EOP(nofit)
               begin
                  // Capture fit/nofit condition based on TLP header length, TLP length and AVST bus width
                  packet_state[ch]  = packet_fit_comb[ch] ? SOP_EOP_FIT : SOP_EOP_NOFIT;
                  offset_eop[ch]    = (tlp_hdr_len[ch] + tlp_pyld_len[ch]) % AVST_WIDTH_DW;
               end
               2'b01:   // (4) EOP(fit) & (5) EOP(nofit)
               begin
                  if (NUM_AVST_CH == 1) begin
                     packet_state[ch]  = packet_fit_q[ch] ? EOP_FIT : EOP_NOFIT;
                  end
                  else begin
                     if ((ch == CH1) && (axis_pcie_txs.tdata[CH0].sop)) begin
                        packet_state[ch]  = packet_fit_comb[CH0] ? EOP_FIT : EOP_NOFIT;
                     end
                     else if (axis_pcie_txs.tdata[ch].sop) begin
                        packet_state[ch]  = packet_fit_comb[ch] ? EOP_FIT : EOP_NOFIT;
                     end
                     else begin
                        packet_state[ch]  = packet_fit_q[ch] ? EOP_FIT : EOP_NOFIT;
                     end
                  end
                  offset_eop[ch] = '0;
               end
               default: // (7) --(continuing packet)
               begin
                  packet_state[ch]  = CTND;
                  offset_eop[ch] = '0;
               end
            endcase
         end
         else begin     // (6) NUL
            packet_state[ch]        = NUL;
            offset_eop[ch]          = '0;
         end
      end
      else begin        // (6) NUL - expecting no gaps in transmission
         packet_state[ch]           = NUL;
         offset_eop[ch]             = '0;
      end
   end
end : PACKET_STATES

// Get offset based on TLP header length
always_comb begin : GET_OFFSET
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (axis_pcie_txs.tvalid && axis_pcie_txs.tdata[ch].valid && axis_pcie_txs.tdata[ch].sop) begin
         case (fmttype[ch])
            PCIE_FMTTYPE_MEM_READ32,
            PCIE_FMTTYPE_MEM_WRITE32,
            PCIE_FMTTYPE_CPL,
            PCIE_FMTTYPE_CPLD:
            begin
               offset[ch]  = OFFSET_3DW;
            end
            PCIE_FMTTYPE_MEM_READ64,
            PCIE_FMTTYPE_MEM_WRITE64:
            begin
               offset[ch]  = OFFSET_4DW;
            end
            default:
            begin
               offset[ch]  = OFFSET_ERR;
            end
         endcase
      end
      else begin
         offset[ch]        = OFFSET_ERR;
      end
   end
end : GET_OFFSET

// Map AXIS 128-bit header and 256-bit payload onto 256-bit AVST data bus on SOP
// Continue to mapp remainder of AXIS payload onto AVST data bus depending on what is coming in on AXIS interface
always_ff @(posedge avl_clk) begin : PACKET_MAP
   // Single-channel scenarios
   if (NUM_AVST_CH == 1) begin
      `ifdef SIM_MODE     
         avl_tx_st_reg[CH0]       <= '0;
      `else
         avl_tx_st_reg[CH0].valid <= '0;
      `endif
      avl_tx_hdr[CH0] = func_to_little_endian_hdr(axis_pcie_txs.tdata[CH0].hdr);
      clear_sop_eop_valid(CH0);
      if (axis_pcie_txs.tvalid && axis_pcie_txs_ready) begin
         case (packet_state[CH0])
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0         TREADY      MAP
            // (1)  SOP,EOP(fit)    1           data[0] <= {pyld[0], hdr[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            SOP_EOP_FIT:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b1, axis_pcie_txs.tuser[CH0].vf_active);
               set_sop_eop(CH0);
               tlp_map_ready <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0         TREADY      MAP
            // (2) SOP,EOP(nofit)   0           data[0] <= {pyld[0], hdr[0]};  buff[0] <= pyld[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            SOP_EOP_NOFIT:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH0].payload, offset[CH0], offset_eop[CH0], axis_pcie_txs.tuser[CH0].vf_active);
               set_sop(CH0);
               tlp_map_ready <= 1'b0;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0         TREADY      MAP
            // (3)  SOP             1           data[0] <= {pyld[0], hdr[0]};  buff[0] <= pyld[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            SOP:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH0].payload, offset[CH0], offset_eop[CH0], axis_pcie_txs.tuser[CH0].vf_active);
               set_sop(CH0);
               tlp_map_ready <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0         TREADY      MAP
            // (4)      EOP(fit)    1           data[0] <= {pyld[0], buff[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            EOP_FIT:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b1, tx_buffer[CH0].vf_active);
               clear_buf(CH0);
               set_eop(CH0);
               tlp_map_ready <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0         TREADY      MAP
            // (5)      EOP(nofit)  0           data[0] <= {pyld[0], buff[0]};  buff[0] <= pyld[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            EOP_NOFIT:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               set_valid_clear_sop_eop(CH0);
               tlp_map_ready <= 1'b0;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0         TREADY      MAP
            // (6)      --          1           data[0] <= {pyld[0], buff[0]};  buff[0] <= pyld[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            CTND:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               set_valid_clear_sop_eop(CH0);
               tlp_map_ready <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0         TREADY      MAP
            // (7)      NUL         1           data[0] <= '0;
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            default:       // (7) NUL
            begin
               clear_sop_eop_valid(CH0);
               tlp_map_ready <= 1'b1;
            end
         endcase
      end
      else if (~fifo_afull && ~tlp_map_ready) begin // finish mapping buffered AXIS payload onto AVST data bus
         map_two_sources(CH0, '0, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b1, tx_buffer[CH0].vf_active);
         clear_buf(CH0);
         set_eop(CH0);
         tlp_map_ready <= 1'b1;
      end
   end
   else begin
      for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      `ifdef SIM_MODE
         avl_tx_st_reg[ch]       <= '0;
      `else
         avl_tx_st_reg[ch].valid <= 1'b0;
      `endif
         avl_tx_hdr[ch] = func_to_little_endian_hdr(axis_pcie_txs.tdata[ch].hdr);
      end
      if (axis_pcie_txs.tvalid && axis_pcie_txs_ready && tlp_map_ready && ~sop_on_ch1) begin
         for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
            clear_sop_eop_valid(ch);
         end
         tlp_map_ready <= 1'b1;
         generate_sop  <= 1'b0;
         sop_on_ch1    <= 1'b0;
         case ({packet_state[CH0], packet_state[CH1]})
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (1)  SOP,EOP(fit)    SOP,EOP(fit)     1           data[0] <= {pyld[0], hdr[0]};  data[1] <= {pyld[1], hdr[1]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_FIT, SOP_EOP_FIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b1, axis_pcie_txs.tuser[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], 1'b1, axis_pcie_txs.tuser[CH1].vf_active);
               set_sop_eop(CH0);
               set_sop_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (2)  SOP,EOP(fit)    NUL              1           data[0] <= {pyld[0], hdr[0]};  data[1] <= '0;
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_FIT, NUL}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b1, axis_pcie_txs.tuser[CH0].vf_active);
               set_sop_eop(CH0);
               clear_sop_eop_valid(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (3)  SOP,EOP(nofit)  NUL              1           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_NOFIT, NUL}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH0].payload, offset[CH0], offset_eop[CH0], axis_pcie_txs.tuser[CH0].vf_active);
               set_sop(CH0);
               set_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (4)      NUL         SOP,EOP(fit)     1           data[0] <= {pyld[1], hdr[1]};  data[1] <= '0;
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {NUL, SOP_EOP_FIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], 1'b1, axis_pcie_txs.tuser[CH1].vf_active);
               set_sop_eop(CH0);
               clear_sop_eop_valid(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (5)      NUL         SOP,EOP(nofit)   1           data[0] <= {pyld[1], hdr[1]};  data[1] <=  pyld[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {NUL, SOP_EOP_NOFIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], 1'b0, axis_pcie_txs.tuser[CH1].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_sop(CH0);
               set_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (6)      EOP(fit)    SOP,EOP(fit)     1           data[0] <= {pyld[0], buff[0]}; data[1] <= {pyld[1], hdr[1]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, SOP_EOP_FIT}:
            begin
               for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
               end
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b1, tx_buffer[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], 1'b1, axis_pcie_txs.tuser[CH1].vf_active);
               clear_buf(CH0);
               set_eop(CH0);
               set_sop_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (7)      SOP         EOP(fit)         1           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP, EOP_FIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, offset[CH0], offset_eop[CH0], 1'b1, axis_pcie_txs.tuser[CH0].vf_active);
               set_sop(CH0);
               set_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (8)      NUL         SOP              1           data[0] <= '0;                 data[1] <= '0;                 buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //   ->     SOP         ???              1           data[0] <=  buff[0];           data[1] <= {???, buff[1]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {NUL, SOP}:
            begin
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               clear_sop_eop_valid(CH0);
               clear_sop_eop_valid(CH1);
               sop_on_ch1    <= 1'b1;
               generate_sop  <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (9)      EOP(fit)    NUL              1           data[0] <= {pyld[0], buff[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, NUL}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b1, tx_buffer[CH0].vf_active);
               clear_buf(CH0);
               set_eop(CH0);
               clear_sop_eop_valid(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (10)     EOP(nofit)  NUL              1           data[0] <= {pyld[0], buff[0]}; data[1] <=  pyld[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_NOFIT, NUL}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               clear_buf(CH0);
               set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (11)     --          EOP(fit)         1           data[0] <= {pyld[0], buff[0]}; data[1] <= {pyld[1], pyld[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {CTND, EOP_FIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b1, tx_buffer[CH0].vf_active);
               clear_buf(CH0);
               set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (12) SOP,EOP(fit)    SOP,EOP(nofit)   0           data[0] <= {pyld[0], hdr[0]};  data[1] <= '0;                 buff[0] <= {pyld[0], hdr[0]}; buff[1] <=  pyld[1];
            //   ->     SOP         EOP(fit)         1           data[0] <=  buff[0];           data[1] <=  buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_FIT, SOP_EOP_NOFIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b1, axis_pcie_txs.tuser[CH0].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_sop_eop(CH0);
               clear_sop_eop_valid(CH1);
               tlp_map_ready <= 1'b0;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {SOP, EOP_FIT};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (13) SOP,EOP(nofit)  SOP,EOP(fit)     0           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]};
            //   -> SOP,EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_NOFIT, SOP_EOP_FIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH0].payload, offset[CH0], offset_eop[CH0], axis_pcie_txs.tuser[CH0].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_sop(CH0);
               set_eop(CH1);
               tlp_map_ready <= 1'b0;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {SOP_EOP_FIT, NUL};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (14) SOP,EOP(nofit)  SOP,EOP(nofit)   0           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //   ->     SOP         EOP(fit)         1           data[0] <=  buff[0];           data[1] <=  buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_NOFIT, SOP_EOP_NOFIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH0].payload, offset[CH0], offset_eop[CH0], axis_pcie_txs.tuser[CH0].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_sop(CH0);
               set_eop(CH1);
               tlp_map_ready <= 1'b0;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {SOP, EOP_FIT};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (15) SOP,EOP(nofit)  SOP              1           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //   ->     SOP         ???              1           data[0] <=  buff[0];           data[1] <= {???, buff[1]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_NOFIT, SOP}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH0].payload, offset[CH0], offset_eop[CH0], axis_pcie_txs.tuser[CH0].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_sop(CH0);
               set_eop(CH1);
               sop_on_ch1    <= 1'b1;
               generate_sop  <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (16)     EOP(nofit)  SOP              1           data[0] <= {pyld[0], buff[0]}; data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //   ->     SOP         ???              1           data[0] <=  buff[0];           data[1] <= {???, buff[1]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_NOFIT, SOP}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
               sop_on_ch1    <= 1'b1;
               generate_sop  <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (17)     EOP(nofit)  SOP,EOP(fit)     0           data[0] <= {pyld[0], buff[0]}; data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]};
            //   -> SOP,EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_NOFIT, SOP_EOP_FIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
               tlp_map_ready <= 1'b0;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {SOP_EOP_FIT, NUL};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (18)     EOP(fit)    SOP,EOP(nofit)   0           data[0] <= {pyld[0], buff[0]}; data[1] <= '0;                 buff[0] <= {pyld[0], hdr[0]}; buff[1] <=  pyld[1];
            //   ->     SOP         EOP(fit)         1           data[0] <=  buff[0];           data[1] <=  buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, SOP_EOP_NOFIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b1, tx_buffer[CH0].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_eop(CH0);
               clear_sop_eop_valid(CH1);
               tlp_map_ready <= 1'b0;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {SOP, EOP_FIT};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (19)     EOP(nofit)  SOP,EOP(nofit)   0           data[0] <= {pyld[0], buff[0]}; data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //   ->     SOP         EOP(fit)         1           data[0] <=  buff[0];           data[1] <=  buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_NOFIT, SOP_EOP_NOFIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               map_one_source_msb(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
               tlp_map_ready <= 1'b0;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {SOP, EOP_FIT};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (20)     SOP         EOP(nofit)       0           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[1];           buff[0] <=  pyld[1];
            //   ->     EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP, EOP_NOFIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH1].payload, offset[CH0], offset_eop[CH0], axis_pcie_txs.tuser[CH0].vf_active);
               set_sop(CH0);
               set_valid_clear_sop_eop(CH1);
               tlp_map_ready <= 1'b0;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {EOP_FIT, NUL};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (21)     --          EOP(nofit)       0           data[0] <= {pyld[0], buff[0]}; data[1] <= {pyld[1], pyld[0]}; buff[0] <=  pyld[1];
            //   ->     EOP(fit)    NULL             1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {CTND, EOP_NOFIT}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH1].payload, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
               tlp_map_ready <= 1'b0;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {EOP_FIT, NUL};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (22) SOP,EOP(fit)    SOP              1           data[0] <= {pyld[0], hdr[0]};  data[1] <= {pyld[1], hdr[1]};  buff[0] <= pyld[1];
            //   -> --(append more) ???              1           data[0] <= {???, buff[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_FIT, SOP}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b1, axis_pcie_txs.tuser[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], 1'b0, axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_sop_eop(CH0);
               set_sop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (23)     SOP         --               1           data[0] <= {pyld[0], hdr[0]};  data[1] <= {pyld[1], pyld[0]}; buff[0] <=  pyld[1]; continue appending buffer...
            //   -> --(append more) ???              1           data[0] <= {???, buff[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP, CTND}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, {'0, avl_tx_hdr[CH0]}, 1'b1, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, offset[CH0], offset_eop[CH0], 1'b0, axis_pcie_txs.tuser[CH0].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH1].payload, offset[CH0], offset_eop[CH0], axis_pcie_txs.tuser[CH0].vf_active);
               set_sop(CH0);
               set_valid_clear_sop_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (24)     EOP(fit)    SOP              1           data[0] <= {pyld[0], buff[0]};  data[1] <= {pyld[1], hdr[1]};  buff[0] <= pyld[1];
            //   -> --(append more) ???              1           data[0] <= {???, buff[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, SOP}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b1, tx_buffer[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], 1'b0, axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               set_eop(CH0);
               set_sop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (25)     --          --               1           data[0] <= {pyld[0], buff[0]}; data[1] <= {pyld[1], pyld[0]}; buff[0] <=  pyld[1];
            //   -> --(append more) ???              1           data[0] <= {???, buff[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {CTND, CTND}:
            begin
               map_two_sources(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH0].data, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, 1'b0, tx_buffer[CH0].vf_active);               
               buf_one_source(CH0, axis_pcie_txs.tdata[CH1].payload, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (26)     NUL             NUL          1           data[0] <= '0;                 data[1] <= '0;
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            default:
            begin
               // do nothing
            end
         endcase
      end
      else if (~fifo_afull && ~tlp_map_ready && ~sop_on_ch1) begin // Finish mapping buffered AXIS payload onto AVST data bus
         for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
            clear_sop_eop_valid(ch);
         end
         tlp_map_ready <= 1'b1;
         sop_on_ch1    <= 1'b0;
         case ({packet_state_next[CH0], packet_state_next[CH1]})
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (18)     EOP(fit)    SOP,EOP(nofit)   0           data[0] <= {pyld[0], buff[0]}; data[1] <= {pyld[1], hdr[1]};  buff[0] <=  pyld[1];
            // (20)     SOP         EOP(nofit)       0           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[1];           buff[0] <=  pyld[1];
            // (21)     --          EOP(nofit)       0           data[0] <= {pyld[0], buff[0]}; data[1] <= {pyld[1], pyld[0]}; buff[0] <=  pyld[1];
            //->(27)    EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, NUL}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               clear_buf(CH0);
               set_eop(CH0);
               // The incoming AXI-S might be data ready despite tlp_map_ready being false.
               // See merge_axis_despite_map_not_ready above.
               if (~axis_pcie_txs_ready) begin
                  clear_sop_eop_valid(CH1);
               end
               else begin
                  map_two_sources(CH1, axis_pcie_txs.tdata[merge_axis_ch].payload, {'0, avl_tx_hdr[merge_axis_ch]}, 1'b1, offset[merge_axis_ch], offset_eop[merge_axis_ch], 1'b1, axis_pcie_txs.tuser[merge_axis_ch].vf_active);
                  set_sop_eop(CH1);
               end
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (13) SOP,EOP(nofit)  SOP,EOP(fit)     0           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]};
            // (17)     EOP(nofit)  SOP,EOP(fit)     0           data[0] <= {pyld[0], buff[0]}; data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]};
            //->(28)SOP,EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_FIT, NUL}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               clear_buf(CH0);
               set_sop_eop(CH0);
               // The incoming AXI-S might be data ready despite tlp_map_ready being false.
               // See merge_axis_despite_map_not_ready above.
               if (~axis_pcie_txs_ready) begin
                  clear_sop_eop_valid(CH1);
               end
               else begin
                  map_two_sources(CH1, axis_pcie_txs.tdata[merge_axis_ch].payload, {'0, avl_tx_hdr[merge_axis_ch]}, 1'b1, offset[merge_axis_ch], offset_eop[merge_axis_ch], 1'b1, axis_pcie_txs.tuser[merge_axis_ch].vf_active);
                  set_sop_eop(CH1);
               end
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (12) SOP,EOP(fit)    SOP,EOP(nofit)   0           data[0] <= {pyld[0], hdr[0]};  data[1] <= '0;                 buff[0] <= {pyld[0], hdr[0]}; buff[1] <=  pyld[1];
            // (14) SOP,EOP(nofit)  SOP,EOP(nofit)   0           data[0] <= {pyld[0], hdr[0]};  data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            // (19)     EOP(nofit)  SOP,EOP(nofit)   0           data[0] <= {pyld[0], buff[0]}; data[1] <=  pyld[0];           buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //->(29)    SOP         EOP(fit)         1           data[0] <=  buff[0];           data[1] <=  buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP, EOP_FIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_one_source_msb(CH1, tx_buffer[CH1].data, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               clear_buf(CH0);
               clear_buf(CH1);
               set_sop(CH0);
               set_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //->(30)
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            default:
            begin
               // do nothing
            end
         endcase
      end
      else if (axis_pcie_txs.tvalid && axis_pcie_txs_ready && sop_on_ch1) begin // Align SOP to channel-0
         for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
            clear_sop_eop_valid(ch);
         end
         tlp_map_ready <= 1'b0;
         sop_on_ch1    <= 1'b1;
         generate_sop  <= 1'b0;
         case ({packet_state[CH0], packet_state[CH1]})
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (31)     EOP(fit)    NUL              1           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= '0;                buff[1] <= '0;
            //   ->     SOP/--      EOP(fit)
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, NUL}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b1, tx_buffer[CH1].vf_active);
               clear_buf(CH0);
               clear_buf(CH1);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
               tlp_map_ready <= 1'b1;
               sop_on_ch1    <= 1'b0;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (32)     EOP(nofit)  NUL              0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <=  pyld[0];          buff[1] <= '0;
            //   ->     SOP/--      --
            //   ->     EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_NOFIT, NUL}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b0, tx_buffer[CH1].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               clear_buf(CH1);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
               {packet_state_next[CH0], packet_state_next[CH1]} <= {EOP_FIT, NUL};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (33)     EOP(fit)    SOP,EOP(fit)     0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], hdr[1]}; buff[1] <= '0;
            //   ->     SOP/--      EOP(fit)
            //   -> SOP,EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, SOP_EOP_FIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b1, tx_buffer[CH1].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               clear_buf(CH1);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
               {packet_state_next[CH0], packet_state_next[CH1]} <= {SOP_EOP_FIT, NUL};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (34)     EOP(nofit)  SOP,EOP(fit)     0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <=  pyld[0];          buff[1] <= {pyld[1], hdr[1]};
            //   ->     SOP/--      --
            //   ->     EOP(fit)    SOP,EOP(fit)     1           data[0] <=  buff[0];           data[1] <= buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_NOFIT, SOP_EOP_FIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b0, tx_buffer[CH1].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               buf_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
               {packet_state_next[CH0], packet_state_next[CH1]} <= {EOP_FIT, SOP_EOP_FIT};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (35)     EOP(fit)    SOP,EOP(nofit)   0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //   ->     SOP/--      EOP(fit)
            //   ->     SOP         EOP(fit)         1           data[0] <=  buff[0];           data[1] <= buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, SOP_EOP_NOFIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b1, tx_buffer[CH1].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
               {packet_state_next[CH0], packet_state_next[CH1]} <= {SOP, EOP_FIT};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (36)     EOP(nofit)  SOP,EOP(nofit)   0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <=  pyld[0];          buff[1] <= {pyld[1], hdr[1]}; buff[2] <= pyld[1];
            //   ->     SOP/--      --
            //   ->     EOP(fit)    SOP              0           data[0] <=  buff[0];           data[1] <= buff[1];            buff[0] <=  buff[2];          buff[1] <= '0;
            //   ->     EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_NOFIT, SOP_EOP_NOFIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b0, tx_buffer[CH1].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               buf_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH2, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active); // use extra buffer for this corner case
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
               {packet_state_next[CH0], packet_state_next[CH1]} <= {EOP_FIT, SOP};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (37)     --          --               1           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], pyld[0]};buff[1] <=  pyld[1];
            //   ->     SOP/--      --
            //   ->     --          ???              1           data[0] <=  buff[0];           data[1] <= {???, buff[1]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {CTND, CTND}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b0, tx_buffer[CH1].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
               tlp_map_ready <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (38)     --          EOP(fit)         0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], pyld[0]};buff[1] <= '0;
            //   ->     SOP/--      --
            //   ->     EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {CTND, EOP_FIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b0, tx_buffer[CH1].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               clear_buf(CH1);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
               {packet_state_next[CH0], packet_state_next[CH1]} <= {EOP_FIT, NUL};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (39)     --          EOP(nofit)       0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], pyld[0]};buff[1] <=  pyld[1];
            //   ->     SOP/--      --
            //   ->     --          EOP(fit)         1           data[0] <=  buff[0];           data[1] <=  buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {CTND, EOP_NOFIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b0, tx_buffer[CH1].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, axis_pcie_txs.tdata[CH0].payload, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
               {packet_state_next[CH0], packet_state_next[CH1]} <= {CTND, EOP_FIT};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (40)     EOP(fit)    SOP              1           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //   ->     SOP/--      EOP(fit)         1
            //   ->     SOP         ???              1           data[0] <=  buff[0];           data[1] <= {???, buff[1]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, SOP}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b1, tx_buffer[CH1].vf_active);
               buf_two_sources(CH0, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH1, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
               tlp_map_ready <= 1'b1;
               generate_sop  <= 1'b1;
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (41)     EOP(nofit)  SOP              0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <=  pyld[0];          buff[1] <= {pyld[1], hdr[1]}; buff[2] <= pyld[1];
            //   ->     SOP/--      --
            //   ->     EOP(fit)    SOP              1           data[0] <=  buff[0];           data[1] <=  buff[1];           buff[0] <=  buff[2];
            //   -> --(append more) ???              1           data[0] <= {???, buff[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_NOFIT, SOP}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_two_sources(CH1, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].data, 1'b0, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, 1'b0, tx_buffer[CH1].vf_active);
               buf_one_source(CH0, axis_pcie_txs.tdata[CH0].payload, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               buf_two_sources(CH1, axis_pcie_txs.tdata[CH1].payload, {'0, avl_tx_hdr[CH1]}, 1'b1, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active);
               buf_one_source(CH2, axis_pcie_txs.tdata[CH1].payload, offset[CH1], offset_eop[CH1], axis_pcie_txs.tuser[CH1].vf_active); // use extra buffer for this corner case
               if (generate_sop)
                  set_sop(CH0);
               else
                  set_valid_clear_sop_eop(CH0);
               set_valid_clear_sop_eop(CH1);
               generate_sop  <= 1'b1;
               {packet_state_next[CH0], packet_state_next[CH1]} <= {EOP_FIT, SOP};
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //->(42)
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            default:
            begin
               tlp_map_ready <= 1'b1;
               sop_on_ch1    <= 1'b0;
            end
         endcase
      end
      else if (~fifo_afull && ~tlp_map_ready && sop_on_ch1) begin
         for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
            clear_sop_eop_valid(ch);
         end
         tlp_map_ready <= 1'b1;
         sop_on_ch1    <= 1'b0;
         generate_sop  <= 1'b0;
         case ({packet_state_next[CH0], packet_state_next[CH1]})
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (36)     EOP(nofit)  SOP,EOP(nofit)   0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <=  pyld[0];          buff[1] <= {pyld[1], hdr[1]}; buff[2] <= pyld[1];
            //->(43)    EOP(fit)    SOP              0           data[0] <=  buff[0];           data[1] <= buff[1];            buff[0] <=  buff[2];          buff[1] <= '0;
            //   ->     EOP(fit)    NUL              1           data[0] <=  buff[0];
            // OR(41)   EOP(nofit)  SOP              0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <=  pyld[0];          buff[1] <= {pyld[1], hdr[1]}; buff[2] <= pyld[1];
            //->(43)    EOP(fit)    SOP              0           data[0] <=  buff[0];           data[1] <= buff[1];            buff[0] <=  buff[2];          buff[1] <= '0;
            //   -> --(append more) ???              1           data[0] <= {???, buff[0]};
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, SOP}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               map_one_source_msb(CH1, tx_buffer[CH1].data, tx_buffer[CH1].offset, '0, tx_buffer[CH1].vf_active); // map entire payload
               tx_buffer[CH0] <= tx_buffer[CH2]; // shift extra buffer into CH0
               clear_buf(CH1);
               clear_buf(CH2);
               set_eop(CH0);
               set_sop(CH1);
               if (generate_sop) begin
                  {packet_state_next[CH0], packet_state_next[CH1]} <= {NUL, NUL};
               end
               else begin
                  tlp_map_ready <= 1'b0;
                  sop_on_ch1    <= 1'b1;
                  {packet_state_next[CH0], packet_state_next[CH1]} <= {EOP_FIT, NUL};
               end
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (32)     EOP(nofit)  NUL              0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <=  pyld[0];          buff[1] <= '0;
            // (38)     --          EOP(fit)         0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], pyld[0]};buff[1] <= '0;
            // (43)     EOP(fit)    SOP              0           data[0] <=  buff[0];           data[1] <= buff[1];            buff[0] <=  buff[2];          buff[1] <= '0;
            //->(44)    EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, NUL}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               clear_buf(CH0);
               set_eop(CH0);
               clear_sop_eop_valid(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (33)     EOP(fit)    SOP,EOP(fit)     0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], hdr[1]}; buff[1] <= '0;
            //->(45)SOP,EOP(fit)    NUL              1           data[0] <=  buff[0];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP_EOP_FIT, NUL}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               clear_buf(CH0);
               set_sop_eop(CH0);
               clear_sop_eop_valid(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (34)     EOP(nofit)  SOP,EOP(fit)     0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <=  pyld[0];          buff[1] <= {pyld[1], hdr[1]};
            //->(46)    EOP(fit)    SOP,EOP(fit)     1           data[0] <=  buff[0];           data[1] <= buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {EOP_FIT, SOP_EOP_FIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, tx_buffer[CH0].offset_eop, tx_buffer[CH0].vf_active);
               map_one_source_msb(CH1, tx_buffer[CH1].data, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               clear_buf(CH0);
               clear_buf(CH1);
               set_eop(CH0);
               set_sop_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (35)     EOP(fit)    SOP,EOP(nofit)   0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], hdr[1]}; buff[1] <=  pyld[1];
            //->(47)    SOP         EOP(fit)         1           data[0] <=  buff[0];           data[1] <= buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {SOP, EOP_FIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_one_source_msb(CH1, tx_buffer[CH1].data, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               clear_buf(CH0);
               clear_buf(CH1);
               set_sop(CH0);
               set_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //          CH0             CH1          TREADY      MAP
            // (39)     --          EOP(nofit)       0           data[0] <=  buff[0];           data[1] <= {pyld[0], buff[1]}; buff[0] <= {pyld[1], pyld[0]};buff[1] <=  pyld[1];
            //->(48)    --          EOP(fit)         1           data[0] <=  buff[0];           data[1] <=  buff[1];
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            {CTND, EOP_FIT}:
            begin
               map_one_source_msb(CH0, tx_buffer[CH0].data, tx_buffer[CH0].offset, '0, tx_buffer[CH0].vf_active); // map entire payload
               map_one_source_msb(CH1, tx_buffer[CH1].data, tx_buffer[CH1].offset, tx_buffer[CH1].offset_eop, tx_buffer[CH1].vf_active);
               clear_buf(CH0);
               clear_buf(CH1);
               set_valid_clear_sop_eop(CH0);
               set_eop(CH1);
            end
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            //->(49)
            // -----------------------------------------------------------------------------------------------------------------------------------------------------
            default:
            begin
               // do nothing
            end
         endcase
      end
   end

   if (~avl_rst_n) begin
      for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
         avl_tx_st_reg[ch].valid    <= 1'b0;
         tlp_map_ready              <= 1'b1;
         sop_on_ch1                 <= 1'b0;
         generate_sop               <= 1'b0;
         clear_sop_eop_valid(ch);
         clear_buf(ch);
         packet_state_next[ch]      <= NUL;
      end
      clear_buf(CH2);
   end

   if (fifo_flush_wr | fifo_flush_rd) begin
      for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
         avl_tx_st_reg[ch].valid    <= 1'b0;
      end
   end
end : PACKET_MAP

//-------------------------------------------
// Assertions
//-------------------------------------------
// synthesis translate_off
   assert_forward_pkt_cnt_overflow :
      assert property ( @(posedge avl_clk) disable iff (~avl_rst_n) (&forward_pkt_cnt |-> ##1 (forward_pkt_cnt > 0)) )
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, forward packet counter overflow", $time)); 
   
   assert_forward_pkt_cnt_underflow :
      assert property ( @(posedge avl_clk) disable iff (~avl_rst_n) ((forward_pkt_cnt == 0) |-> ##1 ~&forward_pkt_cnt) )
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, forward packet counter underflow", $time)); 
// synthesis translate_on

//-------------------------------------------
// Tasks and Functions
//-------------------------------------------
// Reverse the DW from big endian to little endian
function automatic logic [127:0] func_to_little_endian_hdr (
   input logic [127:0] hdr
);
   for (int i=0; i<=3; i=i+1) begin
      func_to_little_endian_hdr[i*32+:32] = hdr[(3-i)*32+:32];
   end
endfunction

/* Pack LSB of source0 with MSB of source1 to target data bus delimited by offset
   map_two_sources(target, source0, source1, hdr_valid, offset)
   - in the case of passing two same-width sources
      -- map_two_sources(target=0/1, source0[256], source1[256], hdr_valid=0, offset=3DW/4DW)
   - in the case of passing header with a source
      -- map_two_sources(target=0/1, source0[256], {'0, hdr[128]}, hdr_valid=1, offset=3DW/4DW)
*/
task map_two_sources;
   input e_channel               i_target;
   input logic [AVST_DW-1:0]     i_source0;
   input logic [AVST_DW-1:0]     i_source1;
   input logic                   i_hdr_valid;
   input e_offset                i_offset;
   input logic [2:0]             i_offset_eop;
   input logic                   i_eop;
   input logic                   i_vf_active;
begin
   case (i_offset)
      OFFSET_3DW:
      begin
         if (i_hdr_valid) begin
            avl_tx_st_reg[i_target].data <= {i_source0[SOP_3DW_DWORD_LEN*32-1:0], i_source1[HDR_3DW_LEN*32-1:0]};
         end
         else begin
            avl_tx_st_reg[i_target].data <= {i_source0[SOP_3DW_DWORD_LEN*32-1:0], i_source1[NON_SOP_DWORD_LEN*32-1:SOP_3DW_DWORD_LEN*32]};
         end
      end
      default: // OFFSET_4DW
      begin
         if (i_hdr_valid) begin
            avl_tx_st_reg[i_target].data <= {i_source0[SOP_4DW_DWORD_LEN*32-1:0], i_source1[HDR_4DW_LEN*32-1:0]};
         end
         else begin
            avl_tx_st_reg[i_target].data <= {i_source0[SOP_4DW_DWORD_LEN*32-1:0], i_source1[NON_SOP_DWORD_LEN*32-1:SOP_4DW_DWORD_LEN*32]};
         end
      end
   endcase
   avl_tx_st_reg[i_target].vf_active <= i_vf_active;
   `ifdef SIM_MODE
      if (i_eop) begin
         case (i_offset_eop)
            3'h7:
            begin
               avl_tx_st_reg[i_target].data[NON_SOP_DWORD_LEN*32-1:7*32] <= '0;
            end
            3'h6:
            begin
               avl_tx_st_reg[i_target].data[NON_SOP_DWORD_LEN*32-1:6*32] <= '0;
            end
            3'h5:
            begin
               avl_tx_st_reg[i_target].data[NON_SOP_DWORD_LEN*32-1:5*32] <= '0;
            end
            3'h4:
            begin
               avl_tx_st_reg[i_target].data[NON_SOP_DWORD_LEN*32-1:4*32] <= '0;
            end
            3'h3:
            begin
               avl_tx_st_reg[i_target].data[NON_SOP_DWORD_LEN*32-1:3*32] <= '0;
            end
            3'h2:
            begin
               avl_tx_st_reg[i_target].data[NON_SOP_DWORD_LEN*32-1:2*32] <= '0;
            end
            3'h1:
            begin
               avl_tx_st_reg[i_target].data[NON_SOP_DWORD_LEN*32-1:1*32] <= '0;
            end
            default:
            begin
               // do nothing
            end
         endcase
      end
   `endif
end
endtask : map_two_sources

// Pack MSB of source delimited by offset to LSB of target data bus
task map_one_source_msb;
   input e_channel               i_target;
   input logic [AVST_DW-1:0]     i_source;
   input e_offset                i_offset;
   input logic [2:0]             i_offset_eop;
   input logic                   i_vf_active;
begin
   avl_tx_st_reg[i_target].data <= '0;
   if (i_offset == OFFSET_3DW) begin
      case (i_offset_eop)
         3'h3:
         begin
            avl_tx_st_reg[i_target].data[3*32-1:0]  <= i_source[(NON_SOP_DWORD_LEN-HDR_3DW_LEN+3)*32-1:(NON_SOP_DWORD_LEN-HDR_3DW_LEN)*32];
         end
         3'h2:
         begin
            avl_tx_st_reg[i_target].data[2*32-1:0]  <= i_source[(NON_SOP_DWORD_LEN-HDR_3DW_LEN+2)*32-1:(NON_SOP_DWORD_LEN-HDR_3DW_LEN)*32];
         end
         3'h1:
         begin
            avl_tx_st_reg[i_target].data[1*32-1:0]  <= i_source[(NON_SOP_DWORD_LEN-HDR_3DW_LEN+1)*32-1:(NON_SOP_DWORD_LEN-HDR_3DW_LEN)*32];
         end
         default:
         begin
            avl_tx_st_reg[i_target].data            <= i_source;
         end
      endcase
   end
   else begin // OFFSET_4DW
      case (i_offset_eop)
         3'h4:
         begin
            avl_tx_st_reg[i_target].data[4*32-1:0]  <= i_source[(NON_SOP_DWORD_LEN-HDR_4DW_LEN+4)*32-1:(NON_SOP_DWORD_LEN-HDR_4DW_LEN)*32];
         end
         3'h3:
         begin
            avl_tx_st_reg[i_target].data[3*32-1:0]  <= i_source[(NON_SOP_DWORD_LEN-HDR_4DW_LEN+3)*32-1:(NON_SOP_DWORD_LEN-HDR_4DW_LEN)*32];
         end
         3'h2:
         begin
            avl_tx_st_reg[i_target].data[2*32-1:0]  <= i_source[(NON_SOP_DWORD_LEN-HDR_4DW_LEN+2)*32-1:(NON_SOP_DWORD_LEN-HDR_4DW_LEN)*32];
         end
         3'h1:
         begin
            avl_tx_st_reg[i_target].data[1*32-1:0]  <= i_source[(NON_SOP_DWORD_LEN-HDR_4DW_LEN+1)*32-1:(NON_SOP_DWORD_LEN-HDR_4DW_LEN)*32];
         end
         default:
         begin
            avl_tx_st_reg[i_target].data            <= i_source;
         end
      endcase
   end
   avl_tx_st_reg[i_target].vf_active <= i_vf_active;
end
endtask : map_one_source_msb

/* Buffer LSB of source0 with MSB of source1 to target buffer delimited by offset
   buf_two_sources(target, source0, source1, hdr_valid, offset)
   - in the case of passing two same width sources
      -- buf_two_sources(target=0/1, source0[256], source1[256], hdr_valid=0, offset=3DW/4DW)
   - in the case of passing header with a source
      -- buf_two_sources(target=0/1, source0[256], {'0, hdr[128]}, hdr_valid=1, offset=3DW/4DW)
*/
task buf_two_sources;
   input e_channel               i_target;
   input logic [AVST_DW-1:0]     i_source0;
   input logic [AVST_DW-1:0]     i_source1;
   input logic                   i_hdr_valid;
   input e_offset                i_offset;
   input logic [2:0]             i_offset_eop;
   input logic                   i_vf_active;
begin
   case (i_offset)
      OFFSET_3DW:
      begin
         if (i_hdr_valid) begin
            tx_buffer[i_target].data <= {i_source0[SOP_3DW_DWORD_LEN*32-1:0], i_source1[HDR_3DW_LEN*32-1:0]};
         end
         else begin
            tx_buffer[i_target].data <= {i_source0[HDR_3DW_LEN*32-1:0], i_source1[NON_SOP_DWORD_LEN*32-1:HDR_3DW_LEN*32]};
         end
      end
      default: // OFFSET_4DW
      begin
         if (i_hdr_valid) begin
            tx_buffer[i_target].data <= {i_source0[SOP_4DW_DWORD_LEN*32-1:0], i_source1[HDR_4DW_LEN*32-1:0]};
         end
         else begin
            tx_buffer[i_target].data <= {i_source0[HDR_4DW_LEN*32-1:0], i_source1[NON_SOP_DWORD_LEN*32-1:HDR_4DW_LEN*32]};
         end
      end
   endcase
   tx_buffer[i_target].offset          <= i_offset;
   tx_buffer[i_target].offset_eop      <= i_offset_eop;
   tx_buffer[i_target].vf_active       <= i_vf_active;
   tx_buffer[i_target].valid           <= 1'b1;
end
endtask : buf_two_sources

// Buffer one entire source 
task buf_one_source;
   input e_channel               i_target;
   input logic [AVST_DW-1:0]     i_source;
   input e_offset                i_offset;
   input logic [2:0]             i_offset_eop;
   input logic                   i_vf_active;
begin
   tx_buffer[i_target].data         <= i_source;
   tx_buffer[i_target].offset       <= i_offset;
   tx_buffer[i_target].offset_eop   <= i_offset_eop;
   tx_buffer[i_target].vf_active    <= i_vf_active;
   tx_buffer[i_target].valid        <= 1'b1;
end
endtask : buf_one_source

// Clear buffer
task clear_buf;
   input integer  i_ch;
begin
   tx_buffer[i_ch].data          <= '0;
   tx_buffer[i_ch].offset        <= OFFSET_ERR;
   tx_buffer[i_ch].offset_eop    <= '0;
   tx_buffer[i_ch].vf_active     <= '0;
   tx_buffer[i_ch].valid         <= '0;
end
endtask : clear_buf

// Clear SOP, EOP, and valid
task clear_sop_eop_valid;
   input integer  i_ch;
begin
   avl_tx_st_reg[i_ch].valid   <= 1'b0;
   avl_tx_st_reg[i_ch].sop     <= 1'b0;
   avl_tx_st_reg[i_ch].eop     <= 1'b0;
end
endtask : clear_sop_eop_valid

// Set valid but clear SOP & EOP
task set_valid_clear_sop_eop;
   input integer  i_ch;
begin
   avl_tx_st_reg[i_ch].valid   <= 1'b1;
   avl_tx_st_reg[i_ch].sop     <= 1'b0;
   avl_tx_st_reg[i_ch].eop     <= 1'b0;
end
endtask : set_valid_clear_sop_eop

// Set SOP & EOP
task set_sop_eop;
   input integer  i_ch;
begin
   avl_tx_st_reg[i_ch].valid   <= 1'b1;
   avl_tx_st_reg[i_ch].sop     <= 1'b1;
   avl_tx_st_reg[i_ch].eop     <= 1'b1;
end
endtask : set_sop_eop

// Set SOP
task set_sop;
   input integer  i_ch;
begin
   avl_tx_st_reg[i_ch].valid   <= 1'b1;
   avl_tx_st_reg[i_ch].sop     <= 1'b1;
   avl_tx_st_reg[i_ch].eop     <= 1'b0;
end
endtask : set_sop

// Set EOP
task set_eop;
   input integer  i_ch;
begin
   avl_tx_st_reg[i_ch].valid   <= 1'b1;
   avl_tx_st_reg[i_ch].sop     <= 1'b0;
   avl_tx_st_reg[i_ch].eop     <= 1'b1;
end
endtask : set_eop

endmodule
