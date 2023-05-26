// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Shared memory BFM 
//    * Only DW access support, no byte access support 
//
//-----------------------------------------------------------------------------
`timescale 1ps / 1ps


module shmem #(
   parameter MEM_ADDR_SIZE = 20, // DW
   parameter TLP_BUF_SIZE = 128, // Size of the buffer storing memory read completion TLP

   // Derived parameter
   parameter MEM_SIZE = (1 << MEM_ADDR_SIZE),
   parameter LOG2_TLP_BUF_SIZE = $clog2(TLP_BUF_SIZE)
)(
   input logic clk,
   input logic rst_n,

   // Interface for DUT
   input t_avst_pcie_tx mem_st,
   output logic         mem_st_ready,

   output logic                            send_req,
   input  logic                            send_ack,
   output logic [LOG2_TLP_BUF_SIZE:0]      num_tx_packet,
   input  logic [LOG2_TLP_BUF_SIZE-1:0]    tx_buf_idx,
   output t_avst_pcie_rx [NUM_AVST_CH-1:0] tx_packet
);

import ofs_fim_pcie_hdr_def::*;

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;

import test_pcie_utils::*;
// memory
logic [MEM_SIZE-1:0][31:0] mem;

logic [31:0] msgmem[$];

logic         shmem_write = 1'b0;
logic [63:0]  shmem_waddr = '0;
logic [31:0]  shmem_wdata = '0;

t_avst_pcie_rx [TLP_BUF_SIZE-1:0] tx_buffer;

logic mem_st_read_ready;
logic mem_st_write_ready;

//--------------------
// DUT memory access
//--------------------
logic [63:0]              full_mem_addr;
logic [MEM_ADDR_SIZE-1:0] mem_addr, mem_addr_q;
t_tlp_mem_req_hdr mem_hdr;
logic mem_vf_active;
logic mem_rd;
logic mem_msgD;
logic hdr_4dw;
logic [10:0] rd_length;
logic [10:0] length, length_q;
logic [3:0]  first_be, last_be;
logic        zero_length_read;
logic        illegal_req;
logic        unsupported_addr;
logic        return_cpl, return_cpl_q;

logic [1:0][255:0] mem_pld;//Fix me for depth - Aravind
bit pld_avl,idx,tmp_idx,sec_pld;

logic [7:0] lpbk_fmt_type;
logic [9:0] lpbk_len;
logic [15:0] lpbk_vendor_id;
logic [31:0] lpbk_mctp_hdr;
logic [7:0] lpbk_msg_code;

`ifdef HTILE
   assign mem_hdr = to_big_endian(mem_st.data[127:0]);
   mem_vf_active  = mem_st.vf_active;
`else
   assign mem_hdr = mem_st.hdr;
   assign mem_vf_active = mem_hdr.requester_id[3];
`endif
assign mem_msgD         = func_is_msgD(mem_hdr.dw0.fmttype);
assign mem_rd           = func_is_mrd_req(mem_hdr.dw0.fmttype);
assign hdr_4dw          = func_is_addr64(mem_hdr.dw0.fmttype);
assign mem_addr         = hdr_4dw ? mem_hdr.lsb_addr[2+:MEM_ADDR_SIZE] : mem_hdr.addr[2+:MEM_ADDR_SIZE];
assign full_mem_addr    = hdr_4dw ? {mem_hdr.addr, mem_hdr.lsb_addr} : {32'h0, mem_hdr.addr};
assign length           = (mem_hdr.dw0.length == 0) ? 'd1024 : mem_hdr.dw0.length;
assign first_be         = mem_hdr.first_be;
assign last_be          = mem_hdr.last_be;
assign zero_length_read = (~|first_be & ~|last_be);

always_comb begin
   illegal_req = 1'b0;

   if (mem_st.valid && mem_st.sop && !mem_msgD) begin
      if (|first_be) begin
         // check first_be=0xf (shmem only supports DW access)
         if (~&first_be) begin
            illegal_req = 1'b1;
            $display("Error: (shmem) first_be of memory request must be 0x0 or 0xf, detected 0x%0x\n", first_be); 
         end
      end
      
      if (length == 10'd1) begin
         // Check last_be=0x0 when length=1DW 
         if (|last_be) begin
            illegal_req = 1'b1;
            $display("Error: (shmem) last_be of memory request must be 0x0 when length=1, detected 0x%0x\n", last_be); 
         end
      end else begin
         // check last_be=0xf (shmem only supports DW access)
         if (~&last_be) begin
            illegal_req = 1'b1;
            $display("Error: (shmem) last_be of memory request must be 0x0 or 0xf, detected 0x%0x\n", last_be); 
         end
      end

      // Check address >= 2^32 when header is 4DW
      if (hdr_4dw && ~|mem_hdr.addr) begin
         illegal_req = 1'b1;
         $display("Error: (shmem) 4DW header is used for memory request to address < 2^32 (address=0x%0x)\n", {mem_hdr.addr, mem_hdr.lsb_addr}); 
      end
      
      if (illegal_req) begin
         //$fatal(0,$psprintf("%8t: %m Illegal/unsupported memory request is detected.", $time));
         //$finish();
      end

      // Check read address < 2^(MEM_ADDR_SIZE)
      return_cpl = 1'b0;
      unsupported_addr = 1'b0;
      if (mem_rd && (full_mem_addr[63:(MEM_ADDR_SIZE+2)] > 0)) 
      begin
         unsupported_addr = 1'b1;
         `ifdef BFM_ENABLE_UNSUPPORTED_ADDR_CPL
            return_cpl = 1'b1;
            unsupported_addr = 1'b0;
         `endif
      end
   end
end

assign mem_st_ready = mem_st_write_ready && mem_st_read_ready;
assign mem_st_write_ready = ~shmem_write;

//VDM payload_comparison
always_ff @(posedge clk) begin
  if(mem_msgD || sec_pld) begin
    //for(int i=0;i<2;i++) begin //change w.r.t Length- Aravind
     if(mem_st.valid) begin  
       mem_pld[idx]=mem_st.data[255:0];
       idx=idx+1;
       pld_avl=1;
     end
    // pld_avl=0;
     sec_pld=1;
   // end
  end
end

always_ff @(posedge clk) begin
 if(mem_msgD && mem_st.valid) begin
    lpbk_fmt_type=mem_hdr.dw0.fmttype;
    lpbk_len=mem_hdr.dw0.length; 
    lpbk_vendor_id=mem_hdr.addr[15:0];
    lpbk_mctp_hdr=mem_hdr.lsb_addr;
    lpbk_msg_code={mem_hdr.last_be,mem_hdr.first_be};
 end
end

// Memory write
always_ff @(posedge clk) begin
   if (shmem_write) begin
      mem[shmem_waddr[2+:MEM_ADDR_SIZE]] <= shmem_wdata;
   end 
   
   if (~shmem_write && mem_st.valid && !mem_msgD) begin
      if (mem_st.sop && ~mem_rd) begin
         $display("[%t] Info: (Endpoint) Writing to shared memory (byte addr:0x%x, length=%0d)", $time, {mem_addr, 2'h0}, length);
         `ifdef HTILE
            if (hdr_4dw) begin
               for (int i=0; i<4; i=i+1) 
                  if (i<length) mem[mem_addr+i] <= mem_st.data[(4+i)*32+:32];
               mem_addr_q <= (length>4) ? mem_addr + 4 : '0;
               length_q   <= (length>4) ? length - 4 : '0;
            end else begin
               for (int i=0; i<5; i=i+1) 
                  if (i<length) mem[mem_addr+i] <= mem_st.data[(3+i)*32+:32];
               mem_addr_q <= (length>5) ? mem_addr + 5 : '0;
               length_q   <= (length>5) ? length - 5 : '0;
            end
         `else
            for (int i=0; i<8; i=i+1) 
               if (i<length) mem[mem_addr+i] <= mem_st.data[i*32+:32];
            mem_addr_q <= (length>8) ? mem_addr + 8 : '0;
            length_q   <= (length>8) ? length - 8 : '0; 
         `endif
      end else if (~mem_st.sop) begin
         for (int i=0; i<8; i=i+1) 
            if (i<length_q) mem[mem_addr_q+i] <= mem_st.data[i*32+:32];
         mem_addr_q <= (length_q>8) ? mem_addr_q + 8 : '0;
         length_q <= (length_q>8) ? length_q - 8 : '0; 
      end
   end 
end

// Memory read
logic prepare_mem_packet;
logic wait_mem_xfer;
logic [4095:0] cur_mem_data;
logic [MEM_ADDR_SIZE-1:0] cur_mem_addr;
logic [10:0] cur_length;
logic [15:0] cur_requester_id;
logic [7:0] cur_tag;
logic       cur_vf_active;
logic       zero_length_rsp;

always_comb begin
   if (tx_buf_idx == num_tx_packet-1) begin
      tx_packet = {'0, tx_buffer[tx_buf_idx]};
   end else begin
      tx_packet = tx_buffer[tx_buf_idx+:2]; 
   end
end

always_ff @(posedge clk) begin
   if (~rst_n) begin
      tx_buffer <= '0;
      num_tx_packet <= '0;
      send_req <= 1'b0;
      wait_mem_xfer <= 1'b0;
      mem_st_read_ready <= 1'b0;
   end else begin
      if (wait_mem_xfer) begin
         if (~send_ack) begin
            wait_mem_xfer <= 1'b0;
            tx_buffer <= '0;
            num_tx_packet <= '0;
            mem_st_read_ready <= 1'b1;
            $display("    ** Packets sent **");
         end
      end else if (send_req) begin
         if (send_ack) begin
            send_req <= 1'b0;
            wait_mem_xfer <= 1'b1;
         end
      end else if (prepare_mem_packet) begin
         if (return_cpl_q) begin
            if (zero_length_rsp) begin
               create_cpl_packet(16'h0, cur_requester_id, 12'd1, cur_tag, {cur_mem_addr[4:0], 2'b0}, cur_vf_active);
            end else begin
               create_cpl_packet(16'h0, cur_requester_id, (cur_length<<2), cur_tag, {cur_mem_addr[4:0], 2'b0}, cur_vf_active);
            end
            prepare_mem_packet <= 1'b0;
            send_req <= 1'b1;
         end else begin
            if (cur_length > 10'd64) begin
                     // length, completer ID, requester ID, byte_count, tag, lower_addr, vf_active, data
               create_cpld_packet(10'd64, 16'h0, cur_requester_id, (cur_length<<2), cur_tag, {cur_mem_addr[4:0], 2'b0}, cur_vf_active, cur_mem_data); 
               cur_length <= cur_length - 'd64;
               cur_mem_addr <= cur_mem_addr + 'd64;
               for (int i=0; i<64; i=i+1) begin
                  if (i<cur_length) cur_mem_data[i*32+:32] <= mem[cur_mem_addr+64+i];
               end
            end else begin
                     // length, completer ID, requester ID, byte_count, tag, lower_addr, vf_active, data
               if (zero_length_rsp) begin
                  create_cpld_packet(cur_length, 16'h0, cur_requester_id, 12'd1, cur_tag, {cur_mem_addr[4:0], 2'b0}, cur_vf_active, cur_mem_data); 
               end else begin
                  create_cpld_packet(cur_length, 16'h0, cur_requester_id, (cur_length<<2), cur_tag, {cur_mem_addr[4:0], 2'b0}, cur_vf_active, cur_mem_data); 
               end
               prepare_mem_packet <= 1'b0;
               send_req <= 1'b1;
            end
         end
      end else if (mem_st.valid) begin
         if (mem_st.sop && mem_rd && ~unsupported_addr) begin 
            prepare_mem_packet <= 1'b1;
            mem_st_read_ready <= 1'b0;

            cur_mem_addr     <= mem_addr; // convert to DW-based address
            cur_length       <= (length == 0) ? 'd1024 : length;
            cur_requester_id <= mem_hdr.requester_id;
            cur_tag          <= mem_hdr.tag;
            cur_vf_active    <= mem_vf_active;
            zero_length_rsp  <= zero_length_read;
            return_cpl_q     <= return_cpl;

            if (return_cpl) begin
               $display("[%t] Info: Start sending CPL packets (start addr:0x%x, length=%0d)", $time, (mem_addr<<2), length);
               cur_mem_data <= '0;
            end else begin
               $display("[%t] Info: Start sending CPLD packets (start addr:0x%x, length=%0d)", $time, (mem_addr<<2), length);
               if (zero_length_read) begin
                  cur_mem_data[31:0] <= 32'hFEFE_FEFE;
               end else begin
                  for (int i=0; i<64; i=i+1) begin
                     if (length == 0 || i<length) cur_mem_data[i*32+:32] <= mem[mem_addr+i];
                  end
               end
            end
         end 
      end else begin
         mem_st_read_ready <= 1'b1;
      end
   end
end

// msgD


//------------------------------------------------------
// Tasks & functions
//------------------------------------------------------
task f_shmem_write;
   input logic [63:0] addr;
   input logic [63:0] data;
   input logic [1:0]  size;
begin
   if (size > 2) begin
      $display("Warning: memory write size exceed limit, only 1DW/2DW write is supported.");
   end else begin
      $display("[%t] Info: (Host) writing to shared memory (byte addr:0x%x, length=%0d)", $time, shmem_waddr, size);
      for (int i=0; i<size; i=i+1) begin
         @(posedge clk)
            shmem_waddr = addr + i*4;
            shmem_wdata = data[i*32+:32];
            shmem_write = 1'b1;
      end
   
      @(posedge clk)
         shmem_write = 1'b0;
   end
end
endtask

task f_shmem_read;
   input  logic [63:0] addr;
   input  logic [1:0]  size;
   output logic [63:0] data;
begin
   data = '0;
   if (size > 2) begin
      $display("Warning: memory write size exceed limit, only 1DW/2DW write is supported.");
   end else begin
      for (int i=0; i<size; i=i+1) begin
         data[i*32+:32] = mem[addr[2+:MEM_ADDR_SIZE]+i];
      end
   end
end
endtask

task f_shmem_display;
   input logic [63:0] addr;
   input int size; // DW
   input int display_size; // DW
   int size_limit;
   logic [MEM_ADDR_SIZE-1:0] mem_addr;
   int remain;
   string data_str;
begin
   if ( (addr>>2 + size) > MEM_SIZE) begin
      $display("Warning (f_shmem_display): memory read size (%0d) exceed limit, display disabled.", size);
   end else if (display_size < 1 || display_size > 4 || display_size == 3) begin
      $display("Warning (f_shmem_display): memory display size %0d is not within supported range (1, 2, 4), display disabled.", display_size);
   end else begin
      $display("\n   *******************************************");
      $display("      Memory content");
      $display("         (0x%x - 0x%x)", addr, (addr+size*4));
      $display("   *******************************************");
      
      case (display_size) 
         2 : mem_addr = {addr[3+:MEM_ADDR_SIZE], 1'b0};
         4 : mem_addr = {addr[4+:MEM_ADDR_SIZE], 2'b0};
         default : mem_addr = addr[2+:MEM_ADDR_SIZE];
      endcase

      remain = size;
      while (remain > 0) begin
         data_str = "";
         size_limit = (remain < display_size) ? remain : display_size;
         // Print DWs by display size
         for (int i=0; i<size_limit; ++i) begin
            $sformat(data_str, "%0s%x", data_str, mem[mem_addr+i]);
            if (i < size_limit-1) $sformat(data_str, "%0s ", data_str);
         end
         $display("      \[0x%6x\] : %0s", {mem_addr, 2'd0}, data_str);
         mem_addr = mem_addr + size_limit;
         remain = remain - size_limit;
      end
   end
end
endtask

//VDM payload_comparison
task f_shmem_vdm_pyld_display;
  output logic [1:0] [255:0] pld_out;
  output logic [7:0] lpbk2rx_fmt_type;
  output logic [9:0] lpbk2rx_len;
  output logic [15:0] lpbk2rx_vendor_id;
  output logic [31:0] lpbk2rx_mctp_hdr;
  output logic [7:0] lpbk2rx_msg_code;
begin
     /*
     //---Loopback the VDM,MCTP header files--//
     lpbk2rx_fmt_type = lpbk_fmt_type;
     lpbk2rx_len      = lpbk_len;
     lpbk2rx_vendor_id = lpbk_vendor_id;
     lpbk2rx_mctp_hdr = lpbk_mctp_hdr;
     lpbk2rx_msg_code = lpbk_msg_code;
     */
     //--Loopback the actual VDM message----//
     while(pld_avl==0)
       @(posedge clk);
     if(pld_avl) begin

       //---Loopback the VDM,MCTP header files--//
       lpbk2rx_fmt_type = lpbk_fmt_type;
       lpbk2rx_len      = lpbk_len;
       lpbk2rx_vendor_id = lpbk_vendor_id;
       lpbk2rx_mctp_hdr = lpbk_mctp_hdr;
       lpbk2rx_msg_code = lpbk_msg_code;

       for (int i=0;i<2;i++) begin
         pld_out[i] = mem_pld[i];
         @(posedge clk);
       end 
     end
end
endtask

task write_mem_packet;
   input t_avst_pcie_rx [127:0] pkt_buf;
   input logic [6:0] buf_size;
begin
   for (int i=0; i<buf_size; i=i+1) begin
      tx_buffer[num_tx_packet] = pkt_buf[i];
      num_tx_packet += 1;
   end
end
endtask

// Create completion packet (CPLD)
task create_cpld_packet;
   input logic [9:0]          length;
   input logic [15:0]         completer;
   input logic [15:0]         requester;
   input logic [11:0]         byte_count;
   input logic [PCIE_EP_TAG_WIDTH-1:0] cpl_tag;
   input logic [6:0]          lower_addr;
   input logic                vf_active;
   input logic [4095:0]       data;
  
   e_endian endian;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0]            buf_size;
   t_tlp_cpl_hdr          hdr;
   logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]   pf;
   logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]   vf;
begin
   `ifdef HTILE
      endian = LITTLE_ENDIAN;
      pf     = requester[3:0];
      vf     = requester[15:4];
   `else
      endian = BIG_ENDIAN;
      pf     = requester[2:0];
      vf     = requester[15:4];
   `endif

   hdr = get_cpl_hdr(endian, CPLD, length, completer, requester, byte_count, cpl_tag, lower_addr); 
   
   create_packet(pkt_buf, buf_size, HAS_DATA, ADDR32, length, hdr, 0, vf_active, pf, vf, data, 0);
   write_mem_packet(pkt_buf, buf_size);
end
endtask

// Create completion packet (CPL)
task create_cpl_packet;
   input logic [15:0]         completer;
   input logic [15:0]         requester;
   input logic [11:0]         byte_count;
   input logic [PCIE_EP_TAG_WIDTH-1:0] cpl_tag;
   input logic [6:0]          lower_addr;
   input logic                vf_active;
  
   e_endian               endian;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0]            buf_size;
   t_tlp_cpl_hdr          hdr;
   logic [PF_WIDTH-1:0]   pf;
   logic [VF_WIDTH-1:0]   vf;
begin
   `ifdef HTILE  
      endian = LITTLE_ENDIAN;
      pf     = requester[3:0];
      vf     = requester[15:4];
   `else
      endian = BIG_ENDIAN;
      pf     = requester[2:0];
      vf     = requester[15:4];
   `endif
   
   hdr = get_cpl_hdr(endian, CPL, 10'h1, completer, requester, byte_count, cpl_tag, lower_addr); 
   
   create_packet(pkt_buf, buf_size, NO_DATA, ADDR32, 10'd1, hdr, 0, vf_active, pf, vf, 0, 0);
   write_mem_packet(pkt_buf, buf_size);
end
endtask

endmodule
