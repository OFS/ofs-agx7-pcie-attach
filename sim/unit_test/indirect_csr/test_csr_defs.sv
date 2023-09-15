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
   localparam DFH           = 32'h0;
   localparam SCRATCHPAD    = DFH + 32'h8;
   localparam STAT          = DFH + 32'h10;
   localparam UNUSED_OFFSET = DFH + 32'hff8;

   localparam DFH_VALUE     = 64'h3_00000_001000_0020;
endpackage

`endif
