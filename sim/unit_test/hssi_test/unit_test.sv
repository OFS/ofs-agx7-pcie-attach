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
import test_param_defs::*;
import top_cfg_pkg::*;


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

`ifdef ETH_10G
    `define ETH_10_OR_25G
`elsif ETH_25G
  `define ETH_10_OR_25G
`endif
    
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
   pfvf = '{0,1,1}; // Set PFVF to PF0-VF1
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
   host_bfm_top.host_bfm.set_bar(4'd0);
   // RO Register check
   test_csr_ro_access_64(result, addr_mode, AFU_DFH_ADDR, AFU_DFH_VAL);
   test_csr_ro_access_64(result, addr_mode, AFU_ID_L_ADDR, AFU_ID_L_VAL);
   test_csr_ro_access_64(result, addr_mode, AFU_ID_H_ADDR, AFU_ID_H_VAL);
   
   // RW access check using scratchpad
   test_csr_access_32(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0001);
   test_csr_access_64(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0003_AFC0_0002);
   test_csr_access_32_ch1(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0004);
   test_csr_access_64_ch1(result, addr_mode, AFU_SCRATCH_ADDR, 'hAFC0_0006_AFC0_0005);
   test_csr_access_32_addr64(result, ADDR64, AFU_SCRATCH_ADDR, 'hAFC0_0007);
   // Test illegal memory read returns CPL
   test_unused_csr_access_32(result, addr_mode, AFU_UNUSED_ADDR, 'hF00D_0001);
   test_unused_csr_access_64(result, addr_mode, AFU_UNUSED_ADDR, 'hF00D_0003_F00D_0002);

   post_test_util(old_test_err_count);
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
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
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT0_ATTR_ADDR , HSSI_IF_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT0_STATUS_ADDR, HSSI_PORT_STATUS_VAL);
   test_csr_ro_access_64(result, addr_mode, HSSI_DFH_LO_ADDR, {HSSI_DFH_HI_VAL, HSSI_DFH_LO_VAL});
   // Unused CSR check
   test_unused_csr_access_32(result, addr_mode, HSSI_WRAP_UNUSED_ADDR, 'hF00D_0004);
   test_unused_csr_access_64(result, addr_mode, HSSI_WRAP_UNUSED_ADDR, 'hF00D_0006_F00D_0005);
   post_test_util(old_test_err_count);
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
end
endtask

// Mailbox write
task write_mailbox;
   input logic         access32; // Enabling 32-bit data access
   input logic [31:0]  cmd_ctrl_addr; // Start address of mailbox access reg
   input logic [63:0]  addr; //Byte address
   input logic [31:0]  write_data32;
   begin
      pfvf = '{0,1,1}; // Set PFVF to PF0-VF1
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
     if (access32) begin
         host_bfm_top.host_bfm.write32(cmd_ctrl_addr + MB_WRDATA_OFFSET, write_data32);
         host_bfm_top.host_bfm.write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr); 
         host_bfm_top.host_bfm.write32(cmd_ctrl_addr, MB_WR); 
         read_ack_mailbox(cmd_ctrl_addr);
         //#1000000
         host_bfm_top.host_bfm.write32(cmd_ctrl_addr, MB_NOOP);
         $display("INFO: Wrote MAILBOX ADDR:%x, WRITE_DATA32:%X", addr, write_data32);
     end 
     else begin
         host_bfm_top.host_bfm.write64(cmd_ctrl_addr + MB_RDDATA_OFFSET, {write_data32,32'h0000_0000});
         host_bfm_top.host_bfm.write64(cmd_ctrl_addr, {addr,MB_WR}); 
         read_ack_mailbox(cmd_ctrl_addr);
         //#1000000
         host_bfm_top.host_bfm.write64(cmd_ctrl_addr, MB_NOOP);
         $display("INFO: Wrote MAILBOX ADDR:%x, WRITE_DATA32:%X", addr, write_data32);
     end
   end
endtask

// Mailbox read
task read_mailbox;
   input logic         access32; // Enabling 32-bit data access
   input  logic [31:0] cmd_ctrl_addr; // Start address of mailbox access reg
   input  logic [63:0] addr; //Byte address
   output logic [31:0] rd_data32;
   logic        [63:0] scratch;
   logic               error;
   cpl_status_t        cpl_status;
   begin
      if (access32) begin
         //WRITE32(ADDR32, cmd_ctrl_addr + MB_ADDRESS_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, addr[31:0]);
         //WRITE32(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_RD);
         host_bfm_top.host_bfm.write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr[31:0]);
         host_bfm_top.host_bfm.write32(cmd_ctrl_addr, MB_RD);
         read_ack_mailbox(cmd_ctrl_addr);
         //#1000000
         //READ32(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, rd_data32, error);
         host_bfm_top.host_bfm.read32_with_completion_status(cmd_ctrl_addr + MB_RDDATA_OFFSET, rd_data32, error, cpl_status);
         if (error) begin
            $display("\nERROR: Mailbox read failed.\n");
            incr_err_count();
         end
         $display("INFO: Read MAILBOX ADDR:%x, READ_DATA32:%X", addr, rd_data32);
         //WRITE32(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_NOOP);
         host_bfm_top.host_bfm.write32(cmd_ctrl_addr, MB_NOOP);
      end 
      else begin
         //WRITE64(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, {addr,MB_RD});
         host_bfm_top.host_bfm.write64(cmd_ctrl_addr, {addr,MB_RD});
         read_ack_mailbox(cmd_ctrl_addr);
         //#1000000
         //READ64(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, scratch, error);
         host_bfm_top.host_bfm.read64_with_completion_status(cmd_ctrl_addr + MB_RDDATA_OFFSET, scratch, error, cpl_status);
         if (error) begin
            $display("\nERROR: Mailbox read failed.\n");
            incr_err_count();
         end
         rd_data32 = scratch[31:0];
         $display("INFO: Read MAILBOX ADDR:%x, READ_DATA32:%X", addr, rd_data32);
         //WRITE64(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_NOOP);
         host_bfm_top.host_bfm.write64(cmd_ctrl_addr, MB_NOOP);
      end
   end
endtask

// Mailbox ack check
task read_ack_mailbox;
   input  logic [31:0] cmd_ctrl_addr; // Start address of mailbox access reg
   logic [31:0] scratch1;
   logic [4:0]  rd_attempts;
   logic        ack_done;
   logic        error;
   cpl_status_t cpl_status;
   begin
      scratch1     = 32'h0;
      rd_attempts  = 'b0;
      ack_done     = 1'h0;

      while (~ack_done && rd_attempts<15) begin
         //READ32(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, scratch1, error);
         host_bfm_top.host_bfm.read32_with_completion_status(cmd_ctrl_addr, scratch1, error, cpl_status);
         ack_done = scratch1[2];
         #100000
         rd_attempts = rd_attempts + 1;
      end
      if (error || (~ack_done)) begin
         $display("\nERROR: Mailbox Ack failed.\n");
         incr_err_count();
      end
      $display("Ack status: 0x%0x",ack_done);
   end
endtask

task wait_for_reset_done;
   logic                error;
   logic                result;
   begin
      pfvf = '{0,0,0}; // Set PFVF to PF0
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      $display("INFO:%t	Waiting for subsystem cold reset deassertion acknowledgment",$time);
      wait(top_tb.DUT.hssi_wrapper.hssi_ss.subsystem_cold_rst_ack_n);
      test_csr_ro_access_32(result, ADDR32, HSSI_WRAP_COLD_RST_ACK_ADDR, 'h0);
      $display("INFO:%t	Subsystem cold reset deassertion acknowledged",$time);
      $display("INFO:%t	Reset Sequence Complete",$time);
      host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
   end
endtask

// Wait for HSSI TX and RX ready
task wait_for_hssi_to_ready;
   logic                error;
   logic                result;
   logic [31:0]         scratch;
   hssi_port_status_t   port_status;
   hssi_port_status_t   port_status_prev;
   hssi_feature_t       hssi_cfg;
   int                  port;
   logic                is_etile;
   cpl_status_t cpl_status;
   begin
      pfvf = '{0,0,0}; // Set PFVF to PF0
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);

      //READ32(ADDR32, HSSI_FEATURE_ADDR, bar, vf_active, pfn, vfn, hssi_cfg, error);
      //READ32(ADDR32, HSSI_VER_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      host_bfm_top.host_bfm.read32_with_completion_status(HSSI_FEATURE_ADDR, hssi_cfg, error, cpl_status);
      host_bfm_top.host_bfm.read32_with_completion_status(HSSI_VER_ADDR, scratch, error, cpl_status);
      is_etile = scratch[31:16] == 'h1;

      for(port=0; port < $bits(hssi_cfg.port_enable); port++) begin
         if (!hssi_cfg.port_enable[port]) begin
            continue;
         end
         
         port_status = '0;
         // Ignore hip_ready for F-Tile (feature major version == 3)
         while ( !port_status.rx_block_lock   || 
                 !port_status.rx_pcs_ready    || 
                 !port_status.tx_lanes_stable ||
                 (is_etile & !port_status.ehip_ready))
            begin

               //READ32(ADDR32, HSSI_PORT0_STATUS_ADDR + 'h4*port, bar, vf_active, pfn, vfn, port_status, error);
               host_bfm_top.host_bfm.read32_with_completion_status(HSSI_PORT0_STATUS_ADDR + 'h4*port, port_status, error, cpl_status);

               if(is_etile) begin
                  if(port_status.ehip_ready & !port_status_prev.ehip_ready)
                  $display ("INFO:%t	Port %0d - EHIP Ready  is high", $time, port);
               end
               
               if(port_status.rx_block_lock & !port_status_prev.rx_block_lock)
                  $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time, port);

               if(port_status.rx_pcs_ready & !port_status_prev.rx_pcs_ready) begin
                  @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
                  $display ("INFO:%t	Port %0d - RX deskew locked", $time, port);
                  $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, port);
               end
            
               if(port_status.tx_lanes_stable & !port_status_prev.tx_lanes_stable) begin
                  // @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p0_clk_pll);
                  $display ("INFO:%t	Port %0d - TX enabled", $time, port);
               end

               port_status_prev = port_status;
         end
      end
     `ifdef FTILE_SIM
       #5us
     `else  //for Etile,PCS ready is stable at 800us, we added a delay of 500us
       #500us
     `endif
      // Check rx pcs ready, tx lane stable and pll lock by reading register
      test_csr_ro_access_64(result, ADDR32, HSSI_WRAP_STATUS_ADDR, HSSI_WRAP_STATUS_VAL);
      host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
   end
endtask

// Wait until all packets received back
task wait_for_all_eop_done;
   input logic [31:0]  num_pkt;
   logic [31:0]        pkt_cnt;
   begin
      pkt_cnt = 32'h0;
`ifdef ETH_10_OR_25G
      while (pkt_cnt < num_pkt) begin
	      @(posedge top_tb.DUT.afu_top.pg_afu.port_gasket.pr_slot.afu_main.port_afu_instances.afu_gen[1].heh_gen.he_hssi_inst.multi_port_axi_sop_traffic_ctrl_inst.GenBrdg[0].axis_to_avst_bridge_inst.avst_rx_st.rx.eop);
         @(posedge top_tb.DUT.afu_top.pg_afu.port_gasket.pr_slot.afu_main.port_afu_instances.afu_gen[1].heh_gen.he_hssi_inst.multi_port_axi_sop_traffic_ctrl_inst.GenBrdg[0].axis_to_avst_bridge_inst.avst_rx_st.clk);
         pkt_cnt=pkt_cnt+1;
      end
`endif
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
   end
endtask

task wait_for_all_eop_done_200G;
   input logic [63:0]  tx_cnt;
   logic [63:0] rx_count;
   begin
      
`ifdef ETH_200G
      rx_count = 32'h0;
      while (tx_cnt > rx_count) begin
         @(posedge top_tb.DUT.afu_top.pg_afu.port_gasket.pr_slot.afu_main.port_afu_instances.afu_gen[1].heh_gen.he_hssi_inst.multi_port_axi_mac_seg_traffic_ctrl_inst.GenTrafWrap[0].mac_seg_packet_client_top.packet_client_top.packet_client_csr.u_rx_eop_cnt.clk);
         rx_count = {top_tb.DUT.afu_top.pg_afu.port_gasket.pr_slot.afu_main.port_afu_instances.afu_gen[1].heh_gen.he_hssi_inst.multi_port_axi_mac_seg_traffic_ctrl_inst.GenTrafWrap[0].mac_seg_packet_client_top.packet_client_top.packet_client_csr.u_rx_eop_cnt.cnt_out[63:0]};
      end
      $display("INFO:%t	- RX EOP count is %d", $time, rx_count);
`endif  
   end
endtask

task traffic_200G_400G;
   input logic  access32;
   logic [63:0] tx_cnt;
   logic [63:0] rx_cnt;
   logic [31:0] tx_cnt_lsb;
   logic [31:0] tx_cnt_msb;
   logic [31:0] rx_cnt_lsb;
   logic [31:0] rx_cnt_msb;
   begin
      pfvf = '{0,1,1}; // Set PFVF to PF0-VF1
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      host_bfm_top.host_bfm.set_bar(4'd0);
      //---------------------------------------------------------------------------
      // Traffic Controller Configuration
      //---------------------------------------------------------------------------
      $display("T:%8d INFO: write mailbox",$time);
     `ifdef INCLUDE_HSSI_PORT_12
      host_bfm_top.host_bfm.write32(AFU_PORT_SEL_ADDR, 32'h1); // select hssi[1] TG
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0004, 32'h1); // HW_TEST_LOOP_CNT =1 default
      //Setting ROM end address.  HW_TEST_ROM_ADDR[15:0] - Rom packet data start addr ;HW_TEST_ROM_ADDR[31:16] - Rom packet data end address 
      //write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0008, 32'h1F00); 
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0008, 32'h02FF_0000); 
      // Clearing status regs and counter values - bit 7 =1 (clear status reg) and bit 8 =1 (clear counter)
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0000, 32'h180); 
      // Resetting the hw_pc_cntrl to default 
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0000, 32'h0);
      // writing hw_pc_cntrl 1 to start the TG 
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0000, 32'h1); 
      `endif

      // port8 
      host_bfm_top.host_bfm.write32(AFU_PORT_SEL_ADDR, 32'h0);// select hssi[0] TG
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0004, 32'h1); // HW_TEST_LOOP_CNT =1 default
            
      //Setting ROM end address.  HW_TEST_ROM_ADDR[15:0] - Rom packet data start addr ;HW_TEST_ROM_ADDR[31:16] - Rom packet data end address
      /*`ifndef ETH_400G
              write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0008, 32'h1F00); 
              `else
              write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0008, 32'h1700);
              `endif */
      `ifndef ETH_400G
              write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0008, 32'h02FF_0000); 
              `else
              write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0008, 32'h0191_0000);
              `endif

      // Clearing status regs and counter values - bit 7 =1 (clear status reg) and bit 8 =1 (clear counter)
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0000, 32'h180); 
      // Resetting the hw_pc_cntrl to default 
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0000, 32'h0);
      // writing hw_pc_cntrl 1 to start the TG 
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0000, 32'h1);

      #500000

      // Stop the TG 
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0000, 32'h0);

      #2000

      $display("T:%8d INFO: read mailbox 1",$time);
      // reading TX SOP 
      read_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0020, tx_cnt_lsb);
      read_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0024, tx_cnt_msb);
      tx_cnt = {tx_cnt_msb, tx_cnt_lsb};
             
      wait_for_all_eop_done_200G(tx_cnt);
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0000, 32'h40);  // Take snapshot of counters (bit 6 =1) 

      $display("T:%8d INFO: read mailbox 2",$time);
      // reading TX SOP 
      read_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h0038, rx_cnt_lsb);
      read_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h003C, rx_cnt_msb);
      rx_cnt = {rx_cnt_msb, rx_cnt_lsb};

      if (tx_cnt != rx_cnt) begin
         incr_err_count();
         $display("\nError: Received good packets does not match Transmitted packets on Port-%0d !\n",0);
         $display("Number of Packets \tSent: %0d\n \tReceived: %0d",tx_cnt,rx_cnt);
      end else begin
         $display("INFO: TEST PASS - Number of Packets \tSent: %0d\n \tReceived: %0d",tx_cnt,rx_cnt);
      end
      host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
   end
endtask

// HSSI Traffic test for 10G/25G variant
task traffic_10G_25G;
   input logic  access32;
   logic [31:0] scratch1;
   begin
      pfvf = '{0,1,1}; // Set PFVF to PF0-VF1
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      host_bfm_top.host_bfm.set_bar(4'd0);
      //---------------------------------------------------------------------------
      // Traffic Controller Configuration
      //---------------------------------------------------------------------------
      for (int id=NUM_ETH_CHANNELS-1; id >=0;id--) begin
         host_bfm_top.host_bfm.write32(AFU_PORT_SEL_ADDR, 32'h1*id);
         // Port-0
         if (id == 0) begin
            //Set packet length type
            write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_TYPE_ADDR, TG_PKT_LEN_TYPE_VAL);
            //Set packet length
            write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_ADDR, TG_PKT_LEN_VAL);
            //Set data pattern type
            write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, TG_DATA_PATTERN_ADDR, TG_DATA_PATTERN_VAL);
            //Set number of packets
            write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR,TG_NUM_PKT_ADDR, TG_NUM_PKT_VAL);
            //Set start to send pacts
            write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, TG_START_XFR_ADDR, 32'h1);
         end
         else begin
            // enable loopback for channel-1 onwards
            write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, LOOPBACK_EN_ADDR, 32'h1);
         end
      end
      wait_for_all_eop_done(TG_NUM_PKT_VAL);
      //---------------------------------------------------------------------------
      // Read Monitor statistics
      //---------------------------------------------------------------------------

      // Port-0
      host_bfm_top.host_bfm.write32(AFU_PORT_SEL_ADDR, 32'h0);
      read_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, TM_PKT_GOOD_ADDR, scratch1);
      if (scratch1 != TG_NUM_PKT_VAL) begin
         incr_err_count();
         $display("\nError: Received good packets does not match Transmitted packets on Port-%0d !\n",0);
         $display("Number of Good Packets Received: \tExpected: %0d\n \tRead: %0d",TG_NUM_PKT_VAL,scratch1);
      end else begin
         $display("INFO: Number of Good Packets Received on Port-%0d :%0d",0,scratch1);
      end
      // Bad packet received at Traffic monitor
      read_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, TM_PKT_BAD_ADDR, scratch1);
      if (scratch1 != 32'h0) begin
         incr_err_count();
         $display("\nError: Received bad packets on Port-%0d !\n",0);
         $display("Number of Bad Packets Received: \tExpected: %0d\n \tRead: %0d",32'h0,scratch1);
      end else begin
         $display("INFO: Number of Bad Packets Received on Port-%0d :%0d",0,scratch1);
      end
      host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
   end
endtask

// HSSI Traffic test for 100G variant
task traffic_100G;
   input logic  access32;
   logic [31:0] tx_cnt;
   logic [31:0] rx_cnt;
   begin
      pfvf = '{0,1,1}; // Set PFVF to PF0-VF1
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      host_bfm_top.host_bfm.set_bar(4'd0);
      //---------------------------------------------------------------------------
      // Traffic Controller Configuration
      //---------------------------------------------------------------------------
      $display("T:%8d INFO: write mailbox",$time);
      `ifdef INCLUDE_HSSI_PORT_4
      host_bfm_top.host_bfm.write32(AFU_PORT_SEL_ADDR, 32'h1);
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h1010, 32'h1E);
      `endif

      host_bfm_top.host_bfm.write32(AFU_PORT_SEL_ADDR, 32'h0);
      write_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h1010, 32'h14);

      #500000
      //---------------------------------------------------------------------------
      // Read Monitor statistics
      //---------------------------------------------------------------------------

      $display("T:%8d INFO: read mailbox 1",$time);
      read_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h1009, tx_cnt);
      tx_cnt = {1'b0, tx_cnt[30:0]};
      $display("T:%8d INFO: read mailbox 2",$time);
      read_mailbox(access32, TRAFFIC_CTRL_CMD_ADDR, 32'h1015, rx_cnt);
      if (tx_cnt != rx_cnt) begin
         incr_err_count();
         $display("\nError: Received good packets does not match Transmitted packets on Port-%0d !\n",0);
         $display("Number of Packets \tSent: %0d\n \tReceived: %0d",tx_cnt,rx_cnt);
      end else begin
         $display("INFO: Number of Packets \tSent: %0d\n \tReceived: %0d",tx_cnt,rx_cnt);
      end
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

// HSSI Traffic test
task traffic_test;
   input logic  access32;
   logic [31:0] old_test_err_count;
   begin 
      $display("T:%8d INFO: Running Traffic Test",$time);

      print_test_header("traffic_test");
      old_test_err_count = get_err_count();

      // Wait for ready before starting the test
      $display("T:%8d INFO: Wait for reset done",$time);
      wait_for_reset_done();
      wait(&(top_tb.DUT.hssi_wrapper.tx_pll_locked[NUM_ETH_CHANNELS-1:0]));

      $display("T:%8d INFO: Wait for hssi ready",$time);
      wait_for_hssi_to_ready();

      `ifdef ETH_200G
      $display("T:%8d INFO: Running eth 200g",$time);
      traffic_200G_400G(access32);
      `elsif ETH_400G
      $display("T:%8d INFO: Running eth 400g",$time);
      traffic_200G_400G(access32);
      `elsif ETH_100G
      $display("T:%8d INFO: Running eth 100g",$time);
      traffic_100G(access32);
      `else      $display("T:%8d INFO: Running eth 10g",$time);
      traffic_10G_25G(access32);
      `endif

      post_test_util(old_test_err_count);
   end
endtask


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
   begin
      $display("Entering HSSI CSR Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      traffic_test (1); // Pass 1 for 32-bit access to mailbox, 0 for 64-bit
   end
endtask


endmodule
