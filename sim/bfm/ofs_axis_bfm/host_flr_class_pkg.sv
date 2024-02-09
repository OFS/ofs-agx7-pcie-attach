// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __HOST_FLR_CLASS_PKG__
`define __HOST_FLR_CLASS_PKG__

package host_flr_class_pkg; 

import host_bfm_types_pkg::*;
import pfvf_class_pkg::*;
import pcie_ss_axis_pkg::t_flr_func;
import pcie_ss_axis_pkg::t_axis_pcie_flr;


class HostFLREvent #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);

   // Data Members
   protected static uint64_t master_flr_id = 0;
   protected uint64_t flr_id = 0;
   protected bit  [4:0] slot;
   //protected bit  [2:0] pf;
   //protected bit [10:0] vf;
   //protected bit        vf_active;
   protected bit        requested;
   protected realtime   request_time;
   protected bit        responded;
   protected realtime   respond_time;
   protected pfvf_struct  flr_type;
   protected PFVFClass#(pf_type, vf_type, pf_list, vf_list) flr_pfvf;


   // Constructor
   function new(
      input pfvf_struct flr_type
   );
      this.flr_pfvf = new(flr_type.pfn, flr_type.vfn, flr_type.vfa);
      this.master_flr_id += 1;
      this.flr_id = this.master_flr_id;
      this.flr_type = flr_type;
      this.slot = '0;
      this.set_flr(flr_type);
      this.requested = 1'b0;
      this.responded = 1'b0;
   endfunction


   // Methods
   /* function void set_flr(pfvf_type_t flr_type); */
   /*    this.pf        = pfvf_attr[flr_type].pfn; */
   /*    this.vf        = pfvf_attr[flr_type].vfn; */
   /*    this.vf_active = pfvf_attr[flr_type].vfa; */
   function void set_flr(pfvf_struct flr_type);
      this.flr_pfvf.set_pfvf_from_struct(flr_type);
   endfunction


   function uint64_t get_flr_id();
      return this.flr_id;
   endfunction


   function bit [2:0] get_pf();
      return this.flr_pfvf.get_pf_field();
   endfunction


   function bit [10:0] get_vf();
      return this.flr_pfvf.get_vf_field();
   endfunction


   function bit get_vf_active();
      return this.flr_pfvf.get_vfa;
   endfunction


   function bit [4:0] get_slot();
      return this.slot;
   endfunction

   function bit get_flr_requested();
      return this.requested;
   endfunction


   function realtime get_flr_time_requested();
      return this.request_time;
   endfunction


   function bit get_flr_responded();
      return this.responded;
   endfunction


   function realtime get_flr_time_responded();
      return this.respond_time;
   endfunction


   function void flr_requested();
      this.requested = 1'b1;
      this.request_time = $realtime;
   endfunction


   function void flr_responded();
      if (this.requested)
      begin
         this.responded = 1'b1;
         this.respond_time = $realtime;
      end
      else
      begin
         $display("FLR ERROR: An FLR response was attempted to be added to an event that has not yet been requested!");
         this.print_flr_event();
      end
   endfunction


   function pfvf_struct get_flr_type();
      return this.flr_type;
   endfunction


   /* function string get_flr_type_name(); */
   /*    return this.flr_type.name(); */
   /* endfunction */


   function void print_flr_event();
      $display("");
      if (this.requested)
      begin
         $display(">>> FLR EVENT: FLR ID: %0d for PF:%0d  VF:%0d  VFA:%B sent at time: %0t.", this.flr_id, this.get_pf(), this.get_vf(), this.get_vf_active(), this.request_time);
      end
      else
      begin
         $display(">>> FLR EVENT: FLR ID: %0d for PF:%0d  VF:%0d  VFA:%B.  Request has not yet been sent.", this.flr_id, this.get_pf(), this.get_vf(), this.get_vf_active());
      end
      $display("               Request Status.: %-s", this.requested ? "SENT" : "PENDING");
      if (this.requested)
      begin
         $display("               Request Time...: %0t", this.request_time);
      end
      $display("               Slot...........: %0d", this.slot);
      $display("               PF.............: %0d", this.get_pf());
      $display("               VF.............: %0d", this.get_vf);
      $display("               VF Active......: %-s", this.get_vf_active ? "ACTIVE" : "PF ONLY");
      $display("               Response Status: %-s", this.responded ? "RECEIVED" : "WAITING");
      if (this.responded)
      begin
         $display("               Response Time..: %0t", this.respond_time);
         $display("               Time Elapsed...: %0t", (this.respond_time - this.request_time));
      end
      $display("");
   endfunction;
   
endclass: HostFLREvent


virtual class HostFLRManager #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);

   // Data Members
   HostFLREvent#(pf_type, vf_type, pf_list, vf_list) flr;
   HostFLREvent#(pf_type, vf_type, pf_list, vf_list) flr_send_queue[$];
   HostFLREvent#(pf_type, vf_type, pf_list, vf_list) flr_response_queue[$];
   HostFLREvent#(pf_type, vf_type, pf_list, vf_list) flr_search_queue[$];
   HostFLREvent#(pf_type, vf_type, pf_list, vf_list) flr_unmatched_response_queue[$];
   HostFLREvent#(pf_type, vf_type, pf_list, vf_list) flrs[$];

   // Constructor
   function new();
   endfunction


   // Methods
   virtual function send_flr(pfvf_struct flr_type);
      flr = new(flr_type);
      flr.flr_requested();
      flr_send_queue.push_back(flr);
      flrs.push_back(flr);
   endfunction


   pure virtual task run_send_flr_reqs();
   pure virtual task run_receive_flr_rsps();


   virtual function int num_all_sent_flrs();
      flr_search_queue = flrs.find() with (item.get_flr_requested());
      return flr_search_queue.size();
   endfunction


   virtual function int num_all_completed_flrs();
      flr_search_queue = flrs.find() with (item.get_flr_responded());
      return flr_search_queue.size();
   endfunction


   virtual function int num_all_outstanding_flrs();
      flr_search_queue = flrs.find() with (item.get_flr_responded() == 1'b0);
      return flr_search_queue.size();
   endfunction


   virtual function int num_all_unmatched_responses();
      return flr_unmatched_response_queue.size();
   endfunction


   virtual function print_all_sent_flrs();
      flr_search_queue = flrs.find() with (item.get_flr_requested());
      $display("Printing all sent FLRs: %0d", this.num_all_sent_flrs());
      foreach (flr_search_queue[i])
      begin
         flr_search_queue[i].print_flr_event();
      end
      $display("");
      $display("Number of sent FLRs: %0d", this.num_all_sent_flrs());
      $display("");
   endfunction


   virtual function print_all_completed_flrs();
      flr_search_queue = flrs.find() with (item.get_flr_responded());
      $display("Printing all completed FLRs: %0d", this.num_all_completed_flrs());
      foreach (flr_search_queue[i])
      begin
         flr_search_queue[i].print_flr_event();
      end
      $display("");
      $display("Number of completed FLRs: %0d", this.num_all_completed_flrs());
      $display("");
   endfunction


   virtual function print_all_outstanding_flrs();
      flr_search_queue = flrs.find() with (item.get_flr_responded == 1'b0);
      $display("Printing all outstanding FLRs: %0d", this.num_all_outstanding_flrs());
      foreach (flr_search_queue[i])
      begin
         flr_search_queue[i].print_flr_event();
      end
      $display("");
      $display("Number of outstanding FLRs: %0d", this.num_all_outstanding_flrs());
      $display("");
   endfunction


   virtual function print_all_unmatched_responses();
      $display("Printing all unmatched FLR Responses: %0d", this.num_all_unmatched_responses());
      foreach (flr_unmatched_response_queue[i])
      begin
         flr_unmatched_response_queue[i].print_flr_event();
      end
      $display("");
      $display("Number of unmatched FLR responses received: %0d", this.num_all_unmatched_responses());
      $display("");
   endfunction

endclass: HostFLRManager

endpackage: host_flr_class_pkg


`endif // __HOST_FLR_CLASS_PKG__
