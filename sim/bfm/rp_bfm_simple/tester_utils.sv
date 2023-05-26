// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Utility tasks for tester
//
//-----------------------------------------------------------------------------

import test_pcie_utils::*;

//-----------------------
// Tag
//----------------------
task f_reset_tag;
begin
   tester_tag = '0;
end
endtask

// Return tag to use for MRD request
task f_get_tag;
   output t_tlp_rp_tag tag;
begin
   wait (~tag_active[tester_tag]);

   tag = tester_tag;
   f_incr_tag();
end
endtask

task f_incr_tag;
begin
   if (tester_tag == RP_MAX_TAGS-1)
      tester_tag = t_tlp_rp_tag'(0);
   else
      tester_tag = tester_tag + 'd1;
end
endtask

//-----------------------
// Shared Memory
//----------------------
task f_shmem_write;
   input logic [63:0] addr;
   input logic [63:0] data;
   input logic [1:0]  size;
begin
   shmem.f_shmem_write(addr, data, size);
end
endtask

task f_shmem_read;
   input  logic [63:0] addr;
   input  logic [1:0]  size;
   output logic [63:0] data;
begin
   shmem.f_shmem_read(addr, size, data);
end
endtask

task f_shmem_display;
   input logic [63:0] addr;
   input int size; // DW
   input int display_size; // DW (1, 2, 4)
begin
   shmem.f_shmem_display(addr, size, display_size);
end
endtask

task f_shmem_vdm_pyld_display;
   output logic [1:0][255:0] data;
   output logic [7:0] lpbk2rx_fmt_type;
   output logic [9:0] lpbk2rx_len;
   output logic [15:0] lpbk2rx_vendor_id;
   output logic [31:0] lpbk2rx_mctp_hdr;
   output logic [7:0] lpbk2rx_msg_code; 
begin
   shmem.f_shmem_vdm_pyld_display(data,lpbk2rx_fmt_type,lpbk2rx_len,lpbk2rx_vendor_id,lpbk2rx_mctp_hdr,lpbk2rx_msg_code);
end
endtask


//-----------------------
// FLR
//-----------------------
task send_flr;
   input logic        vf_flr;
   input logic [2:0]  pfn;
   input logic [10:0] vfn;
begin
   @(posedge avl_clk);
      flr_pfn    = pfn;
      flr_vfn    = vfn;
      vf_active  = vf_flr;
      assert_flr = 1'b1;
   @(posedge avl_clk);
      assert_flr = 1'b0;
   @(posedge avl_clk);
      if (~vf_active) wait (o_flr_pf_active[pfn] === 1'b1);
      else wait (o_flr_rcvd_vf);
end
endtask

task wait_flr;
   input logic        vf_active;
   input logic [2:0]  pfn;
   input logic [10:0] vfn;
begin
   if (~vf_active) begin
      $display("Waiting for PF FLR completion status (PF=%0d)", pfn);
   end else begin
      $display("Waiting for VF FLR completion status (PF=%0d VF=%0d)", pfn, vfn);
   end

   if (~vf_active && (o_flr_pf_active[pfn] === 1'b1)) begin
      wait (~o_flr_pf_active[pfn]);
      $display("   **FLR on PF completed**");
   end

   if (vf_active && (flr_vf_active[pfn][vfn] === 1'b1)) begin
      wait (flr_vf_active[pfn][vfn] === 1'b0);
      $display("   **FLR on VF completed**");
   end
end
endtask


//-----------------------
// Packet
//-----------------------
// Clear packet buffer
task clear_tx_buffer;
begin
   tx_buffer = '0;
   num_tx_packet = '0;
end
endtask

// Send all packets in the tester packet buffer 
task f_send_test_packet;
begin
   $display("   ** Sending TLP packets **");
   @(posedge avl_clk)
      send_test_packet = 1'b1;

   $display("   ** Waiting for ack **");
   @(posedge send_test_ack);
   @(posedge avl_clk);
      send_test_packet = 1'b0;
      clear_tx_buffer();
end
endtask

// Write packet into packet buffer
task write_test_packet;
   input t_avst_pcie_rx [127:0] pkt_buf;
   input logic [6:0] buf_size;
begin
   //$display("Adding test packet size=0x%d", buf_size);
   for (int i=0; i<buf_size; i=i+1) begin
      tx_buffer[num_tx_packet] = pkt_buf[i];
      num_tx_packet += 1;
   end
end
endtask

// Register MRD request
task register_mrd_request;
   input t_tlp_rp_tag tag;
   input logic [63:0]         addr;
   input logic                vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;   
begin
   tester_mmio_req_tag = tag;
   tester_mmio_req_info.requester_id           = '0;
   tester_mmio_req_info.completer_id.vf_active = vf_active;
   tester_mmio_req_info.completer_id.pfn       = pfn;
   tester_mmio_req_info.completer_id.vfn       = vfn;
   tester_mmio_req_info.lower_addr             = addr[6:0];

   @(posedge avl_clk)
      tester_mmio_req_valid = 1'b1;
   @(posedge avl_clk)
      tester_mmio_req_valid = 1'b0;
end
endtask

// Create MRD packet
task create_mrd_packet;
   input t_tlp_rp_tag         tag;
   input e_addr_mode          addr_mode;
   input logic [63:0]         addr;
   input logic [9:0]          length;               
   input logic [2:0]          bar;
   input logic                vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
  
   e_endian    endian;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_rp_tag tag;
   t_tlp_mem_req_hdr hdr;
begin
   `ifdef PTILE
      endian = BIG_ENDIAN;
   `else
      endian = LITTLE_ENDIAN;
   `endif

   hdr = get_mem_hdr(endian, MRD, addr_mode, addr, length, tag, 0);
  
   create_packet(pkt_buf, buf_size, NO_DATA, addr_mode, length, hdr, bar, vf_active, pfn, vfn, 0, 0);
   write_test_packet(pkt_buf, buf_size);

   // Register MRd request
   register_mrd_request(tag, addr, vf_active, pfn, vfn);   
end
endtask

// Create MWR packet
task create_mwr_packet;
   input e_addr_mode          addr_mode;
   input logic [63:0]         addr;
   input logic [9:0]          length;               
   input logic [2:0]          bar;
   input logic                vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [4095:0]       data;
  
   e_endian endian;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_mem_req_hdr  hdr;
begin
   `ifdef PTILE
      endian = BIG_ENDIAN;
   `else
      endian = LITTLE_ENDIAN;
   `endif

   hdr = get_mem_hdr(endian, MWR, addr_mode, addr, length, 0, 0); 
  
   create_packet(pkt_buf, buf_size, HAS_DATA, addr_mode, length, hdr, bar, vf_active, pfn, vfn, data, 0);
   write_test_packet(pkt_buf, buf_size);
end
endtask

// Create MMIO read packet
task create_mwr_packet_with_delay;
   input e_addr_mode          addr_mode;
   input logic [63:0]         addr;
   input logic [9:0]          length;               
   input logic [2:0]          bar;
   input logic                vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [4095:0]       data;
  
   e_endian endian;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_mem_req_hdr  hdr;
begin
   `ifdef PTILE
      endian = BIG_ENDIAN;
   `else
      endian = LITTLE_ENDIAN;
   `endif

   hdr = get_mem_hdr(endian, MWR, addr_mode, addr, length, 0, 0); 
   
   // Add 2 idle cycles between transfer
   create_packet(pkt_buf, buf_size, HAS_DATA, addr_mode, length, hdr, bar, vf_active, pfn, vfn, data, 2);
   write_test_packet(pkt_buf, buf_size);
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
   logic [6:0] buf_size;
   t_tlp_cpl_hdr      hdr;
begin
   `ifdef PTILE
      endian = BIG_ENDIAN;
   `else
      endian = LITTLE_ENDIAN;
   `endif

   hdr = get_cpl_hdr(endian, CPLD, length, completer, requester, byte_count, cpl_tag, lower_addr); 
   
   create_packet(pkt_buf, buf_size, HAS_DATA, ADDR32, length, hdr, 0, vf_active, 0, 0, data, 0);
   write_test_packet(pkt_buf, buf_size);
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
  
   e_endian endian;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_cpl_hdr hdr;
begin
   `ifdef PTILE
      endian = BIG_ENDIAN;
   `else
      endian = LITTLE_ENDIAN;
   `endif

   hdr = get_cpl_hdr(endian, CPL, 10'h1, completer, requester, byte_count, cpl_tag, lower_addr); 
   
   create_packet(pkt_buf, buf_size, NO_DATA, ADDR32, 10'd1, hdr, 0, vf_active, 0, 0, 0, 0);
   write_test_packet(pkt_buf, buf_size);
   f_send_test_packet();
end
endtask

task create_msg_packet;
   input logic        has_data;
   input logic [9:0]  length;
   input logic [7:0]  msg_code;

   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_msg_hdr      hdr;
begin 
   hdr = '0;
   hdr.dw0.fmttype = {has_data, 6'b110000};
   hdr.dw0.length  = length;
   hdr.msg_code    = msg_code;  
   `ifdef HTILE
      hdr = to_little_endian(hdr);
   `endif
   
   create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0, {16{32'hC0DE_1234}}, 0);
   write_test_packet(pkt_buf, buf_size);
end
endtask

task create_vdm_msg_rand_packet;
   input logic         has_data;
   input logic [9:0]   length;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   logic [4095:0] pld;
   t_tlp_vdm_msg_hdr   hdr;
begin 
   hdr = '0;
   hdr.dw0.fmttype = {has_data, 6'b110011}; //fmttype[6:5]=2'b11, fmttype[4:3]=2'b10, fmttype[2:0]=3'b010
   hdr.dw0.length  = length;
   hdr.msg_code    = 'h7f;
   hdr.tag         = {2'h0,2'h3,4'h0}; 
   hdr.pci_target_id =16'hFFFF; 
   hdr.vendor_id   = 'h1ab4; 
   hdr.upper_msg   = 32'h010000C0; //MCTP header info: RSVD = 4'h0, hdr version = 4'h1, destination ID = 8'h0, 
                                   //source EID = 8'h0, SOM = 1'b1, EOM = 1'b1, PktSeq = 2'b0, TO = 1'b0, MsgTag = 3'b0   
   `ifdef HTILE
      hdr = to_little_endian(hdr);
   `endif
   $display("   ** start Sending VDM TLP message packets **");
   pld = {{15{32'hc0de_1234}},8'hFF};
   create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0,pld, 0);
   write_test_packet(pkt_buf, buf_size);
   f_send_test_packet();
   $display("   ** End Sending VDM TLP message packets **");
end
endtask


//creating MCTP VDM message packet
task create_vdm_msg_packet;
   input logic         has_data;
   input logic [9:0]   length;
   input logic [7:0]   msg_code;
   input logic [15:0]  vendor_id;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_vdm_msg_hdr   hdr;
begin 
   hdr = '0;
   hdr.dw0.fmttype = {has_data, 6'b110010}; //fmttype[6:5]=2'b11, fmttype[4:3]=2'b10, fmttype[2:0]=3'b010
   hdr.dw0.length  = length;
   hdr.msg_code    = msg_code;  
   hdr.vendor_id   = vendor_id; 
   hdr.upper_msg   = 32'h010000C0; //MCTP header info: RSVD = 4'h0, hdr version = 4'h1, destination ID = 8'h0, 
                                   //source EID = 8'h0, SOM = 1'b1, EOM = 1'b1, PktSeq = 2'b0, TO = 1'b0, MsgTag = 3'b0   
   `ifdef HTILE
      hdr = to_little_endian(hdr);
   `endif
   $display("   ** start Sending VDM TLP message packets **");
   
   create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0, {16{32'hC0DE_1234}}, 0);
   write_test_packet(pkt_buf, buf_size);
   f_send_test_packet();
   $display("   ** End Sending VDM TLP message packets **");
end
endtask

//creating MCTP multipacket VDM message 
task create_vdm_multimsg_err_packet;
   input logic         has_data;
   input logic [9:0]   length;
   input logic [7:0]   msg_code;
   input logic [15:0]  vendor_id;
   input logic [31:0]  upper_msg;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_vdm_msg_hdr   hdr;
begin 
   hdr = '0;
   hdr.dw0.fmttype = {has_data, 6'b110010}; //fmttype[6:5]=2'b11, fmttype[4:3]=2'b10, fmttype[2:0]=3'b010
   hdr.dw0.length  = length;
   hdr.msg_code    = msg_code;  
   hdr.vendor_id   = vendor_id; 
   hdr.upper_msg   = upper_msg; //MCTP header info: RSVD = 4'h0, hdr version = 4'h1, destination ID = 8'h0, 
                                   //source EID = 8'h0, SOM = 1'b1, EOM = 1'b1, PktSeq = 2'b0, TO = 1'b0, MsgTag = 3'b0   
   `ifdef HTILE
      hdr = to_little_endian(hdr);
   `endif
   $display("   ** start Sending VDM TLP message packets **");
   if(length<='d16) begin
     create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0, {16{32'hC0DE_1234}}, 0);
   end
   else begin
     create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0, {18{32'hC0DE_1234}}, 0);
   end
   write_test_packet(pkt_buf, buf_size);
   f_send_test_packet();
   $display("   ** End Sending VDM TLP message packets **");
end
endtask

//Create MCTP Error packet with various scenarios
task create_vdm_err_packet;
   input logic         has_data;
   input logic [5:0]   hdr_fmt;
   input logic [9:0]   length;
   input logic [7:0]   msg_code;
   input logic [15:0]  vendor_id;
   input logic [31:0]  upper_msg;
   input logic [2:0]   tc;
   input logic [3:0]   th;
   input logic         ep;
   input logic [1:0]   attr;
   input logic         rsvd1; // RorT9 in VDM TLP
   input logic [2:0]   rsvd2; // RorT8 in VDM TLP
   input logic [1:0]   rsvd3; // RorAT in VDM TLP
   input logic [7:0]   tag;
   input logic [1:0]   len_mis; 
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_vdm_msg_hdr   hdr;
begin 
   hdr = '0;
   hdr.dw0.tc      = tc;
   hdr.dw0.th      = th;
   hdr.dw0.ep      = ep;
   hdr.dw0.attr    = attr;
   hdr.dw0.rsvd1   = rsvd1;
   hdr.dw0.rsvd2   = rsvd2;
   hdr.dw0.rsvd3   = rsvd3;
   hdr.dw0.fmttype = {has_data, hdr_fmt}; //fmttype[6:5]=2'b11, fmttype[4:3]=2'b10, fmttype[2:0]=3'b010
   hdr.dw0.length  = length;
   hdr.msg_code    = msg_code; 
   hdr.tag         = tag; 
   hdr.vendor_id   = vendor_id; 
   hdr.upper_msg   = upper_msg; //MCTP header info: RSVD = 4'h0, hdr version = 4'h1, destination ID = 8'h0, 
                                   //source EID = 8'h0, SOM = 1'b1, EOM = 1'b1, PktSeq = 2'b0, TO = 1'b0, MsgTag = 3'b0   
   `ifdef HTILE
      hdr = to_little_endian(hdr);
   `endif
   $display("   ** start Sending VDM TLP message packets **");
   if(len_mis == 2'h0) begin
     create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0, {16{32'hC0DE_1234}}, 0);
   end
   else if (len_mis ==2'h01) begin
     create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0, {10{32'hC0DE_1234}}, 0);
   end
   else begin
     create_packet(pkt_buf, buf_size, has_data, ADDR64, length, hdr, 0, 0, 0, 0, {20{32'hC0DE_1234}}, 0);
   end
   write_test_packet(pkt_buf, buf_size);
   f_send_test_packet();
   $display("   ** End Sending VDM TLP message packets **");
end
endtask

//For loping back TX MCTP VDM message packet to RX side
task lpbk_vdm_msg_packet;
   input logic [7:0]   fmt_type;
   input logic [9:0]   length;
   input logic [15:0]  vendor_id;
   input logic [31:0]  mctp_hdr;
   input logic [7:0]   msg_code;
   input logic [511:0] vdm_msg;
   t_avst_pcie_rx [127:0] pkt_buf;
   logic [6:0] buf_size;
   t_tlp_vdm_msg_hdr   hdr;
begin 
   hdr = '0;
   fmt_type={fmt_type[7:4],4'h2}; //fmt_type has to be 'h72/'h73 in RX side
   hdr.dw0.fmttype = fmt_type; //fmttype[6:5]=2'b11, fmttype[4:3]=2'b10, fmttype[2:0]=3'b010
   hdr.dw0.length  = length;
   hdr.requester_id ='hFFFF;
   hdr.msg_code    = msg_code;  
   hdr.vendor_id   = vendor_id; 
   hdr.upper_msg   = mctp_hdr; //MCTP header info: RSVD = 4'h0, hdr version = 4'h1, destination ID = 8'h0, 
                                   //source EID = 8'h0, SOM = 1'b1, EOM = 1'b1, PktSeq = 2'b0, TO = 1'b0, MsgTag = 3'b0   
   `ifdef HTILE
      hdr = to_little_endian(hdr);
   `endif
   $display("   ** start Sending VDM TLP message packets **");
   
   create_packet(pkt_buf, buf_size, 1, ADDR64, length, hdr, 0, 0, 0, 0, vdm_msg, 0);
   write_test_packet(pkt_buf, buf_size);
   f_send_test_packet();
   $display("   ** End Sending VDM TLP message packets **");
end
endtask

// Retrieve MMIO response 
task read_mmio_rsp;
   input  t_tlp_rp_tag    tag;
   output logic [63:0] data;
   output logic [2:0]  status;
begin
   wait (tester_mmio_buf[tag].rsp_valid);
   @(posedge avl_clk);
      tester_mmio_buf_rd = 1'b1;
      tester_mmio_buf_raddr = tag;
   @(posedge avl_clk);
      tester_mmio_buf_rd = 1'b0;
   @(posedge avl_clk);

   if (tester_mmio_entry.rsp_status !== 3'b0) begin
      $display("Warning: Read completion with error status : 0x%x", tester_mmio_entry.rsp_status);
   end 
   $display("   READDATA: 0x%x\n", tester_mmio_entry.rsp_data);
   
   data = tester_mmio_entry.rsp_data;
   status = tester_mmio_entry.rsp_status;
end
endtask

// MMIO write (32-bit)
task WRITE32;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
begin
   $display("WRITE32: address=0x%x bar=%0d vf_active=%0b pfn=%0d vfn=%0d, data=0x%x", addr, bar, vf_active, pfn, vfn, data);
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   create_mwr_packet(addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn, data);
   f_send_test_packet();
end
endtask

// MMIO write (64-bit)
task WRITE64;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
begin
   $display("WRITE64: address=0x%x bar=%0d vf_active=%0b pfn=%0d vfn=%0d, data=0x%x", addr, bar, vf_active, pfn, vfn, data);
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   create_mwr_packet(addr_mode, addr, 10'd2, bar, vf_active, pfn, vfn, data);
   f_send_test_packet();
end
endtask

// MMIO write (512-bit)
task WRITE512;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [511:0] data;
begin
   $display("WRITE512: address=0x%x bar=%0d vf_active=%0b pfn=%0d vfn=%0d, data=0x%x", addr, bar, vf_active, pfn, vfn, data);
        // addr_32, addr, length, bar, vf_active, pfn, vfn, data
   create_mwr_packet(addr_mode, addr, 10'd16, bar, vf_active, pfn, vfn, data);
   f_send_test_packet();
end
endtask

// MMIO read
task CSR_READ;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [9:0]  length;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   output logic [63:0] data;
   output logic        error;
   t_tlp_rp_tag tag;
   logic [2:0]  status;
begin
   f_get_tag(tag);

      // addr_32, address, length, bar, vf_active, pfn, vfn 
   create_mrd_packet(tag, addr_mode, addr, length, bar, vf_active, pfn, vfn);
   f_send_test_packet();

   read_mmio_rsp(tag, data, status);

   if (status !== 3'b0) begin 
      error = 1'b1;
      data = '0;
   end else begin
      error = 1'b0;
   end
end
endtask

// MMIO read (32-bit)
task READ32;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   output logic [31:0] data;
   output logic        error;
   logic [63:0] scratch;
begin
   $display("READ32: address=0x%x bar=%0d vf_active=%0b pfn=%0d vfn=%0d\n", addr, bar, vf_active, pfn, vfn);
      // addr_32, address, length, bar, vf_active, pfn, vfn 
   CSR_READ(addr_mode, addr, 10'd1, bar, vf_active, pfn, vfn, scratch, error);
   data = scratch[31:0];
end
endtask

// MMIO read (64-bit)
task READ64;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   output logic [63:0] data;
   output logic        error;
   logic [63:0] scratch;
begin
   $display("READ64: address=0x%x bar=%0d vf_active=%0b pfn=%0d vfn=%0d\n", addr, bar, vf_active, pfn, vfn);
      // addr_32, address, length, bar, vf_active, pfn, vfn 
   CSR_READ(addr_mode, addr, 10'd2, bar, vf_active, pfn, vfn, scratch, error);
   data = scratch;
end
endtask


// Assert AFU reset
task assert_afu_reset;
   int count;
   logic [63:0] scratch;
   logic [31:0] wdata;
   logic        error;
   logic [31:0] PORT_CONTROL;
begin
   count = 0;
   PORT_CONTROL = 32'h71000 + 32'h38;
   
   // Assert Port Reset 
   $display("\nAsserting Port Reset...");
   READ64(ADDR32, PORT_CONTROL, 0, 1'b0, 0, 0, scratch, error);	
   wdata = scratch[31:0];
   wdata[0] = 1'b1;
   WRITE32(ADDR32, PORT_CONTROL, 0, 1'b0, 0, 0, wdata);
   
   // Wait for Port Reset Ack 
   $display("\nCheck Port Reset ack  is asserted..."); 
   READ64(ADDR32, PORT_CONTROL, 0, 1'b0, 0, 0, scratch, error);	
   while (scratch[4] != 1'b1 & count < 100) begin
      count++;
      #75000 READ64(ADDR32, PORT_CONTROL, 0, 1'b0, 0, 0, scratch, error);	
   end 
   if (count == 100) begin
       $display("\nERROR: Port Reset Ack never asserted ...");
       test_utils::incr_err_count();
       $finish;       
   end 
   $display("\nAFU is successfully reset ...");
end
endtask

// Deassert AFU reset
task deassert_afu_reset;
   int count;
   logic [63:0] scratch;
   logic [31:0] wdata;
   logic        error;
   logic [31:0] PORT_CONTROL;
begin
   count = 0;
   PORT_CONTROL = 32'h71000 + 32'h38;

   //De-assert Port Reset 
   $display("\nDe-asserting Port Reset...");
   READ64(ADDR32, PORT_CONTROL, 0, 1'b0, 0, 0, scratch, error);	
   wdata = scratch[31:0];
   wdata[0] = 1'b0;
   WRITE32(ADDR32, PORT_CONTROL, 0, 1'b0, 0, 0, wdata);
   #5000000 READ64(ADDR32, PORT_CONTROL, 0, 1'b0, 0, 0, scratch, error);	
   if (scratch[4] != 1'b0) begin
      $display("\nERROR: Port Reset Ack Asserted!");
      test_utils::incr_err_count();
      $finish;       
   end
   
   $display("\nAFU is out of reset ...");
end
endtask




