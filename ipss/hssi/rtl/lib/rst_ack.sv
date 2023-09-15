// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  Reset Assertion/De-assertion based on Ack 
//
//-----------------------------------------------------------------------------

module rst_ack (
   input       i_clk,
   input       i_rst,
   input       i_ack,
   output      o_rst
);


// ------------------------
// State Definitions
// ------------------------
typedef enum bit [1:0] {
    S_IDLE                 = 2'b00,
    S_RST_ASSERT           = 2'b01,   // This state is entered when input reset is asserted
    S_WAIT_RST_DEASSERT    = 2'b10,   // This state is entered when acknowledge for Reset received
    S_WAIT_ACK_DEASSERT    = 2'b11    // This state is entered when input reset is de-asserted, return to IDLE when ack is de-asserted
} rst_state;
rst_state state, next_state;

// FSM transition logic //
always_comb begin : state_transition
   // FSM Default State
   next_state = S_IDLE;
   
   case (state)
   
      S_IDLE : begin
         next_state = S_IDLE;
         if (i_rst) next_state = S_RST_ASSERT;
      end
   
      S_RST_ASSERT : begin
         next_state = S_RST_ASSERT;
         if (i_ack) next_state = S_WAIT_RST_DEASSERT;
      end
   
      S_WAIT_RST_DEASSERT : begin
         next_state = S_WAIT_RST_DEASSERT;
         if (~i_rst) next_state = S_WAIT_ACK_DEASSERT;
      end
   
      S_WAIT_ACK_DEASSERT : begin
         next_state = S_WAIT_ACK_DEASSERT;
         if (~i_ack)  next_state = S_IDLE;
      end
   
   endcase

end : state_transition

// State update
always @(posedge i_clk) begin
   state <= next_state;
end

assign o_rst = (next_state == S_RST_ASSERT) | (next_state == S_WAIT_RST_DEASSERT);

endmodule //rst_ack