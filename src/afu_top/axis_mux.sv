// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// AXI4-S Streaming Multiplexer 
//
//   * The multiplexer supports up to 4 input channels
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module axis_mux #(
   parameter NUM_CH        = 1, // 1-4
   parameter TDATA_WIDTH   = 8,
   parameter TID_WIDTH     = 1,
   parameter TDEST_WIDTH   = 1,
   parameter TUSER_WIDTH   = 1
)(
   input wire         clk,
   input wire         rst_n,

   ofs_axis_if.sink   sink   [NUM_CH-1:0],
   ofs_axis_if.source source
);

localparam TKEEP_WIDTH = (TDATA_WIDTH/8);
localparam SEL_WIDTH   = $clog2(NUM_CH);

logic [NUM_CH-1:0]                  in_tready;
logic [NUM_CH-1:0]                  in_tvalid;
logic [NUM_CH-1:0][TDATA_WIDTH-1:0] in_tdata;
logic [NUM_CH-1:0][TKEEP_WIDTH-1:0] in_tkeep; 
logic [NUM_CH-1:0]                  in_tlast; 
logic [NUM_CH-1:0][TID_WIDTH-1:0]   in_tid;
logic [NUM_CH-1:0][TDEST_WIDTH-1:0] in_tdest; 
logic [NUM_CH-1:0][TUSER_WIDTH-1:0] in_tuser; 

logic                   tvalid_reg;
logic [TDATA_WIDTH-1:0] tdata_reg;
logic [TKEEP_WIDTH-1:0] tkeep_reg; 
logic                   tlast_reg; 
logic [TID_WIDTH-1:0]   tid_reg;
logic [TDEST_WIDTH-1:0] tdest_reg; 
logic [TUSER_WIDTH-1:0] tuser_reg; 

logic [SEL_WIDTH-1:0]   sel; 
logic [NUM_CH-1:0]      sel_1hot;
logic                   sel_valid;
logic [NUM_CH-1:0]      hold; 

logic ready;

assign ready = (~source.tvalid | source.tready);

//-----------------
// Input pipeline
//-----------------
genvar ig;
generate for (ig=0; ig<NUM_CH; ++ig) begin : in_pipe
   ofs_fim_axis_register #(
      .TDATA_WIDTH  (TDATA_WIDTH),
      .ENABLE_TUSER (1),
      .TID_WIDTH    (TID_WIDTH),
      .TDEST_WIDTH  (TDEST_WIDTH),
      .TUSER_WIDTH  (TUSER_WIDTH)
   ) axis_in_reg (
      .clk        (clk             ),
      .rst_n      (rst_n           ),
      .s_tready   (sink[ig].tready ),
      .s_tvalid   (sink[ig].tvalid ),
      .s_tdata    (sink[ig].tdata  ),
      .s_tkeep    (sink[ig].tkeep  ), 
      .s_tlast    (sink[ig].tlast  ), 
      .s_tid      (sink[ig].tid    ), 
      .s_tdest    (sink[ig].tdest  ), 
      .s_tuser    (sink[ig].tuser  ), 
      
      .m_tready   (in_tready [ig]  ),
      .m_tvalid   (in_tvalid [ig]  ),
      .m_tdata    (in_tdata  [ig]  ),
      .m_tkeep    (in_tkeep  [ig]  ), 
      .m_tlast    (in_tlast  [ig]  ), 
      .m_tid      (in_tid    [ig]  ), 
      .m_tdest    (in_tdest  [ig]  ), 
      .m_tuser    (in_tuser  [ig]  ) 
   );
end
endgenerate

//-----------------
// Mux logic
//-----------------
always_comb begin
   for (int i=0; i<NUM_CH; ++i) begin
      hold[i] = (~in_tlast[i] | ~ready);
   end
end

ofs_fim_fair_arbiter #(
   .NUM_INPUTS(NUM_CH)
) arb (
   .clk             (clk),
   .reset_n         (rst_n),
   .in_valid        (in_tvalid),
   .hold_priority   (hold),
   .out_select      (sel),
   .out_select_1hot (sel_1hot),
   .out_valid       (sel_valid)
);

//-----------------
// Output Stage 
//-----------------
always_ff @(posedge clk) begin
   if (ready) begin
      tvalid_reg <= sel_valid;
      tdata_reg  <= in_tdata [sel];
      tkeep_reg  <= in_tkeep [sel];
      tlast_reg  <= in_tlast [sel];
      tid_reg    <= in_tid   [sel];
      tdest_reg  <= in_tdest [sel];
      tuser_reg  <= in_tuser [sel];
   end
   
   if (~rst_n) begin
      tvalid_reg <= 1'b0; 
   end
end

always_comb begin
   source.tvalid = tvalid_reg;
   source.tdata  = tdata_reg;
   source.tkeep  = tkeep_reg;
   source.tlast  = tlast_reg;
   source.tid    = tid_reg;
   source.tdest  = tdest_reg;
   source.tuser  = tuser_reg;
end

always_comb begin
   for (int i=0; i<NUM_CH; ++i) begin
      in_tready[i] = sel_1hot[i] & ready;
   end
end

endmodule : axis_mux

