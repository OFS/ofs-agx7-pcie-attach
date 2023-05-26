// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Module instantiates CDC strobes, synchronizers, etc. for FLR control
// signals between PCIE EP & CoreFIM. 
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"
import pcie_ss_axis_pkg::*;

module pcie_flr_resync #(
   parameter NUM_PF = 1,
   parameter NUM_VF = 1,
   parameter MAX_NUM_VF = 1
)(
   input  logic                    avl_clk,
   input  logic                    avl_rst_n,

   input  logic                    clk,
   input  logic                    rst_n,

   // PCIe interface
   input  logic [7:0]              flr_rcvd_pf,
   input  logic                    flr_rcvd_vf,
   input  logic [2:0]              flr_rcvd_pf_num,
   input  logic [10:0]             flr_rcvd_vf_num,
   output logic [7:0]              flr_completed_pf,
   output logic                    flr_completed_vf,
   output logic [2:0]              flr_completed_pf_num,
   output logic [10:0]             flr_completed_vf_num,

   // FIM interface
   output t_axis_pcie_flr          flr_req_if,
   input  t_axis_pcie_flr          flr_rsp_if
);

localparam PF_WIDTH = (NUM_PF > 1) ? $clog2(NUM_PF) : 1;
localparam VF_WIDTH = (NUM_VF > 1) ? $clog2(NUM_VF) : 1;

localparam FLR_REQ_FIFO_DEPTH = $clog2(MAX_NUM_VF + NUM_PF + 4);
localparam FLR_RSP_FIFO_DEPTH = FLR_REQ_FIFO_DEPTH;

logic [NUM_PF-1:0]   flr_rcvd_pf_in, flr_rcvd_pf_t1;
logic [PF_WIDTH-1:0] flr_rcvd_pf_enc_t1;
logic                flr_pf_valid, flr_pf_valid_t1;

logic                flr_rcvd_vf_t1;
logic [PF_WIDTH-1:0] flr_rcvd_pf_num_t1;
logic [VF_WIDTH-1:0] flr_rcvd_vf_num_t1;

t_axis_pcie_flr      flr_req_din, flr_req_dout;
logic                flr_req_valid;
logic                flr_req_ack;

t_axis_pcie_flr      flr_rsp_dout;
logic                flr_rsp_ack;
logic                flr_rsp_valid;

//----------------------------
// PF/VF FLR request CDC 
//----------------------------
fim_rdack_dcfifo #(
   .DATA_WIDTH            (T_AXIS_PCIE_FLR_WIDTH),
   .DEPTH_LOG2            (FLR_REQ_FIFO_DEPTH), 
   .ALMOST_FULL_THRESHOLD (4),  // assert almfull when empty slots <= 4
   .READ_ACLR_SYNC        ("ON") // add aclr synchronizer on read side
) flr_req_fifo (
   .wclk      (avl_clk),
   .rclk      (clk),
   .aclr      (~avl_rst_n),
   .wdata     (flr_req_din), 
   .wreq      (flr_req_din.tvalid),
   .rdack     (flr_req_ack),
   .rdata     (flr_req_dout),
   .rvalid    (flr_req_valid)
);

assign flr_rcvd_pf_in = flr_rcvd_pf[NUM_PF-1:0];
assign flr_pf_valid   = |(~flr_rcvd_pf_t1 & flr_rcvd_pf_in);
assign flr_req_ack    = flr_req_valid;

always_ff @(posedge avl_clk) begin
   flr_pf_valid_t1 <= flr_pf_valid;

   if (~avl_rst_n) begin
      flr_pf_valid_t1 <= 1'b0;
   end
end

always_ff @(posedge avl_clk) begin
   flr_rcvd_pf_t1     <= flr_rcvd_pf_in;
   flr_rcvd_pf_enc_t1 <= func_1hot_to_bin(flr_rcvd_pf_in);
   flr_rcvd_vf_t1     <= flr_rcvd_vf;
   flr_rcvd_pf_num_t1 <= flr_rcvd_pf_num[PF_WIDTH-1:0];
   flr_rcvd_vf_num_t1 <= flr_rcvd_vf_num[VF_WIDTH-1:0];
end

always_ff @(posedge avl_clk) begin
   flr_req_din.tvalid          <= (flr_pf_valid_t1 | flr_rcvd_vf_t1); 
   flr_req_din.tdata           <= '0;
   flr_req_din.tdata.pf        <= flr_pf_valid_t1 ? flr_rcvd_pf_enc_t1 : flr_rcvd_pf_num_t1;
   flr_req_din.tdata.vf        <= flr_rcvd_vf_num_t1;
   flr_req_din.tdata.vf_active <= flr_rcvd_vf_t1;

   if (~avl_rst_n) begin
      flr_req_din.tvalid <= 1'b0;
   end
end


always_ff @(posedge clk) begin
   flr_req_if        <= flr_req_dout;
   flr_req_if.tvalid <= flr_req_valid;

   if (~rst_n) begin
      flr_req_if.tvalid <= 1'b0;
   end
end

//----------------------------
// PF/VF FLR response CDC 
//----------------------------
fim_rdack_dcfifo #(
   .DATA_WIDTH            (T_AXIS_PCIE_FLR_WIDTH),
   .DEPTH_LOG2            (FLR_RSP_FIFO_DEPTH), 
   .ALMOST_FULL_THRESHOLD (4),  // assert almfull when empty slots <= 4
   .WRITE_ACLR_SYNC       ("ON") // add aclr synchronizer on write side
) flr_rsp_fifo (
   .wclk      (clk),
   .rclk      (avl_clk),
   .aclr      (~avl_rst_n),
   .wdata     (flr_rsp_if), 
   .wreq      (flr_rsp_if.tvalid),
   .rdack     (flr_rsp_ack),
   .rdata     (flr_rsp_dout),
   .rvalid    (flr_rsp_valid)
);

assign flr_rsp_ack = flr_rsp_valid;

always_ff @(posedge avl_clk) begin
   flr_completed_pf    <= '0;
   flr_completed_vf    <= 1'b0;

   if (flr_rsp_valid && ~flr_rsp_dout.tdata.vf_active) begin
      flr_completed_pf <= func_bin_to_1hot(flr_rsp_dout.tdata.pf);
   end

   if (flr_rsp_valid && flr_rsp_dout.tdata.vf_active) begin
      flr_completed_vf <= 1'b1;
   end

   flr_completed_pf_num <= flr_rsp_dout.tdata.pf;
   flr_completed_vf_num <= flr_rsp_dout.tdata.vf;
end

//----------------------------
// Functions 
//----------------------------
function automatic logic [PF_WIDTH-1:0] func_1hot_to_bin (
   input logic [7:0] onehot
);
   func_1hot_to_bin = '0;
   
   for (int i=0; i<NUM_PF; ++i) begin
      if (onehot[i]) func_1hot_to_bin = i[PF_WIDTH-1:0];
   end
endfunction

function automatic logic [7:0] func_bin_to_1hot (
   input logic [PF_WIDTH-1:0] bin
);
   func_bin_to_1hot      = '0;
   func_bin_to_1hot[bin] = 1'b1;
endfunction

endmodule : pcie_flr_resync
