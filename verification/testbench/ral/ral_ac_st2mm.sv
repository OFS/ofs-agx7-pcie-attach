// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_ST2MM
`define RAL_AC_ST2MM

import uvm_pkg::*;

class ral_reg_ac_st2mm_ST2MM_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	function new(string name = "ac_st2mm_ST2MM_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h10000, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h20, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_st2mm_ST2MM_DFH)

endclass : ral_reg_ac_st2mm_ST2MM_DFH


class ral_reg_ac_st2mm_ST2MM_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Reserved;

	function new(string name = "ac_st2mm_ST2MM_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_st2mm_ST2MM_SCRATCHPAD)

endclass : ral_reg_ac_st2mm_ST2MM_SCRATCHPAD


class ral_block_ac_st2mm extends uvm_reg_block;
	rand ral_reg_ac_st2mm_ST2MM_DFH ST2MM_DFH;
	rand ral_reg_ac_st2mm_ST2MM_SCRATCHPAD ST2MM_SCRATCHPAD;
	uvm_reg_field ST2MM_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field ST2MM_DFH_Reserved;
	uvm_reg_field ST2MM_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field ST2MM_DFH_NextDfhByteOffset;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field ST2MM_DFH_FeatureRev;
	uvm_reg_field FeatureRev;
	uvm_reg_field ST2MM_DFH_FeatureID;
	uvm_reg_field FeatureID;
	rand uvm_reg_field ST2MM_SCRATCHPAD_Reserved;

	function new(string name = "ac_st2mm");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.ST2MM_DFH = ral_reg_ac_st2mm_ST2MM_DFH::type_id::create("ST2MM_DFH",,get_full_name());
      this.ST2MM_DFH.configure(this, null, "");
      this.ST2MM_DFH.build();
      this.default_map.add_reg(this.ST2MM_DFH, `UVM_REG_ADDR_WIDTH'h00000, "RW", 0);
		this.ST2MM_DFH_FeatureType = this.ST2MM_DFH.FeatureType;
		this.FeatureType = this.ST2MM_DFH.FeatureType;
		this.ST2MM_DFH_Reserved = this.ST2MM_DFH.Reserved;
		this.ST2MM_DFH_EOL = this.ST2MM_DFH.EOL;
		this.EOL = this.ST2MM_DFH.EOL;
		this.ST2MM_DFH_NextDfhByteOffset = this.ST2MM_DFH.NextDfhByteOffset;
		this.NextDfhByteOffset = this.ST2MM_DFH.NextDfhByteOffset;
		this.ST2MM_DFH_FeatureRev = this.ST2MM_DFH.FeatureRev;
		this.FeatureRev = this.ST2MM_DFH.FeatureRev;
		this.ST2MM_DFH_FeatureID = this.ST2MM_DFH.FeatureID;
		this.FeatureID = this.ST2MM_DFH.FeatureID;
      this.ST2MM_SCRATCHPAD = ral_reg_ac_st2mm_ST2MM_SCRATCHPAD::type_id::create("ST2MM_SCRATCHPAD",,get_full_name());
      this.ST2MM_SCRATCHPAD.configure(this, null, "");
      this.ST2MM_SCRATCHPAD.build();
      this.default_map.add_reg(this.ST2MM_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h00008, "RW", 0);
		this.ST2MM_SCRATCHPAD_Reserved = this.ST2MM_SCRATCHPAD.Reserved;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_st2mm)

endclass : ral_block_ac_st2mm



`endif
