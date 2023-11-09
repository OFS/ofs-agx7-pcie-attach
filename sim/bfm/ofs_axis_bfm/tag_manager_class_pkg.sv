// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __TAG_MANAGER_CLASS_PKG__
`define __TAG_MANAGER_CLASS_PKG__

package tag_manager_class_pkg; 

import host_bfm_types_pkg::*;
import packet_class_pkg::*;

//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// TagManager: Manages 8-bit and 10-bit tag usage for the top-level BFM code.
// Anti-aliasing is not performed here in the tag ranges since this is
// a captive system and there are no legacy 8-bit nor 5-bit responders on the
// link.
//------------------------------------------------------------------------------

class TagManager;

   // Data Members
   //packet_tag_t i;
   //protected bit [10:0] super_i;
   protected packet_tag_t tag8_queue[$];
   protected packet_tag_t tag10_queue[$];
   protected bit tag8_in_use[packet_tag_t];
   protected bit tag10_in_use[packet_tag_t];

   // Constructor
   function new();
      this.reset_tags();
   endfunction

   // Methods
   function void reset_tags();
      packet_tag_t i;
      bit [10:0] super_i;
      this.tag8_queue.delete();
      this.tag10_queue.delete();
      this.tag8_in_use.delete();
      this.tag10_in_use.delete();
      for (i = 10'd0; i <= 10'h0ff; i += 10'd1)
      begin
         this.tag8_queue.push_back(i);
      end
      for (super_i = 11'h100; super_i <= 11'h3ff; super_i += 11'd1)
      begin
         this.tag10_queue.push_back(packet_tag_t'(super_i));
      end
   endfunction : reset_tags


   function bit get_packet_tag_success(
      input packet_format_t packet_format_in,
      input packet_header_op_t packet_header_op_in,
      ref packet_tag_t packet_tag
   );
      if (packet_format_in == POWER_USER)
      begin
         if ((packet_header_op_in == READ) || (packet_header_op_in == ATOMIC))
         begin
            if (tag8_queue.size() > 0)
            begin
               packet_tag = tag8_queue.pop_front();
               tag8_in_use[packet_tag] = 1'b1;
               return 1'b1;
            end
            else
            begin
               return 1'b0;
            end
         end
         else  // if packet_header_op_in is anything else, recycle tag
         begin
            if (tag8_queue.size() > 0)
            begin
               packet_tag = tag8_queue.pop_front();
               tag8_queue.push_back(packet_tag);
               return 1'b1;
            end
            else
            begin
               return 1'b0;
            end
         end
      end
      else  // (packet_format_in == DATA_MOVER)
      begin
         if (packet_header_op_in == READ)
         begin
            if (tag10_queue.size() > 0)
            begin
               packet_tag = tag10_queue.pop_front();
               tag10_in_use[packet_tag] = 1'b1;
               return 1'b1;
            end
            else
            begin
               return 1'b0;
            end
         end
         else  // if packet_header_op_in is anything else, recycle tag
         begin
            if (tag8_queue.size() > 0)
            begin
               packet_tag = tag8_queue.pop_front();
               tag8_queue.push_back(packet_tag);
               return 1'b1;
            end
            else
            begin
               return 1'b0;
            end
         end
      end
   endfunction : get_packet_tag_success


   function void release_tag(
      input packet_tag_t tag
   );
      //packet_tag_t t;
      packet_tag_t search_results[$];
      int search_index[$];
      if (|tag[9:8])
      begin
         if (tag10_in_use.exists(tag))
         begin
            tag10_in_use.delete(tag);
            tag10_queue.push_back(tag);
         end
         else
         begin
            search_results = tag10_queue.find with (item == tag);
            search_index   = tag10_queue.find_index with (item == tag);
            if (search_results.size() == 0)
            begin
               tag10_queue.push_back(tag);
            end
            else
            begin
               if (search_results.size() > 1)
               begin
                  foreach (search_index[i])
                  begin
                     tag10_queue.delete(search_index[i]);
                  end
                  tag10_queue.push_back(tag);
               end
            end
         end
      end
      else  // This is an 8-bit tag
      begin
         if (tag8_in_use.exists(tag))
         begin
            tag8_in_use.delete(tag);
            tag8_queue.push_back(tag);
         end
         else
         begin
            search_results = tag8_queue.find with (item == tag);
            search_index   = tag8_queue.find_index with (item == tag);
            if (search_results.size() == 0)
            begin
               tag8_queue.push_back(tag);
            end
            else
            begin
               if (search_results.size() > 1)
               begin
                  foreach (search_index[i])
                  begin
                     tag8_queue.delete(search_index[i]);
                  end
                  tag8_queue.push_back(tag);
               end
            end
         end
      end
   endfunction : release_tag


   function int get_num_available_8bit_tags();
      return tag8_queue.size();
   endfunction : get_num_available_8bit_tags


   function int queue_8bit_tags_empty();
      return (tag8_queue.size() == 0);
   endfunction : queue_8bit_tags_empty


   function int get_num_used_8bit_tags();
      return tag8_in_use.size();
   endfunction : get_num_used_8bit_tags


   function int get_num_available_10bit_tags();
      return tag10_queue.size();
   endfunction : get_num_available_10bit_tags


   function int queue_10bit_tags_empty();
      return (tag10_queue.size() == 0);
   endfunction : queue_10bit_tags_empty


   function int get_num_used_10bit_tags();
      return tag10_in_use.size();
   endfunction : get_num_used_10bit_tags


   function void dump_tags();
      $display("Dumping Packet Tag Information:");
      $display("  Tag8 Queue:");
      foreach (tag8_queue[i])
      begin
         $display("    %H",tag8_queue[i]);
      end
      $display("  Tag8 In-Use Associative Array:");
      foreach (tag8_in_use[i])
      begin
         $display("    %H",i);
      end
      $display("  Tag10 Queue:");
      foreach (tag10_queue[i])
      begin
         $display("    %H",tag10_queue[i]);
      end
      $display("  Tag10 In-Use Associative Array:");
      foreach (tag10_in_use[i])
      begin
         $display("    %H",i);
      end
   endfunction : dump_tags


   function void dump_8bit_tags();
      $display("Dumping Packet Tag Information:");
      $display("  Tag8 Queue:");
      foreach (tag8_queue[i])
      begin
         $display("    %H",tag8_queue[i]);
      end
      $display("  Tag8 In-Use Associative Array:");
      foreach (tag8_in_use[i])
      begin
         $display("    %H",i);
      end
   endfunction : dump_8bit_tags


   function void dump_10bit_tags();
      $display("Dumping Packet Tag Information:");
      $display("  Tag10 Queue:");
      foreach (tag10_queue[i])
      begin
         $display("    %H",tag10_queue[i]);
      end
      $display("  Tag10 In-Use Associative Array:");
      foreach (tag10_in_use[i])
      begin
         $display("    %H",i);
      end
   endfunction : dump_10bit_tags


   function void dump_used_tags();
      $display("Dumping Packet Tag Information:");
      $display("  Tag8 In-Use Associative Array:");
      foreach (tag8_in_use[i])
      begin
         $display("    %H",i);
      end
      $display("  Tag10 In-Use Associative Array:");
      foreach (tag10_in_use[i])
      begin
         $display("    %H",i);
      end
   endfunction : dump_used_tags

endclass : TagManager


endpackage: tag_manager_class_pkg

`endif // __TAG_MANAGER_CLASS_PKG__
