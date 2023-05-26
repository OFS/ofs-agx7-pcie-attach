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
// Test  RemoteSTP MMIO read write
task test_rstp_mmio;
   output logic result;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [31:0] CHANNEL_ID;
   logic [31:0] CONN_ID;
   logic [31:0] START_LOC;
   logic [31:0] PKT_LEN;
   logic [31:0] LAST_LOC;
   logic [31:0] CTRL_REG;
begin
   print_test_header("test_rstp_mmio");
   old_test_err_count = test_utils::get_err_count();
   
   result     = 1'b1;
   addr_mode  = ADDR32;
   CHANNEL_ID = 'hB;
   CONN_ID    = 'hC;
   START_LOC  = 'h8; // Multiple of 8
   PKT_LEN    = 'h40; // Multiple of 8
   LAST_LOC   = START_LOC + PKT_LEN; // Multiple of 8
   CTRL_REG   = 'h7; // [2:0] are valid
   
   // CSR
   // DFH Register check
     
   CSR_READ(addr_mode, PORT_STP_DFH_ADDR, 10'd02, 0, 1'b0, 0, 0, scratch, error);
   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== PORT_STP_DFH_VAL) begin
       $display("\nERROR: DFH CSR expected and read mismatch! expected=0x%x read=0x%x\n", PORT_STP_DFH_VAL, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
   
   $fdisplay(test_utils::get_logfile_handle(), " \n PORT_STP_DFH_ADDR   (0x%0x)",PORT_STP_DFH_ADDR );
   $fdisplay(test_utils::get_logfile_handle(), " Value (0x%0x)\n", scratch);


  CSR_READ(addr_mode,  PORT_STP_STATUS_ADDR , 10'd02, 0, 1'b0, 0, 0, scratch, error);
   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== PORT_STP_STATUS_VAL) begin
       $display("\nERROR: PORT_STP_STATUS_CSR expected and read mismatch! expected=0x%x read=0x%x\n", PORT_STP_STATUS_VAL, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end

   $fdisplay(test_utils::get_logfile_handle(), " \n PORT_STP_STATUS_ADDR   (0x%0x)",PORT_STP_STATUS_ADDR );
   $fdisplay(test_utils::get_logfile_handle(), " Value (0x%0x)\n", scratch);
 
   

   end
endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin
    test_rstp_mmio    (test_result);
end
endtask



