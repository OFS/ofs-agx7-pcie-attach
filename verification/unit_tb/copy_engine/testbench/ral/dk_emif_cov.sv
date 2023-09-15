// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_DK_EMIF
`define RAL_DK_EMIF

import uvm_pkg::*;

class ral_reg_dk_emif_EMIF_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset_H;
	uvm_reg_field FeatureRevision;
	uvm_reg_field FeatureId;

	covergroup cg_vals ();
		option.per_instance = 1;
		FeatureType_value : coverpoint FeatureType.value[3:0] {
			option.weight = 16;
		}
		Reserved_value : coverpoint Reserved.value {
			bins min = { 19'h0 };
			bins max = { 19'h7FFFF };
			bins others = { [19'h1:19'h7FFFE] };
			option.weight = 3;
		}
		EOL_value : coverpoint EOL.value[0:0] {
			option.weight = 2;
		}
		NextDfhOffset_H_value : coverpoint NextDfhOffset_H.value {
			bins min = { 24'h0 };
			bins max = { 24'hFFFFFF };
			bins others = { [24'h1:24'hFFFFFE] };
			option.weight = 3;
		}
		FeatureRevision_value : coverpoint FeatureRevision.value[3:0] {
			option.weight = 16;
		}
		FeatureId_value : coverpoint FeatureId.value {
			bins min = { 12'h0 };
			bins max = { 12'hFFF };
			bins others = { [12'h1:12'hFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "dk_emif_EMIF_DFH");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 19, 41, "RO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhOffset_H = uvm_reg_field::type_id::create("NextDfhOffset_H",,get_full_name());
      this.NextDfhOffset_H.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.FeatureRevision = uvm_reg_field::type_id::create("FeatureRevision",,get_full_name());
      this.FeatureRevision.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureId = uvm_reg_field::type_id::create("FeatureId",,get_full_name());
      this.FeatureId.configure(this, 12, 0, "RO", 0, 12'hf, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_dk_emif_EMIF_DFH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_dk_emif_EMIF_DFH


class ral_reg_dk_emif_EMIF_STATUS extends uvm_reg;
	uvm_reg_field Reserved;
	uvm_reg_field CalFaliure;
	uvm_reg_field CalSuccess;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved_value : coverpoint Reserved.value {
			bins min = { 62'h0 };
			bins max = { 62'h3FFFFFFFFFFFFFFF };
			bins others = { [62'h1:62'h3FFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
		CalFaliure_value : coverpoint CalFaliure.value[0:0] {
			option.weight = 2;
		}
		CalSuccess_value : coverpoint CalSuccess.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "dk_emif_EMIF_STATUS");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 62, 2, "RO", 0, 62'h000000000, 1, 0, 0);
      this.CalFaliure = uvm_reg_field::type_id::create("CalFaliure",,get_full_name());
      this.CalFaliure.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.CalSuccess = uvm_reg_field::type_id::create("CalSuccess",,get_full_name());
      this.CalSuccess.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_dk_emif_EMIF_STATUS)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_dk_emif_EMIF_STATUS


class ral_reg_dk_emif_EMIF_CAPABILITY extends uvm_reg;
	uvm_reg_field Reserved;
	uvm_reg_field EMIFCap;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved_value : coverpoint Reserved.value {
			bins min = { 63'h0 };
			bins max = { 63'h7FFFFFFFFFFFFFFF };
			bins others = { [63'h1:63'h7FFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
		EMIFCap_value : coverpoint EMIFCap.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "dk_emif_EMIF_CAPABILITY");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 63, 1, "RO", 0, 63'h000000000, 1, 0, 0);
      this.EMIFCap = uvm_reg_field::type_id::create("EMIFCap",,get_full_name());
      this.EMIFCap.configure(this, 1, 0, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_dk_emif_EMIF_CAPABILITY)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_dk_emif_EMIF_CAPABILITY


class ral_block_dk_emif extends uvm_reg_block;
	rand ral_reg_dk_emif_EMIF_DFH EMIF_DFH;
	rand ral_reg_dk_emif_EMIF_STATUS EMIF_STATUS;
	rand ral_reg_dk_emif_EMIF_CAPABILITY EMIF_CAPABILITY;
	uvm_reg_field EMIF_DFH_FeatureType;
	uvm_reg_field FeatureType;
	uvm_reg_field EMIF_DFH_Reserved;
	uvm_reg_field EMIF_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field EMIF_DFH_NextDfhOffset_H;
	uvm_reg_field NextDfhOffset_H;
	uvm_reg_field EMIF_DFH_FeatureRevision;
	uvm_reg_field FeatureRevision;
	uvm_reg_field EMIF_DFH_FeatureId;
	uvm_reg_field FeatureId;
	uvm_reg_field EMIF_STATUS_Reserved;
	uvm_reg_field EMIF_STATUS_CalFaliure;
	uvm_reg_field CalFaliure;
	uvm_reg_field EMIF_STATUS_CalSuccess;
	uvm_reg_field CalSuccess;
	uvm_reg_field EMIF_CAPABILITY_Reserved;
	uvm_reg_field EMIF_CAPABILITY_EMIFCap;
	uvm_reg_field EMIFCap;

	function new(string name = "dk_emif");
		super.new(name, build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.EMIF_DFH = ral_reg_dk_emif_EMIF_DFH::type_id::create("EMIF_DFH",,get_full_name());
      this.EMIF_DFH.configure(this, null, "");
      this.EMIF_DFH.build();
      this.default_map.add_reg(this.EMIF_DFH, `UVM_REG_ADDR_WIDTH'h61000, "RO", 0);
		this.EMIF_DFH_FeatureType = this.EMIF_DFH.FeatureType;
		this.FeatureType = this.EMIF_DFH.FeatureType;
		this.EMIF_DFH_Reserved = this.EMIF_DFH.Reserved;
		this.EMIF_DFH_EOL = this.EMIF_DFH.EOL;
		this.EOL = this.EMIF_DFH.EOL;
		this.EMIF_DFH_NextDfhOffset_H = this.EMIF_DFH.NextDfhOffset_H;
		this.NextDfhOffset_H = this.EMIF_DFH.NextDfhOffset_H;
		this.EMIF_DFH_FeatureRevision = this.EMIF_DFH.FeatureRevision;
		this.FeatureRevision = this.EMIF_DFH.FeatureRevision;
		this.EMIF_DFH_FeatureId = this.EMIF_DFH.FeatureId;
		this.FeatureId = this.EMIF_DFH.FeatureId;
      this.EMIF_STATUS = ral_reg_dk_emif_EMIF_STATUS::type_id::create("EMIF_STATUS",,get_full_name());
      this.EMIF_STATUS.configure(this, null, "");
      this.EMIF_STATUS.build();
      this.default_map.add_reg(this.EMIF_STATUS, `UVM_REG_ADDR_WIDTH'h61008, "RO", 0);
		this.EMIF_STATUS_Reserved = this.EMIF_STATUS.Reserved;
		this.EMIF_STATUS_CalFaliure = this.EMIF_STATUS.CalFaliure;
		this.CalFaliure = this.EMIF_STATUS.CalFaliure;
		this.EMIF_STATUS_CalSuccess = this.EMIF_STATUS.CalSuccess;
		this.CalSuccess = this.EMIF_STATUS.CalSuccess;
      this.EMIF_CAPABILITY = ral_reg_dk_emif_EMIF_CAPABILITY::type_id::create("EMIF_CAPABILITY",,get_full_name());
      this.EMIF_CAPABILITY.configure(this, null, "");
      this.EMIF_CAPABILITY.build();
      this.default_map.add_reg(this.EMIF_CAPABILITY, `UVM_REG_ADDR_WIDTH'h61010, "RO", 0);
		this.EMIF_CAPABILITY_Reserved = this.EMIF_CAPABILITY.Reserved;
		this.EMIF_CAPABILITY_EMIFCap = this.EMIF_CAPABILITY.EMIFCap;
		this.EMIFCap = this.EMIF_CAPABILITY.EMIFCap;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_dk_emif)


	function void sample_values();
	   super.sample_values();
		if (get_coverage(UVM_CVR_FIELD_VALS)) begin
			if (EMIF_DFH.cg_vals != null) EMIF_DFH.cg_vals.sample();
			if (EMIF_STATUS.cg_vals != null) EMIF_STATUS.cg_vals.sample();
			if (EMIF_CAPABILITY.cg_vals != null) EMIF_CAPABILITY.cg_vals.sample();
		end
	endfunction
endclass : ral_block_dk_emif



`endif
