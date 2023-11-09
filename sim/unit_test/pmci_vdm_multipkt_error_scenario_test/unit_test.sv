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
   logic [31:0] msg_word  = 32'hC0DE_1234;
   logic [31:0] msg_words[$];
begin 
   local_som = upper_msg[7];
   local_eom = upper_msg[6];
   local_psn = upper_msg[5:4];
   
   $display("Length: %0d", length);

   msg_words.delete();  // Clear queue.
   for (int i = 0; i < int'(length); i++)
   begin
      msg_words.push_back(msg_word);  // Word replication when used with streaming operator below.
      $display("Loop pass: %0d", i);
   end

   $display("Message Word: %H", msg_word);
   $display("Message Words:");
   $display(msg_words);

   vdm_buf = {<<8{{<<32{ msg_words }}}}; // Stream data into dynamic array little endian by byte by 32-bit words from queue.

   $display("VDM Buf: ");
   $display(vdm_buf);
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
   vt.request_packet.set_mctp_som(local_som);
   vt.request_packet.set_mctp_eom(local_eom);
   vt.request_packet.set_mctp_packet_sequence_number(local_psn);
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
task test_multipkt_vdm_err_test;
   output logic result;
begin
   print_test_header("test_multipkt_vdm_err_test");
   test_vdm_tlp_multipkt_no_eom_test(result);
   test_vdm_tlp_multipkt_no_som_test(result);
   test_vdm_tlp_singlepkt_no_som_test(result);
   test_vdm_tlp_multipkt_middle_pkt_lenerr_test(result);
   test_vdm_tlp_multipkt_last_pkt_lenerr_test(result);
end
endtask


task xfer_vdm_pmci_bmc_init_task;
begin
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
    end
    @(posedge top_tb.bmc_m10.m10_clk);
    @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h0;
    #200us;
    begin @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
       //vdm_pkt_length=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
    end 
    begin @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h1;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
      // mctp_header=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata;
    end 
    begin @(posedge top_tb.bmc_m10.m10_clk);
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h200;
       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
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
end
endtask

task test_vdm_tlp_multipkt_no_eom_test;

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
   create_vdm_multimsg_err_packet(10'd16,32'h01000080); //Multipkt with SOM
   create_vdm_multimsg_err_packet(10'd16,32'h01000010); //Multipkt with no EOM
   #0.4ms;
   xfer_vdm_pmci_bmc_init_task();
   
   create_vdm_multimsg_err_packet(10'd16,32'h010000C0); //Single packet wit SOM and EOM
   #0.4ms;
   xfer_vdm_pmci_bmc_init_task();


   //In this scenario it will not assert error bit since PMCI_SS doesnt know whether how many multipackets will be present. but the Multipkt with NO EOM txns will not be transferred to BMC
   //Read the CSR from HOST
   /*
   READ64(ADDR64,PMCI_VDM_TLP_STS3,0,1'b0,0,0,rdata,error);
   exp_data=8'h0001;
   if(rdata[39:32] ==exp_data)begin
     $display("DATA MATCH:MULITPKT_NO_EOM Error detected");
   end 
   else begin
     $display("DATA_ERROR:MULTIPKT_NO_EOM Error Not matching, exp_data=%h,rdata=%h",exp_data,rdata);
     test_utils::incr_err_count();
     result = 1'b0;
   end 
   */
   #100us; 
    post_test_util(old_test_err_count);
		
end
endtask

task test_vdm_tlp_multipkt_no_som_test;

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
   create_vdm_multimsg_err_packet(10'd16,32'h01000080); //Multipkt with SOM
   create_vdm_multimsg_err_packet(10'd16,32'h01000050); //Multipkt with EOM
   #0.4ms;
   xfer_vdm_pmci_bmc_init_task();
   create_vdm_multimsg_err_packet(10'd16,32'h01000000); //Middle Multipacket with no SOM and no EOM
   create_vdm_multimsg_err_packet(10'd16,32'h01000050); //Middle Multipacket with no SOM and EOM
   #0.4ms;
   xfer_vdm_pmci_bmc_init_task();
   create_vdm_multimsg_err_packet(10'd16,32'h01000080); //Multipkt with SOM
   create_vdm_multimsg_err_packet(10'd16,32'h01000050); //Multipkt with EOM
   #0.4ms;
   xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h0002; //Since both the middle multipackets will trigger the error bit
   if(rdata[39:32] == exp_data)
   begin
     $display("DATA MATCH:MULITPKT_NO_SOM Error Detected");
   end 
   else 
   begin
     $display("DATA_ERROR:MULTIPKT_NO_SOM not matching, exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
   
   #100us; 
    post_test_util(old_test_err_count);
		
end
endtask

task test_vdm_tlp_singlepkt_no_som_test;

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
   create_vdm_multimsg_err_packet(10'd16,32'h01000040);//Single packet with no SOM
   #0.4ms;
   xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h0003;
   if(rdata[39:32] == exp_data)
   begin
     $display("DATA MATCH:SINGLEPKT_NO_SOM ERROR DETECTED");
   end 
   else 
   begin
     $display("DATA_ERROR:SINGLEPKT_NO_SOM is not matching, exp_data=%h,rdata=%h",exp_data,rdata);
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
   xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h0005;
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
   xfer_vdm_pmci_bmc_init_task();
   //Read the CSR from HOST
   //READ64(ADDR64,PMCI_VDM_TLP_STS3 ,0,1'b0,0,0,rdata,error);
   host_bfm_top.host_bfm.read64(PMCI_VDM_TLP_STS3, rdata);
   exp_data = 8'h0006;
   if(rdata[39:32] == exp_data)begin
     $display("DATA MATCH:MULTIPKT_LAST_PKT");
   end 
   else begin
     $display("DATA_ERROR:MULTIPKT_LST_PKT are not matching, exp_data=%h,rdata=%h",exp_data,rdata);
     incr_err_count();
     result = 1'b0;
   end 
    
   #100us; 
    post_test_util(old_test_err_count);
		
end
endtask


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
   begin
      $display("Entering PMCI VDM Multi-Packet Error Scenario Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      host_bfm_top.host_bfm.set_pfvf_setting(PF0);

      test_multipkt_vdm_err_test (test_result);
   end
endtask


endmodule
