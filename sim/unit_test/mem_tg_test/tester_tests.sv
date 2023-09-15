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
      if (scratch !== EMIF_DFH_VAL) begin
	 $display("\nERROR: DFH value mismatched, expected: 0x%0x actual:0x%0x\n", EMIF_DFH_VAL, scratch);      
	 test_utils::incr_err_count();
	 result = 1'b0;
      end
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


// Test AFU MMIO read write
task test_afu_mmio;
   output logic result;
   input  logic [2:0]  bar;
   input  logic [PF_WIDTH-1:0] pfn;
   input  logic [VF_WIDTH-1:0] vfn;
   input  logic                vf_active;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [2:0]  bar;
   logic vf_active;
begin
   print_test_header("test_afu_mmio");
   old_test_err_count = test_utils::get_err_count();
   
   result      = 1'b1;
   addr_mode   = ADDR32;
   
   // AFU CSR
   // RO Register check
   test_csr_ro_access_64(result, addr_mode, AFU_DFH_ADDR, bar, vf_active, pfn, vfn, AFU_DFH_VAL);
   test_csr_ro_access_64(result, addr_mode, AFU_ID_L_ADDR, bar, vf_active, pfn, vfn, AFU_ID_L_VAL);
   test_csr_ro_access_64(result, addr_mode, AFU_ID_H_ADDR, bar, vf_active, pfn, vfn, AFU_ID_H_VAL);
   
   // RW access check using scratchpad
   test_csr_access_32(result, addr_mode, AFU_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0001);
   test_csr_access_64(result, addr_mode, AFU_SCRATCH_ADDR, bar, vf_active, pfn, vfn, 'hAFC0_0003_AFC0_0002);

   // Test illegal memory read returns CPL
   test_unused_csr_access_32(result, addr_mode, MEM_TG_STAT_ADDR + 'h8, bar, vf_active, pfn, vfn, 'hF00D_0001);
   test_unused_csr_access_64(result, addr_mode, MEM_TG_STAT_ADDR + 'h8, bar, vf_active, pfn, vfn, 'hF00D_0003_F00D_0002);

   post_test_util(old_test_err_count);
end
endtask


// Test AFU MMIO read write
`ifdef INCLUDE_DDR4
task mem_tg_test;
   output logic result;

   input int 	loops;
   input int 	wr;
   input int 	rd;
   input int    bls;
   
   logic [2:0]          bar;
   logic [PF_WIDTH-1:0] pfn;
   logic [VF_WIDTH-1:0] vfn;
   logic                vf_active;

   logic [63:0] mem_capability;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic [63:0] tg_status;
   real 	mem_bw;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [2:0]  bar;
   logic vf_active;
   logic tg_active;
   int 	 ch;
   enum {
       TG_ACTIVE_BIT,
       TG_TIMEOUT_BIT,
       TG_FAIL_BIT,
       TG_PASS_BIT
   } tg_stat_bit;
begin
   print_test_header("mem_tg_test");
   old_test_err_count = test_utils::get_err_count();
   
   result      = 1'b1;
   bar         = 3'h0;
   pfn         = MEM_TG_PF;
   vfn         = MEM_TG_VF;
   vf_active   = MEM_TG_VFA;
   addr_mode   = ADDR32;

   
   READ64(ADDR32, MEM_TG_CTRL_ADDR, bar, vf_active, pfn, vfn, mem_capability, error);

   $fdisplay(test_utils::get_logfile_handle(), "MEM_TG_CTRL");
   $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", MEM_TG_CTRL_ADDR);
   $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", mem_capability);

   for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
   // Check TG Version
   READ64(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_VERSION, bar, vf_active, pfn, vfn, scratch, error);
   if(scratch != TG_VERSION_DEFAULT) begin
      $display("\nERROR: TG Version %d did not match expected %d\n",scratch, TG_VERSION_DEFAULT);
      test_utils::incr_err_count();
      result = 1'b0;
   end

   WRITE32(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_LOOP_COUNT, bar, vf_active, pfn, vfn, loops);
   WRITE32(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_WRITE_COUNT, bar, vf_active, pfn, vfn, wr);
   WRITE32(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_READ_COUNT, bar, vf_active, pfn, vfn, rd);
   WRITE32(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_BURST_LENGTH, bar, vf_active, pfn, vfn, bls);
   WRITE32(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_ADDR_MODE_WR, bar, vf_active, pfn, vfn, 32'h2); // Sequential

   READ64(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_LOOP_COUNT, bar, vf_active, pfn, vfn, scratch, error);
   if(scratch[31:0] != loops) begin
      $display("\nERROR: Unable to configure CH%0d TG_LOOP_COUNT exp=%d act=%d \n",ch,loops, scratch);
      test_utils::incr_err_count();
      result = 1'b0;
   end
   READ64(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_WRITE_COUNT, bar, vf_active, pfn, vfn, scratch, error);
   if(scratch[31:0] != wr) begin
      $display("\nERROR: Unable to configure TG_WRITE_COUNT exp=%d act=%d \n",wr, scratch[31:0]);
      test_utils::incr_err_count();
      result = 1'b0;
   end
   READ64(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_READ_COUNT, bar, vf_active, pfn, vfn, scratch, error);
   if(scratch[31:0] != rd) begin
      $display("\nERROR: Unable to configure TG_WRITE_COUNT exp=%d act=%d \n",rd, scratch[31:0]);
      test_utils::incr_err_count();
      result = 1'b0;
   end
   READ64(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_BURST_LENGTH, bar, vf_active, pfn, vfn, scratch, error);
   if(scratch[31:0] != bls) begin
      $display("\nERROR: Unable to configure TG_BURST_LENGTH exp=%d act=%d \n",bls, scratch[31:0]);
      test_utils::incr_err_count();
      result = 1'b0;
   end
   READ64(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_ADDR_MODE_WR, bar, vf_active, pfn, vfn, scratch, error);
   if(scratch[31:0] != 'h2) begin
      $display("\nERROR: Unable to configure TG_ADDR_MODE_WR exp=%d act=%d \n",32'h2, scratch[31:0]);
      test_utils::incr_err_count();
      result = 1'b0;
   end

   WRITE64(ADDR32, (ch+1)*MEM_TG_CFG_OFFSET + TG_START, bar, vf_active, pfn, vfn, 64'h1); // Sequential
   end // for (ch=0; mem_capability[ch] == 1'b1; ch=ch+1)
   
   // Poll TG status for completion
   tg_active = 1'b1;
   while(tg_active) begin
      tg_active = 1'b0;
      READ64(ADDR32, MEM_TG_STAT_ADDR, bar, vf_active, pfn, vfn, tg_status, error);
      $fdisplay(test_utils::get_logfile_handle(), "MEM_TG_STAT");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", MEM_TG_STAT_ADDR);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", mem_capability);
      for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
   	 if (tg_status[TG_ACTIVE_BIT+(4*ch)] == 1'b1) begin
   	    tg_active = 1'b1;
   	 end
      end
   end

   // Check TG test pass status
   #1000000; // Delay to allow ctrl/status synchronizers to settle
   READ64(ADDR32, MEM_TG_STAT_ADDR, bar, vf_active, pfn, vfn, tg_status, error);

   for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
      if (tg_status[TG_PASS_BIT+(4*ch)] != 1'b1) begin
   	 $display("\nERROR: TG[%d] pass did not go high.\n",ch);
   	 test_utils::incr_err_count();
   	 result = 1'b0;
      end
      if (tg_status[TG_TIMEOUT_BIT+(4*ch)] != 1'b0) begin
   	 $display("\nERROR: TG[%d] timeout bit wasn't 0 at test completion.\n",ch);
   	 test_utils::incr_err_count();
   	 result = 1'b0;
      end
      if (tg_status[TG_FAIL_BIT+(4*ch)] != 1'b0) begin
   	 $display("\nERROR: TG[%d] fail bit wasn't 0 at test completion.\n",ch);
   	 test_utils::incr_err_count();
   	 result = 1'b0;
      end
   end
   
   // Mem BW check
   for(ch=0; mem_capability[ch] == 1'b1; ch=ch+1) begin
      READ64(ADDR32, MEM_TG_CLOCKS_OFFSET + (32'h8 * ch), bar, vf_active, pfn, vfn, tg_status, error);
      $display("\n TG[%d] clocks to completion: %d\n",ch,tg_status);
      mem_bw = (((real'(loops) * real'(rd) * real'(bls) * 64.0) / real'(tg_status))*0.3); // GB/s @ 300MHz
      $display("Rd BW = %0.3f GBps\n",mem_bw);
      mem_bw = (((real'(loops) * real'(wr) * real'(bls) * 64.0) / real'(tg_status))*0.3); // GB/s @ 300MHz
      $display("Wr BW = %0.3f GBps\n",mem_bw);
   end
   
   post_test_util(old_test_err_count);
end
endtask
task mem_tg_fail_test;
   output logic result;
   logic [2:0]          bar;
   logic [PF_WIDTH-1:0] pfn;
   logic [VF_WIDTH-1:0] vfn;
   logic                vf_active;
   logic [63:0] mem_capability;
   e_addr_mode  addr_mode;
   logic [31:0] addr;
   logic [63:0] scratch;
   logic [63:0] tg_status;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [2:0]  bar;
   logic vf_active;
   logic tg_active;
   int 	 ch;
   enum {
       TG_ACTIVE_BIT,
       TG_TIMEOUT_BIT,
       TG_FAIL_BIT,
       TG_PASS_BIT
   } tg_stat_bit;
   localparam NUM_TG = top_tb.DUT.afu_top.port_gasket.pr_slot.afu_main.NUM_MEM_CH;;
begin
   print_test_header("mem_tg_fail_test");
   old_test_err_count = test_utils::get_err_count();
   result      = 1'b1;
   bar         = 3'h0;
   pfn         = MEM_TG_PF;
   vfn         = MEM_TG_VF;
   vf_active   = MEM_TG_VFA;
   addr_mode   = ADDR32;
   // Trigger TG
   WRITE64(ADDR32, MEM_TG_CTRL_ADDR, bar, vf_active, pfn, vfn, 'b1);  
   $fdisplay(test_utils::get_logfile_handle(), "\nTurning on memory traffic generator ch 0");
   // Check that TG status went active
   #1000000; // Delay to allow ctrl/status synchronizers to settle
   READ64(ADDR32, MEM_TG_STAT_ADDR, bar, vf_active, pfn, vfn, tg_status, error);
   if (tg_status[TG_ACTIVE_BIT] != 1'b1) begin
      $display("\nERROR: TG[0] active bit did not go high.\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_TIMEOUT_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] timeout bit was not low at test start.\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_FAIL_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] fail bit was not low at test start.\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_PASS_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] pass bit was not low at test start.\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end
   // Force rd rsp data to 0 to trigger test failure
   // LHS must be a constant in force/release statements => constant index select
   // this test only runs on channel 0
   force top_tb.DUT.mem_ss_top.afu_mem_if[0].rdata = '0;

   // Poll TG status for completion
   tg_active = 1'b1;
   while(tg_active) begin
      tg_active = 1'b0;
      READ64(ADDR32, MEM_TG_STAT_ADDR, bar, vf_active, pfn, vfn, tg_status, error);
      $fdisplay(test_utils::get_logfile_handle(), "MEM_TG_STAT");
      $fdisplay(test_utils::get_logfile_handle(), "   Address   (0x%0x)", MEM_TG_STAT_ADDR);
      $fdisplay(test_utils::get_logfile_handle(), "   STATUS value (0x%0x)\n", tg_status);
      for(ch=0; ch < NUM_TG; ch = ch+1) begin
	 if (tg_status[TG_ACTIVE_BIT+(4*ch)] == 1'b1) begin
	    tg_active = 1'b1;
	 end
      end
   end
   // Check TG test pass status
   #1000000; // Delay to allow ctrl/status synchronizers to settle
   READ64(ADDR32, MEM_TG_STAT_ADDR, bar, vf_active, pfn, vfn, tg_status, error);
   if (tg_status[TG_FAIL_BIT] != 1'b1) begin
      $display("\nERROR: TG[0] FAIL did not go high.\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_PASS_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] timeout bit wasn't 0 at fail test completion.\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end
   if (tg_status[TG_TIMEOUT_BIT] != 1'b0) begin
      $display("\nERROR: TG[0] timeout bit wasn't 0 at fail test completion.\n");
      test_utils::incr_err_count();
      result = 1'b0;
   end
   // Release rd rsp data
   release top_tb.DUT.mem_ss_top.afu_mem_if[0].rdata;
   post_test_util(old_test_err_count);
end
endtask
`endif

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
   localparam NUM_TEST_ITER = 2;
   int 	 itr;
begin
   bar         = 3'h0;
   pfn         = MEM_TG_PF;
   vfn         = MEM_TG_VF;
   vf_active   = MEM_TG_VFA;

   // wait for cal
`ifdef INCLUDE_DDR4
   wait(top_tb.DUT.mem_ss_top.mem_ss_fm_inst.mem0_local_cal_success == 1'b1);
`endif
   test_emif_calibration ( test_result );
   
   test_afu_mmio (test_result, bar, pfn, vfn, vf_active);

   for(itr=0; itr < NUM_TEST_ITER; itr = itr+1) begin
   $display("\nRunning write only test... \n");
   mem_tg_test (.result(test_result), .loops('d2), .wr('d10), .rd('d0), .bls('h4));
   $display("\nRunning read only test... \n");
   mem_tg_test (.result(test_result), .loops('d2), .wr('d0), .rd('d10), .bls('h4));
   $display("\nRunning write/read test... \n");
   mem_tg_test (.result(test_result), .loops('d2), .wr('d32), .rd('d32), .bls('h8));
   end
   // mem_tg_fail_test (test_result);
   
end
endtask

