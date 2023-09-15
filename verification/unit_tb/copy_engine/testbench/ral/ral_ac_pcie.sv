// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_PCIE
`define RAL_AC_PCIE

import uvm_pkg::*;

class ral_reg_ac_pcie_PCIE_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field CciMinorRev;
	uvm_reg_field CciVersion;

	function new(string name = "ac_pcie_PCIE_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h4, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhOffset = uvm_reg_field::type_id::create("NextDfhOffset",,get_full_name());
      this.NextDfhOffset.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.CciMinorRev = uvm_reg_field::type_id::create("CciMinorRev",,get_full_name());
      this.CciMinorRev.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.CciVersion = uvm_reg_field::type_id::create("CciVersion",,get_full_name());
      this.CciVersion.configure(this, 12, 0, "RO", 0, 12'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_DFH)

endclass : ral_reg_ac_pcie_PCIE_DFH


class ral_reg_ac_pcie_PCIE_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Scratchpad;

	function new(string name = "ac_pcie_PCIE_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scratchpad = uvm_reg_field::type_id::create("Scratchpad",,get_full_name());
      this.Scratchpad.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_SCRATCHPAD)

endclass : ral_reg_ac_pcie_PCIE_SCRATCHPAD


class ral_reg_ac_pcie_PCIE_STAT extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PcieLinkUp;

	function new(string name = "ac_pcie_PCIE_STAT");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 63, 1, "WO", 0, 63'h000000000, 1, 0, 0);
      this.PcieLinkUp = uvm_reg_field::type_id::create("PcieLinkUp",,get_full_name());
      this.PcieLinkUp.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_STAT)

endclass : ral_reg_ac_pcie_PCIE_STAT


class ral_reg_ac_pcie_PCIE_ERROR_MASK extends uvm_reg;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field ErrorMask;

	function new(string name = "ac_pcie_PCIE_ERROR_MASK");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 54, 10, "WO", 0, 54'h000000000, 1, 0, 0);
      this.ErrorMask = uvm_reg_field::type_id::create("ErrorMask",,get_full_name());
      this.ErrorMask.configure(this, 10, 0, "RW", 0, 10'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_ERROR_MASK)

endclass : ral_reg_ac_pcie_PCIE_ERROR_MASK


class ral_reg_ac_pcie_PCIE_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field FifoOverflowErr;
	rand uvm_reg_field MalformedEopErr;
	rand uvm_reg_field MalformedSopErr;
	rand uvm_reg_field RxPoisonTlpErr;
	rand uvm_reg_field Reserved5;
	rand uvm_reg_field CompTimeOutErr;
	rand uvm_reg_field CompStatErr;
	rand uvm_reg_field CompTagErr;
	rand uvm_reg_field FormatTypeErr;

	function new(string name = "ac_pcie_PCIE_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 55, 9, "WO", 0, 55'h000000000, 1, 0, 0);
      this.FifoOverflowErr = uvm_reg_field::type_id::create("FifoOverflowErr",,get_full_name());
      this.FifoOverflowErr.configure(this, 1, 8, "W1C", 0, 1'h0, 1, 0, 0);
      this.MalformedEopErr = uvm_reg_field::type_id::create("MalformedEopErr",,get_full_name());
      this.MalformedEopErr.configure(this, 1, 7, "W1C", 0, 1'h0, 1, 0, 0);
      this.MalformedSopErr = uvm_reg_field::type_id::create("MalformedSopErr",,get_full_name());
      this.MalformedSopErr.configure(this, 1, 6, "W1C", 0, 1'h0, 1, 0, 0);
      this.RxPoisonTlpErr = uvm_reg_field::type_id::create("RxPoisonTlpErr",,get_full_name());
      this.RxPoisonTlpErr.configure(this, 1, 5, "W1C", 0, 1'h0, 1, 0, 0);
      this.Reserved5 = uvm_reg_field::type_id::create("Reserved5",,get_full_name());
      this.Reserved5.configure(this, 1, 4, "W1C", 0, 1'h0, 1, 0, 0);
      this.CompTimeOutErr = uvm_reg_field::type_id::create("CompTimeOutErr",,get_full_name());
      this.CompTimeOutErr.configure(this, 1, 3, "W1C", 0, 1'h0, 1, 0, 0);
      this.CompStatErr = uvm_reg_field::type_id::create("CompStatErr",,get_full_name());
      this.CompStatErr.configure(this, 1, 2, "W1C", 0, 1'h0, 1, 0, 0);
      this.CompTagErr = uvm_reg_field::type_id::create("CompTagErr",,get_full_name());
      this.CompTagErr.configure(this, 1, 1, "W1C", 0, 1'h0, 1, 0, 0);
      this.FormatTypeErr = uvm_reg_field::type_id::create("FormatTypeErr",,get_full_name());
      this.FormatTypeErr.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_ERROR)

endclass : ral_reg_ac_pcie_PCIE_ERROR


class ral_block_ac_pcie extends uvm_reg_block;
	rand ral_reg_ac_pcie_PCIE_DFH PCIE_DFH;
	rand ral_reg_ac_pcie_PCIE_SCRATCHPAD PCIE_SCRATCHPAD;
	rand ral_reg_ac_pcie_PCIE_STAT PCIE_STAT;
	rand ral_reg_ac_pcie_PCIE_ERROR_MASK PCIE_ERROR_MASK;
	rand ral_reg_ac_pcie_PCIE_ERROR PCIE_ERROR;
	uvm_reg_field PCIE_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field PCIE_DFH_Reserved41;
	rand uvm_reg_field Reserved41;
	uvm_reg_field PCIE_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field PCIE_DFH_NextDfhOffset;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field PCIE_DFH_CciMinorRev;
	uvm_reg_field CciMinorRev;
	uvm_reg_field PCIE_DFH_CciVersion;
	uvm_reg_field CciVersion;
	rand uvm_reg_field PCIE_SCRATCHPAD_Scratchpad;
	rand uvm_reg_field Scratchpad;
	rand uvm_reg_field PCIE_STAT_Reserved;
	rand uvm_reg_field Reserved;
	uvm_reg_field PCIE_STAT_PcieLinkUp;
	uvm_reg_field PcieLinkUp;
	rand uvm_reg_field PCIE_ERROR_MASK_Reserved10;
	rand uvm_reg_field PCIE_ERROR_MASK_ErrorMask;
	rand uvm_reg_field ErrorMask;
	rand uvm_reg_field PCIE_ERROR_Reserved10;
	rand uvm_reg_field PCIE_ERROR_FifoOverflowErr;
	rand uvm_reg_field FifoOverflowErr;
	rand uvm_reg_field PCIE_ERROR_MalformedEopErr;
	rand uvm_reg_field MalformedEopErr;
	rand uvm_reg_field PCIE_ERROR_MalformedSopErr;
	rand uvm_reg_field MalformedSopErr;
	rand uvm_reg_field PCIE_ERROR_RxPoisonTlpErr;
	rand uvm_reg_field RxPoisonTlpErr;
	rand uvm_reg_field PCIE_ERROR_Reserved5;
	rand uvm_reg_field Reserved5;
	rand uvm_reg_field PCIE_ERROR_CompTimeOutErr;
	rand uvm_reg_field CompTimeOutErr;
	rand uvm_reg_field PCIE_ERROR_CompStatErr;
	rand uvm_reg_field CompStatErr;
	rand uvm_reg_field PCIE_ERROR_CompTagErr;
	rand uvm_reg_field CompTagErr;
	rand uvm_reg_field PCIE_ERROR_FormatTypeErr;
	rand uvm_reg_field FormatTypeErr;

	function new(string name = "ac_pcie");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.PCIE_DFH = ral_reg_ac_pcie_PCIE_DFH::type_id::create("PCIE_DFH",,get_full_name());
      this.PCIE_DFH.configure(this, null, "");
      this.PCIE_DFH.build();
      this.default_map.add_reg(this.PCIE_DFH, `UVM_REG_ADDR_WIDTH'h10000, "RW", 0);
		this.PCIE_DFH_FeatureType = this.PCIE_DFH.FeatureType;
		this.FeatureType = this.PCIE_DFH.FeatureType;
		this.PCIE_DFH_Reserved41 = this.PCIE_DFH.Reserved41;
		this.Reserved41 = this.PCIE_DFH.Reserved41;
		this.PCIE_DFH_EOL = this.PCIE_DFH.EOL;
		this.EOL = this.PCIE_DFH.EOL;
		this.PCIE_DFH_NextDfhOffset = this.PCIE_DFH.NextDfhOffset;
		this.NextDfhOffset = this.PCIE_DFH.NextDfhOffset;
		this.PCIE_DFH_CciMinorRev = this.PCIE_DFH.CciMinorRev;
		this.CciMinorRev = this.PCIE_DFH.CciMinorRev;
		this.PCIE_DFH_CciVersion = this.PCIE_DFH.CciVersion;
		this.CciVersion = this.PCIE_DFH.CciVersion;
      this.PCIE_SCRATCHPAD = ral_reg_ac_pcie_PCIE_SCRATCHPAD::type_id::create("PCIE_SCRATCHPAD",,get_full_name());
      this.PCIE_SCRATCHPAD.configure(this, null, "");
      this.PCIE_SCRATCHPAD.build();
      this.default_map.add_reg(this.PCIE_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h10008, "RW", 0);
		this.PCIE_SCRATCHPAD_Scratchpad = this.PCIE_SCRATCHPAD.Scratchpad;
		this.Scratchpad = this.PCIE_SCRATCHPAD.Scratchpad;
      this.PCIE_STAT = ral_reg_ac_pcie_PCIE_STAT::type_id::create("PCIE_STAT",,get_full_name());
      this.PCIE_STAT.configure(this, null, "");
      this.PCIE_STAT.build();
      this.default_map.add_reg(this.PCIE_STAT, `UVM_REG_ADDR_WIDTH'h10010, "RW", 0);
		this.PCIE_STAT_Reserved = this.PCIE_STAT.Reserved;
		this.Reserved = this.PCIE_STAT.Reserved;
		this.PCIE_STAT_PcieLinkUp = this.PCIE_STAT.PcieLinkUp;
		this.PcieLinkUp = this.PCIE_STAT.PcieLinkUp;
      this.PCIE_ERROR_MASK = ral_reg_ac_pcie_PCIE_ERROR_MASK::type_id::create("PCIE_ERROR_MASK",,get_full_name());
      this.PCIE_ERROR_MASK.configure(this, null, "");
      this.PCIE_ERROR_MASK.build();
      this.default_map.add_reg(this.PCIE_ERROR_MASK, `UVM_REG_ADDR_WIDTH'h10018, "RW", 0);
		this.PCIE_ERROR_MASK_Reserved10 = this.PCIE_ERROR_MASK.Reserved10;
		this.PCIE_ERROR_MASK_ErrorMask = this.PCIE_ERROR_MASK.ErrorMask;
		this.ErrorMask = this.PCIE_ERROR_MASK.ErrorMask;
      this.PCIE_ERROR = ral_reg_ac_pcie_PCIE_ERROR::type_id::create("PCIE_ERROR",,get_full_name());
      this.PCIE_ERROR.configure(this, null, "");
      this.PCIE_ERROR.build();
      this.default_map.add_reg(this.PCIE_ERROR, `UVM_REG_ADDR_WIDTH'h10020, "RW", 0);
		this.PCIE_ERROR_Reserved10 = this.PCIE_ERROR.Reserved10;
		this.PCIE_ERROR_FifoOverflowErr = this.PCIE_ERROR.FifoOverflowErr;
		this.FifoOverflowErr = this.PCIE_ERROR.FifoOverflowErr;
		this.PCIE_ERROR_MalformedEopErr = this.PCIE_ERROR.MalformedEopErr;
		this.MalformedEopErr = this.PCIE_ERROR.MalformedEopErr;
		this.PCIE_ERROR_MalformedSopErr = this.PCIE_ERROR.MalformedSopErr;
		this.MalformedSopErr = this.PCIE_ERROR.MalformedSopErr;
		this.PCIE_ERROR_RxPoisonTlpErr = this.PCIE_ERROR.RxPoisonTlpErr;
		this.RxPoisonTlpErr = this.PCIE_ERROR.RxPoisonTlpErr;
		this.PCIE_ERROR_Reserved5 = this.PCIE_ERROR.Reserved5;
		this.Reserved5 = this.PCIE_ERROR.Reserved5;
		this.PCIE_ERROR_CompTimeOutErr = this.PCIE_ERROR.CompTimeOutErr;
		this.CompTimeOutErr = this.PCIE_ERROR.CompTimeOutErr;
		this.PCIE_ERROR_CompStatErr = this.PCIE_ERROR.CompStatErr;
		this.CompStatErr = this.PCIE_ERROR.CompStatErr;
		this.PCIE_ERROR_CompTagErr = this.PCIE_ERROR.CompTagErr;
		this.CompTagErr = this.PCIE_ERROR.CompTagErr;
		this.PCIE_ERROR_FormatTypeErr = this.PCIE_ERROR.FormatTypeErr;
		this.FormatTypeErr = this.PCIE_ERROR.FormatTypeErr;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_pcie)

endclass : ral_block_ac_pcie



`endif
