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

// Test MMIO access with 32-bit address 
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
   // BPF slaves
   //-----------
   $display("\n---------------------------------------");
   $display("Test CSR access to HE-MEM-NULL (PF0-VF0)");
   $display("---------------------------------------\n");
      pfvf = '{0,0,1}; // Set PFVF to PF0-VF0
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 'haa05_05aa);   
   
   $display("\n---------------------------------------");
   $display("Test CSR access to HE-HSSI (PF0-VF1)");
   $display("---------------------------------------\n");
      pfvf = '{0,1,1}; // Set PFVF to PF0-VF1
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 'haa06_06aa);   

   $display("\n---------------------------------------");
   $display("Test CSR access to MEM-TG (PF0-VF2)");
   $display("---------------------------------------\n");
      pfvf = '{0,2,1}; // Set PFVF to PF0-VF2
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 'haa07_07aa);
   
   $display("\n---------------------------------------");
   $display("Test CSR access to PF1)");
   $display("---------------------------------------\n");
      pfvf = '{1,0,0}; // Set PFVF to PF1
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 'haa02_02aa);   
      
   $display("\n---------------------------------------");
   $display("Test CSR access to HE-LB (PF2)");
   $display("---------------------------------------\n");
      pfvf = '{2,0,0}; // Set PFVF to PF2
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 'haa04_04aa);   
   
   $display("\n---------------------------------------");
   $display("Test CSR access to VIRTIO-LB (PF3)");
   $display("---------------------------------------\n");
      pfvf = '{3,0,0}; // Set PFVF to PF3
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      test_csr_read_64(result, addr_mode, VIRTIO_DFH, 64'h1000010000000000); 

      test_csr_read_64(result, addr_mode, VIRTIO_GUID_L, 64'hB9AB_EFBD_90B9_70C4);
      test_csr_read_64(result, addr_mode, VIRTIO_GUID_H, 64'h1AAE_155C_ACC5_4210);   
      
      test_csr_read_32(result, addr_mode, VIRTIO_DFH, 64'h00000000 );
      test_csr_read_32(result, addr_mode, VIRTIO_DFH+4, 64'h10000100); 

      test_csr_read_32(result, addr_mode, VIRTIO_GUID_L, 64'h90B9_70C4);   
      test_csr_read_32(result, addr_mode, VIRTIO_GUID_L+4, 64'hB9AB_EFBD);
      test_csr_read_32(result, addr_mode, VIRTIO_GUID_H, 64'hACC5_4210);
      test_csr_read_32(result, addr_mode, VIRTIO_GUID_H+4, 64'h1AAE_155C); 

      test_csr_access_64(result, addr_mode, VIRTIO_SCRATCHPAD, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, VIRTIO_SCRATCHPAD, 'haa08_08aa);   
   
   $display("\n---------------------------------------");
   $display("Test CSR access to HPS (PF4) CE-NULL");
   $display("---------------------------------------\n");
      pfvf = '{4,0,0}; // Set PFVF to PF4
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 'haa09_09aa);   
      
   post_test_util(old_test_err_count);
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
   //logic [4:0][31:0] unsupported_addr_vec;
   logic [4:0][63:0] unsupported_addr_vec;
   uint32_t      length;
   cpl_status_t  cpl_status;
   return_data_t return_data;
begin
   print_test_header("test_afu_mmio");
   old_test_err_count = get_err_count();
   
   result = 1'b1;
   addr_mode = ADDR32;

   // AFU CSR
   pfvf = '{0,0,0}; // Set PFVF to PF0
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
   host_bfm_top.host_bfm.set_bar(4'd2);
   test_csr_access_32(result, addr_mode, 64'h41000, 'hAFC0_0001);   
   test_csr_access_64(result, addr_mode, 64'h41020, 'hAFC0_0003_AFC0_0002);  

   // AFU unsupported address range should return 0
   unsupported_addr_vec[0] = 64'h0000_0000_0004_0030;
   unsupported_addr_vec[1] = 64'h0000_0000_0004_1200;
   unsupported_addr_vec[2] = 64'h0000_0000_0004_2060;
   unsupported_addr_vec[3] = 64'h0000_0000_0004_3030;
   unsupported_addr_vec[4] = 64'h0000_0000_0004_4000;
   for (int i=0; i<5; ++i) begin
      addr = unsupported_addr_vec[i];
      //WRITE64(addr_mode, addr, 2, 1'b0, 0, 0, 64'h1234_5678_9abc_def0); 
      host_bfm_top.host_bfm.write64(addr, 64'h1234_5678_9abc_def0);
      test_csr_read_64(result, addr_mode, addr, 'h0);
      if (~result) begin
         $display("Error: MMIO read to unsupported AFU address (addr=0x%0x) doesn't return 0.", addr);
      end
   end
  
   //--------------------------------------------------------------
   // Test illegal memory read returns CPL: Misaligned Address
   //--------------------------------------------------------------
   addr = 64'h0000_0000_0004_1001;
   host_bfm_top.host_bfm.read64_with_completion_status(addr, scratch, error, cpl_status);
   if (~error) begin
       $display("\nERROR: MMIO read with unaligned address did not return CPL with unsuccessful status.\n");
       $display("   Address: %H_%H_%H_%H", addr[63:48], addr[47:32], addr[31:16], addr[15:0]);
       incr_err_count();
       result = 1'b0;
   end
   //--------------------------------------------------------------
   // Test illegal length request of 16 bytes (instead of 4 or 8)
   //--------------------------------------------------------------
   addr = 64'h0000_0000_0004_1000;
   host_bfm_top.host_bfm.read_data_with_completion_status(addr, 16, scratch, return_data, error, cpl_status);
   if (~error) begin
       $display("\nERROR: MMIO read with illegal length did not return CPL with unsuccessful status.\n");
       $display("   CSR Read Length (Bytes): %0d", length);
       incr_err_count();
       result = 1'b0;
   end

   post_test_util(old_test_err_count);
end
endtask

// Test back-to-back MMIO write and read 
task test_mmio_burst;
   output logic result;
   input logic  valid_csr_region;
   input [3:0]  bar;
   input logic [63:0] base_addr;
   input [1024*8-1:0] test_name;
   logic [63:0] addr;
   logic [63:0] exp_data;
   logic [63:0] scratch;
   logic [1:0]  status;
   logic [31:0] old_test_err_count;
   Transaction     #(pf_type, vf_type, pf_list, vf_list) t, rtc;
   uint64_t rtc_num;
   WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt, wtc;
   uint64_t wtc_num;
   WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt_queue[$];
   WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt_match_queue[$];
   ReadTransaction #(pf_type, vf_type, pf_list, vf_list) rt;
   Transaction     #(pf_type, vf_type, pf_list, vf_list) rt_queue[$];
   Transaction     #(pf_type, vf_type, pf_list, vf_list) rt_match_queue[$];
   string access_source;
   bit [3:0] first_dw_be = 4'b1111;
   bit [3:0] last_dw_be  = 4'b1111;
   byte_t write_data[];
   byte_t read_data[];
   bit [31:0] wdata;
   bit [31:0] rdata;
   int burst_num = 128;
begin
   print_test_header(test_name);
   old_test_err_count = get_err_count();
   result = 1'b1;
   access_source = "Unit Test, Test MMIO Burst";
   wt_queue.delete();
   rt_queue.delete();

   // Stretch test MMIO write access with a burst of MMIO write
   addr = base_addr;
   for (int i=0; i<burst_num; i=i+1) begin
      $display("Write32: address=0x%x bar=%0d pfn=0 vfn=0, data=0x%x", addr, bar, (i+1));
      //----------------------------------------------------------------
      // Use Transaction objects to create the reads & writes required.
      //----------------------------------------------------------------
      // Create the Write Transactions
      //----------------------------------------------------------------
      wdata = i+1;
      wt = new(
         .access_source(access_source),
         .address(addr),
         .length_dw(1),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      wt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
      wt.set_master_gap(0);
      write_data = new[4]; // 4 bytes per word.
      write_data = {<<8{wdata}};
      wt.write_request_packet.set_data(write_data);
      wt_queue.push_back(wt);
      t = wt;
      // Send all the Write Transactions
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
      addr += 64'h4;
   end
   //----------------------------------------------------------------
   // Create the Read Transactions
   //----------------------------------------------------------------
   addr = base_addr;
   for (int i=0; i<burst_num; i=i+1) begin
      rt = new(
         .access_source(access_source),
         .address(addr),
         .length_dw(1),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      rt.set_pf_vf(host_bfm_top.host_bfm.get_pfvf_setting());
      t = rt;
      // Send all the Read Transactions
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(t);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
      addr += 64'h4;
   end
   @(posedge host_bfm_top.axis_rx_req.clk iff (host_bfm_top.mmio_rx_req_completed_transaction_queue.size() == burst_num));
   host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.get();
   rt_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue;
   host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.put();
   addr = base_addr;
   for (int i=0; i<burst_num; i=i+1) begin
      wt_match_queue = wt_queue.find() with (item.get_address() == addr);
      rt_match_queue = rt_queue.find() with (item.get_address() == addr);
      if ((wt_match_queue.size() > 0) && (rt_match_queue.size() > 0))
      begin
         wtc = wt_match_queue[0];
         rtc = rt_match_queue[0];
         wtc_num = wtc.get_transaction_number();
         rtc_num = rtc.get_transaction_number();
         write_data = new[wtc.request_packet.get_payload_size()];
         wtc.request_packet.get_payload(write_data);
         if (valid_csr_region)
         begin
            wdata = {<<8{write_data}};
         end
         else
         begin
            wdata = '0;
         end
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
      end
      else
      begin
         if (wt_match_queue.size() == 0)
         begin
            $display(">>> ERROR: No Write Transaction Match found for address:%H", addr);
            incr_err_count;
            result = 1'b0;
         end
         if (rt_match_queue.size() == 0)
         begin
            $display(">>> ERROR: No Read Transaction Match found for address:%H", addr);
            incr_err_count;
            result = 1'b0;
         end
      end
      wt_queue = wt_queue.find() with (item.get_transaction_number() != wtc_num);
      rt_queue = rt_queue.find() with (item.get_transaction_number() != rtc_num);
      host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.get();
      host_bfm_top.mmio_rx_req_completed_transaction_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue.find() with (item.get_transaction_number() != rtc_num);
      host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.put();
      addr += 64'h4;
   end
   post_test_util(old_test_err_count);
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
      $display("Entering HE Null Test.");
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      pfvf = '{2,0,0}; // Set PFVF to PF2
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);

      test_mmio_addr32   (test_result);
      test_mmio_addr64   (test_result);
   end
endtask


endmodule
