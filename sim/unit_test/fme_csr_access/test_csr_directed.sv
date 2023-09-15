// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Test module for the FME random access test simulation.
//
//   This module uses the Transaction Classes defined in 
//   "csr_transaction_class_pkg.sv" to perform resets,
//   reads, and writes to the CSR Register block through the RandomTest
//   class.
//
//-----------------------------------------------------------------------------
module test_csr_directed(
   input logic clk,
   ofs_fim_pwrgoodn_if.master pgn,
   ofs_fim_axi_mmio_if.master axi,
   fme_csr_io_if.tb fme_io
);

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_csr_pkg::*;
import fme_csr_pkg::*;
import csr_transaction_class_pkg::*;

//---------------------------------------------------------
// Transaction handles.
//  In this simulation, only the derived transaction class
//  PwrResetTransaction is used directly to perform a power
//  reset to the FME CSR registers.
//---------------------------------------------------------
PwrResetTransaction pt;

//--------------------------------------------------------------------------------------------
// Check handles.
//   Simulation uses check objects for each of the tests we want to run:
//     RandomTest................: Used to perform two types of tests in this testbench:
//                                   1.) CSR Register Random Hit: Does read-write-read to a
//                                       random FME register with a random access type of 
//                                       LOWER32-bits, UPPER32-bits, or FULL64-bits.  The
//                                       register value read back after the write transaction
//                                       is compared against the actual register to make sure
//                                       the value is read back as expected.
//
//                                       The accesses are random-cyclic through the use of
//                                       assertion constraints.  All register addresses are
//                                       hit three times: one with each access type.
//
//                                   2.) CSR Space Random Hit: Does read-write-read to 1024
//                                       random addresses in the entire FME space and makes
//                                       sure that the accesses occur as expected.
//
//                                       These accesses are simply random.
//--------------------------------------------------------------------------------------------
RandomTest rt;

RandData rand_data;
RandRegHit rand_reg_hit;
RandSpaceHit rand_space_hit;

logic pass;
int   num_reg_checks;
int   num_tr_used;
int   num_total_access_errors;
int   num_csr_checks;
int   num_csr_tr_used;
int   num_total_csr_access_errors;
string reg_name;
logic addr_valid;
int i;

int fd; // Output file descriptor for messages.
assign axi.clk = clk;

initial
begin
   //----------------------------------------------------------
   // Initially set "pass" indicator for test.  If any errors -
   // are encountered in the following tests, then the flag   -
   // is cleared.  This is a summary pass/fail indicator.     -
   //----------------------------------------------------------
   pass = 1'b1;
   //----------------------------------------------------------
   // Initial Logic and AXI Bus Clearing ----------------------
   //----------------------------------------------------------
   pgn.pwr_good_n = 1'b0;
   axi.rst_n  = 1'b0;
   axi.awvalid = 1'b0;
   axi.awid = '0;
   axi.awaddr = '0;
   axi.awlen = '0;
   axi.awsize = '0;
   axi.awburst = '0;
   axi.wvalid = '0;
   axi.wdata = '0;
   axi.wstrb = '0;
   axi.wlast = '0;
   axi.bready = 1'b0;
   axi.arvalid = 1'b0;
   axi.arid = '0;
   axi.araddr = '0;
   axi.arlen = '0;
   axi.arsize = '0;
   axi.arburst = '0;
   axi.rready = 1'b0;
   fme_io.inp2cr_fme_error           = {64{1'b1}};
   fme_io.inp2cr_ras_grnerr          = {64{1'b1}};
   fme_io.inp2cr_ras_bluerr          = {64{1'b1}};
   $timeformat(-9, 2, " ns"); // Set time format to nanoseconds with 2 decimal places.
   // Delay ---------------------------------------------------
   repeat (3) @(posedge clk);
   #100ps;
   // Come out of Initial Reset -------------------------------
   pgn.pwr_good_n = 1'b1;
   axi.rst_n  = 1'b1;
   //----------------------------------------------------------
   // Perform a series of bit checks on all of the registers
   // to verify the function of their input connections and 
   // their bit attribute functions.  
   //----------------------------------------------------------
   // TESTS:
   //
   // Tests done with "WriteCheck" objects perform uniform 
   // reset, write-ones, and write-zeros tests of all the 
   // register bits.  
   //
   // Tests done with "WriteOneSetClearCheck" objects perform 
   // more detailed test sequences for registers that require
   // specific reset & read/write timing.
   // 
   // All tests include a "walking-ones" test, a "walking-zeros" 
   // test, and a random data test.
   //----------------------------------------------------------
   repeat (10) @(posedge clk);
   //----------------------------------------------------------------------------------
   // Random CSR Register Hit <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Random CSR Access Check for all FME registers.  RandomCheck objects check that |
   // the access response and data are correct for lower 32-bit-, higher 32-bit-, and |
   // full 64-bit-accesses. The "rand_reg_hit" ojects are constrained to be random-   |
   // cyclic so that all the accesses are unique.
   //----------------------------------------------------------------------------------
   $display("");
   $display("Running FME Random CSR Access Test...");
   $display("");
   for (i=0;i<123;i=i+1) //41*3=123 Register Accesses
   begin
      rand_reg_hit = new();
      assert (rand_reg_hit.randomize());
      case (rand_reg_hit.axi_addr) inside
         [FME_DFH                  : FME_DFH + 20'h7]                  :
         begin
            reg_name = "FME_DFH";
            addr_valid = 1'b1;
         end
         [FME_AFU_ID_L             : FME_AFU_ID_L + 20'h7]             :
         begin
            reg_name = "FME_AFU_ID_L";
            addr_valid = 1'b1;
         end
         [FME_AFU_ID_H             : FME_AFU_ID_H + 20'h7]             :
         begin
            reg_name = "FME_AFU_ID_H";
            addr_valid = 1'b1;
         end
         [FME_NEXT_AFU             : FME_NEXT_AFU + 20'h7]             :
         begin
            reg_name = "FME_NEXT_AFU";
            addr_valid = 1'b1;
         end
         [DUMMY_0020               : DUMMY_0020 + 20'h7]               :
         begin
            reg_name = "DUMMY_0020";
            addr_valid = 1'b1;
         end
         [FME_SCRATCHPAD0          : FME_SCRATCHPAD0 + 20'h7]          :
         begin
            reg_name = "FME_SCRATCHPAD0";
            addr_valid = 1'b1;
         end
         [FAB_CAPABILITY           : FAB_CAPABILITY + 20'h7]           :
         begin
            reg_name = "FAB_CAPABILITY";
            addr_valid = 1'b1;
         end
         [PORT0_OFFSET             : PORT0_OFFSET + 20'h7]             :
         begin
            reg_name = "PORT0_OFFSET";
            addr_valid = 1'b1;
         end
         [PORT1_OFFSET             : PORT1_OFFSET + 20'h7]             :
         begin
            reg_name = "PORT1_OFFSET";
            addr_valid = 1'b1;
         end
         [PORT2_OFFSET             : PORT2_OFFSET + 20'h7]             :
         begin
            reg_name = "PORT2_OFFSET";
            addr_valid = 1'b1;
         end
         [PORT3_OFFSET             : PORT3_OFFSET + 20'h7]             :
         begin
            reg_name = "PORT3_OFFSET";
            addr_valid = 1'b1;
         end
         [FAB_STATUS               : FAB_STATUS + 20'h7]               :
         begin
            reg_name = "FAB_STATUS";
            addr_valid = 1'b1;
         end
         [BITSTREAM_ID             : BITSTREAM_ID + 20'h7]             :
         begin
            reg_name = "BITSTREAM_ID";
            addr_valid = 1'b1;
         end
         [BITSTREAM_MD             : BITSTREAM_MD + 20'h7]             :
         begin
            reg_name = "BITSTREAM_MD";
            addr_valid = 1'b1;
         end
         [BITSTREAM_INFO             : BITSTREAM_INFO + 20'h7]             :
         begin
            reg_name = "BITSTREAM_INFO";
            addr_valid = 1'b1;
         end
         [THERM_MNGM_DFH           : THERM_MNGM_DFH + 20'h7]           :
         begin
            reg_name = "THERM_MNGM_DFH";
            addr_valid = 1'b1;
         end
         [TMP_THRESHOLD            : TMP_THRESHOLD + 20'h7]            :
         begin
            reg_name = "TMP_THRESHOLD";
            addr_valid = 1'b1;
         end
         [TMP_RDSENSOR_FMT1        : TMP_RDSENSOR_FMT1 + 20'h7]        :
         begin
            reg_name = "TMP_RDSENSOR_FMT1";
            addr_valid = 1'b1;
         end
         [TMP_RDSENSOR_FMT2        : TMP_RDSENSOR_FMT2 + 20'h7]        :
         begin
            reg_name = "TMP_RDSENSOR_FMT2";
            addr_valid = 1'b1;
         end
         [TMP_THRESHOLD_CAPABILITY : TMP_THRESHOLD_CAPABILITY + 20'h7] :
         begin
            reg_name = "TMP_THRESHOLD_CAPABILITY";
            addr_valid = 1'b1;
         end
         [GLBL_PERF_DFH            : GLBL_PERF_DFH + 20'h7]            :
         begin
            reg_name = "GLBL_PERF_DFH";
            addr_valid = 1'b1;
         end
         [DUMMY_3008               : DUMMY_3008 + 20'h7]               :
         begin
            reg_name = "DUMMY_3008";
            addr_valid = 1'b1;
         end
         [DUMMY_3010               : DUMMY_3010 + 20'h7]               :
         begin
            reg_name = "DUMMY_3010";
            addr_valid = 1'b1;
         end
         [DUMMY_3018               : DUMMY_3018 + 20'h7]               :
         begin
            reg_name = "DUMMY_3018";
            addr_valid = 1'b1;
         end
         [FPMON_FAB_CTL            : FPMON_FAB_CTL + 20'h7]            :
         begin
            reg_name = "FPMON_FAB_CTL";
            addr_valid = 1'b1;
         end
         [FPMON_FAB_CTR            : FPMON_FAB_CTR + 20'h7]            :
         begin
            reg_name = "FPMON_FAB_CTR";
            addr_valid = 1'b1;
         end
         [FPMON_CLK_CTR            : FPMON_CLK_CTR + 20'h7]            :
         begin
            reg_name = "FPMON_CLK_CTR";
            addr_valid = 1'b1;
         end
         [GLBL_ERROR_DFH           : GLBL_ERROR_DFH + 20'h7]           :
         begin
            reg_name = "GLBL_ERROR_DFH";
            addr_valid = 1'b1;
         end
         [FME_ERROR_MASK0          : FME_ERROR_MASK0 + 20'h7]          :
         begin
            reg_name = "FME_ERROR_MASK0";
            addr_valid = 1'b1;
         end
         [FME_ERROR0               : FME_ERROR0 + 20'h7]               :
         begin
            reg_name = "FME_ERROR0";
            addr_valid = 1'b1;
         end
         [PCIE0_ERROR_MASK         : PCIE0_ERROR_MASK + 20'h7]         :
         begin
            reg_name = "PCIE0_ERROR_MASK";
            addr_valid = 1'b1;
         end
         [PCIE0_ERROR              : PCIE0_ERROR + 20'h7]              :
         begin
            reg_name = "PCIE0_ERROR";
            addr_valid = 1'b1;
         end
         [DUMMY_4028               : DUMMY_4028 + 20'h7]               :
         begin
            reg_name = "DUMMY_4028";
            addr_valid = 1'b1;
         end
         [DUMMY_4030               : DUMMY_4030 + 20'h7]               :
         begin
            reg_name = "DUMMY_4030";
            addr_valid = 1'b1;
         end
         [FME_FIRST_ERROR          : FME_FIRST_ERROR + 20'h7]          :
         begin
            reg_name = "FME_FIRST_ERROR";
            addr_valid = 1'b1;
         end
         [FME_NEXT_ERROR           : FME_NEXT_ERROR + 20'h7]           :
         begin
            reg_name = "FME_NEXT_ERROR";
            addr_valid = 1'b1;
         end
         [RAS_NOFAT_ERROR_MASK     : RAS_NOFAT_ERROR_MASK + 20'h7]     :
         begin
            reg_name = "RAS_NOFAT_ERROR_MASK";
            addr_valid = 1'b1;
         end
         [RAS_NOFAT_ERROR          : RAS_NOFAT_ERROR + 20'h7]          :
         begin
            reg_name = "RAS_NOFAT_ERROR";
            addr_valid = 1'b1;
         end
         [RAS_CATFAT_ERROR_MASK    : RAS_CATFAT_ERROR_MASK + 20'h7]    :
         begin
            reg_name = "RAS_CATFAT_ERROR_MASK";
            addr_valid = 1'b1;
         end
         [RAS_CATFAT_ERROR         : RAS_CATFAT_ERROR + 20'h7]         :
         begin
            reg_name = "RAS_CATFAT_ERROR";
            addr_valid = 1'b1;
         end
         [RAS_ERROR_INJ            : RAS_ERROR_INJ + 20'h7]            :
         begin
            reg_name = "RAS_ERROR_INJ";
            addr_valid = 1'b1;
         end
         [GLBL_ERROR_CAPABILITY    : GLBL_ERROR_CAPABILITY + 20'h7]    :
         begin
            reg_name = "GLBL_ERROR_CAPABILITY";
            addr_valid = 1'b1;
         end
         default                   :
         begin
            reg_name = "EMPTY";
            addr_valid = 1'b0;
         end
      endcase
      rt = new( .axi(axi), .pgn(pgn), 
         .check_reg_name(reg_name),
         .reg_addr(rand_reg_hit.axi_addr),
         .access_type(rand_reg_hit.access_type),
         .valid_addr(addr_valid)
      );
      rt.run();
      rt.get_raw_register(testbench_top.dut.csr_reg[rand_reg_hit.axi_addr[15:12]][rand_reg_hit.axi_addr[7:3]]);
      rt.check();
      if (rt.fail()) pass = 1'b0;
   end
   num_csr_checks = rt.check_count;
   num_csr_tr_used = rt.tr_count;
   num_total_csr_access_errors = rt.total_access_error_count;
   $display("");
   $display("FME Random CSR Access Test Complete.");
   $display("");
   //----------------------------------------------------------------------------------
   // Random CSR Space Scanner <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Sample random addresses across the entire FME address space.  RandomCheck      |
   // objects check that the access response and data are correct.  The               |
   // "rand_space_hit" objects are simple-random, so they can span large ranges, but  |
   // repeat accesses are likely.
   //----------------------------------------------------------------------------------
   $display("");
   $display("Running FME Random Space Access Test...");
   $display("");
   for (i=0;i<1024*16;i=i+1)
   begin
      rand_space_hit = new();
      assert (rand_space_hit.randomize());
      case (rand_space_hit.axi_addr) inside
         [FME_DFH                  : FME_DFH + 20'h7]                  :
         begin
            reg_name = "FME_DFH";
            addr_valid = 1'b1;
         end
         [FME_AFU_ID_L             : FME_AFU_ID_L + 20'h7]             :
         begin
            reg_name = "FME_AFU_ID_L";
            addr_valid = 1'b1;
         end
         [FME_AFU_ID_H             : FME_AFU_ID_H + 20'h7]             :
         begin
            reg_name = "FME_AFU_ID_H";
            addr_valid = 1'b1;
         end
         [FME_NEXT_AFU             : FME_NEXT_AFU + 20'h7]             :
         begin
            reg_name = "FME_NEXT_AFU";
            addr_valid = 1'b1;
         end
         [DUMMY_0020               : DUMMY_0020 + 20'h7]               :
         begin
            reg_name = "DUMMY_0020";
            addr_valid = 1'b1;
         end
         [FME_SCRATCHPAD0          : FME_SCRATCHPAD0 + 20'h7]          :
         begin
            reg_name = "FME_SCRATCHPAD0";
            addr_valid = 1'b1;
         end
         [FAB_CAPABILITY           : FAB_CAPABILITY + 20'h7]           :
         begin
            reg_name = "FAB_CAPABILITY";
            addr_valid = 1'b1;
         end
         [PORT0_OFFSET             : PORT0_OFFSET + 20'h7]             :
         begin
            reg_name = "PORT0_OFFSET";
            addr_valid = 1'b1;
         end
         [PORT1_OFFSET             : PORT1_OFFSET + 20'h7]             :
         begin
            reg_name = "PORT1_OFFSET";
            addr_valid = 1'b1;
         end
         [PORT2_OFFSET             : PORT2_OFFSET + 20'h7]             :
         begin
            reg_name = "PORT2_OFFSET";
            addr_valid = 1'b1;
         end
         [PORT3_OFFSET             : PORT3_OFFSET + 20'h7]             :
         begin
            reg_name = "PORT3_OFFSET";
            addr_valid = 1'b1;
         end
         [FAB_STATUS               : FAB_STATUS + 20'h7]               :
         begin
            reg_name = "FAB_STATUS";
            addr_valid = 1'b1;
         end
         [BITSTREAM_ID             : BITSTREAM_ID + 20'h7]             :
         begin
            reg_name = "BITSTREAM_ID";
            addr_valid = 1'b1;
         end
         [BITSTREAM_MD             : BITSTREAM_MD + 20'h7]             :
         begin
            reg_name = "BITSTREAM_MD";
            addr_valid = 1'b1;
         end
         [BITSTREAM_INFO             : BITSTREAM_INFO + 20'h7]             :
         begin
            reg_name = "BITSTREAM_INFO";
            addr_valid = 1'b1;
         end
         [THERM_MNGM_DFH           : THERM_MNGM_DFH + 20'h7]           :
         begin
            reg_name = "THERM_MNGM_DFH";
            addr_valid = 1'b1;
         end
         [TMP_THRESHOLD            : TMP_THRESHOLD + 20'h7]            :
         begin
            reg_name = "TMP_THRESHOLD";
            addr_valid = 1'b1;
         end
         [TMP_RDSENSOR_FMT1        : TMP_RDSENSOR_FMT1 + 20'h7]        :
         begin
            reg_name = "TMP_RDSENSOR_FMT1";
            addr_valid = 1'b1;
         end
         [TMP_RDSENSOR_FMT2        : TMP_RDSENSOR_FMT2 + 20'h7]        :
         begin
            reg_name = "TMP_RDSENSOR_FMT2";
            addr_valid = 1'b1;
         end
         [TMP_THRESHOLD_CAPABILITY : TMP_THRESHOLD_CAPABILITY + 20'h7] :
         begin
            reg_name = "TMP_THRESHOLD_CAPABILITY";
            addr_valid = 1'b1;
         end
         [GLBL_PERF_DFH            : GLBL_PERF_DFH + 20'h7]            :
         begin
            reg_name = "GLBL_PERF_DFH";
            addr_valid = 1'b1;
         end
         [DUMMY_3008               : DUMMY_3008 + 20'h7]               :
         begin
            reg_name = "DUMMY_3008";
            addr_valid = 1'b1;
         end
         [DUMMY_3010               : DUMMY_3010 + 20'h7]               :
         begin
            reg_name = "DUMMY_3010";
            addr_valid = 1'b1;
         end
         [DUMMY_3018               : DUMMY_3018 + 20'h7]               :
         begin
            reg_name = "DUMMY_3018";
            addr_valid = 1'b1;
         end
         [FPMON_FAB_CTL            : FPMON_FAB_CTL + 20'h7]            :
         begin
            reg_name = "FPMON_FAB_CTL";
            addr_valid = 1'b1;
         end
         [FPMON_FAB_CTR            : FPMON_FAB_CTR + 20'h7]            :
         begin
            reg_name = "FPMON_FAB_CTR";
            addr_valid = 1'b1;
         end
         [FPMON_CLK_CTR            : FPMON_CLK_CTR + 20'h7]            :
         begin
            reg_name = "FPMON_CLK_CTR";
            addr_valid = 1'b1;
         end
         [GLBL_ERROR_DFH           : GLBL_ERROR_DFH + 20'h7]           :
         begin
            reg_name = "GLBL_ERROR_DFH";
            addr_valid = 1'b1;
         end
         [FME_ERROR_MASK0          : FME_ERROR_MASK0 + 20'h7]          :
         begin
            reg_name = "FME_ERROR_MASK0";
            addr_valid = 1'b1;
         end
         [FME_ERROR0               : FME_ERROR0 + 20'h7]               :
         begin
            reg_name = "FME_ERROR0";
            addr_valid = 1'b1;
         end
         [PCIE0_ERROR_MASK         : PCIE0_ERROR_MASK + 20'h7]         :
         begin
            reg_name = "PCIE0_ERROR_MASK";
            addr_valid = 1'b1;
         end
         [PCIE0_ERROR              : PCIE0_ERROR + 20'h7]              :
         begin
            reg_name = "PCIE0_ERROR";
            addr_valid = 1'b1;
         end
         [DUMMY_4028               : DUMMY_4028 + 20'h7]               :
         begin
            reg_name = "DUMMY_4028";
            addr_valid = 1'b1;
         end
         [DUMMY_4030               : DUMMY_4030 + 20'h7]               :
         begin
            reg_name = "DUMMY_4030";
            addr_valid = 1'b1;
         end
         [FME_FIRST_ERROR          : FME_FIRST_ERROR + 20'h7]          :
         begin
            reg_name = "FME_FIRST_ERROR";
            addr_valid = 1'b1;
         end
         [FME_NEXT_ERROR           : FME_NEXT_ERROR + 20'h7]           :
         begin
            reg_name = "FME_NEXT_ERROR";
            addr_valid = 1'b1;
         end
         [RAS_NOFAT_ERROR_MASK     : RAS_NOFAT_ERROR_MASK + 20'h7]     :
         begin
            reg_name = "RAS_NOFAT_ERROR_MASK";
            addr_valid = 1'b1;
         end
         [RAS_NOFAT_ERROR          : RAS_NOFAT_ERROR + 20'h7]          :
         begin
            reg_name = "RAS_NOFAT_ERROR";
            addr_valid = 1'b1;
         end
         [RAS_CATFAT_ERROR_MASK    : RAS_CATFAT_ERROR_MASK + 20'h7]    :
         begin
            reg_name = "RAS_CATFAT_ERROR_MASK";
            addr_valid = 1'b1;
         end
         [RAS_CATFAT_ERROR         : RAS_CATFAT_ERROR + 20'h7]         :
         begin
            reg_name = "RAS_CATFAT_ERROR";
            addr_valid = 1'b1;
         end
         [RAS_ERROR_INJ            : RAS_ERROR_INJ + 20'h7]            :
         begin
            reg_name = "RAS_ERROR_INJ";
            addr_valid = 1'b1;
         end
         [GLBL_ERROR_CAPABILITY    : GLBL_ERROR_CAPABILITY + 20'h7]    :
         begin
            reg_name = "GLBL_ERROR_CAPABILITY";
            addr_valid = 1'b1;
         end
         default                   :
         begin
            reg_name = "EMPTY";
            addr_valid = 1'b0;
         end
      endcase
      rt = new( .axi(axi), .pgn(pgn), 
         .check_reg_name(reg_name),
         .reg_addr(rand_space_hit.axi_addr),
         .access_type(rand_space_hit.access_type),
         .valid_addr(addr_valid)
      );
      rt.run();
      rt.get_raw_register(testbench_top.dut.csr_reg[rand_space_hit.axi_addr[15:12]][rand_space_hit.axi_addr[7:3]]);
      rt.check();
      if (rt.fail()) pass = 1'b0;
   end
   $display("");
   $display("FME Random Space Access Test Complete.");
   $display("");
   // ---------------------------------------------------------------------------------
   // Collect stats from objects.
   // ---------------------------------------------------------------------------------
   num_reg_checks = rt.check_count;
   num_tr_used    = rt.tr_count;
   num_total_access_errors = rt.total_access_error_count;

   //----------------------------------------------------------
   // Open File for Messages and create banner ----------------
   //----------------------------------------------------------
   fd = $fopen("./reg.rout","w");
   $display("");
   $display("  R E G I S T E R    T E S T    C O M P L E T E .");
   $display("");
   $display("");
   if (pass)
   begin
		$display("      '||''|.      |      .|'''.|   .|'''.|  ");
		$display("       ||   ||    |||     ||..  '   ||..  '  ");
		$display("       ||...|'   |  ||     ''|||.    ''|||.  ");
		$display("       ||       .''''|.  .     '|| .     '|| ");
		$display("      .||.     .|.  .||. |'....|'  |'....|'  ");
      //
		$fdisplay(fd, "      '||''|.      |      .|'''.|   .|'''.|  ");
		$fdisplay(fd, "       ||   ||    |||     ||..  '   ||..  '  ");
		$fdisplay(fd, "       ||...|'   |  ||     ''|||.    ''|||.  ");
		$fdisplay(fd, "       ||       .''''|.  .     '|| .     '|| ");
		$fdisplay(fd, "      .||.     .|.  .||. |'....|'  |'....|'  ");
   end
   else
   begin
		$display("      '||''''|     |     '||' '||'      ");
		$display("       ||  .      |||     ||   ||       ");
		$display("       ||''|     |  ||    ||   ||       ");
		$display("       ||       .''''|.   ||   ||       ");
		$display("      .||.     .|.  .||. .||. .||.....| ");
      //
		$fdisplay(fd, "      '||''''|     |     '||' '||'      ");
		$fdisplay(fd, "       ||  .      |||     ||   ||       ");
		$fdisplay(fd, "       ||''|     |  ||    ||   ||       ");
		$fdisplay(fd, "       ||       .''''|.   ||   ||       ");
		$fdisplay(fd, "      .||.     .|.  .||. .||. .||.....| ");
   end
   $display("");
   $display("");
   $display ("Number of transactors used for Random CSR Access Test..........: %0d", num_csr_tr_used);
   $display ("Number of register tests performed for Random CSR Access Test..: %0d", num_csr_checks);
   $display ("Total number of Random CSR Access errors found in test.........: %0d", num_total_csr_access_errors);
   $display("");
   $display ("Number of transactors used for Random Space Access Test........: %0d", num_tr_used-num_csr_tr_used);
   $display ("Number of register tests performed for Random Space Access Test: %0d", num_reg_checks-num_csr_checks);
   $display ("Total number of Random CSR Access errors found in test.........: %0d", num_total_access_errors-num_total_csr_access_errors);
   $display("");
   $display ("Total number of transactors used...............................: %0d", num_tr_used);
   $display ("Total number of register checks performed......................: %0d", num_reg_checks);
   $display ("Total number of CSR Access errors found in test................: %0d", num_total_access_errors);
   $display("");
   $display("");
   if (pass)
   begin
      $display("Test status: OK");
      $display("Test passed!");
   end   
   else
   begin
      $display("Test status: FAILED");
      $display("Test FAILED!");
   end
   $display("");
   $display("");
   $fclose(fd);
   $finish;
end

endmodule
