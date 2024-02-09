// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
//---------------------------------------------------------
// Top-level module for the AXI-ST BFM
//---------------------------------------------------------

import host_bfm_types_pkg::*;

module host_bfm_top # (
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) (
    pcie_ss_axis_if.source axis_rx,
    pcie_ss_axis_if.source axis_rx_req,
    pcie_ss_axis_if.sink   axis_tx,
    pcie_ss_axis_if.sink   axis_tx_req
);

parameter REQUESTER_ID = 16'h0001;
parameter COMPLETER_ID = 16'h0001;
parameter MEMORY_NAME = "HostMemory0";

import host_bfm_types_pkg::*;
import host_memory_class_pkg::*;
import tag_manager_class_pkg::*;
import packet_delay_class_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;
import host_axis_send_class_pkg::*;
import host_axis_receive_class_pkg::*;
import host_transaction_class_pkg::*;
import host_bfm_class_pkg::*;


//---------------------------------------------------------
// Send and receive state machine monitoring variables.
//---------------------------------------------------------
host_axis_send_sm_state_t local_sm_rx, local_next_rx;
host_axis_send_sm_state_t local_sm_rx_req, local_next_rx_req;
host_axis_receive_sm_state_t local_sm_tx, local_next_tx;
host_axis_receive_sm_state_t local_sm_tx_req, local_next_tx_req;


//---------------------------------------------------------
//  Semaphores
//---------------------------------------------------------
semaphore mutex_tag_manager;
semaphore mutex_host_memory;
semaphore mutex_axis_send_rx_req;
semaphore mutex_axis_send_rx;
semaphore mutex_mmio_rx_req_input_transaction_queue;
semaphore mutex_mmio_rx_req_active_transaction_queue;
semaphore mutex_mmio_rx_req_completed_transaction_queue;
semaphore mutex_mmio_rx_req_errored_transaction_queue;
semaphore mutex_mmio_rx_req_packet_history_queue;
semaphore mutex_dm_rx_packet_history_queue;
semaphore mutex_tx_inbound_message_queue;
semaphore mutex_tx_req_inbound_message_queue;


//---------------------------------------------------------
// AXI-ST Interface Class Object Declarations
//---------------------------------------------------------
HostAXISSend #(
   .pf_type(pf_type),
   .vf_type(vf_type),
   .pf_list(pf_list),
   .vf_list(vf_list),
   .SEND_TUSER_WIDTH(host_bfm_types_pkg::TUSER_WIDTH),
   .SEND_TDATA_WIDTH(host_bfm_types_pkg::TDATA_WIDTH)
) axis_send_rx_req;
HostAXISSend #(
   .pf_type(pf_type),
   .vf_type(vf_type),
   .pf_list(pf_list),
   .vf_list(vf_list),
   .SEND_TUSER_WIDTH(host_bfm_types_pkg::TUSER_WIDTH),
   .SEND_TDATA_WIDTH(host_bfm_types_pkg::TDATA_WIDTH)
) axis_send_rx;
HostAXISReceive #(
   .pf_type(pf_type),
   .vf_type(vf_type),
   .pf_list(pf_list),
   .vf_list(vf_list),
   .RECEIVE_TUSER_WIDTH(host_bfm_types_pkg::TUSER_WIDTH),
   .RECEIVE_TDATA_WIDTH(host_bfm_types_pkg::TDATA_WIDTH)
) axis_receive_tx;
HostAXISReceive #(
   .pf_type(pf_type),
   .vf_type(vf_type),
   .pf_list(pf_list),
   .vf_list(vf_list),
   .RECEIVE_TUSER_WIDTH(host_bfm_types_pkg::TUSER_WIDTH),
   .RECEIVE_TDATA_WIDTH(host_bfm_types_pkg::HDR_WIDTH)
) axis_receive_tx_req;


//------------------------------------------------------------------------
// Packet Queues for packet data flow. Queues use Base Class
//    packet handles of type "Packet" so that different packet types can 
//    exist in queue (polymorphism).
//------------------------------------------------------------------------
// MMIO Packet Queues - RX_REQ Interface
//------------------------------------------------------------------------
Packet#(pf_type, vf_type, pf_list, vf_list) mmio_rx_req_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) mmio_rx_req_packet_history_queue[$];


//-----------------------------------------
// Data Mover Packet Queues - RX Interface
//-----------------------------------------
Packet#(pf_type, vf_type, pf_list, vf_list) dm_rx_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) dm_rx_packet_history_queue[$];


//--------------------------------------------
// Mixed Traffic Packet Queues - TX Interface
//--------------------------------------------
Packet#(pf_type, vf_type, pf_list, vf_list) tx_inbound_completion_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_inbound_completion_nonmatched_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_inbound_request_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_inbound_message_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_inbound_dm_completion_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_inbound_dm_request_packet_queue[$];


//------------------------------------------------
// Mixed Traffic Packet Queues - TX_REQ Interface
//------------------------------------------------
Packet#(pf_type, vf_type, pf_list, vf_list) tx_req_inbound_completion_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_req_inbound_completion_nonmatched_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_req_inbound_request_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_req_inbound_message_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_req_inbound_dm_completion_packet_queue[$];
Packet#(pf_type, vf_type, pf_list, vf_list) tx_req_inbound_dm_request_packet_queue[$];


//-------------------------------------------------------------------------------
// Transaction Handles for various transaction types:
//    Transaction.........: Base Class Transaction Handle
//    ReadTransaction.....: Power User Read Transaction
//    WriteTransaction....: Power User Write Transaction
//    AtomicTransaction...: Power User Atomic Transaction
//       - Fetch-Add
//       - Swap
//       - Compare-and-Swap (CAS)
//-------------------------------------------------------------------------------
Transaction      #(pf_type, vf_type, pf_list, vf_list) transaction;
ReadTransaction  #(pf_type, vf_type, pf_list, vf_list) read_transaction;
WriteTransaction #(pf_type, vf_type, pf_list, vf_list) write_transaction;
AtomicTransaction#(pf_type, vf_type, pf_list, vf_list) atomic_transaction;


//------------------------------------------------------------------------
// Transaction Queues for packet data flow. Queues use Base Class
//    transaction handles of type "Transaction" so that different 
//    transaction types can exist in queue (polymorphism).
//------------------------------------------------------------------------
Transaction#(pf_type, vf_type, pf_list, vf_list) mmio_rx_req_input_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) mmio_rx_req_active_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) mmio_rx_req_completed_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) mmio_rx_req_errored_transaction_queue[$];
Transaction#(pf_type, vf_type, pf_list, vf_list) mmio_rx_req_history_transaction_queue[$];


//------------------------------------------------------------------------
// Host Memories and Tag Manager
//------------------------------------------------------------------------
HostMemory host_memory;
TagManager tag_manager;


//---------------------------------------------------------
// Concrete BFM Class Definition
//---------------------------------------------------------
class HostBFMConcrete #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends host_bfm_class_pkg::HostBFM#(pf_type, vf_type, pf_list, vf_list);

   function new();
      super.new();
   endfunction

   virtual task run_rx_req();
      Packet#(pf_type, vf_type, pf_list, vf_list) p;
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      packet_tag_t packet_tag;
      packet_header_op_t packet_op;
      uint64_t debug_address;
      $timeformat(-9, 3, "ns", 4);
      @(posedge axis_rx_req.clk iff (axis_rx_req.rst_n === 1'b1));
      repeat (10) @(posedge axis_rx_req.clk); // Wait for 10 clocks after reset
      forever begin
         @(posedge axis_rx_req.clk)
         begin
            if (mmio_mode == PU_PACKET)
            begin
               //while (mmio_rx_req_packet_queue.size() > 0)
               while (mmio_rx_req_packet_queue.size() > 0)
               begin
                  p = mmio_rx_req_packet_queue.pop_front();
                  packet_op = p.get_packet_op();
                  //if ((packet_op == READ) || (packet_op == WRITE) || (packet_op == ATOMIC) || (packet_op == MSG) || (packet_op == VDM))
                  if ((packet_op == READ) || (packet_op == WRITE) || (packet_op == ATOMIC))
                  begin
                     mutex_tag_manager.get();
                     wait (tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_op), .packet_tag(packet_tag)));
                     mutex_tag_manager.put();
                     p.set_tag(packet_tag);
                     p.set_send_time($realtime);
                     rx_req_packet_gap_delay_queue.put_packet(p.get_request_delay(),p.get_gap(),p); // Put at delay and gap between outgoing packets.
                  end // Packets that need tag.
                  else  // Else send packet as is.
                  begin
                     p.set_send_time($realtime);
                     rx_req_packet_gap_delay_queue.put_packet(p.get_request_delay(),p.get_gap(),p); // Put at delay and gap between outgoing packets.
                  end
               end
            end
            else  // Transaction Mode -- Manual or Method Mode
            begin
               mutex_mmio_rx_req_input_transaction_queue.get();
               while (mmio_rx_req_input_transaction_queue.size() > 0)
               begin
                  t = mmio_rx_req_input_transaction_queue.pop_front();
                  packet_op = (t.get_transactor_type() == CSR_RD) ? READ : (t.get_transactor_type() == CSR_WR) ? WRITE : (t.get_transactor_type() == CSR_ATOMIC) ? ATOMIC : (t.get_transactor_type() == SEND_MSG) ? MSG : (t.get_transactor_type() == SEND_VDM) ? VDM : NULL;
                  if (packet_op != NULL)
                  begin
                     if ((packet_op != MSG) && (packet_op != VDM))
                     begin
                        mutex_tag_manager.get();
                        wait (tag_manager.get_packet_tag_success(.packet_format_in(POWER_USER), .packet_header_op_in(packet_op), .packet_tag(packet_tag)))
                        mutex_tag_manager.put();
                        t.set_packet_tag(packet_tag);
                     end
                     t.set_request_sent();
                     p = t.request_packet;
                     rx_req_packet_gap_delay_queue.put_packet(p.get_request_delay(),p.get_gap(),p); // Put at delay and gap between outgoing packets.
                     mutex_mmio_rx_req_active_transaction_queue.get();
                     if ((packet_op == READ) || (packet_op == ATOMIC)) // Writes are posted and no longer active.
                     begin
                        mmio_rx_req_active_transaction_queue.push_back(t);
                     end
                     mutex_mmio_rx_req_active_transaction_queue.put();
                  end
               end
               mutex_mmio_rx_req_input_transaction_queue.put();
            end
            //--------------------------------------------------------------------
            // Using Packet Delay Gap Queue
            // This queue is queried each clock of axis_rx_req.clk to see if
            // any of the delayed packets are ready to send (delay timed
            // out).  The delay includes a static delay as well as a gap delay
            // from the last packet to the one being put into the queue.  This
            // guarantees that the packets have a certain spacing and aren't
            // jammed together.
            //--------------------------------------------------------------------
            if (rx_req_packet_gap_delay_queue.packet_ready())
            begin
               p = rx_req_packet_gap_delay_queue.get_packet();
               //---------------- Debug -------------------------
               //debug_address = p.get_addr();
               //$display(">>> SEND RXREQ Packet Snoop: Type:%-s   Tag:%H   Address:%H_%H_%H_%H", p.get_packet_op().name(), p.get_tag(), debug_address[63:48], debug_address[47:32], debug_address[31:16], debug_address[15:0]);
               //---------------- Debug -------------------------
               mutex_axis_send_rx_req.get();
               axis_send_rx_req.put_packet_in_send_queue(p);
               mutex_axis_send_rx_req.put();
               mutex_mmio_rx_req_packet_history_queue.get();
               mmio_rx_req_packet_history_queue.push_back(p);
               mutex_mmio_rx_req_packet_history_queue.put();
               if (p.get_packet_op() == WRITE)
               begin
                  mutex_tag_manager.get();
                  tag_manager.release_tag(p.get_tag());
                  mutex_tag_manager.put();
               end
            end
         end
      end
   endtask


   virtual task run_tx();
      Packet#(pf_type, vf_type, pf_list, vf_list) p;
      Packet#(pf_type, vf_type, pf_list, vf_list) cpld;
      Packet#(pf_type, vf_type, pf_list, vf_list) req;
      PacketPUCompletion#(pf_type, vf_type, pf_list, vf_list) puc;
      PacketDMCompletion#(pf_type, vf_type, pf_list, vf_list) dmc;
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      packet_tag_t       packet_tag;
      packet_header_op_t packet_op;
      packet_header_atomic_op_t packet_atomic_op;
      packet_format_t    packet_format;
      int num_packets_received;
      int payload_size;
      bit matched;
      bit mm_mode;
      uint64_t   address;
      //---------------- Debug -------------------------
      uint64_t   debug_address;
      //---------------- Debug -------------------------
      uint64_t   dm_host_address;
      uint64_t   dm_local_address;
      uint64_t   dm_meta_data;
      bit  [6:0] lower_address;
      bit [23:0] dm_lower_address;
      uint32_t   length;
      bit [15:0] requester_id;
      bit [15:0] completer_id;
      byte_t read_buf[];
      byte_t write_buf[];
      byte_t msg_buf[];
      byte_t vdm_buf[];
      byte_t addend[];
      byte_t result[];
      byte_t swap[];
      byte_t compare[];
      byte_t atomic_payload[];
      string access_source;
      $timeformat(-9, 3, "ns", 4);
      @(posedge axis_tx.clk iff (axis_tx.rst_n === 1'b1));
      repeat (10) @(posedge axis_tx.clk); // Wait for 10 clocks after reset
      forever begin
         //@(posedge axis_tx.clk)
         @(negedge axis_tx.clk)
         begin
            while (axis_receive_tx.num_packets_available() > 0)
            begin
               p = axis_receive_tx.get_packet_in_receive_queue();
               //---------------- Debug -------------------------
               //debug_address = p.get_addr();
               //$display(">>> RECEIVE TX Packet Snoop: Type:%-s   Tag:%H   Address:%H_%H_%H_%H", p.get_packet_op().name(), p.get_tag(), debug_address[63:48], debug_address[47:32], debug_address[31:16], debug_address[15:0]);
               //---------------- Debug -------------------------
               packet_op = p.get_packet_op();
               packet_format = p.get_packet_format();
               p.set_arrival_time($realtime);
               if (packet_format == POWER_USER)
               begin
                  if (mmio_mode == PU_PACKET)
                  begin
                     if (packet_op == COMPLETION)
                     begin
                        tx_inbound_completion_packet_queue.push_back(p);
                     end
                     else  // Packet not completion
                     begin
                        if ((packet_op == MSG) || (packet_op == VDM))
                        begin
                           mutex_tx_inbound_message_queue.get();
                           tx_inbound_message_queue.push_back(p);
                           mutex_tx_inbound_message_queue.put();
                        end
                        else
                        begin
                           //$display("Pushing Non-completion into tx_inbound_request_packet_queue");
                           tx_inbound_request_packet_queue.push_back(p);
                        end
                     end
                  end
                  else // Transaction Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                  begin
                     if (packet_op == COMPLETION)
                     begin
                        tx_inbound_completion_packet_queue.push_back(p);
                        //-------------------------------------------------------------------------
                        // The following while loop goes through all the
                        // available completions in the packet queue and
                        // attempts to match the tag to the transactions in
                        // the active transaction queue.
                        //
                        // If there is a tag match, the completion is added to the
                        // transaction.  If the tag doesn't match any of the
                        // active transactions, then it is put into
                        // a "nonmatched" completion queue for examination.
                        //-------------------------------------------------------------------------
                        while (tx_inbound_completion_packet_queue.size() > 0)
                        begin
                           cpld = tx_inbound_completion_packet_queue.pop_front();
                           //------------- Debug -------------------
                           //$display("HOST BFM, TX: PU CplD Found:");
                           //cpld.print_packet();
                           //------------- Debug -------------------
                           matched = 1'b0;
                           mutex_mmio_rx_req_active_transaction_queue.get();
                           foreach (mmio_rx_req_active_transaction_queue[j])
                           begin
                              //------------- Debug -------------------
                              $display("TX: Tag Search Comparison: CPLD Tag: %H   Active Tag: %H", cpld.get_tag(), mmio_rx_req_active_transaction_queue[j].get_packet_tag());
                              //------------- Debug -------------------
                              if ((cpld.get_tag() == mmio_rx_req_active_transaction_queue[j].get_packet_tag()) && (!matched))
                              begin
                                 matched = 1'b1;
                                 mmio_rx_req_active_transaction_queue[j].add_completion(cpld);
                                 //------------- Debug ---------------------------
                                 $display("TX: PU Completion ADDED to transaction!");
                                 //------------- Debug ---------------------------
                              end
                           end
                           mutex_mmio_rx_req_active_transaction_queue.put();
                           if (!matched)
                           begin
                              tx_inbound_completion_nonmatched_packet_queue.push_back(cpld);
                              //------------- Debug ---------------------------
                              $display("TX: NO match found for PU CplD!");
                              //------------- Debug ---------------------------
                           end
                           else
                           begin
                              //------------- Debug ---------------------------
                              $display("TX: Match found for PU CPLD!");
                              //------------- Debug ---------------------------
                           end
                        end
                        //-------------------------------------------------------------------------
                        // The following iteration loop checks each of the
                        // transactions in the active transaction queue to see
                        // if they are done receiving data/completions.
                        //
                        // If so, then they are put in the "completed"
                        // transaction queue and removed from the "active"
                        // queue.
                        //
                        // If the transaction has overflowed - received more
                        // data/completions than planned, then these errored
                        // transactions are put into an "errored" transaction
                        // queue for examination and removed from the "active"
                        // queue.
                        //-------------------------------------------------------------------------
                        mutex_mmio_rx_req_active_transaction_queue.get();
                        foreach (mmio_rx_req_active_transaction_queue[j])
                        begin
                           if (mmio_rx_req_active_transaction_queue[j].transaction_is_done())
                           begin
                              mutex_mmio_rx_req_completed_transaction_queue.get();
                              mmio_rx_req_completed_transaction_queue.push_back(host_bfm_top.mmio_rx_req_active_transaction_queue[j]);
                              mutex_mmio_rx_req_completed_transaction_queue.put();
                              mutex_tag_manager.get();
                              tag_manager.release_tag(host_bfm_top.mmio_rx_req_active_transaction_queue[j].get_packet_tag());
                              mutex_tag_manager.put();
                           end
                           if (mmio_rx_req_active_transaction_queue[j].overflowed())
                           begin
                              mutex_mmio_rx_req_errored_transaction_queue.get();
                              mmio_rx_req_errored_transaction_queue.push_back(host_bfm_top.mmio_rx_req_active_transaction_queue[j]);
                              mutex_mmio_rx_req_errored_transaction_queue.put();
                              mutex_tag_manager.get();
                              tag_manager.release_tag(host_bfm_top.mmio_rx_req_active_transaction_queue[j].get_packet_tag());
                              mutex_tag_manager.put();
                           end
                        end
                        mmio_rx_req_active_transaction_queue = host_bfm_top.mmio_rx_req_active_transaction_queue.find() with (item.transaction_is_not_done());
                        mmio_rx_req_active_transaction_queue = host_bfm_top.mmio_rx_req_active_transaction_queue.find() with (item.not_overflowed());
                        mutex_mmio_rx_req_active_transaction_queue.put();
                     end  // Completions
                     //-------------------------------------------------------------------------
                     //  The following block services the incoming Power User
                     //  (PU) requests from Host Memory.
                     //-------------------------------------------------------------------------
                     else  // Packet not completion
                     begin
                        //---------- Debug ---------------
                        //$display("TX: Got to PU Host BFM Non-Completion Branch.");
                        //---------- Debug ---------------
                        tx_inbound_request_packet_queue.push_back(p);
                        while (tx_inbound_request_packet_queue.size() > 0)
                        begin
                           req = tx_inbound_request_packet_queue.pop_front(); 
                           //---------- Debug ---------------
                           //$display("TX: Received PU non-CplD packet:");
                           //req.print_packet_long();
                           //---------- Debug ---------------
                           packet_op = req.get_packet_op();
                           if (packet_op == READ)
                           begin
                              //---------- Debug ---------------
                              //$display("TX: Got to PU Host BFM Read on TX");
                              //---------- Debug ---------------
                              address = req.get_addr_first_be_adjusted();
                              lower_address = address[6:0];
                              length  = req.get_expected_completion_length_bytes();
                              requester_id = req.get_requester_id();
                              packet_tag = req.get_tag();
                              read_buf = new[length];
                              mutex_host_memory.get();
                              host_memory.read_data(address, "Port-TX PU Read Request", packet_tag, read_buf);
                              mutex_host_memory.put();
                              puc = new(
                                 .cpl_data_type(DATA_PRESENT),
                                 .requester_id(requester_id),
                                 .completer_id(COMPLETER_ID),
                                 .cpl_status(CPL_SUCCESS),
                                 .byte_count(read_buf.size()),
                                 .lower_address(lower_address),
                                 .tag(packet_tag)
                              );
                              puc.set_data(read_buf);
                              p = puc;
                              mutex_axis_send_rx.get();
                              axis_send_rx.put_packet_in_send_queue(p);
                              mutex_axis_send_rx.put();
                              mutex_dm_rx_packet_history_queue.get();
                              dm_rx_packet_history_queue.push_back(p);
                              mutex_dm_rx_packet_history_queue.put();
                           end // If - End of READ
                           else
                           begin
                              if (packet_op == WRITE)
                              begin
                                 //---------- Debug ---------------
                                 //$display("Got to PU Host BFM Write on TX");
                                 //---------- Debug ---------------
                                 //$display("Got to Host BFM Write on TX");
                                 address = req.get_addr_first_be_adjusted();
                                 length  = req.get_length_bytes();
                                 packet_tag = req.get_tag();
                                 payload_size = req.get_payload_size();
                                 write_buf = new[payload_size];
                                 req.get_payload(write_buf);
                                 mutex_host_memory.get();
                                 host_memory.write_data(address, "Port-TX PU Write Request", packet_tag, write_buf);
                                 mutex_host_memory.put();
                              end // If - End of WRITE
                              else
                              begin
                                 if (packet_op == ATOMIC)
                                 begin
                                    //---------- Debug -------------------------
                                    //$display("Got to PU Host BFM Atomic on TX");
                                    //---------- Debug -------------------------
                                    address = req.get_addr();
                                    lower_address = address[6:0];
                                    length  = req.get_expected_completion_length_bytes(); // Gets length of operands and return value.
                                    requester_id = req.get_requester_id();
                                    packet_tag = req.get_tag();
                                    payload_size = req.get_payload_size();
                                    atomic_payload = new[payload_size];
                                    req.get_payload(atomic_payload);
                                    packet_atomic_op = req.get_packet_atomic_op();
                                    if (packet_atomic_op == FETCH_ADD)
                                    begin
                                       access_source = "Port-TX PU Atomic Fetch-Add";
                                       addend = atomic_payload;
                                       result = new[length];
                                       mutex_host_memory.get();
                                       host_memory.atomic_fetch_add(address, access_source, packet_tag, addend, result);
                                       mutex_host_memory.put();
                                       puc = new(
                                          .cpl_data_type(DATA_PRESENT),
                                          .requester_id(requester_id),
                                          .completer_id(COMPLETER_ID),
                                          .cpl_status(CPL_SUCCESS),
                                          .byte_count(result.size()),
                                          .lower_address(lower_address),
                                          .tag(packet_tag)
                                       );
                                       puc.set_data(result);
                                       p = puc;
                                       mutex_axis_send_rx.get();
                                       axis_send_rx.put_packet_in_send_queue(p);
                                       mutex_axis_send_rx.put();
                                       mutex_dm_rx_packet_history_queue.get();
                                       dm_rx_packet_history_queue.push_back(p);
                                       mutex_dm_rx_packet_history_queue.put();
                                    end  // If - END of FETCH_ADD
                                    else
                                    begin
                                       if (packet_atomic_op == SWAP)
                                       begin
                                          access_source = "Port-TX PU Atomic Swap";
                                          swap = atomic_payload;
                                          result = new[length];
                                          mutex_host_memory.get();
                                          host_memory.atomic_swap(address, access_source, packet_tag, swap, result);
                                          mutex_host_memory.put();
                                          puc = new(
                                             .cpl_data_type(DATA_PRESENT),
                                             .requester_id(requester_id),
                                             .completer_id(COMPLETER_ID),
                                             .cpl_status(CPL_SUCCESS),
                                             .byte_count(result.size()),
                                             .lower_address(lower_address),
                                             .tag(packet_tag)
                                          );
                                          puc.set_data(result);
                                          p = puc;
                                          mutex_axis_send_rx.get();
                                          axis_send_rx.put_packet_in_send_queue(p);
                                          mutex_axis_send_rx.put();
                                          mutex_dm_rx_packet_history_queue.get();
                                          dm_rx_packet_history_queue.push_back(p);
                                          mutex_dm_rx_packet_history_queue.put();
                                       end  // If - END of SWAP
                                       else
                                       begin
                                          if (packet_atomic_op == CAS)
                                          begin
                                             access_source = "Port-TX PU Atomic Compare-And-Swap (CAS)";
                                             compare = new[length];
                                             swap    = new[length];
                                             result  = new[length];
                                             for (int i = 0; i < length; i++)
                                             begin
                                                compare[i] = atomic_payload[i];
                                             end
                                             for (int i = length, int j = 0; i < atomic_payload.size(); i++, j++)
                                             begin
                                                swap[j] = atomic_payload[i];
                                             end
                                             mutex_host_memory.get();
                                             host_memory.atomic_compare_and_swap(address, access_source, packet_tag, compare, swap, result);
                                             mutex_host_memory.put();
                                             puc = new(
                                                .cpl_data_type(DATA_PRESENT),
                                                .requester_id(requester_id),
                                                .completer_id(COMPLETER_ID),
                                                .cpl_status(CPL_SUCCESS),
                                                .byte_count(result.size()),
                                                .lower_address(lower_address),
                                                .tag(packet_tag)
                                             );
                                             puc.set_data(result);
                                             p = puc;
                                             mutex_axis_send_rx.get();
                                             axis_send_rx.put_packet_in_send_queue(p);
                                             mutex_axis_send_rx.put();
                                             mutex_dm_rx_packet_history_queue.get();
                                             dm_rx_packet_history_queue.push_back(p);
                                             mutex_dm_rx_packet_history_queue.put();
                                          end  // If - END of CAS
                                       end // Else - CAS Top
                                    end // Else - SWAP Top
                                 end // If - Atomic
                                 else
                                 begin
                                    if ((packet_op == MSG) || (packet_op == VDM))
                                    begin
                                       mutex_tx_inbound_message_queue.get();
                                       tx_inbound_message_queue.push_back(p);
                                       mutex_tx_inbound_message_queue.put();
                                    end // If - MSG/VDM
                                 end // Else - MSG/VDM Top
                              end // Else - Atomic Top
                           end // Else - Write Top
                        end // While - Inbound Packets
                     end // Non-Completion PU packets.
                  end // Else - Completion Top
               end // Power User Block
               else  // (packet_format == DATA_MOVER)
               begin
                  if (dm_mode == DM_PACKET)
                  begin
                     if (packet_op == COMPLETION)
                     begin
                        tx_inbound_dm_completion_packet_queue.push_back(p);
                     end
                     else  // Packet not completion
                     begin
                        tx_inbound_dm_request_packet_queue.push_back(p);
                     end
                  end
                  else // Auto Transaction Mode
                  begin
                     if (packet_op == COMPLETION)
                     begin
                        tx_inbound_dm_completion_packet_queue.push_back(p);
                     end
                     else  // Packet not completion
                     begin
                        tx_inbound_dm_request_packet_queue.push_back(p);
                        while (tx_inbound_dm_request_packet_queue.size() > 0)
                        begin
                           req = tx_inbound_dm_request_packet_queue.pop_front();
                           //----- Debug --------
                           //$display("TX: Received DM Request Packet:");
                           //req.print_packet_long();
                           //----- Debug --------
                           packet_op = req.get_packet_op();
                           dm_host_address  = req.get_dm_host_addr();
                           dm_local_address = req.get_dm_local_addr();
                           dm_lower_address = dm_local_address[23:0];
                           dm_meta_data = req.get_dm_meta_data();
                           mm_mode = req.get_mm_mode();
                           packet_tag = req.get_tag();
                           if (packet_op == READ)
                           begin
                              length = req.get_expected_completion_length_bytes();
                              read_buf = new[length];
                              //----- Debug --------
                              //$display("TX: Performing DM Read of Host Memory with length %0d.", length);
                              //----- Debug --------
                              mutex_host_memory.get();
                              host_memory.read_data(dm_host_address, "Port-TX DM Read Request", packet_tag, read_buf);
                              mutex_host_memory.put();
                              dmc = new(
                                 .tag(packet_tag),
                                 .cpl_status(CPL_SUCCESS),
                                 .local_address_or_meta_data((mm_mode) ? dm_local_address : dm_meta_data),
                                 .length(length),
                                 .mm_mode(mm_mode),
                                 .lower_address(dm_lower_address)
                              );
                              dmc.set_data(read_buf);
                              //----- Debug --------
                              //$display("TX: Sending DM Read Completion of Host Memory:");
                              //dmc.print_packet_long();
                              //----- Debug --------
                              p = dmc;
                              mutex_axis_send_rx.get();
                              axis_send_rx.put_packet_in_send_queue(p);
                              mutex_axis_send_rx.put();
                              mutex_dm_rx_packet_history_queue.get();
                              dm_rx_packet_history_queue.push_back(p);
                              mutex_dm_rx_packet_history_queue.put();
                           end // If - DM Read
                           else
                           begin
                              if (packet_op == WRITE)
                              begin
                                 length = req.get_length_bytes();
                                 //----- Debug --------
                                 //$display("TX: Performing DM Read of Host Memory with length %0d.", length);
                                 //----- Debug --------
                                 payload_size = req.get_payload_size();
                                 write_buf = new[payload_size];
                                 req.get_payload(write_buf);
                                 mutex_host_memory.get();
                                 host_memory.write_data(dm_host_address, "Port-TX DM Write Request", packet_tag, write_buf);
                                 mutex_host_memory.put();
                              end // If - DM Write
                              //----- Debug --------
                              else
                              begin
                                 $display("TX ERROR: Received packet was not a read nor write!");
                              end
                              //----- Debug --------
                           end // Else - Top DM Write
                        end // While - There are DM Request Packets
                     end // Else - Top Packet Not Completion
                  end // Else - Auto Transaction Block
               end // Else - Mode = DM Packet
            end // while packets available
         end // @(negedge axis_tx.clk)
      end // forever loop
   endtask


   virtual task run_tx_req();
      Packet#(pf_type, vf_type, pf_list, vf_list) p;
      Packet#(pf_type, vf_type, pf_list, vf_list) cpld;
      Packet#(pf_type, vf_type, pf_list, vf_list) req;
      PacketPUCompletion#(pf_type, vf_type, pf_list, vf_list) puc;
      PacketDMCompletion#(pf_type, vf_type, pf_list, vf_list) dmc;
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      packet_tag_t       packet_tag;
      packet_header_op_t packet_op;
      packet_header_atomic_op_t packet_atomic_op;
      packet_format_t    packet_format;
      int num_packets_received;
      int payload_size;
      bit matched;
      bit mm_mode;
      uint64_t   address;
      //---------------- Debug -------------------------
      uint64_t   debug_address;
      //---------------- Debug -------------------------
      uint64_t   dm_host_address;
      uint64_t   dm_local_address;
      uint64_t   dm_meta_data;
      bit  [6:0] lower_address;
      bit [23:0] dm_lower_address;
      uint32_t   length;
      bit [15:0] requester_id;
      bit [15:0] completer_id;
      byte_t read_buf[];
      byte_t write_buf[];
      byte_t addend[];
      byte_t result[];
      byte_t swap[];
      byte_t compare[];
      byte_t atomic_payload[];
      string access_source;
      $timeformat(-9, 3, "ns", 4);
      @(posedge axis_tx_req.clk iff (axis_tx_req.rst_n === 1'b1));
      repeat (10) @(posedge axis_tx_req.clk); // Wait for 10 clocks after reset
      forever begin
         @(negedge axis_tx_req.clk)
         begin
            while (axis_receive_tx_req.num_packets_available() > 0)
            begin
               p = axis_receive_tx_req.get_packet_in_receive_queue();
               //---------------- Debug -------------------------
               //debug_address = p.get_addr();
               //$display(">>> RECEIVE TX_REQ Packet Snoop: Type:%-s   Tag:%H   Address:%H_%H_%H_%H", p.get_packet_op().name(), p.get_tag(), debug_address[63:48], debug_address[47:32], debug_address[31:16], debug_address[15:0]);
               //---------------- Debug -------------------------
               packet_op = p.get_packet_op();
               packet_format = p.get_packet_format();
               //$display("TX_REQ: Received Packet Format: %-s   Packet Op: %-s", packet_format.name(), packet_op.name());
               p.set_arrival_time($realtime);
               if (packet_format == POWER_USER)
               begin
                  if (mmio_mode == PU_PACKET)
                  begin
                     if (packet_op == COMPLETION)
                     begin
                        tx_req_inbound_completion_packet_queue.push_back(p);
                     end
                     else  // Packet not completion
                     begin
                        if ((packet_op == MSG) || (packet_op == VDM))
                        begin
                           mutex_tx_req_inbound_message_queue.get();
                           tx_req_inbound_message_queue.push_back(p);
                           mutex_tx_req_inbound_message_queue.put();
                        end
                        else
                        begin
                           //$display("Pushing Non-completion into tx_req_inbound_request_packet_queue");
                           tx_req_inbound_request_packet_queue.push_back(p);
                        end
                     end
                  end
                  else // Transaction Mode >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                  begin
                     if (packet_op == COMPLETION)
                     begin
                        tx_req_inbound_completion_packet_queue.push_back(p);
                        //-------------------------------------------------------------------------
                        // The following while loop goes through all the
                        // available completions in the packet queue and
                        // attempts to match the tag to the transactions in
                        // the active transaction queue.
                        //
                        // If there is a tag match, the completion is added to the
                        // transaction.  If the tag doesn't match any of the
                        // active transactions, then it is put into
                        // a "nonmatched" completion queue for examination.
                        //-------------------------------------------------------------------------
                        while (tx_req_inbound_completion_packet_queue.size() > 0)
                        begin
                           cpld = tx_req_inbound_completion_packet_queue.pop_front();
                           //------------- Debug -------------------
                           //$display("HOST BFM, TX_REQ: PU CplD Found:");
                           //cpld.print_packet();
                           //------------- Debug -------------------
                           matched = 1'b0;
                           mutex_mmio_rx_req_active_transaction_queue.get();
                           foreach (mmio_rx_req_active_transaction_queue[j])
                           begin
                              //------------- Debug -------------------
                              //$display("TX_REQ: Tag Search Comparison: CPLD Tag: %H   Active Tag: %H", cpld.get_tag(), mmio_rx_req_active_transaction_queue[j].get_packet_tag());
                              //------------- Debug -------------------
                              if ((cpld.get_tag() == mmio_rx_req_active_transaction_queue[j].get_packet_tag()) && (!matched))
                              begin
                                 matched = 1'b1;
                                 mmio_rx_req_active_transaction_queue[j].add_completion(cpld);
                                 //------------- Debug ---------------------------
                                 //$display("TX_REQ: PU Completion ADDED to transaction!");
                                 //------------- Debug ---------------------------
                              end
                           end
                           mutex_mmio_rx_req_active_transaction_queue.put();
                           if (!matched)
                           begin
                              tx_req_inbound_completion_nonmatched_packet_queue.push_back(cpld);
                              //------------- Debug ---------------------------
                              //$display("TX_REQ: NO match found for PU CplD!");
                              //------------- Debug ---------------------------
                           end
                           else
                           begin
                              //------------- Debug ---------------------------
                              //$display("TX_REQ: Match found for PU CPLD!");
                              //------------- Debug ---------------------------
                           end
                        end
                        //-------------------------------------------------------------------------
                        // The following iteration loop checks each of the
                        // transactions in the active transaction queue to see
                        // if they are done receiving data/completions.
                        //
                        // If so, then they are put in the "completed"
                        // transaction queue and removed from the "active"
                        // queue.
                        //
                        // If the transaction has overflowed - received more
                        // data/completions than planned, then these errored
                        // transactions are put into an "errored" transaction
                        // queue for examination and removed from the "active"
                        // queue.
                        //-------------------------------------------------------------------------
                        mutex_mmio_rx_req_active_transaction_queue.get();
                        foreach (mmio_rx_req_active_transaction_queue[j])
                        begin
                           if (mmio_rx_req_active_transaction_queue[j].transaction_is_done())
                           begin
                              mutex_mmio_rx_req_completed_transaction_queue.get();
                              mmio_rx_req_completed_transaction_queue.push_back(host_bfm_top.mmio_rx_req_active_transaction_queue[j]);
                              mutex_mmio_rx_req_completed_transaction_queue.put();
                              mutex_tag_manager.get();
                              tag_manager.release_tag(host_bfm_top.mmio_rx_req_active_transaction_queue[j].get_packet_tag());
                              mutex_tag_manager.put();
                           end
                           if (mmio_rx_req_active_transaction_queue[j].overflowed())
                           begin
                              mutex_mmio_rx_req_errored_transaction_queue.get();
                              mmio_rx_req_errored_transaction_queue.push_back(host_bfm_top.mmio_rx_req_active_transaction_queue[j]);
                              mutex_mmio_rx_req_errored_transaction_queue.put();
                              mutex_tag_manager.get();
                              tag_manager.release_tag(host_bfm_top.mmio_rx_req_active_transaction_queue[j].get_packet_tag());
                              mutex_tag_manager.put();
                           end
                        end
                        mmio_rx_req_active_transaction_queue = host_bfm_top.mmio_rx_req_active_transaction_queue.find() with (item.transaction_is_not_done());
                        mmio_rx_req_active_transaction_queue = host_bfm_top.mmio_rx_req_active_transaction_queue.find() with (item.not_overflowed());
                        mutex_mmio_rx_req_active_transaction_queue.put();
                     end  // Completions
                     //-------------------------------------------------------------------------
                     //  The following block services the incoming Power User
                     //  (PU) requests from Host Memory.
                     //-------------------------------------------------------------------------
                     else  // Packet not completion
                     begin
                        //---------- Debug ---------------
                        //$display("TX_REQ: Got to PU Host BFM Non-Completion Branch.");
                        //---------- Debug ---------------
                        tx_req_inbound_request_packet_queue.push_back(p);
                        while (tx_req_inbound_request_packet_queue.size() > 0)
                        begin
                           req = tx_req_inbound_request_packet_queue.pop_front(); 
                           //---------- Debug ---------------
                           //$display("TX_REQ: Received PU non-CplD packet:");
                           //req.print_packet_long();
                           //---------- Debug ---------------
                           packet_op = req.get_packet_op();
                           if (packet_op == READ)
                           begin
                              //---------- Debug ---------------
                              //$display("Got to PU Host BFM Read on TX_REQ");
                              //---------- Debug ---------------
                              address = req.get_addr_first_be_adjusted();
                              lower_address = address[6:0];
                              length  = req.get_expected_completion_length_bytes();
                              requester_id = req.get_requester_id();
                              packet_tag = req.get_tag();
                              read_buf = new[length];
                              mutex_host_memory.get();
                              host_memory.read_data(address, "Port-TX_REQ PU Read Request", packet_tag, read_buf);
                              mutex_host_memory.put();
                              puc = new(
                                 .cpl_data_type(DATA_PRESENT),
                                 .requester_id(requester_id),
                                 .completer_id(COMPLETER_ID),
                                 .cpl_status(CPL_SUCCESS),
                                 .byte_count(read_buf.size()),
                                 .lower_address(lower_address),
                                 .tag(packet_tag)
                              );
                              puc.set_data(read_buf);
                              p = puc;
                              mutex_axis_send_rx.get();
                              axis_send_rx.put_packet_in_send_queue(p);
                              mutex_axis_send_rx.put();
                              mutex_dm_rx_packet_history_queue.get();
                              dm_rx_packet_history_queue.push_back(p);
                              mutex_dm_rx_packet_history_queue.put();
                           end // If - End of READ
                           else
                           begin
                              if (packet_op == WRITE)
                              begin
                                 //---------- Debug ---------------
                                 //$display("Got to PU Host BFM Write on TX_REQ");
                                 //---------- Debug ---------------
                                 //$display("Got to Host BFM Write on TX_REQ");
                                 address = req.get_addr_first_be_adjusted();
                                 length  = req.get_length_bytes();
                                 packet_tag = req.get_tag();
                                 payload_size = req.get_payload_size();
                                 write_buf = new[payload_size];
                                 req.get_payload(write_buf);
                                 mutex_host_memory.get();
                                 host_memory.write_data(address, "Port-TX_REQ PU Write Request", packet_tag, write_buf);
                                 mutex_host_memory.put();
                              end // If - End of WRITE
                              else
                              begin
                                 if (packet_op == ATOMIC)
                                 begin
                                    //---------- Debug -------------------------
                                    //$display("Got to PU Host BFM Atomic on TX_REQ");
                                    //---------- Debug -------------------------
                                    address = req.get_addr();
                                    lower_address = address[6:0];
                                    length  = req.get_expected_completion_length_bytes(); // Gets length of operands and return value.
                                    requester_id = req.get_requester_id();
                                    packet_tag = req.get_tag();
                                    payload_size = req.get_payload_size();
                                    atomic_payload = new[payload_size];
                                    req.get_payload(atomic_payload);
                                    packet_atomic_op = req.get_packet_atomic_op();
                                    if (packet_atomic_op == FETCH_ADD)
                                    begin
                                       access_source = "Port-TX_REQ PU Atomic Fetch-Add";
                                       addend = atomic_payload;
                                       result = new[length];
                                       mutex_host_memory.get();
                                       host_memory.atomic_fetch_add(address, access_source, packet_tag, addend, result);
                                       mutex_host_memory.put();
                                       puc = new(
                                          .cpl_data_type(DATA_PRESENT),
                                          .requester_id(requester_id),
                                          .completer_id(COMPLETER_ID),
                                          .cpl_status(CPL_SUCCESS),
                                          .byte_count(result.size()),
                                          .lower_address(lower_address),
                                          .tag(packet_tag)
                                       );
                                       puc.set_data(result);
                                       p = puc;
                                       mutex_axis_send_rx.get();
                                       axis_send_rx.put_packet_in_send_queue(p);
                                       mutex_axis_send_rx.put();
                                       mutex_dm_rx_packet_history_queue.get();
                                       dm_rx_packet_history_queue.push_back(p);
                                       mutex_dm_rx_packet_history_queue.put();
                                    end  // If - END of FETCH_ADD
                                    else
                                    begin
                                       if (packet_atomic_op == SWAP)
                                       begin
                                          access_source = "Port-TX_REQ PU Atomic Swap";
                                          swap = atomic_payload;
                                          result = new[length];
                                          mutex_host_memory.get();
                                          host_memory.atomic_swap(address, access_source, packet_tag, swap, result);
                                          mutex_host_memory.put();
                                          puc = new(
                                             .cpl_data_type(DATA_PRESENT),
                                             .requester_id(requester_id),
                                             .completer_id(COMPLETER_ID),
                                             .cpl_status(CPL_SUCCESS),
                                             .byte_count(result.size()),
                                             .lower_address(lower_address),
                                             .tag(packet_tag)
                                          );
                                          puc.set_data(result);
                                          p = puc;
                                          mutex_axis_send_rx.get();
                                          axis_send_rx.put_packet_in_send_queue(p);
                                          mutex_axis_send_rx.put();
                                          mutex_dm_rx_packet_history_queue.get();
                                          dm_rx_packet_history_queue.push_back(p);
                                          mutex_dm_rx_packet_history_queue.put();
                                       end  // If - END of SWAP
                                       else
                                       begin
                                          if (packet_atomic_op == CAS)
                                          begin
                                             access_source = "Port-TX_REQ PU Atomic Compare-And-Swap (CAS)";
                                             compare = new[length];
                                             swap    = new[length];
                                             result  = new[length];
                                             for (int i = 0; i < length; i++)
                                             begin
                                                compare[i] = atomic_payload[i];
                                             end
                                             for (int i = length, int j = 0; i < atomic_payload.size(); i++, j++)
                                             begin
                                                swap[j] = atomic_payload[i];
                                             end
                                             mutex_host_memory.get();
                                             host_memory.atomic_compare_and_swap(address, access_source, packet_tag, compare, swap, result);
                                             mutex_host_memory.put();
                                             puc = new(
                                                .cpl_data_type(DATA_PRESENT),
                                                .requester_id(requester_id),
                                                .completer_id(COMPLETER_ID),
                                                .cpl_status(CPL_SUCCESS),
                                                .byte_count(result.size()),
                                                .lower_address(lower_address),
                                                .tag(packet_tag)
                                             );
                                             puc.set_data(result);
                                             p = puc;
                                             mutex_axis_send_rx.get();
                                             axis_send_rx.put_packet_in_send_queue(p);
                                             mutex_axis_send_rx.put();
                                             mutex_dm_rx_packet_history_queue.get();
                                             dm_rx_packet_history_queue.push_back(p);
                                             mutex_dm_rx_packet_history_queue.put();
                                          end  // If - END of CAS
                                       end // Else - CAS Top
                                    end // Else - SWAP Top
                                 end // If - Atomic
                                 else
                                 begin
                                    if ((packet_op == MSG) || (packet_op == VDM))
                                    begin
                                       mutex_tx_inbound_message_queue.get();
                                       tx_inbound_message_queue.push_back(p);
                                       mutex_tx_inbound_message_queue.put();
                                    end // If - MSG/VDM
                                 end // Else - MSG/VDM Top
                              end // Else - Atomic Top
                           end // Else - Write Top
                        end // While - Inbound Packets
                     end // Non-Completion PU packets.
                  end // Else - Completion Top
               end // Power User Block
               else  // (packet_format == DATA_MOVER)
               begin
                  if (dm_mode == DM_PACKET)
                  begin
                     if (packet_op == COMPLETION)
                     begin
                        tx_req_inbound_dm_completion_packet_queue.push_back(p);
                     end
                     else  // Packet not completion
                     begin
                        tx_req_inbound_dm_request_packet_queue.push_back(p);
                        packet_op = p.get_packet_op();
                     end
                  end
                  else // Auto Transaction Mode
                  begin
                     if (packet_op == COMPLETION)
                     begin
                        tx_req_inbound_dm_completion_packet_queue.push_back(p);
                     end
                     else  // Packet not completion
                     begin
                        tx_req_inbound_dm_request_packet_queue.push_back(p);
                        while (tx_req_inbound_dm_request_packet_queue.size() > 0)
                        begin
                           req = tx_req_inbound_dm_request_packet_queue.pop_front();
                           //----- Debug --------
                           //$display("TX_REQ: Received DM Request Packet:");
                           //req.print_packet_long();
                           //----- Debug --------
                           packet_op = req.get_packet_op();
                           dm_host_address  = req.get_dm_host_addr();
                           dm_local_address = req.get_dm_local_addr();
                           dm_lower_address = dm_local_address[23:0];
                           dm_meta_data = req.get_dm_meta_data();
                           mm_mode = req.get_mm_mode();
                           packet_tag = req.get_tag();
                           if (packet_op == READ)
                           begin
                              length = req.get_expected_completion_length_bytes();
                              read_buf = new[length];
                              //----- Debug --------
                              //$display("TX_REQ: Performing DM Read of Host Memory with length %0d.", length);
                              //----- Debug --------
                              mutex_host_memory.get();
                              host_memory.read_data(dm_host_address, "Port-TX_REQ DM Read Request", packet_tag, read_buf);
                              mutex_host_memory.put();
                              dmc = new(
                                 .tag(packet_tag),
                                 .cpl_status(CPL_SUCCESS),
                                 .local_address_or_meta_data((mm_mode) ? dm_local_address : dm_meta_data),
                                 .length(length),
                                 .mm_mode(mm_mode),
                                 .lower_address(dm_lower_address)
                              );
                              dmc.set_data(read_buf);
                              //----- Debug --------
                              //$display("TX_REQ: Sending DM Read Completion of Host Memory:");
                              //dmc.print_packet_long();
                              //----- Debug --------
                              p = dmc;
                              //---------------------------------------------
                              // Using Packet Delay Queue
                              //---------------------------------------------
                              tx_req_packet_delay_queue.put_packet(p.get_completion_delay(),p);
                           end // If - DM Read
                           else
                           begin
                              if (packet_op == WRITE)
                              begin
                                 length = req.get_length_bytes();
                                 //----- Debug --------
                                 //$display("TX_REQ: Performing DM Read of Host Memory with length %0d.", length);
                                 //----- Debug --------
                                 payload_size = req.get_payload_size();
                                 write_buf = new[payload_size];
                                 req.get_payload(write_buf);
                                 mutex_host_memory.get();
                                 host_memory.write_data(dm_host_address, "Port-TX_REQ DM Write Request", packet_tag, write_buf);
                                 mutex_host_memory.put();
                              end // If - DM Write
                              //----- Debug --------
                              else
                              begin
                                 $display("TX_REQ ERROR: Received packet was not a read nor write!");
                              end
                              //----- Debug --------
                           end // Else - Top DM Write
                        end // While - There are DM Request Packets
                        //---------------------------------------------
                     end // Else - Top Packet Not Completion
                  end // Else - Auto Transaction Block
               end // Else - Mode = DM Packet
            end // while packets available
            //----------------------------------------------------------------------
            // Using Packet Delay Queue
            // This Queue is queried at each clock of axis_tx_req.clk to see if any of the 
            // packets are ready to send (delay timed out).  The delay is
            // a static delay in time -- the relationship between packets is
            // preserved -- including packets coming together in a burst.
            //----------------------------------------------------------------------
            if (tx_req_packet_delay_queue.packet_ready())
            begin
               //$display(">>> Outside IF");
               //tx_req_packet_delay_queue.print_delay_queue();
               p = tx_req_packet_delay_queue.get_packet();
               mutex_axis_send_rx.get();
               axis_send_rx.put_packet_in_send_queue(p);
               mutex_axis_send_rx.put();
               mutex_dm_rx_packet_history_queue.get();
               dm_rx_packet_history_queue.push_back(p);
               mutex_dm_rx_packet_history_queue.put();
            end // Packet Delay Queue IF
         end // @(negedge axis_tx_req.clk)
      end // forever loop
   endtask


   virtual task run_rx();
      Packet#(pf_type, vf_type, pf_list, vf_list) p;
      packet_tag_t packet_tag;
      packet_header_op_t packet_op;
      $timeformat(-9, 3, "ns", 4);
      @(posedge axis_rx.clk iff (axis_rx.rst_n === 1'b1));
      repeat (10) @(posedge axis_rx.clk);
      forever begin
         @(posedge axis_rx.clk)
         begin
            if (dm_mode == DM_PACKET)
            begin
               while (dm_rx_packet_queue.size() > 0)
               begin
                  p = dm_rx_packet_queue.pop_front();
                  packet_op = p.get_packet_op();
                  if ((packet_op == READ) || (packet_op == WRITE))
                  begin
                     mutex_tag_manager.get();
                     wait (tag_manager.get_packet_tag_success(.packet_format_in(DATA_MOVER), .packet_header_op_in(packet_op), .packet_tag(packet_tag)));
                     mutex_tag_manager.put();
                     p.set_tag(packet_tag);
                     p.set_send_time($realtime);
                     mutex_axis_send_rx.get();
                     axis_send_rx.put_packet_in_send_queue(p);
                     mutex_axis_send_rx.put();
                     mutex_dm_rx_packet_history_queue.get();
                     dm_rx_packet_history_queue.push_back(p);
                     mutex_dm_rx_packet_history_queue.put();
                     if (p.get_packet_op() == WRITE)
                     begin
                        mutex_tag_manager.get();
                        tag_manager.release_tag(p.get_tag());
                        mutex_tag_manager.put();
                     end
                  end // Packets that need tag.
                  else // Else send packet as is.
                  begin
                     p.set_send_time($realtime);
                     mutex_axis_send_rx.get();
                     axis_send_rx.put_packet_in_send_queue(p);
                     mutex_axis_send_rx.put();
                     mutex_dm_rx_packet_history_queue.get();
                     dm_rx_packet_history_queue.push_back(p);
                     mutex_dm_rx_packet_history_queue.put();
                  end
               end
            end // If - dm_mode == DM_PACKET
         end
      end
   endtask


   virtual task read32(
      input uint64_t      address,
      output logic [31:0] data
   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      Transaction#(pf_type, vf_type, pf_list, vf_list) found_queue[$];
      uint64_t found_transaction_number;
      ReadTransaction#(pf_type, vf_type, pf_list, vf_list) rt;
      bit found, timeout;
      realtime time_start, time_elapsed, time_limit;
      string access_source  = "BFM Read32 Method";
      bit [9:0] length_dw   = 10'd1;
      bit [3:0] first_dw_be = 4'b1111;
      bit [3:0] last_dw_be  = 4'b1111;
      //---------- Debug -----------------------------------------------------
      logic [63:0] data64;
      //----------------------------------------------------------------------
      $timeformat(-9, 3, "ns", 4);
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
         address &= 64'hFFFF_FFFF_FFFF_FFFC;  // Enforce a 32-bit boundary bus.
         rt = new(
            .access_source(access_source),
            .address(address),
            .length_dw(length_dw),
            .first_dw_be(first_dw_be),
            .last_dw_be(last_dw_be)
         );
         time_limit = 100us;
         rt.set_pf_vf(this.get_pfvf_setting());
         t = rt;
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
         time_start = $realtime;
         @(posedge axis_rx_req.clk iff (mmio_rx_req_completed_transaction_queue.size() > 0));
         found = 1'b0;
         timeout = 1'b0;
         while (!found && !timeout)
         begin
            mutex_mmio_rx_req_completed_transaction_queue.get();
            found_queue = mmio_rx_req_completed_transaction_queue.find() with ((item.get_packet_tag() == rt.get_packet_tag()) && (item.get_transactor_type() == CSR_RD));
            mutex_mmio_rx_req_completed_transaction_queue.put();
            if (found_queue.size() > 0)
            begin
               t = found_queue[0];
               //found_transaction_number = found_queue[0].get_transaction_number();
               found_transaction_number = t.get_transaction_number();
               //$display("Read32 Method Matching Transaction Number: %0d", found_transaction_number);
               found = 1'b1;
               //data = found_queue[0].get_return_data32();
               data = t.get_return_data32();
               $display("Read32  Method Data Transaction: Address: %H_%H_%H_%H   Data: %H_%H", address[63:48], address[47:32], address[31:16], address[15:0], data[31:16], data[15:0]);
               //----------------------------------------------------------------------
               //$display("   Elapsed Time for Read32 Method: %0t", $realtime - time_start);
            end
            time_elapsed = $realtime - time_start;
            if (time_elapsed > time_limit)
            begin
               timeout = 1'b1;
               data = {32{1'bx}};
               $display("BFM Read32 Method - WARNING: Timeout of time %0t occurred: Address: %H_%H_%H_%H   Data: %H_%H", time_limit, address[63:48], address[47:32], address[31:16], address[15:0], data[31:16], data[15:0]);
            end
            if (!found && !timeout)
            begin
               @(posedge axis_rx_req.clk); // Allow time to pass to allow queue updates.  Don't bother if we've found our transaction or if we've experienced a timeout.
            end
         end // While
         if (found)
         begin
            mutex_mmio_rx_req_completed_transaction_queue.get();
            mmio_rx_req_completed_transaction_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue.find() with (item.get_transaction_number() != found_transaction_number);
            mutex_mmio_rx_req_completed_transaction_queue.put();
         end
      end
      else
      begin
         $display("ERROR: BFM Read32 Method attempted while MMIO Mode was set to %s", mmio_mode.name());
         data = {32{1'bx}};
      end
   endtask


   virtual task read32_with_completion_status(
      input uint64_t      address,
      output logic [31:0] data,
      output logic        error,
      output cpl_status_t cpl_status
   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      Transaction#(pf_type, vf_type, pf_list, vf_list) found_queue[$];
      uint64_t found_transaction_number;
      ReadTransaction#(pf_type, vf_type, pf_list, vf_list) rt;
      bit found, timeout;
      realtime time_start, time_elapsed, time_limit;
      string access_source  = "BFM Read32 with Completion Result Method";
      bit [9:0] length_dw   = 10'd1;
      bit [3:0] first_dw_be = 4'b1111;
      bit [3:0] last_dw_be  = 4'b1111;
      $timeformat(-9, 3, "ns", 4);
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
         rt = new(
            .access_source(access_source),
            .address(address),
            .length_dw(length_dw),
            .first_dw_be(first_dw_be),
            .last_dw_be(last_dw_be)
         );
         time_limit = 100us;
         rt.set_pf_vf(this.get_pfvf_setting());
         t = rt;
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
         time_start = $realtime;
         @(posedge axis_rx_req.clk iff (mmio_rx_req_completed_transaction_queue.size() > 0));
         found = 1'b0;
         timeout = 1'b0;
         error = 1'b0;
         while (!found && !timeout)
         begin
            mutex_mmio_rx_req_completed_transaction_queue.get();
            found_queue = mmio_rx_req_completed_transaction_queue.find() with ((item.get_packet_tag() == rt.get_packet_tag()) && (item.get_transactor_type() == CSR_RD));
            mutex_mmio_rx_req_completed_transaction_queue.put();
            if (found_queue.size() > 0)
            begin
               found_transaction_number = found_queue[0].get_transaction_number();
               error = found_queue[0].errored();
               //$display("Read32 Method Matching Transaction Number: %0d", found_transaction_number);
               found = 1'b1;
               data = found_queue[0].get_return_data32();
               if (error)
               begin
                  foreach (found_queue[0].completion_queue[j])
                  begin
                     if (found_queue[0].completion_queue[j].get_cpl_status() != CPL_SUCCESS)
                     begin
                        cpl_status = found_queue[0].completion_queue[j].get_cpl_status();
                     end
                  end
               end
               else
               begin
                  cpl_status = CPL_SUCCESS;
               end
               $display("Read32  Method Data Transaction: Address: %H_%H_%H_%H   Data: %H_%H   Error:%H   CplD Status: %-s", address[63:48], address[47:32], address[31:16], address[15:0], data[31:16], data[15:0], error, cpl_status.name());
               //$display("   Elapsed Time for Read32 Method: %0t", $realtime - time_start);
            end
            time_elapsed = $realtime - time_start;
            if (time_elapsed > time_limit)
            begin
               timeout = 1'b1;
               data = {32{1'bx}};
               cpl_status = CPL_COMPLETER_ABORT;
               error = 1'b1;
               $display("BFM Read32 Method - WARNING: Timeout of time %0t occurred: Address: %H_%H_%H_%H   Data: %H_%H", time_limit, address[63:48], address[47:32], address[31:16], address[15:0], data[31:16], data[15:0]);
            end
            if (!found && !timeout)
            begin
               @(posedge axis_rx_req.clk); // Allow time to pass to allow queue updates.  Don't bother if we've found our transaction or if we've experienced a timeout.
            end
         end // While
         if (found)
         begin
            mutex_mmio_rx_req_completed_transaction_queue.get();
            mmio_rx_req_completed_transaction_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue.find() with (item.get_transaction_number() != found_transaction_number);
            mutex_mmio_rx_req_completed_transaction_queue.put();
         end
      end
      else
      begin
         $display("ERROR: BFM Read32 Method attempted while MMIO Mode was set to %s", mmio_mode.name());
         data = {32{1'bx}};
         error = 1'b1;
         cpl_status = CPL_REQUEST_RETRY;
      end
   endtask


   virtual task read64(
      input uint64_t      address,
      output logic [63:0] data
   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      Transaction#(pf_type, vf_type, pf_list, vf_list) found_queue[$];
      uint64_t found_transaction_number;
      ReadTransaction#(pf_type, vf_type, pf_list, vf_list) rt;
      bit found, timeout;
      realtime time_start, time_elapsed, time_limit;
      string access_source  = "BFM Read64 Method";
      bit [9:0] length_dw   = 10'd2;
      bit [3:0] first_dw_be = 4'b1111;
      bit [3:0] last_dw_be  = 4'b1111;
      $timeformat(-9, 3, "ns", 4);
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
         address &= 64'hFFFF_FFFF_FFFF_FFF8;  // Enforce a 64-bit boundary bus.
         rt = new(
            .access_source(access_source),
            .address(address),
            .length_dw(length_dw),
            .first_dw_be(first_dw_be),
            .last_dw_be(last_dw_be)
         );
         time_limit = 100us;
         rt.set_pf_vf(this.get_pfvf_setting());
         t = rt;
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
         time_start = $realtime;
         @(posedge axis_rx_req.clk iff (mmio_rx_req_completed_transaction_queue.size() > 0));
         found = 1'b0;
         timeout = 1'b0;
         while (!found && !timeout)
         begin
            mutex_mmio_rx_req_completed_transaction_queue.get();
            found_queue = mmio_rx_req_completed_transaction_queue.find() with ((item.get_packet_tag() == rt.get_packet_tag()) && (item.get_transactor_type() == CSR_RD));
            mutex_mmio_rx_req_completed_transaction_queue.put();
            if (found_queue.size() > 0)
            begin
               t = found_queue[0];
               found_transaction_number = t.get_transaction_number();
               //$display("Read64 Method Matching Transaction Number: %0d", found_transaction_number);
               found = 1'b1;
               //data = found_queue[0].get_return_data64();
               data = t.get_return_data64();
               $display("Read64  Method Data Transaction: Address: %H_%H_%H_%H   Data: %H_%H_%H_%H", address[63:48], address[47:32], address[31:16], address[15:0], data[63:48], data[47:32], data[31:16], data[15:0]);
               //$display("   Elapsed Time for Read64 Method: %0t", $realtime - time_start);
            end
            time_elapsed = $realtime - time_start;
            if (time_elapsed > time_limit)
            begin
               timeout = 1'b1;
               data = {64{1'bx}};
               $display("BFM Read64 Method - WARNING: Timeout of time %0t occurred: Address: %H_%H_%H_%H   Data: %H_%H_%H_%H", time_limit, address[63:48], address[47:32], address[31:16], address[15:0], data[63:48], data[47:32], data[31:16], data[15:0]);
            end
            if (!found && !timeout)
            begin
               @(posedge axis_rx_req.clk); // Allow time to pass to allow queue updates.  Don't bother if we've found our transaction or if we've experienced a timeout.
            end
         end // While
         if (found)
         begin
            mutex_mmio_rx_req_completed_transaction_queue.get();
            mmio_rx_req_completed_transaction_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue.find() with (item.get_transaction_number() != found_transaction_number);
            mutex_mmio_rx_req_completed_transaction_queue.put();
         end
      end
      else
      begin
         $display("ERROR: BFM Read64 Method attempted while MMIO Mode was set to %s", mmio_mode.name());
         data = {64{1'bx}};
      end
   endtask


   virtual task read64_with_completion_status(
      input uint64_t      address,
      output logic [63:0] data,
      output logic        error,
      output cpl_status_t cpl_status
   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      Transaction#(pf_type, vf_type, pf_list, vf_list) found_queue[$];
      uint64_t found_transaction_number;
      ReadTransaction#(pf_type, vf_type, pf_list, vf_list) rt;
      bit found, timeout;
      realtime time_start, time_elapsed, time_limit;
      string access_source  = "BFM Read64 with Completion Result Method";
      bit [9:0] length_dw   = 10'd2;
      bit [3:0] first_dw_be = 4'b1111;
      bit [3:0] last_dw_be  = 4'b1111;
      $timeformat(-9, 3, "ns", 4);
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
//         $display(">>> READ64 METHOD w/COMP RESULT #1; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
         rt = new(
            .access_source(access_source),
            .address(address),
            .length_dw(length_dw),
            .first_dw_be(first_dw_be),
            .last_dw_be(last_dw_be)
         );
//         $display(">>> READ64 METHOD w/COMP RESULT #2; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
         time_limit = 100us;
         rt.set_pf_vf(this.get_pfvf_setting());
         t = rt;
//         $display(">>> READ64 METHOD w/COMP RESULT #3; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
//         $display(">>> READ64 METHOD w/COMP RESULT #4; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
         time_start = $realtime;
//         $display(">>> READ64 METHOD w/COMP RESULT #5; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
         @(posedge axis_rx_req.clk iff (mmio_rx_req_completed_transaction_queue.size() > 0));
//         $display(">>> READ64 METHOD w/COMP RESULT #6; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
         found = 1'b0;
         timeout = 1'b0;
         error = 1'b0;
         while (!found && !timeout)
         begin
//            $display(">>> READ64 METHOD w/COMP RESULT #7; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
            mutex_mmio_rx_req_completed_transaction_queue.get();
            found_queue = mmio_rx_req_completed_transaction_queue.find() with ((item.get_packet_tag() == rt.get_packet_tag()) && (item.get_transactor_type() == CSR_RD));
            mutex_mmio_rx_req_completed_transaction_queue.put();
//            $display(">>> READ64 METHOD w/COMP RESULT #8; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
            if (found_queue.size() > 0)
            begin
//               $display(">>> READ64 METHOD w/COMP RESULT #9; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
               found_transaction_number = found_queue[0].get_transaction_number();
               error = found_queue[0].errored();
               //$display("Read64 Method Matching Transaction Number: %0d", found_transaction_number);
               found = 1'b1;
               data = found_queue[0].get_return_data64();
//               $display(">>> READ64 METHOD w/COMP RESULT #10; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
               if (error)
               begin
                  foreach (found_queue[0].completion_queue[j])
                  begin
                     if (found_queue[0].completion_queue[j].get_cpl_status() != CPL_SUCCESS)
                     begin
                        cpl_status = found_queue[0].completion_queue[j].get_cpl_status();
                     end
                  end
               end
               else
               begin
                  cpl_status = CPL_SUCCESS;
               end
               $display("Read64  Method Data Transaction: Address: %H_%H_%H_%H   Data: %H_%H_%H_%H   Error:%H   CplD Status: %-s", address[63:48], address[47:32], address[31:16], address[15:0], data[63:48], data[47:32], data[31:16], data[15:0], error, cpl_status.name());
               //$display("   Elapsed Time for Read64 Method: %0t", $realtime - time_start);
            end
            time_elapsed = $realtime - time_start;
            if (time_elapsed > time_limit)
            begin
               timeout = 1'b1;
               data = {64{1'bx}};
               cpl_status = CPL_COMPLETER_ABORT;
               error = 1'b1;
               $display("BFM Read64 Method - WARNING: Timeout of time %0t occurred: Address: %H_%H_%H_%H   Data: %H_%H_%H_%H", time_limit, address[63:48], address[47:32], address[31:16], address[15:0], data[63:48], data[47:32], data[31:16], data[15:0]);
            end
            if (!found && !timeout)
            begin
               @(posedge axis_rx_req.clk); // Allow time to pass to allow queue updates.  Don't bother if we've found our transaction or if we've experienced a timeout.
            end
         end // While
         if (found)
         begin
//            $display(">>> READ64 METHOD w/COMP RESULT #11; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
            mutex_mmio_rx_req_completed_transaction_queue.get();
            mmio_rx_req_completed_transaction_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue.find() with (item.get_transaction_number() != found_transaction_number);
            mutex_mmio_rx_req_completed_transaction_queue.put();
//            $display(">>> READ64 METHOD w/COMP RESULT #12; Number of 8-bit Tags Left:%0d", tag_manager.get_num_available_8bit_tags());
         end
      end
      else
      begin
         $display("ERROR: BFM Read64 Method attempted while MMIO Mode was set to %s", mmio_mode.name());
         data = {64{1'bx}};
         error = 1'b1;
         cpl_status = CPL_REQUEST_RETRY;
      end
   endtask


   virtual task read_data_with_completion_status(
      input uint64_t       address,
      input uint32_t       length_in_bytes,
      output logic [63:0]  data,
      output return_data_t return_data,
      output logic         error,
      output cpl_status_t  cpl_status
   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      Transaction#(pf_type, vf_type, pf_list, vf_list) found_queue[$];
      uint64_t found_transaction_number;
      ReadTransaction#(pf_type, vf_type, pf_list, vf_list) rt;
      bit found, timeout;
      realtime time_start, time_elapsed, time_limit;
      string access_source  = "BFM Read Data Method";
      bit [9:0] length_dw   = (|length_in_bytes[1:0]) ? (((length_in_bytes & 32'hFFFF_FFFC) >> 2) + 1) : length_in_bytes >> 2;
      bit [3:0] first_dw_be = 4'b1111;
      bit [3:0] last_dw_be  = 4'b1111;
      $timeformat(-9, 3, "ns", 4);
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
         rt = new(
            .access_source(access_source),
            .address(address),
            .length_dw(length_dw),
            .first_dw_be(first_dw_be),
            .last_dw_be(last_dw_be)
         );
         time_limit = 100us;
         rt.set_pf_vf(this.get_pfvf_setting());
         t = rt;
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
         time_start = $realtime;
         @(posedge axis_rx_req.clk iff (mmio_rx_req_completed_transaction_queue.size() > 0));
         found = 1'b0;
         timeout = 1'b0;
         error = 1'b0;
         while (!found && !timeout)
         begin
            mutex_mmio_rx_req_completed_transaction_queue.get();
            found_queue = mmio_rx_req_completed_transaction_queue.find() with ((item.get_packet_tag() == rt.get_packet_tag()) && (item.get_transactor_type() == CSR_RD));
            mutex_mmio_rx_req_completed_transaction_queue.put();
            if (found_queue.size() > 0)
            begin
               found_transaction_number = found_queue[0].get_transaction_number();
               //$display("Read64 Method Matching Transaction Number: %0d", found_transaction_number);
               found = 1'b1;
               data = found_queue[0].get_return_data64();
               return_data = found_queue[0].get_return_data();
               cpl_status = CPL_SUCCESS;
               foreach (found_queue[0].completion_queue[j])
               begin
                  if (found_queue[0].completion_queue[j].get_cpl_status() != CPL_SUCCESS)
                  begin
                     cpl_status = found_queue[0].completion_queue[j].get_cpl_status();
                     error = 1'b1;
                  end
               end
               $display("Read Data Method Data Transaction: Address: %H_%H_%H_%H   Data: %H_%H_%H_%H   Error:%H   CplD Status: %-s", address[63:48], address[47:32], address[31:16], address[15:0], data[63:48], data[47:32], data[31:16], data[15:0], error, cpl_status.name());
               $display("   Data Array:", return_data);
               //$display("   Elapsed Time for Read64 Method: %0t", $realtime - time_start);
            end
            time_elapsed = $realtime - time_start;
            if (time_elapsed > time_limit)
            begin
               timeout = 1'b1;
               data = {64{1'bx}};
               cpl_status = CPL_COMPLETER_ABORT;
               error = 1'b1;
               $display("BFM Read Data Method - WARNING: Timeout of time %0t occurred: Address: %H_%H_%H_%H   Data: %H_%H_%H_%H", time_limit, address[63:48], address[47:32], address[31:16], address[15:0], data[63:48], data[47:32], data[31:16], data[15:0]);
            end
            if (!found && !timeout)
            begin
               @(posedge axis_rx_req.clk); // Allow time to pass to allow queue updates.  Don't bother if we've found our transaction or if we've experienced a timeout.
            end
         end // While
         if (found)
         begin
            mutex_mmio_rx_req_completed_transaction_queue.get();
            mmio_rx_req_completed_transaction_queue = host_bfm_top.mmio_rx_req_completed_transaction_queue.find() with (item.get_transaction_number() != found_transaction_number);
            mutex_mmio_rx_req_completed_transaction_queue.put();
         end
      end
      else
      begin
         $display("ERROR: BFM Read Data Method attempted while MMIO Mode was set to %s", mmio_mode.name());
         data = {64{1'bx}};
         error = 1'b1;
         cpl_status = CPL_REQUEST_RETRY;
      end
   endtask


   virtual task write32(
      input uint64_t address,
      input logic [31:0] data
   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt;
      byte_t write_data[];
      string access_source  = "BFM Write32 Method";
      string parray;
      bit [9:0] length_dw   = 10'd1;
      bit [3:0] first_dw_be = 4'b1111;
      bit [3:0] last_dw_be  = 4'b1111;
      $timeformat(-9, 3, "ns", 4);
      write_data = new[4];
      write_data = {<<8{data}};
      //parray = $sformatf("%p", write_data);
      //$display("Write32 Method Data Transaction: address: %H_%H_%H_%H   data: %H_%H   write_data: %s", address[63:48], address[47:32], address[31:16], address[15:0], data[31:16], data[15:0], parray);
      $display("Write32 Method Data Transaction: Address: %H_%H_%H_%H   Data: %H_%H", address[63:48], address[47:32], address[31:16], address[15:0], data[31:16], data[15:0]);
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
         address &= 64'hFFFF_FFFF_FFFF_FFFC;  // Enforce a 32-bit boundary bus.
         wt = new(
            .access_source(access_source),
            .address(address),
            .length_dw(length_dw),
            .first_dw_be(first_dw_be),
            .last_dw_be(last_dw_be)
         );
         wt.set_pf_vf(this.get_pfvf_setting());
         wt.write_request_packet.set_data(write_data);
         t = wt;
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
      end
      else
      begin
         $display("ERROR: BFM Write32 Method attempted while MMIO Mode was set to %s", mmio_mode.name());
      end
   endtask


   virtual task write64(
      input uint64_t    address,
      input logic [63:0] data
   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      WriteTransaction#(pf_type, vf_type, pf_list, vf_list) wt;
      byte_t write_data[];
      string access_source  = "BFM Write64 Method";
      string parray;
      bit [9:0] length_dw   = 10'd2;
      bit [3:0] first_dw_be = 4'b1111;
      bit [3:0] last_dw_be  = 4'b1111;
      bit found;
      $timeformat(-9, 3, "ns", 4);
      write_data = new[8];
      write_data = {<<8{data}};
      //parray = $sformatf("%p", write_data);
      //$display("Write64 Method Data Transaction: address: %H_%H_%H_%H   data: %H_%H_%H_%H   write_data: %s", address[63:48], address[47:32], address[31:16], address[15:0], data[63:48], data[47:32], data[31:16], data[15:0], parray);
      $display("Write64 Method Data Transaction: Address: %H_%H_%H_%H   Data: %H_%H_%H_%H", address[63:48], address[47:32], address[31:16], address[15:0], data[63:48], data[47:32], data[31:16], data[15:0]);
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
         address &= 64'hFFFF_FFFF_FFFF_FFF8;  // Enforce a 64-bit boundary bus.
         wt = new(
            .access_source(access_source),
            .address(address),
            .length_dw(length_dw),
            .first_dw_be(first_dw_be),
            .last_dw_be(last_dw_be)
         );
         wt.set_pf_vf(this.get_pfvf_setting());
         wt.request_packet.set_data(write_data);
         t = wt;
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
      end
      else
      begin
         $display("ERROR: BFM Write64 Method attempted while MMIO Mode was set to %s", mmio_mode.name());
      end
   endtask


   virtual task send_msg(
      input data_present_type_t data_present,
      input msg_route_t         msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [31:0] lower_msg,
      input bit [31:0] upper_msg,
      input packet_tag_t tag,
      ref byte_array_t msg_data

   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      SendMsgTransaction#(pf_type, vf_type, pf_list, vf_list) mt;
      bit [9:0] length_dw;
      string access_source  = "BFM Send MSG Method";
      //string parray;
      $timeformat(-9, 3, "ns", 4);
      //parray = $sformatf("%p", msg_data);
      //$display("Write32 Method Data Transaction: address: %H_%H_%H_%H   data: %H_%H   msg_data: %s", address[63:48], address[47:32], address[31:16], address[15:0], data[31:16], data[15:0], parray);
      $display("Send MSG Method Data Transaction: Number of Message Bytes:%0d", msg_data.size());
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
         length_dw = 10'(msg_data.size()>>2);
         mt = new(
            .access_source(access_source),
            .data_present(data_present),
            .msg_route(msg_route),
            .requester_id(requester_id),
            .msg_code(msg_code),
            .lower_msg(lower_msg),
            .upper_msg(upper_msg),
            .length_dw(length_dw)
         );
         mt.set_pf_vf(this.get_pfvf_setting());
         mt.request_packet.set_tag(tag);
         mt.request_packet.set_data(msg_data);
         t = mt;
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
      end
      else
      begin
         $display("ERROR: BFM Send MSG Method attempted while MMIO Mode was set to %s", mmio_mode.name());
      end
   endtask


   virtual task send_vdm(
      input data_present_type_t data_present,
      input vdm_msg_route_t         msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [15:0] pci_target_id,
      input bit [15:0] vendor_id,
      ref byte_array_t msg_data

   );
      Transaction#(pf_type, vf_type, pf_list, vf_list) t;
      SendVDMTransaction#(pf_type, vf_type, pf_list, vf_list) vt;
      bit [9:0] length_dw;
      string access_source  = "BFM Send VDM Method";
      //string parray;
      $timeformat(-9, 3, "ns", 4);
      //parray = $sformatf("%p", msg_data);
      //$display("Write32 Method Data Transaction: address: %H_%H_%H_%H   data: %H_%H   msg_data: %s", address[63:48], address[47:32], address[31:16], address[15:0], data[31:16], data[15:0], parray);
      $display("Send VDM Method Data Transaction: Number of Message Bytes:%0d", msg_data.size());
      if (mmio_mode == PU_METHOD_TRANSACTION)
      begin
         length_dw = 10'(msg_data.size()>>2);
         vt = new(
            .access_source(access_source),
            .data_present(data_present),
            .msg_route(msg_route),
            .requester_id(requester_id),
            .msg_code(msg_code),
            .pci_target_id(pci_target_id),
            .vendor_id(vendor_id),
            .length_dw(length_dw)
         );
         vt.set_pf_vf(this.get_pfvf_setting());
         vt.request_packet.set_data(msg_data);
         t = vt;
         mutex_mmio_rx_req_input_transaction_queue.get();
         mmio_rx_req_input_transaction_queue.push_back(t);
         mutex_mmio_rx_req_input_transaction_queue.put();
      end
      else
      begin
         $display("ERROR: BFM Send VDM Method attempted while MMIO Mode was set to %s", mmio_mode.name());
      end
   endtask

endclass


//--------------------------------------------------------------
// Host BFM Class Object Declaration using Concrete Extension
//--------------------------------------------------------------
HostBFMConcrete#(pf_type, vf_type, pf_list, vf_list) host_bfm;


//---------------------------------------------------------
// Concrete Packet Delay Queue Class Definition for TX_REQ
//---------------------------------------------------------
class PacketDelayQueueTXREQ #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends packet_delay_class_pkg::PacketDelayQueue#(pf_type, vf_type, pf_list, vf_list);

   function new();
      super.new();
   endfunction

   virtual task tick();
      @(posedge axis_tx_req.clk iff (axis_tx_req.rst_n === 1'b1));
      repeat (10) @(posedge axis_tx_req.clk); // Wait for 10 clocks after the reset
      forever begin
         @(posedge axis_tx_req.clk, negedge axis_tx_req.rst_n) 
         begin
            if (!axis_tx_req.rst_n)
            begin
               mutex_queue.get();
               pd_queue.delete();
               mutex_queue.put();
            end
            else
            begin
               mutex_queue.get();
               foreach (pd_queue[i])
               begin
                  pd_queue[i].tick();
               end
               mutex_queue.put();
            end
         end
      end
   endtask

endclass


//-------------------------------------------------------------
// Concrete Packet Delay Gap Queue Class Definition for RX_REQ
//-------------------------------------------------------------
class PacketGapDelayQueueRXREQ #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends packet_delay_class_pkg::PacketGapDelayQueue#(pf_type, vf_type, pf_list, vf_list);

   function new();
      super.new();
   endfunction

   virtual task tick();
      @(posedge axis_rx_req.clk iff (axis_rx_req.rst_n === 1'b1));
      repeat (10) @(posedge axis_rx_req.clk); // Wait for 10 clocks after the reset
      forever begin
         @(posedge axis_rx_req.clk, negedge axis_rx_req.rst_n) 
         begin
            if (!axis_rx_req.rst_n)
            begin
               mutex_queue.get();
               pd_queue.delete();
               mutex_queue.put();
               sent_gap_counter = 0;
            end
            else
            begin
               if (pd_queue.size() > 0)
               begin
                  mutex_queue.get();
                  foreach (pd_queue[i])
                  begin
                     pd_queue[i].tick();
                  end
                  mutex_queue.put();
               end
               else
               begin
                  if (~&sent_gap_counter)
                  begin
                     sent_gap_counter++;  // Keep track of how long a packet has been sent so we can properly gap if delay < gap.
                  end
               end
            end
         end
      end
   endtask

endclass


//------------------------------------------------
// Mixed Traffic Packet Queues - TX_REQ Interface
//------------------------------------------------
PacketDelayQueueTXREQ#(pf_type, vf_type, pf_list, vf_list) tx_req_packet_delay_queue; // Packet Delay Queue in TX_REQ to slow down completions to RX.
PacketGapDelayQueueRXREQ#(pf_type, vf_type, pf_list, vf_list) rx_req_packet_gap_delay_queue; // Packet Delay Gap Queue in RX_REQ to spread out register accesses coming from BFM.

//------------------------------------------------------------------------
//  Access Mutex Initialization
//------------------------------------------------------------------------
initial
begin
   mutex_tag_manager = new(1);
   mutex_host_memory = new(1);
   mutex_axis_send_rx_req = new(1);
   mutex_axis_send_rx = new(1);
   mutex_mmio_rx_req_input_transaction_queue = new(1);
   mutex_mmio_rx_req_active_transaction_queue = new(1);
   mutex_mmio_rx_req_completed_transaction_queue = new(1);
   mutex_mmio_rx_req_errored_transaction_queue = new(1);
   mutex_mmio_rx_req_packet_history_queue = new(1);
   mutex_dm_rx_packet_history_queue = new(1);
   mutex_tx_inbound_message_queue = new(1);;
   mutex_tx_req_inbound_message_queue = new(1);;
end



//------------------------------------------------------------------------
//  Launch send task for AXI-ST RX Interface.
//------------------------------------------------------------------------
initial
begin
   axis_send_rx = new(.axis(axis_rx));
   fork
      axis_send_rx.run();
   join_none
end


//------------------------------------------------------------------------
//  Launch send task for AXI-ST RX_REQ Interface.
//------------------------------------------------------------------------
initial
begin
   axis_send_rx_req = new(.axis(axis_rx_req));
   fork
      axis_send_rx_req.run();
   join_none
end


//------------------------------------------------------------------------
//  Monitor state machine in AXI-ST RX Interface.
//------------------------------------------------------------------------
initial
begin
   forever begin
      @(posedge axis_rx.clk)
      begin
         local_sm_rx   = axis_send_rx.sm_state;
         local_next_rx = axis_send_rx.sm_next;
      end
   end
end


//------------------------------------------------------------------------
//  Monitor state machine in AXI-ST RX_REQ Interface.
//------------------------------------------------------------------------
initial
begin
   forever begin
      @(posedge axis_rx_req.clk)
      begin
         local_sm_rx_req   = axis_send_rx_req.sm_state;
         local_next_rx_req = axis_send_rx_req.sm_next;
      end
   end
end


//------------------------------------------------------------------------
//  Launch receive task for AXI-ST TX Interface.
//------------------------------------------------------------------------
initial
begin
   axis_receive_tx = new(.axis(axis_tx));
   fork
      axis_receive_tx.run();
   join_none
end


//------------------------------------------------------------------------
//  Monitor state machine in AXI-ST TX Interface.
//------------------------------------------------------------------------
initial
begin
   forever begin
      @(posedge axis_tx.clk)
      begin
         local_sm_tx   = axis_receive_tx.sm_state;
         local_next_tx = axis_receive_tx.sm_next;
      end
   end
end


//------------------------------------------------------------------------
//  Launch receive task for AXI-ST TX_REQ Interface.
//------------------------------------------------------------------------
initial
begin
   axis_receive_tx_req = new(.axis(axis_tx_req));
   fork
      axis_receive_tx_req.run();
   join_none
end


//------------------------------------------------------------------------
//  Monitor state machine in AXI-ST TX Interface.
//------------------------------------------------------------------------
initial
begin
   forever begin
      @(posedge axis_tx_req.clk)
      begin
         local_sm_tx_req   = axis_receive_tx_req.sm_state;
         local_next_tx_req = axis_receive_tx_req.sm_next;
      end
   end
end


//------------------------------------------------------------------------
//  Launch Host BFM logic for all AXI-ST Interface.
//------------------------------------------------------------------------
initial
begin
   host_bfm = new();
   fork
      host_bfm.run_rx_req();
      host_bfm.run_tx();
      host_bfm.run_rx();
      host_bfm.run_tx_req();
   join_none
end

//------------------------------------------------------------------------
//  Launch TX REQ Delay queue delay countdown ticker.
//------------------------------------------------------------------------
initial
begin
   tx_req_packet_delay_queue = new();
   fork
      tx_req_packet_delay_queue.tick();
   join_none
end


//------------------------------------------------------------------------
//  Launch RX REQ Gap Delay queue delay countdown ticker.
//------------------------------------------------------------------------
initial
begin
   rx_req_packet_gap_delay_queue = new();
   fork
      rx_req_packet_gap_delay_queue.tick();
   join_none
end


initial
begin
   host_memory = new(MEMORY_NAME);
   tag_manager = new();
end


endmodule
