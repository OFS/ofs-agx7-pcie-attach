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
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhOffset = uvm_reg_field::type_id::create("NextDfhOffset",,get_full_name());
      this.NextDfhOffset.configure(this, 24, 16, "RO", 0, 24'h2000, 1, 0, 1);
      this.CciMinorRev = uvm_reg_field::type_id::create("CciMinorRev",,get_full_name());
      this.CciMinorRev.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.CciVersion = uvm_reg_field::type_id::create("CciVersion",,get_full_name());
      this.CciVersion.configure(this, 12, 0, "RO", 0, 12'h20, 1, 0, 0);
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
	rand uvm_reg_field ErrorMask;

	function new(string name = "ac_pcie_PCIE_ERROR_MASK");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrorMask = uvm_reg_field::type_id::create("ErrorMask",,get_full_name());
      this.ErrorMask.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_ERROR_MASK)

endclass : ral_reg_ac_pcie_PCIE_ERROR_MASK


class ral_reg_ac_pcie_PCIE_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved_0;
	uvm_reg_field CompletionTimeoutSlotNumber;
	uvm_reg_field CompletionTimeoutVFActive;
	uvm_reg_field CompletionTimeoutVFNum;
	uvm_reg_field CompletionTimeoutPFNum;
	uvm_reg_field CompletionTimeoutTagNumber;
	uvm_reg_field CompletionTimeoutValid;
	rand uvm_reg_field Reserved_1;
	uvm_reg_field PoisonWriteRequest_S3;
	uvm_reg_field PoisonWriteRequest_S2;
	uvm_reg_field PoisonWriteRequest_S1;
	uvm_reg_field PoisonWriteRequest_S0;
	uvm_reg_field PoisonCompletion_S3;
	uvm_reg_field PoisonCompletion_S2;
	uvm_reg_field PoisonCompletion_S1;
	uvm_reg_field PoisonCompletion_S0;
	uvm_reg_field PostedURRequest_S3;
	uvm_reg_field PostedURRequest_S2;
	uvm_reg_field PostedURRequest_S1;
	uvm_reg_field PostedURRequest_S0;
	uvm_reg_field PostedCARequest_S3;
	uvm_reg_field PostedCARequest_S2;
	uvm_reg_field PostedCARequest_S1;
	uvm_reg_field PostedCARequest_S0;
	uvm_reg_field VFErrFIFOOverflow;

	function new(string name = "ac_pcie_PCIE_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved_0 = uvm_reg_field::type_id::create("Reserved_0",,get_full_name());
      this.Reserved_0.configure(this, 2, 62, "WO", 0, 2'h0, 1, 0, 0);
      this.CompletionTimeoutSlotNumber = uvm_reg_field::type_id::create("CompletionTimeoutSlotNumber",,get_full_name());
      this.CompletionTimeoutSlotNumber.configure(this, 5, 57, "RO", 0, 5'h0, 1, 0, 0);
      this.CompletionTimeoutVFActive = uvm_reg_field::type_id::create("CompletionTimeoutVFActive",,get_full_name());
      this.CompletionTimeoutVFActive.configure(this, 1, 56, "RO", 0, 1'h0, 1, 0, 0);
      this.CompletionTimeoutVFNum = uvm_reg_field::type_id::create("CompletionTimeoutVFNum",,get_full_name());
      this.CompletionTimeoutVFNum.configure(this, 11, 45, "RO", 0, 11'h0, 1, 0, 0);
      this.CompletionTimeoutPFNum = uvm_reg_field::type_id::create("CompletionTimeoutPFNum",,get_full_name());
      this.CompletionTimeoutPFNum.configure(this, 3, 42, "RO", 0, 3'h0, 1, 0, 0);
      this.CompletionTimeoutTagNumber = uvm_reg_field::type_id::create("CompletionTimeoutTagNumber",,get_full_name());
      this.CompletionTimeoutTagNumber.configure(this, 10, 32, "RO", 0, 10'h0, 1, 0, 0);
      this.CompletionTimeoutValid = uvm_reg_field::type_id::create("CompletionTimeoutValid",,get_full_name());
      this.CompletionTimeoutValid.configure(this, 1, 31, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved_1 = uvm_reg_field::type_id::create("Reserved_1",,get_full_name());
      this.Reserved_1.configure(this, 14, 17, "WO", 0, 14'h0, 1, 0, 0);
      this.PoisonWriteRequest_S3 = uvm_reg_field::type_id::create("PoisonWriteRequest_S3",,get_full_name());
      this.PoisonWriteRequest_S3.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.PoisonWriteRequest_S2 = uvm_reg_field::type_id::create("PoisonWriteRequest_S2",,get_full_name());
      this.PoisonWriteRequest_S2.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.PoisonWriteRequest_S1 = uvm_reg_field::type_id::create("PoisonWriteRequest_S1",,get_full_name());
      this.PoisonWriteRequest_S1.configure(this, 1, 14, "RO", 0, 1'h0, 1, 0, 0);
      this.PoisonWriteRequest_S0 = uvm_reg_field::type_id::create("PoisonWriteRequest_S0",,get_full_name());
      this.PoisonWriteRequest_S0.configure(this, 1, 13, "RO", 0, 1'h0, 1, 0, 0);
      this.PoisonCompletion_S3 = uvm_reg_field::type_id::create("PoisonCompletion_S3",,get_full_name());
      this.PoisonCompletion_S3.configure(this, 1, 12, "RO", 0, 1'h0, 1, 0, 0);
      this.PoisonCompletion_S2 = uvm_reg_field::type_id::create("PoisonCompletion_S2",,get_full_name());
      this.PoisonCompletion_S2.configure(this, 1, 11, "RO", 0, 1'h0, 1, 0, 0);
      this.PoisonCompletion_S1 = uvm_reg_field::type_id::create("PoisonCompletion_S1",,get_full_name());
      this.PoisonCompletion_S1.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.PoisonCompletion_S0 = uvm_reg_field::type_id::create("PoisonCompletion_S0",,get_full_name());
      this.PoisonCompletion_S0.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.PostedURRequest_S3 = uvm_reg_field::type_id::create("PostedURRequest_S3",,get_full_name());
      this.PostedURRequest_S3.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.PostedURRequest_S2 = uvm_reg_field::type_id::create("PostedURRequest_S2",,get_full_name());
      this.PostedURRequest_S2.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.PostedURRequest_S1 = uvm_reg_field::type_id::create("PostedURRequest_S1",,get_full_name());
      this.PostedURRequest_S1.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.PostedURRequest_S0 = uvm_reg_field::type_id::create("PostedURRequest_S0",,get_full_name());
      this.PostedURRequest_S0.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.PostedCARequest_S3 = uvm_reg_field::type_id::create("PostedCARequest_S3",,get_full_name());
      this.PostedCARequest_S3.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.PostedCARequest_S2 = uvm_reg_field::type_id::create("PostedCARequest_S2",,get_full_name());
      this.PostedCARequest_S2.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.PostedCARequest_S1 = uvm_reg_field::type_id::create("PostedCARequest_S1",,get_full_name());
      this.PostedCARequest_S1.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.PostedCARequest_S0 = uvm_reg_field::type_id::create("PostedCARequest_S0",,get_full_name());
      this.PostedCARequest_S0.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.VFErrFIFOOverflow = uvm_reg_field::type_id::create("VFErrFIFOOverflow",,get_full_name());
      this.VFErrFIFOOverflow.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_ERROR)

endclass : ral_reg_ac_pcie_PCIE_ERROR


class ral_reg_ac_pcie_PCIE_SS_CMD_CSR extends uvm_reg;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field AFU_CMD_ADDR;
	rand uvm_reg_field Reserved0;
	uvm_reg_field ACK_TRANS;
	rand uvm_reg_field WRITE_CMD;
	rand uvm_reg_field READ_CMD;

	function new(string name = "ac_pcie_PCIE_SS_CMD_CSR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved2 = uvm_reg_field::type_id::create("Reserved2",,get_full_name());
      this.Reserved2.configure(this, 14, 50, "WO", 0, 14'h0, 1, 0, 0);
      this.AFU_CMD_ADDR = uvm_reg_field::type_id::create("AFU_CMD_ADDR",,get_full_name());
      this.AFU_CMD_ADDR.configure(this, 18, 32, "RW", 0, 18'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 29, 3, "WO", 0, 29'h0, 1, 0, 0);
      this.ACK_TRANS = uvm_reg_field::type_id::create("ACK_TRANS",,get_full_name());
      this.ACK_TRANS.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.WRITE_CMD = uvm_reg_field::type_id::create("WRITE_CMD",,get_full_name());
      this.WRITE_CMD.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.READ_CMD = uvm_reg_field::type_id::create("READ_CMD",,get_full_name());
      this.READ_CMD.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_SS_CMD_CSR)

endclass : ral_reg_ac_pcie_PCIE_SS_CMD_CSR


class ral_reg_ac_pcie_PCIE_SS_DATA_CSR extends uvm_reg;
	rand uvm_reg_field WRITE_DATA;
	uvm_reg_field READ_DATA;

	function new(string name = "ac_pcie_PCIE_SS_DATA_CSR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.WRITE_DATA = uvm_reg_field::type_id::create("WRITE_DATA",,get_full_name());
      this.WRITE_DATA.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.READ_DATA = uvm_reg_field::type_id::create("READ_DATA",,get_full_name());
      this.READ_DATA.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pcie_PCIE_SS_DATA_CSR)

endclass : ral_reg_ac_pcie_PCIE_SS_DATA_CSR


class ral_block_ac_pcie extends uvm_reg_block;
	rand ral_reg_ac_pcie_PCIE_DFH PCIE_DFH;
	rand ral_reg_ac_pcie_PCIE_SCRATCHPAD PCIE_SCRATCHPAD;
	rand ral_reg_ac_pcie_PCIE_STAT PCIE_STAT;
	rand ral_reg_ac_pcie_PCIE_ERROR_MASK PCIE_ERROR_MASK;
	rand ral_reg_ac_pcie_PCIE_ERROR PCIE_ERROR;
	rand ral_reg_ac_pcie_PCIE_SS_CMD_CSR PCIE_SS_CMD_CSR;
	rand ral_reg_ac_pcie_PCIE_SS_DATA_CSR PCIE_SS_DATA_CSR;
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
	rand uvm_reg_field PCIE_ERROR_MASK_ErrorMask;
	rand uvm_reg_field ErrorMask;
	rand uvm_reg_field PCIE_ERROR_Reserved_0;
	rand uvm_reg_field Reserved_0;
	uvm_reg_field PCIE_ERROR_CompletionTimeoutSlotNumber;
	uvm_reg_field CompletionTimeoutSlotNumber;
	uvm_reg_field PCIE_ERROR_CompletionTimeoutVFActive;
	uvm_reg_field CompletionTimeoutVFActive;
	uvm_reg_field PCIE_ERROR_CompletionTimeoutVFNum;
	uvm_reg_field CompletionTimeoutVFNum;
	uvm_reg_field PCIE_ERROR_CompletionTimeoutPFNum;
	uvm_reg_field CompletionTimeoutPFNum;
	uvm_reg_field PCIE_ERROR_CompletionTimeoutTagNumber;
	uvm_reg_field CompletionTimeoutTagNumber;
	uvm_reg_field PCIE_ERROR_CompletionTimeoutValid;
	uvm_reg_field CompletionTimeoutValid;
	rand uvm_reg_field PCIE_ERROR_Reserved_1;
	rand uvm_reg_field Reserved_1;
	uvm_reg_field PCIE_ERROR_PoisonWriteRequest_S3;
	uvm_reg_field PoisonWriteRequest_S3;
	uvm_reg_field PCIE_ERROR_PoisonWriteRequest_S2;
	uvm_reg_field PoisonWriteRequest_S2;
	uvm_reg_field PCIE_ERROR_PoisonWriteRequest_S1;
	uvm_reg_field PoisonWriteRequest_S1;
	uvm_reg_field PCIE_ERROR_PoisonWriteRequest_S0;
	uvm_reg_field PoisonWriteRequest_S0;
	uvm_reg_field PCIE_ERROR_PoisonCompletion_S3;
	uvm_reg_field PoisonCompletion_S3;
	uvm_reg_field PCIE_ERROR_PoisonCompletion_S2;
	uvm_reg_field PoisonCompletion_S2;
	uvm_reg_field PCIE_ERROR_PoisonCompletion_S1;
	uvm_reg_field PoisonCompletion_S1;
	uvm_reg_field PCIE_ERROR_PoisonCompletion_S0;
	uvm_reg_field PoisonCompletion_S0;
	uvm_reg_field PCIE_ERROR_PostedURRequest_S3;
	uvm_reg_field PostedURRequest_S3;
	uvm_reg_field PCIE_ERROR_PostedURRequest_S2;
	uvm_reg_field PostedURRequest_S2;
	uvm_reg_field PCIE_ERROR_PostedURRequest_S1;
	uvm_reg_field PostedURRequest_S1;
	uvm_reg_field PCIE_ERROR_PostedURRequest_S0;
	uvm_reg_field PostedURRequest_S0;
	uvm_reg_field PCIE_ERROR_PostedCARequest_S3;
	uvm_reg_field PostedCARequest_S3;
	uvm_reg_field PCIE_ERROR_PostedCARequest_S2;
	uvm_reg_field PostedCARequest_S2;
	uvm_reg_field PCIE_ERROR_PostedCARequest_S1;
	uvm_reg_field PostedCARequest_S1;
	uvm_reg_field PCIE_ERROR_PostedCARequest_S0;
	uvm_reg_field PostedCARequest_S0;
	uvm_reg_field PCIE_ERROR_VFErrFIFOOverflow;
	uvm_reg_field VFErrFIFOOverflow;
	rand uvm_reg_field PCIE_SS_CMD_CSR_Reserved2;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field PCIE_SS_CMD_CSR_AFU_CMD_ADDR;
	rand uvm_reg_field AFU_CMD_ADDR;
	rand uvm_reg_field PCIE_SS_CMD_CSR_Reserved0;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PCIE_SS_CMD_CSR_ACK_TRANS;
	uvm_reg_field ACK_TRANS;
	rand uvm_reg_field PCIE_SS_CMD_CSR_WRITE_CMD;
	rand uvm_reg_field WRITE_CMD;
	rand uvm_reg_field PCIE_SS_CMD_CSR_READ_CMD;
	rand uvm_reg_field READ_CMD;
	rand uvm_reg_field PCIE_SS_DATA_CSR_WRITE_DATA;
	rand uvm_reg_field WRITE_DATA;
	uvm_reg_field PCIE_SS_DATA_CSR_READ_DATA;
	uvm_reg_field READ_DATA;

	function new(string name = "ac_pcie");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.PCIE_DFH = ral_reg_ac_pcie_PCIE_DFH::type_id::create("PCIE_DFH",,get_full_name());
      this.PCIE_DFH.configure(this, null, "");
      this.PCIE_DFH.build();
      this.default_map.add_reg(this.PCIE_DFH, `UVM_REG_ADDR_WIDTH'h00000, "RW", 0);
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
      this.default_map.add_reg(this.PCIE_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h00008, "RW", 0);
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
      this.default_map.add_reg(this.PCIE_ERROR_MASK, `UVM_REG_ADDR_WIDTH'h00018, "RW", 0);
		this.PCIE_ERROR_MASK_ErrorMask = this.PCIE_ERROR_MASK.ErrorMask;
		this.ErrorMask = this.PCIE_ERROR_MASK.ErrorMask;
      this.PCIE_ERROR = ral_reg_ac_pcie_PCIE_ERROR::type_id::create("PCIE_ERROR",,get_full_name());
      this.PCIE_ERROR.configure(this, null, "");
      this.PCIE_ERROR.build();
      this.default_map.add_reg(this.PCIE_ERROR, `UVM_REG_ADDR_WIDTH'h00020, "RW", 0);
		this.PCIE_ERROR_Reserved_0 = this.PCIE_ERROR.Reserved_0;
		this.Reserved_0 = this.PCIE_ERROR.Reserved_0;
		this.PCIE_ERROR_CompletionTimeoutSlotNumber = this.PCIE_ERROR.CompletionTimeoutSlotNumber;
		this.CompletionTimeoutSlotNumber = this.PCIE_ERROR.CompletionTimeoutSlotNumber;
		this.PCIE_ERROR_CompletionTimeoutVFActive = this.PCIE_ERROR.CompletionTimeoutVFActive;
		this.CompletionTimeoutVFActive = this.PCIE_ERROR.CompletionTimeoutVFActive;
		this.PCIE_ERROR_CompletionTimeoutVFNum = this.PCIE_ERROR.CompletionTimeoutVFNum;
		this.CompletionTimeoutVFNum = this.PCIE_ERROR.CompletionTimeoutVFNum;
		this.PCIE_ERROR_CompletionTimeoutPFNum = this.PCIE_ERROR.CompletionTimeoutPFNum;
		this.CompletionTimeoutPFNum = this.PCIE_ERROR.CompletionTimeoutPFNum;
		this.PCIE_ERROR_CompletionTimeoutTagNumber = this.PCIE_ERROR.CompletionTimeoutTagNumber;
		this.CompletionTimeoutTagNumber = this.PCIE_ERROR.CompletionTimeoutTagNumber;
		this.PCIE_ERROR_CompletionTimeoutValid = this.PCIE_ERROR.CompletionTimeoutValid;
		this.CompletionTimeoutValid = this.PCIE_ERROR.CompletionTimeoutValid;
		this.PCIE_ERROR_Reserved_1 = this.PCIE_ERROR.Reserved_1;
		this.Reserved_1 = this.PCIE_ERROR.Reserved_1;
		this.PCIE_ERROR_PoisonWriteRequest_S3 = this.PCIE_ERROR.PoisonWriteRequest_S3;
		this.PoisonWriteRequest_S3 = this.PCIE_ERROR.PoisonWriteRequest_S3;
		this.PCIE_ERROR_PoisonWriteRequest_S2 = this.PCIE_ERROR.PoisonWriteRequest_S2;
		this.PoisonWriteRequest_S2 = this.PCIE_ERROR.PoisonWriteRequest_S2;
		this.PCIE_ERROR_PoisonWriteRequest_S1 = this.PCIE_ERROR.PoisonWriteRequest_S1;
		this.PoisonWriteRequest_S1 = this.PCIE_ERROR.PoisonWriteRequest_S1;
		this.PCIE_ERROR_PoisonWriteRequest_S0 = this.PCIE_ERROR.PoisonWriteRequest_S0;
		this.PoisonWriteRequest_S0 = this.PCIE_ERROR.PoisonWriteRequest_S0;
		this.PCIE_ERROR_PoisonCompletion_S3 = this.PCIE_ERROR.PoisonCompletion_S3;
		this.PoisonCompletion_S3 = this.PCIE_ERROR.PoisonCompletion_S3;
		this.PCIE_ERROR_PoisonCompletion_S2 = this.PCIE_ERROR.PoisonCompletion_S2;
		this.PoisonCompletion_S2 = this.PCIE_ERROR.PoisonCompletion_S2;
		this.PCIE_ERROR_PoisonCompletion_S1 = this.PCIE_ERROR.PoisonCompletion_S1;
		this.PoisonCompletion_S1 = this.PCIE_ERROR.PoisonCompletion_S1;
		this.PCIE_ERROR_PoisonCompletion_S0 = this.PCIE_ERROR.PoisonCompletion_S0;
		this.PoisonCompletion_S0 = this.PCIE_ERROR.PoisonCompletion_S0;
		this.PCIE_ERROR_PostedURRequest_S3 = this.PCIE_ERROR.PostedURRequest_S3;
		this.PostedURRequest_S3 = this.PCIE_ERROR.PostedURRequest_S3;
		this.PCIE_ERROR_PostedURRequest_S2 = this.PCIE_ERROR.PostedURRequest_S2;
		this.PostedURRequest_S2 = this.PCIE_ERROR.PostedURRequest_S2;
		this.PCIE_ERROR_PostedURRequest_S1 = this.PCIE_ERROR.PostedURRequest_S1;
		this.PostedURRequest_S1 = this.PCIE_ERROR.PostedURRequest_S1;
		this.PCIE_ERROR_PostedURRequest_S0 = this.PCIE_ERROR.PostedURRequest_S0;
		this.PostedURRequest_S0 = this.PCIE_ERROR.PostedURRequest_S0;
		this.PCIE_ERROR_PostedCARequest_S3 = this.PCIE_ERROR.PostedCARequest_S3;
		this.PostedCARequest_S3 = this.PCIE_ERROR.PostedCARequest_S3;
		this.PCIE_ERROR_PostedCARequest_S2 = this.PCIE_ERROR.PostedCARequest_S2;
		this.PostedCARequest_S2 = this.PCIE_ERROR.PostedCARequest_S2;
		this.PCIE_ERROR_PostedCARequest_S1 = this.PCIE_ERROR.PostedCARequest_S1;
		this.PostedCARequest_S1 = this.PCIE_ERROR.PostedCARequest_S1;
		this.PCIE_ERROR_PostedCARequest_S0 = this.PCIE_ERROR.PostedCARequest_S0;
		this.PostedCARequest_S0 = this.PCIE_ERROR.PostedCARequest_S0;
		this.PCIE_ERROR_VFErrFIFOOverflow = this.PCIE_ERROR.VFErrFIFOOverflow;
		this.VFErrFIFOOverflow = this.PCIE_ERROR.VFErrFIFOOverflow;
      this.PCIE_SS_CMD_CSR = ral_reg_ac_pcie_PCIE_SS_CMD_CSR::type_id::create("PCIE_SS_CMD_CSR",,get_full_name());
      this.PCIE_SS_CMD_CSR.configure(this, null, "");
      this.PCIE_SS_CMD_CSR.build();
      this.default_map.add_reg(this.PCIE_SS_CMD_CSR, `UVM_REG_ADDR_WIDTH'h00028, "RW", 0);
		this.PCIE_SS_CMD_CSR_Reserved2 = this.PCIE_SS_CMD_CSR.Reserved2;
		this.Reserved2 = this.PCIE_SS_CMD_CSR.Reserved2;
		this.PCIE_SS_CMD_CSR_AFU_CMD_ADDR = this.PCIE_SS_CMD_CSR.AFU_CMD_ADDR;
		this.AFU_CMD_ADDR = this.PCIE_SS_CMD_CSR.AFU_CMD_ADDR;
		this.PCIE_SS_CMD_CSR_Reserved0 = this.PCIE_SS_CMD_CSR.Reserved0;
		this.Reserved0 = this.PCIE_SS_CMD_CSR.Reserved0;
		this.PCIE_SS_CMD_CSR_ACK_TRANS = this.PCIE_SS_CMD_CSR.ACK_TRANS;
		this.ACK_TRANS = this.PCIE_SS_CMD_CSR.ACK_TRANS;
		this.PCIE_SS_CMD_CSR_WRITE_CMD = this.PCIE_SS_CMD_CSR.WRITE_CMD;
		this.WRITE_CMD = this.PCIE_SS_CMD_CSR.WRITE_CMD;
		this.PCIE_SS_CMD_CSR_READ_CMD = this.PCIE_SS_CMD_CSR.READ_CMD;
		this.READ_CMD = this.PCIE_SS_CMD_CSR.READ_CMD;
      this.PCIE_SS_DATA_CSR = ral_reg_ac_pcie_PCIE_SS_DATA_CSR::type_id::create("PCIE_SS_DATA_CSR",,get_full_name());
      this.PCIE_SS_DATA_CSR.configure(this, null, "");
      this.PCIE_SS_DATA_CSR.build();
      this.default_map.add_reg(this.PCIE_SS_DATA_CSR, `UVM_REG_ADDR_WIDTH'h00030, "RW", 0);
		this.PCIE_SS_DATA_CSR_WRITE_DATA = this.PCIE_SS_DATA_CSR.WRITE_DATA;
		this.WRITE_DATA = this.PCIE_SS_DATA_CSR.WRITE_DATA;
		this.PCIE_SS_DATA_CSR_READ_DATA = this.PCIE_SS_DATA_CSR.READ_DATA;
		this.READ_DATA = this.PCIE_SS_DATA_CSR.READ_DATA;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_pcie)

endclass : ral_block_ac_pcie



`endif
