// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_MEM_TG
`define RAL_AC_MEM_TG

import uvm_pkg::*;

class ral_reg_ac_mem_tg_AFU_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	uvm_reg_field Reserved52;
	uvm_reg_field AfuMinVersion;
	rand uvm_reg_field Reserved41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field AfuMajVersion;
	uvm_reg_field FeatureID;

	function new(string name = "ac_mem_tg_AFU_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h1, 1, 0, 0);
      this.Reserved52 = uvm_reg_field::type_id::create("Reserved52",,get_full_name());
      this.Reserved52.configure(this, 8, 52, "RO", 0, 8'h0, 1, 0, 0);
      this.AfuMinVersion = uvm_reg_field::type_id::create("AfuMinVersion",,get_full_name());
      this.AfuMinVersion.configure(this, 4, 48, "RO", 0, 4'h0, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 7, 41, "WO", 0, 7'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h1, 1, 0, 0);
      this.NextDfhOffset = uvm_reg_field::type_id::create("NextDfhOffset",,get_full_name());
      this.NextDfhOffset.configure(this, 24, 16, "RO", 0, 24'h0, 1, 0, 1);
      this.AfuMajVersion = uvm_reg_field::type_id::create("AfuMajVersion",,get_full_name());
      this.AfuMajVersion.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_mem_tg_AFU_DFH)

endclass : ral_reg_ac_mem_tg_AFU_DFH


class ral_reg_ac_mem_tg_AFU_ID_L extends uvm_reg;
	uvm_reg_field AFU_ID_L;

	function new(string name = "ac_mem_tg_AFU_ID_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AFU_ID_L = uvm_reg_field::type_id::create("AFU_ID_L",,get_full_name());
      this.AFU_ID_L.configure(this, 64, 0, "RO", 0, 64'ha3dc5b831f5cecbb, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_mem_tg_AFU_ID_L)

endclass : ral_reg_ac_mem_tg_AFU_ID_L


class ral_reg_ac_mem_tg_AFU_ID_H extends uvm_reg;
	uvm_reg_field AFU_ID_H;

	function new(string name = "ac_mem_tg_AFU_ID_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AFU_ID_H = uvm_reg_field::type_id::create("AFU_ID_H",,get_full_name());
      this.AFU_ID_H.configure(this, 64, 0, "RO", 0, 64'h4dadea342c7848cb, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_mem_tg_AFU_ID_H)

endclass : ral_reg_ac_mem_tg_AFU_ID_H


class ral_reg_ac_mem_tg_AFU_NEXT extends uvm_reg;
	rand uvm_reg_field Reserved24;
	uvm_reg_field NextAFU;

	function new(string name = "ac_mem_tg_AFU_NEXT");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved24 = uvm_reg_field::type_id::create("Reserved24",,get_full_name());
      this.Reserved24.configure(this, 40, 24, "WO", 0, 40'h000000000, 1, 0, 1);
      this.NextAFU = uvm_reg_field::type_id::create("NextAFU",,get_full_name());
      this.NextAFU.configure(this, 24, 0, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_mem_tg_AFU_NEXT)

endclass : ral_reg_ac_mem_tg_AFU_NEXT


class ral_reg_ac_mem_tg_AFU_RSVD extends uvm_reg;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_mem_tg_AFU_RSVD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 64, 0, "WO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_mem_tg_AFU_RSVD)

endclass : ral_reg_ac_mem_tg_AFU_RSVD


class ral_reg_ac_mem_tg_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Scratchpad;

	function new(string name = "ac_mem_tg_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scratchpad = uvm_reg_field::type_id::create("Scratchpad",,get_full_name());
      this.Scratchpad.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_mem_tg_SCRATCHPAD)

endclass : ral_reg_ac_mem_tg_SCRATCHPAD


class ral_reg_ac_mem_tg_MEM_TG_CTRL extends uvm_reg;
	rand uvm_reg_field Reserved4;
	rand uvm_reg_field TGControl;

	function new(string name = "ac_mem_tg_MEM_TG_CTRL");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved4 = uvm_reg_field::type_id::create("Reserved4",,get_full_name());
      this.Reserved4.configure(this, 60, 4, "WO", 0, 60'h000000000, 1, 0, 0);
      this.TGControl = uvm_reg_field::type_id::create("TGControl",,get_full_name());
      this.TGControl.configure(this, 4, 0, "W1C", 0, 4'hf, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_mem_tg_MEM_TG_CTRL)

endclass : ral_reg_ac_mem_tg_MEM_TG_CTRL


class ral_reg_ac_mem_tg_MEM_TG_STAT extends uvm_reg;
	rand uvm_reg_field Reserved16;
	uvm_reg_field TGStatus3;
	uvm_reg_field TGStatus2;
	uvm_reg_field TGStatus1;
	uvm_reg_field TGStatus0;

	function new(string name = "ac_mem_tg_MEM_TG_STAT");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved16 = uvm_reg_field::type_id::create("Reserved16",,get_full_name());
      this.Reserved16.configure(this, 48, 16, "WO", 0, 48'h000000000, 1, 0, 1);
      this.TGStatus3 = uvm_reg_field::type_id::create("TGStatus3",,get_full_name());
      this.TGStatus3.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.TGStatus2 = uvm_reg_field::type_id::create("TGStatus2",,get_full_name());
      this.TGStatus2.configure(this, 4, 8, "RO", 0, 4'h0, 1, 0, 0);
      this.TGStatus1 = uvm_reg_field::type_id::create("TGStatus1",,get_full_name());
      this.TGStatus1.configure(this, 4, 4, "RO", 0, 4'h0, 1, 0, 0);
      this.TGStatus0 = uvm_reg_field::type_id::create("TGStatus0",,get_full_name());
      this.TGStatus0.configure(this, 4, 0, "RO", 0, 4'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_mem_tg_MEM_TG_STAT)

endclass : ral_reg_ac_mem_tg_MEM_TG_STAT


class ral_block_ac_mem_tg extends uvm_reg_block;
	rand ral_reg_ac_mem_tg_AFU_DFH AFU_DFH;
	rand ral_reg_ac_mem_tg_AFU_ID_L AFU_ID_L;
	rand ral_reg_ac_mem_tg_AFU_ID_H AFU_ID_H;
	rand ral_reg_ac_mem_tg_AFU_NEXT AFU_NEXT;
	rand ral_reg_ac_mem_tg_AFU_RSVD AFU_RSVD;
	rand ral_reg_ac_mem_tg_SCRATCHPAD SCRATCHPAD;
	rand ral_reg_ac_mem_tg_MEM_TG_CTRL MEM_TG_CTRL;
	rand ral_reg_ac_mem_tg_MEM_TG_STAT MEM_TG_STAT;
	uvm_reg_field AFU_DFH_FeatureType;
	uvm_reg_field FeatureType;
	uvm_reg_field AFU_DFH_Reserved52;
	uvm_reg_field Reserved52;
	uvm_reg_field AFU_DFH_AfuMinVersion;
	uvm_reg_field AfuMinVersion;
	rand uvm_reg_field AFU_DFH_Reserved41;
	rand uvm_reg_field Reserved41;
	uvm_reg_field AFU_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field AFU_DFH_NextDfhOffset;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field AFU_DFH_AfuMajVersion;
	uvm_reg_field AfuMajVersion;
	uvm_reg_field AFU_DFH_FeatureID;
	uvm_reg_field FeatureID;
	uvm_reg_field AFU_ID_L_AFU_ID_L;
	uvm_reg_field AFU_ID_H_AFU_ID_H;
	rand uvm_reg_field AFU_NEXT_Reserved24;
	rand uvm_reg_field Reserved24;
	uvm_reg_field AFU_NEXT_NextAFU;
	uvm_reg_field NextAFU;
	rand uvm_reg_field AFU_RSVD_Reserved0;
	rand uvm_reg_field Reserved0;
	rand uvm_reg_field SCRATCHPAD_Scratchpad;
	rand uvm_reg_field Scratchpad;
	rand uvm_reg_field MEM_TG_CTRL_Reserved4;
	rand uvm_reg_field Reserved4;
	rand uvm_reg_field MEM_TG_CTRL_TGControl;
	rand uvm_reg_field TGControl;
	rand uvm_reg_field MEM_TG_STAT_Reserved16;
	rand uvm_reg_field Reserved16;
	uvm_reg_field MEM_TG_STAT_TGStatus3;
	uvm_reg_field TGStatus3;
	uvm_reg_field MEM_TG_STAT_TGStatus2;
	uvm_reg_field TGStatus2;
	uvm_reg_field MEM_TG_STAT_TGStatus1;
	uvm_reg_field TGStatus1;
	uvm_reg_field MEM_TG_STAT_TGStatus0;
	uvm_reg_field TGStatus0;

	function new(string name = "ac_mem_tg");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.AFU_DFH = ral_reg_ac_mem_tg_AFU_DFH::type_id::create("AFU_DFH",,get_full_name());
      this.AFU_DFH.configure(this, null, "");
      this.AFU_DFH.build();
      this.default_map.add_reg(this.AFU_DFH, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.AFU_DFH_FeatureType = this.AFU_DFH.FeatureType;
		this.FeatureType = this.AFU_DFH.FeatureType;
		this.AFU_DFH_Reserved52 = this.AFU_DFH.Reserved52;
		this.Reserved52 = this.AFU_DFH.Reserved52;
		this.AFU_DFH_AfuMinVersion = this.AFU_DFH.AfuMinVersion;
		this.AfuMinVersion = this.AFU_DFH.AfuMinVersion;
		this.AFU_DFH_Reserved41 = this.AFU_DFH.Reserved41;
		this.Reserved41 = this.AFU_DFH.Reserved41;
		this.AFU_DFH_EOL = this.AFU_DFH.EOL;
		this.EOL = this.AFU_DFH.EOL;
		this.AFU_DFH_NextDfhOffset = this.AFU_DFH.NextDfhOffset;
		this.NextDfhOffset = this.AFU_DFH.NextDfhOffset;
		this.AFU_DFH_AfuMajVersion = this.AFU_DFH.AfuMajVersion;
		this.AfuMajVersion = this.AFU_DFH.AfuMajVersion;
		this.AFU_DFH_FeatureID = this.AFU_DFH.FeatureID;
		this.FeatureID = this.AFU_DFH.FeatureID;
      this.AFU_ID_L = ral_reg_ac_mem_tg_AFU_ID_L::type_id::create("AFU_ID_L",,get_full_name());
      this.AFU_ID_L.configure(this, null, "");
      this.AFU_ID_L.build();
      this.default_map.add_reg(this.AFU_ID_L, `UVM_REG_ADDR_WIDTH'h8, "RO", 0);
		this.AFU_ID_L_AFU_ID_L = this.AFU_ID_L.AFU_ID_L;
      this.AFU_ID_H = ral_reg_ac_mem_tg_AFU_ID_H::type_id::create("AFU_ID_H",,get_full_name());
      this.AFU_ID_H.configure(this, null, "");
      this.AFU_ID_H.build();
      this.default_map.add_reg(this.AFU_ID_H, `UVM_REG_ADDR_WIDTH'h10, "RO", 0);
		this.AFU_ID_H_AFU_ID_H = this.AFU_ID_H.AFU_ID_H;
      this.AFU_NEXT = ral_reg_ac_mem_tg_AFU_NEXT::type_id::create("AFU_NEXT",,get_full_name());
      this.AFU_NEXT.configure(this, null, "");
      this.AFU_NEXT.build();
      this.default_map.add_reg(this.AFU_NEXT, `UVM_REG_ADDR_WIDTH'h18, "RW", 0);
		this.AFU_NEXT_Reserved24 = this.AFU_NEXT.Reserved24;
		this.Reserved24 = this.AFU_NEXT.Reserved24;
		this.AFU_NEXT_NextAFU = this.AFU_NEXT.NextAFU;
		this.NextAFU = this.AFU_NEXT.NextAFU;
      this.AFU_RSVD = ral_reg_ac_mem_tg_AFU_RSVD::type_id::create("AFU_RSVD",,get_full_name());
      this.AFU_RSVD.configure(this, null, "");
      this.AFU_RSVD.build();
      this.default_map.add_reg(this.AFU_RSVD, `UVM_REG_ADDR_WIDTH'h20, "RW", 0);
		this.AFU_RSVD_Reserved0 = this.AFU_RSVD.Reserved0;
		this.Reserved0 = this.AFU_RSVD.Reserved0;
      this.SCRATCHPAD = ral_reg_ac_mem_tg_SCRATCHPAD::type_id::create("SCRATCHPAD",,get_full_name());
      this.SCRATCHPAD.configure(this, null, "");
      this.SCRATCHPAD.build();
      this.default_map.add_reg(this.SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h28, "RW", 0);
		this.SCRATCHPAD_Scratchpad = this.SCRATCHPAD.Scratchpad;
		this.Scratchpad = this.SCRATCHPAD.Scratchpad;
      this.MEM_TG_CTRL = ral_reg_ac_mem_tg_MEM_TG_CTRL::type_id::create("MEM_TG_CTRL",,get_full_name());
      this.MEM_TG_CTRL.configure(this, null, "");
      this.MEM_TG_CTRL.build();
      this.default_map.add_reg(this.MEM_TG_CTRL, `UVM_REG_ADDR_WIDTH'h30, "RW", 0);
		this.MEM_TG_CTRL_Reserved4 = this.MEM_TG_CTRL.Reserved4;
		this.Reserved4 = this.MEM_TG_CTRL.Reserved4;
		this.MEM_TG_CTRL_TGControl = this.MEM_TG_CTRL.TGControl;
		this.TGControl = this.MEM_TG_CTRL.TGControl;
      this.MEM_TG_STAT = ral_reg_ac_mem_tg_MEM_TG_STAT::type_id::create("MEM_TG_STAT",,get_full_name());
      this.MEM_TG_STAT.configure(this, null, "");
      this.MEM_TG_STAT.build();
      this.default_map.add_reg(this.MEM_TG_STAT, `UVM_REG_ADDR_WIDTH'h38, "RW", 0);
		this.MEM_TG_STAT_Reserved16 = this.MEM_TG_STAT.Reserved16;
		this.Reserved16 = this.MEM_TG_STAT.Reserved16;
		this.MEM_TG_STAT_TGStatus3 = this.MEM_TG_STAT.TGStatus3;
		this.TGStatus3 = this.MEM_TG_STAT.TGStatus3;
		this.MEM_TG_STAT_TGStatus2 = this.MEM_TG_STAT.TGStatus2;
		this.TGStatus2 = this.MEM_TG_STAT.TGStatus2;
		this.MEM_TG_STAT_TGStatus1 = this.MEM_TG_STAT.TGStatus1;
		this.TGStatus1 = this.MEM_TG_STAT.TGStatus1;
		this.MEM_TG_STAT_TGStatus0 = this.MEM_TG_STAT.TGStatus0;
		this.TGStatus0 = this.MEM_TG_STAT.TGStatus0;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_mem_tg)

endclass : ral_block_ac_mem_tg



`endif
