// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __HOST_MEMORY_CLASS_PKG__
`define __HOST_MEMORY_CLASS_PKG__

package host_memory_class_pkg; 

import host_bfm_types_pkg::*;

//------------------------------------------------------------------------------
// Parameter and Enum Definitions for Host Memory.
//------------------------------------------------------------------------------
parameter MEM_ADDR_WIDTH  = 64;

typedef enum {
    RD,
    RD_HOST,
    RD_UNINITIALIZED,
    RD_HOST_UNINITIALIZED,
    WR,
    WR_HOST,
    WR_BLOCKED,
    WR_PROTECT,
    WR_UNPROTECT,
    INITIALIZE,
    COPY,
    COPY_BLOCKED,
    ATOMIC_OP_READ_UNINITIALIZED,
    ATOMIC_OP_READ,
    ATOMIC_FETCH_ADD,
    ATOMIC_SWAP,
    ATOMIC_COMP_SWAP,
    ATOMIC_OP_BLOCKED,
    CREATED
} access_type_t;

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

class MemoryAccess;
   protected byte_t        access_data;
   protected realtime      access_time;
   protected access_type_t access_type;
   protected string        access_source;
   protected packet_tag_t  packet_tag;


   function new(
      input byte_t access_data,
      input realtime access_time,
      input access_type_t access_type,
      input string access_source,
      input packet_tag_t packet_tag
   );
      this.access_data = access_data;
      this.access_time = access_time;
      this.access_type = access_type;
      this.access_source = access_source;
      this.packet_tag = packet_tag;
   endfunction


   function void set_access_source(
      input string source
   );
      this.access_source = source;
   endfunction : set_access_source


   function void set_packet_tag(
      input packet_tag_t tag
   );
      this.packet_tag = tag;
   endfunction : set_packet_tag


   function byte_t get_access_data();
      return access_data;
   endfunction : get_access_data


   function realtime get_access_time();
      return access_time;
   endfunction : get_access_time


   function string get_access_type_name();
      return access_type.name();
   endfunction : get_access_type_name


   function access_type_t get_access_type();
      return access_type;
   endfunction : get_access_type


   function string get_access_source();
      return access_source;
   endfunction : get_access_source


   function packet_tag_t get_packet_tag();
      return packet_tag;
   endfunction : get_packet_tag


   function void print(
      uint32_t access_type_maxlen
   );
      string access_type_format;
      string access_type_string;

      access_type_format = $sformatf("%%%0ds", access_type_maxlen);
      access_type_string = $sformatf(access_type_format, access_type.name());
      $display("   %s --- data:%H  tag:%H  source:%s  time:%0t", access_type_string, access_data, packet_tag, access_source, access_time);
   endfunction : print

endclass: MemoryAccess


class MemoryEntry;
   protected string       memory_name;
   protected addr_t       addr;
   protected bit          written;
   protected bit          initialized;
   protected bit          locked;
   protected byte_t       data;
   protected bit          last_access_was_write;
   protected packet_tag_t last_tag;
   protected string       last_source;
   protected MemoryAccess access;
   protected MemoryAccess accesses [$];


   function new(
      input string memory_name,
      input addr_t addr
   );
      this.memory_name = memory_name;
      this.addr = addr;
      this.data = 8'hxx;
      this.written = 1'b0;
      this.initialized = 1'b0;
      this.locked = 1'b0;
      this.last_access_was_write = 1'b0;
      this.last_tag = 10'h000;
      this.last_source = "";
      this.access = new(this.data, $realtime, CREATED, "Testbench", 10'h000);
      this.accesses.delete() ;  //Clears access queue
      this.accesses.push_back(this.access);
   endfunction


   function byte_t read_data(
      input string       access_source,
      input packet_tag_t packet_tag
   );
      if (!initialized && !written)
      begin
         access = new(data, $realtime, RD_UNINITIALIZED, access_source, packet_tag);
         accesses.push_back(access);
         $display("HOST MEMORY Warning[%s]: Read attempted at uninitialized address:%H_%H_%H_%H with data:%H and packet tag:%H at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
      end
      else
      begin
         access = new(data, $realtime, RD, access_source, packet_tag);
         accesses.push_back(access);
         //$display("HOST MEMORY Read[%s]: Read at address:%H_%H_%H_%H returns data:%H with packet tag:%H at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
      end
      last_access_was_write = 1'b0;
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
      return data;
   endfunction : read_data


   function byte_t read_data_host();
      if (!initialized && !written)
      begin
         access = new(data, $realtime, RD_HOST_UNINITIALIZED, "Host", 10'h000);
         accesses.push_back(access);
         $display("HOST MEMORY Warning[%s]: Host Read attempted at uninitialized address:%H_%H_%H_%H with data:%H at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_access_time());
      end
      else
      begin
         access = new(data, $realtime, RD_HOST, "Host", 10'h000);
         accesses.push_back(access);
         //$display("HOST MEMORY Read[%s]: Host Read at address:%H_%H_%H_%H returns data:%H at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_access_time());
      end
      last_access_was_write = 1'b0;
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
      return data;
   endfunction : read_data_host


   function byte_t atomic_read_data(
      input string        access_source,
      input access_type_t atomic_access_type,
      input packet_tag_t  packet_tag
   );
      if (!initialized && !written)
      begin
         access = new(data, $realtime, ATOMIC_OP_READ_UNINITIALIZED, access_source, packet_tag);
         accesses.push_back(access);
         $display("HOST MEMORY Warning[%s]: Atomic Read attempted at uninitialized address:%H_%H_%H_%H with data:%H and packet tag:%H at time:%0t.  Atomic Op: %s", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time(), atomic_access_type.name());
      end
      else
      begin
         access = new(data, $realtime, ATOMIC_OP_READ, access_source, packet_tag);
         accesses.push_back(access);
         //$display("HOST MEMORY Read[%s]: Atomic Read at address:%H_%H_%H_%H returns data:%H with packet tag:%H at time:%0t.  Atomic Op: %s", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time(), atomic_access_type.name());
      end
      last_access_was_write = 1'b0;
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
      return data;
   endfunction : atomic_read_data


   function void write_data(
      input byte_t       data,
      input string       access_source,
      input packet_tag_t packet_tag
   );
      if (locked)
      begin
         access = new(data, $realtime, WR_BLOCKED, access_source, packet_tag);
         accesses.push_back(access);
         $display("HOST MEMORY ERROR[%s]: Write attempted at locked address:%H_%H_%H_%H with data:%H and packet tag:%H at time:%0t was denied.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
      end
      else
      begin
         access = new(data, $realtime, WR, access_source, packet_tag);
         accesses.push_back(access);
         this.data = data;
         //$display("HOST MEMORY Write[%s]: Write at address:%H_%H_%H_%H with data:%H with packet tag:%H at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
         written = 1'b1;
         if (last_access_was_write)
         begin
            // The following message creates a huge transcript file for HE-LB
            // where large dumps of memory are done over and over again.  For
            // now, this message is disabled.  Re-enable if some
            // double-writing is suspected as a bug.
            //$display("HOST MEMORY Warning[%s]: Memory location written twice without being read at address:%H_%H_%H_%H with data:%H and packet tag:%H at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
         end
         last_access_was_write = 1'b1;
      end
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
   endfunction : write_data


   function void atomic_write_data(
      input byte_t        data,
      input string        access_source,
      input access_type_t atomic_access_type,
      input packet_tag_t  packet_tag
   );
      if (locked)
      begin
         access = new(data, $realtime, ATOMIC_OP_BLOCKED, access_source, packet_tag);
         accesses.push_back(access);
         $display("HOST MEMORY ERROR[%s]: Atomic Write attempted at locked address:%H_%H_%H_%H with data:%H and packet tag:%H at time:%0t was denied.  Atomic Op: %s", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time(), atomic_access_type.name());
      end
      else
      begin
         access = new(data, $realtime, atomic_access_type, access_source, packet_tag);
         accesses.push_back(access);
         this.data = data;
         //$display("HOST MEMORY Write[%s]: Atomic Op %s result written at address:%H_%H_%H_%H with data:%H with packet tag:%H at time:%0t.", memory_name, atomic_access_type.name(), addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
         written = 1'b1;
         last_access_was_write = 1'b1;
      end
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
   endfunction : atomic_write_data


   function void copy_data(
      input addr_t       source_addr,
      input byte_t       data
   );
      string copy_source;
      packet_tag_t copy_tag = 10'h000;
      if (locked)
      begin
         access = new(data, $realtime, COPY_BLOCKED, copy_source, copy_tag);
         accesses.push_back(access);
         $display("HOST MEMORY ERROR[%s]: Memory copy attempted from source address:%H_%H_%H_%H to destination locked address:%H_%H_%H_%H with data:%H at time:%0t was denied.", memory_name, source_addr[63:48], source_addr[47:32], source_addr[31:16], source_addr[15:0], addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
      end
      else
      begin
         access = new(data, $realtime, COPY, copy_source, copy_tag);
         accesses.push_back(access);
         this.data = data;
         //$display("HOST MEMORY Copy[%s]: Memory copy from source address:%H_%H_%H_%H to destination address:%H_%H_%H_%H with data:%H at time:%0t.", memory_name, source_addr[63:48], source_addr[47:32], source_addr[31:16], source_addr[15:0], addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
         written = 1'b1;
         if (last_access_was_write)
         begin
            $display("HOST MEMORY Warning[%s]: Memory location written and copied over without being read from source address:%H_%H_%H_%H at address:%H_%H_%H_%H with data:%H at time:%0t.", memory_name, source_addr[63:48], source_addr[47:32], source_addr[31:16], source_addr[15:0], addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_packet_tag(), access.get_access_time());
         end
         last_access_was_write = 1'b1;
      end
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
   endfunction : copy_data


   function void initialize(
      input byte_t data
   );
      access = new(data, $realtime, INITIALIZE, "Testbench", 10'h000);
      accesses.push_back(access);
      this.data = data;
      //$display("HOST MEMORY Write[%s]: Memory Initialization at address:%H_%H_%H_%H with data:%H at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], access.get_access_data(), access.get_access_time());
      initialized = 1'b1;
      written = 1'b0;
      last_access_was_write = 1'b0;
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
   endfunction : initialize


   function void write_protect_on();
      access = new(data, $realtime, WR_PROTECT, "Testbench", 10'h000);
      accesses.push_back(access);
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
      locked = 1'b1;
   endfunction : write_protect_on


   function void write_protect_off();
      access = new(data, $realtime, WR_UNPROTECT, "Testbench", 10'h000);
      accesses.push_back(access);
      last_source = access.get_access_source();
      last_tag    = access.get_packet_tag();
      locked = 1'b0;
   endfunction : write_protect_off


   function addr_t get_addr();
      return addr;
   endfunction : get_addr


   function bit get_written_status();
      return written;
   endfunction : get_written_status


   function bit get_initialized_status();
      return initialized;
   endfunction : get_initialized_status


   function bit get_write_protect_status();
      return locked;
   endfunction : get_write_protect_status


   function byte_t get_data();
      return data;
   endfunction : get_data


   function bit get_last_access_was_write_status();
      return last_access_was_write;
   endfunction : get_last_access_was_write_status


   function packet_tag_t get_last_tag();
      return last_tag;
   endfunction : get_last_tag


   function string get_last_source();
      return last_source;
   endfunction : get_last_source


   function MemoryAccess get_last_memory_access();
      return access;
   endfunction : get_last_memory_access


   function uint64_t get_number_of_accesses();
      return uint64_t'(accesses.size());
   endfunction : get_number_of_accesses


   function uint64_t get_number_of_writes();
      uint64_t count;
      count = 64'd0;
      foreach (accesses[i])
      begin
         if (accesses[i].get_access_type() == WR)
            count += 64'd1;
      end
      return count;
   endfunction : get_number_of_writes


   function uint64_t get_number_of_blocked_writes();
      uint64_t count;
      count = 64'd0;
      foreach (accesses[i])
      begin
         if (accesses[i].get_access_type() == WR_BLOCKED)
            count += 64'd1;
      end
      return count;
   endfunction : get_number_of_blocked_writes


   function uint64_t get_number_of_reads();
      uint64_t count;
      count = 64'd0;
      foreach (accesses[i])
      begin
         if (accesses[i].get_access_type() == RD)
            count += 64'd1;
      end
      return count;
   endfunction : get_number_of_reads


   function uint64_t get_number_of_uninitialized_reads();
      uint64_t count;
      count = 64'd0;
      foreach (accesses[i])
      begin
         if (accesses[i].get_access_type() == RD_UNINITIALIZED)
            count += 64'd1;
      end
      return count;
   endfunction : get_number_of_uninitialized_reads


   function void print_all_accesses();
      uint32_t maxlen;
      string access_type;

      if (accesses.size() > 0)
      begin
         maxlen = 0;
         foreach (accesses[i])
         begin
            access_type = accesses[i].get_access_type_name();
            if (access_type.len() > maxlen)
            begin
               maxlen = access_type.len();
            end
         end
         $display("HOST MEMORY Message[%s]: Access list for memory location at address:%H_%H_%H_%H --- data:%H --- at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], data, $realtime);
         foreach (accesses[i])
         begin
            accesses[i].print(maxlen);
         end
      end
      else
      begin
         $display("HOST MEMORY Message[%s]: Memory location at address:%H_%H_%H_%H --- data:%H --- has no accesses to display at time:%0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], data, $realtime);
      end
   endfunction : print_all_accesses

endclass: MemoryEntry


class HostMemory;
   protected string      memory_name;
   protected MemoryEntry host_memory [addr_t];


   function new (
      input string memory_name
   );
      this.memory_name = memory_name;
   endfunction


   function void read_data(
      input addr_t start_addr,
      input string access_source,
      input packet_tag_t packet_tag,
      ref byte_t read_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(read_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         read_buf[i] = host_memory[addr].read_data(access_source, packet_tag);
         addr = addr + 64'd1;
      end
   endfunction : read_data


   function void read_data_host(
      input addr_t start_addr,
      ref byte_t read_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(read_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         read_buf[i] = host_memory[addr].read_data_host();
         addr = addr + 64'd1;
      end
   endfunction : read_data_host


   function void atomic_read_data(
      input addr_t start_addr,
      input string access_source,
      input access_type_t atomic_access_type,
      input packet_tag_t packet_tag,
      ref byte_t read_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(read_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         read_buf[i] = host_memory[addr].atomic_read_data(access_source, atomic_access_type, packet_tag);
         addr = addr + 64'd1;
      end
   endfunction : atomic_read_data


   function void write_data(
      input addr_t start_addr,
      input string access_source,
      input packet_tag_t packet_tag,
      ref byte_t write_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(write_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         host_memory[addr].write_data(write_buf[i], access_source, packet_tag);
         addr = addr + 64'd1;
      end
   endfunction : write_data


   function void atomic_write_data(
      input addr_t start_addr,
      input string access_source,
      input access_type_t atomic_access_type,
      input packet_tag_t packet_tag,
      ref byte_t write_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(write_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         host_memory[addr].atomic_write_data(write_buf[i], access_source, atomic_access_type, packet_tag);
         addr = addr + 64'd1;
      end
   endfunction : atomic_write_data


   function void initialize_data(
      input addr_t start_addr,
      ref byte_t init_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(init_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         host_memory[addr].initialize(init_buf[i]);
         addr = addr + 64'd1;
      end
   endfunction : initialize_data


   function void write_protect_mem_on(
      input addr_t start_addr,
      input uint64_t count
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < count; i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         host_memory[addr].write_protect_on();
         addr = addr + 64'd1;
      end
   endfunction : write_protect_mem_on


   function void write_protect_mem_off(
      input addr_t start_addr,
      input uint64_t count
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < count; i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         host_memory[addr].write_protect_off();
         addr = addr + 64'd1;
      end
   endfunction : write_protect_mem_off


   function string get_memory_name();
      return memory_name;
   endfunction : get_memory_name


   function void get_written_data(
      input addr_t start_addr,
      ref bit written_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(written_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         written_buf[i] = host_memory[addr].get_written_status();
         addr = addr + 64'd1;
      end
   endfunction : get_written_data


   function void get_initialized_data(
      input addr_t start_addr,
      ref bit initialized_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(initialized_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         initialized_buf[i] = host_memory[addr].get_initialized_status();
         addr = addr + 64'd1;
      end
   endfunction : get_initialized_data


   function void get_write_protect_data(
      input addr_t start_addr,
      ref bit write_protect_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(write_protect_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         write_protect_buf[i] = host_memory[addr].get_write_protect_status();
         addr = addr + 64'd1;
      end
   endfunction : get_write_protect_data


   function void get_last_access_was_write_data(
      input addr_t start_addr,
      ref bit last_access_was_write_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(last_access_was_write_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         last_access_was_write_buf[i] = host_memory[addr].get_last_access_was_write_status();
         addr = addr + 64'd1;
      end
   endfunction : get_last_access_was_write_data


   function void get_last_tag_data(
      input addr_t start_addr,
      ref packet_tag_t last_tag_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(last_tag_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         last_tag_buf[i] = host_memory[addr].get_last_tag();
         addr = addr + 64'd1;
      end
   endfunction : get_last_tag_data


   function void get_last_source_data(
      input addr_t start_addr,
      ref string last_source_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(last_source_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         last_source_buf[i] = host_memory[addr].get_last_source();
         addr = addr + 64'd1;
      end
   endfunction : get_last_source_data


   function void get_last_memory_access_data(
      input addr_t start_addr,
      ref MemoryAccess last_memory_access_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < uint64_t'(last_memory_access_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         last_memory_access_buf[i] = host_memory[addr].get_last_memory_access();
         addr = addr + 64'd1;
      end
   endfunction : get_last_memory_access_data


   function uint64_t get_number_of_memory_accesses(
      input addr_t start_addr,
      ref uint64_t number_of_memory_accesses_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      uint64_t total = 64'd0;
      for (uint64_t i = 64'd0; i < uint64_t'(number_of_memory_accesses_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         number_of_memory_accesses_buf[i] = host_memory[addr].get_number_of_accesses();
         total = total + host_memory[addr].get_number_of_accesses();
         addr = addr + 64'd1;
      end
      return total;
   endfunction : get_number_of_memory_accesses


   function uint64_t get_number_of_writes(
      input addr_t start_addr,
      ref uint64_t number_of_writes_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      uint64_t total = 64'd0;
      for (uint64_t i = 64'd0; i < uint64_t'(number_of_writes_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         number_of_writes_buf[i] = host_memory[addr].get_number_of_writes();
         total = total + host_memory[addr].get_number_of_writes();
         addr = addr + 64'd1;
      end
      return total;
   endfunction : get_number_of_writes


   function uint64_t get_number_of_blocked_writes(
      input addr_t start_addr,
      ref uint64_t number_of_blocked_writes_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      uint64_t total = 64'd0;
      for (uint64_t i = 64'd0; i < uint64_t'(number_of_blocked_writes_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         number_of_blocked_writes_buf[i] = host_memory[addr].get_number_of_blocked_writes();
         total = total + host_memory[addr].get_number_of_blocked_writes();
         addr = addr + 64'd1;
      end
      return total;
   endfunction : get_number_of_blocked_writes


   function uint64_t get_number_of_reads(
      input addr_t start_addr,
      ref uint64_t number_of_reads_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      uint64_t total = 64'd0;
      for (uint64_t i = 64'd0; i < uint64_t'(number_of_reads_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         number_of_reads_buf[i] = host_memory[addr].get_number_of_reads();
         total = total + host_memory[addr].get_number_of_reads();
         addr = addr + 64'd1;
      end
      return total;
   endfunction : get_number_of_reads


   function uint64_t get_number_of_uninitialized_reads(
      input addr_t start_addr,
      ref uint64_t number_of_uninitialized_reads_buf[]
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      uint64_t total = 64'd0;
      for (uint64_t i = 64'd0; i < uint64_t'(number_of_uninitialized_reads_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         number_of_uninitialized_reads_buf[i] = host_memory[addr].get_number_of_uninitialized_reads();
         total = total + host_memory[addr].get_number_of_uninitialized_reads();
         addr = addr + 64'd1;
      end
      return total;
   endfunction : get_number_of_uninitialized_reads


   function bit data_match(
      input addr_t first_start_addr,
      input addr_t second_start_addr,
      ref bit      data_match_buf[]
   );
      addr_t first_addr = first_start_addr;
      addr_t second_addr = second_start_addr;
      MemoryEntry memory_entry;
      bit match = 1'b1;
      for (uint64_t i = 64'd0; i < uint64_t'(data_match_buf.size()); i += 64'd1)
      begin
         if (!host_memory.exists(first_addr))
         begin
            memory_entry = new(memory_name, first_addr);
            host_memory[first_addr] = memory_entry;
         end
         if (!host_memory.exists(second_addr))
         begin
            memory_entry = new(memory_name, second_addr);
            host_memory[second_addr] = memory_entry;
         end
         if (host_memory[first_addr].get_data() === host_memory[second_addr].get_data())
         begin
            data_match_buf[i] = 1'b1;
         end
         else
         begin
            match = 1'b0;
            data_match_buf[i] = 1'b0;
         end
         first_addr = first_addr + 64'd1;
         second_addr = second_addr + 64'd1;
      end
      return match;
   endfunction : data_match


   function void data_copy(
      input addr_t source_start_addr,
      input addr_t destination_start_addr,
      input uint64_t count
   );
      addr_t source_addr = source_start_addr;
      addr_t destination_addr = destination_start_addr;
      MemoryEntry memory_entry;
      byte_t copy_data;
      for (uint64_t i = 64'd0; i < count; i += 64'd1)
      begin
         if (!host_memory.exists(source_addr))
         begin
            memory_entry = new(memory_name, source_addr);
            host_memory[source_addr] = memory_entry;
         end
         if (!host_memory.exists(destination_addr))
         begin
            memory_entry = new(memory_name, destination_addr);
            host_memory[destination_addr] = memory_entry;
         end
         host_memory[destination_addr].copy_data(host_memory[source_addr].get_addr(), host_memory[source_addr].get_data());
         source_addr = source_addr + 64'd1;
         destination_addr = destination_addr + 64'd1;
      end
   endfunction : data_copy


   function void atomic_fetch_add(
      input addr_t addr,
      input string access_source,
      input packet_tag_t packet_tag,
      ref byte_t addend[],
      ref byte_t result[]
   );
      byte_t sum_bytes[]; 
      int addend32;
      int data32;
      int sum32;
      longint addend64;
      longint data64;
      longint sum64;
      if ( ((result.size() == 4) && (addend.size() == 4)) || ((result.size() == 8) && (addend.size() == 8)) )
      begin
         atomic_read_data(addr, access_source, ATOMIC_FETCH_ADD, packet_tag, result);
         if (result.size() == 4)
         begin
            data32 = {<<8{result}};
            addend32 = {<<8{addend}};
            sum32 = data32 + addend32;
            sum_bytes = {<<byte_t{sum32}};
            //$display("HOST MEMORY Atomic Op[%s]: Atomic Fetch-Add at address:%H_%H_%H_%H with addend:%H_%H with packet tag:%H at time:%0t.  Atomic Fetch-Add return value:%H_%H, New memory value: %H_%H.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], addend32[31:16], addend32[15:0], packet_tag, $realtime, data32[31:16], data32[15:0], sum32[31:16], sum32[15:0]);
         end
         else
         begin
            data64 = {<<8{result}};
            addend64 = {<<8{addend}};
            sum64 = data64 + addend64;
            sum_bytes = {<<byte_t{sum64}};
            //$display("HOST MEMORY Atomic Op[%s]: Atomic Fetch-Add at address:%H_%H_%H_%H with addend:%H_%H_%H_%H with packet tag:%H at time:%0t.  Atomic Fetch-Add return value:%H_%H_%H_%H, New memory value: %H_%H_%H_%H.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], addend64[63:48], addend64[47:32], addend64[31:16], addend64[15:0], packet_tag, $realtime, data64[63:48], data64[47:32], data64[31:16], data64[15:0], sum64[63:48], sum64[47:32], sum64[31:16], sum64[15:0]);
         end
         atomic_write_data(addr, access_source, ATOMIC_FETCH_ADD, packet_tag, sum_bytes);
      end
      else
      begin
         $display("HOST MEMORY ERROR[%s]: Atomic Fetch-Add at address:%H_%H_%H_%H has one or more data members with incorrect data width.  Addend and Result references must both have a matching 4-byte or 8-byte width or the Atomic Op is aborted.  Addend width is: %0d and Result width is: %0d.  This occurred with packet tag: %H at time: %0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], addend.size(), result.size(), packet_tag, $realtime);
      end
   endfunction : atomic_fetch_add
   

   function void atomic_swap(
      input addr_t addr,
      input string access_source,
      input packet_tag_t packet_tag,
      ref byte_t swap[],
      ref byte_t result[]
   );
      if ( ((result.size() == 4) && (swap.size() == 4)) || ((result.size() == 8) && (swap.size() == 8)) )
      begin
         atomic_read_data(addr, access_source, ATOMIC_SWAP, packet_tag, result);
         if (result.size() == 4)
         begin
            //$display("HOST MEMORY Atomic Op[%s]: Atomic Swap at address:%H_%H_%H_%H with swap value:%H_%H with packet tag:%H at time:%0t.  Atomic Swap return value:%H_%H.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], {swap[3],swap[2]}, {swap[1],swap[0]}, packet_tag, $realtime, {result[3],result[2]}, {result[1],result[0]});
         end
         else
         begin
            //$display("HOST MEMORY Atomic Op[%s]: Atomic Swap at address:%H_%H_%H_%H with swap value:%H_%H_%H_%H with packet tag:%H at time:%0t.  Atomic Swap return value:%H_%H_%H_%H.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], {swap[7],swap[6]}, {swap[5],swap[4]}, {swap[3],swap[2]}, {swap[1],swap[0]}, packet_tag, $realtime, {result[7],result[6]}, {result[5],result[4]}, {result[3],result[2]}, {result[1],result[0]});
         end
         atomic_write_data(addr, access_source, ATOMIC_SWAP, packet_tag, swap);
      end
      else
      begin
         $display("HOST MEMORY ERROR[%s]: Atomic Swap at address:%H_%H_%H_%H has one or more data members with incorrect data width.  Swap and Result references must both have a matching 4-byte or 8-byte width or the Atomic Op is aborted.  Swap width is: %0d and Result width is: %0d.  This occurred with packet tag: %H at time: %0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], swap.size(), result.size(), packet_tag, $realtime);
      end
   endfunction : atomic_swap


   function void atomic_compare_and_swap(
      input addr_t addr,
      input string access_source,
      input packet_tag_t packet_tag,
      ref byte_t compare[],
      ref byte_t swap[],
      ref byte_t result[]
   );
      byte_t    sum_bytes[]; 
      uint32_t  compare32;
      uint32_t  data32;
      uint64_t  compare64;
      uint64_t  data64;
      uint128_t compare128;
      uint128_t data128;
      if ( ((result.size() == 4) && (compare.size() == 4) && (swap.size() == 4)) || ((result.size() == 8) && (compare.size() == 8) && (swap.size() == 8)) || ((result.size() == 16) && (compare.size() == 16)) )
      begin
         atomic_read_data(addr, access_source, ATOMIC_COMP_SWAP, packet_tag, result);
         if (result.size() == 4)
         begin
            data32 = {<<8{result}};
            compare32 = {<<8{compare}};
            if (data32 === compare32)
            begin
               atomic_write_data(addr, access_source, ATOMIC_COMP_SWAP, packet_tag, swap);
               //$display("HOST MEMORY Atomic Op[%s]: Atomic Compare-and-Swap at address:%H_%H_%H_%H with compare value:%H_%H with packet tag:%H at time:%0t.  Atomic Compare-and-Swap return value:%H_%H, memory value was swapped.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], compare32[31:16], compare32[15:0], packet_tag, $realtime, data32[31:16], data32[15:0]);
            end
            else
            begin
               //$display("HOST MEMORY Atomic Op[%s]: Atomic Compare-and-Swap at address:%H_%H_%H_%H with compare value:%H_%H with packet tag:%H at time:%0t.  Atomic Compare-and-Swap return value:%H_%H, memory value was NOT swapped.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], compare32[31:16], compare32[15:0], packet_tag, $realtime, data32[31:16], data32[15:0]);
            end
         end
         else
         begin
            if (result.size() == 8)
            begin
               data64 = {<<8{result}};
               compare64 = {<<8{compare}};
               if (data64 === compare64)
               begin
                  atomic_write_data(addr, access_source, ATOMIC_COMP_SWAP, packet_tag, swap);
                  //$display("HOST MEMORY Atomic Op[%s]: Atomic Compare-and-Swap at address:%H_%H_%H_%H with compare value:%H_%H_%H_%H with packet tag:%H at time:%0t.  Atomic Compare-and-Swap return value:%H_%H_%H_%H, memory value was swapped.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], compare64[63:48], compare64[47:32], compare64[31:16], compare64[15:0], packet_tag, $realtime, data64[63:48], data64[47:32], data64[31:16], data64[15:0]);
               end
               else
               begin
                  //$display("HOST MEMORY Atomic Op[%s]: Atomic Compare-and-Swap at address:%H_%H_%H_%H with compare value:%H_%H_%H_%H with packet tag:%H at time:%0t.  Atomic Compare-and-Swap return value:%H_%H_%H_%H, memory value was NOT swapped.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], compare64[63:48], compare64[47:32], compare64[31:16], compare64[15:0], packet_tag, $realtime, data64[63:48], data64[47:32], data64[31:16], data64[15:0]);
               end
            end
            else
            begin
               data128 = {<<8{result}};
               compare128 = {<<8{compare}};
               if (data128 === compare128)
               begin
                  atomic_write_data(addr, access_source, ATOMIC_COMP_SWAP, packet_tag, swap);
                  //$display("HOST MEMORY Atomic Op[%s]: Atomic Compare-and-Swap at address:%H_%H_%H_%H with compare value:%H_%H_%H_%H_%H_%H_%H_%H with packet tag:%H at time:%0t.  Atomic Compare-and-Swap return value:%H_%H_%H_%H_%H_%H_%H_%H, memory value was swapped.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], compare128[127:112], compare128[111:96], compare128[95:80], compare128[79:64], compare128[63:48], compare128[47:32], compare128[31:16], compare128[15:0], packet_tag, $realtime, data128[127:112], data128[111:96], data128[95:80], data128[79:64], data128[63:48], data128[47:32], data128[31:16], data128[15:0]);
               end
               else
               begin
                  //$display("HOST MEMORY Atomic Op[%s]: Atomic Compare-and-Swap at address:%H_%H_%H_%H with compare value:%H_%H_%H_%H_%H_%H_%H_%H with packet tag:%H at time:%0t.  Atomic Compare-and-Swap return value:%H_%H_%H_%H_%H_%H_%H_%H, memory value was NOT swapped.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], compare128[127:112], compare128[111:96], compare128[95:80], compare128[79:64], compare128[63:48], compare128[47:32], compare128[31:16], compare128[15:0], packet_tag, $realtime, data128[127:112], data128[111:96], data128[95:80], data128[79:64], data128[63:48], data128[47:32], data128[31:16], data128[15:0]);
               end
            end
         end
      end
      else
      begin
         $display("HOST MEMORY ERROR[%s]: Atomic Compare-and-Swap at address:%H_%H_%H_%H has one or more data members with incorrect data width.  Compare, Swap and Result references must all have a matching 4-byte, 8-byte, or 16-byte width or the Atomic Op is aborted.  Compare width is: %0d, Swap width is: %0d and Result width is: %0d.  This occurred with packet tag: %H at time: %0t.", memory_name, addr[63:48], addr[47:32], addr[31:16], addr[15:0], compare.size(), swap.size(), result.size(), packet_tag, $realtime);
      end
   endfunction : atomic_compare_and_swap


   function void print_all_accesses(
      input addr_t start_addr,
      input uint64_t count
   );
      addr_t addr = start_addr;
      MemoryEntry memory_entry;
      for (uint64_t i = 64'd0; i < count; i += 64'd1)
      begin
         if (!host_memory.exists(addr))
         begin
            memory_entry = new(memory_name, addr);
            host_memory[addr] = memory_entry;
         end
         host_memory[addr].print_all_accesses();
         addr = addr + 64'd1;
      end
   endfunction : print_all_accesses


   function void dump_mem(
      input addr_t start_addr,
      input uint64_t byte_count
   );
      addr_t row_addr;
      addr_t addr;
      row_addr = start_addr & 64'hFFFF_FFFF_FFFF_FFF0;
      addr = row_addr;
      $display("");
      $display("Starting Memory Dump for [%s] from address:%H_%H_%H_%H for %0d bytes at time:%0t", memory_name, start_addr[63:48], start_addr[47:32], start_addr[31:16], start_addr[15:0], byte_count, $realtime);
      while (addr < (start_addr + byte_count))
      begin
         $write("%H --- ",addr);
         for (int i = 0; i < 16; i++)
         begin
            if ((addr >= start_addr) && (addr < (start_addr + byte_count)))
            begin
               if (host_memory.exists(addr))
               begin
                  $write("%H ", host_memory[addr].get_data());
               end
               else
               begin
                  $write("xx "); 
               end
            end
            else
            begin
                  $write("   "); 
            end
            if (i == 7)
            begin
               $write(" ");  // Put extra space in middle of data line for clarity
            end
            if (i == 15)
            begin
               $display("");  // Start a new line of data
            end
            addr += 64'd1;
         end
      end
      $display("");
   endfunction : dump_mem


   function void dump_mem_range(
      input addr_t start_addr,
      input addr_t end_addr
   );
      addr_t row_addr;
      addr_t addr;
      row_addr = start_addr & 64'hFFFF_FFFF_FFFF_FFF0;
      addr = row_addr;
      $display("");
      $display("Starting Memory Dump for [%s] from address:%H_%H_%H_%H to address:%H_%H_%H_%H at time:%0t", memory_name, start_addr[63:48], start_addr[47:32], start_addr[31:16], start_addr[15:0], end_addr[63:48], end_addr[47:32], end_addr[31:16], end_addr[15:0], $realtime);
      while (addr <= end_addr)
      begin
         $write("%H --- ",addr);
         for (int i = 0; i < 16; i++)
         begin
            if ((addr >= start_addr) && (addr <= end_addr))
            begin
               if (host_memory.exists(addr))
               begin
                  $write("%H ", host_memory[addr].get_data());
               end
               else
               begin
                  $write("xx "); 
               end
            end
            else
            begin
                  $write("   "); 
            end
            if (i == 7)
            begin
               $write(" ");  // Put extra space in middle of data line for clarity
            end
            if (i == 15)
            begin
               $display("");  // Start a new line of data
            end
            addr += 64'd1;
         end
      end
      $display("");
   endfunction : dump_mem_range


   function void dump_mem_all();
      addr_t start_addr;
      addr_t end_addr;
      addr_t row_addr;
      addr_t addr;
      addr_t next_addr;
      $display("");
      $display("Starting Full Memory Dump for [%s] at time:%0t", memory_name, $realtime);
      if (host_memory.first(start_addr))
      begin
         host_memory.last(end_addr);
         row_addr = start_addr & 64'hFFFF_FFFF_FFFF_FFF0;
         addr = row_addr;
         while (addr <= end_addr)
         begin
            $write("%H --- ",addr);
            for (int i = 0; i < 16; i++)
            begin
               if ((addr >= start_addr) && (addr <= end_addr))
               begin
                  if (host_memory.exists(addr))
                  begin
                     $write("%H ", host_memory[addr].get_data());
                  end
                  else
                  begin
                     $write("xx "); 
                  end
               end
               else
               begin
                     $write("   "); 
               end
               if (i == 7)
               begin
                  $write(" ");  // Put extra space in middle of data line for clarity
               end
               if (i == 15)
               begin
                  $display("");  // Start a new line of data
               end
               next_addr = addr;
               addr += 64'd1;
            end
            if (host_memory.next(next_addr) && ((next_addr - addr) > 16)) // Skip gaps in memory locations to prevent wasted printing.
            begin
               addr = next_addr & 64'hFFFF_FFFF_FFFF_FFF0;
               $display(""); // Put a blank line in between memory section jumps.
            end
         end
      end
      $display("");
   endfunction : dump_mem_all

endclass: HostMemory


endpackage: host_memory_class_pkg

`endif // __HOST_MEMORY_CLASS_PKG__
