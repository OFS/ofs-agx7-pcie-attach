// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  Toggle ready signal based on the selected mode 
//
//-----------------------------------------------------------------------------

module ready_gen (
   input logic       clk,
   input logic       rst_n,
   input logic       en,
   input logic [3:0] mode,
   output logic      ready
);

always_ff @(posedge clk) begin
   if (~rst_n) begin
      ready <= 1'b0;
   end else if (en) begin
      case (mode)
         4'h0 : begin
            if ($urandom_range(1,10)%2 == 0) begin
               ready <= 1'b0;
            end else begin
               ready <= 1'b1;
            end
         end
         default : begin
            ready <= ~ready;
         end
      endcase
   end else begin
      ready <= 1'b1;
   end
end

endmodule

