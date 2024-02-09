// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT
//---------------------------------------------------------
// Test module for the simulation. 
//---------------------------------------------------------

import host_bfm_types_pkg::*;

module unit_test #(
   parameter SOC_ATTACH = 0,
   parameter type pf_type = default_pfs, 
   parameter pf_type pf_list = '{1'b1}, 
   parameter type vf_type = default_vfs, 
   parameter vf_type vf_list = '{0}
)(
   input logic clk,
   input logic rst_n,
   input logic csr_clk,
   input logic csr_rst_n
);

import pfvf_class_pkg::*;
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
Packet            #(pf_type, vf_type, pf_list, vf_list) p;
PacketPUMemReq    #(pf_type, vf_type, pf_list, vf_list) pumr;
PacketPUAtomic    #(pf_type, vf_type, pf_list, vf_list) pua;
PacketPUCompletion#(pf_type, vf_type, pf_list, vf_list) puc;
PacketDMMemReq    #(pf_type, vf_type, pf_list, vf_list) dmmr;
PacketDMCompletion#(pf_type, vf_type, pf_list, vf_list) dmc;
PacketUnknown     #(pf_type, vf_type, pf_list, vf_list) pu;

Packet#(pf_type, vf_type, pf_list, vf_list) q[$];
Packet#(pf_type, vf_type, pf_list, vf_list) qr[$];


//---------------------------------------------------------
// Transaction Handles and Storage
//---------------------------------------------------------
Transaction      #(pf_type, vf_type, pf_list, vf_list) t;
ReadTransaction  #(pf_type, vf_type, pf_list, vf_list) rt;
WriteTransaction #(pf_type, vf_type, pf_list, vf_list) wt;
AtomicTransaction#(pf_type, vf_type, pf_list, vf_list) at;

Transaction#(pf_type, vf_type, pf_list, vf_list) tx_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_active_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_completed_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_errored_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_history_transaction_queue[$];


//---------------------------------------------------------
// PFVF Structs 
//---------------------------------------------------------
pfvf_struct pfvf;

//---------------------------------------------------------
//  BEGIN: Test Tasks and Utilities
//---------------------------------------------------------
parameter MAX_TEST = 100;
//parameter TIMEOUT = 1.5ms;
parameter TIMEOUT = 10.0ms;


typedef struct packed {
   logic result;
   logic [1024*8-1:0] name;
} t_test_info;

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
   pfvf = '{0,0,0}; // Set PFVF to PF0
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
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


task test_emif_calibration;
   localparam BAR = 0;
   output logic result;
   logic [63:0] scratch;
   logic [63:0] emif_capability;
   logic [63:0] emif_status;
   logic        error;
   logic [31:0] old_test_err_count;
   int 		cal_count;
   int 		addr;
   t_dfh    dfh;
   //int 		dfh_addr;
   uint64_t dfh_addr;
   logic 	dfh_found;
begin
   print_test_header("test_emif_calibration");

   // EMIF DFH discovery and check
   dfh_addr = DFH_START_OFFSET;
   dfh = '0;
   dfh_found = '0;
   while (~dfh.eol && ~dfh_found) begin
      host_bfm_top.host_bfm.read64(dfh_addr, scratch);
      dfh       = t_dfh'(scratch);
      dfh_found = (dfh.feat_id == EMIF_DFH_FEAT_ID);
      $display("\nDFH value: addr=0x%0x: next=0x%0x feat=0x%0x, dfh_found=%0x \n", dfh_addr, dfh_addr+dfh.nxt_dfh_offset, dfh.feat_id, dfh_found);      
      if(~dfh_found)
         dfh_addr  = dfh_addr + dfh.nxt_dfh_offset;
   end

   if(dfh_found) begin
      $display("EMIF_DFH");
      $display("   Address   (0x%0x)", dfh_addr);
      $display("   DFH value (0x%0x)\n", scratch);
   end else begin
      $display("\nERROR: Did not discover EMIF feature in DFH list\n");
      incr_err_count();
      result = 1'b0;
   end // else: !if(~dfh_found)

   if(dfh_found) begin
      // Read EMIF capability register for channel mask
      addr = dfh_addr + EMIF_CAPABILITY_OFFSET;
      host_bfm_top.host_bfm.read64(addr, emif_capability);
      $display("EMIF_CAPABILITY");
      $display("   Address   (0x%0x)", addr);
      $display("   STATUS value (0x%0x)\n", emif_capability);

      // Poll EMIF status while calibration completion != capability mask
      emif_status = 'h0;
      cal_count = 'h0;
      addr = dfh_addr + EMIF_STATUS_OFFSET;
      $display("Polling for EMIF calibration status completion: ");
      while ((emif_capability !== (emif_capability & emif_status)) && cal_count < 'h3) begin
         host_bfm_top.host_bfm.read64(addr, emif_status);
         $display("0x%0x\n", emif_status);
         cal_count = (emif_capability !== (emif_capability & emif_status)) ? 'h0 : cal_count + 1;
         #1000000;
      end

      $display("EMIF_STATUS");
      $display("   Address   (0x%0x)", addr);
      $display("   STATUS value (0x%0x)\n", emif_status);

      old_test_err_count = get_err_count();
      result = 1'b1;
   end // if (dfh_found)

   post_test_util(old_test_err_count);
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
 
   wait (test_done==1) begin
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


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
   begin
      $display("Entering HE-LB Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      pfvf = '{0,0,0}; // Set PFVF to PF0
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      
      `ifdef INCLUDE_DDR4
      // wait for mem_ss rst ack
      wait(top_tb.DUT.mem_ss_top.mem_ss_rst_ack_n == 1'b0);      
      // wiat for cal
      wait(top_tb.DUT.mem_ss_top.mem_ss_cal_success[0] == 1'b1);      
      test_emif_calibration ( test_result );
      `endif

   end
endtask


endmodule
