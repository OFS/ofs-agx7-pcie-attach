// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __PFVF_CLASS_PKG__
`define __PFVF_CLASS_PKG__


package pfvf_class_pkg; 

import host_bfm_types_pkg::*;

class PFVFClass #(
   type pf_type = default_pfs, 
   type vf_type = default_vfs, 
   pf_type pf_list = '{1'b1}, 
   vf_type vf_list = '{0}
);

   // Type Definition for Copy Function and Parameterized Self-Reference
   typedef PFVFClass#(pf_type, vf_type, pf_list, vf_list) pfvf_object_t;

   // Data Members
   protected int        pf;
   protected int        vf;
   protected bit        vfa;
   protected pfvf_struct pfvf_attr;
   const uint64_t pf_base_address = 64'h0000_0000_8000_0000;
   const uint64_t vf_base_address = 64'h9000_0000_0000_0000;
   const uint64_t pf_base_offset  = 64'h0000_0000_2000_0000;
   const uint64_t vf_base_offset  = 64'h0000_0000_0100_0000;
   protected pfvf_struct pfvf_attr_lookup[pfvf_struct];
   protected uint64_t pfvf_addr_lookup[pfvf_struct];
   pf_array_t pf_array;
   vf_array_t vf_array;


   // Constructor
   function new(
      input int pf,
      input int vf,
      input bit vfa
   );
      pfvf_struct pfvf_local;
      this.pf_array.delete();
      this.vf_array.delete();
      this.create_pf_array();
      this.create_vf_array();
      pfvf_local = create_pfvf_struct(pf,vf,vfa);
      this.create_pfvf_lookups();
      if (!(this.set_pfvf(pf, vf, vfa)))
      begin
         pfvf_attr_lookup.first(pfvf_local);
         this.set_pfvf_from_struct(pfvf_local);
      end
      //$display(">>> PFVF Initialization:");
      //this.print_pfvf_status();
      //$display("");
   endfunction


   // Methods
   function bit set_pfvf_first();
      pfvf_struct pfvf_first;
      bit first_response;
      first_response = pfvf_attr_lookup.first(pfvf_first);
      this.set_pfvf_from_struct(pfvf_first);
      return first_response;
   endfunction


   function bit set_pfvf_next();
      pfvf_struct pfvf_next;
      bit next_response;
      pfvf_next = this.pfvf_attr;
      next_response = pfvf_attr_lookup.next(pfvf_next);
      this.set_pfvf_from_struct(pfvf_next);
      return next_response;
   endfunction


   function bit get_pfvf_first(
      ref pfvf_struct pfvf
   );
      return(pfvf_attr_lookup.first(pfvf));
   endfunction


   function bit get_pfvf_next(
      ref pfvf_struct pfvf
   );
      return(pfvf_attr_lookup.next(pfvf));
   endfunction


   function bit get_pfvf_last(
      ref pfvf_struct pfvf
   );
      return(pfvf_attr_lookup.last(pfvf));
   endfunction


   function pfvf_struct create_pfvf_struct(int pf, int vf, bit vfa);
      pfvf_struct pfvf;
      pfvf.pfn = 3'(pf);
      pfvf.vfn = 11'(vf);
      pfvf.vfa = vfa;
      return pfvf;
   endfunction


   //function void copy(PFVFClass pfvf_in);
   function void copy(pfvf_object_t pfvf_in);
      this.pf = pfvf_in.get_pf();
      this.vf = pfvf_in.get_vf();
      this.vfa = pfvf_in.get_vfa();
      this.pfvf_attr = pfvf_in.get_attr();
      pfvf_in.get_pfvf_attr_lookup_array(this.pfvf_attr_lookup);
      pfvf_in.get_pfvf_addr_lookup_array(this.pfvf_addr_lookup);
      this.pf_array = pfvf_in.pf_array;
      this.vf_array = pfvf_in.vf_array;
   endfunction


   function bit pfvf_exists(int pf, int vf, bit vfa);
      pfvf_struct pfvf_local;
      pfvf_local = create_pfvf_struct(pf,vf,vfa);
      return pfvf_attr_lookup.exists(pfvf_local);
   endfunction


   function void create_pfvf_lookups();
      int i,j;
      pfvf_struct pfvf_local;
      uint64_t pf_addr;
      uint64_t vf_addr;
      pf_addr = pf_base_address;
      vf_addr = vf_base_address;
      this.pfvf_attr_lookup.delete();
      this.pfvf_addr_lookup.delete();
      for (i = 0; i <$size(pf_list); i++)
      begin
         if(pf_list[i] == 1'b1)
         begin
            pfvf_local = create_pfvf_struct(i,0,1'b0);
            this.pfvf_attr_lookup[pfvf_local] = pfvf_local;
            this.pfvf_addr_lookup[pfvf_local] = pf_addr;
            pf_addr = pf_addr + pf_base_offset;
            if (vf_list[i] > 0)
            begin
               for (j = 0; j < (vf_list[i]); j++)
               begin
                  pfvf_local = create_pfvf_struct(i,j,1'b1);
                  this.pfvf_attr_lookup[pfvf_local] = pfvf_local;
                  this.pfvf_addr_lookup[pfvf_local] = vf_addr;
                  vf_addr = vf_addr + vf_base_offset;
               end
            end
         end
      end
   endfunction


   function pfvf_struct get_attr();
      return this.pfvf_attr;
   endfunction


   function uint64_t get_base_addr();
      if (this.pfvf_addr_lookup.exists(this.pfvf_attr))
      begin
         return this.pfvf_addr_lookup[pfvf_attr];
      end
      else
      begin
         return 64'hFFFF_FFFF_FFFF_FFFF;
      end
   endfunction


   function int get_pf();
      return this.pf;
   endfunction


   function int get_vf();
      return this.vf;
   endfunction


   function bit get_vfa();
      return this.vfa;
   endfunction


   function bit [2:0] get_pf_field();
      return this.pfvf_attr.pfn;
   endfunction


   function bit [10:0] get_vf_field();
      return this.pfvf_attr.vfn;
   endfunction


   function bit get_vfa_field();
      return this.pfvf_attr.vfa;
   endfunction


   function int get_pf_count();
      int i;
      int count = 0;
      for (i = 0; i < $size(pf_list); i++)
      begin
         if (pf_list[i] == 1)
         begin
            count = count + 1;
         end
      end
      return count;
   endfunction


   function int get_vf_count();
      int i;
      int count = 0;
      for (i = 0; i < $size(vf_list); i++)
      begin
         count += vf_list[i];
      end
      return count;
   endfunction


   function int get_vf_count_for_pf(int pf);
      return vf_list[pf];
   endfunction


   function bit set_pfvf(int pf, int vf, bit vfa);
      pfvf_struct pfvf_local;
      pfvf_local = create_pfvf_struct(pf,vf,vfa);
      if (pfvf_attr_lookup.exists(pfvf_local))
      begin
         this.pf = pf;
         this.vf = vf;
         this.vfa = vfa;
         this.pfvf_attr = pfvf_local;
         return 1'b1;
      end
      else
      begin
         $display("");
         $display(">>> PFVF ERROR: An attempt was made to set a PFVF Object to an invalid combination: PF:%0d, VF:%0d, VFA:%0d", pf, vf, vfa);
         $display("    The PFVF setting was not changed from previous/initial value:");
         this.print_pfvf_attr_lookup();
         $display("");
         return 1'b0;
      end
   endfunction


   function bit set_pfvf_from_struct(pfvf_struct pfvf);
      if (pfvf_attr_lookup.exists(pfvf))
      begin
         this.pf = pfvf.pfn;
         this.vf = pfvf.vfn;
         this.vfa = pfvf.vfa;
         this.pfvf_attr = pfvf;
         return 1'b1;
      end
      else
      begin
         $display("");
         $display(">>> PFVF ERROR: An attempt was made to set a PFVF Object to an invalid combination: PF:%0d, VF:%0d, VFA:%0d", pfvf.pfn, pfvf.vfn, pfvf.vfa);
         $display("    The PFVF setting was not changed from previous/initial value:");
         this.print_pfvf_attr_lookup();
         $display("");
         return 1'b0;
      end
   endfunction


   function void create_pf_array();
      int i, size;
      size = $size(pf_list);
      this.pf_array = new[size];
      for (i = 0; i < size; i++)
      begin
         this.pf_array[i] = pf_list[i];
      end
   endfunction


   function void create_vf_array();
      int i, size;
      size = $size(vf_list);
      this.vf_array = new[size];
      for (i = 0; i < size; i++)
      begin
         this.vf_array[i] = vf_list[i];
      end
   endfunction


   function int get_pf_array_size();
      return this.pf_array.size();
   endfunction


   function void get_pf_array(
      ref bit get_pf_data_buf[]
   );
      int i, size;
      size = get_pf_array_size();
      get_pf_data_buf = new[size];
      for (i = 0; i < get_pf_data_buf.size(); i++)
      begin
         get_pf_data_buf[i] = this.pf_array[i];
      end
   endfunction


   function int get_vf_array_size();
      return this.vf_array.size();
   endfunction


   function void get_vf_array(
      ref int get_vf_data_buf[]
   );
      int i, size;
      size = get_vf_array_size();
      get_vf_data_buf = new[size];
      for (i = 0; i < get_vf_data_buf.size(); i++)
      begin
         get_vf_data_buf[i] = this.vf_array[i];
      end
   endfunction


   function void get_pfvf_attr_lookup_array(
      ref pfvf_struct pfvf_attr_lookup_buf[pfvf_struct]
   );
      pfvf_attr_lookup_buf = this.pfvf_attr_lookup; // Copy Lookup Array
   endfunction


   function void get_pfvf_addr_lookup_array(
      ref uint64_t pfvf_addr_lookup_buf[pfvf_struct]
   );
      pfvf_addr_lookup_buf = this.pfvf_addr_lookup; // Copy Lookup Array
   endfunction


   function void print_pfvf_status();
      uint64_t address;
      address = this.get_base_addr();
      $display("       PF..........: %0d", this.get_pf());
      $display("       VF..........: %0d", this.get_vf());
      $display("       VF Active...: %-s", this.get_vfa ? "ACTIVE" : "PF ONLY");
      $display("       Base Address: %H_%H_%H_%H", address[63:48], address[47:32], address[31:16], address[15:0]);
   endfunction

   function void print_header();
      $display(">>> PFVF Information:");
      print_pfvf_status();
   endfunction;


   function void print();
      $display("");
      this.print_header();
      $display("");
   endfunction



   function void print_pf_list();
      $display(">>> Listing of PFs for this system.");
      $display("       PF Number...: %0d", get_pf_count());
      for (int i = 0; i < $size(pf_list); i++)
      begin
         $display("          PF[%2d]......: %0d", i, pf_list[i]);
      end
      $display("");
   endfunction


   function void print_vf_list();
      $display(">>> Listing of VFs for this system.");
      $display("       VF Number...: %0d", get_vf_count());
      for (int i = 0; i < $size(vf_list); i++)
      begin
         $display("          PF[%2d] #VFs...: %0d", i, vf_list[i]);
      end
      $display("");
   endfunction


   function void print_pfvf_attr_lookup();
      $display(">>> PFVF Attribute Entries....: %0d", pfvf_attr_lookup.num());
      foreach (pfvf_attr_lookup[i])
      begin
         $display("         pfvf_attr_lookup[%H_%H_%H]:", i.pfn, i.vfn, i.vfa);
         $display("            pfn...: %H", pfvf_attr_lookup[i].pfn);
         $display("            vfn...: %H", pfvf_attr_lookup[i].vfn);
         $display("            vfa...: %B", pfvf_attr_lookup[i].vfa);
      end
      $display("");
   endfunction


   function void print_pfvf_addr_lookup();
      this.print_header();
      $display(">>> PFVF Address Entries......: %0d", pfvf_addr_lookup.num());
      foreach (pfvf_addr_lookup[i])
      begin
         $display("       pfvf_addr_lookup[%H_%H_%H] Address......: %H_%H_%H_%H", i.pfn, i.vfn, i.vfa, pfvf_addr_lookup[i][63:48], pfvf_addr_lookup[i][47:32], pfvf_addr_lookup[i][31:16], pfvf_addr_lookup[i][15:0]);
      end
      $display("");
   endfunction

   
endclass: PFVFClass


endpackage: pfvf_class_pkg


`endif // __PFVF_CLASS_PKG__
