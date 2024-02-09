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
   localparam DFH                = 64'h0;
   localparam ID_L               = 64'h8;
   localparam ID_H               = 64'h10;
   localparam SCRATCHPAD0        = 64'h100;
   localparam SCRATCHPAD1        = 64'h104;
   localparam SCRATCHPAD2        = 64'h108;
   localparam DSM_BASEL          = 64'h110;
   localparam DSM_BASEH          = 64'h114;
   localparam SRC_ADDR           = 64'h120;
   localparam DST_ADDR           = 64'h128;
   localparam NUM_LINES          = 64'h130;
   localparam CTL                = 64'h138;
   localparam CFG                = 64'h140;
   localparam INACT_THRESH       = 64'h148;
   localparam INTERRUPT0         = 64'h150;
   localparam SWTEST_MSG         = 64'h158;
   localparam STATUS0            = 64'h160;
   localparam STATUS1            = 64'h168;
   localparam ERROR              = 64'h170;
   localparam STRIDE             = 64'h178;

endpackage

`endif
