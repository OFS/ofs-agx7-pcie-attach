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
task test_csr;
   output logic result;
   logic [63:0] wr_data64;
   logic [63:0] rd_data64;
   logic [31:0] wr_data32_1;
   logic [31:0] wr_data32_2;
   logic [31:0] rd_data32;
   logic        error;
   logic [31:0] addr;
   logic [31:0] addr1;
   logic [31:0] addr2;
   logic [31:0] addr3;
   logic [31:0] addr4;
   reg [31:0]   counter = 0;
   begin
      
      print_test_header("uart_csr_test");
      // ******************************************
      // Just read PG_UART_DFH (register 63,000 offset 0
      // ******************************************
      addr = PG_UART_DFH;
      $display("T:%8d INFO: TEST_PROGRAM %m About to read address 0x%0X.", $time, addr);
      READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m READ64 of Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      
      
      // ******************************************
      // Just read PG_UART_DFH (register 63,000 offset 8
      // ******************************************
      addr = PG_UART_DFH + 32'h8;
      $display("T:%8d INFO: TEST_PROGRAM %m About to read address 0x%0X.", $time, addr);
      READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      
      // ******************************************
      // Just read PG_UART_DFH (register 63,000 offset 10
      // ******************************************
      addr = PG_UART_DFH + 32'h10;
      $display("T:%8d INFO: TEST_PROGRAM %m About to read address 0x%0X.", $time, addr);
      READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      
      // ******************************************
      // Just read PG_UART_DFH (register 63,000 offset 18
      // ******************************************
      addr = PG_UART_DFH + 32'h18;
      $display("T:%8d INFO: TEST_PROGRAM %m About to read address 0x%0X.", $time, addr);
      READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      
      #8us;      
      //$finish;
      $display("T:%8d INFO: TEST_PROGRAM %m This was the finish.", $time);
      
      
      // ******************************************
      $display("T:%8d INFO: TEST_PROGRAM %m Write and read the scratch register PG_UART_DFH (register 63,000 offser 0xF0", $time);
      // ******************************************
      addr = PG_UART_DFH + 32'hF0;
      wr_data64 = {$urandom, $urandom};
      $display("T:%8d INFO: %m About to write Adress 0x%0X with 0x%0X.",$time, addr, wr_data64);
      WRITE64(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data64);	
      $display("T:%8d INFO: %m Now we just write it, are just going to wait 8us for the heack of it.",$time, addr, wr_data64);
      #10us; 
      READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      if (rd_data64 != wr_data64) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data64, rd_data64);
         test_utils::incr_err_count();
      end
      
      #8us;
      
      wr_data32_1 = $urandom;
      $display("T:%8d INFO: TEST_PROGRAM %m Write 32 bits to addr %x with %x, BAR:%x", $time, addr, wr_data32_2, BAR);
      WRITE32(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data32_1);	
      $display("T:%8d INFO: TEST_PROGRAM %m First Write Done", $time);
      
      
      addr = PG_UART_DFH + 32'hF4;
      wr_data32_2 = $urandom;
      $display("T:%8d INFO: TEST_PROGRAM %m Write 32 bits to addr %x with %x, BAR:%x", $time, addr, wr_data32_2, BAR);
      WRITE32(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data32_2);	
      $display("T:%8d INFO: TEST_PROGRAM %m Second Write Done", $time);
      
      addr = PG_UART_DFH + 32'hF0;
      READ32(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data32, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ32 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data32);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      if (rd_data32 != wr_data32_1) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data32_1, rd_data32);
         test_utils::incr_err_count();
      end
      
      addr = PG_UART_DFH + 32'hF4;
      READ32(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data32, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ32 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data32);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      if (rd_data32 != wr_data32_2) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data32_2, rd_data32);
         test_utils::incr_err_count();
      end
      
      addr = PG_UART_DFH + 32'hF0;
      READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      if (rd_data64 != {wr_data32_2, wr_data32_1}) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, {wr_data32_2, wr_data32_1}, rd_data64);
         test_utils::incr_err_count();
      end
      
      #8us;
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m End of Task test_csr", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m Now read the first register of the vuart", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      
      
      for (addr=32'h63204;addr < 32'h63400;addr = addr + 32'h4) begin
         if (addr != 32'h63218) begin // For some reason 0x218 returns X's on bits [7:0] also address 0x200 returns X's on bits 8:0.
            READ32(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data32, error);
            $display("T:%8d INFO: TEST_PROGRAM %m READ32 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data32);
            if (error) begin
               $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
               test_utils::incr_err_count();
            end
         end
      end
      
      #7us;
      $display("T:%8d INFO: TEST_PROGRAM %m #####################################################################", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m ## BEGIN WRITING AND READING FROM the 8-BIT SCRATCH REGISTER 0x21C ##", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m #####################################################################", $time);
      addr = PG_UART_DFH + 32'h21C;
      repeat (10) begin
         wr_data32_1 = $urandom;
         wr_data32_1 = {24'h0, wr_data32_1[7:0]};
         $display("T:%8d INFO: TEST_PROGRAM %m #### WRITE 32 BITS TO ADDR %X WITH %X, BAR:%X ####", $time, addr, wr_data32_1, BAR);
         WRITE32(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data32_1);	
         $display("T:%8d INFO: TEST_PROGRAM %m Write to 0x%X Done", $time, addr);
         
         READ32(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data32, error);
         $display("T:%8d INFO: TEST_PROGRAM %m READ32 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data32);
         if (error) begin
            $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
            test_utils::incr_err_count();
         end
         if (wr_data32_1[7:0] != rd_data32[7:0]) begin
            $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data32_1, rd_data32);
            test_utils::incr_err_count();
         end
      end // repeat (10)
      
      addr1 = PG_UART_DFH + 32'h21c;
      addr2 = PG_UART_DFH + 32'h0f0;
      addr3 = PG_UART_DFH + 32'h0f0;
      #20us;
      $display("T:%8d INFO: TEST_PROGRAM %m #####################################################################", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m NOW DO A LOT OF WRITES AND WATCH FOR AN OVERFLOW.", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m #####################################################################", $time);
      fork
         begin         
            repeat (100) begin
               wr_data32_1 = $urandom;
               wr_data32_1 = {24'h0, wr_data32_1[7:0]};
               counter = counter + 32'h1;
               $display("T:%8d INFO: TEST_PROGRAM %m 1.### WRITE 8 BITS TO ADDR %X WITH %X, BAR:%X counter:%d ####", $time, addr1, wr_data32_1, BAR, counter);
               WRITE32(ADDR32, addr1, BAR, 1'b0, 0, 0, wr_data32_1);	
            end
         end
         begin
            repeat (100) begin
               wr_data64 = {$urandom, $urandom};
               counter = counter + 32'h1;
               $display("T:%8d INFO: TEST_PROGRAM %m 2.### WRITE 64 BITS TO ADDR %X WITH %X, BAR:%X counter:%d ####", $time, addr2, wr_data64, BAR, counter);
               WRITE64(ADDR32, addr2, BAR, 1'b0, 0, 0, wr_data64);	
            end
         end
         begin
            repeat (100) begin
               wr_data32_2 = $urandom;
               counter = counter + 32'h1;
               $display("T:%8d INFO: TEST_PROGRAM %m 3.### WRITE 32 BITS TO ADDR %X WITH %X, BAR:%X counter:%d ####", $time, addr3, wr_data32_2, BAR, counter);
               WRITE32(ADDR32, addr3, BAR, 1'b0, 0, 0, wr_data32_2);	
            end
         end
      join
      

      // ******************************************
      $display("T:%8d INFO: TEST_PROGRAM %m Check that we can still read and rwite data", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m Write and read the scratch register PG_UART_DFH (register 63,000 offser 0xF0", $time);
      // ******************************************
      addr = PG_UART_DFH + 32'hF0;
      wr_data64 = {$urandom, $urandom};
      $display("T:%8d INFO: %m About to write Adress 0x%0X with 0x%0X.",$time, addr, wr_data64);
      WRITE64(ADDR32, addr, BAR, 1'b0, 0, 0, wr_data64);	
      $display("T:%8d INFO: %m Now we just write it, are just going to wait 8us for the heack of it.",$time, addr, wr_data64);
      #10us; 
      READ64(ADDR32, addr, BAR, 1'b0, 0, 0, rd_data64, error);
      $display("T:%8d INFO: TEST_PROGRAM %m READ64 of Address 0x%0X produced 0x%0X.", $time, addr, rd_data64);
      if (error) begin
         $display("T:%8d ERROR: %m Reading Address 0x%0X produced an error",$time, addr);
         test_utils::incr_err_count();
      end
      if (rd_data64 != wr_data64) begin
         $display("T:%8d ERROR: TEST_PROGRAM %m addr:%X, EXPECTED:%X RECEIVED:%X", $time, addr, wr_data64, rd_data64);
         test_utils::incr_err_count();
      end
      




      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m End End End End End", $time);
      $display("T:%8d INFO: TEST_PROGRAM %m *******************************", $time);
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
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic        valid_csr_region;
   begin
      test_csr   (test_result);
   end
endtask
