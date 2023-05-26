// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   This file defines all the test cases for current test.
//
//   main_test() is the main entry function which the tester calls 
//   to execute the unit tests.
//
//-----------------------------------------------------------------------------

import test_csr_defs::*;

//-------------------
// Test utilities
//-------------------
task incr_test_id;
begin
   test_id = test_id + 1;
end
endtask

task post_test_util;
   input logic [31:0] old_test_err_count;
   logic result;
begin
   if (test_utils::get_err_count() > old_test_err_count) begin
      result = 1'b0;
   end else begin
      result = 1'b1;
   end

   repeat (10)
      @(posedge avl_clk);

   @(posedge avl_clk);
      reset_test = 1'b1;
   repeat (5)
      @(posedge avl_clk);
   reset_test = 1'b0;

   f_reset_tag();

   if (result) begin
      $display("\nTest status: OK");
      test_summary[test_id].result = 1'b1;
   end else begin
      $display("\nTest status: FAILED");
      test_summary[test_id].result = 1'b0;
   end
   incr_test_id(); 
end
endtask

task print_test_header;
   input [1024*8-1:0] test_name;
begin
   $display("\n********************************************");
   $display(" Running TEST(%0d) : %0s", test_id, test_name);
   $display("********************************************");   
   test_summary[test_id].name = test_name;
end
endtask

//-------------------
// Test cases 
//-------------------
// Test DFH walking 
task test_dfh_walking;
   output logic result;
   dfh_name[MAX_DFH_IDX-1:0]     dfh_names;
   logic [MAX_DFH_IDX-1:0][63:0] dfh_values;
   t_dfh        dfh;
   int          dfh_cnt;
   logic        eol;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] addr;
   logic [31:0] old_test_err_count;
begin
   print_test_header("test_dfh_walking");
   
   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;

   //--------------------------
   // DFH Bit mapping
   //--------------------------
   //   [63:60]: Feature Type   
   //   [59:52]: Reserved - 0
   //   [51:48]: If AFU - AFU Minor Revision Number (else, reserved)  - 0
   //   [47:41]: Reserved - 0
   //   [40   ]: EOL (End of DFH list)   
   //   [39:16]: Next DFH Byte Offset 
   //   [15:12]: If AfU, AFU Major version number (else feature #) - 0
   //   [11:0 ]: Feature ID 
   //--------------------------

   dfh_names = get_dfh_names();
   dfh_values = get_dfh_values();

   dfh_cnt = 0;
   eol  = 1'b0;
   addr = DFH_START_OFFSET;

   while (~eol && dfh_cnt < MAX_DFH_IDX) begin
      READ64(ADDR32, addr, BAR, 1'b0, 0, 0, scratch, error);
      $fdisplay(test_utils::get_logfile_handle(), "%0s", dfh_names[dfh_cnt]);
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   DFH value (0x%0x)\n", scratch);

      dfh = t_dfh'(scratch);
      eol = dfh.eol;

      if (scratch !== dfh_values[dfh_cnt]) begin
         $display("\nERROR: DFH value mismatched, expected: 0x%0x actual:0x%0x\n", dfh_values[dfh_cnt], scratch);      
         test_utils::incr_err_count();
         eol = 1'b1; // error found, exit the loop
         result = 1'b0;
      end
      
      addr = addr + dfh.nxt_dfh_offset;
      dfh_cnt = dfh_cnt + 1'b1;
   end

   if (result) begin
      if (eol !== 1'b1) begin
         $display("\nERROR: Expect EOL bit to be set for last feature in the DFL (%0s), actual:'b%0b\n", dfh_names[MAX_DFH_IDX-1], eol);      
         test_utils::incr_err_count();
         result = 1'b0; 
      end

      if (dfh_cnt !== MAX_DFH_IDX) begin
         $display("\nERROR: Expected %d features to be discovered, actual:%0d\n", MAX_DFH_IDX, dfh_cnt);      
         test_utils::incr_err_count();
         result = 1'b0; 
      end
   end

   post_test_util(old_test_err_count);
end
endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin
   test_dfh_walking   (test_result);
end
endtask



