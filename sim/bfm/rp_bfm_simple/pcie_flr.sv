// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// PCIe FLR BFM 
//
//-----------------------------------------------------------------------------
`timescale 1ps / 1ps



module pcie_flr #(
   parameter MAX_NUM_VF = (1 << 11)
)(
   input  logic   clk,
   input  logic   rst_n,

   input  logic                i_assert_flr,

   input  logic                i_vf_active,
   input  logic [2:0]          i_pf_num,
   input  logic [10:0]         i_vf_num,

   input  logic [7:0]          i_flr_pf_done,
   output logic [7:0]          o_flr_pf_active,

   output logic                o_flr_rcvd_vf,
   output logic [2:0]          o_flr_rcvd_pf_num,
   output logic [10:0]         o_flr_rcvd_vf_num,
   output logic [7:0][MAX_NUM_VF-1:0] o_flr_vf_active,

   input  logic                i_flr_completed_vf,
   input  logic [2:0]          i_flr_completed_pf_num,
   input  logic [10:0]         i_flr_completed_vf_num
);


import ofs_fim_pcie_pkg::*;

logic [7:0]                  flr_pf_active_q;
logic [7:0][MAX_NUM_VF-1:0]  flr_vf_active_q;

logic [7:0]  flr_pf_done;
logic        flr_rcvd_vf;
logic [2:0]  flr_rcvd_pf_num;
logic [10:0] flr_rcvd_vf_num;
logic        flr_completed_vf;
logic [2:0]  flr_completed_pf_num;
logic [10:0] flr_completed_vf_num;

assign o_flr_rcvd_vf        = flr_rcvd_vf;
assign o_flr_rcvd_pf_num    = flr_rcvd_pf_num;
assign o_flr_rcvd_vf_num    = flr_rcvd_vf_num;

assign o_flr_pf_active      = flr_pf_active_q;
assign o_flr_vf_active      = flr_vf_active_q;

assign flr_pf_done          = i_flr_pf_done;
assign flr_completed_vf     = i_flr_completed_vf;
assign flr_completed_pf_num = i_flr_completed_pf_num;
assign flr_completed_vf_num = i_flr_completed_vf_num;

always_ff @(posedge clk) begin
   if (~rst_n) begin
      flr_pf_active_q   <= '0;

      flr_rcvd_vf       <= 1'b0;
      flr_rcvd_pf_num   <= '0;
      flr_rcvd_vf_num   <= '0;
      flr_vf_active_q   <= '0;
   end else begin
      flr_rcvd_vf     <= 1'b0;
      flr_rcvd_pf_num <= i_pf_num;
      flr_rcvd_vf_num <= i_vf_num;

      if (i_assert_flr) begin 
         if (i_vf_active) begin
            $display("[%t] Info: Assert FLR on VF (PF=%0d, VF=%0d) for 1 cycle.", $time, flr_rcvd_pf_num, flr_rcvd_vf_num);
            flr_rcvd_vf                         <= 1'b1;
            flr_vf_active_q[i_pf_num][i_vf_num] <= 1'b1;
         end else begin
            $display("[%t] Info: Assert FLR on PF %0d.", $time, i_pf_num);
            flr_pf_active_q[i_pf_num] <= 1'b1;
         end
      end

      for (int i=0; i<8; ++i) begin
         if (flr_pf_active_q[i] && (flr_pf_done[i] === 1'b1)) begin
            flr_pf_active_q[i] <= 1'b0;
            $display("[%t] Info: FLR ack received, deasserting FLR on PF %0d.", $time, i);
         end
      end

      if (flr_completed_vf) begin
         if (flr_vf_active_q[flr_completed_pf_num][flr_completed_vf_num] === 1'b1) begin
            flr_vf_active_q[flr_completed_pf_num][flr_completed_vf_num] <= 1'b0;
            $display("[%t] Info: FLR ack received, deasserting FLR on VF (VF=%0d, PF=%0d).", $time, flr_completed_vf_num, flr_completed_pf_num); 
         end
      end 
   end
end

endmodule

`default_nettype wire
