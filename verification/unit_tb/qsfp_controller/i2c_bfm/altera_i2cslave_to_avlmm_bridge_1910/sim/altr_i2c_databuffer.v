// Copyright (C) 2001-2020 Intel Corporation
// SPDX-License-Identifier: MIT


//
// Parameterizable width data buffer
// Meant to be used for THR & RB
// Conceptually a 1-deep FIFO
//
`timescale 1 ps / 1 ps
module altr_i2c_databuffer #(
   parameter DSIZE = 8
) (
   input  clk,
   input  rst_n,
   input  s_rst,  //Sync Reset - when Mode is disabled
   input  put,
   input  get,
   output reg empty,
   input  [DSIZE-1:0] wdata,
   output reg [DSIZE-1:0] rdata
);

//BUFFER storage
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
	  rdata <= {DSIZE{1'b0}};
  end
  else if (put) begin
	  rdata <= wdata; 
  end
end

//EMPTY Indicator
always @(posedge clk or negedge rst_n) begin
   if (!rst_n)
      empty <= 1;
   else begin
      empty <= s_rst ? 1 :
               put   ? 0 :
               get   ? 1 :
               empty;
   end
   
end

endmodule
