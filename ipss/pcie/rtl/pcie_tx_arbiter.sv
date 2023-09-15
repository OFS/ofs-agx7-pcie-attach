// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   PCIe TX arbiter arbitrates betwen the TLP packets from MMIO AXIS-TX channel, 
//   MSIX AXIS-TX channel and AFU AXIS-TX channel
//
//   The arbiter makes sure TLP packets which belong to the same TLP request/response
//   are sent contiguously upstream.
//
//-----------------------------------------------------------------------------

import ofs_fim_if_pkg::*;

module pcie_tx_arbiter #(
)(
   input logic            clk,
   input logic            rst_n,
 
   pcie_ss_axis_if.sink   i_mmio_tx_st,
   pcie_ss_axis_if.sink   i_afu_tx_st,
   pcie_ss_axis_if.sink   i_msix_tx_st,

   pcie_ss_axis_if.source o_pcie_tx_st

);

pcie_ss_axis_if  pcie_tx_q (.clk(clk), .rst_n(rst_n));
pcie_ss_axis_if  mmio_tx_st(.clk(clk), .rst_n(rst_n));
pcie_ss_axis_if  afu_tx_st (.clk(clk), .rst_n(rst_n));
pcie_ss_axis_if  msix_tx_st(.clk(clk), .rst_n(rst_n));

logic mmio_tx_tready_q;
logic afu_tx_tready_q;
logic msix_tx_tready_q;

logic pcie_tx_tready;

//**************************
// Interface assignment
//**************************
// MMIO input
assign mmio_tx_st.tvalid       = i_mmio_tx_st.tvalid;
assign mmio_tx_st.tlast        = i_mmio_tx_st.tlast;
assign mmio_tx_st.tdata        = i_mmio_tx_st.tdata;
assign mmio_tx_st.tuser_vendor = i_mmio_tx_st.tuser_vendor;
assign mmio_tx_st.tkeep        = i_mmio_tx_st.tkeep;
assign i_mmio_tx_st.tready     = mmio_tx_tready_q;
assign mmio_tx_st.tready       = mmio_tx_tready_q;


// AFU input
assign afu_tx_st.tvalid        = i_afu_tx_st.tvalid;
assign afu_tx_st.tdata         = i_afu_tx_st.tdata;
assign afu_tx_st.tkeep         = i_afu_tx_st.tkeep;
assign afu_tx_st.tlast         = i_afu_tx_st.tlast;
assign afu_tx_st.tuser_vendor  = i_afu_tx_st.tuser_vendor; 
assign i_afu_tx_st.tready      = afu_tx_tready_q;
assign afu_tx_st.tready        = afu_tx_tready_q;

// MSIX input
assign msix_tx_st.tvalid       = i_msix_tx_st.tvalid;
assign msix_tx_st.tdata        = i_msix_tx_st.tdata;
assign msix_tx_st.tkeep        = i_msix_tx_st.tkeep;
assign msix_tx_st.tlast        = i_msix_tx_st.tlast;
assign msix_tx_st.tuser_vendor = i_msix_tx_st.tuser_vendor;
assign i_msix_tx_st.tready     = msix_tx_tready_q;
assign msix_tx_st.tready       = msix_tx_tready_q;


// PCIe Tx output to upstream
assign o_pcie_tx_st.tvalid         = pcie_tx_q.tvalid;
assign o_pcie_tx_st.tdata          = pcie_tx_q.tdata;
assign o_pcie_tx_st.tlast          = pcie_tx_q.tlast;
assign o_pcie_tx_st.tkeep          = pcie_tx_q.tkeep;
assign o_pcie_tx_st.tuser_vendor   = pcie_tx_q.tuser_vendor;
assign pcie_tx_tready              = o_pcie_tx_st.tready;
assign pcie_tx_q.tready            = o_pcie_tx_st.tready;

// State definitions for user state machine
typedef enum logic [4:0] {
   ARB_FSM_RESET,
   ARB_FSM_IDLE,
   ARB_FSM_MMIO,
   ARB_FSM_AFU,
   ARB_FSM_MSIX
} t_arbiter_state;

(* syn_encoding = "one-hot" *) t_arbiter_state arbiter_state;

typedef enum logic [2:0] {
   ISTREAM_NONE,
   ISTREAM_MMIO,
   ISTREAM_AFU,
   ISTREAM_MSIX
} t_input_streams;

(* syn_encoding = "one-hot" *) t_input_streams istream_last;

// Favor the AFU path. Allow AFU traffic while the arbiter is idle as long as
// no other ports have requests.
logic no_fim_tx_is_valid;
logic afu_tx_grant_while_idle;
logic afu_tx_is_eop;
t_arbiter_state afu_tx_state_from_idle;

// Grant AFU traffic in idle when only AFU traffic is present
assign no_fim_tx_is_valid      = ~mmio_tx_st.tvalid && ~msix_tx_st.tvalid;
assign afu_tx_grant_while_idle = pcie_tx_tready && no_fim_tx_is_valid;
assign afu_tx_state_from_idle  = (afu_tx_grant_while_idle) ? ARB_FSM_IDLE : ARB_FSM_AFU;


// Fair arbiter between MMIO, AFU, and MSIX interrupt streams
always_ff @(posedge clk) begin : ARB_FSM
   case (arbiter_state)
      // ---------------------------------------------------
      ARB_FSM_RESET:
      begin
         arbiter_state                 <= ARB_FSM_RESET;
         istream_last                  <= ISTREAM_NONE;
         if (rst_n) begin
            arbiter_state              <= ARB_FSM_IDLE;
         end
      end
      // ---------------------------------------------------
      ARB_FSM_IDLE:
      begin
         arbiter_state                 <= ARB_FSM_IDLE;
         case (istream_last)
            ISTREAM_MMIO:
            begin
               if (afu_tx_st.tvalid) begin
                  arbiter_state        <= afu_tx_state_from_idle;
               end
               else if (msix_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MSIX;
               end
               else if (mmio_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MMIO;
               end
               else begin
                  arbiter_state        <= ARB_FSM_IDLE;
               end
            end
            ISTREAM_AFU:
            begin
               if (msix_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MSIX;
               end
               else if (mmio_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MMIO;
               end
               else if (afu_tx_st.tvalid) begin
                  arbiter_state        <= afu_tx_state_from_idle;
               end
               else begin
                  arbiter_state        <= ARB_FSM_IDLE;
               end
            end
            default:
            begin
               if (mmio_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MMIO;
               end
               else if (afu_tx_st.tvalid) begin
                  arbiter_state        <= afu_tx_state_from_idle;
               end
               else if (msix_tx_st.tvalid) begin
                  arbiter_state        <= ARB_FSM_MSIX;
               end
               else begin
                  arbiter_state        <= ARB_FSM_IDLE;
               end
            end
         endcase
      end
      // ---------------------------------------------------
      ARB_FSM_MMIO:
      begin
         arbiter_state                 <= ARB_FSM_MMIO;
         istream_last                  <= ISTREAM_MMIO;
         if (pcie_tx_tready & mmio_tx_st.tvalid) begin
            arbiter_state              <= ARB_FSM_IDLE;
         end
      end
      // ---------------------------------------------------
      ARB_FSM_AFU:
      begin
         arbiter_state                 <= ARB_FSM_AFU;
         istream_last                  <= ISTREAM_AFU;
         if (pcie_tx_tready & afu_tx_st.tvalid) begin
            arbiter_state              <= ARB_FSM_IDLE;
         end
      end
      // ---------------------------------------------------
      ARB_FSM_MSIX:
      begin
         arbiter_state                 <= ARB_FSM_MSIX;
         istream_last                  <= ISTREAM_MSIX;
         if (pcie_tx_tready & msix_tx_st.tvalid) begin
            arbiter_state              <= ARB_FSM_IDLE;
         end
      end
      // ---------------------------------------------------
      default:
      begin
         // something went wrong
         arbiter_state                 <= ARB_FSM_RESET;
      end
   endcase // arbiter_state

   if(~rst_n) begin
      arbiter_state                    <= ARB_FSM_RESET;
   end
end : ARB_FSM

always_comb begin 
   // Arbitrate
   case (arbiter_state)
      ARB_FSM_MMIO:
      begin
         afu_tx_tready_q                     = 1'b0;
         msix_tx_tready_q                    = 1'b0;
         mmio_tx_tready_q                    = pcie_tx_tready;
         pcie_tx_q.tvalid                    = mmio_tx_st.tvalid;
         pcie_tx_q.tlast                     = mmio_tx_st.tlast;
         pcie_tx_q.tdata                     = mmio_tx_st.tdata;
         pcie_tx_q.tuser_vendor              = mmio_tx_st.tuser_vendor;
         pcie_tx_q.tkeep                     = mmio_tx_st.tkeep;
      end
      ARB_FSM_AFU:
      begin
         mmio_tx_tready_q                    = 1'b0;
         msix_tx_tready_q                    = 1'b0;
         afu_tx_tready_q                     = pcie_tx_tready;
         pcie_tx_q.tvalid                    = afu_tx_st.tvalid;
         pcie_tx_q.tlast                     = afu_tx_st.tlast;
         pcie_tx_q.tdata                     = afu_tx_st.tdata;
         pcie_tx_q.tuser_vendor              = afu_tx_st.tuser_vendor;
         pcie_tx_q.tkeep                     = afu_tx_st.tkeep;
      end
      ARB_FSM_MSIX:
      begin
         mmio_tx_tready_q                    = 1'b0;
         afu_tx_tready_q                     = 1'b0;
         msix_tx_tready_q                    = pcie_tx_tready;
         pcie_tx_q.tvalid                    = msix_tx_st.tvalid;
         pcie_tx_q.tlast                     = msix_tx_st.tlast;
         pcie_tx_q.tdata                     = msix_tx_st.tdata;
         pcie_tx_q.tuser_vendor              = msix_tx_st.tuser_vendor;
         pcie_tx_q.tkeep                     = msix_tx_st.tkeep;
      end
      default:
      begin
         mmio_tx_tready_q                    = 1'b0;
         msix_tx_tready_q                    = 1'b0;
         afu_tx_tready_q                     = afu_tx_grant_while_idle;
         pcie_tx_q.tvalid                    = afu_tx_st.tvalid && no_fim_tx_is_valid;
         pcie_tx_q.tlast                     = afu_tx_st.tlast;
         pcie_tx_q.tdata                     = afu_tx_st.tdata;
         pcie_tx_q.tuser_vendor              = afu_tx_st.tuser_vendor;
         pcie_tx_q.tkeep                     = afu_tx_st.tkeep;
      end
   endcase
end

endmodule
