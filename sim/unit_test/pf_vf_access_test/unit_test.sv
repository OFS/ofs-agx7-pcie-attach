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
   $display("\n********************************************************");
   $display(" Running TEST(%0d) : %0s (vf_active=%0d, pfn=%0d vfn=%0d", test_id, test_name, vf_active, pfn, vfn);
   $display("*********************************************************\n");   
   test_summary[test_id].name = test_name;
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
   string    test_name;
   uint32_t  test_pfvf_type_index;
   uint64_t  scratchpad_lookup [uint128_t];
   uint64_t  address;
   uint64_t  guid_high, guid_low;
   uint128_t guid;
   logic     error;
   cpl_status_t cpl_status;
   logic [31:0] old_test_err_count;
   begin
      scratchpad_lookup = '{ uint128_t'(test_csr_defs::FME_GUID)     : FME_SCRATCH_ADDR,
		                       uint128_t'(test_csr_defs::HE_LB_GUID)   : HE_LB_SCRATCH_ADDR,
                             uint128_t'(test_csr_defs::HE_MEM_GUID)  : HE_MEM_SCRATCH_ADDR,
                             uint128_t'(test_csr_defs::HE_HSSI_GUID) : HE_HSSI_SCRATCH_ADDR,
                             uint128_t'(test_csr_defs::HE_NULL_GUID) : HE_NULL_SCRATCH_ADDR,
                             uint128_t'(test_csr_defs::VIO_GUID)     : VIO_SCRATCH_ADDR,
                             uint128_t'(test_csr_defs::CE_GUID)      : CE_SCRATCH_ADDR,
                             uint128_t'(test_csr_defs::MEM_TG_GUID)  : MEM_TG_SCRATCH_ADDR
                          };

      $display("Entering PF/VF Access Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);

      @(posedge clk iff (rst_n === 1'b1));
      repeat (20) @(posedge clk);
      for (test_pfvf_type_index = uint32_t'(pfvf_def_pkg::PF0); test_pfvf_type_index <= uint32_t'(pfvf_def_pkg::PF0_VF2); test_pfvf_type_index += 32'd1)
      begin
         host_bfm_top.host_bfm.set_pfvf_setting(pfvf_type_t'(test_pfvf_type_index));
         $sformat(test_name,"test_pf%0d_vf%0d_vfa%b_access", host_bfm_top.host_bfm.get_pf(), host_bfm_top.host_bfm.get_vf(), host_bfm_top.host_bfm.get_vf_active());
         print_test_header(test_name, host_bfm_top.host_bfm.get_pf(), host_bfm_top.host_bfm.get_vf(), host_bfm_top.host_bfm.get_vf_active());
         address = 'h08;
         host_bfm_top.host_bfm.read64_with_completion_status(address, guid_low, error, cpl_status);
         if (error)
         begin
            $display("\nERROR: Unexpected error reading GUID low word at Address:%H_%H_%H_%H   PF:%0d   VF:%0d   VFA:%0d   CplD Status:%-s", address[63:48], address[47:32], address[31:16], address[15:0], host_bfm_top.host_bfm.get_pf(), host_bfm_top.host_bfm.get_vf(), host_bfm_top.host_bfm.get_vf_active(), cpl_status.name());
            incr_err_count();
            test_result = 1'b0;
         end
         else
         begin
            address = 'h10;
            host_bfm_top.host_bfm.read64_with_completion_status(address, guid_high, error, cpl_status);
            if (error)
            begin
               $display("\nERROR: Unexpected error reading GUID low word at Address:%H_%H_%H_%H   PF:%0d   VF:%0d   VFA:%0d   CplD Status:%-s", address[63:48], address[47:32], address[31:16], address[15:0], host_bfm_top.host_bfm.get_pf(), host_bfm_top.host_bfm.get_vf(), host_bfm_top.host_bfm.get_vf_active(), cpl_status.name());
               incr_err_count();
               test_result = 1'b0;
            end
            else
            begin
               guid = {guid_high,guid_low};
               if (scratchpad_lookup.exists(guid))
               begin
                  old_test_err_count = get_err_count();
                  test_result = 1'b1;
                  print_test_header(test_name, host_bfm_top.host_bfm.get_pf(), host_bfm_top.host_bfm.get_vf(), host_bfm_top.host_bfm.get_vf_active());
                  $display("\nGUID: %H_%H_%H_%H_%H_%H_%H_%H   ScratchPad Address:%H_%H_%H_%H", guid[127:112], guid[111:96], guid[95:80], guid[79:64], guid[63:48], guid[47:32], guid[31:16], guid[15:0], scratchpad_lookup[guid][63:48], scratchpad_lookup[guid][47:32], scratchpad_lookup[guid][31:16], scratchpad_lookup[guid][15:0]);
                  test_csr_access_32(test_result, ADDR32, scratchpad_lookup[guid],     'h1111_2222);
                  test_csr_access_32(test_result, ADDR32, scratchpad_lookup[guid]+'h4, 'hAAAA_BBBB);
                  test_csr_access_64(test_result, ADDR64, scratchpad_lookup[guid],     'h1111_2222_AAAA_BBBB);
                  post_test_util(old_test_err_count);
               end
               else
               begin
                  $display("\nWARNING: No valid Test GUID found at address zero for   PF:%0d   VF:%0d   VFA:%0d", host_bfm_top.host_bfm.get_pf(), host_bfm_top.host_bfm.get_vf(), host_bfm_top.host_bfm.get_vf_active());
               end
            end
         end
      end

      repeat (10) @(posedge clk);
   end
endtask


endmodule
