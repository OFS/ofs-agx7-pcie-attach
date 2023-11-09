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
      this.FeatureRevision.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureId = uvm_reg_field::type_id::create("FeatureId",,get_full_name());
      this.FeatureId.configure(this, 12, 0, "RO", 0, 12'h15, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_DFH_L)

endclass : ral_reg_ac_hssi_HSSI_DFH_L


class ral_reg_ac_hssi_HSSI_DFH_H extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset_H;

	function new(string name = "ac_hssi_HSSI_DFH_H");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 28, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 19, 9, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 8, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhOffset_H = uvm_reg_field::type_id::create("NextDfhOffset_H",,get_full_name());
      this.NextDfhOffset_H.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_DFH_H)

endclass : ral_reg_ac_hssi_HSSI_DFH_H


class ral_reg_ac_hssi_HSSI_VERSION extends uvm_reg;
	uvm_reg_field Major;
	uvm_reg_field Minor;
	rand uvm_reg_field Reserved;

	function new(string name = "ac_hssi_HSSI_VERSION");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Major = uvm_reg_field::type_id::create("Major",,get_full_name());
      this.Major.configure(this, 16, 16, "RO", 0, 16'h1, 1, 0, 1);
      this.Minor = uvm_reg_field::type_id::create("Minor",,get_full_name());
      this.Minor.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 8, 0, "WO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_VERSION)

endclass : ral_reg_ac_hssi_HSSI_VERSION


class ral_reg_ac_hssi_HSSI_FEATURE extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field NumPorts;
	uvm_reg_field ErrorMask;

	function new(string name = "ac_hssi_HSSI_FEATURE");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 27, 5, "WO", 0, 27'h0, 1, 0, 0);
      this.NumPorts = uvm_reg_field::type_id::create("NumPorts",,get_full_name());
      this.NumPorts.configure(this, 4, 1, "RO", 0, 4'h4, 1, 0, 0);
      this.ErrorMask = uvm_reg_field::type_id::create("ErrorMask",,get_full_name());
      this.ErrorMask.configure(this, 1, 0, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_FEATURE)

endclass : ral_reg_ac_hssi_HSSI_FEATURE


class ral_reg_ac_hssi_HSSI_PORT_0_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
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
      this.Reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h1, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h1, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h6, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_4_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_4_ATTR


class ral_reg_ac_hssi_HSSI_PORT_5_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
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
      this.Reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h1, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h1, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h6, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_5_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_5_ATTR


class ral_reg_ac_hssi_HSSI_PORT_6_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
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
      this.Reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h1, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h1, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h6, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_6_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_6_ATTR


class ral_reg_ac_hssi_HSSI_PORT_7_ATTR extends uvm_reg;
	rand uvm_reg_field Reserved;
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
      this.Reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.DRP = uvm_reg_field::type_id::create("DRP",,get_full_name());
      this.DRP.configure(this, 1, 15, "RO", 0, 1'h1, 1, 0, 0);
      this.LowSpeedParam = uvm_reg_field::type_id::create("LowSpeedParam",,get_full_name());
      this.LowSpeedParam.configure(this, 2, 13, "RO", 0, 2'h1, 1, 0, 0);
      this.DataBusWidth = uvm_reg_field::type_id::create("DataBusWidth",,get_full_name());
      this.DataBusWidth.configure(this, 3, 10, "RO", 0, 3'h1, 1, 0, 0);
      this.ReadyLatency = uvm_reg_field::type_id::create("ReadyLatency",,get_full_name());
      this.ReadyLatency.configure(this, 4, 6, "RO", 0, 4'h0, 1, 0, 0);
      this.Profile = uvm_reg_field::type_id::create("Profile",,get_full_name());
      this.Profile.configure(this, 6, 0, "RO", 0, 6'h6, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PORT_7_ATTR)

endclass : ral_reg_ac_hssi_HSSI_PORT_7_ATTR


class ral_reg_ac_hssi_HSSI_CMD_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved;
	uvm_reg_field Status;
	uvm_reg_field Ack;
	rand uvm_reg_field Write;
	rand uvm_reg_field Read;

	function new(string name = "ac_hssi_HSSI_CMD_STATUS");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 27, 5, "WO", 0, 27'h0, 1, 0, 0);
      this.Status = uvm_reg_field::type_id::create("Status",,get_full_name());
      this.Status.configure(this, 2, 3, "RO", 0, 2'h0, 1, 0, 0);
      this.Ack = uvm_reg_field::type_id::create("Ack",,get_full_name());
      this.Ack.configure(this, 1, 2, "RO", 0, 1'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
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
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
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
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
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
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
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
      this.LocalFaultStatus.configure(this, 1, 7, "RO", 0, 1'h1, 1, 0, 0);
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
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
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
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
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
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
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
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 0);
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


class ral_reg_ac_hssi_HSSI_TSE_CTRL extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field MagicSleep_N;
	uvm_reg_field MagicWakeUp;

	function new(string name = "ac_hssi_HSSI_TSE_CTRL");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 13, 19, "WO", 0, 13'h0, 1, 0, 1);
      this.MagicSleep_N = uvm_reg_field::type_id::create("MagicSleep_N",,get_full_name());
      this.MagicSleep_N.configure(this, 1, 1, "RW", 0, 1'h1, 1, 0, 0);
      this.MagicWakeUp = uvm_reg_field::type_id::create("MagicWakeUp",,get_full_name());
      this.MagicWakeUp.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_TSE_CTRL)

endclass : ral_reg_ac_hssi_HSSI_TSE_CTRL


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


class ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_0_to_3 extends uvm_reg;
	rand uvm_reg_field PTP_TX_TS_FP3;
	rand uvm_reg_field Reserved3;
	rand uvm_reg_field PTP_TX_TS_Req3;
	rand uvm_reg_field PTP_TX_TS_FP2;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field PTP_TX_TS_Req2;
	rand uvm_reg_field PTP_TX_TS_FP1;
	rand uvm_reg_field Reserved1;
	rand uvm_reg_field PTP_TX_TS_Req1;
	rand uvm_reg_field PTP_TX_TS_FP0;
	rand uvm_reg_field Reserved0;
	rand uvm_reg_field PTP_TX_TS_Req0;

	function new(string name = "ac_hssi_HSSI_PTP_TX_TS_REQ_CH_0_to_3");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_TS_FP3 = uvm_reg_field::type_id::create("PTP_TX_TS_FP3",,get_full_name());
      this.PTP_TX_TS_FP3.configure(this, 8, 56, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved3 = uvm_reg_field::type_id::create("Reserved3",,get_full_name());
      this.Reserved3.configure(this, 7, 49, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req3 = uvm_reg_field::type_id::create("PTP_TX_TS_Req3",,get_full_name());
      this.PTP_TX_TS_Req3.configure(this, 1, 48, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP2 = uvm_reg_field::type_id::create("PTP_TX_TS_FP2",,get_full_name());
      this.PTP_TX_TS_FP2.configure(this, 8, 40, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved2 = uvm_reg_field::type_id::create("Reserved2",,get_full_name());
      this.Reserved2.configure(this, 7, 33, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req2 = uvm_reg_field::type_id::create("PTP_TX_TS_Req2",,get_full_name());
      this.PTP_TX_TS_Req2.configure(this, 1, 32, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP1 = uvm_reg_field::type_id::create("PTP_TX_TS_FP1",,get_full_name());
      this.PTP_TX_TS_FP1.configure(this, 8, 24, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 7, 17, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req1 = uvm_reg_field::type_id::create("PTP_TX_TS_Req1",,get_full_name());
      this.PTP_TX_TS_Req1.configure(this, 1, 16, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP0 = uvm_reg_field::type_id::create("PTP_TX_TS_FP0",,get_full_name());
      this.PTP_TX_TS_FP0.configure(this, 8, 8, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req0 = uvm_reg_field::type_id::create("PTP_TX_TS_Req0",,get_full_name());
      this.PTP_TX_TS_Req0.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_0_to_3)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_0_to_3


class ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_4_to_7 extends uvm_reg;
	rand uvm_reg_field PTP_TX_TS_FP7;
	rand uvm_reg_field Reserved7;
	rand uvm_reg_field PTP_TX_TS_Req7;
	rand uvm_reg_field PTP_TX_TS_FP6;
	rand uvm_reg_field Reserved6;
	rand uvm_reg_field PTP_TX_TS_Req6;
	rand uvm_reg_field PTP_TX_TS_FP5;
	rand uvm_reg_field Reserved5;
	rand uvm_reg_field PTP_TX_TS_Req5;
	rand uvm_reg_field PTP_TX_TS_FP4;
	rand uvm_reg_field Reserved4;
	rand uvm_reg_field PTP_TX_TS_Req4;

	function new(string name = "ac_hssi_HSSI_PTP_TX_TS_REQ_CH_4_to_7");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_TS_FP7 = uvm_reg_field::type_id::create("PTP_TX_TS_FP7",,get_full_name());
      this.PTP_TX_TS_FP7.configure(this, 8, 56, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved7 = uvm_reg_field::type_id::create("Reserved7",,get_full_name());
      this.Reserved7.configure(this, 7, 49, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req7 = uvm_reg_field::type_id::create("PTP_TX_TS_Req7",,get_full_name());
      this.PTP_TX_TS_Req7.configure(this, 1, 48, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP6 = uvm_reg_field::type_id::create("PTP_TX_TS_FP6",,get_full_name());
      this.PTP_TX_TS_FP6.configure(this, 8, 40, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved6 = uvm_reg_field::type_id::create("Reserved6",,get_full_name());
      this.Reserved6.configure(this, 7, 33, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req6 = uvm_reg_field::type_id::create("PTP_TX_TS_Req6",,get_full_name());
      this.PTP_TX_TS_Req6.configure(this, 1, 32, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP5 = uvm_reg_field::type_id::create("PTP_TX_TS_FP5",,get_full_name());
      this.PTP_TX_TS_FP5.configure(this, 8, 24, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved5 = uvm_reg_field::type_id::create("Reserved5",,get_full_name());
      this.Reserved5.configure(this, 7, 17, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req5 = uvm_reg_field::type_id::create("PTP_TX_TS_Req5",,get_full_name());
      this.PTP_TX_TS_Req5.configure(this, 1, 16, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP4 = uvm_reg_field::type_id::create("PTP_TX_TS_FP4",,get_full_name());
      this.PTP_TX_TS_FP4.configure(this, 8, 8, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved4 = uvm_reg_field::type_id::create("Reserved4",,get_full_name());
      this.Reserved4.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req4 = uvm_reg_field::type_id::create("PTP_TX_TS_Req4",,get_full_name());
      this.PTP_TX_TS_Req4.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_4_to_7)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_4_to_7


class ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_8_to_11 extends uvm_reg;
	rand uvm_reg_field PTP_TX_TS_FP11;
	rand uvm_reg_field Reserved11;
	rand uvm_reg_field PTP_TX_TS_Req11;
	rand uvm_reg_field PTP_TX_TS_FP10;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field PTP_TX_TS_Req10;
	rand uvm_reg_field PTP_TX_TS_FP9;
	rand uvm_reg_field Reserved9;
	rand uvm_reg_field PTP_TX_TS_Req9;
	rand uvm_reg_field PTP_TX_TS_FP8;
	rand uvm_reg_field Reserved8;
	rand uvm_reg_field PTP_TX_TS_Req8;

	function new(string name = "ac_hssi_HSSI_PTP_TX_TS_REQ_CH_8_to_11");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_TS_FP11 = uvm_reg_field::type_id::create("PTP_TX_TS_FP11",,get_full_name());
      this.PTP_TX_TS_FP11.configure(this, 8, 56, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved11 = uvm_reg_field::type_id::create("Reserved11",,get_full_name());
      this.Reserved11.configure(this, 7, 49, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req11 = uvm_reg_field::type_id::create("PTP_TX_TS_Req11",,get_full_name());
      this.PTP_TX_TS_Req11.configure(this, 1, 48, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP10 = uvm_reg_field::type_id::create("PTP_TX_TS_FP10",,get_full_name());
      this.PTP_TX_TS_FP10.configure(this, 8, 40, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved10 = uvm_reg_field::type_id::create("Reserved10",,get_full_name());
      this.Reserved10.configure(this, 7, 33, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req10 = uvm_reg_field::type_id::create("PTP_TX_TS_Req10",,get_full_name());
      this.PTP_TX_TS_Req10.configure(this, 1, 32, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP9 = uvm_reg_field::type_id::create("PTP_TX_TS_FP9",,get_full_name());
      this.PTP_TX_TS_FP9.configure(this, 8, 24, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved9 = uvm_reg_field::type_id::create("Reserved9",,get_full_name());
      this.Reserved9.configure(this, 7, 17, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req9 = uvm_reg_field::type_id::create("PTP_TX_TS_Req9",,get_full_name());
      this.PTP_TX_TS_Req9.configure(this, 1, 16, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP8 = uvm_reg_field::type_id::create("PTP_TX_TS_FP8",,get_full_name());
      this.PTP_TX_TS_FP8.configure(this, 8, 8, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved8 = uvm_reg_field::type_id::create("Reserved8",,get_full_name());
      this.Reserved8.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req8 = uvm_reg_field::type_id::create("PTP_TX_TS_Req8",,get_full_name());
      this.PTP_TX_TS_Req8.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_8_to_11)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_8_to_11


class ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_12_to_15 extends uvm_reg;
	rand uvm_reg_field PTP_TX_TS_FP15;
	rand uvm_reg_field Reserved15;
	rand uvm_reg_field PTP_TX_TS_Req15;
	rand uvm_reg_field PTP_TX_TS_FP14;
	rand uvm_reg_field Reserved14;
	rand uvm_reg_field PTP_TX_TS_Req14;
	rand uvm_reg_field PTP_TX_TS_FP13;
	rand uvm_reg_field Reserved13;
	rand uvm_reg_field PTP_TX_TS_Req13;
	rand uvm_reg_field PTP_TX_TS_FP12;
	rand uvm_reg_field Reserved12;
	rand uvm_reg_field PTP_TX_TS_Req12;

	function new(string name = "ac_hssi_HSSI_PTP_TX_TS_REQ_CH_12_to_15");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_TS_FP15 = uvm_reg_field::type_id::create("PTP_TX_TS_FP15",,get_full_name());
      this.PTP_TX_TS_FP15.configure(this, 8, 56, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved15 = uvm_reg_field::type_id::create("Reserved15",,get_full_name());
      this.Reserved15.configure(this, 7, 49, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req15 = uvm_reg_field::type_id::create("PTP_TX_TS_Req15",,get_full_name());
      this.PTP_TX_TS_Req15.configure(this, 1, 48, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP14 = uvm_reg_field::type_id::create("PTP_TX_TS_FP14",,get_full_name());
      this.PTP_TX_TS_FP14.configure(this, 8, 40, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved14 = uvm_reg_field::type_id::create("Reserved14",,get_full_name());
      this.Reserved14.configure(this, 7, 33, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req14 = uvm_reg_field::type_id::create("PTP_TX_TS_Req14",,get_full_name());
      this.PTP_TX_TS_Req14.configure(this, 1, 32, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP13 = uvm_reg_field::type_id::create("PTP_TX_TS_FP13",,get_full_name());
      this.PTP_TX_TS_FP13.configure(this, 8, 24, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved13 = uvm_reg_field::type_id::create("Reserved13",,get_full_name());
      this.Reserved13.configure(this, 7, 17, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req13 = uvm_reg_field::type_id::create("PTP_TX_TS_Req13",,get_full_name());
      this.PTP_TX_TS_Req13.configure(this, 1, 16, "RW", 0, 1'h0, 1, 0, 0);
      this.PTP_TX_TS_FP12 = uvm_reg_field::type_id::create("PTP_TX_TS_FP12",,get_full_name());
      this.PTP_TX_TS_FP12.configure(this, 8, 8, "RW", 0, 8'h0, 1, 0, 1);
      this.Reserved12 = uvm_reg_field::type_id::create("Reserved12",,get_full_name());
      this.Reserved12.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_TS_Req12 = uvm_reg_field::type_id::create("PTP_TX_TS_Req12",,get_full_name());
      this.PTP_TX_TS_Req12.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_12_to_15)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_12_to_15


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH0_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH0_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH1_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH1_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH2_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH2_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH3_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH3_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH4_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH4_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH5_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH5_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH6_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH6_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH7_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH7_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH8_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH8_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH9_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH9_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH10_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH10_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH11_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH11_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH12_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH12_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH13_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH13_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH14_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH14_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_H


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_L extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_L32;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PTP_TX_ETS_FP;
	rand uvm_reg_field Reserved0;
	uvm_reg_field PTP_TX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH15_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_L32 = uvm_reg_field::type_id::create("PTP_TX_ETS_L32",,get_full_name());
      this.PTP_TX_ETS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 16, 16, "WO", 0, 16'h0, 1, 0, 1);
      this.PTP_TX_ETS_FP = uvm_reg_field::type_id::create("PTP_TX_ETS_FP",,get_full_name());
      this.PTP_TX_ETS_FP.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 7, 1, "WO", 0, 7'h0, 1, 0, 0);
      this.PTP_TX_READY = uvm_reg_field::type_id::create("PTP_TX_READY",,get_full_name());
      this.PTP_TX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_L


class ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_H extends uvm_reg;
	uvm_reg_field PTP_TX_ETS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_TX_ETS_CH15_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_TX_ETS_H64 = uvm_reg_field::type_id::create("PTP_TX_ETS_H64",,get_full_name());
      this.PTP_TX_ETS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH0_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH0_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH1_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH1_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH2_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH2_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH3_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH3_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH4_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH4_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH5_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH5_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH6_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH6_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH7_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH7_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH8_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH8_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH9_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH9_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH10_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH10_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH11_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH11_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH12_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH12_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH13_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH13_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH14_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH14_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_H


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_L extends uvm_reg;
	uvm_reg_field PTP_RX_TS_L32;
	rand uvm_reg_field Reserved;
	uvm_reg_field PTP_RX_READY;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH15_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_L32 = uvm_reg_field::type_id::create("PTP_RX_TS_L32",,get_full_name());
      this.PTP_RX_TS_L32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 31, 1, "WO", 0, 31'h0, 1, 0, 0);
      this.PTP_RX_READY = uvm_reg_field::type_id::create("PTP_RX_READY",,get_full_name());
      this.PTP_RX_READY.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_L)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_L


class ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_H extends uvm_reg;
	uvm_reg_field PTP_RX_TS_H64;

	function new(string name = "ac_hssi_HSSI_PTP_RX_TS_CH15_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.PTP_RX_TS_H64 = uvm_reg_field::type_id::create("PTP_RX_TS_H64",,get_full_name());
      this.PTP_RX_TS_H64.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_H)

endclass : ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_H


class ral_block_ac_hssi extends uvm_reg_block;
	rand ral_reg_ac_hssi_HSSI_DFH_L HSSI_DFH_L;
	rand ral_reg_ac_hssi_HSSI_DFH_H HSSI_DFH_H;
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
	rand ral_reg_ac_hssi_HSSI_CMD_STATUS HSSI_CMD_STATUS;
	rand ral_reg_ac_hssi_HSSI_CTRL_ADDR HSSI_CTRL_ADDR;
	rand ral_reg_ac_hssi_HSSI_WRITE_DATA HSSI_WRITE_DATA;
	rand ral_reg_ac_hssi_HSSI_READ_DATA HSSI_READ_DATA;
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
	rand ral_reg_ac_hssi_HSSI_TSE_CTRL HSSI_TSE_CTRL;
	rand ral_reg_ac_hssi_HSSI_INDV_RST HSSI_INDV_RST;
	rand ral_reg_ac_hssi_HSSI_INDV_RST_ACK HSSI_INDV_RST_ACK;
	rand ral_reg_ac_hssi_HSSI_COLD_RST HSSI_COLD_RST;
	rand ral_reg_ac_hssi_HSSI_STATUS HSSI_STATUS;
	rand ral_reg_ac_hssi_HSSI_SCRATCHPAD HSSI_SCRATCHPAD;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_0_to_3 HSSI_PTP_TX_TS_REQ_CH_0_to_3;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_4_to_7 HSSI_PTP_TX_TS_REQ_CH_4_to_7;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_8_to_11 HSSI_PTP_TX_TS_REQ_CH_8_to_11;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_12_to_15 HSSI_PTP_TX_TS_REQ_CH_12_to_15;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_L HSSI_PTP_TX_ETS_CH0_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_H HSSI_PTP_TX_ETS_CH0_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_L HSSI_PTP_TX_ETS_CH1_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_H HSSI_PTP_TX_ETS_CH1_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_L HSSI_PTP_TX_ETS_CH2_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_H HSSI_PTP_TX_ETS_CH2_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_L HSSI_PTP_TX_ETS_CH3_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_H HSSI_PTP_TX_ETS_CH3_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_L HSSI_PTP_TX_ETS_CH4_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_H HSSI_PTP_TX_ETS_CH4_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_L HSSI_PTP_TX_ETS_CH5_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_H HSSI_PTP_TX_ETS_CH5_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_L HSSI_PTP_TX_ETS_CH6_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_H HSSI_PTP_TX_ETS_CH6_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_L HSSI_PTP_TX_ETS_CH7_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_H HSSI_PTP_TX_ETS_CH7_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_L HSSI_PTP_TX_ETS_CH8_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_H HSSI_PTP_TX_ETS_CH8_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_L HSSI_PTP_TX_ETS_CH9_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_H HSSI_PTP_TX_ETS_CH9_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_L HSSI_PTP_TX_ETS_CH10_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_H HSSI_PTP_TX_ETS_CH10_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_L HSSI_PTP_TX_ETS_CH11_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_H HSSI_PTP_TX_ETS_CH11_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_L HSSI_PTP_TX_ETS_CH12_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_H HSSI_PTP_TX_ETS_CH12_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_L HSSI_PTP_TX_ETS_CH13_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_H HSSI_PTP_TX_ETS_CH13_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_L HSSI_PTP_TX_ETS_CH14_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_H HSSI_PTP_TX_ETS_CH14_H;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_L HSSI_PTP_TX_ETS_CH15_L;
	rand ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_H HSSI_PTP_TX_ETS_CH15_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_L HSSI_PTP_RX_TS_CH0_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_H HSSI_PTP_RX_TS_CH0_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_L HSSI_PTP_RX_TS_CH1_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_H HSSI_PTP_RX_TS_CH1_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_L HSSI_PTP_RX_TS_CH2_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_H HSSI_PTP_RX_TS_CH2_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_L HSSI_PTP_RX_TS_CH3_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_H HSSI_PTP_RX_TS_CH3_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_L HSSI_PTP_RX_TS_CH4_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_H HSSI_PTP_RX_TS_CH4_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_L HSSI_PTP_RX_TS_CH5_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_H HSSI_PTP_RX_TS_CH5_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_L HSSI_PTP_RX_TS_CH6_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_H HSSI_PTP_RX_TS_CH6_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_L HSSI_PTP_RX_TS_CH7_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_H HSSI_PTP_RX_TS_CH7_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_L HSSI_PTP_RX_TS_CH8_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_H HSSI_PTP_RX_TS_CH8_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_L HSSI_PTP_RX_TS_CH9_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_H HSSI_PTP_RX_TS_CH9_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_L HSSI_PTP_RX_TS_CH10_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_H HSSI_PTP_RX_TS_CH10_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_L HSSI_PTP_RX_TS_CH11_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_H HSSI_PTP_RX_TS_CH11_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_L HSSI_PTP_RX_TS_CH12_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_H HSSI_PTP_RX_TS_CH12_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_L HSSI_PTP_RX_TS_CH13_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_H HSSI_PTP_RX_TS_CH13_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_L HSSI_PTP_RX_TS_CH14_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_H HSSI_PTP_RX_TS_CH14_H;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_L HSSI_PTP_RX_TS_CH15_L;
	rand ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_H HSSI_PTP_RX_TS_CH15_H;
	uvm_reg_field HSSI_DFH_L_NextDfhOffset_L;
	uvm_reg_field NextDfhOffset_L;
	uvm_reg_field HSSI_DFH_L_FeatureRevision;
	uvm_reg_field FeatureRevision;
	uvm_reg_field HSSI_DFH_L_FeatureId;
	uvm_reg_field FeatureId;
	uvm_reg_field HSSI_DFH_H_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field HSSI_DFH_H_Reserved;
	uvm_reg_field HSSI_DFH_H_EOL;
	uvm_reg_field EOL;
	uvm_reg_field HSSI_DFH_H_NextDfhOffset_H;
	uvm_reg_field NextDfhOffset_H;
	uvm_reg_field HSSI_VERSION_Major;
	uvm_reg_field Major;
	uvm_reg_field HSSI_VERSION_Minor;
	uvm_reg_field Minor;
	rand uvm_reg_field HSSI_VERSION_Reserved;
	rand uvm_reg_field HSSI_FEATURE_Reserved;
	uvm_reg_field HSSI_FEATURE_NumPorts;
	uvm_reg_field NumPorts;
	uvm_reg_field HSSI_FEATURE_ErrorMask;
	uvm_reg_field ErrorMask;
	rand uvm_reg_field HSSI_PORT_0_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_0_ATTR_DRP;
	uvm_reg_field HSSI_PORT_0_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_0_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_0_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_0_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_1_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_1_ATTR_DRP;
	uvm_reg_field HSSI_PORT_1_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_1_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_1_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_1_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_2_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_2_ATTR_DRP;
	uvm_reg_field HSSI_PORT_2_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_2_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_2_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_2_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_3_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_3_ATTR_DRP;
	uvm_reg_field HSSI_PORT_3_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_3_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_3_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_3_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_4_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_4_ATTR_DRP;
	uvm_reg_field HSSI_PORT_4_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_4_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_4_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_4_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_5_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_5_ATTR_DRP;
	uvm_reg_field HSSI_PORT_5_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_5_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_5_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_5_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_6_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_6_ATTR_DRP;
	uvm_reg_field HSSI_PORT_6_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_6_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_6_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_6_ATTR_Profile;
	rand uvm_reg_field HSSI_PORT_7_ATTR_Reserved;
	uvm_reg_field HSSI_PORT_7_ATTR_DRP;
	uvm_reg_field HSSI_PORT_7_ATTR_LowSpeedParam;
	uvm_reg_field HSSI_PORT_7_ATTR_DataBusWidth;
	uvm_reg_field HSSI_PORT_7_ATTR_ReadyLatency;
	uvm_reg_field HSSI_PORT_7_ATTR_Profile;
	rand uvm_reg_field HSSI_CMD_STATUS_Reserved;
	uvm_reg_field HSSI_CMD_STATUS_Status;
	uvm_reg_field Status;
	uvm_reg_field HSSI_CMD_STATUS_Ack;
	uvm_reg_field Ack;
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
	rand uvm_reg_field HSSI_WRITE_DATA_WriteData;
	rand uvm_reg_field WriteData;
	rand uvm_reg_field HSSI_READ_DATA_ReadData;
	rand uvm_reg_field ReadData;
	rand uvm_reg_field HSSI_TX_LATENCY_Reserved;
	uvm_reg_field HSSI_TX_LATENCY_TxLatency;
	rand uvm_reg_field HSSI_RX_LATENCY_Reserved;
	uvm_reg_field HSSI_RX_LATENCY_TxLatency;
	rand uvm_reg_field HSSI_PORT_0_STATUS_Reserved;
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
	rand uvm_reg_field HSSI_TSE_CTRL_Reserved;
	rand uvm_reg_field HSSI_TSE_CTRL_MagicSleep_N;
	rand uvm_reg_field MagicSleep_N;
	uvm_reg_field HSSI_TSE_CTRL_MagicWakeUp;
	uvm_reg_field MagicWakeUp;
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
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_FP3;
	rand uvm_reg_field PTP_TX_TS_FP3;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_Reserved3;
	rand uvm_reg_field Reserved3;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_Req3;
	rand uvm_reg_field PTP_TX_TS_Req3;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_FP2;
	rand uvm_reg_field PTP_TX_TS_FP2;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_Reserved2;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_Req2;
	rand uvm_reg_field PTP_TX_TS_Req2;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_FP1;
	rand uvm_reg_field PTP_TX_TS_FP1;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_Reserved1;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_Req1;
	rand uvm_reg_field PTP_TX_TS_Req1;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_FP0;
	rand uvm_reg_field PTP_TX_TS_FP0;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_Reserved0;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_Req0;
	rand uvm_reg_field PTP_TX_TS_Req0;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_FP7;
	rand uvm_reg_field PTP_TX_TS_FP7;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_Reserved7;
	rand uvm_reg_field Reserved7;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_Req7;
	rand uvm_reg_field PTP_TX_TS_Req7;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_FP6;
	rand uvm_reg_field PTP_TX_TS_FP6;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_Reserved6;
	rand uvm_reg_field Reserved6;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_Req6;
	rand uvm_reg_field PTP_TX_TS_Req6;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_FP5;
	rand uvm_reg_field PTP_TX_TS_FP5;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_Reserved5;
	rand uvm_reg_field Reserved5;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_Req5;
	rand uvm_reg_field PTP_TX_TS_Req5;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_FP4;
	rand uvm_reg_field PTP_TX_TS_FP4;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_Reserved4;
	rand uvm_reg_field Reserved4;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_Req4;
	rand uvm_reg_field PTP_TX_TS_Req4;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_FP11;
	rand uvm_reg_field PTP_TX_TS_FP11;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_Reserved11;
	rand uvm_reg_field Reserved11;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_Req11;
	rand uvm_reg_field PTP_TX_TS_Req11;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_FP10;
	rand uvm_reg_field PTP_TX_TS_FP10;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_Reserved10;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_Req10;
	rand uvm_reg_field PTP_TX_TS_Req10;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_FP9;
	rand uvm_reg_field PTP_TX_TS_FP9;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_Reserved9;
	rand uvm_reg_field Reserved9;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_Req9;
	rand uvm_reg_field PTP_TX_TS_Req9;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_FP8;
	rand uvm_reg_field PTP_TX_TS_FP8;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_Reserved8;
	rand uvm_reg_field Reserved8;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_Req8;
	rand uvm_reg_field PTP_TX_TS_Req8;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_FP15;
	rand uvm_reg_field PTP_TX_TS_FP15;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_Reserved15;
	rand uvm_reg_field Reserved15;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_Req15;
	rand uvm_reg_field PTP_TX_TS_Req15;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_FP14;
	rand uvm_reg_field PTP_TX_TS_FP14;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_Reserved14;
	rand uvm_reg_field Reserved14;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_Req14;
	rand uvm_reg_field PTP_TX_TS_Req14;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_FP13;
	rand uvm_reg_field PTP_TX_TS_FP13;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_Reserved13;
	rand uvm_reg_field Reserved13;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_Req13;
	rand uvm_reg_field PTP_TX_TS_Req13;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_FP12;
	rand uvm_reg_field PTP_TX_TS_FP12;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_Reserved12;
	rand uvm_reg_field Reserved12;
	rand uvm_reg_field HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_Req12;
	rand uvm_reg_field PTP_TX_TS_Req12;
	uvm_reg_field HSSI_PTP_TX_ETS_CH0_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH0_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH0_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH0_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH0_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH0_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH1_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH1_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH1_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH1_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH1_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH1_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH2_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH2_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH2_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH2_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH2_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH2_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH3_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH3_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH3_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH3_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH3_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH3_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH4_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH4_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH4_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH4_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH4_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH4_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH5_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH5_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH5_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH5_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH5_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH5_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH6_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH6_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH6_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH6_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH6_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH6_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH7_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH7_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH7_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH7_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH7_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH7_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH8_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH8_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH8_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH8_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH8_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH8_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH9_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH9_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH9_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH9_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH9_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH9_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH10_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH10_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH10_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH10_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH10_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH10_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH11_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH11_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH11_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH11_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH11_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH11_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH12_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH12_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH12_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH12_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH12_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH12_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH13_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH13_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH13_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH13_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH13_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH13_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH14_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH14_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH14_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH14_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH14_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH14_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_TX_ETS_CH15_L_PTP_TX_ETS_L32;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH15_L_Reserved1;
	uvm_reg_field HSSI_PTP_TX_ETS_CH15_L_PTP_TX_ETS_FP;
	rand uvm_reg_field HSSI_PTP_TX_ETS_CH15_L_Reserved0;
	uvm_reg_field HSSI_PTP_TX_ETS_CH15_L_PTP_TX_READY;
	uvm_reg_field HSSI_PTP_TX_ETS_CH15_H_PTP_TX_ETS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH0_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH0_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH0_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH0_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH1_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH1_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH1_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH1_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH2_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH2_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH2_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH2_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH3_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH3_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH3_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH3_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH4_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH4_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH4_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH4_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH5_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH5_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH5_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH5_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH6_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH6_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH6_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH6_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH7_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH7_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH7_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH7_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH8_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH8_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH8_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH8_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH9_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH9_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH9_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH9_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH10_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH10_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH10_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH10_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH11_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH11_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH11_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH11_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH12_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH12_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH12_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH12_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH13_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH13_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH13_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH13_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH14_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH14_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH14_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH14_H_PTP_RX_TS_H64;
	uvm_reg_field HSSI_PTP_RX_TS_CH15_L_PTP_RX_TS_L32;
	rand uvm_reg_field HSSI_PTP_RX_TS_CH15_L_Reserved;
	uvm_reg_field HSSI_PTP_RX_TS_CH15_L_PTP_RX_READY;
	uvm_reg_field HSSI_PTP_RX_TS_CH15_H_PTP_RX_TS_H64;

	function new(string name = "ac_hssi");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.HSSI_DFH_L = ral_reg_ac_hssi_HSSI_DFH_L::type_id::create("HSSI_DFH_L",,get_full_name());
      this.HSSI_DFH_L.configure(this, null, "");
      this.HSSI_DFH_L.build();
      this.default_map.add_reg(this.HSSI_DFH_L, `UVM_REG_ADDR_WIDTH'h60000, "RO", 0);
		this.HSSI_DFH_L_NextDfhOffset_L = this.HSSI_DFH_L.NextDfhOffset_L;
		this.NextDfhOffset_L = this.HSSI_DFH_L.NextDfhOffset_L;
		this.HSSI_DFH_L_FeatureRevision = this.HSSI_DFH_L.FeatureRevision;
		this.FeatureRevision = this.HSSI_DFH_L.FeatureRevision;
		this.HSSI_DFH_L_FeatureId = this.HSSI_DFH_L.FeatureId;
		this.FeatureId = this.HSSI_DFH_L.FeatureId;
      this.HSSI_DFH_H = ral_reg_ac_hssi_HSSI_DFH_H::type_id::create("HSSI_DFH_H",,get_full_name());
      this.HSSI_DFH_H.configure(this, null, "");
      this.HSSI_DFH_H.build();
      this.default_map.add_reg(this.HSSI_DFH_H, `UVM_REG_ADDR_WIDTH'h60004, "RW", 0);
		this.HSSI_DFH_H_FeatureType = this.HSSI_DFH_H.FeatureType;
		this.FeatureType = this.HSSI_DFH_H.FeatureType;
		this.HSSI_DFH_H_Reserved = this.HSSI_DFH_H.Reserved;
		this.HSSI_DFH_H_EOL = this.HSSI_DFH_H.EOL;
		this.EOL = this.HSSI_DFH_H.EOL;
		this.HSSI_DFH_H_NextDfhOffset_H = this.HSSI_DFH_H.NextDfhOffset_H;
		this.NextDfhOffset_H = this.HSSI_DFH_H.NextDfhOffset_H;
      this.HSSI_VERSION = ral_reg_ac_hssi_HSSI_VERSION::type_id::create("HSSI_VERSION",,get_full_name());
      this.HSSI_VERSION.configure(this, null, "");
      this.HSSI_VERSION.build();
      this.default_map.add_reg(this.HSSI_VERSION, `UVM_REG_ADDR_WIDTH'h60008, "RW", 0);
		this.HSSI_VERSION_Major = this.HSSI_VERSION.Major;
		this.Major = this.HSSI_VERSION.Major;
		this.HSSI_VERSION_Minor = this.HSSI_VERSION.Minor;
		this.Minor = this.HSSI_VERSION.Minor;
		this.HSSI_VERSION_Reserved = this.HSSI_VERSION.Reserved;
      this.HSSI_FEATURE = ral_reg_ac_hssi_HSSI_FEATURE::type_id::create("HSSI_FEATURE",,get_full_name());
      this.HSSI_FEATURE.configure(this, null, "");
      this.HSSI_FEATURE.build();
      this.default_map.add_reg(this.HSSI_FEATURE, `UVM_REG_ADDR_WIDTH'h6000C, "RW", 0);
		this.HSSI_FEATURE_Reserved = this.HSSI_FEATURE.Reserved;
		this.HSSI_FEATURE_NumPorts = this.HSSI_FEATURE.NumPorts;
		this.NumPorts = this.HSSI_FEATURE.NumPorts;
		this.HSSI_FEATURE_ErrorMask = this.HSSI_FEATURE.ErrorMask;
		this.ErrorMask = this.HSSI_FEATURE.ErrorMask;
      this.HSSI_PORT_0_ATTR = ral_reg_ac_hssi_HSSI_PORT_0_ATTR::type_id::create("HSSI_PORT_0_ATTR",,get_full_name());
      this.HSSI_PORT_0_ATTR.configure(this, null, "");
      this.HSSI_PORT_0_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_0_ATTR, `UVM_REG_ADDR_WIDTH'h60010, "RW", 0);
		this.HSSI_PORT_0_ATTR_Reserved = this.HSSI_PORT_0_ATTR.Reserved;
		this.HSSI_PORT_0_ATTR_DRP = this.HSSI_PORT_0_ATTR.DRP;
		this.HSSI_PORT_0_ATTR_LowSpeedParam = this.HSSI_PORT_0_ATTR.LowSpeedParam;
		this.HSSI_PORT_0_ATTR_DataBusWidth = this.HSSI_PORT_0_ATTR.DataBusWidth;
		this.HSSI_PORT_0_ATTR_ReadyLatency = this.HSSI_PORT_0_ATTR.ReadyLatency;
		this.HSSI_PORT_0_ATTR_Profile = this.HSSI_PORT_0_ATTR.Profile;
      this.HSSI_PORT_1_ATTR = ral_reg_ac_hssi_HSSI_PORT_1_ATTR::type_id::create("HSSI_PORT_1_ATTR",,get_full_name());
      this.HSSI_PORT_1_ATTR.configure(this, null, "");
      this.HSSI_PORT_1_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_1_ATTR, `UVM_REG_ADDR_WIDTH'h60014, "RW", 0);
		this.HSSI_PORT_1_ATTR_Reserved = this.HSSI_PORT_1_ATTR.Reserved;
		this.HSSI_PORT_1_ATTR_DRP = this.HSSI_PORT_1_ATTR.DRP;
		this.HSSI_PORT_1_ATTR_LowSpeedParam = this.HSSI_PORT_1_ATTR.LowSpeedParam;
		this.HSSI_PORT_1_ATTR_DataBusWidth = this.HSSI_PORT_1_ATTR.DataBusWidth;
		this.HSSI_PORT_1_ATTR_ReadyLatency = this.HSSI_PORT_1_ATTR.ReadyLatency;
		this.HSSI_PORT_1_ATTR_Profile = this.HSSI_PORT_1_ATTR.Profile;
      this.HSSI_PORT_2_ATTR = ral_reg_ac_hssi_HSSI_PORT_2_ATTR::type_id::create("HSSI_PORT_2_ATTR",,get_full_name());
      this.HSSI_PORT_2_ATTR.configure(this, null, "");
      this.HSSI_PORT_2_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_2_ATTR, `UVM_REG_ADDR_WIDTH'h60018, "RW", 0);
		this.HSSI_PORT_2_ATTR_Reserved = this.HSSI_PORT_2_ATTR.Reserved;
		this.HSSI_PORT_2_ATTR_DRP = this.HSSI_PORT_2_ATTR.DRP;
		this.HSSI_PORT_2_ATTR_LowSpeedParam = this.HSSI_PORT_2_ATTR.LowSpeedParam;
		this.HSSI_PORT_2_ATTR_DataBusWidth = this.HSSI_PORT_2_ATTR.DataBusWidth;
		this.HSSI_PORT_2_ATTR_ReadyLatency = this.HSSI_PORT_2_ATTR.ReadyLatency;
		this.HSSI_PORT_2_ATTR_Profile = this.HSSI_PORT_2_ATTR.Profile;
      this.HSSI_PORT_3_ATTR = ral_reg_ac_hssi_HSSI_PORT_3_ATTR::type_id::create("HSSI_PORT_3_ATTR",,get_full_name());
      this.HSSI_PORT_3_ATTR.configure(this, null, "");
      this.HSSI_PORT_3_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_3_ATTR, `UVM_REG_ADDR_WIDTH'h6001C, "RW", 0);
		this.HSSI_PORT_3_ATTR_Reserved = this.HSSI_PORT_3_ATTR.Reserved;
		this.HSSI_PORT_3_ATTR_DRP = this.HSSI_PORT_3_ATTR.DRP;
		this.HSSI_PORT_3_ATTR_LowSpeedParam = this.HSSI_PORT_3_ATTR.LowSpeedParam;
		this.HSSI_PORT_3_ATTR_DataBusWidth = this.HSSI_PORT_3_ATTR.DataBusWidth;
		this.HSSI_PORT_3_ATTR_ReadyLatency = this.HSSI_PORT_3_ATTR.ReadyLatency;
		this.HSSI_PORT_3_ATTR_Profile = this.HSSI_PORT_3_ATTR.Profile;
      this.HSSI_PORT_4_ATTR = ral_reg_ac_hssi_HSSI_PORT_4_ATTR::type_id::create("HSSI_PORT_4_ATTR",,get_full_name());
      this.HSSI_PORT_4_ATTR.configure(this, null, "");
      this.HSSI_PORT_4_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_4_ATTR, `UVM_REG_ADDR_WIDTH'h60020, "RW", 0);
		this.HSSI_PORT_4_ATTR_Reserved = this.HSSI_PORT_4_ATTR.Reserved;
		this.HSSI_PORT_4_ATTR_DRP = this.HSSI_PORT_4_ATTR.DRP;
		this.HSSI_PORT_4_ATTR_LowSpeedParam = this.HSSI_PORT_4_ATTR.LowSpeedParam;
		this.HSSI_PORT_4_ATTR_DataBusWidth = this.HSSI_PORT_4_ATTR.DataBusWidth;
		this.HSSI_PORT_4_ATTR_ReadyLatency = this.HSSI_PORT_4_ATTR.ReadyLatency;
		this.HSSI_PORT_4_ATTR_Profile = this.HSSI_PORT_4_ATTR.Profile;
      this.HSSI_PORT_5_ATTR = ral_reg_ac_hssi_HSSI_PORT_5_ATTR::type_id::create("HSSI_PORT_5_ATTR",,get_full_name());
      this.HSSI_PORT_5_ATTR.configure(this, null, "");
      this.HSSI_PORT_5_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_5_ATTR, `UVM_REG_ADDR_WIDTH'h60024, "RW", 0);
		this.HSSI_PORT_5_ATTR_Reserved = this.HSSI_PORT_5_ATTR.Reserved;
		this.HSSI_PORT_5_ATTR_DRP = this.HSSI_PORT_5_ATTR.DRP;
		this.HSSI_PORT_5_ATTR_LowSpeedParam = this.HSSI_PORT_5_ATTR.LowSpeedParam;
		this.HSSI_PORT_5_ATTR_DataBusWidth = this.HSSI_PORT_5_ATTR.DataBusWidth;
		this.HSSI_PORT_5_ATTR_ReadyLatency = this.HSSI_PORT_5_ATTR.ReadyLatency;
		this.HSSI_PORT_5_ATTR_Profile = this.HSSI_PORT_5_ATTR.Profile;
      this.HSSI_PORT_6_ATTR = ral_reg_ac_hssi_HSSI_PORT_6_ATTR::type_id::create("HSSI_PORT_6_ATTR",,get_full_name());
      this.HSSI_PORT_6_ATTR.configure(this, null, "");
      this.HSSI_PORT_6_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_6_ATTR, `UVM_REG_ADDR_WIDTH'h60028, "RW", 0);
		this.HSSI_PORT_6_ATTR_Reserved = this.HSSI_PORT_6_ATTR.Reserved;
		this.HSSI_PORT_6_ATTR_DRP = this.HSSI_PORT_6_ATTR.DRP;
		this.HSSI_PORT_6_ATTR_LowSpeedParam = this.HSSI_PORT_6_ATTR.LowSpeedParam;
		this.HSSI_PORT_6_ATTR_DataBusWidth = this.HSSI_PORT_6_ATTR.DataBusWidth;
		this.HSSI_PORT_6_ATTR_ReadyLatency = this.HSSI_PORT_6_ATTR.ReadyLatency;
		this.HSSI_PORT_6_ATTR_Profile = this.HSSI_PORT_6_ATTR.Profile;
      this.HSSI_PORT_7_ATTR = ral_reg_ac_hssi_HSSI_PORT_7_ATTR::type_id::create("HSSI_PORT_7_ATTR",,get_full_name());
      this.HSSI_PORT_7_ATTR.configure(this, null, "");
      this.HSSI_PORT_7_ATTR.build();
      this.default_map.add_reg(this.HSSI_PORT_7_ATTR, `UVM_REG_ADDR_WIDTH'h6002C, "RW", 0);
		this.HSSI_PORT_7_ATTR_Reserved = this.HSSI_PORT_7_ATTR.Reserved;
		this.HSSI_PORT_7_ATTR_DRP = this.HSSI_PORT_7_ATTR.DRP;
		this.HSSI_PORT_7_ATTR_LowSpeedParam = this.HSSI_PORT_7_ATTR.LowSpeedParam;
		this.HSSI_PORT_7_ATTR_DataBusWidth = this.HSSI_PORT_7_ATTR.DataBusWidth;
		this.HSSI_PORT_7_ATTR_ReadyLatency = this.HSSI_PORT_7_ATTR.ReadyLatency;
		this.HSSI_PORT_7_ATTR_Profile = this.HSSI_PORT_7_ATTR.Profile;
      this.HSSI_CMD_STATUS = ral_reg_ac_hssi_HSSI_CMD_STATUS::type_id::create("HSSI_CMD_STATUS",,get_full_name());
      this.HSSI_CMD_STATUS.configure(this, null, "");
      this.HSSI_CMD_STATUS.build();
      this.default_map.add_reg(this.HSSI_CMD_STATUS, `UVM_REG_ADDR_WIDTH'h60050, "RW", 0);
		this.HSSI_CMD_STATUS_Reserved = this.HSSI_CMD_STATUS.Reserved;
		this.HSSI_CMD_STATUS_Status = this.HSSI_CMD_STATUS.Status;
		this.Status = this.HSSI_CMD_STATUS.Status;
		this.HSSI_CMD_STATUS_Ack = this.HSSI_CMD_STATUS.Ack;
		this.Ack = this.HSSI_CMD_STATUS.Ack;
		this.HSSI_CMD_STATUS_Write = this.HSSI_CMD_STATUS.Write;
		this.Write = this.HSSI_CMD_STATUS.Write;
		this.HSSI_CMD_STATUS_Read = this.HSSI_CMD_STATUS.Read;
		this.Read = this.HSSI_CMD_STATUS.Read;
      this.HSSI_CTRL_ADDR = ral_reg_ac_hssi_HSSI_CTRL_ADDR::type_id::create("HSSI_CTRL_ADDR",,get_full_name());
      this.HSSI_CTRL_ADDR.configure(this, null, "");
      this.HSSI_CTRL_ADDR.build();
      this.default_map.add_reg(this.HSSI_CTRL_ADDR, `UVM_REG_ADDR_WIDTH'h60054, "RW", 0);
		this.HSSI_CTRL_ADDR_HighAddress = this.HSSI_CTRL_ADDR.HighAddress;
		this.HighAddress = this.HSSI_CTRL_ADDR.HighAddress;
		this.HSSI_CTRL_ADDR_ChannelAddress = this.HSSI_CTRL_ADDR.ChannelAddress;
		this.ChannelAddress = this.HSSI_CTRL_ADDR.ChannelAddress;
		this.HSSI_CTRL_ADDR_PortAddress = this.HSSI_CTRL_ADDR.PortAddress;
		this.PortAddress = this.HSSI_CTRL_ADDR.PortAddress;
		this.HSSI_CTRL_ADDR_SAL = this.HSSI_CTRL_ADDR.SAL;
		this.SAL = this.HSSI_CTRL_ADDR.SAL;
      this.HSSI_WRITE_DATA = ral_reg_ac_hssi_HSSI_WRITE_DATA::type_id::create("HSSI_WRITE_DATA",,get_full_name());
      this.HSSI_WRITE_DATA.configure(this, null, "");
      this.HSSI_WRITE_DATA.build();
      this.default_map.add_reg(this.HSSI_WRITE_DATA, `UVM_REG_ADDR_WIDTH'h60058, "RW", 0);
		this.HSSI_WRITE_DATA_WriteData = this.HSSI_WRITE_DATA.WriteData;
		this.WriteData = this.HSSI_WRITE_DATA.WriteData;
      this.HSSI_READ_DATA = ral_reg_ac_hssi_HSSI_READ_DATA::type_id::create("HSSI_READ_DATA",,get_full_name());
      this.HSSI_READ_DATA.configure(this, null, "");
      this.HSSI_READ_DATA.build();
      this.default_map.add_reg(this.HSSI_READ_DATA, `UVM_REG_ADDR_WIDTH'h6005C, "RW", 0);
		this.HSSI_READ_DATA_ReadData = this.HSSI_READ_DATA.ReadData;
		this.ReadData = this.HSSI_READ_DATA.ReadData;
      this.HSSI_TX_LATENCY = ral_reg_ac_hssi_HSSI_TX_LATENCY::type_id::create("HSSI_TX_LATENCY",,get_full_name());
      this.HSSI_TX_LATENCY.configure(this, null, "");
      this.HSSI_TX_LATENCY.build();
      this.default_map.add_reg(this.HSSI_TX_LATENCY, `UVM_REG_ADDR_WIDTH'h60060, "RW", 0);
		this.HSSI_TX_LATENCY_Reserved = this.HSSI_TX_LATENCY.Reserved;
		this.HSSI_TX_LATENCY_TxLatency = this.HSSI_TX_LATENCY.TxLatency;
      this.HSSI_RX_LATENCY = ral_reg_ac_hssi_HSSI_RX_LATENCY::type_id::create("HSSI_RX_LATENCY",,get_full_name());
      this.HSSI_RX_LATENCY.configure(this, null, "");
      this.HSSI_RX_LATENCY.build();
      this.default_map.add_reg(this.HSSI_RX_LATENCY, `UVM_REG_ADDR_WIDTH'h60064, "RW", 0);
		this.HSSI_RX_LATENCY_Reserved = this.HSSI_RX_LATENCY.Reserved;
		this.HSSI_RX_LATENCY_TxLatency = this.HSSI_RX_LATENCY.TxLatency;
      this.HSSI_PORT_0_STATUS = ral_reg_ac_hssi_HSSI_PORT_0_STATUS::type_id::create("HSSI_PORT_0_STATUS",,get_full_name());
      this.HSSI_PORT_0_STATUS.configure(this, null, "");
      this.HSSI_PORT_0_STATUS.build();
      this.default_map.add_reg(this.HSSI_PORT_0_STATUS, `UVM_REG_ADDR_WIDTH'h60068, "RW", 0);
		this.HSSI_PORT_0_STATUS_Reserved = this.HSSI_PORT_0_STATUS.Reserved;
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
      this.default_map.add_reg(this.HSSI_PORT_1_STATUS, `UVM_REG_ADDR_WIDTH'h6006C, "RW", 0);
		this.HSSI_PORT_1_STATUS_Reserved = this.HSSI_PORT_1_STATUS.Reserved;
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
      this.default_map.add_reg(this.HSSI_PORT_2_STATUS, `UVM_REG_ADDR_WIDTH'h60070, "RW", 0);
		this.HSSI_PORT_2_STATUS_Reserved = this.HSSI_PORT_2_STATUS.Reserved;
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
      this.default_map.add_reg(this.HSSI_PORT_3_STATUS, `UVM_REG_ADDR_WIDTH'h60074, "RW", 0);
		this.HSSI_PORT_3_STATUS_Reserved = this.HSSI_PORT_3_STATUS.Reserved;
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
      this.default_map.add_reg(this.HSSI_PORT_4_STATUS, `UVM_REG_ADDR_WIDTH'h60078, "RW", 0);
		this.HSSI_PORT_4_STATUS_Reserved = this.HSSI_PORT_4_STATUS.Reserved;
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
      this.default_map.add_reg(this.HSSI_PORT_5_STATUS, `UVM_REG_ADDR_WIDTH'h6007C, "RW", 0);
		this.HSSI_PORT_5_STATUS_Reserved = this.HSSI_PORT_5_STATUS.Reserved;
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
      this.default_map.add_reg(this.HSSI_PORT_6_STATUS, `UVM_REG_ADDR_WIDTH'h60080, "RW", 0);
		this.HSSI_PORT_6_STATUS_Reserved = this.HSSI_PORT_6_STATUS.Reserved;
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
      this.default_map.add_reg(this.HSSI_PORT_7_STATUS, `UVM_REG_ADDR_WIDTH'h60084, "RW", 0);
		this.HSSI_PORT_7_STATUS_Reserved = this.HSSI_PORT_7_STATUS.Reserved;
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
      this.HSSI_TSE_CTRL = ral_reg_ac_hssi_HSSI_TSE_CTRL::type_id::create("HSSI_TSE_CTRL",,get_full_name());
      this.HSSI_TSE_CTRL.configure(this, null, "");
      this.HSSI_TSE_CTRL.build();
      this.default_map.add_reg(this.HSSI_TSE_CTRL, `UVM_REG_ADDR_WIDTH'h600A8, "RW", 0);
		this.HSSI_TSE_CTRL_Reserved = this.HSSI_TSE_CTRL.Reserved;
		this.HSSI_TSE_CTRL_MagicSleep_N = this.HSSI_TSE_CTRL.MagicSleep_N;
		this.MagicSleep_N = this.HSSI_TSE_CTRL.MagicSleep_N;
		this.HSSI_TSE_CTRL_MagicWakeUp = this.HSSI_TSE_CTRL.MagicWakeUp;
		this.MagicWakeUp = this.HSSI_TSE_CTRL.MagicWakeUp;
      this.HSSI_INDV_RST = ral_reg_ac_hssi_HSSI_INDV_RST::type_id::create("HSSI_INDV_RST",,get_full_name());
      this.HSSI_INDV_RST.configure(this, null, "");
      this.HSSI_INDV_RST.build();
      this.default_map.add_reg(this.HSSI_INDV_RST, `UVM_REG_ADDR_WIDTH'h60800, "RW", 0);
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
      this.default_map.add_reg(this.HSSI_INDV_RST_ACK, `UVM_REG_ADDR_WIDTH'h60808, "RW", 0);
		this.HSSI_INDV_RST_ACK_Reserved = this.HSSI_INDV_RST_ACK.Reserved;
		this.HSSI_INDV_RST_ACK_RxResetAck = this.HSSI_INDV_RST_ACK.RxResetAck;
		this.RxResetAck = this.HSSI_INDV_RST_ACK.RxResetAck;
		this.HSSI_INDV_RST_ACK_TxResetAck = this.HSSI_INDV_RST_ACK.TxResetAck;
		this.TxResetAck = this.HSSI_INDV_RST_ACK.TxResetAck;
      this.HSSI_COLD_RST = ral_reg_ac_hssi_HSSI_COLD_RST::type_id::create("HSSI_COLD_RST",,get_full_name());
      this.HSSI_COLD_RST.configure(this, null, "");
      this.HSSI_COLD_RST.build();
      this.default_map.add_reg(this.HSSI_COLD_RST, `UVM_REG_ADDR_WIDTH'h60810, "RW", 0);
		this.HSSI_COLD_RST_Reserved = this.HSSI_COLD_RST.Reserved;
		this.HSSI_COLD_RST_ColdResetAck = this.HSSI_COLD_RST.ColdResetAck;
		this.ColdResetAck = this.HSSI_COLD_RST.ColdResetAck;
		this.HSSI_COLD_RST_ColdReset = this.HSSI_COLD_RST.ColdReset;
		this.ColdReset = this.HSSI_COLD_RST.ColdReset;
      this.HSSI_STATUS = ral_reg_ac_hssi_HSSI_STATUS::type_id::create("HSSI_STATUS",,get_full_name());
      this.HSSI_STATUS.configure(this, null, "");
      this.HSSI_STATUS.build();
      this.default_map.add_reg(this.HSSI_STATUS, `UVM_REG_ADDR_WIDTH'h60818, "RW", 0);
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
      this.default_map.add_reg(this.HSSI_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h60820, "RW", 0);
		this.HSSI_SCRATCHPAD_Scartchpad = this.HSSI_SCRATCHPAD.Scartchpad;
		this.Scartchpad = this.HSSI_SCRATCHPAD.Scartchpad;
      this.HSSI_PTP_TX_TS_REQ_CH_0_to_3 = ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_0_to_3::type_id::create("HSSI_PTP_TX_TS_REQ_CH_0_to_3",,get_full_name());
      this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.configure(this, null, "");
      this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_TS_REQ_CH_0_to_3, `UVM_REG_ADDR_WIDTH'h60828, "RW", 0);
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_FP3 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_FP3;
		this.PTP_TX_TS_FP3 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_FP3;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_Reserved3 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.Reserved3;
		this.Reserved3 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.Reserved3;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_Req3 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_Req3;
		this.PTP_TX_TS_Req3 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_Req3;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_FP2 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_FP2;
		this.PTP_TX_TS_FP2 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_FP2;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_Reserved2 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.Reserved2;
		this.Reserved2 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.Reserved2;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_Req2 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_Req2;
		this.PTP_TX_TS_Req2 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_Req2;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_FP1 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_FP1;
		this.PTP_TX_TS_FP1 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_FP1;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_Reserved1 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.Reserved1;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_Req1 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_Req1;
		this.PTP_TX_TS_Req1 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_Req1;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_FP0 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_FP0;
		this.PTP_TX_TS_FP0 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_FP0;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_Reserved0 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.Reserved0;
		this.HSSI_PTP_TX_TS_REQ_CH_0_to_3_PTP_TX_TS_Req0 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_Req0;
		this.PTP_TX_TS_Req0 = this.HSSI_PTP_TX_TS_REQ_CH_0_to_3.PTP_TX_TS_Req0;
      this.HSSI_PTP_TX_TS_REQ_CH_4_to_7 = ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_4_to_7::type_id::create("HSSI_PTP_TX_TS_REQ_CH_4_to_7",,get_full_name());
      this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.configure(this, null, "");
      this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_TS_REQ_CH_4_to_7, `UVM_REG_ADDR_WIDTH'h60830, "RW", 0);
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_FP7 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_FP7;
		this.PTP_TX_TS_FP7 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_FP7;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_Reserved7 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.Reserved7;
		this.Reserved7 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.Reserved7;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_Req7 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_Req7;
		this.PTP_TX_TS_Req7 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_Req7;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_FP6 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_FP6;
		this.PTP_TX_TS_FP6 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_FP6;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_Reserved6 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.Reserved6;
		this.Reserved6 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.Reserved6;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_Req6 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_Req6;
		this.PTP_TX_TS_Req6 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_Req6;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_FP5 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_FP5;
		this.PTP_TX_TS_FP5 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_FP5;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_Reserved5 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.Reserved5;
		this.Reserved5 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.Reserved5;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_Req5 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_Req5;
		this.PTP_TX_TS_Req5 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_Req5;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_FP4 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_FP4;
		this.PTP_TX_TS_FP4 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_FP4;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_Reserved4 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.Reserved4;
		this.Reserved4 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.Reserved4;
		this.HSSI_PTP_TX_TS_REQ_CH_4_to_7_PTP_TX_TS_Req4 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_Req4;
		this.PTP_TX_TS_Req4 = this.HSSI_PTP_TX_TS_REQ_CH_4_to_7.PTP_TX_TS_Req4;
      this.HSSI_PTP_TX_TS_REQ_CH_8_to_11 = ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_8_to_11::type_id::create("HSSI_PTP_TX_TS_REQ_CH_8_to_11",,get_full_name());
      this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.configure(this, null, "");
      this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_TS_REQ_CH_8_to_11, `UVM_REG_ADDR_WIDTH'h60838, "RW", 0);
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_FP11 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_FP11;
		this.PTP_TX_TS_FP11 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_FP11;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_Reserved11 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.Reserved11;
		this.Reserved11 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.Reserved11;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_Req11 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_Req11;
		this.PTP_TX_TS_Req11 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_Req11;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_FP10 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_FP10;
		this.PTP_TX_TS_FP10 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_FP10;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_Reserved10 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.Reserved10;
		this.Reserved10 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.Reserved10;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_Req10 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_Req10;
		this.PTP_TX_TS_Req10 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_Req10;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_FP9 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_FP9;
		this.PTP_TX_TS_FP9 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_FP9;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_Reserved9 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.Reserved9;
		this.Reserved9 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.Reserved9;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_Req9 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_Req9;
		this.PTP_TX_TS_Req9 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_Req9;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_FP8 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_FP8;
		this.PTP_TX_TS_FP8 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_FP8;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_Reserved8 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.Reserved8;
		this.Reserved8 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.Reserved8;
		this.HSSI_PTP_TX_TS_REQ_CH_8_to_11_PTP_TX_TS_Req8 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_Req8;
		this.PTP_TX_TS_Req8 = this.HSSI_PTP_TX_TS_REQ_CH_8_to_11.PTP_TX_TS_Req8;
      this.HSSI_PTP_TX_TS_REQ_CH_12_to_15 = ral_reg_ac_hssi_HSSI_PTP_TX_TS_REQ_CH_12_to_15::type_id::create("HSSI_PTP_TX_TS_REQ_CH_12_to_15",,get_full_name());
      this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.configure(this, null, "");
      this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_TS_REQ_CH_12_to_15, `UVM_REG_ADDR_WIDTH'h60840, "RW", 0);
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_FP15 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_FP15;
		this.PTP_TX_TS_FP15 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_FP15;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_Reserved15 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.Reserved15;
		this.Reserved15 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.Reserved15;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_Req15 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_Req15;
		this.PTP_TX_TS_Req15 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_Req15;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_FP14 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_FP14;
		this.PTP_TX_TS_FP14 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_FP14;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_Reserved14 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.Reserved14;
		this.Reserved14 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.Reserved14;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_Req14 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_Req14;
		this.PTP_TX_TS_Req14 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_Req14;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_FP13 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_FP13;
		this.PTP_TX_TS_FP13 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_FP13;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_Reserved13 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.Reserved13;
		this.Reserved13 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.Reserved13;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_Req13 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_Req13;
		this.PTP_TX_TS_Req13 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_Req13;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_FP12 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_FP12;
		this.PTP_TX_TS_FP12 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_FP12;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_Reserved12 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.Reserved12;
		this.Reserved12 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.Reserved12;
		this.HSSI_PTP_TX_TS_REQ_CH_12_to_15_PTP_TX_TS_Req12 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_Req12;
		this.PTP_TX_TS_Req12 = this.HSSI_PTP_TX_TS_REQ_CH_12_to_15.PTP_TX_TS_Req12;
      this.HSSI_PTP_TX_ETS_CH0_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_L::type_id::create("HSSI_PTP_TX_ETS_CH0_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH0_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH0_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH0_L, `UVM_REG_ADDR_WIDTH'h60848, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH0_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH0_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH0_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH0_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH0_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH0_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH0_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH0_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH0_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH0_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH0_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH0_H::type_id::create("HSSI_PTP_TX_ETS_CH0_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH0_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH0_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH0_H, `UVM_REG_ADDR_WIDTH'h60850, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH0_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH0_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH1_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_L::type_id::create("HSSI_PTP_TX_ETS_CH1_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH1_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH1_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH1_L, `UVM_REG_ADDR_WIDTH'h60858, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH1_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH1_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH1_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH1_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH1_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH1_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH1_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH1_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH1_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH1_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH1_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH1_H::type_id::create("HSSI_PTP_TX_ETS_CH1_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH1_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH1_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH1_H, `UVM_REG_ADDR_WIDTH'h60860, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH1_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH1_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH2_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_L::type_id::create("HSSI_PTP_TX_ETS_CH2_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH2_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH2_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH2_L, `UVM_REG_ADDR_WIDTH'h60868, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH2_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH2_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH2_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH2_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH2_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH2_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH2_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH2_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH2_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH2_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH2_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH2_H::type_id::create("HSSI_PTP_TX_ETS_CH2_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH2_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH2_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH2_H, `UVM_REG_ADDR_WIDTH'h60870, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH2_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH2_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH3_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_L::type_id::create("HSSI_PTP_TX_ETS_CH3_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH3_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH3_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH3_L, `UVM_REG_ADDR_WIDTH'h60878, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH3_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH3_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH3_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH3_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH3_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH3_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH3_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH3_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH3_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH3_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH3_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH3_H::type_id::create("HSSI_PTP_TX_ETS_CH3_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH3_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH3_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH3_H, `UVM_REG_ADDR_WIDTH'h60880, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH3_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH3_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH4_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_L::type_id::create("HSSI_PTP_TX_ETS_CH4_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH4_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH4_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH4_L, `UVM_REG_ADDR_WIDTH'h60888, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH4_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH4_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH4_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH4_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH4_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH4_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH4_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH4_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH4_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH4_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH4_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH4_H::type_id::create("HSSI_PTP_TX_ETS_CH4_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH4_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH4_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH4_H, `UVM_REG_ADDR_WIDTH'h60890, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH4_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH4_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH5_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_L::type_id::create("HSSI_PTP_TX_ETS_CH5_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH5_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH5_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH5_L, `UVM_REG_ADDR_WIDTH'h60898, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH5_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH5_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH5_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH5_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH5_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH5_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH5_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH5_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH5_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH5_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH5_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH5_H::type_id::create("HSSI_PTP_TX_ETS_CH5_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH5_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH5_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH5_H, `UVM_REG_ADDR_WIDTH'h608A0, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH5_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH5_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH6_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_L::type_id::create("HSSI_PTP_TX_ETS_CH6_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH6_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH6_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH6_L, `UVM_REG_ADDR_WIDTH'h608A8, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH6_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH6_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH6_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH6_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH6_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH6_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH6_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH6_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH6_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH6_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH6_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH6_H::type_id::create("HSSI_PTP_TX_ETS_CH6_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH6_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH6_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH6_H, `UVM_REG_ADDR_WIDTH'h608B0, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH6_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH6_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH7_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_L::type_id::create("HSSI_PTP_TX_ETS_CH7_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH7_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH7_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH7_L, `UVM_REG_ADDR_WIDTH'h608B8, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH7_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH7_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH7_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH7_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH7_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH7_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH7_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH7_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH7_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH7_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH7_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH7_H::type_id::create("HSSI_PTP_TX_ETS_CH7_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH7_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH7_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH7_H, `UVM_REG_ADDR_WIDTH'h608C0, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH7_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH7_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH8_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_L::type_id::create("HSSI_PTP_TX_ETS_CH8_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH8_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH8_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH8_L, `UVM_REG_ADDR_WIDTH'h608C8, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH8_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH8_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH8_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH8_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH8_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH8_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH8_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH8_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH8_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH8_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH8_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH8_H::type_id::create("HSSI_PTP_TX_ETS_CH8_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH8_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH8_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH8_H, `UVM_REG_ADDR_WIDTH'h608D0, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH8_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH8_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH9_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_L::type_id::create("HSSI_PTP_TX_ETS_CH9_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH9_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH9_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH9_L, `UVM_REG_ADDR_WIDTH'h608D8, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH9_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH9_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH9_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH9_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH9_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH9_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH9_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH9_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH9_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH9_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH9_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH9_H::type_id::create("HSSI_PTP_TX_ETS_CH9_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH9_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH9_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH9_H, `UVM_REG_ADDR_WIDTH'h608E0, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH9_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH9_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH10_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_L::type_id::create("HSSI_PTP_TX_ETS_CH10_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH10_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH10_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH10_L, `UVM_REG_ADDR_WIDTH'h608E8, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH10_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH10_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH10_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH10_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH10_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH10_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH10_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH10_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH10_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH10_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH10_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH10_H::type_id::create("HSSI_PTP_TX_ETS_CH10_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH10_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH10_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH10_H, `UVM_REG_ADDR_WIDTH'h608F0, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH10_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH10_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH11_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_L::type_id::create("HSSI_PTP_TX_ETS_CH11_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH11_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH11_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH11_L, `UVM_REG_ADDR_WIDTH'h608F8, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH11_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH11_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH11_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH11_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH11_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH11_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH11_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH11_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH11_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH11_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH11_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH11_H::type_id::create("HSSI_PTP_TX_ETS_CH11_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH11_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH11_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH11_H, `UVM_REG_ADDR_WIDTH'h60900, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH11_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH11_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH12_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_L::type_id::create("HSSI_PTP_TX_ETS_CH12_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH12_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH12_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH12_L, `UVM_REG_ADDR_WIDTH'h60908, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH12_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH12_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH12_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH12_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH12_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH12_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH12_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH12_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH12_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH12_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH12_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH12_H::type_id::create("HSSI_PTP_TX_ETS_CH12_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH12_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH12_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH12_H, `UVM_REG_ADDR_WIDTH'h60910, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH12_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH12_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH13_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_L::type_id::create("HSSI_PTP_TX_ETS_CH13_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH13_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH13_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH13_L, `UVM_REG_ADDR_WIDTH'h60918, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH13_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH13_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH13_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH13_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH13_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH13_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH13_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH13_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH13_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH13_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH13_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH13_H::type_id::create("HSSI_PTP_TX_ETS_CH13_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH13_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH13_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH13_H, `UVM_REG_ADDR_WIDTH'h60920, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH13_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH13_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH14_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_L::type_id::create("HSSI_PTP_TX_ETS_CH14_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH14_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH14_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH14_L, `UVM_REG_ADDR_WIDTH'h60928, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH14_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH14_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH14_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH14_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH14_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH14_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH14_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH14_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH14_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH14_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH14_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH14_H::type_id::create("HSSI_PTP_TX_ETS_CH14_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH14_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH14_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH14_H, `UVM_REG_ADDR_WIDTH'h60930, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH14_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH14_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_TX_ETS_CH15_L = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_L::type_id::create("HSSI_PTP_TX_ETS_CH15_L",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH15_L.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH15_L.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH15_L, `UVM_REG_ADDR_WIDTH'h60938, "RW", 0);
		this.HSSI_PTP_TX_ETS_CH15_L_PTP_TX_ETS_L32 = this.HSSI_PTP_TX_ETS_CH15_L.PTP_TX_ETS_L32;
		this.HSSI_PTP_TX_ETS_CH15_L_Reserved1 = this.HSSI_PTP_TX_ETS_CH15_L.Reserved1;
		this.HSSI_PTP_TX_ETS_CH15_L_PTP_TX_ETS_FP = this.HSSI_PTP_TX_ETS_CH15_L.PTP_TX_ETS_FP;
		this.HSSI_PTP_TX_ETS_CH15_L_Reserved0 = this.HSSI_PTP_TX_ETS_CH15_L.Reserved0;
		this.HSSI_PTP_TX_ETS_CH15_L_PTP_TX_READY = this.HSSI_PTP_TX_ETS_CH15_L.PTP_TX_READY;
      this.HSSI_PTP_TX_ETS_CH15_H = ral_reg_ac_hssi_HSSI_PTP_TX_ETS_CH15_H::type_id::create("HSSI_PTP_TX_ETS_CH15_H",,get_full_name());
      this.HSSI_PTP_TX_ETS_CH15_H.configure(this, null, "");
      this.HSSI_PTP_TX_ETS_CH15_H.build();
      this.default_map.add_reg(this.HSSI_PTP_TX_ETS_CH15_H, `UVM_REG_ADDR_WIDTH'h60940, "RO", 0);
		this.HSSI_PTP_TX_ETS_CH15_H_PTP_TX_ETS_H64 = this.HSSI_PTP_TX_ETS_CH15_H.PTP_TX_ETS_H64;
      this.HSSI_PTP_RX_TS_CH0_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_L::type_id::create("HSSI_PTP_RX_TS_CH0_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH0_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH0_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH0_L, `UVM_REG_ADDR_WIDTH'h60948, "RW", 0);
		this.HSSI_PTP_RX_TS_CH0_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH0_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH0_L_Reserved = this.HSSI_PTP_RX_TS_CH0_L.Reserved;
		this.HSSI_PTP_RX_TS_CH0_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH0_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH0_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH0_H::type_id::create("HSSI_PTP_RX_TS_CH0_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH0_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH0_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH0_H, `UVM_REG_ADDR_WIDTH'h60950, "RO", 0);
		this.HSSI_PTP_RX_TS_CH0_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH0_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH1_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_L::type_id::create("HSSI_PTP_RX_TS_CH1_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH1_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH1_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH1_L, `UVM_REG_ADDR_WIDTH'h60958, "RW", 0);
		this.HSSI_PTP_RX_TS_CH1_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH1_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH1_L_Reserved = this.HSSI_PTP_RX_TS_CH1_L.Reserved;
		this.HSSI_PTP_RX_TS_CH1_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH1_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH1_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH1_H::type_id::create("HSSI_PTP_RX_TS_CH1_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH1_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH1_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH1_H, `UVM_REG_ADDR_WIDTH'h60960, "RO", 0);
		this.HSSI_PTP_RX_TS_CH1_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH1_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH2_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_L::type_id::create("HSSI_PTP_RX_TS_CH2_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH2_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH2_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH2_L, `UVM_REG_ADDR_WIDTH'h60968, "RW", 0);
		this.HSSI_PTP_RX_TS_CH2_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH2_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH2_L_Reserved = this.HSSI_PTP_RX_TS_CH2_L.Reserved;
		this.HSSI_PTP_RX_TS_CH2_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH2_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH2_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH2_H::type_id::create("HSSI_PTP_RX_TS_CH2_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH2_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH2_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH2_H, `UVM_REG_ADDR_WIDTH'h60970, "RO", 0);
		this.HSSI_PTP_RX_TS_CH2_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH2_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH3_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_L::type_id::create("HSSI_PTP_RX_TS_CH3_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH3_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH3_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH3_L, `UVM_REG_ADDR_WIDTH'h60978, "RW", 0);
		this.HSSI_PTP_RX_TS_CH3_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH3_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH3_L_Reserved = this.HSSI_PTP_RX_TS_CH3_L.Reserved;
		this.HSSI_PTP_RX_TS_CH3_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH3_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH3_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH3_H::type_id::create("HSSI_PTP_RX_TS_CH3_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH3_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH3_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH3_H, `UVM_REG_ADDR_WIDTH'h60980, "RO", 0);
		this.HSSI_PTP_RX_TS_CH3_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH3_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH4_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_L::type_id::create("HSSI_PTP_RX_TS_CH4_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH4_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH4_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH4_L, `UVM_REG_ADDR_WIDTH'h60988, "RW", 0);
		this.HSSI_PTP_RX_TS_CH4_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH4_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH4_L_Reserved = this.HSSI_PTP_RX_TS_CH4_L.Reserved;
		this.HSSI_PTP_RX_TS_CH4_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH4_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH4_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH4_H::type_id::create("HSSI_PTP_RX_TS_CH4_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH4_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH4_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH4_H, `UVM_REG_ADDR_WIDTH'h60990, "RO", 0);
		this.HSSI_PTP_RX_TS_CH4_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH4_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH5_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_L::type_id::create("HSSI_PTP_RX_TS_CH5_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH5_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH5_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH5_L, `UVM_REG_ADDR_WIDTH'h60998, "RW", 0);
		this.HSSI_PTP_RX_TS_CH5_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH5_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH5_L_Reserved = this.HSSI_PTP_RX_TS_CH5_L.Reserved;
		this.HSSI_PTP_RX_TS_CH5_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH5_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH5_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH5_H::type_id::create("HSSI_PTP_RX_TS_CH5_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH5_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH5_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH5_H, `UVM_REG_ADDR_WIDTH'h609A0, "RO", 0);
		this.HSSI_PTP_RX_TS_CH5_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH5_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH6_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_L::type_id::create("HSSI_PTP_RX_TS_CH6_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH6_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH6_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH6_L, `UVM_REG_ADDR_WIDTH'h609A8, "RW", 0);
		this.HSSI_PTP_RX_TS_CH6_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH6_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH6_L_Reserved = this.HSSI_PTP_RX_TS_CH6_L.Reserved;
		this.HSSI_PTP_RX_TS_CH6_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH6_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH6_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH6_H::type_id::create("HSSI_PTP_RX_TS_CH6_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH6_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH6_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH6_H, `UVM_REG_ADDR_WIDTH'h609B0, "RO", 0);
		this.HSSI_PTP_RX_TS_CH6_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH6_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH7_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_L::type_id::create("HSSI_PTP_RX_TS_CH7_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH7_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH7_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH7_L, `UVM_REG_ADDR_WIDTH'h609B8, "RW", 0);
		this.HSSI_PTP_RX_TS_CH7_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH7_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH7_L_Reserved = this.HSSI_PTP_RX_TS_CH7_L.Reserved;
		this.HSSI_PTP_RX_TS_CH7_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH7_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH7_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH7_H::type_id::create("HSSI_PTP_RX_TS_CH7_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH7_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH7_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH7_H, `UVM_REG_ADDR_WIDTH'h609C0, "RO", 0);
		this.HSSI_PTP_RX_TS_CH7_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH7_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH8_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_L::type_id::create("HSSI_PTP_RX_TS_CH8_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH8_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH8_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH8_L, `UVM_REG_ADDR_WIDTH'h609C8, "RW", 0);
		this.HSSI_PTP_RX_TS_CH8_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH8_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH8_L_Reserved = this.HSSI_PTP_RX_TS_CH8_L.Reserved;
		this.HSSI_PTP_RX_TS_CH8_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH8_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH8_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH8_H::type_id::create("HSSI_PTP_RX_TS_CH8_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH8_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH8_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH8_H, `UVM_REG_ADDR_WIDTH'h609D0, "RO", 0);
		this.HSSI_PTP_RX_TS_CH8_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH8_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH9_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_L::type_id::create("HSSI_PTP_RX_TS_CH9_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH9_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH9_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH9_L, `UVM_REG_ADDR_WIDTH'h609D8, "RW", 0);
		this.HSSI_PTP_RX_TS_CH9_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH9_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH9_L_Reserved = this.HSSI_PTP_RX_TS_CH9_L.Reserved;
		this.HSSI_PTP_RX_TS_CH9_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH9_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH9_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH9_H::type_id::create("HSSI_PTP_RX_TS_CH9_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH9_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH9_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH9_H, `UVM_REG_ADDR_WIDTH'h609E0, "RO", 0);
		this.HSSI_PTP_RX_TS_CH9_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH9_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH10_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_L::type_id::create("HSSI_PTP_RX_TS_CH10_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH10_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH10_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH10_L, `UVM_REG_ADDR_WIDTH'h609E8, "RW", 0);
		this.HSSI_PTP_RX_TS_CH10_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH10_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH10_L_Reserved = this.HSSI_PTP_RX_TS_CH10_L.Reserved;
		this.HSSI_PTP_RX_TS_CH10_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH10_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH10_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH10_H::type_id::create("HSSI_PTP_RX_TS_CH10_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH10_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH10_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH10_H, `UVM_REG_ADDR_WIDTH'h609F0, "RO", 0);
		this.HSSI_PTP_RX_TS_CH10_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH10_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH11_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_L::type_id::create("HSSI_PTP_RX_TS_CH11_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH11_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH11_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH11_L, `UVM_REG_ADDR_WIDTH'h609F8, "RW", 0);
		this.HSSI_PTP_RX_TS_CH11_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH11_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH11_L_Reserved = this.HSSI_PTP_RX_TS_CH11_L.Reserved;
		this.HSSI_PTP_RX_TS_CH11_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH11_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH11_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH11_H::type_id::create("HSSI_PTP_RX_TS_CH11_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH11_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH11_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH11_H, `UVM_REG_ADDR_WIDTH'h60A00, "RO", 0);
		this.HSSI_PTP_RX_TS_CH11_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH11_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH12_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_L::type_id::create("HSSI_PTP_RX_TS_CH12_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH12_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH12_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH12_L, `UVM_REG_ADDR_WIDTH'h60A08, "RW", 0);
		this.HSSI_PTP_RX_TS_CH12_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH12_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH12_L_Reserved = this.HSSI_PTP_RX_TS_CH12_L.Reserved;
		this.HSSI_PTP_RX_TS_CH12_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH12_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH12_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH12_H::type_id::create("HSSI_PTP_RX_TS_CH12_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH12_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH12_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH12_H, `UVM_REG_ADDR_WIDTH'h60A10, "RO", 0);
		this.HSSI_PTP_RX_TS_CH12_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH12_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH13_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_L::type_id::create("HSSI_PTP_RX_TS_CH13_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH13_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH13_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH13_L, `UVM_REG_ADDR_WIDTH'h60A18, "RW", 0);
		this.HSSI_PTP_RX_TS_CH13_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH13_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH13_L_Reserved = this.HSSI_PTP_RX_TS_CH13_L.Reserved;
		this.HSSI_PTP_RX_TS_CH13_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH13_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH13_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH13_H::type_id::create("HSSI_PTP_RX_TS_CH13_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH13_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH13_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH13_H, `UVM_REG_ADDR_WIDTH'h60A20, "RO", 0);
		this.HSSI_PTP_RX_TS_CH13_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH13_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH14_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_L::type_id::create("HSSI_PTP_RX_TS_CH14_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH14_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH14_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH14_L, `UVM_REG_ADDR_WIDTH'h60A28, "RW", 0);
		this.HSSI_PTP_RX_TS_CH14_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH14_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH14_L_Reserved = this.HSSI_PTP_RX_TS_CH14_L.Reserved;
		this.HSSI_PTP_RX_TS_CH14_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH14_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH14_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH14_H::type_id::create("HSSI_PTP_RX_TS_CH14_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH14_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH14_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH14_H, `UVM_REG_ADDR_WIDTH'h60A30, "RO", 0);
		this.HSSI_PTP_RX_TS_CH14_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH14_H.PTP_RX_TS_H64;
      this.HSSI_PTP_RX_TS_CH15_L = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_L::type_id::create("HSSI_PTP_RX_TS_CH15_L",,get_full_name());
      this.HSSI_PTP_RX_TS_CH15_L.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH15_L.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH15_L, `UVM_REG_ADDR_WIDTH'h60A38, "RW", 0);
		this.HSSI_PTP_RX_TS_CH15_L_PTP_RX_TS_L32 = this.HSSI_PTP_RX_TS_CH15_L.PTP_RX_TS_L32;
		this.HSSI_PTP_RX_TS_CH15_L_Reserved = this.HSSI_PTP_RX_TS_CH15_L.Reserved;
		this.HSSI_PTP_RX_TS_CH15_L_PTP_RX_READY = this.HSSI_PTP_RX_TS_CH15_L.PTP_RX_READY;
      this.HSSI_PTP_RX_TS_CH15_H = ral_reg_ac_hssi_HSSI_PTP_RX_TS_CH15_H::type_id::create("HSSI_PTP_RX_TS_CH15_H",,get_full_name());
      this.HSSI_PTP_RX_TS_CH15_H.configure(this, null, "");
      this.HSSI_PTP_RX_TS_CH15_H.build();
      this.default_map.add_reg(this.HSSI_PTP_RX_TS_CH15_H, `UVM_REG_ADDR_WIDTH'h60A40, "RO", 0);
		this.HSSI_PTP_RX_TS_CH15_H_PTP_RX_TS_H64 = this.HSSI_PTP_RX_TS_CH15_H.PTP_RX_TS_H64;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_hssi)

endclass : ral_block_ac_hssi



`endif
