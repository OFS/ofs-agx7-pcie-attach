// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
//---------------------------------------------------------
// Test module for the simulation. 
//---------------------------------------------------------
//
import host_bfm_types_pkg::*;

module test_host_bfm#(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
)(
    pcie_ss_axis_if.sink   axis_rx_req,
    pcie_ss_axis_if.sink   axis_rx,
    pcie_ss_axis_if.source axis_tx,
    pcie_ss_axis_if.source axis_tx_req
);

//import host_bfm_types_pkg::*;
import pfvf_class_pkg::*;
import host_memory_class_pkg::*;
import tag_manager_class_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;
import host_axis_send_class_pkg::*;
import host_axis_receive_class_pkg::*;
import host_transaction_class_pkg::*;
import host_bfm_class_pkg::*;

host_axis_send_sm_state_t    local_sm_tx, local_next_tx;
host_axis_send_sm_state_t    local_sm_tx_req, local_next_tx_req;
host_axis_receive_sm_state_t local_sm_rx, local_next_rx;
host_axis_receive_sm_state_t local_sm_rx_req, local_next_rx_req;

//---------------------------------------------------------
// Send and Receive Blocks
//---------------------------------------------------------
HostAXISSend #(
   .pf_type(pf_type),
   .vf_type(vf_type),
   .pf_list(pf_list),
   .vf_list(vf_list),
   .SEND_TUSER_WIDTH(host_bfm_types_pkg::TUSER_WIDTH),
   .SEND_TDATA_WIDTH(host_bfm_types_pkg::TDATA_WIDTH)
) axis_send_tx;
HostAXISSend #( 
   .pf_type(pf_type),
   .vf_type(vf_type),
   .pf_list(pf_list),
   .vf_list(vf_list),
   .SEND_TUSER_WIDTH(host_bfm_types_pkg::TUSER_WIDTH),
   .SEND_TDATA_WIDTH(host_bfm_types_pkg::HDR_WIDTH)
) axis_send_tx_req;
HostAXISReceive #(
   .pf_type(pf_type),
   .vf_type(vf_type),
   .pf_list(pf_list),
   .vf_list(vf_list),
   .RECEIVE_TUSER_WIDTH(host_bfm_types_pkg::TUSER_WIDTH),
   .RECEIVE_TDATA_WIDTH(host_bfm_types_pkg::TDATA_WIDTH)
) axis_receive_rx_req;
HostAXISReceive #(
   .pf_type(pf_type),
   .vf_type(vf_type),
   .pf_list(pf_list),
   .vf_list(vf_list),
   .RECEIVE_TUSER_WIDTH(host_bfm_types_pkg::TUSER_WIDTH),
   .RECEIVE_TDATA_WIDTH(host_bfm_types_pkg::TDATA_WIDTH)
) axis_receive_rx;


//---------------------------------------------------------
//  Packet Handles and Storage
//---------------------------------------------------------
Packet            #(pf_type, vf_type, pf_list, vf_list) p, p1, p2;
PacketPUMemReq    #(pf_type, vf_type, pf_list, vf_list) pumr;
PacketPUAtomic    #(pf_type, vf_type, pf_list, vf_list) pua;
PacketPUCompletion#(pf_type, vf_type, pf_list, vf_list) puc;
PacketDMMemReq    #(pf_type, vf_type, pf_list, vf_list) dmmr;
PacketDMCompletion#(pf_type, vf_type, pf_list, vf_list) dmc;
PacketUnknown     #(pf_type, vf_type, pf_list, vf_list) pu;
PacketPUMsg       #(pf_type, vf_type, pf_list, vf_list) pmsg;
PacketPUVDM       #(pf_type, vf_type, pf_list, vf_list) pvdm;

Packet#(pf_type, vf_type, pf_list, vf_list) q[$];
Packet#(pf_type, vf_type, pf_list, vf_list) qr[$];

//---------------------------------------------------------
// PFVF Structs.
//---------------------------------------------------------
pfvf_struct pfvf, pfvf2;

//---------------------------------------------------------
// Return data queue.
//---------------------------------------------------------
return_data_t return_data;

//---------------------------------------------------------
// Transaction Handles and Storage
//---------------------------------------------------------
Transaction       #(pf_type, vf_type, pf_list, vf_list) t;
ReadTransaction   #(pf_type, vf_type, pf_list, vf_list) rt;
WriteTransaction  #(pf_type, vf_type, pf_list, vf_list) wt;
AtomicTransaction #(pf_type, vf_type, pf_list, vf_list) at;
SendMsgTransaction#(pf_type, vf_type, pf_list, vf_list) mt;
SendVDMTransaction#(pf_type, vf_type, pf_list, vf_list) vt;

Transaction#(pf_type, vf_type, pf_list, vf_list) tx_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_active_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_completed_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_errored_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) tx_history_transaction_queue[$];


//---------------------------------------------------------
//  Host Memories and Tag Manager
//---------------------------------------------------------
HostMemory test_memory;
TagManager test_tag_manager;

//---------------------------------------------------------
// Vars for Simulation Use.
//---------------------------------------------------------
int num_packets_sent, num_packets_received;
int matching_packets, non_matching_packets;
int hit;
int count;
int read_count;
int payload_size;
bit found;

string access_source;

packet_format_t             packet_format;
packet_header_op_t          packet_header_op;
packet_header_op_t          packet_op;
packet_header_atomic_op_t   packet_header_atomic_op;
data_present_type_t         cpl_data_type, cpl_data_type_read;
cpl_status_t                cpl_status, cpl_status_read;
tlp_fmt_t                   tlp_fmt;
tlp_fmt_type_t              tlp_fmt_type;
packet_tag_t                tag;
packet_tag_t                packet_tag;

// Vars for PMMemReq
uint64_t     addr, addr_read;
uint64_t     address;
uint64_t     write_addr;
uint64_t     read_addr;
bit [15:0]   requester_id, requester_id_read;
bit [15:0]   completer_id, completer_id_read;
bit  [3:0]   first_dw_be;
bit  [3:0]   last_dw_be;
uint32_t     length_bytes, length_bytes_read;
bit [11:0]   byte_count, byte_count_read;
bit  [6:0]   lower_address, lower_address_read;
dm_length_t  dm_lower_address, dm_lower_address_read;

bit [31:0] data32, return_data32;
bit [63:0] data64, return_data64;

byte_t error_data_buf[];
byte_t rando;
bit [7:0] error_header_buf[];

byte_t  write_buf[];
byte_t  write_data[];
byte_t  read_buf[];
byte_t  scramble_buf[];
byte_t  atomic_buf[];
byte_t  comp_buf[];
byte_t  data_buf[];
byte_t  msg_buf[];
byte_t  vdm_buf[];
byte_t  tmp_vdm_buf[];

bit [7:0] header_buf[];

bit error;

// Vars for Header Field Checks
bit  [2:0] tc, tc_read;
//bit  [1:0] at, at_read;
bit  [2:0] attr, attr_read;
bit        ep, ep_read;
bit        td, td_read;
bit        th, th_read;
bit        ln, ln_read;
bit  [1:0] ph, read;
bit [23:0] prefix, prefix_read;
bit  [4:0] prefix_type, prefix_type_read;
bit        prefix_present, prefix_present_read;
bit  [4:0] slot_num, slot_num_read;

// Var Fields for Completion
bit bcm, bcm_read;

// Var Fields for DM Read/Write
uint64_t     host_address, host_address_read;
uint64_t     local_address_or_meta_data, local_address_or_meta_data_read;
uint64_t     local_address, local_address_read;
uint64_t     meta_data, meta_data_read;
dm_length_t  length, length_read;
bit [9:0]    length_dw;
bit          mm_mode, mm_mode_read;
bit run_pu_packet_sim;
bit run_pu_transaction_sim;
bit run_pu_method_sim;
bit run_dm_packet_sim;
bit run_dm_auto_sim;
bit run_msg_transaction_sim;
bit run_msg_method_sim;

bit [15:0] msg_route;
bit  [7:0] msg_code;
bit [31:0] lower_msg;
bit [31:0] upper_msg;


initial
begin
   axis_send_tx = new(.axis(axis_tx));
   fork
      axis_send_tx.run();
   join_none
end

initial
begin
   forever begin
      @(posedge axis_tx.clk)
      begin
         local_sm_tx   = axis_send_tx.sm_state;
         local_next_tx = axis_send_tx.sm_next;
      end
   end
end


initial
begin
   axis_send_tx_req = new(.axis(axis_tx_req));
   fork
      axis_send_tx_req.run();
   join_none
end

initial
begin
   forever begin
      @(posedge axis_tx_req.clk)
      begin
         local_sm_tx_req   = axis_send_tx_req.sm_state;
         local_next_tx_req = axis_send_tx_req.sm_next;
      end
   end
end


initial
begin
   axis_receive_rx_req = new(.axis(axis_rx_req));
   fork
      axis_receive_rx_req.run();
   join_none
end


initial
begin
   forever begin
      @(posedge axis_rx_req.clk)
      begin
         local_sm_rx_req   = axis_receive_rx_req.sm_state;
         local_next_rx_req = axis_receive_rx_req.sm_next;
      end
   end
end


initial
begin
   axis_receive_rx = new(.axis(axis_rx));
   fork
      axis_receive_rx.run();
   join_none
end


initial
begin
   forever begin
      @(posedge axis_rx.clk)
      begin
         local_sm_rx   = axis_receive_rx.sm_state;
         local_next_rx = axis_receive_rx.sm_next;
      end
   end
end


initial
begin
   test_memory = new("TestMemory");
   test_tag_manager = new();
end


initial
begin
   $timeformat(-9, 3, "ns", 4);
   run_pu_packet_sim      = 1'b0;
   run_pu_transaction_sim = 1'b0;
   run_pu_method_sim      = 1'b0;
   run_dm_packet_sim      = 1'b0;
   run_dm_auto_sim        = 1'b0;
   run_msg_transaction_sim = 1'b0;
   run_msg_method_sim      = 1'b1;
   @(posedge axis_rx.clk iff (axis_rx.rst_n === 1'b1));
   repeat (10) @(posedge axis_rx.clk);
   //----------- Write Packet #1 -------------------
   if (run_pu_packet_sim)
   begin
      host_bfm_top.host_bfm.set_mmio_mode(PU_PACKET);
      host_bfm_top.host_bfm.set_dm_mode(DM_PACKET);
      //pfvf = new(0,0,0);
      pfvf = '{0,0,0};
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      $display("Beginning Simulation with Write to Host Memory.");
      addr = 64'h1234_5678_9abc_0000;
      tag = 10'h000;
      first_dw_be = 4'hF;
      last_dw_be  = 4'hF;
      packet_header_op = WRITE;
      requester_id = 16'h0003;
      write_buf  = '{8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 
                     8'h88, 8'h99, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 8'hEE, 8'hFF,
                     8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 
                     8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F};
      pumr = new(
         .packet_header_op(packet_header_op),
         .requester_id(requester_id),
         .address(addr),
         .length_dw(write_buf.size()/4),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      pumr.set_data(write_buf);
      p = pumr;
      wait (test_tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing Write Packet Info:");
      p.print_packet_long();
      $display("");
      axis_send_tx.put_packet_in_send_queue(p);
      //----------- Read Packet #3 -------------------
      $display("Reading back from host memory...");
      addr = 64'h1234_5678_9abc_0000;
      tag = 10'h000;
      first_dw_be = 4'hF;
      last_dw_be  = 4'hF;
      packet_header_op = READ;
      requester_id = 16'h0001;
      pumr = new(
         .packet_header_op(packet_header_op),
         .requester_id(requester_id),
         .address(addr),
         .length_dw(1),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      p = pumr;
      wait (test_tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing Read Packet Info:");
      p.print_packet_long();
      $display("");
      axis_send_tx.put_packet_in_send_queue(p);
      //-----------------------------------------------
      // Check to see if packets arrived.
      //-----------------------------------------------
      @(posedge axis_tx.clk iff (host_bfm_top.tx_inbound_request_packet_queue.size() > 1));
      num_packets_received = host_bfm_top.tx_inbound_request_packet_queue.size();
      $display("Number of packets received: %0d", num_packets_received);
      p = host_bfm_top.tx_inbound_request_packet_queue.pop_front();
      $display("");
      $display("First Packet Received:");
      p.print_packet_long();
      $display("");
      $display("Second Packet Received:");
      p = host_bfm_top.tx_inbound_request_packet_queue.pop_front();
      p.print_packet_long();
      packet_tag = p.get_tag();
      //-----------------------------------------------
      // Send a test completion.
      //-----------------------------------------------
      cpl_data_type = DATA_PRESENT;
      completer_id = 16'h0009;
      cpl_status = CPL_SUCCESS;
      lower_address = 7'h00;
      tag = packet_tag;  // Fetched from Read packet above...
      comp_buf  = '{8'h08, 8'h09, 8'h0a, 8'h0b, 8'h0c, 8'h0d, 8'h0e, 8'h0f, 
         8'h78, 8'h79, 8'h7a, 8'h7b, 8'h7c, 8'h7d, 8'h7e, 8'h7f, 
         8'h98, 8'h99, 8'h9a, 8'h9b, 8'h9c, 8'h9d, 8'h9e, 8'h9f, 
         8'hb8, 8'hb9, 8'hba, 8'hbb, 8'hbc, 8'hbd, 8'hbe, 8'hbf};
      puc = new(
         .cpl_data_type(cpl_data_type),
         .requester_id(requester_id),
         .completer_id(completer_id),
         .cpl_status(cpl_status),
         .byte_count(comp_buf.size()),
         .lower_address(lower_address),
         .tag(tag)
      );
      puc.set_data(comp_buf);
      $display("Printing Completion Packet Info:");
      puc.print_packet_long();
      $display("");
      p = puc;
      p.set_send_time($realtime);
      host_bfm_top.mutex_axis_send_rx_req.get();
      host_bfm_top.axis_send_rx_req.put_packet_in_send_queue(p);
      host_bfm_top.mutex_axis_send_rx_req.put();
      // Test for reception
      //wait (axis_receive_rx_req.packet_available());
      //-----------------------------------------------
   //   count = 0;
   //   while (!axis_receive_rx_req.packet_available())
   //   begin
   //      @(posedge axis_rx_req.clk);
   //      count++;
   //   end
      //-----------------------------------------------
      @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      //-----------------------------------------------
      $display("Completion Received...");
      //$display("Number of clocks waited: %0d", count);
      //repeat (30) @(posedge axis_rx_req.clk);
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Completion Info:");
      p.print_packet_long();
      
      //-----------------------------------------------
      // Check Completion...
      //-----------------------------------------------
      //$display("Waiting on Completion...");
      //wait (axis_receive_rx_req.packet_available());
      //while (!axis_receive_rx_req.packet_available())
      //begin
         //@(posedge axis_rx_req.clk);
      //end
      repeat (30) @(posedge axis_rx_req.clk);
      //-----------------------------------------------
      //------ Host-Side Write Packet #1 --------------
      //-----------------------------------------------
      //repeat (10) @(posedge axis_rx_req.clk);
      $display("Host-Side Write to Host Memory.");
      addr = 64'h1200_9876_0000_0000;
      tag = 10'h000;
      first_dw_be = 4'hF;
      last_dw_be  = 4'hF;
      packet_header_op = WRITE;
      requester_id = host_bfm_class_pkg::REQUESTER_ID;
      write_buf  = '{8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 
                     8'h88, 8'h99, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 8'hEE, 8'hFF,
                     8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 
                     8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F};
      pumr = new(
         .packet_header_op(packet_header_op),
         .requester_id(requester_id),
         .address(addr),
         .length_dw(write_buf.size()/4),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      pumr.set_data(write_buf);
      p = pumr;
      host_bfm_top.mutex_tag_manager.get();
      wait (host_bfm_top.tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      host_bfm_top.mutex_tag_manager.put();
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing Host-Side Write Packet Info:");
      p.print_packet_long();
      $display("");
      host_bfm_top.mutex_axis_send_rx_req.get();
      host_bfm_top.axis_send_rx_req.put_packet_in_send_queue(p);
      host_bfm_top.mutex_axis_send_rx_req.put();
      @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side Write Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == WRITE)
      begin
         $display("Write packet received.");
         write_addr = p.get_addr_first_be_adjusted();
         length = p.get_length_bytes();
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         write_buf = new[payload_size];
         p.get_payload(write_buf);
         test_memory.write_data(write_addr, "Port-RX_REQ PU Write Request", packet_tag, write_buf);
         test_memory.dump_mem(write_addr, write_buf.size());
      end
      else
      begin
         $display("Write packet NOT received!");
      end
      
      //----------- Read Packet #3 -------------------
      //repeat (10) @(posedge axis_rx_req.clk);
      $display("Reading back from host memory...");
      addr = 64'h1200_9876_0000_0000;
      tag = 10'h000;
      first_dw_be = 4'hF;
      last_dw_be  = 4'hF;
      packet_header_op = READ;
      requester_id = host_bfm_class_pkg::REQUESTER_ID;
      pumr = new(
         .packet_header_op(packet_header_op),
         .requester_id(requester_id),
         .address(addr),
         .length_dw(payload_size/4),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      p = pumr;
      host_bfm_top.mutex_tag_manager.get();
      wait (host_bfm_top.tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      host_bfm_top.mutex_tag_manager.put();
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing Host-Side Read Packet Info:");
      p.print_packet_long();
      $display("");
      host_bfm_top.mutex_axis_send_rx_req.get();
      host_bfm_top.axis_send_rx_req.put_packet_in_send_queue(p);
      host_bfm_top.mutex_axis_send_rx_req.put();
      @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side Read Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == READ)
      begin
         $display("Read packet received.");
         read_addr = p.get_addr_first_be_adjusted();
         lower_address = read_addr[6:0];
         length = p.get_expected_completion_length_bytes();
         requester_id = p.get_requester_id();
         packet_tag = p.get_tag();
         read_buf = new[length];
         test_memory.read_data(read_addr, "Port-RX_REQ PU Read Request", packet_tag, read_buf);
         puc = new(
            .cpl_data_type(DATA_PRESENT),
            .requester_id(requester_id),
            .completer_id(16'h0002),
            .cpl_status(CPL_SUCCESS),
            .byte_count(read_buf.size()),
            .lower_address(lower_address),
            .tag(packet_tag)
         );
         puc.set_data(read_buf);
         p = puc;
         p.set_send_time($realtime);
         $display("Completion prepared to send back to Host:");
         p.print_packet_long();
         $display("");
         axis_send_tx.put_packet_in_send_queue(p);
      end
      else
      begin
         $display("Read packet NOT received!");
      end
      //-----------------------------------------------
      // Check to see if completion arrived.
      //-----------------------------------------------
      @(posedge axis_tx.clk iff (host_bfm_top.tx_inbound_completion_packet_queue.size() > 0));
      //-----------------------------------------------
      $display("Completion Received...");
      p = host_bfm_top.tx_inbound_completion_packet_queue.pop_front();
      $display("Completion Info:");
      p.print_packet_long();
      repeat (30) @(posedge axis_rx_req.clk);
      //------------------------------------------------------
      //  Packet Sequence Test
      //------------------------------------------------------
      $display("RX_REQ Write Sequence Test.");
      addr = 64'h1200_9876_0000_0000;
      first_dw_be = 4'hF;
      last_dw_be  = 4'hF;
      packet_header_op = WRITE;
      requester_id = host_bfm_class_pkg::REQUESTER_ID;
      count = 1;
      while (count <= 4)
      begin
         write_buf  = '{8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 
                        8'h88, 8'h99, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 8'hEE, 8'hFF,
                        8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 
                        8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F};
         pumr = new(
            .packet_header_op(packet_header_op),
            .requester_id(requester_id),
            .address(addr),
            .length_dw(write_buf.size()/4),
            .first_dw_be(first_dw_be),
            .last_dw_be(last_dw_be)
         );
         pumr.set_data(write_buf);
         p = pumr;
         host_bfm_top.mutex_tag_manager.get();
         wait (host_bfm_top.tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
         host_bfm_top.mutex_tag_manager.put();
         p.set_tag(packet_tag);
         p.set_send_time($realtime);
         $display("Printing Host-Side Write Packet Info:");
         p.print_packet_short();
         //$display("");
         //host_bfm_top.axis_send_rx_req.put_packet_in_send_queue(p);
         host_bfm_top.mmio_rx_req_packet_queue.push_back(p);
         count++;
      end
      //-----------------------------------------------------------------------
      // Tack on Write Packet to check gapping.
      //-----------------------------------------------------------------------
      repeat (25) @(posedge axis_rx_req.clk);
      write_buf  = '{8'h00, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 
                     8'h88, 8'h99, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 8'hEE, 8'hFF,
                     8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 
                     8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F};
      pumr = new(
         .packet_header_op(packet_header_op),
         .requester_id(requester_id),
         .address(addr),
         .length_dw(write_buf.size()/4),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      pumr.set_data(write_buf);
      p = pumr;
      host_bfm_top.mutex_tag_manager.get();
      wait (host_bfm_top.tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      host_bfm_top.mutex_tag_manager.put();
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing Host-Side Write Packet Info:");
      p.print_packet_short();
      //$display("");
      //host_bfm_top.axis_send_rx_req.put_packet_in_send_queue(p);
      host_bfm_top.mmio_rx_req_packet_queue.push_back(p);
      repeat (10) @(posedge axis_rx_req.clk);
      //-------------------------------------------------------
      // Perform Single Read of Host Memory of Multi-Write Area
      //-------------------------------------------------------
      $display("Reading back from host memory...");
      addr = 64'h1200_9876_0000_0000;
      first_dw_be = 4'hF;
      last_dw_be  = 4'hF;
      packet_header_op = READ;
      requester_id = host_bfm_class_pkg::REQUESTER_ID;
      pumr = new(
         .packet_header_op(packet_header_op),
         .requester_id(requester_id),
         .address(addr),
         .length_dw(payload_size/4),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      p = pumr;
      host_bfm_top.mutex_tag_manager.get();
      wait (host_bfm_top.tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      host_bfm_top.mutex_tag_manager.put();
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing Host-Side Read Packet Info:");
      p.print_packet_long();
      $display("");
      host_bfm_top.mutex_axis_send_rx_req.get();
      host_bfm_top.axis_send_rx_req.put_packet_in_send_queue(p);
      host_bfm_top.mutex_axis_send_rx_req.put();
      $display("Waiting for Read Packet to arrive.");
      //@(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      //@(posedge axis_rx_req.clk iff (axis_receive_rx_req.num_packets_available() > 5));
      packet_op = NULL;
      count = 0;
      found = 1'b0;
      while ((packet_op != READ) && (!found) && (count < 20))
      begin
         $display("Waiting for Read Packet to arrive.");
         @(posedge axis_rx_req.clk);
         if (axis_receive_rx_req.packet_available())
         begin
            count++;
            $display("Reading packet out of Receive RX_REQ.");
            p = axis_receive_rx_req.get_packet_in_receive_queue();
            packet_op = p.get_packet_op();
            $display("Reading packet out of Receive RX_REQ with Packet Op:%-s", packet_op.name());
            if (packet_op == READ)
            begin
               found = 1'b1;
               $display("Found Read Packet in RX_REQ Receive!");
            end
         end
      end
      $display("Host-Side Read Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == READ)
      begin
         $display("Read packet received.");
         read_addr = p.get_addr_first_be_adjusted();
         lower_address = read_addr[6:0];
         length = p.get_expected_completion_length_bytes();
         requester_id = p.get_requester_id();
         packet_tag = p.get_tag();
         read_buf = new[length];
         test_memory.read_data(read_addr, "Port-RX_REQ PU Read Request", packet_tag, read_buf);
         puc = new(
            .cpl_data_type(DATA_PRESENT),
            .requester_id(requester_id),
            .completer_id(16'h0002),
            .cpl_status(CPL_SUCCESS),
            .byte_count(read_buf.size()),
            .lower_address(lower_address),
            .tag(packet_tag)
         );
         puc.set_data(read_buf);
         p = puc;
         p.set_send_time($realtime);
         $display("Completion prepared to send back to Host:");
         p.print_packet_long();
         $display("");
         axis_send_tx.put_packet_in_send_queue(p);
      end
      else
      begin
         $display("Read packet NOT received!");
      end
      //--------------------------------------------------------------
      // Send a couple of messages.
      //--------------------------------------------------------------
      // First a regular message followed by a VDM.
      //--------------------------------------------------------------
      pmsg = new(
         .data_present(DATA_PRESENT),
         .msg_route(ROUTED_BY_ID),
         .requester_id(16'h0001),
         .msg_code(8'b1000_1000),
         .lower_msg(32'hA5A5_6969),
         .upper_msg(32'h7777_8888),
         .length_dw(10'd16)
      );
      msg_buf = new[16*4]; // In bytes
      msg_buf = {<<8{{<<32{ {16{32'hC0DE_1234}} }}}};
      pmsg.set_data(msg_buf);
      p =pmsg;
      p.set_send_time($realtime);
      $display("Sending MSG");
      p.print_packet_long();
      $display("");
      host_bfm_top.mutex_axis_send_rx_req.get();
      host_bfm_top.axis_send_rx_req.put_packet_in_send_queue(p);
      host_bfm_top.mutex_axis_send_rx_req.put();
      pvdm = new(
         .data_present(DATA_PRESENT),
         .msg_route(VDM_BROADCAST_FROM_ROOT_COMPLEX),
         .requester_id(16'h0001),
         .msg_code(VDM_TYPE0),
         .pci_target_id(16'hFFFF),
         .vendor_id(16'h1AB4),
         .length_dw(10'd16)
      );
      vdm_buf = new[16*4]; // In bytes
      vdm_buf = {<<8{{<<32{ {16{32'hC0DE_5678}} }}}};
      pvdm.set_data(msg_buf);
      p =pvdm;
      p.set_send_time($realtime);
      $display("Sending VDM");
      p.print_packet_long();
      $display("");
      host_bfm_top.mutex_axis_send_rx_req.get();
      host_bfm_top.axis_send_rx_req.put_packet_in_send_queue(p);
      host_bfm_top.mutex_axis_send_rx_req.put();
      //--------------------------------------------------------------
      //  Receive the messages.
      //--------------------------------------------------------------
      packet_op = NULL;
      count = 0;
      while (count < 2)
      begin
         $display("Waiting for MSG and VDM Packets to arrive.");
         @(posedge axis_rx_req.clk);
         if (axis_receive_rx_req.packet_available())
         begin
            $display("Reading packet out of Receive RX_REQ.");
            p = axis_receive_rx_req.get_packet_in_receive_queue();
            packet_op = p.get_packet_op();
            $display("Reading packet out of Receive RX_REQ with Packet Op:%-s", packet_op.name());
            if ((packet_op == MSG) || (packet_op == VDM))
            begin
               count++;
               $display("Found MSG Packet in RX_REQ Receive! Count:%0d", count);
               p.print_packet_long();
            end
         end
      end
      $display("Out of Loop");
   repeat (30) @(posedge axis_rx_req.clk);
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   // DM Mode Section
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   if (run_dm_packet_sim)
   begin
      host_bfm_top.host_bfm.set_mmio_mode(PU_PACKET);
      host_bfm_top.host_bfm.set_dm_mode(DM_PACKET);
      //pfvf.set_pfvf(0,2,1);
      pfvf = '{0,2,1};
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      //----------- DM Write #1 -------------------
      packet_header_op = WRITE;
      tag = 10'h000;
      host_address = 64'hCCBB_0000_0000_0000;
      local_address_or_meta_data = 64'h1111_2222_3333_4444;
      write_buf  = '{
         8'h08, 8'h09, 8'h0a, 8'h0b, 8'h0c, 8'h0d, 8'h0e, 8'h0f, 
         8'h18, 8'h19, 8'h1a, 8'h1b, 8'h1c, 8'h1d, 8'h1e, 8'h1f, 
         8'h28, 8'h29, 8'h2a, 8'h2b, 8'h2c, 8'h2d, 8'h2e, 8'h2f, 
         8'h38, 8'h39, 8'h3a, 8'h3b, 8'h3c, 8'h3d, 8'h3e, 8'h3f, 
         8'h48, 8'h49, 8'h4a, 8'h4b, 8'h4c, 8'h4d, 8'h4e, 8'h4f, 
         8'h58, 8'h59, 8'h5a, 8'h5b, 8'h5c, 8'h5d, 8'h5e, 8'h5f, 
         8'h68, 8'h69, 8'h6a, 8'h6b, 8'h6c, 8'h6d, 8'h6e, 8'h6f, 
         8'h78, 8'h79, 8'h7a, 8'h7b, 8'h7c, 8'h7d, 8'h7e, 8'h7f, 
         8'h88, 8'h89, 8'h8a, 8'h8b, 8'h8c, 8'h8d, 8'h8e, 8'h8f, 
         8'h98, 8'h99, 8'h9a, 8'h9b, 8'h9c, 8'h9d, 8'h9e, 8'h9f, 
         8'ha8, 8'ha9, 8'haa, 8'hab, 8'hac, 8'had, 8'hae, 8'haf, 
         8'hb8, 8'hb9, 8'hba, 8'hbb, 8'hbc, 8'hbd, 8'hbe, 8'hbf, 
         8'hc8, 8'hc9, 8'hca, 8'hcb, 8'hcc, 8'hcd, 8'hce, 8'hcf, 
         8'hd8, 8'hd9, 8'hda, 8'hdb, 8'hdc, 8'hdd, 8'hde, 8'hdf, 
         8'he8, 8'he9, 8'hea, 8'heb, 8'hec, 8'hed, 8'hee, 8'hef, 
         8'hf8, 8'hf9, 8'hfa, 8'hfb, 8'hfc, 8'hfd, 8'hfe, 8'hff};
      length = dm_length_t'(write_buf.size());
      mm_mode = '1;
      dmmr = new(
         .packet_header_op(packet_header_op),
         .host_address(host_address),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode)
      );
      dmmr.set_data(write_buf);
      p = dmmr;
      wait (test_tag_manager.get_packet_tag_success(.packet_format_in(DATA_MOVER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing DM Write Packet Info:");
      p.print_packet_long();
      $display("");
      axis_send_tx.put_packet_in_send_queue(p);
      repeat (5) @(posedge axis_tx.clk);
      //----------- DM Read #1 -------------------
      packet_header_op = READ;
      tag = 10'h000;
      host_address = 64'hCCBB_0000_0000_0000;
      local_address_or_meta_data = 64'h1111_2222_3333_4444;
      length = dm_length_t'(write_buf.size());
      mm_mode = '0;
      dmmr = new(
         .packet_header_op(packet_header_op),
         .host_address(host_address),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode)
      );
      p = dmmr;
      wait (test_tag_manager.get_packet_tag_success(.packet_format_in(DATA_MOVER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing DM Read Packet Info:");
      p.print_packet_long();
      $display("");
      $display(">>> Here #1");
      axis_send_tx_req.put_packet_in_send_queue(p);
      $display(">>> Here #2");
      //-----------------------------------------------------
      // Check for packet reception
      //-----------------------------------------------------
      //repeat (30) @(posedge axis_tx.clk);
      @(posedge axis_tx.clk iff (host_bfm_top.tx_inbound_dm_request_packet_queue.size() > 0));
      $display(">>> Here #3");
//      $display("TX Inbound DM Request Packet Queue Size: %0d", host_bfm_top.tx_inbound_dm_request_packet_queue.size());
//      $display("TX_REQ Inbound DM Request Packet Queue Size: %0d", host_bfm_top.tx_req_inbound_dm_request_packet_queue.size());
//      $display("TX_REQ Inbound Completion Packet Queue Size: %0d", host_bfm_top.tx_req_inbound_completion_packet_queue.size());
//      $display("TX_REQ Inbound Completion Packet Non-Matched Queue Size: %0d", host_bfm_top.tx_req_inbound_completion_nonmatched_packet_queue.size());
//      $display("TX_REQ Inbound Request Packet Queue Size: %0d", host_bfm_top.tx_req_inbound_request_packet_queue.size());
//      $display("TX_REQ Inbound DM Completion Packet Queue Size: %0d", host_bfm_top.tx_req_inbound_dm_completion_packet_queue.size());
//      $display("TX_REQ Inbound DM Request Packet Queue Size: %0d", host_bfm_top.tx_req_inbound_dm_request_packet_queue.size());
      @(posedge axis_tx_req.clk iff (host_bfm_top.tx_req_inbound_dm_request_packet_queue.size() > 0));
      $display(">>> Here #4");
      num_packets_received = host_bfm_top.tx_inbound_dm_request_packet_queue.size() + host_bfm_top.tx_req_inbound_dm_request_packet_queue.size();
      $display ("Number of DM packets received: %0d", num_packets_received);
      p = host_bfm_top.tx_inbound_dm_request_packet_queue.pop_front();
      $display("");
      $display("First DM Packet Received:");
      p.print_packet_long();
      $display("");
      packet_op = p.get_packet_op();
      if (packet_op == WRITE)
      begin
         $display("Write DM packet received.");
         write_addr = p.get_addr_first_be_adjusted();
         length = p.get_length_bytes();
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         write_buf = new[payload_size];
         p.get_payload(write_buf);
         host_bfm_top.mutex_host_memory.get();
         host_bfm_top.host_memory.write_data(write_addr, "Port-TX DM Write Request", packet_tag, write_buf);
         host_bfm_top.host_memory.dump_mem(write_addr, write_buf.size());
         host_bfm_top.mutex_host_memory.put();
      end
      else
      begin
         $display("Write DM packet NOT received.");
      end
      $display("Second DM Packet Received:");
      if (host_bfm_top.tx_req_inbound_dm_request_packet_queue.size() > 0)
      begin
         p = host_bfm_top.tx_req_inbound_dm_request_packet_queue.pop_front();
         p.print_packet_long();
         $display("");
         packet_op = p.get_packet_op();
         if (packet_op == READ)
         begin
            $display("Read DM packet received.");
            read_addr = p.get_dm_host_addr();
            mm_mode = p.get_mm_mode();
            dm_lower_address = read_addr[23:0];
            length = p.get_expected_completion_length_bytes();
            requester_id = p.get_requester_id();
            packet_tag = p.get_tag();
            read_buf = new[length];
            host_bfm_top.mutex_host_memory.get();
            host_bfm_top.host_memory.read_data(read_addr, "Port-TX DM Read Request", packet_tag, read_buf);
            host_bfm_top.mutex_host_memory.put();
            dmc = new(
               .tag(packet_tag),
               .cpl_status(CPL_SUCCESS),
               .local_address_or_meta_data(local_address_or_meta_data),
               .length(length),
               .mm_mode(mm_mode),
               .lower_address(dm_lower_address)
            );
            dmc.set_data(read_buf);
            p = dmc;
            p.set_send_time($realtime);
            $display("Completion prepared to send back to FPGA:");
            p.print_packet_long();
            $display("");
            host_bfm_top.mutex_axis_send_rx_req.get();
            host_bfm_top.axis_send_rx.put_packet_in_send_queue(p);
            host_bfm_top.mutex_axis_send_rx_req.put();
         end
         else
         begin
            $display("Read DM packet NOT received!");
         end
         @(posedge axis_rx.clk iff (axis_receive_rx.packet_available()));
         $display("Completion Received...");
         p = axis_receive_rx.get_packet_in_receive_queue();
         $display("Completion Info:");
         p.print_packet_long();
         repeat(30) @(posedge axis_rx.clk);
      end
      else
      begin
         $display("Zazu Second DM Read Packet not received.");
      end
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   // PU Mode Transaction Section
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   if (run_pu_transaction_sim)
   begin
      host_bfm_top.host_bfm.set_mmio_mode(PU_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      //--------------------------------------------------
      //
      //  64-bit PU Write from HOST
      //
      //--------------------------------------------------
      $display("");
      $display("-----------------------------------------------");
      $display("  Write Transaction, From Host to FPGA.........");
      $display("     64-bit                                    ");
      $display("-----------------------------------------------");
      access_source = "Directed Test-Write64,Initial";
      address = 64'h8000_0100_0300_7000;
      write_data = '{8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18};
      length_dw = 10'(write_data.size()>>2);
      first_dw_be = 4'b1111;
      last_dw_be  = 4'b1111;
      wt = new(
         .access_source(access_source),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      wt.write_request_packet.set_data(write_data);
      wt.print_data();
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(wt);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
      @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side Write Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == WRITE)
      begin
         $display("Write packet received.");
         write_addr = p.get_addr_first_be_adjusted();
         length = p.get_length_bytes();
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         write_buf = new[payload_size];
         p.get_payload(write_buf);
         test_memory.write_data(write_addr, "Port-RX_REQ PU Write Request", packet_tag, write_buf);
         test_memory.dump_mem(write_addr, write_buf.size());
      end
      else
      begin
         $display("Write packet NOT received!");
      end
      //--------------------------------------------------
      //
      //  64-bit PU Read from HOST
      //
      //--------------------------------------------------
      $display("");
      $display("-----------------------------------------------");
      $display("  Read Transaction, From Host to FPGA..........");
      $display("     64-bit                                    ");
      $display("-----------------------------------------------");
      access_source = "Directed Test-Read64,Memory Read-Back.";
      rt = new(
         .access_source(access_source),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      $display("READ packet tag from tag manager: %H", packet_tag);
      $display("READ packet tag from transaction: %H", rt.get_packet_tag());
      rt.print_data();
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(rt);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
      @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("RECEIVED READ packet tag: %H", p.get_tag());
      $display("Host-Side Read Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == READ)
      begin
         $display("Read packet received.");
         read_addr = p.get_addr_first_be_adjusted();
         lower_address = read_addr[6:0];
         length = p.get_expected_completion_length_bytes();
         requester_id = p.get_requester_id();
         packet_tag = p.get_tag();
         read_buf = new[length];
         test_memory.read_data(read_addr, "Port-RX_REQ PU Read Request", packet_tag, read_buf);
         puc = new(
            .cpl_data_type(DATA_PRESENT),
            .requester_id(requester_id),
            .completer_id(16'h0002),
            .cpl_status(CPL_SUCCESS),
            .byte_count(read_buf.size()),
            .lower_address(lower_address),
            .tag(packet_tag)
         );
         puc.set_data(read_buf);
         p = puc;
         p.set_send_time($realtime);
         $display("Completion prepared to send back to Host:");
         p.print_packet_long();
         $display("");
         axis_send_tx.put_packet_in_send_queue(p);
      end
      else
      begin
         $display("Read packet NOT received!");
      end
      @(posedge axis_rx_req.clk iff (host_bfm_top.mmio_rx_req_completed_transaction_queue.size() > 0));
      $display("We got our completed transaction!");
      host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.get();
      //t = host_bfm_top.mmio_rx_req_completed_transaction_queue.pop_front();
      t = host_bfm_top.mmio_rx_req_completed_transaction_queue.pop_front();
      host_bfm_top.mutex_mmio_rx_req_completed_transaction_queue.put();
      $display("Completion Info:");
      t.print_data();
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   // DM Mode Auto Section
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   if (run_dm_auto_sim)
   begin
      host_bfm_top.host_bfm.set_mmio_mode(PU_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      //----------- DM Write #1 -------------------
      packet_header_op = WRITE;
      tag = 10'h000;
      host_address = 64'hCCBB_0000_0000_0000;
      local_address_or_meta_data = 64'h1111_2222_3333_4444;
      write_buf  = '{
         8'h08, 8'h09, 8'h0a, 8'h0b, 8'h0c, 8'h0d, 8'h0e, 8'h0f, 
         8'h18, 8'h19, 8'h1a, 8'h1b, 8'h1c, 8'h1d, 8'h1e, 8'h1f, 
         8'h28, 8'h29, 8'h2a, 8'h2b, 8'h2c, 8'h2d, 8'h2e, 8'h2f, 
         8'h38, 8'h39, 8'h3a, 8'h3b, 8'h3c, 8'h3d, 8'h3e, 8'h3f, 
         8'h48, 8'h49, 8'h4a, 8'h4b, 8'h4c, 8'h4d, 8'h4e, 8'h4f, 
         8'h58, 8'h59, 8'h5a, 8'h5b, 8'h5c, 8'h5d, 8'h5e, 8'h5f, 
         8'h68, 8'h69, 8'h6a, 8'h6b, 8'h6c, 8'h6d, 8'h6e, 8'h6f, 
         8'h78, 8'h79, 8'h7a, 8'h7b, 8'h7c, 8'h7d, 8'h7e, 8'h7f, 
         8'h88, 8'h89, 8'h8a, 8'h8b, 8'h8c, 8'h8d, 8'h8e, 8'h8f, 
         8'h98, 8'h99, 8'h9a, 8'h9b, 8'h9c, 8'h9d, 8'h9e, 8'h9f, 
         8'ha8, 8'ha9, 8'haa, 8'hab, 8'hac, 8'had, 8'hae, 8'haf, 
         8'hb8, 8'hb9, 8'hba, 8'hbb, 8'hbc, 8'hbd, 8'hbe, 8'hbf, 
         8'hc8, 8'hc9, 8'hca, 8'hcb, 8'hcc, 8'hcd, 8'hce, 8'hcf, 
         8'hd8, 8'hd9, 8'hda, 8'hdb, 8'hdc, 8'hdd, 8'hde, 8'hdf, 
         8'he8, 8'he9, 8'hea, 8'heb, 8'hec, 8'hed, 8'hee, 8'hef, 
         8'hf8, 8'hf9, 8'hfa, 8'hfb, 8'hfc, 8'hfd, 8'hfe, 8'hff};
      length = dm_length_t'(write_buf.size());
      mm_mode = '1;
      dmmr = new(
         .packet_header_op(packet_header_op),
         .host_address(host_address),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode)
      );
      dmmr.set_data(write_buf);
      p = dmmr;
      wait (test_tag_manager.get_packet_tag_success(.packet_format_in(DATA_MOVER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing DM Write Packet Info:");
      p.print_packet_long();
      $display("");
      axis_send_tx.put_packet_in_send_queue(p);
      repeat (5) @(posedge axis_tx.clk);
      //----------- DM Read #1 -------------------
      packet_header_op = READ;
      tag = 10'h000;
      host_address = 64'hCCBB_0000_0000_0000;
      local_address_or_meta_data = 64'h1111_2222_3333_4444;
      length = dm_length_t'(write_buf.size());
      mm_mode = '0;
      dmmr = new(
         .packet_header_op(packet_header_op),
         .host_address(host_address),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode)
      );
      p = dmmr;
      wait (test_tag_manager.get_packet_tag_success(.packet_format_in(DATA_MOVER), .packet_header_op_in(packet_header_op), .packet_tag(packet_tag)));
      p.set_tag(packet_tag);
      p.set_send_time($realtime);
      $display("Printing DM Read Packet Info:");
      p.print_packet_long();
      $display("");
      axis_send_tx_req.put_packet_in_send_queue(p);
      //-----------------------------------------------------
      // Check for completion reception
      //-----------------------------------------------------
      @(posedge axis_rx.clk iff (axis_receive_rx.packet_available()));
      $display("Completion Received...");
      p = axis_receive_rx.get_packet_in_receive_queue();
      $display("Completion Info:");
      p.print_packet_long();
      //repeat(30) @(posedge axis_rx.clk);
   end
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   // PU Method Transaction Section
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
   if (run_pu_method_sim)
   begin
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      //pfvf.set_pfvf(0,2,1);
      pfvf = '{0,2,1};
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      //-----------------------------------------------------
      //  Start with 64-bit
      //-----------------------------------------------------
      $display("");
      $display("-----------------------------------------------");
      $display("  Write Transaction, From Host to FPGA.........");
      $display("     64-bit, Method Driven                     ");
      $display("-----------------------------------------------");
      address = 64'h0000_0000_0800_0108;
      data64 = 64'hbabe_face_cafe_feed;
      fork
         host_bfm_top.host_bfm.write64(address, data64);
      join_none
      @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side Write64 Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == WRITE)
      begin
         $display("Write64 packet received.");
         write_addr = p.get_addr_first_be_adjusted();
         length = p.get_length_bytes();
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         write_buf = new[payload_size];
         p.get_payload(write_buf);
         test_memory.write_data(write_addr, "Port-RX_REQ PU Write Request", packet_tag, write_buf);
         test_memory.dump_mem(write_addr, write_buf.size());
      end
      else
      begin
         $display("Write64 packet NOT received!");
      end
      $display("");
      $display("-----------------------------------------------");
      $display("  Read Transaction, From Host to FPGA..........");
      $display("     64-bit, Method Driven                     ");
      $display("-----------------------------------------------");
      fork
         begin
            //host_bfm_top.host_bfm.read64(address, return_data64);
            //host_bfm_top.host_bfm.read64_with_completion_status(address, return_data64, error, cpl_status_read);
            host_bfm_top.host_bfm.read_data_with_completion_status(address, 8, return_data64, return_data, error, cpl_status_read);
         end
         begin
      //join_none
            @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
            p = axis_receive_rx_req.get_packet_in_receive_queue();
            $display("Host-Side Read64 Info:");
            p.print_packet_long();
            packet_op = p.get_packet_op();
            if (packet_op == READ)
            begin
               $display("Read64 packet received.");
               read_addr = p.get_addr_first_be_adjusted();
               lower_address = read_addr[6:0];
               length = p.get_expected_completion_length_bytes();
               $display("Read64 expected completion length:%0d", length);
               requester_id = p.get_requester_id();
               packet_tag = p.get_tag();
               read_buf = new[length];
               test_memory.read_data(read_addr, "Port-RX_REQ PU Read64 Request", packet_tag, read_buf);
               scramble_buf = new[16];
               for (int i = 0; i < scramble_buf.size(); i++)
               begin
                  std::randomize(rando);
                  scramble_buf[i] = rando;
               end
               puc = new(
                  .cpl_data_type(DATA_PRESENT),
                  .requester_id(requester_id),
                  .completer_id(16'h0002),
                  .cpl_status(CPL_SUCCESS),
                  //.cpl_status(CPL_UNSUPPORTED_REQUEST),
                  //.cpl_status(CPL_REQUEST_RETRY),
                  //.cpl_status(CPL_COMPLETER_ABORT),
                  //.cpl_status(CPL_ERROR),
                  .byte_count(read_buf.size()),
                  //.byte_count(scramble_buf.size()),
                  .lower_address(lower_address),
                  .tag(packet_tag)
               );
               puc.set_data(read_buf);
               //puc.set_data(scramble_buf);
               p = puc;
               p.set_send_time($realtime);
               $display("Completion64 prepared to send back to Host:");
               p.print_packet_long();
               $display("");
               axis_send_tx.put_packet_in_send_queue(p);
            end
            else
            begin
               $display("Read64 packet NOT received!");
            end
         end
      join
      //@(posedge axis_rx_req.clk iff (host_bfm_top.mmio_rx_req_completed_transaction_queue.size() > 1));
      //@(posedge axis_rx_req.clk); // Have to wait a clock to get return_data64 from read_64
      //$display("Data from Method read64: %H", return_data64); 
      $display("Data from Method read_data: %H", return_data64); 
      $display("  Return Data:",return_data);
      $display("Error:%H   CplD Status:%-s", error, cpl_status_read);
      //-----------------------------------------------------
      //  Now 32-bit...
      //-----------------------------------------------------
      $display("");
      $display("-----------------------------------------------");
      $display("  Write Transaction, From Host to FPGA.........");
      $display("     32-bit, Method Driven                     ");
      $display("-----------------------------------------------");
      address = 64'h0000_0000_0800_0204;
      data32 = 32'hcafe_babe;
      //pfvf.set_pfvf(1,0,0);
      pfvf = '{1,0,0};
      host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
      fork
         host_bfm_top.host_bfm.write32(address, data32);
      join_none
      @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side Write32 Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == WRITE)
      begin
         $display("Write32 packet received.");
         write_addr = p.get_addr_first_be_adjusted();
         length = p.get_length_bytes();
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         write_buf = new[payload_size];
         p.get_payload(write_buf);
         test_memory.write_data(write_addr, "Port-RX_REQ PU Write32 Request", packet_tag, write_buf);
         test_memory.dump_mem(write_addr, write_buf.size());
      end
      else
      begin
         $display("Write32 packet NOT received!");
      end
      $display("");
      $display("-----------------------------------------------");
      $display("  Read Transaction, From Host to FPGA..........");
      $display("     32-bit, Method Driven                     ");
      $display("-----------------------------------------------");
      fork
         begin
            //host_bfm_top.host_bfm.read32(address, return_data32);
            //host_bfm_top.host_bfm.read32_with_completion_status(address, return_data32, error, cpl_status_read);
            host_bfm_top.host_bfm.read_data_with_completion_status(address, 4, return_data64, return_data, error, cpl_status_read);
         end
         begin
      //join_none
            @(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
            p = axis_receive_rx_req.get_packet_in_receive_queue();
            $display("Host-Side Read32 Info:");
            p.print_packet_long();
            packet_op = p.get_packet_op();
            if (packet_op == READ)
            begin
               $display("Read32 packet received.");
               read_addr = p.get_addr_first_be_adjusted();
               lower_address = read_addr[6:0];
               length = p.get_expected_completion_length_bytes();
               $display("Read32 expected completion length:%0d", length);
               $display("Read32 tag:%H", p.get_tag());
               requester_id = p.get_requester_id();
               packet_tag = p.get_tag();
               read_buf = new[length];
               test_memory.read_data(read_addr, "Port-RX_REQ PU Read32 Request", packet_tag, read_buf);
               scramble_buf = new[16];
               for (int i = 0; i < 16; i++)
               begin
                  std::randomize(rando);
                  scramble_buf[i] = rando;
               end
               puc = new(
                  .cpl_data_type(DATA_PRESENT),
                  .requester_id(requester_id),
                  .completer_id(16'h0002),
                  .cpl_status(CPL_SUCCESS),
                  //.cpl_status(CPL_UNSUPPORTED_REQUEST),
                  //.cpl_status(CPL_REQUEST_RETRY),
                  //.cpl_status(CPL_COMPLETER_ABORT),
                  //.cpl_status(CPL_ERROR),
                  .byte_count(read_buf.size()),
                  //.byte_count(scramble_buf.size()),
                  .lower_address(lower_address),
                  .tag(packet_tag)
               );
               puc.set_data(read_buf);
               //puc.set_data(scramble_buf);
               p = puc;
               p.set_send_time($realtime);
               $display("Completion32 prepared to send back to Host:");
               p.print_packet_long();
               $display("");
               axis_send_tx.put_packet_in_send_queue(p);
            end
            else
            begin
               $display("Read32 packet NOT received!");
            end
         end
      join
      //@(posedge axis_rx_req.clk iff (host_bfm_top.mmio_rx_req_completed_transaction_queue.size() > 1));
      //repeat (1) @(posedge axis_rx_req.clk); // Have to wait a clock to get return_data32 from read32
      //$display("Data from Method read32: %H", return_data32); 
      $display("Data from Method read_data: %H", return_data64); 
      $display("  Return Data:",return_data);
      $display("Error:%H   CplD Status:%-s", error, cpl_status_read);
   end
   if (run_msg_transaction_sim)
   begin
      host_bfm_top.host_bfm.set_mmio_mode(PU_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      //--------------------------------------------------
      //
      //  Host Send MSG Packet with data.
      //
      //--------------------------------------------------
      $display("");
      $display("-----------------------------------------------");
      $display("  Msg Transaction, From Host to FPGA...........");
      $display("     Contains data.                            ");
      $display("-----------------------------------------------");
      access_source = "Directed Test-Msg with Data";
      msg_buf = new[16*4]; // In bytes
      msg_buf = {<<8{{<<32{ {16{32'hC0DE_1234}} }}}};
      length_dw = 10'(msg_buf.size()>>2);
      mt = new(
         .access_source(access_source),
         .data_present(DATA_PRESENT),
         .msg_route(ROUTED_BY_ID),
         .requester_id(16'h0001),
         .msg_code(8'b1000_1000),
         .lower_msg(32'hA5A5_6969),
         .upper_msg(32'h7777_8888),
         .length_dw(length_dw)
      );
      mt.request_packet.set_data(msg_buf);
      mt.print_data();
      $display("Before RX REQ Input transaction queue Mutex.");
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(mt);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
      $display("After  RX REQ Input transaction queue Mutex.");
      //@(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      while (!axis_receive_rx_req.packet_available())
      begin
         @(posedge axis_rx_req.clk);
         $display("Packets in RX REQ Receive: %0d", axis_receive_rx_req.num_packets_available());
      end
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side Msg Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == MSG)
      begin
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         data_buf = new[payload_size];
         p.get_payload(data_buf);
         $display("Msg packet received. Tag:%H  Payload size:%0d  Payload:", packet_tag, payload_size);
         $display(data_buf);
      end
      else
      begin
         $display("Msg packet NOT received!");
      end
      //--------------------------------------------------
      //
      //  Host Send VDM Packet with data.
      //
      //--------------------------------------------------
      $display("");
      $display("-----------------------------------------------");
      $display("  VDM Transaction, From Host to FPGA...........");
      $display("     Contains data.                            ");
      $display("-----------------------------------------------");
      access_source = "Directed Test-VDM with Data";
      vdm_buf = new[16*4]; // In bytes
      vdm_buf = {<<8{{<<32{ {16{32'hC0DE_5678}} }}}};
      length_dw = 10'(vdm_buf.size()>>2);
      vt = new(
         .access_source(access_source),
         .data_present(DATA_PRESENT),
         .msg_route(VDM_BROADCAST_FROM_ROOT_COMPLEX),
         .requester_id(16'h0001),
         .msg_code(VDM_TYPE0),
         .pci_target_id(16'hFFFF),
         .vendor_id(16'h1AB4),
         .length_dw(length_dw)
      );
      vt.request_packet.set_data(vdm_buf);
      vt.print_data();
      $display("Before RX REQ Input transaction queue Mutex.");
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.get();
      host_bfm_top.mmio_rx_req_input_transaction_queue.push_back(vt);
      host_bfm_top.mutex_mmio_rx_req_input_transaction_queue.put();
      $display("After  RX REQ Input transaction queue Mutex.");
      //@(posedge axis_rx_req.clk iff (axis_receive_rx_req.packet_available()));
      while (!axis_receive_rx_req.packet_available())
      begin
         @(posedge axis_rx_req.clk);
         $display("Packets in RX REQ Receive: %0d", axis_receive_rx_req.num_packets_available());
      end
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side VDM Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == VDM)
      begin
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         data_buf = new[payload_size];
         p.get_payload(data_buf);
         $display("VDM packet received. Tag:%H  Payload size:%0d  Payload:", packet_tag, payload_size);
         $display(data_buf);
      end
      else
      begin
         $display("VDM packet NOT received!");
      end
   end
   //--------------------------------------------------
   //  Send Messages with Methods
   //--------------------------------------------------
   if (run_msg_method_sim)
   begin
      host_bfm_top.host_bfm.set_mmio_mode(PU_METHOD_TRANSACTION);
      host_bfm_top.host_bfm.set_dm_mode(DM_AUTO_TRANSACTION);
      //--------------------------------------------------
      //
      //  Host Send MSG Packet with data.
      //
      //--------------------------------------------------
      $display("");
      $display("-----------------------------------------------");
      $display("  Msg Transaction, From Host to FPGA...........");
      $display("     Contains data.                            ");
      $display("-----------------------------------------------");
      access_source = "Directed Test-Msg with Data";
      msg_buf = new[16*4]; // In bytes
      msg_buf = {<<8{{<<32{ {16{32'hC0DE_1234}} }}}};
      host_bfm_top.host_bfm.send_msg(
         .data_present(DATA_PRESENT),
         .msg_route(ROUTED_BY_ID),
         .requester_id(16'h0001),
         .msg_code(8'b1000_1000),
         .lower_msg(32'hA5A5_6969),
         .upper_msg(32'h7777_8888),
         .tag('0),
         .msg_data(msg_buf)
      );
      while (!axis_receive_rx_req.packet_available())
      begin
         @(posedge axis_rx_req.clk);
         $display("Packets in RX REQ Receive: %0d", axis_receive_rx_req.num_packets_available());
      end
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side Msg Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == MSG)
      begin
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         data_buf = new[payload_size];
         p.get_payload(data_buf);
         $display("Msg packet received. Tag:%H  Payload size:%0d  Payload:", packet_tag, payload_size);
         $display(data_buf);
      end
      else
      begin
         $display("Msg packet NOT received!");
      end
      //--------------------------------------------------
      //
      //  Host Send VDM Packet with data.
      //
      //--------------------------------------------------
      $display("");
      $display("-----------------------------------------------");
      $display("  VDM Transaction, From Host to FPGA...........");
      $display("     Contains data.                            ");
      $display("-----------------------------------------------");
      access_source = "Directed Test-VDM with Data";
      vdm_buf = new[16*4]; // In bytes
      vdm_buf = {<<8{{<<32{ {16{32'hC0DE_5678}} }}}};
      //vdm_buf = new[(16*4)+1]; // In bytes
      //tmp_vdm_buf = {<<8{{<<32{ {16{32'hC0DE_5678}} }}}};
      //for (int i = 0; i < tmp_vdm_buf.size(); i++)
      //begin
         //vdm_buf[i] = tmp_vdm_buf[i];
      //end
      //vdm_buf[tmp_vdm_buf.size()] = 8'h77;
      //vdm_buf[tmp_vdm_buf.size()+1] = 8'h88;
      //vdm_buf[tmp_vdm_buf.size()+2] = 8'h99;
      host_bfm_top.host_bfm.send_vdm(
         .data_present(DATA_PRESENT),
         .msg_route(VDM_BROADCAST_FROM_ROOT_COMPLEX),
         .requester_id(16'h0001),
         .msg_code(VDM_TYPE0),
         .pci_target_id(16'hFFFF),
         .vendor_id(16'h1AB4),
         .msg_data(vdm_buf)
      );
      while (!axis_receive_rx_req.packet_available())
      begin
         @(posedge axis_rx_req.clk);
         $display("Packets in RX REQ Receive: %0d", axis_receive_rx_req.num_packets_available());
      end
      p = axis_receive_rx_req.get_packet_in_receive_queue();
      $display("Host-Side VDM Info:");
      p.print_packet_long();
      packet_op = p.get_packet_op();
      if (packet_op == VDM)
      begin
         packet_tag = p.get_tag();
         payload_size = p.get_payload_size();
         data_buf = new[payload_size];
         p.get_payload(data_buf);
         $display("VDM packet received. Tag:%H  Payload size:%0d  Payload:", packet_tag, payload_size);
         $display(data_buf);
      end
      else
      begin
         $display("VDM packet NOT received!");
      end
   end
   //----------- Finish ----------------------
   repeat (30) @(posedge axis_rx.clk);
   $finish;
end


endmodule
