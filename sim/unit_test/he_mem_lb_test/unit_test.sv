// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT
//---------------------------------------------------------
// Test module for the simulation. 
//---------------------------------------------------------


module unit_test #(
   parameter SOC_ATTACH = 0,
   parameter LINK_NUMBER = 0,
   parameter type pf_type = host_bfm_types_pkg::default_pfs, 
   parameter pf_type pf_list = '{1'b1}, 
   parameter type vf_type = host_bfm_types_pkg::default_vfs, 
   parameter vf_type vf_list = '{0}
)(
   input logic clk,
   input logic rst_n,
   input logic csr_clk,
   input logic csr_rst_n
);

import pfvf_class_pkg::*;
import host_ofs_bfm_memory_class_pkg::*;
import tag_manager_class_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;
import host_axis_send_class_pkg::*;
import host_axis_receive_class_pkg::*;
import host_transaction_class_pkg::*;
import host_bfm_types_pkg::*;
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
localparam string unit_test_name = "HE-MEM Loopback Test";
localparam BUS_WIDTH = host_bfm_types_pkg::TDATA_WIDTH;
localparam BUS_BYTE_WIDTH = host_bfm_types_pkg::TDATA_WIDTH / 8;

// From HE CSRs
test_csr_defs::t_info0 csr_info0;
int local_mem_bus_bytes;

//---------------------------------------------------------
// Mailbox 
//---------------------------------------------------------
mailbox #(host_bfm_types_pkg::mbx_message_t) mbx = new();
host_bfm_types_pkg::mbx_message_t mbx_msg;


typedef struct packed {
   logic result;
   logic [1024*8-1:0] name;
} t_test_info;

int err_count = 0;
logic [31:0] test_id;
t_test_info [MAX_TEST-1:0] test_summary;
logic reset_test;
logic [7:0] checker_err_count;
logic test_done;
logic all_tests_done;
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
   $display("\n");
   $display("****************************************************************");
   $display(" Running TEST(%0d) : %0s", test_id, test_name);
   $display("****************************************************************");
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
   pfvf = '{0,0,0};
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


// Memory loopback test util
task test_mem_loopback_util;
   output logic result;
   input  logic mem_display_on;
   input  logic [2:0]  test_mode;
   input  logic [3:0][BUS_WIDTH-1:0] test_data;
   input  logic [63:0] src_base_addr;
   input  logic [63:0] dst_base_addr;
   input  logic [63:0] dsm_base_addr;
   input  logic [1:0]  cl_mode;
   input  logic [16:0] num_cl; 
   input  logic	     cont_mode;
   string 	           test_name;
   
   logic [31:0] src_addr;
   logic [31:0] dst_addr;
   logic [31:0] wdata;
   logic [31:0] he_cfg;
   logic [63:0] scratch;
   logic [63:0] src_data;
   logic        err_src_addr;
   logic        err_dst_addr;
   byte_t       init_buf[];
   byte_t       read_buf[];
   int          bus_bytes;
begin
   result = 1'b1;

   err_src_addr = |src_base_addr[$clog2(BUS_BYTE_WIDTH)-1:0];
   err_dst_addr = |dst_base_addr[$clog2(BUS_BYTE_WIDTH)-1:0];

   if (err_src_addr) 
   begin
      $display("Error: Source buffer address (0x%0x) is not aligned to cacheline boundary (%0d bytes).", src_base_addr, BUS_BYTE_WIDTH);
   end
   
   if (err_dst_addr) 
   begin
      $display("Error: Destination buffer address (0x%0x) is not aligned to cacheline boundary (%0d bytes).", dst_base_addr, BUS_BYTE_WIDTH);
   end

   result = ~(err_src_addr | err_dst_addr);

   if (~result) 
   begin
      incr_err_count();
   end 
   else 
   begin    
      if(test_mode == 3'b000) 
      begin
         $display("\n (1) Writing test data to source buffer starting at 0x%x", src_base_addr);
         for (int cl=0; cl<num_cl; ++cl) 
         begin
            for (int i=0; i<BUS_BYTE_WIDTH/8; i=i+1) 
            begin
               src_addr = (src_base_addr+cl*BUS_BYTE_WIDTH+i*8);
               dst_addr = (dst_base_addr+cl*BUS_BYTE_WIDTH+i*8);
               // Write data to source buffer
               init_buf = new[8]; 
               init_buf = {<<byte_t{test_data[cl%4][i*64+:64]}};
               host_bfm_top.host_memory.initialize_data(src_addr, init_buf);
               // Clear destination buffer
               init_buf = new[8]; 
               init_buf = {<<byte_t{64'h0}};
               host_bfm_top.host_memory.initialize_data(dst_addr, init_buf);
            end
         end
      end // if (test_mode == 3'b000)
      else 
      begin
         for (int cl=0; cl<1024; ++cl) 
         begin
            for (int i=0; i<BUS_BYTE_WIDTH/8; i=i+1) 
            begin
               src_addr = (src_base_addr+cl*BUS_BYTE_WIDTH+i*8);
               // Init source buffer to 0
               init_buf = new[8]; 
               init_buf = {<<byte_t{64'h0}};
               host_bfm_top.host_memory.initialize_data(src_addr, init_buf);
            end
         end
      end // else: !if(test_mode == 3'b000)
      
      // Clear DSM base address
      init_buf = new[8]; 
      init_buf = {<<byte_t{64'h0}};
      host_bfm_top.host_memory.initialize_data(dsm_base_addr, init_buf);
   
      if (mem_display_on) host_bfm_top.host_memory.dump_mem(src_base_addr, num_cl*BUS_BYTE_WIDTH); // Bytes
          
      //-----------------------------------
      // Start memory loopback test
      //-----------------------------------
      test_name = (test_mode == 3'b000) ? "loopback" : 
		  (test_mode == 3'b001) ? "read"     :
		  (test_mode == 3'b010) ? "write"    : "trput";
      
      $display("\n (2) Start memory %s test",test_name);
      
      wdata = '0;
      wdata[0] = 1'b1;
      // Clear Reset & start bit
      host_bfm_top.host_bfm.write32(CTL, wdata);

      // Configure he-lb
      wdata = '0;
      wdata[1]   = cont_mode;//cont_mode;
      wdata[6:5] = cl_mode;
      wdata[4:2] = test_mode;
      host_bfm_top.host_bfm.write32(CFG, wdata);
    
      // Configure number of CL for test
      wdata = '0;
      wdata[16:0] = num_cl-1;
      host_bfm_top.host_bfm.write32(NUM_LINES, wdata);
      
      // Configure inactivity threshold
      wdata = '0;
      wdata[31:0] = 32'h1000_0000;
      host_bfm_top.host_bfm.write32(INACT_THRESH, wdata);

      // SRC and DST addresses
      host_bfm_top.host_bfm.write64(SRC_ADDR, {'0, src_base_addr[31:$clog2(BUS_BYTE_WIDTH)]});
      host_bfm_top.host_bfm.write64(DST_ADDR, {'0, dst_base_addr[31:$clog2(BUS_BYTE_WIDTH)]});
  
      // DSM base address
      host_bfm_top.host_bfm.write64(DSM_BASEL, {'0, dsm_base_addr[31:$clog2(BUS_BYTE_WIDTH)]});
     
      // Start the test
      wdata = '0;
      wdata[0] = 1'b1; // Set the start bit
      wdata[1] = 1'b1; // Set the start bit
      host_bfm_top.host_bfm.write32(CTL, wdata);
  
      wdata = '0;
      if(cont_mode) 
      begin
         #40000000;
         wdata[0] = 1'b1; // Set the start bit
         wdata[2]   = 1'b1; // Set stop bit
         host_bfm_top.host_bfm.write32(CTL, wdata);
      end
      
      scratch = '0;
      while (~|scratch) 
      begin
         $display("(3) Polling for DSM completion bit to set");
         read_buf = new[4]; // Storage for 1DW of data.
         host_bfm_top.host_memory.read_data_host(dsm_base_addr, read_buf);
         scratch = {<<byte_t{read_buf}};
         if (~|scratch) 
         begin
            #1000000; // Delay to allow downstream MRd and MWr
         end
      end

      wdata = '0;
      // Reset & clear the start bit
      host_bfm_top.host_bfm.write32(CTL, wdata);
      if(test_mode == 3'b000) 
      begin
         $display("\n (4) Checking data at destination buffer starting at 0x%x", dst_base_addr);
         if (mem_display_on) host_bfm_top.host_memory.dump_mem(dst_base_addr, num_cl*BUS_BYTE_WIDTH); // Bytes
   
         // If the local memory bus is narrower than the host bus, HE MEM
         // drops the data the doesn't fit.
         bus_bytes = (local_mem_bus_bytes < BUS_BYTE_WIDTH) ? local_mem_bus_bytes : BUS_BYTE_WIDTH;

         for (int cl=0; cl<num_cl; ++cl)
         begin
            for (int i=0; i<bus_bytes/8; i=i+1)
            begin
               dst_addr = (dst_base_addr+cl*BUS_BYTE_WIDTH+i*8);
               src_addr = (src_base_addr+cl*BUS_BYTE_WIDTH+i*8);
               read_buf = new[8]; // Storage for 2DW of data.
               host_bfm_top.host_memory.read_data_host(src_addr, read_buf);
               src_data = {<<byte_t{read_buf}};
               read_buf = new[8]; // Storage for 2DW of data.
               host_bfm_top.host_memory.read_data_host(dst_addr, read_buf);
               scratch = {<<byte_t{read_buf}};
               if (scratch !== src_data)
               begin
                  $display("\nERROR: write and read mismatch at address 0x%0x! write=0x%x read=0x%x\n", dst_addr, src_data, scratch);
                  $display("\nERROR: Loopback test mismatch!\n");
                  incr_err_count();
                  result = 1'b0;
                  break;
               end
            end
         end // for (int cl=0; cl<num_cl; ++cl)
      end // if (test_mode == 3'b000)

      $display("(5) Reading test performance counters");
      read_buf = new[8]; // Storage for 2DW of data.
      host_bfm_top.host_memory.read_data_host(dsm_base_addr+8, read_buf);
      scratch = {<<byte_t{read_buf}};
      $display("        Number of cycles: %d", scratch[39:0]);
      read_buf = new[8]; // Storage for 2DW of data.
      host_bfm_top.host_memory.read_data_host(dsm_base_addr+16, read_buf);
      scratch = {<<byte_t{read_buf}};
      $display("        Number of reads : %d", scratch[31:0]);
      $display("        Number of writes: %d", scratch[63:31]);
   end
end
endtask


// Test HE-LB memory write/read 
task test_mem_loopback;
   output logic result;
   input  logic mem_display_on;
   input  logic [2:0]  test_mode;
   input  logic [1:0]  cl_mode;
   input  logic [16:0] num_cl;
   input  logic        cont_mode;
   input  [1024*8-1:0] test_name;

   //logic  [16:0]       cl_req_len;
   logic  [2:0]        cl_len;
   logic  [3:0][BUS_WIDTH-1:0] test_data;
   logic  [63:0] src_base_addr, dst_base_addr;
   logic  [63:0] dsm_base_addr;
   logic  [31:0] old_test_err_count;
   logic  err_cl_len;
   logic  result = 1'b1;
begin
   print_test_header(test_name);
   old_test_err_count = get_err_count();
   result = 1'b1;

   // Check cl_mode and num_cl alignment
   cl_len = cl_mode + 1'd1;
   case (cl_mode)
      2'd2 : begin
         err_cl_len = num_cl[0];
      end
      2'd3 : begin
         err_cl_len = |num_cl[1:0];
      end
      default : begin
         err_cl_len = 1'b0;
      end
   endcase
      
   if (err_cl_len) 
   begin
      $display("Error: Number of CL (%0d) does not align with cl_mode (%0d), must be multiple of %0d.", num_cl, cl_mode, cl_len);
   end

   result = ~err_cl_len;

   if (~result) 
   begin
      incr_err_count();
   end 
   else 
   begin
      for (int cl=0; cl<4; ++cl) 
      begin
         // Hardcoded MWr and MRd test
         for (int w=0; w<BUS_BYTE_WIDTH/8; ++w)
         begin
            test_data[cl][w*64 +: 64] = {cl[3:0], {15{4'(w+1)}}};
         end
      end
      src_base_addr = 64'h0;
      dst_base_addr = 64'h0010_0000;
      dsm_base_addr = 64'h0020_0000;
      test_mem_loopback_util(result, mem_display_on, test_mode, test_data, src_base_addr, dst_base_addr, dsm_base_addr, cl_mode, num_cl, cont_mode);

      src_base_addr = src_base_addr + BUS_BYTE_WIDTH;
      dst_base_addr = dst_base_addr + BUS_BYTE_WIDTH;
      dsm_base_addr = dsm_base_addr + BUS_BYTE_WIDTH;
      if (result) 
      begin
         test_mem_loopback_util(result, mem_display_on, test_mode, test_data, src_base_addr, dst_base_addr, dsm_base_addr, cl_mode, num_cl, cont_mode);
      end
   end
   post_test_util(old_test_err_count);
end
endtask


task test_emif_calibration;
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
   all_tests_done = 1'b0;
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
      $display("\n");
      $display("***************************");
      $display("  Test summary for link %0d", LINK_NUMBER);
      $display("***************************");
      for (int i=0; i < test_id; i=i+1) 
      begin
         if (test_summary[i].result)
            $display("   %0s (id=%0d) - pass", test_summary[i].name, i);
         else
            $display("   %0s (id=%0d) - FAILED", test_summary[i].name, i);
      end

      if(get_err_count() == 0) 
      begin
          $display("");
          $display("");
          $display("-----------------------------------------------------");
          $display("Test passed!");
          $display("Test:%s for--> Link:%0d", unit_test_name, LINK_NUMBER);
          $display("-----------------------------------------------------");
          $display("");
          $display("");
          $display("      '||''|.      |      .|'''.|   .|'''.|  ");
          $display("       ||   ||    |||     ||..  '   ||..  '  ");
          $display("       ||...|'   |  ||     ''|||.    ''|||.  ");
          $display("       ||       .''''|.  .     '|| .     '|| ");
          $display("      .||.     .|.  .||. |'....|'  |'....|'  ");
          $display("");
          $display("");
      end 
      else 
      begin
          if (get_err_count() != 0) 
          begin
             $display("");
             $display("");
             $display("-----------------------------------------------------");
             $display("Test FAILED! %d errors reported.\n", get_err_count());
             $display("Test:%s for--> Link:%0d", unit_test_name, LINK_NUMBER);
             $display("-----------------------------------------------------");
             $display("");
             $display("");
             $display("      '||''''|     |     '||' '||'      ");
             $display("       ||  .      |||     ||   ||       ");
             $display("       ||''|     |  ||    ||   ||       ");
             $display("       ||       .''''|.   ||   ||       ");
             $display("      .||.     .|.  .||. .||. .||.....| ");
             $display("");
             $display("");
          end
       end
   end
   
   join_any    
   if (LINK_NUMBER == 0)
   begin
      wait (all_tests_done);
      $finish();  
   end
end

generate
   if (LINK_NUMBER != 0)
   begin // This block covers the scenario where there is more than one link and link N needs to coordinate execution with link0.
      always begin : main   
         #10000;
         wait (rst_n);
         wait (csr_rst_n);
         $display(">>> Link #%0d: Sending READY to Link0.  Waiting for release.", LINK_NUMBER);
         host_gen_block0.pcie_top_host0.unit_test.mbx.put(READY);
         mbx_msg = START;
         while (mbx_msg != GO)
         begin
            $display("Mailbox #%0d State: %s", LINK_NUMBER, mbx_msg.name());
            mbx.get(mbx_msg);
         end
         /* $display(">>> Running %s on Link %0d...", unit_test_name, LINK_NUMBER); */
         /* main_test(test_result); */
         /* $display(">>> %s on Link %0d Completed.", unit_test_name, LINK_NUMBER); */
         /* test_done = 1'b1; */
         $display(">>> No HE MEM LB on Link %0d...", LINK_NUMBER);
         $display(">>> Returning execution back to link 0.  Link %0d actions completed.", LINK_NUMBER);
         host_gen_block0.pcie_top_host0.unit_test.mbx.put(DONE);
      end
   end
   else
   begin
      if (NUMBER_OF_LINKS > 1)
      begin // This block covers the scenario where there is more than one link and link0 needs to communicate with the other links.
         always begin : main   
            #10000;
            wait (rst_n);
            wait (csr_rst_n);
            //-------------------------
            // deassert port reset
            //-------------------------
            deassert_afu_reset();
            //-------------------------
            // Test scenarios 
            //-------------------------
            $display(">>> Running %s on Link 0...", unit_test_name);
            main_test(test_result);
            $display(">>> %s on Link 0 Completed.", unit_test_name);
            test_done = 1'b1;
            #1000
            $display(">>> Link #0: Getting status from Link #1 Mailbox, testing for READY");
            mbx.try_get(mbx_msg);
            $display(">>> Link #0: Link #1 shows status as %s.", mbx_msg.name());
            $display(">>> Link #0: %s complete.  Sending GO to Link #1.", unit_test_name);
            mbx_msg = READY;
            host_gen_block1.pcie_top_host1.unit_test.mbx.put(GO);
            while (mbx_msg != DONE)
            begin
               $display("Mailbox #0 State: %s", mbx_msg.name());
               mbx.get(mbx_msg);
            end
            all_tests_done = 1'b1;
         end
      end
      else
      begin  // This block covers the scenario where there is only one link and no mailbox communication is required.
         always begin : main   
            #10000;
            wait (rst_n);
            wait (csr_rst_n);
            //-------------------------
            // deassert port reset
            //-------------------------
            deassert_afu_reset();
            //-------------------------
            // Test scenarios 
            //-------------------------
            $display(">>> Running %s on Link 0...", unit_test_name);
            main_test(test_result);
            $display(">>> %s on Link 0 Completed.", unit_test_name);
            test_done = 1'b1;
            all_tests_done = 1'b1;
         end
      end
   end
endgenerate


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;
   begin
      $display("Entering %s.", unit_test_name);
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      pfvf = '{0,0,1};
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);

      host_bfm_top.host_bfm.read64(test_csr_defs::INFO0, csr_info0);
      $display("HE API version: %0d", csr_info0.he_lb_api_version);
      if (test_csr_defs::bus_bytes(csr_info0) != BUS_BYTE_WIDTH) begin
          $display("\nERROR: Unexpected bus byte width. Is %0d, expected %0d",
                   test_csr_defs::bus_bytes(csr_info0), BUS_BYTE_WIDTH);
          incr_err_count();
          $finish;
      end

      local_mem_bus_bytes = test_csr_defs::local_mem_bus_bytes(csr_info0);
      $display("HE local memory bus byte width: %0d\n", local_mem_bus_bytes);

     `ifdef INCLUDE_DDR4
      wait(top_tb.DUT.local_mem_wrapper.mem_ss_top.mem_ss_cal_success[0] ||
           top_tb.DUT.local_mem_wrapper.mem_ss_top.mem_ss_cal_fail[0]);
      if (top_tb.DUT.local_mem_wrapper.mem_ss_top.mem_ss_cal_fail[0]) begin
          $display("\nERROR: memory calibration failed");
          incr_err_count();
          $finish;
      end
     `endif
     `ifdef INCLUDE_HBM
      wait(top_tb.DUT.local_mem_wrapper.hbm_ss_top.hbm_cal_success[0] ||
           top_tb.DUT.local_mem_wrapper.hbm_ss_top.hbm_cal_fail[0]);
      if (top_tb.DUT.local_mem_wrapper.hbm_ss_top.hbm_cal_fail[0]) begin
          $display("\nERROR: HBM calibration failed");
          incr_err_count();
          $finish;
      end
     `endif

      test_emif_calibration (test_result);

      test_mem_loopback (test_result, 1, 3'h0, 2'h0, 17'd1, 1'b0, "test_mem_loopback: cl_mode (1CL), length (1)");

      // reqlen1_seq
      test_mem_loopback (test_result, 1, 3'h0, 2'h0, 17'd128, 1'b0, "test_mem_loopback: cl_mode (1CL), length (128)");

      // reqlen2_seq
      test_mem_loopback (test_result, 1, 3'h0, 2'h1, 17'd128, 1'b0, "test_mem_loopback: cl_mode (2CL), length (128)");

      // reqlen4_seq
      test_mem_loopback (test_result, 1, 3'h0, 2'h2, 17'd128, 1'b0, "test_mem_loopback: cl_mode (4CL), length (128)");
      
      // reqlen8_seq
      test_mem_loopback (test_result, 1, 3'h0, 2'h3, 17'd128, 1'b0, "test_mem_loopback: cl_mode (8CL) length (128 CL)");

      // cont_mode
      test_mem_loopback (test_result, 1, 3'h0, 2'h3, 17'd1024, 1'b1, "test_mem_loopback: cl_mode (4CL) length (1024 CL) continuous");

      // read/write reqlen1
      test_mem_loopback (test_result, 0, 3'b001, 2'h0, 17'd128, 1'b0, "test_mem_read: cl_mode (1CL) length (128 CL)");   
      test_mem_loopback (test_result, 0, 3'b010, 2'h0, 17'd128, 1'b0, "test_mem_write: cl_mode (1CL) length (128 CL)");   
      test_mem_loopback (test_result, 0, 3'b011, 2'h0, 17'd128, 1'b0, "test_mem_write: cl_mode (1CL) length (128 CL)");   

      // read/write reqlen2
      test_mem_loopback (test_result, 0, 3'b001, 2'h1, 17'd128, 1'b0, "test_mem_read: cl_mode (2CL) length (128 CL)");   
      test_mem_loopback (test_result, 0, 3'b010, 2'h1, 17'd128, 1'b0, "test_mem_write: cl_mode (2CL) length (128 CL)");   
      test_mem_loopback (test_result, 0, 3'b011, 2'h1, 17'd128, 1'b0, "test_mem_read_write: cl_mode (2CL) length (128 CL)");

      // read/write reqlen4
      test_mem_loopback (test_result, 0, 3'b001, 2'h2, 17'd128, 1'b0, "test_mem_read: cl_mode (4CL) length (128 CL)");   
      test_mem_loopback (test_result, 0, 3'b010, 2'h2, 17'd128, 1'b0, "test_mem_write: cl_mode (4CL) length (128 CL)");   
      test_mem_loopback (test_result, 0, 3'b011, 2'h2, 17'd128, 1'b0, "test_mem_read_write: cl_mode (4CL) length (128 CL)");   
   end
endtask


endmodule
