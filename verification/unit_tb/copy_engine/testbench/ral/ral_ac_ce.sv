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

	function new(string name = "ac_ce_CE_FEATURE_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h1, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EndOfList = uvm_reg_field::type_id::create("EndOfList",,get_full_name());
      this.EndOfList.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_DFH)

endclass : ral_reg_ac_ce_CE_FEATURE_DFH


class ral_reg_ac_ce_CE_FEATURE_GUID_L extends uvm_reg;
	uvm_reg_field CE_ID_L;

	function new(string name = "ac_ce_CE_FEATURE_GUID_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CE_ID_L = uvm_reg_field::type_id::create("CE_ID_L",,get_full_name());
      this.CE_ID_L.configure(this, 64, 0, "RO", 0, 64'hbd4257dc93ea7f91, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_GUID_L)

endclass : ral_reg_ac_ce_CE_FEATURE_GUID_L


class ral_reg_ac_ce_CE_FEATURE_GUID_H extends uvm_reg;
	uvm_reg_field CE_ID_H;

	function new(string name = "ac_ce_CE_FEATURE_GUID_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CE_ID_H = uvm_reg_field::type_id::create("CE_ID_H",,get_full_name());
      this.CE_ID_H.configure(this, 64, 0, "RO", 0, 64'h44bfc10db42a44e5, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_GUID_H)

endclass : ral_reg_ac_ce_CE_FEATURE_GUID_H


class ral_reg_ac_ce_CE_FEATURE_CSR_ADDR extends uvm_reg;
	uvm_reg_field CSR_REL;
	uvm_reg_field CSR_ADDR;

	function new(string name = "ac_ce_CE_FEATURE_CSR_ADDR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CSR_REL = uvm_reg_field::type_id::create("CSR_REL",,get_full_name());
      this.CSR_REL.configure(this, 1, 63, "RO", 0, 1'h0, 1, 0, 0);
      this.CSR_ADDR = uvm_reg_field::type_id::create("CSR_ADDR",,get_full_name());
      this.CSR_ADDR.configure(this, 63, 0, "RO", 0, 63'h000000100, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CE_FEATURE_CSR_ADDR)

endclass : ral_reg_ac_ce_CE_FEATURE_CSR_ADDR


class ral_reg_ac_ce_CE_FEATURE_CSR_SIZE_GROUP extends uvm_reg;
	uvm_reg_field CSR_SIZE;
	uvm_reg_field HAS_PARAMS;
	uvm_reg_field GROUPING_ID;

	function new(string name = "ac_ce_CE_FEATURE_CSR_SIZE_GROUP");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
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

endclass : ral_reg_ac_ce_CE_FEATURE_CSR_SIZE_GROUP


class ral_reg_ac_ce_CSR_SCRATCHPAD0 extends uvm_reg;
	rand uvm_reg_field SCRATCHPAD0;

	function new(string name = "ac_ce_CSR_SCRATCHPAD0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.SCRATCHPAD0 = uvm_reg_field::type_id::create("SCRATCHPAD0",,get_full_name());
      this.SCRATCHPAD0.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_SCRATCHPAD0)

endclass : ral_reg_ac_ce_CSR_SCRATCHPAD0


class ral_reg_ac_ce_CSR_SCRATCHPAD1 extends uvm_reg;
	rand uvm_reg_field SCRATCHPAD1;

	function new(string name = "ac_ce_CSR_SCRATCHPAD1");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.SCRATCHPAD1 = uvm_reg_field::type_id::create("SCRATCHPAD1",,get_full_name());
      this.SCRATCHPAD1.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_SCRATCHPAD1)

endclass : ral_reg_ac_ce_CSR_SCRATCHPAD1


class ral_reg_ac_ce_CSR_HPS2HOST_RDY_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field HPS_RDY;

	function new(string name = "ac_ce_CSR_HPS2HOST_RDY_STATUS");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 63, 1, "WO", 0, 63'h000000000, 1, 0, 0);
      this.HPS_RDY = uvm_reg_field::type_id::create("HPS_RDY",,get_full_name());
      this.HPS_RDY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HPS2HOST_RDY_STATUS)

endclass : ral_reg_ac_ce_CSR_HPS2HOST_RDY_STATUS


class ral_reg_ac_ce_CSR_SRC_ADDR extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field CSR_SRC_ADDR;

	function new(string name = "ac_ce_CSR_SRC_ADDR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.CSR_SRC_ADDR = uvm_reg_field::type_id::create("CSR_SRC_ADDR",,get_full_name());
      this.CSR_SRC_ADDR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_SRC_ADDR)

endclass : ral_reg_ac_ce_CSR_SRC_ADDR


class ral_reg_ac_ce_CSR_DST_ADDR extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field CSR_DST_ADDR;

	function new(string name = "ac_ce_CSR_DST_ADDR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.CSR_DST_ADDR = uvm_reg_field::type_id::create("CSR_DST_ADDR",,get_full_name());
      this.CSR_DST_ADDR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_DST_ADDR)

endclass : ral_reg_ac_ce_CSR_DST_ADDR


class ral_reg_ac_ce_CSR_DATA_SIZE extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field CSR_DATA_SIZE;

	function new(string name = "ac_ce_CSR_DATA_SIZE");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.CSR_DATA_SIZE = uvm_reg_field::type_id::create("CSR_DATA_SIZE",,get_full_name());
      this.CSR_DATA_SIZE.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_DATA_SIZE)

endclass : ral_reg_ac_ce_CSR_DATA_SIZE


class ral_reg_ac_ce_CSR_HOST2CE_MRD_START extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field MRD_START;

	function new(string name = "ac_ce_CSR_HOST2CE_MRD_START");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 63, 1, "WO", 0, 63'h000000000, 1, 0, 0);
      this.MRD_START = uvm_reg_field::type_id::create("MRD_START",,get_full_name());
      this.MRD_START.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HOST2CE_MRD_START)

endclass : ral_reg_ac_ce_CSR_HOST2CE_MRD_START


class ral_reg_ac_ce_CSR_CE2HOST_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field CE_AXIST_CPL_STS;
	uvm_reg_field CE_ACELITE_BRESP_STS;
	uvm_reg_field CE_DMA_STS;

	function new(string name = "ac_ce_CSR_CE2HOST_STATUS");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 57, 7, "WO", 0, 57'h000000000, 1, 0, 0);
      this.CE_AXIST_CPL_STS = uvm_reg_field::type_id::create("CE_AXIST_CPL_STS",,get_full_name());
      this.CE_AXIST_CPL_STS.configure(this, 3, 4, "RO", 0, 3'h0, 1, 0, 0);
      this.CE_ACELITE_BRESP_STS = uvm_reg_field::type_id::create("CE_ACELITE_BRESP_STS",,get_full_name());
      this.CE_ACELITE_BRESP_STS.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.CE_DMA_STS = uvm_reg_field::type_id::create("CE_DMA_STS",,get_full_name());
      this.CE_DMA_STS.configure(this, 2, 0, "RO", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_CE2HOST_STATUS)

endclass : ral_reg_ac_ce_CSR_CE2HOST_STATUS


class ral_reg_ac_ce_CSR_HOST2HPS_GPIO extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field HOST_HPS_CPL;

	function new(string name = "ac_ce_CSR_HOST2HPS_GPIO");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 63, 1, "WO", 0, 63'h000000000, 1, 0, 0);
      this.HOST_HPS_CPL = uvm_reg_field::type_id::create("HOST_HPS_CPL",,get_full_name());
      this.HOST_HPS_CPL.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HOST2HPS_GPIO)

endclass : ral_reg_ac_ce_CSR_HOST2HPS_GPIO


class ral_reg_ac_ce_CSR_HPS2HOST_VFY_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field HPS_RDY_TIMEOUT;
	uvm_reg_field KERNEL_VFY;
	uvm_reg_field SSBL_VFY;

	function new(string name = "ac_ce_CSR_HPS2HOST_VFY_STATUS");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 59, 5, "WO", 0, 59'h000000000, 1, 0, 0);
      this.HPS_RDY_TIMEOUT = uvm_reg_field::type_id::create("HPS_RDY_TIMEOUT",,get_full_name());
      this.HPS_RDY_TIMEOUT.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.KERNEL_VFY = uvm_reg_field::type_id::create("KERNEL_VFY",,get_full_name());
      this.KERNEL_VFY.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.SSBL_VFY = uvm_reg_field::type_id::create("SSBL_VFY",,get_full_name());
      this.SSBL_VFY.configure(this, 2, 0, "RO", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_ce_CSR_HPS2HOST_VFY_STATUS)

endclass : ral_reg_ac_ce_CSR_HPS2HOST_VFY_STATUS


class ral_block_ac_ce extends uvm_reg_block;
	rand ral_reg_ac_ce_CE_FEATURE_DFH CE_FEATURE_DFH;
	rand ral_reg_ac_ce_CE_FEATURE_GUID_L CE_FEATURE_GUID_L;
	rand ral_reg_ac_ce_CE_FEATURE_GUID_H CE_FEATURE_GUID_H;
	rand ral_reg_ac_ce_CE_FEATURE_CSR_ADDR CE_FEATURE_CSR_ADDR;
	rand ral_reg_ac_ce_CE_FEATURE_CSR_SIZE_GROUP CE_FEATURE_CSR_SIZE_GROUP;
	rand ral_reg_ac_ce_CSR_SCRATCHPAD0 CSR_SCRATCHPAD0;
	rand ral_reg_ac_ce_CSR_SCRATCHPAD1 CSR_SCRATCHPAD1;
	rand ral_reg_ac_ce_CSR_HPS2HOST_RDY_STATUS CSR_HPS2HOST_RDY_STATUS;
	rand ral_reg_ac_ce_CSR_SRC_ADDR CSR_SRC_ADDR;
	rand ral_reg_ac_ce_CSR_DST_ADDR CSR_DST_ADDR;
	rand ral_reg_ac_ce_CSR_DATA_SIZE CSR_DATA_SIZE;
	rand ral_reg_ac_ce_CSR_HOST2CE_MRD_START CSR_HOST2CE_MRD_START;
	rand ral_reg_ac_ce_CSR_CE2HOST_STATUS CSR_CE2HOST_STATUS;
	rand ral_reg_ac_ce_CSR_HOST2HPS_GPIO CSR_HOST2HPS_GPIO;
	rand ral_reg_ac_ce_CSR_HPS2HOST_VFY_STATUS CSR_HPS2HOST_VFY_STATUS;
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
	rand uvm_reg_field CSR_SCRATCHPAD0_SCRATCHPAD0;
	rand uvm_reg_field SCRATCHPAD0;
	rand uvm_reg_field CSR_SCRATCHPAD1_SCRATCHPAD1;
	rand uvm_reg_field SCRATCHPAD1;
	rand uvm_reg_field CSR_HPS2HOST_RDY_STATUS_Reserved;
	uvm_reg_field CSR_HPS2HOST_RDY_STATUS_HPS_RDY;
	uvm_reg_field HPS_RDY;
	rand uvm_reg_field CSR_SRC_ADDR_Reserved;
	rand uvm_reg_field CSR_SRC_ADDR_CSR_SRC_ADDR;
	rand uvm_reg_field CSR_DST_ADDR_Reserved;
	rand uvm_reg_field CSR_DST_ADDR_CSR_DST_ADDR;
	rand uvm_reg_field CSR_DATA_SIZE_Reserved;
	rand uvm_reg_field CSR_DATA_SIZE_CSR_DATA_SIZE;
	rand uvm_reg_field CSR_HOST2CE_MRD_START_Reserved;
	rand uvm_reg_field CSR_HOST2CE_MRD_START_MRD_START;
	rand uvm_reg_field MRD_START;
	rand uvm_reg_field CSR_CE2HOST_STATUS_Reserved;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_AXIST_CPL_STS;
	uvm_reg_field CE_AXIST_CPL_STS;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_ACELITE_BRESP_STS;
	uvm_reg_field CE_ACELITE_BRESP_STS;
	uvm_reg_field CSR_CE2HOST_STATUS_CE_DMA_STS;
	uvm_reg_field CE_DMA_STS;
	rand uvm_reg_field CSR_HOST2HPS_GPIO_Reserved;
	rand uvm_reg_field CSR_HOST2HPS_GPIO_HOST_HPS_CPL;
	rand uvm_reg_field HOST_HPS_CPL;
	rand uvm_reg_field CSR_HPS2HOST_VFY_STATUS_Reserved;
	uvm_reg_field CSR_HPS2HOST_VFY_STATUS_HPS_RDY_TIMEOUT;
	uvm_reg_field HPS_RDY_TIMEOUT;
	uvm_reg_field CSR_HPS2HOST_VFY_STATUS_KERNEL_VFY;
	uvm_reg_field KERNEL_VFY;
	uvm_reg_field CSR_HPS2HOST_VFY_STATUS_SSBL_VFY;
	uvm_reg_field SSBL_VFY;

	function new(string name = "ac_ce");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
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
      this.CSR_SCRATCHPAD0 = ral_reg_ac_ce_CSR_SCRATCHPAD0::type_id::create("CSR_SCRATCHPAD0",,get_full_name());
      this.CSR_SCRATCHPAD0.configure(this, null, "");
      this.CSR_SCRATCHPAD0.build();
      this.default_map.add_reg(this.CSR_SCRATCHPAD0, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
		this.CSR_SCRATCHPAD0_SCRATCHPAD0 = this.CSR_SCRATCHPAD0.SCRATCHPAD0;
		this.SCRATCHPAD0 = this.CSR_SCRATCHPAD0.SCRATCHPAD0;
      this.CSR_SCRATCHPAD1 = ral_reg_ac_ce_CSR_SCRATCHPAD1::type_id::create("CSR_SCRATCHPAD1",,get_full_name());
      this.CSR_SCRATCHPAD1.configure(this, null, "");
      this.CSR_SCRATCHPAD1.build();
      this.default_map.add_reg(this.CSR_SCRATCHPAD1, `UVM_REG_ADDR_WIDTH'h108, "RW", 0);
		this.CSR_SCRATCHPAD1_SCRATCHPAD1 = this.CSR_SCRATCHPAD1.SCRATCHPAD1;
		this.SCRATCHPAD1 = this.CSR_SCRATCHPAD1.SCRATCHPAD1;
      this.CSR_HPS2HOST_RDY_STATUS = ral_reg_ac_ce_CSR_HPS2HOST_RDY_STATUS::type_id::create("CSR_HPS2HOST_RDY_STATUS",,get_full_name());
      this.CSR_HPS2HOST_RDY_STATUS.configure(this, null, "");
      this.CSR_HPS2HOST_RDY_STATUS.build();
      this.default_map.add_reg(this.CSR_HPS2HOST_RDY_STATUS, `UVM_REG_ADDR_WIDTH'h110, "RW", 0);
		this.CSR_HPS2HOST_RDY_STATUS_Reserved = this.CSR_HPS2HOST_RDY_STATUS.Reserved;
		this.CSR_HPS2HOST_RDY_STATUS_HPS_RDY = this.CSR_HPS2HOST_RDY_STATUS.HPS_RDY;
		this.HPS_RDY = this.CSR_HPS2HOST_RDY_STATUS.HPS_RDY;
      this.CSR_SRC_ADDR = ral_reg_ac_ce_CSR_SRC_ADDR::type_id::create("CSR_SRC_ADDR",,get_full_name());
      this.CSR_SRC_ADDR.configure(this, null, "");
      this.CSR_SRC_ADDR.build();
      this.default_map.add_reg(this.CSR_SRC_ADDR, `UVM_REG_ADDR_WIDTH'h118, "RW", 0);
		this.CSR_SRC_ADDR_Reserved = this.CSR_SRC_ADDR.Reserved;
		this.CSR_SRC_ADDR_CSR_SRC_ADDR = this.CSR_SRC_ADDR.CSR_SRC_ADDR;
      this.CSR_DST_ADDR = ral_reg_ac_ce_CSR_DST_ADDR::type_id::create("CSR_DST_ADDR",,get_full_name());
      this.CSR_DST_ADDR.configure(this, null, "");
      this.CSR_DST_ADDR.build();
      this.default_map.add_reg(this.CSR_DST_ADDR, `UVM_REG_ADDR_WIDTH'h120, "RW", 0);
		this.CSR_DST_ADDR_Reserved = this.CSR_DST_ADDR.Reserved;
		this.CSR_DST_ADDR_CSR_DST_ADDR = this.CSR_DST_ADDR.CSR_DST_ADDR;
      this.CSR_DATA_SIZE = ral_reg_ac_ce_CSR_DATA_SIZE::type_id::create("CSR_DATA_SIZE",,get_full_name());
      this.CSR_DATA_SIZE.configure(this, null, "");
      this.CSR_DATA_SIZE.build();
      this.default_map.add_reg(this.CSR_DATA_SIZE, `UVM_REG_ADDR_WIDTH'h128, "RW", 0);
		this.CSR_DATA_SIZE_Reserved = this.CSR_DATA_SIZE.Reserved;
		this.CSR_DATA_SIZE_CSR_DATA_SIZE = this.CSR_DATA_SIZE.CSR_DATA_SIZE;
      this.CSR_HOST2CE_MRD_START = ral_reg_ac_ce_CSR_HOST2CE_MRD_START::type_id::create("CSR_HOST2CE_MRD_START",,get_full_name());
      this.CSR_HOST2CE_MRD_START.configure(this, null, "");
      this.CSR_HOST2CE_MRD_START.build();
      this.default_map.add_reg(this.CSR_HOST2CE_MRD_START, `UVM_REG_ADDR_WIDTH'h130, "RW", 0);
		this.CSR_HOST2CE_MRD_START_Reserved = this.CSR_HOST2CE_MRD_START.Reserved;
		this.CSR_HOST2CE_MRD_START_MRD_START = this.CSR_HOST2CE_MRD_START.MRD_START;
		this.MRD_START = this.CSR_HOST2CE_MRD_START.MRD_START;
      this.CSR_CE2HOST_STATUS = ral_reg_ac_ce_CSR_CE2HOST_STATUS::type_id::create("CSR_CE2HOST_STATUS",,get_full_name());
      this.CSR_CE2HOST_STATUS.configure(this, null, "");
      this.CSR_CE2HOST_STATUS.build();
      this.default_map.add_reg(this.CSR_CE2HOST_STATUS, `UVM_REG_ADDR_WIDTH'h138, "RW", 0);
		this.CSR_CE2HOST_STATUS_Reserved = this.CSR_CE2HOST_STATUS.Reserved;
		this.CSR_CE2HOST_STATUS_CE_AXIST_CPL_STS = this.CSR_CE2HOST_STATUS.CE_AXIST_CPL_STS;
		this.CE_AXIST_CPL_STS = this.CSR_CE2HOST_STATUS.CE_AXIST_CPL_STS;
		this.CSR_CE2HOST_STATUS_CE_ACELITE_BRESP_STS = this.CSR_CE2HOST_STATUS.CE_ACELITE_BRESP_STS;
		this.CE_ACELITE_BRESP_STS = this.CSR_CE2HOST_STATUS.CE_ACELITE_BRESP_STS;
		this.CSR_CE2HOST_STATUS_CE_DMA_STS = this.CSR_CE2HOST_STATUS.CE_DMA_STS;
		this.CE_DMA_STS = this.CSR_CE2HOST_STATUS.CE_DMA_STS;
      this.CSR_HOST2HPS_GPIO = ral_reg_ac_ce_CSR_HOST2HPS_GPIO::type_id::create("CSR_HOST2HPS_GPIO",,get_full_name());
      this.CSR_HOST2HPS_GPIO.configure(this, null, "");
      this.CSR_HOST2HPS_GPIO.build();
      this.default_map.add_reg(this.CSR_HOST2HPS_GPIO, `UVM_REG_ADDR_WIDTH'h140, "RW", 0);
		this.CSR_HOST2HPS_GPIO_Reserved = this.CSR_HOST2HPS_GPIO.Reserved;
		this.CSR_HOST2HPS_GPIO_HOST_HPS_CPL = this.CSR_HOST2HPS_GPIO.HOST_HPS_CPL;
		this.HOST_HPS_CPL = this.CSR_HOST2HPS_GPIO.HOST_HPS_CPL;
      this.CSR_HPS2HOST_VFY_STATUS = ral_reg_ac_ce_CSR_HPS2HOST_VFY_STATUS::type_id::create("CSR_HPS2HOST_VFY_STATUS",,get_full_name());
      this.CSR_HPS2HOST_VFY_STATUS.configure(this, null, "");
      this.CSR_HPS2HOST_VFY_STATUS.build();
      this.default_map.add_reg(this.CSR_HPS2HOST_VFY_STATUS, `UVM_REG_ADDR_WIDTH'h148, "RW", 0);
		this.CSR_HPS2HOST_VFY_STATUS_Reserved = this.CSR_HPS2HOST_VFY_STATUS.Reserved;
		this.CSR_HPS2HOST_VFY_STATUS_HPS_RDY_TIMEOUT = this.CSR_HPS2HOST_VFY_STATUS.HPS_RDY_TIMEOUT;
		this.HPS_RDY_TIMEOUT = this.CSR_HPS2HOST_VFY_STATUS.HPS_RDY_TIMEOUT;
		this.CSR_HPS2HOST_VFY_STATUS_KERNEL_VFY = this.CSR_HPS2HOST_VFY_STATUS.KERNEL_VFY;
		this.KERNEL_VFY = this.CSR_HPS2HOST_VFY_STATUS.KERNEL_VFY;
		this.CSR_HPS2HOST_VFY_STATUS_SSBL_VFY = this.CSR_HPS2HOST_VFY_STATUS.SSBL_VFY;
		this.SSBL_VFY = this.CSR_HPS2HOST_VFY_STATUS.SSBL_VFY;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_ce)

endclass : ral_block_ac_ce



`endif
