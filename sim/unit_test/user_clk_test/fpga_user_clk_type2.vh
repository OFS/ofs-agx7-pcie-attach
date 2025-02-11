// Copyright (C) 2025 Intel Corporation.
// SPDX-License-Identifier: MIT

//---------------------------------------------------------
// Type 2 (e.g. Agilex 5) user clock configuration.
// Type 2 is a sequence of masked read-modify-write operations.
//---------------------------------------------------------

//
// These sequences parallel the C code in the OPAE SDK.
//

// Sources of data to be written to the user clock registers.
typedef enum int {
   PLL_PARAM_CONST,
   PLL_PARAM_MN,
   PLL_PARAM_C0,
   PLL_PARAM_C1,
   PLL_PARAM_CP
} e_pll_param;

// Descriptor for a single stage of the user clock configuration sequence.
typedef struct {
   int unsigned addr;
   int unsigned mask;
   e_pll_param param_type;
   int unsigned const_param;
   string msg;
} t_user_clk_type2_seq;

// Sequence of operations to configure an Agilex 5 user clock.
localparam N_AGILEX5_SEQ_STAGES = 11;
localparam t_user_clk_type2_seq agilex5_pll_seq[N_AGILEX5_SEQ_STAGES] = '{
   '{PLL_AGX5_EN_REGS_ADDR, 32'h1, PLL_PARAM_CONST, 1'b1, "Setting reconfiguration enable..."},
   '{PLL_AGX5_CAL_STATUS_ADDR, 32'h200080, PLL_PARAM_CONST, 32'h0, "Clearing calibration status..."},
   '{PLL_AGX5_MN_ADDR, 32'hffffffff, PLL_PARAM_MN, 32'h0, "Setting PLL M+N..."},
   '{PLL_AGX5_C0_ADDR, 32'hffb801ff, PLL_PARAM_C0, 32'h0, "Setting PLL C0..."},
   '{PLL_AGX5_C1_ADDR, 32'hffb801ff, PLL_PARAM_C1, 32'h0, "Setting PLL C1..."},
   '{PLL_AGX5_CP_ADDR, 32'hfffe, PLL_PARAM_CP, 32'h0, "Setting PLL charge pump..."},
   '{PLL_AGX5_RESET_ADDR, 32'h4, PLL_PARAM_CONST, 32'h4, "Asserting PLL reset..."},
   '{PLL_AGX5_RESET_ADDR, 32'h4, PLL_PARAM_CONST, 32'h0, "Deasserting PLL reset..."},
   '{PLL_AGX5_CAL_OVRD_ADDR, 32'h4000, PLL_PARAM_CONST, 32'h4000, "Permitting calibration override..."},
   '{PLL_AGX5_CAL_REQ_ADDR, 32'h800, PLL_PARAM_CONST, 32'h0, "Clearing calibration request..."},
   '{PLL_AGX5_CAL_REQ_ADDR, 32'h800, PLL_PARAM_CONST, 32'h800, "Requesting calibration..."}
};

// Table of charge pump settings for Agilex 5, indexed by M ranges.
typedef struct {
   int unsigned m_low;
   int unsigned m_high;
   int unsigned cp;
} t_user_clk_agilex5_cp;

localparam N_AGILEX5_CP_ENTRIES = 13;
localparam t_user_clk_agilex5_cp agilex5_cp_table[N_AGILEX5_CP_ENTRIES] = '{
   '{2,   2,   'b00011_10101_11111},
   '{3,   5,   'b00011_10001_11010},
   '{6,   7,   'b00011_10001_11010},
   '{8,   10,  'b00010_10000_11000},
   '{11,  15,  'b00010_01100_10010},
   '{16,  20,  'b00001_01001_01110},
   '{21,  23,  'b00001_01001_01110},
   '{24,  43,  'b00000_01000_01100},
   '{44,  64,  'b00000_00110_01001},
   '{65,  85,  'b00000_00110_00110},
   '{86,  124, 'b00000_00101_00101},
   '{125, 160, 'b00000_00011_00011},
   '{161, 320, 'b00000_00010_00010}
};

function int unsigned user_clk_agilex5_cp_lookup(int unsigned m);
begin
   int i;
   if (m < agilex5_cp_table[0].m_low) begin
      return agilex5_cp_table[0].cp;
   end

   // Simple linear search. The table is small and the search is infrequent.
   for (i = 0; i < N_AGILEX5_CP_ENTRIES; i++) begin
      if (m >= agilex5_cp_table[i].m_low && m <= agilex5_cp_table[i].m_high) begin
         return agilex5_cp_table[i].cp;
      end
   end

   return agilex5_cp_table[N_AGILEX5_CP_ENTRIES-1].cp;
end
endfunction

// Type 2 user clock does a masked read-modify-write for every register update.
// Set the mask for the next write by writing it to CMD0.
task user_clk_type2_set_mask;
   input  logic [31:0] mask;
begin
   logic [63:0] reg_cmd64;

   // Mask is stored in the data field
   reg_cmd64 = '0;
   reg_cmd64[CMD0_BIT_DATA_MASK] = 1'b1;
   reg_cmd64[CMD0_BIT_DATA +: 32] = mask;
   host_bfm_top.host_bfm.write64(USER_CLK_FREQ_CMD0, reg_cmd64);
end
endtask

task user_clk_type2_agilex5_freq_set;
   input  logic [1:0] seq;
   input  logic [31:0] pll_m;
   input  logic [31:0] pll_n;
   input  logic [31:0] pll_c1;
   input  logic [31:0] pll_c0;
   output logic result;
begin
   logic [63:0] reg_cmd64;
   logic [63:0] reg_data64;
   int i;
   t_user_clk_type2_seq cmd;
   int unsigned cp_from_table;

   for (i = 0; i < N_AGILEX5_SEQ_STAGES; i++) begin
      cmd = agilex5_pll_seq[i];
      $display("\n%0s", cmd.msg);

      // Mask -- bits that will be updated in the next write
      user_clk_type2_set_mask(cmd.mask);

      // Construct the write, either with a constant value from the table or
      // with the PLL parameters.
      reg_cmd64 = '0;
      reg_cmd64[CMD0_BIT_WRITE] = 1'b1;
      reg_cmd64[CMD0_BIT_ADDR +: CMD0_BIT_ADDR_LEN] = cmd.addr;
      reg_cmd64[CMD0_BIT_DATA +: CMD0_BIT_DATA_LEN] = '0;

      case (cmd.param_type)
         PLL_PARAM_CONST: begin
            reg_cmd64[CMD0_BIT_DATA +: 32] = cmd.const_param;
         end
         PLL_PARAM_MN: begin
            reg_cmd64[CMD0_BIT_DATA+28 : CMD0_BIT_DATA+20] = pll_m[15:8] + pll_m[7:0];
            reg_cmd64[CMD0_BIT_DATA+31] = pll_m[16];

            reg_cmd64[CMD0_BIT_DATA+7 : CMD0_BIT_DATA+0] = pll_n[15:8];  // High
            reg_cmd64[CMD0_BIT_DATA+16 : CMD0_BIT_DATA+9] = pll_n[7:0];  // Low
            reg_cmd64[CMD0_BIT_DATA+17] = pll_n[17];                     // Odd division
            reg_cmd64[CMD0_BIT_DATA+8] = pll_n[16];                      // Bypass enable
         end
         PLL_PARAM_C0: begin
            reg_cmd64[CMD0_BIT_DATA+7 : CMD0_BIT_DATA+0] = pll_c0[15:8];  // High
            reg_cmd64[CMD0_BIT_DATA+30 : CMD0_BIT_DATA+23] = pll_c0[7:0]; // Low
            reg_cmd64[CMD0_BIT_DATA+31] = pll_c0[17];                     // Odd division
            reg_cmd64[CMD0_BIT_DATA+8] = pll_c0[16];                      // Bypass enable
         end
         PLL_PARAM_C1: begin
            reg_cmd64[CMD0_BIT_DATA+7 : CMD0_BIT_DATA+0] = pll_c1[15:8];  // High
            reg_cmd64[CMD0_BIT_DATA+30 : CMD0_BIT_DATA+23] = pll_c1[7:0]; // Low
            reg_cmd64[CMD0_BIT_DATA+31] = pll_c1[17];                     // Odd division
            reg_cmd64[CMD0_BIT_DATA+8] = pll_c1[16];                      // Bypass enable
         end
         PLL_PARAM_CP: begin
            cp_from_table = user_clk_agilex5_cp_lookup(pll_m[15:8] + pll_m[7:0]);
            reg_cmd64[CMD0_BIT_DATA +: 32] = { '0, cp_from_table[14:0], 1'b0 };
         end
      endcase

      user_clk_cmd0_write(reg_cmd64, seq, result);
   end
end
endtask

task user_clk_type2_freq_set;
   input  logic [15:0] tgt_freq_low;
   input  logic [15:0] tgt_freq_high;
   input  logic [1:0] seq;
   input  logic [31:0] pll_m;
   input  logic [31:0] pll_n;
   input  logic [31:0] pll_c1;
   input  logic [31:0] pll_c0;
   output logic result;
begin
   logic [63:0] reg_cmd64;
   logic [63:0] reg_data64;
   logic [15:0] freq;
   logic [5:0] fpga_family;

   //
   // Reset management interface
   //
   reg_cmd64 = '0;
   reg_cmd64[CMD0_BIT_MGMT_RESET] = 1'b1;
   host_bfm_top.host_bfm.write64(USER_CLK_FREQ_CMD0, reg_cmd64);
   reg_cmd64[CMD0_BIT_MGMT_RESET] = 1'b0;
   host_bfm_top.host_bfm.write64(USER_CLK_FREQ_CMD0, reg_cmd64);

   // Read FPGA family from STS1
   host_bfm_top.host_bfm.read64(USER_CLK_FREQ_STS1, reg_data64);
   fpga_family = reg_data64[59:54];

   if (fpga_family == 6'h1) begin
      user_clk_type2_agilex5_freq_set(seq, pll_m, pll_n, pll_c1, pll_c0, result);
   end else begin
      $display("ERROR: FPGA family not supported");
      result = 1;
      incr_err_count();
   end

   #10us;
   user_clk_wait_for_lock(result);

   user_clk_measure_freq(0, tgt_freq_low, freq);
   user_clk_measure_freq(1, tgt_freq_high, freq);
end
endtask
