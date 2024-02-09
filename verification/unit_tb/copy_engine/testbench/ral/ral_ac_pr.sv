// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_PR
`define RAL_AC_PR

import uvm_pkg::*;

class ral_reg_ac_pr_PR_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	function new(string name = "ac_pr_PR_DFH");
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

	`uvm_object_utils(ral_reg_ac_pr_PR_DFH)

endclass : ral_reg_ac_pr_PR_DFH


class ral_reg_ac_pr_PR_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Reserved;

	function new(string name = "ac_pr_PR_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pr_PR_SCRATCHPAD)

endclass : ral_reg_ac_pr_PR_SCRATCHPAD


class ral_block_ac_pr extends uvm_reg_block;
	rand ral_reg_ac_pr_PR_DFH PR_DFH;
	rand ral_reg_ac_pr_PR_SCRATCHPAD PR_SCRATCHPAD;
	uvm_reg_field PR_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field PR_DFH_Reserved;
	uvm_reg_field PR_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field PR_DFH_NextDfhByteOffset;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field PR_DFH_FeatureRev;
	uvm_reg_field FeatureRev;
	uvm_reg_field PR_DFH_FeatureID;
	uvm_reg_field FeatureID;
	rand uvm_reg_field PR_SCRATCHPAD_Reserved;

	function new(string name = "ac_pr");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.PR_DFH = ral_reg_ac_pr_PR_DFH::type_id::create("PR_DFH",,get_full_name());
      this.PR_DFH.configure(this, null, "");
      this.PR_DFH.build();
      this.default_map.add_reg(this.PR_DFH, `UVM_REG_ADDR_WIDTH'h90000, "RW", 0);
		this.PR_DFH_FeatureType = this.PR_DFH.FeatureType;
		this.FeatureType = this.PR_DFH.FeatureType;
		this.PR_DFH_Reserved = this.PR_DFH.Reserved;
		this.PR_DFH_EOL = this.PR_DFH.EOL;
		this.EOL = this.PR_DFH.EOL;
		this.PR_DFH_NextDfhByteOffset = this.PR_DFH.NextDfhByteOffset;
		this.NextDfhByteOffset = this.PR_DFH.NextDfhByteOffset;
		this.PR_DFH_FeatureRev = this.PR_DFH.FeatureRev;
		this.FeatureRev = this.PR_DFH.FeatureRev;
		this.PR_DFH_FeatureID = this.PR_DFH.FeatureID;
		this.FeatureID = this.PR_DFH.FeatureID;
      this.PR_SCRATCHPAD = ral_reg_ac_pr_PR_SCRATCHPAD::type_id::create("PR_SCRATCHPAD",,get_full_name());
      this.PR_SCRATCHPAD.configure(this, null, "");
      this.PR_SCRATCHPAD.build();
      this.default_map.add_reg(this.PR_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h90008, "RW", 0);
		this.PR_SCRATCHPAD_Reserved = this.PR_SCRATCHPAD.Reserved;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_pr)

endclass : ral_block_ac_pr



`endif
