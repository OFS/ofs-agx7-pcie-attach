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
begin
   $display("\n********************************************");
   $display(" Running TEST(%0d) : %0s", test_id, test_name);
   $display("********************************************");   
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


// Test 32-bit CSR RO access
task test_csr_ro_access_32;
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
       $display("\nERROR: CSR expected and read mismatch! expected=0x%x read=0x%x\n", data, scratch);
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

// Test 32-bit CSR access to TG enable register 
task test_400g_tg_en_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [31:0] data;
   input logic [31:0] expected;
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
   end else if (scratch !== expected) begin
       $display("\nERROR: Expected 32'h1 to be returned for AFU_400G_TG_EN register, actual:0x%x\n",scratch);    
       incr_err_count();
       result = 1'b0;
   end 
end
endtask

// 32-bit transaction to exercise ch-1
task test_csr_access_32_ch1;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [31:0] data;
   logic [31:0] scratch;
   //t_tlp_rp_tag tag0,tag1;
   //logic [2:0]  status;
   logic error;
   Transaction     #(pf_type, vf_type, pf_list, vf_list) t, rtc;
   WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt, wtc;
   WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt_queue[$];
   ReadTransaction #(pf_type, vf_type, pf_list, vf_list) rt;
   Transaction     #(pf_type, vf_type, pf_list, vf_list) rt_queue[$];
   string access_source;
   bit [3:0] first_dw_be = 4'b1111;
   bit [3:0] last_dw_be  = 4'b1111;
   byte_t write_data[];
   byte_t read_data[];
   bit [31:0] wdata;
   bit [31:0] rdata;
begin
   result = 1'b1;
   // dummy write to ch-0
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   //create_mwr_packet(addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn, 32'h0BAD_F00D);

   // channel-1 write
   //$display("WRITE32: address=0x%x bar=%0d pfn=%0d vfn=%0d, data=0x%x", addr, bar, pfn, vfn, data);
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   //create_mwr_packet(addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn, data);

   // dummy read from ch-0
   //f_get_tag(tag0);
      // tag, addr_32, address, length, bar, vf_active, pfn, vfn 
   //create_mrd_packet(tag0, addr_mode, AFU_DFH_ADDR, 10'd1, bar, vf_active, pfn, vfn);

   // ch-1 read
   //f_get_tag(tag1);
   //$display("READ32: address=0x%x bar=%0d pfn=%0d vfn=%0d\n", addr, bar, pfn, vfn);
      // tag, addr_32, address, length, bar, vf_active, pfn, vfn 
   //create_mrd_packet(tag1, addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn);
   //f_send_test_packet();

   //read_mmio_rsp(tag1, scratch, status);
   //if (status !== 3'b0) begin 
      //error = 1'b1;
      //data = '0;
   //end else begin
      //error = 1'b0;
   //end

   wdata = 32'h0BAD_F00D;
   access_source = "Unit Test, Test CSR Access 32 Ch1";
   wt_queue.delete();
   rt_queue.delete();
   // Create Write Transactions
   wt = new(
      .access_source(access_source),
      .address(addr),
      .length_dw(1),
      .first_dw_be(first_dw_be),
      .last_dw_be(last_dw_be)
   );
   wt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
   write_data = new[4]; // 4 bytes per word.
   write_data = {<<8{wdata}};
   wt.write_request_packet.set_data(write_data);
   wt_queue.push_back(wt);
   wdata = data;
   wt = new(
      .access_source(access_source),
      .address(addr),
      .length_dw(1),
      .first_dw_be(first_dw_be),
      .last_dw_be(last_dw_be)
   );
   wt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
   write_data = new[4]; // 4 bytes per word.
   write_data = {<<8{wdata}};
   wt.write_request_packet.set_data(write_data);
   $display("Write32: address=0x%x bar=%0d pfn=%0d vfn=%0d, data=0x%x", addr, wt.get_bar_num(), wt.get_pf_num(), wt.get_vf_num(), wdata);
   wt_queue.push_back(wt);
   // Send all the Write Transactions
   foreach (wt_queue[i])
   begin
      t = wt_queue[i];
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   end
   //----------------------------------------------------------------
   // Create the Read Transactions
   //----------------------------------------------------------------
   rt = new(
      .access_source(access_source),
      .address(AFU_DFH_ADDR),
      .length_dw(1),
      .first_dw_be(first_dw_be),
      .last_dw_be(last_dw_be)
   );
   rt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
   rt_queue.push_back(rt);
   rt = new(
      .access_source(access_source),
      .address(addr),
      .length_dw(1),
      .first_dw_be(first_dw_be),
      .last_dw_be(last_dw_be)
   );
   rt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
   rt_queue.push_back(rt);
   $display("Read32: address=0x%x bar=%0d pfn=%0d vfn=%0d\n", addr, rt.get_bar_num(), rt.get_pf_num(), rt.get_vf_num());
   // Send all the Read Transactions
   foreach (rt_queue[i])
   begin
      t = rt;
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   end
   rt_queue.delete();
   @(posedge host_bfm_top.axis_rx_req.clk iff (host_bfm_top.mmio_rx_req_completed_transaction_queue.size() == 2));
   host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.get();
   rt_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue;
   host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.put();
   wtc = wt_queue[$];
   rtc = rt_queue[$];
   //write_data = new[wtc.request_packet.get_payload_size()];
   //wtc.request_packet.get_payload(write_data);
   //wdata = {<<8{write_data}};
   wdata = wtc.get_return_data32();
   rdata = rtc.get_return_data32();
   $display(">>> Test MMIO Burst Data Comparison - wdata:%H    rdata:%H", wdata, rdata);
   if (wdata != rdata)
   begin
      $display(">>> ERROR: Test MMIO Burst Data Comparison Mismatch!");
      incr_err_count;
      result = 1'b0;
   end
   if (rtc.errored())
   begin
      $display(">>> ERROR: Test MMIO Burst Data Comparison Errored Read!");
      $display("    Read CplD Status: %-s", rtc.get_cpl_status().name());
      incr_err_count;
      result = 1'b0;
   end
   foreach (rt_queue[i])
   begin
      host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.get();
      host_bfm_top.mmio_rx_req_completed_transaction_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue.find() with (item.get_transaction_number() != rt_queue[i].get_transaction_number());
      host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.put();
   end
end
endtask

// 64-bit transaction to exercise ch-1
task test_csr_access_64_ch1;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [63:0] data;
   logic [63:0] scratch;
   //t_tlp_rp_tag tag0,tag1;
   //logic [2:0]  status;
   logic error;
   Transaction     #(pf_type, vf_type, pf_list, vf_list) t, rtc;
   WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt, wtc;
   WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt_queue[$];
   ReadTransaction #(pf_type, vf_type, pf_list, vf_list) rt;
   Transaction     #(pf_type, vf_type, pf_list, vf_list) rt_queue[$];
   string access_source;
   bit [3:0] first_dw_be = 4'b1111;
   bit [3:0] last_dw_be  = 4'b1111;
   byte_t write_data[];
   byte_t read_data[];
   bit [31:0] sdata;
   bit [63:0] wdata;
   bit [63:0] rdata;
begin
   result = 1'b1;
//    // dummy write to ch-0
//        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
//   create_mwr_packet(addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn, 32'h0BAD_F00D);
//
//   $display("WRITE64: address=0x%x bar=%0d pfn=%0d vfn=%0d, data=0x%x", addr, bar, pfn, vfn, data);
//        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
//   create_mwr_packet(addr_mode, addr, 10'd2, bar, vf_active, pfn, vfn, data);
//
//   // dummy read from ch-0
//   f_get_tag(tag0);
//      // tag, addr_32, address, length, bar, vf_active, pfn, vfn 
//   create_mrd_packet(tag0, addr_mode, AFU_DFH_ADDR, 10'd1, bar, vf_active, pfn, vfn);
//
//   f_get_tag(tag1);
//   $display("READ64: address=0x%x bar=%0d pfn=%0d vfn=%0d\n", addr, bar, pfn, vfn);
//      // tag, addr_32, address, length, bar, vf_active, pfn, vfn 
//   create_mrd_packet(tag1, addr_mode, addr, 10'd2, bar, vf_active, pfn, vfn);
//   f_send_test_packet();
//
//   read_mmio_rsp(tag1, scratch, status);
//   if (status !== 3'b0) begin 
//      error = 1'b1;
//      data = '0;
//   end else begin
//      error = 1'b0;
//   end
   sdata = 32'h0BAD_F00D;
   access_source = "Unit Test, Test CSR Access 64 Ch1";
   wt_queue.delete();
   rt_queue.delete();
   // Create Write Transactions
   wt = new(
      .access_source(access_source),
      .address(addr),
      .length_dw(1),
      .first_dw_be(first_dw_be),
      .last_dw_be(last_dw_be)
   );
   wt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
   write_data = new[4]; // 4 bytes per word.
   write_data = {<<8{sdata}};
   wt.write_request_packet.set_data(write_data);
   wt_queue.push_back(wt);
   wdata = data;
   wt = new(
      .access_source(access_source),
      .address(addr),
      .length_dw(2),
      .first_dw_be(first_dw_be),
      .last_dw_be(last_dw_be)
   );
   wt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
   write_data = new[8]; // 4 bytes per word.
   write_data = {<<8{wdata}};
   wt.write_request_packet.set_data(write_data);
   $display("Write64: address=0x%x bar=%0d pfn=%0d vfn=%0d, data=0x%x", addr, wt.get_bar_num(), wt.get_pf_num(), wt.get_vf_num(), wdata);
   wt_queue.push_back(wt);
   // Send all the Write Transactions
   foreach (wt_queue[i])
   begin
      t = wt_queue[i];
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   end
   //----------------------------------------------------------------
   // Create the Read Transactions
   //----------------------------------------------------------------
   rt = new(
      .access_source(access_source),
      .address(AFU_DFH_ADDR),
      .length_dw(1),
      .first_dw_be(first_dw_be),
      .last_dw_be(last_dw_be)
   );
   rt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
   rt_queue.push_back(rt);
   rt = new(
      .access_source(access_source),
      .address(addr),
      .length_dw(2),
      .first_dw_be(first_dw_be),
      .last_dw_be(last_dw_be)
   );
   rt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
   rt_queue.push_back(rt);
   $display("Read64: address=0x%x bar=%0d pfn=%0d vfn=%0d\n", addr, rt.get_bar_num(), rt.get_pf_num(), rt.get_vf_num());
   // Send all the Read Transactions
   foreach (rt_queue[i])
   begin
      t = rt;
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
   end
   rt_queue.delete();
   @(posedge host_bfm_top.axis_rx_req.clk iff (host_bfm_top.mmio_rx_req_completed_transaction_queue.size() == 2));
   host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.get();
   rt_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue;
   host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.put();
   wtc = wt_queue[$];
   rtc = rt_queue[$];
   //write_data = new[wtc.request_packet.get_payload_size()];
   //wtc.request_packet.get_payload(write_data);
   //wdata = {<<8{write_data}};
   wdata = wtc.get_return_data64();
   rdata = rtc.get_return_data64();
   $display(">>> Test MMIO Burst Data Comparison - wdata:%H    rdata:%H", wdata, rdata);
   if (wdata != rdata)
   begin
      $display(">>> ERROR: Test MMIO Burst Data Comparison Mismatch!");
      incr_err_count;
      result = 1'b0;
   end
   if (rtc.errored())
   begin
      $display(">>> ERROR: Test MMIO Burst Data Comparison Errored Read!");
      $display("    Read CplD Status: %-s", rtc.get_cpl_status().name());
      incr_err_count;
      result = 1'b0;
   end
   foreach (rt_queue[i])
   begin
      host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.get();
      host_bfm_top.mmio_rx_req_completed_transaction_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue.find() with (item.get_transaction_number() != rt_queue[i].get_transaction_number());
      host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.put();
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


// Test 64-bit CSR RO access
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

   //READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);
   $display("TCRA: 1");
   host_bfm_top.host_bfm.read64_with_completion_status(addr, scratch, error, cpl_status);
   $display("TCRA: 2");

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR expected and read mismatch! expected=0x%x read=0x%x\n", data, scratch);
       incr_err_count();
       result = 1'b0;
   end
   $display("TCRA: 3");
end
endtask

// Test 64-bit CSR access to unused CSR region
task test_unassigned_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;

   //WRITE64(addr_mode, addr, bar, vf_active, pfn, vfn, data);
   //READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);
   host_bfm_top.host_bfm.write64(addr, data);
   host_bfm_top.host_bfm.read64_with_completion_status(addr, scratch, error, cpl_status);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       incr_err_count();
       result = 1'b0;
   end else if (scratch !== 64'hFFFF_FFFF_FFFF_FFFF) begin
       $display("\nERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);
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

// Test 64-bit CSR access to TG enable register
task test_400g_tg_en_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [63:0] data;
   input logic [63:0] expected;
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
   end else if (scratch !== expected) begin
       $display("\nERROR: Expected 64'h0 to be returned for AFU_400G_TG_EN register, actual:0x%x\n",scratch);
       incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit data access with 64b address
task test_csr_access_32_addr64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [63:0] addr;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
   cpl_status_t cpl_status;
begin
   result = 1'b1;

   //WRITE32(addr_mode, {32'h0000_eecc,addr}, bar, vf_active, pfn, vfn, data);
   //READ32(addr_mode, {32'h0000_eecc,addr}, bar, vf_active, pfn, vfn, scratch, error);
   host_bfm_top.host_bfm.write64({32'h0000_eecc,addr[31:0]}, data);
   host_bfm_top.host_bfm.read64_with_completion_status({32'h0000_eecc,addr[31:0]}, scratch, error, cpl_status);

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



// Test AFU MMIO read 
task test_afu_mmio;
   output logic result;
   e_addr_mode  addr_mode;
   //logic [31:0] addr;
   logic [63:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
   uint32_t      length;
   cpl_status_t  cpl_status;
   return_data_t return_data;
begin
   print_test_header("test_afu_mmio");
   old_test_err_count = get_err_count();
   
   result = 1'b1;
   addr_mode = ADDR32;

   // AFU CSR
   $display("TAM: 1");
   pfvf = '{0,1,1}; // Set PFVF to PF0-VF1
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
   $display("TAM: 2");
   host_bfm_top.host_bfm.set_bar(4'd0);
   $display("TAM: 3");
   // RO Register check
   test_csr_ro_access_64(result, addr_mode, AFU_DFH_ADDR, AFU_DFH_VAL);
   $display("TAM: 4");
   test_csr_ro_access_64(result, addr_mode, AFU_ID_L_ADDR, AFU_ID_L_VAL);
   $display("TAM: 5");
   test_csr_ro_access_64(result, addr_mode, AFU_ID_H_ADDR, AFU_ID_H_VAL);
   $display("TAM: 6");
   
   // RW access check using scratchpad
   test_csr_access_32(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0001);
   $display("TAM: 7");
   test_csr_access_64(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0003_AFC0_0002);
   $display("TAM: 8");
   test_csr_access_32_ch1(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0004);
   $display("TAM: 9");
   test_csr_access_64_ch1(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0006_AFC0_0005);
   $display("TAM: 10");
   test_csr_access_32_addr64(result, ADDR64, AFU_SCRATCH_ADDR, 'hAFC0_0007);
   $display("TAM: 11");

   // Test AFU_400_TG_EN
   `ifdef ETH_400G
      test_400g_tg_en_access_32(result, addr_mode, AFU_400G_TG_EN, 'hF00D_0001, 'h1);
      $display("TAM: 12");
      test_400g_tg_en_access_64(result, addr_mode, AFU_400G_TG_EN, 'hF00D_0003_F00D_0002, 'h1);
      $display("TAM: 13");
   `else
      // Test illegal memory read returns CPL
      test_400g_tg_en_access_32(result, addr_mode, AFU_UNUSED_ADDR, 'hF00D_0001, 'h0);
      $display("TAM: 12");
      test_400g_tg_en_access_64(result, addr_mode, AFU_UNUSED_ADDR, 'hF00D_0003_F00D_0002, 'h0);
      $display("TAM: 13");
   `endif

   // Test illegal memory read returns CPL
   test_unused_csr_access_32(result, addr_mode, AFU_UNUSED_ADDR, 'hF00D_0001);
   $display("TAM: 14");
   test_unused_csr_access_64(result, addr_mode, AFU_UNUSED_ADDR, 'hF00D_0003_F00D_0002);
   $display("TAM: 15");
   
   post_test_util(old_test_err_count);
   $display("TAM: 16");
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
   $display("TAM: 17");
end
endtask


// Test HSSI SS read write
task test_hssi_ss_mmio;
   output logic result;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
begin
   print_test_header("test_hssi_ss_mmio");
   old_test_err_count = get_err_count();

   pfvf = '{0,0,0}; // Set PFVF to PF0
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
   host_bfm_top.host_bfm.set_bar(4'd0);
   
   result      = 1'b1;
   addr_mode   = ADDR32;
   //bar         = 3'h0;
   //vf_active   = 1'b0;
   //pfn         = 3'h0;
   //vfn         = 0;
   
   // HSSI Wrapper CSR check
   test_csr_access_64(result, addr_mode, HSSI_WRAP_SCRATCH_ADDR, 'hAFC0_0002_AFC0_0001);
   test_csr_access_32(result, addr_mode, HSSI_WRAP_SCRATCH_ADDR, 'hAFC0_0003);
   // HSSI SS CSR check
   test_csr_ro_access_32(result, addr_mode, HSSI_DFH_LO_ADDR, HSSI_DFH_LO_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_DFH_HI_ADDR, HSSI_DFH_HI_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_VER_ADDR, HSSI_VER_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_FEATURE_ADDR, HSSI_FEATURE_VAL);

   test_csr_ro_access_32(result, addr_mode, HSSI_PORT0_ATTR_ADDR , HSSI_PORT0_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT1_ATTR_ADDR , HSSI_PORT1_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT2_ATTR_ADDR , HSSI_PORT2_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT3_ATTR_ADDR , HSSI_PORT3_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT4_ATTR_ADDR , HSSI_PORT4_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT5_ATTR_ADDR , HSSI_PORT5_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT6_ATTR_ADDR , HSSI_PORT6_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT7_ATTR_ADDR , HSSI_PORT7_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT8_ATTR_ADDR , HSSI_PORT8_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT9_ATTR_ADDR , HSSI_PORT9_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT10_ATTR_ADDR, HSSI_PORT10_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT11_ATTR_ADDR, HSSI_PORT11_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT12_ATTR_ADDR, HSSI_PORT12_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT13_ATTR_ADDR, HSSI_PORT13_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT14_ATTR_ADDR, HSSI_PORT14_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT15_ATTR_ADDR, HSSI_PORT15_ATTR_VAL);

   test_csr_ro_access_64(result, addr_mode, HSSI_DFH_LO_ADDR, {HSSI_DFH_HI_VAL, HSSI_DFH_LO_VAL});
   // Unused CSR check
   test_unused_csr_access_32(result, addr_mode, HSSI_WRAP_UNUSED_ADDR, 'hF00D_0004);
   test_unused_csr_access_64(result, addr_mode, HSSI_WRAP_UNUSED_ADDR, 'hF00D_0006_F00D_0005);
   test_unused_csr_access_64(result, addr_mode, HSSI_SS_UNUSED_ADDR, 'hF00D_0008_F00D_0007);
   post_test_util(old_test_err_count);
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
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
   begin
      $display("Entering HSSI CSR Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      pfvf = '{2,0,0}; // Set PFVF to PF2
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);

      test_hssi_ss_mmio(test_result);
      test_afu_mmio(test_result);
   end
endtask


endmodule
