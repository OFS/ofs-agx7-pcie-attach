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

   // ******************************************************************************************
   // AFU Register Address
   // ******************************************************************************************
   parameter AFU_DFH_ADDR                        = 32'h40000;
   parameter AFU_ID_L_ADDR                       = 32'h40008;
   parameter AFU_ID_H_ADDR                       = 32'h40010;
   parameter AFU_PORT_SEL_ADDR                   = 32'h40040;
   parameter AFU_SCRATCH_ADDR                    = 32'h40048;
   parameter AFU_UNUSED_ADDR                     = 32'h40058;

   // ******************************************************************************************
   // AFU Register Default Values
   // ******************************************************************************************
   parameter AFU_DFH_VAL                        = 64'h1000010000001000;
   parameter AFU_ID_L_VAL                       = 64'hBB370242AC130002;
   parameter AFU_ID_H_VAL                       = 64'h823C334C98BF11EA;
   parameter AFU_SCRATCH_VAL                    = 64'h0000000045324511;

   // ******************************************************************************************
   // HSSI SS IP Register Address
   // ******************************************************************************************
   parameter HSSI_DFH_LO_ADDR               = 32'h14000;
   parameter HSSI_DFH_HI_ADDR               = HSSI_DFH_LO_ADDR + 32'h04;
   parameter HSSI_FEATURE_GUID_L_0_ADDR     = HSSI_DFH_LO_ADDR + 32'h08;
   parameter HSSI_FEATURE_GUID_L_1_ADDR     = HSSI_DFH_LO_ADDR + 32'h0C;
   parameter HSSI_FEATURE_GUID_H_0_ADDR     = HSSI_DFH_LO_ADDR + 32'h10;
   parameter HSSI_FEATURE_GUID_H_1_ADDR     = HSSI_DFH_LO_ADDR + 32'h14;
   parameter HSSI_FEATURE_CSR_ADD_LO_ADDR   = HSSI_DFH_LO_ADDR + 32'h18;
   parameter HSSI_FEATURE_CSR_ADD_HI_ADDR   = HSSI_DFH_LO_ADDR + 32'h1C;
   parameter HSSI_FEATURE_CSR_SIZE_LO_ADDR  = HSSI_DFH_LO_ADDR + 32'h20;
   parameter HSSI_FEATURE_CSR_SIZE_HI_ADDR  = HSSI_DFH_LO_ADDR + 32'h24;

   parameter HSSI_VER_ADDR                  = HSSI_DFH_LO_ADDR + 32'h60;
   parameter HSSI_FEATURE_ADDR              = HSSI_DFH_LO_ADDR + 32'h64;
   parameter HSSI_PORT0_ATTR_ADDR           = HSSI_DFH_LO_ADDR + 32'h68;
   parameter HSSI_PORT1_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'h4;
   parameter HSSI_PORT2_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'h8;
   parameter HSSI_PORT3_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'hC;
   parameter HSSI_PORT4_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'h10;
   parameter HSSI_PORT5_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'h14;
   parameter HSSI_PORT6_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'h18;
   parameter HSSI_PORT7_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'h1C;
   parameter HSSI_PORT8_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'h20;
   parameter HSSI_PORT9_ATTR_ADDR           = HSSI_PORT0_ATTR_ADDR + 32'h24;
   parameter HSSI_PORT10_ATTR_ADDR          = HSSI_PORT0_ATTR_ADDR + 32'h28;
   parameter HSSI_PORT11_ATTR_ADDR          = HSSI_PORT0_ATTR_ADDR + 32'h2C;
   parameter HSSI_PORT12_ATTR_ADDR          = HSSI_PORT0_ATTR_ADDR + 32'h30;
   parameter HSSI_PORT13_ATTR_ADDR          = HSSI_PORT0_ATTR_ADDR + 32'h34;
   parameter HSSI_PORT14_ATTR_ADDR          = HSSI_PORT0_ATTR_ADDR + 32'h38;
   parameter HSSI_PORT15_ATTR_ADDR          = HSSI_PORT0_ATTR_ADDR + 32'h3C;
   parameter HSSI_PORT0_STATUS_ADDR         = HSSI_DFH_LO_ADDR + 32'hC0;
   parameter HSSI_PORT1_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'h4;
   parameter HSSI_PORT2_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'h8;
   parameter HSSI_PORT3_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'hC;
   parameter HSSI_PORT4_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'h10;
   parameter HSSI_PORT5_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'h14;
   parameter HSSI_PORT6_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'h18;
   parameter HSSI_PORT7_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'h1C;
   parameter HSSI_PORT8_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'h20;
   parameter HSSI_PORT9_STATUS_ADDR         = HSSI_PORT0_STATUS_ADDR + 32'h24;
   parameter HSSI_PORT10_STATUS_ADDR        = HSSI_PORT0_STATUS_ADDR + 32'h28;
   parameter HSSI_PORT11_STATUS_ADDR        = HSSI_PORT0_STATUS_ADDR + 32'h2C;
   parameter HSSI_PORT12_STATUS_ADDR        = HSSI_PORT0_STATUS_ADDR + 32'h30;
   parameter HSSI_PORT13_STATUS_ADDR        = HSSI_PORT0_STATUS_ADDR + 32'h34;
   parameter HSSI_PORT14_STATUS_ADDR        = HSSI_PORT0_STATUS_ADDR + 32'h38;
   parameter HSSI_PORT15_STATUS_ADDR        = HSSI_PORT0_STATUS_ADDR + 32'h3C;
   parameter HSSI_SS_UNUSED_ADDR            = HSSI_DFH_LO_ADDR + 32'h1FF;
   parameter HSSI_SS_UNASSIGNED_ADDR        = HSSI_DFH_LO_ADDR + 32'h200;
   // ******************************************************************************************
   // HSSI Wrapper Register Address
   // ******************************************************************************************
   parameter HSSI_WRAP_RST_ADDR             = 32'h14800;
   parameter HSSI_WRAP_ACK_ADDR             = HSSI_WRAP_RST_ADDR + 32'h8;
   parameter HSSI_WRAP_COLD_RST_ACK_ADDR    = HSSI_WRAP_RST_ADDR + 32'h10;
   parameter HSSI_WRAP_STATUS_ADDR          = HSSI_WRAP_RST_ADDR + 32'h18;
   parameter HSSI_WRAP_SCRATCH_ADDR         = HSSI_WRAP_RST_ADDR + 32'h20;
   parameter HSSI_WRAP_UNUSED_ADDR          = HSSI_WRAP_RST_ADDR + 32'h248;

   // ******************************************************************************************
   // HSSI Wrapper Register Values
   // ******************************************************************************************
   parameter HSSI_WRAP_STATUS_VAL           = 64'h000000FF00FF00FF;
   // ******************************************************************************************
   // HSSI SS IP Register Values
   // ******************************************************************************************
   parameter HSSI_DFH_LO_VAL                = 32'h1000_2015;
   parameter HSSI_DFH_HI_VAL                = 32'h3000_0000;
   parameter HSSI_FEATURE_GUID_L_0_VAL      = 32'h18418b9d;
   parameter HSSI_FEATURE_GUID_L_1_VAL      = 32'h99a078ad;
   parameter HSSI_FEATURE_GUID_H_0_VAL      = 32'hd9db4a9b;
   parameter HSSI_FEATURE_GUID_H_1_VAL      = 32'h4118a7cb;
   parameter HSSI_FEATURE_CSR_ADD_LO_VAL    = 32'hC0;
   parameter HSSI_FEATURE_CSR_ADD_HI_VAL    = 32'h00;
   parameter HSSI_FEATURE_CSR_SIZE_LO_VAL   = 32'h10000;
   parameter HSSI_FEATURE_CSR_SIZE_HI_VAL   = 32'h44;
   parameter HSSI_VER_VAL                   = 32'h0001_0000;
   parameter HSSI_FEATURE_VAL               = 32'h0000_3FD1;
   parameter HSSI_PORT0_ATTR_VAL            = 32'h0024_0415;
   parameter HSSI_PORT1_ATTR_VAL            = 32'h0024_0415;
   parameter HSSI_PORT2_ATTR_VAL            = 32'h0024_0415;
   parameter HSSI_PORT3_ATTR_VAL            = 32'h0024_0415;
   parameter HSSI_PORT4_ATTR_VAL            = 32'h0024_0415;
   parameter HSSI_PORT5_ATTR_VAL            = 32'h0024_0415;
   parameter HSSI_PORT6_ATTR_VAL            = 32'h0024_0415;
   parameter HSSI_PORT7_ATTR_VAL            = 32'h0024_0415;
   parameter HSSI_PORT8_ATTR_VAL            = 32'h0000_0000;
   parameter HSSI_PORT9_ATTR_VAL            = 32'h0000_0000;
   parameter HSSI_PORT10_ATTR_VAL           = 32'h0000_0000;
   parameter HSSI_PORT11_ATTR_VAL           = 32'h0000_0000;
   parameter HSSI_PORT12_ATTR_VAL           = 32'h0000_0000;
   parameter HSSI_PORT13_ATTR_VAL           = 32'h0000_0000;
   parameter HSSI_PORT14_ATTR_VAL           = 32'h0000_0000;
   parameter HSSI_PORT15_ATTR_VAL           = 32'h0000_0000;
   parameter HSSI_PORT_STATUS_VAL           = 32'h0000_0000;
   
   // ******************************************************************************************
   // Traffic Controller Register Address
   // ******************************************************************************************
   parameter TG_NUM_PKT_ADDR                = 32'h00;
   parameter TG_PKT_LEN_TYPE_ADDR           = 32'h01;
   parameter TG_DATA_PATTERN_ADDR           = 32'h02;
   parameter TG_START_XFR_ADDR              = 32'h03;
   parameter TG_STOP_XFR_ADDR               = 32'h04;
   parameter TG_SRC_MAC_L_ADDR              = 32'h05;
   parameter TG_SRC_MAC_H_ADDR              = 32'h06;
   parameter TG_DST_MAC_L_ADDR              = 32'h07;
   parameter TG_DST_MAC_H_ADDR              = 32'h08;
   parameter TG_PKT_XFRD_ADDR               = 32'h09;
   parameter TG_RANDOM_SEED0_ADDR           = 32'h0A;
   parameter TG_RANDOM_SEED1_ADDR           = 32'h0B;
   parameter TG_RANDOM_SEED2_ADDR           = 32'h0C;
   parameter TG_PKT_LEN_ADDR                = 32'h0D;
   
   parameter TM_NUM_PKT_ADDR                = 32'h100;
   parameter TM_PKT_GOOD_ADDR               = 32'h101;
   parameter TM_PKT_BAD_ADDR                = 32'h102;
   parameter TM_BYTE_CNT0_ADDR              = 32'h103;
   parameter TM_BYTE_CNT1_ADDR              = 32'h104;
   parameter TM_AVST_RX_ERR_ADDR            = 32'h107;
   
   parameter LOOPBACK_EN_ADDR               = 32'h200;

   // ******************************************************************************************
   // Mailbox Register CMD Space
   // ******************************************************************************************
   // Mailbox address
   parameter TRAFFIC_CTRL_CMD_ADDR          = 32'h40030;
   // OFFSET address in mailbox
   parameter MB_ADDRESS_OFFSET              = 32'h4;
   parameter MB_RDDATA_OFFSET               = 32'h8;
   parameter MB_WRDATA_OFFSET               = 32'hC;
   // CMD
   parameter MB_NOOP                        = 32'h0;
   parameter MB_RD                          = 32'h1;
   parameter MB_WR                          = 32'h2;

   localparam HEH_PF             = 0; 
   localparam HEH_VF             = 1; 
   localparam HEH_VA             = 1; 


endpackage

`endif
