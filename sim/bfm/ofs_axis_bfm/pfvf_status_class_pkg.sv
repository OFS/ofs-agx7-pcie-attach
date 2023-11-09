// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __PFVF_STATUS_CLASS_PKG__
`define __PFVF_STATUS_CLASS_PKG__

package pfvf_status_class_pkg; 

   import pfvf_def_pkg::*;

//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Base Classes: PFVFRouting
//------------------------------------------------------------------------------
// This is a simple object that contains the PF and VF routing information for
// the Host BFM used during packet creation
//------------------------------------------------------------------------------
class PFVFRouting;
   local static PFVFRouting pf_vf_route_singleton;
   local bit     [2:0] pfn;
   local bit    [10:0] vfn;
   local bit           vfa;
   local bit     [3:0] bar;
   local bit     [4:0] slot;
   local static pfvf_type_t setting = PF0;
   local static pfvf_type_t last_setting = PF0;
   local static pfvf_type_t tmp_setting;
   local bit [AXI_ST_ADDR_WIDTH-1:0] base_addr;

   protected function new(pfvf_type_t setting);
      this.set_env(setting);
      this.bar = 4'b0000;
      this.slot = 5'b00000;
   endfunction


   static function PFVFRouting get();
      if (pf_vf_route_singleton == null)
         pf_vf_route_singleton = new(setting);
      return pf_vf_route_singleton;
   endfunction


   function void set_env(pfvf_type_t setting);
      this.last_setting = this.setting;
      this.setting   = setting;
      this.pfn       = pfvf_attr[setting].pfn;
      this.vfn       = pfvf_attr[setting].vfn;
      this.vfa       = pfvf_attr[setting].vfa;
      this.base_addr = pfvf_attr[setting].base_addr;
   endfunction


   function void set_bar(bit[3:0] bar);
      this.bar = bar;
   endfunction


   function void set_slot(bit[4:0] slot);
      this.slot = slot;
   endfunction


   function bit [2:0] get_pf();
      return this.pfn;
   endfunction


   function bit [10:0] get_vf();
      return this.vfn;
   endfunction


   function bit get_vfa();
      return this.vfa;
   endfunction


   function bit [3:0] get_bar();
      return this.bar;
   endfunction


   function bit [4:0] get_slot();
      return this.slot;
   endfunction


   function pfvf_type_t get_env();
      return this.setting;
   endfunction


   function void revert_to_last_setting();
      this.tmp_setting = this.setting;
      this.setting = this.last_setting;
      this.last_setting = this.tmp_setting;
      this.set_env(this.setting);
   endfunction


   function bit [AXI_ST_ADDR_WIDTH-1:0] get_base_addr();
      return this.base_addr;
   endfunction

endclass: PFVFRouting



endpackage: pfvf_status_class_pkg

`endif // __PFVF_STATUS_CLASS_PKG__
