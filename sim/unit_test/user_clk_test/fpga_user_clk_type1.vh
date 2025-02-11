// Copyright (C) 2025 Intel Corporation.
// SPDX-License-Identifier: MIT

//---------------------------------------------------------
// Type 1 (e.g. Agilex 7) user clock configuration.
// Type 1 sequences write to a specific set of registers derived from
// S10 user clock configuration. Agilex 7 HW maps from S10 to Agilex 7
// addresses.
//---------------------------------------------------------

task user_clk_type1_counter_set;
   inout  logic [1:0] seq;
   input  logic [31:0] counter_settings;
   input  logic [CMD0_BIT_ADDR_LEN-1:0] addr;
   output logic result;
begin
   logic [63:0] reg_cmd64;
   logic [63:0] reg_data64;

   // Common settings for all commands
   reg_cmd64 = '0;
   reg_cmd64[CMD0_BIT_WRITE] = 1'b1;
   reg_cmd64[CMD0_BIT_AVMM_RST_N] = 1'b1;

   //
   // High, low, etc. fields are separate commands but the address offsets
   // are the same for each counter.
   //

   // High
   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = addr;
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = { '0, counter_settings[15:8] };
   user_clk_cmd0_write(reg_cmd64, seq, result);

   // Low
   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = addr + 3;
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = { '0, counter_settings[7:0] };
   user_clk_cmd0_write(reg_cmd64, seq, result);

   // Bypass enable
   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = addr + 1;
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = { '0, counter_settings[16] };
   user_clk_cmd0_write(reg_cmd64, seq, result);

   // Odd division
   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = addr + 2;
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = { '0, counter_settings[17], 7'h0 };
   user_clk_cmd0_write(reg_cmd64, seq, result);
end
endtask

// The N counter has different addressing for reasons lost to history.
task user_clk_type1_set_n;
   inout  logic [1:0] seq;
   input  logic [31:0] n;
   input  logic [31:0] cp;
   input  logic [CMD0_BIT_ADDR_LEN-1:0] addr;
   output logic result;
begin
   logic [63:0] reg_cmd64;
   logic [63:0] reg_data64;

   // Common settings for all commands
   reg_cmd64 = '0;
   reg_cmd64[CMD0_BIT_WRITE] = 1'b1;
   reg_cmd64[CMD0_BIT_AVMM_RST_N] = 1'b1;

   //
   // High, low, etc. fields are separate commands but the address offsets
   // are the same for each counter.
   //

   // High
   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = addr;
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = { '0, n[15:8] };
   user_clk_cmd0_write(reg_cmd64, seq, result);

   // Low
   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = addr + 2;
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = { '0, n[7:0] };
   user_clk_cmd0_write(reg_cmd64, seq, result);

   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = addr + 1;
   // Bypass enable
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = { '0, n[16] };
   // Odd division
   reg_cmd64[CMD0_BIT_DATA + 7] = n[17];
   // CP1
   reg_cmd64[CMD0_BIT_DATA + 4 +: 3] = cp[2:0];
   user_clk_cmd0_write(reg_cmd64, seq, result);
end
endtask

// Set frequency with type 1 interface (e.g. Agilex 7)
task user_clk_type1_freq_set;
input  logic [15:0] tgt_freq_low;
input  logic [15:0] tgt_freq_high;
input  logic [1:0] seq;
   input  logic [31:0] pll_m;
   input  logic [31:0] pll_n;
   input  logic [31:0] pll_c1;
   input  logic [31:0] pll_c0;
   input  logic [31:0] pll_lf;
   input  logic [31:0] pll_cp;
   input  logic [31:0] pll_rc;
   output logic result;
begin
   logic error;
   logic [63:0] reg_cmd64;
   logic [63:0] reg_data64;
   logic [15:0] freq;

   $display("\nSetting PLL M...");
   user_clk_type1_counter_set(seq, pll_m, PLL_R1_M_ADDR, result);
   $display("\nSetting PLL N...");
   user_clk_type1_set_n(seq, pll_n, pll_cp, PLL_R1_N_ADDR, result);
   $display("\nSetting PLL C0...");
   user_clk_type1_counter_set(seq, pll_c0, PLL_R1_C0_ADDR, result);
   $display("\nSetting PLL C1...");
   user_clk_type1_counter_set(seq, pll_c1, PLL_R1_C1_ADDR, result);

   // Standard settings for writes
   reg_cmd64 = '0;
   reg_cmd64[CMD0_BIT_WRITE] = 1'b1;
   reg_cmd64[CMD0_BIT_AVMM_RST_N] = 1'b1;

   $display("\nSetting PLL CP2...");
   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = PLL_R1_CP2_ADDR;
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = { '0, pll_cp[5:3], 5'h0 };
   user_clk_cmd0_write(reg_cmd64, seq, result);

   $display("\nSetting PLL LF and RC...");
   reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = PLL_R1_LF_ADDR;
   reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = '0;
   reg_cmd64[CMD0_BIT_DATA + 3 +: 8] = pll_lf[13:6];
   reg_cmd64[CMD0_BIT_DATA + 1 +: 2] = pll_rc[1:0];
   user_clk_cmd0_write(reg_cmd64, seq, result);

   $display("\nAssert resets...");
   reg_cmd64 = '0;
   reg_cmd64[CMD0_BIT_MGMT_RESET] = 1'b1;
   reg_cmd64[CMD0_BIT_IOPLL_RESET] = 1'b1;
   host_bfm_top.host_bfm.write64(USER_CLK_FREQ_CMD0, reg_cmd64);
   #10us;

   $display("\nDeassert IOPLL reset...");
   reg_cmd64[CMD0_BIT_IOPLL_RESET] = 1'b0;
   host_bfm_top.host_bfm.write64(USER_CLK_FREQ_CMD0, reg_cmd64);
   #10us;

   $display("\nDeassert all resets...");
   reg_cmd64[CMD0_BIT_MGMT_RESET] = 1'b0;
   reg_cmd64[CMD0_BIT_AVMM_RST_N] = 1'b1;
   host_bfm_top.host_bfm.write64(USER_CLK_FREQ_CMD0, reg_cmd64);
   #10us;

   user_clk_wait_for_lock(test_result);

   $display("\n*** Skipping calibration. The CSR sequence is not yet implemented but should be here. ***\n");

   user_clk_measure_freq(0, tgt_freq_low, freq);
   user_clk_measure_freq(1, tgt_freq_high, freq);
end
endtask
