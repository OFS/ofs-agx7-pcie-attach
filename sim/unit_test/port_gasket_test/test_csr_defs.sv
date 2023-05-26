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
   int RD_TIMEOUT = 10;
   int GBS_SIZE = 16;
   // Port info
   localparam BAR = 3'h0;
   localparam VF_ACTIVE = 1'h0;
   localparam VF = 0;
   localparam PF = 0;

   // Registers
   localparam PG_PR_DFH          = 32'h70000;
   localparam PG_PR_CTRL         = PG_PR_DFH + 32'h8;
      // PG_PR_CTRL bits
      localparam PRReset_idx     = 0;
      localparam PRReset_ack_idx = 4;
      localparam PRStartRequest_idx  = 12;
      localparam PRDataPushComplete_idx = 13;
   
   localparam PG_PR_STATUS       = PG_PR_DFH + 32'h10;
      localparam PRStatus_idx    = 16; 

   localparam PG_PR_DATA         = PG_PR_DFH + 32'h18;
   localparam PG_PR_ERROR        = PG_PR_DFH + 32'h20;

   localparam PORT_DFH           = 32'h71000;
   localparam PORT_CONTROL       = PORT_DFH + 32'h38;
   
   localparam USER_CLOCK_DFH     = 32'h72000;
   localparam USER_CLK_FREQ_CMD0 = USER_CLOCK_DFH + 32'h8;
      localparam UsrClkCmdMmRst_idx = 52;
      localparam UsrClkCmdWr_idx = 44;
      localparam Seq_idx = 48;
      localparam CmdAdr_idx = 32;
   localparam USER_CLK_FREQ_CMD1 = USER_CLOCK_DFH + 32'h10;

endpackage

`endif
