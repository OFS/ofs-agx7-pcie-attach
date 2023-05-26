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
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nPMCI_ERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
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
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 32'h0) begin
       $display("\nPMCI_ERROR: Expected 32'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
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
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nPMCI_ERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
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
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nPMCI_ERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
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
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nPMCI_ERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
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
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 64'h0) begin
       $display("\nPMCI_ERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
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
   // Test MMIO write stall issue
   //-----------
   //WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h1}});	
   //WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h2}});	 
   //@(posedge fim_clk);
   //WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h3}});	
   //test_csr_read_32(result, ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, 'h03333333); // PMCI_FBM_AR RW range is 27:0

   //$display("Print PMCI DFH register value");
   //   test_csr_read_64(result,addr_mode, PMCI_DFH, 0, 1'b0, 0, 0, 'h3000000010001012);
 
   $display("Test CSR access");
      force top_tb.DUT.pmci_wrapper.pmci_ss.pmci_csr.pmci_csr_0.host_avmm_slv_addr='h1D;
      test_csr_access_64(result,addr_mode, PMCI_FBM_AR, 0, 1'b0, 0, 0, 'hBAADBEEF);
      //test_csr_read_64(result,addr_mode, PMCI_DFH, 0, 1'b0, 0, 0, 'h3000000200001012);
     
      //test_csr_access_32(result, addr_mode, PMCI_FBM_AR, 0, 1'b0, 0, 0, 'h0111_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_SEU_ERR, 0, 1'b0, 0, 0, 'h1111_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);   
     // test_csr_access_32(result, addr_mode, PMCI_PCIE_SS_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_HSSI_SS_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_QSFPA_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_QSFPB_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
      //test_csr_access_32(result, addr_mode, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0002);   
      //test_csr_access_32(result, addr_mode, PMCI_SPI_AR, 0, 1'b0, 0, 0, 'h0000_2222);   
      //test_csr_read_32(result, addr_mode, PMCI_SPI_RD_DR, 0, 1'b0, 0, 0, 'h0);
      //test_csr_access_32(result, addr_mode, PMCI_SPI_WR_DR, 0, 1'b0, 0, 0, 'h1111_2222);   
      //test_csr_access_32(result, addr_mode, PMCI_FBM_FIFO, 0, 1'b0, 0, 0, 'h1111_2222);   
      //test_csr_access_64(result, addr_mode, PMCI_VDM_FCR, 0, 1'b0, 0, 0, 'h1111_2222_3333_4444);   
      //test_csr_access_64(result, addr_mode, PMCI_VDM_PDR, 0, 1'b0, 0, 0, 'h1111_2222_3333_4444);
       //force top_tb.DUT.pmci_wrapper.pmci_ss.pmci_csr.pmci_csr_0.host_avmm_slv_addr='h1D;  
       //test_csr_access_64(result, addr_mode, PMCI_FBM_AR, 0, 1'b0, 0, 0,'hBAADBEEF_DEADBEEF); 

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
   test_mmio_addr32   (test_result);
   test_mmio_addr64   (test_result);
end
endtask



