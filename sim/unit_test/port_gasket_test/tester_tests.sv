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

task wait_dw_count;
   output logic result;
begin
   bit timed_out;
   result = 1;
   fork : check_cnt
      begin
         #50000000;
         $fdisplay(test_utils::get_logfile_handle(), "Oh no.. Timeout waiting for all DW"); 
         test_utils::incr_err_count();
         result = 0;
         timed_out = '1;
         disable check_cnt;
      end
      begin
         wait( top_tb.DUT.afu_top.port_gasket.pr_ctrl.pr_ip_dword_cnt[31:0] === 32'h10);
         $fdisplay(test_utils::get_logfile_handle(), "Seen all DW at PR IP"); 
         disable check_cnt;
      end
   join
end
endtask 

task init_pr;
   output logic result;
begin
   logic error;
   logic [63:0] reg_data64;
   logic [31:0] reg_data32;
   int timeout_cnt;
   result = 1;

   // Step 1. PG_PR_CTRL.PRReset = 1
   $fdisplay(test_utils::get_logfile_handle(), "Asserting PG_PR_CTRL.PRReset"); 
   READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);

   reg_data64 = reg_data64 | (1'b1 <<PRReset_idx);
   WRITE64(ADDR64, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64);

   // Step 2. Wait for PG_PR_CTRL.PRResetAck = 1
   timeout_cnt = 0;
   READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   while (timeout_cnt <RD_TIMEOUT) begin
      $fdisplay(test_utils::get_logfile_handle(), "Waiting for PG_PR_CTRL.PRResetAck"); 
      timeout_cnt++;
 
      if (reg_data64[PRReset_ack_idx] == 1'b1) begin
         $fdisplay(test_utils::get_logfile_handle(), "Received PG_PR_CTRL.PRResetAck!");
         break;
      end
      
      // Reading for next poll
      READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   end
   
   if (timeout_cnt == RD_TIMEOUT) begin
       $fdisplay(test_utils::get_logfile_handle(), "PG_PR_CTRL.PRResetAck not seen, flag error");
       test_utils::incr_err_count();
       result = 0;
   end

   // Step 3. PG_PR_CTRL.PRReset = 0
   $fdisplay(test_utils::get_logfile_handle(), "De-asserting PG_PR_CTRL.PRReset"); 
   reg_data64[PRReset_idx] = 1'b0;
   WRITE64(ADDR64, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64);

end
endtask


task send_gbs;
   output logic result;
begin
   logic error;
   logic [63:0] reg_data64;
   logic [31:0] reg_data32;
   logic [63:0] GBS_DATA [3:0];
   int timeout_cnt;
   result = 1;
   
   // Dummy GBS data (lower 32 bit data should show up)



   // Step 1. PG_PR_CTRL.PRStartRequest = 1
   $fdisplay(test_utils::get_logfile_handle(), "Asserting PG_PR_CTRL.PRStartRequest"); 
   READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);

   reg_data64 = reg_data64 | (1'b1 <<PRStartRequest_idx);
   WRITE64(ADDR64, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64);
   repeat (100) 
      @(posedge fim_clk);

   // Step 2. Force PR status to success since BFM won't do it
   force top_tb.DUT.afu_top.port_gasket.pr_ctrl.pr_ip_status = 3'h3; //PR success
   $fdisplay(test_utils::get_logfile_handle(), "Forcing "); 


   // Step 3. Send GBS data PG_PR_DATA.
   for (int gbs_cnt = 0; gbs_cnt < GBS_SIZE; gbs_cnt++) begin
       $fdisplay(test_utils::get_logfile_handle(), "Writing PG_PR_DATA for gbs_cnt = %d", gbs_cnt);
      WRITE64(ADDR64, PG_PR_DATA, BAR, VF_ACTIVE, PF, VF, gbs_cnt);
      repeat (30)
         @(posedge fim_clk);
   end

   repeat (100)
      @(posedge fim_clk);

   // Step 4. Check Byte count
   $fdisplay(test_utils::get_logfile_handle(), "Checking DW count to PR IP"); 
   wait_dw_count(result);

   // Step 5.  PG_PR_CTRL.PRDataPushComplete = 1 
   $fdisplay(test_utils::get_logfile_handle(), "Asserting PG_PR_CTRL.PRDataPushComplete"); 
   READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);

   reg_data64 = reg_data64 | (1'b1 <<PRDataPushComplete_idx);
   WRITE64(ADDR64, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64);

   repeat (200)
      @(posedge fim_clk);

end
endtask


task check_cmpl_status;
   output logic result;
begin
   logic error;
   logic [63:0] reg_data64;
   logic [31:0] reg_data32;
   int timeout_cnt;
   result = 1;

   // Step 1. Wiat for for PG_PR_CTRL.PRStartRequest == 0
   timeout_cnt = 0;
   READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   while (timeout_cnt <RD_TIMEOUT) begin
      $fdisplay(test_utils::get_logfile_handle(), "Waiting for PG_PR_CTRL.PRStartRequest == 0"); 
      timeout_cnt++;
 
      if (reg_data64[PRStartRequest_idx] == 1'b0) begin
         $fdisplay(test_utils::get_logfile_handle(), "PR complete PRStartRequest = 0!");
         break;
      end
      
      // Reading for next poll
      READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   end

   // Step 2. Check for PR success PG_PR_STATUS.
   READ64(ADDR32, PG_PR_STATUS, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   
   if (reg_data64[PRStatus_idx] == 1'b0) begin
      $fdisplay(test_utils::get_logfile_handle(), "PRStatus = 0, PR Success!");
   end else begin
      // Test is forced success, error scenario not tested
      $fdisplay(test_utils::get_logfile_handle(), "PRStatus = 1, PR Showing Error..not good");
      test_utils::incr_err_count();
      result = 0;
   end

 
end
endtask

task user_clk_csr_remap;
   output logic result;
begin
   logic error;
   logic [63:0] reg_data64;
   logic [31:0] reg_data32;
   logic [9:0] addr;
   logic [1:0] seq;
   result = 1;
   
   seq = 2'h1;
   addr = 9'h11b;
   // Should remap address
   reg_data64 = 64'h0;
   reg_data64[UsrClkCmdMmRst_idx] = 1'b1;
   reg_data64[UsrClkCmdWr_idx] = 1'b1;
   reg_data64[Seq_idx+1:Seq_idx] = seq;
   reg_data64[CmdAdr_idx+9:CmdAdr_idx] = addr;
   WRITE64(ADDR64, USER_CLK_FREQ_CMD0, BAR, VF_ACTIVE, PF, VF, reg_data64);

   repeat (50)
      @(posedge fim_clk);

   seq = seq + 1;
   addr = 9'h100;
   reg_data64[Seq_idx+1:Seq_idx] = seq;
   reg_data64[CmdAdr_idx+9:CmdAdr_idx] = addr;
   // Should not remap address
   WRITE64(ADDR64, USER_CLK_FREQ_CMD0, BAR, VF_ACTIVE, PF, VF, reg_data64);

   repeat (400)
      @(posedge fim_clk);

      $fdisplay(test_utils::get_logfile_handle(), "Userclk test complete, checkwavefrom for remap");
   //Verify by visual inspection

end
endtask



//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin

   // PR Test
   init_pr(test_result);
   send_gbs(test_result);
   check_cmpl_status(test_result);

   // User clock test 
   user_clk_csr_remap(test_result);
   
end
endtask

