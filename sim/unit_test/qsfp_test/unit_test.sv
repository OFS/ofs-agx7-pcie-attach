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


// Test MMIO access with 64-bit address 
task test_mmio_addr64;
   output logic result;
begin
   print_test_header("test_mmio_addr64");
   test_mmio(result, ADDR64);
end
endtask

// Test memory write 32-bit address 
task test_mmio;
   output logic result;
   input e_addr_mode addr_mode;
   logic [63:0] base_addr;
   logic [63:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
begin

   old_test_err_count = get_err_count();
   result = 1'b1;

   $display("\n------------------------------------");
   $display("Test CSR access to QSFP0 CSR region");
   $display("------------------------------------\n");
      test_csr_read_64(result, addr_mode, QSFP0_DFH, QSFP0_DFH_VALUE);   
      test_csr_access_64(result, addr_mode, QSFP0_DFH + SCRATCHPAD_OFFSET, 'h1111_2222_3333_4444);
      test_csr_access_64(result, addr_mode, QSFP0_DFH + CTRL_OFFSET, 'h0A);
      test_csr_access_64(result, addr_mode, QSFP0_DFH + CTRL_OFFSET, 'h15);
      // I2C
      test_csr_access_32(result, addr_mode, QSFP0_DFH + I2C_BASE_OFFSET+CTRL, 'h15);
      test_csr_access_32(result, addr_mode, QSFP0_DFH + I2C_BASE_OFFSET+CTRL, 'h2A);
      test_csr_access_32(result, addr_mode, QSFP0_DFH + I2C_BASE_OFFSET+ISER, 'h15);
      test_csr_access_32(result, addr_mode, QSFP0_DFH + I2C_BASE_OFFSET+ISER, 'h0A);
      test_csr_access_32(result, addr_mode, QSFP0_DFH + I2C_BASE_OFFSET+SCL_LOW, 'h12C0);
      test_csr_access_32(result, addr_mode, QSFP0_DFH + I2C_BASE_OFFSET+SCL_HIGH, 'h12C1);
      test_csr_access_32(result, addr_mode, QSFP0_DFH + I2C_BASE_OFFSET+SCL_HIGH, 'h12C2);
      test_csr_read_32(result, addr_mode, QSFP0_DFH + I2C_BASE_OFFSET+STATUS, 'h1);

   $display("\n------------------------------------");
   $display("Test CSR access to QSFP1 CSR region");
   $display("------------------------------------\n");
      test_csr_read_64(result, addr_mode, QSFP1_DFH, QSFP1_DFH_VALUE);   
      test_csr_access_64(result, addr_mode, QSFP1_DFH + SCRATCHPAD_OFFSET, 'hAAAA_BBBB_CCCC_DDDD);
      test_csr_access_64(result, addr_mode, QSFP1_DFH + CTRL_OFFSET, 'h0A);
      test_csr_access_64(result, addr_mode, QSFP1_DFH + CTRL_OFFSET, 'h15);
      // I2C
      test_csr_access_32(result, addr_mode, QSFP1_DFH + I2C_BASE_OFFSET+CTRL, 'h15);
      test_csr_access_32(result, addr_mode, QSFP1_DFH + I2C_BASE_OFFSET+CTRL, 'h2A);
      test_csr_access_32(result, addr_mode, QSFP1_DFH + I2C_BASE_OFFSET+ISER, 'h15);
      test_csr_access_32(result, addr_mode, QSFP1_DFH + I2C_BASE_OFFSET+ISER, 'h0A);
      test_csr_access_32(result, addr_mode, QSFP1_DFH + I2C_BASE_OFFSET+SCL_LOW, 'h13C0);
      test_csr_access_32(result, addr_mode, QSFP1_DFH + I2C_BASE_OFFSET+SCL_HIGH, 'h13C1);
      test_csr_access_32(result, addr_mode, QSFP1_DFH + I2C_BASE_OFFSET+SCL_HIGH, 'h13C2);
      test_csr_read_32(result, addr_mode, QSFP1_DFH + I2C_BASE_OFFSET+STATUS, 'h1);

   post_test_util(old_test_err_count);
end
endtask

// Test AFU MMIO read 
task test_afu_mmio;
   output logic result;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [4:0][31:0] unsupported_addr_vec;
   cpl_status_t cpl_status;
begin
   print_test_header("test_afu_mmio");
   old_test_err_count = get_err_count();
   
   result = 1'b1;
   addr_mode = ADDR32;

   host_bfm_top.host_bfm.set_pfvf_setting(PF2);

   // AFU CSR
   test_csr_access_32(result, addr_mode, 32'h41000, 'hAFC0_0001);   
   test_csr_access_64(result, addr_mode, 32'h41020, 'hAFC0_0003_AFC0_0002);  

   // AFU unsupported address range should return 0
   unsupported_addr_vec[0] = 32'h40030;
   unsupported_addr_vec[1] = 32'h41200;
   unsupported_addr_vec[2] = 32'h42060;
   unsupported_addr_vec[3] = 32'h43030;
   unsupported_addr_vec[4] = 32'h44000;
   for (int i=0; i<5; ++i) begin
      addr = unsupported_addr_vec[i];
      //WRITE64(addr_mode, addr, 2, 1'b0, 0, 0, 64'h1234_5678_9abc_def0); 
      host_bfm_top.host_bfm.write64(addr, 64'h1234_5678_9abc_def0);
      host_bfm_top.host_bfm.set_pfvf_setting(PF0);
      test_csr_read_64(result, addr_mode, addr, 'h0);
      if (~result) begin
         $display("Error: MMIO read to unsupported AFU address (addr=0x%0x) doesn't return 0.", addr);
      end
   end
   
   // Test illegal memory read returns CPL
      // misaligned address
   //READ64(addr_mode, 32'h41001, 2, 1'b0, 0, 0, scratch, error);
   host_bfm_top.host_bfm.read64_with_completion_status(32'h41001, scratch, error, cpl_status);
   if (~error) begin
       $display("\nERROR: MMIO read with unaligned address did not return CPL with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end
      // illegal length
   //CSR_READ(addr_mode, 32'h41000, 10'd16, 2, 1'b0, 0, 0, scratch, error);
   host_bfm_top.host_bfm.read64_with_completion_status(32'h41000, scratch, error, cpl_status);
   if (~error) begin
       $display("\nERROR: MMIO read with illegal length did not return CPL with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end

   post_test_util(old_test_err_count);
end
endtask


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
begin
   $display("Entering QSFP Test.");
   host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
   host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
   host_bfm_top.host_bfm.set_pfvf_setting(PF0);
   
   // test_mmio_addr32   (test_result);
   test_mmio_addr64   (test_result);
end
endtask


endmodule
