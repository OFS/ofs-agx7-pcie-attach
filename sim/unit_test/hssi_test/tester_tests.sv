// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   This file defines all the test cases for current test.
//
//   main_test() is the main entry function which the tester calls 
//   to execute the unit tests.
//
//-----------------------------------------------------------------------------

import test_csr_defs::*;
import test_param_defs::*;
import top_cfg_pkg::*;

parameter HEH_VF = 1;
parameter HEH_VA = 1; 
parameter HEH_PF = 0;
//-------------------
// Test utilities
//-------------------
task incr_test_id;
begin
   test_id = test_id + 1;
end
endtask

task post_test_util;
   input logic [31:0] old_test_err_count;
   logic result;
begin
   if (test_utils::get_err_count() > old_test_err_count) begin
      result = 1'b0;
   end else begin
      result = 1'b1;
   end

   repeat (10)
      @(posedge avl_clk);

   @(posedge avl_clk);
      reset_test = 1'b1;
   repeat (5)
      @(posedge avl_clk);
   reset_test = 1'b0;

   f_reset_tag();

   if (result) begin
      $display("\nTest status: OK");
      test_summary[test_id].result = 1'b1;
   end else begin
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
// Test 32-bit CSR RW access
task test_csr_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE32(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit CSR RO access
task test_csr_ro_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;

   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR expected and read mismatch! expected=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit CSR access to unused CSR region
task test_unused_csr_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE32(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 32'h0) begin
       $display("\nERROR: Expected 32'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// 32-bit transaction to exercise ch-1
task test_csr_access_32_ch1;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   t_tlp_rp_tag tag0,tag1;
   logic [2:0]  status;
   logic error;
begin
   result = 1'b1;
   // dummy write to ch-0
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   create_mwr_packet(addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn, 32'h0BAD_F00D);

   // channel-1 write
   $display("WRITE32: address=0x%x bar=%0d pfn=%0d vfn=%0d, data=0x%x", addr, bar, pfn, vfn, data);
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   create_mwr_packet(addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn, data);

   // dummy read from ch-0
   f_get_tag(tag0);
      // tag, addr_32, address, length, bar, vf_active, pfn, vfn 
   create_mrd_packet(tag0, addr_mode, AFU_DFH_ADDR, 10'd1, bar, vf_active, pfn, vfn);

   // ch-1 read
   f_get_tag(tag1);
   $display("READ32: address=0x%x bar=%0d pfn=%0d vfn=%0d\n", addr, bar, pfn, vfn);
      // tag, addr_32, address, length, bar, vf_active, pfn, vfn 
   create_mrd_packet(tag1, addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn);
   f_send_test_packet();

   read_mmio_rsp(tag1, scratch, status);
   if (status !== 3'b0) begin 
      error = 1'b1;
      data = '0;
   end else begin
      error = 1'b0;
   end

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// 64-bit transaction to exercise ch-1
task test_csr_access_64_ch1;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   t_tlp_rp_tag tag0,tag1;
   logic [2:0]  status;
   logic error;
begin
   result = 1'b1;
    // dummy write to ch-0
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   create_mwr_packet(addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn, 32'h0BAD_F00D);

   $display("WRITE64: address=0x%x bar=%0d pfn=%0d vfn=%0d, data=0x%x", addr, bar, pfn, vfn, data);
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   create_mwr_packet(addr_mode, addr, 10'd2, bar, vf_active, pfn, vfn, data);

   // dummy read from ch-0
   f_get_tag(tag0);
      // tag, addr_32, address, length, bar, vf_active, pfn, vfn 
   create_mrd_packet(tag0, addr_mode, AFU_DFH_ADDR, 10'd1, bar, vf_active, pfn, vfn);

   f_get_tag(tag1);
   $display("READ64: address=0x%x bar=%0d pfn=%0d vfn=%0d\n", addr, bar, pfn, vfn);
      // tag, addr_32, address, length, bar, vf_active, pfn, vfn 
   create_mrd_packet(tag1, addr_mode, addr, 10'd2, bar, vf_active, pfn, vfn);
   f_send_test_packet();

   read_mmio_rsp(tag1, scratch, status);
   if (status !== 3'b0) begin 
      error = 1'b1;
      data = '0;
   end else begin
      error = 1'b0;
   end

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR RW access
task test_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE64(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR RO access
task test_csr_ro_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;

   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR expected and read mismatch! expected=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR access to unused CSR region
task test_unused_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE64(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 64'h0) begin
       $display("\nERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR read access
task test_csr_read_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit data access with 64b address
task test_csr_access_32_addr64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE32(addr_mode, {32'h0000_eecc,addr}, bar, vf_active, pfn, vfn, data);	
   READ32(addr_mode, {32'h0000_eecc,addr}, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test AFU MMIO read write
task test_afu_mmio;
   output logic result;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [2:0]  bar;
   logic vf_active;
   logic [PF_WIDTH-1:0] pfn;
   logic [VF_WIDTH-1:0] vfn;
begin
   print_test_header("test_afu_mmio");
   old_test_err_count = test_utils::get_err_count();
   
   result      = 1'b1;
   addr_mode   = ADDR32;
   bar         = 3'h0;
   vf_active   = 1'b1;
   pfn         = 1'b0;
   vfn         = 1'b1;
   
   // AFU CSR
   // RO Register check
   test_csr_ro_access_64(result, addr_mode, AFU_DFH_ADDR, bar, vf_active, pfn, vfn, AFU_DFH_VAL);
   test_csr_ro_access_64(result, addr_mode, AFU_ID_L_ADDR, bar, vf_active, pfn, vfn, AFU_ID_L_VAL);
   test_csr_ro_access_64(result, addr_mode, AFU_ID_H_ADDR, bar, vf_active, pfn, vfn, AFU_ID_H_VAL);
   
   // RW access check using scratchpad
   test_csr_access_32(result, addr_mode, AFU_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0001);
   test_csr_access_64(result, addr_mode, AFU_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0003_AFC0_0002);
   test_csr_access_32_ch1(result, addr_mode, AFU_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0004);
   test_csr_access_64_ch1(result, addr_mode, AFU_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0006_AFC0_0005);
   test_csr_access_32_addr64(result, ADDR64, AFU_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0007);
   // Test illegal memory read returns CPL
   test_unused_csr_access_32(result, addr_mode, AFU_UNUSED_ADDR, bar, vf_active, pfn, vfn, 'hF00D_0001);
   test_unused_csr_access_64(result, addr_mode, AFU_UNUSED_ADDR, bar, vf_active, pfn, vfn, 'hF00D_0003_F00D_0002);

   post_test_util(old_test_err_count);
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
   logic [2:0]  bar;
   logic vf_active;
   logic [PF_WIDTH-1:0] pfn;
   logic [VF_WIDTH-1:0] vfn;
begin
   print_test_header("test_hssi_ss_mmio");
   old_test_err_count = test_utils::get_err_count();
   
   result      = 1'b1;
   addr_mode   = ADDR32;
   bar         = 3'h0;
   vf_active   = 1'b0;
   pfn         = 3'h0;
   vfn         = 0;
   
   // HSSI Wrapper CSR check
   test_csr_access_64(result, addr_mode, HSSI_WRAP_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0002_AFC0_0001);
   test_csr_access_32(result, addr_mode, HSSI_WRAP_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0003);
   // HSSI SS CSR check
   test_csr_ro_access_32(result, addr_mode, HSSI_DFH_LO_ADDR, bar, vf_active, pfn, vfn, HSSI_DFH_LO_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_DFH_HI_ADDR, bar, vf_active, pfn, vfn, HSSI_DFH_HI_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_VER_ADDR, bar, vf_active, pfn, vfn, HSSI_VER_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_FEATURE_ADDR, bar, vf_active, pfn, vfn, HSSI_FEATURE_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT0_ATTR_ADDR, bar, vf_active, pfn, vfn, HSSI_IF_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT0_STATUS_ADDR, bar, vf_active, pfn, vfn, HSSI_PORT_STATUS_VAL);
   test_csr_ro_access_64(result, addr_mode, HSSI_DFH_LO_ADDR, bar, vf_active, pfn, vfn, {HSSI_DFH_HI_VAL, HSSI_DFH_LO_VAL});
   // Unused CSR check
   test_unused_csr_access_32(result, addr_mode, HSSI_WRAP_UNUSED_ADDR, bar, vf_active, pfn, vfn, 'hF00D_0004);
   test_unused_csr_access_64(result, addr_mode, HSSI_WRAP_UNUSED_ADDR, bar, vf_active, pfn, vfn, 'hF00D_0006_F00D_0005);
 
   post_test_util(old_test_err_count);
end
endtask

// Mailbox write
task write_mailbox;
   input logic         access32; // Enabling 32-bit data access
   input logic [31:0]  bar;
   input logic [31:0]  cmd_ctrl_addr; // Start address of mailbox access reg
   input logic [31:0]  addr; //Byte address
   input logic [31:0]  write_data32;
   begin
     if (access32) begin
         WRITE32(ADDR32, cmd_ctrl_addr + MB_WRDATA_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, write_data32);
         WRITE32(ADDR32, cmd_ctrl_addr + MB_ADDRESS_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, addr); 
         WRITE32(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_WR); 
         read_ack_mailbox(bar, cmd_ctrl_addr);
         //#1000000
         WRITE32(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_NOOP);
         $display("INFO: Wrote MAILBOX ADDR:%x, WRITE_DATA32:%X", addr, write_data32);
     end 
     else begin
         WRITE64(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, {write_data32,32'h0000_0000});
         WRITE64(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, {addr,MB_WR}); 
         read_ack_mailbox(bar, cmd_ctrl_addr);
         //#1000000
         WRITE64(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_NOOP);
         $display("INFO: Wrote MAILBOX ADDR:%x, WRITE_DATA32:%X", addr, write_data32);
     end
   end
endtask

// Mailbox read
task read_mailbox;
   input logic         access32; // Enabling 32-bit data access
   input  logic [31:0] bar;
   input  logic [31:0] cmd_ctrl_addr; // Start address of mailbox access reg
   input  logic [31:0] addr; //Byte address
   output logic [31:0] rd_data32;
   logic        [63:0] scratch;
   logic             error;
   begin
      if (access32) begin
         WRITE32(ADDR32, cmd_ctrl_addr + MB_ADDRESS_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, addr);
         WRITE32(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_RD);
         read_ack_mailbox(bar, cmd_ctrl_addr);
         //#1000000
         READ32(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, rd_data32, error);
         if (error) begin
            $display("\nERROR: Mailbox read failed.\n");
            test_utils::incr_err_count();
         end
         $display("INFO: Read MAILBOX ADDR:%x, READ_DATA32:%X", addr, rd_data32);
         WRITE32(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_NOOP);
      end 
      else begin
         WRITE64(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, {addr,MB_RD});
         read_ack_mailbox(bar, cmd_ctrl_addr);
         //#1000000
         READ64(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar,  HEH_VA, HEH_PF, HEH_VF, scratch, error);
         if (error) begin
            $display("\nERROR: Mailbox read failed.\n");
            test_utils::incr_err_count();
         end
         rd_data32 = scratch[31:0];
         $display("INFO: Read MAILBOX ADDR:%x, READ_DATA32:%X", addr, rd_data32);
         WRITE64(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, MB_NOOP);
      end
   end
endtask

// Mailbox ack check
task read_ack_mailbox;
   input  logic [31:0] bar;
   input  logic [31:0] cmd_ctrl_addr; // Start address of mailbox access reg
          logic [31:0] scratch1;
          logic [4:0]  rd_attempts;
          logic        ack_done;
          logic        error;
   begin
     scratch1     = 32'h0;
     rd_attempts  = 'b0;
     ack_done     = 1'h0;
     
     while (~ack_done && rd_attempts<15) begin
         READ32(ADDR32, cmd_ctrl_addr, bar,  HEH_VA, HEH_PF, HEH_VF, scratch1, error);
         ack_done = scratch1[2];
         #100000
         rd_attempts=rd_attempts+1;
     end
     if (error || (~ack_done)) begin
       $display("\nERROR: Mailbox Ack failed.\n");
       test_utils::incr_err_count();
     end
     $display("Ack status: 0x%0x",ack_done);
   end
endtask

task wait_for_reset_done;
   logic [2:0]          bar;
   logic                vf_active;
   logic [PF_WIDTH-1:0] pfn;
   logic [VF_WIDTH-1:0] vfn;
   logic                error;
   logic                result;
   begin
      bar         = 3'h0;
      vf_active   = 1'b0;
      pfn         = 3'h0;
      vfn         = 0;

      $display("INFO:%t	Waiting for subsystem cold reset deassertion acknowledgment",$time);
      wait(top_tb.DUT.hssi_wrapper.hssi_ss.subsystem_cold_rst_ack_n);
      test_csr_ro_access_32(result, ADDR32, HSSI_WRAP_COLD_RST_ACK_ADDR, bar, vf_active, pfn, vfn, 'h0);
      $display("INFO:%t	Subsystem cold reset deassertion acknowledged",$time);

      $display("INFO:%t	Reset Sequence Complete",$time);
   end
endtask

// Wait for HSSI TX and RX ready
task wait_for_hssi_to_ready;
   logic [2:0]          bar;
   logic                vf_active;
   logic [PF_WIDTH-1:0] pfn;
   logic [VF_WIDTH-1:0] vfn;
   logic                error;
   logic                result;
   logic [31:0]         scratch;
   begin
      bar         = 3'h0;
      vf_active   = 1'b0;
      pfn         = 3'h0;
      vfn         = 0;
      // Port-0
      `ifdef INCLUDE_HSSI_PORT_0
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,0);
        wait(top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p0_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,0);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,0);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p0_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,0);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 0);
        while (top_tb.DUT.hssi_wrapper.hssi_ss.p0_rx_pcs_ready !== 1'b1) @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 0);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 0);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 0);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.p0_tx_lanes_stable === 1'b1);
        @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p0_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 0);
      end
      join_none
      wait fork;

      READ32(ADDR32, HSSI_PORT0_STATUS_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 0,scratch[4],scratch[0]);
      `endif
      `ifdef INCLUDE_HSSI_PORT_1
      // Port-1
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,1);
        wait(top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p1_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,1);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,1);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p1_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,1);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 1);
        while (top_tb.DUT.hssi_wrapper.hssi_ss.p1_rx_pcs_ready !== 1'b1) @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 1);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 1);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 1);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.p1_tx_lanes_stable === 1'b1);
        @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p1_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 1);
      end
      join_none
      wait fork;

      READ32(ADDR32, HSSI_PORT1_STATUS_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 1,scratch[4],scratch[0]);
      `endif
      `ifdef INCLUDE_HSSI_PORT_2
      // Port-2
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,2);
        wait(top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p2_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,2);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,2);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p2_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,2);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 2);
        while (top_tb.DUT.hssi_wrapper.hssi_ss.p2_rx_pcs_ready !== 1'b1) @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 2);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 2);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 2);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.p2_tx_lanes_stable === 1'b1);
        @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p2_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 2);
      end
      join_none
      wait fork;

      READ32(ADDR32, HSSI_PORT2_STATUS_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 2,scratch[4],scratch[0]);
      `endif
      `ifdef INCLUDE_HSSI_PORT_3
      // Port-3
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,3);
        wait(top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p3_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,3);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,3);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p3_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,3);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 3);
        while (top_tb.DUT.hssi_wrapper.hssi_ss.p3_rx_pcs_ready !== 1'b1) @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 3);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 3);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 3);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.p3_tx_lanes_stable === 1'b1);
        @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p3_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 3);
      end
      join_none
      wait fork;

      READ32(ADDR32, HSSI_PORT3_STATUS_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 3,scratch[4],scratch[0]);
      `endif
      `ifdef INCLUDE_HSSI_PORT_4
     // Port-4
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,4);
        wait(top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p4_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,4);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,4);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p4_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,4);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 4);
        while (top_tb.DUT.hssi_wrapper.hssi_ss.p4_rx_pcs_ready !== 1'b1) @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 4);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 4);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 4);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.p4_tx_lanes_stable === 1'b1);
        @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p4_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 4);
      end
      join_none
      wait fork;

      READ32(ADDR32, HSSI_PORT4_STATUS_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 4,scratch[4],scratch[0]);
      `endif
      `ifdef INCLUDE_HSSI_PORT_5
     // Port-5
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,5);
        wait(top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p5_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,5);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,5);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p5_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,5);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 5);
        while (top_tb.DUT.hssi_wrapper.hssi_ss.p5_rx_pcs_ready !== 1'b1) @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 5);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 5);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 5);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.p5_tx_lanes_stable === 1'b1);
        @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p5_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 5);
      end
      join_none
      wait fork;

      READ32(ADDR32, HSSI_PORT5_STATUS_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 5,scratch[4],scratch[0]);
      `endif
      `ifdef INCLUDE_HSSI_PORT_6
      // Port-6
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,6);
        wait(top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p6_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,6);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,6);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p6_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,6);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 6);
        while (top_tb.DUT.hssi_wrapper.hssi_ss.p6_rx_pcs_ready !== 1'b1) @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 6);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 6);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 6);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.p6_tx_lanes_stable === 1'b1);
        @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p6_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 6);
      end
      join_none
      wait fork;

      READ32(ADDR32, HSSI_PORT6_STATUS_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 6,scratch[4],scratch[0]);
      `endif
      `ifdef INCLUDE_HSSI_PORT_7
      // Port-7
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,7);
        wait(top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p7_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,7);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,7);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p7_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,7);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 7);
        while (top_tb.DUT.hssi_wrapper.hssi_ss.p7_rx_pcs_ready !== 1'b1) @(negedge top_tb.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 7);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 7);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 7);
        wait (top_tb.DUT.hssi_wrapper.hssi_ss.p7_tx_lanes_stable === 1'b1);
        @(posedge top_tb.DUT.hssi_wrapper.hssi_ss.o_p7_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 7);
      end
      join_none
      wait fork;

      READ32(ADDR32, HSSI_PORT7_STATUS_ADDR, bar, vf_active, pfn, vfn, scratch, error);
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 7,scratch[4],scratch[0]);
      `endif
      #5000000
      // Check rx pcs ready, tx lane stable and pll lock by reading register
      test_csr_ro_access_64(result, ADDR32, HSSI_WRAP_STATUS_ADDR, bar, vf_active, pfn, vfn, HSSI_WRAP_STATUS_VAL);
      
   end
endtask

// Wait until all packets received back
task wait_for_all_eop_done;
   input logic [31:0]  num_pkt;
   logic [31:0]        pkt_cnt;
   begin
      pkt_cnt = 32'h0;
      while (pkt_cnt < num_pkt) begin
	      @(posedge top_tb.DUT.afu_top.port_gasket.pr_slot.afu_main.port_afu_instances.afu_gen[1].heh_gen.he_hssi_inst.multi_port_axi_traffic_ctrl_inst.GenBrdg[0].axis_to_avst_bridge_inst.avst_rx_st.rx.eop);
         @(posedge top_tb.DUT.afu_top.port_gasket.pr_slot.afu_main.port_afu_instances.afu_gen[1].heh_gen.he_hssi_inst.multi_port_axi_traffic_ctrl_inst.GenBrdg[0].axis_to_avst_bridge_inst.avst_rx_st.clk);
         pkt_cnt=pkt_cnt+1;
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
   end
endtask

// HSSI Traffic test for 10G/25G variant
task traffic_10G_25G;
   input logic  access32;
   logic [31:0] scratch1;
   begin
      //---------------------------------------------------------------------------
      // Traffic Controller Configuration
      //---------------------------------------------------------------------------
      for (int id=NUM_ETH_CHANNELS-1; id >=0;id--) begin
         WRITE32(ADDR32, AFU_PORT_SEL_ADDR, 0,  HEH_VA, HEH_PF, HEH_VF, 32'h1*id);
         // Port-0
         if (id == 0) begin
            //Set packet length type
            write_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_TYPE_ADDR, TG_PKT_LEN_TYPE_VAL);
            //Set packet length
            write_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_ADDR, TG_PKT_LEN_VAL);
            //Set data pattern type
            write_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, TG_DATA_PATTERN_ADDR, TG_DATA_PATTERN_VAL);
            //Set number of packets
            write_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR,TG_NUM_PKT_ADDR, TG_NUM_PKT_VAL);
            //Set start to send packets
            write_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, TG_START_XFR_ADDR, 32'h1);
         end
         else begin
            // enable loopback for channel-1 onwards
            write_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, LOOPBACK_EN_ADDR, 32'h1);
         end
      end
      wait_for_all_eop_done(TG_NUM_PKT_VAL);
      //---------------------------------------------------------------------------
      // Read Monitor statistics
      //---------------------------------------------------------------------------

      // Port-0
      WRITE32(ADDR32, AFU_PORT_SEL_ADDR, 0,  HEH_VA, HEH_PF, HEH_VF, 32'h0);
      read_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, TM_PKT_GOOD_ADDR, scratch1);
      if (scratch1 != TG_NUM_PKT_VAL) begin
         test_utils::incr_err_count();
         $display("\nError: Received good packets does not match Transmitted packets on Port-%0d !\n",0);
         $display("Number of Good Packets Received: \tExpected: %0d\n \tRead: %0d",TG_NUM_PKT_VAL,scratch1);
      end else begin
         $display("INFO: Number of Good Packets Received on Port-%0d :%0d",0,scratch1);
      end
      // Bad packet received at Traffic monitor
      read_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, TM_PKT_BAD_ADDR, scratch1);
      if (scratch1 != 32'h0) begin
         test_utils::incr_err_count();
         $display("\nError: Received bad packets on Port-%0d !\n",0);
         $display("Number of Bad Packets Received: \tExpected: %0d\n \tRead: %0d",32'h0,scratch1);
      end else begin
         $display("INFO: Number of Bad Packets Received on Port-%0d :%0d",0,scratch1);
      end

   end
endtask

// HSSI Traffic test for 100G variant
task traffic_100G;
   input logic  access32;
   logic [31:0] tx_cnt;
   logic [31:0] rx_cnt;
   begin
      //---------------------------------------------------------------------------
      // Traffic Controller Configuration
      //---------------------------------------------------------------------------
      $display("T:%8d INFO: write mailbox",$time);
      `ifdef INCLUDE_HSSI_PORT_4
      WRITE32(ADDR32, AFU_PORT_SEL_ADDR, 0,  HEH_VA, HEH_PF, HEH_VF, 32'h1);
      write_mailbox(access32, 0, TRAFFIC_CTRL_CMD_ADDR, 32'h1010, 32'h1E);
      `endif

      WRITE32(ADDR32, AFU_PORT_SEL_ADDR, 0,  HEH_VA, HEH_PF, HEH_VF, 32'h0);
      write_mailbox(access32, 0, TRAFFIC_CTRL_CMD_ADDR, 32'h1010, 32'h14);

      #500000
      //---------------------------------------------------------------------------
      // Read Monitor statistics
      //---------------------------------------------------------------------------

      $display("T:%8d INFO: read mailbox 1",$time);
      read_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, 32'h1009, tx_cnt);
      tx_cnt = {1'b0, tx_cnt[30:0]};
      $display("T:%8d INFO: read mailbox 2",$time);
      read_mailbox(access32,0, TRAFFIC_CTRL_CMD_ADDR, 32'h1015, rx_cnt);
      if (tx_cnt != rx_cnt) begin
         test_utils::incr_err_count();
         $display("\nError: Received good packets does not match Transmitted packets on Port-%0d !\n",0);
         $display("Number of Packets \tSent: %0d\n \tReceived: %0d",tx_cnt,rx_cnt);
      end else begin
         $display("INFO: Number of Packets \tSent: %0d\n \tReceived: %0d",tx_cnt,rx_cnt);
      end

   end
endtask

// HSSI Traffic test
task traffic_test;
   input logic  access32;
   logic [31:0] old_test_err_count;
   begin 
      $display("T:%8d INFO: running traffic traffic test Running eth 10g",$time);

      print_test_header("traffic_test");
      old_test_err_count = test_utils::get_err_count();

      // Wait for ready before starting the test
      $display("T:%8d INFO: Wait for reset done",$time);
      wait_for_reset_done();
      $display("T:%8d INFO: Wait for hssi ready",$time);
      wait_for_hssi_to_ready();

      `ifdef ETH_100G
      $display("T:%8d INFO: Running eth 100g",$time);
      traffic_100G(access32);
      `else
      $display("T:%8d INFO: Running eth 10g",$time);
      traffic_10G_25G(access32);
      `endif

      post_test_util(old_test_err_count);
   end
endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin
   traffic_test (1); // Pass 1 for 32-bit access to mailbox, 0 for 64-bit
end
endtask
