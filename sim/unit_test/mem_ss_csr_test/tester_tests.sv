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
   logic [31:0] scratch32;
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

task test_mem_ss_csr;
   localparam BAR = 0;
   output logic result;
   logic [63:0] scratch;
   logic [31:0] scratch32;
   logic [63:0] emif_capability;
   logic [63:0] emif_status;
   logic        error;
   logic [31:0] old_test_err_count;
   int 		ch;
   int 		addr;
   t_dfh        dfh;
   int 		dfh_addr;
   logic 	dfh_found;
begin
   print_test_header("test_mem_ss_csr");

   // EMIF DFH discovery and check
   dfh_addr = DFH_START_OFFSET;
   dfh = '0;
   dfh_found = '0;
   while (~dfh.eol && ~dfh_found) begin
      READ64(ADDR32, dfh_addr, BAR, 1'b0, 0, 0, scratch, error);
      dfh       = t_dfh'(scratch);
      dfh_found = (dfh.feat_id == EMIF_DFH_FEAT_ID);
      $display("\nDFH value: addr=0x%0x: next=0x%0x feat=0x%0x, dfh_found=%0x \n", dfh_addr, dfh_addr+dfh.nxt_dfh_offset, dfh.feat_id, dfh_found);      
      if(~dfh_found)
	 dfh_addr  = dfh_addr + dfh.nxt_dfh_offset;
   end

   if(dfh_found) begin
      $fdisplay(test_utils::get_logfile_handle(), "EMIF_DFH");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", dfh_addr);
      $fdisplay(test_utils::get_logfile_handle(), "   DFH value (0x%0x)\n", scratch);
   end else begin
      $display("\nERROR: Did not discover EMIF feature in DFH list\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end // else: !if(~dfh_found)

   if(dfh_found) begin
      
      // Read EMIF capability register for channel mask
      addr = dfh_addr + EMIF_CAPABILITY_OFFSET;
      READ64(ADDR32, addr, 3'h0, 1'b0, 0, 0, emif_capability, error);
      $fdisplay(test_utils::get_logfile_handle(), "EMIF_CAPABILITY");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", emif_capability);


      // Version
      addr = dfh_addr + MEM_SS_VERSION_OFFSET;
      READ32(ADDR32, addr, 3'h0, 1'b0, 0, 0, scratch32, error);
      $fdisplay(test_utils::get_logfile_handle(), "MEM_SS_VERSION");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", scratch32);
      if (scratch32 !== MEM_SS_VERSION_VAL) begin
	 $display("\nERROR: MemSS Feature value mismatched, expected: 0x%0x actual:0x%0x\n", MEM_SS_VERSION_VAL, scratch32);
	 test_utils::incr_err_count();
	 result = 1'b0;
      end

      // # memory channels
      addr = dfh_addr + MEM_SS_FEAT_LIST_OFFSET;
      READ32(ADDR32, addr, 3'h0, 1'b0, 0, 0, scratch32, error);
      $fdisplay(test_utils::get_logfile_handle(), "MEM_SS_FEAT_LIST");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", scratch32);
      if (scratch32 !== MEM_SS_FEAT_LIST_VAL) begin
	 $display("\nERROR: MemSS feature list value mismatched, expected: 0x%0x actual:0x%0x\n", MEM_SS_FEAT_LIST_VAL, scratch32);
	 test_utils::incr_err_count();
	 result = 1'b0;
      end

      addr = dfh_addr + MEM_SS_FEAT_LIST_2_OFFSET;
      READ32(ADDR32, addr, 3'h0, 1'b0, 0, 0, scratch32, error);
      $fdisplay(test_utils::get_logfile_handle(), "MEM_SS_FEAT_LIST_2");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", scratch32);
      if (scratch32 !== MEM_SS_FEAT_LIST_2_VAL) begin
	 $display("\nERROR: MemSS # of channels value mismatched, expected: 0x%0x actual:0x%0x\n", MEM_SS_FEAT_LIST_2_VAL, scratch32);
	 test_utils::incr_err_count();
	 result = 1'b0;
      end
      
      // MemSS interface attributes
      addr = dfh_addr + MEM_SS_IF_ATTR_OFFSET;
      READ32(ADDR32, addr, 3'h0, 1'b0, 0, 0, scratch32, error);
      $fdisplay(test_utils::get_logfile_handle(), "MEM_SS_IF_ATTR_VAL");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", scratch32);
      if (scratch32 !== MEM_SS_IF_ATTR_VAL) begin
	 $display("\nERROR: MemSS interface attributes value mismatched, expected: 0x%0x actual:0x%0x\n", MEM_SS_IF_ATTR_VAL, scratch32);
	 test_utils::incr_err_count();
	 result = 1'b0;
      end

      // MemSS scratchpad
      addr = dfh_addr + MEM_SS_SCRATCH_OFFSET;
      WRITE32(ADDR32, addr, 3'h0, 1'b0, 0, 0, 64'hdeadbeef);
      READ32(ADDR32, addr, 3'h0, 1'b0, 0, 0, scratch32, error);
      $fdisplay(test_utils::get_logfile_handle(), "MEM_SS_SCRATCH");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", scratch32);
      if (scratch32 !== 32'hdeadbeef) begin
	 $display("\nERROR: MemSS scratchpad mismatch, expected: 0x%0x actual:0x%0x\n", 32'hdeadbeef, scratch32);
	 test_utils::incr_err_count();
	 result = 1'b0;
      end
   
      // MemSS interface instance attributes
      addr = dfh_addr + MEM_SS_CH_ATTR_OFFSET;
      for(ch=0; ch < MEM_SS_NUM_CH_VAL; ch = ch+1) begin
	 READ32(ADDR32, addr + (64'h8*ch) , 3'h0, 1'b0, 0, 0, scratch32, error);
	 $fdisplay(test_utils::get_logfile_handle(), "MEM_SS_IF_ATTR_VAL");
	 $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)",  addr + (64'h8*ch));
	 $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", scratch32);
	 if (scratch32 !== MEM_SS_CH_ATTR_VAL) begin
            $display("\nERROR: MemSS interface channel attributes value mismatched, expected: 0x%0x actual:0x%0x\n", MEM_SS_CH_ATTR_VAL, scratch32);
            test_utils::incr_err_count();
            result = 1'b0;
	 end
      end // for (ch=0; ch < MEM_SS_NUM_CH_VAL; ch = ch+1)

      // // Memory Efficiency Monitors
      // addr = dfh_addr + MEM_SS_CSR_OFFSET + MEM_SS_EFFMON_OFFSET;
      // for(ch=0; ch < MEM_SS_NUM_CH_VAL; ch = ch+1) begin
      // 	 READ32(ADDR32, addr + (MEM_SS_EFFMON_OFFSET*ch), 3'h0, 1'b0, 0, 0, scratch, error);
      // 	 $fdisplay(test_utils::get_logfile_handle(), "MEM_SS_EFFMON_%0d_VAL",ch);
      // 	 $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr + (MEM_SS_EFFMON_OFFSET*ch));
      // 	 $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", scratch);
      // 	 if (scratch !== MEM_SS_EFFMON_START_VAL) begin
      //       $display("\nERROR: EFFMON_%0d_START value mismatched, expected: 0x%0x actual:0x%0x\n", ch, MEM_SS_EFFMON_START_VAL , scratch);
      //       test_utils::incr_err_count();
      //       result = 1'b0;
      // 	 end
      // end // for (ch=0; ch < MEM_SS_NUM_CH_VAL; ch = ch+1)

      old_test_err_count = test_utils::get_err_count();
      result = 1'b1;
   end // if (dfh_found)

   post_test_util(old_test_err_count);
end
endtask

task test_emif_calibration;
   localparam BAR = 0;
   output logic result;
   logic [63:0] scratch;
   logic [63:0] emif_capability;
   logic [63:0] emif_status;
   logic        error;
   logic [31:0] old_test_err_count;
   int 		cal_count;
   int 		addr;
   t_dfh        dfh;
   int 		dfh_addr;
   logic 	dfh_found;
begin
   print_test_header("test_emif_calibration");

   // EMIF DFH discovery and check
   dfh_addr = DFH_START_OFFSET;
   dfh = '0;
   dfh_found = '0;
   while (~dfh.eol && ~dfh_found) begin
      READ64(ADDR32, dfh_addr, BAR, 1'b0, 0, 0, scratch, error);
      dfh       = t_dfh'(scratch);
      dfh_found = (dfh.feat_id == EMIF_DFH_FEAT_ID);
      $display("\nDFH value: addr=0x%0x: next=0x%0x feat=0x%0x, dfh_found=%0x \n", dfh_addr, dfh_addr+dfh.nxt_dfh_offset, dfh.feat_id, dfh_found);      
      if(~dfh_found)
	 dfh_addr  = dfh_addr + dfh.nxt_dfh_offset;
   end

   if(dfh_found) begin
      $fdisplay(test_utils::get_logfile_handle(), "EMIF_DFH");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", dfh_addr);
      $fdisplay(test_utils::get_logfile_handle(), "   DFH value (0x%0x)\n", scratch);
      end else begin
      $display("\nERROR: Did not discover EMIF feature in DFH list\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end // else: !if(~dfh_found)

   if(dfh_found) begin
      
      // Read EMIF capability register for channel mask
      addr = dfh_addr + EMIF_CAPABILITY_OFFSET;
      READ64(ADDR32, addr, 3'h0, 1'b0, 0, 0, emif_capability, error);
      $fdisplay(test_utils::get_logfile_handle(), "EMIF_CAPABILITY");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", emif_capability);


      // Poll EMIF status while calibration completion != capability mask
      emif_status = 'h0;
      cal_count = 'h0;
      addr = dfh_addr + EMIF_STATUS_OFFSET;
      $display("Polling for EMIF calibration status completion: ");
      while ((emif_capability !== (emif_capability & emif_status)) && cal_count < 'h3) begin
	 READ64(ADDR32, addr, 3'h0, 1'b0, 0, 0, emif_status, error);
	 $display("0x%0x\n", emif_status);
	 cal_count = (emif_capability !== (emif_capability & emif_status)) ? 'h0 : cal_count + 1;
	 #1000000;
      end

      $fdisplay(test_utils::get_logfile_handle(), "EMIF_STATUS");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", addr);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", emif_status);

      old_test_err_count = test_utils::get_err_count();
      result = 1'b1;
   end // if (dfh_found)

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
   vf_active = 1'b1;

   // // wait for cal
   wait(top_tb.DUT.mem_ss_top.mem_ss_cal_success[0] == 1'b1);
   test_emif_calibration ( test_result );
   test_mem_ss_csr ( test_result );

end
endtask

