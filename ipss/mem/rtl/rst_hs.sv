// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// Subsystem reset handshake module
//
//-----------------------------------------------------------------------------

module rst_hs
(
   input logic clk,
   // reset initiator signal
   input logic 	rst_init,

   // SS reset handshake signals
   // from init
   output logic rst_req,
   output logic rst_n,

   // from rsp
   input logic 	rst_rdy,
   input logic 	rst_ack_n
);

   enum logic [2:0] {
      RST_IDLE,
      WAIT_RDY,
      WARM_RST
   } rst_state;

   always_ff @(posedge clk) begin
      case(rst_state)
	RST_IDLE: begin
	   rst_req <= 1'b0;
	   rst_n   <= 1'b1;
	   if(rst_init && rst_ack_n) begin // MemSS behavior, only take reset requests when rst_ack is deasserted
	      rst_state <= WAIT_RDY;
	      rst_req   <= 1'b1;
	   end
	end
	WAIT_RDY: if(rst_rdy) rst_state <= WARM_RST;
	WARM_RST: begin
	   rst_req <= 1'b0;
	   rst_n   <= 1'b0;
	   if(~rst_ack_n) begin
	      rst_state <= RST_IDLE;
	      rst_n <= 1'b1;
	   end
	end
	default:  rst_state <= RST_IDLE;
      endcase // case (rst_state)
   end
endmodule // rst_hdshk

