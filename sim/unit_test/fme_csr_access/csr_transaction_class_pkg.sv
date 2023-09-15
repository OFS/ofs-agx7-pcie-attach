// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   CSR Transaction Class and Test/Check Class Package <<<<<<<<<<<<<<<<<<<<<<
//
//   This file provides definitions for the transaction and test/check classes 
//   used as transaction and test objects during simulation.  Included is an 
//   abstract base class for the transaction classes to help create polymorphic 
//   objects in the usable derived classes.
//
//   The test/check classes also have an abstract base class and may be made 
//   polymorphic if needed, but currently there is only one derived class.
//
//   Also included in this package are some simple parameters and classes to be
//   used as utilities and data structures by the larger classes.
//
//-----------------------------------------------------------------------------

`ifndef __CSR_TRANSACTION_CLASS_PKG__
`define __CSR_TRANSACTION_CLASS_PKG__

package csr_transaction_class_pkg; 

import ofs_csr_pkg::*;
import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;


//------------------------------------------------------------------------------
// Parameter and Enum Definitions for CSRs.
//------------------------------------------------------------------------------
parameter CSR_REG_WIDTH  = 64;
parameter CSR_ADDR_WIDTH = 20;
parameter CSR_FEATURE_RANGE = 32;
parameter CSR_FEATURE_NUM = 16;

typedef enum logic [1:0] {
   RESET_N     = 2'b00,
   PWR_GOOD_N  = 2'b01,
   READ        = 2'b10,
   WRITE       = 2'b11
} transactor_type_t;

//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Base Classes: RegError, RegCheck
//------------------------------------------------------------------------------
// These are simple logging objects for the test classes that follow.
//------------------------------------------------------------------------------
class RegError;
   logic [19:0] error_addr;
   logic [63:0] reg_read;
   logic [63:0] reg_expected;
   resp_t       rd_resp;
   resp_t       wr_resp;
   logic [6:0]  rd_id;
   logic [6:0]  wr_id;
   logic        error_detected;
   int          error_count;
   logic        reg_mismatch;
   logic        reg_has_x;
   logic        reg_read_x;
   logic        resp_wrong;
   logic        unused_wrong;
   string       error_msgs[$];
   logic        valid_addr;
   time         error_time;


   function new();
      this.error_addr     = {20{1'b0}};
      this.reg_read       = {64{1'b0}};
      this.reg_expected   = {64{1'b0}};
      this.rd_resp        = RESP_OKAY;
      this.wr_resp        = RESP_OKAY;
      this.rd_id          = {7{1'b0}};
      this.wr_id          = {7{1'b0}};
      this.error_detected = 1'b0;
      this.error_count    = 0;
      this.reg_mismatch   = 1'b0;
      this.reg_has_x      = 1'b0;
      this.reg_read_x     = 1'b0;
      this.resp_wrong     = 1'b0;
      this.unused_wrong   = 1'b0;
      this.error_msgs.delete();
      this.valid_addr     = 1'b0;
      this.error_time     = $time;
   endfunction


   function clear();
      error_addr     = {20{1'b0}};
      reg_read       = {64{1'b0}};
      reg_expected   = {64{1'b0}};
      rd_resp        = RESP_OKAY;
      wr_resp        = RESP_OKAY;
      rd_id          = {7{1'b0}};
      wr_id          = {7{1'b0}};
      error_detected = 1'b0;
      error_count    = 0;
      reg_mismatch   = 1'b0;
      reg_has_x      = 1'b0;
      reg_read_x     = 1'b0;
      resp_wrong     = 1'b0;
      unused_wrong   = 1'b0;
      error_msgs.delete();
      valid_addr     = 1'b0;
      error_time     = $time;
   endfunction

endclass: RegError


class RegCheck;
   logic [19:0] test_addr;
   logic [63:0] rd_value;
   logic [63:0] value;
   resp_t       rd_resp;
   resp_t       wr_resp;
   logic [6:0]  rd_id;
   logic [6:0]  wr_id;
   logic        valid_addr;
   time         check_time;


   function new();
      this.test_addr  = {20{1'b0}};
      this.rd_value   = {64{1'b0}};
      this.value      = {64{1'b0}};
      this.rd_resp    = RESP_OKAY;
      this.wr_resp    = RESP_OKAY;
      this.rd_id      = {7{1'b0}};
      this.wr_id      = {7{1'b0}};
      this.valid_addr = 1'b0;
      this.check_time = $time;
   endfunction


   function clear();
      test_addr  = {20{1'b0}};
      rd_value   = {64{1'b0}};
      value      = {64{1'b0}};
      rd_resp    = RESP_OKAY;
      wr_resp    = RESP_OKAY;
      rd_id      = {7{1'b0}};
      wr_id      = {7{1'b0}};
      valid_addr = 1'b0;
      check_time = $time;
   endfunction

endclass: RegCheck


//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Base Class: RandData
//------------------------------------------------------------------------------
// This is a simple random data object used by the test classes requiring 
// random data.
//------------------------------------------------------------------------------
class RandData;
   rand logic [63:0] data;

   function new();
      this.data = {64{1'b0}};
   endfunction

endclass: RandData


//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Base Class: RandRegHit
//------------------------------------------------------------------------------
// This is a simple random data object used by the test classes that provides
// a random-cyclic address and access type to be used to thoroughly test the 
// access logic of the Port CSRs.
//------------------------------------------------------------------------------
class RandRegHit;
   logic [19:0] axi_addr;
   csr_access_type_t access_type;

   typedef struct packed {
      logic [19:3] top_addr;
      csr_access_type_t raccess_type;
   } reg_hit_t;

   randc reg_hit_t reg_hit;
   static reg_hit_t reg_hits[$];

   constraint c_raccess_type {
      reg_hit.raccess_type inside {LOWER32, UPPER32, FULL64};
      reg_hit.top_addr inside {
         [17'b0000_0000_0000_0000_0:17'b0000_0000_0000_0110_1],    // Address Range: 20'h0_0000 - 20'h0_0068 : 14 registers
         [17'b0000_0001_0000_0000_0:17'b0000_0001_0000_0010_0],    // Address Range: 20'h0_1000 - 20'h0_1020 :  5 registers
         [17'b0000_0011_0000_0000_0:17'b0000_0011_0000_0011_0],    // Address Range: 20'h0_3000 - 20'h0_3030 :  7 registers
         [17'b0000_0100_0000_0000_0:17'b0000_0100_0000_0111_0],    // Address Range: 20'h0_4000 - 20'h0_4070 : 15 registers
         [17'b0000_0101_0000_0000_0:17'b0000_0101_0000_1011_0],    // Address Range: 20'h0_5000 - 20'h0_50B0 : 23 registers
         [17'b0000_1001_0000_0000_0:17'b0000_1001_0000_0111_1],    // Address Range: 20'h0_9000 - 20'h0_9078 : 16 registers
         [17'b0000_1010_0000_0000_0:17'b0000_1010_0000_0000_1]     // Address Range: 20'h0_A000 - 20'h0_A008 :  2 registers
      };
      !(reg_hit inside {reg_hits});
   }


   function new();
      axi_addr = '0;
   endfunction


   function void post_randomize();
      access_type = reg_hit.raccess_type;
      reg_hits.push_back(reg_hit);
      if (reg_hits.size() >= 246)  // 82 Registers x 3 accesses = 246 unique combinations.
      begin
         reg_hits.delete(); // Clear the queue and start over cycle.
      end
      if (access_type == LOWER32)
      begin
         axi_addr = {reg_hit.top_addr,3'b000};
      end
      else
      begin
         if (access_type == UPPER32)
         begin
            axi_addr = {reg_hit.top_addr,3'b100};
         end
         else
         begin
            axi_addr = {reg_hit.top_addr,3'b000};
         end
      end
   endfunction

endclass: RandRegHit


//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Base Class: RandSpaceHit
//------------------------------------------------------------------------------
// This is a simple random data object used by the test classes that provides
// a basic random address and access type to be used to sample-test the access 
// logic of the Port CSR address space.
//------------------------------------------------------------------------------
class RandSpaceHit;
   logic [19:0] axi_addr;
   csr_access_type_t access_type;

   typedef struct packed {
      logic [19:3] top_addr;
      csr_access_type_t raccess_type;
   } reg_hit_t;

   rand reg_hit_t reg_hit;
   static reg_hit_t reg_hits[$];

   constraint c_raccess_type {
      reg_hit.raccess_type inside {LOWER32, UPPER32, FULL64};
      reg_hit.top_addr inside {[17'b0000_0000_0000_0000_0:17'b1111_1111_1111_1111_1]};
   }


   function new();
      axi_addr = '0;
   endfunction


   function void post_randomize();
      access_type = reg_hit.raccess_type;
      if (access_type == LOWER32)
      begin
         axi_addr = {reg_hit.top_addr,3'b000};
      end
      else
      begin
         if (access_type == UPPER32)
         begin
            axi_addr = {reg_hit.top_addr,3'b100};
         end
         else
         begin
            axi_addr = {reg_hit.top_addr,3'b000};
         end
      end
   endfunction

endclass: RandSpaceHit

//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Base Class: Transaction
//------------------------------------------------------------------------------
// All Transactions are designed to use the abstract base class "Transaction".
// The method "run()" is included in base class as a pure virtual function so 
// that we can use polymorphism to put transactions of different types into a
// single queue and process them all the same way using base class handles.
//------------------------------------------------------------------------------
virtual class Transaction; // Abstract Base Class
   virtual ofs_fim_pwrgoodn_if.master pgn;
   virtual ofs_fim_axi_mmio_if #(
      .AWID_WIDTH(MMIO_TID_WIDTH),
      .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
      .WDATA_WIDTH(MMIO_DATA_WIDTH),
      .ARID_WIDTH(MMIO_TID_WIDTH),
      .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
      .RDATA_WIDTH(MMIO_DATA_WIDTH)
   ).master axi;
   transactor_type_t transactor;
   static logic [6:0] count = 6'h10;
   static int t_count = 0;
   logic [6:0] id;
   int delay;

   // Constructor
   function new(  
      virtual ofs_fim_axi_mmio_if #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi,
      virtual ofs_fim_pwrgoodn_if.master pgn
   );
      id = '0;
      delay = 0;
      t_count++;
      this.axi = axi;
      this.pgn = pgn;
   endfunction

   // Pure virtual functions for polymorphism.
   pure virtual function void set_delay(int delay_value);
   pure virtual task run();
endclass: Transaction


//------------------------------------------------------------------------------
// Derived Class: ResetTransaction
// Inheritance..: Transaction
//------------------------------------------------------------------------------
// This class asserts the soft reset "rst_n" for two clocks in the AXI MMIO 
// interface.  The length of the reset can be changed using the "set_delay"
// method function.
//------------------------------------------------------------------------------
class ResetTransaction extends Transaction;

   // Constructor
   function new(
      virtual ofs_fim_axi_mmio_if #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi,
      virtual ofs_fim_pwrgoodn_if.master pgn
   );
      super.new(.axi(axi), .pgn(pgn));
      this.delay = 2;
      this.transactor = RESET_N;
   endfunction


   virtual function void set_delay(int delay_value);
      delay = delay_value;
   endfunction


   virtual task run();
      @(posedge axi.clk);
      #100ps axi.rst_n = 1'b0;
      repeat (delay) @(posedge axi.clk);
      #100ps axi.rst_n = 1'b1;
   endtask

endclass: ResetTransaction


//------------------------------------------------------------------------------
// Derived Class: PwrResetTransaction
// Inheritance..: Transaction
//------------------------------------------------------------------------------
// This class asserts the hard reset "rst_n" for two clocks in the PwrGoodN 
// interface.  The length of the reset can be changed using the "set_delay"
// method function.
//------------------------------------------------------------------------------
class PwrResetTransaction extends Transaction;

   // Constructor
   function new(
      virtual ofs_fim_axi_mmio_if  #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi, 
      virtual ofs_fim_pwrgoodn_if.master pgn
   );
      super.new(.axi(axi), .pgn(pgn));
      this.delay = 2;
      this.transactor = PWR_GOOD_N;
   endfunction


   virtual function void set_delay(int delay_value);
      delay = delay_value;
   endfunction


   virtual task run();
      @(posedge axi.clk);
      #100ps pgn.pwr_good_n = 1'b0;
      axi.rst_n = 1'b0;
      repeat (delay) @(posedge axi.clk);
      #100ps pgn.pwr_good_n = 1'b1;
      axi.rst_n = 1'b1;
   endtask

endclass: PwrResetTransaction


//------------------------------------------------------------------------------
// Derived Class: ReadTransaction
// Inheritance..: Transaction
//------------------------------------------------------------------------------
// This class performs an AXI read based on the read address and access type.
// The access type is enum defined in "ofs_csr_pkg.sv".  The values are repeated
// here for convenience:
//   typedef enum logic [1:0] {
//      NONE    = 2'b00,
//      LOWER32 = 2'b01,
//      UPPER32 = 2'b10,
//      FULL64  = 2'b11
//   } csr_access_type_t
//------------------------------------------------------------------------------
class ReadTransaction extends Transaction;
   logic [19:0] rd_addr;
   logic [63:0] rd_data;
   logic [6:0]  rd_id;
   resp_t      rd_resp;
   csr_access_type_t access;

   // Constructor
   function new(
      virtual ofs_fim_axi_mmio_if  #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi, 
      virtual ofs_fim_pwrgoodn_if.master pgn, 
      input logic [19:0] rd_addr, 
      input csr_access_type_t access
   );
      super.new(.axi(axi), .pgn(pgn));
      id = count++;
      this.transactor = READ;
      this.rd_addr = rd_addr;
      this.access  = access;
   endfunction


   virtual function void set_delay(int delay_value);
      delay = delay_value;
   endfunction


   virtual task run();
      $timeformat(-9, 2, " ns");
      @(posedge axi.clk);
      #100ps;
      axi.arid = id;
      axi.arlen = 8'b1;
      if (access == FULL64)
      begin
         axi.arsize = 3'b011;
         rd_addr[2:0] = 3'b000;
      end
      else
      begin
         if (access == UPPER32)
         begin
            axi.arsize = 3'b010;
            rd_addr[2:0] = 3'b100;
         end
         else
         begin
            if (access == LOWER32)
            begin
               axi.arsize = 3'b010;
               rd_addr[2:0] = 3'b000;
            end
            else
            begin
               axi.arsize = 3'b000;
               rd_addr[2:0] = 3'b000;
            end
         end
      end
      axi.araddr = rd_addr;
      axi.arburst = 2'b01;
      axi.arvalid  = 1'b1;
      wait (axi.arready === 1'b1);
      @(posedge axi.clk);
      #100ps axi.arvalid   = 1'b0;
      axi.rready = 1'b1;
      wait (axi.rvalid === 1'b1)
      #100ps rd_data = axi.rdata;
      rd_id = axi.rid;
      //rd_resp = axi.rresp;
      $cast(rd_resp, axi.rresp);
      wait (axi.rvalid === 1'b0)
      #100ps axi.rready = 1'b0;
      if (access == FULL64)
      begin
         $display (     "Read  64-bit register @ address:%H_%H got  data:%H_%H_%H_%H with response:%s for transaction id:%H:%H at time:%0t.", rd_addr[19:16], rd_addr[15:0], rd_data[63:48], rd_data[47:32], rd_data[31:16], rd_data[15:0], rd_resp.name, id, rd_id, $time);
      end
      else
      begin
         if (access == UPPER32)
         begin
            $display (     "Read  upper 32-bit register @ address:%H_%H got  data:%H_%H with response:%s for transaction id:%H:%H at time:%0t.", rd_addr[19:16], rd_addr[15:0], rd_data[63:48], rd_data[47:32], rd_resp.name, id, rd_id, $time);
         end
         else
         begin
            if (access == LOWER32)
            begin
               $display (     "Read  lower 32-bit register @ address:%H_%H got  data:%H_%H with response:%s for transaction id:%H:%H at time:%0t", rd_addr[19:16], rd_addr[15:0], rd_data[31:16], rd_data[15:0], rd_resp.name, id, rd_id, $time);
            end
            else
            begin
            end
         end
      end
      @(posedge axi.clk);
   endtask

endclass: ReadTransaction


//------------------------------------------------------------------------------
// Derived Class: ReadTransactionSilent
// Inheritance..: ReadTransaction
//------------------------------------------------------------------------------
// This class performs an AXI read based on the read address and access type.
// The access type is enum defined in "ofs_csr_pkg.sv".  The values are repeated
// here for convenience:
//   typedef enum logic [1:0] {
//      NONE    = 2'b00,
//      LOWER32 = 2'b01,
//      UPPER32 = 2'b10,
//      FULL64  = 2'b11
//   } csr_access_type_t
//
// This class is the same as ReadTransaction -- it just does not have the display
// messages in the "run" method so that many of these reads may be performed 
// in loops without flooding the message output for normal operations.
//------------------------------------------------------------------------------
class ReadTransactionSilent extends ReadTransaction;

   // Constructor
   function new(
      virtual ofs_fim_axi_mmio_if  #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi, 
      virtual ofs_fim_pwrgoodn_if.master pgn, 
      input logic [19:0] rd_addr, 
      input csr_access_type_t access
   );
      super.new(.axi(axi), .pgn(pgn), .rd_addr(rd_addr), .access(access));
   endfunction


   virtual task run();
      $timeformat(-9, 2, " ns");
      @(posedge axi.clk);
      #100ps;
      axi.arid = id;
      axi.arlen = 8'b1;
      if (access == FULL64)
      begin
         axi.arsize = 3'b011;
         rd_addr[2:0] = 3'b000;
      end
      else
      begin
         if (access == UPPER32)
         begin
            axi.arsize = 3'b010;
            rd_addr[2:0] = 3'b100;
         end
         else
         begin
            if (access == LOWER32)
            begin
               axi.arsize = 3'b010;
               rd_addr[2:0] = 3'b000;
            end
            else
            begin
               axi.arsize = 3'b000;
               rd_addr[2:0] = 3'b000;
            end
         end
      end
      axi.araddr = rd_addr;
      axi.arburst = 2'b01;
      axi.arvalid  = 1'b1;
      wait (axi.arready === 1'b1);
      @(posedge axi.clk);
      #100ps axi.arvalid   = 1'b0;
      axi.rready = 1'b1;
      wait (axi.rvalid === 1'b1)
      #100ps rd_data = axi.rdata;
      rd_id = axi.rid;
      //rd_resp = axi.rresp;
      $cast(rd_resp, axi.rresp);
      wait (axi.rvalid === 1'b0)
      #100ps axi.rready = 1'b0;
      @(posedge axi.clk);
   endtask

endclass: ReadTransactionSilent


//------------------------------------------------------------------------------
// Derived Class: WriteTransaction
// Inheritance..: Transaction
//------------------------------------------------------------------------------
// This class performs an AXI write based on the write address, write data, and
// access type.
//
// The access type is enum defined in "ofs_csr_pkg.sv".  The values are repeated
// here for convenience:
//   typedef enum logic [1:0] {
//      NONE    = 2'b00,
//      LOWER32 = 2'b01,
//      UPPER32 = 2'b10,
//      FULL64  = 2'b11
//   } csr_access_type_t
//------------------------------------------------------------------------------
class WriteTransaction extends Transaction;
   logic [19:0] wr_addr;
   logic [63:0] wr_data;
   logic [6:0]  wr_id;
   resp_t       wr_resp;
   csr_access_type_t access;

   // Constructor
   function new(
      virtual ofs_fim_axi_mmio_if #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi, 
      virtual ofs_fim_pwrgoodn_if.master pgn,
      input logic [19:0] wr_addr, 
      input logic [63:0] wr_data, 
      input csr_access_type_t access
   );
      super.new(.axi(axi), .pgn(pgn));
      id = count++;
      this.transactor = WRITE;
      this.wr_addr = wr_addr;
      this.wr_data = wr_data;
      this.access = access;
   endfunction


   virtual function void set_delay(int delay_value);
      delay = delay_value;
   endfunction


   virtual task run();
      @(posedge axi.clk);
      #100ps;
      axi.awid = id;
      axi.awlen = 8'b1;
      if (access == FULL64)
      begin
         axi.awsize = 3'b011;
         axi.wstrb = 8'hFF;
         wr_addr[2:0] = 3'b000;
      end
      else
      begin
         if (access == UPPER32)
         begin
            axi.awsize = 3'b010;
            axi.wstrb = 8'hF0;
            wr_addr[2:0] = 3'b100;
         end
         else
         begin
            if (access == LOWER32)
            begin
               axi.awsize = 3'b010;
               axi.wstrb = 8'h0F;
               wr_addr[2:0] = 3'b000;
            end
            else
            begin
               axi.awsize = 3'b000;
               axi.wstrb = 8'h00;
               wr_addr[2:0] = 3'b000;
            end
         end
      end
      axi.awaddr = wr_addr;
      axi.awburst = 2'b01;
      axi.awvalid  = 1'b1;
      axi.wdata = wr_data;
      axi.wlast = 1'b1;
      axi.wvalid  = 1'b1;
      wait ((axi.awready === 1'b1) || (axi.wready === 1'b1));
      @(posedge axi.clk);
      if ((axi.awready === 1'b1) && (axi.wready === 1'b1))
      begin
         #100ps axi.awvalid   = 1'b0;
         axi.wvalid = 1'b0;
         axi.wlast = 1'b0;
      end
      else
      begin
         if ((axi.awready === 1'b1) && (axi.wready === 1'b0))
         begin
            #100ps axi.awvalid   = 1'b0;
            wait (axi.wready === 1'b1);
            @(posedge axi.clk);
            #100ps axi.wvalid = 1'b0;
            axi.wlast = 1'b0;
         end
         else
         begin
            if ((axi.awready === 1'b0) && (axi.wready === 1'b1))
            begin
               #100ps axi.wvalid = 1'b0;
               wait (axi.awready === 1'b1);
               @(posedge axi.clk);
               #100ps axi.awvalid   = 1'b0;
               axi.wlast = 1'b0;
            end
         end
      end
      axi.bready = 1'b1;
      wait (axi.bvalid === 1'b1);
      #100ps wr_id = axi.bid;
      //wr_resp = axi.bresp;
      $cast(wr_resp, axi.bresp);
      @(posedge axi.clk);
      #100ps axi.bready = 1'b0;
      @(posedge axi.clk);
      if (access == FULL64)
      begin
         $display (     "Write 64-bit register @ address:%H_%H with data:%H_%H_%H_%H got  response:%s for transaction id:%H:%H at time:%0t.", wr_addr[19:16], wr_addr[15:0], wr_data[63:48], wr_data[47:32], wr_data[31:16], wr_data[15:0], wr_resp.name, id, wr_id, $time);
      end
      else
      begin
         if (access == UPPER32)
         begin
            $display (     "Write upper 32-bit register @ address:%H_%H with data:%H_%H got  response:%s for transaction id:%H:%H at time:%0t.", wr_addr[19:16], wr_addr[15:0], wr_data[63:48], wr_data[47:32], wr_resp.name, id, wr_id, $time);
         end
         else
         begin
            if (access == LOWER32)
            begin
               $display (     "Write lower 32-bit register @ address:%H_%H with data:%H_%H got  response:%s for transaction id:%H:%H at time:%0t.", wr_addr[19:16], wr_addr[15:0], wr_data[31:16], wr_data[15:0], wr_resp.name, id, wr_id, $time);
            end
            else
            begin
            end
         end
      end
      @(posedge axi.clk);
   endtask

endclass: WriteTransaction


//------------------------------------------------------------------------------
// Derived Class: WriteTransactionSilent
// Inheritance..: WriteTransaction
//------------------------------------------------------------------------------
// This class performs an AXI write based on the write address, write data, and
// access type.
//
// The access type is enum defined in "ofs_csr_pkg.sv".  The values are repeated
// here for convenience:
//   typedef enum logic [1:0] {
//      NONE    = 2'b00,
//      LOWER32 = 2'b01,
//      UPPER32 = 2'b10,
//      FULL64  = 2'b11
//   } csr_access_type_t
//
// This class is the same as WriteTransaction -- it just does not have the display
// messages in the "run" method so that many of these reads may be performed 
// in loops without flooding the message output for normal operations.
//------------------------------------------------------------------------------
class WriteTransactionSilent extends WriteTransaction;

   // Constructor
   function new(
      virtual ofs_fim_axi_mmio_if #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi, 
      virtual ofs_fim_pwrgoodn_if.master pgn,
      input logic [19:0] wr_addr, 
      input logic [63:0] wr_data, 
      input csr_access_type_t access
   );
      super.new(.axi(axi), .pgn(pgn), .wr_addr(wr_addr), .wr_data(wr_data), .access(access));
   endfunction


   virtual task run();
      @(posedge axi.clk);
      #100ps;
      axi.awid = id;
      axi.awlen = 8'b1;
      if (access == FULL64)
      begin
         axi.awsize = 3'b011;
         axi.wstrb = 8'hFF;
         wr_addr[2:0] = 3'b000;
      end
      else
      begin
         if (access == UPPER32)
         begin
            axi.awsize = 3'b010;
            axi.wstrb = 8'hF0;
            wr_addr[2:0] = 3'b100;
         end
         else
         begin
            if (access == LOWER32)
            begin
               axi.awsize = 3'b010;
               axi.wstrb = 8'h0F;
               wr_addr[2:0] = 3'b000;
            end
            else
            begin
               axi.awsize = 3'b000;
               axi.wstrb = 8'h00;
               wr_addr[2:0] = 3'b000;
            end
         end
      end
      axi.awaddr = wr_addr;
      axi.awburst = 2'b01;
      axi.awvalid  = 1'b1;
      axi.wdata = wr_data;
      axi.wlast = 1'b1;
      axi.wvalid  = 1'b1;
      wait ((axi.awready === 1'b1) || (axi.wready === 1'b1));
      @(posedge axi.clk);
      if ((axi.awready === 1'b1) && (axi.wready === 1'b1))
      begin
         #100ps axi.awvalid   = 1'b0;
         axi.wvalid = 1'b0;
         axi.wlast = 1'b0;
      end
      else
      begin
         if ((axi.awready === 1'b1) && (axi.wready === 1'b0))
         begin
            #100ps axi.awvalid   = 1'b0;
            wait (axi.wready === 1'b1);
            @(posedge axi.clk);
            #100ps axi.wvalid = 1'b0;
            axi.wlast = 1'b0;
         end
         else
         begin
            if ((axi.awready === 1'b0) && (axi.wready === 1'b1))
            begin
               #100ps axi.wvalid = 1'b0;
               wait (axi.awready === 1'b1);
               @(posedge axi.clk);
               #100ps axi.awvalid   = 1'b0;
               axi.wlast = 1'b0;
            end
         end
      end
      axi.bready = 1'b1;
      wait (axi.bvalid === 1'b1)
      #100ps wr_id = axi.bid;
      //wr_resp = axi.bresp;
      $cast(wr_resp, axi.bresp);
      @(posedge axi.clk);
      #100ps axi.bready = 1'b0;
      @(posedge axi.clk);
   endtask

endclass: WriteTransactionSilent


//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Base Class: RegTest
//------------------------------------------------------------------------------
// All register checking tests to use the abstract base class "RegTest".
// This base class implements all of the core elements of the check/test classes
// and sets forward a foundation for polymorphism if it is desired later.
//
// Each of the following derived classes performs a register test or enables
// a type of register test.
//------------------------------------------------------------------------------
virtual class RegTest; // Abstract Base Class

   virtual ofs_fim_axi_mmio_if #(
      .AWID_WIDTH(MMIO_TID_WIDTH),
      .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
      .WDATA_WIDTH(MMIO_DATA_WIDTH),
      .ARID_WIDTH(MMIO_TID_WIDTH),
      .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
      .RDATA_WIDTH(MMIO_DATA_WIDTH)
   ).master axi;
   virtual ofs_fim_pwrgoodn_if.master pgn;
   string check_reg_name;
   logic [19:0] reg_addr;
   csr_access_type_t access_type;
   Transaction tr;
   ResetTransaction rt;
   PwrResetTransaction prt;
   ReadTransaction rdt;
   ReadTransactionSilent rdst;
   WriteTransaction wrt;
   WriteTransactionSilent wrst;
   static int check_count = 0;
   static int total_access_error_count = 0;
   int tr_count;

   // Constructor
   function new(
      virtual ofs_fim_axi_mmio_if  #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi, 
      virtual ofs_fim_pwrgoodn_if.master pgn, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      input csr_access_type_t access_type
   );
      this.axi                      = axi;
      this.pgn                      = pgn;
      this.check_reg_name           = check_reg_name;
      this.reg_addr                 = reg_addr;
      this.access_type              = access_type;
      check_count++;
   endfunction


   // Pure virtual functions to support polymorphism if this is desired later.
   pure virtual task run();
   pure virtual function void  check();
   pure virtual function logic pass();
   pure virtual function logic fail();
   pure virtual function void  report_error_queue();

endclass: RegTest


//------------------------------------------------------------------------------
// Derived Class: RandomTest
// Inheritance..: RegTest
//------------------------------------------------------------------------------
// This class performs a set of random data read/writes to random addresses 
// using random access types: (lower 32-bits, upper 32-bits, and full 64-bits).
//
// The things checked in this test are:
//   1.) Correct AXI read responses for the respective address.
//   2.) Correct AXI write response for the respective address.
//   3.) Correctly read data as compared to the source register contents for the
//       respective bus access type.  If an empty location is read, the data
//       values are tested to make sure they are all zero.
//
//------------------------------------------------------------------------------
class RandomTest extends RegTest;
   logic [19:0] wr_addr;
   logic [63:0] wr_data;
   logic [6:0]  wr_id;
   resp_t       wr_resp;
   logic [19:0] rd_addr;
   logic [63:0] rd_data;
   logic [6:0]  rd_id;
   resp_t       rd_resp;
   RegError reg_error;
   RegCheck reg_check;
   RandData rand_data;
   logic valid_addr;

   
   // Constructor
   function new(
      virtual ofs_fim_axi_mmio_if #(
         .AWID_WIDTH(MMIO_TID_WIDTH),
         .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
         .WDATA_WIDTH(MMIO_DATA_WIDTH),
         .ARID_WIDTH(MMIO_TID_WIDTH),
         .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
         .RDATA_WIDTH(MMIO_DATA_WIDTH)
      ).master axi, 
      virtual ofs_fim_pwrgoodn_if.master pgn, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      input csr_access_type_t access_type,
      input logic        valid_addr
   );
      super.new(
         .axi(axi),
         .pgn(pgn),
         .check_reg_name(check_reg_name),
         .reg_addr(reg_addr),
         .access_type(access_type)
      );
      this.wr_addr = reg_addr;
      this.rd_addr = reg_addr;
      this.valid_addr = valid_addr;
   endfunction


   virtual task run();
      //--------------------------------------------------
      // Perform random pattern test.
      //--------------------------------------------------
      rand_data = new();
      rand_data.randomize();
      reg_check = new();
      reg_check.test_addr = rd_addr;
      reg_check.valid_addr = valid_addr;
      rdt = new(
         .axi(axi),
         .pgn(pgn),
         .rd_addr(rd_addr),
         .access(access_type)
      );
      rdt.run();
      reg_check.rd_value = rdt.rd_data;
      wr_data = rand_data.data;
      wrt = new(
         .axi(axi),
         .pgn(pgn),
         .wr_addr(wr_addr),
         .wr_data(wr_data),
         .access(access_type)
      );
      wrt.run();
      reg_check.wr_resp = wrt.wr_resp;
      reg_check.wr_id   = wrt.wr_id;
      rdt = new(
         .axi(axi),
         .pgn(pgn),
         .rd_addr(rd_addr),
         .access(access_type)
      );
      rdt.run();
      reg_check.check_time = $time;
      reg_check.rd_value   = rdt.rd_data;
      reg_check.rd_resp = rdt.rd_resp;
      reg_check.rd_id   = rdt.rd_id;
      tr_count = wrt.t_count;
   endtask


   virtual function void get_raw_register( // Sample the source CSR register to make sure read value matches contents.
      input logic [63:0] csr_value
   );
      reg_check.value = csr_value;
      //-------------------------------------------------------------------------------------------------------
      // The following commented-out lines help to verify the error conditions logic.
      //-------------------------------------------------------------------------------------------------------
      //if ((reg_check.test_addr & 20'hF_FFF8) == 20'h0_3008)  // Test to ensure testbench catches data bit error in register value.
         //reg_check.value = csr_value ^ 64'h0000_0001_0000_0000;
      //if ((reg_check.test_addr & 20'hF_FFF8) == 20'h0_0020)  // Test to ensure testbench catches data bit error to unsed space.
         //reg_check.rd_value = 64'h0000_0001_0000_0000;
      //if ((reg_check.test_addr & 20'hF_FFF8) == 20'h0_0020)  // Test to ensure testbench catches invalid region returning read response okay.
         //reg_check.rd_resp = RESP_OKAY;
      //if ((reg_check.test_addr & 20'hF_FFF8) == 20'h0_0020)  // Test to ensure testbench catches invalid region returning write response okay.
         //reg_check.wr_resp = RESP_OKAY;
      //if ((reg_check.test_addr & 20'hF_FFF8) == 20'h0_0010)  // Test to ensure testbench catches valid region returning read response error.
         //reg_check.rd_resp = RESP_SLVERR;
      //if ((reg_check.test_addr & 20'hF_FFF8) == 20'h0_0010)  // Test to ensure testbench catches valid region returning write response error.
         //reg_check.wr_resp = RESP_SLVERR;
   endfunction


//------------------------------------------------------------------------------
// Check the results and print out any error messages contained in the error
// queue.
//------------------------------------------------------------------------------
   virtual function void check();
      reg_error = access_check(
         .check(reg_check)
      );
      total_access_error_count = total_access_error_count + reg_error.error_count;
      report_error_queue();
   endfunction



//------------------------------------------------------------------------------
// Check the test results and generate any relevent error messages.
//------------------------------------------------------------------------------
   virtual function RegError access_check(
      input RegCheck check
   );
      string error_message;
      RegError error;
      logic    found_x_bit;
      error = new();

      error.error_addr   = check.test_addr;
      error.reg_read     = check.rd_value;
      error.reg_expected = check.value; 
      error.rd_resp = check.rd_resp;
      error.wr_resp = check.wr_resp;
      error.rd_id = check.rd_id;
      error.wr_id = check.wr_id;
      error.valid_addr = check.valid_addr;
      error.error_time = check.check_time;

      if (check.valid_addr)
      begin
         found_x_bit = 1'b0;
         for (int i = 0; i < 64; i++)
         begin
            if (check.value[i] === 1'bx)
            begin
               found_x_bit = 1'b1;
            end
         end
         if (found_x_bit)
         begin
            error.error_detected = 1'b1;
            error.reg_has_x = 1'b1;
            error.error_count = error.error_count + 1;
            error_message = $sformatf("ERROR: During a Valid Address Range Access to Register:%s @ Address:%H_%H Real Register Incorrectly Contains Unknown Bits at Time:%0t. REG:%H_%H_%H_%H", check_reg_name, check.test_addr[19:16], check.test_addr[15:0], check.check_time, check.value[63:48], check.value[47:32], check.value[31:16], check.value[15:0]);
            error.error_msgs.push_back(error_message);
         end
      end

      if (check.valid_addr)
      begin
         found_x_bit = 1'b0;
         for (int i = 0; i < 64; i++)
         begin
            if (check.rd_value[i] === 1'bx)
            begin
               found_x_bit = 1'b1;
            end
         end
         if (found_x_bit)
         begin
            error.error_detected = 1'b1;
            error.reg_read_x = 1'b1;
            error.error_count = error.error_count + 1;
            error_message = $sformatf("ERROR: During a Valid Address Range Access to Register:%s @ Address:%H_%H Register Read Incorrectly Contains Unknown Bits with rd_resp:%s and wr_resp:%s at Time:%0t. READ:%H_%H_%H_%H", check_reg_name, check.test_addr[19:16], check.test_addr[15:0], check.rd_resp.name, check.wr_resp.name, check.check_time, check.rd_value[63:48], check.rd_value[47:32], check.rd_value[31:16], check.rd_value[15:0]);
            error.error_msgs.push_back(error_message);
         end
      end

      if (check.valid_addr && ((check.rd_resp != RESP_OKAY) || (check.wr_resp != RESP_OKAY)))
      begin
         error.error_detected = 1'b1;
         error.resp_wrong = 1'b1;
         error.error_count = error.error_count + 1;
         error_message = $sformatf("ERROR: Valid Address Range Access to Register:%s @ Address:%H_%H Incorrectly Flagged as Out-of-Bounds with rd_resp:%s and wr_resp:%s at Time:%0t.", check_reg_name, check.test_addr[19:16], check.test_addr[15:0], check.rd_resp.name, check.wr_resp.name, check.check_time);
         error.error_msgs.push_back(error_message);
      end

      if ((check.valid_addr == 1'b1) && (access_type == LOWER32) && ((check.rd_value & 64'h0000_0000_FFFF_FFFF) !== (check.value & 64'h0000_0000_FFFF_FFFF)))
      begin
         error.error_detected = 1'b1;
         error.reg_mismatch = 1'b1;
         error.error_count = error.error_count + 1;
         error_message = $sformatf("ERROR: LOWER32-bit Read to Register:%s @ Address:%H_%H Returns with Value:%H_%H_%H_%H and Does Not Match Real Register Value:%H_%H_%H_%H rd_id:%H at time %0t.", check_reg_name, check.test_addr[19:16], check.test_addr[15:0], check.rd_value[63:48], check.rd_value[47:32], check.rd_value[31:16], check.rd_value[15:0], {16{1'b0}}, {16{1'b0}}, check.value[31:16], check.value[15:0], check.rd_id, check.check_time);
         error.error_msgs.push_back(error_message);
      end

      if ((check.valid_addr == 1'b1) && (access_type == UPPER32) && ((check.rd_value & 64'hFFFF_FFFF_0000_0000) !== (check.value & 64'hFFFF_FFFF_0000_0000)))
      begin
         error.error_detected = 1'b1;
         error.reg_mismatch = 1'b1;
         error.error_count = error.error_count + 1;
         error_message = $sformatf("ERROR: UPPER32-bit Read to Register:%s @ Address:%H_%H Returns with Value:%H_%H_%H_%H and Does Not Match Real Register Value:%H_%H_%H_%H rd_id:%H at time %0t.", check_reg_name, check.test_addr[19:16], check.test_addr[15:0], check.rd_value[63:48], check.rd_value[47:32], check.rd_value[31:16], check.rd_value[15:0], check.value[63:48], check.value[47:32], {16{1'b0}}, {16{1'b0}}, check.rd_id, check.check_time);
         error.error_msgs.push_back(error_message);
      end

      if ((check.valid_addr == 1'b1) && (access_type == FULL64) && (check.rd_value !== check.value))
      begin
         error.error_detected = 1'b1;
         error.reg_mismatch = 1'b1;
         error.error_count = error.error_count + 1;
         error_message = $sformatf("ERROR: FULL64-bit Read to Register:%s @ Address:%H_%H Returns with Value:%H_%H_%H_%H and Does Not Match Real Register Value:%H_%H_%H_%H rd_id:%H at time %0t.", check_reg_name, check.test_addr[19:16], check.test_addr[15:0], check.rd_value[63:48], check.rd_value[47:32], check.rd_value[31:16], check.rd_value[15:0], check.value[63:48], check.value[47:32], check.value[31:16], check.value[15:0], check.rd_id, check.check_time);
         error.error_msgs.push_back(error_message);
      end

      if ((check.valid_addr == 1'b0) && (check.rd_value !== 64'h0000_0000_0000_0000))
      begin
         error.error_detected = 1'b1;
         error.unused_wrong = 1'b1;
         error.error_count = error.error_count + 1;
         error_message = $sformatf("ERROR: Unused Area Read to Address:%H_%H Returns with Value:%H_%H_%H_%H and Does Not Match Correct Value:0000_0000_0000_0000 rd_id:%H at time %0t.", check.test_addr[19:16], check.test_addr[15:0], check.rd_value[63:48], check.rd_value[47:32], check.rd_value[31:16], check.rd_value[15:0], check.rd_id, check.check_time);
         error.error_msgs.push_back(error_message);
      end

      return error;
   endfunction


   virtual function logic pass();
      return !reg_error.error_detected;
   endfunction


   virtual function logic fail();
      return reg_error.error_detected;
   endfunction


   virtual function void report_error_queue();
      logic fail;
      fail = reg_error.error_detected;
      $timeformat(-9, 2," ns");
      if (fail)
      begin
         for (int i = 0; i < reg_error.error_msgs.size(); i++)
         begin
            $display(reg_error.error_msgs[i]);
         end
      end
      else
      begin
         $display("SUCCESS: No Errors for Register:%s @ Address:%H_%H.", check_reg_name, reg_error.error_addr[19:16], reg_error.error_addr[15:0]);
      end
      $display("");
   endfunction

endclass: RandomTest


endpackage: csr_transaction_class_pkg

`endif // __CSR_TRANSACTION_CLASS_PKG__
