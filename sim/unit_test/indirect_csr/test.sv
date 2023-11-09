// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Test module 
//
//-----------------------------------------------------------------------------

module test #(
   parameter CMD_W = 16,
   parameter AW    = 19,
   parameter DW    = 64
)(
    // Clocks and Reset
    input  logic                            i_csr_clk,             
    input  logic                            i_csr_rst_n,           

    // Indirect CSR Interface
    input  logic [CMD_W-1:0]                i_csr_cmd,              // Indirect CSR command
    input  logic [AW-1:0]                   i_csr_addr,             // Indirect CSR address
    input  logic [DW-1:0]                   i_csr_writedata,        // Indirect CSR write data
    output logic [DW-1:0]                   o_csr_readdata,         // Indirect CSR read data
    output logic                            o_csr_ack,              // Indirect CSR acknowledgment
    output logic [1:0]                      o_csr_rresp,            // Indirect CSR read response
    output logic [1:0]                      o_csr_bresp             // Indirect CSR write response
);

ofs_fim_axi_lite_if #(.AWADDR_WIDTH(AW), .ARADDR_WIDTH(AW)) csr_lite_if();

axi4lite_indirect_csr_if #(
    .CMD_W         (16),   // Indirect CSR command width
    .CSR_ADDR_W    (19),   // Indirect CSR address width
    .AXI_ADDR_W    (19),   // AXI address width
    .DATA_W        (64)    // Data width
) axi4lite_indirect_csr_if (
   .i_csr_clk       (i_csr_clk),
   .i_csr_rst_n     (i_csr_rst_n),

   .i_csr_cmd       (i_csr_cmd),
   .i_csr_addr      (i_csr_addr),
   .i_csr_writedata (i_csr_writedata),
   .o_csr_readdata  (o_csr_readdata),
   .o_csr_ack       (o_csr_ack),
   .o_csr_rresp     (o_csr_rresp),
   .o_csr_bresp     (o_csr_bresp),

   .csr_lite_if     (csr_lite_if)
);

dummy_csr #(
   .FEAT_ID          (12'h020),
   .FEAT_VER         (4'h0),
   .NEXT_DFH_OFFSET  (24'h1000),
   .END_OF_LIST      (1'b0)  
) dummy_csr (
   .clk         (i_csr_clk),
   .rst_n       (i_csr_rst_n),
   .csr_lite_if (csr_lite_if)
);

endmodule

