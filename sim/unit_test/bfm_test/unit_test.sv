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

Packet q[$];
Packet qr[$];


//---------------------------------------------------------
// Transaction Handles and Storage
//---------------------------------------------------------
Transaction       t;
ReadTransaction   rt;
WriteTransaction  wt;
AtomicTransaction at;

Transaction tx_transaction_queue[$];
Transaction tx_active_transaction_queue[$];
Transaction tx_completed_transaction_queue[$];
Transaction tx_errored_transaction_queue[$];
Transaction tx_history_transaction_queue[$];



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


// Memory loopback test util
task test_mem_loopback_util;
   output logic result;
   input  logic mem_display_on;
   input  logic [2:0]  test_mode;
   input  logic [3:0][511:0] test_data;
   input  logic [63:0] src_base_addr;
   input  logic [63:0] dst_base_addr;
   input  logic [63:0] dsm_base_addr;
   input  logic [1:0]  cl_mode;
   input  logic [16:0] num_cl; 
   
   logic [31:0] src_addr;
   logic [31:0] dst_addr;
   logic [31:0] wdata;
   logic [63:0] scratch;
   logic        err_src_addr;
   logic        err_dst_addr;
   byte_t       init_buf[];
   byte_t       read_buf[];
begin
   result = 1'b1;

   err_src_addr = |src_base_addr[5:0];
   err_dst_addr = |dst_base_addr[5:0];

   if (err_src_addr) 
   begin
      $display("Error: Source buffer address (0x%0x) is not aligned to cacheline boundary (64 bytes).", src_base_addr);
   end
   
   if (err_dst_addr) 
   begin
      $display("Error: Destination buffer address (0x%0x) is not aligned to cacheline boundary (64 bytes).", dst_base_addr);
   end

   result = ~(err_src_addr | err_dst_addr);

   if (~result) 
   begin
      incr_err_count();
   end 
   else 
   begin    
      $display("\n (1) Writing test data to source buffer starting at 0x%x", src_base_addr);
      for (int cl=0; cl<num_cl; ++cl) 
      begin
         for (int i=0; i<8; i=i+1) 
         begin
            src_addr = (src_base_addr+cl*64+i*8);
            dst_addr = (dst_base_addr+cl*64+i*8);
            // Write data to source buffer
            init_buf = new[8]; 
            init_buf = {<<byte_t{test_data[cl%4][i*64+:64]}};
            host_bfm_top.host_memory.initialize_data(src_addr, init_buf);
            // Clear destination buffer
            init_buf = new[8]; 
            init_buf = {<<byte_t{64'h0}};
            host_bfm_top.host_memory.initialize_data(dst_addr, init_buf);
         end
      end 
      
      // Clear DSM base address
      init_buf = new[8]; 
      init_buf = {<<byte_t{64'h0}};
      host_bfm_top.host_memory.initialize_data(dsm_base_addr, init_buf);
   
      if (mem_display_on) host_bfm_top.host_memory.dump_mem(src_base_addr, num_cl*64); // Bytes
          
      //-----------------------------------
      // Start memory loopback test
      //-----------------------------------
      
      $display("\n (2) Start memory loopback test");
      
      wdata = '0;
      wdata[0] = 1'b1;
      // Clear Reset & start bit
      host_bfm_top.host_bfm.write32(CTL, wdata);

      // Configure he-lb
      wdata = '0;
      wdata[6:5] = cl_mode;
      wdata[4:2] = test_mode;
      host_bfm_top.host_bfm.write32(CFG, wdata);
    
      // Configure number of CL for test
      wdata = '0;
      wdata[16:0] = num_cl-1;
      host_bfm_top.host_bfm.write32(NUM_LINES, wdata);
      
      // Configure inactivity threshold
      wdata = '0;
      wdata[31:0] = 32'h1000_0000;
      host_bfm_top.host_bfm.write32(INACT_THRESH, wdata);

      // SRC and DST addresses
      host_bfm_top.host_bfm.write64(SRC_ADDR, {'0, src_base_addr[31:6]});
      host_bfm_top.host_bfm.write64(DST_ADDR, {'0, dst_base_addr[31:6]});
  
      // DSM base address
      host_bfm_top.host_bfm.write64(DSM_BASEL, {'0, dsm_base_addr[31:6]});
     
      // Start the test
      wdata = '0;
      wdata[0] = 1'b1; // De-assert the reset bit.
      wdata[1] = 1'b1; // Set the start bit.
      host_bfm_top.host_bfm.write32(CTL, wdata);
  
      scratch = '0;
      while (~|scratch) 
      begin
         $display("(3) Polling for DSM completion bit to set");
         read_buf = new[4]; // Storage for 1DW of data.
         host_bfm_top.host_memory.read_data_host(dsm_base_addr, read_buf);
         scratch = {<<byte_t{read_buf}};
         if (~|scratch) 
         begin
            #1000000; // Delay to allow downstream MRd and MWr
         end
      end

      wdata = '0;
      // Reset & clear the start bit
      host_bfm_top.host_bfm.write32(CTL, wdata);

      $display("\n (4) Checking data at destination buffer starting at 0x%x", dst_base_addr);
      if (mem_display_on) host_bfm_top.host_memory.dump_mem(dst_base_addr, num_cl*64); // Bytes
   
      for (int cl=0; cl<num_cl; ++cl) begin
         for (int i=0; i<8; i=i+1) begin
            dst_addr = (dst_base_addr+cl*64+i*8);
            read_buf = new[8]; // Storage for 2DW of data in bytes.
            host_bfm_top.host_memory.read_data_host(dst_addr, read_buf);
            scratch = {<<byte_t{read_buf}};
            if (scratch !== test_data[cl%4][i*64+:64]) begin
               $display("\nERROR: write and read mismatch at address 0x%0x! write=0x%x read=0x%x\n", dst_addr, test_data[cl%4][i*64+:64], scratch);
               $display("\nERROR: Loopback test mismatch!\n");
               incr_err_count();
               result = 1'b0;
               break;
            end
         end // for (int i=0; i<8; i=i+1)
      end // for (int cl=0; cl<num_cl; ++cl)
   end
end
endtask


// Test HE-LB memory write/read 
task test_mem_loopback;
   output logic result;
   input  logic mem_display_on;
   input  logic [2:0]  test_mode;
   input  logic [1:0]  cl_mode;
   input  logic [16:0] num_cl;
   input  [1024*8-1:0] test_name;

   logic  [2:0]        cl_len;
   logic  [3:0][511:0] test_data;
   logic  [31:0] src_base_addr, dst_base_addr;
   logic  [31:0] dsm_base_addr;
   logic  [31:0] old_test_err_count;
   logic  err_cl_len;
begin
   print_test_header(test_name);
   old_test_err_count = get_err_count();
   result = 1'b1;

   // Check cl_mode and num_cl alignment
   cl_len = cl_mode + 1'd1;
   case (cl_mode)
      2'd2 : begin
         err_cl_len = num_cl[0];
      end
      2'd3 : begin
         err_cl_len = |num_cl[1:0];
      end
      default : begin
         err_cl_len = 1'b0;
      end
   endcase
      
   if (err_cl_len) 
   begin
      $display("Error: Number of CL (%0d) does not align with cl_mode (%0d), must be multiple of %0d.", num_cl, cl_mode, cl_len);
   end

   result = ~err_cl_len;

   if (~result) 
   begin
      incr_err_count();
   end 
   else 
   begin
      for (int cl=0; cl<4; ++cl) 
      begin
         // Hardcoded MWr and MRd test
         test_data[cl] = {{cl[3:0], 60'h8888888_88888888},
                          {cl[3:0], 60'h7777777_77777777},
                          {cl[3:0], 60'h6666666_66666666},
                          {cl[3:0], 60'h5555555_55555555},
                          {cl[3:0], 60'h4444444_44444444},
                          {cl[3:0], 60'h3333333_33333333},
                          {cl[3:0], 60'h2222222_22222222},
                          {cl[3:0], 60'h1111111_11111111}};
      end
      src_base_addr = 64'h0;
      dst_base_addr = 64'h0010_0000;
      dsm_base_addr = 64'h0020_0000;
      test_mem_loopback_util(result, mem_display_on, test_mode, test_data, src_base_addr, dst_base_addr, dsm_base_addr, cl_mode, num_cl);

   end
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
      $display("Begin Timeout Thread.");
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
   //@(posedge clk iff (rst_n === 1'b1));
   $display("MAIN Always - After Wait for rst_n.");
   wait (csr_rst_n);
   //@(posedge csr_clk iff (csr_rst_n === 1'b1));
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
      $display("Entering BFM Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      host_bfm_top.host_bfm.set_pfvf_setting(PF2);
      test_mem_loopback (test_result, 1, 3'h0, 2'h0, 17'd1, "test_mem_loopback: cl_mode (1CL), length (1)");
   end
endtask


endmodule
