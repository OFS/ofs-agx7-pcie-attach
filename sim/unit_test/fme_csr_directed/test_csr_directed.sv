// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Test module for the FME unit test simulation.
//
//   This module uses the Transaction Classes defined in 
//   "csr_transaction_class_pkg.sv" to perform resets,
//   reads, and writes to the CSR Register block.
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
//   Simulation uses abstract base class transaction "tr" 
//   handles to group all transactions into a single queue 
//   called "Transaction".  Polymorphism is used in all
//   derived classes so that different transaction types 
//   can all coexist in a single queue.
//---------------------------------------------------------
PwrResetTransaction pt;

//--------------------------------------------------------------------------------------------
// Check handles.
//   Simulation uses check objects for each of the tests we want to run:
//     ResetCheck................: Performs a "soft" reset check using the AXI reset.
//     HardResetCheck............: Performs a "hard" reset check using the PowerGoodN reset.
//     WriteCheck................: Performs a write-ones check and then a write-zeros check 
//                                 for "normal" registers.
//     WriteOneSetClearCheck.....: Performs a write check with sequence to properly check
//                                 write-one-to-set and write-one-to-clear registers.
//     WriteWalkingOnesZerosCheck: Performs a "walking-ones" and "walking-zeros" write test on
//                                 registers.
//     WriteRandomCheck..........: Performs a series of register writes with random data to
//                                 check for bit errors.
//--------------------------------------------------------------------------------------------
ResetCheck rc;
HardResetCheck hrc;
WriteCheck wc;
WriteOneSetClearCheck woscc;
WriteWalkingOnesZerosCheck wwozc;
WriteRandomCheck wrc;

logic pass;
int   num_reg_checks;
int   num_tr_used;
int   num_total_bit_errors;
string reg_name_pass;
string suffix;

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
   // Initial Logic and AXI Bus Clearing                      |
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
   // FME_DFH Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_DFH Register Test @ Address 20'h0_0000 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_dfh_attr),
      .check_reg_name("FME_DFH"),
      .reg_addr(20'h0_0000),
      .reset_reg(testbench_top.dut.fme_csr_fme_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_dfh_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_DFH[15:12]][FME_DFH[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_dfh_attr),
      .check_reg_name("FME_DFH"),
      .reg_addr(20'h0_0000),
      .reset_reg(testbench_top.dut.fme_csr_fme_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_dfh_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_DFH[15:12]][FME_DFH[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_dfh_attr),
      .check_reg_name("FME_DFH"),
      .reg_addr(20'h0_0000),
      .reset_reg(testbench_top.dut.fme_csr_fme_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_dfh_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_dfh_attr),
      .check_reg_name("FME_DFH"),
      .reg_addr(20'h0_0000),
      .reset_reg(testbench_top.dut.fme_csr_fme_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_dfh_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_dfh_attr),
      .check_reg_name("FME_DFH"),
      .reg_addr(20'h0_0000),
      .reset_reg(testbench_top.dut.fme_csr_fme_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_dfh_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FME_AFU_ID_L Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_AFU_ID_L Register Test @ Address 20'h0_0008 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_l_attr),
      .check_reg_name("FME_AFU_ID_L"),
      .reg_addr(20'h0_0008),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_l_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_l_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_AFU_ID_L[15:12]][FME_AFU_ID_L[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_l_attr),
      .check_reg_name("FME_AFU_ID_L"),
      .reg_addr(20'h0_0008),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_l_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_l_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_AFU_ID_L[15:12]][FME_AFU_ID_L[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_l_attr),
      .check_reg_name("FME_AFU_ID_L"),
      .reg_addr(20'h0_0008),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_l_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_l_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_l_attr),
      .check_reg_name("FME_AFU_ID_L"),
      .reg_addr(20'h0_0008),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_l_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_l_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_l_attr),
      .check_reg_name("FME_AFU_ID_L"),
      .reg_addr(20'h0_0008),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_l_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_l_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FME_AFU_ID_H Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_AFU_ID_H Register Test @ Address 20'h0_0010 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_h_attr),
      .check_reg_name("FME_AFU_ID_H"),
      .reg_addr(20'h0_0010),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_h_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_h_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_AFU_ID_H[15:12]][FME_AFU_ID_H[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_h_attr),
      .check_reg_name("FME_AFU_ID_H"),
      .reg_addr(20'h0_0010),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_h_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_h_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_AFU_ID_H[15:12]][FME_AFU_ID_H[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_h_attr),
      .check_reg_name("FME_AFU_ID_H"),
      .reg_addr(20'h0_0010),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_h_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_h_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_h_attr),
      .check_reg_name("FME_AFU_ID_H"),
      .reg_addr(20'h0_0010),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_h_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_h_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_afu_id_h_attr),
      .check_reg_name("FME_AFU_ID_H"),
      .reg_addr(20'h0_0010),
      .reset_reg(testbench_top.dut.fme_csr_fme_afu_id_h_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_afu_id_h_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FME_NEXT_AFU Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_NEXT_AFU Register Test @ Address 20'h0_0018 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_afu_attr),
      .check_reg_name("FME_NEXT_AFU"),
      .reg_addr(20'h0_0018),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_afu_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_afu_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_NEXT_AFU[15:12]][FME_NEXT_AFU[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_afu_attr),
      .check_reg_name("FME_NEXT_AFU"),
      .reg_addr(20'h0_0018),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_afu_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_afu_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_NEXT_AFU[15:12]][FME_NEXT_AFU[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_afu_attr),
      .check_reg_name("FME_NEXT_AFU"),
      .reg_addr(20'h0_0018),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_afu_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_afu_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_afu_attr),
      .check_reg_name("FME_NEXT_AFU"),
      .reg_addr(20'h0_0018),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_afu_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_afu_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_afu_attr),
      .check_reg_name("FME_NEXT_AFU"),
      .reg_addr(20'h0_0018),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_afu_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_afu_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FME_SCRATCHPAD0 Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_SCRATCHPAD0 Register Test @ Address 20'h0_0028 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_scratchpad0_attr),
      .check_reg_name("FME_SCRATCHPAD0"),
      .reg_addr(20'h0_0028),
      .reset_reg(testbench_top.dut.fme_csr_fme_scratchpad0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_scratchpad0_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_SCRATCHPAD0[15:12]][FME_SCRATCHPAD0[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_scratchpad0_attr),
      .check_reg_name("FME_SCRATCHPAD0"),
      .reg_addr(20'h0_0028),
      .reset_reg(testbench_top.dut.fme_csr_fme_scratchpad0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_scratchpad0_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_SCRATCHPAD0[15:12]][FME_SCRATCHPAD0[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_scratchpad0_attr),
      .check_reg_name("FME_SCRATCHPAD0"),
      .reg_addr(20'h0_0028),
      .reset_reg(testbench_top.dut.fme_csr_fme_scratchpad0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_scratchpad0_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_scratchpad0_attr),
      .check_reg_name("FME_SCRATCHPAD0"),
      .reg_addr(20'h0_0028),
      .reset_reg(testbench_top.dut.fme_csr_fme_scratchpad0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_scratchpad0_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_scratchpad0_attr),
      .check_reg_name("FME_SCRATCHPAD0"),
      .reg_addr(20'h0_0028),
      .reset_reg(testbench_top.dut.fme_csr_fme_scratchpad0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_scratchpad0_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FAB_CAPABILITY Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FAB_CAPABILITY Register Test @ Address 20'h0_0030 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_capability_attr),
      .check_reg_name("FAB_CAPABILITY"),
      .reg_addr(20'h0_0030),
      .reset_reg(testbench_top.dut.fme_csr_fab_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_capability_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FAB_CAPABILITY[15:12]][FAB_CAPABILITY[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_capability_attr),
      .check_reg_name("FAB_CAPABILITY"),
      .reg_addr(20'h0_0030),
      .reset_reg(testbench_top.dut.fme_csr_fab_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_capability_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FAB_CAPABILITY[15:12]][FAB_CAPABILITY[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_capability_attr),
      .check_reg_name("FAB_CAPABILITY"),
      .reg_addr(20'h0_0030),
      .reset_reg(testbench_top.dut.fme_csr_fab_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_capability_update)
   );
   wc.check();
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_capability_attr),
      .check_reg_name("FAB_CAPABILITY"),
      .reg_addr(20'h0_0030),
      .reset_reg(testbench_top.dut.fme_csr_fab_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_capability_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_capability_attr),
      .check_reg_name("FAB_CAPABILITY"),
      .reg_addr(20'h0_0030),
      .reset_reg(testbench_top.dut.fme_csr_fab_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_capability_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // PORT0_OFFSET Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" PORT0_OFFSET Register Test @ Address 20'h0_0038 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port0_offset_attr),
      .check_reg_name("PORT0_OFFSET"),
      .reg_addr(20'h0_0038),
      .reset_reg(testbench_top.dut.fme_csr_port0_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port0_offset_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PORT0_OFFSET[15:12]][PORT0_OFFSET[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port0_offset_attr),
      .check_reg_name("PORT0_OFFSET"),
      .reg_addr(20'h0_0038),
      .reset_reg(testbench_top.dut.fme_csr_port0_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port0_offset_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PORT0_OFFSET[15:12]][PORT0_OFFSET[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port0_offset_attr),
      .check_reg_name("PORT0_OFFSET"),
      .reg_addr(20'h0_0038),
      .reset_reg(testbench_top.dut.fme_csr_port0_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port0_offset_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port0_offset_attr),
      .check_reg_name("PORT0_OFFSET"),
      .reg_addr(20'h0_0038),
      .reset_reg(testbench_top.dut.fme_csr_port0_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port0_offset_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port0_offset_attr),
      .check_reg_name("PORT0_OFFSET"),
      .reg_addr(20'h0_0038),
      .reset_reg(testbench_top.dut.fme_csr_port0_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port0_offset_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // PORT1_OFFSET Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" PORT1_OFFSET Register Test @ Address 20'h0_0040 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port1_offset_attr),
      .check_reg_name("PORT1_OFFSET"),
      .reg_addr(20'h0_0040),
      .reset_reg(testbench_top.dut.fme_csr_port1_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port1_offset_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PORT1_OFFSET[15:12]][PORT1_OFFSET[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port1_offset_attr),
      .check_reg_name("PORT1_OFFSET"),
      .reg_addr(20'h0_0040),
      .reset_reg(testbench_top.dut.fme_csr_port1_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port1_offset_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PORT1_OFFSET[15:12]][PORT1_OFFSET[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port1_offset_attr),
      .check_reg_name("PORT1_OFFSET"),
      .reg_addr(20'h0_0040),
      .reset_reg(testbench_top.dut.fme_csr_port1_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port1_offset_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port1_offset_attr),
      .check_reg_name("PORT1_OFFSET"),
      .reg_addr(20'h0_0040),
      .reset_reg(testbench_top.dut.fme_csr_port1_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port1_offset_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port1_offset_attr),
      .check_reg_name("PORT1_OFFSET"),
      .reg_addr(20'h0_0040),
      .reset_reg(testbench_top.dut.fme_csr_port1_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port1_offset_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // PORT2_OFFSET Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" PORT2_OFFSET Register Test @ Address 20'h0_0048 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port2_offset_attr),
      .check_reg_name("PORT2_OFFSET"),
      .reg_addr(20'h0_0048),
      .reset_reg(testbench_top.dut.fme_csr_port2_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port2_offset_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PORT2_OFFSET[15:12]][PORT2_OFFSET[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port2_offset_attr),
      .check_reg_name("PORT2_OFFSET"),
      .reg_addr(20'h0_0048),
      .reset_reg(testbench_top.dut.fme_csr_port2_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port2_offset_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PORT2_OFFSET[15:12]][PORT2_OFFSET[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port2_offset_attr),
      .check_reg_name("PORT2_OFFSET"),
      .reg_addr(20'h0_0048),
      .reset_reg(testbench_top.dut.fme_csr_port2_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port2_offset_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port2_offset_attr),
      .check_reg_name("PORT2_OFFSET"),
      .reg_addr(20'h0_0048),
      .reset_reg(testbench_top.dut.fme_csr_port2_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port2_offset_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port2_offset_attr),
      .check_reg_name("PORT2_OFFSET"),
      .reg_addr(20'h0_0048),
      .reset_reg(testbench_top.dut.fme_csr_port2_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port2_offset_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // PORT3_OFFSET Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" PORT3_OFFSET Register Test @ Address 20'h0_0050 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port3_offset_attr),
      .check_reg_name("PORT3_OFFSET"),
      .reg_addr(20'h0_0050),
      .reset_reg(testbench_top.dut.fme_csr_port3_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port3_offset_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PORT3_OFFSET[15:12]][PORT3_OFFSET[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port3_offset_attr),
      .check_reg_name("PORT3_OFFSET"),
      .reg_addr(20'h0_0050),
      .reset_reg(testbench_top.dut.fme_csr_port3_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port3_offset_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PORT3_OFFSET[15:12]][PORT3_OFFSET[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port3_offset_attr),
      .check_reg_name("PORT3_OFFSET"),
      .reg_addr(20'h0_0050),
      .reset_reg(testbench_top.dut.fme_csr_port3_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port3_offset_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port3_offset_attr),
      .check_reg_name("PORT3_OFFSET"),
      .reg_addr(20'h0_0050),
      .reset_reg(testbench_top.dut.fme_csr_port3_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port3_offset_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.port3_offset_attr),
      .check_reg_name("PORT3_OFFSET"),
      .reg_addr(20'h0_0050),
      .reset_reg(testbench_top.dut.fme_csr_port3_offset_reset),
      .update_reg(testbench_top.dut.fme_csr_port3_offset_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FAB_STATUS Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FAB_STATUS Register Test @ Address 20'h0_0058 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge clk); #100ps;
   @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_status_attr),
      .check_reg_name("FAB_STATUS"),
      .reg_addr(20'h0_0058),
      .reset_reg(testbench_top.dut.fme_csr_fab_status_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_status_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FAB_STATUS[15:12]][FAB_STATUS[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge clk); #100ps;
   @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_status_attr),
      .check_reg_name("FAB_STATUS"),
      .reg_addr(20'h0_0058),
      .reset_reg(testbench_top.dut.fme_csr_fab_status_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_status_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FAB_STATUS[15:12]][FAB_STATUS[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk); #100ps;
   @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_status_attr),
      .check_reg_name("FAB_STATUS"),
      .reg_addr(20'h0_0058),
      .reset_reg(testbench_top.dut.fme_csr_fab_status_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_status_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_fab_status_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_status_attr),
      .check_reg_name("FAB_STATUS"),
      .reg_addr(20'h0_0058),
      .reset_reg(testbench_top.dut.fme_csr_fab_status_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_status_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fab_status_attr),
      .check_reg_name("FAB_STATUS"),
      .reg_addr(20'h0_0058),
      .reset_reg(testbench_top.dut.fme_csr_fab_status_reset),
      .update_reg(testbench_top.dut.fme_csr_fab_status_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // BITSTREAM_ID Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check: Not run -- cannot load from ROM when reset.                        |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" BITSTREAM_ID Register Test @ Address 20'h0_0060 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.bitstream_id_attr),
      .check_reg_name("BITSTREAM_ID"),
      .reg_addr(20'h0_0060),
      .reset_reg(testbench_top.dut.fme_csr_bitstream_id_reset),
      .update_reg(testbench_top.dut.fme_csr_bitstream_id_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.bitstream_id_attr),
      .check_reg_name("BITSTREAM_ID"),
      .reg_addr(20'h0_0060),
      .reset_reg(testbench_top.dut.fme_csr_bitstream_id_reset),
      .update_reg(testbench_top.dut.fme_csr_bitstream_id_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.bitstream_id_attr),
      .check_reg_name("BITSTREAM_ID"),
      .reg_addr(20'h0_0060),
      .reset_reg(testbench_top.dut.fme_csr_bitstream_id_reset),
      .update_reg(testbench_top.dut.fme_csr_bitstream_id_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // BITSTREAM_MD Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check: Not run -- cannot load from ROM when reset.                        |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" BITSTREAM_MD Register Test @ Address 20'h0_0068 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.bitstream_md_attr),
      .check_reg_name("BITSTREAM_MD"),
      .reg_addr(20'h0_0068),
      .reset_reg(testbench_top.dut.fme_csr_bitstream_md_reset),
      .update_reg(testbench_top.dut.fme_csr_bitstream_md_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.bitstream_md_attr),
      .check_reg_name("BITSTREAM_MD"),
      .reg_addr(20'h0_0068),
      .reset_reg(testbench_top.dut.fme_csr_bitstream_md_reset),
      .update_reg(testbench_top.dut.fme_csr_bitstream_md_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.bitstream_md_attr),
      .check_reg_name("BITSTREAM_MD"),
      .reg_addr(20'h0_0068),
      .reset_reg(testbench_top.dut.fme_csr_bitstream_md_reset),
      .update_reg(testbench_top.dut.fme_csr_bitstream_md_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // THERM_MNGM_DFH Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" THERM_MNGM_DFH Register Test @ Address 20'h0_1000 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.therm_mngm_dfh_attr),
      .check_reg_name("THERM_MNGM_DFH"),
      .reg_addr(20'h0_1000),
      .reset_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[THERM_MNGM_DFH[15:12]][THERM_MNGM_DFH[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.therm_mngm_dfh_attr),
      .check_reg_name("THERM_MNGM_DFH"),
      .reg_addr(20'h0_1000),
      .reset_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[THERM_MNGM_DFH[15:12]][THERM_MNGM_DFH[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.therm_mngm_dfh_attr),
      .check_reg_name("THERM_MNGM_DFH"),
      .reg_addr(20'h0_1000),
      .reset_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.therm_mngm_dfh_attr),
      .check_reg_name("THERM_MNGM_DFH"),
      .reg_addr(20'h0_1000),
      .reset_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.therm_mngm_dfh_attr),
      .check_reg_name("THERM_MNGM_DFH"),
      .reg_addr(20'h0_1000),
      .reset_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_therm_mngm_dfh_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // TMP_THRESHOLD Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" TMP_THRESHOLD Register Test @ Address 20'h0_1008 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_attr),
      .check_reg_name("TMP_THRESHOLD"),
      .reg_addr(20'h0_1008),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[TMP_THRESHOLD[15:12]][TMP_THRESHOLD[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_attr),
      .check_reg_name("TMP_THRESHOLD"),
      .reg_addr(20'h0_1008),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[TMP_THRESHOLD[15:12]][TMP_THRESHOLD[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_attr),
      .check_reg_name("TMP_THRESHOLD"),
      .reg_addr(20'h0_1008),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_tmp_threshold_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_attr),
      .check_reg_name("TMP_THRESHOLD"),
      .reg_addr(20'h0_1008),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_attr),
      .check_reg_name("TMP_THRESHOLD"),
      .reg_addr(20'h0_1008),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // TMP_RDSENSOR_FMT1 Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" TMP_RDSENSOR_FMT1 Register Test @ Address 20'h0_1010 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_rdsensor_fmt1_attr),
      .check_reg_name("TMP_RDSENSOR_FMT1"),
      .reg_addr(20'h0_1010),
      .reset_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[TMP_RDSENSOR_FMT1[15:12]][TMP_RDSENSOR_FMT1[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_rdsensor_fmt1_attr),
      .check_reg_name("TMP_RDSENSOR_FMT1"),
      .reg_addr(20'h0_1010),
      .reset_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[TMP_RDSENSOR_FMT1[15:12]][TMP_RDSENSOR_FMT1[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_rdsensor_fmt1_attr),
      .check_reg_name("TMP_RDSENSOR_FMT1"),
      .reg_addr(20'h0_1010),
      .reset_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // TMP_RDSENSOR_FMT2 Test                                                          |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_rdsensor_fmt2_attr),
      .check_reg_name("TMP_RDSENSOR_FMT2"),
      .reg_addr(20'h0_1018),
      .reset_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt2_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt2_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_rdsensor_fmt1_attr),
      .check_reg_name("TMP_RDSENSOR_FMT1"),
      .reg_addr(20'h0_1010),
      .reset_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_rdsensor_fmt1_attr),
      .check_reg_name("TMP_RDSENSOR_FMT1"),
      .reg_addr(20'h0_1010),
      .reset_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_rdsensor_fmt1_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // TMP_THRESHOLD_CAPABILITY Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" TMP_THRESHOLD_CAPABILITY Register Test @ Address 20'h0_1020 <<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_capability_attr),
      .check_reg_name("TMP_THRESHOLD_CAPABILITY"),
      .reg_addr(20'h0_1020),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[TMP_THRESHOLD_CAPABILITY[15:12]][TMP_THRESHOLD_CAPABILITY[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_capability_attr),
      .check_reg_name("TMP_THRESHOLD_CAPABILITY"),
      .reg_addr(20'h0_1020),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[TMP_THRESHOLD_CAPABILITY[15:12]][TMP_THRESHOLD_CAPABILITY[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_capability_attr),
      .check_reg_name("TMP_THRESHOLD_CAPABILITY"),
      .reg_addr(20'h0_1020),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_capability_attr),
      .check_reg_name("TMP_THRESHOLD_CAPABILITY"),
      .reg_addr(20'h0_1020),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.tmp_threshold_capability_attr),
      .check_reg_name("TMP_THRESHOLD_CAPABILITY"),
      .reg_addr(20'h0_1020),
      .reset_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_tmp_threshold_capability_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // GLBL_PERF_DFH Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" GLBL_PERF_DFH Register Test @ Address 20'h0_3000 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_perf_dfh_attr),
      .check_reg_name("GLBL_PERF_DFH"),
      .reg_addr(20'h0_3000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[GLBL_PERF_DFH[15:12]][GLBL_PERF_DFH[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_perf_dfh_attr),
      .check_reg_name("GLBL_PERF_DFH"),
      .reg_addr(20'h0_3000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[GLBL_PERF_DFH[15:12]][GLBL_PERF_DFH[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_perf_dfh_attr),
      .check_reg_name("GLBL_PERF_DFH"),
      .reg_addr(20'h0_3000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_perf_dfh_attr),
      .check_reg_name("GLBL_PERF_DFH"),
      .reg_addr(20'h0_3000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_perf_dfh_attr),
      .check_reg_name("GLBL_PERF_DFH"),
      .reg_addr(20'h0_3000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_perf_dfh_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FPMON_FAB_CTL Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FPMON_FAB_CTL Register Test @ Address 20'h0_3020 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctl_attr),
      .check_reg_name("FPMON_FAB_CTL"),
      .reg_addr(20'h0_3020),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FPMON_FAB_CTL[15:12]][FPMON_FAB_CTL[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctl_attr),
      .check_reg_name("FPMON_FAB_CTL"),
      .reg_addr(20'h0_3020),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FPMON_FAB_CTL[15:12]][FPMON_FAB_CTL[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctl_attr),
      .check_reg_name("FPMON_FAB_CTL"),
      .reg_addr(20'h0_3020),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctl_attr),
      .check_reg_name("FPMON_FAB_CTL"),
      .reg_addr(20'h0_3020),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctl_attr),
      .check_reg_name("FPMON_FAB_CTL"),
      .reg_addr(20'h0_3020),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctl_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FPMON_FAB_CTR Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FPMON_FAB_CTR Register Test @ Address 20'h0_3028 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctr_attr),
      .check_reg_name("FPMON_FAB_CTR"),
      .reg_addr(20'h0_3028),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FPMON_FAB_CTR[15:12]][FPMON_FAB_CTR[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctr_attr),
      .check_reg_name("FPMON_FAB_CTR"),
      .reg_addr(20'h0_3028),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FPMON_FAB_CTR[15:12]][FPMON_FAB_CTR[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctr_attr),
      .check_reg_name("FPMON_FAB_CTR"),
      .reg_addr(20'h0_3028),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_fpmon_fab_ctr_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctr_attr),
      .check_reg_name("FPMON_FAB_CTR"),
      .reg_addr(20'h0_3028),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_fab_ctr_attr),
      .check_reg_name("FPMON_FAB_CTR"),
      .reg_addr(20'h0_3028),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_fab_ctr_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FPMON_CLK_CTR Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FPMON_CLK_CTR Register Test @ Address 20'h0_3030 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_clk_ctr_attr),
      .check_reg_name("FPMON_CLK_CTR"),
      .reg_addr(20'h0_3030),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FPMON_CLK_CTR[15:12]][FPMON_CLK_CTR[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_clk_ctr_attr),
      .check_reg_name("FPMON_CLK_CTR"),
      .reg_addr(20'h0_3030),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FPMON_CLK_CTR[15:12]][FPMON_CLK_CTR[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_clk_ctr_attr),
      .check_reg_name("FPMON_CLK_CTR"),
      .reg_addr(20'h0_3030),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_fpmon_clk_ctr_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_clk_ctr_attr),
      .check_reg_name("FPMON_CLK_CTR"),
      .reg_addr(20'h0_3030),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fpmon_clk_ctr_attr),
      .check_reg_name("FPMON_CLK_CTR"),
      .reg_addr(20'h0_3030),
      .reset_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_reset),
      .update_reg(testbench_top.dut.fme_csr_fpmon_clk_ctr_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // GLBL_ERROR_DFH Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" GLBL_ERROR_DFH Register Test @ Address 20'h0_4000 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_dfh_attr),
      .check_reg_name("GLBL_ERROR_DFH"),
      .reg_addr(20'h0_4000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_dfh_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[GLBL_ERROR_DFH[15:12]][GLBL_ERROR_DFH[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_dfh_attr),
      .check_reg_name("GLBL_ERROR_DFH"),
      .reg_addr(20'h0_4000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_dfh_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[GLBL_ERROR_DFH[15:12]][GLBL_ERROR_DFH[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_dfh_attr),
      .check_reg_name("GLBL_ERROR_DFH"),
      .reg_addr(20'h0_4000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_dfh_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_dfh_attr),
      .check_reg_name("GLBL_ERROR_DFH"),
      .reg_addr(20'h0_4000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_dfh_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_dfh_attr),
      .check_reg_name("GLBL_ERROR_DFH"),
      .reg_addr(20'h0_4000),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_dfh_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_dfh_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FME_ERROR_MASK0 Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_ERROR_MASK0 Register Test @ Address 20'h0_4008 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_error_mask0_attr),
      .check_reg_name("FME_ERROR_MASK0"),
      .reg_addr(20'h0_4008),
      .reset_reg(testbench_top.dut.fme_csr_fme_error_mask0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error_mask0_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_ERROR_MASK0[15:12]][FME_ERROR_MASK0[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_error_mask0_attr),
      .check_reg_name("FME_ERROR_MASK0"),
      .reg_addr(20'h0_4008),
      .reset_reg(testbench_top.dut.fme_csr_fme_error_mask0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error_mask0_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_ERROR_MASK0[15:12]][FME_ERROR_MASK0[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_error_mask0_attr),
      .check_reg_name("FME_ERROR_MASK0"),
      .reg_addr(20'h0_4008),
      .reset_reg(testbench_top.dut.fme_csr_fme_error_mask0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error_mask0_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_error_mask0_attr),
      .check_reg_name("FME_ERROR_MASK0"),
      .reg_addr(20'h0_4008),
      .reset_reg(testbench_top.dut.fme_csr_fme_error_mask0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error_mask0_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_error_mask0_attr),
      .check_reg_name("FME_ERROR_MASK0"),
      .reg_addr(20'h0_4008),
      .reset_reg(testbench_top.dut.fme_csr_fme_error_mask0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error_mask0_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FME_ERROR0 Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_ERROR0 Register Test @ Address 20'h0_4010 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_fme_error0_update = { {58{1'b0}},1'b1,{3{1'b0}}, {2{1'b1}} }; // Set RW1C/S bits.
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_fme_error0_update = '0; // Allow writes to affect bits.
   repeat (2) @(posedge axi.clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {58{RsvdZ}},RW1CS,{3{RsvdZ}},{2{RW1CS}} }), // Error registers must have their attributes set explicitly.
      .check_reg_name("FME_ERROR0"),
      .reg_addr(20'h0_4010),
      .reset_reg(testbench_top.dut.fme_csr_fme_error0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error0_update)
   );
   rc.write_value({64{1'b0}}); // RW1CS bits set with inputs above.  Check to make sure they retain their state after a soft reset.
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_ERROR0[15:12]][FME_ERROR0[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_fme_error0_update = { {58{1'b0}},1'b1,{3{1'b0}}, {2{1'b1}} }; // Set RW1C/S bits.
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_fme_error0_update = '0; // Allow writes to affect bits.
   repeat (2) @(posedge axi.clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {58{RsvdZ}},RW1CS,{3{RsvdZ}},{2{RW1CS}} }), // Error registers must have their attributes set explicitly.
      .check_reg_name("FME_ERROR0"),
      .reg_addr(20'h0_4010),
      .reset_reg(testbench_top.dut.fme_csr_fme_error0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error0_update)
   );
   hrc.write_value({64{1'b0}}); // RW1CS bits set with inputs above.  Check to make sure they retain their state after a soft reset.
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_ERROR0[15:12]][FME_ERROR0[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_fme_error0_update = { {58{1'b0}},1'b1,{3{1'b0}}, {2{1'b1}} }; // Set RW1C/S bits.
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_fme_error0_update = '0; // Allow writes to affect bits.
   repeat (2) @(posedge axi.clk);
   woscc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {58{RsvdZ}},RW1CS,{3{RsvdZ}},{2{RW1CS}} }), // Error registers are RW1CS attribute type.
      .check_reg_name("FME_ERROR0"),
      .reg_addr(20'h0_4010),
      .reset_reg(testbench_top.dut.fme_csr_fme_error0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error0_update)
   );
   woscc.check_data( .write_value_passed({ {58{1'b0}},1'b1,{3{1'b0}}, {2{1'b1}} }) );  // Write all ones to used bits and test result.
   if (woscc.fail()) pass = 1'b0;
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_fme_error0_update = { {58{1'b0}},1'b1,{3{1'b0}}, {2{1'b1}} }; // Set RW1C/S bits.
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_fme_error0_update = '0; // Allow writes to affect bits.
   repeat (2) @(posedge axi.clk);
   woscc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {58{RsvdZ}},RW1CS,{3{RsvdZ}},{2{RW1CS}} }), // Error registers are RW1CS attribute type.
      .check_reg_name("FME_ERROR0"),
      .reg_addr(20'h0_4010),
      .reset_reg(testbench_top.dut.fme_csr_fme_error0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error0_update)
   );
   woscc.check_data( .write_value_passed({ {58{1'b0}},1'b0,{3{1'b0}}, {2{1'b0}} }) );  // Write all zeros to used bits and test result.
   if (woscc.fail()) pass = 1'b0;
   @(posedge axi.clk); #100ps;
   release testbench_top.dut.fme_csr_fme_error0_update; // Release RW1C/S bits.
   @(posedge axi.clk);
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {58{RsvdZ}},RW1CS,{3{RsvdZ}},{2{RW1CS}} }),
      .check_reg_name("FME_ERROR0"),
      .reg_addr(20'h0_4010),
      .reset_reg(testbench_top.dut.fme_csr_fme_error0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error0_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {58{RsvdZ}},RW1CS,{3{RsvdZ}},{2{RW1CS}} }),
      .check_reg_name("FME_ERROR0"),
      .reg_addr(20'h0_4010),
      .reset_reg(testbench_top.dut.fme_csr_fme_error0_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_error0_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // PCIE0_ERROR_MASK Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" PCIE0_ERROR_MASK Register Test @ Address 20'h0_4018 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.pcie0_error_mask_attr),
      .check_reg_name("PCIE0_ERROR_MASK"),
      .reg_addr(20'h0_4018),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_mask_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PCIE0_ERROR_MASK[15:12]][PCIE0_ERROR_MASK[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.pcie0_error_mask_attr),
      .check_reg_name("PCIE0_ERROR_MASK"),
      .reg_addr(20'h0_4018),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_mask_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PCIE0_ERROR_MASK[15:12]][PCIE0_ERROR_MASK[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.pcie0_error_mask_attr),
      .check_reg_name("PCIE0_ERROR_MASK"),
      .reg_addr(20'h0_4018),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_mask_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.pcie0_error_mask_attr),
      .check_reg_name("PCIE0_ERROR_MASK"),
      .reg_addr(20'h0_4018),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_mask_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.pcie0_error_mask_attr),
      .check_reg_name("PCIE0_ERROR_MASK"),
      .reg_addr(20'h0_4018),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_mask_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // PCIE0_ERROR Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" PCIE0_ERROR Register Test @ Address 20'h0_4020 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_pcie0_error_update = { {2{1'b1}},{49{1'b0}},{13{1'b1}} }; // Set RW1C/S bits.
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_pcie0_error_update = '0; // Allow writes to affect bits.
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {2{RW1CS}},{49{RsvdZ}},{13{RW1CS}} }), // Error registers must have their attributes set explicitly.
      .check_reg_name("PCIE0_ERROR"),
      .reg_addr(20'h0_4020),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_update)
   );
   rc.write_value({64{1'b0}}); // RW1CS bits set with inputs above.  Check to make sure they retain their state after a soft reset.
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PCIE0_ERROR[15:12]][PCIE0_ERROR[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_pcie0_error_update = { {2{1'b1}},{49{1'b0}},{13{1'b1}} }; // Set RW1C/S bits.
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_pcie0_error_update = '0; // Allow writes to affect bits.
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {2{RW1CS}},{49{RsvdZ}},{13{RW1CS}} }), // Error registers must have their attributes set explicitly.
      .check_reg_name("PCIE0_ERROR"),
      .reg_addr(20'h0_4020),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_update)
   );
   hrc.write_value({64{1'b0}}); // RW1CS bits set with inputs above.  Check to make sure they retain their state after a soft reset.
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[PCIE0_ERROR[15:12]][PCIE0_ERROR[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_pcie0_error_update = { {2{1'b1}},{49{1'b0}},{13{1'b1}} }; // Set RW1C/S bits.
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_pcie0_error_update = '0; // Allow writes to affect bits.
   repeat (2) @(posedge axi.clk);
   woscc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {2{RW1CS}},{49{RsvdZ}},{13{RW1CS}} }), // Error registers are RW1CS attribute type.
      .check_reg_name("PCIE0_ERROR"),
      .reg_addr(20'h0_4020),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_update)
   );
   woscc.check_data( .write_value_passed({ {2{1'b1}},{49{1'b0}},{13{1'b1}} }) );  // Write all ones and test result.
   if (woscc.fail()) pass = 1'b0;
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_pcie0_error_update = { {2{1'b1}},{49{1'b0}},{13{1'b1}} }; // Set RW1C/S bits.
   @(posedge axi.clk); #100ps;
   force testbench_top.dut.fme_csr_pcie0_error_update = '0; // Allow writes to affect bits.
   repeat (2) @(posedge axi.clk);
   woscc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {2{RW1CS}},{49{RsvdZ}},{13{RW1CS}} }), // Error registers are RW1CS attribute type.
      .check_reg_name("PCIE0_ERROR"),
      .reg_addr(20'h0_4020),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_update)
   );
   woscc.check_data( .write_value_passed({ {2{1'b0}},{49{1'b0}},{13{1'b0}} }) );  // Write all zeroes and test result.
   if (woscc.fail()) pass = 1'b0;
   @(posedge axi.clk); #100ps;
   release testbench_top.dut.fme_csr_pcie0_error_update; // Release RW1C/S bits.
   @(posedge axi.clk);
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {2{RW1CS}},{49{RsvdZ}},{13{RW1CS}} }),
      .check_reg_name("PCIE0_ERROR"),
      .reg_addr(20'h0_4020),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr({ {2{RW1CS}},{49{RsvdZ}},{13{RW1CS}} }),
      .check_reg_name("PCIE0_ERROR"),
      .reg_addr(20'h0_4020),
      .reset_reg(testbench_top.dut.fme_csr_pcie0_error_reset),
      .update_reg(testbench_top.dut.fme_csr_pcie0_error_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FME_FIRST_ERROR Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_FIRST_ERROR Register Test @ Address 20'h0_4038 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge clk); #100ps;
   force testbench_top.dut.ferr_id = 2'b11;
   force testbench_top.dut.fme_ferr_comb = '1;
   @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_first_error_attr),
      .check_reg_name("FME_FIRST_ERROR"),
      .reg_addr(20'h0_4038),
      .reset_reg(testbench_top.dut.fme_csr_fme_first_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_first_error_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_FIRST_ERROR[15:12]][FME_FIRST_ERROR[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge clk); #100ps;
   force testbench_top.dut.ferr_id = 2'b11;
   force testbench_top.dut.fme_ferr_comb = '1;
   @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_first_error_attr),
      .check_reg_name("FME_FIRST_ERROR"),
      .reg_addr(20'h0_4038),
      .reset_reg(testbench_top.dut.fme_csr_fme_first_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_first_error_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_FIRST_ERROR[15:12]][FME_FIRST_ERROR[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk); #100ps;
   force testbench_top.dut.ferr_id = 2'b11;
   force testbench_top.dut.fme_ferr_comb = '1;
   @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_first_error_attr),
      .check_reg_name("FME_FIRST_ERROR"),
      .reg_addr(20'h0_4038),
      .reset_reg(testbench_top.dut.fme_csr_fme_first_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_first_error_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   force testbench_top.dut.ferr_id = 2'b00;
   force testbench_top.dut.fme_ferr_comb = '0;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_fme_first_error_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   release testbench_top.dut.ferr_id;
   release testbench_top.dut.fme_ferr_comb;
   @(posedge clk);
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_first_error_attr),
      .check_reg_name("FME_FIRST_ERROR"),
      .reg_addr(20'h0_4038),
      .reset_reg(testbench_top.dut.fme_csr_fme_first_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_first_error_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_first_error_attr),
      .check_reg_name("FME_FIRST_ERROR"),
      .reg_addr(20'h0_4038),
      .reset_reg(testbench_top.dut.fme_csr_fme_first_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_first_error_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // FME_NEXT_ERROR Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" FME_NEXT_ERROR Register Test @ Address 20'h0_4040 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   @(posedge clk); #100ps;
   force testbench_top.dut.nerr_id = 2'b11;
   force testbench_top.dut.fme_nerr_comb = '1;
   @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_error_attr),
      .check_reg_name("FME_NEXT_ERROR"),
      .reg_addr(20'h0_4040),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_error_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_NEXT_ERROR[15:12]][FME_NEXT_ERROR[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   @(posedge clk); #100ps;
   force testbench_top.dut.nerr_id = 2'b11;
   force testbench_top.dut.fme_nerr_comb = '1;
   @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_error_attr),
      .check_reg_name("FME_NEXT_ERROR"),
      .reg_addr(20'h0_4040),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_error_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[FME_NEXT_ERROR[15:12]][FME_NEXT_ERROR[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk); #100ps;
   force testbench_top.dut.nerr_id = 2'b11;
   force testbench_top.dut.fme_nerr_comb = '1;
   @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_error_attr),
      .check_reg_name("FME_NEXT_ERROR"),
      .reg_addr(20'h0_4040),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_error_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   force testbench_top.dut.nerr_id = 2'b00;
   force testbench_top.dut.fme_nerr_comb = '0;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_fme_next_error_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   release testbench_top.dut.nerr_id;
   release testbench_top.dut.fme_nerr_comb;
   @(posedge clk);
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_error_attr),
      .check_reg_name("FME_NEXT_ERROR"),
      .reg_addr(20'h0_4040),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_error_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.fme_next_error_attr),
      .check_reg_name("FME_NEXT_ERROR"),
      .reg_addr(20'h0_4040),
      .reset_reg(testbench_top.dut.fme_csr_fme_next_error_reset),
      .update_reg(testbench_top.dut.fme_csr_fme_next_error_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // RAS_NOFAT_ERROR_MASK Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" RAS_NOFAT_ERROR_MASK Register Test @ Address 20'h0_4048 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_mask_attr),
      .check_reg_name("RAS_NOFAT_ERROR_MASK"),
      .reg_addr(20'h0_4048),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_NOFAT_ERROR_MASK[15:12]][RAS_NOFAT_ERROR_MASK[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_mask_attr),
      .check_reg_name("RAS_NOFAT_ERROR_MASK"),
      .reg_addr(20'h0_4048),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_NOFAT_ERROR_MASK[15:12]][RAS_NOFAT_ERROR_MASK[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_mask_attr),
      .check_reg_name("RAS_NOFAT_ERROR_MASK"),
      .reg_addr(20'h0_4048),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_mask_attr),
      .check_reg_name("RAS_NOFAT_ERROR_MASK"),
      .reg_addr(20'h0_4048),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_mask_attr),
      .check_reg_name("RAS_NOFAT_ERROR_MASK"),
      .reg_addr(20'h0_4048),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_mask_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // RAS_NOFAT_ERROR Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" RAS_NOFAT_ERROR Register Test @ Address 20'h0_4050 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   pt = new(
      .axi(axi),
      .pgn(pgn) 
   ); 
   pt.run(); // Perform a power reset before proceeding to clear mask register.
   @(posedge clk); #100ps;
   force testbench_top.dut.ras_grnerr_masked = '1;
   repeat (4) @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_attr),
      .check_reg_name("RAS_NOFAT_ERROR"),
      .reg_addr(20'h0_4050),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_NOFAT_ERROR[15:12]][RAS_NOFAT_ERROR[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   pt = new(
      .axi(axi),
      .pgn(pgn) 
   ); 
   pt.run(); // Perform a power reset before proceeding to clear mask register.
   @(posedge clk); #100ps;
   force testbench_top.dut.ras_grnerr_masked = '1;
   repeat (4) @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_attr),
      .check_reg_name("RAS_NOFAT_ERROR"),
      .reg_addr(20'h0_4050),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_NOFAT_ERROR[15:12]][RAS_NOFAT_ERROR[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk); #100ps;
   force testbench_top.dut.ras_grnerr_masked = '1;
   repeat (4) @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_attr), // Error registers are RW1CS attribute type.
      //.check_reg_attr({64{RW1CS}}), // Error registers are RW1CS attribute type.
      .check_reg_name("RAS_NOFAT_ERROR"),
      .reg_addr(20'h0_4050),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   force testbench_top.dut.ras_grnerr_masked = '0;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_ras_nofat_error_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_attr),
      .check_reg_name("RAS_NOFAT_ERROR"),
      .reg_addr(20'h0_4050),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_nofat_error_attr),
      .check_reg_name("RAS_NOFAT_ERROR"),
      .reg_addr(20'h0_4050),
      .reset_reg(testbench_top.dut.fme_csr_ras_nofat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_nofat_error_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   release testbench_top.dut.ras_grnerr_masked;
   @(posedge clk);
   //----------------------------------------------------------------------------------
   // RAS_CATFAT_ERROR_MASK Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" RAS_CATFAT_ERROR_MASK Register Test @ Address 20'h0_4058 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_mask_attr),
      .check_reg_name("RAS_CATFAT_ERROR_MASK"),
      .reg_addr(20'h0_4058),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_CATFAT_ERROR_MASK[15:12]][RAS_CATFAT_ERROR_MASK[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_mask_attr),
      .check_reg_name("RAS_CATFAT_ERROR_MASK"),
      .reg_addr(20'h0_4058),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_CATFAT_ERROR_MASK[15:12]][RAS_CATFAT_ERROR_MASK[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_mask_attr),
      .check_reg_name("RAS_CATFAT_ERROR_MASK"),
      .reg_addr(20'h0_4058),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_mask_attr),
      .check_reg_name("RAS_CATFAT_ERROR_MASK"),
      .reg_addr(20'h0_4058),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_mask_attr),
      .check_reg_name("RAS_CATFAT_ERROR_MASK"),
      .reg_addr(20'h0_4058),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_mask_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // RAS_CATFAT_ERROR Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" RAS_CATFAT_ERROR Register Test @ Address 20'h0_4060 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   pt = new(
      .axi(axi),
      .pgn(pgn) 
   ); 
   pt.run(); // Perform a power reset before proceeding to clear mask register.
   @(posedge clk); #100ps;
   force testbench_top.dut.ras_bluerr_masked = '1;
   repeat (4) @(posedge clk);
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_attr),
      .check_reg_name("RAS_CATFAT_ERROR"),
      .reg_addr(20'h0_4060),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_CATFAT_ERROR[15:12]][RAS_CATFAT_ERROR[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   pt = new(
      .axi(axi),
      .pgn(pgn) 
   ); 
   pt.run(); // Perform a power reset before proceeding to clear mask register.
   @(posedge clk); #100ps;
   force testbench_top.dut.ras_bluerr_masked = '1;
   repeat (4) @(posedge clk);
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_attr),
      .check_reg_name("RAS_CATFAT_ERROR"),
      .reg_addr(20'h0_4060),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_CATFAT_ERROR[15:12]][RAS_CATFAT_ERROR[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   @(posedge clk); #100ps;
   force testbench_top.dut.ras_bluerr_masked = '1;
   repeat (4) @(posedge clk);
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_attr), // Error registers are RW1CS attribute type.
      .check_reg_name("RAS_CATFAT_ERROR"),
      .reg_addr(20'h0_4060),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   force testbench_top.dut.ras_bluerr_masked = '0;
   @(posedge clk);
   wc.update_reg = testbench_top.dut.fme_csr_ras_catfat_error_update;
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_attr),
      .check_reg_name("RAS_CATFAT_ERROR"),
      .reg_addr(20'h0_4060),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_catfat_error_attr),
      .check_reg_name("RAS_CATFAT_ERROR"),
      .reg_addr(20'h0_4060),
      .reset_reg(testbench_top.dut.fme_csr_ras_catfat_error_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_catfat_error_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   @(posedge clk); #100ps;
   release testbench_top.dut.ras_bluerr_masked;
   @(posedge clk);
   //----------------------------------------------------------------------------------
   // RAS_ERROR_INJ Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" RAS_ERROR_INJ Register Test @ Address 20'h0_4068 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_error_inj_attr),
      .check_reg_name("RAS_ERROR_INJ"),
      .reg_addr(20'h0_4068),
      .reset_reg(testbench_top.dut.fme_csr_ras_error_inj_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_error_inj_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_ERROR_INJ[15:12]][RAS_ERROR_INJ[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_error_inj_attr),
      .check_reg_name("RAS_ERROR_INJ"),
      .reg_addr(20'h0_4068),
      .reset_reg(testbench_top.dut.fme_csr_ras_error_inj_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_error_inj_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[RAS_ERROR_INJ[15:12]][RAS_ERROR_INJ[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_error_inj_attr),
      .check_reg_name("RAS_ERROR_INJ"),
      .reg_addr(20'h0_4068),
      .reset_reg(testbench_top.dut.fme_csr_ras_error_inj_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_error_inj_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_error_inj_attr),
      .check_reg_name("RAS_ERROR_INJ"),
      .reg_addr(20'h0_4068),
      .reset_reg(testbench_top.dut.fme_csr_ras_error_inj_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_error_inj_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.ras_error_inj_attr),
      .check_reg_name("RAS_ERROR_INJ"),
      .reg_addr(20'h0_4068),
      .reset_reg(testbench_top.dut.fme_csr_ras_error_inj_reset),
      .update_reg(testbench_top.dut.fme_csr_ras_error_inj_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // GLBL_ERROR_CAPABILITY Test <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |
   //----------------------------------------------------------------------------------
   // Reset Check                                                                     |
   //----------------------------------------------------------------------------------
   $display("");
   $display("-------------------------------------------------------------------------------------------");
   $display(" GLBL_ERROR_CAPABILITY Register Test @ Address 20'h0_4070 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< |");
   $display("-------------------------------------------------------------------------------------------");
   $display("");
   rc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_capability_attr),
      .check_reg_name("GLBL_ERROR_CAPABILITY"),
      .reg_addr(20'h0_4070),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_capability_update)
   );
   rc.write_value({64{1'b1}});
   rc.reset_on();
   rc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[GLBL_ERROR_CAPABILITY[15:12]][GLBL_ERROR_CAPABILITY[7:3]]),
      .reset_time($time)
   );
   rc.reset_off();
   rc.check();
   if (rc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Hard Reset Check                                                                |
   //----------------------------------------------------------------------------------
   hrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_capability_attr),
      .check_reg_name("GLBL_ERROR_CAPABILITY"),
      .reg_addr(20'h0_4070),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_capability_update)
   );
   hrc.write_value({64{1'b1}});
   hrc.reset_on();
   hrc.update_reset_value(
      .reset_value(testbench_top.dut.csr_reg[GLBL_ERROR_CAPABILITY[15:12]][GLBL_ERROR_CAPABILITY[7:3]]),
      .reset_time($time)
   );
   hrc.reset_off();
   hrc.check();
   if (hrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Function Check                                                                  |
   //----------------------------------------------------------------------------------
   wc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_capability_attr),
      .check_reg_name("GLBL_ERROR_CAPABILITY"),
      .reg_addr(20'h0_4070),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_capability_update)
   );
   wc.check();
   if (wc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Walking Ones/Zeros Test                                                         |
   //----------------------------------------------------------------------------------
   wwozc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_capability_attr),
      .check_reg_name("GLBL_ERROR_CAPABILITY"),
      .reg_addr(20'h0_4070),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_capability_update)
   );
   wwozc.check();
   if (wwozc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // Random Data Write Test                                                          |
   //----------------------------------------------------------------------------------
   wrc = new( .axi(axi), .pgn(pgn), 
      .check_reg_attr(testbench_top.dut.glbl_error_capability_attr),
      .check_reg_name("GLBL_ERROR_CAPABILITY"),
      .reg_addr(20'h0_4070),
      .reset_reg(testbench_top.dut.fme_csr_glbl_error_capability_reset),
      .update_reg(testbench_top.dut.fme_csr_glbl_error_capability_update)
   );
   wrc.check();
   if (wrc.fail()) pass = 1'b0;
   //----------------------------------------------------------------------------------
   // ---------------------------------------------------------------------------------
   // Collect stats from objects.
   // ---------------------------------------------------------------------------------
   num_reg_checks = wc.check_count;
   num_tr_used    = wc.tr_count;
   num_total_bit_errors = wc.total_bit_error_count;


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
   $display ("Number of transactors used..............: %0d", num_tr_used);
   $display ("Number of register checks performed.....: %0d", num_reg_checks);
   $display ("Total number of bit errors found in test: %0d", num_total_bit_errors);
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
