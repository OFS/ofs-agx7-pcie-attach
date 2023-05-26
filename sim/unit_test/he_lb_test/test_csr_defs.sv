// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  CSR address 
//
//-----------------------------------------------------------------------------
`ifndef __TEST_CSR_DEFS__
`define __TEST_CSR_DEFS__

package test_csr_defs;
   localparam DFH                = 32'h0;
   localparam ID_L               = 32'h8;
   localparam ID_H               = 32'h10;
   localparam SCRATCHPAD0        = 32'h100;
   localparam SCRATCHPAD1        = 32'h104;
   localparam SCRATCHPAD2        = 32'h108;
   localparam DSM_BASEL          = 32'h110;
   localparam DSM_BASEH          = 32'h114;
   localparam SRC_ADDR           = 32'h120;
   localparam DST_ADDR           = 32'h128;
   localparam NUM_LINES          = 32'h130;
   localparam CTL                = 32'h138;
   localparam CFG                = 32'h140;
   localparam INACT_THRESH       = 32'h148;
   localparam INTERRUPT0         = 32'h150;
   localparam SWTEST_MSG         = 32'h158;
   localparam STATUS0            = 32'h160;
   localparam STATUS1            = 32'h168;
   localparam ERROR              = 32'h170;
   localparam STRIDE             = 32'h178;

endpackage

`endif
