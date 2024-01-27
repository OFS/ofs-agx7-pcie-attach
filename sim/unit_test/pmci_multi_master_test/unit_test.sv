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


task test_mmio_addr32;
   output logic result;
begin
   print_test_header("test_mmio_addr32");
   test_mmio(result, ADDR32);
end
endtask

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
   
   //-----------
   // Test MMIO write stall issue
   //-----------
   host_bfm_top.host_bfm.write32(PMCI_FBM_AR, {8{4'h1}});
   host_bfm_top.host_bfm.write32(PMCI_FBM_AR, {8{4'h2}});
   @(posedge clk);
   host_bfm_top.host_bfm.write32(PMCI_FBM_AR, {8{4'h3}});
   test_csr_read_32(result, ADDR32, PMCI_FBM_AR, 'h03333333); // PMCI_FBM_AR RW range is 27:0
   
   host_bfm_top.host_bfm.write32(PMCI_FBM_AR, {8{4'h0}});
   host_bfm_top.host_bfm.write32(PMCI_FBM_AR, {8{4'hF}});

   //To improve the toggle percentage of Flash address varianble, all 0's and
   //all f's were written to the PMCI_FBM_AR   

   //$display("Print PMCI DFH register value");
   //   test_csr_read_64(result,addr_mode, PMCI_DFH, 0, 1'b0, 0, 0, 'h3000000010001012);
 
   $display("Test CSR access");
      test_csr_read_64(result,addr_mode, PMCI_DFH, 'h3000000200001012);
      test_csr_access_32(result, addr_mode, PMCI_FBM_AR, 'h0111_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_SEU_ERR, 'h1111_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_VDM_BA, 'h0004_2000);   
     // test_csr_access_32(result, addr_mode, PMCI_PCIE_SS_BA, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_HSSI_SS_BA, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_QSFPA_BA, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_QSFPB_BA, 'h0001_2222);   
      test_csr_access_32(result, addr_mode, PMCI_SPI_CSR, 'h0000_0002);   
      test_csr_access_32(result, addr_mode, PMCI_SPI_AR, 'h0000_2222);   
      test_csr_read_32(result, addr_mode, PMCI_SPI_RD_DR, 'h0);
      test_csr_access_32(result, addr_mode, PMCI_SPI_WR_DR, 'h1111_2222);   
      //test_csr_access_32(result, addr_mode, PMCI_FBM_FIFO, 'h1111_2222);   
      //test_csr_access_64(result, addr_mode, PMCI_VDM_FCR, 'h1111_2222_3333_4444);   
      //test_csr_access_64(result, addr_mode, PMCI_VDM_PDR, 'h1111_2222_3333_4444);   

   post_test_util(old_test_err_count);
end
endtask


// Test MMIO access with 64-bit address 
task test_pmci_multi_master_read;
   output logic result;
begin
   print_test_header("test_pmci_multi_master_read");
   test_pmci_mctp_multi_master_test(result, ADDR64);
end
endtask

task test_pmci_mctp_multi_master_test;

   output logic result;
   input e_addr_mode addr_mode;
   logic [31:0] scratch,ack;
   logic [31:0] cnt, rdcnt;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [62:0] rdata,wdata,exp_data;
   bit  [2:0]  hb_ctr;
   cpl_status_t cpl_status;

begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   $display("Test NIOS polling QSFP telemetry and MCTP triggering read-request to QSFP-B continously ");
   @(posedge clk);
   @(posedge clk);
   @(posedge clk);
     
      //WRITE32(ADDR32, PMCI_QSFP_BA, 0, 1'b0, 0, 0, 'h0001_2000);	
      //WRITE32(ADDR32, PMCI_QSFP2_BA, 0, 1'b0, 0, 0, 'h0001_3000);	
      host_bfm_top.host_bfm.write32(PMCI_QSFP_BA,  'h0001_2000);
      host_bfm_top.host_bfm.write32(PMCI_QSFP2_BA, 'h0001_3000);
        fork
        begin
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h0;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h3333_2222_0000_440d; // shadow_csr[100]->'h0d
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h100 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h2;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h002d_0000_0000_0000; // shadow_csr[116]->'h2d,shadow_csr[117]-> 'h0
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h114 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h3;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_0000_feff_2211; // shadow_csr[11A]->'hff,shadow_csr[11b]->'hff
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h118 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h0;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_0000_0000_000d; // shadow_csr[102]->'h0
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h100 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'd48;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_005a_0000_005f; // shadow_csr[280]->'h5f ,shadow_csr[281]->'h0, shadow_csr[284]-> 'h5a,shadow_csr[285]->'h0
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h284 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
        #10ms;
        end
        begin
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h0;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h3333_2222_0000_440d; // shadow_csr[100]->'h0d
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h100 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h2;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h002d_0000_0000_0000; // shadow_csr[116]->'h2d,shadow_csr[117]-> 'h0
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h114 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h3;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_0000_feff_1122; // shadow_csr[11A]->'hff,shadow_csr[11b]->'hff
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h118 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h0;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_0000_0000_000d; // shadow_csr[102]->'h0
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h100 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'd48;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_005a_0000_005f; // shadow_csr[280]->'h5f ,shadow_csr[281]->'h0, shadow_csr[284]-> 'h5a,shadow_csr[285]->'h0
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h284 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);

        #10ms;
        end
        begin
          forever
          begin @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.in_clk_clk);  
            force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata = (top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_address == 'h2)?'h20 : top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata;
            force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata = (top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_address == 'h8)?'h01 : top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata;    
            force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata = (top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_address == 'h6)?'h19 : top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata;
            force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata = (top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_address == 'h5)?'h0 : top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata;
          end
        end
	begin
	forever
	begin @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.clk) ;
          @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.axi_m_bridge.aresetn);
          #200us;
         if( top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_waitreq==1 ) begin
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_addr[19:0] = 'h13028;
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_read = 'h1;
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_byteen[7:0] = 'hf;
         end
         else begin 
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_addr[19:0] = 'h13028;
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_read = 'h0; //change read to 0 when waitreq is low
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_byteen[7:0] = 'hf;
         end  
	end
	end
        begin
          //#4.2ms;
          //check whether pmci_nios_hb signal is rising.if it's rising twice read the telemetry register values from mailbox
          while(hb_ctr!='h2) begin
            @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.pmci_csr.pmci_csr_0.pmci_nios_hb) begin
              hb_ctr=hb_ctr+1;
            end
          end
        end
        join_any


        //READ MAILBOX VALUES FROM THE HOST//
 
         for (int i=0;i<4;i++) begin

           wdata = 'h8000_1048 + 'h4*i;
           //WRITE32(ADDR32, PMCI_SPI_AR, 0, 1'b0, 0, 0, wdata);	
           //WRITE32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0001);	
           host_bfm_top.host_bfm.write32(PMCI_SPI_AR, wdata);
           host_bfm_top.host_bfm.write32(PMCI_SPI_CSR, 'h0000_0001);

           do begin
             //READ32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, ack, error);	
             host_bfm_top.host_bfm.read32_with_completion_status(PMCI_SPI_CSR, ack, error, cpl_status);
           end while(ack[2] != 1'b1);

           //READ32(ADDR32, PMCI_SPI_RD_DR, 0, 1'b0, 0, 0, rdata, error);	
           host_bfm_top.host_bfm.read32_with_completion_status(PMCI_SPI_RD_DR, rdata, error, cpl_status);
           if(i==0||i==2) begin
              exp_data ='d180;
           end
           else if (i==1||i==3) begin
              exp_data ='d190;
           end
         
           if(rdata[31:0] == exp_data) begin
              $display("DATA MATCH:Value written to %h is %d",wdata,exp_data);
           end else begin
              $display("PMCI_ERROR:Value written to %h is %d",wdata,rdata);
              incr_err_count();
              result = 1'b0;
           end

           //WRITE32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0000);	
           host_bfm_top.host_bfm.write32(PMCI_SPI_CSR, 'h0000_0000);
           
         end

         for (int i=0;i<4;i++) begin

           wdata = 'h8000_10b0 + 'h4*i;
           //WRITE32(ADDR32, PMCI_SPI_AR, 0, 1'b0, 0, 0, wdata);	
           //WRITE32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0001);	
           host_bfm_top.host_bfm.write32(PMCI_SPI_AR, wdata);
           host_bfm_top.host_bfm.write32(PMCI_SPI_CSR, 'h0000_0001);

           do begin
             //READ32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, ack, error);	
             host_bfm_top.host_bfm.read32_with_completion_status(PMCI_SPI_CSR, ack, error, cpl_status);
           end while(ack[2] != 1'b1);

           //READ32(ADDR32, PMCI_SPI_RD_DR, 0, 1'b0, 0, 0, rdata, error);	
           host_bfm_top.host_bfm.read32_with_completion_status(PMCI_SPI_RD_DR, rdata, error, cpl_status);
           if(i==0||i==2) begin
              exp_data ='d90;
           end
           else if (i==1||i==3) begin
              exp_data ='d6553;
           end
         
           if(rdata[31:0] == exp_data) begin
              $display("DATA MATCH:Value written to %h is %d",wdata,exp_data);
           end else begin
              $display("PMCI_ERROR:Value written to %h is %d",wdata,rdata);
              incr_err_count();
              result = 1'b0;
           end

           //WRITE32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0000);
           host_bfm_top.host_bfm.write32(PMCI_SPI_CSR, 'h0000_0000);
	
        end 
 

    #100us;
    post_test_util(old_test_err_count);
    //$system("rm -rf ../../../../../pmci_ss_nios_fw.hex");
    //$system("rm -rf ../../../../../pmci_ss_nios_fw.ver");
		
end
endtask


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
   begin
      $display("Entering PMCI CSR Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      pfvf = '{0,0,0}; // Set PFVF to PF0
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);

      test_pmci_multi_master_read(test_result);
   end
endtask


endmodule
