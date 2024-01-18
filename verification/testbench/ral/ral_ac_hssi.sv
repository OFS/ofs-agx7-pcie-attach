// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_HSSI
`define RAL_AC_HSSI

import uvm_pkg::*;

class ral_reg_ac_hssi_HSSI_DFH_L extends uvm_reg;
	uvm_reg_field NextDfhOffset_L;
	uvm_reg_field FeatureRevision;
	uvm_reg_field FeatureId;

	function new(string name = "ac_hssi_HSSI_DFH_L");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.NextDfhOffset_L = uvm_reg_field::type_id::create("NextDfhOffset_L",,get_full_name());
      this.NextDfhOffset_L.configure(this, 16, 16, "RO", 0, 16'h1000, 1, 0, 1);
      this.FeatureRevision = uvm_reg_field::type_id::create("FeatureRevision",,get_full_name());
      `ifdef FTILE_SIM
      this.FeatureRevision.configure(this, 4, 12, "RO", 0, 4'h3, 1, 0, 0);
      `else
      this.FeatureRevision.configure(this, 4, 12, "RO", 0, 4'h2, 1, 0, 0);
      `endif
      this.FeatureId = uvm_reg_field::type_id::create("FeatureId",,get_full_name());
      this.FeatureId.configure(this, 12, 0, "RO", 0, 12'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_DFH_L)

endclass : ral_reg_ac_hssi_HSSI_DFH_L


class ral_reg_ac_hssi_HSSI_DFH_H extends uvm_reg;
	uvm_reg_field FeatureType;
	uvm_reg_field DfhVersion;
	uvm_reg_field DfhMinorVersion;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset_H;

	function new(string name = "ac_hssi_HSSI_DFH_H");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 28, "RO", 0, 4'h3, 1, 0, 0);
      this.DfhVersion = uvm_reg_field::type_id::create("DfhVersion",,get_full_name());
      this.DfhVersion.configure(this, 8, 20, "RO", 0, 8'h0, 1, 0, 0);
      this.DfhMinorVersion = uvm_reg_field::type_id::create("DfhMinorVersion",,get_full_name());
      this.DfhMinorVersion.configure(this, 4, 16, "RO", 0, 4'h0, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 7, 9, "WO", 0, 7'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhOffset_H = uvm_reg_field::type_id::create("NextDfhOffset_H",,get_full_name());
      this.NextDfhOffset_H.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_DFH_H)

endclass : ral_reg_ac_hssi_HSSI_DFH_H


class ral_reg_ac_hssi_FEATURE_GUID_L_0 extends uvm_reg;
	uvm_reg_field GUID_bits_31_0;

	function new(string name = "ac_hssi_FEATURE_GUID_L_0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.GUID_bits_31_0 = uvm_reg_field::type_id::create("GUID_bits_31_0",,get_full_name());
      this.GUID_bits_31_0.configure(this, 32, 0, "RO", 0, 32'h18418b9d, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_FEATURE_GUID_L_0)

endclass : ral_reg_ac_hssi_FEATURE_GUID_L_0


class ral_reg_ac_hssi_FEATURE_GUID_L_1 extends uvm_reg;
	uvm_reg_field GUID_bits_63_32;

	function new(string name = "ac_hssi_FEATURE_GUID_L_1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.GUID_bits_63_32 = uvm_reg_field::type_id::create("GUID_bits_63_32",,get_full_name());
      this.GUID_bits_63_32.configure(this, 32, 0, "RO", 0, 32'h99a078ad, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_FEATURE_GUID_L_1)

endclass : ral_reg_ac_hssi_FEATURE_GUID_L_1


class ral_reg_ac_hssi_FEATURE_GUID_H_0 extends uvm_reg;
	uvm_reg_field GUID_bits_95_64;

	function new(string name = "ac_hssi_FEATURE_GUID_H_0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.GUID_bits_95_64 = uvm_reg_field::type_id::create("GUID_bits_95_64",,get_full_name());
      this.GUID_bits_95_64.configure(this, 32, 0, "RO", 0, 32'hd9db4a9b, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_FEATURE_GUID_H_0)

endclass : ral_reg_ac_hssi_FEATURE_GUID_H_0


class ral_reg_ac_hssi_FEATURE_GUID_H_1 extends uvm_reg;
	uvm_reg_field GUID_bits_127_96;

	function new(string name = "ac_hssi_FEATURE_GUID_H_1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.GUID_bits_127_96 = uvm_reg_field::type_id::create("GUID_bits_127_96",,get_full_name());
      this.GUID_bits_127_96.configure(this, 32, 0, "RO", 0, 32'h4118a7cb, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_FEATURE_GUID_H_1)

endclass : ral_reg_ac_hssi_FEATURE_GUID_H_1


class ral_reg_ac_hssi_FEATURE_CSR_ADDR_LO extends uvm_reg;
	uvm_reg_field CSR_Addr_Lo;
	uvm_reg_field CSR_REL;

	function new(string name = "ac_hssi_FEATURE_CSR_ADDR_LO");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CSR_Addr_Lo = uvm_reg_field::type_id::create("CSR_Addr_Lo",,get_full_name());
      this.CSR_Addr_Lo.configure(this, 31, 1, "RO", 0, 31'h60, 1, 0, 0);
      this.CSR_REL = uvm_reg_field::type_id::create("CSR_REL",,get_full_name());
      this.CSR_REL.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_FEATURE_CSR_ADDR_LO)

endclass : ral_reg_ac_hssi_FEATURE_CSR_ADDR_LO


class ral_reg_ac_hssi_FEATURE_CSR_ADDR_HI extends uvm_reg;
	uvm_reg_field CSR_Addr_Hi;

	function new(string name = "ac_hssi_FEATURE_CSR_ADDR_HI");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CSR_Addr_Hi = uvm_reg_field::type_id::create("CSR_Addr_Hi",,get_full_name());
      this.CSR_Addr_Hi.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_FEATURE_CSR_ADDR_HI)

endclass : ral_reg_ac_hssi_FEATURE_CSR_ADDR_HI


class ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_LO extends uvm_reg;
	uvm_reg_field HAS_PARAMS;
	uvm_reg_field Grouping_ID;
	uvm_reg_field Instance_ID;

	function new(string name = "ac_hssi_FEATURE_CSR_SIZE_GROUP_LO");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.HAS_PARAMS = uvm_reg_field::type_id::create("HAS_PARAMS",,get_full_name());
      this.HAS_PARAMS.configure(this, 1, 31, "RO", 0, 1'h0, 1, 0, 0);
      this.Grouping_ID = uvm_reg_field::type_id::create("Grouping_ID",,get_full_name());
      this.Grouping_ID.configure(this, 15, 16, "RO", 0, 15'h0, 1, 0, 0);
      this.Instance_ID = uvm_reg_field::type_id::create("Instance_ID",,get_full_name());
      this.Instance_ID.configure(this, 16, 0, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_LO)

endclass : ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_LO


class ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_HI extends uvm_reg;
	uvm_reg_field CSR_SIZE;

	function new(string name = "ac_hssi_FEATURE_CSR_SIZE_GROUP_HI");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CSR_SIZE = uvm_reg_field::type_id::create("CSR_SIZE",,get_full_name());
      this.CSR_SIZE.configure(this, 32, 0, "RO", 0, 32'h44, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_HI)

endclass : ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_HI


class ral_reg_ac_hssi_HSSI_VERSION extends uvm_reg;
	uvm_reg_field Major;
	uvm_reg_field Minor;
	rand uvm_reg_field Reserved;

	function new(string name = "ac_hssi_HSSI_VERSION");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Major = uvm_reg_field::type_id::create("Major",,get_full_name());
      `ifdef FTILE_SIM
      this.Major.configure(this, 16, 16, "RO", 0, 16'h2, 1, 0, 1);
      `else
      this.Major.configure(this, 16, 16, "RO", 0, 16'h1, 1, 0, 1);
      `endif
      this.Minor = uvm_reg_field::type_id::create("Minor",,get_full_name());
      this.Minor.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 0, "WO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_VERSION)

endclass : ral_reg_ac_hssi_HSSI_VERSION


class ral_reg_ac_hssi_HSSI_FEATURE extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PortEnable;
	uvm_reg_field NumPorts;
	uvm_reg_field ErrorMask;

	function new(string name = "ac_hssi_HSSI_FEATURE");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 10, 22, "WO", 0, 10'h0, 1, 0, 0);
      this.PortEnable = uvm_reg_field::type_id::create("PortEnable",,get_full_name());
      this.PortEnable.configure(this, 16, 6, "RO", 0, 16'hff, 1, 0, 0);
      this.NumPorts = uvm_reg_field::type_id::create("NumPorts",,get_full_name());
      this.NumPorts.configure(this, 5, 1, "RO", 0, 5'h8, 1, 0, 0);
      this.ErrorMask = uvm_reg_field::type_id::create("ErrorMask",,get_full_name());
      this.ErrorMask.configure(this, 1, 0, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_FEATURE)

endclass : ral_reg_ac_hssi_HSSI_FEATURE


class ral_reg_ac_hssi_HSSI_PORT_0_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_0_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_0_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_0_ATTR


class ral_reg_ac_hssi_HSSI_PORT_1_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_1_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_1_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_1_ATTR


class ral_reg_ac_hssi_HSSI_PORT_2_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_2_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_2_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_2_ATTR


class ral_reg_ac_hssi_HSSI_PORT_3_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_3_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_3_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_3_ATTR


class ral_reg_ac_hssi_HSSI_PORT_4_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_4_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_4_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_4_ATTR


class ral_reg_ac_hssi_HSSI_PORT_5_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_5_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_5_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_5_ATTR


class ral_reg_ac_hssi_HSSI_PORT_6_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_6_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_6_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_6_ATTR


class ral_reg_ac_hssi_HSSI_PORT_7_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_7_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_7_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_7_ATTR

`ifdef ENABLE_8_TO_15_PORTS

class ral_reg_ac_hssi_HSSI_PORT_8_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_8_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_8_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_8_ATTR


class ral_reg_ac_hssi_HSSI_PORT_9_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_9_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_9_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_9_ATTR


class ral_reg_ac_hssi_HSSI_PORT_10_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_10_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_10_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_10_ATTR


class ral_reg_ac_hssi_HSSI_PORT_11_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_11_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_11_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_11_ATTR


class ral_reg_ac_hssi_HSSI_PORT_12_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_12_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_12_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_12_ATTR

class ral_reg_ac_hssi_HSSI_PORT_13_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_13_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_13_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_13_ATTR


class ral_reg_ac_hssi_HSSI_PORT_14_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_14_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_14_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_14_ATTR


class ral_reg_ac_hssi_HSSI_PORT_15_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PtpEnable;
	uvm_reg_field AnltEnable;
	uvm_reg_field RsfecEnable;
	uvm_reg_field SubProfile;
	uvm_reg_field DRP;
	uvm_reg_field LowSpeedParam;
	uvm_reg_field DataBusWidth;
	uvm_reg_field ReadyLatency;
	uvm_reg_field Profile;

	function new(string name = "ac_hssi_HSSI_PORT_15_ATTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.PtpEnable = uvm_reg_field::type_id::create("PtpEnable",,get_full_name());
      this.PtpEnable.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.AnltEnable = uvm_reg_field::type_id::create("AnltEnable",,get_full_name());
      this.AnltEnable.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.RsfecEnable = uvm_reg_field::type_id::create("RsfecEnable",,get_full_name());
      this.RsfecEnable.configure(this, 1, 21, "RO", 0, 1'h1, 1, 0, 0);
      this.SubProfile = uvm_reg_field::type_id::create("SubProfile",,get_full_name());
      this.SubProfile.configure(this, 5, 16, "RO", 0, 5'h4, 1, 0, 0);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_15_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_15_ATTR

`endif

class ral_reg_ac_hssi_HSSI_CMD_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field REG_OFFSET;
	uvm_reg_field Error;
	uvm_reg_field Busy;
	rand uvm_reg_field Ack;
	rand uvm_reg_field Write;
	rand uvm_reg_field Read;

	function new(string name = "ac_hssi_HSSI_CMD_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 25, 7, "WO", 0, 25'h0, 1, 0, 0);
      this.REG_OFFSET = uvm_reg_field::type_id::create("REG_OFFSET",,get_full_name());
      this.REG_OFFSET.configure(this, 2, 5, "RW", 0, 2'h0, 1, 0, 0);
      this.Error = uvm_reg_field::type_id::create("Error",,get_full_name());
      this.Error.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.Busy = uvm_reg_field::type_id::create("Busy",,get_full_name());
      this.Busy.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.Ack = uvm_reg_field::type_id::create("Ack",,get_full_name());
      this.Ack.configure(this, 1, 2, "RW", 0, 1'h1, 1, 0, 0);
      this.Write = uvm_reg_field::type_id::create("Write",,get_full_name());
      this.Write.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.Read = uvm_reg_field::type_id::create("Read",,get_full_name());
      this.Read.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_CMD_STATUS)

endclass : ral_reg_ac_hssi_HSSI_CMD_STATUS


class ral_reg_ac_hssi_HSSI_CTRL_ADDR extends uvm_reg;
	rand uvm_reg_field HighAddress;
	rand uvm_reg_field ChannelAddress;
	rand uvm_reg_field PortAddress;
	rand uvm_reg_field SAL;

	function new(string name = "ac_hssi_HSSI_CTRL_ADDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.HighAddress = uvm_reg_field::type_id::create("HighAddress",,get_full_name());
      this.HighAddress.configure(this, 16, 16, "RW", 0, 16'h0, 1, 0, 1);
      this.ChannelAddress = uvm_reg_field::type_id::create("ChannelAddress",,get_full_name());
      this.ChannelAddress.configure(this, 4, 12, "RW", 0, 4'h0, 1, 0, 0);
      this.PortAddress = uvm_reg_field::type_id::create("PortAddress",,get_full_name());
      this.PortAddress.configure(this, 4, 8, "RW", 0, 4'h0, 1, 0, 0);
      this.SAL = uvm_reg_field::type_id::create("SAL",,get_full_name());
      this.SAL.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_CTRL_ADDR)

endclass : ral_reg_ac_hssi_HSSI_CTRL_ADDR


class ral_reg_ac_hssi_HSSI_READ_DATA extends uvm_reg;
	rand uvm_reg_field ReadData;

	function new(string name = "ac_hssi_HSSI_READ_DATA");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ReadData = uvm_reg_field::type_id::create("ReadData",,get_full_name());
      this.ReadData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_READ_DATA)

endclass : ral_reg_ac_hssi_HSSI_READ_DATA


class ral_reg_ac_hssi_HSSI_WRITE_DATA extends uvm_reg;
	rand uvm_reg_field WriteData;

	function new(string name = "ac_hssi_HSSI_WRITE_DATA");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.WriteData = uvm_reg_field::type_id::create("WriteData",,get_full_name());
      this.WriteData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_WRITE_DATA)

endclass : ral_reg_ac_hssi_HSSI_WRITE_DATA


class ral_reg_ac_hssi_HSSI_TX_LATENCY extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field TxLatency;

	function new(string name = "ac_hssi_HSSI_TX_LATENCY");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.TxLatency = uvm_reg_field::type_id::create("TxLatency",,get_full_name());
      this.TxLatency.configure(this, 4, 1, "RO", 0, 4'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_TX_LATENCY)

endclass : ral_reg_ac_hssi_HSSI_TX_LATENCY


class ral_reg_ac_hssi_HSSI_RX_LATENCY extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field TxLatency;

	function new(string name = "ac_hssi_HSSI_RX_LATENCY");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.TxLatency = uvm_reg_field::type_id::create("TxLatency",,get_full_name());
      this.TxLatency.configure(this, 4, 1, "RO", 0, 4'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_RX_LATENCY)

endclass : ral_reg_ac_hssi_HSSI_RX_LATENCY


class ral_reg_ac_hssi_HSSI_PORT_0_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_0_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_0_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_0_STATUS


class ral_reg_ac_hssi_HSSI_PORT_1_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_1_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_1_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_1_STATUS


class ral_reg_ac_hssi_HSSI_PORT_2_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_2_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_2_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_2_STATUS


class ral_reg_ac_hssi_HSSI_PORT_3_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_3_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_3_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_3_STATUS


class ral_reg_ac_hssi_HSSI_PORT_4_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_4_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_4_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_4_STATUS


class ral_reg_ac_hssi_HSSI_PORT_5_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_5_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_5_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_5_STATUS


class ral_reg_ac_hssi_HSSI_PORT_6_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_6_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_6_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_6_STATUS


class ral_reg_ac_hssi_HSSI_PORT_7_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_7_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_7_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_7_STATUS

`ifdef ENABLE_8_TO_15_PORTS

class ral_reg_ac_hssi_HSSI_PORT_8_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_8_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_8_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_8_STATUS


class ral_reg_ac_hssi_HSSI_PORT_9_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_9_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_9_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_9_STATUS


class ral_reg_ac_hssi_HSSI_PORT_10_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_10_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_10_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_10_STATUS


class ral_reg_ac_hssi_HSSI_PORT_11_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_11_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_11_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_11_STATUS


class ral_reg_ac_hssi_HSSI_PORT_12_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_12_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_12_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_12_STATUS


class ral_reg_ac_hssi_HSSI_PORT_13_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_13_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_13_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_13_STATUS


class ral_reg_ac_hssi_HSSI_PORT_14_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_14_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_14_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_14_STATUS


class ral_reg_ac_hssi_HSSI_PORT_15_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field EHIP_TX_PLL_LOCKED;
	uvm_reg_field TX_PLL_LOCKED;
	uvm_reg_field RX_PCS_READY;
	uvm_reg_field TX_LANES_STABLE;
	uvm_reg_field CAL_ERROR;
	uvm_reg_field LOAD_ERROR;
	uvm_reg_field ETH_MODE;
	uvm_reg_field ENA_10;
	uvm_reg_field SET_1000;
	uvm_reg_field SET_10;
	uvm_reg_field MAC_ECC_STATUS;
	uvm_reg_field PCS_ECC_STATUS;
	uvm_reg_field RemoteFaultDsiable;
	uvm_reg_field ForceRemoteFault;
	uvm_reg_field RemoteFaultStatus;
	uvm_reg_field LocalFaultStatus;
	uvm_reg_field UndirectionalEn;
	uvm_reg_field LinkFaultGenEn;
	uvm_reg_field RxBlockLock;
	uvm_reg_field RxAMLock;
	uvm_reg_field CDRLock;
	uvm_reg_field RxHiBER;
	uvm_reg_field EHIPReady;

	function new(string name = "ac_hssi_HSSI_PORT_15_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.EHIP_TX_PLL_LOCKED = uvm_reg_field::type_id::create("EHIP_TX_PLL_LOCKED",,get_full_name());
      this.EHIP_TX_PLL_LOCKED.configure(this, 2, 24, "RO", 0, 2'h0, 1, 0, 0);
      this.TX_PLL_LOCKED = uvm_reg_field::type_id::create("TX_PLL_LOCKED",,get_full_name());
      this.TX_PLL_LOCKED.configure(this, 1, 23, "RO", 0, 1'h0, 1, 0, 0);
      this.RX_PCS_READY = uvm_reg_field::type_id::create("RX_PCS_READY",,get_full_name());
      this.RX_PCS_READY.configure(this, 1, 22, "RO", 0, 1'h0, 1, 0, 0);
      this.TX_LANES_STABLE = uvm_reg_field::type_id::create("TX_LANES_STABLE",,get_full_name());
      this.TX_LANES_STABLE.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
      this.CAL_ERROR = uvm_reg_field::type_id::create("CAL_ERROR",,get_full_name());
      this.CAL_ERROR.configure(this, 1, 20, "RO", 0, 1'h0, 1, 0, 0);
      this.LOAD_ERROR = uvm_reg_field::type_id::create("LOAD_ERROR",,get_full_name());
      this.LOAD_ERROR.configure(this, 1, 19, "RO", 0, 1'h0, 1, 0, 0);
      this.ETH_MODE = uvm_reg_field::type_id::create("ETH_MODE",,get_full_name());
      this.ETH_MODE.configure(this, 1, 18, "RO", 0, 1'h0, 1, 0, 0);
      this.ENA_10 = uvm_reg_field::type_id::create("ENA_10",,get_full_name());
      this.ENA_10.configure(this, 1, 17, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_1000 = uvm_reg_field::type_id::create("SET_1000",,get_full_name());
      this.SET_1000.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.SET_10 = uvm_reg_field::type_id::create("SET_10",,get_full_name());
      this.SET_10.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.MAC_ECC_STATUS = uvm_reg_field::type_id::create("MAC_ECC_STATUS",,get_full_name());
      this.MAC_ECC_STATUS.configure(this, 2, 13, "RO", 0, 2'h0, 1, 0, 0);
      this.PCS_ECC_STATUS = uvm_reg_field::type_id::create("PCS_ECC_STATUS",,get_full_name());
      this.PCS_ECC_STATUS.configure(this, 2, 11, "RO", 0, 2'h0, 1, 0, 0);
      this.RemoteFaultDsiable = uvm_reg_field::type_id::create("RemoteFaultDsiable",,get_full_name());
      this.RemoteFaultDsiable.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ForceRemoteFault = uvm_reg_field::type_id::create("ForceRemoteFault",,get_full_name());
      this.ForceRemoteFault.configure(this, 1, 9, "RO", 0, 1'h0, 1, 0, 0);
      this.RemoteFaultStatus = uvm_reg_field::type_id::create("RemoteFaultStatus",,get_full_name());
      this.RemoteFaultStatus.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.LocalFaultStatus = uvm_reg_field::type_id::create("LocalFaultStatus",,get_full_name());
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.UndirectionalEn = uvm_reg_field::type_id::create("UndirectionalEn",,get_full_name());
      this.UndirectionalEn.configure(this, 1, 6, "RO", 0, 1'h0, 1, 0, 0);
      this.LinkFaultGenEn = uvm_reg_field::type_id::create("LinkFaultGenEn",,get_full_name());
      this.LinkFaultGenEn.configure(this, 1, 5, "RO", 0, 1'h0, 1, 0, 0);
      this.RxBlockLock = uvm_reg_field::type_id::create("RxBlockLock",,get_full_name());
      this.RxBlockLock.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.RxAMLock = uvm_reg_field::type_id::create("RxAMLock",,get_full_name());
      this.RxAMLock.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.CDRLock = uvm_reg_field::type_id::create("CDRLock",,get_full_name());
      this.CDRLock.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.RxHiBER = uvm_reg_field::type_id::create("RxHiBER",,get_full_name());
      this.RxHiBER.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.EHIPReady = uvm_reg_field::type_id::create("EHIPReady",,get_full_name());
      this.EHIPReady.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_15_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PORT_15_STATUS
`endif

class ral_reg_ac_hssi_HSSI_TSE_CTRL extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field MagicSleep_N;
	uvm_reg_field MagicWakeUp;

	function new(string name = "ac_hssi_HSSI_TSE_CTRL");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 30, 2, "WO", 0, 30'h0, 1, 0, 1);
      this.MagicSleep_N = uvm_reg_field::type_id::create("MagicSleep_N",,get_full_name());
      this.MagicSleep_N.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.MagicWakeUp = uvm_reg_field::type_id::create("MagicWakeUp",,get_full_name());
      this.MagicWakeUp.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_TSE_CTRL)

endclass : ral_reg_ac_hssi_HSSI_TSE_CTRL


class ral_reg_ac_hssi_HSSI_DBG_CTRL extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field LED_Blinking_Rate;
	rand uvm_reg_field LED_Status_Override_En;
	rand uvm_reg_field Port_N_LED_Status_Override;
	rand uvm_reg_field Override_Port_N_LED_Status;
	rand uvm_reg_field Override_Port_N_LED_Speed;

	function new(string name = "ac_hssi_HSSI_DBG_CTRL");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
      this.LED_Blinking_Rate = uvm_reg_field::type_id::create("LED_Blinking_Rate",,get_full_name());
      this.LED_Blinking_Rate.configure(this, 8, 11, "RW", 0, 8'h31, 1, 0, 0);
      this.LED_Status_Override_En = uvm_reg_field::type_id::create("LED_Status_Override_En",,get_full_name());
      this.LED_Status_Override_En.configure(this, 1, 10, "RW", 0, 1'h0, 1, 0, 0);
      this.Port_N_LED_Status_Override = uvm_reg_field::type_id::create("Port_N_LED_Status_Override",,get_full_name());
      this.Port_N_LED_Status_Override.configure(this, 4, 6, "RW", 0, 4'h0, 1, 0, 0);
      this.Override_Port_N_LED_Status = uvm_reg_field::type_id::create("Override_Port_N_LED_Status",,get_full_name());
      this.Override_Port_N_LED_Status.configure(this, 3, 3, "RW", 0, 3'h0, 1, 0, 0);
      this.Override_Port_N_LED_Speed = uvm_reg_field::type_id::create("Override_Port_N_LED_Speed",,get_full_name());
      this.Override_Port_N_LED_Speed.configure(this, 3, 0, "RW", 0, 3'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_DBG_CTRL)

endclass : ral_reg_ac_hssi_HSSI_DBG_CTRL


class ral_reg_ac_hssi_HSSI_INDV_RST extends uvm_reg;
	rand uvm_reg_field RxReset;
	rand uvm_reg_field TxReset;
	rand uvm_reg_field AxisRxReset;
	rand uvm_reg_field AxisTxReset;

	function new(string name = "ac_hssi_HSSI_INDV_RST");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.RxReset = uvm_reg_field::type_id::create("RxReset",,get_full_name());
      this.RxReset.configure(this, 16, 48, "RW", 0, 16'h0, 1, 0, 1);
      this.TxReset = uvm_reg_field::type_id::create("TxReset",,get_full_name());
      this.TxReset.configure(this, 16, 32, "RW", 0, 16'h0, 1, 0, 1);
      this.AxisRxReset = uvm_reg_field::type_id::create("AxisRxReset",,get_full_name());
      this.AxisRxReset.configure(this, 16, 16, "RW", 0, 16'h0, 1, 0, 1);
      this.AxisTxReset = uvm_reg_field::type_id::create("AxisTxReset",,get_full_name());
      this.AxisTxReset.configure(this, 16, 0, "RW", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_INDV_RST)

endclass : ral_reg_ac_hssi_HSSI_INDV_RST


class ral_reg_ac_hssi_HSSI_INDV_RST_ACK extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field RxResetAck;
	uvm_reg_field TxResetAck;

	function new(string name = "ac_hssi_HSSI_INDV_RST_ACK");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.RxResetAck = uvm_reg_field::type_id::create("RxResetAck",,get_full_name());
      this.RxResetAck.configure(this, 16, 16, "RO", 0, 16'hffff, 1, 0, 1);
      this.TxResetAck = uvm_reg_field::type_id::create("TxResetAck",,get_full_name());
      this.TxResetAck.configure(this, 16, 0, "RO", 0, 16'hffff, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_INDV_RST_ACK)

endclass : ral_reg_ac_hssi_HSSI_INDV_RST_ACK


class ral_reg_ac_hssi_HSSI_COLD_RST extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field ColdResetAck;
	rand uvm_reg_field ColdReset;

	function new(string name = "ac_hssi_HSSI_COLD_RST");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 62, 2, "WO", 0, 62'h000000000, 1, 0, 0);
      this.ColdResetAck = uvm_reg_field::type_id::create("ColdResetAck",,get_full_name());
      this.ColdResetAck.configure(this, 1, 1, "RO", 0, 1'h1, 1, 0, 0);
      this.ColdReset = uvm_reg_field::type_id::create("ColdReset",,get_full_name());
      this.ColdReset.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_COLD_RST)

endclass : ral_reg_ac_hssi_HSSI_COLD_RST


class ral_reg_ac_hssi_HSSI_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field RxPCSReady;
	uvm_reg_field TxLaneStable;
	uvm_reg_field TxPllLocked;

	function new(string name = "ac_hssi_HSSI_STATUS");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 16, 48, "WO", 0, 16'h0, 1, 0, 1);
      this.RxPCSReady = uvm_reg_field::type_id::create("RxPCSReady",,get_full_name());
      this.RxPCSReady.configure(this, 16, 32, "RO", 0, 16'h0, 1, 0, 1);
      this.TxLaneStable = uvm_reg_field::type_id::create("TxLaneStable",,get_full_name());
      this.TxLaneStable.configure(this, 16, 16, "RO", 0, 16'h0, 1, 0, 1);
      this.TxPllLocked = uvm_reg_field::type_id::create("TxPllLocked",,get_full_name());
      this.TxPllLocked.configure(this, 16, 0, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_STATUS)

endclass : ral_reg_ac_hssi_HSSI_STATUS


class ral_reg_ac_hssi_HSSI_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Scartchpad;

	function new(string name = "ac_hssi_HSSI_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scartchpad = uvm_reg_field::type_id::create("Scartchpad",,get_full_name());
      this.Scartchpad.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_SCRATCHPAD)

endclass : ral_reg_ac_hssi_HSSI_SCRATCHPAD


class ral_reg_ac_hssi_HSSI_PTP_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_STATUS");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 56, "WO", 0, 8'h0, 1, 0, 1);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 16, 16, "RO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 16, 0, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_STATUS)

endclass : ral_reg_ac_hssi_HSSI_PTP_STATUS


class ral_block_ac_hssi extends uvm_reg_block;
	rand ral_reg_ac_hssi_HSSI_DFH_L HSSI_DFH_L;
	rand ral_reg_ac_hssi_HSSI_DFH_H HSSI_DFH_H;
	rand ral_reg_ac_hssi_FEATURE_GUID_L_0 FEATURE_GUID_L_0;
	rand ral_reg_ac_hssi_FEATURE_GUID_L_1 FEATURE_GUID_L_1;
	rand ral_reg_ac_hssi_FEATURE_GUID_H_0 FEATURE_GUID_H_0;
	rand ral_reg_ac_hssi_FEATURE_GUID_H_1 FEATURE_GUID_H_1;
	rand ral_reg_ac_hssi_FEATURE_CSR_ADDR_LO FEATURE_CSR_ADDR_LO;
	rand ral_reg_ac_hssi_FEATURE_CSR_ADDR_HI FEATURE_CSR_ADDR_HI;
	rand ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_LO FEATURE_CSR_SIZE_GROUP_LO;
	rand ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_HI FEATURE_CSR_SIZE_GROUP_HI;
	rand ral_reg_ac_hssi_HSSI_VERSION HSSI_VERSION;
	rand ral_reg_ac_hssi_HSSI_FEATURE HSSI_FEATURE;
	rand ral_reg_ac_hssi_HSSI_PORT_0_ATTR HSSI_PORT_0_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_1_ATTR HSSI_PORT_1_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_2_ATTR HSSI_PORT_2_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_3_ATTR HSSI_PORT_3_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_4_ATTR HSSI_PORT_4_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_5_ATTR HSSI_PORT_5_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_6_ATTR HSSI_PORT_6_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_7_ATTR HSSI_PORT_7_ATTR;
        `ifdef ENABLE_8_TO_15_PORTS
	rand ral_reg_ac_hssi_HSSI_PORT_8_ATTR HSSI_PORT_8_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_9_ATTR HSSI_PORT_9_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_10_ATTR HSSI_PORT_10_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_11_ATTR HSSI_PORT_11_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_12_ATTR HSSI_PORT_12_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_13_ATTR HSSI_PORT_13_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_14_ATTR HSSI_PORT_14_ATTR;
	rand ral_reg_ac_hssi_HSSI_PORT_15_ATTR HSSI_PORT_15_ATTR;
        `endif
	rand ral_reg_ac_hssi_HSSI_CMD_STATUS HSSI_CMD_STATUS;
	rand ral_reg_ac_hssi_HSSI_CTRL_ADDR HSSI_CTRL_ADDR;
	rand ral_reg_ac_hssi_HSSI_READ_DATA HSSI_READ_DATA;
	rand ral_reg_ac_hssi_HSSI_WRITE_DATA HSSI_WRITE_DATA;
	rand ral_reg_ac_hssi_HSSI_TX_LATENCY HSSI_TX_LATENCY;
	rand ral_reg_ac_hssi_HSSI_RX_LATENCY HSSI_RX_LATENCY;
	rand ral_reg_ac_hssi_HSSI_PORT_0_STATUS HSSI_PORT_0_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_1_STATUS HSSI_PORT_1_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_2_STATUS HSSI_PORT_2_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_3_STATUS HSSI_PORT_3_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_4_STATUS HSSI_PORT_4_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_5_STATUS HSSI_PORT_5_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_6_STATUS HSSI_PORT_6_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_7_STATUS HSSI_PORT_7_STATUS;
        `ifdef ENABLE_8_TO_15_PORTS
	rand ral_reg_ac_hssi_HSSI_PORT_8_STATUS HSSI_PORT_8_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_9_STATUS HSSI_PORT_9_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_10_STATUS HSSI_PORT_10_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_11_STATUS HSSI_PORT_11_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_12_STATUS HSSI_PORT_12_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_13_STATUS HSSI_PORT_13_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_14_STATUS HSSI_PORT_14_STATUS;
	rand ral_reg_ac_hssi_HSSI_PORT_15_STATUS HSSI_PORT_15_STATUS;
        `endif
	rand ral_reg_ac_hssi_HSSI_TSE_CTRL HSSI_TSE_CTRL;
	rand ral_reg_ac_hssi_HSSI_DBG_CTRL HSSI_DBG_CTRL;
	rand ral_reg_ac_hssi_HSSI_INDV_RST HSSI_INDV_RST;
	rand ral_reg_ac_hssi_HSSI_INDV_RST_ACK HSSI_INDV_RST_ACK;
	rand ral_reg_ac_hssi_HSSI_COLD_RST HSSI_COLD_RST;
	rand ral_reg_ac_hssi_HSSI_STATUS HSSI_STATUS;
	rand ral_reg_ac_hssi_HSSI_SCRATCHPAD HSSI_SCRATCHPAD;
	rand ral_reg_ac_hssi_HSSI_PTP_STATUS HSSI_PTP_STATUS;
	uvm_reg_field HSSI_DFH_L_NextDfhOffset_L;
	uvm_reg_field NextDfhOffset_L;
	uvm_reg_field HSSI_DFH_L_FeatureRevision;
	uvm_reg_field FeatureRevision;
	uvm_reg_field HSSI_DFH_L_FeatureId;
	uvm_reg_field FeatureId;
	uvm_reg_field HSSI_DFH_H_FeatureType;
	uvm_reg_field FeatureType;
	uvm_reg_field HSSI_DFH_H_DfhVersion;
	uvm_reg_field DfhVersion;
	uvm_reg_field HSSI_DFH_H_DfhMinorVersion;
	uvm_reg_field DfhMinorVersion;
	rand uvm_reg_field HSSI_DFH_H_Reserved;
	uvm_reg_field HSSI_DFH_H_EOL;
	uvm_reg_field EOL;
	uvm_reg_field HSSI_DFH_H_NextDfhOffset_H;
	uvm_reg_field NextDfhOffset_H;
	uvm_reg_field FEATURE_GUID_L_0_GUID_bits_31_0;
	uvm_reg_field GUID_bits_31_0;
	uvm_reg_field FEATURE_GUID_L_1_GUID_bits_63_32;
	uvm_reg_field GUID_bits_63_32;
	uvm_reg_field FEATURE_GUID_H_0_GUID_bits_95_64;
	uvm_reg_field GUID_bits_95_64;
	uvm_reg_field FEATURE_GUID_H_1_GUID_bits_127_96;
	uvm_reg_field GUID_bits_127_96;
	uvm_reg_field FEATURE_CSR_ADDR_LO_CSR_Addr_Lo;
	uvm_reg_field CSR_Addr_Lo;
	uvm_reg_field FEATURE_CSR_ADDR_LO_CSR_REL;
	uvm_reg_field CSR_REL;
	uvm_reg_field FEATURE_CSR_ADDR_HI_CSR_Addr_Hi;
	uvm_reg_field CSR_Addr_Hi;
	uvm_reg_field FEATURE_CSR_SIZE_GROUP_LO_HAS_PARAMS;
	uvm_reg_field HAS_PARAMS;
	uvm_reg_field FEATURE_CSR_SIZE_GROUP_LO_Grouping_ID;
	uvm_reg_field Grouping_ID;
	uvm_reg_field FEATURE_CSR_SIZE_GROUP_LO_Instance_ID;
	uvm_reg_field Instance_ID;
	uvm_reg_field FEATURE_CSR_SIZE_GROUP_HI_CSR_SIZE;
	uvm_reg_field CSR_SIZE;
	uvm_reg_field HSSI_VERSION_Major;
	uvm_reg_field Major;
	uvm_reg_field HSSI_VERSION_Minor;
	uvm_reg_field Minor;
	rand uvm_reg_field HSSI_VERSION_Reserved;
	rand uvm_reg_field HSSI_FEATURE_Reserved;
	uvm_reg_field HSSI_FEATURE_PortEnable;
	uvm_reg_field PortEnable;
	uvm_reg_field HSSI_FEATURE_NumPorts;
	uvm_reg_field NumPorts;
	uvm_reg_field HSSI_FEATURE_ErrorMask;
	uvm_reg_field ErrorMask;
	rand uvm_reg_field HSSI_PORT_0_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_0_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_0_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_0_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_0_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_0_ATTR_DRP;
	uvm_reg_field HSSI_PORT_0_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_0_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_0_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_0_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_1_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_1_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_1_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_1_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_1_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_1_ATTR_DRP;
	uvm_reg_field HSSI_PORT_1_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_1_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_1_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_1_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_2_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_2_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_2_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_2_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_2_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_2_ATTR_DRP;
	uvm_reg_field HSSI_PORT_2_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_2_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_2_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_2_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_3_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_3_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_3_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_3_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_3_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_3_ATTR_DRP;
	uvm_reg_field HSSI_PORT_3_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_3_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_3_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_3_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_4_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_4_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_4_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_4_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_4_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_4_ATTR_DRP;
	uvm_reg_field HSSI_PORT_4_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_4_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_4_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_4_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_5_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_5_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_5_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_5_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_5_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_5_ATTR_DRP;
	uvm_reg_field HSSI_PORT_5_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_5_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_5_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_5_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_6_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_6_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_6_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_6_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_6_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_6_ATTR_DRP;
	uvm_reg_field HSSI_PORT_6_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_6_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_6_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_6_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_7_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_7_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_7_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_7_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_7_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_7_ATTR_DRP;
	uvm_reg_field HSSI_PORT_7_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_7_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_7_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_7_ATTR_Profile;
        `ifdef ENABLE_8_TO_15_PORTS
       	rand uvm_reg_field HSSI_PORT_8_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_8_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_8_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_8_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_8_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_8_ATTR_DRP;
	uvm_reg_field HSSI_PORT_8_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_8_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_8_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_8_ATTR_Profile;
        rand uvm_reg_field HSSI_PORT_9_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_9_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_9_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_9_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_9_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_9_ATTR_DRP;
	uvm_reg_field HSSI_PORT_9_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_9_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_9_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_9_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_10_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_10_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_10_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_10_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_10_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_10_ATTR_DRP;
	uvm_reg_field HSSI_PORT_10_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_10_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_10_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_10_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_11_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_11_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_11_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_11_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_11_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_11_ATTR_DRP;
	uvm_reg_field HSSI_PORT_11_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_11_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_11_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_11_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_12_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_12_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_12_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_12_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_12_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_12_ATTR_DRP;
	uvm_reg_field HSSI_PORT_12_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_12_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_12_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_12_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_13_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_13_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_13_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_13_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_13_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_13_ATTR_DRP;
	uvm_reg_field HSSI_PORT_13_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_13_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_13_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_13_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_14_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_14_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_14_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_14_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_14_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_14_ATTR_DRP;
	uvm_reg_field HSSI_PORT_14_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_14_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_14_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_14_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_15_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_15_ATTR_PtpEnable;
	uvm_reg_field HSSI_PORT_15_ATTR_AnltEnable;
	uvm_reg_field HSSI_PORT_15_ATTR_RsfecEnable;
	uvm_reg_field HSSI_PORT_15_ATTR_SubProfile;
	uvm_reg_field HSSI_PORT_15_ATTR_DRP;
	uvm_reg_field HSSI_PORT_15_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_15_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_15_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_15_ATTR_Profile;
        `endif
	rand uvm_reg_field HSSI_CMD_STATUS_Reserved;
	rand uvm_reg_field HSSI_CMD_STATUS_REG_OFFSET;
	rand uvm_reg_field REG_OFFSET;
	uvm_reg_field HSSI_CMD_STATUS_Error;
	uvm_reg_field Error;
	uvm_reg_field HSSI_CMD_STATUS_Busy;
	uvm_reg_field Busy;
	rand uvm_reg_field HSSI_CMD_STATUS_Ack;
	rand uvm_reg_field Ack;
	rand uvm_reg_field HSSI_CMD_STATUS_Write;
	rand uvm_reg_field Write;
	rand uvm_reg_field HSSI_CMD_STATUS_Read;
	rand uvm_reg_field Read;
	rand uvm_reg_field HSSI_CTRL_ADDR_HighAddress;
	rand uvm_reg_field HighAddress;
	rand uvm_reg_field HSSI_CTRL_ADDR_ChannelAddress;
	rand uvm_reg_field ChannelAddress;
	rand uvm_reg_field HSSI_CTRL_ADDR_PortAddress;
	rand uvm_reg_field PortAddress;
	rand uvm_reg_field HSSI_CTRL_ADDR_SAL;
	rand uvm_reg_field SAL;
	rand uvm_reg_field HSSI_READ_DATA_ReadData;
	rand uvm_reg_field ReadData;
	rand uvm_reg_field HSSI_WRITE_DATA_WriteData;
	rand uvm_reg_field WriteData;
	rand uvm_reg_field HSSI_TX_LATENCY_Reserved;
	uvm_reg_field HSSI_TX_LATENCY_TxLatency;
	rand uvm_reg_field HSSI_RX_LATENCY_Reserved;
	uvm_reg_field HSSI_RX_LATENCY_TxLatency;
	rand uvm_reg_field HSSI_PORT_0_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_0_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_0_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_0_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_0_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_0_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_0_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_0_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_0_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_0_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_0_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_0_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_0_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_0_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_0_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_0_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_0_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_0_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_0_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_0_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_0_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_0_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_0_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_0_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_1_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_1_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_1_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_1_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_1_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_1_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_1_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_1_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_1_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_1_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_1_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_1_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_1_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_1_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_1_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_1_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_1_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_1_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_1_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_1_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_1_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_1_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_1_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_1_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_2_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_2_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_2_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_2_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_2_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_2_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_2_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_2_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_2_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_2_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_2_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_2_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_2_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_2_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_2_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_2_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_2_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_2_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_2_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_2_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_2_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_2_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_2_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_2_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_3_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_3_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_3_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_3_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_3_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_3_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_3_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_3_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_3_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_3_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_3_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_3_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_3_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_3_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_3_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_3_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_3_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_3_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_3_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_3_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_3_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_3_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_3_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_3_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_4_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_4_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_4_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_4_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_4_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_4_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_4_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_4_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_4_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_4_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_4_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_4_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_4_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_4_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_4_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_4_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_4_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_4_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_4_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_4_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_4_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_4_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_4_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_4_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_5_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_5_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_5_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_5_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_5_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_5_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_5_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_5_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_5_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_5_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_5_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_5_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_5_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_5_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_5_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_5_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_5_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_5_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_5_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_5_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_5_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_5_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_5_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_5_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_6_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_6_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_6_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_6_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_6_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_6_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_6_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_6_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_6_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_6_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_6_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_6_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_6_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_6_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_6_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_6_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_6_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_6_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_6_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_6_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_6_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_6_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_6_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_6_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_7_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_7_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_7_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_7_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_7_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_7_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_7_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_7_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_7_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_7_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_7_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_7_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_7_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_7_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_7_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_7_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_7_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_7_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_7_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_7_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_7_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_7_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_7_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_7_STATUS_EHIPReady;
        `ifdef ENABLE_8_TO_15_PORTS
	rand uvm_reg_field HSSI_PORT_8_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_8_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_8_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_8_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_8_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_8_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_8_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_8_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_8_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_8_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_8_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_8_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_8_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_8_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_8_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_8_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_8_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_8_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_8_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_8_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_8_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_8_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_8_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_8_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_9_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_9_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_9_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_9_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_9_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_9_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_9_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_9_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_9_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_9_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_9_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_9_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_9_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_9_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_9_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_9_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_9_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_9_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_9_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_9_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_9_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_9_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_9_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_9_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_10_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_10_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_10_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_10_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_10_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_10_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_10_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_10_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_10_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_10_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_10_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_10_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_10_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_10_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_10_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_10_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_10_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_10_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_10_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_10_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_10_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_10_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_10_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_10_STATUS_EHIPReady;
        rand uvm_reg_field HSSI_PORT_11_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_11_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_11_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_11_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_11_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_11_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_11_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_11_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_11_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_11_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_11_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_11_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_11_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_11_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_11_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_11_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_11_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_11_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_11_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_11_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_11_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_11_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_11_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_11_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_12_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_12_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_12_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_12_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_12_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_12_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_12_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_12_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_12_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_12_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_12_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_12_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_12_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_12_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_12_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_12_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_12_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_12_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_12_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_12_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_12_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_12_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_12_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_12_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_13_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_13_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_13_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_13_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_13_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_13_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_13_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_13_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_13_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_13_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_13_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_13_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_13_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_13_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_13_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_13_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_13_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_13_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_13_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_13_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_13_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_13_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_13_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_13_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_14_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_14_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_14_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_14_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_14_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_14_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_14_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_14_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_14_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_14_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_14_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_14_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_14_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_14_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_14_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_14_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_14_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_14_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_14_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_14_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_14_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_14_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_14_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_14_STATUS_EHIPReady;
	rand uvm_reg_field HSSI_PORT_15_STATUS_Reserved;
	uvm_reg_field HSSI_PORT_15_STATUS_EHIP_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_15_STATUS_TX_PLL_LOCKED;
	uvm_reg_field HSSI_PORT_15_STATUS_RX_PCS_READY;
	uvm_reg_field HSSI_PORT_15_STATUS_TX_LANES_STABLE;
	uvm_reg_field HSSI_PORT_15_STATUS_CAL_ERROR;
	uvm_reg_field HSSI_PORT_15_STATUS_LOAD_ERROR;
	uvm_reg_field HSSI_PORT_15_STATUS_ETH_MODE;
	uvm_reg_field HSSI_PORT_15_STATUS_ENA_10;
	uvm_reg_field HSSI_PORT_15_STATUS_SET_1000;
	uvm_reg_field HSSI_PORT_15_STATUS_SET_10;
	uvm_reg_field HSSI_PORT_15_STATUS_MAC_ECC_STATUS;
	uvm_reg_field HSSI_PORT_15_STATUS_PCS_ECC_STATUS;
	uvm_reg_field HSSI_PORT_15_STATUS_RemoteFaultDsiable;
	uvm_reg_field HSSI_PORT_15_STATUS_ForceRemoteFault;
	uvm_reg_field HSSI_PORT_15_STATUS_RemoteFaultStatus;
	uvm_reg_field HSSI_PORT_15_STATUS_LocalFaultStatus;
	uvm_reg_field HSSI_PORT_15_STATUS_UndirectionalEn;
	uvm_reg_field HSSI_PORT_15_STATUS_LinkFaultGenEn;
	uvm_reg_field HSSI_PORT_15_STATUS_RxBlockLock;
	uvm_reg_field HSSI_PORT_15_STATUS_RxAMLock;
	uvm_reg_field HSSI_PORT_15_STATUS_CDRLock;
	uvm_reg_field HSSI_PORT_15_STATUS_RxHiBER;
	uvm_reg_field HSSI_PORT_15_STATUS_EHIPReady;
        `endif
	rand uvm_reg_field HSSI_TSE_CTRL_Reserved;
	rand uvm_reg_field HSSI_TSE_CTRL_MagicSleep_N;
	rand uvm_reg_field MagicSleep_N;
	uvm_reg_field HSSI_TSE_CTRL_MagicWakeUp;
	uvm_reg_field MagicWakeUp;
	rand uvm_reg_field HSSI_DBG_CTRL_Reserved;
	rand uvm_reg_field HSSI_DBG_CTRL_LED_Blinking_Rate;
	rand uvm_reg_field LED_Blinking_Rate;
	rand uvm_reg_field HSSI_DBG_CTRL_LED_Status_Override_En;
	rand uvm_reg_field LED_Status_Override_En;
	rand uvm_reg_field HSSI_DBG_CTRL_Port_N_LED_Status_Override;
	rand uvm_reg_field Port_N_LED_Status_Override;
	rand uvm_reg_field HSSI_DBG_CTRL_Override_Port_N_LED_Status;
	rand uvm_reg_field Override_Port_N_LED_Status;
	rand uvm_reg_field HSSI_DBG_CTRL_Override_Port_N_LED_Speed;
	rand uvm_reg_field Override_Port_N_LED_Speed;
	rand uvm_reg_field HSSI_INDV_RST_RxReset;
	rand uvm_reg_field RxReset;
	rand uvm_reg_field HSSI_INDV_RST_TxReset;
	rand uvm_reg_field TxReset;
	rand uvm_reg_field HSSI_INDV_RST_AxisRxReset;
	rand uvm_reg_field AxisRxReset;
	rand uvm_reg_field HSSI_INDV_RST_AxisTxReset;
	rand uvm_reg_field AxisTxReset;
	rand uvm_reg_field HSSI_INDV_RST_ACK_Reserved;
	uvm_reg_field HSSI_INDV_RST_ACK_RxResetAck;
	uvm_reg_field RxResetAck;
	uvm_reg_field HSSI_INDV_RST_ACK_TxResetAck;
	uvm_reg_field TxResetAck;
	rand uvm_reg_field HSSI_COLD_RST_Reserved;
	uvm_reg_field HSSI_COLD_RST_ColdResetAck;
	uvm_reg_field ColdResetAck;
	rand uvm_reg_field HSSI_COLD_RST_ColdReset;
	rand uvm_reg_field ColdReset;
	rand uvm_reg_field HSSI_STATUS_Reserved;
	uvm_reg_field HSSI_STATUS_RxPCSReady;
	uvm_reg_field RxPCSReady;
	uvm_reg_field HSSI_STATUS_TxLaneStable;
	uvm_reg_field TxLaneStable;
	uvm_reg_field HSSI_STATUS_TxPllLocked;
	uvm_reg_field TxPllLocked;
	rand uvm_reg_field HSSI_SCRATCHPAD_Scartchpad;
	rand uvm_reg_field Scartchpad;
	rand uvm_reg_field HSSI_PTP_STATUS_Reserved;
	uvm_reg_field HSSI_PTP_STATUS_PTP_RX_READY;
	uvm_reg_field PTP_RX_READY;
	uvm_reg_field HSSI_PTP_STATUS_PTP_TX_READY;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.HSSI_DFH_L = ral_reg_ac_hssi_HSSI_DFH_L::type_id::create("HSSI_DFH_L",,get_full_name());
      this.HSSI_DFH_L.configure(this, null, "");
      this.HSSI_DFH_L.build();
      this.default_map.add_reg(this.HSSI_DFH_L, `UVM_REG_ADDR_WIDTH'h0, "RO", 0);
		this.HSSI_DFH_L_NextDfhOffset_L = this.HSSI_DFH_L.NextDfhOffset_L;
		this.NextDfhOffset_L = this.HSSI_DFH_L.NextDfhOffset_L;
		this.HSSI_DFH_L_FeatureRevision = this.HSSI_DFH_L.FeatureRevision;
		this.FeatureRevision = this.HSSI_DFH_L.FeatureRevision;
		this.HSSI_DFH_L_FeatureId = this.HSSI_DFH_L.FeatureId;
		this.FeatureId = this.HSSI_DFH_L.FeatureId;
      this.HSSI_DFH_H = ral_reg_ac_hssi_HSSI_DFH_H::type_id::create("HSSI_DFH_H",,get_full_name());
      this.HSSI_DFH_H.configure(this, null, "");
      this.HSSI_DFH_H.build();
      this.default_map.add_reg(this.HSSI_DFH_H, `UVM_REG_ADDR_WIDTH'h4, "RW", 0);
		this.HSSI_DFH_H_FeatureType = this.HSSI_DFH_H.FeatureType;
		this.FeatureType = this.HSSI_DFH_H.FeatureType;
		this.HSSI_DFH_H_DfhVersion = this.HSSI_DFH_H.DfhVersion;
		this.DfhVersion = this.HSSI_DFH_H.DfhVersion;
		this.HSSI_DFH_H_DfhMinorVersion = this.HSSI_DFH_H.DfhMinorVersion;
		this.DfhMinorVersion = this.HSSI_DFH_H.DfhMinorVersion;
		this.HSSI_DFH_H_Reserved = this.HSSI_DFH_H.Reserved;
		this.HSSI_DFH_H_EOL = this.HSSI_DFH_H.EOL;
		this.EOL = this.HSSI_DFH_H.EOL;
		this.HSSI_DFH_H_NextDfhOffset_H = this.HSSI_DFH_H.NextDfhOffset_H;
		this.NextDfhOffset_H = this.HSSI_DFH_H.NextDfhOffset_H;
      this.FEATURE_GUID_L_0 = ral_reg_ac_hssi_FEATURE_GUID_L_0::type_id::create("FEATURE_GUID_L_0",,get_full_name());
      this.FEATURE_GUID_L_0.configure(this, null, "");
      this.FEATURE_GUID_L_0.build();
      this.default_map.add_reg(this.FEATURE_GUID_L_0, `UVM_REG_ADDR_WIDTH'h8, "RO", 0);
		this.FEATURE_GUID_L_0_GUID_bits_31_0 = this.FEATURE_GUID_L_0.GUID_bits_31_0;
		this.GUID_bits_31_0 = this.FEATURE_GUID_L_0.GUID_bits_31_0;
      this.FEATURE_GUID_L_1 = ral_reg_ac_hssi_FEATURE_GUID_L_1::type_id::create("FEATURE_GUID_L_1",,get_full_name());
      this.FEATURE_GUID_L_1.configure(this, null, "");
      this.FEATURE_GUID_L_1.build();
      this.default_map.add_reg(this.FEATURE_GUID_L_1, `UVM_REG_ADDR_WIDTH'hC, "RO", 0);
		this.FEATURE_GUID_L_1_GUID_bits_63_32 = this.FEATURE_GUID_L_1.GUID_bits_63_32;
		this.GUID_bits_63_32 = this.FEATURE_GUID_L_1.GUID_bits_63_32;
      this.FEATURE_GUID_H_0 = ral_reg_ac_hssi_FEATURE_GUID_H_0::type_id::create("FEATURE_GUID_H_0",,get_full_name());
      this.FEATURE_GUID_H_0.configure(this, null, "");
      this.FEATURE_GUID_H_0.build();
      this.default_map.add_reg(this.FEATURE_GUID_H_0, `UVM_REG_ADDR_WIDTH'h10, "RO", 0);
		this.FEATURE_GUID_H_0_GUID_bits_95_64 = this.FEATURE_GUID_H_0.GUID_bits_95_64;
		this.GUID_bits_95_64 = this.FEATURE_GUID_H_0.GUID_bits_95_64;
      this.FEATURE_GUID_H_1 = ral_reg_ac_hssi_FEATURE_GUID_H_1::type_id::create("FEATURE_GUID_H_1",,get_full_name());
      this.FEATURE_GUID_H_1.configure(this, null, "");
      this.FEATURE_GUID_H_1.build();
      this.default_map.add_reg(this.FEATURE_GUID_H_1, `UVM_REG_ADDR_WIDTH'h14, "RO", 0);
		this.FEATURE_GUID_H_1_GUID_bits_127_96 = this.FEATURE_GUID_H_1.GUID_bits_127_96;
		this.GUID_bits_127_96 = this.FEATURE_GUID_H_1.GUID_bits_127_96;
      this.FEATURE_CSR_ADDR_LO = ral_reg_ac_hssi_FEATURE_CSR_ADDR_LO::type_id::create("FEATURE_CSR_ADDR_LO",,get_full_name());
      this.FEATURE_CSR_ADDR_LO.configure(this, null, "");
      this.FEATURE_CSR_ADDR_LO.build();
      this.default_map.add_reg(this.FEATURE_CSR_ADDR_LO, `UVM_REG_ADDR_WIDTH'h18, "RO", 0);
		this.FEATURE_CSR_ADDR_LO_CSR_Addr_Lo = this.FEATURE_CSR_ADDR_LO.CSR_Addr_Lo;
		this.CSR_Addr_Lo = this.FEATURE_CSR_ADDR_LO.CSR_Addr_Lo;
		this.FEATURE_CSR_ADDR_LO_CSR_REL = this.FEATURE_CSR_ADDR_LO.CSR_REL;
		this.CSR_REL = this.FEATURE_CSR_ADDR_LO.CSR_REL;
      this.FEATURE_CSR_ADDR_HI = ral_reg_ac_hssi_FEATURE_CSR_ADDR_HI::type_id::create("FEATURE_CSR_ADDR_HI",,get_full_name());
      this.FEATURE_CSR_ADDR_HI.configure(this, null, "");
      this.FEATURE_CSR_ADDR_HI.build();
      this.default_map.add_reg(this.FEATURE_CSR_ADDR_HI, `UVM_REG_ADDR_WIDTH'h1C, "RO", 0);
		this.FEATURE_CSR_ADDR_HI_CSR_Addr_Hi = this.FEATURE_CSR_ADDR_HI.CSR_Addr_Hi;
		this.CSR_Addr_Hi = this.FEATURE_CSR_ADDR_HI.CSR_Addr_Hi;
      this.FEATURE_CSR_SIZE_GROUP_LO = ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_LO::type_id::create("FEATURE_CSR_SIZE_GROUP_LO",,get_full_name());
      this.FEATURE_CSR_SIZE_GROUP_LO.configure(this, null, "");
      this.FEATURE_CSR_SIZE_GROUP_LO.build();
      this.default_map.add_reg(this.FEATURE_CSR_SIZE_GROUP_LO, `UVM_REG_ADDR_WIDTH'h20, "RO", 0);
		this.FEATURE_CSR_SIZE_GROUP_LO_HAS_PARAMS = this.FEATURE_CSR_SIZE_GROUP_LO.HAS_PARAMS;
		this.HAS_PARAMS = this.FEATURE_CSR_SIZE_GROUP_LO.HAS_PARAMS;
		this.FEATURE_CSR_SIZE_GROUP_LO_Grouping_ID = this.FEATURE_CSR_SIZE_GROUP_LO.Grouping_ID;
		this.Grouping_ID = this.FEATURE_CSR_SIZE_GROUP_LO.Grouping_ID;
		this.FEATURE_CSR_SIZE_GROUP_LO_Instance_ID = this.FEATURE_CSR_SIZE_GROUP_LO.Instance_ID;
		this.Instance_ID = this.FEATURE_CSR_SIZE_GROUP_LO.Instance_ID;
      this.FEATURE_CSR_SIZE_GROUP_HI = ral_reg_ac_hssi_FEATURE_CSR_SIZE_GROUP_HI::type_id::create("FEATURE_CSR_SIZE_GROUP_HI",,get_full_name());
      this.FEATURE_CSR_SIZE_GROUP_HI.configure(this, null, "");
      this.FEATURE_CSR_SIZE_GROUP_HI.build();
      this.default_map.add_reg(this.FEATURE_CSR_SIZE_GROUP_HI, `UVM_REG_ADDR_WIDTH'h24, "RO", 0);
		this.FEATURE_CSR_SIZE_GROUP_HI_CSR_SIZE = this.FEATURE_CSR_SIZE_GROUP_HI.CSR_SIZE;
		this.CSR_SIZE = this.FEATURE_CSR_SIZE_GROUP_HI.CSR_SIZE;
      this.HSSI_VERSION = ral_reg_ac_hssi_HSSI_VERSION::type_id::create("HSSI_VERSION",,get_full_name());
      this.HSSI_VERSION.configure(this, null, "");
      this.HSSI_VERSION.build();
      this.default_map.add_reg(this.HSSI_VERSION, `UVM_REG_ADDR_WIDTH'h60, "RW", 0);
		this.HSSI_VERSION_Major = this.HSSI_VERSION.Major;
		this.Major = this.HSSI_VERSION.Major;
		this.HSSI_VERSION_Minor = this.HSSI_VERSION.Minor;
		this.Minor = this.HSSI_VERSION.Minor;
		this.HSSI_VERSION_Reserved = this.HSSI_VERSION.Reserved;
      this.HSSI_FEATURE = ral_reg_ac_hssi_HSSI_FEATURE::type_id::create("HSSI_FEATURE",,get_full_name());
      this.HSSI_FEATURE.configure(this, null, "");
      this.HSSI_FEATURE.build();
      this.default_map.add_reg(this.HSSI_FEATURE, `UVM_REG_ADDR_WIDTH'h64, "RW", 0);
		this.HSSI_FEATURE_Reserved = this.HSSI_FEATURE.Reserved;
		this.HSSI_FEATURE_PortEnable = this.HSSI_FEATURE.PortEnable;
		this.PortEnable = this.HSSI_FEATURE.PortEnable;
		this.HSSI_FEATURE_NumPorts = this.HSSI_FEATURE.NumPorts;
		this.NumPorts = this.HSSI_FEATURE.NumPorts;
		this.HSSI_FEATURE_ErrorMask = this.HSSI_FEATURE.ErrorMask;
		this.ErrorMask = this.HSSI_FEATURE.ErrorMask;
      this.HSSI_PORT_0_ATTR = ral_reg_ac_hssi_HSSI_PORT_0_ATTR::type_id::create("HSSI_PORT_0_ATTR",,get_full_name());
      this.HSSI_PORT_0_ATTR.configure(this, null, "");
      this.HSSI_PORT_0_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_0_ATTR, `UVM_REG_ADDR_WIDTH'h68, "RW", 0);
		this.HSSI_PORT_0_ATTR_Reserved = this.HSSI_PORT_0_ATTR.Reserved;
		this.HSSI_PORT_0_ATTR_PtpEnable = this.HSSI_PORT_0_ATTR.PtpEnable;
		this.HSSI_PORT_0_ATTR_AnltEnable = this.HSSI_PORT_0_ATTR.AnltEnable;
		this.HSSI_PORT_0_ATTR_RsfecEnable = this.HSSI_PORT_0_ATTR.RsfecEnable;
		this.HSSI_PORT_0_ATTR_SubProfile = this.HSSI_PORT_0_ATTR.SubProfile;
		this.HSSI_PORT_0_ATTR_DRP = this.HSSI_PORT_0_ATTR.DRP;
		this.HSSI_PORT_0_ATTR_LowSpeedParam = this.HSSI_PORT_0_ATTR.LowSpeedParam;
		this.HSSI_PORT_0_ATTR_DataBusWidth = this.HSSI_PORT_0_ATTR.DataBusWidth;
		this.HSSI_PORT_0_ATTR_ReadyLatency = this.HSSI_PORT_0_ATTR.ReadyLatency;
		this.HSSI_PORT_0_ATTR_Profile = this.HSSI_PORT_0_ATTR.Profile;
      this.HSSI_PORT_1_ATTR = ral_reg_ac_hssi_HSSI_PORT_1_ATTR::type_id::create("HSSI_PORT_1_ATTR",,get_full_name());
      this.HSSI_PORT_1_ATTR.configure(this, null, "");
      this.HSSI_PORT_1_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_1_ATTR, `UVM_REG_ADDR_WIDTH'h6C, "RW", 0);
		this.HSSI_PORT_1_ATTR_Reserved = this.HSSI_PORT_1_ATTR.Reserved;
		this.HSSI_PORT_1_ATTR_PtpEnable = this.HSSI_PORT_1_ATTR.PtpEnable;
		this.HSSI_PORT_1_ATTR_AnltEnable = this.HSSI_PORT_1_ATTR.AnltEnable;
		this.HSSI_PORT_1_ATTR_RsfecEnable = this.HSSI_PORT_1_ATTR.RsfecEnable;
		this.HSSI_PORT_1_ATTR_SubProfile = this.HSSI_PORT_1_ATTR.SubProfile;
		this.HSSI_PORT_1_ATTR_DRP = this.HSSI_PORT_1_ATTR.DRP;
		this.HSSI_PORT_1_ATTR_LowSpeedParam = this.HSSI_PORT_1_ATTR.LowSpeedParam;
		this.HSSI_PORT_1_ATTR_DataBusWidth = this.HSSI_PORT_1_ATTR.DataBusWidth;
		this.HSSI_PORT_1_ATTR_ReadyLatency = this.HSSI_PORT_1_ATTR.ReadyLatency;
		this.HSSI_PORT_1_ATTR_Profile = this.HSSI_PORT_1_ATTR.Profile;
      this.HSSI_PORT_2_ATTR = ral_reg_ac_hssi_HSSI_PORT_2_ATTR::type_id::create("HSSI_PORT_2_ATTR",,get_full_name());
      this.HSSI_PORT_2_ATTR.configure(this, null, "");
      this.HSSI_PORT_2_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_2_ATTR, `UVM_REG_ADDR_WIDTH'h70, "RW", 0);
		this.HSSI_PORT_2_ATTR_Reserved = this.HSSI_PORT_2_ATTR.Reserved;
		this.HSSI_PORT_2_ATTR_PtpEnable = this.HSSI_PORT_2_ATTR.PtpEnable;
		this.HSSI_PORT_2_ATTR_AnltEnable = this.HSSI_PORT_2_ATTR.AnltEnable;
		this.HSSI_PORT_2_ATTR_RsfecEnable = this.HSSI_PORT_2_ATTR.RsfecEnable;
		this.HSSI_PORT_2_ATTR_SubProfile = this.HSSI_PORT_2_ATTR.SubProfile;
		this.HSSI_PORT_2_ATTR_DRP = this.HSSI_PORT_2_ATTR.DRP;
		this.HSSI_PORT_2_ATTR_LowSpeedParam = this.HSSI_PORT_2_ATTR.LowSpeedParam;
		this.HSSI_PORT_2_ATTR_DataBusWidth = this.HSSI_PORT_2_ATTR.DataBusWidth;
		this.HSSI_PORT_2_ATTR_ReadyLatency = this.HSSI_PORT_2_ATTR.ReadyLatency;
		this.HSSI_PORT_2_ATTR_Profile = this.HSSI_PORT_2_ATTR.Profile;
      this.HSSI_PORT_3_ATTR = ral_reg_ac_hssi_HSSI_PORT_3_ATTR::type_id::create("HSSI_PORT_3_ATTR",,get_full_name());
      this.HSSI_PORT_3_ATTR.configure(this, null, "");
      this.HSSI_PORT_3_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_3_ATTR, `UVM_REG_ADDR_WIDTH'h74, "RW", 0);
		this.HSSI_PORT_3_ATTR_Reserved = this.HSSI_PORT_3_ATTR.Reserved;
		this.HSSI_PORT_3_ATTR_PtpEnable = this.HSSI_PORT_3_ATTR.PtpEnable;
		this.HSSI_PORT_3_ATTR_AnltEnable = this.HSSI_PORT_3_ATTR.AnltEnable;
		this.HSSI_PORT_3_ATTR_RsfecEnable = this.HSSI_PORT_3_ATTR.RsfecEnable;
		this.HSSI_PORT_3_ATTR_SubProfile = this.HSSI_PORT_3_ATTR.SubProfile;
		this.HSSI_PORT_3_ATTR_DRP = this.HSSI_PORT_3_ATTR.DRP;
		this.HSSI_PORT_3_ATTR_LowSpeedParam = this.HSSI_PORT_3_ATTR.LowSpeedParam;
		this.HSSI_PORT_3_ATTR_DataBusWidth = this.HSSI_PORT_3_ATTR.DataBusWidth;
		this.HSSI_PORT_3_ATTR_ReadyLatency = this.HSSI_PORT_3_ATTR.ReadyLatency;
		this.HSSI_PORT_3_ATTR_Profile = this.HSSI_PORT_3_ATTR.Profile;
      this.HSSI_PORT_4_ATTR = ral_reg_ac_hssi_HSSI_PORT_4_ATTR::type_id::create("HSSI_PORT_4_ATTR",,get_full_name());
      this.HSSI_PORT_4_ATTR.configure(this, null, "");
      this.HSSI_PORT_4_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_4_ATTR, `UVM_REG_ADDR_WIDTH'h78, "RW", 0);
		this.HSSI_PORT_4_ATTR_Reserved = this.HSSI_PORT_4_ATTR.Reserved;
		this.HSSI_PORT_4_ATTR_PtpEnable = this.HSSI_PORT_4_ATTR.PtpEnable;
		this.HSSI_PORT_4_ATTR_AnltEnable = this.HSSI_PORT_4_ATTR.AnltEnable;
		this.HSSI_PORT_4_ATTR_RsfecEnable = this.HSSI_PORT_4_ATTR.RsfecEnable;
		this.HSSI_PORT_4_ATTR_SubProfile = this.HSSI_PORT_4_ATTR.SubProfile;
		this.HSSI_PORT_4_ATTR_DRP = this.HSSI_PORT_4_ATTR.DRP;
		this.HSSI_PORT_4_ATTR_LowSpeedParam = this.HSSI_PORT_4_ATTR.LowSpeedParam;
		this.HSSI_PORT_4_ATTR_DataBusWidth = this.HSSI_PORT_4_ATTR.DataBusWidth;
		this.HSSI_PORT_4_ATTR_ReadyLatency = this.HSSI_PORT_4_ATTR.ReadyLatency;
		this.HSSI_PORT_4_ATTR_Profile = this.HSSI_PORT_4_ATTR.Profile;
      this.HSSI_PORT_5_ATTR = ral_reg_ac_hssi_HSSI_PORT_5_ATTR::type_id::create("HSSI_PORT_5_ATTR",,get_full_name());
      this.HSSI_PORT_5_ATTR.configure(this, null, "");
      this.HSSI_PORT_5_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_5_ATTR, `UVM_REG_ADDR_WIDTH'h7C, "RW", 0);
		this.HSSI_PORT_5_ATTR_Reserved = this.HSSI_PORT_5_ATTR.Reserved;
		this.HSSI_PORT_5_ATTR_PtpEnable = this.HSSI_PORT_5_ATTR.PtpEnable;
		this.HSSI_PORT_5_ATTR_AnltEnable = this.HSSI_PORT_5_ATTR.AnltEnable;
		this.HSSI_PORT_5_ATTR_RsfecEnable = this.HSSI_PORT_5_ATTR.RsfecEnable;
		this.HSSI_PORT_5_ATTR_SubProfile = this.HSSI_PORT_5_ATTR.SubProfile;
		this.HSSI_PORT_5_ATTR_DRP = this.HSSI_PORT_5_ATTR.DRP;
		this.HSSI_PORT_5_ATTR_LowSpeedParam = this.HSSI_PORT_5_ATTR.LowSpeedParam;
		this.HSSI_PORT_5_ATTR_DataBusWidth = this.HSSI_PORT_5_ATTR.DataBusWidth;
		this.HSSI_PORT_5_ATTR_ReadyLatency = this.HSSI_PORT_5_ATTR.ReadyLatency;
		this.HSSI_PORT_5_ATTR_Profile = this.HSSI_PORT_5_ATTR.Profile;
      this.HSSI_PORT_6_ATTR = ral_reg_ac_hssi_HSSI_PORT_6_ATTR::type_id::create("HSSI_PORT_6_ATTR",,get_full_name());
      this.HSSI_PORT_6_ATTR.configure(this, null, "");
      this.HSSI_PORT_6_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_6_ATTR, `UVM_REG_ADDR_WIDTH'h80, "RW", 0);
		this.HSSI_PORT_6_ATTR_Reserved = this.HSSI_PORT_6_ATTR.Reserved;
		this.HSSI_PORT_6_ATTR_PtpEnable = this.HSSI_PORT_6_ATTR.PtpEnable;
		this.HSSI_PORT_6_ATTR_AnltEnable = this.HSSI_PORT_6_ATTR.AnltEnable;
		this.HSSI_PORT_6_ATTR_RsfecEnable = this.HSSI_PORT_6_ATTR.RsfecEnable;
		this.HSSI_PORT_6_ATTR_SubProfile = this.HSSI_PORT_6_ATTR.SubProfile;
		this.HSSI_PORT_6_ATTR_DRP = this.HSSI_PORT_6_ATTR.DRP;
		this.HSSI_PORT_6_ATTR_LowSpeedParam = this.HSSI_PORT_6_ATTR.LowSpeedParam;
		this.HSSI_PORT_6_ATTR_DataBusWidth = this.HSSI_PORT_6_ATTR.DataBusWidth;
		this.HSSI_PORT_6_ATTR_ReadyLatency = this.HSSI_PORT_6_ATTR.ReadyLatency;
		this.HSSI_PORT_6_ATTR_Profile = this.HSSI_PORT_6_ATTR.Profile;
      this.HSSI_PORT_7_ATTR = ral_reg_ac_hssi_HSSI_PORT_7_ATTR::type_id::create("HSSI_PORT_7_ATTR",,get_full_name());
      this.HSSI_PORT_7_ATTR.configure(this, null, "");
      this.HSSI_PORT_7_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_7_ATTR, `UVM_REG_ADDR_WIDTH'h84, "RW", 0);
		this.HSSI_PORT_7_ATTR_Reserved = this.HSSI_PORT_7_ATTR.Reserved;
		this.HSSI_PORT_7_ATTR_PtpEnable = this.HSSI_PORT_7_ATTR.PtpEnable;
		this.HSSI_PORT_7_ATTR_AnltEnable = this.HSSI_PORT_7_ATTR.AnltEnable;
		this.HSSI_PORT_7_ATTR_RsfecEnable = this.HSSI_PORT_7_ATTR.RsfecEnable;
		this.HSSI_PORT_7_ATTR_SubProfile = this.HSSI_PORT_7_ATTR.SubProfile;
		this.HSSI_PORT_7_ATTR_DRP = this.HSSI_PORT_7_ATTR.DRP;
		this.HSSI_PORT_7_ATTR_LowSpeedParam = this.HSSI_PORT_7_ATTR.LowSpeedParam;
		this.HSSI_PORT_7_ATTR_DataBusWidth = this.HSSI_PORT_7_ATTR.DataBusWidth;
		this.HSSI_PORT_7_ATTR_ReadyLatency = this.HSSI_PORT_7_ATTR.ReadyLatency;
		this.HSSI_PORT_7_ATTR_Profile = this.HSSI_PORT_7_ATTR.Profile;
      `ifdef ENABLE_8_TO_15_PORTS
      this.HSSI_PORT_8_ATTR = ral_reg_ac_hssi_HSSI_PORT_8_ATTR::type_id::create("HSSI_PORT_8_ATTR",,get_full_name());
      this.HSSI_PORT_8_ATTR.configure(this, null, "");
      this.HSSI_PORT_8_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_8_ATTR, `UVM_REG_ADDR_WIDTH'h88, "RW", 0);
		this.HSSI_PORT_8_ATTR_Reserved = this.HSSI_PORT_8_ATTR.Reserved;
		this.HSSI_PORT_8_ATTR_PtpEnable = this.HSSI_PORT_8_ATTR.PtpEnable;
		this.HSSI_PORT_8_ATTR_AnltEnable = this.HSSI_PORT_8_ATTR.AnltEnable;
		this.HSSI_PORT_8_ATTR_RsfecEnable = this.HSSI_PORT_8_ATTR.RsfecEnable;
		this.HSSI_PORT_8_ATTR_SubProfile = this.HSSI_PORT_8_ATTR.SubProfile;
		this.HSSI_PORT_8_ATTR_DRP = this.HSSI_PORT_8_ATTR.DRP;
		this.HSSI_PORT_8_ATTR_LowSpeedParam = this.HSSI_PORT_8_ATTR.LowSpeedParam;
		this.HSSI_PORT_8_ATTR_DataBusWidth = this.HSSI_PORT_8_ATTR.DataBusWidth;
		this.HSSI_PORT_8_ATTR_ReadyLatency = this.HSSI_PORT_8_ATTR.ReadyLatency;
		this.HSSI_PORT_8_ATTR_Profile = this.HSSI_PORT_8_ATTR.Profile;
      this.HSSI_PORT_9_ATTR = ral_reg_ac_hssi_HSSI_PORT_9_ATTR::type_id::create("HSSI_PORT_9_ATTR",,get_full_name());
      this.HSSI_PORT_9_ATTR.configure(this, null, "");
      this.HSSI_PORT_9_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_9_ATTR, `UVM_REG_ADDR_WIDTH'h8c, "RW", 0);
		this.HSSI_PORT_9_ATTR_Reserved = this.HSSI_PORT_9_ATTR.Reserved;
		this.HSSI_PORT_9_ATTR_PtpEnable = this.HSSI_PORT_9_ATTR.PtpEnable;
		this.HSSI_PORT_9_ATTR_AnltEnable = this.HSSI_PORT_9_ATTR.AnltEnable;
		this.HSSI_PORT_9_ATTR_RsfecEnable = this.HSSI_PORT_9_ATTR.RsfecEnable;
		this.HSSI_PORT_9_ATTR_SubProfile = this.HSSI_PORT_9_ATTR.SubProfile;
		this.HSSI_PORT_9_ATTR_DRP = this.HSSI_PORT_9_ATTR.DRP;
		this.HSSI_PORT_9_ATTR_LowSpeedParam = this.HSSI_PORT_9_ATTR.LowSpeedParam;
		this.HSSI_PORT_9_ATTR_DataBusWidth = this.HSSI_PORT_9_ATTR.DataBusWidth;
		this.HSSI_PORT_9_ATTR_ReadyLatency = this.HSSI_PORT_9_ATTR.ReadyLatency;
		this.HSSI_PORT_9_ATTR_Profile = this.HSSI_PORT_9_ATTR.Profile;
      this.HSSI_PORT_10_ATTR = ral_reg_ac_hssi_HSSI_PORT_10_ATTR::type_id::create("HSSI_PORT_10_ATTR",,get_full_name());
      this.HSSI_PORT_10_ATTR.configure(this, null, "");
      this.HSSI_PORT_10_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_10_ATTR, `UVM_REG_ADDR_WIDTH'h90, "RW", 0);
		this.HSSI_PORT_10_ATTR_Reserved = this.HSSI_PORT_10_ATTR.Reserved;
		this.HSSI_PORT_10_ATTR_PtpEnable = this.HSSI_PORT_10_ATTR.PtpEnable;
		this.HSSI_PORT_10_ATTR_AnltEnable = this.HSSI_PORT_10_ATTR.AnltEnable;
		this.HSSI_PORT_10_ATTR_RsfecEnable = this.HSSI_PORT_10_ATTR.RsfecEnable;
		this.HSSI_PORT_10_ATTR_SubProfile = this.HSSI_PORT_10_ATTR.SubProfile;
		this.HSSI_PORT_10_ATTR_DRP = this.HSSI_PORT_10_ATTR.DRP;
		this.HSSI_PORT_10_ATTR_LowSpeedParam = this.HSSI_PORT_10_ATTR.LowSpeedParam;
		this.HSSI_PORT_10_ATTR_DataBusWidth = this.HSSI_PORT_10_ATTR.DataBusWidth;
		this.HSSI_PORT_10_ATTR_ReadyLatency = this.HSSI_PORT_10_ATTR.ReadyLatency;
		this.HSSI_PORT_10_ATTR_Profile = this.HSSI_PORT_10_ATTR.Profile;
      this.HSSI_PORT_11_ATTR = ral_reg_ac_hssi_HSSI_PORT_11_ATTR::type_id::create("HSSI_PORT_11_ATTR",,get_full_name());
      this.HSSI_PORT_11_ATTR.configure(this, null, "");
      this.HSSI_PORT_11_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_11_ATTR, `UVM_REG_ADDR_WIDTH'h94, "RW", 0);
		this.HSSI_PORT_11_ATTR_Reserved = this.HSSI_PORT_11_ATTR.Reserved;
		this.HSSI_PORT_11_ATTR_PtpEnable = this.HSSI_PORT_11_ATTR.PtpEnable;
		this.HSSI_PORT_11_ATTR_AnltEnable = this.HSSI_PORT_11_ATTR.AnltEnable;
		this.HSSI_PORT_11_ATTR_RsfecEnable = this.HSSI_PORT_11_ATTR.RsfecEnable;
		this.HSSI_PORT_11_ATTR_SubProfile = this.HSSI_PORT_11_ATTR.SubProfile;
		this.HSSI_PORT_11_ATTR_DRP = this.HSSI_PORT_11_ATTR.DRP;
		this.HSSI_PORT_11_ATTR_LowSpeedParam = this.HSSI_PORT_11_ATTR.LowSpeedParam;
		this.HSSI_PORT_11_ATTR_DataBusWidth = this.HSSI_PORT_11_ATTR.DataBusWidth;
		this.HSSI_PORT_11_ATTR_ReadyLatency = this.HSSI_PORT_11_ATTR.ReadyLatency;
		this.HSSI_PORT_11_ATTR_Profile = this.HSSI_PORT_11_ATTR.Profile;
     this.HSSI_PORT_12_ATTR = ral_reg_ac_hssi_HSSI_PORT_12_ATTR::type_id::create("HSSI_PORT_12_ATTR",,get_full_name());
      this.HSSI_PORT_12_ATTR.configure(this, null, "");
      this.HSSI_PORT_12_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_12_ATTR, `UVM_REG_ADDR_WIDTH'h98, "RW", 0);
		this.HSSI_PORT_12_ATTR_Reserved = this.HSSI_PORT_12_ATTR.Reserved;
		this.HSSI_PORT_12_ATTR_PtpEnable = this.HSSI_PORT_12_ATTR.PtpEnable;
		this.HSSI_PORT_12_ATTR_AnltEnable = this.HSSI_PORT_12_ATTR.AnltEnable;
		this.HSSI_PORT_12_ATTR_RsfecEnable = this.HSSI_PORT_12_ATTR.RsfecEnable;
		this.HSSI_PORT_12_ATTR_SubProfile = this.HSSI_PORT_12_ATTR.SubProfile;
		this.HSSI_PORT_12_ATTR_DRP = this.HSSI_PORT_12_ATTR.DRP;
		this.HSSI_PORT_12_ATTR_LowSpeedParam = this.HSSI_PORT_12_ATTR.LowSpeedParam;
		this.HSSI_PORT_12_ATTR_DataBusWidth = this.HSSI_PORT_12_ATTR.DataBusWidth;
		this.HSSI_PORT_12_ATTR_ReadyLatency = this.HSSI_PORT_12_ATTR.ReadyLatency;
		this.HSSI_PORT_12_ATTR_Profile = this.HSSI_PORT_12_ATTR.Profile;
      this.HSSI_PORT_13_ATTR = ral_reg_ac_hssi_HSSI_PORT_13_ATTR::type_id::create("HSSI_PORT_13_ATTR",,get_full_name());
      this.HSSI_PORT_13_ATTR.configure(this, null, "");
      this.HSSI_PORT_13_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_13_ATTR, `UVM_REG_ADDR_WIDTH'h9c, "RW", 0);
		this.HSSI_PORT_13_ATTR_Reserved = this.HSSI_PORT_13_ATTR.Reserved;
		this.HSSI_PORT_13_ATTR_PtpEnable = this.HSSI_PORT_13_ATTR.PtpEnable;
		this.HSSI_PORT_13_ATTR_AnltEnable = this.HSSI_PORT_13_ATTR.AnltEnable;
		this.HSSI_PORT_13_ATTR_RsfecEnable = this.HSSI_PORT_13_ATTR.RsfecEnable;
		this.HSSI_PORT_13_ATTR_SubProfile = this.HSSI_PORT_13_ATTR.SubProfile;
		this.HSSI_PORT_13_ATTR_DRP = this.HSSI_PORT_13_ATTR.DRP;
		this.HSSI_PORT_13_ATTR_LowSpeedParam = this.HSSI_PORT_13_ATTR.LowSpeedParam;
		this.HSSI_PORT_13_ATTR_DataBusWidth = this.HSSI_PORT_13_ATTR.DataBusWidth;
		this.HSSI_PORT_13_ATTR_ReadyLatency = this.HSSI_PORT_13_ATTR.ReadyLatency;
		this.HSSI_PORT_13_ATTR_Profile = this.HSSI_PORT_13_ATTR.Profile;
      this.HSSI_PORT_14_ATTR = ral_reg_ac_hssi_HSSI_PORT_14_ATTR::type_id::create("HSSI_PORT_14_ATTR",,get_full_name());
      this.HSSI_PORT_14_ATTR.configure(this, null, "");
      this.HSSI_PORT_14_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_14_ATTR, `UVM_REG_ADDR_WIDTH'ha0, "RW", 0);
		this.HSSI_PORT_14_ATTR_Reserved = this.HSSI_PORT_14_ATTR.Reserved;
		this.HSSI_PORT_14_ATTR_PtpEnable = this.HSSI_PORT_14_ATTR.PtpEnable;
		this.HSSI_PORT_14_ATTR_AnltEnable = this.HSSI_PORT_14_ATTR.AnltEnable;
		this.HSSI_PORT_14_ATTR_RsfecEnable = this.HSSI_PORT_14_ATTR.RsfecEnable;
		this.HSSI_PORT_14_ATTR_SubProfile = this.HSSI_PORT_14_ATTR.SubProfile;
		this.HSSI_PORT_14_ATTR_DRP = this.HSSI_PORT_14_ATTR.DRP;
		this.HSSI_PORT_14_ATTR_LowSpeedParam = this.HSSI_PORT_14_ATTR.LowSpeedParam;
		this.HSSI_PORT_14_ATTR_DataBusWidth = this.HSSI_PORT_14_ATTR.DataBusWidth;
		this.HSSI_PORT_14_ATTR_ReadyLatency = this.HSSI_PORT_14_ATTR.ReadyLatency;
		this.HSSI_PORT_14_ATTR_Profile = this.HSSI_PORT_14_ATTR.Profile;
      this.HSSI_PORT_15_ATTR = ral_reg_ac_hssi_HSSI_PORT_15_ATTR::type_id::create("HSSI_PORT_15_ATTR",,get_full_name());
      this.HSSI_PORT_15_ATTR.configure(this, null, "");
      this.HSSI_PORT_15_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_15_ATTR, `UVM_REG_ADDR_WIDTH'ha4, "RW", 0);
		this.HSSI_PORT_15_ATTR_Reserved = this.HSSI_PORT_15_ATTR.Reserved;
		this.HSSI_PORT_15_ATTR_PtpEnable = this.HSSI_PORT_15_ATTR.PtpEnable;
		this.HSSI_PORT_15_ATTR_AnltEnable = this.HSSI_PORT_15_ATTR.AnltEnable;
		this.HSSI_PORT_15_ATTR_RsfecEnable = this.HSSI_PORT_15_ATTR.RsfecEnable;
		this.HSSI_PORT_15_ATTR_SubProfile = this.HSSI_PORT_15_ATTR.SubProfile;
		this.HSSI_PORT_15_ATTR_DRP = this.HSSI_PORT_15_ATTR.DRP;
		this.HSSI_PORT_15_ATTR_LowSpeedParam = this.HSSI_PORT_15_ATTR.LowSpeedParam;
		this.HSSI_PORT_15_ATTR_DataBusWidth = this.HSSI_PORT_15_ATTR.DataBusWidth;
		this.HSSI_PORT_15_ATTR_ReadyLatency = this.HSSI_PORT_15_ATTR.ReadyLatency;
		this.HSSI_PORT_15_ATTR_Profile = this.HSSI_PORT_15_ATTR.Profile;
      `endif
      this.HSSI_CMD_STATUS = ral_reg_ac_hssi_HSSI_CMD_STATUS::type_id::create("HSSI_CMD_STATUS",,get_full_name());
      this.HSSI_CMD_STATUS.configure(this, null, "");
      this.HSSI_CMD_STATUS.build();
      this.default_map.add_reg(this.HSSI_CMD_STATUS, `UVM_REG_ADDR_WIDTH'hA8, "RW", 0);
		this.HSSI_CMD_STATUS_Reserved = this.HSSI_CMD_STATUS.Reserved;
		this.HSSI_CMD_STATUS_REG_OFFSET = this.HSSI_CMD_STATUS.REG_OFFSET;
		this.REG_OFFSET = this.HSSI_CMD_STATUS.REG_OFFSET;
		this.HSSI_CMD_STATUS_Error = this.HSSI_CMD_STATUS.Error;
		this.Error = this.HSSI_CMD_STATUS.Error;
		this.HSSI_CMD_STATUS_Busy = this.HSSI_CMD_STATUS.Busy;
		this.Busy = this.HSSI_CMD_STATUS.Busy;
		this.HSSI_CMD_STATUS_Ack = this.HSSI_CMD_STATUS.Ack;
		this.Ack = this.HSSI_CMD_STATUS.Ack;
		this.HSSI_CMD_STATUS_Write = this.HSSI_CMD_STATUS.Write;
		this.Write = this.HSSI_CMD_STATUS.Write;
		this.HSSI_CMD_STATUS_Read = this.HSSI_CMD_STATUS.Read;
		this.Read = this.HSSI_CMD_STATUS.Read;
      this.HSSI_CTRL_ADDR = ral_reg_ac_hssi_HSSI_CTRL_ADDR::type_id::create("HSSI_CTRL_ADDR",,get_full_name());
      this.HSSI_CTRL_ADDR.configure(this, null, "");
      this.HSSI_CTRL_ADDR.build();
      this.default_map.add_reg(this.HSSI_CTRL_ADDR, `UVM_REG_ADDR_WIDTH'hAC, "RW", 0);
		this.HSSI_CTRL_ADDR_HighAddress = this.HSSI_CTRL_ADDR.HighAddress;
		this.HighAddress = this.HSSI_CTRL_ADDR.HighAddress;
		this.HSSI_CTRL_ADDR_ChannelAddress = this.HSSI_CTRL_ADDR.ChannelAddress;
		this.ChannelAddress = this.HSSI_CTRL_ADDR.ChannelAddress;
		this.HSSI_CTRL_ADDR_PortAddress = this.HSSI_CTRL_ADDR.PortAddress;
		this.PortAddress = this.HSSI_CTRL_ADDR.PortAddress;
		this.HSSI_CTRL_ADDR_SAL = this.HSSI_CTRL_ADDR.SAL;
		this.SAL = this.HSSI_CTRL_ADDR.SAL;
      this.HSSI_READ_DATA = ral_reg_ac_hssi_HSSI_READ_DATA::type_id::create("HSSI_READ_DATA",,get_full_name());
      this.HSSI_READ_DATA.configure(this, null, "");
      this.HSSI_READ_DATA.build();
      this.default_map.add_reg(this.HSSI_READ_DATA, `UVM_REG_ADDR_WIDTH'hB0, "RW", 0);
		this.HSSI_READ_DATA_ReadData = this.HSSI_READ_DATA.ReadData;
		this.ReadData = this.HSSI_READ_DATA.ReadData;
      this.HSSI_WRITE_DATA = ral_reg_ac_hssi_HSSI_WRITE_DATA::type_id::create("HSSI_WRITE_DATA",,get_full_name());
      this.HSSI_WRITE_DATA.configure(this, null, "");
      this.HSSI_WRITE_DATA.build();
      this.default_map.add_reg(this.HSSI_WRITE_DATA, `UVM_REG_ADDR_WIDTH'hB4, "RW", 0);
		this.HSSI_WRITE_DATA_WriteData = this.HSSI_WRITE_DATA.WriteData;
		this.WriteData = this.HSSI_WRITE_DATA.WriteData;
      this.HSSI_TX_LATENCY = ral_reg_ac_hssi_HSSI_TX_LATENCY::type_id::create("HSSI_TX_LATENCY",,get_full_name());
      this.HSSI_TX_LATENCY.configure(this, null, "");
      this.HSSI_TX_LATENCY.build();
      this.default_map.add_reg(this.HSSI_TX_LATENCY, `UVM_REG_ADDR_WIDTH'hB8, "RW", 0);
		this.HSSI_TX_LATENCY_Reserved = this.HSSI_TX_LATENCY.Reserved;
		this.HSSI_TX_LATENCY_TxLatency = this.HSSI_TX_LATENCY.TxLatency;
      this.HSSI_RX_LATENCY = ral_reg_ac_hssi_HSSI_RX_LATENCY::type_id::create("HSSI_RX_LATENCY",,get_full_name());
      this.HSSI_RX_LATENCY.configure(this, null, "");
      this.HSSI_RX_LATENCY.build();
      this.default_map.add_reg(this.HSSI_RX_LATENCY, `UVM_REG_ADDR_WIDTH'hBC, "RW", 0);
		this.HSSI_RX_LATENCY_Reserved = this.HSSI_RX_LATENCY.Reserved;
		this.HSSI_RX_LATENCY_TxLatency = this.HSSI_RX_LATENCY.TxLatency;
      this.HSSI_PORT_0_STATUS = ral_reg_ac_hssi_HSSI_PORT_0_STATUS::type_id::create("HSSI_PORT_0_STATUS",,get_full_name());
      this.HSSI_PORT_0_STATUS.configure(this, null, "");
      this.HSSI_PORT_0_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_0_STATUS, `UVM_REG_ADDR_WIDTH'hC0, "RW", 0);
		this.HSSI_PORT_0_STATUS_Reserved = this.HSSI_PORT_0_STATUS.Reserved;
		this.HSSI_PORT_0_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_0_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_0_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_0_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_0_STATUS_RX_PCS_READY = this.HSSI_PORT_0_STATUS.RX_PCS_READY;
		this.HSSI_PORT_0_STATUS_TX_LANES_STABLE = this.HSSI_PORT_0_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_0_STATUS_CAL_ERROR = this.HSSI_PORT_0_STATUS.CAL_ERROR;
		this.HSSI_PORT_0_STATUS_LOAD_ERROR = this.HSSI_PORT_0_STATUS.LOAD_ERROR;
		this.HSSI_PORT_0_STATUS_ETH_MODE = this.HSSI_PORT_0_STATUS.ETH_MODE;
		this.HSSI_PORT_0_STATUS_ENA_10 = this.HSSI_PORT_0_STATUS.ENA_10;
		this.HSSI_PORT_0_STATUS_SET_1000 = this.HSSI_PORT_0_STATUS.SET_1000;
		this.HSSI_PORT_0_STATUS_SET_10 = this.HSSI_PORT_0_STATUS.SET_10;
		this.HSSI_PORT_0_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_0_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_0_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_0_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_0_STATUS_RemoteFaultDsiable = this.HSSI_PORT_0_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_0_STATUS_ForceRemoteFault = this.HSSI_PORT_0_STATUS.ForceRemoteFault;
		this.HSSI_PORT_0_STATUS_RemoteFaultStatus = this.HSSI_PORT_0_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_0_STATUS_LocalFaultStatus = this.HSSI_PORT_0_STATUS.LocalFaultStatus;
		this.HSSI_PORT_0_STATUS_UndirectionalEn = this.HSSI_PORT_0_STATUS.UndirectionalEn;
		this.HSSI_PORT_0_STATUS_LinkFaultGenEn = this.HSSI_PORT_0_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_0_STATUS_RxBlockLock = this.HSSI_PORT_0_STATUS.RxBlockLock;
		this.HSSI_PORT_0_STATUS_RxAMLock = this.HSSI_PORT_0_STATUS.RxAMLock;
		this.HSSI_PORT_0_STATUS_CDRLock = this.HSSI_PORT_0_STATUS.CDRLock;
		this.HSSI_PORT_0_STATUS_RxHiBER = this.HSSI_PORT_0_STATUS.RxHiBER;
		this.HSSI_PORT_0_STATUS_EHIPReady = this.HSSI_PORT_0_STATUS.EHIPReady;
      this.HSSI_PORT_1_STATUS = ral_reg_ac_hssi_HSSI_PORT_1_STATUS::type_id::create("HSSI_PORT_1_STATUS",,get_full_name());
      this.HSSI_PORT_1_STATUS.configure(this, null, "");
      this.HSSI_PORT_1_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_1_STATUS, `UVM_REG_ADDR_WIDTH'hC4, "RW", 0);
		this.HSSI_PORT_1_STATUS_Reserved = this.HSSI_PORT_1_STATUS.Reserved;
		this.HSSI_PORT_1_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_1_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_1_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_1_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_1_STATUS_RX_PCS_READY = this.HSSI_PORT_1_STATUS.RX_PCS_READY;
		this.HSSI_PORT_1_STATUS_TX_LANES_STABLE = this.HSSI_PORT_1_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_1_STATUS_CAL_ERROR = this.HSSI_PORT_1_STATUS.CAL_ERROR;
		this.HSSI_PORT_1_STATUS_LOAD_ERROR = this.HSSI_PORT_1_STATUS.LOAD_ERROR;
		this.HSSI_PORT_1_STATUS_ETH_MODE = this.HSSI_PORT_1_STATUS.ETH_MODE;
		this.HSSI_PORT_1_STATUS_ENA_10 = this.HSSI_PORT_1_STATUS.ENA_10;
		this.HSSI_PORT_1_STATUS_SET_1000 = this.HSSI_PORT_1_STATUS.SET_1000;
		this.HSSI_PORT_1_STATUS_SET_10 = this.HSSI_PORT_1_STATUS.SET_10;
		this.HSSI_PORT_1_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_1_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_1_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_1_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_1_STATUS_RemoteFaultDsiable = this.HSSI_PORT_1_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_1_STATUS_ForceRemoteFault = this.HSSI_PORT_1_STATUS.ForceRemoteFault;
		this.HSSI_PORT_1_STATUS_RemoteFaultStatus = this.HSSI_PORT_1_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_1_STATUS_LocalFaultStatus = this.HSSI_PORT_1_STATUS.LocalFaultStatus;
		this.HSSI_PORT_1_STATUS_UndirectionalEn = this.HSSI_PORT_1_STATUS.UndirectionalEn;
		this.HSSI_PORT_1_STATUS_LinkFaultGenEn = this.HSSI_PORT_1_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_1_STATUS_RxBlockLock = this.HSSI_PORT_1_STATUS.RxBlockLock;
		this.HSSI_PORT_1_STATUS_RxAMLock = this.HSSI_PORT_1_STATUS.RxAMLock;
		this.HSSI_PORT_1_STATUS_CDRLock = this.HSSI_PORT_1_STATUS.CDRLock;
		this.HSSI_PORT_1_STATUS_RxHiBER = this.HSSI_PORT_1_STATUS.RxHiBER;
		this.HSSI_PORT_1_STATUS_EHIPReady = this.HSSI_PORT_1_STATUS.EHIPReady;
      this.HSSI_PORT_2_STATUS = ral_reg_ac_hssi_HSSI_PORT_2_STATUS::type_id::create("HSSI_PORT_2_STATUS",,get_full_name());
      this.HSSI_PORT_2_STATUS.configure(this, null, "");
      this.HSSI_PORT_2_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_2_STATUS, `UVM_REG_ADDR_WIDTH'hC8, "RW", 0);
		this.HSSI_PORT_2_STATUS_Reserved = this.HSSI_PORT_2_STATUS.Reserved;
		this.HSSI_PORT_2_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_2_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_2_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_2_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_2_STATUS_RX_PCS_READY = this.HSSI_PORT_2_STATUS.RX_PCS_READY;
		this.HSSI_PORT_2_STATUS_TX_LANES_STABLE = this.HSSI_PORT_2_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_2_STATUS_CAL_ERROR = this.HSSI_PORT_2_STATUS.CAL_ERROR;
		this.HSSI_PORT_2_STATUS_LOAD_ERROR = this.HSSI_PORT_2_STATUS.LOAD_ERROR;
		this.HSSI_PORT_2_STATUS_ETH_MODE = this.HSSI_PORT_2_STATUS.ETH_MODE;
		this.HSSI_PORT_2_STATUS_ENA_10 = this.HSSI_PORT_2_STATUS.ENA_10;
		this.HSSI_PORT_2_STATUS_SET_1000 = this.HSSI_PORT_2_STATUS.SET_1000;
		this.HSSI_PORT_2_STATUS_SET_10 = this.HSSI_PORT_2_STATUS.SET_10;
		this.HSSI_PORT_2_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_2_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_2_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_2_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_2_STATUS_RemoteFaultDsiable = this.HSSI_PORT_2_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_2_STATUS_ForceRemoteFault = this.HSSI_PORT_2_STATUS.ForceRemoteFault;
		this.HSSI_PORT_2_STATUS_RemoteFaultStatus = this.HSSI_PORT_2_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_2_STATUS_LocalFaultStatus = this.HSSI_PORT_2_STATUS.LocalFaultStatus;
		this.HSSI_PORT_2_STATUS_UndirectionalEn = this.HSSI_PORT_2_STATUS.UndirectionalEn;
		this.HSSI_PORT_2_STATUS_LinkFaultGenEn = this.HSSI_PORT_2_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_2_STATUS_RxBlockLock = this.HSSI_PORT_2_STATUS.RxBlockLock;
		this.HSSI_PORT_2_STATUS_RxAMLock = this.HSSI_PORT_2_STATUS.RxAMLock;
		this.HSSI_PORT_2_STATUS_CDRLock = this.HSSI_PORT_2_STATUS.CDRLock;
		this.HSSI_PORT_2_STATUS_RxHiBER = this.HSSI_PORT_2_STATUS.RxHiBER;
		this.HSSI_PORT_2_STATUS_EHIPReady = this.HSSI_PORT_2_STATUS.EHIPReady;
      this.HSSI_PORT_3_STATUS = ral_reg_ac_hssi_HSSI_PORT_3_STATUS::type_id::create("HSSI_PORT_3_STATUS",,get_full_name());
      this.HSSI_PORT_3_STATUS.configure(this, null, "");
      this.HSSI_PORT_3_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_3_STATUS, `UVM_REG_ADDR_WIDTH'hCC, "RW", 0);
		this.HSSI_PORT_3_STATUS_Reserved = this.HSSI_PORT_3_STATUS.Reserved;
		this.HSSI_PORT_3_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_3_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_3_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_3_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_3_STATUS_RX_PCS_READY = this.HSSI_PORT_3_STATUS.RX_PCS_READY;
		this.HSSI_PORT_3_STATUS_TX_LANES_STABLE = this.HSSI_PORT_3_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_3_STATUS_CAL_ERROR = this.HSSI_PORT_3_STATUS.CAL_ERROR;
		this.HSSI_PORT_3_STATUS_LOAD_ERROR = this.HSSI_PORT_3_STATUS.LOAD_ERROR;
		this.HSSI_PORT_3_STATUS_ETH_MODE = this.HSSI_PORT_3_STATUS.ETH_MODE;
		this.HSSI_PORT_3_STATUS_ENA_10 = this.HSSI_PORT_3_STATUS.ENA_10;
		this.HSSI_PORT_3_STATUS_SET_1000 = this.HSSI_PORT_3_STATUS.SET_1000;
		this.HSSI_PORT_3_STATUS_SET_10 = this.HSSI_PORT_3_STATUS.SET_10;
		this.HSSI_PORT_3_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_3_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_3_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_3_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_3_STATUS_RemoteFaultDsiable = this.HSSI_PORT_3_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_3_STATUS_ForceRemoteFault = this.HSSI_PORT_3_STATUS.ForceRemoteFault;
		this.HSSI_PORT_3_STATUS_RemoteFaultStatus = this.HSSI_PORT_3_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_3_STATUS_LocalFaultStatus = this.HSSI_PORT_3_STATUS.LocalFaultStatus;
		this.HSSI_PORT_3_STATUS_UndirectionalEn = this.HSSI_PORT_3_STATUS.UndirectionalEn;
		this.HSSI_PORT_3_STATUS_LinkFaultGenEn = this.HSSI_PORT_3_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_3_STATUS_RxBlockLock = this.HSSI_PORT_3_STATUS.RxBlockLock;
		this.HSSI_PORT_3_STATUS_RxAMLock = this.HSSI_PORT_3_STATUS.RxAMLock;
		this.HSSI_PORT_3_STATUS_CDRLock = this.HSSI_PORT_3_STATUS.CDRLock;
		this.HSSI_PORT_3_STATUS_RxHiBER = this.HSSI_PORT_3_STATUS.RxHiBER;
		this.HSSI_PORT_3_STATUS_EHIPReady = this.HSSI_PORT_3_STATUS.EHIPReady;
      this.HSSI_PORT_4_STATUS = ral_reg_ac_hssi_HSSI_PORT_4_STATUS::type_id::create("HSSI_PORT_4_STATUS",,get_full_name());
      this.HSSI_PORT_4_STATUS.configure(this, null, "");
      this.HSSI_PORT_4_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_4_STATUS, `UVM_REG_ADDR_WIDTH'hD0, "RW", 0);
		this.HSSI_PORT_4_STATUS_Reserved = this.HSSI_PORT_4_STATUS.Reserved;
		this.HSSI_PORT_4_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_4_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_4_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_4_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_4_STATUS_RX_PCS_READY = this.HSSI_PORT_4_STATUS.RX_PCS_READY;
		this.HSSI_PORT_4_STATUS_TX_LANES_STABLE = this.HSSI_PORT_4_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_4_STATUS_CAL_ERROR = this.HSSI_PORT_4_STATUS.CAL_ERROR;
		this.HSSI_PORT_4_STATUS_LOAD_ERROR = this.HSSI_PORT_4_STATUS.LOAD_ERROR;
		this.HSSI_PORT_4_STATUS_ETH_MODE = this.HSSI_PORT_4_STATUS.ETH_MODE;
		this.HSSI_PORT_4_STATUS_ENA_10 = this.HSSI_PORT_4_STATUS.ENA_10;
		this.HSSI_PORT_4_STATUS_SET_1000 = this.HSSI_PORT_4_STATUS.SET_1000;
		this.HSSI_PORT_4_STATUS_SET_10 = this.HSSI_PORT_4_STATUS.SET_10;
		this.HSSI_PORT_4_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_4_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_4_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_4_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_4_STATUS_RemoteFaultDsiable = this.HSSI_PORT_4_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_4_STATUS_ForceRemoteFault = this.HSSI_PORT_4_STATUS.ForceRemoteFault;
		this.HSSI_PORT_4_STATUS_RemoteFaultStatus = this.HSSI_PORT_4_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_4_STATUS_LocalFaultStatus = this.HSSI_PORT_4_STATUS.LocalFaultStatus;
		this.HSSI_PORT_4_STATUS_UndirectionalEn = this.HSSI_PORT_4_STATUS.UndirectionalEn;
		this.HSSI_PORT_4_STATUS_LinkFaultGenEn = this.HSSI_PORT_4_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_4_STATUS_RxBlockLock = this.HSSI_PORT_4_STATUS.RxBlockLock;
		this.HSSI_PORT_4_STATUS_RxAMLock = this.HSSI_PORT_4_STATUS.RxAMLock;
		this.HSSI_PORT_4_STATUS_CDRLock = this.HSSI_PORT_4_STATUS.CDRLock;
		this.HSSI_PORT_4_STATUS_RxHiBER = this.HSSI_PORT_4_STATUS.RxHiBER;
		this.HSSI_PORT_4_STATUS_EHIPReady = this.HSSI_PORT_4_STATUS.EHIPReady;
      this.HSSI_PORT_5_STATUS = ral_reg_ac_hssi_HSSI_PORT_5_STATUS::type_id::create("HSSI_PORT_5_STATUS",,get_full_name());
      this.HSSI_PORT_5_STATUS.configure(this, null, "");
      this.HSSI_PORT_5_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_5_STATUS, `UVM_REG_ADDR_WIDTH'hD4, "RW", 0);
		this.HSSI_PORT_5_STATUS_Reserved = this.HSSI_PORT_5_STATUS.Reserved;
		this.HSSI_PORT_5_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_5_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_5_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_5_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_5_STATUS_RX_PCS_READY = this.HSSI_PORT_5_STATUS.RX_PCS_READY;
		this.HSSI_PORT_5_STATUS_TX_LANES_STABLE = this.HSSI_PORT_5_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_5_STATUS_CAL_ERROR = this.HSSI_PORT_5_STATUS.CAL_ERROR;
		this.HSSI_PORT_5_STATUS_LOAD_ERROR = this.HSSI_PORT_5_STATUS.LOAD_ERROR;
		this.HSSI_PORT_5_STATUS_ETH_MODE = this.HSSI_PORT_5_STATUS.ETH_MODE;
		this.HSSI_PORT_5_STATUS_ENA_10 = this.HSSI_PORT_5_STATUS.ENA_10;
		this.HSSI_PORT_5_STATUS_SET_1000 = this.HSSI_PORT_5_STATUS.SET_1000;
		this.HSSI_PORT_5_STATUS_SET_10 = this.HSSI_PORT_5_STATUS.SET_10;
		this.HSSI_PORT_5_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_5_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_5_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_5_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_5_STATUS_RemoteFaultDsiable = this.HSSI_PORT_5_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_5_STATUS_ForceRemoteFault = this.HSSI_PORT_5_STATUS.ForceRemoteFault;
		this.HSSI_PORT_5_STATUS_RemoteFaultStatus = this.HSSI_PORT_5_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_5_STATUS_LocalFaultStatus = this.HSSI_PORT_5_STATUS.LocalFaultStatus;
		this.HSSI_PORT_5_STATUS_UndirectionalEn = this.HSSI_PORT_5_STATUS.UndirectionalEn;
		this.HSSI_PORT_5_STATUS_LinkFaultGenEn = this.HSSI_PORT_5_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_5_STATUS_RxBlockLock = this.HSSI_PORT_5_STATUS.RxBlockLock;
		this.HSSI_PORT_5_STATUS_RxAMLock = this.HSSI_PORT_5_STATUS.RxAMLock;
		this.HSSI_PORT_5_STATUS_CDRLock = this.HSSI_PORT_5_STATUS.CDRLock;
		this.HSSI_PORT_5_STATUS_RxHiBER = this.HSSI_PORT_5_STATUS.RxHiBER;
		this.HSSI_PORT_5_STATUS_EHIPReady = this.HSSI_PORT_5_STATUS.EHIPReady;
      this.HSSI_PORT_6_STATUS = ral_reg_ac_hssi_HSSI_PORT_6_STATUS::type_id::create("HSSI_PORT_6_STATUS",,get_full_name());
      this.HSSI_PORT_6_STATUS.configure(this, null, "");
      this.HSSI_PORT_6_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_6_STATUS, `UVM_REG_ADDR_WIDTH'hD8, "RW", 0);
		this.HSSI_PORT_6_STATUS_Reserved = this.HSSI_PORT_6_STATUS.Reserved;
		this.HSSI_PORT_6_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_6_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_6_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_6_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_6_STATUS_RX_PCS_READY = this.HSSI_PORT_6_STATUS.RX_PCS_READY;
		this.HSSI_PORT_6_STATUS_TX_LANES_STABLE = this.HSSI_PORT_6_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_6_STATUS_CAL_ERROR = this.HSSI_PORT_6_STATUS.CAL_ERROR;
		this.HSSI_PORT_6_STATUS_LOAD_ERROR = this.HSSI_PORT_6_STATUS.LOAD_ERROR;
		this.HSSI_PORT_6_STATUS_ETH_MODE = this.HSSI_PORT_6_STATUS.ETH_MODE;
		this.HSSI_PORT_6_STATUS_ENA_10 = this.HSSI_PORT_6_STATUS.ENA_10;
		this.HSSI_PORT_6_STATUS_SET_1000 = this.HSSI_PORT_6_STATUS.SET_1000;
		this.HSSI_PORT_6_STATUS_SET_10 = this.HSSI_PORT_6_STATUS.SET_10;
		this.HSSI_PORT_6_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_6_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_6_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_6_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_6_STATUS_RemoteFaultDsiable = this.HSSI_PORT_6_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_6_STATUS_ForceRemoteFault = this.HSSI_PORT_6_STATUS.ForceRemoteFault;
		this.HSSI_PORT_6_STATUS_RemoteFaultStatus = this.HSSI_PORT_6_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_6_STATUS_LocalFaultStatus = this.HSSI_PORT_6_STATUS.LocalFaultStatus;
		this.HSSI_PORT_6_STATUS_UndirectionalEn = this.HSSI_PORT_6_STATUS.UndirectionalEn;
		this.HSSI_PORT_6_STATUS_LinkFaultGenEn = this.HSSI_PORT_6_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_6_STATUS_RxBlockLock = this.HSSI_PORT_6_STATUS.RxBlockLock;
		this.HSSI_PORT_6_STATUS_RxAMLock = this.HSSI_PORT_6_STATUS.RxAMLock;
		this.HSSI_PORT_6_STATUS_CDRLock = this.HSSI_PORT_6_STATUS.CDRLock;
		this.HSSI_PORT_6_STATUS_RxHiBER = this.HSSI_PORT_6_STATUS.RxHiBER;
		this.HSSI_PORT_6_STATUS_EHIPReady = this.HSSI_PORT_6_STATUS.EHIPReady;
      this.HSSI_PORT_7_STATUS = ral_reg_ac_hssi_HSSI_PORT_7_STATUS::type_id::create("HSSI_PORT_7_STATUS",,get_full_name());
      this.HSSI_PORT_7_STATUS.configure(this, null, "");
      this.HSSI_PORT_7_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_7_STATUS, `UVM_REG_ADDR_WIDTH'hDC, "RW", 0);
		this.HSSI_PORT_7_STATUS_Reserved = this.HSSI_PORT_7_STATUS.Reserved;
		this.HSSI_PORT_7_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_7_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_7_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_7_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_7_STATUS_RX_PCS_READY = this.HSSI_PORT_7_STATUS.RX_PCS_READY;
		this.HSSI_PORT_7_STATUS_TX_LANES_STABLE = this.HSSI_PORT_7_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_7_STATUS_CAL_ERROR = this.HSSI_PORT_7_STATUS.CAL_ERROR;
		this.HSSI_PORT_7_STATUS_LOAD_ERROR = this.HSSI_PORT_7_STATUS.LOAD_ERROR;
		this.HSSI_PORT_7_STATUS_ETH_MODE = this.HSSI_PORT_7_STATUS.ETH_MODE;
		this.HSSI_PORT_7_STATUS_ENA_10 = this.HSSI_PORT_7_STATUS.ENA_10;
		this.HSSI_PORT_7_STATUS_SET_1000 = this.HSSI_PORT_7_STATUS.SET_1000;
		this.HSSI_PORT_7_STATUS_SET_10 = this.HSSI_PORT_7_STATUS.SET_10;
		this.HSSI_PORT_7_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_7_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_7_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_7_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_7_STATUS_RemoteFaultDsiable = this.HSSI_PORT_7_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_7_STATUS_ForceRemoteFault = this.HSSI_PORT_7_STATUS.ForceRemoteFault;
		this.HSSI_PORT_7_STATUS_RemoteFaultStatus = this.HSSI_PORT_7_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_7_STATUS_LocalFaultStatus = this.HSSI_PORT_7_STATUS.LocalFaultStatus;
		this.HSSI_PORT_7_STATUS_UndirectionalEn = this.HSSI_PORT_7_STATUS.UndirectionalEn;
		this.HSSI_PORT_7_STATUS_LinkFaultGenEn = this.HSSI_PORT_7_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_7_STATUS_RxBlockLock = this.HSSI_PORT_7_STATUS.RxBlockLock;
		this.HSSI_PORT_7_STATUS_RxAMLock = this.HSSI_PORT_7_STATUS.RxAMLock;
		this.HSSI_PORT_7_STATUS_CDRLock = this.HSSI_PORT_7_STATUS.CDRLock;
		this.HSSI_PORT_7_STATUS_RxHiBER = this.HSSI_PORT_7_STATUS.RxHiBER;
		this.HSSI_PORT_7_STATUS_EHIPReady = this.HSSI_PORT_7_STATUS.EHIPReady;
      `ifdef ENABLE_8_TO_15_PORTS
      this.HSSI_PORT_8_STATUS = ral_reg_ac_hssi_HSSI_PORT_8_STATUS::type_id::create("HSSI_PORT_8_STATUS",,get_full_name());
      this.HSSI_PORT_8_STATUS.configure(this, null, "");
      this.HSSI_PORT_8_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_8_STATUS, `UVM_REG_ADDR_WIDTH'hE0, "RW", 0);
		this.HSSI_PORT_8_STATUS_Reserved = this.HSSI_PORT_8_STATUS.Reserved;
		this.HSSI_PORT_8_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_8_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_8_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_8_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_8_STATUS_RX_PCS_READY = this.HSSI_PORT_8_STATUS.RX_PCS_READY;
		this.HSSI_PORT_8_STATUS_TX_LANES_STABLE = this.HSSI_PORT_8_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_8_STATUS_CAL_ERROR = this.HSSI_PORT_8_STATUS.CAL_ERROR;
		this.HSSI_PORT_8_STATUS_LOAD_ERROR = this.HSSI_PORT_8_STATUS.LOAD_ERROR;
		this.HSSI_PORT_8_STATUS_ETH_MODE = this.HSSI_PORT_8_STATUS.ETH_MODE;
		this.HSSI_PORT_8_STATUS_ENA_10 = this.HSSI_PORT_8_STATUS.ENA_10;
		this.HSSI_PORT_8_STATUS_SET_1000 = this.HSSI_PORT_8_STATUS.SET_1000;
		this.HSSI_PORT_8_STATUS_SET_10 = this.HSSI_PORT_8_STATUS.SET_10;
		this.HSSI_PORT_8_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_8_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_8_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_8_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_8_STATUS_RemoteFaultDsiable = this.HSSI_PORT_8_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_8_STATUS_ForceRemoteFault = this.HSSI_PORT_8_STATUS.ForceRemoteFault;
		this.HSSI_PORT_8_STATUS_RemoteFaultStatus = this.HSSI_PORT_8_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_8_STATUS_LocalFaultStatus = this.HSSI_PORT_8_STATUS.LocalFaultStatus;
		this.HSSI_PORT_8_STATUS_UndirectionalEn = this.HSSI_PORT_8_STATUS.UndirectionalEn;
		this.HSSI_PORT_8_STATUS_LinkFaultGenEn = this.HSSI_PORT_8_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_8_STATUS_RxBlockLock = this.HSSI_PORT_8_STATUS.RxBlockLock;
		this.HSSI_PORT_8_STATUS_RxAMLock = this.HSSI_PORT_8_STATUS.RxAMLock;
		this.HSSI_PORT_8_STATUS_CDRLock = this.HSSI_PORT_8_STATUS.CDRLock;
		this.HSSI_PORT_8_STATUS_RxHiBER = this.HSSI_PORT_8_STATUS.RxHiBER;
		this.HSSI_PORT_8_STATUS_EHIPReady = this.HSSI_PORT_8_STATUS.EHIPReady;
      this.HSSI_PORT_9_STATUS = ral_reg_ac_hssi_HSSI_PORT_9_STATUS::type_id::create("HSSI_PORT_9_STATUS",,get_full_name());
      this.HSSI_PORT_9_STATUS.configure(this, null, "");
      this.HSSI_PORT_9_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_9_STATUS, `UVM_REG_ADDR_WIDTH'hE4, "RW", 0);
		this.HSSI_PORT_9_STATUS_Reserved = this.HSSI_PORT_9_STATUS.Reserved;
		this.HSSI_PORT_9_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_9_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_9_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_9_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_9_STATUS_RX_PCS_READY = this.HSSI_PORT_9_STATUS.RX_PCS_READY;
		this.HSSI_PORT_9_STATUS_TX_LANES_STABLE = this.HSSI_PORT_9_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_9_STATUS_CAL_ERROR = this.HSSI_PORT_9_STATUS.CAL_ERROR;
		this.HSSI_PORT_9_STATUS_LOAD_ERROR = this.HSSI_PORT_9_STATUS.LOAD_ERROR;
		this.HSSI_PORT_9_STATUS_ETH_MODE = this.HSSI_PORT_9_STATUS.ETH_MODE;
		this.HSSI_PORT_9_STATUS_ENA_10 = this.HSSI_PORT_9_STATUS.ENA_10;
		this.HSSI_PORT_9_STATUS_SET_1000 = this.HSSI_PORT_9_STATUS.SET_1000;
		this.HSSI_PORT_9_STATUS_SET_10 = this.HSSI_PORT_9_STATUS.SET_10;
		this.HSSI_PORT_9_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_9_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_9_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_9_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_9_STATUS_RemoteFaultDsiable = this.HSSI_PORT_9_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_9_STATUS_ForceRemoteFault = this.HSSI_PORT_9_STATUS.ForceRemoteFault;
		this.HSSI_PORT_9_STATUS_RemoteFaultStatus = this.HSSI_PORT_9_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_9_STATUS_LocalFaultStatus = this.HSSI_PORT_9_STATUS.LocalFaultStatus;
		this.HSSI_PORT_9_STATUS_UndirectionalEn = this.HSSI_PORT_9_STATUS.UndirectionalEn;
		this.HSSI_PORT_9_STATUS_LinkFaultGenEn = this.HSSI_PORT_9_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_9_STATUS_RxBlockLock = this.HSSI_PORT_9_STATUS.RxBlockLock;
		this.HSSI_PORT_9_STATUS_RxAMLock = this.HSSI_PORT_9_STATUS.RxAMLock;
		this.HSSI_PORT_9_STATUS_CDRLock = this.HSSI_PORT_9_STATUS.CDRLock;
		this.HSSI_PORT_9_STATUS_RxHiBER = this.HSSI_PORT_9_STATUS.RxHiBER;
		this.HSSI_PORT_9_STATUS_EHIPReady = this.HSSI_PORT_9_STATUS.EHIPReady;
      this.HSSI_PORT_10_STATUS = ral_reg_ac_hssi_HSSI_PORT_10_STATUS::type_id::create("HSSI_PORT_10_STATUS",,get_full_name());
      this.HSSI_PORT_10_STATUS.configure(this, null, "");
      this.HSSI_PORT_10_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_10_STATUS, `UVM_REG_ADDR_WIDTH'hE8, "RW", 0);
		this.HSSI_PORT_10_STATUS_Reserved = this.HSSI_PORT_10_STATUS.Reserved;
		this.HSSI_PORT_10_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_10_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_10_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_10_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_10_STATUS_RX_PCS_READY = this.HSSI_PORT_10_STATUS.RX_PCS_READY;
		this.HSSI_PORT_10_STATUS_TX_LANES_STABLE = this.HSSI_PORT_10_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_10_STATUS_CAL_ERROR = this.HSSI_PORT_10_STATUS.CAL_ERROR;
		this.HSSI_PORT_10_STATUS_LOAD_ERROR = this.HSSI_PORT_10_STATUS.LOAD_ERROR;
		this.HSSI_PORT_10_STATUS_ETH_MODE = this.HSSI_PORT_10_STATUS.ETH_MODE;
		this.HSSI_PORT_10_STATUS_ENA_10 = this.HSSI_PORT_10_STATUS.ENA_10;
		this.HSSI_PORT_10_STATUS_SET_1000 = this.HSSI_PORT_10_STATUS.SET_1000;
		this.HSSI_PORT_10_STATUS_SET_10 = this.HSSI_PORT_10_STATUS.SET_10;
		this.HSSI_PORT_10_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_10_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_10_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_10_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_10_STATUS_RemoteFaultDsiable = this.HSSI_PORT_10_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_10_STATUS_ForceRemoteFault = this.HSSI_PORT_10_STATUS.ForceRemoteFault;
		this.HSSI_PORT_10_STATUS_RemoteFaultStatus = this.HSSI_PORT_10_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_10_STATUS_LocalFaultStatus = this.HSSI_PORT_10_STATUS.LocalFaultStatus;
		this.HSSI_PORT_10_STATUS_UndirectionalEn = this.HSSI_PORT_10_STATUS.UndirectionalEn;
		this.HSSI_PORT_10_STATUS_LinkFaultGenEn = this.HSSI_PORT_10_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_10_STATUS_RxBlockLock = this.HSSI_PORT_10_STATUS.RxBlockLock;
		this.HSSI_PORT_10_STATUS_RxAMLock = this.HSSI_PORT_10_STATUS.RxAMLock;
		this.HSSI_PORT_10_STATUS_CDRLock = this.HSSI_PORT_10_STATUS.CDRLock;
		this.HSSI_PORT_10_STATUS_RxHiBER = this.HSSI_PORT_10_STATUS.RxHiBER;
		this.HSSI_PORT_10_STATUS_EHIPReady = this.HSSI_PORT_10_STATUS.EHIPReady;
      this.HSSI_PORT_11_STATUS = ral_reg_ac_hssi_HSSI_PORT_11_STATUS::type_id::create("HSSI_PORT_11_STATUS",,get_full_name());
      this.HSSI_PORT_11_STATUS.configure(this, null, "");
      this.HSSI_PORT_11_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_11_STATUS, `UVM_REG_ADDR_WIDTH'hEC, "RW", 0);
		this.HSSI_PORT_11_STATUS_Reserved = this.HSSI_PORT_11_STATUS.Reserved;
		this.HSSI_PORT_11_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_11_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_11_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_11_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_11_STATUS_RX_PCS_READY = this.HSSI_PORT_11_STATUS.RX_PCS_READY;
		this.HSSI_PORT_11_STATUS_TX_LANES_STABLE = this.HSSI_PORT_11_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_11_STATUS_CAL_ERROR = this.HSSI_PORT_11_STATUS.CAL_ERROR;
		this.HSSI_PORT_11_STATUS_LOAD_ERROR = this.HSSI_PORT_11_STATUS.LOAD_ERROR;
		this.HSSI_PORT_11_STATUS_ETH_MODE = this.HSSI_PORT_11_STATUS.ETH_MODE;
		this.HSSI_PORT_11_STATUS_ENA_10 = this.HSSI_PORT_11_STATUS.ENA_10;
		this.HSSI_PORT_11_STATUS_SET_1000 = this.HSSI_PORT_11_STATUS.SET_1000;
		this.HSSI_PORT_11_STATUS_SET_10 = this.HSSI_PORT_11_STATUS.SET_10;
		this.HSSI_PORT_11_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_11_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_11_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_11_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_11_STATUS_RemoteFaultDsiable = this.HSSI_PORT_11_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_11_STATUS_ForceRemoteFault = this.HSSI_PORT_11_STATUS.ForceRemoteFault;
		this.HSSI_PORT_11_STATUS_RemoteFaultStatus = this.HSSI_PORT_11_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_11_STATUS_LocalFaultStatus = this.HSSI_PORT_11_STATUS.LocalFaultStatus;
		this.HSSI_PORT_11_STATUS_UndirectionalEn = this.HSSI_PORT_11_STATUS.UndirectionalEn;
		this.HSSI_PORT_11_STATUS_LinkFaultGenEn = this.HSSI_PORT_11_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_11_STATUS_RxBlockLock = this.HSSI_PORT_11_STATUS.RxBlockLock;
		this.HSSI_PORT_11_STATUS_RxAMLock = this.HSSI_PORT_11_STATUS.RxAMLock;
		this.HSSI_PORT_11_STATUS_CDRLock = this.HSSI_PORT_11_STATUS.CDRLock;
		this.HSSI_PORT_11_STATUS_RxHiBER = this.HSSI_PORT_11_STATUS.RxHiBER;
		this.HSSI_PORT_11_STATUS_EHIPReady = this.HSSI_PORT_11_STATUS.EHIPReady;
     this.HSSI_PORT_12_STATUS = ral_reg_ac_hssi_HSSI_PORT_12_STATUS::type_id::create("HSSI_PORT_12_STATUS",,get_full_name());
     this.HSSI_PORT_12_STATUS.configure(this, null, "");
     this.HSSI_PORT_12_STATUS.build();
     this.default_map.add_reg(this.HSSI_PORT_12_STATUS, `UVM_REG_ADDR_WIDTH'hF0, "RW", 0);
		this.HSSI_PORT_12_STATUS_Reserved = this.HSSI_PORT_12_STATUS.Reserved;
		this.HSSI_PORT_12_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_12_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_12_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_12_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_12_STATUS_RX_PCS_READY = this.HSSI_PORT_12_STATUS.RX_PCS_READY;
		this.HSSI_PORT_12_STATUS_TX_LANES_STABLE = this.HSSI_PORT_12_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_12_STATUS_CAL_ERROR = this.HSSI_PORT_12_STATUS.CAL_ERROR;
		this.HSSI_PORT_12_STATUS_LOAD_ERROR = this.HSSI_PORT_12_STATUS.LOAD_ERROR;
		this.HSSI_PORT_12_STATUS_ETH_MODE = this.HSSI_PORT_12_STATUS.ETH_MODE;
		this.HSSI_PORT_12_STATUS_ENA_10 = this.HSSI_PORT_12_STATUS.ENA_10;
		this.HSSI_PORT_12_STATUS_SET_1000 = this.HSSI_PORT_12_STATUS.SET_1000;
		this.HSSI_PORT_12_STATUS_SET_10 = this.HSSI_PORT_12_STATUS.SET_10;
		this.HSSI_PORT_12_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_12_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_12_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_12_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_12_STATUS_RemoteFaultDsiable = this.HSSI_PORT_12_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_12_STATUS_ForceRemoteFault = this.HSSI_PORT_12_STATUS.ForceRemoteFault;
		this.HSSI_PORT_12_STATUS_RemoteFaultStatus = this.HSSI_PORT_12_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_12_STATUS_LocalFaultStatus = this.HSSI_PORT_12_STATUS.LocalFaultStatus;
		this.HSSI_PORT_12_STATUS_UndirectionalEn = this.HSSI_PORT_12_STATUS.UndirectionalEn;
		this.HSSI_PORT_12_STATUS_LinkFaultGenEn = this.HSSI_PORT_12_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_12_STATUS_RxBlockLock = this.HSSI_PORT_12_STATUS.RxBlockLock;
		this.HSSI_PORT_12_STATUS_RxAMLock = this.HSSI_PORT_12_STATUS.RxAMLock;
		this.HSSI_PORT_12_STATUS_CDRLock = this.HSSI_PORT_12_STATUS.CDRLock;
		this.HSSI_PORT_12_STATUS_RxHiBER = this.HSSI_PORT_12_STATUS.RxHiBER;
		this.HSSI_PORT_12_STATUS_EHIPReady = this.HSSI_PORT_12_STATUS.EHIPReady;
      this.HSSI_PORT_13_STATUS = ral_reg_ac_hssi_HSSI_PORT_13_STATUS::type_id::create("HSSI_PORT_13_STATUS",,get_full_name());
      this.HSSI_PORT_13_STATUS.configure(this, null, "");
      this.HSSI_PORT_13_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_13_STATUS, `UVM_REG_ADDR_WIDTH'hF4, "RW", 0);
		this.HSSI_PORT_13_STATUS_Reserved = this.HSSI_PORT_13_STATUS.Reserved;
		this.HSSI_PORT_13_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_13_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_13_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_13_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_13_STATUS_RX_PCS_READY = this.HSSI_PORT_13_STATUS.RX_PCS_READY;
		this.HSSI_PORT_13_STATUS_TX_LANES_STABLE = this.HSSI_PORT_13_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_13_STATUS_CAL_ERROR = this.HSSI_PORT_13_STATUS.CAL_ERROR;
		this.HSSI_PORT_13_STATUS_LOAD_ERROR = this.HSSI_PORT_13_STATUS.LOAD_ERROR;
		this.HSSI_PORT_13_STATUS_ETH_MODE = this.HSSI_PORT_13_STATUS.ETH_MODE;
		this.HSSI_PORT_13_STATUS_ENA_10 = this.HSSI_PORT_13_STATUS.ENA_10;
		this.HSSI_PORT_13_STATUS_SET_1000 = this.HSSI_PORT_13_STATUS.SET_1000;
		this.HSSI_PORT_13_STATUS_SET_10 = this.HSSI_PORT_13_STATUS.SET_10;
		this.HSSI_PORT_13_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_13_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_13_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_13_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_13_STATUS_RemoteFaultDsiable = this.HSSI_PORT_13_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_13_STATUS_ForceRemoteFault = this.HSSI_PORT_13_STATUS.ForceRemoteFault;
		this.HSSI_PORT_13_STATUS_RemoteFaultStatus = this.HSSI_PORT_13_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_13_STATUS_LocalFaultStatus = this.HSSI_PORT_13_STATUS.LocalFaultStatus;
		this.HSSI_PORT_13_STATUS_UndirectionalEn = this.HSSI_PORT_13_STATUS.UndirectionalEn;
		this.HSSI_PORT_13_STATUS_LinkFaultGenEn = this.HSSI_PORT_13_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_13_STATUS_RxBlockLock = this.HSSI_PORT_13_STATUS.RxBlockLock;
		this.HSSI_PORT_13_STATUS_RxAMLock = this.HSSI_PORT_13_STATUS.RxAMLock;
		this.HSSI_PORT_13_STATUS_CDRLock = this.HSSI_PORT_13_STATUS.CDRLock;
		this.HSSI_PORT_13_STATUS_RxHiBER = this.HSSI_PORT_13_STATUS.RxHiBER;
		this.HSSI_PORT_13_STATUS_EHIPReady = this.HSSI_PORT_13_STATUS.EHIPReady;
      this.HSSI_PORT_14_STATUS = ral_reg_ac_hssi_HSSI_PORT_14_STATUS::type_id::create("HSSI_PORT_14_STATUS",,get_full_name());
      this.HSSI_PORT_14_STATUS.configure(this, null, "");
      this.HSSI_PORT_14_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_14_STATUS, `UVM_REG_ADDR_WIDTH'hF8, "RW", 0);
		this.HSSI_PORT_14_STATUS_Reserved = this.HSSI_PORT_14_STATUS.Reserved;
		this.HSSI_PORT_14_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_14_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_14_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_14_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_14_STATUS_RX_PCS_READY = this.HSSI_PORT_14_STATUS.RX_PCS_READY;
		this.HSSI_PORT_14_STATUS_TX_LANES_STABLE = this.HSSI_PORT_14_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_14_STATUS_CAL_ERROR = this.HSSI_PORT_14_STATUS.CAL_ERROR;
		this.HSSI_PORT_14_STATUS_LOAD_ERROR = this.HSSI_PORT_14_STATUS.LOAD_ERROR;
		this.HSSI_PORT_14_STATUS_ETH_MODE = this.HSSI_PORT_14_STATUS.ETH_MODE;
		this.HSSI_PORT_14_STATUS_ENA_10 = this.HSSI_PORT_14_STATUS.ENA_10;
		this.HSSI_PORT_14_STATUS_SET_1000 = this.HSSI_PORT_14_STATUS.SET_1000;
		this.HSSI_PORT_14_STATUS_SET_10 = this.HSSI_PORT_14_STATUS.SET_10;
		this.HSSI_PORT_14_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_14_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_14_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_14_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_14_STATUS_RemoteFaultDsiable = this.HSSI_PORT_14_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_14_STATUS_ForceRemoteFault = this.HSSI_PORT_14_STATUS.ForceRemoteFault;
		this.HSSI_PORT_14_STATUS_RemoteFaultStatus = this.HSSI_PORT_14_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_14_STATUS_LocalFaultStatus = this.HSSI_PORT_14_STATUS.LocalFaultStatus;
		this.HSSI_PORT_14_STATUS_UndirectionalEn = this.HSSI_PORT_14_STATUS.UndirectionalEn;
		this.HSSI_PORT_14_STATUS_LinkFaultGenEn = this.HSSI_PORT_14_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_14_STATUS_RxBlockLock = this.HSSI_PORT_14_STATUS.RxBlockLock;
		this.HSSI_PORT_14_STATUS_RxAMLock = this.HSSI_PORT_14_STATUS.RxAMLock;
		this.HSSI_PORT_14_STATUS_CDRLock = this.HSSI_PORT_14_STATUS.CDRLock;
		this.HSSI_PORT_14_STATUS_RxHiBER = this.HSSI_PORT_14_STATUS.RxHiBER;
		this.HSSI_PORT_14_STATUS_EHIPReady = this.HSSI_PORT_14_STATUS.EHIPReady;
      this.HSSI_PORT_15_STATUS = ral_reg_ac_hssi_HSSI_PORT_15_STATUS::type_id::create("HSSI_PORT_15_STATUS",,get_full_name());
      this.HSSI_PORT_15_STATUS.configure(this, null, "");
      this.HSSI_PORT_15_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_15_STATUS, `UVM_REG_ADDR_WIDTH'hFC, "RW", 0);
		this.HSSI_PORT_15_STATUS_Reserved = this.HSSI_PORT_15_STATUS.Reserved;
		this.HSSI_PORT_15_STATUS_EHIP_TX_PLL_LOCKED = this.HSSI_PORT_15_STATUS.EHIP_TX_PLL_LOCKED;
		this.HSSI_PORT_15_STATUS_TX_PLL_LOCKED = this.HSSI_PORT_15_STATUS.TX_PLL_LOCKED;
		this.HSSI_PORT_15_STATUS_RX_PCS_READY = this.HSSI_PORT_15_STATUS.RX_PCS_READY;
		this.HSSI_PORT_15_STATUS_TX_LANES_STABLE = this.HSSI_PORT_15_STATUS.TX_LANES_STABLE;
		this.HSSI_PORT_15_STATUS_CAL_ERROR = this.HSSI_PORT_15_STATUS.CAL_ERROR;
		this.HSSI_PORT_15_STATUS_LOAD_ERROR = this.HSSI_PORT_15_STATUS.LOAD_ERROR;
		this.HSSI_PORT_15_STATUS_ETH_MODE = this.HSSI_PORT_15_STATUS.ETH_MODE;
		this.HSSI_PORT_15_STATUS_ENA_10 = this.HSSI_PORT_15_STATUS.ENA_10;
		this.HSSI_PORT_15_STATUS_SET_1000 = this.HSSI_PORT_15_STATUS.SET_1000;
		this.HSSI_PORT_15_STATUS_SET_10 = this.HSSI_PORT_15_STATUS.SET_10;
		this.HSSI_PORT_15_STATUS_MAC_ECC_STATUS = this.HSSI_PORT_15_STATUS.MAC_ECC_STATUS;
		this.HSSI_PORT_15_STATUS_PCS_ECC_STATUS = this.HSSI_PORT_15_STATUS.PCS_ECC_STATUS;
		this.HSSI_PORT_15_STATUS_RemoteFaultDsiable = this.HSSI_PORT_15_STATUS.RemoteFaultDsiable;
		this.HSSI_PORT_15_STATUS_ForceRemoteFault = this.HSSI_PORT_15_STATUS.ForceRemoteFault;
		this.HSSI_PORT_15_STATUS_RemoteFaultStatus = this.HSSI_PORT_15_STATUS.RemoteFaultStatus;
		this.HSSI_PORT_15_STATUS_LocalFaultStatus = this.HSSI_PORT_15_STATUS.LocalFaultStatus;
		this.HSSI_PORT_15_STATUS_UndirectionalEn = this.HSSI_PORT_15_STATUS.UndirectionalEn;
		this.HSSI_PORT_15_STATUS_LinkFaultGenEn = this.HSSI_PORT_15_STATUS.LinkFaultGenEn;
		this.HSSI_PORT_15_STATUS_RxBlockLock = this.HSSI_PORT_15_STATUS.RxBlockLock;
		this.HSSI_PORT_15_STATUS_RxAMLock = this.HSSI_PORT_15_STATUS.RxAMLock;
		this.HSSI_PORT_15_STATUS_CDRLock = this.HSSI_PORT_15_STATUS.CDRLock;
		this.HSSI_PORT_15_STATUS_RxHiBER = this.HSSI_PORT_15_STATUS.RxHiBER;
		this.HSSI_PORT_15_STATUS_EHIPReady = this.HSSI_PORT_15_STATUS.EHIPReady;
      `endif
      this.HSSI_TSE_CTRL = ral_reg_ac_hssi_HSSI_TSE_CTRL::type_id::create("HSSI_TSE_CTRL",,get_full_name());
      this.HSSI_TSE_CTRL.configure(this, null, "");
      this.HSSI_TSE_CTRL.build();
      this.default_map.add_reg(this.HSSI_TSE_CTRL, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
		this.HSSI_TSE_CTRL_Reserved = this.HSSI_TSE_CTRL.Reserved;
		this.HSSI_TSE_CTRL_MagicSleep_N = this.HSSI_TSE_CTRL.MagicSleep_N;
		this.MagicSleep_N = this.HSSI_TSE_CTRL.MagicSleep_N;
		this.HSSI_TSE_CTRL_MagicWakeUp = this.HSSI_TSE_CTRL.MagicWakeUp;
		this.MagicWakeUp = this.HSSI_TSE_CTRL.MagicWakeUp;
      this.HSSI_DBG_CTRL = ral_reg_ac_hssi_HSSI_DBG_CTRL::type_id::create("HSSI_DBG_CTRL",,get_full_name());
      this.HSSI_DBG_CTRL.configure(this, null, "");
      this.HSSI_DBG_CTRL.build();
      this.default_map.add_reg(this.HSSI_DBG_CTRL, `UVM_REG_ADDR_WIDTH'h108, "RW", 0);
		this.HSSI_DBG_CTRL_Reserved = this.HSSI_DBG_CTRL.Reserved;
		this.HSSI_DBG_CTRL_LED_Blinking_Rate = this.HSSI_DBG_CTRL.LED_Blinking_Rate;
		this.LED_Blinking_Rate = this.HSSI_DBG_CTRL.LED_Blinking_Rate;
		this.HSSI_DBG_CTRL_LED_Status_Override_En = this.HSSI_DBG_CTRL.LED_Status_Override_En;
		this.LED_Status_Override_En = this.HSSI_DBG_CTRL.LED_Status_Override_En;
		this.HSSI_DBG_CTRL_Port_N_LED_Status_Override = this.HSSI_DBG_CTRL.Port_N_LED_Status_Override;
		this.Port_N_LED_Status_Override = this.HSSI_DBG_CTRL.Port_N_LED_Status_Override;
		this.HSSI_DBG_CTRL_Override_Port_N_LED_Status = this.HSSI_DBG_CTRL.Override_Port_N_LED_Status;
		this.Override_Port_N_LED_Status = this.HSSI_DBG_CTRL.Override_Port_N_LED_Status;
		this.HSSI_DBG_CTRL_Override_Port_N_LED_Speed = this.HSSI_DBG_CTRL.Override_Port_N_LED_Speed;
		this.Override_Port_N_LED_Speed = this.HSSI_DBG_CTRL.Override_Port_N_LED_Speed;
      this.HSSI_INDV_RST = ral_reg_ac_hssi_HSSI_INDV_RST::type_id::create("HSSI_INDV_RST",,get_full_name());
      this.HSSI_INDV_RST.configure(this, null, "");
      this.HSSI_INDV_RST.build();
      this.default_map.add_reg(this.HSSI_INDV_RST, `UVM_REG_ADDR_WIDTH'h800, "RW", 0);
		this.HSSI_INDV_RST_RxReset = this.HSSI_INDV_RST.RxReset;
		this.RxReset = this.HSSI_INDV_RST.RxReset;
		this.HSSI_INDV_RST_TxReset = this.HSSI_INDV_RST.TxReset;
		this.TxReset = this.HSSI_INDV_RST.TxReset;
		this.HSSI_INDV_RST_AxisRxReset = this.HSSI_INDV_RST.AxisRxReset;
		this.AxisRxReset = this.HSSI_INDV_RST.AxisRxReset;
		this.HSSI_INDV_RST_AxisTxReset = this.HSSI_INDV_RST.AxisTxReset;
		this.AxisTxReset = this.HSSI_INDV_RST.AxisTxReset;
      this.HSSI_INDV_RST_ACK = ral_reg_ac_hssi_HSSI_INDV_RST_ACK::type_id::create("HSSI_INDV_RST_ACK",,get_full_name());
      this.HSSI_INDV_RST_ACK.configure(this, null, "");
      this.HSSI_INDV_RST_ACK.build();
      this.default_map.add_reg(this.HSSI_INDV_RST_ACK, `UVM_REG_ADDR_WIDTH'h808, "RW", 0);
		this.HSSI_INDV_RST_ACK_Reserved = this.HSSI_INDV_RST_ACK.Reserved;
		this.HSSI_INDV_RST_ACK_RxResetAck = this.HSSI_INDV_RST_ACK.RxResetAck;
		this.RxResetAck = this.HSSI_INDV_RST_ACK.RxResetAck;
		this.HSSI_INDV_RST_ACK_TxResetAck = this.HSSI_INDV_RST_ACK.TxResetAck;
		this.TxResetAck = this.HSSI_INDV_RST_ACK.TxResetAck;
      this.HSSI_COLD_RST = ral_reg_ac_hssi_HSSI_COLD_RST::type_id::create("HSSI_COLD_RST",,get_full_name());
      this.HSSI_COLD_RST.configure(this, null, "");
      this.HSSI_COLD_RST.build();
      this.default_map.add_reg(this.HSSI_COLD_RST, `UVM_REG_ADDR_WIDTH'h810, "RW", 0);
		this.HSSI_COLD_RST_Reserved = this.HSSI_COLD_RST.Reserved;
		this.HSSI_COLD_RST_ColdResetAck = this.HSSI_COLD_RST.ColdResetAck;
		this.ColdResetAck = this.HSSI_COLD_RST.ColdResetAck;
		this.HSSI_COLD_RST_ColdReset = this.HSSI_COLD_RST.ColdReset;
		this.ColdReset = this.HSSI_COLD_RST.ColdReset;
      this.HSSI_STATUS = ral_reg_ac_hssi_HSSI_STATUS::type_id::create("HSSI_STATUS",,get_full_name());
      this.HSSI_STATUS.configure(this, null, "");
      this.HSSI_STATUS.build();
      this.default_map.add_reg(this.HSSI_STATUS, `UVM_REG_ADDR_WIDTH'h818, "RW", 0);
		this.HSSI_STATUS_Reserved = this.HSSI_STATUS.Reserved;
		this.HSSI_STATUS_RxPCSReady = this.HSSI_STATUS.RxPCSReady;
		this.RxPCSReady = this.HSSI_STATUS.RxPCSReady;
		this.HSSI_STATUS_TxLaneStable = this.HSSI_STATUS.TxLaneStable;
		this.TxLaneStable = this.HSSI_STATUS.TxLaneStable;
		this.HSSI_STATUS_TxPllLocked = this.HSSI_STATUS.TxPllLocked;
		this.TxPllLocked = this.HSSI_STATUS.TxPllLocked;
      this.HSSI_SCRATCHPAD = ral_reg_ac_hssi_HSSI_SCRATCHPAD::type_id::create("HSSI_SCRATCHPAD",,get_full_name());
      this.HSSI_SCRATCHPAD.configure(this, null, "");
      this.HSSI_SCRATCHPAD.build();
      this.default_map.add_reg(this.HSSI_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h820, "RW", 0);
		this.HSSI_SCRATCHPAD_Scartchpad = this.HSSI_SCRATCHPAD.Scartchpad;
		this.Scartchpad = this.HSSI_SCRATCHPAD.Scartchpad;
      this.HSSI_PTP_STATUS = ral_reg_ac_hssi_HSSI_PTP_STATUS::type_id::create("HSSI_PTP_STATUS",,get_full_name());
      this.HSSI_PTP_STATUS.configure(this, null, "");
      this.HSSI_PTP_STATUS.build();
      this.default_map.add_reg(this.HSSI_PTP_STATUS, `UVM_REG_ADDR_WIDTH'h828, "RW", 0);
		this.HSSI_PTP_STATUS_Reserved = this.HSSI_PTP_STATUS.Reserved;
		this.HSSI_PTP_STATUS_PTP_RX_READY = this.HSSI_PTP_STATUS.PTP_RX_READY;
		this.PTP_RX_READY = this.HSSI_PTP_STATUS.PTP_RX_READY;
		this.HSSI_PTP_STATUS_PTP_TX_READY = this.HSSI_PTP_STATUS.PTP_TX_READY;
		this.PTP_TX_READY = this.HSSI_PTP_STATUS.PTP_TX_READY;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_hssi)

endclass : ral_block_ac_hssi



`endif
