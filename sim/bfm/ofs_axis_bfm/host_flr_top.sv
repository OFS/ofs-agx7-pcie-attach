// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
//---------------------------------------------------------
// Top-level module for the AXI-ST BFM
//---------------------------------------------------------

import pcie_ss_axis_pkg::t_flr_func;
import pcie_ss_axis_pkg::t_axis_pcie_flr;

module host_flr_top(
   input logic clk,
   input logic rst_n,
   output t_axis_pcie_flr flr_req_if,
   input  t_axis_pcie_flr flr_rsp_if
);

import host_bfm_types_pkg::*;
import flr_def_pkg::*;
import host_flr_class_pkg::*;

//---------------------------------------------------------
// Concrete BFM Class Definition
//---------------------------------------------------------
class HostFLRManagerConcrete extends host_flr_class_pkg::HostFLRManager;

   function new();
      super.new();
   endfunction

   virtual task run_send_flr_reqs();
      HostFLREvent flr;
      $timeformat(-9, 3, "ns", 4);
      @(posedge clk iff (rst_n === 1'b1));
      forever begin
         @(posedge clk)
         begin
            if (flr_send_queue.size() > 0)
            begin
               flr = flr_send_queue.pop_front();
               host_flr_top.flr_req_if.tvalid = 1'b1;
               host_flr_top.flr_req_if.tdata.slot = flr.get_slot();
               host_flr_top.flr_req_if.tdata.pf   = flr.get_pf();
               host_flr_top.flr_req_if.tdata.vf   = flr.get_vf();
               host_flr_top.flr_req_if.tdata.vf_active = flr.get_vf_active();
               $display("Sending PCIe FLR with FLR ID: %0d for %-s at time: %0t", flr.get_flr_id(), flr.get_flr_type_name(), flr.get_flr_time_requested());
               flr.print_flr_event();
            end
            else
            begin
               host_flr_top.flr_req_if.tvalid = 1'b0;
               host_flr_top.flr_req_if.tdata.slot = 5'd0;
               host_flr_top.flr_req_if.tdata.pf   = 3'd0;
               host_flr_top.flr_req_if.tdata.vf   = 11'd0;
               host_flr_top.flr_req_if.tdata.vf_active = 1'b0;
            end
         end
      end
   endtask


   virtual task run_receive_flr_rsps();
      HostFLREvent flr, first_flr_match;
      uint32_t setting_index;
      flr_type_t flr_type;
      uint64_t flr_id;
      bit matched;
      $timeformat(-9, 3, "ns", 4);
      @(posedge clk iff (rst_n === 1'b1));
      forever begin
         @(negedge clk)
         begin
            if (host_flr_top.flr_rsp_if.tvalid === 1'b1) 
            begin
               if (host_flr_top.flr_rsp_if.tdata.vf_active == 1'b0)
               begin
                  setting_index =  uint32_t'(flr_def_pkg::PF0);
                  setting_index += uint32_t'(host_flr_top.flr_rsp_if.tdata.pf);
                  flr_type = flr_type_t'(setting_index);
               end
               else
               begin
                  setting_index =  uint32_t'(flr_def_pkg::PF0_VF0);
                  setting_index += uint32_t'(host_flr_top.flr_rsp_if.tdata.vf);
                  flr_type = flr_type_t'(setting_index);
               end
               flr = new(flr_type);
               flr.flr_requested(); // To set "requested" bit prior to matching response with request.
               flr.flr_responded(); // Setting proper "responded" bit and receive time
               flr_response_queue.push_back(flr);
               while (flr_response_queue.size() > 0)
               begin
                  flr = flr_response_queue.pop_front();
                  flr_search_queue = flrs.find() with ((item.get_flr_requested()) && (item.get_flr_responded == 1'b0) && (item.get_flr_type() == flr.get_flr_type()));
                  if (flr_search_queue.size() > 0)
                  begin
                     first_flr_match = flr_search_queue.pop_front();
                     flr_id = first_flr_match.get_flr_id();
                     $display(">>> Found FLR ID: %0d", flr_id);
                     matched = 1'b0;
                     foreach (flrs[i])
                     begin
                        if (!matched)
                        begin
                           if (flrs[i].get_flr_id() == flr_id)
                           begin
                              flrs[i].flr_responded();
                              $display("Matching FLR Response with FLR ID: %0d for %-s requested time %0t, responded time: %0t.", flrs[i].get_flr_id(), flrs[i].get_flr_type_name(), flrs[i].get_flr_time_requested(), flrs[i].get_flr_time_responded());
                              matched = 1'b1;
                           end // Found ID Match
                        end // If (!matched)
                     end // Foreach
                  end // if (flr_search_queue.size() > 0)
                  else // No matches to search.
                  begin
                     flr_unmatched_response_queue.push_back(flr);
                     $display("FLR ERROR: FLR Response with type %-s at time %0t was not matched with a FLR Request in the Queue.", flr.get_flr_type_name(), flr.get_flr_time_responded());
                  end
               end // While loop processing responses.
            end // If there is a response to process.
         end // @clk negedge
      end // Forever loop
   endtask

endclass

//--------------------------------------------------------------
// Host BFM Class Object Declaration using Concrete Extension
//--------------------------------------------------------------
HostFLRManagerConcrete flr_manager;

//------------------------------------------------------------------------
//  Launch FLR Manager logic for FLR Requests/Responses.
//------------------------------------------------------------------------
initial
begin
   flr_manager = new();
   fork
      flr_manager.run_send_flr_reqs();
      flr_manager.run_receive_flr_rsps();
   join_none
end


endmodule
