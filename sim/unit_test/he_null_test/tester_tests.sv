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
// Test 32-bit CSR access
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

// Test 64-bit CSR access
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

// Test 32-bit CSR read access
task test_csr_read_32;
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
       $display("\nERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
       test_utils::incr_err_count();
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

   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;

   //-----------
   // BPF slaves
   //-----------
   $display("Test CSR access to HE-MEM-NULL (PF0-VF0)");
   $display("---------------------\n");
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HEM_VA, HEM_PF, HEM_VF, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HEM_VA, HEM_PF, HEM_VF,  'haa05_05aa);   
   
   $display("\n---------------------");
   $display("Test CSR access to HE-HSSI-NULL (PF0-VF1)");
   $display("---------------------\n");
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HEH_VA, HEH_PF, HEH_VF, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HEH_VA, HEH_PF, HEH_VF, 'haa06_06aa);   
   
   $display("\n---------------------");
   $display("Test CSR access to MEM-TG-NULL (PF0-VF2)");
   $display("---------------------\n");
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HEM_TG_VA, HEM_TG_PF, HEM_TG_VF, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HEM_TG_VA, HEM_TG_PF, HEM_TG_VF, 'haa07_07aa);   

   $display("\n---------------------");
   $display("Test CSR access to PF1 - HE-LB-NULL)");
   $display("---------------------\n");
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 0, PF1_VA, PF1_PF, PF1_VF, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 0, PF1_VA, PF1_PF, PF1_VF,'haa02_02aa);   
      
   
   $display("\n---------------------");
   $display("Test CSR access to HE-LB-NULL (PF2)");
   $display("---------------------\n");
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HLB_VA, HLB_PF, HLB_VF, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HLB_VA, HLB_PF, HLB_VF,'haa04_04aa);   
   
   $display("\n---------------------");
   $display("Test CSR access to VIRTIO-LB (PF3)");
   $display("---------------------\n");
      test_csr_read_64(result, addr_mode, VIRTIO_DFH, 0, VIO_VA, VIO_PF, VIO_VF, 64'h1000010000000000);   

      test_csr_read_64(result, addr_mode, VIRTIO_GUID_L, 0, VIO_VA, VIO_PF, VIO_VF, 64'hB9AB_EFBD_90B9_70C4);
      test_csr_read_64(result, addr_mode, VIRTIO_GUID_H, 0, VIO_VA, VIO_PF, VIO_VF, 64'h1AAE_155C_ACC5_4210);   

      test_csr_read_32(result, addr_mode, VIRTIO_DFH, 0, VIO_VA, VIO_PF, VIO_VF, 64'h00000000 );   
      test_csr_read_32(result, addr_mode, VIRTIO_DFH+4, 0, VIO_VA, VIO_PF, VIO_VF, 64'h10000100);   

      test_csr_read_32(result, addr_mode, VIRTIO_GUID_L, 0, VIO_VA, VIO_PF, VIO_VF, 64'h90B9_70C4);   
      test_csr_read_32(result, addr_mode, VIRTIO_GUID_L+4, 0, VIO_VA, VIO_PF, VIO_VF, 64'hB9AB_EFBD);   
      test_csr_read_32(result, addr_mode, VIRTIO_GUID_H, 0, VIO_VA, VIO_PF, VIO_VF, 64'hACC5_4210);   
      test_csr_read_32(result, addr_mode, VIRTIO_GUID_H+4, 0, VIO_VA, VIO_PF, VIO_VF, 64'h1AAE_155C);   

      test_csr_access_64(result, addr_mode, VIRTIO_SCRATCHPAD, 0, VIO_VA, VIO_PF, VIO_VF, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, VIRTIO_SCRATCHPAD, 0, VIO_VA, VIO_PF, VIO_VF, 'haa08_08aa);   
   
   $display("\n---------------------");
   $display("Test CSR access to (PF4) CE-NULL");
   $display("---------------------\n");
      test_csr_access_64(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HPS_VA, HPS_PF, HPS_VF, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, HE_NULL_SCRATCHPAD, 0, HPS_VA, HPS_PF, HPS_VF, 'haa09_09aa);   
      
   post_test_util(old_test_err_count);
end
endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
begin
   //deassert_afu_reset();
   test_mmio_addr32   (test_result);
   test_mmio_addr64   (test_result);

end
endtask

