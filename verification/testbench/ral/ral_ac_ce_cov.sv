// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_CE
`define RAL_AC_CE

import uvm_pkg::*;

class ral_reg_ac_ce_CE_FEATURE_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EndOfList;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	covergroup cg_vals ();
		option.per_instance = 1;
		FeatureType_value : coverpoint FeatureType.value[3:0] { //Added by script default bin
      bins default_value = { 'h1 };
      option.weight = 1;
    }
		EndOfList_value : coverpoint EndOfList.value[0:0] { //Added by script default bin
      bins default_value = { 'h1 };
      option.weight = 1;
    }
		NextDfhByteOffset_value : coverpoint NextDfhByteOffset.value { //Added by script default bin
      bins default_value = { 'h1000 };
      option.weight = 1;
    }
		FeatureRev_value : coverpoint FeatureRev.value[3:0] { //Added by script default bin
      bins default_value = { 'h1 };
      option.weight = 1;
    }
		FeatureID_value : coverpoint FeatureID.value { //Added by script default bin
      bins default_value = { 'h1 };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_ce_CE_FEATURE_DFH");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h1, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 41, "WO", 0, 1'h0, 1, 0, 0);
      this.EndOfList = uvm_reg_field::type_id::create("EndOfList",,get_full_name());
      this.EndOfList.configure(this, 1, 40, "RO", 0, 1'h1, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_DFH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CE_FEATURE_DFH


class ral_reg_ac_ce_CE_FEATURE_GUID_L extends uvm_reg;
	uvm_reg_field CE_ID_L;

	covergroup cg_vals ();
		option.per_instance = 1;
		CE_ID_L_value : coverpoint CE_ID_L.value { //Added by script default bin
      bins default_value = { 'hbd4257dc93ea7f91 };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_ce_CE_FEATURE_GUID_L");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.CE_ID_L = uvm_reg_field::type_id::create("CE_ID_L",,get_full_name());
      this.CE_ID_L.configure(this, 64, 0, "RO", 0, 64'hbd4257dc93ea7f91, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_GUID_L)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CE_FEATURE_GUID_L


class ral_reg_ac_ce_CE_FEATURE_GUID_H extends uvm_reg;
	uvm_reg_field CE_ID_H;

	covergroup cg_vals ();
		option.per_instance = 1;
		CE_ID_H_value : coverpoint CE_ID_H.value { //Added by script default bin
      bins default_value = { 'h44bfc10db42a44e5 };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_ce_CE_FEATURE_GUID_H");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.CE_ID_H = uvm_reg_field::type_id::create("CE_ID_H",,get_full_name());
      this.CE_ID_H.configure(this, 64, 0, "RO", 0, 64'h44bfc10db42a44e5, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_GUID_H)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CE_FEATURE_GUID_H


class ral_reg_ac_ce_CE_FEATURE_CSR_ADDR extends uvm_reg;
	uvm_reg_field CSR_REL;
	uvm_reg_field CSR_ADDR;

	covergroup cg_vals ();
		option.per_instance = 1;
		CSR_REL_value : coverpoint CSR_REL.value[0:0] { //Added by script default bin
      bins default_value = { 'h0 };
      option.weight = 1;
    }
		CSR_ADDR_value : coverpoint CSR_ADDR.value { //Added by script default bin
      bins default_value = { 'h100 };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_ce_CE_FEATURE_CSR_ADDR");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.CSR_REL = uvm_reg_field::type_id::create("CSR_REL",,get_full_name());
      this.CSR_REL.configure(this, 1, 63, "RO", 0, 1'h0, 1, 0, 0);
      this.CSR_ADDR = uvm_reg_field::type_id::create("CSR_ADDR",,get_full_name());
      this.CSR_ADDR.configure(this, 63, 0, "RO", 0, 63'h000000100, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_CSR_ADDR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CE_FEATURE_CSR_ADDR


class ral_reg_ac_ce_CE_FEATURE_CSR_SIZE_GROUP extends uvm_reg;
	uvm_reg_field CSR_SIZE;
	uvm_reg_field HAS_PARAMS;
	uvm_reg_field GROUPING_ID;

	covergroup cg_vals ();
		option.per_instance = 1;
		CSR_SIZE_value : coverpoint CSR_SIZE.value { //Added by script default bin
      bins default_value = { 'h50 };
      option.weight = 1;
    }
		HAS_PARAMS_value : coverpoint HAS_PARAMS.value[0:0] { //Added by script default bin
      bins default_value = { 'h0 };
      option.weight = 1;
    }
		GROUPING_ID_value : coverpoint GROUPING_ID.value { //Added by script default bin
      bins default_value = { 'h0 };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_ce_CE_FEATURE_CSR_SIZE_GROUP");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.CSR_SIZE = uvm_reg_field::type_id::create("CSR_SIZE",,get_full_name());
      this.CSR_SIZE.configure(this, 32, 32, "RO", 0, 32'h50, 1, 0, 1);
      this.HAS_PARAMS = uvm_reg_field::type_id::create("HAS_PARAMS",,get_full_name());
      this.HAS_PARAMS.configure(this, 1, 31, "RO", 0, 1'h0, 1, 0, 0);
      this.GROUPING_ID = uvm_reg_field::type_id::create("GROUPING_ID",,get_full_name());
      this.GROUPING_ID.configure(this, 31, 0, "RO", 0, 31'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_CSR_SIZE_GROUP)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CE_FEATURE_CSR_SIZE_GROUP


class ral_reg_ac_ce_CSR_HOST_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field HOST_SCRATCHPAD;

	covergroup cg_vals ();
		option.per_instance = 1;
		HOST_SCRATCHPAD_value : coverpoint HOST_SCRATCHPAD.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_HOST_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.HOST_SCRATCHPAD = uvm_reg_field::type_id::create("HOST_SCRATCHPAD",,get_full_name());
      this.HOST_SCRATCHPAD.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HOST_SCRATCHPAD)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_HOST_SCRATCHPAD


class ral_reg_ac_ce_CSR_CE2HOST_DATA_REQ_LIMIT extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field DATA_REQ_LIMIT;

	covergroup cg_vals ();
		option.per_instance = 1;
		DATA_REQ_LIMIT_value : coverpoint DATA_REQ_LIMIT.value[1:0] {
			option.weight = 4;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_CE2HOST_DATA_REQ_LIMIT");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 2, "WO", 0, 1'h000000000, 1, 0, 0);
      this.DATA_REQ_LIMIT = uvm_reg_field::type_id::create("DATA_REQ_LIMIT",,get_full_name());
      this.DATA_REQ_LIMIT.configure(this, 2, 0, "RW", 0, 2'h3, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_CE2HOST_DATA_REQ_LIMIT)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_CE2HOST_DATA_REQ_LIMIT


class ral_reg_ac_ce_CSR_IMG_SRC_ADDR extends uvm_reg;
	rand uvm_reg_field IMG_SRC_ADDR;

	covergroup cg_vals ();
		option.per_instance = 1;
		IMG_SRC_ADDR_value : coverpoint IMG_SRC_ADDR.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_IMG_SRC_ADDR");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.IMG_SRC_ADDR = uvm_reg_field::type_id::create("IMG_SRC_ADDR",,get_full_name());
      this.IMG_SRC_ADDR.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_IMG_SRC_ADDR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_IMG_SRC_ADDR


class ral_reg_ac_ce_CSR_IMG_DST_ADDR extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field IMG_DST_ADDR;

	covergroup cg_vals ();
		option.per_instance = 1;
		IMG_DST_ADDR_value : coverpoint IMG_DST_ADDR.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_IMG_DST_ADDR");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 32, "WO", 0, 1'h0, 1, 0, 1);
      this.IMG_DST_ADDR = uvm_reg_field::type_id::create("IMG_DST_ADDR",,get_full_name());
      this.IMG_DST_ADDR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_IMG_DST_ADDR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_IMG_DST_ADDR


class ral_reg_ac_ce_CSR_IMG_SIZE extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field IMG_SIZE;

	covergroup cg_vals ();
		option.per_instance = 1;
		IMG_SIZE_value : coverpoint IMG_SIZE.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_IMG_SIZE");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 32, "WO", 0, 1'h0, 1, 0, 1);
      this.IMG_SIZE = uvm_reg_field::type_id::create("IMG_SIZE",,get_full_name());
      this.IMG_SIZE.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_IMG_SIZE)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_IMG_SIZE


class ral_reg_ac_ce_CSR_HOST2CE_MRD_START extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field MRD_START;

	covergroup cg_vals ();
		option.per_instance = 1;
		MRD_START_value : coverpoint MRD_START.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_HOST2CE_MRD_START");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 1, "WO", 0, 1'h000000000, 1, 0, 0);
      this.MRD_START = uvm_reg_field::type_id::create("MRD_START",,get_full_name());
      this.MRD_START.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HOST2CE_MRD_START)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_HOST2CE_MRD_START


class ral_reg_ac_ce_CSR_CE2HOST_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field CE_IMG_ADDR_STS;
	uvm_reg_field CE_FIFO2_STS;
	uvm_reg_field CE_FIFO1_STS;
	uvm_reg_field CE_AXIST_CPL_STS;
	uvm_reg_field CE_ACELITE_BRESP_STS;
	uvm_reg_field CE_DMA_STS;

	covergroup cg_vals ();
		option.per_instance = 1;
		CE_IMG_ADDR_STS_value : coverpoint CE_IMG_ADDR_STS.value[1:0] {
			option.weight = 4;
		}
		CE_FIFO2_STS_value : coverpoint CE_FIFO2_STS.value[1:0] {
			option.weight = 4;
		}
		CE_FIFO1_STS_value : coverpoint CE_FIFO1_STS.value[1:0] {
			option.weight = 4;
		}
		CE_AXIST_CPL_STS_value : coverpoint CE_AXIST_CPL_STS.value[2:0] {
			option.weight = 8;
		}
		CE_ACELITE_BRESP_STS_value : coverpoint CE_ACELITE_BRESP_STS.value[1:0] {
			option.weight = 4;
		}
		CE_DMA_STS_value : coverpoint CE_DMA_STS.value[1:0] {
			option.weight = 4;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_CE2HOST_STATUS");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 13, "WO", 0, 1'h000000000, 1, 0, 0);
      this.CE_IMG_ADDR_STS = uvm_reg_field::type_id::create("CE_IMG_ADDR_STS",,get_full_name());
      this.CE_IMG_ADDR_STS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.CE_FIFO2_STS = uvm_reg_field::type_id::create("CE_FIFO2_STS",,get_full_name());
      this.CE_FIFO2_STS.configure(this, 2, 9, "RO", 0, 2'h0, 1, 0, 0);
      this.CE_FIFO1_STS = uvm_reg_field::type_id::create("CE_FIFO1_STS",,get_full_name());
      this.CE_FIFO1_STS.configure(this, 2, 7, "RO", 0, 2'h0, 1, 0, 0);
      this.CE_AXIST_CPL_STS = uvm_reg_field::type_id::create("CE_AXIST_CPL_STS",,get_full_name());
      this.CE_AXIST_CPL_STS.configure(this, 3, 4, "RO", 0, 3'h0, 1, 0, 0);
      this.CE_ACELITE_BRESP_STS = uvm_reg_field::type_id::create("CE_ACELITE_BRESP_STS",,get_full_name());
      this.CE_ACELITE_BRESP_STS.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.CE_DMA_STS = uvm_reg_field::type_id::create("CE_DMA_STS",,get_full_name());
      this.CE_DMA_STS.configure(this, 2, 0, "RO", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_CE2HOST_STATUS)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_CE2HOST_STATUS


class ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field HOST2HPS_IMG_XFR;

	covergroup cg_vals ();
		option.per_instance = 1;
		HOST2HPS_IMG_XFR_value : coverpoint HOST2HPS_IMG_XFR.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_HOST2HPS_IMG_XFR");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 1, "WO", 0, 1'h000000000, 1, 0, 0);
      this.HOST2HPS_IMG_XFR = uvm_reg_field::type_id::create("HOST2HPS_IMG_XFR",,get_full_name());
      this.HOST2HPS_IMG_XFR.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR


class ral_reg_ac_ce_CSR_HPS2HOST_RSP_SHDW extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field HPS_RDY_SHDW;
	uvm_reg_field KERNEL_VFY_SHDW;
	uvm_reg_field SSBL_VFY_SHDW;

	covergroup cg_vals ();
		option.per_instance = 1;
		HPS_RDY_SHDW_value : coverpoint HPS_RDY_SHDW.value[0:0] {
			option.weight = 2;
		}
		KERNEL_VFY_SHDW_value : coverpoint KERNEL_VFY_SHDW.value[1:0] {
			option.weight = 4;
		}
		SSBL_VFY_SHDW_value : coverpoint SSBL_VFY_SHDW.value[1:0] {
			option.weight = 4;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_HPS2HOST_RSP_SHDW");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 5, "WO", 0, 1'h000000000, 1, 0, 0);
      this.HPS_RDY_SHDW = uvm_reg_field::type_id::create("HPS_RDY_SHDW",,get_full_name());
      this.HPS_RDY_SHDW.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.KERNEL_VFY_SHDW = uvm_reg_field::type_id::create("KERNEL_VFY_SHDW",,get_full_name());
      this.KERNEL_VFY_SHDW.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.SSBL_VFY_SHDW = uvm_reg_field::type_id::create("SSBL_VFY_SHDW",,get_full_name());
      this.SSBL_VFY_SHDW.configure(this, 2, 0, "RO", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HPS2HOST_RSP_SHDW)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_HPS2HOST_RSP_SHDW


class ral_reg_ac_ce_CSR_CE_SFTRST extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field CE_SFTRST;

	covergroup cg_vals ();
		option.per_instance = 1;
		CE_SFTRST_value : coverpoint CE_SFTRST.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_CE_SFTRST");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 1, "WO", 0, 1'h000000000, 1, 0, 0);
      this.CE_SFTRST = uvm_reg_field::type_id::create("CE_SFTRST",,get_full_name());
      this.CE_SFTRST.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_CE_SFTRST)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_CE_SFTRST


class ral_reg_ac_ce_CSR_HPS_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field HPS_SCRATCHPAD;

	covergroup cg_vals ();
		option.per_instance = 1;
		HPS_SCRATCHPAD_value : coverpoint HPS_SCRATCHPAD.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_HPS_SCRATCHPAD");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.HPS_SCRATCHPAD = uvm_reg_field::type_id::create("HPS_SCRATCHPAD",,get_full_name());
      this.HPS_SCRATCHPAD.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HPS_SCRATCHPAD)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_HPS_SCRATCHPAD


class ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR_SHDW extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field HOST2HPS_IMG_XFR_SHDW;

	covergroup cg_vals ();
		option.per_instance = 1;
		HOST2HPS_IMG_XFR_SHDW_value : coverpoint HOST2HPS_IMG_XFR_SHDW.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_HOST2HPS_IMG_XFR_SHDW");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 1, "WO", 0, 1'h0, 1, 0, 0);
      this.HOST2HPS_IMG_XFR_SHDW = uvm_reg_field::type_id::create("HOST2HPS_IMG_XFR_SHDW",,get_full_name());
      this.HOST2HPS_IMG_XFR_SHDW.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR_SHDW)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR_SHDW


class ral_reg_ac_ce_CSR_HPS2HOST_RSP extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field HPS_RDY;
	rand uvm_reg_field KERNEL_VFY;
	rand uvm_reg_field SSBL_VFY;

	covergroup cg_vals ();
		option.per_instance = 1;
		HPS_RDY_value : coverpoint HPS_RDY.value[0:0] {
			option.weight = 2;
		}
		KERNEL_VFY_value : coverpoint KERNEL_VFY.value[1:0] {
			option.weight = 4;
		}
		SSBL_VFY_value : coverpoint SSBL_VFY.value[1:0] {
			option.weight = 4;
		}
	endgroup : cg_vals

	function new(string name = "ac_ce_CSR_HPS2HOST_RSP");
		super.new(name, 32,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 1, 5, "WO", 0, 1'h0, 1, 0, 0);
      this.HPS_RDY = uvm_reg_field::type_id::create("HPS_RDY",,get_full_name());
      this.HPS_RDY.configure(this, 1, 4, "RW", 0, 1'h0, 1, 0, 0);
      this.KERNEL_VFY = uvm_reg_field::type_id::create("KERNEL_VFY",,get_full_name());
      this.KERNEL_VFY.configure(this, 2, 2, "RW", 0, 2'h0, 1, 0, 0);
      this.SSBL_VFY = uvm_reg_field::type_id::create("SSBL_VFY",,get_full_name());
      this.SSBL_VFY.configure(this, 2, 0, "RW", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HPS2HOST_RSP)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_ce_CSR_HPS2HOST_RSP


class ral_block_ac_ce extends uvm_reg_block;
	rand ral_reg_ac_ce_CE_FEATURE_DFH CE_FEATURE_DFH;
	rand ral_reg_ac_ce_CE_FEATURE_GUID_L CE_FEATURE_GUID_L;
	rand ral_reg_ac_ce_CE_FEATURE_GUID_H CE_FEATURE_GUID_H;
	rand ral_reg_ac_ce_CE_FEATURE_CSR_ADDR CE_FEATURE_CSR_ADDR;
	rand ral_reg_ac_ce_CE_FEATURE_CSR_SIZE_GROUP CE_FEATURE_CSR_SIZE_GROUP;
	rand ral_reg_ac_ce_CSR_HOST_SCRATCHPAD CSR_HOST_SCRATCHPAD;
	rand ral_reg_ac_ce_CSR_CE2HOST_DATA_REQ_LIMIT CSR_CE2HOST_DATA_REQ_LIMIT;
	rand ral_reg_ac_ce_CSR_IMG_SRC_ADDR CSR_IMG_SRC_ADDR;
	rand ral_reg_ac_ce_CSR_IMG_DST_ADDR CSR_IMG_DST_ADDR;
	rand ral_reg_ac_ce_CSR_IMG_SIZE CSR_IMG_SIZE;
	rand ral_reg_ac_ce_CSR_HOST2CE_MRD_START CSR_HOST2CE_MRD_START;
	rand ral_reg_ac_ce_CSR_CE2HOST_STATUS CSR_CE2HOST_STATUS;
	rand ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR CSR_HOST2HPS_IMG_XFR;
	rand ral_reg_ac_ce_CSR_HPS2HOST_RSP_SHDW CSR_HPS2HOST_RSP_SHDW;
	rand ral_reg_ac_ce_CSR_CE_SFTRST CSR_CE_SFTRST;
	rand ral_reg_ac_ce_CSR_HPS_SCRATCHPAD CSR_HPS_SCRATCHPAD;
	rand ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR_SHDW CSR_HOST2HPS_IMG_XFR_SHDW;
	rand ral_reg_ac_ce_CSR_HPS2HOST_RSP CSR_HPS2HOST_RSP;
	uvm_reg_field CE_FEATURE_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field CE_FEATURE_DFH_Reserved;
	uvm_reg_field CE_FEATURE_DFH_EndOfList;
	uvm_reg_field EndOfList;
	uvm_reg_field CE_FEATURE_DFH_NextDfhByteOffset;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field CE_FEATURE_DFH_FeatureRev;
	uvm_reg_field FeatureRev;
	uvm_reg_field CE_FEATURE_DFH_FeatureID;
	uvm_reg_field FeatureID;
	uvm_reg_field CE_FEATURE_GUID_L_CE_ID_L;
	uvm_reg_field CE_ID_L;
	uvm_reg_field CE_FEATURE_GUID_H_CE_ID_H;
	uvm_reg_field CE_ID_H;
	uvm_reg_field CE_FEATURE_CSR_ADDR_CSR_REL;
	uvm_reg_field CSR_REL;
	uvm_reg_field CE_FEATURE_CSR_ADDR_CSR_ADDR;
	uvm_reg_field CSR_ADDR;
	uvm_reg_field CE_FEATURE_CSR_SIZE_GROUP_CSR_SIZE;
	uvm_reg_field CSR_SIZE;
	uvm_reg_field CE_FEATURE_CSR_SIZE_GROUP_HAS_PARAMS;
	uvm_reg_field HAS_PARAMS;
	uvm_reg_field CE_FEATURE_CSR_SIZE_GROUP_GROUPING_ID;
	uvm_reg_field GROUPING_ID;
	rand uvm_reg_field CSR_HOST_SCRATCHPAD_HOST_SCRATCHPAD;
	rand uvm_reg_field HOST_SCRATCHPAD;
	rand uvm_reg_field CSR_CE2HOST_DATA_REQ_LIMIT_Reserved;
	rand uvm_reg_field CSR_CE2HOST_DATA_REQ_LIMIT_DATA_REQ_LIMIT;
	rand uvm_reg_field DATA_REQ_LIMIT;
	rand uvm_reg_field CSR_IMG_SRC_ADDR_IMG_SRC_ADDR;
	rand uvm_reg_field IMG_SRC_ADDR;
	rand uvm_reg_field CSR_IMG_DST_ADDR_Reserved;
	rand uvm_reg_field CSR_IMG_DST_ADDR_IMG_DST_ADDR;
	rand uvm_reg_field IMG_DST_ADDR;
	rand uvm_reg_field CSR_IMG_SIZE_Reserved;
	rand uvm_reg_field CSR_IMG_SIZE_IMG_SIZE;
	rand uvm_reg_field IMG_SIZE;
	rand uvm_reg_field CSR_HOST2CE_MRD_START_Reserved;
	rand uvm_reg_field CSR_HOST2CE_MRD_START_MRD_START;
	rand uvm_reg_field MRD_START;
	rand uvm_reg_field CSR_CE2HOST_STATUS_Reserved;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_IMG_ADDR_STS;
	uvm_reg_field CE_IMG_ADDR_STS;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_FIFO2_STS;
	uvm_reg_field CE_FIFO2_STS;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_FIFO1_STS;
	uvm_reg_field CE_FIFO1_STS;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_AXIST_CPL_STS;
	uvm_reg_field CE_AXIST_CPL_STS;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_ACELITE_BRESP_STS;
	uvm_reg_field CE_ACELITE_BRESP_STS;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_DMA_STS;
	uvm_reg_field CE_DMA_STS;
	rand uvm_reg_field CSR_HOST2HPS_IMG_XFR_Reserved;
	rand uvm_reg_field CSR_HOST2HPS_IMG_XFR_HOST2HPS_IMG_XFR;
	rand uvm_reg_field HOST2HPS_IMG_XFR;
	rand uvm_reg_field CSR_HPS2HOST_RSP_SHDW_Reserved;
	uvm_reg_field CSR_HPS2HOST_RSP_SHDW_HPS_RDY_SHDW;
	uvm_reg_field HPS_RDY_SHDW;
	uvm_reg_field CSR_HPS2HOST_RSP_SHDW_KERNEL_VFY_SHDW;
	uvm_reg_field KERNEL_VFY_SHDW;
	uvm_reg_field CSR_HPS2HOST_RSP_SHDW_SSBL_VFY_SHDW;
	uvm_reg_field SSBL_VFY_SHDW;
	rand uvm_reg_field CSR_CE_SFTRST_Reserved;
	rand uvm_reg_field CSR_CE_SFTRST_CE_SFTRST;
	rand uvm_reg_field CE_SFTRST;
	rand uvm_reg_field CSR_HPS_SCRATCHPAD_HPS_SCRATCHPAD;
	rand uvm_reg_field HPS_SCRATCHPAD;
	rand uvm_reg_field CSR_HOST2HPS_IMG_XFR_SHDW_Reserved;
	uvm_reg_field CSR_HOST2HPS_IMG_XFR_SHDW_HOST2HPS_IMG_XFR_SHDW;
	uvm_reg_field HOST2HPS_IMG_XFR_SHDW;
	rand uvm_reg_field CSR_HPS2HOST_RSP_Reserved;
	rand uvm_reg_field CSR_HPS2HOST_RSP_HPS_RDY;
	rand uvm_reg_field HPS_RDY;
	rand uvm_reg_field CSR_HPS2HOST_RSP_KERNEL_VFY;
	rand uvm_reg_field KERNEL_VFY;
	rand uvm_reg_field CSR_HPS2HOST_RSP_SSBL_VFY;
	rand uvm_reg_field SSBL_VFY;

	function new(string name = "ac_ce");
		super.new(name, build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.CE_FEATURE_DFH = ral_reg_ac_ce_CE_FEATURE_DFH::type_id::create("CE_FEATURE_DFH",,get_full_name());
      this.CE_FEATURE_DFH.configure(this, null, "");
      this.CE_FEATURE_DFH.build();
      this.default_map.add_reg(this.CE_FEATURE_DFH, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.CE_FEATURE_DFH_FeatureType = this.CE_FEATURE_DFH.FeatureType;
		this.FeatureType = this.CE_FEATURE_DFH.FeatureType;
		this.CE_FEATURE_DFH_Reserved = this.CE_FEATURE_DFH.Reserved;
		this.CE_FEATURE_DFH_EndOfList = this.CE_FEATURE_DFH.EndOfList;
		this.EndOfList = this.CE_FEATURE_DFH.EndOfList;
		this.CE_FEATURE_DFH_NextDfhByteOffset = this.CE_FEATURE_DFH.NextDfhByteOffset;
		this.NextDfhByteOffset = this.CE_FEATURE_DFH.NextDfhByteOffset;
		this.CE_FEATURE_DFH_FeatureRev = this.CE_FEATURE_DFH.FeatureRev;
		this.FeatureRev = this.CE_FEATURE_DFH.FeatureRev;
		this.CE_FEATURE_DFH_FeatureID = this.CE_FEATURE_DFH.FeatureID;
		this.FeatureID = this.CE_FEATURE_DFH.FeatureID;
      this.CE_FEATURE_GUID_L = ral_reg_ac_ce_CE_FEATURE_GUID_L::type_id::create("CE_FEATURE_GUID_L",,get_full_name());
      this.CE_FEATURE_GUID_L.configure(this, null, "");
      this.CE_FEATURE_GUID_L.build();
      this.default_map.add_reg(this.CE_FEATURE_GUID_L, `UVM_REG_ADDR_WIDTH'h8, "RO", 0);
		this.CE_FEATURE_GUID_L_CE_ID_L = this.CE_FEATURE_GUID_L.CE_ID_L;
		this.CE_ID_L = this.CE_FEATURE_GUID_L.CE_ID_L;
      this.CE_FEATURE_GUID_H = ral_reg_ac_ce_CE_FEATURE_GUID_H::type_id::create("CE_FEATURE_GUID_H",,get_full_name());
      this.CE_FEATURE_GUID_H.configure(this, null, "");
      this.CE_FEATURE_GUID_H.build();
      this.default_map.add_reg(this.CE_FEATURE_GUID_H, `UVM_REG_ADDR_WIDTH'h10, "RO", 0);
		this.CE_FEATURE_GUID_H_CE_ID_H = this.CE_FEATURE_GUID_H.CE_ID_H;
		this.CE_ID_H = this.CE_FEATURE_GUID_H.CE_ID_H;
      this.CE_FEATURE_CSR_ADDR = ral_reg_ac_ce_CE_FEATURE_CSR_ADDR::type_id::create("CE_FEATURE_CSR_ADDR",,get_full_name());
      this.CE_FEATURE_CSR_ADDR.configure(this, null, "");
      this.CE_FEATURE_CSR_ADDR.build();
      this.default_map.add_reg(this.CE_FEATURE_CSR_ADDR, `UVM_REG_ADDR_WIDTH'h18, "RO", 0);
		this.CE_FEATURE_CSR_ADDR_CSR_REL = this.CE_FEATURE_CSR_ADDR.CSR_REL;
		this.CSR_REL = this.CE_FEATURE_CSR_ADDR.CSR_REL;
		this.CE_FEATURE_CSR_ADDR_CSR_ADDR = this.CE_FEATURE_CSR_ADDR.CSR_ADDR;
		this.CSR_ADDR = this.CE_FEATURE_CSR_ADDR.CSR_ADDR;
      this.CE_FEATURE_CSR_SIZE_GROUP = ral_reg_ac_ce_CE_FEATURE_CSR_SIZE_GROUP::type_id::create("CE_FEATURE_CSR_SIZE_GROUP",,get_full_name());
      this.CE_FEATURE_CSR_SIZE_GROUP.configure(this, null, "");
      this.CE_FEATURE_CSR_SIZE_GROUP.build();
      this.default_map.add_reg(this.CE_FEATURE_CSR_SIZE_GROUP, `UVM_REG_ADDR_WIDTH'h20, "RO", 0);
		this.CE_FEATURE_CSR_SIZE_GROUP_CSR_SIZE = this.CE_FEATURE_CSR_SIZE_GROUP.CSR_SIZE;
		this.CSR_SIZE = this.CE_FEATURE_CSR_SIZE_GROUP.CSR_SIZE;
		this.CE_FEATURE_CSR_SIZE_GROUP_HAS_PARAMS = this.CE_FEATURE_CSR_SIZE_GROUP.HAS_PARAMS;
		this.HAS_PARAMS = this.CE_FEATURE_CSR_SIZE_GROUP.HAS_PARAMS;
		this.CE_FEATURE_CSR_SIZE_GROUP_GROUPING_ID = this.CE_FEATURE_CSR_SIZE_GROUP.GROUPING_ID;
		this.GROUPING_ID = this.CE_FEATURE_CSR_SIZE_GROUP.GROUPING_ID;
      this.CSR_HOST_SCRATCHPAD = ral_reg_ac_ce_CSR_HOST_SCRATCHPAD::type_id::create("CSR_HOST_SCRATCHPAD",,get_full_name());
      this.CSR_HOST_SCRATCHPAD.configure(this, null, "");
      this.CSR_HOST_SCRATCHPAD.build();
      this.default_map.add_reg(this.CSR_HOST_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
		this.CSR_HOST_SCRATCHPAD_HOST_SCRATCHPAD = this.CSR_HOST_SCRATCHPAD.HOST_SCRATCHPAD;
		this.HOST_SCRATCHPAD = this.CSR_HOST_SCRATCHPAD.HOST_SCRATCHPAD;
      this.CSR_CE2HOST_DATA_REQ_LIMIT = ral_reg_ac_ce_CSR_CE2HOST_DATA_REQ_LIMIT::type_id::create("CSR_CE2HOST_DATA_REQ_LIMIT",,get_full_name());
      this.CSR_CE2HOST_DATA_REQ_LIMIT.configure(this, null, "");
      this.CSR_CE2HOST_DATA_REQ_LIMIT.build();
      this.default_map.add_reg(this.CSR_CE2HOST_DATA_REQ_LIMIT, `UVM_REG_ADDR_WIDTH'h108, "RW", 0);
		this.CSR_CE2HOST_DATA_REQ_LIMIT_Reserved = this.CSR_CE2HOST_DATA_REQ_LIMIT.Reserved;
		this.CSR_CE2HOST_DATA_REQ_LIMIT_DATA_REQ_LIMIT = this.CSR_CE2HOST_DATA_REQ_LIMIT.DATA_REQ_LIMIT;
		this.DATA_REQ_LIMIT = this.CSR_CE2HOST_DATA_REQ_LIMIT.DATA_REQ_LIMIT;
      this.CSR_IMG_SRC_ADDR = ral_reg_ac_ce_CSR_IMG_SRC_ADDR::type_id::create("CSR_IMG_SRC_ADDR",,get_full_name());
      this.CSR_IMG_SRC_ADDR.configure(this, null, "");
      this.CSR_IMG_SRC_ADDR.build();
      this.default_map.add_reg(this.CSR_IMG_SRC_ADDR, `UVM_REG_ADDR_WIDTH'h110, "RW", 0);
		this.CSR_IMG_SRC_ADDR_IMG_SRC_ADDR = this.CSR_IMG_SRC_ADDR.IMG_SRC_ADDR;
		this.IMG_SRC_ADDR = this.CSR_IMG_SRC_ADDR.IMG_SRC_ADDR;
      this.CSR_IMG_DST_ADDR = ral_reg_ac_ce_CSR_IMG_DST_ADDR::type_id::create("CSR_IMG_DST_ADDR",,get_full_name());
      this.CSR_IMG_DST_ADDR.configure(this, null, "");
      this.CSR_IMG_DST_ADDR.build();
      this.default_map.add_reg(this.CSR_IMG_DST_ADDR, `UVM_REG_ADDR_WIDTH'h118, "RW", 0);
		this.CSR_IMG_DST_ADDR_Reserved = this.CSR_IMG_DST_ADDR.Reserved;
		this.CSR_IMG_DST_ADDR_IMG_DST_ADDR = this.CSR_IMG_DST_ADDR.IMG_DST_ADDR;
		this.IMG_DST_ADDR = this.CSR_IMG_DST_ADDR.IMG_DST_ADDR;
      this.CSR_IMG_SIZE = ral_reg_ac_ce_CSR_IMG_SIZE::type_id::create("CSR_IMG_SIZE",,get_full_name());
      this.CSR_IMG_SIZE.configure(this, null, "");
      this.CSR_IMG_SIZE.build();
      this.default_map.add_reg(this.CSR_IMG_SIZE, `UVM_REG_ADDR_WIDTH'h120, "RW", 0);
		this.CSR_IMG_SIZE_Reserved = this.CSR_IMG_SIZE.Reserved;
		this.CSR_IMG_SIZE_IMG_SIZE = this.CSR_IMG_SIZE.IMG_SIZE;
		this.IMG_SIZE = this.CSR_IMG_SIZE.IMG_SIZE;
      this.CSR_HOST2CE_MRD_START = ral_reg_ac_ce_CSR_HOST2CE_MRD_START::type_id::create("CSR_HOST2CE_MRD_START",,get_full_name());
      this.CSR_HOST2CE_MRD_START.configure(this, null, "");
      this.CSR_HOST2CE_MRD_START.build();
      this.default_map.add_reg(this.CSR_HOST2CE_MRD_START, `UVM_REG_ADDR_WIDTH'h128, "RW", 0);
		this.CSR_HOST2CE_MRD_START_Reserved = this.CSR_HOST2CE_MRD_START.Reserved;
		this.CSR_HOST2CE_MRD_START_MRD_START = this.CSR_HOST2CE_MRD_START.MRD_START;
		this.MRD_START = this.CSR_HOST2CE_MRD_START.MRD_START;
      this.CSR_CE2HOST_STATUS = ral_reg_ac_ce_CSR_CE2HOST_STATUS::type_id::create("CSR_CE2HOST_STATUS",,get_full_name());
      this.CSR_CE2HOST_STATUS.configure(this, null, "");
      this.CSR_CE2HOST_STATUS.build();
      this.default_map.add_reg(this.CSR_CE2HOST_STATUS, `UVM_REG_ADDR_WIDTH'h130, "RW", 0);
		this.CSR_CE2HOST_STATUS_Reserved = this.CSR_CE2HOST_STATUS.Reserved;
		this.CSR_CE2HOST_STATUS_CE_IMG_ADDR_STS = this.CSR_CE2HOST_STATUS.CE_IMG_ADDR_STS;
		this.CE_IMG_ADDR_STS = this.CSR_CE2HOST_STATUS.CE_IMG_ADDR_STS;
		this.CSR_CE2HOST_STATUS_CE_FIFO2_STS = this.CSR_CE2HOST_STATUS.CE_FIFO2_STS;
		this.CE_FIFO2_STS = this.CSR_CE2HOST_STATUS.CE_FIFO2_STS;
		this.CSR_CE2HOST_STATUS_CE_FIFO1_STS = this.CSR_CE2HOST_STATUS.CE_FIFO1_STS;
		this.CE_FIFO1_STS = this.CSR_CE2HOST_STATUS.CE_FIFO1_STS;
		this.CSR_CE2HOST_STATUS_CE_AXIST_CPL_STS = this.CSR_CE2HOST_STATUS.CE_AXIST_CPL_STS;
		this.CE_AXIST_CPL_STS = this.CSR_CE2HOST_STATUS.CE_AXIST_CPL_STS;
		this.CSR_CE2HOST_STATUS_CE_ACELITE_BRESP_STS = this.CSR_CE2HOST_STATUS.CE_ACELITE_BRESP_STS;
		this.CE_ACELITE_BRESP_STS = this.CSR_CE2HOST_STATUS.CE_ACELITE_BRESP_STS;
		this.CSR_CE2HOST_STATUS_CE_DMA_STS = this.CSR_CE2HOST_STATUS.CE_DMA_STS;
		this.CE_DMA_STS = this.CSR_CE2HOST_STATUS.CE_DMA_STS;
      this.CSR_HOST2HPS_IMG_XFR = ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR::type_id::create("CSR_HOST2HPS_IMG_XFR",,get_full_name());
      this.CSR_HOST2HPS_IMG_XFR.configure(this, null, "");
      this.CSR_HOST2HPS_IMG_XFR.build();
      this.default_map.add_reg(this.CSR_HOST2HPS_IMG_XFR, `UVM_REG_ADDR_WIDTH'h138, "RW", 0);
		this.CSR_HOST2HPS_IMG_XFR_Reserved = this.CSR_HOST2HPS_IMG_XFR.Reserved;
		this.CSR_HOST2HPS_IMG_XFR_HOST2HPS_IMG_XFR = this.CSR_HOST2HPS_IMG_XFR.HOST2HPS_IMG_XFR;
		this.HOST2HPS_IMG_XFR = this.CSR_HOST2HPS_IMG_XFR.HOST2HPS_IMG_XFR;
      this.CSR_HPS2HOST_RSP_SHDW = ral_reg_ac_ce_CSR_HPS2HOST_RSP_SHDW::type_id::create("CSR_HPS2HOST_RSP_SHDW",,get_full_name());
      this.CSR_HPS2HOST_RSP_SHDW.configure(this, null, "");
      this.CSR_HPS2HOST_RSP_SHDW.build();
      this.default_map.add_reg(this.CSR_HPS2HOST_RSP_SHDW, `UVM_REG_ADDR_WIDTH'h140, "RW", 0);
		this.CSR_HPS2HOST_RSP_SHDW_Reserved = this.CSR_HPS2HOST_RSP_SHDW.Reserved;
		this.CSR_HPS2HOST_RSP_SHDW_HPS_RDY_SHDW = this.CSR_HPS2HOST_RSP_SHDW.HPS_RDY_SHDW;
		this.HPS_RDY_SHDW = this.CSR_HPS2HOST_RSP_SHDW.HPS_RDY_SHDW;
		this.CSR_HPS2HOST_RSP_SHDW_KERNEL_VFY_SHDW = this.CSR_HPS2HOST_RSP_SHDW.KERNEL_VFY_SHDW;
		this.KERNEL_VFY_SHDW = this.CSR_HPS2HOST_RSP_SHDW.KERNEL_VFY_SHDW;
		this.CSR_HPS2HOST_RSP_SHDW_SSBL_VFY_SHDW = this.CSR_HPS2HOST_RSP_SHDW.SSBL_VFY_SHDW;
		this.SSBL_VFY_SHDW = this.CSR_HPS2HOST_RSP_SHDW.SSBL_VFY_SHDW;
      this.CSR_CE_SFTRST = ral_reg_ac_ce_CSR_CE_SFTRST::type_id::create("CSR_CE_SFTRST",,get_full_name());
      this.CSR_CE_SFTRST.configure(this, null, "");
      this.CSR_CE_SFTRST.build();
      this.default_map.add_reg(this.CSR_CE_SFTRST, `UVM_REG_ADDR_WIDTH'h148, "RW", 0);
		this.CSR_CE_SFTRST_Reserved = this.CSR_CE_SFTRST.Reserved;
		this.CSR_CE_SFTRST_CE_SFTRST = this.CSR_CE_SFTRST.CE_SFTRST;
		this.CE_SFTRST = this.CSR_CE_SFTRST.CE_SFTRST;
      this.CSR_HPS_SCRATCHPAD = ral_reg_ac_ce_CSR_HPS_SCRATCHPAD::type_id::create("CSR_HPS_SCRATCHPAD",,get_full_name());
      this.CSR_HPS_SCRATCHPAD.configure(this, null, "");
      this.CSR_HPS_SCRATCHPAD.build();
      this.default_map.add_reg(this.CSR_HPS_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h150, "RW", 0);
		this.CSR_HPS_SCRATCHPAD_HPS_SCRATCHPAD = this.CSR_HPS_SCRATCHPAD.HPS_SCRATCHPAD;
		this.HPS_SCRATCHPAD = this.CSR_HPS_SCRATCHPAD.HPS_SCRATCHPAD;
      this.CSR_HOST2HPS_IMG_XFR_SHDW = ral_reg_ac_ce_CSR_HOST2HPS_IMG_XFR_SHDW::type_id::create("CSR_HOST2HPS_IMG_XFR_SHDW",,get_full_name());
      this.CSR_HOST2HPS_IMG_XFR_SHDW.configure(this, null, "");
      this.CSR_HOST2HPS_IMG_XFR_SHDW.build();
      this.default_map.add_reg(this.CSR_HOST2HPS_IMG_XFR_SHDW, `UVM_REG_ADDR_WIDTH'h154, "RW", 0);
		this.CSR_HOST2HPS_IMG_XFR_SHDW_Reserved = this.CSR_HOST2HPS_IMG_XFR_SHDW.Reserved;
		this.CSR_HOST2HPS_IMG_XFR_SHDW_HOST2HPS_IMG_XFR_SHDW = this.CSR_HOST2HPS_IMG_XFR_SHDW.HOST2HPS_IMG_XFR_SHDW;
		this.HOST2HPS_IMG_XFR_SHDW = this.CSR_HOST2HPS_IMG_XFR_SHDW.HOST2HPS_IMG_XFR_SHDW;
      this.CSR_HPS2HOST_RSP = ral_reg_ac_ce_CSR_HPS2HOST_RSP::type_id::create("CSR_HPS2HOST_RSP",,get_full_name());
      this.CSR_HPS2HOST_RSP.configure(this, null, "");
      this.CSR_HPS2HOST_RSP.build();
      this.default_map.add_reg(this.CSR_HPS2HOST_RSP, `UVM_REG_ADDR_WIDTH'h158, "RW", 0);
		this.CSR_HPS2HOST_RSP_Reserved = this.CSR_HPS2HOST_RSP.Reserved;
		this.CSR_HPS2HOST_RSP_HPS_RDY = this.CSR_HPS2HOST_RSP.HPS_RDY;
		this.HPS_RDY = this.CSR_HPS2HOST_RSP.HPS_RDY;
		this.CSR_HPS2HOST_RSP_KERNEL_VFY = this.CSR_HPS2HOST_RSP.KERNEL_VFY;
		this.KERNEL_VFY = this.CSR_HPS2HOST_RSP.KERNEL_VFY;
		this.CSR_HPS2HOST_RSP_SSBL_VFY = this.CSR_HPS2HOST_RSP.SSBL_VFY;
		this.SSBL_VFY = this.CSR_HPS2HOST_RSP.SSBL_VFY;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_ce)

endclass : ral_block_ac_ce



`endif
