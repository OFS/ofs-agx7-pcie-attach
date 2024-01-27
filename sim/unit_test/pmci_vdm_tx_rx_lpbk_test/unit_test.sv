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


task test_vdm_msg;

   output logic result;
   input e_addr_mode addr_mode;
   logic [63:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;

   $display("Test VDM RX path starts");
      //WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h1}});	
      //WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h2}});	 
   host_bfm_top.host_bfm.write32(PMCI_FBM_AR, {8{4'h1}});
   host_bfm_top.host_bfm.write32(PMCI_FBM_AR, {8{4'h2}});
   @(posedge clk);
      //WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h3}});	
   host_bfm_top.host_bfm.write32(PMCI_FBM_AR, {8{4'h3}});
   test_csr_read_64(result,addr_mode, ST2MM_DFH, 'h3000000200000014);
      //create_vdm_msg_packet('h1,'d16,'h7f,'h1ab4);
   vdm_buf = {<<8{{<<32{ {16{32'hC0DE_1234}} }}}}; // Stream data into dynamic array little endian by byte by 32-bit words.
   host_bfm_top.host_bfm.send_vdm(
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .msg_data(vdm_buf)
   );
   test_csr_access_64(result, addr_mode, ST2MM_SCRATCHPAD, 'h1111_2222_3333_4444);   
      //create_vdm_msg_packet('h1,'d13,'h7f,'h1ab4);
   vdm_buf = {<<8{{<<32{ {13{32'hC0DE_1234}} }}}}; // Stream data into dynamic array little endian by byte by 32-bit words.
   host_bfm_top.host_bfm.send_vdm(
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .msg_data(vdm_buf)
   );
   test_csr_access_64(result, addr_mode, ST2MM_SCRATCHPAD, 'hAAAA_BBBB_CCCC_DDDD);   
      //create_vdm_msg_packet('h1,'d1,'h7f,'h1ab4);
   vdm_buf = {<<8{{<<32{ {1{32'hC0DE_1234}} }}}}; // Stream data into dynamic array little endian by byte by 32-bit words.
   host_bfm_top.host_bfm.send_vdm(
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .msg_data(vdm_buf)
   );
   test_csr_access_32(result, addr_mode, PMCI_FBM_AR, 'h0111_2222);   
      //create_vdm_msg_packet('h1,'d5,'h7f,'h1ab4);
   vdm_buf = {<<8{{<<32{ {5{32'hC0DE_1234}} }}}}; // Stream data into dynamic array little endian by byte by 32-bit words.
   host_bfm_top.host_bfm.send_vdm(
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .msg_data(vdm_buf)
   );
   test_csr_access_32(result, addr_mode, PMCI_SPI_CSR, 'h0000_0002);   
      //create_vdm_msg_packet('h1,'d10,'h7f,'h1ab4);
   vdm_buf = {<<8{{<<32{ {10{32'hC0DE_1234}} }}}}; // Stream data into dynamic array little endian by byte by 32-bit words.
   host_bfm_top.host_bfm.send_vdm(
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .msg_data(vdm_buf)
   );
   test_csr_access_32(result, addr_mode, PMCI_SPI_AR, 'h0000_2222);   
      //create_vdm_msg_packet('h1,'d2,'h7f,'h1ab4);
   vdm_buf = {<<8{{<<32{ {2{32'hC0DE_1234}} }}}}; // Stream data into dynamic array little endian by byte by 32-bit words.
   host_bfm_top.host_bfm.send_vdm(
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .msg_data(vdm_buf)
   );
   test_csr_access_32(result, addr_mode, PMCI_SPI_WR_DR, 'h1111_2222);   
      //create_vdm_msg_packet('h1,'d4,'h7f,'h1ab4);
   vdm_buf = {<<8{{<<32{ {4{32'hC0DE_1234}} }}}}; // Stream data into dynamic array little endian by byte by 32-bit words.
   host_bfm_top.host_bfm.send_vdm(
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .msg_data(vdm_buf)
   );
   $display("Test VDM RX path ends");
   #50us;
     
    post_test_util(old_test_err_count);
		
end
endtask


//creating MCTP multipacket VDM message 
task create_vdm_multimsg_err_packet;
   input logic [9:0]   length;
   input logic [31:0]  upper_msg;
   bit local_som;
   bit local_eom;
   bit [1:0] local_psn;
   bit [7:0] local_destination_endpoint_id;
   bit [7:0] local_source_endpoint_id;
   bit local_tag_owner;
   bit [2:0] local_message_tag;
   logic [31:0] msg_word  = 32'hC0DE_1234;
   logic [31:0] msg_words[$];
begin 
   local_destination_endpoint_id = upper_msg[23:16];
   local_source_endpoint_id      = upper_msg[15:8];
   local_som = upper_msg[7];
   local_eom = upper_msg[6];
   local_psn = upper_msg[5:4];
   local_tag_owner = upper_msg[3];
   local_message_tag = upper_msg[2:0];
   
   //$display("Length: %0d", length);

   msg_words.delete();  // Clear queue.
   for (int i = 0; i < int'(length); i++)
   begin
      msg_words.push_back(msg_word);  // Word replication when used with streaming operator below.
      //$display("Loop pass: %0d", i);
   end

   //$display("Message Word: %H", msg_word);
   //$display("Message Words:");
   //$display(msg_words);

   vdm_buf = {<<8{{<<32{ msg_words }}}}; // Stream data into dynamic array little endian by byte by 32-bit words from queue.

   //$display("VDM Buf: ");
   //$display(vdm_buf);
   vt = new(
      .access_source("Unit Test"),
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .length_dw(length)
   );
   vt.request_packet.set_data(vdm_buf);
   vt.request_packet.set_mctp_destination_endpoint_id(local_destination_endpoint_id);
   vt.request_packet.set_mctp_source_endpoint_id(local_source_endpoint_id);
   vt.request_packet.set_mctp_som(local_som);
   vt.request_packet.set_mctp_eom(local_eom);
   vt.request_packet.set_mctp_packet_sequence_number(local_psn);
   vt.request_packet.set_mctp_tag_owner(local_tag_owner);
   vt.request_packet.set_mctp_message_tag(local_message_tag);
   $display("Sending the following VDM MCTP Message Packet:");
   vt.print_data();
   t = vt;

   $display("   ** Start Sending VDM TLP message packets **");
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
   host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   $display("   ** End Sending VDM TLP message packets **");
end
endtask


//creating MCTP multipacket VDM message 
task create_vdm_err_packet;
   input logic [31:0]  upper_msg;
   input logic [2:0]   tc;
   input logic         th;
   input logic         ep;
   input logic [1:0]   attr;
   input logic         rsvd1; // RorT9 in VDM TLP
   input logic [2:0]   rsvd2; // RorT8 in VDM TLP
   input logic [1:0]   rsvd3; // RorAT in VDM TLP
   input logic [7:0]   tag;
   input logic [1:0]   len_mis; 
   bit [9:0] local_tag10;
   bit local_tc;
   bit local_th;
   bit local_ep;
   bit [2:0] local_attr;
   bit local_ln;
   bit [1:0] local_at;
   bit [3:0] local_mctp_vdm_code;
   bit local_som;
   bit local_eom;
   bit [1:0] local_psn;
   bit [3:0] local_header_version;
   bit [7:0] local_destination_endpoint_id;
   bit [7:0] local_source_endpoint_id;
   bit local_tag_owner;
   bit [2:0] local_message_tag;
   logic [31:0] msg_word  = 32'hC0DE_1234;
   logic [31:0] msg_words[$];
   logic [9:0] length;
begin 
   //---------- DW3 Fields --------------------------
   local_header_version = upper_msg[27:24];
   local_destination_endpoint_id = upper_msg[23:16];
   local_source_endpoint_id      = upper_msg[15:8];
   local_som = upper_msg[7];
   local_eom = upper_msg[6];
   local_psn = upper_msg[5:4];
   local_tag_owner = upper_msg[3];
   local_message_tag = upper_msg[2:0];
   //---------- DW0/DW1 Fields ----------------------
   local_tag10 = {rsvd1,rsvd2[2],8'h00};
   local_tc = tc;
   local_th = th;
   local_ep = ep;
   local_attr = {rsvd2[1],attr};
   local_ln = rsvd2[0];
   local_at = rsvd3;
   local_mctp_vdm_code = tag[3:0];
  
   if (len_mis == 2'b00)
   begin
      length = 10'd16;
   end
   else
   begin
      if (len_mis == 2'b01)
      begin
         length = 10'd10;
      end
      else
      begin
         length = 10'd20;
      end
   end

   //$display("Length: %0d", length);

   msg_words.delete();  // Clear queue.
   for (int i = 0; i < int'(length); i++)
   begin
      msg_words.push_back(msg_word);  // Word replication when used with streaming operator below.
      //$display("Loop pass: %0d", i);
   end

   //$display("Message Word: %H", msg_word);
   //$display("Message Words:");
   //$display(msg_words);

   vdm_buf = {<<8{{<<32{ msg_words }}}}; // Stream data into dynamic array little endian by byte by 32-bit words from queue.

   //$display("VDM Buf: ");
   //$display(vdm_buf);
   vt = new(
      .access_source("Unit Test"),
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'h0000),
      .vendor_id(16'h1AB4),
      .length_dw(length)
   );
   //---------- DW3 Fields --------------------------
   vt.request_packet.set_data(vdm_buf);
   vt.request_packet.set_mctp_header_version(local_header_version);
   vt.request_packet.set_mctp_destination_endpoint_id(local_destination_endpoint_id);
   vt.request_packet.set_mctp_source_endpoint_id(local_source_endpoint_id);
   vt.request_packet.set_mctp_som(local_som);
   vt.request_packet.set_mctp_eom(local_eom);
   vt.request_packet.set_mctp_packet_sequence_number(local_psn);
   vt.request_packet.set_mctp_tag_owner(local_tag_owner);
   vt.request_packet.set_mctp_message_tag(local_message_tag);
   //---------- DW0/DW1 Fields ----------------------
   vt.request_packet.set_tag(local_tag10);
   vt.request_packet.set_tc(local_tc);
   vt.request_packet.set_th(local_th);
   vt.request_packet.set_ep(local_ep);
   vt.request_packet.set_attr(local_attr);
   vt.request_packet.set_ln(local_ln);
   vt.request_packet.set_at(local_at);
   vt.request_packet.set_mctp_vdm_code(local_mctp_vdm_code);
   $display("Sending the following VDM MCTP Message Packet:");
   vt.print_data();
   t = vt;

   $display("   ** Start Sending VDM TLP message packets **");
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
   host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   $display("   ** End Sending VDM TLP message packets **");
end
endtask


// Test VDM Error scenarios for multi packet
task test_vdm_err_test;
   output logic result;
begin
   print_test_header("test_vdm_err_test");
   test_vdm_tlp_hdr1_dw0_err_test(result);
   test_vdm_tlp_hdr1_dw1_err_test(result);
   test_vdm_tlp_hdr1_dw3_err_test(result);
   test_vdm_tlp_deid_err_test(result);
end
endtask


task test_vdm_tlp_hdr1_dw0_err_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [15:0] exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   //create EP,TC,TH,ATTR etc in the vdm_err task.
   //Format,type,message code and vendor ID error----will be filtered at ST2MM level.will not reach PMCI_SS
   //ep bit is also set to 0. else this would trigger interrupt from fme_top. Interrupt testcases are seperately tested at top level
   create_vdm_err_packet(32'h010000C0,3'h7,1'b1,1'b0,2'h3,1'b1,3'h7,2'h3,8'h0,2'h0);
   #0.4ms;
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS2,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS2, rdata);
   exp_data = 16'h0001;
   if(rdata[31:16] == exp_data)
   begin
     $display("DATA MATCH:Invalid TLP detected");
   end 
   else 
   begin
     $display("DATA MATCH:Values are not matching for DW0 TLP exp_data=%h,rdata=%h",exp_data,rdata[31:16]);
     old_test_err_count = get_err_count();
     result = 1'b0;
   end 
   #100us; 
    post_test_util(old_test_err_count);
end
endtask

task test_vdm_tlp_hdr1_dw1_err_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [15:0] exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   // Modify MCTP VDM code in TAG field in DW1
   create_vdm_err_packet(32'h010000C0,3'h0,1'b0,1'b0,2'h0,1'b0,3'h0,2'h0,8'hF,2'h0);
   #0.4ms;
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS2,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS2, rdata);
   exp_data = 16'h0002;
   if(rdata[31:16] == exp_data)
   begin
     $display("DATA MATCH:Invalid TLP in DW1 detected");
   end 
   else 
   begin
     $display("DATA MATCH:Values are not matching for DW1 TLP exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
   #100us; 
    post_test_util(old_test_err_count);
end
endtask

task test_vdm_tlp_hdr1_dw3_err_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [15:0] exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   //Modify Header Version in MCTP Header field in DW3
   create_vdm_err_packet(32'h000000C0,3'h0,1'b0,1'b0,2'h0,1'b0,3'h0,2'h0,8'h0,2'h0);
   #0.4ms;
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS2,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS2, rdata);
   exp_data = 16'h0001;
   if(rdata[15:0] == exp_data)
   begin
     $display("DATA MATCH:Invalid TLP in DW3 detected");
   end 
   else 
   begin
     $display("DATA MATCH:Values are not matching for DW3 TLP exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
   #100us; 
    post_test_util(old_test_err_count);
end
endtask


task test_vdm_tlp_deid_err_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [15:0] exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   // Modify DEID field in MCTP HDR
   create_vdm_err_packet(32'h012100C0,3'h0,4'h0,1'b0,2'h0,1'b0,3'h0,2'h0,8'h0,2'h0);
   #0.4ms;
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS2,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS2, rdata);
   exp_data = 16'h0002;
   if(rdata[15:0] == exp_data)
   begin
     $display("DATA MATCH:Invalid TLP in DEID detected");
   end 
   else 
   begin
     $display("DATA MATCH:Values are not matching for DEID TLP exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
   #100us; 
    post_test_util(old_test_err_count);
end
endtask


task test_vdm_tlp_multipkt_deid_err_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [7:0]  exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   create_vdm_multimsg_err_packet(10'd16,32'h01000080);
   create_vdm_multimsg_err_packet(10'd16,32'h01FF0050);
   #0.4ms;
   //xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h01;
   if(rdata[39:32] == exp_data)
   begin
     $display("DATA MATCH:MULTIPKT_DEID_ERR DETCTED");
   end 
   else 
   begin
     $display("DATA_ERROR:MULTIPKT_DEID_ERR NOT matching, exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
   #100us; 
    post_test_util(old_test_err_count);
end
endtask

task test_vdm_tlp_multipkt_seid_err_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [7:0]  exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   create_vdm_multimsg_err_packet(10'd16,32'h01000180);
   create_vdm_multimsg_err_packet(10'd16,32'h01000250);
   #0.4ms;
   //xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h02;
   if(rdata[39:32] == exp_data)
   begin
     $display("DATA MATCH:MULTIPKT_SEID DETECTED");
   end 
   else 
   begin
     $display("DATA_ERROR:MULTIPKT SEID  not matching, exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
   #100us; 
    post_test_util(old_test_err_count);
end
endtask

task test_vdm_tlp_multipkt_tag_err_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [7:0]  exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   create_vdm_multimsg_err_packet(10'd16,32'h01000087);
   create_vdm_multimsg_err_packet(10'd16,32'h01000055);
   #0.4ms;
   //xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h03;
   if(rdata[39:32] == exp_data)
   begin
     $display("DATA MATCH:MULTIPKT TAG DETECTED");
   end 
   else 
   begin
     $display("DATA_ERROR:MULTIPKT TAG ERROR are not matching, exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
    
   #100us; 
    post_test_util(old_test_err_count);
		
end
endtask


task test_vdm_tlp_multipkt_pktseq_err_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [7:0]  exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   create_vdm_multimsg_err_packet(10'd16,32'h01000080);
   create_vdm_multimsg_err_packet(10'd16,32'h01000070);
   #0.4ms;
   //xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h04;
   if(rdata[39:32] == exp_data)
   begin
     $display("DATA MATCH:MULTIPKT PKT_SEQ DETECTED");
   end 
   else 
   begin
     $display("DATA_ERROR:MULTIPKT PKT_SEQ ERROR are not matching, exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
    
   #100us; 
    post_test_util(old_test_err_count);
		
end
endtask


task test_vdm_tlp_multipkt_middle_pkt_lenerr_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [7:0]  exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   create_vdm_multimsg_err_packet(10'd15,32'h01000080);
   create_vdm_multimsg_err_packet(10'd16,32'h01000010);//Middle pkt with length 15
   create_vdm_multimsg_err_packet(10'd15,32'h01000060);
   #0.4ms;
   //xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h05;
   if(rdata[39:32] == exp_data)
   begin
     $display("DATA MATCH:MULITPKT_MIDDLE_PKT_LENERR ");
   end 
   else 
   begin
     $display("DATA_ERROR:MULTIPKT_MIDDLE_PKT are not matching, exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
    
   #100us; 
    post_test_util(old_test_err_count);
		
end
endtask

task test_vdm_tlp_multipkt_last_pkt_lenerr_test;

   output logic result;
   logic [31:0] old_test_err_count;
   logic        error;
   logic [63:0] rdata;
   logic [7:0]  exp_data;
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   repeat (6) @(posedge clk);
   
   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);
    
    #200us;
   //creating error packet scenarios to see whether error conditions are getting hit.
   create_vdm_multimsg_err_packet(10'd15,32'h01000080);
   create_vdm_multimsg_err_packet(10'd15,32'h01000010);
   create_vdm_multimsg_err_packet(10'd16,32'h01000060);
   #0.4ms;
   //xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h0006;
   if(rdata[39:32] == exp_data)
   begin
     $display("DATA MATCH:MULTIPKT_LAST_PKT");
   end 
   else 
   begin
     $display("DATA_ERROR:MULTIPKT_LST_PKT are not matching, exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
    
   #100us; 
    post_test_util(old_test_err_count);
		
end
endtask


task create_vdm_msg_rand_packet;
   input logic         has_data;
   input logic [9:0]   length;
   logic [31:0] msg_word = 32'hC0DE_1234;
   logic [31:0] msg_words[$];
   byte_t tmp_vdm_buf[];
begin 
    vt = new(
      .access_source("Unit Test"),
      .data_present( (has_data) ? DATA_PRESENT : NO_DATA_PRESENT),
      .msg_route(VDM_BROADCAST_FROM_ROOT_COMPLEX),
      .requester_id(16'h0000),
      .msg_code(VDM_TYPE1),
      .pci_target_id(16'hFFFF),
      .vendor_id(16'h1AB4),
      .length_dw(length)
   );
   msg_words.delete();
   for (int i = 0; i < int'(length-10'd1); i++)
   begin
      msg_words.push_back(msg_word);
   end
   vdm_buf = new[((int'(length-10'd1))*4)+1]; // In bytes.
   tmp_vdm_buf = {<<8{{<<32{msg_words}}}};
   for (int i = 0; i < tmp_vdm_buf.size(); i++)
   begin
      vdm_buf[i] = tmp_vdm_buf[i];
   end
   vdm_buf[tmp_vdm_buf.size()] = 8'hFF;
   vt.request_packet.set_data(vdm_buf);
   $display("VDM Message from Rand Packet Task:");
   vt.print_data();
   t = vt;
   $display("   ** Start Sending VDM TLP message packet **");
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
   host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   $display("   ** End Sending VDM TLP message packet **");
   //hdr = '0;
   //hdr.dw0.fmttype = {has_data, 6'b110011}; //fmttype[6:5]=2'b11, fmttype[4:3]=2'b10, fmttype[2:0]=3'b010
   //hdr.dw0.length  = length;
   //hdr.msg_code    = 'h7f;
   //hdr.tag         = {2'h0,2'h3,4'h0}; 
   //hdr.pci_target_id =16'hFFFF; 
   //hdr.vendor_id   = 'h1ab4; 
   //hdr.upper_msg   = 32'h010000C0; //MCTP header info: RSVD = 4'h0, hdr version = 4'h1, destination ID = 8'h0, 
                                   //source EID = 8'h0, SOM = 1'b1, EOM = 1'b1, PktSeq = 2'b0, TO = 1'b0, MsgTag = 3'b0   
   //`ifdef HTILE
      //hdr = to_little_endian(hdr);
   //`endif
   $display("   ** start Sending VDM TLP message packets **");
   //pld = {{15{32'hc0de_1234}},8'hFF};
   //create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0,pld, 0);
   //write_test_packet(pkt_buf, buf_size);
   //f_send_test_packet();
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
   host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   $display("   ** End Sending VDM TLP message packets **");
end
endtask


// Test MMIO access with 64-bit address 
task test_vdm_tx_rx_lpbk;
   output logic result;
begin
   print_test_header("test_vdm_tx_rx_lpbk");
   test_vdm_tx_rx_lpbk_test(result); //Scenario to cover all the fields with FF's to achieve 100% toggle coverage
end
endtask


task test_vdm_tx_rx_lpbk_test;

   output logic result;
   logic [31:0] scratch,ack;
   logic [31:0] cnt, rdcnt;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [62:0] rdata,wdata,exp_data;
   logic [31:0] vdm_wdata,mctp_header,vdm_pkt_length;
   static logic [7:0] i_temp;
   static logic [7:0] j_temp;
   //bit [7:0] cnt;
   bit [7:0] valid_cnt;
   logic [31:0] vdm_ref_pld[$];
   logic [31:0] rx_vdm_pld[$];
   logic [1:0][255:0] act_data;
   logic [15:0][31:0] tx_data;
   logic [15:0][31:0] rx_data;
   logic [255:0] ref_data_temp;
   logic [511:0] lpbk_vdm_msg;
   logic [15:0][31:0] vdm_pkt;
   logic  [7:0] lpbk_fmt_type;
   logic  [9:0] lpbk_len;
   logic  [15:0] lpbk_vendor_id;
   logic  [31:0] lpbk_mctp_hdr;
   logic  [7:0]  lpbk_msg_code;
   logic [31:0] msg_payload_words[];
   byte_t msg_payload_bytes[];
   
   bit act_vdm_valid; 
begin
   old_test_err_count = get_err_count();
   result = 1'b1;
   $display("Test MCTP VDM TX-RX Loopback ");
   repeat (6) @(posedge clk);

   //WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
   host_bfm_top.host_bfm.write32(PMCI_VDM_BA, 'h0004_2000);

    #200us;
    begin @(posedge top_tb.bmc_m10.m10_clk);
    force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr ='h4;
    force top_tb.bmc_m10.avmm_nios_read ='h1;

    while(!( top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata[1]==0 && top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddvld ==1));
        @(posedge top_tb.bmc_m10.m10_clk);
  
    for ( int i=0;i<16;i++) 
    begin @(posedge top_tb.bmc_m10.m10_clk);
       i_temp=i; 
       force top_tb.bmc_m10.avmm_nios_read ='h0;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h300+i_temp;
       force top_tb.bmc_m10.avmm_nios_write ='h1;
       assert(std::randomize(vdm_wdata));
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata =vdm_wdata;
       vdm_ref_pld.push_back(vdm_wdata);
    end 
    begin @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h5;
       force top_tb.bmc_m10.avmm_nios_write ='h1;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h0,1'h0,1'h0,3'h0,8'h0,16'h0};
    end
    begin @(posedge top_tb.bmc_m10.m10_clk); 
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h4;
       force top_tb.bmc_m10.avmm_nios_write ='h1;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={12'h10,2'h0,3'h0,1'h1};
    end
    end
    @(posedge top_tb.bmc_m10.m10_clk); 
    @(posedge top_tb.bmc_m10.m10_clk); 
    force top_tb.bmc_m10.avmm_nios_write ='h0;
    
    
    //Get the actual values from PCIe BFM//

    //f_shmem_vdm_pyld_display(act_data,lpbk_fmt_type,lpbk_len,lpbk_vendor_id,lpbk_mctp_hdr,lpbk_msg_code);
    $display("Waiting for VDM Reception at BFM at time %0t.", $realtime);
    @(posedge clk iff (host_bfm_top.tx_inbound_message_queue.size() > 0));
    $display("VDM message received by BFM at time %0t.", $realtime);
    p = host_bfm_top.tx_inbound_message_queue.pop_front();
    $display("VDM message received:");
    p.print_packet_long();
    msg_payload_bytes = new[p.get_payload_size()];
    p.get_payload(msg_payload_bytes);
    $display(">>> VDM Payload Info:");
    $display("    msg_payload_bytes:");
    $display(msg_payload_bytes);
    msg_payload_words = {<<32{{<<8{msg_payload_bytes}}}};
    $display("    msg_payload_words:");
    $display(msg_payload_words);
    for (int i = 0; i < 16; i++)
    begin
       tx_data[i] = msg_payload_words[i];
    end
    lpbk_fmt_type  = p.get_fmt_type();
    lpbk_len       = p.get_length_dw();
    lpbk_vendor_id = p.get_vendor_id();
    lpbk_msg_code  = p.get_msg_code();
    lpbk_mctp_hdr  = p.get_upper_msg();
    if(lpbk_fmt_type !=='h70) begin
      $display("Error in tx format type: Expected: 8'h70   Received: 8'h%H", lpbk_fmt_type);
      incr_err_count();
      result = 1'b0;
    end
    if(lpbk_len !=='d16) begin
      $display("Error in tx length: Expected: 10'd16   Received: 10'd%0d", lpbk_len);
      incr_err_count();
      result = 1'b0;
    end
    if(lpbk_vendor_id !=='h1ab4) begin
      $display("Error in tx vendor ID: Expected: 16'h1AB4   Received: 16'h%H", lpbk_vendor_id);
      incr_err_count();
      result = 1'b0;
    end
    if(lpbk_mctp_hdr !=='h010000c0) begin
      $display("Error in tx mctp header is %h",lpbk_mctp_hdr);
      incr_err_count();
      result = 1'b0;
    end
    if(lpbk_msg_code !== 'h7f) begin
      $display("Error in tx message code: Expected: 8'h7F   Received: 8'h%H", lpbk_msg_code);
      incr_err_count();
      result = 1'b0;
    end
    if (result == 1'b1)
    begin
       $display("Received VDM Message has the correct format!");
    end
    #200us;
    //$display("    tx_data:");
    //for ( int i=0;i<16;i++) begin
     //tx_data[i] =vdm_ref_pld.pop_front();
     //$display("tx_data word %0d: %H", i, tx_data[i]);
    //end

    //lpbk_vdm_msg={act_data[1],act_data[0]};
    //Loopback at RX side begins
    //test_vdm_msg_rx_path (result,lpbk_fmt_type,lpbk_len,lpbk_vendor_id,lpbk_mctp_hdr,lpbk_msg_code,lpbk_vdm_msg);  // 64B   VDM packet
    vt = new(
      .access_source("Unit Test"),
      .data_present(DATA_PRESENT),
      .msg_route(VDM_ROUTED_BY_ID),
      .requester_id(16'hFFFF),
      .msg_code(lpbk_msg_code),
      .pci_target_id(16'h0000),
      .vendor_id(lpbk_vendor_id),
      .length_dw(lpbk_len)
   );
   //vt.request_packet = p;
   vt.request_packet.set_data(msg_payload_bytes);
   $display("Loopback VDM Message:");
   vt.print_data();
   t = vt;
   $display("   ** Start Sending VDM TLP message packet **");
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
   host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
   host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   $display("   ** End Sending VDM TLP message packet **");
    //BMC txns for RX path
    begin @(posedge top_tb.bmc_m10.m10_clk); 
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h1;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h0,2'h0,1'h1,1'h0};
    end
    @(posedge top_tb.bmc_m10.m10_clk);
    @(posedge top_tb.bmc_m10.m10_clk);
    @(posedge top_tb.bmc_m10.m10_clk);

    begin @(posedge top_tb.bmc_m10.m10_clk); 
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h1;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h1,3'h0,1'h1};
    end/*
    begin @(posedge top_tb.bmc_m10.m10_clk); 
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h1;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h1,3'h0,1'h1};
    end*/
    @(posedge top_tb.bmc_m10.m10_clk);
    @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h0;
    #200us;
    begin @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
       vdm_pkt_length=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
    end 
    begin @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h1;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
       mctp_header=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata;
    end 
    begin @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h200;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
       vdm_pkt=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
    end 
    begin @(posedge top_tb.bmc_m10.m10_clk); 
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h0;
    end
    begin @(posedge top_tb.bmc_m10.m10_clk); 
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h1;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h0,2'h0,1'h0,1'h0};
    end
    begin @(posedge top_tb.bmc_m10.m10_clk); 
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h0;
    end
    #1ms;
    fork begin
    for ( int j=0;j<16;j++) begin
    begin @(posedge top_tb.bmc_m10.m10_clk);
      if(!top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_waitreq) begin
       j_temp=j;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h200+j_temp;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
       //vdm_pkt=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
      end
      else begin
          j=j-1;
      end 
    end
    end
    end
    begin
      while (!top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddvld) begin
        @(posedge top_tb.bmc_m10.m10_clk);
      end
      while(valid_cnt<16) begin
      if(top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddvld==1) begin
        vdm_pkt=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
        rx_vdm_pld.push_back(vdm_pkt);
        valid_cnt=valid_cnt+1;
      end
        @(posedge top_tb.bmc_m10.m10_clk);
      end
    end
    join

    for (int i = 0; i < 16; i++) begin
      rx_data[i]=rx_vdm_pld.pop_front();
    end
    pyld_compare(tx_data,rx_data,result);
     

    force top_tb.DUT.pmci_wrapper.reset_csr=1'b1;  //to cover reset toggle coverage. not actually related to functionality
    #100us;
    force top_tb.DUT.pmci_wrapper.reset_csr=1'b0;

    #100us; 
    post_test_util(old_test_err_count);
end
endtask


//Compare the payload (VDM Message) in BMC with Shared memory in PCIe BFM.
task pyld_compare(input [15:0][31:0]tx_vdm_data,input [15:0][31:0] rx_vdm_data,output bit result);

for(int i=0;i<16;i++) begin
  if(rx_vdm_data[i]==tx_vdm_data[i])
    $display("VDM payloads are matching on BMC and PCIe BFM side");
  else begin
    $display("VDM payloads are not matching ,BMC side VDM value is %h,PCIe BFM side VDM value is %h",tx_vdm_data[i],rx_vdm_data[i]);
    incr_err_count();
    result = 1'b0;
  end
end
endtask


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
   begin
      $display("Entering PMCI VDM TX/RX Loopback Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      pfvf = '{0,0,0}; // Set PFVF to PF0
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);

      test_vdm_tx_rx_lpbk (test_result);
   end
endtask


endmodule
