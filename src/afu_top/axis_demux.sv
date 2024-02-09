// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// AXI4-S Streaming Demultiplexer
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module axis_demux #(
   parameter NUM_CH        = 1,
   parameter TDATA_WIDTH   = 8,
   parameter TID_WIDTH     = 1,
   parameter TDEST_WIDTH   = 1,
   parameter TUSER_WIDTH   = 1,

   // Derived parameter
   parameter SEL_WIDTH = $clog2(NUM_CH)
)(
   input logic [SEL_WIDTH-1:0] sel,

   ofs_axis_if.sink   sink,
   ofs_axis_if.source source [NUM_CH-1:0]
);

localparam TKEEP_WIDTH = (TDATA_WIDTH/8);

wire clk;
wire rst_n;

logic [SEL_WIDTH-1:0]    ch_sel;
logic                    axis_in_tready;
logic                    axis_in_tvalid;
logic [TDATA_WIDTH-1:0]  axis_in_tdata;
logic [TKEEP_WIDTH-1:0]  axis_in_tkeep; 
logic                    axis_in_tlast; 
logic [TID_WIDTH-1:0]    axis_in_tid;
logic [TDEST_WIDTH-1:0]  axis_in_tdest; 
logic [TUSER_WIDTH-1:0]  axis_in_tuser; 

logic                    axis_out_tready;
logic                    axis_out_tvalid;
logic [TDATA_WIDTH-1:0]  axis_out_tdata;
logic [TKEEP_WIDTH-1:0]  axis_out_tkeep; 
logic                    axis_out_tlast; 
logic [TID_WIDTH-1:0]    axis_out_tid;
logic [TDEST_WIDTH-1:0]  axis_out_tdest; 
logic [TUSER_WIDTH-1:0]  axis_out_tuser; 


assign clk   = sink.clk;
assign rst_n = sink.rst_n;

// Input pipeline
ofs_fim_axis_register #(
   .TDATA_WIDTH (TDATA_WIDTH+SEL_WIDTH),
   .ENABLE_TUSER (1),
   .TID_WIDTH   (TID_WIDTH),
   .TDEST_WIDTH (TDEST_WIDTH),
   .TUSER_WIDTH (TUSER_WIDTH)
) axis_in_reg (
   .clk        (clk                     ),
   .rst_n      (rst_n                   ),
   .s_tready   (sink.tready             ),
   .s_tvalid   (sink.tvalid             ),
   .s_tdata    ({sink.tdata, sel}       ),
   .s_tkeep    (sink.tkeep              ), 
   .s_tlast    (sink.tlast              ), 
   .s_tid      (sink.tid                ), 
   .s_tdest    (sink.tdest              ), 
   .s_tuser    (sink.tuser              ), 
   
   .m_tready   (axis_in_tready          ),
   .m_tvalid   (axis_in_tvalid          ),
   .m_tdata    ({axis_in_tdata, ch_sel} ),
   .m_tkeep    (axis_in_tkeep           ), 
   .m_tlast    (axis_in_tlast           ), 
   .m_tid      (axis_in_tid             ), 
   .m_tdest    (axis_in_tdest           ), 
   .m_tuser    (axis_in_tuser           ) 
);

// Demux logic
logic [NUM_CH-1:0] tvalid, tready; 

always_comb begin
   tvalid = '0;
   axis_in_tready = 1'b1; 

   for (int i=0; i<NUM_CH; ++i) begin
      if (ch_sel == i[SEL_WIDTH-1:0]) begin
         tvalid[i] = axis_in_tvalid;
         axis_in_tready = axis_in_tready && tready[i];
      end
   end
end

// Output pipeline
genvar ig;
generate for (ig=0; ig<NUM_CH; ++ig) 
begin : demux_reg 
   ofs_fim_axis_register #(
      .MODE        (1), // 0: skid buffer 1: simple buffer 2: simple buffer (bubble) 3: bypass
      .TDATA_WIDTH (TDATA_WIDTH),
      .ENABLE_TUSER (1),
      .TID_WIDTH   (TID_WIDTH),
      .TDEST_WIDTH (TDEST_WIDTH),
      .TUSER_WIDTH (TUSER_WIDTH)
   ) axis_out_reg (
      .clk        (clk               ),
      .rst_n      (rst_n             ),
      .s_tready   (tready[ig]        ),
      .s_tvalid   (tvalid[ig]        ),
      .s_tdata    (axis_in_tdata     ),
      .s_tkeep    (axis_in_tkeep     ), 
      .s_tlast    (axis_in_tlast     ), 
      .s_tid      (axis_in_tid       ), 
      .s_tdest    (axis_in_tdest     ), 
      .s_tuser    (axis_in_tuser     ), 
      
      .m_tready   (source[ig].tready ),
      .m_tvalid   (source[ig].tvalid ),
      .m_tdata    (source[ig].tdata  ),
      .m_tkeep    (source[ig].tkeep  ), 
      .m_tlast    (source[ig].tlast  ), 
      .m_tid      (source[ig].tid    ), 
      .m_tdest    (source[ig].tdest  ), 
      .m_tuser    (source[ig].tuser  ) 
   );
end
endgenerate

endmodule : axis_demux

