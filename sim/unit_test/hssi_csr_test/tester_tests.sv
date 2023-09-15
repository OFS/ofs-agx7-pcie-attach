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
import top_cfg_pkg::*;

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
task test_unassigned_csr_access_64;
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
   end else if (scratch !== 64'hFFFF_FFFF_FFFF_FFFF) begin
       $display("\nERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

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
   vf_active   = HEH_VA;
   pfn         = HEH_PF;
   vfn         = HEH_VF;
   
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
   test_csr_ro_access_32(result, addr_mode, HSSI_FEATURE_ADDR , bar, vf_active, pfn, vfn, HSSI_FEATURE_VAL);

   test_csr_ro_access_32(result, addr_mode, HSSI_PORT0_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT0_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT1_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT1_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT2_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT2_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT3_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT3_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT4_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT4_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT5_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT5_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT6_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT6_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT7_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT7_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT8_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT8_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT9_ATTR_ADDR , bar, vf_active, pfn, vfn, HSSI_PORT9_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT10_ATTR_ADDR, bar, vf_active, pfn, vfn, HSSI_PORT10_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT11_ATTR_ADDR, bar, vf_active, pfn, vfn, HSSI_PORT11_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT12_ATTR_ADDR, bar, vf_active, pfn, vfn, HSSI_PORT12_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT13_ATTR_ADDR, bar, vf_active, pfn, vfn, HSSI_PORT13_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT14_ATTR_ADDR, bar, vf_active, pfn, vfn, HSSI_PORT14_ATTR_VAL);
   test_csr_ro_access_32(result, addr_mode, HSSI_PORT15_ATTR_ADDR, bar, vf_active, pfn, vfn, HSSI_PORT15_ATTR_VAL);

   test_csr_ro_access_64(result, addr_mode, HSSI_DFH_LO_ADDR, bar, vf_active, pfn, vfn, {HSSI_DFH_HI_VAL, HSSI_DFH_LO_VAL});
   // Unused CSR check
   test_unused_csr_access_32(result, addr_mode, HSSI_WRAP_UNUSED_ADDR, bar, vf_active, pfn, vfn, 'hF00D_0004);
   test_unused_csr_access_64(result, addr_mode, HSSI_WRAP_UNUSED_ADDR, bar, vf_active, pfn, vfn, 'hF00D_0006_F00D_0005);
   test_unused_csr_access_64(result, addr_mode, HSSI_SS_UNUSED_ADDR, bar, vf_active, pfn, vfn, 'hF00D_0008_F00D_0007);
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
         WRITE32(ADDR32, cmd_ctrl_addr + MB_WRDATA_OFFSET, bar, 1'b1, 3'h2, 1, write_data32);
         WRITE32(ADDR32, cmd_ctrl_addr + MB_ADDRESS_OFFSET, bar, 1'b1, 3'h2, 1, addr); 
         WRITE32(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, MB_WR); 
         read_ack_mailbox(bar, cmd_ctrl_addr);
         //#1000000
         WRITE32(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, MB_NOOP);
         $display("INFO: Wrote MAILBOX ADDR:%x, WRITE_DATA32:%X", addr, write_data32);
     end 
     else begin
         WRITE64(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar, 1'b1, 3'h2, 1, {write_data32,32'h0000_0000});
         WRITE64(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, {addr,MB_WR}); 
         read_ack_mailbox(bar, cmd_ctrl_addr);
         //#1000000
         WRITE64(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, MB_NOOP);
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
         WRITE32(ADDR32, cmd_ctrl_addr + MB_ADDRESS_OFFSET, bar, 1'b1, 3'h2, 1, addr);
         WRITE32(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, MB_RD);
         read_ack_mailbox(bar, cmd_ctrl_addr);
         //#1000000
         READ32(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar, 1'b1, 3'h2, 1, rd_data32, error);
         if (error) begin
            $display("\nERROR: Mailbox read failed.\n");
            test_utils::incr_err_count();
         end
         $display("INFO: Read MAILBOX ADDR:%x, READ_DATA32:%X", addr, rd_data32);
         WRITE32(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, MB_NOOP);
      end 
      else begin
         WRITE64(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, {addr,MB_RD});
         read_ack_mailbox(bar, cmd_ctrl_addr);
         //#1000000
         READ64(ADDR32, cmd_ctrl_addr + MB_RDDATA_OFFSET, bar, 1'b1, 3'h2, 1, scratch, error);
         if (error) begin
            $display("\nERROR: Mailbox read failed.\n");
            test_utils::incr_err_count();
         end
         rd_data32 = scratch[31:0];
         $display("INFO: Read MAILBOX ADDR:%x, READ_DATA32:%X", addr, rd_data32);
         WRITE64(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, MB_NOOP);
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
         READ32(ADDR32, cmd_ctrl_addr, bar, 1'b1, 3'h2, 1, scratch1, error);
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

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin
   test_hssi_ss_mmio (test_result);
   test_afu_mmio (test_result);
end
endtask
