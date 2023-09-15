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
//   polymorphic if needed, but currently there are a few changes in some of
//   the derived classes that would prevent this.
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
// Base Classes: BitErrorLog, BitCheckLog
//------------------------------------------------------------------------------
// These are simple logging objects for the test classes that follow.
//------------------------------------------------------------------------------
class BitErrorLog;
   logic [63:0] bit_pos;
   logic [63:0] bit_expected;
   string       test_name;


   function new();
      this.bit_pos      = {64{1'b0}};
      this.bit_expected = {64{1'b0}};
      this.test_name    = "";
   endfunction


   function clear();
      bit_pos      = {64{1'b0}};
      bit_expected = {64{1'b0}};
      test_name    = "";
   endfunction


   function int error_count();
      int i;
      logic [63:0] register;
      i = 0;
      register = bit_pos;
      while (register > 64'd0)
      begin
         register = register & (register - 64'd1);  // Efficient for relatively low 1's density that is expected.
         i = i + 1;
      end
      return i;
   endfunction

endclass: BitErrorLog


class BitCheckLog;
   logic [63:0] last_value;
   time         check_time;
   logic [63:0] value;
   string       test_name;


   function new();
      this.last_value = {64{1'b0}};
      this.check_time = $time;
      this.value      = {64{1'b0}};
      this.test_name  = "";
   endfunction


   function clear();
      last_value = {64{1'b0}};
      check_time = $time;
      value      = {64{1'b0}};
      test_name  = "";
   endfunction

endclass: BitCheckLog


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
   logic [1:0] rd_resp;
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
         $display (     "Read  64-bit register @ address:%H_%H got  data:%H_%H_%H_%H with response:%H for transaction id:%H:%H at time:%0t.", rd_addr[19:16], rd_addr[15:0], rd_data[63:48], rd_data[47:32], rd_data[31:16], rd_data[15:0], rd_resp, id, rd_id, $time);
      end
      else
      begin
         if (access == UPPER32)
         begin
            $display (     "Read  upper 32-bit register @ address:%H_%H got  data:%H_%H with response:%H for transaction id:%H:%H at time:%0t.", rd_addr[19:16], rd_addr[15:0], rd_data[63:48], rd_data[47:32], rd_resp, id, rd_id, $time);
         end
         else
         begin
            if (access == LOWER32)
            begin
               $display (     "Read  lower 32-bit register @ address:%H_%H got  data:%H_%H with response:%H for transaction id:%H:%H at time:%0t", rd_addr[19:16], rd_addr[15:0], rd_data[31:16], rd_data[15:0], rd_resp, id, rd_id, $time);
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
   logic [1:0]  wr_resp;
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
         $display (     "Write 64-bit register @ address:%H_%H with data:%H_%H_%H_%H got  response:%H for transaction id:%H:%H at time:%0t.", wr_addr[19:16], wr_addr[15:0], wr_data[63:48], wr_data[47:32], wr_data[31:16], wr_data[15:0], wr_resp, id, wr_id, $time);
      end
      else
      begin
         if (access == UPPER32)
         begin
            $display (     "Write upper 32-bit register @ address:%H_%H with data:%H_%H got  response:%H for transaction id:%H:%H at time:%0t.", wr_addr[19:16], wr_addr[15:0], wr_data[63:48], wr_data[47:32], wr_resp, id, wr_id, $time);
         end
         else
         begin
            if (access == LOWER32)
            begin
               $display (     "Write upper 32-bit register @ address:%H_%H with data:%H_%H got  response:%H for transaction id:%H:%H at time:%0t.", wr_addr[19:16], wr_addr[15:0], wr_data[63:48], wr_data[47:32], wr_resp, id, wr_id, $time);
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
      wait (axi.bvalid === 1'b1);
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
// Base Class: RegCheck
//------------------------------------------------------------------------------
// All register checking tests to use the abstract base class "RegCheck".
// This base class implements all of the core elements of the check/test classes
// and sets forward a foundation for polymorphism if it is desired later.
//
// Each of the following derived classes performs a register test or enables
// a type of register test.
//------------------------------------------------------------------------------
virtual class RegCheck; // Abstract Base Class

   virtual ofs_fim_pwrgoodn_if.master pgn;
   virtual ofs_fim_axi_mmio_if #(
      .AWID_WIDTH(MMIO_TID_WIDTH),
      .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
      .WDATA_WIDTH(MMIO_DATA_WIDTH),
      .ARID_WIDTH(MMIO_TID_WIDTH),
      .ARADDR_WIDTH(MMIO_ADDR_WIDTH),
      .RDATA_WIDTH(MMIO_DATA_WIDTH)
   ).master axi;
   ofs_csr_reg_generic_attr_t check_reg_attr;
   string check_reg_name;
   logic [19:0] reg_addr;
   ofs_csr_reg_generic_t reset_reg;
   ofs_csr_reg_generic_t update_reg;
   Transaction tr;
   ResetTransaction rt;
   PwrResetTransaction prt;
   ReadTransaction rdt;
   ReadTransactionSilent rdst;
   WriteTransaction wrt;
   WriteTransactionSilent wrst;
   static int check_count = 0;
   static int total_bit_error_count = 0;
   int tr_count;
   int i;

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
      input ofs_csr_reg_generic_attr_t check_reg_attr, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      input ofs_csr_reg_generic_t reset_reg, 
      input ofs_csr_reg_generic_t update_reg  
   );
      this.axi                      = axi;
      this.pgn                      = pgn;
      this.check_reg_attr           = check_reg_attr;
      this.check_reg_name           = check_reg_name;
      this.reg_addr                 = reg_addr;
      this.reset_reg                = reset_reg;
      this.update_reg               = update_reg;
      check_count++;
      this.i                        = 0;
   endfunction


   // Pure virtual functions to support polymorphism if this is desired later.
   pure virtual task                 check();
   pure virtual task                 check_data(
      input logic [63:0] write_value_passed
   );
   pure virtual function BitErrorLog bit_check  (
      input BitCheckLog            check
   );
   pure virtual function logic pass();
   pure virtual function logic fail();
   pure virtual function void  report_errors(
      input BitErrorLog error,
      input BitCheckLog check
   );

endclass: RegCheck


//------------------------------------------------------------------------------
// Derived Class: ResetCheck
// Inheritance..: RegCheck
//------------------------------------------------------------------------------
// This class asserts the soft reset "rst_n" and checks to make sure that the
// register resets or obeys it's "sticky" attributes if applicable.
//------------------------------------------------------------------------------
class ResetCheck extends RegCheck;
   BitErrorLog reset_error;
   BitCheckLog reset_check;
   logic [19:0] wr_addr;
   logic [63:0] wr_data;
   logic [6:0]  wr_id;
   logic [1:0]  wr_resp;
   logic [19:0] rd_addr;
   logic [63:0] rd_data;
   logic [6:0]  rd_id;
   logic [1:0]  rd_resp;
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
      input ofs_csr_reg_generic_attr_t check_reg_attr, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      ref   ofs_csr_reg_generic_t reset_reg, 
      ref   ofs_csr_reg_generic_t update_reg  
   );
      super.new(
         .axi(axi),
         .pgn(pgn),
         .check_reg_attr(check_reg_attr),
         .check_reg_name(check_reg_name),
         .reg_addr(reg_addr),
         .reset_reg(reset_reg),
         .update_reg(update_reg)
      );
      this.wr_addr = reg_addr;
      this.rd_addr = reg_addr;
      this.reset_check = new();
   endfunction


   virtual task check();
      reset_error = bit_check(
         .check(reset_check)
      );
      total_bit_error_count = total_bit_error_count + reset_error.error_count();
      if (|wr_data)
      begin
         reset_check.test_name = "soft-reset/writing ones";
         reset_error.test_name = "soft-reset/writing ones";
      end
      else
      begin
         reset_check.test_name = "soft-reset/writing zeros";
         reset_error.test_name = "soft-reset/writing zeros";
      end
      $display("");
      report_errors(
         .error(reset_error),
         .check(reset_check)
      );
      $display("");
      tr_count = rdt.t_count;
   endtask


   virtual task write_value(
      input logic [63:0] write_value_passed
   );
      wr_data = write_value_passed;
      wrt = new(
         .axi(axi),
         .pgn(pgn),
         .wr_addr(wr_addr),
         .wr_data(wr_data),
         .access(FULL64)
      );
      wrt.run();
      rdt = new(
         .axi(axi),
         .pgn(pgn),
         .rd_addr(rd_addr),
         .access(FULL64)
      );
      rdt.run();
      reset_check.last_value = rdt.rd_data;
   endtask


   virtual task reset_on();
      @(posedge axi.clk);
      #100ps axi.rst_n = 1'b0;
      repeat (4) @(posedge axi.clk);
   endtask


   virtual function void update_reset_value(
      input logic [63:0] reset_value,
      input time         reset_time
   );
   reset_check.value = reset_value;
   reset_check.check_time = reset_time;
   $display("Reset 64-bit register @ address:%H_%H got  data:%H_%H_%H_%H with soft reset at time:%0t.", rd_addr[19:16], rd_addr[15:0], reset_value[63:48], reset_value[47:32], reset_value[31:16], reset_value[15:0], reset_time);
   endfunction


   virtual task reset_off();
      @(posedge axi.clk);
      #100ps axi.rst_n = 1'b1;
      repeat (4) @(posedge axi.clk);
   endtask


   virtual task check_data(
      input logic [63:0] write_value_passed
   ); // Task does nothing with this class, but is kept for abstract base class compatibility.
   endtask


   virtual function BitErrorLog bit_check(
      input BitCheckLog check
   );
      int i;
      BitErrorLog bit_checker;
      bit_checker = new();
      for(i=0; i<64; i=i+1)
      begin: bit_check_loop
         case (check_reg_attr.data[i])
            RO: begin // All read-only bits should contain their reset/update values.
               if ((check.value[i] !== reset_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = reset_reg.data[i];
               end
            end
            RW: begin  // All RW bits should contain reset values.
               if ((check.value[i] !== reset_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = reset_reg.data[i];
               end
            end
            RWS, RWD: begin  // All sticky read-write bits should contain latest write data.
               if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = check.last_value[i];
               end
            end
            RW1C: begin  // All RW1C bits should contain their reset values.
               if ((check.value[i] !== reset_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = reset_reg.data[i];
               end
            end
            RW1CS, RW1CD: begin  // All sticky Write-one-to-clear bits should retain their value.
               if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = check.last_value[i];
               end
            end
            RW1S: begin  // All Write-one-to-set attributes behave the same out of reset.
               if ((check.value[i] !== reset_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = reset_reg.data[i];
               end
            end
            RW1SS, RW1SD: begin  // All Write-one-to-set attributes behave the same out of reset.
               if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = check.last_value[i];
               end
            end
            Rsvd, RsvdP: begin // These bits are don't cares.
                  bit_checker.bit_pos[i] = 1'b0;
                  bit_checker.bit_expected[i] = 1'bX;
            end
            RsvdZ: begin
               if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = 1'b0;
               end
            end
         endcase
      end: bit_check_loop
      return bit_checker;
   endfunction


   virtual function logic pass();
      return ~(|reset_error.bit_pos);
   endfunction


   virtual function logic fail();
      return (|reset_error.bit_pos);
   endfunction


   virtual function void report_errors(
         input BitErrorLog error,
         input BitCheckLog check
   );
      int i;
      $timeformat(-9, 2," ns");
      if ( (|error.bit_pos) )
      begin
         $display ("ERROR:  Register:%s at address:%H_%H has failed bit-level %s check with %2d bits in error at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], error.test_name, error.error_count(), check.check_time);
         $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
      end
      else
      begin
         $display ("Success: Register:%s at address %H_%H has passed bit-level %s check at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], error.test_name, check.check_time);
      end
      for (i=0; i<64; i=i+1)
      begin
         if (error.bit_pos[i] == 1'b1)
         begin
            $display("        Bit:%2d with attribute:%-5s of register field:%H_%H_%H_%H is:%b and should be:%b", i, check_reg_attr.data[i].name, check.value[63:48], check.value[47:32], check.value[31:16], check.value[15:0], check.value[i], error.bit_expected[i]);
         end
      end
      if ( (|error.bit_pos) )
      begin
         $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
      end
   endfunction

endclass: ResetCheck


//------------------------------------------------------------------------------
// Derived Class: HardResetCheck
// Inheritance..: ResetCheck
//------------------------------------------------------------------------------
// This class asserts the hard reset "pwr_good_n" as well as the AXI soft reset,
// "rst_n" and checks to make sure that the register resets or obeys it's 
// "sticky" attributes if applicable.
//------------------------------------------------------------------------------
class HardResetCheck extends ResetCheck;

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
      input ofs_csr_reg_generic_attr_t check_reg_attr, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      ref   ofs_csr_reg_generic_t reset_reg, 
      ref   ofs_csr_reg_generic_t update_reg  
   );
      super.new(
         .axi(axi),
         .pgn(pgn),
         .check_reg_attr(check_reg_attr),
         .check_reg_name(check_reg_name),
         .reg_addr(reg_addr),
         .reset_reg(reset_reg),
         .update_reg(update_reg)
      );
   endfunction


   virtual task check();
      reset_error = bit_check(
         .check(reset_check)
      );
      total_bit_error_count = total_bit_error_count + reset_error.error_count();
      if (|wr_data)
      begin
         reset_check.test_name = "hard-reset/writing ones";
         reset_error.test_name = "hard-reset/writing ones";
      end
      else
      begin
         reset_check.test_name = "hard-reset/writing zeros";
         reset_error.test_name = "hard-reset/writing zeros";
      end
      $display("");
      report_errors(
         .error(reset_error),
         .check(reset_check)
      );
      $display("");
      tr_count = rdt.t_count;
   endtask


   virtual task reset_on();
      @(posedge axi.clk);
      #100ps axi.rst_n = 1'b0;
      pgn.pwr_good_n = 1'b0;
      repeat (4) @(posedge axi.clk);
   endtask


   virtual function void update_reset_value(
      input logic [63:0] reset_value,
      input time         reset_time
   );
   reset_check.value = reset_value;
   reset_check.check_time = reset_time;
   $display("Reset 64-bit register @ address:%H_%H got  data:%H_%H_%H_%H with hard reset at time:%0t.", rd_addr[19:16], rd_addr[15:0], reset_value[63:48], reset_value[47:32], reset_value[31:16], reset_value[15:0], reset_time);
   endfunction


   virtual task reset_off();
      @(posedge axi.clk);
      #100ps axi.rst_n = 1'b1;
      pgn.pwr_good_n = 1'b1;
      repeat (4) @(posedge axi.clk);
   endtask


   virtual function BitErrorLog bit_check(
      input BitCheckLog check
   );
      int i;
      BitErrorLog bit_checker;
      bit_checker = new();
      for(i=0; i<64; i=i+1)
      begin: bit_check_loop
         case (check_reg_attr.data[i])
            RO: begin // All read-only bits should contain their reset/update values.
               if ((check.value[i] !== reset_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = reset_reg.data[i];
               end
            end
            RW, RWS: begin  // All RW & RWS bits should contain reset values.
               if ((check.value[i] !== reset_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = reset_reg.data[i];
               end
            end
            RWD: begin  // All hard sticky read-write bits should contain latest write data.
               if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = check.last_value[i];
               end
            end
            RW1C, RW1CS: begin  // All RW1C & RW1CS bits should contain their reset values.
               if ((check.value[i] !== reset_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = reset_reg.data[i];
               end
            end
            RW1CD: begin  // All hard Write-one-to-clear bits should retain their value.
               if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = check.last_value[i];
               end
            end
            RW1S, RW1SS: begin  // All RW1S & RW1SS bits should contain their reset values.
               if ((check.value[i] !== reset_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = reset_reg.data[i];
               end
            end
            RW1SD: begin  // All hard Write-one-to-set bits should retain their values.
               if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = check.last_value[i];
               end
            end
            Rsvd, RsvdP: begin // These bits are don't cares.
                  bit_checker.bit_pos[i] = 1'b0;
                  bit_checker.bit_expected[i] = 1'bX;
            end
            RsvdZ: begin
               if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = 1'b0;
               end
            end
         endcase
      end: bit_check_loop
      return bit_checker;
   endfunction


   virtual function logic pass();
      return ~(|reset_error.bit_pos);
   endfunction


   virtual function logic fail();
      return (|reset_error.bit_pos);
   endfunction

endclass: HardResetCheck



//------------------------------------------------------------------------------
// Derived Class: WriteCheck
// Inheritance..: RegCheck
//------------------------------------------------------------------------------
// This class performs an all-ones write and an all-zeros write to a register
// and makes sure that the bits in the register retain their appropriate state
// according to their relative bit attributes.
//------------------------------------------------------------------------------
class WriteCheck extends RegCheck;
   logic [19:0] wr_addr;
   logic [63:0] wr_data;
   logic [6:0]  wr_id;
   logic [1:0]  wr_resp;
   logic [19:0] rd_addr;
   logic [63:0] rd_data;
   logic [6:0]  rd_id;
   logic [1:0]  rd_resp;
   csr_access_type_t access;
   BitErrorLog write0_error;
   BitErrorLog write1_error;
   BitCheckLog write0_check;
   BitCheckLog write1_check;
   
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
      input ofs_csr_reg_generic_attr_t check_reg_attr, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      ref   ofs_csr_reg_generic_t reset_reg, 
      ref   ofs_csr_reg_generic_t update_reg
   );
      super.new(
         .axi(axi),
         .pgn(pgn),
         .check_reg_attr(check_reg_attr),
         .check_reg_name(check_reg_name),
         .reg_addr(reg_addr),
         .reset_reg(reset_reg),
         .update_reg(update_reg)
      );
      this.wr_addr = reg_addr;
      this.rd_addr = reg_addr;
      this.write0_check = new();
      this.write1_check = new();
   endfunction


   virtual task check();
      rdt = new(
         .axi(axi),
         .pgn(pgn),
         .rd_addr(rd_addr),
         .access(FULL64)
      );
      rdt.run();
      write1_check.last_value = rdt.rd_data;
      wr_data = 64'hFFFF_FFFF_FFFF_FFFF;
      wrt = new(
         .axi(axi),
         .pgn(pgn),
         .wr_addr(wr_addr),
         .wr_data(wr_data),
         .access(FULL64)
      );
      wrt.run();
      rdt.run();
      write1_check.value = rdt.rd_data;
      write1_check.check_time = $time;
      write1_error = bit_check(
         .check(write1_check)
      );
      total_bit_error_count = total_bit_error_count + write1_error.error_count();
      write1_check.test_name  = "write-one";
      write1_error.test_name  = "write-one";
      $display(""); // Provide readable space before calling "report_errors()".
      report_errors(
         .error(write1_error),
         .check(write1_check)
      );
      $display(""); // Provide readable space after calling "report_errors()".
      rdt.run();
      write0_check.last_value = rdt.rd_data;
      wr_data = 64'h0000_0000_0000_0000;
      wrt.wr_data = wr_data;
      wrt.run();
      rdt.run();
      write0_check.value = rdt.rd_data;
      write0_check.check_time = $time;
      write0_error = bit_check(
         .check(write0_check)
      );
      total_bit_error_count = total_bit_error_count + write0_error.error_count();
      write0_check.test_name  = "write-zero";
      write0_error.test_name  = "write-zero";
      $display(""); // Provide readable space before calling "report_errors()".
      report_errors(
         .error(write0_error),
         .check(write0_check)
      );
      $display(""); // Provide readable space after calling "report_errors()".
      tr_count = wrt.t_count; // Record statistic for the number of transactors used.
   endtask


   virtual task check_data(
      input logic [63:0] write_value_passed
   );
      wr_data = write_value_passed;
   endtask


   virtual function BitErrorLog bit_check(
      input BitCheckLog check
   );
      int i;
      BitErrorLog bit_checker;
      bit_checker = new();
      for(i=0; i<64; i=i+1)
      begin: bit_check_loop
         case (check_reg_attr.data[i])
            RO: begin // All read-only bits should contain their update values.
               if ((check.value[i] !== update_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = update_reg.data[i];
               end
            end
            RW, RWS, RWD: begin  // All read-write bits should contain latest write data.
               if ((check.value[i] !== wr_data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = wr_data[i];
               end
            end
            RW1C, RW1CS, RW1CD: begin  // All Write-one-to-clear attributes behave the same out of reset.
               if ((wr_data[i] == 1'b1) || (check.value[i] === 1'bx))
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Due to clock delay after write, register will set if update is high.
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx)) // Register must clear if update is low.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
               end
               else
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Register will be set if update is high.
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx)) // Inactive: Register should retain last value if write bit not set.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = check.last_value[i];
                     end
                  end
               end
            end
            RW1S, RW1SS, RW1SD: begin  // All Write-one-to-set attributes behave the same out of reset.
               if ((wr_data[i] == 1'b1) || (check.value[i] === 1'bx))
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Due to clock delay after write, register will clear if update is high.
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx)) // Register must set if update is low.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
               end
               else
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Register will be clear if update is high.
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx)) //Inactive: Register should retain last value if write bit not set.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = check.last_value[i];
                     end
                  end
               end
            end
            Rsvd, RsvdP: begin // These bits are don't cares.
            end
            RsvdZ: begin
               if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = 1'b0;
               end
            end
         endcase
      end: bit_check_loop
      return bit_checker;
   endfunction


   virtual function logic pass();
      return ~((|write1_error.bit_pos) || (|write0_error.bit_pos));
   endfunction


   virtual function logic fail();
      return ((|write1_error.bit_pos) || (|write0_error.bit_pos));
   endfunction


   virtual function void report_errors(
      input BitErrorLog error, 
      input BitCheckLog check
   );
      int i;
      $timeformat(-9, 2," ns");
      if ( (|error.bit_pos) )
      begin
         $display ("ERROR:  Register:%s at address:%H_%H has failed bit-level %s check with %2d bits in error at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], error.test_name, error.error_count(), check.check_time);
         $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
      end
      else
      begin
         $display ("Success: Register:%s at address %H_%H has passed bit-level %s check at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], error.test_name, check.check_time);
      end
      for (i=0; i<64; i=i+1)
      begin
         if (error.bit_pos[i] == 1'b1)
         begin
            $display("        Bit:%2d with attribute:%-5s of register field:%H_%H_%H_%H is:%b and should be:%b", i, check_reg_attr.data[i].name, check.value[63:48], check.value[47:32], check.value[31:16], check.value[15:0], check.value[i], error.bit_expected[i]);
         end
      end
      if ( (|error.bit_pos) )
      begin
         $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
      end
   endfunction

endclass: WriteCheck
      
      
//------------------------------------------------------------------------------
// Derived Class: WriteOneSetClearCheck
// Inheritance..: WriteCheck
//------------------------------------------------------------------------------
// This class performs a write to a register with a value that is passed as
// an input to the "check_data" method function and makes sure that the bits in 
// the register retain their appropriate state according to their relative bit 
// attributes.
//
// This Class differs from inherited WriteCheck by not using any resets and
// using a passed value to write to the register.  This allows testing of 
// write-one-to-clear (RW1C) and write-one-to-set (RW1S) register types from 
// the main testbench which can sequence the set/clear states of the bits
// from their inputs and then monitor the effect of specific writes to these 
// bits.
//------------------------------------------------------------------------------
class WriteOneSetClearCheck extends WriteCheck;
   BitErrorLog write_error;
   BitCheckLog write_check;

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
      input ofs_csr_reg_generic_attr_t check_reg_attr, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      ref   ofs_csr_reg_generic_t reset_reg, 
      ref   ofs_csr_reg_generic_t update_reg
   );
      super.new(
         .axi(axi),
         .pgn(pgn),
         .check_reg_attr(check_reg_attr),
         .check_reg_name(check_reg_name),
         .reg_addr(reg_addr),
         .reset_reg(reset_reg),
         .update_reg(update_reg)
      );
      this.write_check = new();
   endfunction


   virtual task check_data(
      input logic [63:0] write_value_passed
   );
      rdt = new(
         .axi(axi),
         .pgn(pgn),
         .rd_addr(rd_addr),
         .access(FULL64)
      );
      rdt.run();
      write_check.last_value = rdt.rd_data;
      wr_data = write_value_passed;
      wrt = new(
         .axi(axi),
         .pgn(pgn),
         .wr_addr(wr_addr),
         .wr_data(wr_data),
         .access(FULL64)
      );
      wrt.run();
      rdt.run();
      write_check.value = rdt.rd_data;
      write_check.check_time = $time;
      write_error = bit_check(
         .check(write_check)
      );
      total_bit_error_count = total_bit_error_count + write_error.error_count();
      if (|wr_data)
      begin
         write_check.test_name  = "write-one-sticky";
         write_error.test_name  = "write-one-sticky";
      end
      else
      begin
         write_check.test_name  = "write-zero-sticky";
         write_error.test_name  = "write-zero-sticky";
      end
      $display(""); // Provide readable space before calling "report_errors()".
      report_errors(
         .error(write_error),
         .check(write_check)
      );
      $display(""); // Provide readable space after calling "report_errors()".
      tr_count = wrt.t_count; // Record statistic for the number of transactors used.
   endtask


   virtual function BitErrorLog bit_check(
      input BitCheckLog check
   );
      int i;
      BitErrorLog bit_checker;
      bit_checker = new();
      for(i=0; i<64; i=i+1)
      begin: bit_check_loop
         case (check_reg_attr.data[i])
            RW1C, RW1CS, RW1CD: begin  // All Write-one-to-clear attributes behave the same out of reset.
               if ((wr_data[i] == 1'b1) || (check.value[i] === 1'bx))
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Due to clock delay after write, register will set if update is high.
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx)) // Register must clear if update is low.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
               end
               else
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Register will be set if update is high.
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx)) // Inactive: Register should retain last value if write bit not set.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = check.last_value[i];
                     end
                  end
               end
            end
            RW1S, RW1SS, RW1SD: begin  // All Write-one-to-set attributes behave the same out of reset.
               if ((wr_data[i] == 1'b1) || (check.value[i] === 1'bx))
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Due to clock delay after write, register will clear if update is high.
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx)) // Register must set if update is low.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
               end
               else
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Register will be clear if update is high.
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx)) //Inactive: Register should retain last value if write bit not set.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = check.last_value[i];
                     end
                  end
               end
            end
            default: begin
               bit_checker.bit_pos[i] = 1'b0;
               bit_checker.bit_expected[i] = 1'bX;
            end
         endcase
      end: bit_check_loop
      return bit_checker;
   endfunction


   virtual function logic pass();
      return ~(|write_error.bit_pos);
   endfunction


   virtual function logic fail();
      return (|write_error.bit_pos);
   endfunction


   virtual function void report_errors(
      input BitErrorLog error, 
      input BitCheckLog check
   );
      int i;
      $timeformat(-9, 2," ns");
      if ( (|error.bit_pos) )
      begin
         $display ("ERROR:  Register:%s at address:%H_%H has failed bit-level %s check with %2d bits in error at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], error.test_name, error.error_count(), check.check_time);
         $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
      end
      else
      begin
         $display ("Success: Register:%s at address %H_%H has passed bit-level %s check at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], error.test_name, check.check_time);
      end
      for (i=0; i<64; i=i+1)
      begin
         if (error.bit_pos[i] == 1'b1)
         begin
            $display("        Bit:%2d with attribute:%-5s of register field:%H_%H_%H_%H is:%b and should be:%b", i, check_reg_attr.data[i].name, check.value[63:48], check.value[47:32], check.value[31:16], check.value[15:0], check.value[i], error.bit_expected[i]);
         end
      end
      if ( (|error.bit_pos) )
      begin
         $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
      end
   endfunction
      
endclass: WriteOneSetClearCheck


//------------------------------------------------------------------------------
// Derived Class: WriteWalkingOnesZerosCheck
// Inheritance..: RegCheck
//------------------------------------------------------------------------------
// This class performs a "walking-ones" and "walking-zeroes" write test to the
// target register and makes sure that the bits in the register retain their 
// appropriate state according to their relative bit attributes.
//------------------------------------------------------------------------------
class WriteWalkingOnesZerosCheck extends RegCheck;
   logic [19:0] wr_addr;
   logic [63:0] wr_data;
   logic [6:0]  wr_id;
   logic [1:0]  wr_resp;
   logic [19:0] rd_addr;
   logic [63:0] rd_data;
   logic [6:0]  rd_id;
   logic [1:0]  rd_resp;
   csr_access_type_t access;
   BitErrorLog walk_error;
   BitCheckLog walk_check;
   logic [63:0] shift_reg;

   Transaction tq[$]; // Transaction Queue
   BitErrorLog beq[$]; // Bit Error Queue
   BitCheckLog bcq[$]; // Bit Check Queue
   
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
      input ofs_csr_reg_generic_attr_t check_reg_attr, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      ref   ofs_csr_reg_generic_t reset_reg, 
      ref   ofs_csr_reg_generic_t update_reg
   );
      super.new(
         .axi(axi),
         .pgn(pgn),
         .check_reg_attr(check_reg_attr),
         .check_reg_name(check_reg_name),
         .reg_addr(reg_addr),
         .reset_reg(reset_reg),
         .update_reg(update_reg)
      );
      this.wr_addr = reg_addr;
      this.rd_addr = reg_addr;
      this.walk_check = new();
   endfunction


   virtual task check();
      int i;
      //--------------------------------------------------
      // Walking Ones Test
      //--------------------------------------------------
      for (i=0; i<64; i=i+1)
      begin
         shift_reg = 64'h0000_0000_0000_0001 << i;
         walk_check = new();
         rdst = new(
            .axi(axi),
            .pgn(pgn),
            .rd_addr(rd_addr),
            .access(FULL64)
         );
         rdst.run();
         walk_check.last_value = rdst.rd_data;
         wr_data = shift_reg;
         wrst = new(
            .axi(axi),
            .pgn(pgn),
            .wr_addr(wr_addr),
            .wr_data(wr_data),
            .access(FULL64)
         );
         wrst.run();
         rdst.run();
         walk_check.value = rdst.rd_data;
         walk_check.check_time = $time;
         walk_error = bit_check(
            .check(walk_check)
         );
         total_bit_error_count = total_bit_error_count + walk_error.error_count();
         walk_check.test_name  = "walking-ones";
         walk_error.test_name  = "walking-ones";
         tr = rdst;
         tq.push_back(tr);
         tr = wrst;
         tq.push_back(tr);
         bcq.push_back(walk_check);
         beq.push_back(walk_error);
      end
      report_error_queue();
      //--------------------------------------------------
      // Walking Zeros Test
      //--------------------------------------------------
      for (i=0; i<64; i=i+1)
      begin
         shift_reg = ~(64'h0000_0000_0000_0001 << i);
         walk_check = new();
         rdst = new(
            .axi(axi),
            .pgn(pgn),
            .rd_addr(rd_addr),
            .access(FULL64)
         );
         rdst.run();
         walk_check.last_value = rdst.rd_data;
         wr_data = shift_reg;
         wrst = new(
            .axi(axi),
            .pgn(pgn),
            .wr_addr(wr_addr),
            .wr_data(wr_data),
            .access(FULL64)
         );
         wrst.run();
         rdst.run();
         walk_check.value = rdst.rd_data;
         walk_check.check_time = $time;
         walk_error = bit_check(
            .check(walk_check)
         );
         total_bit_error_count = total_bit_error_count + walk_error.error_count();
         walk_check.test_name  = "walking-zeros";
         walk_error.test_name  = "walking-zeros";
         tr = rdst;
         tq.push_back(tr);
         tr = wrst;
         tq.push_back(tr);
         bcq.push_back(walk_check);
         beq.push_back(walk_error);
      end
      report_error_queue();
   endtask


   virtual task check_data(
      input logic [63:0] write_value_passed
   ); // Task does nothing with this class, but is kept for abstract base class compatibility.
   endtask


   virtual function BitErrorLog bit_check(
      input BitCheckLog check
   );
      int i;
      BitErrorLog bit_checker;
      bit_checker = new();
      for(i=0; i<64; i=i+1)
      begin: bit_check_loop
         case (check_reg_attr.data[i])
            RO: begin // All read-only bits should contain their update values.
               if ((check.value[i] !== update_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = update_reg.data[i];
               end
            end
            RW, RWS, RWD: begin  // All read-write bits should contain latest write data.
               if ((check.value[i] !== wr_data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = wr_data[i];
               end
            end
            RW1C, RW1CS, RW1CD: begin  // All Write-one-to-clear attributes behave the same out of reset.
               if ((wr_data[i] == 1'b1) || (check.value[i] === 1'bx))
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Due to clock delay after write, register will set if update is high.
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx)) // Register must clear if update is low.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
               end
               else
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Register will be set if update is high.
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx)) // Inactive: Register should retain last value if write bit not set.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = check.last_value[i];
                     end
                  end
               end
            end
            RW1S, RW1SS, RW1SD: begin  // All Write-one-to-set attributes behave the same out of reset.
               if ((wr_data[i] == 1'b1) || (check.value[i] === 1'bx))
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Due to clock delay after write, register will clear if update is high.
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx)) // Register must set if update is low.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
               end
               else
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Register will be clear if update is high.
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx)) //Inactive: Register should retain last value if write bit not set.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = check.last_value[i];
                     end
                  end
               end
            end
            Rsvd, RsvdP: begin // These bits are don't cares.
            end
            RsvdZ: begin
               if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = 1'b0;
               end
            end
         endcase
      end: bit_check_loop
      return bit_checker;
   endfunction


   virtual function logic pass();
      int i;
      logic test_passes;
      test_passes = 1'b1;
      for (i=0; i<beq.size(); i=i+1)
      begin
         if (|beq[i].bit_pos)
            test_passes = 1'b0;
      end
      return test_passes;
   endfunction


   virtual function logic fail();
      int i;
      logic test_fails;
      test_fails = 1'b0;
      for (i=0; i<beq.size(); i=i+1)
      begin
         if (|beq[i].bit_pos)
            test_fails = 1'b1;
      end
      return test_fails;
   endfunction


   virtual function void report_errors(
      input BitErrorLog error,  // Use report_error_queue instead.  Keep for Base Class compatibility.
      input BitCheckLog check   // Use report_error_queue instead.  Keep for Base Class compatibility.
   ); // This method does nothing in this class.  Keep for Base Class compatibility.
   endfunction


   virtual function void report_error_queue();
      int i, j;
      logic pass;
      string test_name;
      time check_time;
      pass = 1'b1;
      $timeformat(-9, 2," ns");
      test_name = beq[63].test_name; // Pull out series test name from top element.
      check_time = bcq[63].check_time; // Pull out check time from top element.
      for (i=0; i<beq.size(); i=i+1)
      begin
         if ( (|beq[i].bit_pos) )
         begin
            $display ("");
            $display ("ERROR:  Register:%s at address:%H_%H has failed bit-level %s check with %2d bits in error at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], beq[i].test_name, beq[i].error_count(), bcq[i].check_time);
            $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
            pass = 1'b0;
         end
         // Print out the bit positions in error.
         for (j=0; j<64; j=j+1)
         begin
            if (beq[i].bit_pos[j] == 1'b1)
            begin
               $display("        Bit:%2d with attribute:%-5s of register field:%H_%H_%H_%H is:%b and should be:%b", j, check_reg_attr.data[j].name, bcq[i].value[63:48], bcq[i].value[47:32], bcq[i].value[31:16], bcq[i].value[15:0], bcq[i].value[j], beq[i].bit_expected[j]);
            end
         end
         if ( (|beq[i].bit_pos) )
         begin
            $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
         end
      end
      if (pass)
      begin
         $display ("Success: Register:%s at address %H_%H has passed bit-level %s check at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], beq[$].test_name, bcq[$].check_time);
      end
      //else 
      //begin
         $display ("");
      //end
   endfunction

endclass: WriteWalkingOnesZerosCheck


//------------------------------------------------------------------------------
// Derived Class: WriteRandomCheck
// Inheritance..: RegCheck
//------------------------------------------------------------------------------
// This class performs a set of random data writes to a register and makes sure 
// that the bits in the register retain their appropriate state according to 
// their relative bit attributes.
//
// The default number of random writes performed is set in the constructor and
// is currently set to a value of 1024.  The number of random writes performed
// can be changed with the "set_run_depth" method function and the currently 
// set value can be read with the "get_run_depth" method function.
//
// Silent read and write transaction objects are used in this test so that the 
// stdout output isn't flooded with the messages regarding all of the register 
// reads and writes.
//------------------------------------------------------------------------------
class WriteRandomCheck extends RegCheck;
   logic [19:0] wr_addr;
   logic [63:0] wr_data;
   logic [6:0]  wr_id;
   logic [1:0]  wr_resp;
   logic [19:0] rd_addr;
   logic [63:0] rd_data;
   logic [6:0]  rd_id;
   logic [1:0]  rd_resp;
   csr_access_type_t access;
   BitErrorLog rand_error;
   BitCheckLog rand_check;
   RandData rand_data;
   int rand_num;

   Transaction tq[$]; // Transaction Queue
   BitErrorLog beq[$]; // Bit Error Queue
   BitCheckLog bcq[$]; // Bit Check Queue
   
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
      input ofs_csr_reg_generic_attr_t check_reg_attr, 
      string check_reg_name,
      input logic [19:0] reg_addr, 
      ref   ofs_csr_reg_generic_t reset_reg, 
      ref   ofs_csr_reg_generic_t update_reg
   );
      super.new(
         .axi(axi),
         .pgn(pgn),
         .check_reg_attr(check_reg_attr),
         .check_reg_name(check_reg_name),
         .reg_addr(reg_addr),
         .reset_reg(reset_reg),
         .update_reg(update_reg)
      );
      this.wr_addr = reg_addr;
      this.rd_addr = reg_addr;
      this.rand_check = new();
      this.rand_data  = new();
      this.rand_num = 1024;
   endfunction


   virtual function void set_run_depth(
      int n
   );
      if (n > 0)
      begin
         rand_num = n;
      end
      else
      begin
         $display("WARNING: Attempt to set Random Number Run Depth to:%0d in WriteRandomCheck Oject denied.  Depth remains set to: %0d", n, rand_num);
      end
   endfunction


   virtual function int get_run_depth();
      return rand_num;
   endfunction


   virtual task check();
      int i;
      //--------------------------------------------------
      // Perform random pattern test.
      //--------------------------------------------------
      for (i=0; i<rand_num; i=i+1)
      begin
         rand_data.randomize();
         rand_check = new();
         rdst = new(
            .axi(axi),
            .pgn(pgn),
            .rd_addr(rd_addr),
            .access(FULL64)
         );
         rdst.run();
         rand_check.last_value = rdst.rd_data;
         wr_data = rand_data.data;
         wrst = new(
            .axi(axi),
            .pgn(pgn),
            .wr_addr(wr_addr),
            .wr_data(wr_data),
            .access(FULL64)
         );
         wrst.run();
         rdst.run();
         rand_check.value = rdst.rd_data;
         rand_check.check_time = $time;
         rand_error = bit_check(
            .check(rand_check)
         );
         total_bit_error_count = total_bit_error_count + rand_error.error_count();
         rand_check.test_name  = "random-pattern";
         rand_error.test_name  = "random-pattern";
         tr = rdst;
         tq.push_back(tr);
         tr = wrst;
         tq.push_back(tr);
         bcq.push_back(rand_check);
         beq.push_back(rand_error);
      end
      report_error_queue();
   endtask


   virtual task check_data(
      input logic [63:0] write_value_passed
   ); // Task does nothing with this class, but is kept for abstract base class compatibility.
   endtask


   virtual function BitErrorLog bit_check(
      input BitCheckLog check
   );
      int i;
      BitErrorLog bit_checker;
      bit_checker = new();
      for(i=0; i<64; i=i+1)
      begin: bit_check_loop
         case (check_reg_attr.data[i])
            RO: begin // All read-only bits should contain their update values.
               if ((check.value[i] !== update_reg.data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = update_reg.data[i];
               end
            end
            RW, RWS, RWD: begin  // All read-write bits should contain latest write data.
               if ((check.value[i] !== wr_data[i]) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = wr_data[i];
               end
            end
            RW1C, RW1CS, RW1CD: begin  // All Write-one-to-clear attributes behave the same out of reset.
               if ((wr_data[i] == 1'b1) || (check.value[i] === 1'bx))
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Due to clock delay after write, register will set if update is high.
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx)) // Register must clear if update is low.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
               end
               else
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Register will be set if update is high.
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx)) // Inactive: Register should retain last value if write bit not set.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = check.last_value[i];
                     end
                  end
               end
            end
            RW1S, RW1SS, RW1SD: begin  // All Write-one-to-set attributes behave the same out of reset.
               if ((wr_data[i] == 1'b1) || (check.value[i] === 1'bx))
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Due to clock delay after write, register will clear if update is high.
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== 1'b1) || (check.value[i] === 1'bx)) // Register must set if update is low.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b1;
                     end
                  end
               end
               else
               begin
                  if ((update_reg.data[i] == 1'b1) || (check.value[i] === 1'bx)) // Register will be clear if update is high.
                  begin
                     if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = 1'b0;
                     end
                  end
                  else
                  begin
                     if ((check.value[i] !== check.last_value[i]) || (check.value[i] === 1'bx)) //Inactive: Register should retain last value if write bit not set.
                     begin
                        bit_checker.bit_pos[i] = 1'b1;
                        bit_checker.bit_expected[i] = check.last_value[i];
                     end
                  end
               end
            end
            Rsvd, RsvdP: begin // These bits are don't cares.
            end
            RsvdZ: begin
               if ((check.value[i] !== 1'b0) || (check.value[i] === 1'bx))
               begin
                  bit_checker.bit_pos[i] = 1'b1;
                  bit_checker.bit_expected[i] = 1'b0;
               end
            end
         endcase
      end: bit_check_loop
      return bit_checker;
   endfunction


   virtual function logic pass();
      int i;
      logic test_passes;
      test_passes = 1'b1;
      for (i=0; i<beq.size(); i=i+1)
      begin
         if (|beq[i].bit_pos)
            test_passes = 1'b0;
      end
      return test_passes;
   endfunction


   virtual function logic fail();
      int i;
      logic test_fails;
      test_fails = 1'b0;
      for (i=0; i<beq.size(); i=i+1)
      begin
         if (|beq[i].bit_pos)
            test_fails = 1'b1;
      end
      return test_fails;
   endfunction


   virtual function void report_errors(
      input BitErrorLog error,  // Use report_error_queue instead.  Keep for Base Class compatibility.
      input BitCheckLog check   // Use report_error_queue instead.  Keep for Base Class compatibility.
   ); // This method does nothing in this class.  Keep for Base Class compatibility.
   endfunction


   virtual function void report_error_queue();
      int i, j;
      logic pass;
      pass = 1'b1;
      $timeformat(-9, 2," ns");
      for (i=0; i<beq.size(); i=i+1)
      begin
         if ( (|beq[i].bit_pos) )
         begin
            $display ("");
            $display ("ERROR:  Register:%s at address:%H_%H has failed bit-level %s check at iteration:%0d with %2d bits in error at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], beq[i].test_name, i, beq[i].error_count(), bcq[i].check_time);
            $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
            pass = 1'b0;
         end
         // Print out the bit positions in error.
         for (j=0; j<64; j=j+1)
         begin
            if (beq[i].bit_pos[j] == 1'b1)
            begin
               $display("        Bit:%2d with attribute:%-5s of register field:%H_%H_%H_%H is:%b and should be:%b", j, check_reg_attr.data[j].name, bcq[i].value[63:48], bcq[i].value[47:32], bcq[i].value[31:16], bcq[i].value[15:0], bcq[i].value[j], beq[i].bit_expected[j]);
            end
         end
         if ( (|beq[i].bit_pos) )
         begin
            $display ("-------------------------------------------------------------------------------------------------------------------------------------------");
         end
      end
      if (pass)
      begin
         $display ("Success: Register:%s at address %H_%H has passed bit-level %s check with %0d iterations at time:%0t.", check_reg_name, reg_addr[19:16], reg_addr[15:0], beq[$].test_name, beq.size(), bcq[$].check_time);
      end
      //else 
      //begin
         $display ("");
      //end
   endfunction

endclass: WriteRandomCheck


endpackage: csr_transaction_class_pkg

`endif // __CSR_TRANSACTION_CLASS_PKG__
