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
`include "ofs_ip_cfg_db.vh"

package test_csr_defs;
   int RD_TIMEOUT = 10;
   int GBS_SIZE = 16;
   // Port info
   localparam BAR = 3'h0;
   localparam VF_ACTIVE = 1'h0;
   localparam VF = 0;
   localparam PF = 0;

   localparam NUMBER_OF_LINKS = `OFS_FIM_IP_CFG_PCIE_SS_NUM_LINKS;

   // Registers
   localparam USER_CLK_DFH             = 32'h72000;
   localparam USER_CLK_FREQ_CMD0       = USER_CLK_DFH + 32'h8;
   localparam USER_CLK_FREQ_CMD1       = USER_CLK_DFH + 32'h10;

   localparam USER_CLK_FREQ_STS0       = USER_CLK_DFH + 32'h18;
   localparam USER_CLK_FREQ_STS1       = USER_CLK_DFH + 32'h20;

   localparam CMD0_BIT_DATA            = 0;     // Data start bit
   localparam CMD0_BIT_DATA_LEN        = 32;    // Data length
   localparam CMD0_BIT_ADDR            = 32;    // Address start bit
   localparam CMD0_BIT_ADDR_LEN        = 10;    // Address length
   localparam CMD0_BIT_WRITE           = 44;    // Write request
   localparam CMD0_BIT_SEQ_NUM         = 48;    // Sequence number start bit (2 bit field)
   localparam CMD0_BIT_DATA_MASK       = 51;    // Mask for future write data
   localparam CMD0_BIT_AVMM_RST_N      = 52;    // Avalon interface reset_n
   localparam CMD0_BIT_MGMT_RESET      = 56;
   localparam CMD0_BIT_IOPLL_RESET     = 57;
   localparam STS0_BIT_PLL_LOCKED      = 60;    // Is PLL locked

   localparam CMD1_BIT_SEL_CLK         = 32;    // Select clock (1 bit)

   // Revision 1 (Agilex 7) and 0 (S10) registers exposed by OFS
   localparam PLL_R1_CAL_REQ_ADDR      = 10'h149;
   localparam PLL_R1_CAL_REQ_DATA      = 9'h42;
   localparam PLL_R1_CAL_EN_ADDR       = 10'h14a;
   localparam PLL_R1_CAL_EN_DATA       = 9'h3;
   localparam PLL_R1_M_ADDR            = 10'h104;
   localparam PLL_R1_N_ADDR            = 10'h100;
   localparam PLL_R1_C0_ADDR           = 10'h11b;
   localparam PLL_R1_C1_ADDR           = 10'h11f;
   localparam PLL_R1_LF_ADDR           = 10'h10a;
   localparam PLL_R1_CP2_ADDR          = 10'h10d;

   localparam PLL_AGX5_EN_REGS_ADDR    = 'h10;
   localparam PLL_AGX5_CAL_STATUS_ADDR = 'h58;
   localparam PLL_AGX5_CAL_OVRD_ADDR   = 'h48;
   localparam PLL_AGX5_CAL_REQ_ADDR    = 'h88;
   localparam PLL_AGX5_MN_ADDR         = 'h40;
   localparam PLL_AGX5_C0_ADDR         = 'h5c;
   localparam PLL_AGX5_C1_ADDR         = 'h60;
   localparam PLL_AGX5_CP_ADDR         = 'h44;
   localparam PLL_AGX5_RESET_ADDR      = 'h80;

endpackage

`endif
