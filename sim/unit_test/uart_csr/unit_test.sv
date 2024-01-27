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
PacketPUMsg       #(pf_type, vf_type, pf_list, vf_list) pmsg;
PacketPUVDM       #(pf_type, vf_type, pf_list, vf_list) pvdm;


Packet#(pf_type, vf_type, pf_list, vf_list) q[$];
Packet#(pf_type, vf_type, pf_list, vf_list) qr[$];


//---------------------------------------------------------
// Transaction Handles and Storage
//---------------------------------------------------------
Transaction       #(pf_type, vf_type, pf_list, vf_list) t;
ReadTransaction   #(pf_type, vf_type, pf_list, vf_list) rt;
WriteTransaction  #(pf_type, vf_type, pf_list, vf_list) wt;
AtomicTransaction #(pf_type, vf_type, pf_list, vf_list) at;
SendMsgTransaction#(pf_type, vf_type, pf_list, vf_list) mt;
SendVDMTransaction#(pf_type, vf_type, pf_list, vf_list) vt;

Transaction#(pf_type, vf_type, pf_list, vf_list) tx_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_active_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_completed_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_errored_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_history_transaction_queue[$];


//---------------------------------------------------------
// PFVF Structs 
//---------------------------------------------------------
pfvf_struct pfvf;

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



task test_csr;
   output logic result;
   logic [63:0] wr_data64;
   logic [63:0] rd_data64;
   logic [31:0] wr_data32_1;
   logic [31:0] wr_data32_2;
   logic [31:0] rd_data32;
   logic        error;
   logic [31:0] addr;
   logic [31:0] addr1;
   logic [31:0] addr2;
   logic [31:0] addr3;
   logic [31:0] addr4;
   reg [31:0]   counter = 0;
   cpl_status_t cpl_status;
   begin
      
      print_test_header("uart_csr_test");
      // ******************************************
      // Just read PG_UART_DFH (register 63,000 offset 0
      // ******************************************
      addr = PG_UART_DFH;
      $display("T:%8d INFO: TEST_PROGRAM %m About to read address 0x%0X.", $time, addr);
      //READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      host_bfm_top.host_bfm.read64_with_completion_status(addr, rd_data64, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m READ64 of Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      
      
      // ******************************************
      // Just read PG_UART_DFH (register 63,000 offset 8
      // ******************************************
      addr = PG_UART_DFH + 32'h8;
      $display("T:%8d INFO: TEST_PROGRAM %m About to read address 0x%0X.", $time, addr);
      //READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      host_bfm_top.host_bfm.read64_with_completion_status(addr, rd_data64, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      
      // ******************************************
      // Just read PG_UART_DFH (register 63,000 offset 10
      // ******************************************
      addr = PG_UART_DFH + 32'h10;
      $display("T:%8d INFO: TEST_PROGRAM %m About to read address 0x%0X.", $time, addr);
      //READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      host_bfm_top.host_bfm.read64_with_completion_status(addr, rd_data64, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      
      // ******************************************
      // Just read PG_UART_DFH (register 63,000 offset 18
      // ******************************************
      addr = PG_UART_DFH + 32'h18;
      $display("T:%8d INFO: TEST_PROGRAM %m About to read address 0x%0X.", $time, addr);
      //READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      host_bfm_top.host_bfm.read64_with_completion_status(addr, rd_data64, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      
      #8us;      
      //$finish;
      $display("T:%8d INFO: TEST_PROGRAM %m This was the finish.", $time);
      
      
      // ******************************************
      $display("T:%8d INFO: TEST_PROGRAM %m Write and read the scratch register PG_UART_DFH (register 63,000 offser 0xF0", $time);
      // ******************************************
      addr = PG_UART_DFH + 32'hF0;
      wr_data64 = {$urandom, $urandom};
      $display("T:%8d INFO: %m About to write Adress 0x%0X with 0x%0X.",$time, addr, wr_data64);
      //WRITE64(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data64);	
      host_bfm_top.host_bfm.write64(addr, wr_data64);
      $display("T:%8d INFO: %m Now we just write it, are just going to wait 8us for the heack of it.",$time, addr, wr_data64);
      #10us; 
      //READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      host_bfm_top.host_bfm.read64_with_completion_status(addr, rd_data64, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      if (rd_data64 != wr_data64) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data64, rd_data64);
         incr_err_count();
      end
      
      #8us;
      
      wr_data32_1 = $urandom;
      $display("T:%8d INFO: TEST_PROGRAM %m Write 32 bits to addr %x with %x, BAR:%x", $time, addr, wr_data32_2, BAR);
      //WRITE32(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data32_1);	
      host_bfm_top.host_bfm.write32(addr, wr_data32_1);
      $display("T:%8d INFO: TEST_PROGRAM %m First Write Done", $time);
      
      
      addr = PG_UART_DFH + 32'hF4;
      wr_data32_2 = $urandom;
      $display("T:%8d INFO: TEST_PROGRAM %m Write 32 bits to addr %x with %x, BAR:%x", $time, addr, wr_data32_2, BAR);
      //WRITE32(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data32_2);	
      host_bfm_top.host_bfm.write32(addr, wr_data32_2);
      $display("T:%8d INFO: TEST_PROGRAM %m Second Write Done", $time);
      
      addr = PG_UART_DFH + 32'hF0;
      //READ32(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data32, error);
      host_bfm_top.host_bfm.read32_with_completion_status(addr, rd_data32, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ32 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data32);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      if (rd_data32 != wr_data32_1) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data32_1, rd_data32);
         incr_err_count();
      end
      
      addr = PG_UART_DFH + 32'hF4;
      //READ32(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data32, error);
      host_bfm_top.host_bfm.read32_with_completion_status(addr, rd_data32, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ32 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data32);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      if (rd_data32 != wr_data32_2) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data32_2, rd_data32);
         incr_err_count();
      end
      
      addr = PG_UART_DFH + 32'hF0;
      //READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      host_bfm_top.host_bfm.read64_with_completion_status(addr, rd_data64, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      if (rd_data64 != {wr_data32_2, wr_data32_1}) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, {wr_data32_2, wr_data32_1}, rd_data64);
         incr_err_count();
      end
      
      #8us;
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m End of Task test_csr", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m Now read the first register of the vuart", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      
      
      for (addr = 32'h63204; addr < 32'h63400; addr = addr + 32'h4) begin
         if (addr != 32'h63218) begin // For some reason 0x218 returns X's on bits [7:0] also address 0x200 returns X's on bits 8:0.
            //READ32(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data32, error);
            host_bfm_top.host_bfm.read32_with_completion_status(addr, rd_data32, error, cpl_status);
            $display("T:%8d INFO: TEST_PROGRAM %m READ32 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data32);
            if (error) begin
               $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
               incr_err_count();
            end
         end
      end
      
      #7us;
      $display("T:%8d INFO: TEST_PROGRAM %m #####################################################################", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m ## BEGIN WRITING AND READING FROM the 8-BIT SCRATCH REGISTER 0x21C ##", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m #####################################################################", $time);
      addr = PG_UART_DFH + 32'h21C;
      repeat (10) begin
         wr_data32_1 = $urandom;
         wr_data32_1 = {24'h0, wr_data32_1[7:0]};
         $display("T:%8d INFO: TEST_PROGRAM %m #### WRITE 32 BITS TO ADDR %X WITH %X, BAR:%X ####", $time, addr, wr_data32_1, BAR);
         //WRITE32(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data32_1);	
         host_bfm_top.host_bfm.write32(addr, wr_data32_1);
         $display("T:%8d INFO: TEST_PROGRAM %m Write to 0x%X Done", $time, addr);
         
         //READ32(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data32, error);
         host_bfm_top.host_bfm.read32_with_completion_status(addr, rd_data32, error, cpl_status);
         $display("T:%8d INFO: TEST_PROGRAM %m READ32 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data32);
         if (error) begin
            $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
            incr_err_count();
         end
         if (wr_data32_1[7:0] != rd_data32[7:0]) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data32_1, rd_data32);
            incr_err_count();
         end
      end // repeat (10)
      
      addr1 = PG_UART_DFH + 32'h21c;
      addr2 = PG_UART_DFH + 32'h0f0;
      addr3 = PG_UART_DFH + 32'h0f0;
      #20us;
      $display("T:%8d INFO: TEST_PROGRAM %m #####################################################################", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m NOW DO A LOT OF WRITES AND WATCH FOR AN OVERFLOW.", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m #####################################################################", $time);
      fork
         begin         
            repeat (100) begin
               wr_data32_1 = $urandom;
               wr_data32_1 = {24'h0, wr_data32_1[7:0]};
               counter = counter + 32'h1;
               $display("T:%8d INFO: TEST_PROGRAM %m 1.### WRITE 8 BITS TO ADDR %X WITH %X, BAR:%X counter:%d ####", $time, addr1, wr_data32_1, BAR, counter);
               //WRITE32(ADDR32, addr1, BAR, 1'b0, 0, 0, wr_data32_1);	
               host_bfm_top.host_bfm.write32(addr1, wr_data32_1);
            end
         end
         begin
            repeat (100) begin
               wr_data64 = {$urandom, $urandom};
               counter = counter + 32'h1;
               $display("T:%8d INFO: TEST_PROGRAM %m 2.### WRITE 64 BITS TO ADDR %X WITH %X, BAR:%X counter:%d ####", $time, addr2, wr_data64, BAR, counter);
               //WRITE64(ADDR32, addr2, BAR, 1'b0, 0, 0, wr_data64);	
               host_bfm_top.host_bfm.write64(addr2, wr_data64);
            end
         end
         begin
            repeat (100) begin
               wr_data32_2 = $urandom;
               counter = counter + 32'h1;
               $display("T:%8d INFO: TEST_PROGRAM %m 3.### WRITE 32 BITS TO ADDR %X WITH %X, BAR:%X counter:%d ####", $time, addr3, wr_data32_2, BAR, counter);
               //WRITE32(ADDR32, addr3, BAR, 1'b0, 0, 0, wr_data32_2);	
               host_bfm_top.host_bfm.write32(addr3, wr_data32_2);
            end
         end
      join
      

      // ******************************************
      $display("T:%8d INFO: TEST_PROGRAM %m Check that we can still read and rwite data", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m Write and read the scratch register PG_UART_DFH (register 63,000 offser 0xF0", $time);
      // ******************************************
      addr = PG_UART_DFH + 32'hF0;
      wr_data64 = {$urandom, $urandom};
      $display("T:%8d INFO: %m About to write Adress 0x%0X with 0x%0X.",$time, addr, wr_data64);
      //WRITE64(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data64);	
      host_bfm_top.host_bfm.write64(addr, wr_data64);
      $display("T:%8d INFO: %m Now we just write it, are just going to wait 8us for the heack of it.",$time, addr, wr_data64);
      #10us; 
      //READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      host_bfm_top.host_bfm.read64_with_completion_status(addr, rd_data64, error, cpl_status);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         incr_err_count();
      end
      if (rd_data64 != wr_data64) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data64, rd_data64);
         incr_err_count();
      end
      




      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m End End End End End", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
   end
endtask


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
begin
   $display("Entering UART CSR Test.");
   host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
   host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
   pfvf = '{0,0,0}; // Set PFVF to PF0
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
   
    test_csr (test_result);
end
endtask

endmodule
