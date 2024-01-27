// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __HOST_TRANSACTION_CLASS_PKG__
`define __HOST_TRANSACTION_CLASS_PKG__

package host_transaction_class_pkg; 

import host_bfm_types_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;

//------------------------------------------------------------------------------
// Enum Definitions for Transactions.
//------------------------------------------------------------------------------

typedef enum {
   CSR_NULL,
   CSR_RD,
   CSR_WR,
   CSR_ATOMIC,
   SEND_MSG,
   SEND_VDM
} transactor_type_t;


typedef byte_t return_data_t[$];

parameter REQUESTER_ID = 16'h0001;
parameter MASTER_REQUEST_DELAY_DEFAULT = 0;
parameter MASTER_COMPLETION_DELAY_DEFAULT = 65;
parameter MASTER_GAP_DELAY_DEFAULT = 5;

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

virtual class Transaction #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);

   // Data Members
   protected transactor_type_t transactor_type;
   protected static uint64_t   master_transaction_number = 0;
   protected uint64_t          transaction_number;
   protected static uint32_t   master_request_delay = MASTER_REQUEST_DELAY_DEFAULT;  // In clock AXI-ST Bus cycles - delay for outgoing request packets.
   protected static uint32_t   master_completion_delay = MASTER_COMPLETION_DELAY_DEFAULT;  // In clock AXI-ST Bus cycles.
   protected static uint32_t   master_gap = MASTER_GAP_DELAY_DEFAULT;  // In clock AXI-ST Bus cycles - minimum distance between outgoing request packets..
   protected uint32_t          request_delay;  // In clock AXI-ST Bus cycles - delay for outgoing request packets.
   protected uint32_t          completion_delay;  // In clock AXI-ST Bus cycles.
   protected uint32_t          gap;  // In clock AXI-ST Bus cycles - minimum distance between outgoing request packets..
   protected string            access_source;
   protected bit               request_sent;
   protected bit               transaction_done;
   protected bit               overflow;
   protected bit               error;
   protected cpl_status_t      cpl_status;
   protected packet_tag_t packet_tag;
   protected int number_of_request_bytes;
   protected int sum_of_completion_bytes;
   protected bit [31:0] return_data32;
   protected bit [63:0] return_data64;
   protected byte_t     return_data[$];
   protected byte_t     cpld_data[];
   protected int        cpld_data_size;
   //------------------------------------------------------
   // Stuff for Derived Classes, but have to include method
   // definitions here:
   Packet#(pf_type, vf_type, pf_list, vf_list) request_packet;
   Packet#(pf_type, vf_type, pf_list, vf_list) completion_queue[$];
   //------------------------------------------------------


   // Constructor
   function new(
      input string access_source
   );
      this.transactor_type = CSR_NULL;
      this.master_transaction_number += 64'd1;
      this.transaction_number = master_transaction_number;
      this.access_source = access_source;
      this.request_sent = 1'b0;
      this.transaction_done = 1'b0;
      this.overflow = 1'b0;
      this.error    = 1'b0;
      this.packet_tag = 10'd0; // Tag set later by Tag Manager in BFM
      this.number_of_request_bytes = 0;
      this.sum_of_completion_bytes = 0;
      this.return_data32 = '0;
      this.return_data64 = '0;
      this.return_data.delete();
      this.completion_queue.delete();
      // Standard Delay values follow.  These may be changed depending on need,
      // but care must be taken not to inadvertently change the order of
      // packets when using different delay values.
      this.request_delay = master_request_delay;
      this.completion_delay = master_request_delay;
      this.gap = master_gap;
   endfunction


   // Methods
   virtual function transactor_type_t get_transactor_type();
      return this.transactor_type;
   endfunction


   virtual function cpl_status_t get_cpl_status();
      return this.cpl_status;
   endfunction


   virtual function uint64_t get_transaction_number();
      return this.transaction_number;
   endfunction


   virtual function void set_pf_vf(pfvf_struct setting);
      this.request_packet.set_pf_vf(setting);
   endfunction


   virtual function void revert_to_last_pfvf_setting();
      this.request_packet.revert_to_last_pfvf_setting();
   endfunction


   virtual function pfvf_struct get_pf_vf();
      return this.request_packet.get_pf_vf();
   endfunction


   virtual function bit [2:0] get_pf_num();
      return this.request_packet.get_pf_num();
   endfunction


   virtual function bit [10:0] get_vf_num();
      return this.request_packet.get_vf_num();
   endfunction


   virtual function bit get_vf_active();
      return this.request_packet.get_vf_active();
   endfunction


   virtual function void set_bar_num(bit[3:0] bar);
      this.request_packet.set_bar_num(bar);
   endfunction


   virtual function void set_slot_num(bit[4:0] slot);
      this.request_packet.set_slot_num(slot);
   endfunction


   virtual function bit [3:0] get_bar_num();
      return this.request_packet.get_bar_num();
   endfunction


   virtual function bit [4:0] get_slot_num();
      return this.request_packet.get_slot_num();
   endfunction


   virtual function void reset_master_delays();
      this.set_master_request_delay(MASTER_REQUEST_DELAY_DEFAULT);
      this.set_master_completion_delay(MASTER_COMPLETION_DELAY_DEFAULT);
      this.set_master_gap(MASTER_GAP_DELAY_DEFAULT);
   endfunction
      


   virtual function void set_master_request_delay(input uint32_t delay);
      this.master_request_delay = delay;
      this.set_request_delay(delay);
   endfunction


   virtual function uint32_t get_master_request_delay();
      return this.master_request_delay;
   endfunction


   virtual function void set_master_completion_delay(input uint32_t delay);
      this.master_completion_delay = delay;
      this.set_completion_delay(delay);
   endfunction


   virtual function uint32_t get_master_completion_delay();
      return this.master_completion_delay;
   endfunction


   virtual function void set_master_gap(input uint32_t gap);
      this.master_gap = gap;
      this.set_gap(gap);
   endfunction


   virtual function uint32_t get_master_gap();
      return this.master_gap;
   endfunction


   virtual function void set_request_delay(input uint32_t delay);
      this.request_delay = delay;
      this.request_packet.set_request_delay(delay);
   endfunction


   virtual function uint32_t get_request_delay();
      return this.request_delay;
   endfunction


   virtual function void set_completion_delay(input uint32_t delay);
      this.completion_delay = delay;
      this.request_packet.set_completion_delay(delay);
   endfunction


   virtual function uint32_t get_completion_delay();
      return this.completion_delay;
   endfunction


   virtual function void set_gap(input uint32_t gap);
      this.gap = gap;
      this.request_packet.set_gap(gap);
   endfunction


   virtual function uint32_t get_gap();
      return this.gap;
   endfunction


   virtual function string get_access_source();
      return this.access_source;
   endfunction


   virtual function void set_access_source(
      input string access_source_in
   );
      this.access_source = access_source_in;
   endfunction


   virtual function bit get_request_sent();
      return this.request_sent;
   endfunction


   virtual function void set_request_sent();
      this.request_sent = 1'b1;
      this.request_packet.set_send_time($realtime);
   endfunction


   virtual function bit transaction_is_done();
      this.calc_number_of_request_bytes();
      this.calc_sum_of_completion_bytes();
      this.transactor_complete_check();
      return (this.transaction_done == 1'b1);
   endfunction


   virtual function bit transaction_is_not_done();
      this.calc_number_of_request_bytes();
      this.calc_sum_of_completion_bytes();
      this.transactor_complete_check();
      return (this.transaction_done == 1'b0);
   endfunction


   virtual function bit overflowed();
      this.calc_number_of_request_bytes();
      this.calc_sum_of_completion_bytes();
      this.transactor_complete_check();
      return (this.overflow == 1'b1);
   endfunction


   virtual function bit not_overflowed();
      this.calc_number_of_request_bytes();
      this.calc_sum_of_completion_bytes();
      this.transactor_complete_check();
      return (this.overflow == 1'b0);
   endfunction


   virtual function bit errored();
      this.calc_number_of_request_bytes();
      this.calc_sum_of_completion_bytes();
      this.transactor_complete_check();
      return (this.error == 1'b1);
   endfunction


   virtual function bit not_errored();
      this.calc_number_of_request_bytes();
      this.calc_sum_of_completion_bytes();
      this.transactor_complete_check();
      return (this.error == 1'b0);
   endfunction


   virtual function packet_tag_t get_packet_tag();
      packet_tag = request_packet.get_tag();
      return this.packet_tag;
   endfunction


   virtual function void set_packet_tag(
      input packet_tag_t tag
   );
      this.packet_tag = tag;
      request_packet.set_tag(tag);
   endfunction


   virtual function int get_number_of_request_bytes();
      this.calc_number_of_request_bytes();
      return this.number_of_request_bytes;
   endfunction


   virtual function int get_sum_of_completion_bytes();
      this.calc_sum_of_completion_bytes();
      return this.sum_of_completion_bytes;
   endfunction


   virtual function bit [31:0] get_return_data32();
      this.transactor_complete_check();
      return this.return_data32;
   endfunction


   virtual function bit [63:0] get_return_data64();
      this.transactor_complete_check();
      return this.return_data64;
   endfunction


   virtual function return_data_t get_return_data();
      this.transactor_complete_check();
      return return_data;
   endfunction


   virtual function void calc_sum_of_completion_bytes();
      sum_of_completion_bytes = 0;
      foreach (completion_queue[i])
      begin
         sum_of_completion_bytes += completion_queue[i].get_payload_size();
      end
  endfunction


   virtual function void add_completion(
      input Packet#(pf_type, vf_type, pf_list, vf_list) completion 
   );
      completion_queue.push_back(completion);
      calc_sum_of_completion_bytes();
   endfunction
       
   
   pure virtual function void print_data();
   pure virtual function void calc_number_of_request_bytes();
   pure virtual function void transactor_complete_check();

   // Empty Methods for Polymorphism Compatibility
   // Read Transactor-Specific Methods
   
   virtual function bit [15:0] get_requester_id();
      return this.request_packet.get_requester_id();
   endfunction


   virtual function uint64_t get_address();
      return this.request_packet.get_addr();
   endfunction


   virtual function void set_address(
      input uint64_t address
   );
      this.request_packet.set_addr(address);
   endfunction


   virtual function bit [9:0] get_length_dw();
      return request_packet.get_length_dw();
   endfunction


   virtual function void set_length_dw(
      input bit [9:0] length_dw
   );
      this.request_packet.set_length_dw(length_dw);
   endfunction


   virtual function bit [3:0] get_first_dw_be();
   // Zero default get method return for polymorphism
      return 4'h0;
   endfunction


   virtual function void set_first_dw_be(
      input bit [3:0] first_dw_be
   );
   // Empty function defined for polymorphism
   endfunction


   virtual function bit [3:0] get_last_dw_be();
   // Zero default get method return for polymorphism
      return 4'h0;
   endfunction


   virtual function void set_last_dw_be(
      input bit [3:0] last_dw_be
   );
   // Empty function defined for polymorphism
   endfunction


   virtual function bit [31:0] get_lower_msg();
   // Zero default get method return for polymorphism
      return 32'h0;
   endfunction


   virtual function bit [31:0] get_upper_msg();
   // Zero default get method return for polymorphism
      return 32'h0;
   endfunction


   virtual function bit [15:0] get_pci_target_id();
   // Zero default get method return for polymorphism
      return 16'h0;
   endfunction


   virtual function bit [15:0] get_vendor_id();
   // Zero default get method return for polymorphism
      return 16'h0;
   endfunction


   virtual function bit [7:0] get_msg_code();
   // Zero default get method return for polymorphism
      return 8'h0;
   endfunction

endclass: Transaction



class ReadTransaction #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends Transaction#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   PacketPUMemReq#(pf_type, vf_type, pf_list, vf_list) read_request_packet;
   

   // Constructor
   function new(
      input string access_source,
      input uint64_t address,
      input bit  [9:0] length_dw,
      input bit  [3:0] first_dw_be,
      input bit  [3:0] last_dw_be
   );
      super.new(
         .access_source(access_source)
      );
      // Immediate Assignements
      this.transactor_type = CSR_RD;
      this.read_request_packet = new(
         .packet_header_op(READ),
         .requester_id(REQUESTER_ID),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      this.request_packet = read_request_packet;
      this.request_packet.set_request_delay(this.request_delay);
      this.request_packet.set_completion_delay(this.completion_delay);
      this.request_packet.set_gap(this.gap);
   endfunction


   virtual function void calc_number_of_request_bytes();
      number_of_request_bytes = read_request_packet.get_expected_completion_length_bytes();
   endfunction


   virtual function void transactor_complete_check();
      int j;
      calc_number_of_request_bytes();
      calc_sum_of_completion_bytes();
      if (this.request_sent == 1'b1)
      begin
         // Check for errors first.
         cpl_status = CPL_SUCCESS;
         foreach (completion_queue[i])
         begin
            if (completion_queue[i].get_cpl_status() != CPL_SUCCESS)
            begin
               this.error = 1'b1;
               cpl_status = completion_queue[i].get_cpl_status();
            end
         end
         // Transaction is done if all bytes received or an error has
         // occurred.
         transaction_done = (sum_of_completion_bytes == number_of_request_bytes) || (this.error);
         if (transaction_done)
         begin

            return_data.delete();
            foreach (completion_queue[i])
            begin
               cpld_data_size = completion_queue[i].get_payload_size();
               cpld_data = new[cpld_data_size];
               completion_queue[i].get_payload(cpld_data);
               for (j = 0; j < cpld_data_size; j++)
               begin
                  return_data.push_back(cpld_data[j]);
               end
            end
            if (return_data.size() == 4)
            begin
               return_data32 = { <<8{return_data}};
               return_data64 = { <<8{return_data}};
               return_data64 = return_data64 >> 32;
            end
            else
            begin
               if (return_data.size() == 8)
               begin
                  return_data32 = '0;
                  return_data64 = { <<8{return_data}};
               end
               else
               begin
                  if(return_data.size() > 8)
                  begin
                     return_data32 = { <<8{return_data[0:3]}};
                     return_data64 = { <<8{return_data[0:7]}};
                  end
                  else
                  begin
                     return_data32 = '0;
                     return_data64 = '0;
                  end
               end
            end
         end
         if (sum_of_completion_bytes > number_of_request_bytes)
         begin
            overflow = 1'b1;
         end
      end
      else
      begin
         transaction_done = 1'b0;
         overflow = 1'b0;
         error    = 1'b0;
         cpl_status = CPL_SUCCESS;
      end
   endfunction


   virtual function bit [15:0] get_requester_id();
      return this.request_packet.get_requester_id();
   endfunction


   virtual function bit [3:0] get_first_dw_be();
      return this.request_packet.get_first_dw_be();
   endfunction


   virtual function void set_first_dw_be(
      input bit [3:0] first_dw_be
   );
      this.request_packet.set_first_dw_be(first_dw_be);
   endfunction


   virtual function bit [3:0] get_last_dw_be();
      return this.request_packet.get_last_dw_be();
   endfunction


   virtual function void set_last_dw_be(
      input bit [3:0] last_dw_be
   );
      this.request_packet.set_last_dw_be(last_dw_be);
   endfunction


   virtual function void print_data();
      this.transactor_complete_check();
      $display("");
      $display(">>> READ TRANSACTION: Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Request Packet: ");
      request_packet.print_packet_long();
      $display("    Completion Packets: %0d", completion_queue.size());
      foreach (completion_queue[i])
      begin
         completion_queue[i].print_packet_long();
      end
      $display("    Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Delay......................: %0d", request_delay);
      $display("    Access Source..............: %-s", access_source);
      $display("    Request Sent...............: %-s", (request_sent == 1'b1) ? "SENT" : "PENDING");
      $display("    Transaction Done...........: %-s", (overflow || error) ? "ERROR" : (transaction_done == 1'b1) ? "DONE" : "PROCESSING");
      $display("    Overflow...................: %-s", (overflow == 1'b1) ? "OVERFLOW" : "NONE");
      $display("    Error......................: %-s::%-s", ((error == 1'b1) ? "ERROR" : "NONE"), cpl_status.name());
      $display("    Packet Tag.................: %H", packet_tag);
      $display("    Number of Request Bytes....: %0d", number_of_request_bytes);
      $display("    Sum of Completion Bytes....: %0d", sum_of_completion_bytes);
      $display("    Return Data 32.............: %H_%H", return_data32[31:16], return_data32[15:0]);
      $display("    Return Data 64.............: %H_%H_%H_%H", return_data64[63:48], return_data64[47:32], return_data64[31:16], return_data64[15:0]);
      $display("    Return Data Array Bytes:%0d", return_data.size());
      if (return_data.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach (return_data[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", return_data[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put extra space in middle of data line for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (return_data.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction

endclass : ReadTransaction


class WriteTransaction #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends ReadTransaction#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   PacketPUMemReq#(pf_type, vf_type, pf_list, vf_list) write_request_packet;
   

   // Constructor
   function new(
      input string access_source,
      input uint64_t address,
      input bit  [9:0] length_dw,
      input bit  [3:0] first_dw_be,
      input bit  [3:0] last_dw_be
   );
      super.new(
         .access_source(access_source),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      // Immediate Assignements
      this.transactor_type = CSR_WR;
      this.write_request_packet = new(
         .packet_header_op(WRITE),
         .requester_id(REQUESTER_ID),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      this.request_packet = write_request_packet;
   endfunction


   virtual function void calc_number_of_request_bytes();
      number_of_request_bytes = write_request_packet.get_expected_completion_length_bytes();
   endfunction


   virtual function void transactor_complete_check();
      byte_t return_data[];
      int payload_size;
      payload_size = request_packet.get_payload_size();
      return_data = new[payload_size];
      request_packet.get_payload(return_data);
      transaction_done = (this.request_sent == 1'b1) ? 1'b1 : 1'b0;
      if (payload_size == 4)
      begin
         return_data32 = { <<8{return_data}};
         return_data64 = { <<8{return_data}};
         return_data64 = return_data64 >> 32;
      end
      else
      begin
         if (payload_size == 8)
         begin
            return_data32 = '0;
            return_data64 = { <<8{return_data}};
         end
         else
         begin
            if(return_data.size() > 8)
            begin
               return_data32 = { <<8{return_data[0:3]}};
               return_data64 = { <<8{return_data[0:7]}};
            end
            else
            begin
               return_data32 = '0;
               return_data64 = '0;
            end
         end
      end
   endfunction


   virtual function void print_data();
      this.transactor_complete_check();
      $display("");
      $display(">>> WRITE TRANSACTION: Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Request Packet: ");
      request_packet.print_packet_long();
      $display("    Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Delay......................: %0d", request_delay);
      $display("    Access Source..............: %-s", access_source);
      $display("    Request Sent...............: %-s", (request_sent == 1'b1) ? "SENT" : "PENDING");
      $display("    Transaction Done...........: %-s", (transaction_done == 1'b1) ? "DONE" : "PROCESSING");
      $display("    Packet Tag.................: %H", packet_tag);
      $display("    Number of Request Bytes....: %0d", number_of_request_bytes);
      $display("");
   endfunction

endclass : WriteTransaction


class AtomicTransaction #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends ReadTransaction#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   PacketPUAtomic#(pf_type, vf_type, pf_list, vf_list) atomic_request_packet;
   

   // Constructor
   function new(
      input string access_source,
      input packet_header_atomic_op_t packet_header_atomic_op,
      input uint64_t address,
      input bit  [9:0] length_dw
   );
      super.new(
         .access_source(access_source),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(4'b1111),
         .last_dw_be(4'b1111)
      );
      // Immediate Assignements
      this.transactor_type = CSR_ATOMIC;
      this.atomic_request_packet = new(
         .packet_header_atomic_op(packet_header_atomic_op),
         .requester_id(REQUESTER_ID),
         .address(address),
         .length_dw(length_dw)
      );
      this.request_packet = atomic_request_packet;
   endfunction


   virtual function void calc_number_of_request_bytes();
      number_of_request_bytes = atomic_request_packet.get_expected_completion_length_bytes();
   endfunction


   virtual function void transactor_complete_check();
      int j;
      calc_number_of_request_bytes();
      calc_sum_of_completion_bytes();
      if (this.request_sent == 1'b1)
      begin
         // Check for errors first.
         cpl_status = CPL_SUCCESS;
         foreach (completion_queue[i])
         begin
            if (completion_queue[i].get_cpl_status() != CPL_SUCCESS)
            begin
               this.error = 1'b1;
               cpl_status = completion_queue[i].get_cpl_status();
            end
         end
         // Transaction is done if all bytes received or an error has
         // occurred.
         transaction_done = (sum_of_completion_bytes == number_of_request_bytes) || (this.error);
         if (transaction_done)
         begin
            return_data.delete();
            foreach (completion_queue[i])
            begin
               cpld_data_size = completion_queue[i].get_payload_size();
               cpld_data = new[cpld_data_size];
               completion_queue[i].get_payload(cpld_data);
               for (j = 0; j < cpld_data_size; j++)
               begin
                  return_data.push_back(cpld_data[j]);
               end
            end
            if (return_data.size() == 4)
            begin
               return_data32 = { <<8{return_data}};
               return_data64 = { <<8{return_data}};
               return_data64 = return_data64 >> 32;
            end
            else
            begin
               if (return_data.size() == 8)
               begin
                  return_data32 = '0;
                  return_data64 = { <<8{return_data}};
               end
            end
         end
         if (sum_of_completion_bytes > number_of_request_bytes)
         begin
            overflow = 1'b1;
         end
      end
      else
      begin
         transaction_done = 1'b0;
         overflow = 1'b0;
         error    = 1'b0;
         cpl_status = CPL_SUCCESS;
      end
   endfunction


   virtual function void print_data();
      this.transactor_complete_check();
      $display("");
      $display(">>> ATOMIC TRANSACTION: Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Request Packet: ");
      request_packet.print_packet_long();
      $display("    Completion Packets: %0d", completion_queue.size());
      foreach (completion_queue[i])
      begin
         completion_queue[i].print_packet_long();
      end
      $display("    Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Delay......................: %0d", request_delay);
      $display("    Access Source..............: %-s", access_source);
      $display("    Request Sent...............: %-s", (request_sent == 1'b1) ? "SENT" : "PENDING");
      $display("    Transaction Done...........: %-s", (overflow) ? "ERROR" : (transaction_done == 1'b1) ? "DONE" : "PROCESSING");
      $display("    Overflow...................: %-s", (overflow == 1'b1) ? "OVERFLOW" : "NONE");
      $display("    Error......................: %-s::%-s", ((error == 1'b1) ? "ERROR" : "NONE"), cpl_status.name());
      $display("    Packet Tag.................: %H", packet_tag);
      $display("    Number of Request Bytes....: %0d", number_of_request_bytes);
      $display("    Sum of Completion Bytes....: %0d", sum_of_completion_bytes);
      $display("    Return Data 32.............: %H_%H", return_data32[31:16], return_data32[15:0]);
      $display("    Return Data 64.............: %H_%H_%H_%H", return_data64[63:48], return_data64[47:32], return_data64[31:16], return_data64[15:0]);
      $display("    Return Data Array Bytes:%0d", return_data.size());
      if (return_data.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach (return_data[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", return_data[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put extra space in middle of data line for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (return_data.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction

endclass : AtomicTransaction


class SendMsgTransaction #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends Transaction#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   PacketPUMsg#(pf_type, vf_type, pf_list, vf_list) msg_packet;
   

   // Constructor
   function new(
      input string access_source,
      input data_present_type_t data_present,
      input msg_route_t         msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [31:0] lower_msg,
      input bit [31:0] upper_msg,
      input bit  [9:0] length_dw
   );
      super.new(
         .access_source(access_source)
      );
      // Immediate Assignements
      this.transactor_type = SEND_MSG;
      this.msg_packet = new(
         .data_present(data_present),
         .msg_route(msg_route),
         .requester_id(requester_id),
         .msg_code(msg_code),
         .lower_msg(lower_msg),
         .upper_msg(upper_msg),
         .length_dw(length_dw)
      );
      this.request_packet = msg_packet;
      this.request_packet.set_request_delay(this.request_delay);
      this.request_packet.set_completion_delay(this.completion_delay);
      this.request_packet.set_gap(this.gap);
   endfunction


   virtual function void calc_number_of_request_bytes();
      number_of_request_bytes = msg_packet.get_expected_completion_length_bytes();
   endfunction


   virtual function void transactor_complete_check();
      byte_t return_data[];
      int payload_size;
      payload_size = request_packet.get_payload_size();
      //$display("MSG TCC: payload size: %0d", payload_size);
      return_data = new[payload_size];
      request_packet.get_payload(return_data);
      transaction_done = (this.request_sent == 1'b1) ? 1'b1 : 1'b0;
      if (payload_size == 4)
      begin
         return_data32 = { <<8{return_data}};
         return_data64 = { <<8{return_data}};
         return_data64 = return_data64 >> 32;
      end
      else
      begin
         if (payload_size == 8)
         begin
            return_data32 = { <<8{return_data[0:3]}};
            return_data64 = { <<8{return_data}};
         end
         else
         begin
            if(return_data.size() > 8)
            begin
               return_data32 = { <<8{return_data[0:3]}};
               return_data64 = { <<8{return_data[0:7]}};
            end
            else
            begin
               return_data32 = '0;
               return_data64 = '0;
            end
         end
      end
   endfunction


   virtual function bit [15:0] get_requester_id();
      return this.request_packet.get_requester_id();
   endfunction


   virtual function bit [31:0] get_lower_msg();
      return this.request_packet.get_lower_msg();
   endfunction


   virtual function bit [31:0] get_upper_msg();
      return this.request_packet.get_upper_msg();
   endfunction


   virtual function bit [15:0] get_pci_target_id();
      return this.request_packet.get_pci_target_id();
   endfunction


   virtual function bit [15:0] get_vendor_id();
      return this.request_packet.get_vendor_id();
   endfunction


   virtual function bit [7:0] get_msg_code();
      return this.request_packet.get_msg_code();
   endfunction


   virtual function void print_data();
      this.transactor_complete_check();
      $display("");
      $display(">>> MSG TRANSACTION: Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Request Packet: ");
      request_packet.print_packet_long();
      $display("    Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Delay......................: %0d", request_delay);
      $display("    Access Source..............: %-s", access_source);
      $display("    Request Sent...............: %-s", (request_sent == 1'b1) ? "SENT" : "PENDING");
      $display("    Transaction Done...........: %-s", (overflow || error) ? "ERROR" : (transaction_done == 1'b1) ? "DONE" : "PROCESSING");
      $display("    Packet Tag.................: %H", packet_tag);
      $display("    Number of Request Bytes....: %0d", number_of_request_bytes);
      $display("    Return Data 32.............: %H_%H", return_data32[31:16], return_data32[15:0]);
      $display("    Return Data 64.............: %H_%H_%H_%H", return_data64[63:48], return_data64[47:32], return_data64[31:16], return_data64[15:0]);
      $display("    Return Data Array Bytes:%0d", return_data.size());
      if (return_data.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach (return_data[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", return_data[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put extra space in middle of data line for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (return_data.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction

endclass : SendMsgTransaction


class SendVDMTransaction #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends Transaction#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   PacketPUVDM#(pf_type, vf_type, pf_list, vf_list) vdm_packet;
   

   // Constructor
   function new(
      input string access_source,
      input data_present_type_t data_present,
      input vdm_msg_route_t         msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [15:0] pci_target_id,
      input bit [15:0] vendor_id,
      input bit  [9:0] length_dw
   );
      super.new(
         .access_source(access_source)
      );
      // Immediate Assignements
      this.transactor_type = SEND_MSG;
      this.vdm_packet = new(
         .data_present(data_present),
         .msg_route(msg_route),
         .requester_id(requester_id),
         .msg_code(msg_code),
         .pci_target_id(pci_target_id),
         .vendor_id(vendor_id),
         .length_dw(length_dw)
      );
      this.request_packet = vdm_packet;
      this.request_packet.set_request_delay(this.request_delay);
      this.request_packet.set_completion_delay(this.completion_delay);
      this.request_packet.set_gap(this.gap);
   endfunction


   virtual function void calc_number_of_request_bytes();
      number_of_request_bytes = vdm_packet.get_expected_completion_length_bytes();
   endfunction


   virtual function void transactor_complete_check();
      byte_t return_data[];
      int payload_size;
      payload_size = request_packet.get_payload_size();
      return_data = new[payload_size];
      request_packet.get_payload(return_data);
      transaction_done = (this.request_sent == 1'b1) ? 1'b1 : 1'b0;
      if (payload_size == 4)
      begin
         return_data32 = { <<8{return_data}};
         return_data64 = { <<8{return_data}};
         return_data64 = return_data64 >> 32;
      end
      else
      begin
         if (payload_size == 8)
         begin
            return_data32 = { <<8{return_data[0:3]}};
            return_data64 = { <<8{return_data}};
         end
         else
         begin
            if(return_data.size() > 8)
            begin
               return_data32 = { <<8{return_data[0:3]}};
               return_data64 = { <<8{return_data[0:7]}};
            end
            else
            begin
               return_data32 = '0;
               return_data64 = '0;
            end
         end
      end
   endfunction


   virtual function bit [15:0] get_requester_id();
      return this.request_packet.get_requester_id();
   endfunction


   virtual function bit [31:0] get_lower_msg();
      return this.request_packet.get_lower_msg();
   endfunction


   virtual function bit [31:0] get_upper_msg();
      return this.request_packet.get_upper_msg();
   endfunction


   virtual function bit [15:0] get_pci_target_id();
      return this.request_packet.get_pci_target_id();
   endfunction


   virtual function bit [15:0] get_vendor_id();
      return this.request_packet.get_vendor_id();
   endfunction


   virtual function bit [7:0] get_msg_code();
      return this.request_packet.get_msg_code();
   endfunction


   virtual function bit [3:0] get_mctp_vdm_code();
      return this.request_packet.get_mctp_vdm_code();
   endfunction


   virtual function void set_mctp_vdm_code(input bit [3:0] vdm_code);
      this.request_packet.set_mctp_vdm_code(vdm_code);
   endfunction


   virtual function bit [3:0] get_mctp_header_version();
      return this.request_packet.get_mctp_header_version();
   endfunction


   virtual function void set_mctp_header_version(input bit [3:0] header_version);
      this.request_packet.set_mctp_header_version(header_version);
   endfunction


   virtual function bit [7:0] get_mctp_destination_endpoint_id();
      return this.request_packet.get_mctp_destination_endpoint_id();
   endfunction


   virtual function void set_mctp_destination_endpoint_id(bit [7:0] destination_endpoint_id);
      this.request_packet.set_mctp_destination_endpoint_id(destination_endpoint_id);
   endfunction


   virtual function bit [7:0] get_mctp_source_endpoint_id();
      return this.request_packet.get_mctp_source_endpoint_id();
   endfunction


   virtual function void set_mctp_source_endpoint_id(bit [7:0] source_endpoint_id);
      this.request_packet.set_mctp_source_endpoint_id(source_endpoint_id);
   endfunction


   virtual function bit get_mctp_som();
      return this.request_packet.get_mctp_som();
   endfunction


   virtual function void set_mctp_som(input bit som);
      this.request_packet.set_mctp_som(som);
   endfunction


   virtual function bit get_mctp_eom();
      return this.request_packet.get_mctp_eom();
   endfunction


   virtual function void set_mctp_eom(input bit eom);
      this.request_packet.set_mctp_eom(eom);
   endfunction


   virtual function bit [1:0] get_mctp_packet_sequence_number();
      return this.request_packet.get_mctp_packet_sequence_number();
   endfunction


   virtual function void set_mctp_packet_sequence_number(input bit [1:0] psn);
      this.request_packet.set_mctp_packet_sequence_number(psn);
   endfunction


   virtual function bit get_mctp_tag_owner();
      return this.request_packet.get_mctp_tag_owner();
   endfunction


   virtual function void set_mctp_tag_owner(input bit tag_owner);
      this.request_packet.set_mctp_tag_owner(tag_owner);
   endfunction


   virtual function bit [2:0] get_mctp_message_tag();
      return this.request_packet.get_mctp_message_tag();
   endfunction


   virtual function void set_mctp_message_tag(input bit [2:0] message_tag);
      this.request_packet.set_mctp_message_tag(message_tag);
   endfunction


   virtual function void print_data();
      this.transactor_complete_check();
      $display("");
      $display(">>> VDM TRANSACTION: Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Request Packet: ");
      request_packet.print_packet_long();
      $display("    Printing information for transactor number: %H_%H_%H_%H", transaction_number[63:48], transaction_number[47:32], transaction_number[31:16], transaction_number[15:0]);
      $display("    Delay......................: %0d", request_delay);
      $display("    Access Source..............: %-s", access_source);
      $display("    Request Sent...............: %-s", (request_sent == 1'b1) ? "SENT" : "PENDING");
      $display("    Transaction Done...........: %-s", (overflow || error) ? "ERROR" : (transaction_done == 1'b1) ? "DONE" : "PROCESSING");
      $display("    Packet Tag.................: %H", packet_tag);
      $display("    Number of Request Bytes....: %0d", number_of_request_bytes);
      $display("    Return Data 32.............: %H_%H", return_data32[31:16], return_data32[15:0]);
      $display("    Return Data 64.............: %H_%H_%H_%H", return_data64[63:48], return_data64[47:32], return_data64[31:16], return_data64[15:0]);
      $display("    Return Data Array Bytes:%0d", return_data.size());
      if (return_data.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach (return_data[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", return_data[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put extra space in middle of data line for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (return_data.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction

endclass : SendVDMTransaction


endpackage: host_transaction_class_pkg

`endif // __HOST_TRANSACTION_CLASS_PKG__
