// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_EMIF
`define RAL_AC_EMIF

import uvm_pkg::*;

class ral_reg_ac_emif_EMIF_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset_H;
	uvm_reg_field FeatureRevision;
	uvm_reg_field FeatureId;

	covergroup cg_vals ();
		option.per_instance = 1;
		FeatureType_value : coverpoint FeatureType.value[3:0] { //Added by script default bin
      bins default_value = { 'h3 };
      option.weight = 1;
    }
		EOL_value : coverpoint EOL.value[0:0] { //Added by script default bin
      bins default_value = { 'h0 };
      option.weight = 1;
    }
		NextDfhOffset_H_value : coverpoint NextDfhOffset_H.value { //Added by script default bin
      bins default_value = { 'hB000 };
      option.weight = 1;
    }
		FeatureRevision_value : coverpoint FeatureRevision.value[3:0] { //Added by script default bin
      bins default_value = { 'h1 };
      option.weight = 1;
    }
		FeatureId_value : coverpoint FeatureId.value { //Added by script default bin
      bins default_value = { 'h009 };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_emif_EMIF_DFH");
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
      this.NextDfhOffset_H.configure(this, 24, 16, "RO", 0, 24'hB000, 1, 0, 1);
      this.FeatureRevision = uvm_reg_field::type_id::create("FeatureRevision",,get_full_name());
      this.FeatureRevision.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureId = uvm_reg_field::type_id::create("FeatureId",,get_full_name());
      this.FeatureId.configure(this, 12, 0, "RO", 0, 12'h9, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_EMIF_DFH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_EMIF_DFH


class ral_reg_ac_emif_EMIF_STATUS extends uvm_reg;
	uvm_reg_field Reserved;
	uvm_reg_field CalFaliure;
	uvm_reg_field CalSuccess;

	covergroup cg_vals ();
		option.per_instance = 1;
		CalFaliure_value : coverpoint CalFaliure.value[3:0] {
			option.weight = 16;
		}
		CalSuccess_value : coverpoint CalSuccess.value[3:0] {
			option.weight = 16;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_EMIF_STATUS");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 56, 8, "RO", 0, 56'h000000000, 1, 0, 1);
      this.CalFaliure = uvm_reg_field::type_id::create("CalFaliure",,get_full_name());
      this.CalFaliure.configure(this, 4, 4, "RO", 0, 4'h0, 1, 0, 0);
      this.CalSuccess = uvm_reg_field::type_id::create("CalSuccess",,get_full_name());
      this.CalSuccess.configure(this, 4, 0, "RO", 0, 4'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_EMIF_STATUS)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_EMIF_STATUS


class ral_reg_ac_emif_EMIF_CAPABILITY extends uvm_reg;
	uvm_reg_field Reserved;
	uvm_reg_field EMIFCap;

	covergroup cg_vals ();
		option.per_instance = 1;
		EMIFCap_value : coverpoint EMIFCap.value[3:0] { //Added by script default bin
      bins default_value = { 'hF };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_emif_EMIF_CAPABILITY");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 60, 4, "RO", 0, 60'h000000000, 1, 0, 0);
      this.EMIFCap = uvm_reg_field::type_id::create("EMIFCap",,get_full_name());
      this.EMIFCap.configure(this, 4, 0, "RO", 0, 4'hf, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_EMIF_CAPABILITY)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_EMIF_CAPABILITY


class ral_reg_ac_emif_MEM_SS_VERSION extends uvm_reg;
	uvm_reg_field MajorVersionNum;
	uvm_reg_field MinorVersionNum;
	uvm_reg_field Reserved;

	covergroup cg_vals ();
		option.per_instance = 1;
		MajorVersionNum_value : coverpoint MajorVersionNum.value {
			bins min = { 16'h0 };
			bins max = { 16'hFFFF };
			bins others = { [16'h1:16'hFFFE] };
			option.weight = 3;
		}
		MinorVersionNum_value : coverpoint MinorVersionNum.value {
			bins min = { 8'h0 };
			bins max = { 8'hFF };
			bins others = { [8'h1:8'hFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_VERSION");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MajorVersionNum = uvm_reg_field::type_id::create("MajorVersionNum",,get_full_name());
      this.MajorVersionNum.configure(this, 16, 16, "RO", 0, 16'h1, 1, 0, 1);
      this.MinorVersionNum = uvm_reg_field::type_id::create("MinorVersionNum",,get_full_name());
      this.MinorVersionNum.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_VERSION)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_VERSION


class ral_reg_ac_emif_MEM_SS_FEAT_LIST extends uvm_reg;
	uvm_reg_field Reserved_1;
	uvm_reg_field MemSSMemType;
	uvm_reg_field Reserved_0;
	uvm_reg_field UserIntfSupport;

	covergroup cg_vals ();
		option.per_instance = 1;
		MemSSMemType_value : coverpoint MemSSMemType.value {
			bins min = { 8'h0 };
			bins max = { 8'hFF };
			bins others = { [8'h1:8'hFE] };
			option.weight = 3;
		}
		UserIntfSupport_value : coverpoint UserIntfSupport.value[1:0] {
			option.weight = 4;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_FEAT_LIST");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
      this.MemSSMemType = uvm_reg_field::type_id::create("MemSSMemType",,get_full_name());
      this.MemSSMemType.configure(this, 8, 16, "RO", 0, 8'h1, 1, 0, 1);
      this.Reserved_0 = uvm_reg_field::type_id::create("Reserved_0",,get_full_name());
      this.Reserved_0.configure(this, 14, 2, "RO", 0, 14'h0, 1, 0, 0);
      this.UserIntfSupport = uvm_reg_field::type_id::create("UserIntfSupport",,get_full_name());
      this.UserIntfSupport.configure(this, 2, 0, "RO", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_FEAT_LIST)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_FEAT_LIST


class ral_reg_ac_emif_MEM_SS_FEAT_LIST_2 extends uvm_reg;
	uvm_reg_field Reserved_1;
	uvm_reg_field Reserved_0;

	function new(string name = "ac_emif_MEM_SS_FEAT_LIST_2");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 28, 4, "RO", 0, 28'h0, 1, 0, 0);
      this.Reserved_0 = uvm_reg_field::type_id::create("Reserved_0",,get_full_name());
      this.Reserved_0.configure(this, 4, 0, "RO", 0, 4'h5, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_FEAT_LIST_2)

endclass : ral_reg_ac_emif_MEM_SS_FEAT_LIST_2


class ral_reg_ac_emif_MEM_SS_IF_ATTR extends uvm_reg;
	uvm_reg_field Reserved_1;
	uvm_reg_field AXILDataWidth;
	uvm_reg_field Reserved_0;

	covergroup cg_vals ();
		option.per_instance = 1;
		AXILDataWidth_value : coverpoint AXILDataWidth.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_IF_ATTR");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 27, 5, "RO", 0, 27'h0, 1, 0, 0);
      this.AXILDataWidth = uvm_reg_field::type_id::create("AXILDataWidth",,get_full_name());
      this.AXILDataWidth.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved_0 = uvm_reg_field::type_id::create("Reserved_0",,get_full_name());
      this.Reserved_0.configure(this, 4, 0, "RO", 0, 4'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_IF_ATTR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_IF_ATTR


class ral_reg_ac_emif_MEM_SS_SCRATCH extends uvm_reg;
	rand uvm_reg_field Scratchpad;

	covergroup cg_vals ();
		option.per_instance = 1;
		Scratchpad_value : coverpoint Scratchpad.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_SCRATCH");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Scratchpad = uvm_reg_field::type_id::create("Scratchpad",,get_full_name());
      this.Scratchpad.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_SCRATCH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_SCRATCH


class ral_reg_ac_emif_MEM_SS_STATUS extends uvm_reg;
	uvm_reg_field Reserved;
	rand uvm_reg_field DecErr;
	rand uvm_reg_field SlvErr;

	covergroup cg_vals ();
		option.per_instance = 1;
		DecErr_value : coverpoint DecErr.value[0:0] {
			option.weight = 2;
		}
		SlvErr_value : coverpoint SlvErr.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_STATUS");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 30, 2, "RO", 0, 30'h0, 1, 0, 0);
      this.DecErr = uvm_reg_field::type_id::create("DecErr",,get_full_name());
      this.DecErr.configure(this, 1, 1, "W1C", 0, 1'h0, 1, 0, 0);
      this.SlvErr = uvm_reg_field::type_id::create("SlvErr",,get_full_name());
      this.SlvErr.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_STATUS)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_STATUS


class ral_reg_ac_emif_MEM_SS_CH0_ATTR extends uvm_reg;
	uvm_reg_field Reserved_1;
	uvm_reg_field AutoPrecharge;
	uvm_reg_field NumUserPools;
	uvm_reg_field NumWriteCopies;
	uvm_reg_field Reserved_0;
	uvm_reg_field ReadyLatency;

	covergroup cg_vals ();
		option.per_instance = 1;
		AutoPrecharge_value : coverpoint AutoPrecharge.value[0:0] {
			option.weight = 2;
		}
		NumUserPools_value : coverpoint NumUserPools.value[2:0] {
			option.weight = 8;
		}
		NumWriteCopies_value : coverpoint NumWriteCopies.value[3:0] {
			option.weight = 16;
		}
		ReadyLatency_value : coverpoint ReadyLatency.value[3:0] {
			option.weight = 16;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_CH0_ATTR");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 4, 28, "RO", 0, 4'h0, 1, 0, 0);
      this.AutoPrecharge = uvm_reg_field::type_id::create("AutoPrecharge",,get_full_name());
      this.AutoPrecharge.configure(this, 1, 27, "RO", 0, 1'h1, 1, 0, 0);
      this.NumUserPools = uvm_reg_field::type_id::create("NumUserPools",,get_full_name());
      this.NumUserPools.configure(this, 3, 24, "RO", 0, 3'h1, 1, 0, 0);
      this.NumWriteCopies = uvm_reg_field::type_id::create("NumWriteCopies",,get_full_name());
      this.NumWriteCopies.configure(this, 4, 20, "RO", 0, 4'h1, 1, 0, 0);
      this.Reserved_0 = uvm_reg_field::type_id::create("Reserved_0",,get_full_name());
      this.Reserved_0.configure(this, 16, 4, "RO", 0, 16'h0000, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 0, "RO", 0, 4'h3, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_CH0_ATTR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_CH0_ATTR


class ral_reg_ac_emif_MEM_SS_CH1_ATTR extends uvm_reg;
	uvm_reg_field Reserved_1;
	uvm_reg_field AutoPrecharge;
	uvm_reg_field NumUserPools;
	uvm_reg_field NumWriteCopies;
	uvm_reg_field Reserved_0;
	uvm_reg_field ReadyLatency;

	covergroup cg_vals ();
		option.per_instance = 1;
		AutoPrecharge_value : coverpoint AutoPrecharge.value[0:0] {
			option.weight = 2;
		}
		NumUserPools_value : coverpoint NumUserPools.value[2:0] {
			option.weight = 8;
		}
		NumWriteCopies_value : coverpoint NumWriteCopies.value[3:0] {
			option.weight = 16;
		}
		ReadyLatency_value : coverpoint ReadyLatency.value[3:0] {
			option.weight = 16;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_CH1_ATTR");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 4, 28, "RO", 0, 4'h0, 1, 0, 0);
      this.AutoPrecharge = uvm_reg_field::type_id::create("AutoPrecharge",,get_full_name());
      this.AutoPrecharge.configure(this, 1, 27, "RO", 0, 1'h1, 1, 0, 0);
      this.NumUserPools = uvm_reg_field::type_id::create("NumUserPools",,get_full_name());
      this.NumUserPools.configure(this, 3, 24, "RO", 0, 3'h1, 1, 0, 0);
      this.NumWriteCopies = uvm_reg_field::type_id::create("NumWriteCopies",,get_full_name());
      this.NumWriteCopies.configure(this, 4, 20, "RO", 0, 4'h1, 1, 0, 0);
      this.Reserved_0 = uvm_reg_field::type_id::create("Reserved_0",,get_full_name());
      this.Reserved_0.configure(this, 16, 4, "RO", 0, 16'h0000, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 0, "RO", 0, 4'h3, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_CH1_ATTR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_CH1_ATTR


class ral_reg_ac_emif_MEM_SS_CH2_ATTR extends uvm_reg;
	uvm_reg_field Reserved_1;
	uvm_reg_field AutoPrecharge;
	uvm_reg_field NumUserPools;
	uvm_reg_field NumWriteCopies;
	uvm_reg_field Reserved_0;
	uvm_reg_field ReadyLatency;

	covergroup cg_vals ();
		option.per_instance = 1;
		AutoPrecharge_value : coverpoint AutoPrecharge.value[0:0] {
			option.weight = 2;
		}
		NumUserPools_value : coverpoint NumUserPools.value[2:0] {
			option.weight = 8;
		}
		NumWriteCopies_value : coverpoint NumWriteCopies.value[3:0] {
			option.weight = 16;
		}
		ReadyLatency_value : coverpoint ReadyLatency.value[3:0] {
			option.weight = 16;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_CH2_ATTR");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 4, 28, "RO", 0, 4'h0, 1, 0, 0);
      this.AutoPrecharge = uvm_reg_field::type_id::create("AutoPrecharge",,get_full_name());
      this.AutoPrecharge.configure(this, 1, 27, "RO", 0, 1'h1, 1, 0, 0);
      this.NumUserPools = uvm_reg_field::type_id::create("NumUserPools",,get_full_name());
      this.NumUserPools.configure(this, 3, 24, "RO", 0, 3'h1, 1, 0, 0);
      this.NumWriteCopies = uvm_reg_field::type_id::create("NumWriteCopies",,get_full_name());
      this.NumWriteCopies.configure(this, 4, 20, "RO", 0, 4'h1, 1, 0, 0);
      this.Reserved_0 = uvm_reg_field::type_id::create("Reserved_0",,get_full_name());
      this.Reserved_0.configure(this, 16, 4, "RO", 0, 16'h0000, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 0, "RO", 0, 4'h3, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_CH2_ATTR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_CH2_ATTR


class ral_reg_ac_emif_MEM_SS_CH3_ATTR extends uvm_reg;
	uvm_reg_field Reserved_1;
	uvm_reg_field AutoPrecharge;
	uvm_reg_field NumUserPools;
	uvm_reg_field NumWriteCopies;
	uvm_reg_field Reserved_0;
	uvm_reg_field ReadyLatency;

	covergroup cg_vals ();
		option.per_instance = 1;
		AutoPrecharge_value : coverpoint AutoPrecharge.value[0:0] {
			option.weight = 2;
		}
		NumUserPools_value : coverpoint NumUserPools.value[2:0] {
			option.weight = 8;
		}
		NumWriteCopies_value : coverpoint NumWriteCopies.value[3:0] {
			option.weight = 16;
		}
		ReadyLatency_value : coverpoint ReadyLatency.value[3:0] {
			option.weight = 16;
		}
	endgroup : cg_vals

	function new(string name = "ac_emif_MEM_SS_CH3_ATTR");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 4, 28, "RO", 0, 4'h0, 1, 0, 0);
      this.AutoPrecharge = uvm_reg_field::type_id::create("AutoPrecharge",,get_full_name());
      this.AutoPrecharge.configure(this, 1, 27, "RO", 0, 1'h1, 1, 0, 0);
      this.NumUserPools = uvm_reg_field::type_id::create("NumUserPools",,get_full_name());
      this.NumUserPools.configure(this, 3, 24, "RO", 0, 3'h1, 1, 0, 0);
      this.NumWriteCopies = uvm_reg_field::type_id::create("NumWriteCopies",,get_full_name());
      this.NumWriteCopies.configure(this, 4, 20, "RO", 0, 4'h1, 1, 0, 0);
      this.Reserved_0 = uvm_reg_field::type_id::create("Reserved_0",,get_full_name());
      this.Reserved_0.configure(this, 16, 4, "RO", 0, 16'h0000, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 0, "RO", 0, 4'h3, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_emif_MEM_SS_CH3_ATTR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_emif_MEM_SS_CH3_ATTR


class ral_block_ac_emif extends uvm_reg_block;
	rand ral_reg_ac_emif_EMIF_DFH EMIF_DFH;
	rand ral_reg_ac_emif_EMIF_STATUS EMIF_STATUS;
	rand ral_reg_ac_emif_EMIF_CAPABILITY EMIF_CAPABILITY;
	rand ral_reg_ac_emif_MEM_SS_VERSION MEM_SS_VERSION;
	rand ral_reg_ac_emif_MEM_SS_FEAT_LIST MEM_SS_FEAT_LIST;
	rand ral_reg_ac_emif_MEM_SS_FEAT_LIST_2 MEM_SS_FEAT_LIST_2;
	rand ral_reg_ac_emif_MEM_SS_IF_ATTR MEM_SS_IF_ATTR;
	rand ral_reg_ac_emif_MEM_SS_SCRATCH MEM_SS_SCRATCH;
	rand ral_reg_ac_emif_MEM_SS_STATUS MEM_SS_STATUS;
	rand ral_reg_ac_emif_MEM_SS_CH0_ATTR MEM_SS_CH0_ATTR;
	rand ral_reg_ac_emif_MEM_SS_CH1_ATTR MEM_SS_CH1_ATTR;
	rand ral_reg_ac_emif_MEM_SS_CH2_ATTR MEM_SS_CH2_ATTR;
	rand ral_reg_ac_emif_MEM_SS_CH3_ATTR MEM_SS_CH3_ATTR;
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
	uvm_reg_field MEM_SS_VERSION_MajorVersionNum;
	uvm_reg_field MajorVersionNum;
	uvm_reg_field MEM_SS_VERSION_MinorVersionNum;
	uvm_reg_field MinorVersionNum;
	uvm_reg_field MEM_SS_VERSION_Reserved;
	uvm_reg_field MEM_SS_FEAT_LIST_Reserved_1;
	uvm_reg_field MEM_SS_FEAT_LIST_MemSSMemType;
	uvm_reg_field MemSSMemType;
	uvm_reg_field MEM_SS_FEAT_LIST_Reserved_0;
	uvm_reg_field MEM_SS_FEAT_LIST_UserIntfSupport;
	uvm_reg_field UserIntfSupport;
	uvm_reg_field MEM_SS_FEAT_LIST_2_Reserved_1;
	uvm_reg_field MEM_SS_FEAT_LIST_2_Reserved_0;
	uvm_reg_field MEM_SS_IF_ATTR_Reserved_1;
	uvm_reg_field MEM_SS_IF_ATTR_AXILDataWidth;
	uvm_reg_field AXILDataWidth;
	uvm_reg_field MEM_SS_IF_ATTR_Reserved_0;
	rand uvm_reg_field MEM_SS_SCRATCH_Scratchpad;
	rand uvm_reg_field Scratchpad;
	uvm_reg_field MEM_SS_STATUS_Reserved;
	rand uvm_reg_field MEM_SS_STATUS_DecErr;
	rand uvm_reg_field DecErr;
	rand uvm_reg_field MEM_SS_STATUS_SlvErr;
	rand uvm_reg_field SlvErr;
	uvm_reg_field MEM_SS_CH0_ATTR_Reserved_1;
	uvm_reg_field MEM_SS_CH0_ATTR_AutoPrecharge;
	uvm_reg_field MEM_SS_CH0_ATTR_NumUserPools;
	uvm_reg_field MEM_SS_CH0_ATTR_NumWriteCopies;
	uvm_reg_field MEM_SS_CH0_ATTR_Reserved_0;
	uvm_reg_field MEM_SS_CH0_ATTR_ReadyLatency;
	uvm_reg_field MEM_SS_CH1_ATTR_Reserved_1;
	uvm_reg_field MEM_SS_CH1_ATTR_AutoPrecharge;
	uvm_reg_field MEM_SS_CH1_ATTR_NumUserPools;
	uvm_reg_field MEM_SS_CH1_ATTR_NumWriteCopies;
	uvm_reg_field MEM_SS_CH1_ATTR_Reserved_0;
	uvm_reg_field MEM_SS_CH1_ATTR_ReadyLatency;
	uvm_reg_field MEM_SS_CH2_ATTR_Reserved_1;
	uvm_reg_field MEM_SS_CH2_ATTR_AutoPrecharge;
	uvm_reg_field MEM_SS_CH2_ATTR_NumUserPools;
	uvm_reg_field MEM_SS_CH2_ATTR_NumWriteCopies;
	uvm_reg_field MEM_SS_CH2_ATTR_Reserved_0;
	uvm_reg_field MEM_SS_CH2_ATTR_ReadyLatency;
	uvm_reg_field MEM_SS_CH3_ATTR_Reserved_1;
	uvm_reg_field MEM_SS_CH3_ATTR_AutoPrecharge;
	uvm_reg_field MEM_SS_CH3_ATTR_NumUserPools;
	uvm_reg_field MEM_SS_CH3_ATTR_NumWriteCopies;
	uvm_reg_field MEM_SS_CH3_ATTR_Reserved_0;
	uvm_reg_field MEM_SS_CH3_ATTR_ReadyLatency;

	function new(string name = "ac_emif");
		super.new(name, build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.EMIF_DFH = ral_reg_ac_emif_EMIF_DFH::type_id::create("EMIF_DFH",,get_full_name());
      this.EMIF_DFH.configure(this, null, "");
      this.EMIF_DFH.build();
      this.default_map.add_reg(this.EMIF_DFH, `UVM_REG_ADDR_WIDTH'h0, "RO", 0);
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
      this.EMIF_STATUS = ral_reg_ac_emif_EMIF_STATUS::type_id::create("EMIF_STATUS",,get_full_name());
      this.EMIF_STATUS.configure(this, null, "");
      this.EMIF_STATUS.build();
      this.default_map.add_reg(this.EMIF_STATUS, `UVM_REG_ADDR_WIDTH'h8, "RO", 0);
		this.EMIF_STATUS_Reserved = this.EMIF_STATUS.Reserved;
		this.EMIF_STATUS_CalFaliure = this.EMIF_STATUS.CalFaliure;
		this.CalFaliure = this.EMIF_STATUS.CalFaliure;
		this.EMIF_STATUS_CalSuccess = this.EMIF_STATUS.CalSuccess;
		this.CalSuccess = this.EMIF_STATUS.CalSuccess;
      this.EMIF_CAPABILITY = ral_reg_ac_emif_EMIF_CAPABILITY::type_id::create("EMIF_CAPABILITY",,get_full_name());
      this.EMIF_CAPABILITY.configure(this, null, "");
      this.EMIF_CAPABILITY.build();
      this.default_map.add_reg(this.EMIF_CAPABILITY, `UVM_REG_ADDR_WIDTH'h10, "RO", 0);
		this.EMIF_CAPABILITY_Reserved = this.EMIF_CAPABILITY.Reserved;
		this.EMIF_CAPABILITY_EMIFCap = this.EMIF_CAPABILITY.EMIFCap;
		this.EMIFCap = this.EMIF_CAPABILITY.EMIFCap;
      this.MEM_SS_VERSION = ral_reg_ac_emif_MEM_SS_VERSION::type_id::create("MEM_SS_VERSION",,get_full_name());
      this.MEM_SS_VERSION.configure(this, null, "");
      this.MEM_SS_VERSION.build();
      this.default_map.add_reg(this.MEM_SS_VERSION, `UVM_REG_ADDR_WIDTH'h860, "RO", 0);
		this.MEM_SS_VERSION_MajorVersionNum = this.MEM_SS_VERSION.MajorVersionNum;
		this.MajorVersionNum = this.MEM_SS_VERSION.MajorVersionNum;
		this.MEM_SS_VERSION_MinorVersionNum = this.MEM_SS_VERSION.MinorVersionNum;
		this.MinorVersionNum = this.MEM_SS_VERSION.MinorVersionNum;
		this.MEM_SS_VERSION_Reserved = this.MEM_SS_VERSION.Reserved;
      this.MEM_SS_FEAT_LIST = ral_reg_ac_emif_MEM_SS_FEAT_LIST::type_id::create("MEM_SS_FEAT_LIST",,get_full_name());
      this.MEM_SS_FEAT_LIST.configure(this, null, "");
      this.MEM_SS_FEAT_LIST.build();
      this.default_map.add_reg(this.MEM_SS_FEAT_LIST, `UVM_REG_ADDR_WIDTH'h864, "RO", 0);
		this.MEM_SS_FEAT_LIST_Reserved_1 = this.MEM_SS_FEAT_LIST.Reserved_1;
		this.MEM_SS_FEAT_LIST_MemSSMemType = this.MEM_SS_FEAT_LIST.MemSSMemType;
		this.MemSSMemType = this.MEM_SS_FEAT_LIST.MemSSMemType;
		this.MEM_SS_FEAT_LIST_Reserved_0 = this.MEM_SS_FEAT_LIST.Reserved_0;
		this.MEM_SS_FEAT_LIST_UserIntfSupport = this.MEM_SS_FEAT_LIST.UserIntfSupport;
		this.UserIntfSupport = this.MEM_SS_FEAT_LIST.UserIntfSupport;
      this.MEM_SS_FEAT_LIST_2 = ral_reg_ac_emif_MEM_SS_FEAT_LIST_2::type_id::create("MEM_SS_FEAT_LIST_2",,get_full_name());
      this.MEM_SS_FEAT_LIST_2.configure(this, null, "");
      this.MEM_SS_FEAT_LIST_2.build();
      this.default_map.add_reg(this.MEM_SS_FEAT_LIST_2, `UVM_REG_ADDR_WIDTH'h868, "RO", 0);
		this.MEM_SS_FEAT_LIST_2_Reserved_1 = this.MEM_SS_FEAT_LIST_2.Reserved_1;
		this.MEM_SS_FEAT_LIST_2_Reserved_0 = this.MEM_SS_FEAT_LIST_2.Reserved_0;
      this.MEM_SS_IF_ATTR = ral_reg_ac_emif_MEM_SS_IF_ATTR::type_id::create("MEM_SS_IF_ATTR",,get_full_name());
      this.MEM_SS_IF_ATTR.configure(this, null, "");
      this.MEM_SS_IF_ATTR.build();
      this.default_map.add_reg(this.MEM_SS_IF_ATTR, `UVM_REG_ADDR_WIDTH'h870, "RO", 0);
		this.MEM_SS_IF_ATTR_Reserved_1 = this.MEM_SS_IF_ATTR.Reserved_1;
		this.MEM_SS_IF_ATTR_AXILDataWidth = this.MEM_SS_IF_ATTR.AXILDataWidth;
		this.AXILDataWidth = this.MEM_SS_IF_ATTR.AXILDataWidth;
		this.MEM_SS_IF_ATTR_Reserved_0 = this.MEM_SS_IF_ATTR.Reserved_0;
      this.MEM_SS_SCRATCH = ral_reg_ac_emif_MEM_SS_SCRATCH::type_id::create("MEM_SS_SCRATCH",,get_full_name());
      this.MEM_SS_SCRATCH.configure(this, null, "");
      this.MEM_SS_SCRATCH.build();
      this.default_map.add_reg(this.MEM_SS_SCRATCH, `UVM_REG_ADDR_WIDTH'h880, "RW", 0);
		this.MEM_SS_SCRATCH_Scratchpad = this.MEM_SS_SCRATCH.Scratchpad;
		this.Scratchpad = this.MEM_SS_SCRATCH.Scratchpad;
      this.MEM_SS_STATUS = ral_reg_ac_emif_MEM_SS_STATUS::type_id::create("MEM_SS_STATUS",,get_full_name());
      this.MEM_SS_STATUS.configure(this, null, "");
      this.MEM_SS_STATUS.build();
      this.default_map.add_reg(this.MEM_SS_STATUS, `UVM_REG_ADDR_WIDTH'h8B0, "RW", 0);
		this.MEM_SS_STATUS_Reserved = this.MEM_SS_STATUS.Reserved;
		this.MEM_SS_STATUS_DecErr = this.MEM_SS_STATUS.DecErr;
		this.DecErr = this.MEM_SS_STATUS.DecErr;
		this.MEM_SS_STATUS_SlvErr = this.MEM_SS_STATUS.SlvErr;
		this.SlvErr = this.MEM_SS_STATUS.SlvErr;
      this.MEM_SS_CH0_ATTR = ral_reg_ac_emif_MEM_SS_CH0_ATTR::type_id::create("MEM_SS_CH0_ATTR",,get_full_name());
      this.MEM_SS_CH0_ATTR.configure(this, null, "");
      this.MEM_SS_CH0_ATTR.build();
      this.default_map.add_reg(this.MEM_SS_CH0_ATTR, `UVM_REG_ADDR_WIDTH'h900, "RO", 0);
		this.MEM_SS_CH0_ATTR_Reserved_1 = this.MEM_SS_CH0_ATTR.Reserved_1;
		this.MEM_SS_CH0_ATTR_AutoPrecharge = this.MEM_SS_CH0_ATTR.AutoPrecharge;
		this.MEM_SS_CH0_ATTR_NumUserPools = this.MEM_SS_CH0_ATTR.NumUserPools;
		this.MEM_SS_CH0_ATTR_NumWriteCopies = this.MEM_SS_CH0_ATTR.NumWriteCopies;
		this.MEM_SS_CH0_ATTR_Reserved_0 = this.MEM_SS_CH0_ATTR.Reserved_0;
		this.MEM_SS_CH0_ATTR_ReadyLatency = this.MEM_SS_CH0_ATTR.ReadyLatency;
      this.MEM_SS_CH1_ATTR = ral_reg_ac_emif_MEM_SS_CH1_ATTR::type_id::create("MEM_SS_CH1_ATTR",,get_full_name());
      this.MEM_SS_CH1_ATTR.configure(this, null, "");
      this.MEM_SS_CH1_ATTR.build();
      this.default_map.add_reg(this.MEM_SS_CH1_ATTR, `UVM_REG_ADDR_WIDTH'h908, "RO", 0);
		this.MEM_SS_CH1_ATTR_Reserved_1 = this.MEM_SS_CH1_ATTR.Reserved_1;
		this.MEM_SS_CH1_ATTR_AutoPrecharge = this.MEM_SS_CH1_ATTR.AutoPrecharge;
		this.MEM_SS_CH1_ATTR_NumUserPools = this.MEM_SS_CH1_ATTR.NumUserPools;
		this.MEM_SS_CH1_ATTR_NumWriteCopies = this.MEM_SS_CH1_ATTR.NumWriteCopies;
		this.MEM_SS_CH1_ATTR_Reserved_0 = this.MEM_SS_CH1_ATTR.Reserved_0;
		this.MEM_SS_CH1_ATTR_ReadyLatency = this.MEM_SS_CH1_ATTR.ReadyLatency;
      this.MEM_SS_CH2_ATTR = ral_reg_ac_emif_MEM_SS_CH2_ATTR::type_id::create("MEM_SS_CH2_ATTR",,get_full_name());
      this.MEM_SS_CH2_ATTR.configure(this, null, "");
      this.MEM_SS_CH2_ATTR.build();
      this.default_map.add_reg(this.MEM_SS_CH2_ATTR, `UVM_REG_ADDR_WIDTH'h910, "RO", 0);
		this.MEM_SS_CH2_ATTR_Reserved_1 = this.MEM_SS_CH2_ATTR.Reserved_1;
		this.MEM_SS_CH2_ATTR_AutoPrecharge = this.MEM_SS_CH2_ATTR.AutoPrecharge;
		this.MEM_SS_CH2_ATTR_NumUserPools = this.MEM_SS_CH2_ATTR.NumUserPools;
		this.MEM_SS_CH2_ATTR_NumWriteCopies = this.MEM_SS_CH2_ATTR.NumWriteCopies;
		this.MEM_SS_CH2_ATTR_Reserved_0 = this.MEM_SS_CH2_ATTR.Reserved_0;
		this.MEM_SS_CH2_ATTR_ReadyLatency = this.MEM_SS_CH2_ATTR.ReadyLatency;
      this.MEM_SS_CH3_ATTR = ral_reg_ac_emif_MEM_SS_CH3_ATTR::type_id::create("MEM_SS_CH3_ATTR",,get_full_name());
      this.MEM_SS_CH3_ATTR.configure(this, null, "");
      this.MEM_SS_CH3_ATTR.build();
      this.default_map.add_reg(this.MEM_SS_CH3_ATTR, `UVM_REG_ADDR_WIDTH'h918, "RO", 0);
		this.MEM_SS_CH3_ATTR_Reserved_1 = this.MEM_SS_CH3_ATTR.Reserved_1;
		this.MEM_SS_CH3_ATTR_AutoPrecharge = this.MEM_SS_CH3_ATTR.AutoPrecharge;
		this.MEM_SS_CH3_ATTR_NumUserPools = this.MEM_SS_CH3_ATTR.NumUserPools;
		this.MEM_SS_CH3_ATTR_NumWriteCopies = this.MEM_SS_CH3_ATTR.NumWriteCopies;
		this.MEM_SS_CH3_ATTR_Reserved_0 = this.MEM_SS_CH3_ATTR.Reserved_0;
		this.MEM_SS_CH3_ATTR_ReadyLatency = this.MEM_SS_CH3_ATTR.ReadyLatency;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_emif)

endclass : ral_block_ac_emif



`endif
