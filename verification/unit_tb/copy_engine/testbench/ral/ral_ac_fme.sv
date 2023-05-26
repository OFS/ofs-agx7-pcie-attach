// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_FME
`define RAL_AC_FME

import uvm_pkg::*;

class ral_reg_ac_fme_FME_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field AfuMajVersion;
	uvm_reg_field CorefimVersion;

	function new(string name = "ac_fme_FME_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h4, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhOffset = uvm_reg_field::type_id::create("NextDfhOffset",,get_full_name());
      this.NextDfhOffset.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.AfuMajVersion = uvm_reg_field::type_id::create("AfuMajVersion",,get_full_name());
      this.AfuMajVersion.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.CorefimVersion = uvm_reg_field::type_id::create("CorefimVersion",,get_full_name());
      this.CorefimVersion.configure(this, 12, 0, "RO", 0, 12'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_DFH)

endclass : ral_reg_ac_fme_FME_DFH


class ral_reg_ac_fme_FME_AFU_ID_L extends uvm_reg;
	uvm_reg_field AfuIdLow;

	function new(string name = "ac_fme_FME_AFU_ID_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AfuIdLow = uvm_reg_field::type_id::create("AfuIdLow",,get_full_name());
      this.AfuIdLow.configure(this, 64, 0, "RO", 0, 64'h82fe38f0f9e17764, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_AFU_ID_L)

endclass : ral_reg_ac_fme_FME_AFU_ID_L


class ral_reg_ac_fme_FME_AFU_ID_H extends uvm_reg;
	uvm_reg_field AfuIdHigh;

	function new(string name = "ac_fme_FME_AFU_ID_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AfuIdHigh = uvm_reg_field::type_id::create("AfuIdHigh",,get_full_name());
      this.AfuIdHigh.configure(this, 64, 0, "RO", 0, 64'hbfaf2ae94a5246e3, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_AFU_ID_H)

endclass : ral_reg_ac_fme_FME_AFU_ID_H


class ral_reg_ac_fme_FME_NEXT_AFU extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field NextAfuDfhOffset;

	function new(string name = "ac_fme_FME_NEXT_AFU");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 40, 24, "WO", 0, 40'h000000000, 1, 0, 1);
      this.NextAfuDfhOffset = uvm_reg_field::type_id::create("NextAfuDfhOffset",,get_full_name());
      this.NextAfuDfhOffset.configure(this, 24, 0, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_NEXT_AFU)

endclass : ral_reg_ac_fme_FME_NEXT_AFU


class ral_reg_ac_fme_DUMMY_0020 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_0020");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_0020)

endclass : ral_reg_ac_fme_DUMMY_0020


class ral_reg_ac_fme_FME_SCRATCHPAD0 extends uvm_reg;
	rand uvm_reg_field Scratchpad;

	function new(string name = "ac_fme_FME_SCRATCHPAD0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scratchpad = uvm_reg_field::type_id::create("Scratchpad",,get_full_name());
      this.Scratchpad.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_SCRATCHPAD0)

endclass : ral_reg_ac_fme_FME_SCRATCHPAD0


class ral_reg_ac_fme_FAB_CAPABILITY extends uvm_reg;
	rand uvm_reg_field Reserved30;
	uvm_reg_field AddressWidth;
	rand uvm_reg_field Reserved20;
	uvm_reg_field NumPorts;
	rand uvm_reg_field Reserved13;
	uvm_reg_field Pcie0Link;
	rand uvm_reg_field Reserved8;
	uvm_reg_field FabricVersion;

	function new(string name = "ac_fme_FAB_CAPABILITY");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved30 = uvm_reg_field::type_id::create("Reserved30",,get_full_name());
      this.Reserved30.configure(this, 34, 30, "WO", 0, 34'h000000000, 1, 0, 0);
      this.AddressWidth = uvm_reg_field::type_id::create("AddressWidth",,get_full_name());
      this.AddressWidth.configure(this, 6, 24, "RO", 0, 6'h14, 1, 0, 0);
      this.Reserved20 = uvm_reg_field::type_id::create("Reserved20",,get_full_name());
      this.Reserved20.configure(this, 4, 20, "WO", 0, 4'h0, 1, 0, 0);
      this.NumPorts = uvm_reg_field::type_id::create("NumPorts",,get_full_name());
      this.NumPorts.configure(this, 3, 17, "RO", 0, 3'h1, 1, 0, 0);
      this.Reserved13 = uvm_reg_field::type_id::create("Reserved13",,get_full_name());
      this.Reserved13.configure(this, 4, 13, "WO", 0, 4'h0, 1, 0, 0);
      this.Pcie0Link = uvm_reg_field::type_id::create("Pcie0Link",,get_full_name());
      this.Pcie0Link.configure(this, 1, 12, "RO", 0, 1'h1, 1, 0, 0);
      this.Reserved8 = uvm_reg_field::type_id::create("Reserved8",,get_full_name());
      this.Reserved8.configure(this, 4, 8, "WO", 0, 4'h0, 1, 0, 0);
      this.FabricVersion = uvm_reg_field::type_id::create("FabricVersion",,get_full_name());
      this.FabricVersion.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FAB_CAPABILITY)

endclass : ral_reg_ac_fme_FAB_CAPABILITY


class ral_reg_ac_fme_PORT0_OFFSET extends uvm_reg;
	rand uvm_reg_field Reserved61;
	uvm_reg_field PortImplemented;
	rand uvm_reg_field Reserved57;
	rand uvm_reg_field DecouplePortCSR;
	rand uvm_reg_field AfuAccessCtrl;
	rand uvm_reg_field Reserved35;
	uvm_reg_field BarID;
	rand uvm_reg_field Reserved24;
	uvm_reg_field PortByteOffset;

	function new(string name = "ac_fme_PORT0_OFFSET");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved61 = uvm_reg_field::type_id::create("Reserved61",,get_full_name());
      this.Reserved61.configure(this, 3, 61, "WO", 0, 3'h0, 1, 0, 0);
      this.PortImplemented = uvm_reg_field::type_id::create("PortImplemented",,get_full_name());
      this.PortImplemented.configure(this, 1, 60, "RO", 0, 1'h1, 1, 0, 0);
      this.Reserved57 = uvm_reg_field::type_id::create("Reserved57",,get_full_name());
      this.Reserved57.configure(this, 3, 57, "WO", 0, 3'h0, 1, 0, 0);
      this.DecouplePortCSR = uvm_reg_field::type_id::create("DecouplePortCSR",,get_full_name());
      this.DecouplePortCSR.configure(this, 1, 56, "RW", 0, 1'h0, 1, 0, 0);
      this.AfuAccessCtrl = uvm_reg_field::type_id::create("AfuAccessCtrl",,get_full_name());
      this.AfuAccessCtrl.configure(this, 1, 55, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved35 = uvm_reg_field::type_id::create("Reserved35",,get_full_name());
      this.Reserved35.configure(this, 20, 35, "WO", 0, 20'h0, 1, 0, 0);
      this.BarID = uvm_reg_field::type_id::create("BarID",,get_full_name());
      this.BarID.configure(this, 3, 32, "RO", 0, 3'h7, 1, 0, 0);
      this.Reserved24 = uvm_reg_field::type_id::create("Reserved24",,get_full_name());
      this.Reserved24.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PortByteOffset = uvm_reg_field::type_id::create("PortByteOffset",,get_full_name());
      this.PortByteOffset.configure(this, 24, 0, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_PORT0_OFFSET)

endclass : ral_reg_ac_fme_PORT0_OFFSET


class ral_reg_ac_fme_PORT1_OFFSET extends uvm_reg;
	rand uvm_reg_field Reserved61;
	uvm_reg_field PortImplemented;
	rand uvm_reg_field Reserved57;
	rand uvm_reg_field DecouplePortCSR;
	rand uvm_reg_field AfuAccessCtrl;
	rand uvm_reg_field Reserved35;
	uvm_reg_field BarID;
	rand uvm_reg_field Reserved24;
	uvm_reg_field PortByteOffset;

	function new(string name = "ac_fme_PORT1_OFFSET");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved61 = uvm_reg_field::type_id::create("Reserved61",,get_full_name());
      this.Reserved61.configure(this, 3, 61, "WO", 0, 3'h0, 1, 0, 0);
      this.PortImplemented = uvm_reg_field::type_id::create("PortImplemented",,get_full_name());
      this.PortImplemented.configure(this, 1, 60, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved57 = uvm_reg_field::type_id::create("Reserved57",,get_full_name());
      this.Reserved57.configure(this, 3, 57, "WO", 0, 3'h0, 1, 0, 0);
      this.DecouplePortCSR = uvm_reg_field::type_id::create("DecouplePortCSR",,get_full_name());
      this.DecouplePortCSR.configure(this, 1, 56, "RW", 0, 1'h0, 1, 0, 0);
      this.AfuAccessCtrl = uvm_reg_field::type_id::create("AfuAccessCtrl",,get_full_name());
      this.AfuAccessCtrl.configure(this, 1, 55, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved35 = uvm_reg_field::type_id::create("Reserved35",,get_full_name());
      this.Reserved35.configure(this, 20, 35, "WO", 0, 20'h0, 1, 0, 0);
      this.BarID = uvm_reg_field::type_id::create("BarID",,get_full_name());
      this.BarID.configure(this, 3, 32, "RO", 0, 3'h0, 1, 0, 0);
      this.Reserved24 = uvm_reg_field::type_id::create("Reserved24",,get_full_name());
      this.Reserved24.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PortByteOffset = uvm_reg_field::type_id::create("PortByteOffset",,get_full_name());
      this.PortByteOffset.configure(this, 24, 0, "RO", 0, 24'h80000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_PORT1_OFFSET)

endclass : ral_reg_ac_fme_PORT1_OFFSET


class ral_reg_ac_fme_PORT2_OFFSET extends uvm_reg;
	rand uvm_reg_field Reserved61;
	uvm_reg_field PortImplemented;
	rand uvm_reg_field Reserved57;
	rand uvm_reg_field DecouplePortCSR;
	rand uvm_reg_field AfuAccessCtrl;
	rand uvm_reg_field Reserved35;
	uvm_reg_field BarID;
	rand uvm_reg_field Reserved24;
	uvm_reg_field PortByteOffset;

	function new(string name = "ac_fme_PORT2_OFFSET");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved61 = uvm_reg_field::type_id::create("Reserved61",,get_full_name());
      this.Reserved61.configure(this, 3, 61, "WO", 0, 3'h0, 1, 0, 0);
      this.PortImplemented = uvm_reg_field::type_id::create("PortImplemented",,get_full_name());
      this.PortImplemented.configure(this, 1, 60, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved57 = uvm_reg_field::type_id::create("Reserved57",,get_full_name());
      this.Reserved57.configure(this, 3, 57, "WO", 0, 3'h0, 1, 0, 0);
      this.DecouplePortCSR = uvm_reg_field::type_id::create("DecouplePortCSR",,get_full_name());
      this.DecouplePortCSR.configure(this, 1, 56, "RW", 0, 1'h0, 1, 0, 0);
      this.AfuAccessCtrl = uvm_reg_field::type_id::create("AfuAccessCtrl",,get_full_name());
      this.AfuAccessCtrl.configure(this, 1, 55, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved35 = uvm_reg_field::type_id::create("Reserved35",,get_full_name());
      this.Reserved35.configure(this, 20, 35, "WO", 0, 20'h0, 1, 0, 0);
      this.BarID = uvm_reg_field::type_id::create("BarID",,get_full_name());
      this.BarID.configure(this, 3, 32, "RO", 0, 3'h0, 1, 0, 0);
      this.Reserved24 = uvm_reg_field::type_id::create("Reserved24",,get_full_name());
      this.Reserved24.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PortByteOffset = uvm_reg_field::type_id::create("PortByteOffset",,get_full_name());
      this.PortByteOffset.configure(this, 24, 0, "RO", 0, 24'h100000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_PORT2_OFFSET)

endclass : ral_reg_ac_fme_PORT2_OFFSET


class ral_reg_ac_fme_PORT3_OFFSET extends uvm_reg;
	rand uvm_reg_field Reserved61;
	uvm_reg_field PortImplemented;
	rand uvm_reg_field Reserved57;
	rand uvm_reg_field DecouplePortCSR;
	rand uvm_reg_field AfuAccessCtrl;
	rand uvm_reg_field Reserved35;
	uvm_reg_field BarID;
	rand uvm_reg_field Reserved24;
	uvm_reg_field PortByteOffset;

	function new(string name = "ac_fme_PORT3_OFFSET");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved61 = uvm_reg_field::type_id::create("Reserved61",,get_full_name());
      this.Reserved61.configure(this, 3, 61, "WO", 0, 3'h0, 1, 0, 0);
      this.PortImplemented = uvm_reg_field::type_id::create("PortImplemented",,get_full_name());
      this.PortImplemented.configure(this, 1, 60, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved57 = uvm_reg_field::type_id::create("Reserved57",,get_full_name());
      this.Reserved57.configure(this, 3, 57, "WO", 0, 3'h0, 1, 0, 0);
      this.DecouplePortCSR = uvm_reg_field::type_id::create("DecouplePortCSR",,get_full_name());
      this.DecouplePortCSR.configure(this, 1, 56, "RW", 0, 1'h0, 1, 0, 0);
      this.AfuAccessCtrl = uvm_reg_field::type_id::create("AfuAccessCtrl",,get_full_name());
      this.AfuAccessCtrl.configure(this, 1, 55, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved35 = uvm_reg_field::type_id::create("Reserved35",,get_full_name());
      this.Reserved35.configure(this, 20, 35, "WO", 0, 20'h0, 1, 0, 0);
      this.BarID = uvm_reg_field::type_id::create("BarID",,get_full_name());
      this.BarID.configure(this, 3, 32, "RO", 0, 3'h0, 1, 0, 0);
      this.Reserved24 = uvm_reg_field::type_id::create("Reserved24",,get_full_name());
      this.Reserved24.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PortByteOffset = uvm_reg_field::type_id::create("PortByteOffset",,get_full_name());
      this.PortByteOffset.configure(this, 24, 0, "RO", 0, 24'h180000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_PORT3_OFFSET)

endclass : ral_reg_ac_fme_PORT3_OFFSET


class ral_reg_ac_fme_FAB_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved9;
	uvm_reg_field Pcie0LinkStatus;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_fme_FAB_STATUS");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved9 = uvm_reg_field::type_id::create("Reserved9",,get_full_name());
      this.Reserved9.configure(this, 55, 9, "WO", 0, 55'h000000000, 1, 0, 0);
      this.Pcie0LinkStatus = uvm_reg_field::type_id::create("Pcie0LinkStatus",,get_full_name());
      this.Pcie0LinkStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 8, 0, "WO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FAB_STATUS)

endclass : ral_reg_ac_fme_FAB_STATUS


class ral_reg_ac_fme_BITSTREAM_ID extends uvm_reg;
	uvm_reg_field VerMajor;
	uvm_reg_field VerMinor;
	uvm_reg_field VerPatch;
	uvm_reg_field VerDebug;
	rand uvm_reg_field Reserved36;
	uvm_reg_field HssiID;
	uvm_reg_field GitHash;

	function new(string name = "ac_fme_BITSTREAM_ID");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.VerMajor = uvm_reg_field::type_id::create("VerMajor",,get_full_name());
      this.VerMajor.configure(this, 4, 60, "RO", 0, 4'h0, 1, 0, 0);
      this.VerMinor = uvm_reg_field::type_id::create("VerMinor",,get_full_name());
      this.VerMinor.configure(this, 4, 56, "RO", 0, 4'h1, 1, 0, 0);
      this.VerPatch = uvm_reg_field::type_id::create("VerPatch",,get_full_name());
      this.VerPatch.configure(this, 4, 52, "RO", 0, 4'h2, 1, 0, 0);
      this.VerDebug = uvm_reg_field::type_id::create("VerDebug",,get_full_name());
      this.VerDebug.configure(this, 4, 48, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved36 = uvm_reg_field::type_id::create("Reserved36",,get_full_name());
      this.Reserved36.configure(this, 12, 36, "WO", 0, 12'h0, 1, 0, 0);
      this.HssiID = uvm_reg_field::type_id::create("HssiID",,get_full_name());
      this.HssiID.configure(this, 4, 32, "RO", 0, 4'h7, 1, 0, 0);
      this.GitHash = uvm_reg_field::type_id::create("GitHash",,get_full_name());
      this.GitHash.configure(this, 32, 0, "RO", 0, 32'h89abcdef, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_BITSTREAM_ID)

endclass : ral_reg_ac_fme_BITSTREAM_ID


class ral_reg_ac_fme_BITSTREAM_MD extends uvm_reg;
	rand uvm_reg_field Reserved28;
	uvm_reg_field SynthYear;
	uvm_reg_field SynthMonth;
	uvm_reg_field SynthDay;
	uvm_reg_field SynthSeed;

	function new(string name = "ac_fme_BITSTREAM_MD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved28 = uvm_reg_field::type_id::create("Reserved28",,get_full_name());
      this.Reserved28.configure(this, 36, 28, "WO", 0, 36'h000000000, 1, 0, 0);
      this.SynthYear = uvm_reg_field::type_id::create("SynthYear",,get_full_name());
      this.SynthYear.configure(this, 8, 20, "RO", 0, 8'haa, 1, 0, 0);
      this.SynthMonth = uvm_reg_field::type_id::create("SynthMonth",,get_full_name());
      this.SynthMonth.configure(this, 8, 12, "RO", 0, 8'haa, 1, 0, 0);
      this.SynthDay = uvm_reg_field::type_id::create("SynthDay",,get_full_name());
      this.SynthDay.configure(this, 8, 4, "RO", 0, 8'haa, 1, 0, 0);
      this.SynthSeed = uvm_reg_field::type_id::create("SynthSeed",,get_full_name());
      this.SynthSeed.configure(this, 4, 0, "RO", 0, 4'ha, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_BITSTREAM_MD)

endclass : ral_reg_ac_fme_BITSTREAM_MD


class ral_reg_ac_fme_THERM_MNGM_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved40;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	function new(string name = "ac_fme_THERM_MNGM_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved40 = uvm_reg_field::type_id::create("Reserved40",,get_full_name());
      this.Reserved40.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h2000, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_THERM_MNGM_DFH)

endclass : ral_reg_ac_fme_THERM_MNGM_DFH


class ral_reg_ac_fme_TMP_THRESHOLD extends uvm_reg;
	rand uvm_reg_field Reserved45;
	rand uvm_reg_field ThresholdPolicy;
	rand uvm_reg_field Reserved42;
	rand uvm_reg_field ValModeTherm;
	rand uvm_reg_field Reserved36;
	uvm_reg_field ThermTripStatus;
	rand uvm_reg_field Reserved34;
	uvm_reg_field Threshold2Status;
	uvm_reg_field Threshold1Status;
	rand uvm_reg_field Reserved31;
	rand uvm_reg_field ThermTripThreshold;
	rand uvm_reg_field Reserved16;
	rand uvm_reg_field TempThreshold2Enab;
	rand uvm_reg_field TempThreshold2;
	rand uvm_reg_field TempThreshold1Enab;
	rand uvm_reg_field TempThreshold1;

	function new(string name = "ac_fme_TMP_THRESHOLD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved45 = uvm_reg_field::type_id::create("Reserved45",,get_full_name());
      this.Reserved45.configure(this, 19, 45, "WO", 0, 19'h0, 1, 0, 0);
      this.ThresholdPolicy = uvm_reg_field::type_id::create("ThresholdPolicy",,get_full_name());
      this.ThresholdPolicy.configure(this, 1, 44, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved42 = uvm_reg_field::type_id::create("Reserved42",,get_full_name());
      this.Reserved42.configure(this, 2, 42, "WO", 0, 2'h0, 1, 0, 0);
      this.ValModeTherm = uvm_reg_field::type_id::create("ValModeTherm",,get_full_name());
      this.ValModeTherm.configure(this, 1, 41, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved36 = uvm_reg_field::type_id::create("Reserved36",,get_full_name());
      this.Reserved36.configure(this, 5, 36, "WO", 0, 5'h0, 1, 0, 0);
      this.ThermTripStatus = uvm_reg_field::type_id::create("ThermTripStatus",,get_full_name());
      this.ThermTripStatus.configure(this, 1, 35, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved34 = uvm_reg_field::type_id::create("Reserved34",,get_full_name());
      this.Reserved34.configure(this, 1, 34, "WO", 0, 1'h0, 1, 0, 0);
      this.Threshold2Status = uvm_reg_field::type_id::create("Threshold2Status",,get_full_name());
      this.Threshold2Status.configure(this, 1, 33, "RO", 0, 1'h0, 1, 0, 0);
      this.Threshold1Status = uvm_reg_field::type_id::create("Threshold1Status",,get_full_name());
      this.Threshold1Status.configure(this, 1, 32, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved31 = uvm_reg_field::type_id::create("Reserved31",,get_full_name());
      this.Reserved31.configure(this, 1, 31, "WO", 0, 1'h0, 1, 0, 0);
      this.ThermTripThreshold = uvm_reg_field::type_id::create("ThermTripThreshold",,get_full_name());
      this.ThermTripThreshold.configure(this, 7, 24, "RW", 0, 7'h5d, 1, 0, 0);
      this.Reserved16 = uvm_reg_field::type_id::create("Reserved16",,get_full_name());
      this.Reserved16.configure(this, 8, 16, "WO", 0, 8'h0, 1, 0, 1);
      this.TempThreshold2Enab = uvm_reg_field::type_id::create("TempThreshold2Enab",,get_full_name());
      this.TempThreshold2Enab.configure(this, 1, 15, "RW", 0, 1'h0, 1, 0, 0);
      this.TempThreshold2 = uvm_reg_field::type_id::create("TempThreshold2",,get_full_name());
      this.TempThreshold2.configure(this, 7, 8, "RW", 0, 7'h5f, 1, 0, 0);
      this.TempThreshold1Enab = uvm_reg_field::type_id::create("TempThreshold1Enab",,get_full_name());
      this.TempThreshold1Enab.configure(this, 1, 7, "RW", 0, 1'h0, 1, 0, 0);
      this.TempThreshold1 = uvm_reg_field::type_id::create("TempThreshold1",,get_full_name());
      this.TempThreshold1.configure(this, 7, 0, "RW", 0, 7'h5a, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_TMP_THRESHOLD)

endclass : ral_reg_ac_fme_TMP_THRESHOLD


class ral_reg_ac_fme_TMP_RDSENSOR_FMT1 extends uvm_reg;
	rand uvm_reg_field Reserved42;
	uvm_reg_field TempThermalSensor;
	rand uvm_reg_field Reserved25;
	uvm_reg_field TempValid;
	uvm_reg_field NumbTempReads;
	rand uvm_reg_field Reserved7;
	uvm_reg_field FpgaTemp;

	function new(string name = "ac_fme_TMP_RDSENSOR_FMT1");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved42 = uvm_reg_field::type_id::create("Reserved42",,get_full_name());
      this.Reserved42.configure(this, 22, 42, "WO", 0, 22'h0, 1, 0, 0);
      this.TempThermalSensor = uvm_reg_field::type_id::create("TempThermalSensor",,get_full_name());
      this.TempThermalSensor.configure(this, 10, 32, "RO", 0, 10'h0, 1, 0, 0);
      this.Reserved25 = uvm_reg_field::type_id::create("Reserved25",,get_full_name());
      this.Reserved25.configure(this, 7, 25, "WO", 0, 7'h0, 1, 0, 0);
      this.TempValid = uvm_reg_field::type_id::create("TempValid",,get_full_name());
      this.TempValid.configure(this, 1, 24, "RO", 0, 1'h0, 1, 0, 0);
      this.NumbTempReads = uvm_reg_field::type_id::create("NumbTempReads",,get_full_name());
      this.NumbTempReads.configure(this, 16, 8, "RO", 0, 16'h0, 1, 0, 1);
      this.Reserved7 = uvm_reg_field::type_id::create("Reserved7",,get_full_name());
      this.Reserved7.configure(this, 1, 7, "WO", 0, 1'h0, 1, 0, 0);
      this.FpgaTemp = uvm_reg_field::type_id::create("FpgaTemp",,get_full_name());
      this.FpgaTemp.configure(this, 7, 0, "RO", 0, 7'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_TMP_RDSENSOR_FMT1)

endclass : ral_reg_ac_fme_TMP_RDSENSOR_FMT1


class ral_reg_ac_fme_TMP_RDSENSOR_FMT2 extends uvm_reg;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_fme_TMP_RDSENSOR_FMT2");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 64, 0, "WO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_TMP_RDSENSOR_FMT2)

endclass : ral_reg_ac_fme_TMP_RDSENSOR_FMT2


class ral_reg_ac_fme_TMP_THRESHOLD_CAPABILITY extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field DisablTmpThrReport;

	function new(string name = "ac_fme_TMP_THRESHOLD_CAPABILITY");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 63, 1, "WO", 0, 63'h000000000, 1, 0, 0);
      this.DisablTmpThrReport = uvm_reg_field::type_id::create("DisablTmpThrReport",,get_full_name());
      this.DisablTmpThrReport.configure(this, 1, 0, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_TMP_THRESHOLD_CAPABILITY)

endclass : ral_reg_ac_fme_TMP_THRESHOLD_CAPABILITY


class ral_reg_ac_fme_GLBL_PERF_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	function new(string name = "ac_fme_GLBL_PERF_DFH");
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
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h7, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_GLBL_PERF_DFH)

endclass : ral_reg_ac_fme_GLBL_PERF_DFH


class ral_reg_ac_fme_DUMMY_3008 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_3008");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_3008)

endclass : ral_reg_ac_fme_DUMMY_3008


class ral_reg_ac_fme_DUMMY_3010 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_3010");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_3010)

endclass : ral_reg_ac_fme_DUMMY_3010


class ral_reg_ac_fme_DUMMY_3018 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_3018");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_3018)

endclass : ral_reg_ac_fme_DUMMY_3018


class ral_reg_ac_fme_FPMON_FAB_CTL extends uvm_reg;
	rand uvm_reg_field Reserved24;
	rand uvm_reg_field PortFilter;
	rand uvm_reg_field Reserved22;
	rand uvm_reg_field PortId;
	rand uvm_reg_field FabricEventCode;
	rand uvm_reg_field Reserved9;
	rand uvm_reg_field FreezeCounters;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_fme_FPMON_FAB_CTL");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved24 = uvm_reg_field::type_id::create("Reserved24",,get_full_name());
      this.Reserved24.configure(this, 40, 24, "WO", 0, 40'h000000000, 1, 0, 1);
      this.PortFilter = uvm_reg_field::type_id::create("PortFilter",,get_full_name());
      this.PortFilter.configure(this, 1, 23, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved22 = uvm_reg_field::type_id::create("Reserved22",,get_full_name());
      this.Reserved22.configure(this, 1, 22, "WO", 0, 1'h0, 1, 0, 0);
      this.PortId = uvm_reg_field::type_id::create("PortId",,get_full_name());
      this.PortId.configure(this, 2, 20, "RW", 0, 2'h0, 1, 0, 0);
      this.FabricEventCode = uvm_reg_field::type_id::create("FabricEventCode",,get_full_name());
      this.FabricEventCode.configure(this, 4, 16, "RW", 0, 4'h0, 1, 0, 0);
      this.Reserved9 = uvm_reg_field::type_id::create("Reserved9",,get_full_name());
      this.Reserved9.configure(this, 7, 9, "WO", 0, 7'h0, 1, 0, 0);
      this.FreezeCounters = uvm_reg_field::type_id::create("FreezeCounters",,get_full_name());
      this.FreezeCounters.configure(this, 1, 8, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 8, 0, "WO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FPMON_FAB_CTL)

endclass : ral_reg_ac_fme_FPMON_FAB_CTL


class ral_reg_ac_fme_FPMON_FAB_CTR extends uvm_reg;
	uvm_reg_field FabricEventCode;
	uvm_reg_field FabricEventCounter;

	function new(string name = "ac_fme_FPMON_FAB_CTR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FabricEventCode = uvm_reg_field::type_id::create("FabricEventCode",,get_full_name());
      this.FabricEventCode.configure(this, 4, 60, "RO", 0, 4'h0, 1, 0, 0);
      this.FabricEventCounter = uvm_reg_field::type_id::create("FabricEventCounter",,get_full_name());
      this.FabricEventCounter.configure(this, 60, 0, "RO", 0, 60'h000000000, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FPMON_FAB_CTR)

endclass : ral_reg_ac_fme_FPMON_FAB_CTR


class ral_reg_ac_fme_FPMON_CLK_CTR extends uvm_reg;
	uvm_reg_field ClockCounter;

	function new(string name = "ac_fme_FPMON_CLK_CTR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ClockCounter = uvm_reg_field::type_id::create("ClockCounter",,get_full_name());
      this.ClockCounter.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FPMON_CLK_CTR)

endclass : ral_reg_ac_fme_FPMON_CLK_CTR


class ral_reg_ac_fme_GLBL_ERROR_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRevision;
	uvm_reg_field FeatureId;

	function new(string name = "ac_fme_GLBL_ERROR_DFH");
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
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'hc000, 1, 0, 1);
      this.FeatureRevision = uvm_reg_field::type_id::create("FeatureRevision",,get_full_name());
      this.FeatureRevision.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureId = uvm_reg_field::type_id::create("FeatureId",,get_full_name());
      this.FeatureId.configure(this, 12, 0, "RO", 0, 12'h4, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_GLBL_ERROR_DFH)

endclass : ral_reg_ac_fme_GLBL_ERROR_DFH


class ral_reg_ac_fme_FME_ERROR0_MASK extends uvm_reg;
	rand uvm_reg_field Reserved6;
	rand uvm_reg_field ErrorMask5;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field ErrorMask0;

	function new(string name = "ac_fme_FME_ERROR0_MASK");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved6 = uvm_reg_field::type_id::create("Reserved6",,get_full_name());
      this.Reserved6.configure(this, 58, 6, "WO", 0, 58'h000000000, 1, 0, 0);
      this.ErrorMask5 = uvm_reg_field::type_id::create("ErrorMask5",,get_full_name());
      this.ErrorMask5.configure(this, 1, 5, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved2 = uvm_reg_field::type_id::create("Reserved2",,get_full_name());
      this.Reserved2.configure(this, 3, 2, "WO", 0, 3'h0, 1, 0, 0);
      this.ErrorMask0 = uvm_reg_field::type_id::create("ErrorMask0",,get_full_name());
      this.ErrorMask0.configure(this, 2, 0, "RW", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_ERROR0_MASK)

endclass : ral_reg_ac_fme_FME_ERROR0_MASK


class ral_reg_ac_fme_FME_ERROR0 extends uvm_reg;
	rand uvm_reg_field Reserved6;
	rand uvm_reg_field AfuAccessModeErr;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field RemoteSTPParityErr;
	rand uvm_reg_field PartialReconfigFIFOParityErr;

	function new(string name = "ac_fme_FME_ERROR0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved6 = uvm_reg_field::type_id::create("Reserved6",,get_full_name());
      this.Reserved6.configure(this, 58, 6, "WO", 0, 58'h000000000, 1, 0, 0);
      this.AfuAccessModeErr = uvm_reg_field::type_id::create("AfuAccessModeErr",,get_full_name());
      this.AfuAccessModeErr.configure(this, 1, 5, "W1C", 0, 1'h0, 1, 0, 0);
      this.Reserved2 = uvm_reg_field::type_id::create("Reserved2",,get_full_name());
      this.Reserved2.configure(this, 3, 2, "WO", 0, 3'h0, 1, 0, 0);
      this.RemoteSTPParityErr = uvm_reg_field::type_id::create("RemoteSTPParityErr",,get_full_name());
      this.RemoteSTPParityErr.configure(this, 1, 1, "W1C", 0, 1'h0, 1, 0, 0);
      this.PartialReconfigFIFOParityErr = uvm_reg_field::type_id::create("PartialReconfigFIFOParityErr",,get_full_name());
      this.PartialReconfigFIFOParityErr.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_ERROR0)

endclass : ral_reg_ac_fme_FME_ERROR0


class ral_reg_ac_fme_PCIE0_ERROR_MASK extends uvm_reg;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field ErrorMask;

	function new(string name = "ac_fme_PCIE0_ERROR_MASK");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 51, 13, "WO", 0, 51'h000000000, 1, 0, 0);
      this.ErrorMask = uvm_reg_field::type_id::create("ErrorMask",,get_full_name());
      this.ErrorMask.configure(this, 13, 0, "RW", 0, 13'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_PCIE0_ERROR_MASK)

endclass : ral_reg_ac_fme_PCIE0_ERROR_MASK


class ral_reg_ac_fme_PCIE0_ERROR extends uvm_reg;
	rand uvm_reg_field FunctTypeErr;
	rand uvm_reg_field VFNumb;
	rand uvm_reg_field Reserved13;
	rand uvm_reg_field FifoOverflowErr;
	rand uvm_reg_field MalformedEopErr;
	rand uvm_reg_field MalformedSopErr;
	rand uvm_reg_field RxPoisonTlpErr;
	rand uvm_reg_field ParityErr;
	rand uvm_reg_field CompTimeOutErr;
	rand uvm_reg_field CompStatErr;
	rand uvm_reg_field CompTagErr;
	rand uvm_reg_field MRLengthErr;
	rand uvm_reg_field MRAddrErr;
	rand uvm_reg_field MWLengthErr;
	rand uvm_reg_field MWAddrErr;
	rand uvm_reg_field FormatTypeErr;

	function new(string name = "ac_fme_PCIE0_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FunctTypeErr = uvm_reg_field::type_id::create("FunctTypeErr",,get_full_name());
      this.FunctTypeErr.configure(this, 1, 63, "W1C", 0, 1'h0, 1, 0, 0);
      this.VFNumb = uvm_reg_field::type_id::create("VFNumb",,get_full_name());
      this.VFNumb.configure(this, 1, 62, "W1C", 0, 1'h0, 1, 0, 0);
      this.Reserved13 = uvm_reg_field::type_id::create("Reserved13",,get_full_name());
      this.Reserved13.configure(this, 49, 13, "WO", 0, 49'h000000000, 1, 0, 0);
      this.FifoOverflowErr = uvm_reg_field::type_id::create("FifoOverflowErr",,get_full_name());
      this.FifoOverflowErr.configure(this, 1, 12, "W1C", 0, 1'h0, 1, 0, 0);
      this.MalformedEopErr = uvm_reg_field::type_id::create("MalformedEopErr",,get_full_name());
      this.MalformedEopErr.configure(this, 1, 11, "W1C", 0, 1'h0, 1, 0, 0);
      this.MalformedSopErr = uvm_reg_field::type_id::create("MalformedSopErr",,get_full_name());
      this.MalformedSopErr.configure(this, 1, 10, "W1C", 0, 1'h0, 1, 0, 0);
      this.RxPoisonTlpErr = uvm_reg_field::type_id::create("RxPoisonTlpErr",,get_full_name());
      this.RxPoisonTlpErr.configure(this, 1, 9, "W1C", 0, 1'h0, 1, 0, 0);
      this.ParityErr = uvm_reg_field::type_id::create("ParityErr",,get_full_name());
      this.ParityErr.configure(this, 1, 8, "W1C", 0, 1'h0, 1, 0, 0);
      this.CompTimeOutErr = uvm_reg_field::type_id::create("CompTimeOutErr",,get_full_name());
      this.CompTimeOutErr.configure(this, 1, 7, "W1C", 0, 1'h0, 1, 0, 0);
      this.CompStatErr = uvm_reg_field::type_id::create("CompStatErr",,get_full_name());
      this.CompStatErr.configure(this, 1, 6, "W1C", 0, 1'h0, 1, 0, 0);
      this.CompTagErr = uvm_reg_field::type_id::create("CompTagErr",,get_full_name());
      this.CompTagErr.configure(this, 1, 5, "W1C", 0, 1'h0, 1, 0, 0);
      this.MRLengthErr = uvm_reg_field::type_id::create("MRLengthErr",,get_full_name());
      this.MRLengthErr.configure(this, 1, 4, "W1C", 0, 1'h0, 1, 0, 0);
      this.MRAddrErr = uvm_reg_field::type_id::create("MRAddrErr",,get_full_name());
      this.MRAddrErr.configure(this, 1, 3, "W1C", 0, 1'h0, 1, 0, 0);
      this.MWLengthErr = uvm_reg_field::type_id::create("MWLengthErr",,get_full_name());
      this.MWLengthErr.configure(this, 1, 2, "W1C", 0, 1'h0, 1, 0, 0);
      this.MWAddrErr = uvm_reg_field::type_id::create("MWAddrErr",,get_full_name());
      this.MWAddrErr.configure(this, 1, 1, "W1C", 0, 1'h0, 1, 0, 0);
      this.FormatTypeErr = uvm_reg_field::type_id::create("FormatTypeErr",,get_full_name());
      this.FormatTypeErr.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_PCIE0_ERROR)

endclass : ral_reg_ac_fme_PCIE0_ERROR


class ral_reg_ac_fme_DUMMY_4028 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_4028");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_4028)

endclass : ral_reg_ac_fme_DUMMY_4028


class ral_reg_ac_fme_DUMMY_4030 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_4030");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_4030)

endclass : ral_reg_ac_fme_DUMMY_4030


class ral_reg_ac_fme_FME_FIRST_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field ErrorRegID;
	uvm_reg_field ErrorRegStatus;

	function new(string name = "ac_fme_FME_FIRST_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 2, 62, "WO", 0, 2'h0, 1, 0, 0);
      this.ErrorRegID = uvm_reg_field::type_id::create("ErrorRegID",,get_full_name());
      this.ErrorRegID.configure(this, 2, 60, "RO", 0, 2'h0, 1, 0, 0);
      this.ErrorRegStatus = uvm_reg_field::type_id::create("ErrorRegStatus",,get_full_name());
      this.ErrorRegStatus.configure(this, 60, 0, "RO", 0, 60'h000000000, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_FIRST_ERROR)

endclass : ral_reg_ac_fme_FME_FIRST_ERROR


class ral_reg_ac_fme_FME_NEXT_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field ErrorRegID;
	uvm_reg_field ErrorRegStatus;

	function new(string name = "ac_fme_FME_NEXT_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 2, 62, "WO", 0, 2'h0, 1, 0, 0);
      this.ErrorRegID = uvm_reg_field::type_id::create("ErrorRegID",,get_full_name());
      this.ErrorRegID.configure(this, 2, 60, "RO", 0, 2'h0, 1, 0, 0);
      this.ErrorRegStatus = uvm_reg_field::type_id::create("ErrorRegStatus",,get_full_name());
      this.ErrorRegStatus.configure(this, 60, 0, "RO", 0, 60'h000000000, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_NEXT_ERROR)

endclass : ral_reg_ac_fme_FME_NEXT_ERROR


class ral_reg_ac_fme_RAS_NOFAT_ERROR_MASK extends uvm_reg;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field ErrorMask5;
	rand uvm_reg_field Reserved4;
	rand uvm_reg_field ErrorMask2;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_fme_RAS_NOFAT_ERROR_MASK");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 57, 7, "WO", 0, 57'h000000000, 1, 0, 0);
      this.ErrorMask5 = uvm_reg_field::type_id::create("ErrorMask5",,get_full_name());
      this.ErrorMask5.configure(this, 2, 5, "RW", 0, 2'h0, 1, 0, 0);
      this.Reserved4 = uvm_reg_field::type_id::create("Reserved4",,get_full_name());
      this.Reserved4.configure(this, 1, 4, "WO", 0, 1'h0, 1, 0, 0);
      this.ErrorMask2 = uvm_reg_field::type_id::create("ErrorMask2",,get_full_name());
      this.ErrorMask2.configure(this, 2, 2, "RW", 0, 2'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 2, 0, "WO", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_RAS_NOFAT_ERROR_MASK)

endclass : ral_reg_ac_fme_RAS_NOFAT_ERROR_MASK


class ral_reg_ac_fme_RAS_NOFAT_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved7;
	rand uvm_reg_field InjectedWarningErr;
	rand uvm_reg_field AfuAccessModeErr;
	rand uvm_reg_field Reserved4;
	rand uvm_reg_field PortFatalErr;
	uvm_reg_field PcieError;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_fme_RAS_NOFAT_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved7 = uvm_reg_field::type_id::create("Reserved7",,get_full_name());
      this.Reserved7.configure(this, 57, 7, "WO", 0, 57'h000000000, 1, 0, 0);
      this.InjectedWarningErr = uvm_reg_field::type_id::create("InjectedWarningErr",,get_full_name());
      this.InjectedWarningErr.configure(this, 1, 6, "W1C", 0, 1'h0, 1, 0, 0);
      this.AfuAccessModeErr = uvm_reg_field::type_id::create("AfuAccessModeErr",,get_full_name());
      this.AfuAccessModeErr.configure(this, 1, 5, "W1C", 0, 1'h0, 1, 0, 0);
      this.Reserved4 = uvm_reg_field::type_id::create("Reserved4",,get_full_name());
      this.Reserved4.configure(this, 1, 4, "WO", 0, 1'h0, 1, 0, 0);
      this.PortFatalErr = uvm_reg_field::type_id::create("PortFatalErr",,get_full_name());
      this.PortFatalErr.configure(this, 1, 3, "W1C", 0, 1'h0, 1, 0, 0);
      this.PcieError = uvm_reg_field::type_id::create("PcieError",,get_full_name());
      this.PcieError.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 2, 0, "WO", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_RAS_NOFAT_ERROR)

endclass : ral_reg_ac_fme_RAS_NOFAT_ERROR


class ral_reg_ac_fme_RAS_CATFAT_ERR_MASK extends uvm_reg;
	rand uvm_reg_field Reserved12;
	rand uvm_reg_field ErrorMask11;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field ErrorMask6;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_fme_RAS_CATFAT_ERR_MASK");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved12 = uvm_reg_field::type_id::create("Reserved12",,get_full_name());
      this.Reserved12.configure(this, 52, 12, "WO", 0, 52'h000000000, 1, 0, 0);
      this.ErrorMask11 = uvm_reg_field::type_id::create("ErrorMask11",,get_full_name());
      this.ErrorMask11.configure(this, 1, 11, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 1, 10, "WO", 0, 1'h0, 1, 0, 0);
      this.ErrorMask6 = uvm_reg_field::type_id::create("ErrorMask6",,get_full_name());
      this.ErrorMask6.configure(this, 4, 6, "RW", 0, 4'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 6, 0, "WO", 0, 6'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_RAS_CATFAT_ERR_MASK)

endclass : ral_reg_ac_fme_RAS_CATFAT_ERR_MASK


class ral_reg_ac_fme_RAS_CATFAT_ERR extends uvm_reg;
	rand uvm_reg_field Reserved12;
	uvm_reg_field InjectedCatastErr;
	rand uvm_reg_field Reserved10;
	uvm_reg_field CrcCatastErr;
	uvm_reg_field InjectedFatalErr;
	uvm_reg_field PciePoisonErr;
	uvm_reg_field FabricFatalErr;
	rand uvm_reg_field Reserved0;

	function new(string name = "ac_fme_RAS_CATFAT_ERR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved12 = uvm_reg_field::type_id::create("Reserved12",,get_full_name());
      this.Reserved12.configure(this, 52, 12, "WO", 0, 52'h000000000, 1, 0, 0);
      this.InjectedCatastErr = uvm_reg_field::type_id::create("InjectedCatastErr",,get_full_name());
      this.InjectedCatastErr.configure(this, 1, 11, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 1, 10, "WO", 0, 1'h0, 1, 0, 0);
      this.CrcCatastErr = uvm_reg_field::type_id::create("CrcCatastErr",,get_full_name());
      this.CrcCatastErr.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.InjectedFatalErr = uvm_reg_field::type_id::create("InjectedFatalErr",,get_full_name());
      this.InjectedFatalErr.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.PciePoisonErr = uvm_reg_field::type_id::create("PciePoisonErr",,get_full_name());
      this.PciePoisonErr.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.FabricFatalErr = uvm_reg_field::type_id::create("FabricFatalErr",,get_full_name());
      this.FabricFatalErr.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 6, 0, "WO", 0, 6'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_RAS_CATFAT_ERR)

endclass : ral_reg_ac_fme_RAS_CATFAT_ERR


class ral_reg_ac_fme_RAS_ERROR_INJ extends uvm_reg;
	rand uvm_reg_field Reserved0;
	rand uvm_reg_field NoFatalError;
	rand uvm_reg_field FatalError;
	rand uvm_reg_field CatastError;

	function new(string name = "ac_fme_RAS_ERROR_INJ");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 61, 3, "WO", 0, 61'h000000000, 1, 0, 0);
      this.NoFatalError = uvm_reg_field::type_id::create("NoFatalError",,get_full_name());
      this.NoFatalError.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
      this.FatalError = uvm_reg_field::type_id::create("FatalError",,get_full_name());
      this.FatalError.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.CatastError = uvm_reg_field::type_id::create("CatastError",,get_full_name());
      this.CatastError.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_RAS_ERROR_INJ)

endclass : ral_reg_ac_fme_RAS_ERROR_INJ


class ral_reg_ac_fme_GLBL_ERROR_CAPABILITY extends uvm_reg;
	rand uvm_reg_field Reserved13;
	uvm_reg_field InterruptVectorNumber;
	uvm_reg_field SupportsInterrupt;

	function new(string name = "ac_fme_GLBL_ERROR_CAPABILITY");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved13 = uvm_reg_field::type_id::create("Reserved13",,get_full_name());
      this.Reserved13.configure(this, 51, 13, "WO", 0, 51'h000000000, 1, 0, 0);
      this.InterruptVectorNumber = uvm_reg_field::type_id::create("InterruptVectorNumber",,get_full_name());
      this.InterruptVectorNumber.configure(this, 12, 1, "RO", 0, 12'h6, 1, 0, 0);
      this.SupportsInterrupt = uvm_reg_field::type_id::create("SupportsInterrupt",,get_full_name());
      this.SupportsInterrupt.configure(this, 1, 0, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_GLBL_ERROR_CAPABILITY)

endclass : ral_reg_ac_fme_GLBL_ERROR_CAPABILITY


class ral_reg_ac_fme_FME_PR_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRevision;
	uvm_reg_field FeatureId;

	function new(string name = "ac_fme_FME_PR_DFH");
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
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'hb000, 1, 0, 1);
      this.FeatureRevision = uvm_reg_field::type_id::create("FeatureRevision",,get_full_name());
      this.FeatureRevision.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureId = uvm_reg_field::type_id::create("FeatureId",,get_full_name());
      this.FeatureId.configure(this, 12, 0, "RO", 0, 12'h5, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_PR_DFH)

endclass : ral_reg_ac_fme_FME_PR_DFH


class ral_reg_ac_fme_FME_PR_CTRL extends uvm_reg;
	rand uvm_reg_field TBD;
	rand uvm_reg_field Reserved15;
	rand uvm_reg_field PRKind;
	rand uvm_reg_field PRDataPushComplete;
	rand uvm_reg_field PRStartRequest;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field PRRegionId;
	rand uvm_reg_field Reserved5;
	uvm_reg_field PRResetAck;
	rand uvm_reg_field Reserved1;
	rand uvm_reg_field PRReset;

	function new(string name = "ac_fme_FME_PR_CTRL");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.TBD = uvm_reg_field::type_id::create("TBD",,get_full_name());
      this.TBD.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.Reserved15 = uvm_reg_field::type_id::create("Reserved15",,get_full_name());
      this.Reserved15.configure(this, 17, 15, "WO", 0, 17'h0, 1, 0, 0);
      this.PRKind = uvm_reg_field::type_id::create("PRKind",,get_full_name());
      this.PRKind.configure(this, 1, 14, "RW", 0, 1'h0, 1, 0, 0);
      this.PRDataPushComplete = uvm_reg_field::type_id::create("PRDataPushComplete",,get_full_name());
      this.PRDataPushComplete.configure(this, 1, 13, "W1S", 0, 1'h0, 1, 0, 0);
      this.PRStartRequest = uvm_reg_field::type_id::create("PRStartRequest",,get_full_name());
      this.PRStartRequest.configure(this, 1, 12, "W1S", 0, 1'h0, 1, 0, 0);
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 2, 10, "WO", 0, 2'h0, 1, 0, 0);
      this.PRRegionId = uvm_reg_field::type_id::create("PRRegionId",,get_full_name());
      this.PRRegionId.configure(this, 2, 8, "RW", 0, 2'h0, 1, 0, 0);
      this.Reserved5 = uvm_reg_field::type_id::create("Reserved5",,get_full_name());
      this.Reserved5.configure(this, 3, 5, "WO", 0, 3'h0, 1, 0, 0);
      this.PRResetAck = uvm_reg_field::type_id::create("PRResetAck",,get_full_name());
      this.PRResetAck.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 3, 1, "WO", 0, 3'h0, 1, 0, 0);
      this.PRReset = uvm_reg_field::type_id::create("PRReset",,get_full_name());
      this.PRReset.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_PR_CTRL)

endclass : ral_reg_ac_fme_FME_PR_CTRL


class ral_reg_ac_fme_FME_PR_STATUS extends uvm_reg;
	uvm_reg_field SecurityBlockStatus;
	rand uvm_reg_field Reserved28;
	uvm_reg_field PRHostStatus;
	rand uvm_reg_field Reserved23;
	uvm_reg_field AlteraPRCrtlrStatus;
	rand uvm_reg_field Reserved17;
	uvm_reg_field PRStatus;
	rand uvm_reg_field Reserved9;
	uvm_reg_field NumbCredits;

	function new(string name = "ac_fme_FME_PR_STATUS");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.SecurityBlockStatus = uvm_reg_field::type_id::create("SecurityBlockStatus",,get_full_name());
      this.SecurityBlockStatus.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved28 = uvm_reg_field::type_id::create("Reserved28",,get_full_name());
      this.Reserved28.configure(this, 4, 28, "WO", 0, 4'h0, 1, 0, 0);
      this.PRHostStatus = uvm_reg_field::type_id::create("PRHostStatus",,get_full_name());
      this.PRHostStatus.configure(this, 4, 24, "RO", 0, 4'h0, 1, 0, 0);
      this.Reserved23 = uvm_reg_field::type_id::create("Reserved23",,get_full_name());
      this.Reserved23.configure(this, 1, 23, "WO", 0, 1'h0, 1, 0, 0);
      this.AlteraPRCrtlrStatus = uvm_reg_field::type_id::create("AlteraPRCrtlrStatus",,get_full_name());
      this.AlteraPRCrtlrStatus.configure(this, 3, 20, "RO", 0, 3'h0, 1, 0, 0);
      this.Reserved17 = uvm_reg_field::type_id::create("Reserved17",,get_full_name());
      this.Reserved17.configure(this, 3, 17, "WO", 0, 3'h0, 1, 0, 0);
      this.PRStatus = uvm_reg_field::type_id::create("PRStatus",,get_full_name());
      this.PRStatus.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved9 = uvm_reg_field::type_id::create("Reserved9",,get_full_name());
      this.Reserved9.configure(this, 7, 9, "WO", 0, 7'h0, 1, 0, 0);
      this.NumbCredits = uvm_reg_field::type_id::create("NumbCredits",,get_full_name());
      this.NumbCredits.configure(this, 9, 0, "RO", 0, 9'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_PR_STATUS)

endclass : ral_reg_ac_fme_FME_PR_STATUS


class ral_reg_ac_fme_FME_PR_DATA extends uvm_reg;
	rand uvm_reg_field PRData;

	function new(string name = "ac_fme_FME_PR_DATA");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PRData = uvm_reg_field::type_id::create("PRData",,get_full_name());
      this.PRData.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_PR_DATA)

endclass : ral_reg_ac_fme_FME_PR_DATA


class ral_reg_ac_fme_FME_PR_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved7;
	rand uvm_reg_field SecureLoadFailed;
	rand uvm_reg_field HostInitTimeout;
	rand uvm_reg_field HostInitFIFOOverflow;
	rand uvm_reg_field IPInitProtocolError;
	rand uvm_reg_field IPInitIncompatibleBitstream;
	rand uvm_reg_field IPInitCRCError;
	rand uvm_reg_field HostInitOperationError;

	function new(string name = "ac_fme_FME_PR_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved7 = uvm_reg_field::type_id::create("Reserved7",,get_full_name());
      this.Reserved7.configure(this, 57, 7, "WO", 0, 57'h000000000, 1, 0, 0);
      this.SecureLoadFailed = uvm_reg_field::type_id::create("SecureLoadFailed",,get_full_name());
      this.SecureLoadFailed.configure(this, 1, 6, "W1C", 0, 1'h0, 1, 0, 0);
      this.HostInitTimeout = uvm_reg_field::type_id::create("HostInitTimeout",,get_full_name());
      this.HostInitTimeout.configure(this, 1, 5, "W1C", 0, 1'h0, 1, 0, 0);
      this.HostInitFIFOOverflow = uvm_reg_field::type_id::create("HostInitFIFOOverflow",,get_full_name());
      this.HostInitFIFOOverflow.configure(this, 1, 4, "W1C", 0, 1'h0, 1, 0, 0);
      this.IPInitProtocolError = uvm_reg_field::type_id::create("IPInitProtocolError",,get_full_name());
      this.IPInitProtocolError.configure(this, 1, 3, "W1C", 0, 1'h0, 1, 0, 0);
      this.IPInitIncompatibleBitstream = uvm_reg_field::type_id::create("IPInitIncompatibleBitstream",,get_full_name());
      this.IPInitIncompatibleBitstream.configure(this, 1, 2, "W1C", 0, 1'h0, 1, 0, 0);
      this.IPInitCRCError = uvm_reg_field::type_id::create("IPInitCRCError",,get_full_name());
      this.IPInitCRCError.configure(this, 1, 1, "W1C", 0, 1'h0, 1, 0, 0);
      this.HostInitOperationError = uvm_reg_field::type_id::create("HostInitOperationError",,get_full_name());
      this.HostInitOperationError.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_PR_ERROR)

endclass : ral_reg_ac_fme_FME_PR_ERROR


class ral_reg_ac_fme_DUMMY_5028 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5028");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5028)

endclass : ral_reg_ac_fme_DUMMY_5028


class ral_reg_ac_fme_DUMMY_5030 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5030");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5030)

endclass : ral_reg_ac_fme_DUMMY_5030


class ral_reg_ac_fme_DUMMY_5038 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5038");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5038)

endclass : ral_reg_ac_fme_DUMMY_5038


class ral_reg_ac_fme_DUMMY_5040 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5040");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5040)

endclass : ral_reg_ac_fme_DUMMY_5040


class ral_reg_ac_fme_DUMMY_5048 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5048");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5048)

endclass : ral_reg_ac_fme_DUMMY_5048


class ral_reg_ac_fme_DUMMY_5050 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5050");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5050)

endclass : ral_reg_ac_fme_DUMMY_5050


class ral_reg_ac_fme_DUMMY_5058 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5058");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5058)

endclass : ral_reg_ac_fme_DUMMY_5058


class ral_reg_ac_fme_DUMMY_5060 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5060");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5060)

endclass : ral_reg_ac_fme_DUMMY_5060


class ral_reg_ac_fme_DUMMY_5068 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5068");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5068)

endclass : ral_reg_ac_fme_DUMMY_5068


class ral_reg_ac_fme_DUMMY_5070 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5070");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5070)

endclass : ral_reg_ac_fme_DUMMY_5070


class ral_reg_ac_fme_DUMMY_5078 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5078");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5078)

endclass : ral_reg_ac_fme_DUMMY_5078


class ral_reg_ac_fme_DUMMY_5080 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5080");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5080)

endclass : ral_reg_ac_fme_DUMMY_5080


class ral_reg_ac_fme_DUMMY_5088 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5088");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5088)

endclass : ral_reg_ac_fme_DUMMY_5088


class ral_reg_ac_fme_DUMMY_5090 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5090");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5090)

endclass : ral_reg_ac_fme_DUMMY_5090


class ral_reg_ac_fme_DUMMY_5098 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_5098");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_5098)

endclass : ral_reg_ac_fme_DUMMY_5098


class ral_reg_ac_fme_DUMMY_50A0 extends uvm_reg;
	uvm_reg_field Zero;

	function new(string name = "ac_fme_DUMMY_50A0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_DUMMY_50A0)

endclass : ral_reg_ac_fme_DUMMY_50A0


class ral_reg_ac_fme_FME_PR_INTFC_ID_L extends uvm_reg;
	uvm_reg_field InterfaceIdL;

	function new(string name = "ac_fme_FME_PR_INTFC_ID_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.InterfaceIdL = uvm_reg_field::type_id::create("InterfaceIdL",,get_full_name());
      this.InterfaceIdL.configure(this, 64, 0, "RO", 0, 64'h2222222222222222, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_PR_INTFC_ID_L)

endclass : ral_reg_ac_fme_FME_PR_INTFC_ID_L


class ral_reg_ac_fme_FME_PR_INTFC_ID_H extends uvm_reg;
	uvm_reg_field InterfaceIdH;

	function new(string name = "ac_fme_FME_PR_INTFC_ID_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.InterfaceIdH = uvm_reg_field::type_id::create("InterfaceIdH",,get_full_name());
      this.InterfaceIdH.configure(this, 64, 0, "RO", 0, 64'heeeeeeeeeeeeeeee, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_FME_PR_INTFC_ID_H)

endclass : ral_reg_ac_fme_FME_PR_INTFC_ID_H


class ral_reg_ac_fme_MSIX_ADDR0 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	function new(string name = "ac_fme_MSIX_ADDR0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_ADDR0)

endclass : ral_reg_ac_fme_MSIX_ADDR0


class ral_reg_ac_fme_MSIX_CTLDAT0 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	function new(string name = "ac_fme_MSIX_CTLDAT0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_CTLDAT0)

endclass : ral_reg_ac_fme_MSIX_CTLDAT0


class ral_reg_ac_fme_MSIX_ADDR1 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	function new(string name = "ac_fme_MSIX_ADDR1");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_ADDR1)

endclass : ral_reg_ac_fme_MSIX_ADDR1


class ral_reg_ac_fme_MSIX_CTLDAT1 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	function new(string name = "ac_fme_MSIX_CTLDAT1");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_CTLDAT1)

endclass : ral_reg_ac_fme_MSIX_CTLDAT1


class ral_reg_ac_fme_MSIX_ADDR2 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	function new(string name = "ac_fme_MSIX_ADDR2");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_ADDR2)

endclass : ral_reg_ac_fme_MSIX_ADDR2


class ral_reg_ac_fme_MSIX_CTLDAT2 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	function new(string name = "ac_fme_MSIX_CTLDAT2");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_CTLDAT2)

endclass : ral_reg_ac_fme_MSIX_CTLDAT2


class ral_reg_ac_fme_MSIX_ADDR3 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	function new(string name = "ac_fme_MSIX_ADDR3");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_ADDR3)

endclass : ral_reg_ac_fme_MSIX_ADDR3


class ral_reg_ac_fme_MSIX_CTLDAT3 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	function new(string name = "ac_fme_MSIX_CTLDAT3");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_CTLDAT3)

endclass : ral_reg_ac_fme_MSIX_CTLDAT3


class ral_reg_ac_fme_MSIX_ADDR4 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	function new(string name = "ac_fme_MSIX_ADDR4");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_ADDR4)

endclass : ral_reg_ac_fme_MSIX_ADDR4


class ral_reg_ac_fme_MSIX_CTLDAT4 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	function new(string name = "ac_fme_MSIX_CTLDAT4");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_CTLDAT4)

endclass : ral_reg_ac_fme_MSIX_CTLDAT4


class ral_reg_ac_fme_MSIX_ADDR5 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	function new(string name = "ac_fme_MSIX_ADDR5");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_ADDR5)

endclass : ral_reg_ac_fme_MSIX_ADDR5


class ral_reg_ac_fme_MSIX_CTLDAT5 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	function new(string name = "ac_fme_MSIX_CTLDAT5");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_CTLDAT5)

endclass : ral_reg_ac_fme_MSIX_CTLDAT5


class ral_reg_ac_fme_MSIX_ADDR6 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	function new(string name = "ac_fme_MSIX_ADDR6");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_ADDR6)

endclass : ral_reg_ac_fme_MSIX_ADDR6


class ral_reg_ac_fme_MSIX_CTLDAT6 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	function new(string name = "ac_fme_MSIX_CTLDAT6");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_CTLDAT6)

endclass : ral_reg_ac_fme_MSIX_CTLDAT6


class ral_reg_ac_fme_MSIX_ADDR7 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	function new(string name = "ac_fme_MSIX_ADDR7");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_ADDR7)

endclass : ral_reg_ac_fme_MSIX_ADDR7


class ral_reg_ac_fme_MSIX_CTLDAT7 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	function new(string name = "ac_fme_MSIX_CTLDAT7");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_CTLDAT7)

endclass : ral_reg_ac_fme_MSIX_CTLDAT7


class ral_reg_ac_fme_MSIX_PBA extends uvm_reg;
	rand uvm_reg_field Reserved7;
	uvm_reg_field MsixPba;

	function new(string name = "ac_fme_MSIX_PBA");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved7 = uvm_reg_field::type_id::create("Reserved7",,get_full_name());
      this.Reserved7.configure(this, 57, 7, "WO", 0, 57'h000000000, 1, 0, 0);
      this.MsixPba = uvm_reg_field::type_id::create("MsixPba",,get_full_name());
      this.MsixPba.configure(this, 7, 0, "RO", 0, 7'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_PBA)

endclass : ral_reg_ac_fme_MSIX_PBA


class ral_reg_ac_fme_MSIX_COUNT_CSR extends uvm_reg;
	rand uvm_reg_field Reserved32;
	uvm_reg_field Afu2SyncFifoMsixCount;
	uvm_reg_field SyncFifo2MsixCount;
	uvm_reg_field Msix2CdcMsixCount;
	uvm_reg_field Cdc2AvlMsixCount;

	function new(string name = "ac_fme_MSIX_COUNT_CSR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved32 = uvm_reg_field::type_id::create("Reserved32",,get_full_name());
      this.Reserved32.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.Afu2SyncFifoMsixCount = uvm_reg_field::type_id::create("Afu2SyncFifoMsixCount",,get_full_name());
      this.Afu2SyncFifoMsixCount.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
      this.SyncFifo2MsixCount = uvm_reg_field::type_id::create("SyncFifo2MsixCount",,get_full_name());
      this.SyncFifo2MsixCount.configure(this, 8, 16, "RO", 0, 8'h0, 1, 0, 1);
      this.Msix2CdcMsixCount = uvm_reg_field::type_id::create("Msix2CdcMsixCount",,get_full_name());
      this.Msix2CdcMsixCount.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Cdc2AvlMsixCount = uvm_reg_field::type_id::create("Cdc2AvlMsixCount",,get_full_name());
      this.Cdc2AvlMsixCount.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_fme_MSIX_COUNT_CSR)

endclass : ral_reg_ac_fme_MSIX_COUNT_CSR


class ral_block_ac_fme extends uvm_reg_block;
	rand ral_reg_ac_fme_FME_DFH FME_DFH;
	rand ral_reg_ac_fme_FME_AFU_ID_L FME_AFU_ID_L;
	rand ral_reg_ac_fme_FME_AFU_ID_H FME_AFU_ID_H;
	rand ral_reg_ac_fme_FME_NEXT_AFU FME_NEXT_AFU;
	rand ral_reg_ac_fme_DUMMY_0020 DUMMY_0020;
	rand ral_reg_ac_fme_FME_SCRATCHPAD0 FME_SCRATCHPAD0;
	rand ral_reg_ac_fme_FAB_CAPABILITY FAB_CAPABILITY;
	rand ral_reg_ac_fme_PORT0_OFFSET PORT0_OFFSET;
	rand ral_reg_ac_fme_PORT1_OFFSET PORT1_OFFSET;
	rand ral_reg_ac_fme_PORT2_OFFSET PORT2_OFFSET;
	rand ral_reg_ac_fme_PORT3_OFFSET PORT3_OFFSET;
	rand ral_reg_ac_fme_FAB_STATUS FAB_STATUS;
	rand ral_reg_ac_fme_BITSTREAM_ID BITSTREAM_ID;
	rand ral_reg_ac_fme_BITSTREAM_MD BITSTREAM_MD;
	rand ral_reg_ac_fme_THERM_MNGM_DFH THERM_MNGM_DFH;
	rand ral_reg_ac_fme_TMP_THRESHOLD TMP_THRESHOLD;
	rand ral_reg_ac_fme_TMP_RDSENSOR_FMT1 TMP_RDSENSOR_FMT1;
	rand ral_reg_ac_fme_TMP_RDSENSOR_FMT2 TMP_RDSENSOR_FMT2;
	rand ral_reg_ac_fme_TMP_THRESHOLD_CAPABILITY TMP_THRESHOLD_CAPABILITY;
	rand ral_reg_ac_fme_GLBL_PERF_DFH GLBL_PERF_DFH;
	rand ral_reg_ac_fme_DUMMY_3008 DUMMY_3008;
	rand ral_reg_ac_fme_DUMMY_3010 DUMMY_3010;
	rand ral_reg_ac_fme_DUMMY_3018 DUMMY_3018;
	rand ral_reg_ac_fme_FPMON_FAB_CTL FPMON_FAB_CTL;
	rand ral_reg_ac_fme_FPMON_FAB_CTR FPMON_FAB_CTR;
	rand ral_reg_ac_fme_FPMON_CLK_CTR FPMON_CLK_CTR;
	rand ral_reg_ac_fme_GLBL_ERROR_DFH GLBL_ERROR_DFH;
	rand ral_reg_ac_fme_FME_ERROR0_MASK FME_ERROR0_MASK;
	rand ral_reg_ac_fme_FME_ERROR0 FME_ERROR0;
	rand ral_reg_ac_fme_PCIE0_ERROR_MASK PCIE0_ERROR_MASK;
	rand ral_reg_ac_fme_PCIE0_ERROR PCIE0_ERROR;
	rand ral_reg_ac_fme_DUMMY_4028 DUMMY_4028;
	rand ral_reg_ac_fme_DUMMY_4030 DUMMY_4030;
	rand ral_reg_ac_fme_FME_FIRST_ERROR FME_FIRST_ERROR;
	rand ral_reg_ac_fme_FME_NEXT_ERROR FME_NEXT_ERROR;
	rand ral_reg_ac_fme_RAS_NOFAT_ERROR_MASK RAS_NOFAT_ERROR_MASK;
	rand ral_reg_ac_fme_RAS_NOFAT_ERROR RAS_NOFAT_ERROR;
	rand ral_reg_ac_fme_RAS_CATFAT_ERR_MASK RAS_CATFAT_ERR_MASK;
	rand ral_reg_ac_fme_RAS_CATFAT_ERR RAS_CATFAT_ERR;
	rand ral_reg_ac_fme_RAS_ERROR_INJ RAS_ERROR_INJ;
	rand ral_reg_ac_fme_GLBL_ERROR_CAPABILITY GLBL_ERROR_CAPABILITY;
	rand ral_reg_ac_fme_FME_PR_DFH FME_PR_DFH;
	rand ral_reg_ac_fme_FME_PR_CTRL FME_PR_CTRL;
	rand ral_reg_ac_fme_FME_PR_STATUS FME_PR_STATUS;
	rand ral_reg_ac_fme_FME_PR_DATA FME_PR_DATA;
	rand ral_reg_ac_fme_FME_PR_ERROR FME_PR_ERROR;
	rand ral_reg_ac_fme_DUMMY_5028 DUMMY_5028;
	rand ral_reg_ac_fme_DUMMY_5030 DUMMY_5030;
	rand ral_reg_ac_fme_DUMMY_5038 DUMMY_5038;
	rand ral_reg_ac_fme_DUMMY_5040 DUMMY_5040;
	rand ral_reg_ac_fme_DUMMY_5048 DUMMY_5048;
	rand ral_reg_ac_fme_DUMMY_5050 DUMMY_5050;
	rand ral_reg_ac_fme_DUMMY_5058 DUMMY_5058;
	rand ral_reg_ac_fme_DUMMY_5060 DUMMY_5060;
	rand ral_reg_ac_fme_DUMMY_5068 DUMMY_5068;
	rand ral_reg_ac_fme_DUMMY_5070 DUMMY_5070;
	rand ral_reg_ac_fme_DUMMY_5078 DUMMY_5078;
	rand ral_reg_ac_fme_DUMMY_5080 DUMMY_5080;
	rand ral_reg_ac_fme_DUMMY_5088 DUMMY_5088;
	rand ral_reg_ac_fme_DUMMY_5090 DUMMY_5090;
	rand ral_reg_ac_fme_DUMMY_5098 DUMMY_5098;
	rand ral_reg_ac_fme_DUMMY_50A0 DUMMY_50A0;
	rand ral_reg_ac_fme_FME_PR_INTFC_ID_L FME_PR_INTFC_ID_L;
	rand ral_reg_ac_fme_FME_PR_INTFC_ID_H FME_PR_INTFC_ID_H;
	rand ral_reg_ac_fme_MSIX_ADDR0 MSIX_ADDR0;
	rand ral_reg_ac_fme_MSIX_CTLDAT0 MSIX_CTLDAT0;
	rand ral_reg_ac_fme_MSIX_ADDR1 MSIX_ADDR1;
	rand ral_reg_ac_fme_MSIX_CTLDAT1 MSIX_CTLDAT1;
	rand ral_reg_ac_fme_MSIX_ADDR2 MSIX_ADDR2;
	rand ral_reg_ac_fme_MSIX_CTLDAT2 MSIX_CTLDAT2;
	rand ral_reg_ac_fme_MSIX_ADDR3 MSIX_ADDR3;
	rand ral_reg_ac_fme_MSIX_CTLDAT3 MSIX_CTLDAT3;
	rand ral_reg_ac_fme_MSIX_ADDR4 MSIX_ADDR4;
	rand ral_reg_ac_fme_MSIX_CTLDAT4 MSIX_CTLDAT4;
	rand ral_reg_ac_fme_MSIX_ADDR5 MSIX_ADDR5;
	rand ral_reg_ac_fme_MSIX_CTLDAT5 MSIX_CTLDAT5;
	rand ral_reg_ac_fme_MSIX_ADDR6 MSIX_ADDR6;
	rand ral_reg_ac_fme_MSIX_CTLDAT6 MSIX_CTLDAT6;
	rand ral_reg_ac_fme_MSIX_ADDR7 MSIX_ADDR7;
	rand ral_reg_ac_fme_MSIX_CTLDAT7 MSIX_CTLDAT7;
	rand ral_reg_ac_fme_MSIX_PBA MSIX_PBA;
	rand ral_reg_ac_fme_MSIX_COUNT_CSR MSIX_COUNT_CSR;
	uvm_reg_field FME_DFH_FeatureType;
	rand uvm_reg_field FME_DFH_Reserved;
	uvm_reg_field FME_DFH_EOL;
	uvm_reg_field FME_DFH_NextDfhOffset;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field FME_DFH_AfuMajVersion;
	uvm_reg_field AfuMajVersion;
	uvm_reg_field FME_DFH_CorefimVersion;
	uvm_reg_field CorefimVersion;
	uvm_reg_field FME_AFU_ID_L_AfuIdLow;
	uvm_reg_field AfuIdLow;
	uvm_reg_field FME_AFU_ID_H_AfuIdHigh;
	uvm_reg_field AfuIdHigh;
	rand uvm_reg_field FME_NEXT_AFU_Reserved;
	uvm_reg_field FME_NEXT_AFU_NextAfuDfhOffset;
	uvm_reg_field NextAfuDfhOffset;
	uvm_reg_field DUMMY_0020_Zero;
	rand uvm_reg_field FME_SCRATCHPAD0_Scratchpad;
	rand uvm_reg_field Scratchpad;
	rand uvm_reg_field FAB_CAPABILITY_Reserved30;
	rand uvm_reg_field Reserved30;
	uvm_reg_field FAB_CAPABILITY_AddressWidth;
	uvm_reg_field AddressWidth;
	rand uvm_reg_field FAB_CAPABILITY_Reserved20;
	rand uvm_reg_field Reserved20;
	uvm_reg_field FAB_CAPABILITY_NumPorts;
	uvm_reg_field NumPorts;
	rand uvm_reg_field FAB_CAPABILITY_Reserved13;
	uvm_reg_field FAB_CAPABILITY_Pcie0Link;
	uvm_reg_field Pcie0Link;
	rand uvm_reg_field FAB_CAPABILITY_Reserved8;
	rand uvm_reg_field Reserved8;
	uvm_reg_field FAB_CAPABILITY_FabricVersion;
	uvm_reg_field FabricVersion;
	rand uvm_reg_field PORT0_OFFSET_Reserved61;
	uvm_reg_field PORT0_OFFSET_PortImplemented;
	rand uvm_reg_field PORT0_OFFSET_Reserved57;
	rand uvm_reg_field PORT0_OFFSET_DecouplePortCSR;
	rand uvm_reg_field PORT0_OFFSET_AfuAccessCtrl;
	rand uvm_reg_field PORT0_OFFSET_Reserved35;
	uvm_reg_field PORT0_OFFSET_BarID;
	rand uvm_reg_field PORT0_OFFSET_Reserved24;
	uvm_reg_field PORT0_OFFSET_PortByteOffset;
	rand uvm_reg_field PORT1_OFFSET_Reserved61;
	uvm_reg_field PORT1_OFFSET_PortImplemented;
	rand uvm_reg_field PORT1_OFFSET_Reserved57;
	rand uvm_reg_field PORT1_OFFSET_DecouplePortCSR;
	rand uvm_reg_field PORT1_OFFSET_AfuAccessCtrl;
	rand uvm_reg_field PORT1_OFFSET_Reserved35;
	uvm_reg_field PORT1_OFFSET_BarID;
	rand uvm_reg_field PORT1_OFFSET_Reserved24;
	uvm_reg_field PORT1_OFFSET_PortByteOffset;
	rand uvm_reg_field PORT2_OFFSET_Reserved61;
	uvm_reg_field PORT2_OFFSET_PortImplemented;
	rand uvm_reg_field PORT2_OFFSET_Reserved57;
	rand uvm_reg_field PORT2_OFFSET_DecouplePortCSR;
	rand uvm_reg_field PORT2_OFFSET_AfuAccessCtrl;
	rand uvm_reg_field PORT2_OFFSET_Reserved35;
	uvm_reg_field PORT2_OFFSET_BarID;
	rand uvm_reg_field PORT2_OFFSET_Reserved24;
	uvm_reg_field PORT2_OFFSET_PortByteOffset;
	rand uvm_reg_field PORT3_OFFSET_Reserved61;
	uvm_reg_field PORT3_OFFSET_PortImplemented;
	rand uvm_reg_field PORT3_OFFSET_Reserved57;
	rand uvm_reg_field PORT3_OFFSET_DecouplePortCSR;
	rand uvm_reg_field PORT3_OFFSET_AfuAccessCtrl;
	rand uvm_reg_field PORT3_OFFSET_Reserved35;
	uvm_reg_field PORT3_OFFSET_BarID;
	rand uvm_reg_field PORT3_OFFSET_Reserved24;
	uvm_reg_field PORT3_OFFSET_PortByteOffset;
	rand uvm_reg_field FAB_STATUS_Reserved9;
	uvm_reg_field FAB_STATUS_Pcie0LinkStatus;
	uvm_reg_field Pcie0LinkStatus;
	rand uvm_reg_field FAB_STATUS_Reserved0;
	uvm_reg_field BITSTREAM_ID_VerMajor;
	uvm_reg_field VerMajor;
	uvm_reg_field BITSTREAM_ID_VerMinor;
	uvm_reg_field VerMinor;
	uvm_reg_field BITSTREAM_ID_VerPatch;
	uvm_reg_field VerPatch;
	uvm_reg_field BITSTREAM_ID_VerDebug;
	uvm_reg_field VerDebug;
	rand uvm_reg_field BITSTREAM_ID_Reserved36;
	uvm_reg_field BITSTREAM_ID_HssiID;
	uvm_reg_field HssiID;
	uvm_reg_field BITSTREAM_ID_GitHash;
	uvm_reg_field GitHash;
	rand uvm_reg_field BITSTREAM_MD_Reserved28;
	uvm_reg_field BITSTREAM_MD_SynthYear;
	uvm_reg_field SynthYear;
	uvm_reg_field BITSTREAM_MD_SynthMonth;
	uvm_reg_field SynthMonth;
	uvm_reg_field BITSTREAM_MD_SynthDay;
	uvm_reg_field SynthDay;
	uvm_reg_field BITSTREAM_MD_SynthSeed;
	uvm_reg_field SynthSeed;
	uvm_reg_field THERM_MNGM_DFH_FeatureType;
	rand uvm_reg_field THERM_MNGM_DFH_Reserved40;
	rand uvm_reg_field Reserved40;
	uvm_reg_field THERM_MNGM_DFH_EOL;
	uvm_reg_field THERM_MNGM_DFH_NextDfhByteOffset;
	uvm_reg_field THERM_MNGM_DFH_FeatureRev;
	uvm_reg_field THERM_MNGM_DFH_FeatureID;
	rand uvm_reg_field TMP_THRESHOLD_Reserved45;
	rand uvm_reg_field Reserved45;
	rand uvm_reg_field TMP_THRESHOLD_ThresholdPolicy;
	rand uvm_reg_field ThresholdPolicy;
	rand uvm_reg_field TMP_THRESHOLD_Reserved42;
	rand uvm_reg_field TMP_THRESHOLD_ValModeTherm;
	rand uvm_reg_field ValModeTherm;
	rand uvm_reg_field TMP_THRESHOLD_Reserved36;
	uvm_reg_field TMP_THRESHOLD_ThermTripStatus;
	uvm_reg_field ThermTripStatus;
	rand uvm_reg_field TMP_THRESHOLD_Reserved34;
	rand uvm_reg_field Reserved34;
	uvm_reg_field TMP_THRESHOLD_Threshold2Status;
	uvm_reg_field Threshold2Status;
	uvm_reg_field TMP_THRESHOLD_Threshold1Status;
	uvm_reg_field Threshold1Status;
	rand uvm_reg_field TMP_THRESHOLD_Reserved31;
	rand uvm_reg_field Reserved31;
	rand uvm_reg_field TMP_THRESHOLD_ThermTripThreshold;
	rand uvm_reg_field ThermTripThreshold;
	rand uvm_reg_field TMP_THRESHOLD_Reserved16;
	rand uvm_reg_field Reserved16;
	rand uvm_reg_field TMP_THRESHOLD_TempThreshold2Enab;
	rand uvm_reg_field TempThreshold2Enab;
	rand uvm_reg_field TMP_THRESHOLD_TempThreshold2;
	rand uvm_reg_field TempThreshold2;
	rand uvm_reg_field TMP_THRESHOLD_TempThreshold1Enab;
	rand uvm_reg_field TempThreshold1Enab;
	rand uvm_reg_field TMP_THRESHOLD_TempThreshold1;
	rand uvm_reg_field TempThreshold1;
	rand uvm_reg_field TMP_RDSENSOR_FMT1_Reserved42;
	uvm_reg_field TMP_RDSENSOR_FMT1_TempThermalSensor;
	uvm_reg_field TempThermalSensor;
	rand uvm_reg_field TMP_RDSENSOR_FMT1_Reserved25;
	rand uvm_reg_field Reserved25;
	uvm_reg_field TMP_RDSENSOR_FMT1_TempValid;
	uvm_reg_field TempValid;
	uvm_reg_field TMP_RDSENSOR_FMT1_NumbTempReads;
	uvm_reg_field NumbTempReads;
	rand uvm_reg_field TMP_RDSENSOR_FMT1_Reserved7;
	uvm_reg_field TMP_RDSENSOR_FMT1_FpgaTemp;
	uvm_reg_field FpgaTemp;
	rand uvm_reg_field TMP_RDSENSOR_FMT2_Reserved0;
	rand uvm_reg_field TMP_THRESHOLD_CAPABILITY_Reserved;
	uvm_reg_field TMP_THRESHOLD_CAPABILITY_DisablTmpThrReport;
	uvm_reg_field DisablTmpThrReport;
	uvm_reg_field GLBL_PERF_DFH_FeatureType;
	rand uvm_reg_field GLBL_PERF_DFH_Reserved;
	uvm_reg_field GLBL_PERF_DFH_EOL;
	uvm_reg_field GLBL_PERF_DFH_NextDfhByteOffset;
	uvm_reg_field GLBL_PERF_DFH_FeatureRev;
	uvm_reg_field GLBL_PERF_DFH_FeatureID;
	uvm_reg_field DUMMY_3008_Zero;
	uvm_reg_field DUMMY_3010_Zero;
	uvm_reg_field DUMMY_3018_Zero;
	rand uvm_reg_field FPMON_FAB_CTL_Reserved24;
	rand uvm_reg_field FPMON_FAB_CTL_PortFilter;
	rand uvm_reg_field PortFilter;
	rand uvm_reg_field FPMON_FAB_CTL_Reserved22;
	rand uvm_reg_field Reserved22;
	rand uvm_reg_field FPMON_FAB_CTL_PortId;
	rand uvm_reg_field PortId;
	rand uvm_reg_field FPMON_FAB_CTL_FabricEventCode;
	rand uvm_reg_field FPMON_FAB_CTL_Reserved9;
	rand uvm_reg_field FPMON_FAB_CTL_FreezeCounters;
	rand uvm_reg_field FreezeCounters;
	rand uvm_reg_field FPMON_FAB_CTL_Reserved0;
	uvm_reg_field FPMON_FAB_CTR_FabricEventCode;
	uvm_reg_field FPMON_FAB_CTR_FabricEventCounter;
	uvm_reg_field FabricEventCounter;
	uvm_reg_field FPMON_CLK_CTR_ClockCounter;
	uvm_reg_field ClockCounter;
	uvm_reg_field GLBL_ERROR_DFH_FeatureType;
	rand uvm_reg_field GLBL_ERROR_DFH_Reserved;
	uvm_reg_field GLBL_ERROR_DFH_EOL;
	uvm_reg_field GLBL_ERROR_DFH_NextDfhByteOffset;
	uvm_reg_field GLBL_ERROR_DFH_FeatureRevision;
	uvm_reg_field GLBL_ERROR_DFH_FeatureId;
	rand uvm_reg_field FME_ERROR0_MASK_Reserved6;
	rand uvm_reg_field FME_ERROR0_MASK_ErrorMask5;
	rand uvm_reg_field FME_ERROR0_MASK_Reserved2;
	rand uvm_reg_field FME_ERROR0_MASK_ErrorMask0;
	rand uvm_reg_field ErrorMask0;
	rand uvm_reg_field FME_ERROR0_Reserved6;
	rand uvm_reg_field FME_ERROR0_AfuAccessModeErr;
	rand uvm_reg_field FME_ERROR0_Reserved2;
	rand uvm_reg_field FME_ERROR0_RemoteSTPParityErr;
	rand uvm_reg_field RemoteSTPParityErr;
	rand uvm_reg_field FME_ERROR0_PartialReconfigFIFOParityErr;
	rand uvm_reg_field PartialReconfigFIFOParityErr;
	rand uvm_reg_field PCIE0_ERROR_MASK_Reserved10;
	rand uvm_reg_field PCIE0_ERROR_MASK_ErrorMask;
	rand uvm_reg_field ErrorMask;
	rand uvm_reg_field PCIE0_ERROR_FunctTypeErr;
	rand uvm_reg_field FunctTypeErr;
	rand uvm_reg_field PCIE0_ERROR_VFNumb;
	rand uvm_reg_field VFNumb;
	rand uvm_reg_field PCIE0_ERROR_Reserved13;
	rand uvm_reg_field PCIE0_ERROR_FifoOverflowErr;
	rand uvm_reg_field FifoOverflowErr;
	rand uvm_reg_field PCIE0_ERROR_MalformedEopErr;
	rand uvm_reg_field MalformedEopErr;
	rand uvm_reg_field PCIE0_ERROR_MalformedSopErr;
	rand uvm_reg_field MalformedSopErr;
	rand uvm_reg_field PCIE0_ERROR_RxPoisonTlpErr;
	rand uvm_reg_field RxPoisonTlpErr;
	rand uvm_reg_field PCIE0_ERROR_ParityErr;
	rand uvm_reg_field ParityErr;
	rand uvm_reg_field PCIE0_ERROR_CompTimeOutErr;
	rand uvm_reg_field CompTimeOutErr;
	rand uvm_reg_field PCIE0_ERROR_CompStatErr;
	rand uvm_reg_field CompStatErr;
	rand uvm_reg_field PCIE0_ERROR_CompTagErr;
	rand uvm_reg_field CompTagErr;
	rand uvm_reg_field PCIE0_ERROR_MRLengthErr;
	rand uvm_reg_field MRLengthErr;
	rand uvm_reg_field PCIE0_ERROR_MRAddrErr;
	rand uvm_reg_field MRAddrErr;
	rand uvm_reg_field PCIE0_ERROR_MWLengthErr;
	rand uvm_reg_field MWLengthErr;
	rand uvm_reg_field PCIE0_ERROR_MWAddrErr;
	rand uvm_reg_field MWAddrErr;
	rand uvm_reg_field PCIE0_ERROR_FormatTypeErr;
	rand uvm_reg_field FormatTypeErr;
	uvm_reg_field DUMMY_4028_Zero;
	uvm_reg_field DUMMY_4030_Zero;
	rand uvm_reg_field FME_FIRST_ERROR_Reserved;
	uvm_reg_field FME_FIRST_ERROR_ErrorRegID;
	uvm_reg_field FME_FIRST_ERROR_ErrorRegStatus;
	rand uvm_reg_field FME_NEXT_ERROR_Reserved;
	uvm_reg_field FME_NEXT_ERROR_ErrorRegID;
	uvm_reg_field FME_NEXT_ERROR_ErrorRegStatus;
	rand uvm_reg_field RAS_NOFAT_ERROR_MASK_Reserved10;
	rand uvm_reg_field RAS_NOFAT_ERROR_MASK_ErrorMask5;
	rand uvm_reg_field RAS_NOFAT_ERROR_MASK_Reserved4;
	rand uvm_reg_field RAS_NOFAT_ERROR_MASK_ErrorMask2;
	rand uvm_reg_field ErrorMask2;
	rand uvm_reg_field RAS_NOFAT_ERROR_MASK_Reserved0;
	rand uvm_reg_field RAS_NOFAT_ERROR_Reserved7;
	rand uvm_reg_field RAS_NOFAT_ERROR_InjectedWarningErr;
	rand uvm_reg_field InjectedWarningErr;
	rand uvm_reg_field RAS_NOFAT_ERROR_AfuAccessModeErr;
	rand uvm_reg_field RAS_NOFAT_ERROR_Reserved4;
	rand uvm_reg_field RAS_NOFAT_ERROR_PortFatalErr;
	rand uvm_reg_field PortFatalErr;
	uvm_reg_field RAS_NOFAT_ERROR_PcieError;
	uvm_reg_field PcieError;
	rand uvm_reg_field RAS_NOFAT_ERROR_Reserved0;
	rand uvm_reg_field RAS_CATFAT_ERR_MASK_Reserved12;
	rand uvm_reg_field RAS_CATFAT_ERR_MASK_ErrorMask11;
	rand uvm_reg_field ErrorMask11;
	rand uvm_reg_field RAS_CATFAT_ERR_MASK_Reserved10;
	rand uvm_reg_field RAS_CATFAT_ERR_MASK_ErrorMask6;
	rand uvm_reg_field ErrorMask6;
	rand uvm_reg_field RAS_CATFAT_ERR_MASK_Reserved0;
	rand uvm_reg_field RAS_CATFAT_ERR_Reserved12;
	uvm_reg_field RAS_CATFAT_ERR_InjectedCatastErr;
	uvm_reg_field InjectedCatastErr;
	rand uvm_reg_field RAS_CATFAT_ERR_Reserved10;
	uvm_reg_field RAS_CATFAT_ERR_CrcCatastErr;
	uvm_reg_field CrcCatastErr;
	uvm_reg_field RAS_CATFAT_ERR_InjectedFatalErr;
	uvm_reg_field InjectedFatalErr;
	uvm_reg_field RAS_CATFAT_ERR_PciePoisonErr;
	uvm_reg_field PciePoisonErr;
	uvm_reg_field RAS_CATFAT_ERR_FabricFatalErr;
	uvm_reg_field FabricFatalErr;
	rand uvm_reg_field RAS_CATFAT_ERR_Reserved0;
	rand uvm_reg_field RAS_ERROR_INJ_Reserved0;
	rand uvm_reg_field RAS_ERROR_INJ_NoFatalError;
	rand uvm_reg_field NoFatalError;
	rand uvm_reg_field RAS_ERROR_INJ_FatalError;
	rand uvm_reg_field FatalError;
	rand uvm_reg_field RAS_ERROR_INJ_CatastError;
	rand uvm_reg_field CatastError;
	rand uvm_reg_field GLBL_ERROR_CAPABILITY_Reserved13;
	uvm_reg_field GLBL_ERROR_CAPABILITY_InterruptVectorNumber;
	uvm_reg_field InterruptVectorNumber;
	uvm_reg_field GLBL_ERROR_CAPABILITY_SupportsInterrupt;
	uvm_reg_field SupportsInterrupt;
	uvm_reg_field FME_PR_DFH_FeatureType;
	rand uvm_reg_field FME_PR_DFH_Reserved;
	uvm_reg_field FME_PR_DFH_EOL;
	uvm_reg_field FME_PR_DFH_NextDfhByteOffset;
	uvm_reg_field FME_PR_DFH_FeatureRevision;
	uvm_reg_field FME_PR_DFH_FeatureId;
	rand uvm_reg_field FME_PR_CTRL_TBD;
	rand uvm_reg_field TBD;
	rand uvm_reg_field FME_PR_CTRL_Reserved15;
	rand uvm_reg_field Reserved15;
	rand uvm_reg_field FME_PR_CTRL_PRKind;
	rand uvm_reg_field PRKind;
	rand uvm_reg_field FME_PR_CTRL_PRDataPushComplete;
	rand uvm_reg_field PRDataPushComplete;
	rand uvm_reg_field FME_PR_CTRL_PRStartRequest;
	rand uvm_reg_field PRStartRequest;
	rand uvm_reg_field FME_PR_CTRL_Reserved10;
	rand uvm_reg_field FME_PR_CTRL_PRRegionId;
	rand uvm_reg_field PRRegionId;
	rand uvm_reg_field FME_PR_CTRL_Reserved5;
	rand uvm_reg_field Reserved5;
	uvm_reg_field FME_PR_CTRL_PRResetAck;
	uvm_reg_field PRResetAck;
	rand uvm_reg_field FME_PR_CTRL_Reserved1;
	rand uvm_reg_field Reserved1;
	rand uvm_reg_field FME_PR_CTRL_PRReset;
	rand uvm_reg_field PRReset;
	uvm_reg_field FME_PR_STATUS_SecurityBlockStatus;
	uvm_reg_field SecurityBlockStatus;
	rand uvm_reg_field FME_PR_STATUS_Reserved28;
	uvm_reg_field FME_PR_STATUS_PRHostStatus;
	uvm_reg_field PRHostStatus;
	rand uvm_reg_field FME_PR_STATUS_Reserved23;
	rand uvm_reg_field Reserved23;
	uvm_reg_field FME_PR_STATUS_AlteraPRCrtlrStatus;
	uvm_reg_field AlteraPRCrtlrStatus;
	rand uvm_reg_field FME_PR_STATUS_Reserved17;
	rand uvm_reg_field Reserved17;
	uvm_reg_field FME_PR_STATUS_PRStatus;
	uvm_reg_field PRStatus;
	rand uvm_reg_field FME_PR_STATUS_Reserved9;
	uvm_reg_field FME_PR_STATUS_NumbCredits;
	uvm_reg_field NumbCredits;
	rand uvm_reg_field FME_PR_DATA_PRData;
	rand uvm_reg_field PRData;
	rand uvm_reg_field FME_PR_ERROR_Reserved7;
	rand uvm_reg_field FME_PR_ERROR_SecureLoadFailed;
	rand uvm_reg_field SecureLoadFailed;
	rand uvm_reg_field FME_PR_ERROR_HostInitTimeout;
	rand uvm_reg_field HostInitTimeout;
	rand uvm_reg_field FME_PR_ERROR_HostInitFIFOOverflow;
	rand uvm_reg_field HostInitFIFOOverflow;
	rand uvm_reg_field FME_PR_ERROR_IPInitProtocolError;
	rand uvm_reg_field IPInitProtocolError;
	rand uvm_reg_field FME_PR_ERROR_IPInitIncompatibleBitstream;
	rand uvm_reg_field IPInitIncompatibleBitstream;
	rand uvm_reg_field FME_PR_ERROR_IPInitCRCError;
	rand uvm_reg_field IPInitCRCError;
	rand uvm_reg_field FME_PR_ERROR_HostInitOperationError;
	rand uvm_reg_field HostInitOperationError;
	uvm_reg_field DUMMY_5028_Zero;
	uvm_reg_field DUMMY_5030_Zero;
	uvm_reg_field DUMMY_5038_Zero;
	uvm_reg_field DUMMY_5040_Zero;
	uvm_reg_field DUMMY_5048_Zero;
	uvm_reg_field DUMMY_5050_Zero;
	uvm_reg_field DUMMY_5058_Zero;
	uvm_reg_field DUMMY_5060_Zero;
	uvm_reg_field DUMMY_5068_Zero;
	uvm_reg_field DUMMY_5070_Zero;
	uvm_reg_field DUMMY_5078_Zero;
	uvm_reg_field DUMMY_5080_Zero;
	uvm_reg_field DUMMY_5088_Zero;
	uvm_reg_field DUMMY_5090_Zero;
	uvm_reg_field DUMMY_5098_Zero;
	uvm_reg_field DUMMY_50A0_Zero;
	uvm_reg_field FME_PR_INTFC_ID_L_InterfaceIdL;
	uvm_reg_field InterfaceIdL;
	uvm_reg_field FME_PR_INTFC_ID_H_InterfaceIdH;
	uvm_reg_field InterfaceIdH;
	rand uvm_reg_field MSIX_ADDR0_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR0_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT0_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT0_MsgData;
	rand uvm_reg_field MSIX_ADDR1_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR1_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT1_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT1_MsgData;
	rand uvm_reg_field MSIX_ADDR2_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR2_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT2_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT2_MsgData;
	rand uvm_reg_field MSIX_ADDR3_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR3_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT3_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT3_MsgData;
	rand uvm_reg_field MSIX_ADDR4_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR4_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT4_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT4_MsgData;
	rand uvm_reg_field MSIX_ADDR5_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR5_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT5_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT5_MsgData;
	rand uvm_reg_field MSIX_ADDR6_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR6_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT6_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT6_MsgData;
	rand uvm_reg_field MSIX_ADDR7_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR7_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT7_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT7_MsgData;
	rand uvm_reg_field MSIX_PBA_Reserved7;
	uvm_reg_field MSIX_PBA_MsixPba;
	uvm_reg_field MsixPba;
	rand uvm_reg_field MSIX_COUNT_CSR_Reserved32;
	rand uvm_reg_field Reserved32;
	uvm_reg_field MSIX_COUNT_CSR_Afu2SyncFifoMsixCount;
	uvm_reg_field Afu2SyncFifoMsixCount;
	uvm_reg_field MSIX_COUNT_CSR_SyncFifo2MsixCount;
	uvm_reg_field SyncFifo2MsixCount;
	uvm_reg_field MSIX_COUNT_CSR_Msix2CdcMsixCount;
	uvm_reg_field Msix2CdcMsixCount;
	uvm_reg_field MSIX_COUNT_CSR_Cdc2AvlMsixCount;
	uvm_reg_field Cdc2AvlMsixCount;

	function new(string name = "ac_fme");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.FME_DFH = ral_reg_ac_fme_FME_DFH::type_id::create("FME_DFH",,get_full_name());
      this.FME_DFH.configure(this, null, "");
      this.FME_DFH.build();
      this.default_map.add_reg(this.FME_DFH, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.FME_DFH_FeatureType = this.FME_DFH.FeatureType;
		this.FME_DFH_Reserved = this.FME_DFH.Reserved;
		this.FME_DFH_EOL = this.FME_DFH.EOL;
		this.FME_DFH_NextDfhOffset = this.FME_DFH.NextDfhOffset;
		this.NextDfhOffset = this.FME_DFH.NextDfhOffset;
		this.FME_DFH_AfuMajVersion = this.FME_DFH.AfuMajVersion;
		this.AfuMajVersion = this.FME_DFH.AfuMajVersion;
		this.FME_DFH_CorefimVersion = this.FME_DFH.CorefimVersion;
		this.CorefimVersion = this.FME_DFH.CorefimVersion;
      this.FME_AFU_ID_L = ral_reg_ac_fme_FME_AFU_ID_L::type_id::create("FME_AFU_ID_L",,get_full_name());
      this.FME_AFU_ID_L.configure(this, null, "");
      this.FME_AFU_ID_L.build();
      this.default_map.add_reg(this.FME_AFU_ID_L, `UVM_REG_ADDR_WIDTH'h8, "RO", 0);
		this.FME_AFU_ID_L_AfuIdLow = this.FME_AFU_ID_L.AfuIdLow;
		this.AfuIdLow = this.FME_AFU_ID_L.AfuIdLow;
      this.FME_AFU_ID_H = ral_reg_ac_fme_FME_AFU_ID_H::type_id::create("FME_AFU_ID_H",,get_full_name());
      this.FME_AFU_ID_H.configure(this, null, "");
      this.FME_AFU_ID_H.build();
      this.default_map.add_reg(this.FME_AFU_ID_H, `UVM_REG_ADDR_WIDTH'h10, "RO", 0);
		this.FME_AFU_ID_H_AfuIdHigh = this.FME_AFU_ID_H.AfuIdHigh;
		this.AfuIdHigh = this.FME_AFU_ID_H.AfuIdHigh;
      this.FME_NEXT_AFU = ral_reg_ac_fme_FME_NEXT_AFU::type_id::create("FME_NEXT_AFU",,get_full_name());
      this.FME_NEXT_AFU.configure(this, null, "");
      this.FME_NEXT_AFU.build();
      this.default_map.add_reg(this.FME_NEXT_AFU, `UVM_REG_ADDR_WIDTH'h18, "RW", 0);
		this.FME_NEXT_AFU_Reserved = this.FME_NEXT_AFU.Reserved;
		this.FME_NEXT_AFU_NextAfuDfhOffset = this.FME_NEXT_AFU.NextAfuDfhOffset;
		this.NextAfuDfhOffset = this.FME_NEXT_AFU.NextAfuDfhOffset;
      this.DUMMY_0020 = ral_reg_ac_fme_DUMMY_0020::type_id::create("DUMMY_0020",,get_full_name());
      this.DUMMY_0020.configure(this, null, "");
      this.DUMMY_0020.build();
      this.default_map.add_reg(this.DUMMY_0020, `UVM_REG_ADDR_WIDTH'h20, "RO", 0);
		this.DUMMY_0020_Zero = this.DUMMY_0020.Zero;
      this.FME_SCRATCHPAD0 = ral_reg_ac_fme_FME_SCRATCHPAD0::type_id::create("FME_SCRATCHPAD0",,get_full_name());
      this.FME_SCRATCHPAD0.configure(this, null, "");
      this.FME_SCRATCHPAD0.build();
      this.default_map.add_reg(this.FME_SCRATCHPAD0, `UVM_REG_ADDR_WIDTH'h28, "RW", 0);
		this.FME_SCRATCHPAD0_Scratchpad = this.FME_SCRATCHPAD0.Scratchpad;
		this.Scratchpad = this.FME_SCRATCHPAD0.Scratchpad;
      this.FAB_CAPABILITY = ral_reg_ac_fme_FAB_CAPABILITY::type_id::create("FAB_CAPABILITY",,get_full_name());
      this.FAB_CAPABILITY.configure(this, null, "");
      this.FAB_CAPABILITY.build();
      this.default_map.add_reg(this.FAB_CAPABILITY, `UVM_REG_ADDR_WIDTH'h30, "RW", 0);
		this.FAB_CAPABILITY_Reserved30 = this.FAB_CAPABILITY.Reserved30;
		this.Reserved30 = this.FAB_CAPABILITY.Reserved30;
		this.FAB_CAPABILITY_AddressWidth = this.FAB_CAPABILITY.AddressWidth;
		this.AddressWidth = this.FAB_CAPABILITY.AddressWidth;
		this.FAB_CAPABILITY_Reserved20 = this.FAB_CAPABILITY.Reserved20;
		this.Reserved20 = this.FAB_CAPABILITY.Reserved20;
		this.FAB_CAPABILITY_NumPorts = this.FAB_CAPABILITY.NumPorts;
		this.NumPorts = this.FAB_CAPABILITY.NumPorts;
		this.FAB_CAPABILITY_Reserved13 = this.FAB_CAPABILITY.Reserved13;
		this.FAB_CAPABILITY_Pcie0Link = this.FAB_CAPABILITY.Pcie0Link;
		this.Pcie0Link = this.FAB_CAPABILITY.Pcie0Link;
		this.FAB_CAPABILITY_Reserved8 = this.FAB_CAPABILITY.Reserved8;
		this.Reserved8 = this.FAB_CAPABILITY.Reserved8;
		this.FAB_CAPABILITY_FabricVersion = this.FAB_CAPABILITY.FabricVersion;
		this.FabricVersion = this.FAB_CAPABILITY.FabricVersion;
      this.PORT0_OFFSET = ral_reg_ac_fme_PORT0_OFFSET::type_id::create("PORT0_OFFSET",,get_full_name());
      this.PORT0_OFFSET.configure(this, null, "");
      this.PORT0_OFFSET.build();
      this.default_map.add_reg(this.PORT0_OFFSET, `UVM_REG_ADDR_WIDTH'h38, "RW", 0);
		this.PORT0_OFFSET_Reserved61 = this.PORT0_OFFSET.Reserved61;
		this.PORT0_OFFSET_PortImplemented = this.PORT0_OFFSET.PortImplemented;
		this.PORT0_OFFSET_Reserved57 = this.PORT0_OFFSET.Reserved57;
		this.PORT0_OFFSET_DecouplePortCSR = this.PORT0_OFFSET.DecouplePortCSR;
		this.PORT0_OFFSET_AfuAccessCtrl = this.PORT0_OFFSET.AfuAccessCtrl;
		this.PORT0_OFFSET_Reserved35 = this.PORT0_OFFSET.Reserved35;
		this.PORT0_OFFSET_BarID = this.PORT0_OFFSET.BarID;
		this.PORT0_OFFSET_Reserved24 = this.PORT0_OFFSET.Reserved24;
		this.PORT0_OFFSET_PortByteOffset = this.PORT0_OFFSET.PortByteOffset;
      this.PORT1_OFFSET = ral_reg_ac_fme_PORT1_OFFSET::type_id::create("PORT1_OFFSET",,get_full_name());
      this.PORT1_OFFSET.configure(this, null, "");
      this.PORT1_OFFSET.build();
      this.default_map.add_reg(this.PORT1_OFFSET, `UVM_REG_ADDR_WIDTH'h40, "RW", 0);
		this.PORT1_OFFSET_Reserved61 = this.PORT1_OFFSET.Reserved61;
		this.PORT1_OFFSET_PortImplemented = this.PORT1_OFFSET.PortImplemented;
		this.PORT1_OFFSET_Reserved57 = this.PORT1_OFFSET.Reserved57;
		this.PORT1_OFFSET_DecouplePortCSR = this.PORT1_OFFSET.DecouplePortCSR;
		this.PORT1_OFFSET_AfuAccessCtrl = this.PORT1_OFFSET.AfuAccessCtrl;
		this.PORT1_OFFSET_Reserved35 = this.PORT1_OFFSET.Reserved35;
		this.PORT1_OFFSET_BarID = this.PORT1_OFFSET.BarID;
		this.PORT1_OFFSET_Reserved24 = this.PORT1_OFFSET.Reserved24;
		this.PORT1_OFFSET_PortByteOffset = this.PORT1_OFFSET.PortByteOffset;
      this.PORT2_OFFSET = ral_reg_ac_fme_PORT2_OFFSET::type_id::create("PORT2_OFFSET",,get_full_name());
      this.PORT2_OFFSET.configure(this, null, "");
      this.PORT2_OFFSET.build();
      this.default_map.add_reg(this.PORT2_OFFSET, `UVM_REG_ADDR_WIDTH'h48, "RW", 0);
		this.PORT2_OFFSET_Reserved61 = this.PORT2_OFFSET.Reserved61;
		this.PORT2_OFFSET_PortImplemented = this.PORT2_OFFSET.PortImplemented;
		this.PORT2_OFFSET_Reserved57 = this.PORT2_OFFSET.Reserved57;
		this.PORT2_OFFSET_DecouplePortCSR = this.PORT2_OFFSET.DecouplePortCSR;
		this.PORT2_OFFSET_AfuAccessCtrl = this.PORT2_OFFSET.AfuAccessCtrl;
		this.PORT2_OFFSET_Reserved35 = this.PORT2_OFFSET.Reserved35;
		this.PORT2_OFFSET_BarID = this.PORT2_OFFSET.BarID;
		this.PORT2_OFFSET_Reserved24 = this.PORT2_OFFSET.Reserved24;
		this.PORT2_OFFSET_PortByteOffset = this.PORT2_OFFSET.PortByteOffset;
      this.PORT3_OFFSET = ral_reg_ac_fme_PORT3_OFFSET::type_id::create("PORT3_OFFSET",,get_full_name());
      this.PORT3_OFFSET.configure(this, null, "");
      this.PORT3_OFFSET.build();
      this.default_map.add_reg(this.PORT3_OFFSET, `UVM_REG_ADDR_WIDTH'h50, "RW", 0);
		this.PORT3_OFFSET_Reserved61 = this.PORT3_OFFSET.Reserved61;
		this.PORT3_OFFSET_PortImplemented = this.PORT3_OFFSET.PortImplemented;
		this.PORT3_OFFSET_Reserved57 = this.PORT3_OFFSET.Reserved57;
		this.PORT3_OFFSET_DecouplePortCSR = this.PORT3_OFFSET.DecouplePortCSR;
		this.PORT3_OFFSET_AfuAccessCtrl = this.PORT3_OFFSET.AfuAccessCtrl;
		this.PORT3_OFFSET_Reserved35 = this.PORT3_OFFSET.Reserved35;
		this.PORT3_OFFSET_BarID = this.PORT3_OFFSET.BarID;
		this.PORT3_OFFSET_Reserved24 = this.PORT3_OFFSET.Reserved24;
		this.PORT3_OFFSET_PortByteOffset = this.PORT3_OFFSET.PortByteOffset;
      this.FAB_STATUS = ral_reg_ac_fme_FAB_STATUS::type_id::create("FAB_STATUS",,get_full_name());
      this.FAB_STATUS.configure(this, null, "");
      this.FAB_STATUS.build();
      this.default_map.add_reg(this.FAB_STATUS, `UVM_REG_ADDR_WIDTH'h58, "RW", 0);
		this.FAB_STATUS_Reserved9 = this.FAB_STATUS.Reserved9;
		this.FAB_STATUS_Pcie0LinkStatus = this.FAB_STATUS.Pcie0LinkStatus;
		this.Pcie0LinkStatus = this.FAB_STATUS.Pcie0LinkStatus;
		this.FAB_STATUS_Reserved0 = this.FAB_STATUS.Reserved0;
      this.BITSTREAM_ID = ral_reg_ac_fme_BITSTREAM_ID::type_id::create("BITSTREAM_ID",,get_full_name());
      this.BITSTREAM_ID.configure(this, null, "");
      this.BITSTREAM_ID.build();
      this.default_map.add_reg(this.BITSTREAM_ID, `UVM_REG_ADDR_WIDTH'h60, "RW", 0);
		this.BITSTREAM_ID_VerMajor = this.BITSTREAM_ID.VerMajor;
		this.VerMajor = this.BITSTREAM_ID.VerMajor;
		this.BITSTREAM_ID_VerMinor = this.BITSTREAM_ID.VerMinor;
		this.VerMinor = this.BITSTREAM_ID.VerMinor;
		this.BITSTREAM_ID_VerPatch = this.BITSTREAM_ID.VerPatch;
		this.VerPatch = this.BITSTREAM_ID.VerPatch;
		this.BITSTREAM_ID_VerDebug = this.BITSTREAM_ID.VerDebug;
		this.VerDebug = this.BITSTREAM_ID.VerDebug;
		this.BITSTREAM_ID_Reserved36 = this.BITSTREAM_ID.Reserved36;
		this.BITSTREAM_ID_HssiID = this.BITSTREAM_ID.HssiID;
		this.HssiID = this.BITSTREAM_ID.HssiID;
		this.BITSTREAM_ID_GitHash = this.BITSTREAM_ID.GitHash;
		this.GitHash = this.BITSTREAM_ID.GitHash;
      this.BITSTREAM_MD = ral_reg_ac_fme_BITSTREAM_MD::type_id::create("BITSTREAM_MD",,get_full_name());
      this.BITSTREAM_MD.configure(this, null, "");
      this.BITSTREAM_MD.build();
      this.default_map.add_reg(this.BITSTREAM_MD, `UVM_REG_ADDR_WIDTH'h68, "RW", 0);
		this.BITSTREAM_MD_Reserved28 = this.BITSTREAM_MD.Reserved28;
		this.BITSTREAM_MD_SynthYear = this.BITSTREAM_MD.SynthYear;
		this.SynthYear = this.BITSTREAM_MD.SynthYear;
		this.BITSTREAM_MD_SynthMonth = this.BITSTREAM_MD.SynthMonth;
		this.SynthMonth = this.BITSTREAM_MD.SynthMonth;
		this.BITSTREAM_MD_SynthDay = this.BITSTREAM_MD.SynthDay;
		this.SynthDay = this.BITSTREAM_MD.SynthDay;
		this.BITSTREAM_MD_SynthSeed = this.BITSTREAM_MD.SynthSeed;
		this.SynthSeed = this.BITSTREAM_MD.SynthSeed;
      this.THERM_MNGM_DFH = ral_reg_ac_fme_THERM_MNGM_DFH::type_id::create("THERM_MNGM_DFH",,get_full_name());
      this.THERM_MNGM_DFH.configure(this, null, "");
      this.THERM_MNGM_DFH.build();
      this.default_map.add_reg(this.THERM_MNGM_DFH, `UVM_REG_ADDR_WIDTH'h1000, "RW", 0);
		this.THERM_MNGM_DFH_FeatureType = this.THERM_MNGM_DFH.FeatureType;
		this.THERM_MNGM_DFH_Reserved40 = this.THERM_MNGM_DFH.Reserved40;
		this.Reserved40 = this.THERM_MNGM_DFH.Reserved40;
		this.THERM_MNGM_DFH_EOL = this.THERM_MNGM_DFH.EOL;
		this.THERM_MNGM_DFH_NextDfhByteOffset = this.THERM_MNGM_DFH.NextDfhByteOffset;
		this.THERM_MNGM_DFH_FeatureRev = this.THERM_MNGM_DFH.FeatureRev;
		this.THERM_MNGM_DFH_FeatureID = this.THERM_MNGM_DFH.FeatureID;
      this.TMP_THRESHOLD = ral_reg_ac_fme_TMP_THRESHOLD::type_id::create("TMP_THRESHOLD",,get_full_name());
      this.TMP_THRESHOLD.configure(this, null, "");
      this.TMP_THRESHOLD.build();
      this.default_map.add_reg(this.TMP_THRESHOLD, `UVM_REG_ADDR_WIDTH'h1008, "RW", 0);
		this.TMP_THRESHOLD_Reserved45 = this.TMP_THRESHOLD.Reserved45;
		this.Reserved45 = this.TMP_THRESHOLD.Reserved45;
		this.TMP_THRESHOLD_ThresholdPolicy = this.TMP_THRESHOLD.ThresholdPolicy;
		this.ThresholdPolicy = this.TMP_THRESHOLD.ThresholdPolicy;
		this.TMP_THRESHOLD_Reserved42 = this.TMP_THRESHOLD.Reserved42;
		this.TMP_THRESHOLD_ValModeTherm = this.TMP_THRESHOLD.ValModeTherm;
		this.ValModeTherm = this.TMP_THRESHOLD.ValModeTherm;
		this.TMP_THRESHOLD_Reserved36 = this.TMP_THRESHOLD.Reserved36;
		this.TMP_THRESHOLD_ThermTripStatus = this.TMP_THRESHOLD.ThermTripStatus;
		this.ThermTripStatus = this.TMP_THRESHOLD.ThermTripStatus;
		this.TMP_THRESHOLD_Reserved34 = this.TMP_THRESHOLD.Reserved34;
		this.Reserved34 = this.TMP_THRESHOLD.Reserved34;
		this.TMP_THRESHOLD_Threshold2Status = this.TMP_THRESHOLD.Threshold2Status;
		this.Threshold2Status = this.TMP_THRESHOLD.Threshold2Status;
		this.TMP_THRESHOLD_Threshold1Status = this.TMP_THRESHOLD.Threshold1Status;
		this.Threshold1Status = this.TMP_THRESHOLD.Threshold1Status;
		this.TMP_THRESHOLD_Reserved31 = this.TMP_THRESHOLD.Reserved31;
		this.Reserved31 = this.TMP_THRESHOLD.Reserved31;
		this.TMP_THRESHOLD_ThermTripThreshold = this.TMP_THRESHOLD.ThermTripThreshold;
		this.ThermTripThreshold = this.TMP_THRESHOLD.ThermTripThreshold;
		this.TMP_THRESHOLD_Reserved16 = this.TMP_THRESHOLD.Reserved16;
		this.Reserved16 = this.TMP_THRESHOLD.Reserved16;
		this.TMP_THRESHOLD_TempThreshold2Enab = this.TMP_THRESHOLD.TempThreshold2Enab;
		this.TempThreshold2Enab = this.TMP_THRESHOLD.TempThreshold2Enab;
		this.TMP_THRESHOLD_TempThreshold2 = this.TMP_THRESHOLD.TempThreshold2;
		this.TempThreshold2 = this.TMP_THRESHOLD.TempThreshold2;
		this.TMP_THRESHOLD_TempThreshold1Enab = this.TMP_THRESHOLD.TempThreshold1Enab;
		this.TempThreshold1Enab = this.TMP_THRESHOLD.TempThreshold1Enab;
		this.TMP_THRESHOLD_TempThreshold1 = this.TMP_THRESHOLD.TempThreshold1;
		this.TempThreshold1 = this.TMP_THRESHOLD.TempThreshold1;
      this.TMP_RDSENSOR_FMT1 = ral_reg_ac_fme_TMP_RDSENSOR_FMT1::type_id::create("TMP_RDSENSOR_FMT1",,get_full_name());
      this.TMP_RDSENSOR_FMT1.configure(this, null, "");
      this.TMP_RDSENSOR_FMT1.build();
      this.default_map.add_reg(this.TMP_RDSENSOR_FMT1, `UVM_REG_ADDR_WIDTH'h1010, "RW", 0);
		this.TMP_RDSENSOR_FMT1_Reserved42 = this.TMP_RDSENSOR_FMT1.Reserved42;
		this.TMP_RDSENSOR_FMT1_TempThermalSensor = this.TMP_RDSENSOR_FMT1.TempThermalSensor;
		this.TempThermalSensor = this.TMP_RDSENSOR_FMT1.TempThermalSensor;
		this.TMP_RDSENSOR_FMT1_Reserved25 = this.TMP_RDSENSOR_FMT1.Reserved25;
		this.Reserved25 = this.TMP_RDSENSOR_FMT1.Reserved25;
		this.TMP_RDSENSOR_FMT1_TempValid = this.TMP_RDSENSOR_FMT1.TempValid;
		this.TempValid = this.TMP_RDSENSOR_FMT1.TempValid;
		this.TMP_RDSENSOR_FMT1_NumbTempReads = this.TMP_RDSENSOR_FMT1.NumbTempReads;
		this.NumbTempReads = this.TMP_RDSENSOR_FMT1.NumbTempReads;
		this.TMP_RDSENSOR_FMT1_Reserved7 = this.TMP_RDSENSOR_FMT1.Reserved7;
		this.TMP_RDSENSOR_FMT1_FpgaTemp = this.TMP_RDSENSOR_FMT1.FpgaTemp;
		this.FpgaTemp = this.TMP_RDSENSOR_FMT1.FpgaTemp;
      this.TMP_RDSENSOR_FMT2 = ral_reg_ac_fme_TMP_RDSENSOR_FMT2::type_id::create("TMP_RDSENSOR_FMT2",,get_full_name());
      this.TMP_RDSENSOR_FMT2.configure(this, null, "");
      this.TMP_RDSENSOR_FMT2.build();
      this.default_map.add_reg(this.TMP_RDSENSOR_FMT2, `UVM_REG_ADDR_WIDTH'h1018, "RW", 0);
		this.TMP_RDSENSOR_FMT2_Reserved0 = this.TMP_RDSENSOR_FMT2.Reserved0;
      this.TMP_THRESHOLD_CAPABILITY = ral_reg_ac_fme_TMP_THRESHOLD_CAPABILITY::type_id::create("TMP_THRESHOLD_CAPABILITY",,get_full_name());
      this.TMP_THRESHOLD_CAPABILITY.configure(this, null, "");
      this.TMP_THRESHOLD_CAPABILITY.build();
      this.default_map.add_reg(this.TMP_THRESHOLD_CAPABILITY, `UVM_REG_ADDR_WIDTH'h1020, "RW", 0);
		this.TMP_THRESHOLD_CAPABILITY_Reserved = this.TMP_THRESHOLD_CAPABILITY.Reserved;
		this.TMP_THRESHOLD_CAPABILITY_DisablTmpThrReport = this.TMP_THRESHOLD_CAPABILITY.DisablTmpThrReport;
		this.DisablTmpThrReport = this.TMP_THRESHOLD_CAPABILITY.DisablTmpThrReport;
      this.GLBL_PERF_DFH = ral_reg_ac_fme_GLBL_PERF_DFH::type_id::create("GLBL_PERF_DFH",,get_full_name());
      this.GLBL_PERF_DFH.configure(this, null, "");
      this.GLBL_PERF_DFH.build();
      this.default_map.add_reg(this.GLBL_PERF_DFH, `UVM_REG_ADDR_WIDTH'h3000, "RW", 0);
		this.GLBL_PERF_DFH_FeatureType = this.GLBL_PERF_DFH.FeatureType;
		this.GLBL_PERF_DFH_Reserved = this.GLBL_PERF_DFH.Reserved;
		this.GLBL_PERF_DFH_EOL = this.GLBL_PERF_DFH.EOL;
		this.GLBL_PERF_DFH_NextDfhByteOffset = this.GLBL_PERF_DFH.NextDfhByteOffset;
		this.GLBL_PERF_DFH_FeatureRev = this.GLBL_PERF_DFH.FeatureRev;
		this.GLBL_PERF_DFH_FeatureID = this.GLBL_PERF_DFH.FeatureID;
      this.DUMMY_3008 = ral_reg_ac_fme_DUMMY_3008::type_id::create("DUMMY_3008",,get_full_name());
      this.DUMMY_3008.configure(this, null, "");
      this.DUMMY_3008.build();
      this.default_map.add_reg(this.DUMMY_3008, `UVM_REG_ADDR_WIDTH'h3008, "RO", 0);
		this.DUMMY_3008_Zero = this.DUMMY_3008.Zero;
      this.DUMMY_3010 = ral_reg_ac_fme_DUMMY_3010::type_id::create("DUMMY_3010",,get_full_name());
      this.DUMMY_3010.configure(this, null, "");
      this.DUMMY_3010.build();
      this.default_map.add_reg(this.DUMMY_3010, `UVM_REG_ADDR_WIDTH'h3010, "RO", 0);
		this.DUMMY_3010_Zero = this.DUMMY_3010.Zero;
      this.DUMMY_3018 = ral_reg_ac_fme_DUMMY_3018::type_id::create("DUMMY_3018",,get_full_name());
      this.DUMMY_3018.configure(this, null, "");
      this.DUMMY_3018.build();
      this.default_map.add_reg(this.DUMMY_3018, `UVM_REG_ADDR_WIDTH'h3018, "RO", 0);
		this.DUMMY_3018_Zero = this.DUMMY_3018.Zero;
      this.FPMON_FAB_CTL = ral_reg_ac_fme_FPMON_FAB_CTL::type_id::create("FPMON_FAB_CTL",,get_full_name());
      this.FPMON_FAB_CTL.configure(this, null, "");
      this.FPMON_FAB_CTL.build();
      this.default_map.add_reg(this.FPMON_FAB_CTL, `UVM_REG_ADDR_WIDTH'h3020, "RW", 0);
		this.FPMON_FAB_CTL_Reserved24 = this.FPMON_FAB_CTL.Reserved24;
		this.FPMON_FAB_CTL_PortFilter = this.FPMON_FAB_CTL.PortFilter;
		this.PortFilter = this.FPMON_FAB_CTL.PortFilter;
		this.FPMON_FAB_CTL_Reserved22 = this.FPMON_FAB_CTL.Reserved22;
		this.Reserved22 = this.FPMON_FAB_CTL.Reserved22;
		this.FPMON_FAB_CTL_PortId = this.FPMON_FAB_CTL.PortId;
		this.PortId = this.FPMON_FAB_CTL.PortId;
		this.FPMON_FAB_CTL_FabricEventCode = this.FPMON_FAB_CTL.FabricEventCode;
		this.FPMON_FAB_CTL_Reserved9 = this.FPMON_FAB_CTL.Reserved9;
		this.FPMON_FAB_CTL_FreezeCounters = this.FPMON_FAB_CTL.FreezeCounters;
		this.FreezeCounters = this.FPMON_FAB_CTL.FreezeCounters;
		this.FPMON_FAB_CTL_Reserved0 = this.FPMON_FAB_CTL.Reserved0;
      this.FPMON_FAB_CTR = ral_reg_ac_fme_FPMON_FAB_CTR::type_id::create("FPMON_FAB_CTR",,get_full_name());
      this.FPMON_FAB_CTR.configure(this, null, "");
      this.FPMON_FAB_CTR.build();
      this.default_map.add_reg(this.FPMON_FAB_CTR, `UVM_REG_ADDR_WIDTH'h3028, "RO", 0);
		this.FPMON_FAB_CTR_FabricEventCode = this.FPMON_FAB_CTR.FabricEventCode;
		this.FPMON_FAB_CTR_FabricEventCounter = this.FPMON_FAB_CTR.FabricEventCounter;
		this.FabricEventCounter = this.FPMON_FAB_CTR.FabricEventCounter;
      this.FPMON_CLK_CTR = ral_reg_ac_fme_FPMON_CLK_CTR::type_id::create("FPMON_CLK_CTR",,get_full_name());
      this.FPMON_CLK_CTR.configure(this, null, "");
      this.FPMON_CLK_CTR.build();
      this.default_map.add_reg(this.FPMON_CLK_CTR, `UVM_REG_ADDR_WIDTH'h3030, "RO", 0);
		this.FPMON_CLK_CTR_ClockCounter = this.FPMON_CLK_CTR.ClockCounter;
		this.ClockCounter = this.FPMON_CLK_CTR.ClockCounter;
      this.GLBL_ERROR_DFH = ral_reg_ac_fme_GLBL_ERROR_DFH::type_id::create("GLBL_ERROR_DFH",,get_full_name());
      this.GLBL_ERROR_DFH.configure(this, null, "");
      this.GLBL_ERROR_DFH.build();
      this.default_map.add_reg(this.GLBL_ERROR_DFH, `UVM_REG_ADDR_WIDTH'h4000, "RW", 0);
		this.GLBL_ERROR_DFH_FeatureType = this.GLBL_ERROR_DFH.FeatureType;
		this.GLBL_ERROR_DFH_Reserved = this.GLBL_ERROR_DFH.Reserved;
		this.GLBL_ERROR_DFH_EOL = this.GLBL_ERROR_DFH.EOL;
		this.GLBL_ERROR_DFH_NextDfhByteOffset = this.GLBL_ERROR_DFH.NextDfhByteOffset;
		this.GLBL_ERROR_DFH_FeatureRevision = this.GLBL_ERROR_DFH.FeatureRevision;
		this.GLBL_ERROR_DFH_FeatureId = this.GLBL_ERROR_DFH.FeatureId;
      this.FME_ERROR0_MASK = ral_reg_ac_fme_FME_ERROR0_MASK::type_id::create("FME_ERROR0_MASK",,get_full_name());
      this.FME_ERROR0_MASK.configure(this, null, "");
      this.FME_ERROR0_MASK.build();
      this.default_map.add_reg(this.FME_ERROR0_MASK, `UVM_REG_ADDR_WIDTH'h4008, "RW", 0);
		this.FME_ERROR0_MASK_Reserved6 = this.FME_ERROR0_MASK.Reserved6;
		this.FME_ERROR0_MASK_ErrorMask5 = this.FME_ERROR0_MASK.ErrorMask5;
		this.FME_ERROR0_MASK_Reserved2 = this.FME_ERROR0_MASK.Reserved2;
		this.FME_ERROR0_MASK_ErrorMask0 = this.FME_ERROR0_MASK.ErrorMask0;
		this.ErrorMask0 = this.FME_ERROR0_MASK.ErrorMask0;
      this.FME_ERROR0 = ral_reg_ac_fme_FME_ERROR0::type_id::create("FME_ERROR0",,get_full_name());
      this.FME_ERROR0.configure(this, null, "");
      this.FME_ERROR0.build();
      this.default_map.add_reg(this.FME_ERROR0, `UVM_REG_ADDR_WIDTH'h4010, "RW", 0);
		this.FME_ERROR0_Reserved6 = this.FME_ERROR0.Reserved6;
		this.FME_ERROR0_AfuAccessModeErr = this.FME_ERROR0.AfuAccessModeErr;
		this.FME_ERROR0_Reserved2 = this.FME_ERROR0.Reserved2;
		this.FME_ERROR0_RemoteSTPParityErr = this.FME_ERROR0.RemoteSTPParityErr;
		this.RemoteSTPParityErr = this.FME_ERROR0.RemoteSTPParityErr;
		this.FME_ERROR0_PartialReconfigFIFOParityErr = this.FME_ERROR0.PartialReconfigFIFOParityErr;
		this.PartialReconfigFIFOParityErr = this.FME_ERROR0.PartialReconfigFIFOParityErr;
      this.PCIE0_ERROR_MASK = ral_reg_ac_fme_PCIE0_ERROR_MASK::type_id::create("PCIE0_ERROR_MASK",,get_full_name());
      this.PCIE0_ERROR_MASK.configure(this, null, "");
      this.PCIE0_ERROR_MASK.build();
      this.default_map.add_reg(this.PCIE0_ERROR_MASK, `UVM_REG_ADDR_WIDTH'h4018, "RW", 0);
		this.PCIE0_ERROR_MASK_Reserved10 = this.PCIE0_ERROR_MASK.Reserved10;
		this.PCIE0_ERROR_MASK_ErrorMask = this.PCIE0_ERROR_MASK.ErrorMask;
		this.ErrorMask = this.PCIE0_ERROR_MASK.ErrorMask;
      this.PCIE0_ERROR = ral_reg_ac_fme_PCIE0_ERROR::type_id::create("PCIE0_ERROR",,get_full_name());
      this.PCIE0_ERROR.configure(this, null, "");
      this.PCIE0_ERROR.build();
      this.default_map.add_reg(this.PCIE0_ERROR, `UVM_REG_ADDR_WIDTH'h4020, "RW", 0);
		this.PCIE0_ERROR_FunctTypeErr = this.PCIE0_ERROR.FunctTypeErr;
		this.FunctTypeErr = this.PCIE0_ERROR.FunctTypeErr;
		this.PCIE0_ERROR_VFNumb = this.PCIE0_ERROR.VFNumb;
		this.VFNumb = this.PCIE0_ERROR.VFNumb;
		this.PCIE0_ERROR_Reserved13 = this.PCIE0_ERROR.Reserved13;
		this.PCIE0_ERROR_FifoOverflowErr = this.PCIE0_ERROR.FifoOverflowErr;
		this.FifoOverflowErr = this.PCIE0_ERROR.FifoOverflowErr;
		this.PCIE0_ERROR_MalformedEopErr = this.PCIE0_ERROR.MalformedEopErr;
		this.MalformedEopErr = this.PCIE0_ERROR.MalformedEopErr;
		this.PCIE0_ERROR_MalformedSopErr = this.PCIE0_ERROR.MalformedSopErr;
		this.MalformedSopErr = this.PCIE0_ERROR.MalformedSopErr;
		this.PCIE0_ERROR_RxPoisonTlpErr = this.PCIE0_ERROR.RxPoisonTlpErr;
		this.RxPoisonTlpErr = this.PCIE0_ERROR.RxPoisonTlpErr;
		this.PCIE0_ERROR_ParityErr = this.PCIE0_ERROR.ParityErr;
		this.ParityErr = this.PCIE0_ERROR.ParityErr;
		this.PCIE0_ERROR_CompTimeOutErr = this.PCIE0_ERROR.CompTimeOutErr;
		this.CompTimeOutErr = this.PCIE0_ERROR.CompTimeOutErr;
		this.PCIE0_ERROR_CompStatErr = this.PCIE0_ERROR.CompStatErr;
		this.CompStatErr = this.PCIE0_ERROR.CompStatErr;
		this.PCIE0_ERROR_CompTagErr = this.PCIE0_ERROR.CompTagErr;
		this.CompTagErr = this.PCIE0_ERROR.CompTagErr;
		this.PCIE0_ERROR_MRLengthErr = this.PCIE0_ERROR.MRLengthErr;
		this.MRLengthErr = this.PCIE0_ERROR.MRLengthErr;
		this.PCIE0_ERROR_MRAddrErr = this.PCIE0_ERROR.MRAddrErr;
		this.MRAddrErr = this.PCIE0_ERROR.MRAddrErr;
		this.PCIE0_ERROR_MWLengthErr = this.PCIE0_ERROR.MWLengthErr;
		this.MWLengthErr = this.PCIE0_ERROR.MWLengthErr;
		this.PCIE0_ERROR_MWAddrErr = this.PCIE0_ERROR.MWAddrErr;
		this.MWAddrErr = this.PCIE0_ERROR.MWAddrErr;
		this.PCIE0_ERROR_FormatTypeErr = this.PCIE0_ERROR.FormatTypeErr;
		this.FormatTypeErr = this.PCIE0_ERROR.FormatTypeErr;
      this.DUMMY_4028 = ral_reg_ac_fme_DUMMY_4028::type_id::create("DUMMY_4028",,get_full_name());
      this.DUMMY_4028.configure(this, null, "");
      this.DUMMY_4028.build();
      this.default_map.add_reg(this.DUMMY_4028, `UVM_REG_ADDR_WIDTH'h4028, "RO", 0);
		this.DUMMY_4028_Zero = this.DUMMY_4028.Zero;
      this.DUMMY_4030 = ral_reg_ac_fme_DUMMY_4030::type_id::create("DUMMY_4030",,get_full_name());
      this.DUMMY_4030.configure(this, null, "");
      this.DUMMY_4030.build();
      this.default_map.add_reg(this.DUMMY_4030, `UVM_REG_ADDR_WIDTH'h4030, "RO", 0);
		this.DUMMY_4030_Zero = this.DUMMY_4030.Zero;
      this.FME_FIRST_ERROR = ral_reg_ac_fme_FME_FIRST_ERROR::type_id::create("FME_FIRST_ERROR",,get_full_name());
      this.FME_FIRST_ERROR.configure(this, null, "");
      this.FME_FIRST_ERROR.build();
      this.default_map.add_reg(this.FME_FIRST_ERROR, `UVM_REG_ADDR_WIDTH'h4038, "RW", 0);
		this.FME_FIRST_ERROR_Reserved = this.FME_FIRST_ERROR.Reserved;
		this.FME_FIRST_ERROR_ErrorRegID = this.FME_FIRST_ERROR.ErrorRegID;
		this.FME_FIRST_ERROR_ErrorRegStatus = this.FME_FIRST_ERROR.ErrorRegStatus;
      this.FME_NEXT_ERROR = ral_reg_ac_fme_FME_NEXT_ERROR::type_id::create("FME_NEXT_ERROR",,get_full_name());
      this.FME_NEXT_ERROR.configure(this, null, "");
      this.FME_NEXT_ERROR.build();
      this.default_map.add_reg(this.FME_NEXT_ERROR, `UVM_REG_ADDR_WIDTH'h4040, "RW", 0);
		this.FME_NEXT_ERROR_Reserved = this.FME_NEXT_ERROR.Reserved;
		this.FME_NEXT_ERROR_ErrorRegID = this.FME_NEXT_ERROR.ErrorRegID;
		this.FME_NEXT_ERROR_ErrorRegStatus = this.FME_NEXT_ERROR.ErrorRegStatus;
      this.RAS_NOFAT_ERROR_MASK = ral_reg_ac_fme_RAS_NOFAT_ERROR_MASK::type_id::create("RAS_NOFAT_ERROR_MASK",,get_full_name());
      this.RAS_NOFAT_ERROR_MASK.configure(this, null, "");
      this.RAS_NOFAT_ERROR_MASK.build();
      this.default_map.add_reg(this.RAS_NOFAT_ERROR_MASK, `UVM_REG_ADDR_WIDTH'h4048, "RW", 0);
		this.RAS_NOFAT_ERROR_MASK_Reserved10 = this.RAS_NOFAT_ERROR_MASK.Reserved10;
		this.RAS_NOFAT_ERROR_MASK_ErrorMask5 = this.RAS_NOFAT_ERROR_MASK.ErrorMask5;
		this.RAS_NOFAT_ERROR_MASK_Reserved4 = this.RAS_NOFAT_ERROR_MASK.Reserved4;
		this.RAS_NOFAT_ERROR_MASK_ErrorMask2 = this.RAS_NOFAT_ERROR_MASK.ErrorMask2;
		this.ErrorMask2 = this.RAS_NOFAT_ERROR_MASK.ErrorMask2;
		this.RAS_NOFAT_ERROR_MASK_Reserved0 = this.RAS_NOFAT_ERROR_MASK.Reserved0;
      this.RAS_NOFAT_ERROR = ral_reg_ac_fme_RAS_NOFAT_ERROR::type_id::create("RAS_NOFAT_ERROR",,get_full_name());
      this.RAS_NOFAT_ERROR.configure(this, null, "");
      this.RAS_NOFAT_ERROR.build();
      this.default_map.add_reg(this.RAS_NOFAT_ERROR, `UVM_REG_ADDR_WIDTH'h4050, "RW", 0);
		this.RAS_NOFAT_ERROR_Reserved7 = this.RAS_NOFAT_ERROR.Reserved7;
		this.RAS_NOFAT_ERROR_InjectedWarningErr = this.RAS_NOFAT_ERROR.InjectedWarningErr;
		this.InjectedWarningErr = this.RAS_NOFAT_ERROR.InjectedWarningErr;
		this.RAS_NOFAT_ERROR_AfuAccessModeErr = this.RAS_NOFAT_ERROR.AfuAccessModeErr;
		this.RAS_NOFAT_ERROR_Reserved4 = this.RAS_NOFAT_ERROR.Reserved4;
		this.RAS_NOFAT_ERROR_PortFatalErr = this.RAS_NOFAT_ERROR.PortFatalErr;
		this.PortFatalErr = this.RAS_NOFAT_ERROR.PortFatalErr;
		this.RAS_NOFAT_ERROR_PcieError = this.RAS_NOFAT_ERROR.PcieError;
		this.PcieError = this.RAS_NOFAT_ERROR.PcieError;
		this.RAS_NOFAT_ERROR_Reserved0 = this.RAS_NOFAT_ERROR.Reserved0;
      this.RAS_CATFAT_ERR_MASK = ral_reg_ac_fme_RAS_CATFAT_ERR_MASK::type_id::create("RAS_CATFAT_ERR_MASK",,get_full_name());
      this.RAS_CATFAT_ERR_MASK.configure(this, null, "");
      this.RAS_CATFAT_ERR_MASK.build();
      this.default_map.add_reg(this.RAS_CATFAT_ERR_MASK, `UVM_REG_ADDR_WIDTH'h4058, "RW", 0);
		this.RAS_CATFAT_ERR_MASK_Reserved12 = this.RAS_CATFAT_ERR_MASK.Reserved12;
		this.RAS_CATFAT_ERR_MASK_ErrorMask11 = this.RAS_CATFAT_ERR_MASK.ErrorMask11;
		this.ErrorMask11 = this.RAS_CATFAT_ERR_MASK.ErrorMask11;
		this.RAS_CATFAT_ERR_MASK_Reserved10 = this.RAS_CATFAT_ERR_MASK.Reserved10;
		this.RAS_CATFAT_ERR_MASK_ErrorMask6 = this.RAS_CATFAT_ERR_MASK.ErrorMask6;
		this.ErrorMask6 = this.RAS_CATFAT_ERR_MASK.ErrorMask6;
		this.RAS_CATFAT_ERR_MASK_Reserved0 = this.RAS_CATFAT_ERR_MASK.Reserved0;
      this.RAS_CATFAT_ERR = ral_reg_ac_fme_RAS_CATFAT_ERR::type_id::create("RAS_CATFAT_ERR",,get_full_name());
      this.RAS_CATFAT_ERR.configure(this, null, "");
      this.RAS_CATFAT_ERR.build();
      this.default_map.add_reg(this.RAS_CATFAT_ERR, `UVM_REG_ADDR_WIDTH'h4060, "RW", 0);
		this.RAS_CATFAT_ERR_Reserved12 = this.RAS_CATFAT_ERR.Reserved12;
		this.RAS_CATFAT_ERR_InjectedCatastErr = this.RAS_CATFAT_ERR.InjectedCatastErr;
		this.InjectedCatastErr = this.RAS_CATFAT_ERR.InjectedCatastErr;
		this.RAS_CATFAT_ERR_Reserved10 = this.RAS_CATFAT_ERR.Reserved10;
		this.RAS_CATFAT_ERR_CrcCatastErr = this.RAS_CATFAT_ERR.CrcCatastErr;
		this.CrcCatastErr = this.RAS_CATFAT_ERR.CrcCatastErr;
		this.RAS_CATFAT_ERR_InjectedFatalErr = this.RAS_CATFAT_ERR.InjectedFatalErr;
		this.InjectedFatalErr = this.RAS_CATFAT_ERR.InjectedFatalErr;
		this.RAS_CATFAT_ERR_PciePoisonErr = this.RAS_CATFAT_ERR.PciePoisonErr;
		this.PciePoisonErr = this.RAS_CATFAT_ERR.PciePoisonErr;
		this.RAS_CATFAT_ERR_FabricFatalErr = this.RAS_CATFAT_ERR.FabricFatalErr;
		this.FabricFatalErr = this.RAS_CATFAT_ERR.FabricFatalErr;
		this.RAS_CATFAT_ERR_Reserved0 = this.RAS_CATFAT_ERR.Reserved0;
      this.RAS_ERROR_INJ = ral_reg_ac_fme_RAS_ERROR_INJ::type_id::create("RAS_ERROR_INJ",,get_full_name());
      this.RAS_ERROR_INJ.configure(this, null, "");
      this.RAS_ERROR_INJ.build();
      this.default_map.add_reg(this.RAS_ERROR_INJ, `UVM_REG_ADDR_WIDTH'h4068, "RW", 0);
		this.RAS_ERROR_INJ_Reserved0 = this.RAS_ERROR_INJ.Reserved0;
		this.RAS_ERROR_INJ_NoFatalError = this.RAS_ERROR_INJ.NoFatalError;
		this.NoFatalError = this.RAS_ERROR_INJ.NoFatalError;
		this.RAS_ERROR_INJ_FatalError = this.RAS_ERROR_INJ.FatalError;
		this.FatalError = this.RAS_ERROR_INJ.FatalError;
		this.RAS_ERROR_INJ_CatastError = this.RAS_ERROR_INJ.CatastError;
		this.CatastError = this.RAS_ERROR_INJ.CatastError;
      this.GLBL_ERROR_CAPABILITY = ral_reg_ac_fme_GLBL_ERROR_CAPABILITY::type_id::create("GLBL_ERROR_CAPABILITY",,get_full_name());
      this.GLBL_ERROR_CAPABILITY.configure(this, null, "");
      this.GLBL_ERROR_CAPABILITY.build();
      this.default_map.add_reg(this.GLBL_ERROR_CAPABILITY, `UVM_REG_ADDR_WIDTH'h4070, "RW", 0);
		this.GLBL_ERROR_CAPABILITY_Reserved13 = this.GLBL_ERROR_CAPABILITY.Reserved13;
		this.GLBL_ERROR_CAPABILITY_InterruptVectorNumber = this.GLBL_ERROR_CAPABILITY.InterruptVectorNumber;
		this.InterruptVectorNumber = this.GLBL_ERROR_CAPABILITY.InterruptVectorNumber;
		this.GLBL_ERROR_CAPABILITY_SupportsInterrupt = this.GLBL_ERROR_CAPABILITY.SupportsInterrupt;
		this.SupportsInterrupt = this.GLBL_ERROR_CAPABILITY.SupportsInterrupt;
      this.FME_PR_DFH = ral_reg_ac_fme_FME_PR_DFH::type_id::create("FME_PR_DFH",,get_full_name());
      this.FME_PR_DFH.configure(this, null, "");
      this.FME_PR_DFH.build();
      this.default_map.add_reg(this.FME_PR_DFH, `UVM_REG_ADDR_WIDTH'h5000, "RW", 0);
		this.FME_PR_DFH_FeatureType = this.FME_PR_DFH.FeatureType;
		this.FME_PR_DFH_Reserved = this.FME_PR_DFH.Reserved;
		this.FME_PR_DFH_EOL = this.FME_PR_DFH.EOL;
		this.FME_PR_DFH_NextDfhByteOffset = this.FME_PR_DFH.NextDfhByteOffset;
		this.FME_PR_DFH_FeatureRevision = this.FME_PR_DFH.FeatureRevision;
		this.FME_PR_DFH_FeatureId = this.FME_PR_DFH.FeatureId;
      this.FME_PR_CTRL = ral_reg_ac_fme_FME_PR_CTRL::type_id::create("FME_PR_CTRL",,get_full_name());
      this.FME_PR_CTRL.configure(this, null, "");
      this.FME_PR_CTRL.build();
      this.default_map.add_reg(this.FME_PR_CTRL, `UVM_REG_ADDR_WIDTH'h5008, "RW", 0);
		this.FME_PR_CTRL_TBD = this.FME_PR_CTRL.TBD;
		this.TBD = this.FME_PR_CTRL.TBD;
		this.FME_PR_CTRL_Reserved15 = this.FME_PR_CTRL.Reserved15;
		this.Reserved15 = this.FME_PR_CTRL.Reserved15;
		this.FME_PR_CTRL_PRKind = this.FME_PR_CTRL.PRKind;
		this.PRKind = this.FME_PR_CTRL.PRKind;
		this.FME_PR_CTRL_PRDataPushComplete = this.FME_PR_CTRL.PRDataPushComplete;
		this.PRDataPushComplete = this.FME_PR_CTRL.PRDataPushComplete;
		this.FME_PR_CTRL_PRStartRequest = this.FME_PR_CTRL.PRStartRequest;
		this.PRStartRequest = this.FME_PR_CTRL.PRStartRequest;
		this.FME_PR_CTRL_Reserved10 = this.FME_PR_CTRL.Reserved10;
		this.FME_PR_CTRL_PRRegionId = this.FME_PR_CTRL.PRRegionId;
		this.PRRegionId = this.FME_PR_CTRL.PRRegionId;
		this.FME_PR_CTRL_Reserved5 = this.FME_PR_CTRL.Reserved5;
		this.Reserved5 = this.FME_PR_CTRL.Reserved5;
		this.FME_PR_CTRL_PRResetAck = this.FME_PR_CTRL.PRResetAck;
		this.PRResetAck = this.FME_PR_CTRL.PRResetAck;
		this.FME_PR_CTRL_Reserved1 = this.FME_PR_CTRL.Reserved1;
		this.Reserved1 = this.FME_PR_CTRL.Reserved1;
		this.FME_PR_CTRL_PRReset = this.FME_PR_CTRL.PRReset;
		this.PRReset = this.FME_PR_CTRL.PRReset;
      this.FME_PR_STATUS = ral_reg_ac_fme_FME_PR_STATUS::type_id::create("FME_PR_STATUS",,get_full_name());
      this.FME_PR_STATUS.configure(this, null, "");
      this.FME_PR_STATUS.build();
      this.default_map.add_reg(this.FME_PR_STATUS, `UVM_REG_ADDR_WIDTH'h5010, "RW", 0);
		this.FME_PR_STATUS_SecurityBlockStatus = this.FME_PR_STATUS.SecurityBlockStatus;
		this.SecurityBlockStatus = this.FME_PR_STATUS.SecurityBlockStatus;
		this.FME_PR_STATUS_Reserved28 = this.FME_PR_STATUS.Reserved28;
		this.FME_PR_STATUS_PRHostStatus = this.FME_PR_STATUS.PRHostStatus;
		this.PRHostStatus = this.FME_PR_STATUS.PRHostStatus;
		this.FME_PR_STATUS_Reserved23 = this.FME_PR_STATUS.Reserved23;
		this.Reserved23 = this.FME_PR_STATUS.Reserved23;
		this.FME_PR_STATUS_AlteraPRCrtlrStatus = this.FME_PR_STATUS.AlteraPRCrtlrStatus;
		this.AlteraPRCrtlrStatus = this.FME_PR_STATUS.AlteraPRCrtlrStatus;
		this.FME_PR_STATUS_Reserved17 = this.FME_PR_STATUS.Reserved17;
		this.Reserved17 = this.FME_PR_STATUS.Reserved17;
		this.FME_PR_STATUS_PRStatus = this.FME_PR_STATUS.PRStatus;
		this.PRStatus = this.FME_PR_STATUS.PRStatus;
		this.FME_PR_STATUS_Reserved9 = this.FME_PR_STATUS.Reserved9;
		this.FME_PR_STATUS_NumbCredits = this.FME_PR_STATUS.NumbCredits;
		this.NumbCredits = this.FME_PR_STATUS.NumbCredits;
      this.FME_PR_DATA = ral_reg_ac_fme_FME_PR_DATA::type_id::create("FME_PR_DATA",,get_full_name());
      this.FME_PR_DATA.configure(this, null, "");
      this.FME_PR_DATA.build();
      this.default_map.add_reg(this.FME_PR_DATA, `UVM_REG_ADDR_WIDTH'h5018, "RW", 0);
		this.FME_PR_DATA_PRData = this.FME_PR_DATA.PRData;
		this.PRData = this.FME_PR_DATA.PRData;
      this.FME_PR_ERROR = ral_reg_ac_fme_FME_PR_ERROR::type_id::create("FME_PR_ERROR",,get_full_name());
      this.FME_PR_ERROR.configure(this, null, "");
      this.FME_PR_ERROR.build();
      this.default_map.add_reg(this.FME_PR_ERROR, `UVM_REG_ADDR_WIDTH'h5020, "RW", 0);
		this.FME_PR_ERROR_Reserved7 = this.FME_PR_ERROR.Reserved7;
		this.FME_PR_ERROR_SecureLoadFailed = this.FME_PR_ERROR.SecureLoadFailed;
		this.SecureLoadFailed = this.FME_PR_ERROR.SecureLoadFailed;
		this.FME_PR_ERROR_HostInitTimeout = this.FME_PR_ERROR.HostInitTimeout;
		this.HostInitTimeout = this.FME_PR_ERROR.HostInitTimeout;
		this.FME_PR_ERROR_HostInitFIFOOverflow = this.FME_PR_ERROR.HostInitFIFOOverflow;
		this.HostInitFIFOOverflow = this.FME_PR_ERROR.HostInitFIFOOverflow;
		this.FME_PR_ERROR_IPInitProtocolError = this.FME_PR_ERROR.IPInitProtocolError;
		this.IPInitProtocolError = this.FME_PR_ERROR.IPInitProtocolError;
		this.FME_PR_ERROR_IPInitIncompatibleBitstream = this.FME_PR_ERROR.IPInitIncompatibleBitstream;
		this.IPInitIncompatibleBitstream = this.FME_PR_ERROR.IPInitIncompatibleBitstream;
		this.FME_PR_ERROR_IPInitCRCError = this.FME_PR_ERROR.IPInitCRCError;
		this.IPInitCRCError = this.FME_PR_ERROR.IPInitCRCError;
		this.FME_PR_ERROR_HostInitOperationError = this.FME_PR_ERROR.HostInitOperationError;
		this.HostInitOperationError = this.FME_PR_ERROR.HostInitOperationError;
      this.DUMMY_5028 = ral_reg_ac_fme_DUMMY_5028::type_id::create("DUMMY_5028",,get_full_name());
      this.DUMMY_5028.configure(this, null, "");
      this.DUMMY_5028.build();
      this.default_map.add_reg(this.DUMMY_5028, `UVM_REG_ADDR_WIDTH'h5028, "RO", 0);
		this.DUMMY_5028_Zero = this.DUMMY_5028.Zero;
      this.DUMMY_5030 = ral_reg_ac_fme_DUMMY_5030::type_id::create("DUMMY_5030",,get_full_name());
      this.DUMMY_5030.configure(this, null, "");
      this.DUMMY_5030.build();
      this.default_map.add_reg(this.DUMMY_5030, `UVM_REG_ADDR_WIDTH'h5030, "RO", 0);
		this.DUMMY_5030_Zero = this.DUMMY_5030.Zero;
      this.DUMMY_5038 = ral_reg_ac_fme_DUMMY_5038::type_id::create("DUMMY_5038",,get_full_name());
      this.DUMMY_5038.configure(this, null, "");
      this.DUMMY_5038.build();
      this.default_map.add_reg(this.DUMMY_5038, `UVM_REG_ADDR_WIDTH'h5038, "RO", 0);
		this.DUMMY_5038_Zero = this.DUMMY_5038.Zero;
      this.DUMMY_5040 = ral_reg_ac_fme_DUMMY_5040::type_id::create("DUMMY_5040",,get_full_name());
      this.DUMMY_5040.configure(this, null, "");
      this.DUMMY_5040.build();
      this.default_map.add_reg(this.DUMMY_5040, `UVM_REG_ADDR_WIDTH'h5040, "RO", 0);
		this.DUMMY_5040_Zero = this.DUMMY_5040.Zero;
      this.DUMMY_5048 = ral_reg_ac_fme_DUMMY_5048::type_id::create("DUMMY_5048",,get_full_name());
      this.DUMMY_5048.configure(this, null, "");
      this.DUMMY_5048.build();
      this.default_map.add_reg(this.DUMMY_5048, `UVM_REG_ADDR_WIDTH'h5048, "RO", 0);
		this.DUMMY_5048_Zero = this.DUMMY_5048.Zero;
      this.DUMMY_5050 = ral_reg_ac_fme_DUMMY_5050::type_id::create("DUMMY_5050",,get_full_name());
      this.DUMMY_5050.configure(this, null, "");
      this.DUMMY_5050.build();
      this.default_map.add_reg(this.DUMMY_5050, `UVM_REG_ADDR_WIDTH'h5050, "RO", 0);
		this.DUMMY_5050_Zero = this.DUMMY_5050.Zero;
      this.DUMMY_5058 = ral_reg_ac_fme_DUMMY_5058::type_id::create("DUMMY_5058",,get_full_name());
      this.DUMMY_5058.configure(this, null, "");
      this.DUMMY_5058.build();
      this.default_map.add_reg(this.DUMMY_5058, `UVM_REG_ADDR_WIDTH'h5058, "RO", 0);
		this.DUMMY_5058_Zero = this.DUMMY_5058.Zero;
      this.DUMMY_5060 = ral_reg_ac_fme_DUMMY_5060::type_id::create("DUMMY_5060",,get_full_name());
      this.DUMMY_5060.configure(this, null, "");
      this.DUMMY_5060.build();
      this.default_map.add_reg(this.DUMMY_5060, `UVM_REG_ADDR_WIDTH'h5060, "RO", 0);
		this.DUMMY_5060_Zero = this.DUMMY_5060.Zero;
      this.DUMMY_5068 = ral_reg_ac_fme_DUMMY_5068::type_id::create("DUMMY_5068",,get_full_name());
      this.DUMMY_5068.configure(this, null, "");
      this.DUMMY_5068.build();
      this.default_map.add_reg(this.DUMMY_5068, `UVM_REG_ADDR_WIDTH'h5068, "RO", 0);
		this.DUMMY_5068_Zero = this.DUMMY_5068.Zero;
      this.DUMMY_5070 = ral_reg_ac_fme_DUMMY_5070::type_id::create("DUMMY_5070",,get_full_name());
      this.DUMMY_5070.configure(this, null, "");
      this.DUMMY_5070.build();
      this.default_map.add_reg(this.DUMMY_5070, `UVM_REG_ADDR_WIDTH'h5070, "RO", 0);
		this.DUMMY_5070_Zero = this.DUMMY_5070.Zero;
      this.DUMMY_5078 = ral_reg_ac_fme_DUMMY_5078::type_id::create("DUMMY_5078",,get_full_name());
      this.DUMMY_5078.configure(this, null, "");
      this.DUMMY_5078.build();
      this.default_map.add_reg(this.DUMMY_5078, `UVM_REG_ADDR_WIDTH'h5078, "RO", 0);
		this.DUMMY_5078_Zero = this.DUMMY_5078.Zero;
      this.DUMMY_5080 = ral_reg_ac_fme_DUMMY_5080::type_id::create("DUMMY_5080",,get_full_name());
      this.DUMMY_5080.configure(this, null, "");
      this.DUMMY_5080.build();
      this.default_map.add_reg(this.DUMMY_5080, `UVM_REG_ADDR_WIDTH'h5080, "RO", 0);
		this.DUMMY_5080_Zero = this.DUMMY_5080.Zero;
      this.DUMMY_5088 = ral_reg_ac_fme_DUMMY_5088::type_id::create("DUMMY_5088",,get_full_name());
      this.DUMMY_5088.configure(this, null, "");
      this.DUMMY_5088.build();
      this.default_map.add_reg(this.DUMMY_5088, `UVM_REG_ADDR_WIDTH'h5088, "RO", 0);
		this.DUMMY_5088_Zero = this.DUMMY_5088.Zero;
      this.DUMMY_5090 = ral_reg_ac_fme_DUMMY_5090::type_id::create("DUMMY_5090",,get_full_name());
      this.DUMMY_5090.configure(this, null, "");
      this.DUMMY_5090.build();
      this.default_map.add_reg(this.DUMMY_5090, `UVM_REG_ADDR_WIDTH'h5090, "RO", 0);
		this.DUMMY_5090_Zero = this.DUMMY_5090.Zero;
      this.DUMMY_5098 = ral_reg_ac_fme_DUMMY_5098::type_id::create("DUMMY_5098",,get_full_name());
      this.DUMMY_5098.configure(this, null, "");
      this.DUMMY_5098.build();
      this.default_map.add_reg(this.DUMMY_5098, `UVM_REG_ADDR_WIDTH'h5098, "RO", 0);
		this.DUMMY_5098_Zero = this.DUMMY_5098.Zero;
      this.DUMMY_50A0 = ral_reg_ac_fme_DUMMY_50A0::type_id::create("DUMMY_50A0",,get_full_name());
      this.DUMMY_50A0.configure(this, null, "");
      this.DUMMY_50A0.build();
      this.default_map.add_reg(this.DUMMY_50A0, `UVM_REG_ADDR_WIDTH'h50A0, "RO", 0);
		this.DUMMY_50A0_Zero = this.DUMMY_50A0.Zero;
      this.FME_PR_INTFC_ID_L = ral_reg_ac_fme_FME_PR_INTFC_ID_L::type_id::create("FME_PR_INTFC_ID_L",,get_full_name());
      this.FME_PR_INTFC_ID_L.configure(this, null, "");
      this.FME_PR_INTFC_ID_L.build();
      this.default_map.add_reg(this.FME_PR_INTFC_ID_L, `UVM_REG_ADDR_WIDTH'h50A8, "RO", 0);
		this.FME_PR_INTFC_ID_L_InterfaceIdL = this.FME_PR_INTFC_ID_L.InterfaceIdL;
		this.InterfaceIdL = this.FME_PR_INTFC_ID_L.InterfaceIdL;
      this.FME_PR_INTFC_ID_H = ral_reg_ac_fme_FME_PR_INTFC_ID_H::type_id::create("FME_PR_INTFC_ID_H",,get_full_name());
      this.FME_PR_INTFC_ID_H.configure(this, null, "");
      this.FME_PR_INTFC_ID_H.build();
      this.default_map.add_reg(this.FME_PR_INTFC_ID_H, `UVM_REG_ADDR_WIDTH'h50B0, "RO", 0);
		this.FME_PR_INTFC_ID_H_InterfaceIdH = this.FME_PR_INTFC_ID_H.InterfaceIdH;
		this.InterfaceIdH = this.FME_PR_INTFC_ID_H.InterfaceIdH;
      this.MSIX_ADDR0 = ral_reg_ac_fme_MSIX_ADDR0::type_id::create("MSIX_ADDR0",,get_full_name());
      this.MSIX_ADDR0.configure(this, null, "");
      this.MSIX_ADDR0.build();
      this.default_map.add_reg(this.MSIX_ADDR0, `UVM_REG_ADDR_WIDTH'h9000, "RW", 0);
		this.MSIX_ADDR0_MsgAddrUpp = this.MSIX_ADDR0.MsgAddrUpp;
		this.MSIX_ADDR0_MsgAddrLow = this.MSIX_ADDR0.MsgAddrLow;
      this.MSIX_CTLDAT0 = ral_reg_ac_fme_MSIX_CTLDAT0::type_id::create("MSIX_CTLDAT0",,get_full_name());
      this.MSIX_CTLDAT0.configure(this, null, "");
      this.MSIX_CTLDAT0.build();
      this.default_map.add_reg(this.MSIX_CTLDAT0, `UVM_REG_ADDR_WIDTH'h9008, "RW", 0);
		this.MSIX_CTLDAT0_MsgControl = this.MSIX_CTLDAT0.MsgControl;
		this.MSIX_CTLDAT0_MsgData = this.MSIX_CTLDAT0.MsgData;
      this.MSIX_ADDR1 = ral_reg_ac_fme_MSIX_ADDR1::type_id::create("MSIX_ADDR1",,get_full_name());
      this.MSIX_ADDR1.configure(this, null, "");
      this.MSIX_ADDR1.build();
      this.default_map.add_reg(this.MSIX_ADDR1, `UVM_REG_ADDR_WIDTH'h9010, "RW", 0);
		this.MSIX_ADDR1_MsgAddrUpp = this.MSIX_ADDR1.MsgAddrUpp;
		this.MSIX_ADDR1_MsgAddrLow = this.MSIX_ADDR1.MsgAddrLow;
      this.MSIX_CTLDAT1 = ral_reg_ac_fme_MSIX_CTLDAT1::type_id::create("MSIX_CTLDAT1",,get_full_name());
      this.MSIX_CTLDAT1.configure(this, null, "");
      this.MSIX_CTLDAT1.build();
      this.default_map.add_reg(this.MSIX_CTLDAT1, `UVM_REG_ADDR_WIDTH'h9018, "RW", 0);
		this.MSIX_CTLDAT1_MsgControl = this.MSIX_CTLDAT1.MsgControl;
		this.MSIX_CTLDAT1_MsgData = this.MSIX_CTLDAT1.MsgData;
      this.MSIX_ADDR2 = ral_reg_ac_fme_MSIX_ADDR2::type_id::create("MSIX_ADDR2",,get_full_name());
      this.MSIX_ADDR2.configure(this, null, "");
      this.MSIX_ADDR2.build();
      this.default_map.add_reg(this.MSIX_ADDR2, `UVM_REG_ADDR_WIDTH'h9020, "RW", 0);
		this.MSIX_ADDR2_MsgAddrUpp = this.MSIX_ADDR2.MsgAddrUpp;
		this.MSIX_ADDR2_MsgAddrLow = this.MSIX_ADDR2.MsgAddrLow;
      this.MSIX_CTLDAT2 = ral_reg_ac_fme_MSIX_CTLDAT2::type_id::create("MSIX_CTLDAT2",,get_full_name());
      this.MSIX_CTLDAT2.configure(this, null, "");
      this.MSIX_CTLDAT2.build();
      this.default_map.add_reg(this.MSIX_CTLDAT2, `UVM_REG_ADDR_WIDTH'h9028, "RW", 0);
		this.MSIX_CTLDAT2_MsgControl = this.MSIX_CTLDAT2.MsgControl;
		this.MSIX_CTLDAT2_MsgData = this.MSIX_CTLDAT2.MsgData;
      this.MSIX_ADDR3 = ral_reg_ac_fme_MSIX_ADDR3::type_id::create("MSIX_ADDR3",,get_full_name());
      this.MSIX_ADDR3.configure(this, null, "");
      this.MSIX_ADDR3.build();
      this.default_map.add_reg(this.MSIX_ADDR3, `UVM_REG_ADDR_WIDTH'h9030, "RW", 0);
		this.MSIX_ADDR3_MsgAddrUpp = this.MSIX_ADDR3.MsgAddrUpp;
		this.MSIX_ADDR3_MsgAddrLow = this.MSIX_ADDR3.MsgAddrLow;
      this.MSIX_CTLDAT3 = ral_reg_ac_fme_MSIX_CTLDAT3::type_id::create("MSIX_CTLDAT3",,get_full_name());
      this.MSIX_CTLDAT3.configure(this, null, "");
      this.MSIX_CTLDAT3.build();
      this.default_map.add_reg(this.MSIX_CTLDAT3, `UVM_REG_ADDR_WIDTH'h9038, "RW", 0);
		this.MSIX_CTLDAT3_MsgControl = this.MSIX_CTLDAT3.MsgControl;
		this.MSIX_CTLDAT3_MsgData = this.MSIX_CTLDAT3.MsgData;
      this.MSIX_ADDR4 = ral_reg_ac_fme_MSIX_ADDR4::type_id::create("MSIX_ADDR4",,get_full_name());
      this.MSIX_ADDR4.configure(this, null, "");
      this.MSIX_ADDR4.build();
      this.default_map.add_reg(this.MSIX_ADDR4, `UVM_REG_ADDR_WIDTH'h9040, "RW", 0);
		this.MSIX_ADDR4_MsgAddrUpp = this.MSIX_ADDR4.MsgAddrUpp;
		this.MSIX_ADDR4_MsgAddrLow = this.MSIX_ADDR4.MsgAddrLow;
      this.MSIX_CTLDAT4 = ral_reg_ac_fme_MSIX_CTLDAT4::type_id::create("MSIX_CTLDAT4",,get_full_name());
      this.MSIX_CTLDAT4.configure(this, null, "");
      this.MSIX_CTLDAT4.build();
      this.default_map.add_reg(this.MSIX_CTLDAT4, `UVM_REG_ADDR_WIDTH'h9048, "RW", 0);
		this.MSIX_CTLDAT4_MsgControl = this.MSIX_CTLDAT4.MsgControl;
		this.MSIX_CTLDAT4_MsgData = this.MSIX_CTLDAT4.MsgData;
      this.MSIX_ADDR5 = ral_reg_ac_fme_MSIX_ADDR5::type_id::create("MSIX_ADDR5",,get_full_name());
      this.MSIX_ADDR5.configure(this, null, "");
      this.MSIX_ADDR5.build();
      this.default_map.add_reg(this.MSIX_ADDR5, `UVM_REG_ADDR_WIDTH'h9050, "RW", 0);
		this.MSIX_ADDR5_MsgAddrUpp = this.MSIX_ADDR5.MsgAddrUpp;
		this.MSIX_ADDR5_MsgAddrLow = this.MSIX_ADDR5.MsgAddrLow;
      this.MSIX_CTLDAT5 = ral_reg_ac_fme_MSIX_CTLDAT5::type_id::create("MSIX_CTLDAT5",,get_full_name());
      this.MSIX_CTLDAT5.configure(this, null, "");
      this.MSIX_CTLDAT5.build();
      this.default_map.add_reg(this.MSIX_CTLDAT5, `UVM_REG_ADDR_WIDTH'h9058, "RW", 0);
		this.MSIX_CTLDAT5_MsgControl = this.MSIX_CTLDAT5.MsgControl;
		this.MSIX_CTLDAT5_MsgData = this.MSIX_CTLDAT5.MsgData;
      this.MSIX_ADDR6 = ral_reg_ac_fme_MSIX_ADDR6::type_id::create("MSIX_ADDR6",,get_full_name());
      this.MSIX_ADDR6.configure(this, null, "");
      this.MSIX_ADDR6.build();
      this.default_map.add_reg(this.MSIX_ADDR6, `UVM_REG_ADDR_WIDTH'h9060, "RW", 0);
		this.MSIX_ADDR6_MsgAddrUpp = this.MSIX_ADDR6.MsgAddrUpp;
		this.MSIX_ADDR6_MsgAddrLow = this.MSIX_ADDR6.MsgAddrLow;
      this.MSIX_CTLDAT6 = ral_reg_ac_fme_MSIX_CTLDAT6::type_id::create("MSIX_CTLDAT6",,get_full_name());
      this.MSIX_CTLDAT6.configure(this, null, "");
      this.MSIX_CTLDAT6.build();
      this.default_map.add_reg(this.MSIX_CTLDAT6, `UVM_REG_ADDR_WIDTH'h9068, "RW", 0);
		this.MSIX_CTLDAT6_MsgControl = this.MSIX_CTLDAT6.MsgControl;
		this.MSIX_CTLDAT6_MsgData = this.MSIX_CTLDAT6.MsgData;
      this.MSIX_ADDR7 = ral_reg_ac_fme_MSIX_ADDR7::type_id::create("MSIX_ADDR7",,get_full_name());
      this.MSIX_ADDR7.configure(this, null, "");
      this.MSIX_ADDR7.build();
      this.default_map.add_reg(this.MSIX_ADDR7, `UVM_REG_ADDR_WIDTH'h9070, "RW", 0);
		this.MSIX_ADDR7_MsgAddrUpp = this.MSIX_ADDR7.MsgAddrUpp;
		this.MSIX_ADDR7_MsgAddrLow = this.MSIX_ADDR7.MsgAddrLow;
      this.MSIX_CTLDAT7 = ral_reg_ac_fme_MSIX_CTLDAT7::type_id::create("MSIX_CTLDAT7",,get_full_name());
      this.MSIX_CTLDAT7.configure(this, null, "");
      this.MSIX_CTLDAT7.build();
      this.default_map.add_reg(this.MSIX_CTLDAT7, `UVM_REG_ADDR_WIDTH'h9078, "RW", 0);
		this.MSIX_CTLDAT7_MsgControl = this.MSIX_CTLDAT7.MsgControl;
		this.MSIX_CTLDAT7_MsgData = this.MSIX_CTLDAT7.MsgData;
      this.MSIX_PBA = ral_reg_ac_fme_MSIX_PBA::type_id::create("MSIX_PBA",,get_full_name());
      this.MSIX_PBA.configure(this, null, "");
      this.MSIX_PBA.build();
      this.default_map.add_reg(this.MSIX_PBA, `UVM_REG_ADDR_WIDTH'hA000, "RW", 0);
		this.MSIX_PBA_Reserved7 = this.MSIX_PBA.Reserved7;
		this.MSIX_PBA_MsixPba = this.MSIX_PBA.MsixPba;
		this.MsixPba = this.MSIX_PBA.MsixPba;
      this.MSIX_COUNT_CSR = ral_reg_ac_fme_MSIX_COUNT_CSR::type_id::create("MSIX_COUNT_CSR",,get_full_name());
      this.MSIX_COUNT_CSR.configure(this, null, "");
      this.MSIX_COUNT_CSR.build();
      this.default_map.add_reg(this.MSIX_COUNT_CSR, `UVM_REG_ADDR_WIDTH'hA008, "RW", 0);
		this.MSIX_COUNT_CSR_Reserved32 = this.MSIX_COUNT_CSR.Reserved32;
		this.Reserved32 = this.MSIX_COUNT_CSR.Reserved32;
		this.MSIX_COUNT_CSR_Afu2SyncFifoMsixCount = this.MSIX_COUNT_CSR.Afu2SyncFifoMsixCount;
		this.Afu2SyncFifoMsixCount = this.MSIX_COUNT_CSR.Afu2SyncFifoMsixCount;
		this.MSIX_COUNT_CSR_SyncFifo2MsixCount = this.MSIX_COUNT_CSR.SyncFifo2MsixCount;
		this.SyncFifo2MsixCount = this.MSIX_COUNT_CSR.SyncFifo2MsixCount;
		this.MSIX_COUNT_CSR_Msix2CdcMsixCount = this.MSIX_COUNT_CSR.Msix2CdcMsixCount;
		this.Msix2CdcMsixCount = this.MSIX_COUNT_CSR.Msix2CdcMsixCount;
		this.MSIX_COUNT_CSR_Cdc2AvlMsixCount = this.MSIX_COUNT_CSR.Cdc2AvlMsixCount;
		this.Cdc2AvlMsixCount = this.MSIX_COUNT_CSR.Cdc2AvlMsixCount;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_fme)

endclass : ral_block_ac_fme



`endif
