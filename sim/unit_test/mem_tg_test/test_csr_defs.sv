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
   // DFH logic
   // ******************************************************************************************
   typedef struct packed {
      logic [3:0]  feat_type;
      logic [7:0]  rsvd1;
      logic [3:0]  afu_minor_ver;
      logic [6:0]  rsvd0;
      logic        eol;
      logic [23:0] nxt_dfh_offset;
      logic [3:0]  afu_major_ver;
      logic [11:0] feat_id;
   } t_dfh;

   localparam DFH_START_OFFSET = 64'h0; 
   localparam EMIF_DFH_FEAT_ID = 12'h9; 

   // ******************************************************************************************
   // EMIF feature registers
   // ******************************************************************************************
   localparam EMIF_STATUS_OFFSET     = 64'h8;
   localparam EMIF_CAPABILITY_OFFSET = EMIF_STATUS_OFFSET + 64'h8;
   localparam EMIF_DFH_VAL           = 64'h3_00000_00B000_1009;

   // ******************************************************************************************
   // MEM TG AFU registers
   // ******************************************************************************************
   localparam MEM_TG_PF  = 0;
   localparam MEM_TG_VF  = 2;
   localparam MEM_TG_VFA = 1; 

   parameter AFU_DFH_ADDR                        = 64'h00000;
   parameter AFU_ID_L_ADDR                       = 64'h00008;
   parameter AFU_ID_H_ADDR                       = 64'h00010;
   parameter AFU_NEXT_ADDR                       = 64'h00018;
   parameter AFU_RSVD_ADDR                       = 64'h00020;
   parameter AFU_SCRATCH_ADDR                    = 64'h00028;
   parameter MEM_TG_CTRL_ADDR                    = 64'h00030;
   parameter MEM_TG_STAT_ADDR                    = 64'h00038;

   // Perf counters
   parameter MEM_TG_CLOCKS_OFFSET                = 64'h00050;


   parameter MEM_TG_CFG_OFFSET = 64'h1000;
   // ******************************************************************************************
   // TG Address Map 
   // ******************************************************************************************
   // Traffic generator version
   localparam TG_VERSION = {10'h0,2'b00};
   // Start
   localparam TG_START = {10'h1,2'b00};
   // Loop count
   localparam TG_LOOP_COUNT = {10'h2,2'b00};
   // Write count
   localparam TG_WRITE_COUNT = {10'h3,2'b00};
   // Read count
   localparam TG_READ_COUNT = {10'h4,2'b00};
   // Write repeat count
   localparam TG_WRITE_REPEAT_COUNT = {10'h5,2'b00};
   // Read repeat count
   localparam TG_READ_REPEAT_COUNT = {10'h6,2'b00};
   // Burst length
   localparam TG_BURST_LENGTH = {10'h7,2'b00};
   // Group-wise Selective Clear
   localparam TG_CLEAR = {10'h8,2'b00};
   // Idle count within a loop
   localparam TG_RW_GEN_IDLE_COUNT = {10'hE,2'b00};
   // Idle count between consecutive loops
   localparam TG_RW_GEN_LOOP_IDLE_COUNT = {10'hF,2'b00};
   // Sequential start address (Write) (Lower 32 bits)
   localparam TG_SEQ_START_ADDR_WR_L = {10'h10,2'b00};
   // Sequential start address (Write) (Upper 32 bits)
   localparam TG_SEQ_START_ADDR_WR_H = {10'h11,2'b00};
   // Address mode
   localparam TG_ADDR_MODE_WR = {10'h12,2'b00};
   // Random sequential number of addresses (Write)
   localparam TG_RAND_SEQ_ADDRS_WR = {10'h13,2'b00};
   // Return to start address
   localparam TG_RETURN_TO_START_ADDR = {10'h14,2'b00};
   // Sequential address increment
   localparam TG_SEQ_ADDR_INCR = {10'h1D,2'b00};
   // Sequential start address (Read) (Lower 32 bits)
   localparam TG_SEQ_START_ADDR_RD_L = {10'h1E,2'b00};
   // Sequential start address (Read) (Upper 32 bits)
   localparam TG_SEQ_START_ADDR_RD_H = {10'h1F,2'b00};
   // Address mode (Read)
   localparam TG_ADDR_MODE_RD = {10'h20,2'b00};
   // Random sequential number of addresses (Read)
   localparam TG_RAND_SEQ_ADDRS_RD = {10'h21,2'b00};
   // Pass
   localparam TG_PASS = {10'h22,2'b00};
   // Fail
   localparam TG_FAIL = {10'h23,2'b00};
   // Failure count (lower 32 bits)
   localparam TG_FAIL_COUNT_L = {10'h24,2'b00};
   // Failure count (upper 32 bits)
   localparam TG_FAIL_COUNT_H = {10'h25,2'b00};
   // First failure address (lower 32 bits)
   localparam TG_FIRST_FAIL_ADDR_L = {10'h26,2'b00};
   // First failure address (upper 32 bits)
   localparam TG_FIRST_FAIL_ADDR_H = {10'h27,2'b00};
   // Total read count (lower 32 bits)
   localparam TG_TOTAL_READ_COUNT_L = {10'h28,2'b00};
   // Total read count (upper 32 bits)
   localparam TG_TOTAL_READ_COUNT_H = {10'h29,2'b00};
   // Test complete status register
   localparam TG_TEST_COMPLETE = {10'h2A,2'b00};
   // Invert Byte Enable Write
   localparam TG_INVERT_BYTEEN = {10'h2B,2'b00};
   // Restart Default Traffic
   localparam TG_RESTART_DEFAULT_TRAFFIC = {10'h2C,2'b00};
   // Worm Enable User Mode
   localparam TG_USER_WORM_EN = {10'h2D,2'b00};
   // Test byte-enable
   localparam TG_TEST_BYTEEN = {10'h2E,2'b00};
   // Timeout
   localparam TG_TIMEOUT = {10'h2F,2'b00};
   // Number of data generators
   localparam TG_NUM_DATA_GEN = {10'h31,2'b00};
   // Number of byte enable generators
   localparam TG_NUM_BYTEEN_GEN = {10'h32,2'b00};
   // Width of read data and PNF signals
   localparam TG_RDATA_WIDTH = {10'h37,2'b00};
   // Error reporting register for illegal configurations of the traffic generator
   localparam TG_ERROR_REPORT = {10'h3B,2'b00};
   // Data rate width ratio
   localparam TG_DATA_RATE_WIDTH_RATIO = {10'h3C,2'b00};
   // Persistent PNF per bit (144*8 / 32 addresses needed)
   localparam TG_PNF = {10'h40,2'b00};
   // First failure expected data (144*8 / 32 addresses needed)
   localparam TG_FAIL_EXPECTED_DATA = {10'h80,2'b00};
   // First failure read data (144*8 / 32 addresses needed)
   localparam TG_FAIL_READ_DATA = {10'hC0,2'b00};
   // Data generator seed
   localparam TG_DATA_SEED = {10'h100,2'b00};
   // Byte enable generator seed
   localparam TG_BYTEEN_SEED = {10'h200,2'b00};
   // Data per-pin pattern type selection
   localparam TG_PPPG_SEL = {10'h300,2'b00};
   // Byte-Enable pattern type selection
   localparam TG_BYTEEN_SEL = {10'h3A0,2'b00};

   // ******************************************************************************************
   // TG CSR DEFAULTS
   // ******************************************************************************************
   localparam TG_VERSION_DEFAULT = 'd169;
   localparam TG_START_DEFAULT = '0;
   localparam TG_LOOP_COUNT_DEFAULT = 1'b1;
   localparam TG_WRITE_COUNT_DEFAULT = 1'b1;
   localparam TG_READ_COUNT_DEFAULT = 1'b1;
   localparam TG_WRITE_REPEAT_COUNT_DEFAULT = 1'b1;
   localparam TG_READ_REPEAT_COUNT_DEFAULT = 1'b1;
   localparam TG_BURST_LENGTH_DEFAULT = 1'b1;
   localparam TG_CLEAR_DEFAULT = '0;
   localparam TG_RW_GEN_IDLE_COUNT_DEFAULT = '0;
   localparam TG_RW_GEN_LOOP_IDLE_COUNT_DEFAULT = '0;
   localparam TG_SEQ_START_ADDR_WR_L_DEFAULT = '0;
   localparam TG_ADDR_MODE_WR_DEFAULT = 2'h2;
   localparam TG_RAND_SEQ_ADDRS_WR_DEFAULT = 1'b1;
   localparam TG_RETURN_TO_START_ADDR_DEFAULT = '0;
   localparam TG_SEQ_ADDR_INCR_DEFAULT = 1'b1;
   localparam TG_SEQ_START_ADDR_RD_L_DEFAULT = '0;
   localparam TG_ADDR_MODE_RD_DEFAULT = 2'h2;
   localparam TG_RAND_SEQ_ADDRS_RD_DEFAULT = 1'b1;
   localparam TG_INVERT_BYTEEN_DEFAULT = '0;
   localparam TG_RESTART_DEFAULT_TRAFFIC_DEFAULT = '0;
   localparam TG_USER_WORM_EN_DEFAULT = 1'b0;
   localparam TG_TEST_BYTEEN_DEFAULT = 1'b0;
   localparam TG_DATA_SEED_DEFAULT = 32'h5a5a5a5a;
   localparam TG_BYTEEN_SEED_DEFAULT = 32'hFFFFFFFF;
   localparam TG_PPPG_SEL_DEFAULT = '0;
   localparam TG_BYTEEN_SEL_DEFAULT = '0;
   
   // ******************************************************************************************
   // AFU Register Default Values
   // ******************************************************************************************
   localparam AFU_DFH_VAL                        = 64'h1000010000001000;
   localparam AFU_ID_L_VAL                       = 64'hA3DC5B831F5CECBB;
   localparam AFU_ID_H_VAL                       = 64'h4DADEA342C7848CB;

endpackage

`endif
