// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __PACKET_DELAY_CLASS_PKG__
`define __PACKET_DELAY_CLASS_PKG__

package packet_delay_class_pkg; 

import host_bfm_types_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;

//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Class: Packet Delay Object
//------------------------------------------------------------------------------
// The Packet Delay objects are simply records of the packet's time while 
// waiting to be sent according to a clock defined in the Packet Delay Queue.
//------------------------------------------------------------------------------

class PacketDelay #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);
   protected static uint64_t master_delay_id = 0;
   protected uint64_t        delay_id;
   protected uint32_t        delay;
   protected uint32_t        delay_remaining;
   Packet#(pf_type, vf_type, pf_list, vf_list) p;
   protected realtime        start_time;


   function new(
      input uint32_t delay,
      input Packet#(pf_type, vf_type, pf_list, vf_list) p
   );
      this.master_delay_id += 1;
      this.delay_id = master_delay_id;
      this.delay = delay;
      this.delay_remaining = delay;
      this.p = p;
      this.start_time = $realtime;
   endfunction


   virtual function void tick();
      if (this.delay_remaining > 0)
      begin
         this.delay_remaining -= 1;
      end
   endfunction


   virtual function bit ready_to_send();
      return (this.delay_remaining == 0) ? 1'b1 : 1'b0;
   endfunction


   virtual function bit not_ready_to_send();
      return (this.delay_remaining == 0) ? 1'b0 : 1'b1;
   endfunction


   virtual function uint64_t get_delay_id();
      return this.delay_id;
   endfunction


   virtual function uint32_t get_starting_delay();
      return this.delay;
   endfunction


   virtual function uint32_t get_remaining_delay();
      return this.delay_remaining;
   endfunction


   virtual function realtime get_start_time();
      return this.start_time;
   endfunction


   virtual function void print();
      $display("   Delay ID..........: %0d", this.delay_id);
      $display("   Starting Delay....: %0d clocks", this.delay);
      $display("   Remaining Delay...: %0d clocks", this.delay_remaining);
      $display("   Packet Tag........: %H", this.p.get_tag());
      $display("");
   endfunction : print


   virtual function void print_long();
      $display("   Delay ID..........: %0d", this.delay_id);
      $display("   Starting Delay....: %0d clocks", this.delay);
      $display("   Remaining Delay...: %0d clocks", this.delay_remaining);
      $display("   Packet Info.......:");
      this.p.print_packet_long();
      $display("");
   endfunction : print_long

endclass: PacketDelay


class PacketGapDelay #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketDelay#(pf_type, vf_type, pf_list, vf_list);

   protected uint32_t delay_requested;
   protected uint32_t gap;
   protected uint32_t gap_requested;
   protected uint32_t last_packet_delay_remaining;
   protected int      delay_calc;

   function new(
      input uint32_t delay,
      input uint32_t gap,
      input uint32_t last_packet_delay_remaining,
      input uint32_t sent_gap_counter,
      input Packet#(pf_type, vf_type, pf_list, vf_list) p
   );
      super.new(
         .delay(delay),
         .p(p)
      );
      this.delay_requested = delay;
      this.gap_requested = gap;
      this.last_packet_delay_remaining = last_packet_delay_remaining;
      if (last_packet_delay_remaining  == 0)
      begin
         //$display(">>> PGD: Last Packet Delay Remaining == 0");
         if (sent_gap_counter <= (this.delay + gap))
         begin
            this.delay = this.delay + gap - sent_gap_counter + 1;
            //$display(">>> PGD: #1  this.delay:%0d  SGP:%0d  GAP:%0d", this.delay, sent_gap_counter, gap);
         end
         else
         begin
            //$display(">>> PGD: #2  this.delay:%0d  SGP:%0d  GAP:%0d", this.delay, sent_gap_counter, gap);
         end
      end
      else
      begin
         //$display(">>> PGD: ELSE OF: Last Packet Delay Remaining == 0");
         delay_calc = int'(this.delay) - int'(last_packet_delay_remaining);
         //$display(">>> PGD: #3a  this.delay:%0d  delay_calc:%0d  LPDR:%0d  SGP:%0d  GAP:%0d", this.delay, delay_calc, last_packet_delay_remaining, sent_gap_counter, gap);
         if (delay_calc <= 0 )
         begin
            this.delay = last_packet_delay_remaining + gap + 1;
            //$display(">>> PGD: #3  this.delay:%0d  delay_calc:%0d  LPDR:%0d  SGP:%0d  GAP:%0d", this.delay, delay_calc, last_packet_delay_remaining, sent_gap_counter, gap);
         end
         else
         begin
            if (this.delay - last_packet_delay_remaining <= gap)
            begin
               this.delay = last_packet_delay_remaining + gap + 1;
               //$display(">>> PGD: #4  this.delay:%0d  LPDR:%0d  SGP:%0d  GAP:%0d", this.delay, last_packet_delay_remaining, sent_gap_counter, gap);
            end
            else
            begin
               //$display(">>> PGD: #5  this.delay:%0d  LPDR:%0d  SGP:%0d  GAP:%0d", this.delay, last_packet_delay_remaining, sent_gap_counter, gap);
            end
         end
      end
      this.delay_remaining = this.delay;
   endfunction


   virtual function uint32_t get_gap_delay();
      return this.gap_requested;
   endfunction


   virtual function void print();
      $display("   Delay ID..........: %0d", this.delay_id);
      $display("   Starting Delay....: %0d clocks", this.delay);
      $display("   Remaining Delay...: %0d clocks", this.delay_remaining);
      $display("   Delay Requested...: %0d clocks", this.delay_requested);
      $display("   Gap Requested.....: %0d clocks", this.gap_requested);
      $display("   Packet Tag........: %H", this.p.get_tag());
      $display("");
   endfunction : print


   virtual function void print_long();
      $display("   Delay ID..........: %0d", this.delay_id);
      $display("   Starting Delay....: %0d clocks", this.delay);
      $display("   Remaining Delay...: %0d clocks", this.delay_remaining);
      $display("   Delay Requested...: %0d clocks", this.delay_requested);
      $display("   Gap Requested.....: %0d clocks", this.gap_requested);
      $display("   Packet Info.......:");
      this.p.print_packet_long();
      $display("");
   endfunction : print_long

endclass: PacketGapDelay


virtual class PacketDelayQueue #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);
   protected PacketDelay #(pf_type, vf_type, pf_list, vf_list) pd_queue[$];
   protected PacketDelay #(pf_type, vf_type, pf_list, vf_list) pd_search[$];
   protected semaphore    mutex_queue;


   function new();
      this.mutex_queue = new(1);
   endfunction


   pure virtual task tick();


   virtual function bit packet_ready();
      bit packets_available;
      //mutex_queue.get();
      pd_search = pd_queue.find() with (item.ready_to_send());
      packets_available = (pd_search.size() > 0) ? 1'b1 : 1'b0;
      //mutex_queue.put();
      return packets_available;
   endfunction


   virtual function int number_of_packets_available();
      int num_packets_available;
      //mutex_queue.get();
      pd_search = pd_queue.find() with (item.ready_to_send());
      num_packets_available = pd_search.size();
      //mutex_queue.put();
      return num_packets_available;
   endfunction


   virtual function int number_of_packets_waiting();
      int num_packets_waiting;
      //mutex_queue.get();
      pd_search = pd_queue.find() with (item.not_ready_to_send());
      num_packets_waiting = pd_search.size();
      //mutex_queue.put();
      return num_packets_waiting;
   endfunction


   virtual function Packet#(pf_type, vf_type, pf_list, vf_list) get_packet();
      uint64_t    found_delay_id;
      PacketDelay#(pf_type, vf_type, pf_list, vf_list) found_pd;
      //mutex_queue.get();
      pd_search = pd_queue.find() with (item.ready_to_send());
      if (pd_search.size > 0)
      begin
         found_pd = pd_search[0];
         found_delay_id = found_pd.get_delay_id();
         pd_queue = pd_queue.find() with (item.get_delay_id() != found_delay_id);
         return found_pd.p;
      end
      else
      begin
         return null;
      end
      //mutex_queue.put();
   endfunction


   virtual function void put_packet(
      input uint32_t delay,
      input Packet#(pf_type, vf_type, pf_list, vf_list) p
   );
      PacketDelay#(pf_type, vf_type, pf_list, vf_list) pdl;
      pdl = new(delay,p);
      //mutex_queue.get();
      pd_queue.push_back(pdl);
      //mutex_queue.put();
   endfunction


   virtual function void print_delay_queue();
      $display("Printing Contents of Packet Delay Queue:");
      $display("---------------------------------------");
      //mutex_queue.get();
      foreach (pd_queue[i])
      begin
         pd_queue[i].print();
      end
      //mutex_queue.put();
      $display("---------------------------------------");
      $display("End of Packet Delay Queue Print.");
      $display("");
   endfunction


   virtual function void print_delay_queue_long();
      $display("Printing Contents of Packet Delay Queue:");
      $display("---------------------------------------");
      //mutex_queue.get();
      foreach (pd_queue[i])
      begin
         pd_queue[i].print_long();
      end
      //mutex_queue.put();
      $display("---------------------------------------");
      $display("End of Packet Delay Queue Print (Long).");
      $display("");
   endfunction

endclass: PacketDelayQueue


virtual class PacketGapDelayQueue #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);
   protected uint32_t        sent_gap_counter;
   protected PacketGapDelay#(pf_type, vf_type, pf_list, vf_list) pd_queue[$];
   protected PacketGapDelay#(pf_type, vf_type, pf_list, vf_list) pd_search[$];
   protected semaphore       mutex_queue;


   function new();
      this.mutex_queue = new(1);
      sent_gap_counter = 0;
   endfunction


   pure virtual task tick();


   virtual function bit packet_ready();
      bit packets_available;
      //mutex_queue.get();
      pd_search = pd_queue.find() with (item.ready_to_send());
      packets_available = (pd_search.size() > 0) ? 1'b1 : 1'b0;
      //mutex_queue.put();
      return packets_available;
   endfunction


   virtual function int number_of_packets_available();
      int num_packets_available;
      //mutex_queue.get();
      pd_search = pd_queue.find() with (item.ready_to_send());
      num_packets_available = pd_search.size();
      //mutex_queue.put();
      return num_packets_available;
   endfunction


   virtual function int number_of_packets_waiting();
      int num_packets_waiting;
      //mutex_queue.get();
      pd_search = pd_queue.find() with (item.not_ready_to_send());
      num_packets_waiting = pd_search.size();
      //mutex_queue.put();
      return num_packets_waiting;
   endfunction


   virtual function Packet#(pf_type, vf_type, pf_list, vf_list) get_packet();
      uint64_t       found_delay_id;
      PacketGapDelay#(pf_type, vf_type, pf_list, vf_list) found_pd;
      //mutex_queue.get();
      pd_search = pd_queue.find() with (item.ready_to_send());
      if (pd_search.size > 0)
      begin
         found_pd = pd_search[0];
         found_delay_id = found_pd.get_delay_id();
         pd_queue = pd_queue.find() with (item.get_delay_id() != found_delay_id);
         return found_pd.p;
      end
      else
      begin
         return null;
      end
      //mutex_queue.put();
   endfunction


   virtual function void put_packet(
      input uint32_t delay,
      input uint32_t gap,
      input Packet#(pf_type, vf_type, pf_list, vf_list) p
   );
      PacketGapDelay#(pf_type, vf_type, pf_list, vf_list) pdl;
      uint32_t last_packet_delay_remaining;
      uint32_t max_delay_remaining;
      pd_search = pd_queue.find() with (item.not_ready_to_send());
      if (pd_search.size() == 0)
      begin
         last_packet_delay_remaining = 0;
      end
      else
      begin
         max_delay_remaining = 0;
         foreach (pd_search[i])
         begin
            if (pd_search[i].get_remaining_delay() > max_delay_remaining)
            begin
               max_delay_remaining = pd_search[i].get_remaining_delay();
            end
         end
         last_packet_delay_remaining = max_delay_remaining;
      end
      pdl = new(delay,gap,last_packet_delay_remaining,sent_gap_counter,p);
      sent_gap_counter = 0;
      //mutex_queue.get();
      pd_queue.push_back(pdl);
      //mutex_queue.put();
   endfunction


   virtual function void print_delay_queue();
      $display("Printing Contents of Packet Delay Queue:");
      $display("---------------------------------------");
      //mutex_queue.get();
      foreach (pd_queue[i])
      begin
         pd_queue[i].print();
      end
      //mutex_queue.put();
      $display("---------------------------------------");
      $display("End of Packet Delay Queue Print.");
      $display("");
   endfunction


   virtual function void print_delay_queue_long();
      $display("Printing Contents of Packet Delay Queue:");
      $display("---------------------------------------");
      //mutex_queue.get();
      foreach (pd_queue[i])
      begin
         pd_queue[i].print_long();
      end
      //mutex_queue.put();
      $display("---------------------------------------");
      $display("End of Packet Delay Queue Print (Long).");
      $display("");
   endfunction


endclass: PacketGapDelayQueue

endpackage: packet_delay_class_pkg

`endif // __PACKET_DELAY_CLASS_PKG__
