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

   $display("\n---------------------");
   $display("Test CSR access to HE-LB (PF2)");
   $display("---------------------\n");
      test_csr_access_64(result, addr_mode, SCRATCHPAD0, 0, 1'b0, 3'h2, 0, 'h1111_2222_3333_4444);
      test_csr_access_32(result, addr_mode, SCRATCHPAD0, 0, 1'b0, 3'h2, 0, 'haa04_04aa);   

      test_unused_csr_access_32(result, addr_mode, 32'hff0, 0, 1'b0, 0, 0, 'hF00D_0001);
      test_unused_csr_access_64(result, addr_mode, 32'hff0, 0, 1'b0, 0, 0, 'hF00D_0001_6464_6464);
   

   post_test_util(old_test_err_count);
end
endtask

// Memory loopback test util
task test_mem_loopback_util;
   output logic result;
   input  logic mem_display_on;
   input  logic [2:0]  bar;
   input  logic [2:0]  pfn;
   input  logic [11:0] vfn;
   input  logic        vf_active;
   input  logic [2:0]  test_mode;
   input  logic [3:0][511:0] test_data;
   input  logic [63:0] src_base_addr;
   input  logic [63:0] dst_base_addr;
   input  logic [63:0] dsm_base_addr;
   input  logic [1:0]  cl_mode;
   input  logic [16:0] num_cl; 

   logic [31:0] src_addr;
   logic [31:0] dst_addr;
   logic [31:0] wdata;
   logic [63:0] scratch;
   logic        err_src_addr;
   logic        err_dst_addr;   
begin
   result = 1'b1;

   err_src_addr = |src_base_addr[5:0];
   err_dst_addr = |dst_base_addr[5:0];

   if (err_src_addr) begin
      $display("Error: Source buffer address (0x%0x) is not aligned to cacheline boundary (64 bytes).", src_base_addr);
   end
   
   if (err_dst_addr) begin
      $display("Error: Destination buffer address (0x%0x) is not aligned to cacheline boundary (64 bytes).", dst_base_addr);
   end

   result = ~(err_src_addr | err_dst_addr);

   if (~result) begin
      test_utils::incr_err_count();
   end else begin    
      $display("\n (1) Writing test data to source buffer starting at 0x%x", src_base_addr);
      for (int cl=0; cl<num_cl; ++cl) begin
         for (int i=0; i<8; i=i+1) begin
            src_addr = (src_base_addr+cl*64+i*8);
            dst_addr = (dst_base_addr+cl*64+i*8);
            // Write data to source buffer
            f_shmem_write(src_addr, test_data[cl%4][i*64+:64], 2);
            // Clear destination buffer
            f_shmem_write(dst_addr, 64'h0, 2);
         end
      end
     
      // Clear DSM base address
      f_shmem_write(dsm_base_addr, 64'h0, 2);
   
      if (mem_display_on) f_shmem_display(src_base_addr, num_cl*16, 4);
          
      //-----------------------------------
      // Start memory loopback test
      //-----------------------------------
      $display("\n (2) Start memory loopback test");
      
      wdata = '0;
      wdata[0] = 1'b1;
      // Clear Reset & start bit
      WRITE32(ADDR32, CTL, bar, vf_active, pfn, vfn, wdata);  

      // Configure he-lb
      wdata = '0;
      wdata[6:5] = cl_mode;
      wdata[4:2] = test_mode;
      WRITE32(ADDR32, CFG, bar, vf_active, pfn, vfn, wdata);  
    
      // Configure number of CL for test
      wdata = '0;
      wdata[16:0] = num_cl-1;
      WRITE32(ADDR32, NUM_LINES, bar, vf_active, pfn, vfn, wdata);  
      
      // Configure inactivity threshold
      wdata = '0;
      wdata[31:0] = 32'h1000_0000;
      WRITE32(ADDR32, INACT_THRESH, bar, vf_active, pfn, vfn, wdata);  

      // SRC and DST addresses
      WRITE64(ADDR32, SRC_ADDR, bar, vf_active, pfn, vfn, {'0, src_base_addr[31:6]});
      WRITE64(ADDR32, DST_ADDR, bar, vf_active, pfn, vfn, {'0, dst_base_addr[31:6]});
  
      // DSM base address
      WRITE64(ADDR32, DSM_BASEL, bar, vf_active, pfn, vfn, {'0, dsm_base_addr[31:6]});
     
      // Start the test
      wdata = '0;
      wdata[0] = 1'b1; // Set the start bit
      wdata[1] = 1'b1; // Set the start bit
      WRITE32(ADDR32, CTL, bar, vf_active, pfn, vfn, wdata);  
  
      scratch = '0;
      while (~|scratch) begin
         $display("(3) Polling for DSM completion bit to set");
         f_shmem_read(dsm_base_addr, 1, scratch);
         if (~|scratch) begin
            #1000000; // Delay to allow downstream MRd and MWr
         end
      end

      wdata = '0;
      // Reset & clear the start bit
      WRITE32(ADDR32, CTL, bar, vf_active, pfn, vfn, wdata);  

        $display("\n (4) Checking data at destination buffer starting at 0x%x", dst_base_addr);
      if (mem_display_on) f_shmem_display(dst_base_addr, num_cl*16, 4);
   
      for (int cl=0; cl<num_cl; ++cl) begin
         for (int i=0; i<8; i=i+1) begin
            dst_addr = (dst_base_addr+cl*64+i*8);
            f_shmem_read(dst_addr, 2, scratch);
            if (scratch !== test_data[cl%4][i*64+:64]) begin
               $display("\nERROR: write and read mismatch at address 0x%0x! write=0x%x read=0x%x\n", dst_addr, test_data[cl%4][i*64+:64], scratch);
               $display("\nERROR: Loopback test mismatch!\n");
               test_utils::incr_err_count();
               result = 1'b0;
               break;
            end
         end
      end
   end
end
endtask

// Test HE-LB memory write/read 
task test_mem_loopback;
   output logic result;
   input  logic mem_display_on;
   input  logic [2:0]  bar;
   input  logic [2:0]  pfn;
   input  logic [11:0] vfn;
   input  logic        vf_active;
   input  logic [2:0]  test_mode;
   input  logic [1:0]  cl_mode;
   input  logic [16:0] num_cl;
   input  [1024*8-1:0] test_name;

   logic  [2:0]        cl_len;
   logic  [3:0][511:0] test_data;
   logic  [31:0] src_base_addr, dst_base_addr;
   logic  [31:0] dsm_base_addr;
   logic  [31:0] old_test_err_count;
   logic  err_cl_len;
begin
   print_test_header(test_name);
   old_test_err_count = test_utils::get_err_count();
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
      
   if (err_cl_len) begin
      $display("Error: Number of CL (%0d) does not align with cl_mode (%0d), must be multiple of %0d.", num_cl, cl_mode, cl_len);
   end

   result = ~err_cl_len;

   if (~result) begin
      test_utils::incr_err_count();
   end else begin
      for (int cl=0; cl<4; ++cl) begin
         // Hardcoded MWr and MRd test
         test_data[cl] = {{cl[3:0], 60'h8888888_88888888},
                          {cl[3:0], 60'h7777777_77777777},
                          {cl[3:0], 60'h6666666_66666666},
                          {cl[3:0], 60'h5555555_55555555},
                          {cl[3:0], 60'h4444444_44444444},
                          {cl[3:0], 60'h3333333_33333333},
                          {cl[3:0], 60'h2222222_22222222},
                          {cl[3:0], 60'h1111111_11111111}};
      end

      src_base_addr = 64'h0;
      dst_base_addr = 64'h0010_0000;
      dsm_base_addr = 64'h0020_0000;
      test_mem_loopback_util(result, mem_display_on, bar, pfn, vfn, vf_active, test_mode, test_data, src_base_addr, dst_base_addr, dsm_base_addr, cl_mode, num_cl);

// Todo : re-enable this once HSD:22011863680 is fixed
/*      src_base_addr = 64'h40;
      dst_base_addr = 64'h0010_0040;
      dsm_base_addr = 64'h0020_0040;
      if (result) begin
         test_mem_loopback_util(result, mem_display_on, barr, pfn, vfn, vf_active, test_mode, test_data, src_base_addr, dst_base_addr, dsm_base_addr, cl_mode, num_cl);
      end
*/
   end

   post_test_util(old_test_err_count);
end
endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic [2:0]  bar;
   logic [2:0]  pfn;
   logic [11:0] vfn;
   logic        vf_active;
   logic valid_csr_region;
begin
   bar = 'h0;
   pfn = 3'h2;
   vfn = 'h0;
   vf_active = 1'b0;

   test_mem_loopback (test_result, 1, bar, pfn, vfn, vf_active, 3'h0, 2'h0, 16'd1, "test_mem_loopback: cl_mode (1CL), length (1)");
end
endtask

