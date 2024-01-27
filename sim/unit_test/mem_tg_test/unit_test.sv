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
       $display("\nERROR: CSR write and read mismatch! write=%H_%H_%H_%H read=%H_%H_%H_%H\n", data[63:48], data[47:32], data[31:16], data[15:0], scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);
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
       $display("\nERROR: Expected 32'h0 to be returned for unused CSR region, actual:%H_%H_%H_%H\n", scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);      
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
       $display("\nERROR: CSR write and read mismatch! write=%H_%H_%H_%H read=%H_%H_%H_%H\n", data[63:48], data[47:32], data[31:16], data[15:0], scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);
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
       $display("\nERROR: CSR read mismatch! expected=%H_%H_%H_%H actual=%H_%H_%H_%H\n", data[63:48], data[47:32], data[31:16], data[15:0], scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);
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
       $display("\nERROR: CSR read mismatch! expected=%H_%H_%H_%H actual=%H_%H_%H_%H\n", data[63:48], data[47:32], data[31:16], data[15:0], scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);
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
       $display("\nERROR: Expected 64'h0 to be returned for unused CSR region, actual:%H_%H_%H_%H\n", scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);      
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
       $display("\nERROR: CSR expected and read mismatch! expected=%H_%H_%H_%H read=%H_%H_%H_%H\n", data[63:48], data[47:32], data[31:16], data[15:0], scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);
       incr_err_count();
       result = 1'b0;
   end
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
   uint64_t dfh_next;
   logic 	dfh_found;
begin
   print_test_header("test_emif_calibration");
   pfvf = '{0,0,0}; // Set PFVF to PF0
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
   // EMIF DFH discovery and check
   dfh_addr = DFH_START_OFFSET;
   dfh = '0;
   dfh_found = '0;
   while (~dfh.eol && ~dfh_found) begin
      host_bfm_top.host_bfm.read64(dfh_addr, scratch);
      dfh       = t_dfh'(scratch);
      dfh_found = (dfh.feat_id == EMIF_DFH_FEAT_ID);
      dfh_next  = dfh_addr+dfh.nxt_dfh_offset;
      $display("\nDFH value: addr=%H_%H_%H_%H: next=%H_%H_%H_%H feat=%H, dfh_found=%H \n", dfh_addr[63:48], dfh_addr[47:32], dfh_addr[31:16], dfh_addr[15:0], dfh_next[63:48], dfh_next[47:32], dfh_next[31:16], dfh_next[15:0], dfh.feat_id, dfh_found);      
      if(~dfh_found)
         dfh_addr  = dfh_addr + dfh.nxt_dfh_offset;
   end
   if(dfh_found) begin
      $display("EMIF_DFH");
      $display("   Address...:%H_%H_%H_%H)", dfh_addr[63:48], dfh_addr[47:32], dfh_addr[31:16], dfh_addr[15:0]);
      $display("   DFH value.:%H_%H_%H_%H\n", scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);
      if (scratch !== EMIF_DFH_VAL) begin
         $display("\nERROR: DFH value mismatched, expected:%H_%H_%H_%H   actual:%H_%H_%H_%H\n", EMIF_DFH_VAL[63:48], EMIF_DFH_VAL[47:32], EMIF_DFH_VAL[31:16], EMIF_DFH_VAL[15:0], scratch[63:48], scratch[47:32], scratch[31:16], scratch[15:0]);      
         incr_err_count();
         result = 1'b0;
      end
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
      $display("   Address........:%H_%H_%H_%H", addr[63:48], addr[47:32], addr[31:16], addr[15:0]);
      $display("   EMIF Capability:%H_%H_%H_%H\n", emif_capability[63:48], emif_capability[47:32], emif_capability[31:16], emif_capability[15:0]);

      // Poll EMIF status while calibration completion != capability mask
      emif_status = 'h0;
      cal_count = 'h0;
      addr = dfh_addr + EMIF_STATUS_OFFSET;
      $display("Polling for EMIF calibration status completion: ");
      while ((emif_capability !== (emif_capability & emif_status)) && cal_count < 'h3) begin
         host_bfm_top.host_bfm.read64(addr, emif_status);
         $display("   %H_%H_%H_%H\n", emif_status[63:48], emif_status[47:32], emif_status[31:16], emif_status[15:0]);
         cal_count = (emif_capability !== (emif_capability & emif_status)) ? 'h0 : cal_count + 1;
         #1000000;
      end
      $display("EMIF_STATUS");
      $display("   Address.....:%H_%H_%H_%H", addr[63:48], addr[47:32], addr[31:16], addr[15:0]);
      $display("   STATUS value:%H_%H_%H_%H\n", emif_status[63:48], emif_status[47:32], emif_status[31:16], emif_status[15:0]);
      old_test_err_count = get_err_count();
      result = 1'b1;
   end // if (dfh_found)
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
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
 `ifdef INCLUDE_DDR4
   force {top_tb.DUT.mem_ss_top.mem_ss_inst.i1_app_ss_mm_awaddr[32]} = 1'b0;
   force {top_tb.DUT.mem_ss_top.mem_ss_inst.i0_app_ss_mm_awaddr[32]} = 1'b0;
   force {top_tb.DUT.mem_ss_top.mem_ss_inst.i1_app_ss_mm_araddr[32]} = 1'b0;
   force {top_tb.DUT.mem_ss_top.mem_ss_inst.i0_app_ss_mm_araddr[32]} = 1'b0;
 `endif
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


// Test AFU MMIO read write
task test_afu_mmio;
   output logic result;
   e_addr_mode  addr_mode;
   logic [63:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
begin
   print_test_header("test_afu_mmio");
   old_test_err_count = get_err_count();
   
   result      = 1'b1;
   addr_mode   = ADDR32;
   
   // AFU CSR
   // RO Register check
   test_csr_ro_access_64(result, addr_mode, AFU_DFH_ADDR, AFU_DFH_VAL);
   test_csr_ro_access_64(result, addr_mode, AFU_ID_L_ADDR, AFU_ID_L_VAL);
   test_csr_ro_access_64(result, addr_mode, AFU_ID_H_ADDR, AFU_ID_H_VAL);
   
   // RW access check using scratchpad
   test_csr_access_32(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0001);
   test_csr_access_64(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0003_AFC0_0002);

   // Test illegal memory read returns CPL
   test_unused_csr_access_32(result, addr_mode, MEM_TG_STAT_ADDR + 'h8, 'hF00D_0001);
   test_unused_csr_access_64(result, addr_mode, MEM_TG_STAT_ADDR + 'h8, 'hF00D_0003_F00D_0002);

   post_test_util(old_test_err_count);
end
endtask


// Test AFU MMIO read write
`ifdef INCLUDE_DDR4
task mem_tg_test;
   output logic result;

   input int 	loops;
   input int 	wr;
   input int 	rd;
   input int   bls;
   
   logic [63:0] mem_capability;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic [63:0] tg_status;
   real 	mem_bw;
   logic        error;
   logic [31:0] old_test_err_count;
   logic tg_active;
   int 	 ch;
   cpl_status_t cpl_status;
   enum {
       TG_ACTIVE_BIT,
       TG_TIMEOUT_BIT,
       TG_FAIL_BIT,
       TG_PASS_BIT
   } tg_stat_bit;
begin
   print_test_header("mem_tg_test");
   old_test_err_count = get_err_count();
   
   result      = 1'b1;
   addr_mode   = ADDR32;

   pfvf = '{0,2,1}; // Set PFVF to PF0-VF2
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);

   
   host_bfm_top.host_bfm.read64_with_completion_status(MEM_TG_CTRL_ADDR, mem_capability, error, cpl_status);

   $display("MEM_TG_CTRL");
   $display("   Address.......:%H_%H_%H_%H", MEM_TG_CTRL_ADDR[63:48], MEM_TG_CTRL_ADDR[47:32], MEM_TG_CTRL_ADDR[31:16], MEM_TG_CTRL_ADDR[15:0]);
   $display("   MEM Capability:%H_%H_%H_%H\n", mem_capability[63:48], mem_capability[47:32], mem_capability[31:16], mem_capability[15:0]);

   for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
   // Check TG Version
      host_bfm_top.host_bfm.read64_with_completion_status((ch+1)*MEM_TG_CFG_OFFSET + TG_VERSION, scratch, error, cpl_status);
      if(scratch != TG_VERSION_DEFAULT) begin
         $display("\nERROR: TG Version %d did not match expected %d\n",scratch, TG_VERSION_DEFAULT);
         incr_err_count();
         result = 1'b0;
      end

      host_bfm_top.host_bfm.write32((ch+1)*MEM_TG_CFG_OFFSET + TG_LOOP_COUNT,   loops);
      host_bfm_top.host_bfm.write32((ch+1)*MEM_TG_CFG_OFFSET + TG_WRITE_COUNT,  wr);
      host_bfm_top.host_bfm.write32((ch+1)*MEM_TG_CFG_OFFSET + TG_READ_COUNT,   rd);
      host_bfm_top.host_bfm.write32((ch+1)*MEM_TG_CFG_OFFSET + TG_BURST_LENGTH, bls);
      host_bfm_top.host_bfm.write32((ch+1)*MEM_TG_CFG_OFFSET + TG_ADDR_MODE_WR, 32'h2);

      host_bfm_top.host_bfm.read64_with_completion_status((ch+1)*MEM_TG_CFG_OFFSET + TG_LOOP_COUNT, scratch, error, cpl_status);
      if(scratch[31:0] != loops) begin
         $display("\nERROR: Unable to configure CH%0d TG_LOOP_COUNT exp=%d act=%d \n",ch,loops, scratch);
         incr_err_count();
         result = 1'b0;
      end
      host_bfm_top.host_bfm.read64_with_completion_status((ch+1)*MEM_TG_CFG_OFFSET + TG_WRITE_COUNT, scratch, error, cpl_status);
      if(scratch[31:0] != wr) begin
         $display("\nERROR: Unable to configure TG_WRITE_COUNT exp=%d act=%d \n",wr, scratch[31:0]);
         incr_err_count();
         result = 1'b0;
      end
      host_bfm_top.host_bfm.read64_with_completion_status((ch+1)*MEM_TG_CFG_OFFSET + TG_READ_COUNT, scratch, error, cpl_status);
      if(scratch[31:0] != rd) begin
         $display("\nERROR: Unable to configure TG_READ_COUNT exp=%d act=%d \n",rd, scratch[31:0]);
         incr_err_count();
         result = 1'b0;
      end
      host_bfm_top.host_bfm.read64_with_completion_status((ch+1)*MEM_TG_CFG_OFFSET + TG_BURST_LENGTH, scratch, error, cpl_status);
      if(scratch[31:0] != bls) begin
         $display("\nERROR: Unable to configure TG_BURST_LENGTH exp=%d act=%d \n",bls, scratch[31:0]);
         incr_err_count();
         result = 1'b0;
      end
      host_bfm_top.host_bfm.read64_with_completion_status((ch+1)*MEM_TG_CFG_OFFSET + TG_ADDR_MODE_WR, scratch, error, cpl_status);
      if(scratch[31:0] != 'h2) begin
         $display("\nERROR: Unable to configure TG_ADDR_MODE_WR exp=%d act=%d \n",32'h2, scratch[31:0]);
         incr_err_count();
         result = 1'b0;
      end

      //host_bfm_top.host_bfm.write64((ch+1)*MEM_TG_CFG_OFFSET + TG_START, 64'h1);
      host_bfm_top.host_bfm.write32((ch+1)*MEM_TG_CFG_OFFSET + TG_START, 32'h1);
   end // for (ch=0; mem_capability[ch] == 1'b1; ch=ch+1)
   
   // Poll TG status for completion
   tg_active = 1'b1;
   while(tg_active) begin
      tg_active = 1'b0;
      host_bfm_top.host_bfm.read64_with_completion_status(MEM_TG_STAT_ADDR, tg_status, error, cpl_status);
      $display("MEM_TG_STAT");
      $display("   Address.......: %H_%H_%H_%H", MEM_TG_STAT_ADDR[63:48], MEM_TG_STAT_ADDR[47:32], MEM_TG_STAT_ADDR[31:16], MEM_TG_STAT_ADDR[15:0]);
      //$display("   STATUS value (0x%0x)\n", mem_capability);
      $display("   MEM Capability: %H_%H_%H_%H", mem_capability[63:48], mem_capability[47:32], mem_capability[31:16], mem_capability[15:0]);
      $display("   TG Status.....: %H_%H_%H_%H", tg_status[63:48], tg_status[47:32], tg_status[31:16], tg_status[15:0]);
      for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
   	 if (tg_status[TG_ACTIVE_BIT+(4*ch)] == 1'b1) begin
   	    tg_active = 1'b1;
   	 end
      end
   end

   // Check TG test pass status
   #1000000; // Delay to allow ctrl/status synchronizers to settle
   host_bfm_top.host_bfm.read64_with_completion_status(MEM_TG_STAT_ADDR, tg_status, error, cpl_status);
   $display("MEM_TG_STAT - After time delay for ctrl/status synchronizers to settle.");
   $display("   Address.......: %H_%H_%H_%H", MEM_TG_STAT_ADDR[63:48], MEM_TG_STAT_ADDR[47:32], MEM_TG_STAT_ADDR[31:16], MEM_TG_STAT_ADDR[15:0]);
   $display("   MEM Capability: %H_%H_%H_%H", mem_capability[63:48], mem_capability[47:32], mem_capability[31:16], mem_capability[15:0]);
   $display("   TG Status.....: %H_%H_%H_%H", tg_status[63:48], tg_status[47:32], tg_status[31:16], tg_status[15:0]);

   for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
      if (tg_status[TG_PASS_BIT+(4*ch)] != 1'b1) begin
   	 $display("\nERROR: TG[%d] pass did not go high.\n",ch);
   	 incr_err_count();
   	 result = 1'b0;
      end
      if (tg_status[TG_TIMEOUT_BIT+(4*ch)] != 1'b0) begin
   	 $display("\nERROR: TG[%d] timeout bit wasn't 0 at test completion.\n",ch);
   	 incr_err_count();
   	 result = 1'b0;
      end
      if (tg_status[TG_FAIL_BIT+(4*ch)] != 1'b0) begin
   	 $display("\nERROR: TG[%d] fail bit wasn't 0 at test completion.\n",ch);
   	 incr_err_count();
   	 result = 1'b0;
      end
   end
   
   // Mem BW check
   for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
      host_bfm_top.host_bfm.read64_with_completion_status(MEM_TG_CLOCKS_OFFSET + (32'h8 * ch), tg_status, error, cpl_status);
      $display("\n TG[%d] clocks to completion: %d\n",ch,tg_status);
      mem_bw = (((real'(loops) * real'(rd) * real'(bls) * 64.0) / real'(tg_status))*0.3); // GB/s @ 300MHz
      $display("Rd BW = %0.3f GBps\n",mem_bw);
      mem_bw = (((real'(loops) * real'(wr) * real'(bls) * 64.0) / real'(tg_status))*0.3); // GB/s @ 300MHz
      $display("Wr BW = %0.3f GBps\n",mem_bw);
   end
   post_test_util(old_test_err_count);
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
end
endtask


task mem_tg_fail_test;
   output logic result;
   logic [63:0] mem_capability;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic [63:0] tg_status;
   logic        error;
   logic [31:0] old_test_err_count;
   logic vf_active;
   logic tg_active;
   int 	 ch;
   cpl_status_t cpl_status;
   enum {
       TG_ACTIVE_BIT,
       TG_TIMEOUT_BIT,
       TG_FAIL_BIT,
       TG_PASS_BIT
   } tg_stat_bit;
   //localparam NUM_TG = top_tb.DUT.afu_top.port_gasket.pr_slot.afu_main.NUM_MEM_CH;;
begin
   pfvf = '{0,2,1}; // Set PFVF to PF0-VF2
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
   print_test_header("mem_tg_fail_test");
   old_test_err_count = get_err_count();
   result      = 1'b1;
   addr_mode   = ADDR32;

   //READ64(ADDR32, MEM_TG_CTRL_ADDR, bar, vf_active, pfn, vfn, mem_capability, error);
   host_bfm_top.host_bfm.read64_with_completion_status(MEM_TG_CTRL_ADDR, mem_capability, error, cpl_status);

   // Trigger TG
   host_bfm_top.host_bfm.write64(MEM_TG_CTRL_ADDR, 'b1);
   $display("\nTurning on memory traffic generator ch 0");
   // Check that TG status went active
   #1000000; // Delay to allow ctrl/status synchronizers to settle
   host_bfm_top.host_bfm.read64_with_completion_status(MEM_TG_STAT_ADDR, tg_status, error, cpl_status);
   $display("MEM_TG_STAT - After time delay for ctrl/status synchronizers to settle.");
   $display("   Address.......: %H_%H_%H_%H", MEM_TG_STAT_ADDR[63:48], MEM_TG_STAT_ADDR[47:32], MEM_TG_STAT_ADDR[31:16], MEM_TG_STAT_ADDR[15:0]);
   $display("   MEM Capability: %H_%H_%H_%H", mem_capability[63:48], mem_capability[47:32], mem_capability[31:16], mem_capability[15:0]);
   $display("   TG Status.....: %H_%H_%H_%H", tg_status[63:48], tg_status[47:32], tg_status[31:16], tg_status[15:0]);
   if (tg_status[TG_ACTIVE_BIT] != 1'b1) begin
      $display("\nERROR: TG[0] active bit did not go high.\n");
      incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_TIMEOUT_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] timeout bit was not low at test start.\n");
      incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_FAIL_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] fail bit was not low at test start.\n");
      incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_PASS_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] pass bit was not low at test start.\n");
      incr_err_count();
      result = 1'b0;
   end
   // Force rd rsp data to 0 to trigger test failure
   // LHS must be a constant in force/release statements => constant index select
   // this test only runs on channel 0
  `ifdef INCLUDE_DDR4
   force top_tb.DUT.mem_ss_top.afu_mem_if[0].rdata = '0;
  `endif

   // Poll TG status for completion
   tg_active = 1'b1;
   while(tg_active) begin
      tg_active = 1'b0;
      host_bfm_top.host_bfm.read64_with_completion_status(MEM_TG_STAT_ADDR, tg_status, error, cpl_status);
      $display("MEM_TG_STAT");
      $display("   Address.......: %H_%H_%H_%H", MEM_TG_STAT_ADDR[63:48], MEM_TG_STAT_ADDR[47:32], MEM_TG_STAT_ADDR[31:16], MEM_TG_STAT_ADDR[15:0]);
      $display("   MEM Capability: %H_%H_%H_%H", mem_capability[63:48], mem_capability[47:32], mem_capability[31:16], mem_capability[15:0]);
      $display("   TG Status.....: %H_%H_%H_%H", tg_status[63:48], tg_status[47:32], tg_status[31:16], tg_status[15:0]);
      //for(ch=0; ch < NUM_TG; ch = ch+1) begin
      for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
         if (tg_status[TG_ACTIVE_BIT+(4*ch)] == 1'b1) begin
            tg_active = 1'b1;
         end
      end
   end
   // Check TG test pass status
   #1000000; // Delay to allow ctrl/status synchronizers to settle
   host_bfm_top.host_bfm.read64_with_completion_status(MEM_TG_STAT_ADDR, tg_status, error, cpl_status);
   if (tg_status[TG_FAIL_BIT] != 1'b1) begin
      $display("\nERROR: TG[0] FAIL did not go high.\n");
      incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_PASS_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] timeout bit wasn't 0 at fail test completion.\n");
      incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_TIMEOUT_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] timeout bit wasn't 0 at fail test completion.\n");
      incr_err_count();
      result = 1'b0;
   end
   // Release rd rsp data
  `ifdef INCLUDE_DDR4
   release top_tb.DUT.mem_ss_top.afu_mem_if[0].rdata;
  `endif
   post_test_util(old_test_err_count);
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
end
endtask
`endif


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
   localparam NUM_TEST_ITER = 2;
   int 	 itr;
   begin
      $display("Entering MEM-TG Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      pfvf = '{0,2,1}; // Set PFVF to PF0-VF2
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);

      // wait for cal
     `ifdef INCLUDE_DDR4
      wait(top_tb.DUT.mem_ss_top.mem_ss_cal_success[0] == 1'b1);
 
      test_emif_calibration ( test_result );
   
      pfvf = '{0,2,1}; // Set PFVF to PF0-VF2
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      test_afu_mmio (test_result); 
      for(itr=0; itr < NUM_TEST_ITER; itr = itr+1) begin
         $display("\nRunning write only test... \n");
         mem_tg_test (.result(test_result), .loops('d4), .wr('d10), .rd('d0), .bls('h4));
         $display("\nRunning read only test... \n");
         mem_tg_test (.result(test_result), .loops('d4), .wr('d0), .rd('d10), .bls('h4));
         $display("\nRunning write/read test... \n");
         mem_tg_test (.result(test_result), .loops('d4), .wr('d32), .rd('d32), .bls('h8));
      end
    `endif
   // mem_tg_fail_test (test_result);


   end
endtask


endmodule
