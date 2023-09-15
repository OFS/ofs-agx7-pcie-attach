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
   input logic        vf_active;
   input logic [2:0]  pfn;
   input logic [10:0] vfn;
begin
   $display("\n********************************************");
   $display(" Running TEST(%0d) : %0s (vf_active=%0d, pfn=%0d vfn=%0d", test_id, test_name, vf_active, pfn, vfn);
   $display("********************************************");   
   test_summary[test_id].name = test_name;
end
endtask

task verify_pcie_err_count;
   output logic result;
   input logic [7:0] exp_err;
begin
   // Wait 30 clock cycles for checker error to be logged
   repeat (30)
      @(posedge fim_clk);

   if (checker_err_count != exp_err) 
   begin
      result = 1'b0;
      $display("Failed - expected errors: %0d,  actual errors: %0d", exp_err, checker_err_count);
   end else begin
      result = 1'b1;
      $display("Checker error count matches: %0d", checker_err_count);
   end
   if (~result)
      test_utils::incr_err_count();
end
endtask

task verify_pcie_err_code;
   output logic result;
   input logic [31:0] exp_err_code;
begin
   // Wait 10 clock cycles for checker error to be logged
   repeat (10)
      @(posedge fim_clk);

   if (pcie_p2c_chk_err_code != exp_err_code) 
   begin
      result = 1'b0;
      $display("Failed - error code mismatch, expected: 0x%x,  actual: 0x%x", exp_err_code, pcie_p2c_chk_err_code);
   end else begin
      result = 1'b1;
      $display("Checker error code matches: 0x%x", pcie_p2c_chk_err_code);
   end
   if (~result)
      test_utils::incr_err_count();
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

task test_pf_vf_access;
   output logic       result;
   input logic        vf_active;
   input logic [2:0]  pfn;
   input logic [10:0] vfn;
   input test_csr_defs::t_guid_map   scratch_lookup;
   input string test_name;

   bit [127:0] guid;
   logic [63:0] scratch;
   logic        error;
   int          count;
   logic [31:0] old_test_err_count;
   // string       test_name;
begin
   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;
   print_test_header(test_name, vf_active, pfn, vfn);
   READ64(ADDR32, 'h8, '0, vf_active, pfn, vfn, guid[63:0], error);	
   READ64(ADDR32, 'h10, '0, vf_active, pfn, vfn, guid[127:64], error);	
   $display("\nGUID: 0x%x scratch_addr:0x%x\n",guid, scratch_lookup[guid]);

   test_csr_access_32(result, ADDR32, scratch_lookup[guid],     0, vf_active, pfn, vfn, 'h1111_2222);
   test_csr_access_32(result, ADDR32, scratch_lookup[guid]+'h4, 0, vf_active, pfn, vfn, 'hAAAA_BBBB);
   test_csr_access_64(result, ADDR64, scratch_lookup[guid],     0, vf_active, pfn, vfn, 'h1111_2222_AAAA_BBBB);
   
   post_test_util(old_test_err_count);
end
endtask

//-------------------
// Test main entry 
//-------------------

task main_test;
   import test_csr_defs::*;
   t_pf_vf_entry_info pf_vf_map;
   t_guid_map scratch_lookup;
   output logic test_result;
   logic valid_csr_region;
   string test_name;
begin
 
   pf_vf_map = top_cfg_pkg::get_pf_vf_entry_info();

   scratch_lookup = '{ test_csr_defs::FME_GUID     : FME_SCRATCH_ADDR,
		       test_csr_defs::HE_LB_GUID   : HE_LB_SCRATCH_ADDR,
                       test_csr_defs::HE_MEM_GUID  : HE_MEM_SCRATCH_ADDR,
                       test_csr_defs::HE_HSSI_GUID : HE_HSSI_SCRATCH_ADDR,
                       test_csr_defs::HE_NULL_GUID : HE_NULL_SCRATCH_ADDR,
                       test_csr_defs::VIO_GUID     : VIO_SCRATCH_ADDR,
                       test_csr_defs::CE_GUID      : CE_SCRATCH_ADDR,
                       test_csr_defs::MEM_TG_GUID  : MEM_TG_SCRATCH_ADDR
                     };
   

   for (int pf = 0; pf < top_cfg_pkg::MAX_PF_NUM; pf++) begin
      if(top_cfg_pkg::PF_ENABLED_VEC[pf]) begin
	 $sformat(test_name,"test_pf%0d_access",pf);
	 test_pf_vf_access (test_result, 0, pf, 0, scratch_lookup, test_name);
	 for(int vf = 0; vf < top_cfg_pkg::PF_NUM_VFS_VEC[pf]; vf++) begin
	    $sformat(test_name,"test_pf%0d_vf%0d_access",pf,vf);
	    test_pf_vf_access (test_result, 1, pf, vf, scratch_lookup, test_name);
	 end
      end
   end
   
end
endtask
