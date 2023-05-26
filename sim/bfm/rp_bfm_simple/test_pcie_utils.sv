// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   PCIe packet utility tasks
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"

`ifndef __TEST_PCIE_UTILS__
`define __TEST_PCIE_UTILS__

package test_pcie_utils;
   import ofs_fim_pcie_hdr_def::*;
   import ofs_fim_pcie_pkg::*;

typedef enum bit [1:0] {MWR, MRD, CPLD, CPL} e_tlp_type;
typedef enum bit {ADDR32, ADDR64} e_addr_mode;
typedef enum bit {BIG_ENDIAN, LITTLE_ENDIAN} e_endian;

localparam HAS_DATA = 1'b1;
localparam NO_DATA = 1'b0;

function automatic logic [127:0] to_little_endian (
   input  logic [127:0] hdr  
);
   for (int i=0; i<=3; i=i+1) begin
      to_little_endian[i*32+:32] = hdr[(3-i)*32+:32];
   end
endfunction

function automatic logic [127:0] to_big_endian (
   input  logic [127:0] hdr  
);
   for (int i=0; i<=3; i=i+1) begin
      to_big_endian[i*32+:32] = hdr[(3-i)*32+:32];
   end
endfunction

function automatic logic [127:0] get_mem_hdr (
   input e_endian    endian,
   input e_tlp_type  req,
   input e_addr_mode addr_mode,
   input logic [63:0] addr,
   input logic [9:0]  length,
   input logic [7:0]  tag,
   input logic [15:0] requester_id
);
   t_tlp_mem_req_hdr hdr;
   logic addr_mode_32b;
   
   addr_mode_32b = (addr_mode == ADDR32) ? 1'b1 : 1'b0;
   hdr = '0;

   if (req == MWR) begin // Memory write      
      hdr.dw0.fmttype  = addr_mode_32b ? PCIE_FMTTYPE_MEM_WRITE32 : PCIE_FMTTYPE_MEM_WRITE64;
   end else begin // Memory read
      hdr.dw0.fmttype  = addr_mode_32b ? PCIE_FMTTYPE_MEM_READ32 : PCIE_FMTTYPE_MEM_READ64;
   end
   
   hdr.dw0.length   = length;
   hdr.requester_id = requester_id;
   hdr.tag          = tag;
   hdr.last_be      = 4'hf;
   hdr.first_be     = 4'hf;
   hdr.addr         = addr_mode_32b ? addr[31:0] : addr[63:32];
   hdr.lsb_addr     = addr_mode_32b ? '0 : addr[31:0];

   return (endian == BIG_ENDIAN) ? hdr : to_little_endian(hdr);
endfunction

function automatic logic [127:0] get_cpl_hdr (
   input e_endian     endian,
   input e_tlp_type   req,
   input logic [9:0]  length,
   input logic [15:0] completer,
   input logic [15:0] requester,
   input logic [11:0] byte_count,
   input logic [7:0]  cpl_tag,
   input logic [6:0]  lower_addr
);
   t_tlp_cpl_hdr hdr;
   
   hdr = '0;
   hdr.dw0.fmttype   = (req == CPLD) ? PCIE_FMTTYPE_CPLD : PCIE_FMTTYPE_CPL;
   hdr.dw0.length    = length;
   hdr.completer_id  = completer;
   hdr.status        = (req == CPLD) ? 3'b0 : 3'b100;
   hdr.byte_count    = byte_count;
   hdr.requester_id  = requester;
   hdr.tag           = cpl_tag;
   hdr.lower_addr    = lower_addr;
   
   return (endian == BIG_ENDIAN) ? hdr : to_little_endian(hdr);
endfunction

// Create TLP packet
task create_packet;
   output t_avst_pcie_rx [127:0] pkt_buf;
   output logic [6:0]            buf_size;

   input logic                   has_data;
   input e_addr_mode             addr_mode;
   input logic [9:0]             length;
   input logic [127:0]           hdr;
   input logic [2:0]             bar;
   input logic                   vf_active;
   input logic [PF_WIDTH-1:0]    pfn;
   input logic [VF_WIDTH-1:0]    vfn;
   input logic [4095:0]          data;
   input logic [7:0]             idle_cycle;
   
   logic [6:0]    total_packet;
   t_avst_pcie_rx packet;
   logic [10:0]   cur_length;
   logic [9:0]    dw_offset;
begin
`ifdef PTILE
   create_ptile_packet(pkt_buf, buf_size, has_data, addr_mode, length, hdr, bar, vf_active, pfn, vfn, data, idle_cycle);
`else
   create_htile_packet(pkt_buf, buf_size, has_data, addr_mode, length, hdr, bar, vf_active, pfn, vfn, data, idle_cycle);
`endif
end
endtask

task create_htile_packet;
   output t_avst_pcie_rx [127:0] pkt_buf;
   output logic [6:0]            buf_size;

   input logic                   has_data;
   input e_addr_mode             addr_mode;
   input logic [9:0]             length;
   input logic [127:0]           hdr;
   input logic [2:0]             bar;
   input logic                   vf_active;
   input logic [PF_WIDTH-1:0]    pfn;
   input logic [VF_WIDTH-1:0]    vfn;
   input logic [4095:0]          data;
   input logic [7:0]             idle_cycle;
   
   logic [6:0]    total_packet;
   t_avst_pcie_rx packet;
   logic [10:0]   cur_length;
   logic [9:0]    dw_offset;
begin
   //--------------------
   // Packets to be sent to DUT AVST channels
   //--------------------   
   total_packet = '0;
   packet       = '0;
   packet.valid = 1'b1;
   packet.sop   = 1'b1;
   
   packet.bar       = bar;
   packet.vf_active = vf_active;
   packet.pfn       = pfn;
   packet.vfn       = vfn;
  
   dw_offset = 0;
   if (has_data) begin
      cur_length = (length == 0) ? 11'd1024 : length;
      if (addr_mode == ADDR32) begin
         packet.data[95:0] = hdr[95:0];
         for (int i=0; i<5; i=i+1) begin
            if (i < cur_length) begin
               packet.data[(i*32+96)+:32] = data[dw_offset*32+:32];
            end
            dw_offset = dw_offset + 1;
         end

         packet.empty = (cur_length < 5) ? (5-cur_length) : 0;
         cur_length   = (cur_length > 5) ? (cur_length-5) : 0;
      end else begin
         packet.data[127:0] = hdr;
         for (int i=0; i<4; i=i+1) begin
            if (i < cur_length) begin
               packet.data[(i*32+128)+:32] = data[dw_offset*32+:32];
            end
            dw_offset = dw_offset + 1;
         end
         packet.empty = (cur_length < 4) ? (4-cur_length) : 0;
         cur_length   = (cur_length > 4) ? (cur_length-4) : 0;
      end
   end else begin
      cur_length = 0;
      packet.empty = '0;
      packet.data = {'0, hdr};
   end

   packet.eop = (cur_length == 0) ? 1'b1 : 1'b0;
   
   pkt_buf[total_packet] = packet;
   total_packet += 1;

   // Multi packets TLP
   packet.sop = 1'b0;
   while (cur_length > 0) begin
      packet.data = '0;
      packet.empty = (cur_length < 8) ? (8-cur_length) : 0;
      
      for (int i=0; i<8; i=i+1) begin
         if (i < cur_length) begin
            packet.data[i*32+:32] = data[dw_offset*32+:32];
         end
         dw_offset = dw_offset+1;
      end

      cur_length = (cur_length > 8) ? (cur_length-8) : 0;
      packet.eop = (cur_length == 0) ? 1'b1 : 1'b0;
   
      pkt_buf[total_packet] = packet;
      total_packet += 1;

      // Add idle cycles
      for (int i=0; i<idle_cycle*2; i=i+1) begin
         pkt_buf[total_packet] = '0;
         total_packet += 1;
      end
   end 

   buf_size = total_packet;
end
endtask

task create_ptile_packet;
   output t_avst_pcie_rx [127:0] pkt_buf;
   output logic [6:0]            buf_size;

   input logic                   has_data;
   input e_addr_mode             addr_mode;
   input logic [9:0]             length;
   input logic [127:0]           hdr;
   input logic [2:0]             bar;
   input logic                   vf_active;
   input logic [PF_WIDTH-1:0]    pfn;
   input logic [VF_WIDTH-1:0]    vfn;
   input logic [4095:0]          data;
   input logic [7:0]             idle_cycle;
   
   logic [6:0]    total_packet;
   t_avst_pcie_rx packet;
   logic [10:0]   cur_length;
   logic [9:0]    dw_offset;
begin
   //--------------------
   // Packets to be sent to DUT AVST channels
   //--------------------   
   total_packet = '0;
   packet       = '0;
   packet.valid = 1'b1;
   packet.sop   = 1'b1;
   
   packet.hdr       = hdr;
   packet.bar       = bar;
   packet.vf_active = vf_active;
   packet.pfn       = pfn;
   packet.vfn       = vfn;
  
   dw_offset = 0;
   if (has_data) begin
      cur_length = (length == 0) ? 11'd1024 : length;
      
      for (int i=0; i<8; i=i+1) begin
         if (i < cur_length) begin
            packet.data[i*32+:32] = data[dw_offset*32+:32];
         end
         dw_offset = dw_offset + 1;
      end

      packet.empty = (cur_length < 8) ? (8-cur_length) : 0;
      cur_length   = (cur_length > 8) ? (cur_length-8) : 0;
   end else begin
      cur_length = 0;
      packet.empty = '0;
      packet.data = '0;
   end

   packet.eop = (cur_length == 0) ? 1'b1 : 1'b0;
   
   pkt_buf[total_packet] = packet;
   total_packet += 1;

   // Multi packets TLP
   packet.sop = 1'b0;
   while (cur_length > 0) begin
      packet.data = '0;
      packet.empty = (cur_length < 8) ? (8-cur_length) : 0;
      
      for (int i=0; i<8; i=i+1) begin
         if (i < cur_length) begin
            packet.data[i*32+:32] = data[dw_offset*32+:32];
         end
         dw_offset = dw_offset+1;
      end

      cur_length = (cur_length > 8) ? (cur_length-8) : 0;
      packet.eop = (cur_length == 0) ? 1'b1 : 1'b0;
   
      pkt_buf[total_packet] = packet;
      total_packet += 1;

      // Add idle cycles
      for (int i=0; i<idle_cycle*2; i=i+1) begin
         pkt_buf[total_packet] = '0;
         total_packet += 1;
      end
   end 

   buf_size = total_packet;
end
endtask

endpackage : test_pcie_utils

`endif // __TEST_PCIE_UTILS__



