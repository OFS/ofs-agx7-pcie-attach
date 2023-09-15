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
   localparam QSFP0_DFH             = 32'h12000;
   localparam QSFP1_DFH             = 32'h13000;
   //-----------------------
   // Common CSR OFFSETs
   //-----------------------
   localparam CTRL_OFFSET           = 32'h20; // [4:0] -> RW
   localparam STATUS_OFFSET         = 32'h28; // [7:0] -> RO
   localparam SCRATCHPAD_OFFSET     = 32'h30; // 64b RW
   //-----------------------
   // I2C CSRs
   //-----------------------
   localparam I2C_BASE_OFFSET       = 32'h40;
   // I2C Controller Register address offset wrt I2C base
   localparam TFR_CMD               = 32'h00; // [9:0]  WO
   localparam RX_DATA               = 32'h04; // [7:0]  RO
   localparam CTRL                  = 32'h08; // [5:0]  RW
   localparam ISER                  = 32'h0C; // [4:0]  RW
   localparam ISR                   = 32'h10; // [4:0]  RO
   localparam STATUS                = 32'h14; // [0]    RO
   localparam TFR_CMD_FIFO_LVL      = 32'h18; // [4:0]  RO
   localparam RX_DATA_FIFO_LVL      = 32'h1C; // [4:0]  RO
   localparam SCL_LOW               = 32'h20; // [15:0] RW
   localparam SCL_HIGH              = 32'h24; // [15:0] RW
   localparam SCL_HOLD              = 32'h28; // [15:0] RW
   
   //-----------------------
   // Expected Values
   //-----------------------
   localparam QSFP0_DFH_VALUE     = 64'h3000000010000013; 
   localparam QSFP1_DFH_VALUE     = 64'h3000000010000013; 
      
   
endpackage

`endif
