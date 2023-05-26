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

`include "fpga_defines.vh"


module pcie_tx_bridge_ptile 
import ofs_fim_pcie_hdr_def::*;
import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;
(
   input  logic                           avl_clk,
   input  logic                           avl_rst_n, // Synchronous reset
   output ofs_fim_pcie_pkg::t_avst_txs    avl_tx_st,
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

t_avst_txs avl_tx_st_reg, avl_tx_st_reg2;

logic [2:0] avl_tx_ready_q;
logic rx_cpl_buffer_ready;
logic tlp_map_ready;
logic sop_on_ch1, generate_sop;
logic [CPL_CREDIT_WIDTH-1:0] mrd_length [1:0]; // 1DW units

logic [NUM_AVST_CH-1:0][127:0]          avl_tx_hdr;
logic [FIM_PCIE_TLP_CH-1:0]             sop;
logic [FIM_PCIE_TLP_CH-1:0]             mrd;
t_tlp_mem_req_hdr [FIM_PCIE_TLP_CH-1:0] mem_req_hdr;
logic [FIM_PCIE_TLP_CH-1:0][6:0]        fmttype;

logic [9:0] tlp_hdr_len  [1:0];
logic [9:0] tlp_pyld_len [1:0];

logic fifo_forward_pkt;
logic [FIFO_DEPTH_LOG2:0] forward_pkt_cnt;
logic forward_pkt_cnt_incr, forward_pkt_cnt_decr;

logic fifo_wrreq, fifo_rdack;
logic fifo_full, fifo_afull, fifo_empty;
logic fifo_rvalid;
t_avst_txs fifo_din, fifo_dout;

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

// Store & forward FIFO write side control
always_comb begin
   fifo_din = avl_tx_st_reg2;
   if (NUM_AVST_CH == 1) begin
      fifo_wrreq = avl_tx_st_reg2[CH0].valid;
   end
   else begin
      fifo_wrreq = avl_tx_st_reg2[CH0].valid | avl_tx_st_reg2[CH1].valid;
   end
end

// Store & forward FIFO read side control
always_comb begin
   avl_tx_st = fifo_dout;
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      avl_tx_st[ch].valid = avl_tx_ready_q[2] && fifo_rvalid && fifo_dout[ch].valid && fifo_forward_pkt;
   end
   fifo_rdack = avl_tx_ready_q[2] & fifo_forward_pkt;
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

ofs_fim_pcie_txs_axis_if tx_aligner_out_if();

t_axis_pcie_txs axis_pcie_txs_in;
logic axis_in_pipeln_ready;
t_axis_pcie_txs axis_pcie_txs;
logic axis_pcie_txs_ready;

tx_aligner tx_aligner (
   .i_afu_tx_st (axis_tx_st),
   .o_afu_tx_st (tx_aligner_out_if)
);

always_comb begin
   axis_pcie_txs_in         = tx_aligner_out_if.tx;
   tx_aligner_out_if.tready = axis_in_pipeln_ready;
   
   // The axis_tx_st.tready signal comes from multiple sources, not just the
   // target skid buffer. Set the valid flag passed to the skid buffer to match
   // the true ready state.
   axis_pcie_txs_in.tvalid = tx_aligner_out_if.tx.tvalid && tx_aligner_out_if.tready;
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

// AXIS ready leaving ingress skid buffer
assign axis_pcie_txs_ready = ~fifo_afull && rx_cpl_buffer_ready;

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


//-----------------------------------------------------------------
// Generate MRD info for RX bridge
//-----------------------------------------------------------------
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

//-----------------------------------------------------------------
// RX CPL credit tracking
//-----------------------------------------------------------------
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
      rx_cpl_buffer_ready <= 1'b1;
   end
end
 
//-----------------------------------------------------------------
// Map AXIS onto AVST data bus 
//-----------------------------------------------------------------
always_ff @(posedge avl_clk) begin : PACKET_MAP
   for (int ch=0; ch<NUM_AVST_CH; ++ch) begin
      `ifdef SIM_MODE     
         avl_tx_st_reg[ch] <= '0;
      `else
         avl_tx_st_reg[ch].valid <= 1'b0;
      `endif

      if (axis_pcie_txs.tvalid && axis_pcie_txs_ready) begin
         avl_tx_st_reg[ch].valid     <= axis_pcie_txs.tdata[ch].valid;
         avl_tx_st_reg[ch].sop       <= axis_pcie_txs.tdata[ch].sop;
         avl_tx_st_reg[ch].eop       <= axis_pcie_txs.tdata[ch].eop;
         avl_tx_st_reg[ch].hdr       <= axis_pcie_txs.tdata[ch].hdr;
         avl_tx_st_reg[ch].hdr[83]   <= axis_pcie_txs.tuser[ch].vf_active;
         avl_tx_st_reg[ch].data      <= axis_pcie_txs.tdata[ch].payload;
         avl_tx_st_reg[ch].vf_active <= axis_pcie_txs.tuser[ch].vf_active;
      end

      if (~avl_rst_n) begin
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

endmodule

