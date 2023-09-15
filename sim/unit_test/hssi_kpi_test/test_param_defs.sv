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
   parameter TG_NUM_PKT_VAL                = 32'h80;    // Number of packet to be transfered
   parameter TG_PKT_LEN_TYPE_VAL           = 32'h0000;  // 1'b0: Fixed Length; 1'b1: Random length 
   parameter TG_DATA_PATTERN_VAL           = 32'h0000;  // 1'b0: Incremental pattern; 1'b1: Random pattern
   parameter TG_PKT_LEN_VAL                = 32'h84;    // Length of each packet to be transfered
   
    // ******************************************************************************************
    // Parameters for KPI calculation
    // ******************************************************************************************
    parameter USER_CLK_FREQ_MHZ           = 402.83203125; // User clock @ HE-HSSI in MHz
    parameter SAMPLE_PERIOD_NS            = (1000 / USER_CLK_FREQ_MHZ); // sample period in nanoseconds
    parameter FCS_SIZE_BYTE               = 4;
    parameter PREAMBLE_SIZE_BYTE          = 7;
    parameter SFD_SIZE_BYTE               = 1;
    parameter IPG_SIZE_BYTE               = 12;
    parameter OVERHEAD_SIZE_BYTE          = FCS_SIZE_BYTE + PREAMBLE_SIZE_BYTE + SFD_SIZE_BYTE + IPG_SIZE_BYTE;  
    parameter ETH_SPEED                   = 25; // in GHz
    `ifdef DISABLE_HE_HSSI_CRC
    parameter DATA_PKT_SIZE               = TG_PKT_LEN_VAL - 8.0;
    `else
    parameter DATA_PKT_SIZE               = TG_PKT_LEN_VAL - 4.0;
    `endif
    parameter TOTAL_DATA_SIZE_BIT         = DATA_PKT_SIZE * TG_NUM_PKT_VAL * 8;
    parameter THEORETICAL_THROUGHPUT      = (DATA_PKT_SIZE / (DATA_PKT_SIZE + OVERHEAD_SIZE_BYTE));
    parameter THEORETICAL_THROUGHPUT_GBPS = THEORETICAL_THROUGHPUT * ETH_SPEED;
endpackage

`endif
