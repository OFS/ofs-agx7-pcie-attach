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
import flr_def_pkg::*;
import host_memory_class_pkg::*;
import tag_manager_class_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;
import host_axis_send_class_pkg::*;
import host_axis_receive_class_pkg::*;
import host_transaction_class_pkg::*;
import host_bfm_class_pkg::*;
import host_flr_class_pkg::*;
import test_csr_defs::*;


//---------------------------------------------------------
//  BEGIN: Test Tasks and Utilities
//---------------------------------------------------------
parameter MAX_TEST = 100;
parameter TIMEOUT = 10.0ms;
parameter RP_MAX_TAGS = 64;

typedef struct packed {
   logic result;
   logic [1024*8-1:0] name;
} t_test_info;

typedef enum bit [1:0] {MWR, MRD, CPLD, CPL} e_tlp_type;
typedef enum bit {ADDR32, ADDR64} e_addr_mode;
typedef enum bit {BIG_ENDIAN, LITTLE_ENDIAN} e_endian;

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
   input logic        vf_active;
   input logic [2:0]  pfn;
   input logic [10:0] vfn;
begin
   $display("\n********************************************");
   $display(" Running TEST(%0d) : %0s (vf_active=%0d, pfn=%0d vfn=%0d", test_id, test_name, vf_active, pfn, vfn);
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
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf_def_pkg::PF0);
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
      $display("Begin Timeout Thread.  Test will timeout in %0t\n", TIMEOUT);
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
   #10000;
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

   string test_name;
   uint32_t test_flr_type_index;
   HostFLREvent flr;
   logic [31:0] old_test_err_count;

   begin
      $display("Entering FLR Test.");
      @(posedge clk iff (rst_n === 1'b1));
      repeat (20) @(posedge clk);
      for (test_flr_type_index = uint32_t'(flr_def_pkg::PF0); test_flr_type_index < uint32_t'(flr_def_pkg::NUM_OF_FLR_FUNCTIONS); test_flr_type_index += 32'd1)
      begin
         host_flr_top.flr_manager.send_flr(flr_type_t'(test_flr_type_index));
         flr = host_flr_top.flr_manager.flrs[$];
         $sformat(test_name,"test_pf%0d_vf%0d_vfa%b_flr", flr.get_pf(), flr.get_vf(), flr.get_vf_active());
         print_test_header(test_name, flr.get_vf_active(), flr.get_pf(), flr.get_vf());
         old_test_err_count = get_err_count();
         while (host_flr_top.flr_manager.num_all_outstanding_flrs() > 0 )
         begin
            @(posedge clk);
         end
         post_test_util(old_test_err_count);
      end
      $display(">>> All Sent FLRs <<<");
      host_flr_top.flr_manager.print_all_sent_flrs();
      $display("");
      $display(">>> All Outstanding FLRs <<<");
      host_flr_top.flr_manager.print_all_outstanding_flrs();
      $display("");
      $display(">>> All Unmatched FLR Responses <<<");
      host_flr_top.flr_manager.print_all_unmatched_responses();
      $display("");
      if (host_flr_top.flr_manager.num_all_outstanding_flrs() == 0)
      begin
         test_result = 1'b1;
      end

      repeat (10) @(posedge clk);
   end
endtask


endmodule
