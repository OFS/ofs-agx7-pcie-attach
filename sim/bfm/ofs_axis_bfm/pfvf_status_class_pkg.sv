// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __PFVF_STATUS_CLASS_PKG__
`define __PFVF_STATUS_CLASS_PKG__

package pfvf_status_class_pkg; 

   import host_bfm_types_pkg::*; 
   import pfvf_class_pkg::*;

//------------------------------------------------------------------------------
// CLASS DEFINITIONS
//------------------------------------------------------------------------------
// Base Classes: PFVFRouting
//------------------------------------------------------------------------------
// This is a simple object that contains the PF and VF routing information for
// the Host BFM used during packet creation
//------------------------------------------------------------------------------
class PFVFRouting #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);
   local static PFVFRouting#(pf_type, vf_type, pf_list, vf_list) pf_vf_route_singleton;
   //local bit     [2:0] pfn;
   //local bit    [10:0] vfn;
   //local bit           vfa;
   local bit     [3:0] bar;
   local bit     [4:0] slot;
   /* local static pfvf_type_t setting = PF0; */
   /* local static pfvf_type_t last_setting = PF0; */
   /* local static pfvf_type_t tmp_setting; */
   local static pfvf_struct setting;
   local static pfvf_struct last_setting;
   local static pfvf_struct tmp_setting;
   local PFVFClass #(pf_type, vf_type, pf_list, vf_list) pfvf;

   //protected function new(pfvf_type_t setting);
   protected function new(pfvf_struct setting);
      this.pfvf = new(0,0,0);
      this.setting = pfvf.get_attr();
      this.last_setting = pfvf.get_attr();
      this.set_env(setting);
      this.bar = 4'b0000;
      this.slot = 5'b00000;
   endfunction


   static function PFVFRouting#(pf_type, vf_type, pf_list, vf_list) get();
      if (pf_vf_route_singleton == null)
         pf_vf_route_singleton = new(setting);
      return pf_vf_route_singleton;
   endfunction


   //function void set_env(pfvf_type_t setting);
   function void set_env(pfvf_struct setting);
      if (this.pfvf.set_pfvf_from_struct(setting))
      begin
         this.last_setting = this.setting;
         this.setting   = setting;
         /* this.setting   = setting; */
         /* this.pfn       = pfvf_attr[setting].pfn; */
         /* this.vfn       = pfvf_attr[setting].vfn; */
         /* this.vfa       = pfvf_attr[setting].vfa; */
      end
   endfunction


   function void set_bar(bit[3:0] bar);
      this.bar = bar;
   endfunction


   function void set_slot(bit[4:0] slot);
      this.slot = slot;
   endfunction


   function bit [2:0] get_pf();
      return this.pfvf.get_pf_field();
   endfunction


   function bit [10:0] get_vf();
      return this.pfvf.get_vf_field();
   endfunction


   function bit get_vfa();
      return this.pfvf.get_vfa();
   endfunction


   function bit [3:0] get_bar();
      return this.bar;
   endfunction


   function bit [4:0] get_slot();
      return this.slot;
   endfunction


   //function pfvf_type_t get_env();
   function pfvf_struct get_env();
      return this.setting;
   endfunction


   function void revert_to_last_setting();
      if (this.pfvf.set_pfvf_from_struct(this.last_setting))
      begin
         this.tmp_setting = this.setting;
         this.setting = this.last_setting;
         this.last_setting = this.tmp_setting;
      end
   endfunction


   function uint64_t get_base_addr();
      return this.pfvf.get_base_addr();
   endfunction

endclass: PFVFRouting



endpackage: pfvf_status_class_pkg

`endif // __PFVF_STATUS_CLASS_PKG__
