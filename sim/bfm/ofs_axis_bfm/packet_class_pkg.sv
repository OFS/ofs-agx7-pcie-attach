// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __PACKET_CLASS_PKG__
`define __PACKET_CLASS_PKG__

package packet_class_pkg; 

import host_bfm_types_pkg::*;
import pfvf_class_pkg::*;
import pfvf_status_class_pkg::*;

//------------------------------------------------------------------------------
// Parameter and Enum Definitions for Host Memory.
//------------------------------------------------------------------------------
typedef enum {
   POWER_USER,
   DATA_MOVER
} packet_format_t;

typedef enum {
   READ,
   WRITE,
   COMPLETION,
   ATOMIC,
   MSG,
   VDM,
   UNKNOWN,
   NULL
} packet_header_op_t;

typedef enum {
   FETCH_ADD,
   SWAP,
   CAS,
   NON_ATOMIC
} packet_header_atomic_op_t;

typedef enum {
   NO_DATA_PRESENT,
   DATA_PRESENT
} data_present_type_t;

typedef enum bit [2:0] {
   CPL_SUCCESS             = 3'b000,
   CPL_UNSUPPORTED_REQUEST = 3'b001,
   CPL_REQUEST_RETRY       = 3'b010,
   CPL_COMPLETER_ABORT     = 3'b100,
   CPL_ERROR               = 3'b111
} cpl_status_t;

typedef enum bit [2:0] {
   HDR_3DW_NO_DATA   = 3'b000,
   HDR_4DW_NO_DATA   = 3'b001,
   HDR_3DW_WITH_DATA = 3'b010,
   HDR_4DW_WITH_DATA = 3'b011,
   HDR_TLP_PREFIX    = 3'b100
} tlp_fmt_t;

typedef enum bit [7:0] {
   MRD3       = 8'b000_0_0000,  // Covered in PacketHeaderPUMemReq Class
   CPL        = 8'b000_0_1010,  // Covered in PacketHeaderPUCompletion Class
   MRD4       = 8'b001_0_0000,  // Covered in PacketHeaderPUMemReq Class & PacketHeaderDMMemReq Class
   MSG0       = 8'b001_1_0000,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG1       = 8'b001_1_0001,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG2       = 8'b001_1_0010,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG3       = 8'b001_1_0011,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG4       = 8'b001_1_0100,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG5       = 8'b001_1_0101,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MWR3       = 8'b010_0_0000,  // Covered in PacketHeaderPUMemReq Class
   CPLD       = 8'b010_0_1010,  // Covered in PacketHeaderPUCompletion Class & PacketHeaderDMCompletion Class
   FETCH_ADD3 = 8'b010_0_1100,  // Covered in PacketHeaderPUAtomic Class
   SWAP3      = 8'b010_0_1101,  // Covered in PacketHeaderPUAtomic Class
   CAS3       = 8'b010_0_1110,  // Covered in PacketHeaderPUAtomic Class
   MWR4       = 8'b011_0_0000,  // Covered in PacketHeaderPUMemReq Class & PacketHeaderDMMemReq Class
   FETCH_ADD4 = 8'b011_0_1100,  // Covered in PacketHeaderPUAtomic Class
   SWAP4      = 8'b011_0_1101,  // Covered in PacketHeaderPUAtomic Class
   CAS4       = 8'b011_0_1110,  // Covered in PacketHeaderPUAtomic Class
   MSGD0      = 8'b011_1_0000,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD1      = 8'b011_1_0001,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD2      = 8'b011_1_0010,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD3      = 8'b011_1_0011,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD4      = 8'b011_1_0100,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD5      = 8'b011_1_0101,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   ERROR      = 8'b111_1_1111   // Fall-out Error Condition
} tlp_fmt_type_t;

typedef enum bit [2:0] {
   TO_ROOT_COMPLEX             = 3'b000,
   ROUTED_BY_ADDRESS           = 3'b001,
   ROUTED_BY_ID                = 3'b010,
   BROADCAST_FROM_ROOT_COMPLEX = 3'b011,
   LOCAL_TERM_AT_RX            = 3'b100,
   ROUTED_TO_ROOT_COMPLEX      = 3'b101
} msg_route_t;

typedef enum bit [2:0] {
   VDM_TO_ROOT_COMPLEX             = 3'b000,
   VDM_ROUTED_BY_ID                = 3'b010,
   VDM_BROADCAST_FROM_ROOT_COMPLEX = 3'b011
} vdm_msg_route_t;

typedef enum bit [7:0] {
   VDM_TYPE0 = 8'h7E,
   VDM_TYPE1 = 8'h7F
} vdm_msg_type_t;



//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeader
// Class Inheritance: None
//------------------------------------------------------------------------------
// This abstract base class forms the basis for all of the packet header
// formats contained in the Packet Class.  It contains the data members to
// support construction of the standard PCIe Transaction Layer Packet (TLP)
// header fields.
//
// The function methods are common for all of the header subclasses in order
// to facilitate polymorphism.
//------------------------------------------------------------------------------

virtual class PacketHeader #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
); // Abstract Base Class

   // Data Members
   protected packet_format_t packet_format;
   protected packet_header_op_t packet_header_op;
   protected PFVFRouting#(pf_type, vf_type, pf_list, vf_list) pf_vf_route; // Singleton object for PCIe setting
   protected bit  [3:0] bar;
   protected bit  [4:0] slot;
   //protected bit  [2:0] pf;
   //protected bit [10:0] vf;
   //protected bit        vf_active;
   protected pfvf_struct pf_vf_setting, last_pf_vf_setting;
   protected PFVFClass#(pf_type, vf_type, pf_list, vf_list) pfvf;
   protected uint32_t          request_delay;  // In clock AXI-ST Bus cycles - delay for outgoing request packets.
   protected uint32_t          completion_delay;  // In clock AXI-ST Bus cycles.
   protected uint32_t          gap;  // In clock AXI-ST Bus cycles - minimum distance between outgoing request packets..
   // PCIe Header Fields
   protected tlp_fmt_t      fmt;  // TLP Format: 3DW/4DW w/o Data and Prefix
   protected bit [4:0]      tlp_type; // TLP Type field: MRd, MWr, Cpl, etc.
   protected tlp_fmt_type_t fmt_type; // Combination of FMT and Type
   protected bit [9:0]      length_dw; // TLP payload length in double-words (32-bits)
   protected packet_tag_t   tag;  // Packet Tag
   protected bit [2:0]      tc;   // Traffic Class
   protected bit [1:0]      at;   // Address Type: 00 Untranslated, 01 Translation Request, 10 Translated, and 11 is Reserved. 
   protected bit [2:0]      attr; // Attributes: {ID-Based Ordering, Relaxed Ordering, No Snoop}
   protected bit            ep;  // Error Poisoned: indicates the TLP is poisoned.
   protected bit            td;  // TLP Digest: a 1'b1 indicates presence of TLP Digest in form of DW at the end of the TLP.
   protected bit            th;  // TLP Hints: a 1'b1 indicates the presence of TLP processing hints in header and optional TPH TLP prefix.
   protected bit            ln;  // Lightweight Notification
   protected bit [1:0]      ph; // Processing Hints

   // Power User and Data Mover Header Fields
   protected bit [23:0] prefix;
   protected bit  [4:0] prefix_type;
   protected bit        prefix_present;

   // Data Mapping into Double Words and Bytes
   protected bit [31:0] header_dw [8];
   protected bit [7:0] header_bytes [32];


   // Constructor for PacketHeader
   function new(
      input packet_format_t packet_format,
      input packet_header_op_t packet_header_op,
      input bit [9:0] length_dw
   );
      this.packet_format = packet_format;
      this.packet_header_op = packet_header_op;
      this.length_dw = length_dw;
      this.tag = '0;
      this.tc = '0;
      this.at = '0;
      this.attr = '0;
      this.ep = '0;
      this.td = '0;
      this.th = '0;
      this.ln = '0;
      this.ph = '0;
      this.prefix = '0;
      this.prefix_type = '0;
      this.prefix_present = '0;
      this.pf_vf_route = PFVFRouting#(pf_type, vf_type, pf_list, vf_list)::get(); // Singleton object for PCIe setting.
      this.bar  = pf_vf_route.get_bar();
      this.slot = pf_vf_route.get_slot();
      //this.pf   = pf_vf_route.get_pf();
      //this.vf   = pf_vf_route.get_vf();
      //this.vf_active = pf_vf_route.get_vfa();
      this.pf_vf_setting = pf_vf_route.get_env();
      this.last_pf_vf_setting = pf_vf_route.get_env();
      this.pfvf = new(0,0,0);
      this.pfvf.set_pfvf_from_struct(pf_vf_setting);
      this.request_delay = 0;
      this.completion_delay = 65;
      this.gap = 5;
   endfunction
  

   // Class Methods
   virtual function void set_pf_vf(pfvf_struct setting);
      // NOTE: Changing the PF/VF here does not change the state of the Host
      // as in the commented out line immediately below.  This must be done
      // with the BFM object.  This will only change the packet's state.
      // New packets will change via the pf_vf_route.
      //this.pf_vf_route.set_env(setting);
      if (this.pfvf.set_pfvf_from_struct(setting))
      begin
         this.last_pf_vf_setting = this.pf_vf_setting;
         this.pf_vf_setting = setting;
         map_fields();
      end
   endfunction


   virtual function void revert_to_last_pfvf_setting();
      pfvf_struct tmp_setting;
      if (this.pfvf.set_pfvf_from_struct(this.last_pf_vf_setting))
      begin
         tmp_setting = this.pf_vf_setting;
         this.pf_vf_setting = this.last_pf_vf_setting;
         this.last_pf_vf_setting = tmp_setting;
         map_fields();
      end
   endfunction


   virtual function pfvf_struct get_pf_vf();
      return this.pf_vf_setting;
   endfunction
      

   virtual function packet_format_t get_packet_format();
      return this.packet_format;
   endfunction


   virtual function bit packet_is_power_user_format();
      // Static function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return (packet_format == POWER_USER);
   endfunction


   virtual function bit packet_is_data_mover_format();
      // Static function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return (packet_format == DATA_MOVER);
   endfunction


   virtual function packet_header_op_t get_packet_header_op();
      return this.packet_header_op;
   endfunction


   virtual function packet_header_atomic_op_t get_packet_header_atomic_op();
      // Static function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return NON_ATOMIC;
   endfunction


   virtual function tlp_fmt_type_t get_fmt_type();
      return this.fmt_type;
   endfunction


   virtual function tlp_fmt_t get_fmt();
      return this.fmt;
   endfunction


   virtual function bit [4:0] get_tlp_type();
      return this.tlp_type;
   endfunction


   virtual function data_present_type_t get_cpl_data_type();
      // Static function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return NO_DATA_PRESENT;
   endfunction


   virtual function bit [9:0] get_length_dw();
      return this.length_dw;
   endfunction


   virtual function void set_length_dw(input bit [9:0] length_dw);
      this.length_dw = length_dw;
      map_fields();
   endfunction


   virtual function bit [3:0] get_first_dw_be();
      // Static-one function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 4'b1111;
   endfunction


   virtual function void set_first_dw_be(input bit [3:0] first_dw_be);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [3:0] get_last_dw_be();
      // Static-one function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 4'b1111;
   endfunction


   virtual function void set_last_dw_be(input bit [3:0] last_dw_be);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function packet_tag_t get_tag();
      return this.tag;
   endfunction


   virtual function void set_tag(input packet_tag_t tag);
      this.tag = tag;
      map_fields();
   endfunction


   virtual function bit [2:0] get_tc();
      return this.tc;
   endfunction


   virtual function void set_tc(input bit [2:0] tc);
      this.tc = tc;
      map_fields();
   endfunction


   virtual function bit [1:0] get_at();
      return this.at;
   endfunction


   virtual function void set_at(input bit [1:0] at);
      this.at = at;
      map_fields();
   endfunction


   virtual function bit [2:0] get_attr();
      return this.attr;
   endfunction


   virtual function void set_attr(input bit [2:0] attr);
      this.attr = attr;
      map_fields();
   endfunction


   virtual function bit get_ep();
      return this.ep;
   endfunction


   virtual function void set_ep(input bit ep);
      this.ep = ep;
      map_fields();
   endfunction


   virtual function bit get_td();
      return this.td;
   endfunction


   virtual function void set_td(input bit td);
      this.td = td;
      map_fields();
   endfunction


   virtual function bit get_th();
      return this.th;
   endfunction


   virtual function void set_th(input bit th);
      this.th = th;
      map_fields();
   endfunction


   virtual function bit get_ln();
      return this.ln;
   endfunction


   virtual function void set_ln(input bit ln);
      this.ln = ln;
      map_fields();
   endfunction


   virtual function bit [1:0] get_ph();
      return this.ph;
   endfunction


   virtual function void set_ph(
      input bit [1:0] ph
   );
      this.ph = ph;
      map_fields();
   endfunction


   virtual function bit [1:0] get_pad_length();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 2'b00;
   endfunction


   virtual function void set_pad_length(input bit [1:0] pad_length);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [3:0] get_mctp_vdm_code();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 4'b0000;
   endfunction


   virtual function void set_mctp_vdm_code(input bit [3:0] vdm_code);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [3:0] get_mctp_header_version();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 4'b0000;
   endfunction


   virtual function void set_mctp_header_version(input bit [3:0] header_version);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [7:0] get_mctp_destination_endpoint_id();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 8'h00;
   endfunction


   virtual function void set_mctp_destination_endpoint_id(bit [7:0] destination_endpoint_id);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [7:0] get_mctp_source_endpoint_id();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 8'h00;
   endfunction


   virtual function void set_mctp_source_endpoint_id(bit [7:0] source_endpoint_id);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit get_mctp_som();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 1'h0;
   endfunction


   virtual function void set_mctp_som(input bit som);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit get_mctp_eom();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 1'h0;
   endfunction


   virtual function void set_mctp_eom(input bit eom);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [1:0] get_mctp_packet_sequence_number();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 2'b00;
   endfunction


   virtual function void set_mctp_packet_sequence_number(input bit [1:0] psn);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit get_mctp_tag_owner();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 1'b0;
   endfunction


   virtual function void set_mctp_tag_owner(input bit tag_owner);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [2:0] get_mctp_message_tag();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 3'b000;
   endfunction


   virtual function void set_mctp_message_tag(input bit [2:0] message_tag);
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [23:0] get_prefix();
      return this.prefix;
   endfunction


   virtual function void set_prefix(input bit [23:0] prefix);
      this.prefix = prefix;
      map_fields();
   endfunction


   virtual function bit [4:0] get_prefix_type();
      return this.prefix_type;
   endfunction


   virtual function void set_prefix_type(input bit [4:0] prefix_type);
      this.prefix_type = prefix_type;
      map_fields();
   endfunction


   virtual function bit get_prefix_present();
      return this.prefix_present;
   endfunction


   virtual function void set_prefix_present(input bit prefix_present);
      this.prefix_present = prefix_present;
      map_fields();
   endfunction


   virtual function bit [2:0] get_pf_num();
      return this.pfvf.get_pf_field();
   endfunction


   virtual function bit [10:0] get_vf_num();
      return this.pfvf.get_vf_field();
   endfunction


   virtual function bit get_vf_active();
      return this.pfvf.get_vfa();
   endfunction


   virtual function void set_bar_num(bit[3:0] bar);
      this.bar = bar;
   endfunction
  

   virtual function void set_slot_num(bit[4:0] slot);
      this.slot = slot;
   endfunction


   virtual function bit [3:0] get_bar_num();
      return this.bar;
   endfunction


   virtual function bit [4:0] get_slot_num();
      return this.slot;
   endfunction


   virtual function void set_request_delay(input uint32_t delay);
      this.request_delay = delay;
   endfunction


   virtual function uint32_t get_request_delay();
      return this.request_delay;
   endfunction


   virtual function void set_completion_delay(input uint32_t delay);
      this.completion_delay = delay;
   endfunction


   virtual function uint32_t get_completion_delay();
      return this.completion_delay;
   endfunction


   virtual function void set_gap(input uint32_t gap);
      this.gap = gap;
   endfunction


   virtual function uint32_t get_gap();
      return this.gap;
   endfunction



   //-------------------------------------------------------
   // Abstract and Null Methods for Base Class PacketHeader
   //-------------------------------------------------------
   
   //-------------------------------------------------------------------------
   // The following private method helps to control the values the
   // TLP Fmt/Type are set to depending on header, address, and request type.
   pure virtual protected function void set_packet_fmt_type();

   //-------------------------------------------------------------------------
   // Address methods work with a 64-bit value or the lower 32-bit portion of
   // the address argument depending on 3DW or 4DW header with value
   // passed as a 64-bit value.
   pure virtual function uint64_t get_addr();
   pure virtual function uint64_t get_addr_first_be_adjusted();
   pure virtual function void set_addr(input uint64_t addr);

   //-------------------------------------------------------------------------
   // Get method for TLP Requester ID
   virtual function bit [15:0] get_requester_id();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {16{1'b0}};
   endfunction


   //-------------------------------------------------------------------------
   // Get method for MSG Code for MSG TLPs
   virtual function bit [7:0] get_msg_code();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {8{1'b0}};
   endfunction


   //-------------------------------------------------------------------------
   // Get method for Lower Message data for MSG TLPs
   virtual function bit [31:0] get_lower_msg();
      return {this.get_pci_target_id(), this.get_vendor_id()};
   endfunction


   //-------------------------------------------------------------------------
   // Get method for Upper Message data for MSG TLPs
   virtual function bit [31:0] get_upper_msg();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {32{1'b0}};
   endfunction


   //-------------------------------------------------------------------------
   // Get method for PCI Target ID data for VDM MSG TLPs
   virtual function bit [15:0] get_pci_target_id();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {16{1'b0}};
   endfunction


   //-------------------------------------------------------------------------
   // Get method for Vendor ID data for VDM MSG TLPs
   virtual function bit [15:0] get_vendor_id();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {16{1'b0}};
   endfunction

   //---------------------------------------------------------------------------------------
   // Byte-length of payload for Power User Mode: 1 - 2^12 (4MB) or Data Mode: 2^24 or 16MB
   pure virtual function uint32_t get_length_bytes();
   pure virtual function uint32_t get_expected_completion_length_bytes();

   
   virtual function void set_length_bytes(
      input uint32_t length_bytes
   );
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction

   //-------------------------------------------------------------------------
   // Host and Local methods for Data-Mover Headers
   virtual function uint64_t get_dm_host_addr();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {64{1'b0}};
   endfunction


   virtual function void set_dm_host_addr(
      input uint64_t dm_host_addr
   );
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function uint64_t get_dm_local_addr();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {64{1'b0}};
   endfunction


   virtual function void set_dm_local_addr(
      input uint64_t dm_local_addr
   );
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   //-------------------------------------------------------------------------
   // Data-Mover methods for mm_mode
   virtual function bit get_mm_mode();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 1'b0;
   endfunction


   virtual function void set_mm_mode(
      input bit mm_mode
   );
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   //-------------------------------------------------------------------------
   // Meta-Data field methods for Data-Mover Headers
   virtual function uint64_t get_dm_meta_data();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {64{1'b0}};
   endfunction


   virtual function void set_dm_meta_data(
      input uint64_t dm_meta_data
   );
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   //-------------------------------------------------------------------------
   // Cpl Packet Header methods
   virtual function bit [15:0] get_completer_id();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 16'd0;
   endfunction


   virtual function bit [11:0] get_byte_count();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 11'd0;
   endfunction


   virtual function bit [6:0] get_lower_address();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {7{1'b0}};
   endfunction


   virtual function bit [23:0] get_dm_lower_address();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {24{1'b0}};
   endfunction


   virtual function cpl_status_t get_cpl_status();
      // Static-value function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      // An error condition is returned in this context because, unless it is
      // redefined in an appropriate child class, use of this method results
      // in an error condition.
      return CPL_ERROR;
   endfunction


   virtual function void set_cpl_status(
      input cpl_status_t cpl_status
   );
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit get_bcm();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 1'b0;
   endfunction


   virtual function void set_bcm(
      input bit bcm
   );
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit get_fc();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 1'b0;
   endfunction


   virtual function void set_fc(
      input bit fc
   );
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   // Extract header values from object - Useful for packet transmission
   virtual function void get_header_bytes(
      ref bit [7:0] header_buf[]
   );
      for (int i = 0; i < header_buf.size(); i++)
      begin
         header_buf[i] = header_bytes[i];
      end
   endfunction


   // Extract header values from object - Useful for packet comparison
   virtual function void get_header_words(
      ref bit [31:0] header_buf[]
   );
      for (int i = 0; i < header_buf.size(); i++)
      begin
         header_buf[i] = header_dw[i];
      end
   endfunction


   // Assign header fields from bytes - Useful for packet reception
   virtual function void set_header_bytes(
      const ref bit [7:0] header_buf[]
   );
      int i;
      for (i = 0; i < header_buf.size(); i++)
      begin
         header_bytes[i] = header_buf[i];
      end
      for (i = 0; i < 8; i++)
      begin
         header_dw[i] = {<<8{header_bytes[4*i],header_bytes[(4*i)+1], header_bytes[(4*i)+2], header_bytes[(4*i)+3]}};
      end
      assign_fields();
   endfunction


   // Map Header Values to Double-Word Fields
   pure virtual protected function void map_fields();

   // Assign Header Values from Double-Word Fields
   pure virtual protected function void assign_fields();

   // Print out packet header info.
   pure virtual function void print_header_short();
   pure virtual function void print_header();
   pure virtual function void print_header_long();

endclass : PacketHeader


//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeaderUnknown
// Class Inheritance: PacketHeader
//------------------------------------------------------------------------------
// This class forms is a very flexible and generic class meant to be free from
// format restrictions enforced by other derived header classes.
//
// The 'map_fields' and 'assign_fields' function methods in this class are
// empty functions: freeing up the user to format the header double-words as
// they want without the class correcting them.  This is particularly
// important if the user wants to create "errored" packets or packets with an
// unusual format that does not comply with the formatting enforced by other
// classes.
//
// Having this freedom comes at a price however: the user will have to
// manually map all the header fields that are desired when creating packet
// headers as well as extracting the desired bit fields from received packets.
//------------------------------------------------------------------------------

class PacketHeaderUnknown #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketHeader#(pf_type, vf_type, pf_list, vf_list);

   //Data Members
   protected int payload_length;

   // Constructor for PacketHeaderUnknown 
   function new(
      input packet_format_t packet_format
   );
      super.new(
         .packet_format(packet_format), 
         .packet_header_op(UNKNOWN),
         .length_dw(10'd0) 
      );
      this.packet_header_op = UNKNOWN;
   endfunction


   virtual protected function void set_packet_fmt_type();
      // Empty function: this method does nothing in this class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function uint64_t get_addr();
      // Static-zero function: this method does nothing in this 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {64{1'b0}};
   endfunction


   virtual function uint64_t get_addr_first_be_adjusted();
      // Static-zero function: this method does nothing in this 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return {64{1'b0}};
   endfunction


   virtual function void set_addr(input uint64_t addr);
      // Empty function: this method does nothing in this class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual function bit [11:0] get_byte_count();
      return payload_length[11:0];
   endfunction


   virtual function uint32_t get_length_bytes();
      return payload_length;
   endfunction


   virtual function uint32_t get_expected_completion_length_bytes();
      return 0;
   endfunction


   virtual function void set_length_bytes(
      input uint32_t length_bytes
   );
      this.payload_length = length_bytes;
   endfunction


   virtual protected function void map_fields();
      // Empty function: this method does nothing in this class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   virtual protected function void assign_fields();
      // Empty function: this method does nothing in this abstract base class,
      // but select child classes will define it.  It is declared here to
      // maintain base class compatibility (polymorphism).
   endfunction


   //------------------------------------------
   // Header printing for PacketHeaderUnknown  
   //------------------------------------------
   virtual function void print_header_short();
      $display("   Packet Header Info (Short):");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
   endfunction


   virtual function void print_header();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      for (i=0; i<4; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<4*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((4*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


   virtual function void print_header_long();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      for (i=0; i<8; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<8*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((8*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


endclass : PacketHeaderUnknown


//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeaderPUMemReq
// Class Inheritance: PacketHeader
//------------------------------------------------------------------------------
// This class supports the Power User Memory Request headers for read and
// write packets with 4DW or 3DW support for 64-bit or 32-bit addressing.
//
// These packets for all of our Control and Status Register (CSR) reads and
// writes which drive most of the simulation unit tests.
//------------------------------------------------------------------------------

class PacketHeaderPUMemReq #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketHeader#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected uint64_t   address;
   protected bit [15:0] requester_id;
   protected bit  [3:0] first_dw_be;
   protected bit  [3:0] last_dw_be;

   // Constructor for PacketHeaderPUMemReq 
   function new(
      input packet_header_op_t packet_header_op,
      input bit [15:0] requester_id,
      input uint64_t   address,
      input bit  [9:0] length_dw,
      input bit  [3:0] first_dw_be,
      input bit  [3:0] last_dw_be
   );
      super.new(
         .packet_format(POWER_USER), 
         .packet_header_op(packet_header_op),
         .length_dw(length_dw)
      );
      if ((packet_header_op == READ) || (packet_header_op == WRITE))
         this.packet_header_op = packet_header_op;
      else
         this.packet_header_op = NULL;
      this.requester_id = requester_id;
      this.address = address;
      this.first_dw_be = first_dw_be;
      this.last_dw_be  = last_dw_be;
      this.ph = 2'b00;
      this.set_packet_fmt_type();
   endfunction

   
   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw};
      header_dw[1] = {requester_id, tag[7:0], last_dw_be, first_dw_be};
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         header_dw[2] = address[63:32];
         header_dw[3] = {address[31:2], ph};
      end
      else
      begin
         header_dw[2] = {address[31:2], ph};
         header_dw[3] = '0;  // Blank Field for 3DW Addressing
      end
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, 1'b0, slot, bar, pfvf.get_vfa(), pfvf.get_vf_field(), pfvf.get_pf_field()};
      header_dw[6] = '0; // Reserved Fields
      header_dw[7] = '0; // Reserved Fields
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      bit local_vfa;
      bit  [2:0] local_pf;
      bit [10:0] local_vf;
      pfvf_struct local_pfvf;
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw} = header_dw[0];
      fmt = tlp_fmt_t'(fmt_type[7:5]);
      tlp_type = fmt_type[4:0];
      if ((fmt_type == MRD4) || (fmt_type == MRD3))
      begin
         packet_header_op = READ;
      end
      else
      begin
         if ((fmt_type == MWR4) || (fmt_type == MWR3))
            packet_header_op = WRITE;
         else
            packet_header_op = NULL;
      end
      {requester_id, tag[7:0], last_dw_be, first_dw_be} = header_dw[1];
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         address[63:32] = header_dw[2];
         {address[31:2], ph} = header_dw[3];
      end
      else
      begin
         address[63:32] = '0;
         {address[31:2], ph} = header_dw[2];
      end
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {slot, bar, local_vfa, local_vf, local_pf} = header_dw[5][23:0];
      local_pfvf.pfn = local_pf;
      local_pfvf.vfn = local_vf;
      local_pfvf.vfa = local_vfa;
      pfvf.set_pfvf_from_struct(local_pfvf);
   endfunction


   virtual protected function void set_packet_fmt_type();
      if ((packet_header_op == READ) || (packet_header_op == WRITE))
      begin
         if (|address[63:32])
         begin
            if (packet_header_op == READ)
            begin
               this.fmt_type = MRD4;
            end
            else
            begin
               this.fmt_type = MWR4;
            end
         end
         else
         begin
            if (packet_header_op == READ)
            begin
               this.fmt_type = MRD3;
            end
            else
            begin
               this.fmt_type = MWR3;
            end
         end
      end
      else
      begin
         this.packet_header_op = NULL;
         this.fmt_type = ERROR;
      end
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction


   virtual function uint64_t get_addr();
      return this.address;
   endfunction


   //---------------------------------------------------------------------------
   // This get method returns the memory request address adjusted by the
   // first byte enable field.  For each zero in the field, the byte address
   // is moved up on address location.
   //
   // This method assumes that the first byte enable fields bits are
   // contiguous and right adjusted.  If this is not the case, then the
   // address calculation should be done by reading the address with the
   // "get_addr" method and modifying as needed using the byte enable fetched
   // with the get method "get_first_dw_be".
   //---------------------------------------------------------------------------
   virtual function uint64_t get_addr_first_be_adjusted();
      uint64_t addr;
      int i;
      addr = this.address;
      for (i = 0; i < 4; i++)
      begin
         if (this.first_dw_be[i] == 1'b0)
         begin
            addr = addr + uint64_t'(1);
         end
      end
      return addr;
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      this.address = addr;
      this.set_packet_fmt_type(); // Done in case the address requires a change between 4DW and 3DW headers.
   endfunction


   virtual function bit [15:0] get_requester_id();
      return this.requester_id;
   endfunction


   virtual function bit [3:0] get_first_dw_be();
      return this.first_dw_be;
   endfunction


   virtual function void set_first_dw_be(input bit [3:0] first_dw_be);
      this.first_dw_be = first_dw_be;
      map_fields();
   endfunction


   virtual function bit [3:0] get_last_dw_be();
      return this.last_dw_be;
   endfunction


   virtual function void set_last_dw_be(input bit [3:0] last_dw_be);
      this.last_dw_be = last_dw_be;
      map_fields();
   endfunction


   virtual function uint32_t get_length_bytes();
      uint32_t total_bytes;
      int i;
      if (length_dw == '0)
      begin
         total_bytes = 1024 * 4;
      end
      else
      begin
         total_bytes = length_dw * 4;
      end
      for (i=0; i<4; i=i+1)
      begin
         if (first_dw_be[i] == 1'b0)
         begin
            total_bytes = total_bytes - uint32_t'(1);
         end
      end
      for (i=0; i<4; i=i+1)
      begin
         if (last_dw_be[i] == 1'b0)
         begin
            total_bytes = total_bytes - uint32_t'(1);
         end
      end
      return total_bytes;
   endfunction


   virtual function uint32_t get_expected_completion_length_bytes();
      if (packet_header_op == READ)
         return this.get_length_bytes();
      else
         return 0;
   endfunction


   //------------------------------------------
   // Header printing for PacketHeaderPUMemReq
   //------------------------------------------
   virtual function void print_header_short();
      $display("   Packet Header Info (Short):");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Packet Tag........: %H", this.tag);
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         $display("      Address...........: %H_%H_%H_%H", this.address[63:48], this.address[47:32], this.address[31:16], this.address[15:0]);
      end
      else
      begin
         $display("      Address...........: %H_%H", this.address[31:16], this.address[15:0]);
      end
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
   endfunction


   virtual function void print_header();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Requester ID......: %H", this.requester_id);
      $display("      Packet Tag........: %H", this.tag);
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         $display("      Address...........: %H_%H_%H_%H", this.address[63:48], this.address[47:32], this.address[31:16], this.address[15:0]);
      end
      else
      begin
         $display("      Address...........: %H_%H", this.address[31:16], this.address[15:0]);
      end
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      First DW BE.......: %B", this.get_first_dw_be());
      $display("      Last DW BE........: %B", this.get_last_dw_be());
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      for (i=0; i<4; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<4*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((4*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


   virtual function void print_header_long();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Requester ID......: %H", this.requester_id);
      $display("      Packet Tag........: %H", this.tag);
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         $display("      Address...........: %H_%H_%H_%H", this.address[63:48], this.address[47:32], this.address[31:16], this.address[15:0]);
      end
      else
      begin
         $display("      Address...........: %H_%H", this.address[31:16], this.address[15:0]);
      end
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      First DW BE.......: %B", this.get_first_dw_be());
      $display("      Last DW BE........: %B", this.get_last_dw_be());
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      $display("      Prefix............: %H", this.prefix);
      $display("      Prefix Type.......: %H", this.prefix_type);
      $display("      Prefix Present....: %B", this.prefix_present);
      $display("      PF................: %H", this.get_pf_num());
      $display("      VF................: %H", this.get_vf_num());
      $display("      VF Active.........: %H", this.get_vf_active());
      $display("      BAR Number........: %H", this.get_bar_num());
      $display("      Slot Number.......: %H", this.get_slot_num());
      for (i=0; i<8; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<8*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((8*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction

endclass : PacketHeaderPUMemReq


//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeaderPUAtomic
// Class Inheritance: PacketHeaderPUMemReq
//------------------------------------------------------------------------------
// This class supports the Power User Atomic Operation headers for
// fetch-add, swap, and compare-and-swap (CAS) PCIe operations.
//
// Operations;
//1. Fetch-Add operations with operand field lengths of 1DW or 2DW (operand sizes of 32-bit and 64-bit).
//   - Packet will contain one operand, the "add" value.
//   - Packet will contain the address of the target memory location for the operation.
//   - Operation: 
//      - Adds the "add" value to the value at the target memory location.
//      - Stores the result of the addition at the same memory location.
//      - Returns the original value found at the memory location prior to the add operations.
//2. Swap operations with operand field lengths of 1DW or 2DW (operand sizes of 32-bit and 64-bit).
//   - Packet will contain one operand, the "swap" value.
//   - Packet will contain the address of the target memory location for the operation.
//   - Operation: 
//      - Swaps the data at a target location with the "swap" value. 
//      - Stores the "swap" value at the target address.
//      - Returns the original value found at the memory location prior to the operation.
//3. Compare-and-Swap operations with operand field lengths of 2DW, 4DW, or 8DW (operand sizes of 32-bit, 64-bit, and 128-bit).
//   - Packet will contain two operands.
//      - First operand is the "compare" value.
//      - Second operand is the "swap" value.
//   - Packet will contain the address of the target memory location for the operation.
//   - Operation: 
//      - First the data at the target memory location is compared to the "compare" value.
//      - If the two values are different, no change to the target memory location occurs.
//      - However, if the data at the target location is equal to the "compare" value, then a swap occurs.
//         - The data at the target memory location is swapped with the "swap" value.
//         - The "swap" data is stored at the target memory location.
//      - Whether the swap occurs or not, the operation returns the original value found at the target memory location.
//
//In all of the Atomic operations, the original data at the targeted memory location is returned back to the requester with a completion packet.
//------------------------------------------------------------------------------

class PacketHeaderPUAtomic #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketHeaderPUMemReq#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected packet_header_atomic_op_t packet_header_atomic_op;

   // Constructor for PacketHeaderPUAtomic 
   function new(
      input packet_header_atomic_op_t packet_header_atomic_op,
      input bit [15:0] requester_id,
      input uint64_t   address,
      input bit  [9:0] length_dw
   );
      super.new(
         .packet_header_op(ATOMIC), 
         .requester_id(requester_id),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(4'b1111),
         .last_dw_be(4'b1111)
      );
      if ( ((packet_header_atomic_op == FETCH_ADD) && ((length_dw == 10'd1) || (length_dw == 10'd2))) ||
           ((packet_header_atomic_op == SWAP)      && ((length_dw == 10'd1) || (length_dw == 10'd2))) ||
           ((packet_header_atomic_op == CAS)       && ((length_dw == 10'd2) || (length_dw == 10'd4)   || (length_dw == 10'd8))) )
      begin
         this.packet_header_op = ATOMIC;
         this.packet_header_atomic_op = packet_header_atomic_op;
      end
      else
      begin
         this.packet_header_op = NULL;
         this.packet_header_atomic_op = packet_header_atomic_op;
      end
      this.set_packet_fmt_type();
   endfunction


   virtual protected function void assign_fields();
      bit local_vfa;
      bit  [2:0] local_pf;
      bit [10:0] local_vf;
      pfvf_struct local_pfvf;
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw} = header_dw[0];
      fmt = tlp_fmt_t'(fmt_type[7:5]);
      tlp_type = fmt_type[4:0];
      if ( (fmt_type == FETCH_ADD3) || (fmt_type == FETCH_ADD4) ||
           (fmt_type == SWAP3)      || (fmt_type == SWAP4)      ||
           (fmt_type == CAS3)       || (fmt_type == CAS4) )
      begin
         packet_header_op = ATOMIC;
      end
      else
      begin
         packet_header_op = NULL;
      end
      {requester_id, tag[7:0], last_dw_be, first_dw_be} = header_dw[1];
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         address[63:32] = header_dw[2];
         {address[31:2], ph} = header_dw[3];
      end
      else
      begin
         address[63:32] = '0;
         {address[31:2], ph} = header_dw[2];
      end
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {slot, bar, local_vfa, local_vf, local_pf} = header_dw[5][23:0];
      local_pfvf.pfn = local_pf;
      local_pfvf.vfn = local_vf;
      local_pfvf.vfa = local_vfa;
      pfvf.set_pfvf_from_struct(local_pfvf);
   endfunction


   virtual protected function void set_packet_fmt_type();
      if (packet_header_op == ATOMIC)
      begin
         if (|address[63:32])
         begin
            if (packet_header_atomic_op == FETCH_ADD)
            begin
               this.fmt_type = FETCH_ADD4;
            end
            else
            begin
               if (packet_header_atomic_op == SWAP)
               begin
                  this.fmt_type = SWAP4;
               end
               else
               begin
                  this.fmt_type = CAS4;
               end
            end
         end
         else
         begin
            if (packet_header_atomic_op == FETCH_ADD)
            begin
               this.fmt_type = FETCH_ADD3;
            end
            else
            begin
               if (packet_header_atomic_op == SWAP)
               begin
                  this.fmt_type = SWAP3;
               end
               else
               begin
                  this.fmt_type = CAS3;
               end
            end
         end
      end
      else
      begin
         this.packet_header_op = NULL;
         this.fmt_type = ERROR;
      end
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction


   virtual function packet_header_atomic_op_t get_packet_header_atomic_op();
      return this.packet_header_atomic_op;
   endfunction


   virtual function uint32_t get_length_bytes();
      uint32_t total_bytes;
      total_bytes = length_dw * 4;
      return total_bytes;
   endfunction


   virtual function uint32_t get_expected_completion_length_bytes();
      uint32_t total_bytes;
      if ((packet_header_atomic_op == FETCH_ADD) || (packet_header_atomic_op == SWAP))
      begin
         total_bytes = length_dw * 4;
         $display("Giving long expected completion width of >> %0d", total_bytes);
      end
      else
      begin
         total_bytes = length_dw * 2; // Smaller completion for CAS Atomic Operation because half of request payload is immediate compare value.
         $display("Giving short expected completion width of >> %0d", total_bytes);
      end
      return total_bytes;
   endfunction
      


   //------------------------------------------
   // Header printing for PacketHeaderPUAtomic
   //------------------------------------------
   virtual function void print_header_short();
      $display("   Packet Header Info (Short):");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Atomic Operation..: %s", this.packet_header_atomic_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Packet Tag........: %H", this.tag);
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         $display("      Address...........: %H_%H_%H_%H", this.address[63:48], this.address[47:32], this.address[31:16], this.address[15:0]);
      end
      else
      begin
         $display("      Address...........: %H_%H", this.address[31:16], this.address[15:0]);
      end
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
   endfunction


   virtual function void print_header();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Atomic Operation..: %s", this.packet_header_atomic_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Requester ID......: %H", this.requester_id);
      $display("      Packet Tag........: %H", this.tag);
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         $display("      Address...........: %H_%H_%H_%H", this.address[63:48], this.address[47:32], this.address[31:16], this.address[15:0]);
      end
      else
      begin
         $display("      Address...........: %H_%H", this.address[31:16], this.address[15:0]);
      end
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      First DW BE.......: %B", this.get_first_dw_be());
      $display("      Last DW BE........: %B", this.get_last_dw_be());
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      for (i=0; i<4; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<4*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((4*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


   virtual function void print_header_long();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Atomic Operation..: %s", this.packet_header_atomic_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Requester ID......: %H", this.requester_id);
      $display("      Packet Tag........: %H", this.tag);
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         $display("      Address...........: %H_%H_%H_%H", this.address[63:48], this.address[47:32], this.address[31:16], this.address[15:0]);
      end
      else
      begin
         $display("      Address...........: %H_%H", this.address[31:16], this.address[15:0]);
      end
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      First DW BE.......: %B", this.get_first_dw_be());
      $display("      Last DW BE........: %B", this.get_last_dw_be());
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      $display("      Prefix............: %H", this.prefix);
      $display("      Prefix Type.......: %H", this.prefix_type);
      $display("      Prefix Present....: %B", this.prefix_present);
      $display("      PF................: %H", this.get_pf_num());
      $display("      VF................: %H", this.get_vf_num());
      $display("      VF Active.........: %H", this.get_vf_active());
      $display("      BAR Number........: %H", this.get_bar_num());
      $display("      Slot Number.......: %H", this.get_slot_num());
      for (i=0; i<8; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<8*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((8*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction

endclass : PacketHeaderPUAtomic


//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeaderPUCompletion
// Class Inheritance: PacketHeaderPUMemReq
//------------------------------------------------------------------------------
// This header class is another extremely important class that is used in 
// concert with all of the packets requesting data.  For operations like reads 
// and Atomic operations where data is returned from the completer to the 
// requester, this data is sent back in the form of one or more completion 
// packets.  
//
// This class supports completions with or without data up to the maximum
// payload allowed by PCI Express.
//------------------------------------------------------------------------------

class PacketHeaderPUCompletion #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketHeaderPUMemReq#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected data_present_type_t cpl_data_type;
   protected bit [15:0]   completer_id;
   protected cpl_status_t cpl_status;
   protected bit bcm; // Byte Count Modified
   protected bit [11:0]   byte_count; // TLP payload length in bytes 
   protected bit  [6:0]   lower_address;  // Lower byte address for starting byte of completion

   // Constructor for PacketHeaderPUCompletion 
   function new(
      input data_present_type_t cpl_data_type,
      input bit [15:0] requester_id,
      input bit [15:0] completer_id,
      input cpl_status_t cpl_status,
      input bit [11:0] byte_count,
      input bit  [6:0] lower_address
   );
      super.new(
         .packet_header_op(COMPLETION),
         .requester_id(requester_id),
         .address({64{1'b0}}),
         .length_dw( (|byte_count[1:0]) ? (byte_count>>2) + 10'd1 : byte_count>>2 ),
         .first_dw_be(4'b0000),
         .last_dw_be(4'b0000)
      );
      this.packet_header_op = COMPLETION;
      this.cpl_data_type = cpl_data_type;
      this.completer_id = completer_id;
      this.cpl_status = cpl_status;
      this.byte_count = byte_count;
      this.lower_address = lower_address;
      this.bcm = 1'b0;
      this.set_packet_fmt_type();
   endfunction


   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw};
      header_dw[1] = {requester_id, cpl_status, bcm, byte_count};
      header_dw[2] = {completer_id, tag[7:0], 1'b0, lower_address};
      header_dw[3] = '0;  // Blank Field
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, 1'b0, this.slot, this.bar, this.pfvf.get_vfa(), this.pfvf.get_vf_field(), this.pfvf.get_pf_field()};
      header_dw[6] = '0; // Reserved Fields
      header_dw[7] = '0; // Reserved Fields
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      bit local_vfa;
      bit  [2:0] local_pf;
      bit [10:0] local_vf;
      pfvf_struct local_pfvf;
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw} = header_dw[0];
      {requester_id, cpl_status, bcm, byte_count} = header_dw[1];
      completer_id = header_dw[2][31:16];
      tag[7:0] = header_dw[2][15:8];
      lower_address = header_dw[2][6:0];
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {slot, bar, local_vfa, local_vf, local_pf} = header_dw[5][23:0];
      local_pfvf.pfn = local_pf;
      local_pfvf.vfn = local_vf;
      local_pfvf.vfa = local_vfa;
      pfvf.set_pfvf_from_struct(local_pfvf);
   endfunction


   virtual protected function void set_packet_fmt_type();
      if (packet_header_op == COMPLETION) 
      begin
         if (cpl_data_type == DATA_PRESENT)
         begin
            this.fmt_type = CPLD;
         end
         else
         begin
            this.fmt_type = CPL;
         end
      end
      else
      begin
         this.packet_header_op = NULL;
         this.fmt_type = ERROR;
      end
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction


   virtual function data_present_type_t get_cpl_data_type();
      return this.cpl_data_type;
   endfunction


   virtual function uint64_t get_addr();
      return {'0, this.lower_address};
   endfunction


   virtual function uint64_t get_addr_first_be_adjusted();
      return this.get_addr();
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      this.lower_address = addr[6:0];
      map_fields();
   endfunction


   virtual function uint32_t get_length_bytes();
      uint32_t total_bytes;
      if (byte_count == '0)
      begin
         total_bytes = 1024 * 4;
      end
      else
      begin
         total_bytes = uint32_t'(byte_count);
      end
      return total_bytes;
   endfunction


   virtual function uint32_t get_expected_completion_length_bytes();
      return 0;
   endfunction


   virtual function void set_length_bytes(
      input uint32_t length_bytes
   );
      // Future: Put some checking here in cast length_bytes[63:12] has any
      // ones in it.
      if (length_bytes == 1024*4)
         this.byte_count = '0;
      else
         this.byte_count = length_bytes[11:0];
      length_dw = (|byte_count[1:0]) ? (byte_count>>2) + 10'd1 : byte_count>>2;
      map_fields();
   endfunction


   virtual function bit [15:0] get_completer_id();
      return this.completer_id;
   endfunction


   virtual function bit [11:0] get_byte_count();
      return this.byte_count;
   endfunction


   virtual function bit [6:0] get_lower_address();
      return this.lower_address;
   endfunction


   virtual function cpl_status_t get_cpl_status();
      return this.cpl_status;
   endfunction


   virtual function void set_cpl_status(
      input cpl_status_t cpl_status
   );
      this.cpl_status = cpl_status;
      map_fields();
   endfunction


   virtual function bit get_bcm();
      return bcm;
   endfunction


   virtual function void set_bcm(input bit bcm);
      this.bcm = bcm;
      map_fields();
   endfunction



   //----------------------------------------------
   // Header printing for PacketHeaderPUCompletion
   //----------------------------------------------
   virtual function void print_header_short();
      $display("   Packet Header Info (Short):");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Completion Data...: %s", this.cpl_data_type.name());
      $display("      Completion Status.: %s", this.cpl_status.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Lower Address.....: %H", this.lower_address);
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Byte Count........: %H", this.byte_count);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
   endfunction


   virtual function void print_header();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Completion Data...: %s", this.cpl_data_type.name());
      $display("      Completion Status.: %s", this.cpl_status.name());
      $display("      Requester ID......: %H", this.requester_id);
      $display("      Completer ID......: %H", this.completer_id);
      $display("      Packet Tag........: %H", this.tag);
      $display("      Lower Address.....: %H", this.lower_address);
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Byte Count........: %H", this.byte_count);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      BCM...............: %B", this.bcm);
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      for (i=0; i<4; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<4*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((4*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


   virtual function void print_header_long();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Completion Data...: %s", this.cpl_data_type.name());
      $display("      Completion Status.: %s", this.cpl_status.name());
      $display("      Requester ID......: %H", this.requester_id);
      $display("      Completer ID......: %H", this.completer_id);
      $display("      Packet Tag........: %H", this.tag);
      $display("      Lower Address.....: %H", this.lower_address);
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Byte Count........: %H", this.byte_count);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      BCM...............: %B", this.bcm);
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      $display("      Prefix............: %H", this.prefix);
      $display("      Prefix Type.......: %H", this.prefix_type);
      $display("      Prefix Present....: %B", this.prefix_present);
      $display("      PF................: %H", this.get_pf_num());
      $display("      VF................: %H", this.get_vf_num());
      $display("      VF Active.........: %H", this.get_vf_active());
      $display("      BAR Number........: %H", this.get_bar_num());
      $display("      Slot Number.......: %H", this.get_slot_num());
      for (i=0; i<8; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<8*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((8*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction

endclass : PacketHeaderPUCompletion


//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeaderDMMemReq
// Class Inheritance: PacketHeader
//------------------------------------------------------------------------------
// The header class `PacketHeaderDMMemReq` supports the Intel PCIe Subsystem 
// Data Mover packet header format.  Data Mover format was devised to make 
// large data transfers more efficient by allowing data transfers of up to 16MB 
// instead of the usual maximum of 4096 bytes using a PCIe TLP.  To include the 
// much larger 24-bit length field, some of the PCIe TLP's fields had to be 
// repurposed, while others were preserved and carried over from the standard 
// TLP header.  This class implements read and write memory requests using this 
// expanded data throughput capability.
//
// These packets use already-defined TLP FMT/Type values of 8'h20 for Data 
// Mover Read (DMRd) and 8'h60 for Data Mover Write (DMWr).  These normally 
// correspond to MRd (with 4DW header) and MWr (also with 4DW header) TLP 
// FMT/Type encodings in Power User (PCIe TLP) format.  Since both Power User 
// and Data Mover packets can coexist on the same AXI-ST bus, there was a way 
// needed to differentiate the two during bus transactions.  This is done by 
// using the AXI-ST bus' `tuser_vendor` bits to communicate this difference in 
// real time.  Bit `tuser_vendor[0]` signals to the transaction receiver what 
// format the packet header is in:
// 
// - `tuser_vendor[0] = 1'b0` indicates a Power User header (regular PCIe TLP).
// - `tuser_vendor[0] = 1'b1` indicates a Data Mover header.
// 
// The BFM logic and the FIM AXI-ST interface logic must be able to decode 
// this operation in order to properly sort the mixed traffic.  If, for some 
// reason, an AXI-ST interface is not expected to carry mixed traffic, then 
// this bit _can_ be ignored, but decoding one bit should not impose too much 
// of a logic burden and supporting both packet formats would make the AXI-ST 
// interfaces more robust and interchangeable in operation.
//------------------------------------------------------------------------------

class PacketHeaderDMMemReq #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketHeader#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected uint64_t host_address;
   protected uint64_t local_address;
   protected uint64_t meta_data;
   protected dm_length_t length;
   protected bit mm_mode;

   // Constructor for PacketHeaderDMMemReq 
   function new(
      input packet_header_op_t packet_header_op,
      input uint64_t host_address,
      input uint64_t local_address_or_meta_data,
      input dm_length_t length,
      input bit mm_mode
   );
      super.new(
         .packet_format(DATA_MOVER),
         .packet_header_op(packet_header_op),
         .length_dw( (|length[1:0]) ? (length>>2) + 10'd1 : length>>2 )
      );
      if ((packet_header_op == READ) || (packet_header_op == WRITE))
         this.packet_header_op = packet_header_op;
      else
         this.packet_header_op = NULL;
      this.host_address = host_address;
      this.mm_mode = mm_mode;
      if (mm_mode)
      begin
         this.local_address = local_address_or_meta_data;
         this.meta_data = '0;
      end
      else
      begin
         this.local_address = '0;
         this.meta_data = local_address_or_meta_data;
      end
      this.length = length;
      this.ph = 2'b00;
      this.set_packet_fmt_type();
   endfunction

   
   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length[11:2]};
      header_dw[1] = {host_address[1:0], length[23:12], length[1:0], tag[7:0], 8'b0000_0000};
      header_dw[2] = host_address[63:32];
      header_dw[3] = {host_address[31:2], ph};
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, mm_mode, this.slot, 4'b0000, this.pfvf.get_vfa(), this.pfvf.get_vf_field(), this.pfvf.get_pf_field()};
      if (mm_mode)
      begin
         header_dw[6] = local_address[63:32];
         header_dw[7] = local_address[31:0];
      end
      else
      begin
         header_dw[6] = meta_data[63:32];
         header_dw[7] = meta_data[31:0];
      end
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      bit local_vfa;
      bit  [2:0] local_pf;
      bit [10:0] local_vf;
      pfvf_struct local_pfvf;
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length[11:2]} = header_dw[0];
      {host_address[1:0], length[23:12], length[1:0], tag[7:0]} = header_dw[1][31:8];
      host_address[63:32] = header_dw[2];
      {host_address[31:2], ph} = header_dw[3];
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {mm_mode, slot, bar, local_vfa, local_vf, local_pf} = header_dw[5][24:0];
      local_pfvf.pfn = local_pf;
      local_pfvf.vfn = local_vf;
      local_pfvf.vfa = local_vfa;
      pfvf.set_pfvf_from_struct(local_pfvf);
      if (mm_mode)
      begin
         local_address[63:32] = header_dw[6];
         local_address[31:0]  = header_dw[7];
      end
      else
      begin
         meta_data[63:32] = header_dw[6];
         meta_data[31:0]  = header_dw[7];
      end
   endfunction


   virtual protected function void set_packet_fmt_type();
      if ((packet_header_op == READ) || (packet_header_op == WRITE))
      begin
         if (packet_header_op == READ)
         begin
            this.fmt_type = MRD4;
         end
         else
         begin
            this.fmt_type = MWR4;
         end
      end
      else
      begin
         this.packet_header_op = NULL;
         this.fmt_type = ERROR;
      end
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction


   virtual function uint64_t get_addr();
      return this.host_address;
   endfunction


   virtual function uint64_t get_addr_first_be_adjusted();
      return this.get_addr();
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      this.host_address = addr;
      map_fields();
   endfunction


   virtual function uint32_t get_length_bytes();
      return uint32_t'(length);
   endfunction


   virtual function uint32_t get_expected_completion_length_bytes();
      if (packet_header_op == READ)
         return this.get_length_bytes();
      else
         return 0;
   endfunction


   virtual function void set_length_bytes(
      input uint32_t length_bytes
   );
      this.length = length_bytes[23:0];
      map_fields();
   endfunction


   //----------------------------------
   // Data-Mover Packet Format Methods
   //----------------------------------


   virtual function uint64_t get_dm_host_addr();
      return this.host_address;
   endfunction


   virtual function void set_dm_host_addr(
      input uint64_t dm_host_addr
   );
      this.host_address = dm_host_addr;
      map_fields();
   endfunction


   virtual function uint64_t get_dm_local_addr();
      return this.local_address;
   endfunction


   virtual function void set_dm_local_addr(
      input uint64_t dm_local_addr
   );
      this.local_address = dm_local_addr;
      map_fields();
   endfunction


   virtual function bit get_mm_mode();
      return this.mm_mode;
   endfunction


   virtual function void set_mm_mode(
      input bit mm_mode
   );
      this.mm_mode = mm_mode;
      map_fields();
   endfunction


   virtual function uint64_t get_dm_meta_data();
      return this.meta_data;
   endfunction


   virtual function void set_dm_meta_data(
      input uint64_t dm_meta_data
   );
      this.meta_data = dm_meta_data;
      map_fields();
   endfunction


   //------------------------------------------
   // Header printing for PacketHeaderDMMemReq 
   //------------------------------------------
   virtual function void print_header_short();
      $display("   Packet Header Info (Short):");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Host Address......: %H_%H_%H_%H", this.host_address[63:48], this.host_address[47:32], this.host_address[31:16], this.host_address[15:0]);
      if (this.mm_mode)
         $display("      Local Address.....: %H_%H_%H_%H", this.local_address[63:48], this.local_address[47:32], this.local_address[31:16], this.local_address[15:0]);
      else
         $display("      Meta Data.........: %H_%H_%H_%H", this.meta_data[63:48], this.meta_data[47:32], this.meta_data[31:16], this.meta_data[15:0]);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
   endfunction


   virtual function void print_header();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Host Address......: %H_%H_%H_%H", this.host_address[63:48], this.host_address[47:32], this.host_address[31:16], this.host_address[15:0]);
      if (this.mm_mode)
         $display("      Local Address.....: %H_%H_%H_%H", this.local_address[63:48], this.local_address[47:32], this.local_address[31:16], this.local_address[15:0]);
      else
         $display("      Meta Data.........: %H_%H_%H_%H", this.meta_data[63:48], this.meta_data[47:32], this.meta_data[31:16], this.meta_data[15:0]);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      $display("      MM Mode...........: %B", this.mm_mode);
      for (i=0; i<4; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<4*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((4*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


   virtual function void print_header_long();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Host Address......: %H_%H_%H_%H", this.host_address[63:48], this.host_address[47:32], this.host_address[31:16], this.host_address[15:0]);
      if (this.mm_mode)
         $display("      Local Address.....: %H_%H_%H_%H", this.local_address[63:48], this.local_address[47:32], this.local_address[31:16], this.local_address[15:0]);
      else
         $display("      Meta Data.........: %H_%H_%H_%H", this.meta_data[63:48], this.meta_data[47:32], this.meta_data[31:16], this.meta_data[15:0]);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      $display("      MM Mode...........: %B", this.mm_mode);
      $display("      Prefix............: %H", this.prefix);
      $display("      Prefix Type.......: %H", this.prefix_type);
      $display("      Prefix Present....: %B", this.prefix_present);
      $display("      PF................: %H", this.get_pf_num());
      $display("      VF................: %H", this.get_vf_num());
      $display("      VF Active.........: %H", this.get_vf_active());
      $display("      BAR Number........: %H", this.get_bar_num());
      $display("      Slot Number.......: %H", this.get_slot_num());
      for (i=0; i<8; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<8*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((8*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction

endclass : PacketHeaderDMMemReq 


//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeaderDMCompletion
// Class Inheritance: PacketHeaderDMMemReq
//------------------------------------------------------------------------------
// The header class `PacketHeaderDMCompletion` is the completion counterpart 
// for the Data Mover memory request class `PacketHeaderDMMemReq`.  Memory 
// requests made with Data Mover reads (DMRd) will have their data returned 
// to them with completion packets using this header.  Inheritance from the 
// `PacketHeaderDMMemReq` class preserves the overall Data Mover header format 
// and simplifies the code for this derived class.
//
// This packet uses an already-defined TLP FMT/Type value of 8'h4A which 
// corresponds to a PCIe Completion TLP with Data (CplD).  As with the DMRd 
// and DMWr requests, both Power User traffic and Data Mover Completions may 
// coexist on the same AXI-ST bus, requiring a way to differentiate the PU 
// and DM completions from one another during bus transactions.  This 
// differentiation is done in the same manner as the DM Requests using the 
// AXI-ST bus's `tuser_vendor` bits.  Bit `tuser_vendor[0]` signals to the 
// transaction receiver what format the packet header is in:
//
//   - `tuser_vendor[0] = 1'b0` indicates a Power User header (regular PCIe TLP).
//   - `tuser_vendor[0] = 1'b1` indicates a Data Mover header.
//
// The BFM logic and the FIM AXI-ST interface logic must be able to decode 
// this operation in order to properly sort the mixed traffic.  If, for some 
// reason, an AXI-ST interface is not expected to carry mixed traffic, then 
// this bit _can_ be ignored, but decoding one bit should not impose too much 
// of a logic burden and supporting both packet formats would make the AXI-ST 
// interfaces more robust and interchangeable in operation.
//------------------------------------------------------------------------------

class PacketHeaderDMCompletion #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketHeaderDMMemReq#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected cpl_status_t cpl_status;
   protected bit fc; // Final Completion.
   protected bit [23:0] lower_address;
   protected bit reordering_enable;

   // Constructor for PacketHeaderDMCompletion 
   function new(
      input cpl_status_t cpl_status, 
      input uint64_t local_address_or_meta_data,
      input dm_length_t length,
      input bit mm_mode,
      input bit [23:0] lower_address
   );
      super.new(
         .packet_header_op(COMPLETION),
         .host_address({64{1'b0}}),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode)
      );
      this.packet_header_op = COMPLETION;  // Super turns this to NULL.  Must be set correctly to COMPLETION.
      this.cpl_status = cpl_status;
      this.lower_address = lower_address;
      this.reordering_enable = 1'b1;  // For now, Reordering is always enabled per current IP usage.
      this.fc = 1'b1;  // For now, default to one completion per IP reordering setting scenario.
      this.set_packet_fmt_type();
   endfunction

   
   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, 1'b0, tc, 1'b0, attr[2], ln, th, td, ep, attr[1:0], 2'b00, length[11:2]};
      header_dw[1] = {{16{1'b0}}, cpl_status, {13{1'b0}}};
      header_dw[2] = {{16{1'b0}}, {8{1'b0}}, lower_address[7:0]};
      if (reordering_enable)
      begin
         header_dw[3] = {tag, fc, 1'b0, length[13:12], length[1:0], length[23:14], lower_address[13:8]};
      end
      else
      begin
         header_dw[3] = {tag, fc, 1'b0, length[13:12], length[1:0], lower_address[23:14], lower_address[13:8]};
      end
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, mm_mode, this.slot, 4'b0000, this.pfvf.get_vfa(), this.pfvf.get_vf_field(), this.pfvf.get_pf_field()};
      if (mm_mode)
      begin
         header_dw[6] = local_address[63:32];
         header_dw[7] = local_address[31:0];
      end
      else
      begin
         header_dw[6] = meta_data[63:32];
         header_dw[7] = meta_data[31:0];
      end
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      bit local_vfa;
      bit  [2:0] local_pf;
      bit [10:0] local_vf;
      pfvf_struct local_pfvf;
      fmt_type = tlp_fmt_type_t'(header_dw[0][31:24]);
      tc       = header_dw[0][22:20];
      {attr[2],ln, th, td, ep, attr[1:0]}  = header_dw[0][18:12];
      length[11:2] = header_dw[0][9:0];
      cpl_status   = cpl_status_t'(header_dw[1][15:13]);
      lower_address[7:0] = header_dw[2][7:0];
      if (reordering_enable)
      begin
         {tag, fc} = header_dw[3][31:21];
         {length[13:12], length[1:0], length[23:14], lower_address[13:8]} = header_dw[3][19:0];
      end
      else
      begin
         {tag, fc} = header_dw[3][31:21];
         {length[13:12], length[1:0], lower_address[23:14], lower_address[13:8]} = header_dw[3][19:0];
      end
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {mm_mode, slot, bar, local_vfa, local_vf, local_pf} = header_dw[5][24:0];
      local_pfvf.pfn = local_pf;
      local_pfvf.vfn = local_vf;
      local_pfvf.vfa = local_vfa;
      pfvf.set_pfvf_from_struct(local_pfvf);
      if (mm_mode)
      begin
         local_address[63:32] = header_dw[6];
         local_address[31:0]  = header_dw[7];
      end
      else
      begin
         meta_data[63:32] = header_dw[6];
         meta_data[31:0]  = header_dw[7];
      end
   endfunction


   virtual protected function void set_packet_fmt_type();
      this.packet_header_op = COMPLETION;
      this.fmt_type = CPLD;
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction


   virtual function uint64_t get_addr();
      return {'0,this.lower_address};
   endfunction


   virtual function uint64_t get_addr_first_be_adjusted();
      return this.get_addr();
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      this.lower_address = addr[23:0];
      map_fields();
   endfunction


   virtual function bit [23:0] get_dm_lower_address();
      return this.lower_address;
   endfunction


   virtual function cpl_status_t get_cpl_status();
      return this.cpl_status;
   endfunction


   virtual function void set_cpl_status(
      input cpl_status_t cpl_status
   );
      this.cpl_status = cpl_status;
      map_fields();
   endfunction


   virtual function bit get_fc();
      return this.fc;
   endfunction


   virtual function void set_fc(
      input bit fc
   );
      this.fc = fc;
      map_fields();
   endfunction


   //----------------------------------------------
   // Header printing for PacketHeaderDMCompletion 
   //----------------------------------------------
   virtual function void print_header_short();
      $display("   Packet Header Info (Short):");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Completion Status.: %s", this.cpl_status.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Lower Address.....: %H", this.lower_address);
      if (this.mm_mode)
         $display("      Local Address.....: %H_%H_%H_%H", this.local_address[63:48], this.local_address[47:32], this.local_address[31:16], this.local_address[15:0]);
      else
         $display("      Meta Data.........: %H_%H_%H_%H", this.meta_data[63:48], this.meta_data[47:32], this.meta_data[31:16], this.meta_data[15:0]);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
   endfunction


   virtual function void print_header();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Completion Status.: %s", this.cpl_status.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Lower Address.....: %H", this.lower_address);
      if (this.mm_mode)
         $display("      Local Address.....: %H_%H_%H_%H", this.local_address[63:48], this.local_address[47:32], this.local_address[31:16], this.local_address[15:0]);
      else
         $display("      Meta Data.........: %H_%H_%H_%H", this.meta_data[63:48], this.meta_data[47:32], this.meta_data[31:16], this.meta_data[15:0]);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      FC................: %B", this.fc);
      $display("      MM Mode...........: %B", this.mm_mode);
      for (i=0; i<4; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<4*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((4*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


   virtual function void print_header_long();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Completion Status.: %s", this.cpl_status.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Lower Address.....: %H", this.lower_address);
      if (this.mm_mode)
         $display("      Local Address.....: %H_%H_%H_%H", this.local_address[63:48], this.local_address[47:32], this.local_address[31:16], this.local_address[15:0]);
      else
         $display("      Meta Data.........: %H_%H_%H_%H", this.meta_data[63:48], this.meta_data[47:32], this.meta_data[31:16], this.meta_data[15:0]);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      FC................: %B", this.fc);
      $display("      MM Mode...........: %B", this.mm_mode);
      $display("      Prefix............: %H", this.prefix);
      $display("      Prefix Type.......: %H", this.prefix_type);
      $display("      Prefix Present....: %B", this.prefix_present);
      $display("      PF................: %H", this.get_pf_num());
      $display("      VF................: %H", this.get_vf_num());
      $display("      VF Active.........: %H", this.get_vf_active());
      $display("      BAR Number........: %H", this.get_bar_num());
      $display("      Slot Number.......: %H", this.get_slot_num());
      for (i=0; i<8; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<8*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((8*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction

endclass : PacketHeaderDMCompletion 


//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeaderMsg
// Class Inheritance: PacketHeader
//------------------------------------------------------------------------------
// General PCIe Message TLPs are supported by using the class `PacketHeaderMsg`.  
// Messages may be sent in a variety of ways within a PCIe system and this 
// packet format is intended to support them.  This class supports the general 
// message request format, but does not support all of the message fields used 
// in all message types.  Most notably, the header double words #2 and #3 are 
// simply provided as generic 32-bit inputs into the constructor and stored in 
// data members `lower_msg` and `upper_msg`.  There is a get method for each 
// of the fields, `get_lower_msg()` and `get_upper_msg()`, but no set method 
// is provided -- meaning that these fields must be set during construction and 
// not changed.  Message TLPs are posted like memory write requests, but their 
// routing through the PCIe system can be based on address, ID, or an implicit 
// route.  The routing subfield in Byte 3, bits [2:0] of this header 
// communicates which routing method in intended and which specific message 
// format the header takes.
//------------------------------------------------------------------------------

class PacketHeaderMsg #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketHeader#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected data_present_type_t data_present;
   protected msg_route_t msg_route;
   protected bit [15:0]  requester_id;
   protected bit  [7:0]  msg_code;
   protected bit [31:0]  lower_msg;
   protected bit [31:0]  upper_msg;

   // Constructor for PacketHeaderMsg 
   function new(
      input data_present_type_t data_present,
      input msg_route_t         msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [31:0] lower_msg,
      input bit [31:0] upper_msg,
      input bit  [9:0] length_dw
   );
      super.new(
         .packet_format(POWER_USER), 
         .packet_header_op(MSG),
         .length_dw(length_dw)
      );
      this.data_present = data_present;
      this.msg_route = msg_route;
      this.requester_id = requester_id;
      this.msg_code = msg_code;
      this.lower_msg = lower_msg;
      this.upper_msg = upper_msg;
      this.set_packet_fmt_type();
   endfunction

   
   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw};
      header_dw[1] = {requester_id, tag[7:0], msg_code};
      header_dw[2] = lower_msg;
      header_dw[3] = upper_msg;
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, 1'b0, this.slot, this.bar, this.pfvf.get_vfa(), this.pfvf.get_vf_field(), this.pfvf.get_pf_field()};
      header_dw[6] = '0; // Reserved Fields
      header_dw[7] = '0; // Reserved Fields
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      bit local_vfa;
      bit  [2:0] local_pf;
      bit [10:0] local_vf;
      pfvf_struct local_pfvf;
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw} = header_dw[0];
      {requester_id, tag[7:0], msg_code} = header_dw[1];
      fmt = tlp_fmt_t'(fmt_type[7:5]);
      tlp_type = fmt_type[4:0];
      if ((fmt_type == MSG0)  || (fmt_type == MSG1)  || (fmt_type == MSG2)  || (fmt_type == MSG3)  || 
          (fmt_type == MSG4)  || (fmt_type == MSG5)  ||
          (fmt_type == MSGD0) || (fmt_type == MSGD1) || (fmt_type == MSGD2) || (fmt_type == MSGD3) || 
          (fmt_type == MSGD4) || (fmt_type == MSGD5))
      begin
         if ((msg_code == VDM_TYPE0) || (msg_code == VDM_TYPE1))
         begin
            packet_header_op = VDM;
         end
         else
         begin
            packet_header_op = MSG;
         end
      end
      else
      begin
         packet_header_op = NULL;
      end
      if ((msg_code == VDM_TYPE0) || (msg_code == VDM_TYPE1))
      begin
         $display("WARNING: MSG TLP Object created with VDM MSG Code: %H", msg_code);
         $display("   This will work okay, just know that DW2 in the ");
         $display("   Header will be treated as a single 32-bit word.");
         $display("   Get Methods will work okay for either class.   ");
      end
      lower_msg = header_dw[2];
      upper_msg = header_dw[3];
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {slot, bar, local_vfa, local_vf, local_pf} = header_dw[5][23:0];
      local_pfvf.pfn = local_pf;
      local_pfvf.vfn = local_vf;
      local_pfvf.vfa = local_vfa;
      pfvf.set_pfvf_from_struct(local_pfvf);
   endfunction


   virtual protected function void set_packet_fmt_type();
      if (data_present)
      begin
         this.fmt_type = tlp_fmt_type_t'(int'(MSGD0) + int'(msg_route));
      end
      else
      begin
         this.fmt_type = tlp_fmt_type_t'(int'(MSG0) + int'(msg_route));
      end
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction


   virtual function uint64_t get_addr();
      return 64'd0;
   endfunction


   virtual function uint64_t get_addr_first_be_adjusted();
      return this.get_addr();
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      // Empty function to preserve Polymorphism with base class and other
      // derived classes.
   endfunction


   virtual function bit [15:0] get_requester_id();
      return this.requester_id;
   endfunction


   virtual function bit [7:0] get_msg_code();
      return this.msg_code;
   endfunction


   virtual function bit [31:0] get_lower_msg();
      return this.lower_msg;
   endfunction


   virtual function bit [31:0] get_upper_msg();
      return this.upper_msg;
   endfunction


   virtual function bit [15:0] get_pci_target_id();
      return this.lower_msg[31:16];
   endfunction


   virtual function bit [15:0] get_vendor_id();
      return this.lower_msg[15:0];
   endfunction


   virtual function uint32_t get_length_bytes();
      uint32_t total_bytes;
      int i;
      if ((fmt_type == MSGD0) || (fmt_type == MSGD1) || (fmt_type == MSGD2) || (fmt_type == MSGD3) || 
          (fmt_type == MSGD4) || (fmt_type == MSGD5))
      begin
         if (length_dw == '0)
         begin
            total_bytes = 1024 * 4;
         end
         else
         begin
            total_bytes = length_dw * 4;
         end
      end
      else
      begin
         total_bytes = 0;
      end
      return total_bytes;
   endfunction


   virtual function uint32_t get_expected_completion_length_bytes();
      return 0;
   endfunction


   //------------------------------------------
   // Header printing for PacketHeaderMsg 
   //------------------------------------------
   virtual function void print_header_short();
      $display("   Packet Header Info (Short):");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
   endfunction


   virtual function void print_header();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Requester ID......: %H", this.requester_id);
      $display("      Packet Tag........: %H", this.tag);
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      Message Code......: %H", this.msg_code);
      $display("      Lower Message.....: %H", this.lower_msg);
      $display("      Upper Message.....: %H", this.upper_msg);
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      for (i=0; i<4; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<4*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((4*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


   virtual function void print_header_long();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Requester ID......: %H", this.requester_id);
      $display("      Packet Tag........: %H", this.tag);
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
      $display("      Message Code......: %H", this.msg_code);
      $display("      Lower Message.....: %H", this.lower_msg);
      $display("      Upper Message.....: %H", this.upper_msg);
      $display("      TC................: %B", this.tc);
      $display("      AT................: %B", this.at);
      $display("      Attr..............: %B", this.attr);
      $display("      EP................: %B", this.ep);
      $display("      TD................: %B", this.td);
      $display("      TH................: %B", this.th);
      $display("      LN................: %B", this.ln);
      $display("      PH................: %B", this.ph);
      $display("      Prefix............: %H", this.prefix);
      $display("      Prefix Type.......: %H", this.prefix_type);
      $display("      Prefix Present....: %B", this.prefix_present);
      $display("      PF................: %H", this.get_pf_num());
      $display("      VF................: %H", this.get_vf_num());
      $display("      VF Active.........: %H", this.get_vf_active());
      $display("      BAR Number........: %H", this.get_bar_num());
      $display("      Slot Number.......: %H", this.get_slot_num());
      for (i=0; i<8; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<8*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((8*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction

endclass : PacketHeaderMsg


//------------------------------------------------------------------------------
// CLASS DEFINITION
//------------------------------------------------------------------------------
// Class Name.......: PacketHeaderVDM
// Class Inheritance: PacketHeader
//------------------------------------------------------------------------------
// Vendor-Defined Messages in OFS are enabled using the `PacketHeaderVDM` packet
// header class.  Specifically with OFS, the VDM format is used to to implement 
// a Management Component Transport Protocol (MCTP).  MCTP is a protocol devised
// by the Distributed Management Task Force (DMTF) to support communications for
// control and management functions between intelligent hardware blocks.  MCTP 
// establishes a communications message format and message exchange protocols.  
//
// It might seem like a packet header class defining 'Vendor-Defined Messages' 
// or VDMs would naturally be a derived class from `PacketHeaderMsg`, but this 
// is not so.  VDMs are much more precisely defined as opposed to the general 
// PCIe message TLPs that they are best served as a unique class unto 
// themselves, only inheriting from the abstract base class `PacketHeader`.  
// There is a little duplication of data members between `PacketHeaderMsg` 
// and `PacketHeaderVDM` but they rapidly diverge in practical ways such that 
// there is little to no advantage using inheritance between these two message 
// header classes.
//------------------------------------------------------------------------------

class PacketHeaderVDM #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketHeader#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected data_present_type_t data_present;
   protected vdm_msg_route_t msg_route;
   protected bit [15:0] requester_id;
   protected bit  [1:0] pad_length;
   protected bit  [3:0] mctp_vdm_code;
   protected bit  [7:0] msg_code;
   protected bit [15:0] pci_target_id;
   protected bit [15:0] vendor_id;
   protected bit  [3:0] mctp_header_version;
   protected bit  [7:0] destination_endpoint_id;
   protected bit  [7:0] source_endpoint_id;
   protected bit        som;
   protected bit        eom;
   protected bit  [1:0] packet_sequence_number;
   protected bit        tag_owner; // TO bit.
   protected bit  [2:0] msg_tag;


   // Constructor for PacketHeaderVDM 
   function new(
      input data_present_type_t data_present,
      input vdm_msg_route_t     msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [15:0] pci_target_id,
      input bit [15:0] vendor_id,
      input bit  [9:0] length_dw
   );
      super.new(
         .packet_format(POWER_USER), 
         .packet_header_op(VDM),
         .length_dw(length_dw)
      );
      this.data_present = data_present;
      this.msg_route = msg_route;
      this.requester_id = requester_id;
      this.msg_code = msg_code;
      this.pci_target_id = pci_target_id;
      this.vendor_id = vendor_id;
      this.pad_length = 2'd0;
      //this.upper_msg = upper_msg;
      //-------------------------------------------------------------------
      // The following fields are set according to MCTP PCIe VDM Transport
      // Binding Specification.
      //-------------------------------------------------------------------
      this.mctp_vdm_code = 4'b0000;
      this.mctp_header_version = 4'b0001;
      this.destination_endpoint_id = 8'h00;
      this.source_endpoint_id      = 8'h00;
      this.som = 1'b1;
      this.eom = 1'b1;
      this.packet_sequence_number = 2'b00;
      this.tag_owner = 1'b0;
      this.msg_tag = 3'b000;
      //-------------------------------------------------------------------
      this.set_packet_fmt_type();
   endfunction

   
   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw};
      header_dw[1] = {requester_id, 2'b00, pad_length, mctp_vdm_code, msg_code};
      header_dw[2] = {pci_target_id, vendor_id};
      //header_dw[3] = upper_msg;
      header_dw[3] = {4'b0000, mctp_header_version, destination_endpoint_id, source_endpoint_id, som, eom, packet_sequence_number, tag_owner, msg_tag};
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, 1'b0, slot, bar, pfvf.get_vfa(), pfvf.get_vf_field(), pfvf.get_pf_field()};
      header_dw[6] = '0; // Reserved Fields
      header_dw[7] = '0; // Reserved Fields
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      bit local_vfa;
      bit  [2:0] local_pf;
      bit [10:0] local_vf;
      pfvf_struct local_pfvf;
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw} = header_dw[0];
      //{requester_id, tag[7:0], msg_code} = header_dw[1];
      requester_id = header_dw[1][31:16];
      {pad_length, mctp_vdm_code, msg_code} = header_dw[1][13:0];
      fmt = tlp_fmt_t'(fmt_type[7:5]);
      tlp_type = fmt_type[4:0];
      if ((fmt_type == MSG0)  || (fmt_type == MSG1)  || (fmt_type == MSG2)  || (fmt_type == MSG3)  || 
          (fmt_type == MSG4)  || (fmt_type == MSG5)  ||
          (fmt_type == MSGD0) || (fmt_type == MSGD1) || (fmt_type == MSGD2) || (fmt_type == MSGD3) || 
          (fmt_type == MSGD4) || (fmt_type == MSGD5))
      begin
         if ((msg_code == VDM_TYPE0) || (msg_code == VDM_TYPE1))
         begin
            packet_header_op = VDM;
         end
         else
         begin
            packet_header_op = MSG;
         end
      end
      else
      begin
         packet_header_op = NULL;
      end
      if ((msg_code != VDM_TYPE0) && (msg_code != VDM_TYPE1))
      begin
         $display("WARNING: VDM TLP Object created with MSG Code: %H", msg_code);
         $display("   This will work okay, just know that DW2 in the ");
         $display("   Header will be treated as two 16-bit fields    ");
         $display("   instead of a single 32-bit field.              ");
         $display("   Get Methods will work okay for either class.   ");
      end
      {pci_target_id, vendor_id} = header_dw[2];
      //upper_msg = header_dw[3];
      {mctp_header_version, destination_endpoint_id, source_endpoint_id, som, eom, packet_sequence_number, tag_owner, msg_tag} = header_dw[3][27:0];
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {slot, bar, local_vfa, local_vf, local_pf} = header_dw[5][23:0];
      local_pfvf.pfn = local_pf;
      local_pfvf.vfn = local_vf;
      local_pfvf.vfa = local_vfa;
      pfvf.set_pfvf_from_struct(local_pfvf);
   endfunction


   virtual protected function void set_packet_fmt_type();
      if (data_present)
      begin
         this.fmt_type = tlp_fmt_type_t'(int'(MSGD0) + int'(msg_route));
      end
      else
      begin
         this.fmt_type = tlp_fmt_type_t'(int'(MSG0) + int'(msg_route));
      end
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction


   virtual function uint64_t get_addr();
      return 64'd0;
   endfunction


   virtual function uint64_t get_addr_first_be_adjusted();
      return this.get_addr();
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      // Empty function to preserve Polymorphism with base class and other
      // derived classes.
   endfunction


   virtual function bit [1:0] get_pad_length();
      return this.pad_length;
   endfunction


   virtual function void set_pad_length(input bit [1:0] pad_length);
      this.pad_length = pad_length;
      map_fields();
   endfunction


   virtual function bit [15:0] get_requester_id();
      return this.requester_id;
   endfunction


   virtual function bit [3:0] get_mctp_vdm_code();
      return this.mctp_vdm_code;
   endfunction


   virtual function void set_mctp_vdm_code(input bit [3:0] vdm_code);
      this.mctp_vdm_code = vdm_code;
      map_fields();
   endfunction


   virtual function bit [3:0] get_mctp_header_version();
      return this.mctp_header_version;
   endfunction


   virtual function void set_mctp_header_version(input bit [3:0] header_version);
      this.mctp_header_version = header_version;
      map_fields();
   endfunction


   virtual function bit [7:0] get_mctp_destination_endpoint_id();
      return this.destination_endpoint_id;
   endfunction


   virtual function void set_mctp_destination_endpoint_id(bit [7:0] destination_endpoint_id);
      this.destination_endpoint_id = destination_endpoint_id;
   endfunction


   virtual function bit [7:0] get_mctp_source_endpoint_id();
      return this.source_endpoint_id;
   endfunction


   virtual function void set_mctp_source_endpoint_id(bit [7:0] source_endpoint_id);
      this.source_endpoint_id = source_endpoint_id;
   endfunction


   virtual function bit get_mctp_som();
      return this.som;
   endfunction


   virtual function void set_mctp_som(input bit som);
      this.som = som;
      map_fields();
   endfunction


   virtual function bit get_mctp_eom();
      return this.eom;
   endfunction


   virtual function void set_mctp_eom(input bit eom);
      this.eom = eom;
      map_fields();
   endfunction


   virtual function bit [1:0] get_mctp_packet_sequence_number();
      return this.packet_sequence_number;
   endfunction


   virtual function void set_mctp_packet_sequence_number(input bit [1:0] psn);
      this.packet_sequence_number = psn;
      map_fields();
   endfunction


   virtual function bit get_mctp_tag_owner();
      return this.tag_owner;
   endfunction


   virtual function void set_mctp_tag_owner(input bit tag_owner);
      this.tag_owner = tag_owner ;
      map_fields();
   endfunction


   virtual function bit [2:0] get_mctp_message_tag();
      return this.msg_tag;
   endfunction


   virtual function void set_mctp_message_tag(input bit [2:0] message_tag);
      this.msg_tag = message_tag;
      map_fields();
   endfunction


   virtual function bit [7:0] get_msg_code();
      return this.msg_code;
   endfunction


   virtual function bit [31:0] get_lower_msg();
      return {pci_target_id, vendor_id};
   endfunction


   virtual function bit [31:0] get_upper_msg();
      return {4'b0000, mctp_header_version, destination_endpoint_id, source_endpoint_id, som, eom, packet_sequence_number, tag_owner, msg_tag};
   endfunction


   virtual function bit [15:0] get_pci_target_id();
      return this.pci_target_id;
   endfunction


   virtual function bit [15:0] get_vendor_id();
      return this.vendor_id;
   endfunction


   virtual function uint32_t get_length_bytes();
      uint32_t total_bytes;
      int i;
      if ((fmt_type == MSGD0) || (fmt_type == MSGD1) || (fmt_type == MSGD2) || (fmt_type == MSGD3) || 
          (fmt_type == MSGD4) || (fmt_type == MSGD5))
      begin
         if (length_dw == '0)
         begin
            total_bytes = 1024 * 4;
         end
         else
         begin
            total_bytes = length_dw * 4;
         end
      end
      else
      begin
         total_bytes = 0;
      end
      return total_bytes;
   endfunction


   virtual function uint32_t get_expected_completion_length_bytes();
      return 0;
   endfunction


   //------------------------------------------
   // Header printing for PacketHeaderVDM 
   //------------------------------------------
   virtual function void print_header_short();
      $display("   Packet Header Info (Short):");
      $display("      Packet Format.....: %s", this.packet_format.name());
      $display("      Packet Operation..: %s", this.packet_header_op.name());
      $display("      Header Format.....: %s", this.fmt.name());
      $display("      Header Format/Type: %s", this.fmt_type.name());
      $display("      Packet Tag........: %H", this.tag);
      $display("      Length DW.........: %0d", this.length_dw);
      $display("      Length Bytes......: %0d", this.get_length_bytes());
   endfunction


   virtual function void print_header();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format...............: %s", this.packet_format.name());
      $display("      Packet Operation............: %s", this.packet_header_op.name());
      $display("      Header Format...............: %s", this.fmt.name());
      $display("      Header Format/Type..........: %s", this.fmt_type.name());
      $display("      Requester ID................: %H", this.requester_id);
      $display("      Packet Tag..................: %H", this.tag);
      $display("      Length DW...................: %0d", this.length_dw);
      $display("      Length Bytes................: %0d", this.get_length_bytes());
      $display("      Pad Length..................: %0d", this.pad_length);
      $display("      Message Code................: %H", this.msg_code);
      $display("      PCI Target ID...............: %H", this.pci_target_id);
      $display("      Vendor ID...................: %H", this.vendor_id);
      //$display("      Upper Message.....: %H", this.upper_msg);
      $display("      MCTP Header Version.........: %H", this.mctp_header_version);
      $display("      MCTP Destination Endpoint ID: %H", this.destination_endpoint_id);
      $display("      MCTP Source      Endpoint ID: %H", this.source_endpoint_id);
      $display("      MCTP Start of Message.......: %B", this.som);
      $display("      MCTP End   of Message.......: %B", this.eom);
      $display("      MCTP Packet Sequence Number.: %H", this.packet_sequence_number);
      $display("      MCTP Tag Owner..............: %B", this.tag_owner);
      $display("      MCTP Message Tag............: %H", this.msg_tag);
      $display("      TC..........................: %B", this.tc);
      $display("      AT..........................: %B", this.at);
      $display("      Attr........................: %B", this.attr);
      $display("      EP..........................: %B", this.ep);
      $display("      TD..........................: %B", this.td);
      $display("      TH..........................: %B", this.th);
      $display("      LN..........................: %B", this.ln);
      $display("      PH..........................: %B", this.ph);
      for (i=0; i<4; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<4*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((4*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction


   virtual function void print_header_long();
      int i;
      $display("   Packet Header Info:");
      $display("      Packet Format...............: %s", this.packet_format.name());
      $display("      Packet Operation............: %s", this.packet_header_op.name());
      $display("      Header Format...............: %s", this.fmt.name());
      $display("      Header Format/Type..........: %s", this.fmt_type.name());
      $display("      Requester ID................: %H", this.requester_id);
      $display("      Packet Tag..................: %H", this.tag);
      $display("      Length DW...................: %0d", this.length_dw);
      $display("      Length Bytes................: %0d", this.get_length_bytes());
      $display("      Pad Length..................: %0d", this.pad_length);
      $display("      Message Code................: %H", this.msg_code);
      $display("      PCI Target ID...............: %H", this.pci_target_id);
      $display("      Vendor ID...................: %H", this.vendor_id);
      //$display("      Upper Message.....: %H", this.upper_msg);
      $display("      MCTP Header Version.........: %H", this.mctp_header_version);
      $display("      MCTP Destination Endpoint ID: %H", this.destination_endpoint_id);
      $display("      MCTP Source      Endpoint ID: %H", this.source_endpoint_id);
      $display("      MCTP Start of Message.......: %B", this.som);
      $display("      MCTP End   of Message.......: %B", this.eom);
      $display("      MCTP Packet Sequence Number.: %H", this.packet_sequence_number);
      $display("      MCTP Tag Owner..............: %B", this.tag_owner);
      $display("      MCTP Message Tag............: %H", this.msg_tag);
      $display("      TC..........................: %B", this.tc);
      $display("      AT..........................: %B", this.at);
      $display("      Attr........................: %B", this.attr);
      $display("      EP..........................: %B", this.ep);
      $display("      TD..........................: %B", this.td);
      $display("      TH..........................: %B", this.th);
      $display("      LN..........................: %B", this.ln);
      $display("      PH..........................: %B", this.ph);
      $display("      Prefix......................: %H", this.prefix);
      $display("      Prefix Type.................: %H", this.prefix_type);
      $display("      Prefix Present..............: %B", this.prefix_present);
      $display("      PF..........................: %H", this.get_pf_num());
      $display("      VF..........................: %H", this.get_vf_num());
      $display("      VF Active...................: %H", this.get_vf_active());
      $display("      BAR Number..................: %H", this.get_bar_num());
      $display("      Slot Number.................: %H", this.get_slot_num());
      for (i=0; i<8; i=i+1)
      begin
         $display("      Header DW %0d.......: %H_%H", i, this.header_dw[i][31:16], this.header_dw[i][15:0]);
      end
      $write("      Header Bytes......: ");
      for (i=0; i<8*4; i=i+1)
      begin
         $write("%H ", this.header_bytes[i]);
         if ((i + 1) % 4 == 0)
         begin
            $display(""); // Start New Line
            if (i != ((8*4)-1))
               $write("                          ");  // Display leading spaces.
         end
      end
   endfunction

endclass : PacketHeaderVDM


virtual class Packet #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);  // Abstract Base Class

   // Data Members
   protected PacketHeader#(pf_type, vf_type, pf_list, vf_list) packet_header;
   //protected bit [7:0] payload [];  // Data Payload Array
   protected byte_t payload [];  // Data Payload Array
   protected bit [7:0] header_bytes[]; // Header Data in bytes, little endian.
   protected int    index_get;  // Index for accessing data
   protected realtime  creation_time;
   protected realtime  send_time;
   protected realtime  arrival_time;

   // Constructor for Packet
   function new(
      input packet_format_t packet_format,
      input packet_header_op_t packet_header_op,
      input bit [9:0] length_dw
   );
      //------------------------------------------------------------------- 
      // The class for headers cannot be used here because
      // a class cannot contain a constructor for an abstract base class,
      // even if the class that contains it is also an abstract base class!
      //------------------------------------------------------------------- 
      //packet_header = new(
      //   .packet_format(packet_format),
      //   .packet_header_op(packet_header_op),
      //   .length_dw(length_dw)
      //);
      this.index_get = 0;
      this.payload.delete();  // Clear payload queue.
      this.header_bytes = new[32];  // Create storage for header bytes.
      this.creation_time = $realtime;
      this.send_time = this.creation_time;  // Set to creation time unless updated later.
   endfunction

   //-----------------------------------
   // Class Methods -- Packet Top-Level
   //-----------------------------------
   //protected virtual function void get_header_bytes(
   virtual function void get_header_bytes(
      ref bit [7:0] header_buf []
   );
      this.packet_header.get_header_bytes(header_buf);
   endfunction


   protected virtual function void get_header_words(
      ref bit [31:0] header_buf []
   );
      this.packet_header.get_header_words(header_buf);
   endfunction


   //protected virtual function void set_header_bytes(
   virtual function void set_header_bytes(
      const ref bit [7:0] header_buf[]
   );
      this.packet_header.set_header_bytes(header_buf);
   endfunction


   virtual function int get_size_of_packet_data_and_header();
      return (this.payload.size() + header_bytes.size());  // Payload size plus header size (32).
   endfunction


   virtual function void get_data(
      ref byte_t get_data_buf[]
   );
      int i, j;
      this.get_header_bytes(this.header_bytes);
      for (i = 0; i < header_bytes.size(); i++)
      begin
         get_data_buf[i] = byte_t'(header_bytes[i]);
      end
      for (j = 0; j < payload.size(); j++, i++)
      begin
         get_data_buf[i] = payload[j];
      end
      index_get = 0;
   endfunction


   virtual function void get_payload(
      ref byte_t payload_data_buf[]
   );
      int i;
      for (i = 0; i < payload.size(); i++)
      begin
         payload_data_buf[i] = payload[i];
      end
   endfunction


   virtual function int get_payload_size();
      return this.payload.size();
   endfunction


   virtual function byte_t get_next_data_byte();
      byte_t get_byte;
      this.get_header_bytes(this.header_bytes);
      if (index_get < this.get_size_of_packet_data_and_header())
      begin
         if (index_get < header_bytes.size())
         begin
            get_byte = header_bytes[index_get];
            index_get++;
         end
         else
         begin
            get_byte = payload[index_get - header_bytes.size()];
            index_get++;
            if ( !(index_get < this.get_size_of_packet_data_and_header()) )
            begin
               index_get = 0;
            end
         end
      end
      else
      begin
         index_get = 0;
         get_byte = 8'hFF;
      end
      return get_byte;
   endfunction


   virtual function void reset_get_index();
      this.index_get = 0;
   endfunction


   virtual function void set_data(
      //const ref bit [7:0] set_data_buf[]
      const ref byte_t set_data_buf[]
   );
      payload = new[set_data_buf.size()];
      for (int i = 0; i < set_data_buf.size(); i++)
      begin
         payload[i] = set_data_buf[i];
      end
   endfunction


   virtual function void set_next_data_byte(
      input byte_t data_byte
   );
      payload = new[payload.size() + 1] (payload);
      payload[payload.size() - 1] = data_byte;
   endfunction


   virtual function void clear_data_payload();
      payload.delete();
   endfunction


   //---------------------------------------------------------
   // Class Methods -- Packet Header Access via Encapsulation
   //---------------------------------------------------------
   virtual function void set_pf_vf(pfvf_struct setting);
      this.packet_header.set_pf_vf(setting);
   endfunction


   virtual function void revert_to_last_pfvf_setting();
      this.packet_header.revert_to_last_pfvf_setting();
   endfunction


   virtual function pfvf_struct get_pf_vf();
      return this.packet_header.get_pf_vf();
   endfunction


   virtual function bit [2:0] get_pf_num();
      return this.packet_header.get_pf_num();
   endfunction


   virtual function bit [10:0] get_vf_num();
      return this.packet_header.get_vf_num();
   endfunction


   virtual function bit get_vf_active();
      return this.packet_header.get_vf_active();
   endfunction


   virtual function void set_bar_num(bit[3:0] bar);
      this.packet_header.set_bar_num(bar);
   endfunction
  

   virtual function void set_slot_num(bit[4:0] slot);
      this.packet_header.set_slot_num(slot);
   endfunction


   virtual function bit [3:0] get_bar_num();
      return this.packet_header.get_bar_num();
   endfunction


   virtual function bit [4:0] get_slot_num();
      return this.packet_header.get_slot_num();
   endfunction


   virtual function void set_request_delay(input uint32_t delay);
      this.packet_header.set_request_delay(delay);
   endfunction


   virtual function uint32_t get_request_delay();
      return this.packet_header.get_request_delay();
   endfunction


   virtual function void set_completion_delay(input uint32_t delay);
      this.packet_header.set_completion_delay(delay);
   endfunction


   virtual function uint32_t get_completion_delay();
      return this.packet_header.get_completion_delay();
   endfunction


   virtual function void set_gap(input uint32_t gap);
      this.packet_header.set_gap(gap);
   endfunction


   virtual function uint32_t get_gap();
      return this.packet_header.get_gap();
   endfunction
      

   virtual function packet_format_t get_packet_format();
      return this.packet_header.get_packet_format;
   endfunction


   virtual function bit packet_is_power_user_format();
      return this.packet_header.packet_is_power_user_format();
   endfunction


   virtual function bit packet_is_data_mover_format();
      return this.packet_header.packet_is_data_mover_format();
   endfunction


   virtual function packet_header_op_t get_packet_op();
      return this.packet_header.get_packet_header_op();
   endfunction


   virtual function packet_header_atomic_op_t get_packet_atomic_op();
      return this.packet_header.get_packet_header_atomic_op();
   endfunction


   virtual function tlp_fmt_type_t get_fmt_type();
      return this.packet_header.get_fmt_type();
   endfunction


   virtual function tlp_fmt_t get_fmt();
      return this.packet_header.get_fmt();
   endfunction


   virtual function bit [4:0] get_tlp_type();
      return this.packet_header.get_tlp_type();
   endfunction


   virtual function data_present_type_t get_cpl_data_type();
      return this.packet_header.get_cpl_data_type();
   endfunction


   virtual function bit [3:0] get_first_dw_be();
      return this.packet_header.get_first_dw_be();
   endfunction


   virtual function void set_first_dw_be(input bit [3:0] first_dw_be);
      this.packet_header.set_first_dw_be(first_dw_be);
   endfunction


   virtual function bit [3:0] get_last_dw_be();
      return this.packet_header.get_last_dw_be();
   endfunction


   virtual function void set_last_dw_be(input bit [3:0] last_dw_be);
      this.packet_header.set_last_dw_be(last_dw_be);
   endfunction


   virtual function bit [9:0] get_length_dw();
      return this.packet_header.get_length_dw();
   endfunction


   virtual function void set_length_dw(input bit [9:0] length_dw);
      this.packet_header.set_length_dw(length_dw);
   endfunction


   virtual function packet_tag_t get_tag();
      return this.packet_header.get_tag();
   endfunction


   virtual function void set_tag(input packet_tag_t tag);
      this.packet_header.set_tag(tag);
   endfunction


   virtual function bit [2:0] get_tc();
      return this.packet_header.get_tc();
   endfunction


   virtual function void set_tc(input bit [2:0] tc);
      this.packet_header.set_tc(tc);
   endfunction


   virtual function bit [1:0] get_at();
      return this.packet_header.get_at();
   endfunction


   virtual function void set_at(input bit [1:0] at);
      this.packet_header.set_at(at);
   endfunction


   virtual function bit [2:0] get_attr();
      return this.packet_header.get_attr();
   endfunction


   virtual function void set_attr(input bit [2:0] attr);
      this.packet_header.set_attr(attr);
   endfunction


   virtual function bit get_ep();
      return this.packet_header.get_ep();
   endfunction


   virtual function void set_ep(input bit ep);
      this.packet_header.set_ep(ep);
   endfunction


   virtual function bit get_td();
      return this.packet_header.get_td();
   endfunction


   virtual function void set_td(input bit td);
      this.packet_header.set_td(td);
   endfunction


   virtual function bit get_th();
      return this.packet_header.get_th();
   endfunction


   virtual function void set_th(input bit th);
      this.packet_header.set_th(th);
   endfunction


   virtual function bit get_ln();
      return this.packet_header.get_ln();
   endfunction


   virtual function void set_ln(input bit ln);
      this.packet_header.set_ln(ln);
   endfunction


   virtual function bit [1:0] get_ph();
      return this.packet_header.get_ph();
   endfunction


   virtual function void set_ph(
      input bit [1:0] ph
   );
      this.packet_header.set_ph(ph);
   endfunction


   virtual function bit [23:0] get_prefix();
      return this.packet_header.get_prefix();
   endfunction


   virtual function void set_prefix(input bit [23:0] prefix);
      this.packet_header.set_prefix(prefix);
   endfunction


   virtual function bit [4:0] get_prefix_type();
      return this.packet_header.get_prefix_type();
   endfunction


   virtual function void set_prefix_type(input bit [4:0] prefix_type);
      this.packet_header.set_prefix_type(prefix_type);
   endfunction


   virtual function bit get_prefix_present();
      return this.packet_header.get_prefix_present();
   endfunction


   virtual function void set_prefix_present(input bit prefix_present);
      this.packet_header.set_prefix_present(prefix_present);
   endfunction

   //--------------------------------------------------------------------------
   // Methods Interfacing to PacketHeader Base Class Abstract and Null Methods
   //--------------------------------------------------------------------------
   
   //-------------------------------------------------------------------------
   // Address methods work with a 64-bit value or the lower 32-bit portion of
   // the address argument depending on 3DW or 4DW header with value
   // passed as a 64-bit value.
   virtual function uint64_t get_addr();
      return this.packet_header.get_addr();
   endfunction


   virtual function uint64_t get_addr_first_be_adjusted();
      return this.packet_header.get_addr_first_be_adjusted();
   endfunction


   virtual function void set_addr(input uint64_t addr);
      this.packet_header.set_addr(addr);
   endfunction

   //-------------------------------------------------------------------------
   // VDM MCTP Message and related Methods
   //-------------------------------------------------------------------------
   // Get method for TLP Requester ID
   //-------------------------------------------------------------------------
   virtual function bit [15:0] get_requester_id();
      return this.packet_header.get_requester_id();
   endfunction


   virtual function bit [31:0] get_lower_msg();
      return this.packet_header.get_lower_msg();
   endfunction


   virtual function bit [31:0] get_upper_msg();
      return this.packet_header.get_upper_msg();
   endfunction


   virtual function bit [15:0] get_pci_target_id();
      return this.packet_header.get_pci_target_id();
   endfunction


   virtual function bit [15:0] get_vendor_id();
      return this.packet_header.get_vendor_id();
   endfunction


   virtual function bit [7:0] get_msg_code();
      return this.packet_header.get_msg_code();
   endfunction


   virtual function bit [1:0] get_pad_length();
      return this.packet_header.get_pad_length();
   endfunction


   virtual function void set_pad_length(input bit [1:0] pad_length);
      this.packet_header.set_pad_length(pad_length);
   endfunction


   virtual function bit [3:0] get_mctp_vdm_code();
      return this.packet_header.get_mctp_vdm_code();
   endfunction


   virtual function void set_mctp_vdm_code(input bit [3:0] vdm_code);
      this.packet_header.set_mctp_vdm_code(vdm_code);
   endfunction


   virtual function bit [3:0] get_mctp_header_version();
      return this.packet_header.get_mctp_header_version();
   endfunction


   virtual function void set_mctp_header_version(input bit [3:0] header_version);
      this.packet_header.set_mctp_header_version(header_version);
   endfunction


   virtual function bit [7:0] get_mctp_destination_endpoint_id();
      return this.packet_header.get_mctp_destination_endpoint_id();
   endfunction


   virtual function void set_mctp_destination_endpoint_id(bit [7:0] destination_endpoint_id);
      this.packet_header.set_mctp_destination_endpoint_id(destination_endpoint_id);
   endfunction


   virtual function bit [7:0] get_mctp_source_endpoint_id();
      return this.packet_header.get_mctp_source_endpoint_id();
   endfunction


   virtual function void set_mctp_source_endpoint_id(bit [7:0] source_endpoint_id);
      this.packet_header.set_mctp_source_endpoint_id(source_endpoint_id);
   endfunction


   virtual function bit get_mctp_som();
      return this.packet_header.get_mctp_som();
   endfunction


   virtual function void set_mctp_som(input bit som);
      this.packet_header.set_mctp_som(som);
   endfunction


   virtual function bit get_mctp_eom();
      return this.packet_header.get_mctp_eom();
   endfunction


   virtual function void set_mctp_eom(input bit eom);
      this.packet_header.set_mctp_eom(eom);
   endfunction


   virtual function bit [1:0] get_mctp_packet_sequence_number();
      return this.packet_header.get_mctp_packet_sequence_number();
   endfunction


   virtual function void set_mctp_packet_sequence_number(input bit [1:0] psn);
      this.packet_header.set_mctp_packet_sequence_number(psn);
   endfunction


   virtual function bit get_mctp_tag_owner();
      return this.packet_header.get_mctp_tag_owner();
   endfunction


   virtual function void set_mctp_tag_owner(input bit tag_owner);
      this.packet_header.set_mctp_tag_owner(tag_owner);
   endfunction


   virtual function bit [2:0] get_mctp_message_tag();
      return this.packet_header.get_mctp_message_tag();
   endfunction


   virtual function void set_mctp_message_tag(input bit [2:0] message_tag);
      this.packet_header.set_mctp_message_tag(message_tag);
   endfunction


   //---------------------------------------------------------------------------------------
   // Byte-length of payload for Power User Mode: 1 - 2^12 (4MB) or Data Mode: 2^24 or 16MB
   virtual function uint32_t get_length_bytes();
      return this.packet_header.get_length_bytes();
   endfunction


   virtual function uint32_t get_expected_completion_length_bytes();
      return this.packet_header.get_expected_completion_length_bytes();
   endfunction

   
   virtual function void set_length_bytes(
      input uint32_t length_bytes
   );
      this.packet_header.set_length_bytes(length_bytes);
   endfunction

   //-------------------------------------------------------------------------
   // Host and Local methods for Data-Mover Headers
   virtual function uint64_t get_dm_host_addr();
      return this.packet_header.get_dm_host_addr();
   endfunction


   virtual function void set_dm_host_addr(
      input uint64_t dm_host_addr
   );
      this.packet_header.set_dm_host_addr(dm_host_addr);
   endfunction


   virtual function uint64_t get_dm_local_addr();
      return this.packet_header.get_dm_local_addr();
   endfunction


   virtual function void set_dm_local_addr(
      input uint64_t dm_local_addr
   );
      this.packet_header.set_dm_local_addr(dm_local_addr);
   endfunction


   //-------------------------------------------------------------------------
   // Data-Mover methods for mm_mode
   virtual function bit get_mm_mode();
      return this.packet_header.get_mm_mode();
   endfunction


   virtual function void set_mm_mode(
      input bit mm_mode
   );
      this.packet_header.set_mm_mode(mm_mode);
   endfunction


   //-------------------------------------------------------------------------
   // Meta-Data field methods for Data-Mover Headers
   virtual function uint64_t get_dm_meta_data();
      return this.packet_header.get_dm_meta_data();
   endfunction


   virtual function void set_dm_meta_data(
      input uint64_t dm_meta_data
   );
      this.packet_header.set_dm_meta_data(dm_meta_data);
   endfunction


   //-------------------------------------------------------------------------
   // Cpl Packet Header methods
   virtual function bit [15:0] get_completer_id();
      return this.packet_header.get_completer_id();
   endfunction


   virtual function bit [11:0] get_byte_count();
      return this.packet_header.get_byte_count();
   endfunction


   virtual function bit [6:0] get_lower_address();
      return this.packet_header.get_lower_address();
   endfunction


   virtual function bit [23:0] get_dm_lower_address();
      return this.packet_header.get_dm_lower_address();
   endfunction


   virtual function cpl_status_t get_cpl_status();
      return this.packet_header.get_cpl_status();
   endfunction


   virtual function void set_cpl_status(
      input cpl_status_t cpl_status
   );
      this.packet_header.set_cpl_status(cpl_status);
   endfunction


   virtual function bit get_bcm();
      return this.packet_header.get_bcm();
   endfunction


   virtual function void set_bcm(
      input bit bcm
   );
      this.packet_header.set_bcm(bcm);
   endfunction


   virtual function bit get_fc();
      return this.packet_header.get_fc();
   endfunction


   virtual function void set_fc(
      input bit fc
   );
      this.packet_header.set_fc(fc);
   endfunction


   virtual function realtime get_creation_time();
      return this.creation_time;
   endfunction


   virtual function void set_send_time(
      input realtime send_time_in
   );
      this.send_time = send_time_in;
   endfunction


   virtual function realtime get_send_time();
      return this.send_time;
   endfunction


   virtual function void set_arrival_time(
      input realtime arrival_time_in
   );
      this.arrival_time = arrival_time_in;
   endfunction


   virtual function realtime get_arrival_time();
      return this.arrival_time;
   endfunction


   virtual function bit packets_equal(
      input Packet#(pf_type, vf_type, pf_list, vf_list) p2
   );
      int i; 
      bit match = 1'b1;
      int p1_payload_size;
      int p2_payload_size;
      bit [31:0] p1_header_words[];
      bit [31:0] p2_header_words[];
      byte_t p1_data_bytes[];
      byte_t p2_data_bytes[];
      p1_header_words = new[8];
      p2_header_words = new[8];
      this.get_header_words(p1_header_words);
      p2.get_header_words(p2_header_words);
      p1_payload_size = this.get_payload_size();
      p2_payload_size = p2.get_payload_size();
      p1_data_bytes = new[p1_payload_size];
      p2_data_bytes = new[p2_payload_size];
      this.get_payload(p1_data_bytes);
      p2.get_payload(p2_data_bytes);
      for (i = 0; i < 8; i++)
      begin
         if ((i != 5) && (i != 6))  // Skip these words as they do not have packet-oriented information we are interested in.
         begin
            if (p1_header_words[i] != p2_header_words[i])
            begin
               match = 1'b0;
               $display("ERROR: Header word %0d had an error: p1:%H  p2:%H  diff:%H", i, p1_header_words[i], p2_header_words[i], (p1_header_words[i] ^ p2_header_words[i]));
            end
         end
      end
      if (p1_payload_size != p2_payload_size)
      begin
         match = 1'b0;
         $display("ERROR: Payload size differs between the two packets: p1:%0d bytes p2:%0d bytes.", p1_payload_size, p1_payload_size);
      end
      else
      begin
         for (i = 0; i < p1_payload_size; i++)
         begin
            if (p1_data_bytes[i] !== p2_data_bytes[i])
            begin
               match = 1'b0;
               $display("ERROR: Payload byte %0d had an error: p1:%H  p2:%H  diff:%H", i, p1_data_bytes[i], p2_data_bytes[i], (p1_data_bytes[i] ^ p2_data_bytes[i]));
            end
         end
      end
      return match;
   endfunction


   // Print out packet info.
   pure virtual function void print_packet_short();
   pure virtual function void print_packet();
   pure virtual function void print_packet_long();

endclass : Packet


class PacketUnknown #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends Packet #(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected PacketHeaderUnknown#(pf_type, vf_type, pf_list, vf_list) packet_header_unknown;

   // Constructor for PacketUnknown 
   function new(
      input packet_format_t packet_format
   );
      super.new(
         .packet_format(packet_format),
         .packet_header_op(UNKNOWN),
         .length_dw(10'd0)
      );
      packet_header_unknown = new(
         .packet_format(packet_format)
      );
      this.packet_header = packet_header_unknown; // Use Polymorphism to map header to subclass.
   endfunction

   // Class Methods
   virtual function void print_packet_short();
      $display("");
      $display("Packet Information (short):");
      this.packet_header.print_header_short();
      $display("   Packet Payload: %0d Bytes", payload.size());
      $display("");
   endfunction


   virtual function void print_packet();
      $display("");
      $display("Packet Information:");
      this.packet_header.print_header();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction


   virtual function void print_packet_long();
      $display("");
      $display("Packet Information (long):");
      this.packet_header.print_header_long();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction
   
endclass : PacketUnknown


class PacketPUMemReq #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends Packet #(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected PacketHeaderPUMemReq#(pf_type, vf_type, pf_list, vf_list) packet_header_pu_mem_req;

   // Constructor for PacketPUMemReq 
   function new(
      input packet_header_op_t packet_header_op,
      input bit [15:0] requester_id,
      input uint64_t   address,
      input bit  [9:0] length_dw,
      input bit  [3:0] first_dw_be,
      input bit  [3:0] last_dw_be
   );
      super.new(
         .packet_format(POWER_USER),
         .packet_header_op(packet_header_op),
         .length_dw(length_dw)
      );
      packet_header_pu_mem_req = new(
         .packet_header_op(packet_header_op),
         .requester_id(requester_id),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(first_dw_be),
         .last_dw_be(last_dw_be)
      );
      this.packet_header = packet_header_pu_mem_req; // Use Polymorphism to map header to subclass.
   endfunction


   // Class Methods
   virtual function void print_packet_short();
      $display("");
      $display("Packet Information (short):");
      this.packet_header.print_header_short();
      $display("   Packet Payload: %0d Bytes", payload.size());
      $display("");
   endfunction


   virtual function void print_packet();
      $display("");
      $display("Packet Information:");
      this.packet_header.print_header();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction


   virtual function void print_packet_long();
      $display("");
      $display("Packet Information (long):");
      this.packet_header.print_header_long();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction

endclass : PacketPUMemReq 


class PacketPUAtomic #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketPUMemReq #(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected PacketHeaderPUAtomic#(pf_type, vf_type, pf_list, vf_list) packet_header_pu_atomic;

   // Constructor for PacketPUAtomic 
   function new(
      input packet_header_atomic_op_t packet_header_atomic_op,
      input bit [15:0] requester_id,
      input uint64_t   address,
      input bit  [9:0] length_dw
   );
      super.new(
         .packet_header_op(ATOMIC),
         .requester_id(requester_id),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(4'b1111),
         .last_dw_be(4'b1111)
      );
      packet_header_pu_atomic = new(
         .packet_header_atomic_op(packet_header_atomic_op),
         .requester_id(requester_id),
         .address(address),
         .length_dw(length_dw)
      );
      this.packet_header = packet_header_pu_atomic;
   endfunction

endclass : PacketPUAtomic 


class PacketPUCompletion #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketPUMemReq #(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected PacketHeaderPUCompletion#(pf_type, vf_type, pf_list, vf_list) packet_header_pu_completion;

   // Constructor for PacketPUCompletion 
   function new(
      input data_present_type_t cpl_data_type,
      input bit [15:0] requester_id,
      input bit [15:0] completer_id,
      input cpl_status_t cpl_status,
      input bit [11:0] byte_count,
      input bit  [6:0] lower_address,
      input packet_tag_t tag
   );
      super.new(
         .packet_header_op(COMPLETION),
         .requester_id(requester_id),
         .address({64{1'b0}}),
         .length_dw( (|byte_count[1:0]) ? (byte_count>>2) + 10'd1 : byte_count>>2 ),
         .first_dw_be(4'b0000),
         .last_dw_be(4'b0000)
      );
      packet_header_pu_completion = new(
         .cpl_data_type(cpl_data_type),
         .requester_id(requester_id),
         .completer_id(completer_id),
         .cpl_status(cpl_status),
         .byte_count(byte_count),
         .lower_address(lower_address)
      );
      this.packet_header = packet_header_pu_completion;
      this.set_tag(tag);
   endfunction

endclass : PacketPUCompletion 


class PacketDMMemReq #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends Packet #(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected PacketHeaderDMMemReq#(pf_type, vf_type, pf_list, vf_list) packet_header_dm_mem_req;

   // Constructor for PacketDMMemReq 
   function new(
      input packet_header_op_t packet_header_op,
      input uint64_t host_address,
      input uint64_t local_address_or_meta_data,
      input dm_length_t length,
      input bit mm_mode
   );
      super.new(
         .packet_format(DATA_MOVER),
         .packet_header_op(packet_header_op),
         .length_dw( (|length[1:0]) ? (length>>2) + 10'd1 : length>>2 )
      );
      packet_header_dm_mem_req = new(
         .packet_header_op(packet_header_op),
         .host_address(host_address),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode)
      );
      this.packet_header = packet_header_dm_mem_req;
   endfunction


   // Class Methods
   virtual function void print_packet_short();
      $display("");
      $display("Packet Information (short):");
      this.packet_header.print_header_short();
      $display("   Packet Payload: %0d Bytes", payload.size());
      $display("");
   endfunction


   virtual function void print_packet();
      $display("");
      $display("Packet Information:");
      this.packet_header.print_header();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction


   virtual function void print_packet_long();
      $display("");
      $display("Packet Information (long):");
      this.packet_header.print_header_long();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction

endclass : PacketDMMemReq 


class PacketDMCompletion #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends PacketDMMemReq #(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected PacketHeaderDMCompletion#(pf_type, vf_type, pf_list, vf_list) packet_header_dm_completion;

   // Constructor for PacketDMCompletion 
   function new(
      input cpl_status_t cpl_status,
      input uint64_t local_address_or_meta_data,
      input dm_length_t length,
      input bit mm_mode,
      input bit [23:0] lower_address,
      input packet_tag_t tag
   );
      super.new(
         .packet_header_op(COMPLETION),
         .host_address({64{1'b0}}),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode)
      );
      packet_header_dm_completion = new(
         .cpl_status(cpl_status),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode),
         .lower_address(lower_address)
      );
      this.packet_header = packet_header_dm_completion;
      this.set_tag(tag);
   endfunction

endclass : PacketDMCompletion


class PacketPUMsg #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends Packet #(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected PacketHeaderMsg#(pf_type, vf_type, pf_list, vf_list) packet_header_msg;

   // Constructor
   function new(
      input data_present_type_t data_present,
      input msg_route_t         msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [31:0] lower_msg,
      input bit [31:0] upper_msg,
      input bit  [9:0] length_dw
   );
      super.new(
         .packet_format(POWER_USER),
         .packet_header_op(MSG),
         .length_dw(length_dw)
      );
      packet_header_msg = new(
         .data_present(data_present),
         .msg_route(msg_route),
         .requester_id(requester_id),
         .msg_code(msg_code),
         .lower_msg(lower_msg),
         .upper_msg(upper_msg),
         .length_dw(length_dw)
      );
      this.packet_header = packet_header_msg; // Use Polymorphism to map header to subclass.
   endfunction


   // Class Methods
   virtual function void print_packet_short();
      $display("");
      $display("Packet Information (short):");
      this.packet_header.print_header_short();
      $display("   Packet Payload: %0d Bytes", payload.size());
      $display("");
   endfunction


   virtual function void print_packet();
      $display("");
      $display("Packet Information:");
      this.packet_header.print_header();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction


   virtual function void print_packet_long();
      $display("");
      $display("Packet Information (long):");
      this.packet_header.print_header_long();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction

endclass : PacketPUMsg


class PacketPUVDM #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
) extends Packet#(pf_type, vf_type, pf_list, vf_list);

   // Data Members
   protected PacketHeaderVDM#(pf_type, vf_type, pf_list, vf_list) packet_header_vdm;

   // Constructor
   function new(
      input data_present_type_t data_present,
      input vdm_msg_route_t     msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [15:0] pci_target_id,
      input bit [15:0] vendor_id,
      input bit  [9:0] length_dw
   );
      super.new(
         .packet_format(POWER_USER),
         .packet_header_op(VDM),
         .length_dw(length_dw)
      );
      packet_header_vdm = new(
         .data_present(data_present),
         .msg_route(msg_route),
         .requester_id(requester_id),
         .msg_code(msg_code),
         .pci_target_id(pci_target_id),
         .vendor_id(vendor_id),
         .length_dw(length_dw)
      );
      this.packet_header = packet_header_vdm; // Use Polymorphism to map header to subclass.
   endfunction


   virtual function void set_data(
      const ref byte_t set_data_buf[]
   );
      int bytes_needed_to_complete_word;
      int word_x4_remainder;
      int last_data_index;
      //$display(">>> SD: set_data_buf.size(): %0d", set_data_buf.size());
      word_x4_remainder = (set_data_buf.size() % 4);
      //$display(">>> SD: word_x4_remainder: %0d", word_x4_remainder);
      if (word_x4_remainder > 0)
      begin
         bytes_needed_to_complete_word = 4 - word_x4_remainder;
         //$display(">>> SD 1: bytes_needed_to_complete_word: %0d", bytes_needed_to_complete_word);
      end
      else
      begin
         bytes_needed_to_complete_word = 0;
         //$display(">>> SD 2: bytes_needed_to_complete_word: %0d", bytes_needed_to_complete_word);
      end
      payload = new[(set_data_buf.size() + bytes_needed_to_complete_word)];
      for (int i = 0; i < set_data_buf.size(); i++)
      begin
         payload[i] = set_data_buf[i];
      end
      if (bytes_needed_to_complete_word > 0)
      begin
         for (int i = set_data_buf.size(); i < (set_data_buf.size() + bytes_needed_to_complete_word); i++)
         begin
            payload[i] = 8'h00; // Pad Message to even words.
         end
         this.packet_header.set_pad_length(2'(bytes_needed_to_complete_word));
      end
   endfunction

   // Class Methods
   virtual function void print_packet_short();
      $display("");
      $display("Packet Information (short):");
      this.packet_header.print_header_short();
      $display("   Packet Payload: %0d Bytes", payload.size());
      $display("");
   endfunction


   virtual function void print_packet();
      $display("");
      $display("Packet Information:");
      this.packet_header.print_header();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction


   virtual function void print_packet_long();
      $display("");
      $display("Packet Information (long):");
      this.packet_header.print_header_long();
      $display("   Packet Payload: %0d Bytes", payload.size());
      if (payload.size() == 0)
         $display("");
      else
         $write  ("      "); // Indent
      foreach(payload[i])
      begin
         if (i % 16 == 0)
         begin
            $write("%H --- ", i);
         end
         $write("%H ", payload[i]);
         if ((i + 1) % 8 == 0)
         begin
            $write(" ");  // Put an extra space in middle of data line every 8 samples for clarity
         end
         if ((i + 1) % 16 == 0)
         begin
            $display("");  // Start a new line every 16 samples.
            $write  ("      "); // Indent
         end
      end
      $display("");    // Provides finish to last data "write"
      if (payload.size() > 0)
         $display(""); // Provides tidy space after printing payload
   endfunction

endclass : PacketPUVDM


endpackage: packet_class_pkg

`endif // __PACKET_CLASS_PKG__
