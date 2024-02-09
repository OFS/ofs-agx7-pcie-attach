// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __HOST_AXIS_SEND_CLASS_PKG__
`define __HOST_AXIS_SEND_CLASS_PKG__

package host_axis_send_class_pkg; 

   import host_bfm_types_pkg::*;
   import pfvf_status_class_pkg::*;
   import packet_class_pkg::*;

   typedef enum {
      RESET,
      IDLE,
      SEND_PU_ALL,
      SEND_PU_HDR,
      SEND_PU_DATA,
      SEND_PU_COMPLETE,
      SEND_DM_ALL,
      SEND_DM_HDR,
      SEND_DM_DATA,
      SEND_DM_COMPLETE
   } host_axis_send_sm_state_t;

class HostAXISSend #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0},
   int SEND_TUSER_WIDTH, 
   int SEND_TDATA_WIDTH
);

   // Local Parameters
    localparam BUS_WIDTH = (SEND_TDATA_WIDTH)/8;

   // Data Members
    //protected host_axis_send_sm_state_t sm_state, sm_next;
    host_axis_send_sm_state_t sm_state, sm_next; // Unprotect during simulation to observe in testbench
    protected packet_format_t packet_format;
    protected byte_t data_buf[];  // Dynamic Array of bytes to extract data from packet.
    protected byte_t data_queue[$]; // Queue of bytes to send.
    protected byte_t lane_data[BUS_WIDTH]; // Fixed Array of bytes arranged by bus width.
    protected bit       lane_used[BUS_WIDTH]; // Fixed Array of bits arranged by bus width indicating which byte lanes are being used.

    // Packet Object Handles
    protected Packet#(pf_type, vf_type, pf_list, vf_list) p;
    protected Packet#(pf_type, vf_type, pf_list, vf_list) q[$];

   virtual pcie_ss_axis_if #(
      //.USER_W(host_bfm_types_pkg::TUSER_WIDTH),
      //.DATA_W(host_bfm_types_pkg::TDATA_WIDTH)
      .USER_W(SEND_TUSER_WIDTH),
      .DATA_W(SEND_TDATA_WIDTH)
   ).source axis;

   // Constructor
   function new(
      virtual pcie_ss_axis_if #(
         //.USER_W(host_bfm_types_pkg::TUSER_WIDTH),
         //.DATA_W(host_bfm_types_pkg::TDATA_WIDTH)
         .USER_W(SEND_TUSER_WIDTH),
         .DATA_W(SEND_TDATA_WIDTH)
      ).source axis 
   );
      this.axis = axis;
      this.q.delete();
      this.data_queue.delete();
      this.lane_data = '{default:'0};
      this.lane_used = '{default:1'b0};
      this.sm_state = RESET;
      this.set_next_state();
      this.set_outputs();
   endfunction


   function void put_packet_in_send_queue(input Packet#(pf_type, vf_type, pf_list, vf_list) p);
      this.q.push_back(p);
   endfunction


   protected function bit packet_available();
      return (q.size() > 0);
   endfunction


   protected function void load_data_queue();
      data_buf = new[number_of_bytes_available()];
      p.get_data(data_buf);
      data_queue.delete();
      for (int i = 0; i < data_buf.size(); i++)
      begin
         data_queue.push_back(data_buf[i]);
      end
   endfunction


   protected function bit get_next_packet();
      if (packet_available())
      begin
         p = q.pop_front();
         load_data_queue();
         return 1'b1;
      end
      else
      begin
         return 1'b0;
      end
   endfunction


   protected function int bytes_sent();
      return (number_of_bytes_available() - number_of_bytes_remaining());
   endfunction
      

   protected function bit packet_is_pu_format();
      return p.packet_is_power_user_format();
   endfunction


   protected function bit packet_is_dm_format();
      return p.packet_is_data_mover_format();
   endfunction


   protected function int number_of_bytes_available();
      return p.get_size_of_packet_data_and_header();
   endfunction


   protected function int number_of_bytes_remaining();
      return data_queue.size();
   endfunction


   protected function void set_next_state();
      if (!axis.rst_n)
      begin
         sm_next = RESET;
      end
      else
      begin
         case (sm_state)
            RESET: begin
               if (packet_available())
               begin
                  get_next_packet();
                  if (packet_is_pu_format() && (number_of_bytes_available() <= BUS_WIDTH))
                  begin
                     sm_next = SEND_PU_ALL;
                  end
                  else
                  begin
                     if (packet_is_pu_format() && (number_of_bytes_available() > BUS_WIDTH))
                     begin
                        sm_next = SEND_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && (number_of_bytes_available() <= BUS_WIDTH))
                        begin
                           sm_next = SEND_DM_ALL;
                        end
                        else
                        begin // (packet_is_dm_format() && (number_of_bytes_available() > BUS_WIDTH))
                           sm_next = SEND_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            IDLE: begin
               if (packet_available())
               begin
                  get_next_packet();
                  if (packet_is_pu_format() && (number_of_bytes_available() <= BUS_WIDTH))
                  begin
                     sm_next = SEND_PU_ALL;
                  end
                  else
                  begin
                     if (packet_is_pu_format() && (number_of_bytes_available() > BUS_WIDTH))
                     begin
                        sm_next = SEND_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && (number_of_bytes_available() <= BUS_WIDTH))
                        begin
                           sm_next = SEND_DM_ALL;
                        end
                        else
                        begin // (packet_is_dm_format() && (number_of_bytes_available() > BUS_WIDTH))
                           sm_next = SEND_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            SEND_PU_ALL: begin
               if (packet_available())
               begin
                  get_next_packet();
                  if (packet_is_pu_format() && (number_of_bytes_available() <= BUS_WIDTH))
                  begin
                     sm_next = SEND_PU_ALL;
                  end
                  else
                  begin
                     if (packet_is_pu_format() && (number_of_bytes_available() > BUS_WIDTH))
                     begin
                        sm_next = SEND_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && (number_of_bytes_available() <= BUS_WIDTH))
                        begin
                           sm_next = SEND_DM_ALL;
                        end
                        else
                        begin // (packet_is_dm_format() && (number_of_bytes_available() > BUS_WIDTH))
                           sm_next = SEND_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            SEND_PU_HDR: begin
               if (number_of_bytes_remaining() <= BUS_WIDTH)
               begin
                  sm_next = SEND_PU_COMPLETE;
               end
               else
               begin // (number_of_bytes_remaining() > BUS_WIDTH)
                  sm_next = SEND_PU_DATA;
               end
            end
            SEND_PU_DATA: begin
               if (number_of_bytes_remaining() <= BUS_WIDTH)
               begin
                  sm_next = SEND_PU_COMPLETE;
               end
               else
               begin // (number_of_bytes_remaining() > BUS_WIDTH)
                  sm_next = SEND_PU_DATA;
               end
            end
            SEND_PU_COMPLETE: begin
               if (packet_available())
               begin
                  get_next_packet();
                  if (packet_is_pu_format() && (number_of_bytes_available() <= BUS_WIDTH))
                  begin
                     sm_next = SEND_PU_ALL;
                  end
                  else
                  begin
                     if (packet_is_pu_format() && (number_of_bytes_available() > BUS_WIDTH))
                     begin
                        sm_next = SEND_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && (number_of_bytes_available() <= BUS_WIDTH))
                        begin
                           sm_next = SEND_DM_ALL;
                        end
                        else
                        begin // (packet_is_dm_format() && (number_of_bytes_available() > BUS_WIDTH))
                           sm_next = SEND_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            SEND_DM_ALL: begin
               if (packet_available())
               begin
                  get_next_packet();
                  if (packet_is_pu_format() && (number_of_bytes_available() <= BUS_WIDTH))
                  begin
                     sm_next = SEND_PU_ALL;
                  end
                  else
                  begin
                     if (packet_is_pu_format() && (number_of_bytes_available() > BUS_WIDTH))
                     begin
                        sm_next = SEND_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && (number_of_bytes_available() <= BUS_WIDTH))
                        begin
                           sm_next = SEND_DM_ALL;
                        end
                        else
                        begin // (packet_is_dm_format() && (number_of_bytes_available() > BUS_WIDTH))
                           sm_next = SEND_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            SEND_DM_HDR: begin
               if (number_of_bytes_remaining() <= BUS_WIDTH)
               begin
                  sm_next = SEND_DM_COMPLETE;
               end
               else
               begin // (number_of_bytes_remaining() > BUS_WIDTH)
                  sm_next = SEND_DM_DATA;
               end
            end
            SEND_DM_DATA: begin
               if (number_of_bytes_remaining() <= BUS_WIDTH)
               begin
                  sm_next = SEND_DM_COMPLETE;
               end
               else
               begin // (number_of_bytes_remaining() > BUS_WIDTH)
                  sm_next = SEND_DM_DATA;
               end
            end
            SEND_DM_COMPLETE: begin
               if (packet_available())
               begin
                  get_next_packet();
                  if (packet_is_pu_format() && (number_of_bytes_available() <= BUS_WIDTH))
                  begin
                     sm_next = SEND_PU_ALL;
                  end
                  else
                  begin
                     if (packet_is_pu_format() && (number_of_bytes_available() > BUS_WIDTH))
                     begin
                        sm_next = SEND_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && (number_of_bytes_available() <= BUS_WIDTH))
                        begin
                           sm_next = SEND_DM_ALL;
                        end
                        else
                        begin // (packet_is_dm_format() && (number_of_bytes_available() > BUS_WIDTH))
                           sm_next = SEND_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
         endcase
      end
   endfunction


   protected function void process_data();
      int i, bytes_available;
      if (axis.rst_n)
      begin
         case (sm_state)
            RESET: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
            end
            IDLE: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
            end
            SEND_PU_ALL: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
               bytes_available = data_queue.size();
               for (i = 0; i < bytes_available; i++)
               begin
                  lane_data[i] = data_queue.pop_front();
                  lane_used[i] = 1'b1;
               end
            end
            SEND_PU_HDR: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
               bytes_available = BUS_WIDTH;
               for (i = 0; i < bytes_available; i++)
               begin
                  lane_data[i] = data_queue.pop_front();
                  lane_used[i] = 1'b1;
               end
            end
            SEND_PU_DATA: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
               bytes_available = BUS_WIDTH;
               for (i = 0; i < bytes_available; i++)
               begin
                  lane_data[i] = data_queue.pop_front();
                  lane_used[i] = 1'b1;
               end
            end
            SEND_PU_COMPLETE: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
               bytes_available = data_queue.size();
               for (i = 0; i < bytes_available; i++)
               begin
                  lane_data[i] = data_queue.pop_front();
                  lane_used[i] = 1'b1;
               end
            end
            SEND_DM_ALL: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
               bytes_available = data_queue.size();
               for (i = 0; i < bytes_available; i++)
               begin
                  lane_data[i] = data_queue.pop_front();
                  lane_used[i] = 1'b1;
               end
            end
            SEND_DM_HDR: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
               bytes_available = BUS_WIDTH;
               for (i = 0; i < bytes_available; i++)
               begin
                  lane_data[i] = data_queue.pop_front();
                  lane_used[i] = 1'b1;
               end
            end
            SEND_DM_DATA: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
               bytes_available = BUS_WIDTH;
               for (i = 0; i < bytes_available; i++)
               begin
                  lane_data[i] = data_queue.pop_front();
                  lane_used[i] = 1'b1;
               end
            end
            SEND_DM_COMPLETE: begin
               lane_data = '{default:'0};
               lane_used = '{default:1'b0};
               bytes_available = data_queue.size();
               for (i = 0; i < bytes_available; i++)
               begin
                  lane_data[i] = data_queue.pop_front();
                  lane_used[i] = 1'b1;
               end
            end
         endcase
      end
      else // We are in reset
      begin
         lane_data = '{default:'0};
         lane_used = '{default:1'b0};
      end
      axis.tdata = {<<8{lane_data}}; // Streaming operator: bytes to data bus word.
      axis.tkeep = {<<{lane_used}};  // Streaming operator: bits to keep word.
   endfunction


   protected function void set_outputs();
         axis.tvalid = ( (sm_state == SEND_PU_ALL)      ||
                         (sm_state == SEND_PU_HDR)      ||
                         (sm_state == SEND_PU_DATA)     ||
                         (sm_state == SEND_PU_COMPLETE) ||
                         (sm_state == SEND_DM_ALL)      ||
                         (sm_state == SEND_DM_HDR)      ||
                         (sm_state == SEND_DM_DATA)     ||
                         (sm_state == SEND_DM_COMPLETE) );

         axis.tlast =  ( (sm_state == SEND_PU_ALL)      ||
                         (sm_state == SEND_PU_COMPLETE) ||
                         (sm_state == SEND_DM_ALL)      ||
                         (sm_state == SEND_DM_COMPLETE) );
         
         axis.tuser_vendor = ( (sm_state == SEND_DM_ALL)      ||
                               (sm_state == SEND_DM_HDR)      ||
                               (sm_state == SEND_DM_DATA)     ||
                               (sm_state == SEND_DM_COMPLETE) ) ? 1'b1 : 1'b0;
   endfunction


   task run();
      $timeformat(-9, 3, "ns", 4);
      set_next_state();
      forever begin
         @(posedge axis.clk)
         begin
            if (axis.tready)
            begin
               set_next_state();
               sm_state <= sm_next;
               #10ps // Small delay until combinatorial outputs go valid.
               process_data();
               set_outputs();
            end
         end
      end
   endtask

endclass : HostAXISSend

endpackage: host_axis_send_class_pkg

`endif // __HOST_AXIS_SEND_CLASS_PKG__
