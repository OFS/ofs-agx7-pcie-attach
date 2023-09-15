// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  Test parameters 
//
//-----------------------------------------------------------------------------
`ifndef __TEST_PARAM_DEFS__
`define __TEST_PARAM_DEFS__

package test_param_defs;

   // ******************************************************************************************
   // Traffic Controller Register Values
   // ******************************************************************************************
   parameter TG_NUM_PKT_VAL                = 32'h20;  // Number of packet to be transfered
   parameter TG_PKT_LEN_TYPE_VAL           = 32'h0000;  // 1'b0: Fixed Length; 1'b1: Random length 
   parameter TG_DATA_PATTERN_VAL           = 32'h0000;  // 1'b0: Incremental pattern; 1'b1: Random pattern
   parameter TG_PKT_LEN_VAL                = 32'h42;  // Length of each packet to be transfered
   
endpackage

`endif
