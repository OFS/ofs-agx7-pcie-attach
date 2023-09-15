// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_AFU_INTF
`define RAL_AC_AFU_INTF

import uvm_pkg::*;

class ral_reg_ac_AFU_INTF_AFU_INTF_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	function new(string name = "ac_AFU_INTF_AFU_INTF_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h1, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h0, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h2, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h10, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_AFU_INTF_AFU_INTF_DFH)

endclass : ral_reg_ac_AFU_INTF_AFU_INTF_DFH


class ral_reg_ac_AFU_INTF_AFU_INTF_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Scratchpad;

	function new(string name = "ac_AFU_INTF_AFU_INTF_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scratchpad = uvm_reg_field::type_id::create("Scratchpad",,get_full_name());
      this.Scratchpad.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_AFU_INTF_AFU_INTF_SCRATCHPAD)

endclass : ral_reg_ac_AFU_INTF_AFU_INTF_SCRATCHPAD


class ral_reg_ac_AFU_INTF_AFU_INTF_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved63_32;
	uvm_reg_field BlockingTraffic;
	rand uvm_reg_field Reserved30_27;
	rand uvm_reg_field Vf_num;
	rand uvm_reg_field VfFlrAccessErr;
	rand uvm_reg_field Reserved16;
	rand uvm_reg_field Reserved15;
	rand uvm_reg_field MalformedTlpErr;
	rand uvm_reg_field MaxPayloadErr;
	rand uvm_reg_field MaxReadReqSizeErr;
	rand uvm_reg_field MaxTagErr;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field Reserved9;
	rand uvm_reg_field UnexpMMIORspErr;
	rand uvm_reg_field MMIOTimeoutErr;
	rand uvm_reg_field Reserved6;
	rand uvm_reg_field Reserved5;
	rand uvm_reg_field MMIODataPayloadOvrErr;
	rand uvm_reg_field MMIOInsuffDataErr;
	rand uvm_reg_field TxMWRDataPayloadOvrErr;
	rand uvm_reg_field TxMWRInsuffDataErr;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_AFU_INTF_AFU_INTF_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved63_32 = uvm_reg_field::type_id::create("Reserved63_32",,get_full_name());
      this.Reserved63_32.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.BlockingTraffic = uvm_reg_field::type_id::create("BlockingTraffic",,get_full_name());
      this.BlockingTraffic.configure(this, 1, 31, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved30_27 = uvm_reg_field::type_id::create("Reserved30_27",,get_full_name());
      this.Reserved30_27.configure(this, 4, 27, "WO", 0, 4'h0, 1, 0, 0);
      this.Vf_num = uvm_reg_field::type_id::create("Vf_num",,get_full_name());
      this.Vf_num.configure(this, 9, 18, "W1C", 0, 9'h0, 1, 0, 0);
      this.VfFlrAccessErr = uvm_reg_field::type_id::create("VfFlrAccessErr",,get_full_name());
      this.VfFlrAccessErr.configure(this, 1, 17, "W1C", 0, 1'h0, 1, 0, 0);
      this.Reserved16 = uvm_reg_field::type_id::create("Reserved16",,get_full_name());
      this.Reserved16.configure(this, 1, 16, "WO", 0, 1'h0, 1, 0, 0);
      this.Reserved15 = uvm_reg_field::type_id::create("Reserved15",,get_full_name());
      this.Reserved15.configure(this, 1, 15, "WO", 0, 1'h0, 1, 0, 0);
      this.MalformedTlpErr = uvm_reg_field::type_id::create("MalformedTlpErr",,get_full_name());
      this.MalformedTlpErr.configure(this, 1, 14, "W1C", 0, 1'h0, 1, 0, 0);
      this.MaxPayloadErr = uvm_reg_field::type_id::create("MaxPayloadErr",,get_full_name());
      this.MaxPayloadErr.configure(this, 1, 13, "W1C", 0, 1'h0, 1, 0, 0);
      this.MaxReadReqSizeErr = uvm_reg_field::type_id::create("MaxReadReqSizeErr",,get_full_name());
      this.MaxReadReqSizeErr.configure(this, 1, 12, "W1C", 0, 1'h0, 1, 0, 0);
      this.MaxTagErr = uvm_reg_field::type_id::create("MaxTagErr",,get_full_name());
      this.MaxTagErr.configure(this, 1, 11, "W1C", 0, 1'h0, 1, 0, 0);
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 1, 10, "WO", 0, 1'h0, 1, 0, 0);
      this.Reserved9 = uvm_reg_field::type_id::create("Reserved9",,get_full_name());
      this.Reserved9.configure(this, 1, 9, "WO", 0, 1'h0, 1, 0, 0);
      this.UnexpMMIORspErr = uvm_reg_field::type_id::create("UnexpMMIORspErr",,get_full_name());
      this.UnexpMMIORspErr.configure(this, 1, 8, "W1C", 0, 1'h0, 1, 0, 0);
      this.MMIOTimeoutErr = uvm_reg_field::type_id::create("MMIOTimeoutErr",,get_full_name());
      this.MMIOTimeoutErr.configure(this, 1, 7, "W1C", 0, 1'h0, 1, 0, 0);
      this.Reserved6 = uvm_reg_field::type_id::create("Reserved6",,get_full_name());
      this.Reserved6.configure(this, 1, 6, "WO", 0, 1'h0, 1, 0, 0);
      this.Reserved5 = uvm_reg_field::type_id::create("Reserved5",,get_full_name());
      this.Reserved5.configure(this, 1, 5, "WO", 0, 1'h0, 1, 0, 0);
      this.MMIODataPayloadOvrErr = uvm_reg_field::type_id::create("MMIODataPayloadOvrErr",,get_full_name());
      this.MMIODataPayloadOvrErr.configure(this, 1, 4, "W1C", 0, 1'h0, 1, 0, 0);
      this.MMIOInsuffDataErr = uvm_reg_field::type_id::create("MMIOInsuffDataErr",,get_full_name());
      this.MMIOInsuffDataErr.configure(this, 1, 3, "W1C", 0, 1'h0, 1, 0, 0);
      this.TxMWRDataPayloadOvrErr = uvm_reg_field::type_id::create("TxMWRDataPayloadOvrErr",,get_full_name());
      this.TxMWRDataPayloadOvrErr.configure(this, 1, 2, "W1C", 0, 1'h0, 1, 0, 0);
      this.TxMWRInsuffDataErr = uvm_reg_field::type_id::create("TxMWRInsuffDataErr",,get_full_name());
      this.TxMWRInsuffDataErr.configure(this, 1, 1, "W1C", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 1, 0, "WO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_AFU_INTF_AFU_INTF_ERROR)

endclass : ral_reg_ac_AFU_INTF_AFU_INTF_ERROR


class ral_reg_ac_AFU_INTF_AFU_INTF_FIRST_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved63_27;
	uvm_reg_field Vf_num;
	uvm_reg_field VfFlrAccessErr;
	rand uvm_reg_field Reserved16;
	rand uvm_reg_field Reserved15;
	uvm_reg_field MalformedTlpErr;
	uvm_reg_field MaxPayloadErr;
	uvm_reg_field MaxReadReqSizeErr;
	uvm_reg_field MaxTagErr;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field Reserved9;
	uvm_reg_field UnexpMMIORspErr;
	uvm_reg_field MMIOTimeoutErr;
	rand uvm_reg_field Reserved6;
	rand uvm_reg_field Reserved5;
	uvm_reg_field MMIODataPayloadOvrErr;
	uvm_reg_field MMIOInsuffDataErr;
	uvm_reg_field TxMWRDataPayloadOvrErr;
	uvm_reg_field TxMWRInsuffDataErr;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_AFU_INTF_AFU_INTF_FIRST_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved63_27 = uvm_reg_field::type_id::create("Reserved63_27",,get_full_name());
      this.Reserved63_27.configure(this, 37, 27, "WO", 0, 37'h000000000, 1, 0, 0);
      this.Vf_num = uvm_reg_field::type_id::create("Vf_num",,get_full_name());
      this.Vf_num.configure(this, 9, 18, "RO", 0, 9'h0, 1, 0, 0);
      this.VfFlrAccessErr = uvm_reg_field::type_id::create("VfFlrAccessErr",,get_full_name());
      this.VfFlrAccessErr.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved16 = uvm_reg_field::type_id::create("Reserved16",,get_full_name());
      this.Reserved16.configure(this, 1, 16, "WO", 0, 1'h0, 1, 0, 0);
      this.Reserved15 = uvm_reg_field::type_id::create("Reserved15",,get_full_name());
      this.Reserved15.configure(this, 1, 15, "WO", 0, 1'h0, 1, 0, 0);
      this.MalformedTlpErr = uvm_reg_field::type_id::create("MalformedTlpErr",,get_full_name());
      this.MalformedTlpErr.configure(this, 1, 14, "RO", 0, 1'h0, 1, 0, 0);
      this.MaxPayloadErr = uvm_reg_field::type_id::create("MaxPayloadErr",,get_full_name());
      this.MaxPayloadErr.configure(this, 1, 13, "RO", 0, 1'h0, 1, 0, 0);
      this.MaxReadReqSizeErr = uvm_reg_field::type_id::create("MaxReadReqSizeErr",,get_full_name());
      this.MaxReadReqSizeErr.configure(this, 1, 12, "RO", 0, 1'h0, 1, 0, 0);
      this.MaxTagErr = uvm_reg_field::type_id::create("MaxTagErr",,get_full_name());
      this.MaxTagErr.configure(this, 1, 11, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 1, 10, "WO", 0, 1'h0, 1, 0, 0);
      this.Reserved9 = uvm_reg_field::type_id::create("Reserved9",,get_full_name());
      this.Reserved9.configure(this, 1, 9, "WO", 0, 1'h0, 1, 0, 0);
      this.UnexpMMIORspErr = uvm_reg_field::type_id::create("UnexpMMIORspErr",,get_full_name());
      this.UnexpMMIORspErr.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.MMIOTimeoutErr = uvm_reg_field::type_id::create("MMIOTimeoutErr",,get_full_name());
      this.MMIOTimeoutErr.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved6 = uvm_reg_field::type_id::create("Reserved6",,get_full_name());
      this.Reserved6.configure(this, 1, 6, "WO", 0, 1'h0, 1, 0, 0);
      this.Reserved5 = uvm_reg_field::type_id::create("Reserved5",,get_full_name());
      this.Reserved5.configure(this, 1, 5, "WO", 0, 1'h0, 1, 0, 0);
      this.MMIODataPayloadOvrErr = uvm_reg_field::type_id::create("MMIODataPayloadOvrErr",,get_full_name());
      this.MMIODataPayloadOvrErr.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.MMIOInsuffDataErr = uvm_reg_field::type_id::create("MMIOInsuffDataErr",,get_full_name());
      this.MMIOInsuffDataErr.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.TxMWRDataPayloadOvrErr = uvm_reg_field::type_id::create("TxMWRDataPayloadOvrErr",,get_full_name());
      this.TxMWRDataPayloadOvrErr.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.TxMWRInsuffDataErr = uvm_reg_field::type_id::create("TxMWRInsuffDataErr",,get_full_name());
      this.TxMWRInsuffDataErr.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 1, 0, "WO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_AFU_INTF_AFU_INTF_FIRST_ERROR)

endclass : ral_reg_ac_AFU_INTF_AFU_INTF_FIRST_ERROR


class ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY0 extends uvm_reg;
	uvm_reg_field Dummy_register;

	function new(string name = "ac_AFU_INTF_AFU_INTF_DUMMY0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Dummy_register = uvm_reg_field::type_id::create("Dummy_register",,get_full_name());
      this.Dummy_register.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY0)

endclass : ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY0


class ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY1 extends uvm_reg;
	uvm_reg_field Dummy_register;

	function new(string name = "ac_AFU_INTF_AFU_INTF_DUMMY1");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Dummy_register = uvm_reg_field::type_id::create("Dummy_register",,get_full_name());
      this.Dummy_register.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY1)

endclass : ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY1


class ral_block_ac_AFU_INTF extends uvm_reg_block;
	rand ral_reg_ac_AFU_INTF_AFU_INTF_DFH AFU_INTF_DFH;
	rand ral_reg_ac_AFU_INTF_AFU_INTF_SCRATCHPAD AFU_INTF_SCRATCHPAD;
	rand ral_reg_ac_AFU_INTF_AFU_INTF_ERROR AFU_INTF_ERROR;
	rand ral_reg_ac_AFU_INTF_AFU_INTF_FIRST_ERROR AFU_INTF_FIRST_ERROR;
	rand ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY0 AFU_INTF_DUMMY0;
	rand ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY1 AFU_INTF_DUMMY1;
	uvm_reg_field AFU_INTF_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field AFU_INTF_DFH_Reserved41;
	rand uvm_reg_field Reserved41;
	uvm_reg_field AFU_INTF_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field AFU_INTF_DFH_NextDfhByteOffset;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field AFU_INTF_DFH_FeatureRev;
	uvm_reg_field FeatureRev;
	uvm_reg_field AFU_INTF_DFH_FeatureID;
	uvm_reg_field FeatureID;
	rand uvm_reg_field AFU_INTF_SCRATCHPAD_Scratchpad;
	rand uvm_reg_field Scratchpad;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved63_32;
	rand uvm_reg_field Reserved63_32;
	uvm_reg_field AFU_INTF_ERROR_BlockingTraffic;
	uvm_reg_field BlockingTraffic;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved30_27;
	rand uvm_reg_field Reserved30_27;
	rand uvm_reg_field AFU_INTF_ERROR_Vf_num;
	rand uvm_reg_field AFU_INTF_ERROR_VfFlrAccessErr;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved16;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved15;
	rand uvm_reg_field AFU_INTF_ERROR_MalformedTlpErr;
	rand uvm_reg_field AFU_INTF_ERROR_MaxPayloadErr;
	rand uvm_reg_field AFU_INTF_ERROR_MaxReadReqSizeErr;
	rand uvm_reg_field AFU_INTF_ERROR_MaxTagErr;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved10;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved9;
	rand uvm_reg_field AFU_INTF_ERROR_UnexpMMIORspErr;
	rand uvm_reg_field AFU_INTF_ERROR_MMIOTimeoutErr;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved6;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved5;
	rand uvm_reg_field AFU_INTF_ERROR_MMIODataPayloadOvrErr;
	rand uvm_reg_field AFU_INTF_ERROR_MMIOInsuffDataErr;
	rand uvm_reg_field AFU_INTF_ERROR_TxMWRDataPayloadOvrErr;
	rand uvm_reg_field AFU_INTF_ERROR_TxMWRInsuffDataErr;
	rand uvm_reg_field AFU_INTF_ERROR_Reserved0;
	rand uvm_reg_field AFU_INTF_FIRST_ERROR_Reserved63_27;
	rand uvm_reg_field Reserved63_27;
	uvm_reg_field AFU_INTF_FIRST_ERROR_Vf_num;
	uvm_reg_field AFU_INTF_FIRST_ERROR_VfFlrAccessErr;
	rand uvm_reg_field AFU_INTF_FIRST_ERROR_Reserved16;
	rand uvm_reg_field AFU_INTF_FIRST_ERROR_Reserved15;
	uvm_reg_field AFU_INTF_FIRST_ERROR_MalformedTlpErr;
	uvm_reg_field AFU_INTF_FIRST_ERROR_MaxPayloadErr;
	uvm_reg_field AFU_INTF_FIRST_ERROR_MaxReadReqSizeErr;
	uvm_reg_field AFU_INTF_FIRST_ERROR_MaxTagErr;
	rand uvm_reg_field AFU_INTF_FIRST_ERROR_Reserved10;
	rand uvm_reg_field AFU_INTF_FIRST_ERROR_Reserved9;
	uvm_reg_field AFU_INTF_FIRST_ERROR_UnexpMMIORspErr;
	uvm_reg_field AFU_INTF_FIRST_ERROR_MMIOTimeoutErr;
	rand uvm_reg_field AFU_INTF_FIRST_ERROR_Reserved6;
	rand uvm_reg_field AFU_INTF_FIRST_ERROR_Reserved5;
	uvm_reg_field AFU_INTF_FIRST_ERROR_MMIODataPayloadOvrErr;
	uvm_reg_field AFU_INTF_FIRST_ERROR_MMIOInsuffDataErr;
	uvm_reg_field AFU_INTF_FIRST_ERROR_TxMWRDataPayloadOvrErr;
	uvm_reg_field AFU_INTF_FIRST_ERROR_TxMWRInsuffDataErr;
	rand uvm_reg_field AFU_INTF_FIRST_ERROR_Reserved0;
	uvm_reg_field AFU_INTF_DUMMY0_Dummy_register;
	uvm_reg_field AFU_INTF_DUMMY1_Dummy_register;

	function new(string name = "ac_AFU_INTF");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.AFU_INTF_DFH = ral_reg_ac_AFU_INTF_AFU_INTF_DFH::type_id::create("AFU_INTF_DFH",,get_full_name());
      this.AFU_INTF_DFH.configure(this, null, "");
      this.AFU_INTF_DFH.build();
      this.default_map.add_reg(this.AFU_INTF_DFH, `UVM_REG_ADDR_WIDTH'h00000, "RW", 0);
		this.AFU_INTF_DFH_FeatureType = this.AFU_INTF_DFH.FeatureType;
		this.FeatureType = this.AFU_INTF_DFH.FeatureType;
		this.AFU_INTF_DFH_Reserved41 = this.AFU_INTF_DFH.Reserved41;
		this.Reserved41 = this.AFU_INTF_DFH.Reserved41;
		this.AFU_INTF_DFH_EOL = this.AFU_INTF_DFH.EOL;
		this.EOL = this.AFU_INTF_DFH.EOL;
		this.AFU_INTF_DFH_NextDfhByteOffset = this.AFU_INTF_DFH.NextDfhByteOffset;
		this.NextDfhByteOffset = this.AFU_INTF_DFH.NextDfhByteOffset;
		this.AFU_INTF_DFH_FeatureRev = this.AFU_INTF_DFH.FeatureRev;
		this.FeatureRev = this.AFU_INTF_DFH.FeatureRev;
		this.AFU_INTF_DFH_FeatureID = this.AFU_INTF_DFH.FeatureID;
		this.FeatureID = this.AFU_INTF_DFH.FeatureID;
      this.AFU_INTF_SCRATCHPAD = ral_reg_ac_AFU_INTF_AFU_INTF_SCRATCHPAD::type_id::create("AFU_INTF_SCRATCHPAD",,get_full_name());
      this.AFU_INTF_SCRATCHPAD.configure(this, null, "");
      this.AFU_INTF_SCRATCHPAD.build();
      this.default_map.add_reg(this.AFU_INTF_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h00008, "RW", 0);
		this.AFU_INTF_SCRATCHPAD_Scratchpad = this.AFU_INTF_SCRATCHPAD.Scratchpad;
		this.Scratchpad = this.AFU_INTF_SCRATCHPAD.Scratchpad;
      this.AFU_INTF_ERROR = ral_reg_ac_AFU_INTF_AFU_INTF_ERROR::type_id::create("AFU_INTF_ERROR",,get_full_name());
      this.AFU_INTF_ERROR.configure(this, null, "");
      this.AFU_INTF_ERROR.build();
      this.default_map.add_reg(this.AFU_INTF_ERROR, `UVM_REG_ADDR_WIDTH'h00010, "RW", 0);
		this.AFU_INTF_ERROR_Reserved63_32 = this.AFU_INTF_ERROR.Reserved63_32;
		this.Reserved63_32 = this.AFU_INTF_ERROR.Reserved63_32;
		this.AFU_INTF_ERROR_BlockingTraffic = this.AFU_INTF_ERROR.BlockingTraffic;
		this.BlockingTraffic = this.AFU_INTF_ERROR.BlockingTraffic;
		this.AFU_INTF_ERROR_Reserved30_27 = this.AFU_INTF_ERROR.Reserved30_27;
		this.Reserved30_27 = this.AFU_INTF_ERROR.Reserved30_27;
		this.AFU_INTF_ERROR_Vf_num = this.AFU_INTF_ERROR.Vf_num;
		this.AFU_INTF_ERROR_VfFlrAccessErr = this.AFU_INTF_ERROR.VfFlrAccessErr;
		this.AFU_INTF_ERROR_Reserved16 = this.AFU_INTF_ERROR.Reserved16;
		this.AFU_INTF_ERROR_Reserved15 = this.AFU_INTF_ERROR.Reserved15;
		this.AFU_INTF_ERROR_MalformedTlpErr = this.AFU_INTF_ERROR.MalformedTlpErr;
		this.AFU_INTF_ERROR_MaxPayloadErr = this.AFU_INTF_ERROR.MaxPayloadErr;
		this.AFU_INTF_ERROR_MaxReadReqSizeErr = this.AFU_INTF_ERROR.MaxReadReqSizeErr;
		this.AFU_INTF_ERROR_MaxTagErr = this.AFU_INTF_ERROR.MaxTagErr;
		this.AFU_INTF_ERROR_Reserved10 = this.AFU_INTF_ERROR.Reserved10;
		this.AFU_INTF_ERROR_Reserved9 = this.AFU_INTF_ERROR.Reserved9;
		this.AFU_INTF_ERROR_UnexpMMIORspErr = this.AFU_INTF_ERROR.UnexpMMIORspErr;
		this.AFU_INTF_ERROR_MMIOTimeoutErr = this.AFU_INTF_ERROR.MMIOTimeoutErr;
		this.AFU_INTF_ERROR_Reserved6 = this.AFU_INTF_ERROR.Reserved6;
		this.AFU_INTF_ERROR_Reserved5 = this.AFU_INTF_ERROR.Reserved5;
		this.AFU_INTF_ERROR_MMIODataPayloadOvrErr = this.AFU_INTF_ERROR.MMIODataPayloadOvrErr;
		this.AFU_INTF_ERROR_MMIOInsuffDataErr = this.AFU_INTF_ERROR.MMIOInsuffDataErr;
		this.AFU_INTF_ERROR_TxMWRDataPayloadOvrErr = this.AFU_INTF_ERROR.TxMWRDataPayloadOvrErr;
		this.AFU_INTF_ERROR_TxMWRInsuffDataErr = this.AFU_INTF_ERROR.TxMWRInsuffDataErr;
		this.AFU_INTF_ERROR_Reserved0 = this.AFU_INTF_ERROR.Reserved0;
      this.AFU_INTF_FIRST_ERROR = ral_reg_ac_AFU_INTF_AFU_INTF_FIRST_ERROR::type_id::create("AFU_INTF_FIRST_ERROR",,get_full_name());
      this.AFU_INTF_FIRST_ERROR.configure(this, null, "");
      this.AFU_INTF_FIRST_ERROR.build();
      this.default_map.add_reg(this.AFU_INTF_FIRST_ERROR, `UVM_REG_ADDR_WIDTH'h00018, "RW", 0);
		this.AFU_INTF_FIRST_ERROR_Reserved63_27 = this.AFU_INTF_FIRST_ERROR.Reserved63_27;
		this.Reserved63_27 = this.AFU_INTF_FIRST_ERROR.Reserved63_27;
		this.AFU_INTF_FIRST_ERROR_Vf_num = this.AFU_INTF_FIRST_ERROR.Vf_num;
		this.AFU_INTF_FIRST_ERROR_VfFlrAccessErr = this.AFU_INTF_FIRST_ERROR.VfFlrAccessErr;
		this.AFU_INTF_FIRST_ERROR_Reserved16 = this.AFU_INTF_FIRST_ERROR.Reserved16;
		this.AFU_INTF_FIRST_ERROR_Reserved15 = this.AFU_INTF_FIRST_ERROR.Reserved15;
		this.AFU_INTF_FIRST_ERROR_MalformedTlpErr = this.AFU_INTF_FIRST_ERROR.MalformedTlpErr;
		this.AFU_INTF_FIRST_ERROR_MaxPayloadErr = this.AFU_INTF_FIRST_ERROR.MaxPayloadErr;
		this.AFU_INTF_FIRST_ERROR_MaxReadReqSizeErr = this.AFU_INTF_FIRST_ERROR.MaxReadReqSizeErr;
		this.AFU_INTF_FIRST_ERROR_MaxTagErr = this.AFU_INTF_FIRST_ERROR.MaxTagErr;
		this.AFU_INTF_FIRST_ERROR_Reserved10 = this.AFU_INTF_FIRST_ERROR.Reserved10;
		this.AFU_INTF_FIRST_ERROR_Reserved9 = this.AFU_INTF_FIRST_ERROR.Reserved9;
		this.AFU_INTF_FIRST_ERROR_UnexpMMIORspErr = this.AFU_INTF_FIRST_ERROR.UnexpMMIORspErr;
		this.AFU_INTF_FIRST_ERROR_MMIOTimeoutErr = this.AFU_INTF_FIRST_ERROR.MMIOTimeoutErr;
		this.AFU_INTF_FIRST_ERROR_Reserved6 = this.AFU_INTF_FIRST_ERROR.Reserved6;
		this.AFU_INTF_FIRST_ERROR_Reserved5 = this.AFU_INTF_FIRST_ERROR.Reserved5;
		this.AFU_INTF_FIRST_ERROR_MMIODataPayloadOvrErr = this.AFU_INTF_FIRST_ERROR.MMIODataPayloadOvrErr;
		this.AFU_INTF_FIRST_ERROR_MMIOInsuffDataErr = this.AFU_INTF_FIRST_ERROR.MMIOInsuffDataErr;
		this.AFU_INTF_FIRST_ERROR_TxMWRDataPayloadOvrErr = this.AFU_INTF_FIRST_ERROR.TxMWRDataPayloadOvrErr;
		this.AFU_INTF_FIRST_ERROR_TxMWRInsuffDataErr = this.AFU_INTF_FIRST_ERROR.TxMWRInsuffDataErr;
		this.AFU_INTF_FIRST_ERROR_Reserved0 = this.AFU_INTF_FIRST_ERROR.Reserved0;
      this.AFU_INTF_DUMMY0 = ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY0::type_id::create("AFU_INTF_DUMMY0",,get_full_name());
      this.AFU_INTF_DUMMY0.configure(this, null, "");
      this.AFU_INTF_DUMMY0.build();
      this.default_map.add_reg(this.AFU_INTF_DUMMY0, `UVM_REG_ADDR_WIDTH'h00020, "RO", 0);
		this.AFU_INTF_DUMMY0_Dummy_register = this.AFU_INTF_DUMMY0.Dummy_register;
      this.AFU_INTF_DUMMY1 = ral_reg_ac_AFU_INTF_AFU_INTF_DUMMY1::type_id::create("AFU_INTF_DUMMY1",,get_full_name());
      this.AFU_INTF_DUMMY1.configure(this, null, "");
      this.AFU_INTF_DUMMY1.build();
      this.default_map.add_reg(this.AFU_INTF_DUMMY1, `UVM_REG_ADDR_WIDTH'h00028, "RO", 0);
		this.AFU_INTF_DUMMY1_Dummy_register = this.AFU_INTF_DUMMY1.Dummy_register;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_AFU_INTF)

endclass : ral_block_ac_AFU_INTF



`endif
