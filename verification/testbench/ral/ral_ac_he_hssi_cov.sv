// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_HE_HSSI
`define RAL_AC_HE_HSSI

import uvm_pkg::*;

class ral_reg_ac_he_hssi_AFU_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	covergroup cg_vals ();
		option.per_instance = 1;
		FeatureType_value : coverpoint FeatureType.value[3:0] { //Added by script default bin
      bins default_value = { 'h1 };
      option.weight = 1;
    }
		EOL_value : coverpoint EOL.value[0:0] { //Added by script default bin
      bins default_value = { 'h1 };
      option.weight = 1;
    }
		NextDfhByteOffset_value : coverpoint NextDfhByteOffset.value { //Added by script default bin
      bins default_value = { 'h0000 };
      option.weight = 1;
    }
		FeatureRev_value : coverpoint FeatureRev.value[3:0] { //Added by script default bin
      bins default_value = { 'h1 };
      option.weight = 1;
    }
		FeatureID_value : coverpoint FeatureID.value { //Added by script default bin
      bins default_value = { 'h0 };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_he_hssi_AFU_DFH");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h1, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h1, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h0, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_hssi_AFU_DFH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_he_hssi_AFU_DFH


class ral_reg_ac_he_hssi_AFU_ID_L extends uvm_reg;
	uvm_reg_field AFU_ID_L;

	covergroup cg_vals ();
		option.per_instance = 1;
		AFU_ID_L_value : coverpoint AFU_ID_L.value { //Added by script default bin
      bins default_value = { 'hBB370242AC130002 };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_he_hssi_AFU_ID_L");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.AFU_ID_L = uvm_reg_field::type_id::create("AFU_ID_L",,get_full_name());
      this.AFU_ID_L.configure(this, 64, 0, "RO", 0, 64'hbb370242ac130002, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_hssi_AFU_ID_L)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_he_hssi_AFU_ID_L


class ral_reg_ac_he_hssi_AFU_ID_H extends uvm_reg;
	uvm_reg_field AFU_ID_H;

	covergroup cg_vals ();
		option.per_instance = 1;
		AFU_ID_H_value : coverpoint AFU_ID_H.value { //Added by script default bin
      bins default_value = { 'h823C334C98BF11EA };
      option.weight = 1;
    }
	endgroup : cg_vals

	function new(string name = "ac_he_hssi_AFU_ID_H");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.AFU_ID_H = uvm_reg_field::type_id::create("AFU_ID_H",,get_full_name());
      this.AFU_ID_H.configure(this, 64, 0, "RO", 0, 64'h823c334c98bf11ea, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_hssi_AFU_ID_H)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_he_hssi_AFU_ID_H


class ral_reg_ac_he_hssi_TRAFFIC_CTRL_CMD extends uvm_reg;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field AFU_CMD_ADDR;
	rand uvm_reg_field Reserved0;
	uvm_reg_field ACK_TRANS;
	rand uvm_reg_field WRITE_CMD;
	rand uvm_reg_field READ_CMD;

	covergroup cg_vals ();
		option.per_instance = 1;
		AFU_CMD_ADDR_value : coverpoint AFU_CMD_ADDR.value {
			bins min = { 16'h0 };
			bins max = { 16'hFFFF };
			bins others = { [16'h1:16'hFFFE] };
			option.weight = 3;
		}
		ACK_TRANS_value : coverpoint ACK_TRANS.value[0:0] {
			option.weight = 2;
		}
		WRITE_CMD_value : coverpoint WRITE_CMD.value[0:0] {
			option.weight = 2;
		}
		READ_CMD_value : coverpoint READ_CMD.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_he_hssi_TRAFFIC_CTRL_CMD");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved2 = uvm_reg_field::type_id::create("Reserved2",,get_full_name());
      this.Reserved2.configure(this, 16, 48, "WO", 0, 16'h0, 1, 0, 1);
      this.AFU_CMD_ADDR = uvm_reg_field::type_id::create("AFU_CMD_ADDR",,get_full_name());
      this.AFU_CMD_ADDR.configure(this, 16, 32, "RW", 0, 16'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 29, 3, "WO", 0, 29'h0, 1, 0, 0);
      this.ACK_TRANS = uvm_reg_field::type_id::create("ACK_TRANS",,get_full_name());
      this.ACK_TRANS.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.WRITE_CMD = uvm_reg_field::type_id::create("WRITE_CMD",,get_full_name());
      this.WRITE_CMD.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.READ_CMD = uvm_reg_field::type_id::create("READ_CMD",,get_full_name());
      this.READ_CMD.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_hssi_TRAFFIC_CTRL_CMD)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_he_hssi_TRAFFIC_CTRL_CMD


class ral_reg_ac_he_hssi_TRAFFIC_CTRL_DATA extends uvm_reg;
	rand uvm_reg_field WRITE_DATA;
	uvm_reg_field READ_DATA;

	covergroup cg_vals ();
		option.per_instance = 1;
		WRITE_DATA_value : coverpoint WRITE_DATA.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		READ_DATA_value : coverpoint READ_DATA.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_he_hssi_TRAFFIC_CTRL_DATA");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.WRITE_DATA = uvm_reg_field::type_id::create("WRITE_DATA",,get_full_name());
      this.WRITE_DATA.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.READ_DATA = uvm_reg_field::type_id::create("READ_DATA",,get_full_name());
      this.READ_DATA.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_hssi_TRAFFIC_CTRL_DATA)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_he_hssi_TRAFFIC_CTRL_DATA


class ral_reg_ac_he_hssi_TRAFFIC_CTRL_CH_SEL extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field CHANNEL_SEL;

	covergroup cg_vals ();
		option.per_instance = 1;
		CHANNEL_SEL_value : coverpoint CHANNEL_SEL.value[3:0] {
			bins zero  = { 8'h0 };
			bins one   = { 8'h1 };
			bins two   = { 8'h2 };
			bins three = { 8'h3 };
			bins four  = { 8'h4 };
			bins five  = { 8'h5 };
			bins six   = { 8'h6 };
			bins seven = { 8'h7 };
			option.weight = 8;
		}
	endgroup : cg_vals

	function new(string name = "ac_he_hssi_TRAFFIC_CTRL_CH_SEL");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 60, 4, "WO", 0, 60'h000000000, 1, 0, 0);
      this.CHANNEL_SEL = uvm_reg_field::type_id::create("CHANNEL_SEL",,get_full_name());
      this.CHANNEL_SEL.configure(this, 4, 0, "RW", 0, 4'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_hssi_TRAFFIC_CTRL_CH_SEL)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_he_hssi_TRAFFIC_CTRL_CH_SEL


class ral_reg_ac_he_hssi_AFU_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Scratchpad;

	covergroup cg_vals ();
		option.per_instance = 1;
		Scratchpad_value : coverpoint Scratchpad.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_he_hssi_AFU_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Scratchpad = uvm_reg_field::type_id::create("Scratchpad",,get_full_name());
      this.Scratchpad.configure(this, 64, 0, "RW", 0, 64'h045324511, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_hssi_AFU_SCRATCHPAD)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_he_hssi_AFU_SCRATCHPAD


class ral_reg_ac_he_hssi_AFU_CROSSBAR_EN extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field CrossbarEn;

	covergroup cg_vals ();
		option.per_instance = 1;
		CrossbarEn_value : coverpoint CrossbarEn.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_he_hssi_AFU_CROSSBAR_EN");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 63, 1, "WO", 0, 63'h000000000, 1, 0, 0);
      this.CrossbarEn = uvm_reg_field::type_id::create("CrossbarEn",,get_full_name());
      this.CrossbarEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_hssi_AFU_CROSSBAR_EN)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_he_hssi_AFU_CROSSBAR_EN


class ral_block_ac_he_hssi extends uvm_reg_block;
	rand ral_reg_ac_he_hssi_AFU_DFH AFU_DFH;
	rand ral_reg_ac_he_hssi_AFU_ID_L AFU_ID_L;
	rand ral_reg_ac_he_hssi_AFU_ID_H AFU_ID_H;
	rand ral_reg_ac_he_hssi_TRAFFIC_CTRL_CMD TRAFFIC_CTRL_CMD;
	rand ral_reg_ac_he_hssi_TRAFFIC_CTRL_DATA TRAFFIC_CTRL_DATA;
	rand ral_reg_ac_he_hssi_TRAFFIC_CTRL_CH_SEL TRAFFIC_CTRL_CH_SEL;
	rand ral_reg_ac_he_hssi_AFU_SCRATCHPAD AFU_SCRATCHPAD;
	rand ral_reg_ac_he_hssi_AFU_CROSSBAR_EN AFU_CROSSBAR_EN;
	uvm_reg_field AFU_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field AFU_DFH_Reserved41;
	rand uvm_reg_field Reserved41;
	uvm_reg_field AFU_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field AFU_DFH_NextDfhByteOffset;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field AFU_DFH_FeatureRev;
	uvm_reg_field FeatureRev;
	uvm_reg_field AFU_DFH_FeatureID;
	uvm_reg_field FeatureID;
	uvm_reg_field AFU_ID_L_AFU_ID_L;
	uvm_reg_field AFU_ID_H_AFU_ID_H;
	rand uvm_reg_field TRAFFIC_CTRL_CMD_Reserved2;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field TRAFFIC_CTRL_CMD_AFU_CMD_ADDR;
	rand uvm_reg_field AFU_CMD_ADDR;
	rand uvm_reg_field TRAFFIC_CTRL_CMD_Reserved0;
	rand uvm_reg_field Reserved0;
	uvm_reg_field TRAFFIC_CTRL_CMD_ACK_TRANS;
	uvm_reg_field ACK_TRANS;
	rand uvm_reg_field TRAFFIC_CTRL_CMD_WRITE_CMD;
	rand uvm_reg_field WRITE_CMD;
	rand uvm_reg_field TRAFFIC_CTRL_CMD_READ_CMD;
	rand uvm_reg_field READ_CMD;
	rand uvm_reg_field TRAFFIC_CTRL_DATA_WRITE_DATA;
	rand uvm_reg_field WRITE_DATA;
	uvm_reg_field TRAFFIC_CTRL_DATA_READ_DATA;
	uvm_reg_field READ_DATA;
	rand uvm_reg_field TRAFFIC_CTRL_CH_SEL_Reserved;
	rand uvm_reg_field TRAFFIC_CTRL_CH_SEL_CHANNEL_SEL;
	rand uvm_reg_field CHANNEL_SEL;
	rand uvm_reg_field AFU_SCRATCHPAD_Scratchpad;
	rand uvm_reg_field Scratchpad;
	rand uvm_reg_field AFU_CROSSBAR_EN_Reserved;
	rand uvm_reg_field AFU_CROSSBAR_EN_CrossbarEn;
	rand uvm_reg_field CrossbarEn;

	function new(string name = "ac_he_hssi");
		super.new(name, build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.AFU_DFH = ral_reg_ac_he_hssi_AFU_DFH::type_id::create("AFU_DFH",,get_full_name());
      this.AFU_DFH.configure(this, null, "");
      this.AFU_DFH.build();
      this.default_map.add_reg(this.AFU_DFH, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.AFU_DFH_FeatureType = this.AFU_DFH.FeatureType;
		this.FeatureType = this.AFU_DFH.FeatureType;
		this.AFU_DFH_Reserved41 = this.AFU_DFH.Reserved41;
		this.Reserved41 = this.AFU_DFH.Reserved41;
		this.AFU_DFH_EOL = this.AFU_DFH.EOL;
		this.EOL = this.AFU_DFH.EOL;
		this.AFU_DFH_NextDfhByteOffset = this.AFU_DFH.NextDfhByteOffset;
		this.NextDfhByteOffset = this.AFU_DFH.NextDfhByteOffset;
		this.AFU_DFH_FeatureRev = this.AFU_DFH.FeatureRev;
		this.FeatureRev = this.AFU_DFH.FeatureRev;
		this.AFU_DFH_FeatureID = this.AFU_DFH.FeatureID;
		this.FeatureID = this.AFU_DFH.FeatureID;
      this.AFU_ID_L = ral_reg_ac_he_hssi_AFU_ID_L::type_id::create("AFU_ID_L",,get_full_name());
      this.AFU_ID_L.configure(this, null, "");
      this.AFU_ID_L.build();
      this.default_map.add_reg(this.AFU_ID_L, `UVM_REG_ADDR_WIDTH'h8, "RO", 0);
		this.AFU_ID_L_AFU_ID_L = this.AFU_ID_L.AFU_ID_L;
      this.AFU_ID_H = ral_reg_ac_he_hssi_AFU_ID_H::type_id::create("AFU_ID_H",,get_full_name());
      this.AFU_ID_H.configure(this, null, "");
      this.AFU_ID_H.build();
      this.default_map.add_reg(this.AFU_ID_H, `UVM_REG_ADDR_WIDTH'h10, "RO", 0);
		this.AFU_ID_H_AFU_ID_H = this.AFU_ID_H.AFU_ID_H;
      this.TRAFFIC_CTRL_CMD = ral_reg_ac_he_hssi_TRAFFIC_CTRL_CMD::type_id::create("TRAFFIC_CTRL_CMD",,get_full_name());
      this.TRAFFIC_CTRL_CMD.configure(this, null, "");
      this.TRAFFIC_CTRL_CMD.build();
      this.default_map.add_reg(this.TRAFFIC_CTRL_CMD, `UVM_REG_ADDR_WIDTH'h30, "RW", 0);
		this.TRAFFIC_CTRL_CMD_Reserved2 = this.TRAFFIC_CTRL_CMD.Reserved2;
		this.Reserved2 = this.TRAFFIC_CTRL_CMD.Reserved2;
		this.TRAFFIC_CTRL_CMD_AFU_CMD_ADDR = this.TRAFFIC_CTRL_CMD.AFU_CMD_ADDR;
		this.AFU_CMD_ADDR = this.TRAFFIC_CTRL_CMD.AFU_CMD_ADDR;
		this.TRAFFIC_CTRL_CMD_Reserved0 = this.TRAFFIC_CTRL_CMD.Reserved0;
		this.Reserved0 = this.TRAFFIC_CTRL_CMD.Reserved0;
		this.TRAFFIC_CTRL_CMD_ACK_TRANS = this.TRAFFIC_CTRL_CMD.ACK_TRANS;
		this.ACK_TRANS = this.TRAFFIC_CTRL_CMD.ACK_TRANS;
		this.TRAFFIC_CTRL_CMD_WRITE_CMD = this.TRAFFIC_CTRL_CMD.WRITE_CMD;
		this.WRITE_CMD = this.TRAFFIC_CTRL_CMD.WRITE_CMD;
		this.TRAFFIC_CTRL_CMD_READ_CMD = this.TRAFFIC_CTRL_CMD.READ_CMD;
		this.READ_CMD = this.TRAFFIC_CTRL_CMD.READ_CMD;
      this.TRAFFIC_CTRL_DATA = ral_reg_ac_he_hssi_TRAFFIC_CTRL_DATA::type_id::create("TRAFFIC_CTRL_DATA",,get_full_name());
      this.TRAFFIC_CTRL_DATA.configure(this, null, "");
      this.TRAFFIC_CTRL_DATA.build();
      this.default_map.add_reg(this.TRAFFIC_CTRL_DATA, `UVM_REG_ADDR_WIDTH'h38, "RW", 0);
		this.TRAFFIC_CTRL_DATA_WRITE_DATA = this.TRAFFIC_CTRL_DATA.WRITE_DATA;
		this.WRITE_DATA = this.TRAFFIC_CTRL_DATA.WRITE_DATA;
		this.TRAFFIC_CTRL_DATA_READ_DATA = this.TRAFFIC_CTRL_DATA.READ_DATA;
		this.READ_DATA = this.TRAFFIC_CTRL_DATA.READ_DATA;
      this.TRAFFIC_CTRL_CH_SEL = ral_reg_ac_he_hssi_TRAFFIC_CTRL_CH_SEL::type_id::create("TRAFFIC_CTRL_CH_SEL",,get_full_name());
      this.TRAFFIC_CTRL_CH_SEL.configure(this, null, "");
      this.TRAFFIC_CTRL_CH_SEL.build();
      this.default_map.add_reg(this.TRAFFIC_CTRL_CH_SEL, `UVM_REG_ADDR_WIDTH'h40, "RW", 0);
		this.TRAFFIC_CTRL_CH_SEL_Reserved = this.TRAFFIC_CTRL_CH_SEL.Reserved;
		this.TRAFFIC_CTRL_CH_SEL_CHANNEL_SEL = this.TRAFFIC_CTRL_CH_SEL.CHANNEL_SEL;
		this.CHANNEL_SEL = this.TRAFFIC_CTRL_CH_SEL.CHANNEL_SEL;
      this.AFU_SCRATCHPAD = ral_reg_ac_he_hssi_AFU_SCRATCHPAD::type_id::create("AFU_SCRATCHPAD",,get_full_name());
      this.AFU_SCRATCHPAD.configure(this, null, "");
      this.AFU_SCRATCHPAD.build();
      this.default_map.add_reg(this.AFU_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h48, "RW", 0);
		this.AFU_SCRATCHPAD_Scratchpad = this.AFU_SCRATCHPAD.Scratchpad;
		this.Scratchpad = this.AFU_SCRATCHPAD.Scratchpad;
      this.AFU_CROSSBAR_EN = ral_reg_ac_he_hssi_AFU_CROSSBAR_EN::type_id::create("AFU_CROSSBAR_EN",,get_full_name());
      this.AFU_CROSSBAR_EN.configure(this, null, "");
      this.AFU_CROSSBAR_EN.build();
      this.default_map.add_reg(this.AFU_CROSSBAR_EN, `UVM_REG_ADDR_WIDTH'h50, "RW", 0);
		this.AFU_CROSSBAR_EN_Reserved = this.AFU_CROSSBAR_EN.Reserved;
		this.AFU_CROSSBAR_EN_CrossbarEn = this.AFU_CROSSBAR_EN.CrossbarEn;
		this.CrossbarEn = this.AFU_CROSSBAR_EN.CrossbarEn;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_he_hssi)

endclass : ral_block_ac_he_hssi



`endif
