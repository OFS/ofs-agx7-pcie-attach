// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __HOST_AXIS_RECEIVE_CLASS_PKG__
`define __HOST_AXIS_RECEIVE_CLASS_PKG__

package host_axis_receive_class_pkg; 

   import host_bfm_types_pkg::*;
   import pfvf_status_class_pkg::*;
   import packet_class_pkg::*;

   typedef enum {
      RESET,
      IDLE,
      RECEIVE_PU_ALL,
      RECEIVE_PU_HDR,
      RECEIVE_PU_DATA,
      RECEIVE_PU_COMPLETE,
      RECEIVE_DM_ALL,
      RECEIVE_DM_HDR,
      RECEIVE_DM_DATA,
      RECEIVE_DM_COMPLETE
   } host_axis_receive_sm_state_t;

class HostAXISReceive #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0},
   int RECEIVE_TUSER_WIDTH, 
   int RECEIVE_TDATA_WIDTH
);

   // Local Parameters
    localparam BUS_WIDTH = (host_bfm_types_pkg::TDATA_WIDTH)/8;

   // Data Members
   protected packet_format_t packet_format;
   //protected host_axis_receive_sm_state_t sm_state, sm_next;
   host_axis_receive_sm_state_t sm_state, sm_next; // Unprotect during simulation to observe in testbench
   protected bit [7:0] header_buf[];  // Dynamic Array of bytes to extract header from AXI Stream.
   //protected bit [7:0] data_buf[];  // Dynamic Array of bytes to extract data from AXI Stream.
   protected byte_t data_buf[];  // Dynamic Array of bytes to extract data from AXI Stream.
   protected byte_t data_queue[$]; // Queue of data bytes received.

   // Packet Object Handles
   protected Packet            #(pf_type, vf_type, pf_list, vf_list) p;
   protected Packet            #(pf_type, vf_type, pf_list, vf_list) q[$];
   protected PacketPUMemReq    #(pf_type, vf_type, pf_list, vf_list) pumr;
   protected PacketPUAtomic    #(pf_type, vf_type, pf_list, vf_list) pua;
   protected PacketPUCompletion#(pf_type, vf_type, pf_list, vf_list) puc;
   protected PacketDMMemReq    #(pf_type, vf_type, pf_list, vf_list) dmmr;
   protected PacketDMCompletion#(pf_type, vf_type, pf_list, vf_list) dmc;
   protected PacketUnknown     #(pf_type, vf_type, pf_list, vf_list) pu;
   protected PacketPUMsg       #(pf_type, vf_type, pf_list, vf_list) pmsg;
   protected PacketPUVDM       #(pf_type, vf_type, pf_list, vf_list) pvdm;


   virtual pcie_ss_axis_if #(
      //.USER_W(host_bfm_types_pkg::TUSER_WIDTH),
      //.DATA_W(host_bfm_types_pkg::TDATA_WIDTH)
      .USER_W(RECEIVE_TUSER_WIDTH),
      .DATA_W(RECEIVE_TDATA_WIDTH)
   ).sink axis;

   // Constructor
   function new(
      virtual pcie_ss_axis_if #(
         //.USER_W(host_bfm_types_pkg::TUSER_WIDTH),
         //.DATA_W(host_bfm_types_pkg::TDATA_WIDTH)
         .USER_W(RECEIVE_TUSER_WIDTH),
         .DATA_W(RECEIVE_TDATA_WIDTH)
      ).sink axis 
   );
      this.axis = axis;
      this.q.delete();
      this.data_queue.delete();
      this.sm_state = RESET;
      this.set_next_state();
      this.set_outputs();
   endfunction


   function Packet#(pf_type, vf_type, pf_list, vf_list) get_packet_in_receive_queue();
      return this.q.pop_front;
   endfunction


   function bit packet_available();
      return (q.size() > 0);
   endfunction


   function int num_packets_available();
      return q.size(); 
   endfunction


   protected function bit receiving_data();
      return (axis.tvalid == 1'b1);
   endfunction


   protected function bit end_of_packet();
      return (axis.tlast == 1'b1);
   endfunction


   protected function bit packet_is_pu_format();
      return (packet_format == POWER_USER);
   endfunction


   protected function bit packet_is_dm_format();
      return (packet_format == DATA_MOVER);
   endfunction


   //-----------------------------------------------------------------
   // New Methods for Host AXIS Receive ------------------------------
   
   protected function void capture_header_and_data();
      int i, j;
      header_buf = new[32];
      data_queue.delete();
      packet_format = (axis.tuser_vendor[0] == 1'b1) ? DATA_MOVER : POWER_USER;
      for (i = 0; i < header_buf.size(); i++)
      begin
         header_buf[i] = axis.tdata[8*i +: 8];
      end
      for (j = header_buf.size(); j < BUS_WIDTH; j++)
      begin
         if (axis.tkeep[j] == 1'b1)
         begin
            data_queue.push_back(axis.tdata[8*j +: 8]);
         end
      end
   endfunction


   protected function void capture_data();
      int i;
      for (i = 0; i < BUS_WIDTH; i++)
      begin
         if (axis.tkeep[i] == 1'b1)
         begin
            data_queue.push_back(axis.tdata[8*i +: 8]);
         end
      end
   endfunction


   protected function void create_packet_and_store();
      int i, byte_data_size;
      byte_data_size = data_queue.size();
      data_buf = new[byte_data_size];
//      $display("CPS: Data Queue Size: %0d", byte_data_size);
//      $display("CPS: Data Queue Data:");
//      foreach(data_queue[i])
//      begin
//         $display("   Index:%2d  Data:%H", i, data_queue[i]);
//      end
      for (i = 0; i < byte_data_size; i++)
      begin
            data_buf[i] = data_queue.pop_front();
      end
      if (packet_format == POWER_USER)
      begin
         if ( (header_buf[3] == MRD3) || (header_buf[3] == MRD4) )
         begin
            pumr = new(
               .packet_header_op(READ),
               .requester_id(16'd0),
               .address(64'd0),
               .length_dw(64'd0),
               .first_dw_be(4'd0),
               .last_dw_be(4'd0)
            );
            pumr.set_header_bytes(header_buf);
            pumr.set_data(data_buf);
            p = pumr;
            q.push_back(p);
         end
         else
         begin
            if ( (header_buf[3] == MWR3) || (header_buf[3] == MWR4) )
            begin
               pumr = new(
                  .packet_header_op(WRITE),
                  .requester_id(16'd0),
                  .address(64'd0),
                  .length_dw(64'd0),
                  .first_dw_be(4'd0),
                  .last_dw_be(4'd0)
               );
               pumr.set_header_bytes(header_buf);
               pumr.set_data(data_buf);
               p = pumr;
               q.push_back(p);
            end
            else
            begin
               if ( (header_buf[3] == CPL) || (header_buf[3] == CPLD) )
               begin
                  puc = new(
                     .cpl_data_type( (header_buf[3] == CPL) ? NO_DATA_PRESENT : DATA_PRESENT),
                     .requester_id(16'd0),
                     .completer_id(16'd0),
                     .cpl_status(CPL_SUCCESS),
                     .byte_count(data_buf.size()),
                     .lower_address(7'd0),
                     .tag(10'd0)
                  );
                  puc.set_header_bytes(header_buf);
                  //------------------------------------------------
                  //  There is currently a bug where some out-of-range
                  //  completions return with tkeep = all ones.  Therefore,
                  //  the header length must be consulted to confirm
                  //  the payload byte count.
                  //------------------------------------------------
                  if (int'(puc.get_byte_count()) < data_buf.size())
                  begin
                     data_buf = new[int'(puc.get_byte_count())](data_buf);
                  end
                  puc.set_data(data_buf);
                  p = puc;
                  q.push_back(p);
               end
               else
               begin
                  if ( (header_buf[3] == FETCH_ADD3) || (header_buf[3] == FETCH_ADD4) )
                  begin
                     pua = new(
                        .packet_header_atomic_op(FETCH_ADD),
                        .requester_id(16'd0),
                        .address(64'd0),
                        .length_dw(data_buf.size()/4)
                     );
                     pua.set_header_bytes(header_buf);
                     pua.set_data(data_buf);
                     p = pua;
                     q.push_back(p);
                  end
                  else
                  begin
                     if ( (header_buf[3] == SWAP3) || (header_buf[3] == SWAP4) )
                     begin
                        pua = new(
                           .packet_header_atomic_op(SWAP),
                           .requester_id(16'd0),
                           .address(64'd0),
                           .length_dw(data_buf.size()/4)
                        );
                        pua.set_header_bytes(header_buf);
                        pua.set_data(data_buf);
                        p = pua;
                        q.push_back(p);
                     end
                     else
                     begin
                        if ( (header_buf[3] == CAS3) || (header_buf[3] == CAS4) )
                        begin
                           pua = new(
                              .packet_header_atomic_op(CAS),
                              .requester_id(16'd0),
                              .address(64'd0),
                              .length_dw(data_buf.size()/4)
                           );
                           pua.set_header_bytes(header_buf);
                           pua.set_data(data_buf);
                           p = pua;
                           q.push_back(p);
                        end
                        else
                        begin
                           if ( (header_buf[3] == MSG0) || (header_buf[3] == MSG1) || (header_buf[3] == MSG2) || 
                                (header_buf[3] == MSG3) || (header_buf[3] == MSG4) || (header_buf[3] == MSG5)
                             )
                           begin
                              if ((header_buf[4] == VDM_TYPE0) || (header_buf[4] == VDM_TYPE1))
                              begin
                                 pvdm = new(
                                    .data_present(NO_DATA_PRESENT),
                                    .msg_route('0),
                                    .requester_id('0),
                                    .msg_code('0),
                                    .pci_target_id('0),
                                    .vendor_id('0),
                                    .length_dw('0)
                                 );
                                 pvdm.set_header_bytes(header_buf);
                                 pvdm.set_data(data_buf);
                                 p = pvdm;
                                 q.push_back(p);
                              end
                              else
                              begin 
                                 pmsg = new(
                                    .data_present(NO_DATA_PRESENT),
                                    .msg_route('0),
                                    .requester_id('0),
                                    .msg_code('0),
                                    .lower_msg('0),
                                    .upper_msg('0),
                                    .length_dw('0)
                                 );
                                 pmsg.set_header_bytes(header_buf);
                                 pmsg.set_data(data_buf);
                                 p = pmsg;
                                 q.push_back(p);
                              end
                           end
                           else
                           begin
                              if ( (header_buf[3] == MSGD0) || (header_buf[3] == MSGD1) || (header_buf[3] == MSGD2) || 
                                   (header_buf[3] == MSGD3) || (header_buf[3] == MSGD4) || (header_buf[3] == MSGD5)
                                )
                              begin
                              if ((header_buf[4] == VDM_TYPE0) || (header_buf[4] == VDM_TYPE1))
                              begin
                                 pvdm = new(
                                    .data_present(DATA_PRESENT),
                                    .msg_route('0),
                                    .requester_id('0),
                                    .msg_code('0),
                                    .pci_target_id('0),
                                    .vendor_id('0),
                                    .length_dw('0)
                                 );
                                 pvdm.set_header_bytes(header_buf);
                                 pvdm.set_data(data_buf);
                                 p = pvdm;
                                 q.push_back(p);
                              end
                              else
                              begin 
                                 pmsg = new(
                                    .data_present(DATA_PRESENT),
                                    .msg_route('0),
                                    .requester_id('0),
                                    .msg_code('0),
                                    .lower_msg('0),
                                    .upper_msg('0),
                                    .length_dw('0)
                                 );
                                 pmsg.set_header_bytes(header_buf);
                                 pmsg.set_data(data_buf);
                                 p = pmsg;
                                 q.push_back(p);
                              end
                              end
                              else
                              begin
                                 pu = new(
                                    .packet_format(POWER_USER)
                                 );
                                 pu.set_header_bytes(header_buf);
                                 pu.set_data(data_buf);
                                 p = pu;
                                 q.push_back(p);
                              end
                           end
                        end
                     end
                  end
               end
            end
         end
      end
      else // packet_formet == DATA_MOVER
      begin
         if ( header_buf[3] == MRD4 )
         begin
            dmmr = new(
               .packet_header_op(READ),
               .host_address(64'd0),
               .local_address_or_meta_data(64'd0),
               .length(dm_length_t'(0)),
               .mm_mode(1'b0)
            );
            dmmr.set_header_bytes(header_buf);
            dmmr.set_data(data_buf);
            p = dmmr;
            q.push_back(p);
         end
         else
         begin
            if ( header_buf[3] == MWR4 )
            begin
               dmmr = new(
                  .packet_header_op(WRITE),
                  .host_address(64'd0),
                  .local_address_or_meta_data(64'd0),
                  .length(dm_length_t'(0)),
                  .mm_mode(1'b0)
               );
               dmmr.set_header_bytes(header_buf);
               dmmr.set_data(data_buf);
               p = dmmr;
               q.push_back(p);
            end
            else
            begin
               if ( header_buf[3] == CPLD )
               begin
                  dmc = new(
                     .tag(10'd0),
                     .cpl_status(CPL_SUCCESS),
                     .local_address_or_meta_data(64'd0),
                     .length(dm_length_t'(0)),
                     .mm_mode(1'b0),
                     .lower_address(24'd0)
                  );
                  dmc.set_header_bytes(header_buf);
                  dmc.set_data(data_buf);
                  p = dmc;
                  q.push_back(p);
               end
               else
               begin
                  pu = new(
                     .packet_format(DATA_MOVER)
                  );
                  pu.set_header_bytes(header_buf);
                  pu.set_data(data_buf);
                  p = pu;
                  q.push_back(p);
               end
            end
         end
      end
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
               if (receiving_data())
               begin
                  capture_header_and_data();
                  if (packet_is_pu_format() && end_of_packet())
                  begin
                     sm_next = RECEIVE_PU_ALL;
                     create_packet_and_store();
                  end
                  else
                  begin
                     if (packet_is_pu_format() && !(end_of_packet()))
                     begin
                        sm_next = RECEIVE_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && end_of_packet())
                        begin
                           sm_next = RECEIVE_DM_ALL;
                           create_packet_and_store();
                        end
                        else
                        begin // (packet_is_dm_format() && !(end_of_packet()))
                           sm_next = RECEIVE_DM_HDR;
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
               if (receiving_data())
               begin
                  capture_header_and_data();
                  if (packet_is_pu_format() && end_of_packet())
                  begin
                     sm_next = RECEIVE_PU_ALL;
                     create_packet_and_store();
                  end
                  else
                  begin
                     if (packet_is_pu_format() && !(end_of_packet()))
                     begin
                        sm_next = RECEIVE_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && end_of_packet())
                        begin
                           sm_next = RECEIVE_DM_ALL;
                           create_packet_and_store();
                        end
                        else
                        begin // (packet_is_dm_format() && !(end_of_packet()))
                           sm_next = RECEIVE_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            RECEIVE_PU_ALL: begin
               if (receiving_data())
               begin
                  capture_header_and_data();
                  if (packet_is_pu_format() && end_of_packet())
                  begin
                     sm_next = RECEIVE_PU_ALL;
                     create_packet_and_store();
                  end
                  else
                  begin
                     if (packet_is_pu_format() && !(end_of_packet()))
                     begin
                        sm_next = RECEIVE_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && end_of_packet())
                        begin
                           sm_next = RECEIVE_DM_ALL;
                           create_packet_and_store();
                        end
                        else
                        begin // (packet_is_dm_format() && !(end_of_packet()))
                           sm_next = RECEIVE_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            RECEIVE_PU_HDR: begin
               if (receiving_data())
               begin
                  capture_data();
                  if (end_of_packet())
                  begin
                     sm_next = RECEIVE_PU_COMPLETE;
                     create_packet_and_store();
                  end
                  else
                  begin // !(end_of_packet())
                     sm_next = RECEIVE_PU_DATA;
                  end
               end
               else
               begin
                  sm_next = RECEIVE_PU_HDR;
               end
            end
            RECEIVE_PU_DATA: begin
               if (receiving_data())
               begin
                  capture_data();
                  if (end_of_packet())
                  begin
                     sm_next = RECEIVE_PU_COMPLETE;
                     create_packet_and_store();
                  end
                  else
                  begin // !(end_of_packet())
                     sm_next = RECEIVE_PU_DATA;
                  end
               end
               else
               begin
                  sm_next = RECEIVE_PU_DATA;
               end
            end
            RECEIVE_PU_COMPLETE: begin
               if (receiving_data())
               begin
                  capture_header_and_data();
                  if (packet_is_pu_format() && end_of_packet())
                  begin
                     sm_next = RECEIVE_PU_ALL;
                     create_packet_and_store();
                  end
                  else
                  begin
                     if (packet_is_pu_format() && !(end_of_packet()))
                     begin
                        sm_next = RECEIVE_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && end_of_packet())
                        begin
                           sm_next = RECEIVE_DM_ALL;
                           create_packet_and_store();
                        end
                        else
                        begin // (packet_is_dm_format() && !(end_of_packet()))
                           sm_next = RECEIVE_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            RECEIVE_DM_ALL: begin
               if (receiving_data())
               begin
                  capture_header_and_data();
                  if (packet_is_pu_format() && end_of_packet())
                  begin
                     sm_next = RECEIVE_PU_ALL;
                     create_packet_and_store();
                  end
                  else
                  begin
                     if (packet_is_pu_format() && !(end_of_packet()))
                     begin
                        sm_next = RECEIVE_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && end_of_packet())
                        begin
                           sm_next = RECEIVE_DM_ALL;
                           create_packet_and_store();
                        end
                        else
                        begin // (packet_is_dm_format() && !(end_of_packet()))
                           sm_next = RECEIVE_DM_HDR;
                        end
                     end
                  end
               end
               else // No Packet Available
               begin
                  sm_next = IDLE;
               end
            end
            RECEIVE_DM_HDR: begin
               if (receiving_data())
               begin
                  capture_data();
                  if (end_of_packet())
                  begin
                     sm_next = RECEIVE_DM_COMPLETE;
                     create_packet_and_store();
                  end
                  else
                  begin // !(end_of_packet())
                     sm_next = RECEIVE_DM_DATA;
                  end
               end
               else
               begin
                  sm_next = RECEIVE_DM_HDR;
               end
            end
            RECEIVE_DM_DATA: begin
               if (receiving_data())
               begin
                  capture_data();
                  if (end_of_packet())
                  begin
                     sm_next = RECEIVE_DM_COMPLETE;
                     create_packet_and_store();
                  end
                  else
                  begin // !(end_of_packet())
                     sm_next = RECEIVE_DM_DATA;
                  end
               end
               else
               begin
                  sm_next = RECEIVE_DM_DATA;
               end
            end
            RECEIVE_DM_COMPLETE: begin
               if (receiving_data())
               begin
                  capture_header_and_data();
                  if (packet_is_pu_format() && end_of_packet())
                  begin
                     sm_next = RECEIVE_PU_ALL;
                     create_packet_and_store();
                  end
                  else
                  begin
                     if (packet_is_pu_format() && !(end_of_packet()))
                     begin
                        sm_next = RECEIVE_PU_HDR;
                     end
                     else
                     begin
                        if (packet_is_dm_format() && end_of_packet())
                        begin
                           sm_next = RECEIVE_DM_ALL;
                           create_packet_and_store();
                        end
                        else
                        begin // (packet_is_dm_format() && !(end_of_packet()))
                           sm_next = RECEIVE_DM_HDR;
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


   protected function void set_outputs();
         axis.tready = ( (sm_state == IDLE)                ||
                         (sm_state == RECEIVE_PU_ALL)      ||
                         (sm_state == RECEIVE_PU_HDR)      ||
                         (sm_state == RECEIVE_PU_DATA)     ||
                         (sm_state == RECEIVE_PU_COMPLETE) ||
                         (sm_state == RECEIVE_DM_ALL)      ||
                         (sm_state == RECEIVE_DM_HDR)      ||
                         (sm_state == RECEIVE_DM_DATA)     ||
                         (sm_state == RECEIVE_DM_COMPLETE) );
   endfunction


   task run();
      $timeformat(-9, 3, "ns", 4);
      set_next_state();
      forever begin
         @(posedge axis.clk)
         begin
            set_next_state();
            sm_state <= sm_next;
            #10ps // Small delay until combinatorial outputs go valid.
            set_outputs();
         end
      end
   endtask

endclass : HostAXISReceive

endpackage: host_axis_receive_class_pkg

`endif // __HOST_AXIS_RECEIVE_CLASS_PKG__
