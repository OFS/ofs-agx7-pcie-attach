// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT
//---------------------------------------------------------
// Test module for the simulation. 
//---------------------------------------------------------
module unit_test(
   input logic clk,
   input logic rst_n,
   input logic csr_clk,
   input logic csr_rst_n
);

import host_bfm_types_pkg::*;
import pfvf_def_pkg::*;
import host_memory_class_pkg::*;
import tag_manager_class_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;
import host_axis_send_class_pkg::*;
import host_axis_receive_class_pkg::*;
import host_transaction_class_pkg::*;
import host_bfm_class_pkg::*;
import test_csr_defs::*;


//---------------------------------------------------------
// FLR handle and FLR Memory
//---------------------------------------------------------
//HostFLREvent flr;
//HostFLREvent flrs_received[$];
//HostFLREvent flrs_sent_history[$];


//---------------------------------------------------------
// Packet Handles and Storage
//---------------------------------------------------------
Packet p;
PacketPUMemReq pumr;
PacketPUAtomic pua;
PacketPUCompletion puc;
PacketDMMemReq dmmr;
PacketDMCompletion dmc;
PacketUnknown pu;
PacketPUMsg pmsg;
PacketPUVDM pvdm;


Packet q[$];
Packet qr[$];


//---------------------------------------------------------
// Transaction Handles and Storage
//---------------------------------------------------------
Transaction       t;
ReadTransaction   rt;
WriteTransaction  wt;
AtomicTransaction at;
SendMsgTransaction mt;
SendVDMTransaction vt;

Transaction tx_transaction_queue[$];
Transaction tx_active_transaction_queue[$];
Transaction tx_completed_transaction_queue[$];
Transaction tx_errored_transaction_queue[$];
Transaction tx_history_transaction_queue[$];

byte_t msg_buf[];
byte_t vdm_buf[];

//---------------------------------------------------------
//  BEGIN: Test Tasks and Utilities
//---------------------------------------------------------
parameter MAX_TEST = 100;
//parameter TIMEOUT = 1.5ms;
//parameter TIMEOUT = 10.0ms;
parameter TIMEOUT = 30.0ms;


typedef struct packed {
   logic result;
   logic [1024*8-1:0] name;
} t_test_info;
typedef enum bit {ADDR32, ADDR64} e_addr_mode;

int err_count = 0;
logic [31:0] test_id;
t_test_info [MAX_TEST-1:0] test_summary;
logic reset_test;
logic [7:0] checker_err_count;
logic test_done;
logic test_result;

//---------------------------------------------------------
//  Test Utilities
//---------------------------------------------------------
function void incr_err_count();
   err_count++;
endfunction


function int get_err_count();
   return err_count;
endfunction


//---------------------------------------------------------
//  Test Tasks
//---------------------------------------------------------
task incr_test_id;
begin
   test_id = test_id + 1;
end
endtask

task post_test_util;
   input logic [31:0] old_test_err_count;
   logic result;
begin
   if (get_err_count() > old_test_err_count) 
   begin
      result = 1'b0;
   end else begin
      result = 1'b1;
   end

   repeat (10) @(posedge clk);

   @(posedge clk);
      reset_test = 1'b1;
   repeat (5) @(posedge clk);
   reset_test = 1'b0;

   if (result) 
   begin
      $display("\nTest status: OK");
      test_summary[test_id].result = 1'b1;
   end 
   else 
   begin
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


// Deassert AFU reset
task deassert_afu_reset;
   int count;
   logic [63:0] scratch;
   logic [31:0] wdata;
   logic        error;
   logic [31:0] PORT_CONTROL;
begin
   count = 0;
   PORT_CONTROL = 32'h71000 + 32'h38;
   //De-assert Port Reset 
   $display("\nDe-asserting Port Reset...");
   host_bfm_top.host_bfm.set_pfvf_setting(PF0);
   host_bfm_top.host_bfm.read64(PORT_CONTROL, scratch);
   wdata = scratch[31:0];
   wdata[0] = 1'b0;
   host_bfm_top.host_bfm.write32(PORT_CONTROL, wdata);
   #5000000 host_bfm_top.host_bfm.read64(PORT_CONTROL, scratch);
   if (scratch[4] != 1'b0) begin
      $display("\nERROR: Port Reset Ack Asserted!");
      incr_err_count();
      $finish;       
   end
   $display("\nAFU is out of reset ...");
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
end
endtask


//-------------------
// Test cases 
//-------------------
// Test 32-bit CSR access
task test_csr_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;

   host_bfm_top.host_bfm.write32(addr, data);
   host_bfm_top.host_bfm.read32_with_completion_status(addr, scratch, error, cpl_status);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit CSR access to unused CSR region
task test_unused_csr_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;

   host_bfm_top.host_bfm.write32(addr, data);
   host_bfm_top.host_bfm.read32_with_completion_status(addr, scratch, error, cpl_status);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== 32'h0) begin
       $display("\nERROR: Expected 32'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
       incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR access
task test_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;

   host_bfm_top.host_bfm.write64(addr, data);
   host_bfm_top.host_bfm.read64_with_completion_status(addr, scratch, error, cpl_status);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR read access
task test_csr_read_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;
   host_bfm_top.host_bfm.read64_with_completion_status(addr, scratch, error, cpl_status);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
       incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit CSR read access
task test_csr_read_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;
   host_bfm_top.host_bfm.read32_with_completion_status(addr, scratch, error, cpl_status);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
       incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR access to unused CSR region
task test_unused_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;

   host_bfm_top.host_bfm.write64(addr, data);
   host_bfm_top.host_bfm.read64_with_completion_status(addr, scratch, error, cpl_status);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== 64'h0) begin
       $display("\nERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
       incr_err_count();
       result = 1'b0;
   end
end
endtask

task test_csr_ro_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;

   host_bfm_top.host_bfm.read64_with_completion_status(addr, scratch, error, cpl_status);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR expected and read mismatch! expected=0x%x read=0x%x\n", data, scratch);
       incr_err_count();
       result = 1'b0;
   end
end
endtask


//---------------------------------------------------------
//  END: Test Tasks and Utilities
//---------------------------------------------------------

//---------------------------------------------------------
// Initials for Sim Setup
//---------------------------------------------------------
initial 
begin
   reset_test = 1'b0;
   test_id = '0;
   test_done = 1'b0;
   test_result = 1'b0;
end


initial 
begin
   fork: timeout_thread begin
      $display("Begin Timeout Thread.  Test will time out in %0t\n", TIMEOUT);
     // timeout thread, wait for TIMEOUT period to pass
     #(TIMEOUT);
     // The test hasn't finished within TIMEOUT Period
     @(posedge clk);
     $display ("TIMEOUT, test_pass didn't go high in %0t\n", TIMEOUT);
     disable timeout_thread;
   end
 
   wait (test_done == 1) begin
      // Test summary
      $display("\n********************");
      $display("  Test summary");
      $display("********************");
      for (int i=0; i < test_id; i=i+1) 
      begin
         if (test_summary[i].result)
            $display("   %0s (id=%0d) - pass", test_summary[i].name, i);
         else
            $display("   %0s (id=%0d) - FAILED", test_summary[i].name, i);
      end

      if(get_err_count() == 0) 
      begin
          $display("Test passed!");
      end 
      else 
      begin
          if (get_err_count() != 0) 
          begin
             $display("Test FAILED! %d errors reported.\n", get_err_count());
          end
       end
   end
   
   join_any    
   $finish();  
end

always begin : main   
   $display("Start of MAIN Always.");
   #10000;
   $display("MAIN Always - After Delay");
   wait (rst_n);
   $display("MAIN Always - After Wait for rst_n.");
   wait (csr_rst_n);
   $display("MAIN Always - After Wait for csr_rst_n.");
   //-------------------------
   // deassert port reset
   //-------------------------
   deassert_afu_reset();
   $display("MAIN Always - After Deassert of AFU Reset.");
   //-------------------------
   // Test scenarios 
   //-------------------------
   main_test(test_result);
   $display("MAIN Always - After Main Task.");
   test_done = 1'b1;
end


task wait_dw_count;
   output logic result;
begin
   bit timed_out;
   result = 1;
   fork : check_cnt
      begin
         #50000000;
         $display("Oh no.. Timeout waiting for all DW"); 
         incr_err_count();
         result = 0;
         timed_out = '1;
         disable check_cnt;
      end
      begin
         wait( top_tb.DUT.afu_top.pg_afu.port_gasket.pr_ctrl.pr_ip_dword_cnt[31:0] === 32'h10);
         $display("Seen all DW at PR IP"); 
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
   $display("Asserting PG_PR_CTRL.PRReset"); 
   //READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   host_bfm_top.host_bfm.read64(PG_PR_CTRL, reg_data64);

   reg_data64 = reg_data64 | (1'b1 <<PRReset_idx);
   //WRITE64(ADDR64, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64);
   host_bfm_top.host_bfm.write64(PG_PR_CTRL, reg_data64);

   // Step 2. Wait for PG_PR_CTRL.PRResetAck = 1
   timeout_cnt = 0;
   //READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   host_bfm_top.host_bfm.read64(PG_PR_CTRL, reg_data64);
   while (timeout_cnt < RD_TIMEOUT) 
   begin
      $display("Waiting for PG_PR_CTRL.PRResetAck"); 
      timeout_cnt++;
 
      if (reg_data64[PRReset_ack_idx] == 1'b1) begin
         $display("Received PG_PR_CTRL.PRResetAck!");
         break;
      end
      
      // Reading for next poll
      //READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
      host_bfm_top.host_bfm.read64(PG_PR_CTRL, reg_data64);
   end
   
   if (timeout_cnt == RD_TIMEOUT) begin
       $display("PG_PR_CTRL.PRResetAck not seen, flag error");
       incr_err_count();
       result = 0;
   end

   // Step 3. PG_PR_CTRL.PRReset = 0
   $display("De-asserting PG_PR_CTRL.PRReset"); 
   reg_data64[PRReset_idx] = 1'b0;
   //WRITE64(ADDR64, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64);
   host_bfm_top.host_bfm.write64(PG_PR_CTRL, reg_data64);

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
   $display("Asserting PG_PR_CTRL.PRStartRequest"); 
   //READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   host_bfm_top.host_bfm.read64(PG_PR_CTRL, reg_data64);

   reg_data64 = reg_data64 | (1'b1 <<PRStartRequest_idx);
   //WRITE64(ADDR64, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64);
   host_bfm_top.host_bfm.write64(PG_PR_CTRL, reg_data64);
   repeat (100) 
      @(posedge clk);

   // Step 2. Force PR status to success since BFM won't do it
   force top_tb.DUT.afu_top.pg_afu.port_gasket.pr_ctrl.pr_ip_status = 3'h3; //PR success
   $display("Forcing "); 


   // Step 3. Send GBS data PG_PR_DATA.
   for (int gbs_cnt = 0; gbs_cnt < GBS_SIZE; gbs_cnt++) begin
       $display("Writing PG_PR_DATA for gbs_cnt = %d", gbs_cnt);
      //WRITE64(ADDR64, PG_PR_DATA, BAR, VF_ACTIVE, PF, VF, gbs_cnt);
      host_bfm_top.host_bfm.write64(PG_PR_DATA, gbs_cnt);
      repeat (30)
         @(posedge clk);
   end

   repeat (100)
      @(posedge clk);

   // Step 4. Check Byte count
   $display("Checking DW count to PR IP"); 
   wait_dw_count(result);

   // Step 5.  PG_PR_CTRL.PRDataPushComplete = 1 
   $display("Asserting PG_PR_CTRL.PRDataPushComplete"); 
   //READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   host_bfm_top.host_bfm.read64(PG_PR_CTRL, reg_data64);

   reg_data64 = reg_data64 | (1'b1 <<PRDataPushComplete_idx);
   //WRITE64(ADDR64, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64);
   host_bfm_top.host_bfm.write64(PG_PR_CTRL, reg_data64);

   repeat (200)
      @(posedge clk);

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
   //READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   host_bfm_top.host_bfm.read64(PG_PR_CTRL, reg_data64);
   while (timeout_cnt <RD_TIMEOUT) begin
      $display("Waiting for PG_PR_CTRL.PRStartRequest == 0"); 
      timeout_cnt++;
 
      if (reg_data64[PRStartRequest_idx] == 1'b0) begin
         $display("PR complete PRStartRequest = 0!");
         break;
      end
      
      // Reading for next poll
      //READ64(ADDR32, PG_PR_CTRL, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
      host_bfm_top.host_bfm.read64(PG_PR_CTRL, reg_data64);
   end

   // Step 2. Check for PR success PG_PR_STATUS.
   //READ64(ADDR32, PG_PR_STATUS, BAR, VF_ACTIVE, PF, VF, reg_data64, error);
   host_bfm_top.host_bfm.read64(PG_PR_STATUS, reg_data64);
   
   if (reg_data64[PRStatus_idx] == 1'b0) begin
      $display("PRStatus = 0, PR Success!");
   end else begin
      // Test is forced success, error scenario not tested
      $display("PRStatus = 1, PR Showing Error..not good");
      incr_err_count();
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
   //WRITE64(ADDR64, USER_CLK_FREQ_CMD0, BAR, VF_ACTIVE, PF, VF, reg_data64);
   host_bfm_top.host_bfm.write64(USER_CLK_FREQ_CMD0, reg_data64);

   repeat (50)
      @(posedge clk);

   seq = seq + 1;
   addr = 9'h100;
   reg_data64[Seq_idx+1:Seq_idx] = seq;
   reg_data64[CmdAdr_idx+9:CmdAdr_idx] = addr;
   // Should not remap address
   //WRITE64(ADDR64, USER_CLK_FREQ_CMD0, BAR, VF_ACTIVE, PF, VF, reg_data64);
   host_bfm_top.host_bfm.write64(USER_CLK_FREQ_CMD0, reg_data64);

   repeat (400)
      @(posedge clk);

      $display("Userclk test complete, checkwavefrom for remap");
   //Verify by visual inspection

end
endtask


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
begin
   $display("Entering Port Gasket Test.");
   host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
   host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
   host_bfm_top.host_bfm.set_pfvf_setting(PF0);

   // PR Test
   init_pr(test_result);
   send_gbs(test_result);
   check_cmpl_status(test_result);

   // User clock test 
   user_clk_csr_remap(test_result);
   
end
endtask


endmodule
