// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __HOST_BFM_CLASS_PKG__
`define __HOST_BFM_CLASS_PKG__

package host_bfm_class_pkg; 

   import host_bfm_types_pkg::*;
   import pfvf_status_class_pkg::*;
   import packet_class_pkg::*;
   import host_transaction_class_pkg::*;

//----------------------------------------------------------------------------------------------------
// Parameter and Enum Definitions for Host BFM.
//----------------------------------------------------------------------------------------------------
   parameter REQUESTER_ID = 16'h0001;
   parameter COMPLETER_ID = 16'h0001;

   typedef enum {
      PU_PACKET,
      PU_TRANSACTION,
      PU_METHOD_TRANSACTION
   } mmio_mode_t;

   typedef enum {
      DM_PACKET,
      DM_AUTO_TRANSACTION
   } dm_mode_t;

//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
virtual class HostBFM #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);

   // Data Members
   protected mmio_mode_t mmio_mode;
   protected dm_mode_t   dm_mode;
   protected PFVFRouting#(pf_type, vf_type, pf_list, vf_list) pf_vf_route; // Singleton object for PCIe setting.


   // Constructor
   function new();
      //this.mmio_mode = PU_PACKET;
      //this.mmio_mode = PU_TRANSACTION;
      this.mmio_mode = PU_METHOD_TRANSACTION;
      //this.dm_mode   = DM_PACKET;
      this.dm_mode   = DM_AUTO_TRANSACTION;
      this.pf_vf_route = PFVFRouting#(pf_type, vf_type, pf_list, vf_list)::get(); // Singletom object for PCIe setting.
   endfunction


   // Methods
   virtual function void set_mmio_mode(
      input mmio_mode_t mmio_mode
   );
      this.mmio_mode = mmio_mode;
   endfunction


   virtual function mmio_mode_t get_mmio_mode();
      return this.mmio_mode;
   endfunction


   virtual function void set_dm_mode(
      input dm_mode_t dm_mode
   );
      this.dm_mode = dm_mode;
   endfunction


   virtual function dm_mode_t get_dm_mode();
      return this.dm_mode;
   endfunction


   //virtual function void set_pfvf_setting(pfvf_type_t setting);
   virtual function void set_pfvf_setting(pfvf_struct setting);
      this.pf_vf_route.set_env(setting);
   endfunction


   virtual function pfvf_struct get_pfvf_setting();
      return this.pf_vf_route.get_env();
   endfunction


   virtual function void revert_to_last_pfvf_setting();
      this.pf_vf_route.revert_to_last_setting();
   endfunction


   virtual function bit [2:0] get_pf();
      return this.pf_vf_route.get_pf();
   endfunction


   virtual function bit [10:0] get_vf();
      return this.pf_vf_route.get_vf();
   endfunction


   virtual function bit get_vf_active();
      return this.pf_vf_route.get_vfa();
   endfunction


   virtual function void set_bar(bit[3:0] bar);
      this.pf_vf_route.set_bar(bar);
   endfunction


   virtual function bit [3:0] get_bar();
      return this.pf_vf_route.get_bar();
   endfunction


   virtual function void set_slot(bit[4:0] slot);
      this.pf_vf_route.set_slot(slot);
   endfunction


   virtual function bit [4:0] get_slot();
      return this.pf_vf_route.get_slot();
   endfunction


   pure virtual task run_rx_req();
   pure virtual task run_tx();
   pure virtual task run_tx_req();
   pure virtual task run_rx();
   pure virtual task read32(
      input uint64_t address,
      output logic [31:0] data
   );
   pure virtual task read64(
      input uint64_t address,
      output logic [63:0] data
   );
   pure virtual task read32_with_completion_status(
      input uint64_t address,
      output logic [31:0] data,
      output logic        error,
      output cpl_status_t cpl_status
   );
   pure virtual task read64_with_completion_status(
      input uint64_t address,
      output logic [63:0] data,
      output logic        error,
      output cpl_status_t cpl_status
   );
   pure virtual task read_data_with_completion_status(
      input uint64_t address,
      input uint32_t length_in_bytes,
      output logic [63:0]  data,
      output return_data_t return_data,
      output logic         error,
      output cpl_status_t  cpl_status
   );
   pure virtual task write32(
      input uint64_t address,
      input logic [31:0] data
   );
   pure virtual task write64(
      input uint64_t address,
      input logic [63:0] data
   );
   pure virtual task send_msg(
      input data_present_type_t data_present,
      input msg_route_t         msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [31:0] lower_msg,
      input bit [31:0] upper_msg,
      input packet_tag_t tag,
      ref byte_array_t msg_data
   );
   pure virtual task send_vdm(
      input data_present_type_t data_present,
      input vdm_msg_route_t         msg_route,
      input bit [15:0] requester_id,
      input bit  [7:0] msg_code,
      input bit [15:0] pci_target_id,
      input bit [15:0] vendor_id,
      ref byte_array_t msg_data
   );

endclass : HostBFM



endpackage: host_bfm_class_pkg

`endif // __HOST_BFM_CLASS_PKG__
