// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_SRC_PORT_GASKET_AGILEX_PG
`define RAL_AC_SRC_PORT_GASKET_AGILEX_PG

import uvm_pkg::*;

class ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved52;
	uvm_reg_field AFUMinorRevNumber;
	rand uvm_reg_field Reserved41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	covergroup cg_vals ();
		option.per_instance = 1;
		FeatureType_value : coverpoint FeatureType.value[3:0] {
			option.weight = 16;
		}
		Reserved52_value : coverpoint Reserved52.value {
			bins min = { 8'h0 };
			bins max = { 8'hFF };
			bins others = { [8'h1:8'hFE] };
			option.weight = 3;
		}
		AFUMinorRevNumber_value : coverpoint AFUMinorRevNumber.value[3:0] {
			option.weight = 16;
		}
		Reserved41_value : coverpoint Reserved41.value {
			bins min = { 7'h0 };
			bins max = { 7'h7F };
			bins others = { [7'h1:7'h7E] };
			option.weight = 3;
		}
		EOL_value : coverpoint EOL.value[0:0] {
			option.weight = 2;
		}
		NextDfhByteOffset_value : coverpoint NextDfhByteOffset.value {
			bins min = { 24'h0 };
			bins max = { 24'hFFFFFF };
			bins others = { [24'h1:24'hFFFFFE] };
			option.weight = 3;
		}
		FeatureRev_value : coverpoint FeatureRev.value[3:0] {
			option.weight = 16;
		}
		FeatureID_value : coverpoint FeatureID.value {
			bins min = { 12'h0 };
			bins max = { 12'hFFF };
			bins others = { [12'h1:12'hFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PG_PR_DFH");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved52 = uvm_reg_field::type_id::create("Reserved52",,get_full_name());
      this.Reserved52.configure(this, 8, 52, "WO", 0, 8'h0, 1, 0, 0);
      this.AFUMinorRevNumber = uvm_reg_field::type_id::create("AFUMinorRevNumber",,get_full_name());
      this.AFUMinorRevNumber.configure(this, 4, 48, "RO", 0, 4'h0, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 7, 41, "WO", 0, 7'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h5, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DFH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DFH


class ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_CTRL extends uvm_reg;
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

	covergroup cg_vals ();
		option.per_instance = 1;
		TBD_value : coverpoint TBD.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		Reserved15_value : coverpoint Reserved15.value {
			bins min = { 17'h0 };
			bins max = { 17'h1FFFF };
			bins others = { [17'h1:17'h1FFFE] };
			option.weight = 3;
		}
		PRKind_value : coverpoint PRKind.value[0:0] {
			option.weight = 2;
		}
		PRDataPushComplete_value : coverpoint PRDataPushComplete.value[0:0] {
			option.weight = 2;
		}
		PRStartRequest_value : coverpoint PRStartRequest.value[0:0] {
			option.weight = 2;
		}
		Reserved10_value : coverpoint Reserved10.value[1:0] {
			option.weight = 4;
		}
		PRRegionId_value : coverpoint PRRegionId.value[1:0] {
			option.weight = 4;
		}
		Reserved5_value : coverpoint Reserved5.value[2:0] {
			option.weight = 8;
		}
		PRResetAck_value : coverpoint PRResetAck.value[0:0] {
			option.weight = 2;
		}
		Reserved1_value : coverpoint Reserved1.value[2:0] {
			option.weight = 8;
		}
		PRReset_value : coverpoint PRReset.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PG_PR_CTRL");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
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

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_CTRL)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_CTRL


class ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_STATUS extends uvm_reg;
	uvm_reg_field SecurityBlockStatus;
	rand uvm_reg_field Reserved28;
	uvm_reg_field PRHostStatus;
	rand uvm_reg_field Reserved23;
	uvm_reg_field AlteraPRCrtlrStatus;
	rand uvm_reg_field Reserved17;
	uvm_reg_field PRStatus;
	rand uvm_reg_field Reserved9;
	uvm_reg_field NumbCredits;

	covergroup cg_vals ();
		option.per_instance = 1;
		SecurityBlockStatus_value : coverpoint SecurityBlockStatus.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		Reserved28_value : coverpoint Reserved28.value[3:0] {
			option.weight = 16;
		}
		PRHostStatus_value : coverpoint PRHostStatus.value[3:0] {
			option.weight = 16;
		}
		Reserved23_value : coverpoint Reserved23.value[0:0] {
			option.weight = 2;
		}
		AlteraPRCrtlrStatus_value : coverpoint AlteraPRCrtlrStatus.value[2:0] {
			option.weight = 8;
		}
		Reserved17_value : coverpoint Reserved17.value[2:0] {
			option.weight = 8;
		}
		PRStatus_value : coverpoint PRStatus.value[0:0] {
			option.weight = 2;
		}
		Reserved9_value : coverpoint Reserved9.value {
			bins min = { 7'h0 };
			bins max = { 7'h7F };
			bins others = { [7'h1:7'h7E] };
			option.weight = 3;
		}
		NumbCredits_value : coverpoint NumbCredits.value {
			bins min = { 9'h0 };
			bins max = { 9'h1FF };
			bins others = { [9'h1:9'h1FE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PG_PR_STATUS");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
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
      this.NumbCredits.configure(this, 9, 0, "RO", 0, 9'h1ff, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_STATUS)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_STATUS


class ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DATA extends uvm_reg;
	rand uvm_reg_field PRData;

	covergroup cg_vals ();
		option.per_instance = 1;
		PRData_value : coverpoint PRData.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PG_PR_DATA");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.PRData = uvm_reg_field::type_id::create("PRData",,get_full_name());
      this.PRData.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DATA)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DATA


class ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_ERROR extends uvm_reg;
	rand uvm_reg_field Reserved7;
	rand uvm_reg_field SecureLoadFailed;
	rand uvm_reg_field HostInitTimeout;
	rand uvm_reg_field HostInitFIFOOverflow;
	rand uvm_reg_field IPInitProtocolError;
	rand uvm_reg_field IPInitIncompatibleBitstream;
	rand uvm_reg_field IPInitCRCError;
	rand uvm_reg_field HostInitOperationError;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved7_value : coverpoint Reserved7.value {
			bins min = { 57'h0 };
			bins max = { 57'h1FFFFFFFFFFFFFF };
			bins others = { [57'h1:57'h1FFFFFFFFFFFFFE] };
			option.weight = 3;
		}
		SecureLoadFailed_value : coverpoint SecureLoadFailed.value[0:0] {
			option.weight = 2;
		}
		HostInitTimeout_value : coverpoint HostInitTimeout.value[0:0] {
			option.weight = 2;
		}
		HostInitFIFOOverflow_value : coverpoint HostInitFIFOOverflow.value[0:0] {
			option.weight = 2;
		}
		IPInitProtocolError_value : coverpoint IPInitProtocolError.value[0:0] {
			option.weight = 2;
		}
		IPInitIncompatibleBitstream_value : coverpoint IPInitIncompatibleBitstream.value[0:0] {
			option.weight = 2;
		}
		IPInitCRCError_value : coverpoint IPInitCRCError.value[0:0] {
			option.weight = 2;
		}
		HostInitOperationError_value : coverpoint HostInitOperationError.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PG_PR_ERROR");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
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

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_ERROR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_ERROR


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5028 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5028");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5028)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5028


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5030 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5030");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5030)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5030


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5038 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5038");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5038)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5038


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5040 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5040");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5040)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5040


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5048 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5048");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5048)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5048


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5050 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5050");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5050)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5050


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5058 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5058");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5058)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5058


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5060 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5060");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5060)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5060


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5068 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5068");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5068)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5068


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5070 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5070");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5070)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5070


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5078 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5078");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5078)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5078


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5080 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5080");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5080)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5080


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5088 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5088");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5088)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5088


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5090 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5090");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5090)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5090


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5098 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_5098");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5098)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5098


class ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_50A0 extends uvm_reg;
	uvm_reg_field Zero;

	covergroup cg_vals ();
		option.per_instance = 1;
		Zero_value : coverpoint Zero.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_DUMMY_50A0");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Zero = uvm_reg_field::type_id::create("Zero",,get_full_name());
      this.Zero.configure(this, 64, 0, "RO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_50A0)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_50A0


class ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_L extends uvm_reg;
	uvm_reg_field InterfaceIdL;

	covergroup cg_vals ();
		option.per_instance = 1;
		InterfaceIdL_value : coverpoint InterfaceIdL.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_L");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.InterfaceIdL = uvm_reg_field::type_id::create("InterfaceIdL",,get_full_name());
      this.InterfaceIdL.configure(this, 64, 0, "RO", 0, 64'h2222222222222222, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_L)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_L


class ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_H extends uvm_reg;
	uvm_reg_field InterfaceIdH;

	covergroup cg_vals ();
		option.per_instance = 1;
		InterfaceIdH_value : coverpoint InterfaceIdH.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_H");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.InterfaceIdH = uvm_reg_field::type_id::create("InterfaceIdH",,get_full_name());
      this.InterfaceIdH.configure(this, 64, 0, "RO", 0, 64'heeeeeeeeeeeeeeee, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_H)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_H


class ral_reg_ac_src_port_gasket_agilex_pg_PG_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Reserved;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved_value : coverpoint Reserved.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PG_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PG_SCRATCHPAD)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PG_SCRATCHPAD


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field AfuMajVersion;
	uvm_reg_field CorefimVersion;

	covergroup cg_vals ();
		option.per_instance = 1;
		FeatureType_value : coverpoint FeatureType.value[3:0] {
			option.weight = 16;
		}
		Reserved41_value : coverpoint Reserved41.value {
			bins min = { 19'h0 };
			bins max = { 19'h7FFFF };
			bins others = { [19'h1:19'h7FFFE] };
			option.weight = 3;
		}
		EOL_value : coverpoint EOL.value[0:0] {
			option.weight = 2;
		}
		NextDfhOffset_value : coverpoint NextDfhOffset.value {
			bins min = { 24'h0 };
			bins max = { 24'hFFFFFF };
			bins others = { [24'h1:24'hFFFFFE] };
			option.weight = 3;
		}
		AfuMajVersion_value : coverpoint AfuMajVersion.value[3:0] {
			option.weight = 16;
		}
		CorefimVersion_value : coverpoint CorefimVersion.value {
			bins min = { 12'h0 };
			bins max = { 12'hFFF };
			bins others = { [12'h1:12'hFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_DFH");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
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
      this.AfuMajVersion = uvm_reg_field::type_id::create("AfuMajVersion",,get_full_name());
      this.AfuMajVersion.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.CorefimVersion = uvm_reg_field::type_id::create("CorefimVersion",,get_full_name());
      this.CorefimVersion.configure(this, 12, 0, "RO", 0, 12'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_DFH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_DFH


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_L extends uvm_reg;
	uvm_reg_field PortIdLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		PortIdLow_value : coverpoint PortIdLow.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_AFU_ID_L");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.PortIdLow = uvm_reg_field::type_id::create("PortIdLow",,get_full_name());
      this.PortIdLow.configure(this, 64, 0, "RO", 0, 64'h9642b06c6b355b87, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_L)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_L


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_H extends uvm_reg;
	uvm_reg_field PortIdHigh;

	covergroup cg_vals ();
		option.per_instance = 1;
		PortIdHigh_value : coverpoint PortIdHigh.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_AFU_ID_H");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.PortIdHigh = uvm_reg_field::type_id::create("PortIdHigh",,get_full_name());
      this.PortIdHigh.configure(this, 64, 0, "RO", 0, 64'h3ab49893138d42eb, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_H)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_H


class ral_reg_ac_src_port_gasket_agilex_pg_FIRST_AFU_OFFSET extends uvm_reg;
	rand uvm_reg_field Reserved24;
	uvm_reg_field PortAfuDfhOffset;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved24_value : coverpoint Reserved24.value {
			bins min = { 40'h0 };
			bins max = { 40'hFFFFFFFFFF };
			bins others = { [40'h1:40'hFFFFFFFFFE] };
			option.weight = 3;
		}
		PortAfuDfhOffset_value : coverpoint PortAfuDfhOffset.value {
			bins min = { 24'h0 };
			bins max = { 24'hFFFFFF };
			bins others = { [24'h1:24'hFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_FIRST_AFU_OFFSET");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved24 = uvm_reg_field::type_id::create("Reserved24",,get_full_name());
      this.Reserved24.configure(this, 40, 24, "WO", 0, 40'h000000000, 1, 0, 1);
      this.PortAfuDfhOffset = uvm_reg_field::type_id::create("PortAfuDfhOffset",,get_full_name());
      this.PortAfuDfhOffset.configure(this, 24, 0, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_FIRST_AFU_OFFSET)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_FIRST_AFU_OFFSET


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_MAILBOX extends uvm_reg;
	rand uvm_reg_field Mailbox;

	covergroup cg_vals ();
		option.per_instance = 1;
		Mailbox_value : coverpoint Mailbox.value {
			bins min = { 64'h0 };
			bins max = { 64'hFFFFFFFFFFFFFFFF };
			bins others = { [64'h1:64'hFFFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_MAILBOX");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Mailbox = uvm_reg_field::type_id::create("Mailbox",,get_full_name());
      this.Mailbox.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_MAILBOX)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_MAILBOX


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_SCRATCHPAD0 extends uvm_reg;
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

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_SCRATCHPAD0");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Scratchpad = uvm_reg_field::type_id::create("Scratchpad",,get_full_name());
      this.Scratchpad.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_SCRATCHPAD0)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_SCRATCHPAD0


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_CAPABILITY extends uvm_reg;
	rand uvm_reg_field Reserved36;
	uvm_reg_field NumbSuppInterrupt;
	rand uvm_reg_field Reserved24;
	uvm_reg_field MmioSize;
	rand uvm_reg_field Reserved0;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved36_value : coverpoint Reserved36.value {
			bins min = { 28'h0 };
			bins max = { 28'hFFFFFFF };
			bins others = { [28'h1:28'hFFFFFFE] };
			option.weight = 3;
		}
		NumbSuppInterrupt_value : coverpoint NumbSuppInterrupt.value[3:0] {
			option.weight = 16;
		}
		Reserved24_value : coverpoint Reserved24.value {
			bins min = { 8'h0 };
			bins max = { 8'hFF };
			bins others = { [8'h1:8'hFE] };
			option.weight = 3;
		}
		MmioSize_value : coverpoint MmioSize.value {
			bins min = { 16'h0 };
			bins max = { 16'hFFFF };
			bins others = { [16'h1:16'hFFFE] };
			option.weight = 3;
		}
		Reserved0_value : coverpoint Reserved0.value {
			bins min = { 8'h0 };
			bins max = { 8'hFF };
			bins others = { [8'h1:8'hFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_CAPABILITY");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved36 = uvm_reg_field::type_id::create("Reserved36",,get_full_name());
      this.Reserved36.configure(this, 28, 36, "WO", 0, 28'h0, 1, 0, 0);
      this.NumbSuppInterrupt = uvm_reg_field::type_id::create("NumbSuppInterrupt",,get_full_name());
      this.NumbSuppInterrupt.configure(this, 4, 32, "RO", 0, 4'h4, 1, 0, 0);
      this.Reserved24 = uvm_reg_field::type_id::create("Reserved24",,get_full_name());
      this.Reserved24.configure(this, 8, 24, "WO", 0, 8'h0, 1, 0, 1);
      this.MmioSize = uvm_reg_field::type_id::create("MmioSize",,get_full_name());
      this.MmioSize.configure(this, 16, 8, "RO", 0, 16'h100, 1, 0, 1);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 8, 0, "WO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_CAPABILITY)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_CAPABILITY


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_CONTROL extends uvm_reg;
	rand uvm_reg_field Reserved5;
	uvm_reg_field PortSoftResetAck;
	uvm_reg_field FlrPortReset;
	rand uvm_reg_field LatencyTolerance;
	rand uvm_reg_field Reserved1;
	rand uvm_reg_field PortSoftReset;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved5_value : coverpoint Reserved5.value {
			bins min = { 59'h0 };
			bins max = { 59'h7FFFFFFFFFFFFFF };
			bins others = { [59'h1:59'h7FFFFFFFFFFFFFE] };
			option.weight = 3;
		}
		PortSoftResetAck_value : coverpoint PortSoftResetAck.value[0:0] {
			option.weight = 2;
		}
		FlrPortReset_value : coverpoint FlrPortReset.value[0:0] {
			option.weight = 2;
		}
		LatencyTolerance_value : coverpoint LatencyTolerance.value[0:0] {
			option.weight = 2;
		}
		Reserved1_value : coverpoint Reserved1.value[0:0] {
			option.weight = 2;
		}
		PortSoftReset_value : coverpoint PortSoftReset.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_CONTROL");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved5 = uvm_reg_field::type_id::create("Reserved5",,get_full_name());
      this.Reserved5.configure(this, 59, 5, "WO", 0, 59'h000000000, 1, 0, 0);
      this.PortSoftResetAck = uvm_reg_field::type_id::create("PortSoftResetAck",,get_full_name());
      this.PortSoftResetAck.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.FlrPortReset = uvm_reg_field::type_id::create("FlrPortReset",,get_full_name());
      this.FlrPortReset.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.LatencyTolerance = uvm_reg_field::type_id::create("LatencyTolerance",,get_full_name());
      this.LatencyTolerance.configure(this, 1, 2, "RW", 0, 1'h1, 1, 0, 0);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 1, 1, "WO", 0, 1'h0, 1, 0, 0);
      this.PortSoftReset = uvm_reg_field::type_id::create("PortSoftReset",,get_full_name());
      this.PortSoftReset.configure(this, 1, 0, "RW", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_CONTROL)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_CONTROL


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_STATUS extends uvm_reg;
	rand uvm_reg_field Reserved1;
	uvm_reg_field PortFreeze;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved1_value : coverpoint Reserved1.value {
			bins min = { 63'h0 };
			bins max = { 63'h7FFFFFFFFFFFFFFF };
			bins others = { [63'h1:63'h7FFFFFFFFFFFFFFE] };
			option.weight = 3;
		}
		PortFreeze_value : coverpoint PortFreeze.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_STATUS");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 63, 1, "WO", 0, 63'h000000000, 1, 0, 0);
      this.PortFreeze = uvm_reg_field::type_id::create("PortFreeze",,get_full_name());
      this.PortFreeze.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_STATUS)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_STATUS


class ral_reg_ac_src_port_gasket_agilex_pg_USER_CLOCK_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field CciMinorRev;
	uvm_reg_field CciVersion;

	covergroup cg_vals ();
		option.per_instance = 1;
		FeatureType_value : coverpoint FeatureType.value[3:0] {
			option.weight = 16;
		}
		Reserved41_value : coverpoint Reserved41.value {
			bins min = { 19'h0 };
			bins max = { 19'h7FFFF };
			bins others = { [19'h1:19'h7FFFE] };
			option.weight = 3;
		}
		EOL_value : coverpoint EOL.value[0:0] {
			option.weight = 2;
		}
		NextDfhOffset_value : coverpoint NextDfhOffset.value {
			bins min = { 24'h0 };
			bins max = { 24'hFFFFFF };
			bins others = { [24'h1:24'hFFFFFE] };
			option.weight = 3;
		}
		CciMinorRev_value : coverpoint CciMinorRev.value[3:0] {
			option.weight = 16;
		}
		CciVersion_value : coverpoint CciVersion.value {
			bins min = { 12'h0 };
			bins max = { 12'hFFF };
			bins others = { [12'h1:12'hFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_USER_CLOCK_DFH");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhOffset = uvm_reg_field::type_id::create("NextDfhOffset",,get_full_name());
      this.NextDfhOffset.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.CciMinorRev = uvm_reg_field::type_id::create("CciMinorRev",,get_full_name());
      this.CciMinorRev.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.CciVersion = uvm_reg_field::type_id::create("CciVersion",,get_full_name());
      this.CciVersion.configure(this, 12, 0, "RO", 0, 12'h14, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_USER_CLOCK_DFH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_USER_CLOCK_DFH


class ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD0 extends uvm_reg;
	rand uvm_reg_field Reserved4;
	rand uvm_reg_field UsrClkCmdPllRst;
	rand uvm_reg_field UsrClkCmdPllMgmtRst;
	rand uvm_reg_field Reserved3;
	rand uvm_reg_field UsrClkCmdMmRst;
	rand uvm_reg_field Reserved2;
	rand uvm_reg_field UsrClkCmdSeq;
	rand uvm_reg_field Reserved1;
	rand uvm_reg_field UsrClkCmdWr;
	rand uvm_reg_field Reserved0;
	rand uvm_reg_field UsrClkCmdAdr;
	rand uvm_reg_field UsrClkCmdDat;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved4_value : coverpoint Reserved4.value {
			bins min = { 6'h0 };
			bins max = { 6'h3F };
			bins others = { [6'h1:6'h3E] };
			option.weight = 3;
		}
		UsrClkCmdPllRst_value : coverpoint UsrClkCmdPllRst.value[0:0] {
			option.weight = 2;
		}
		UsrClkCmdPllMgmtRst_value : coverpoint UsrClkCmdPllMgmtRst.value[0:0] {
			option.weight = 2;
		}
		Reserved3_value : coverpoint Reserved3.value[2:0] {
			option.weight = 8;
		}
		UsrClkCmdMmRst_value : coverpoint UsrClkCmdMmRst.value[0:0] {
			option.weight = 2;
		}
		Reserved2_value : coverpoint Reserved2.value[1:0] {
			option.weight = 4;
		}
		UsrClkCmdSeq_value : coverpoint UsrClkCmdSeq.value[1:0] {
			option.weight = 4;
		}
		Reserved1_value : coverpoint Reserved1.value[2:0] {
			option.weight = 8;
		}
		UsrClkCmdWr_value : coverpoint UsrClkCmdWr.value[0:0] {
			option.weight = 2;
		}
		Reserved0_value : coverpoint Reserved0.value[1:0] {
			option.weight = 4;
		}
		UsrClkCmdAdr_value : coverpoint UsrClkCmdAdr.value {
			bins min = { 10'h0 };
			bins max = { 10'h3FF };
			bins others = { [10'h1:10'h3FE] };
			option.weight = 3;
		}
		UsrClkCmdDat_value : coverpoint UsrClkCmdDat.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD0");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved4 = uvm_reg_field::type_id::create("Reserved4",,get_full_name());
      this.Reserved4.configure(this, 6, 58, "WO", 0, 6'h0, 1, 0, 0);
      this.UsrClkCmdPllRst = uvm_reg_field::type_id::create("UsrClkCmdPllRst",,get_full_name());
      this.UsrClkCmdPllRst.configure(this, 1, 57, "RW", 0, 1'h0, 1, 0, 0);
      this.UsrClkCmdPllMgmtRst = uvm_reg_field::type_id::create("UsrClkCmdPllMgmtRst",,get_full_name());
      this.UsrClkCmdPllMgmtRst.configure(this, 1, 56, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved3 = uvm_reg_field::type_id::create("Reserved3",,get_full_name());
      this.Reserved3.configure(this, 3, 53, "WO", 0, 3'h0, 1, 0, 0);
      this.UsrClkCmdMmRst = uvm_reg_field::type_id::create("UsrClkCmdMmRst",,get_full_name());
      this.UsrClkCmdMmRst.configure(this, 1, 52, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved2 = uvm_reg_field::type_id::create("Reserved2",,get_full_name());
      this.Reserved2.configure(this, 2, 50, "WO", 0, 2'h0, 1, 0, 0);
      this.UsrClkCmdSeq = uvm_reg_field::type_id::create("UsrClkCmdSeq",,get_full_name());
      this.UsrClkCmdSeq.configure(this, 2, 48, "RW", 0, 2'h0, 1, 0, 0);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 3, 45, "WO", 0, 3'h0, 1, 0, 0);
      this.UsrClkCmdWr = uvm_reg_field::type_id::create("UsrClkCmdWr",,get_full_name());
      this.UsrClkCmdWr.configure(this, 1, 44, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 2, 42, "WO", 0, 2'h0, 1, 0, 0);
      this.UsrClkCmdAdr = uvm_reg_field::type_id::create("UsrClkCmdAdr",,get_full_name());
      this.UsrClkCmdAdr.configure(this, 10, 32, "RW", 0, 10'h0, 1, 0, 0);
      this.UsrClkCmdDat = uvm_reg_field::type_id::create("UsrClkCmdDat",,get_full_name());
      this.UsrClkCmdDat.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD0)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD0


class ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD1 extends uvm_reg;
	rand uvm_reg_field Reserved1;
	rand uvm_reg_field FreqCntrClkSel;
	rand uvm_reg_field Reserved0;

	covergroup cg_vals ();
		option.per_instance = 1;
		Reserved1_value : coverpoint Reserved1.value {
			bins min = { 31'h0 };
			bins max = { 31'h7FFFFFFF };
			bins others = { [31'h1:31'h7FFFFFFE] };
			option.weight = 3;
		}
		FreqCntrClkSel_value : coverpoint FreqCntrClkSel.value[0:0] {
			option.weight = 2;
		}
		Reserved0_value : coverpoint Reserved0.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD1");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 31, 33, "WO", 0, 31'h0, 1, 0, 0);
      this.FreqCntrClkSel = uvm_reg_field::type_id::create("FreqCntrClkSel",,get_full_name());
      this.FreqCntrClkSel.configure(this, 1, 32, "RW", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 32, 0, "WO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD1)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD1


class ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS0 extends uvm_reg;
	uvm_reg_field UsrClkStMmError;
	rand uvm_reg_field UsrClkStPllActClk;
	uvm_reg_field UsrClkStPllLocked;
	rand uvm_reg_field Reserved4;
	uvm_reg_field UsrClkStPllRst;
	uvm_reg_field UsrClkStPllMgmtRst;
	rand uvm_reg_field Reserved3;
	uvm_reg_field UsrClkStMmRst;
	rand uvm_reg_field Reserved2;
	uvm_reg_field UsrClkStSeq;
	rand uvm_reg_field Reserved1;
	uvm_reg_field UsrClkStWr;
	rand uvm_reg_field Reserved0;
	uvm_reg_field UsrClkStAdr;
	uvm_reg_field UsrClkStDat;

	covergroup cg_vals ();
		option.per_instance = 1;
		UsrClkStMmError_value : coverpoint UsrClkStMmError.value[0:0] {
			option.weight = 2;
		}
		UsrClkStPllActClk_value : coverpoint UsrClkStPllActClk.value[1:0] {
			option.weight = 4;
		}
		UsrClkStPllLocked_value : coverpoint UsrClkStPllLocked.value[0:0] {
			option.weight = 2;
		}
		Reserved4_value : coverpoint Reserved4.value[1:0] {
			option.weight = 4;
		}
		UsrClkStPllRst_value : coverpoint UsrClkStPllRst.value[0:0] {
			option.weight = 2;
		}
		UsrClkStPllMgmtRst_value : coverpoint UsrClkStPllMgmtRst.value[0:0] {
			option.weight = 2;
		}
		Reserved3_value : coverpoint Reserved3.value[2:0] {
			option.weight = 8;
		}
		UsrClkStMmRst_value : coverpoint UsrClkStMmRst.value[0:0] {
			option.weight = 2;
		}
		Reserved2_value : coverpoint Reserved2.value[1:0] {
			option.weight = 4;
		}
		UsrClkStSeq_value : coverpoint UsrClkStSeq.value[1:0] {
			option.weight = 4;
		}
		Reserved1_value : coverpoint Reserved1.value[2:0] {
			option.weight = 8;
		}
		UsrClkStWr_value : coverpoint UsrClkStWr.value[0:0] {
			option.weight = 2;
		}
		Reserved0_value : coverpoint Reserved0.value[1:0] {
			option.weight = 4;
		}
		UsrClkStAdr_value : coverpoint UsrClkStAdr.value {
			bins min = { 10'h0 };
			bins max = { 10'h3FF };
			bins others = { [10'h1:10'h3FE] };
			option.weight = 3;
		}
		UsrClkStDat_value : coverpoint UsrClkStDat.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS0");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.UsrClkStMmError = uvm_reg_field::type_id::create("UsrClkStMmError",,get_full_name());
      this.UsrClkStMmError.configure(this, 1, 63, "RO", 0, 1'h0, 1, 0, 0);
      this.UsrClkStPllActClk = uvm_reg_field::type_id::create("UsrClkStPllActClk",,get_full_name());
      this.UsrClkStPllActClk.configure(this, 2, 61, "WO", 0, 2'h0, 1, 0, 0);
      this.UsrClkStPllLocked = uvm_reg_field::type_id::create("UsrClkStPllLocked",,get_full_name());
      this.UsrClkStPllLocked.configure(this, 1, 60, "RO", 0, 1'h1, 1, 0, 0);
      this.Reserved4 = uvm_reg_field::type_id::create("Reserved4",,get_full_name());
      this.Reserved4.configure(this, 2, 58, "WO", 0, 2'h0, 1, 0, 0);
      this.UsrClkStPllRst = uvm_reg_field::type_id::create("UsrClkStPllRst",,get_full_name());
      this.UsrClkStPllRst.configure(this, 1, 57, "RO", 0, 1'h0, 1, 0, 0);
      this.UsrClkStPllMgmtRst = uvm_reg_field::type_id::create("UsrClkStPllMgmtRst",,get_full_name());
      this.UsrClkStPllMgmtRst.configure(this, 1, 56, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved3 = uvm_reg_field::type_id::create("Reserved3",,get_full_name());
      this.Reserved3.configure(this, 3, 53, "WO", 0, 3'h0, 1, 0, 0);
      this.UsrClkStMmRst = uvm_reg_field::type_id::create("UsrClkStMmRst",,get_full_name());
      this.UsrClkStMmRst.configure(this, 1, 52, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved2 = uvm_reg_field::type_id::create("Reserved2",,get_full_name());
      this.Reserved2.configure(this, 2, 50, "WO", 0, 2'h0, 1, 0, 0);
      this.UsrClkStSeq = uvm_reg_field::type_id::create("UsrClkStSeq",,get_full_name());
      this.UsrClkStSeq.configure(this, 2, 48, "RO", 0, 2'h0, 1, 0, 0);
      this.Reserved1 = uvm_reg_field::type_id::create("Reserved1",,get_full_name());
      this.Reserved1.configure(this, 3, 45, "WO", 0, 3'h0, 1, 0, 0);
      this.UsrClkStWr = uvm_reg_field::type_id::create("UsrClkStWr",,get_full_name());
      this.UsrClkStWr.configure(this, 1, 44, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved0 = uvm_reg_field::type_id::create("Reserved0",,get_full_name());
      this.Reserved0.configure(this, 2, 42, "WO", 0, 2'h0, 1, 0, 0);
      this.UsrClkStAdr = uvm_reg_field::type_id::create("UsrClkStAdr",,get_full_name());
      this.UsrClkStAdr.configure(this, 10, 32, "RO", 0, 10'h0, 1, 0, 0);
      this.UsrClkStDat = uvm_reg_field::type_id::create("UsrClkStDat",,get_full_name());
      this.UsrClkStDat.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS0)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS0


class ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS1 extends uvm_reg;
	uvm_reg_field FreqCntrVersion;
	uvm_reg_field Reserved;
	uvm_reg_field FreqPLLRef;
	uvm_reg_field FreqCntrClkMeasured;
	uvm_reg_field Reserved41;
	uvm_reg_field FreqCntrMeasuredFreq;

	covergroup cg_vals ();
		option.per_instance = 1;
		FreqCntrVersion_value : coverpoint FreqCntrVersion.value[3:0] {
			option.weight = 16;
		}
		Reserved_value : coverpoint Reserved.value {
			bins min = { 9'h0 };
			bins max = { 9'h1FF };
			bins others = { [9'h1:9'h1FE] };
			option.weight = 3;
		}
		FreqPLLRef_value : coverpoint FreqPLLRef.value {
			bins min = { 18'h0 };
			bins max = { 18'h3FFFF };
			bins others = { [18'h1:18'h3FFFE] };
			option.weight = 3;
		}
		FreqCntrClkMeasured_value : coverpoint FreqCntrClkMeasured.value[0:0] {
			option.weight = 2;
		}
		Reserved41_value : coverpoint Reserved41.value {
			bins min = { 15'h0 };
			bins max = { 15'h7FFF };
			bins others = { [15'h1:15'h7FFE] };
			option.weight = 3;
		}
		FreqCntrMeasuredFreq_value : coverpoint FreqCntrMeasuredFreq.value {
			bins min = { 17'h0 };
			bins max = { 17'h1FFFF };
			bins others = { [17'h1:17'h1FFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS1");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.FreqCntrVersion = uvm_reg_field::type_id::create("FreqCntrVersion",,get_full_name());
      this.FreqCntrVersion.configure(this, 4, 60, "RO", 0, 4'h4, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 9, 51, "RO", 0, 9'h0, 1, 0, 0);
      this.FreqPLLRef = uvm_reg_field::type_id::create("FreqPLLRef",,get_full_name());
      this.FreqPLLRef.configure(this, 18, 33, "RO", 0, 18'h2710, 1, 0, 0);
      this.FreqCntrClkMeasured = uvm_reg_field::type_id::create("FreqCntrClkMeasured",,get_full_name());
      this.FreqCntrClkMeasured.configure(this, 1, 32, "RO", 0, 1'h0, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 15, 17, "RO", 0, 15'h0, 1, 0, 0);
      this.FreqCntrMeasuredFreq = uvm_reg_field::type_id::create("FreqCntrMeasuredFreq",,get_full_name());
      this.FreqCntrMeasuredFreq.configure(this, 17, 0, "RO", 0, 17'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS1)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS1


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_DFH extends uvm_reg;
	rand uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	covergroup cg_vals ();
		option.per_instance = 1;
		FeatureType_value : coverpoint FeatureType.value[3:0] {
			option.weight = 16;
		}
		Reserved41_value : coverpoint Reserved41.value {
			bins min = { 19'h0 };
			bins max = { 19'h7FFFF };
			bins others = { [19'h1:19'h7FFFE] };
			option.weight = 3;
		}
		EOL_value : coverpoint EOL.value[0:0] {
			option.weight = 2;
		}
		NextDfhByteOffset_value : coverpoint NextDfhByteOffset.value {
			bins min = { 24'h0 };
			bins max = { 24'hFFFFFF };
			bins others = { [24'h1:24'hFFFFFE] };
			option.weight = 3;
		}
		FeatureRev_value : coverpoint FeatureRev.value[3:0] {
			option.weight = 16;
		}
		FeatureID_value : coverpoint FeatureID.value {
			bins min = { 12'h0 };
			bins max = { 12'hFFF };
			bins others = { [12'h1:12'hFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_STP_DFH");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "WO", 0, 4'h3, 1, 0, 0);
      this.Reserved41 = uvm_reg_field::type_id::create("Reserved41",,get_full_name());
      this.Reserved41.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h1, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h0, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h2, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h13, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_DFH)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_DFH


class ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_STATUS extends uvm_reg;
	uvm_reg_field NumMmioResp;
	uvm_reg_field NumMmioReq;
	uvm_reg_field NumMmioWr;
	uvm_reg_field RxFifoUnderflow;
	uvm_reg_field RxFifoOverflow;
	uvm_reg_field TxFifoUnderflow;
	uvm_reg_field TxFifoOverflow;
	uvm_reg_field RxFifoCount;
	uvm_reg_field TxFifoCount;
	uvm_reg_field MmioTimeOut;
	uvm_reg_field UnsupportedRD;
	uvm_reg_field StpInReset;
	uvm_reg_field RwTimeOut;

	covergroup cg_vals ();
		option.per_instance = 1;
		NumMmioResp_value : coverpoint NumMmioResp.value {
			bins min = { 16'h0 };
			bins max = { 16'hFFFF };
			bins others = { [16'h1:16'hFFFE] };
			option.weight = 3;
		}
		NumMmioReq_value : coverpoint NumMmioReq.value {
			bins min = { 16'h0 };
			bins max = { 16'hFFFF };
			bins others = { [16'h1:16'hFFFE] };
			option.weight = 3;
		}
		NumMmioWr_value : coverpoint NumMmioWr.value {
			bins min = { 16'h0 };
			bins max = { 16'hFFFF };
			bins others = { [16'h1:16'hFFFE] };
			option.weight = 3;
		}
		RxFifoUnderflow_value : coverpoint RxFifoUnderflow.value[0:0] {
			option.weight = 2;
		}
		RxFifoOverflow_value : coverpoint RxFifoOverflow.value[0:0] {
			option.weight = 2;
		}
		TxFifoUnderflow_value : coverpoint TxFifoUnderflow.value[0:0] {
			option.weight = 2;
		}
		TxFifoOverflow_value : coverpoint TxFifoOverflow.value[0:0] {
			option.weight = 2;
		}
		RxFifoCount_value : coverpoint RxFifoCount.value[3:0] {
			option.weight = 16;
		}
		TxFifoCount_value : coverpoint TxFifoCount.value[3:0] {
			option.weight = 16;
		}
		MmioTimeOut_value : coverpoint MmioTimeOut.value[0:0] {
			option.weight = 2;
		}
		UnsupportedRD_value : coverpoint UnsupportedRD.value[0:0] {
			option.weight = 2;
		}
		StpInReset_value : coverpoint StpInReset.value[0:0] {
			option.weight = 2;
		}
		RwTimeOut_value : coverpoint RwTimeOut.value[0:0] {
			option.weight = 2;
		}
	endgroup : cg_vals

	function new(string name = "ac_src_port_gasket_agilex_pg_PORT_STP_STATUS");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.NumMmioResp = uvm_reg_field::type_id::create("NumMmioResp",,get_full_name());
      this.NumMmioResp.configure(this, 16, 48, "RO", 0, 16'h0, 1, 0, 1);
      this.NumMmioReq = uvm_reg_field::type_id::create("NumMmioReq",,get_full_name());
      this.NumMmioReq.configure(this, 16, 32, "RO", 0, 16'h0, 1, 0, 1);
      this.NumMmioWr = uvm_reg_field::type_id::create("NumMmioWr",,get_full_name());
      this.NumMmioWr.configure(this, 16, 16, "RO", 0, 16'h0, 1, 0, 1);
      this.RxFifoUnderflow = uvm_reg_field::type_id::create("RxFifoUnderflow",,get_full_name());
      this.RxFifoUnderflow.configure(this, 1, 15, "RO", 0, 1'h0, 1, 0, 0);
      this.RxFifoOverflow = uvm_reg_field::type_id::create("RxFifoOverflow",,get_full_name());
      this.RxFifoOverflow.configure(this, 1, 14, "RO", 0, 1'h0, 1, 0, 0);
      this.TxFifoUnderflow = uvm_reg_field::type_id::create("TxFifoUnderflow",,get_full_name());
      this.TxFifoUnderflow.configure(this, 1, 13, "RO", 0, 1'h0, 1, 0, 0);
      this.TxFifoOverflow = uvm_reg_field::type_id::create("TxFifoOverflow",,get_full_name());
      this.TxFifoOverflow.configure(this, 1, 12, "RO", 0, 1'h0, 1, 0, 0);
      this.RxFifoCount = uvm_reg_field::type_id::create("RxFifoCount",,get_full_name());
      this.RxFifoCount.configure(this, 4, 8, "RO", 0, 4'h0, 1, 0, 0);
      this.TxFifoCount = uvm_reg_field::type_id::create("TxFifoCount",,get_full_name());
      this.TxFifoCount.configure(this, 4, 4, "RO", 0, 4'h0, 1, 0, 0);
      this.MmioTimeOut = uvm_reg_field::type_id::create("MmioTimeOut",,get_full_name());
      this.MmioTimeOut.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.UnsupportedRD = uvm_reg_field::type_id::create("UnsupportedRD",,get_full_name());
      this.UnsupportedRD.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.StpInReset = uvm_reg_field::type_id::create("StpInReset",,get_full_name());
      this.StpInReset.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.RwTimeOut = uvm_reg_field::type_id::create("RwTimeOut",,get_full_name());
      this.RwTimeOut.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_STATUS)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_STATUS


class ral_block_ac_src_port_gasket_agilex_pg extends uvm_reg_block;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DFH PG_PR_DFH;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_CTRL PG_PR_CTRL;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_STATUS PG_PR_STATUS;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DATA PG_PR_DATA;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_ERROR PG_PR_ERROR;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5028 DUMMY_5028;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5030 DUMMY_5030;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5038 DUMMY_5038;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5040 DUMMY_5040;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5048 DUMMY_5048;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5050 DUMMY_5050;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5058 DUMMY_5058;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5060 DUMMY_5060;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5068 DUMMY_5068;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5070 DUMMY_5070;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5078 DUMMY_5078;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5080 DUMMY_5080;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5088 DUMMY_5088;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5090 DUMMY_5090;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5098 DUMMY_5098;
	rand ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_50A0 DUMMY_50A0;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_L PG_PR_INTFC_ID_L;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_H PG_PR_INTFC_ID_H;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PG_SCRATCHPAD PG_SCRATCHPAD;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_DFH PORT_DFH;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_L PORT_AFU_ID_L;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_H PORT_AFU_ID_H;
	rand ral_reg_ac_src_port_gasket_agilex_pg_FIRST_AFU_OFFSET FIRST_AFU_OFFSET;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_MAILBOX PORT_MAILBOX;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_SCRATCHPAD0 PORT_SCRATCHPAD0;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_CAPABILITY PORT_CAPABILITY;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_CONTROL PORT_CONTROL;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_STATUS PORT_STATUS;
	rand ral_reg_ac_src_port_gasket_agilex_pg_USER_CLOCK_DFH USER_CLOCK_DFH;
	rand ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD0 USER_CLK_FREQ_CMD0;
	rand ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD1 USER_CLK_FREQ_CMD1;
	rand ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS0 USER_CLK_FREQ_STS0;
	rand ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS1 USER_CLK_FREQ_STS1;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_DFH PORT_STP_DFH;
	rand ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_STATUS PORT_STP_STATUS;
	uvm_reg_field PG_PR_DFH_FeatureType;
	rand uvm_reg_field PG_PR_DFH_Reserved52;
	rand uvm_reg_field Reserved52;
	uvm_reg_field PG_PR_DFH_AFUMinorRevNumber;
	uvm_reg_field AFUMinorRevNumber;
	rand uvm_reg_field PG_PR_DFH_Reserved41;
	uvm_reg_field PG_PR_DFH_EOL;
	uvm_reg_field PG_PR_DFH_NextDfhByteOffset;
	uvm_reg_field PG_PR_DFH_FeatureRev;
	uvm_reg_field PG_PR_DFH_FeatureID;
	rand uvm_reg_field PG_PR_CTRL_TBD;
	rand uvm_reg_field TBD;
	rand uvm_reg_field PG_PR_CTRL_Reserved15;
	rand uvm_reg_field Reserved15;
	rand uvm_reg_field PG_PR_CTRL_PRKind;
	rand uvm_reg_field PRKind;
	rand uvm_reg_field PG_PR_CTRL_PRDataPushComplete;
	rand uvm_reg_field PRDataPushComplete;
	rand uvm_reg_field PG_PR_CTRL_PRStartRequest;
	rand uvm_reg_field PRStartRequest;
	rand uvm_reg_field PG_PR_CTRL_Reserved10;
	rand uvm_reg_field Reserved10;
	rand uvm_reg_field PG_PR_CTRL_PRRegionId;
	rand uvm_reg_field PRRegionId;
	rand uvm_reg_field PG_PR_CTRL_Reserved5;
	uvm_reg_field PG_PR_CTRL_PRResetAck;
	uvm_reg_field PRResetAck;
	rand uvm_reg_field PG_PR_CTRL_Reserved1;
	rand uvm_reg_field PG_PR_CTRL_PRReset;
	rand uvm_reg_field PRReset;
	uvm_reg_field PG_PR_STATUS_SecurityBlockStatus;
	uvm_reg_field SecurityBlockStatus;
	rand uvm_reg_field PG_PR_STATUS_Reserved28;
	rand uvm_reg_field Reserved28;
	uvm_reg_field PG_PR_STATUS_PRHostStatus;
	uvm_reg_field PRHostStatus;
	rand uvm_reg_field PG_PR_STATUS_Reserved23;
	rand uvm_reg_field Reserved23;
	uvm_reg_field PG_PR_STATUS_AlteraPRCrtlrStatus;
	uvm_reg_field AlteraPRCrtlrStatus;
	rand uvm_reg_field PG_PR_STATUS_Reserved17;
	rand uvm_reg_field Reserved17;
	uvm_reg_field PG_PR_STATUS_PRStatus;
	uvm_reg_field PRStatus;
	rand uvm_reg_field PG_PR_STATUS_Reserved9;
	rand uvm_reg_field Reserved9;
	uvm_reg_field PG_PR_STATUS_NumbCredits;
	uvm_reg_field NumbCredits;
	rand uvm_reg_field PG_PR_DATA_PRData;
	rand uvm_reg_field PRData;
	rand uvm_reg_field PG_PR_ERROR_Reserved7;
	rand uvm_reg_field Reserved7;
	rand uvm_reg_field PG_PR_ERROR_SecureLoadFailed;
	rand uvm_reg_field SecureLoadFailed;
	rand uvm_reg_field PG_PR_ERROR_HostInitTimeout;
	rand uvm_reg_field HostInitTimeout;
	rand uvm_reg_field PG_PR_ERROR_HostInitFIFOOverflow;
	rand uvm_reg_field HostInitFIFOOverflow;
	rand uvm_reg_field PG_PR_ERROR_IPInitProtocolError;
	rand uvm_reg_field IPInitProtocolError;
	rand uvm_reg_field PG_PR_ERROR_IPInitIncompatibleBitstream;
	rand uvm_reg_field IPInitIncompatibleBitstream;
	rand uvm_reg_field PG_PR_ERROR_IPInitCRCError;
	rand uvm_reg_field IPInitCRCError;
	rand uvm_reg_field PG_PR_ERROR_HostInitOperationError;
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
	uvm_reg_field PG_PR_INTFC_ID_L_InterfaceIdL;
	uvm_reg_field InterfaceIdL;
	uvm_reg_field PG_PR_INTFC_ID_H_InterfaceIdH;
	uvm_reg_field InterfaceIdH;
	rand uvm_reg_field PG_SCRATCHPAD_Reserved;
	uvm_reg_field PORT_DFH_FeatureType;
	rand uvm_reg_field PORT_DFH_Reserved41;
	uvm_reg_field PORT_DFH_EOL;
	uvm_reg_field PORT_DFH_NextDfhOffset;
	uvm_reg_field PORT_DFH_AfuMajVersion;
	uvm_reg_field AfuMajVersion;
	uvm_reg_field PORT_DFH_CorefimVersion;
	uvm_reg_field CorefimVersion;
	uvm_reg_field PORT_AFU_ID_L_PortIdLow;
	uvm_reg_field PortIdLow;
	uvm_reg_field PORT_AFU_ID_H_PortIdHigh;
	uvm_reg_field PortIdHigh;
	rand uvm_reg_field FIRST_AFU_OFFSET_Reserved24;
	uvm_reg_field FIRST_AFU_OFFSET_PortAfuDfhOffset;
	uvm_reg_field PortAfuDfhOffset;
	rand uvm_reg_field PORT_MAILBOX_Mailbox;
	rand uvm_reg_field Mailbox;
	rand uvm_reg_field PORT_SCRATCHPAD0_Scratchpad;
	rand uvm_reg_field Scratchpad;
	rand uvm_reg_field PORT_CAPABILITY_Reserved36;
	rand uvm_reg_field Reserved36;
	uvm_reg_field PORT_CAPABILITY_NumbSuppInterrupt;
	uvm_reg_field NumbSuppInterrupt;
	rand uvm_reg_field PORT_CAPABILITY_Reserved24;
	uvm_reg_field PORT_CAPABILITY_MmioSize;
	uvm_reg_field MmioSize;
	rand uvm_reg_field PORT_CAPABILITY_Reserved0;
	rand uvm_reg_field PORT_CONTROL_Reserved5;
	uvm_reg_field PORT_CONTROL_PortSoftResetAck;
	uvm_reg_field PortSoftResetAck;
	uvm_reg_field PORT_CONTROL_FlrPortReset;
	uvm_reg_field FlrPortReset;
	rand uvm_reg_field PORT_CONTROL_LatencyTolerance;
	rand uvm_reg_field LatencyTolerance;
	rand uvm_reg_field PORT_CONTROL_Reserved1;
	rand uvm_reg_field PORT_CONTROL_PortSoftReset;
	rand uvm_reg_field PortSoftReset;
	rand uvm_reg_field PORT_STATUS_Reserved1;
	uvm_reg_field PORT_STATUS_PortFreeze;
	uvm_reg_field PortFreeze;
	uvm_reg_field USER_CLOCK_DFH_FeatureType;
	rand uvm_reg_field USER_CLOCK_DFH_Reserved41;
	uvm_reg_field USER_CLOCK_DFH_EOL;
	uvm_reg_field USER_CLOCK_DFH_NextDfhOffset;
	uvm_reg_field USER_CLOCK_DFH_CciMinorRev;
	uvm_reg_field CciMinorRev;
	uvm_reg_field USER_CLOCK_DFH_CciVersion;
	uvm_reg_field CciVersion;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_Reserved4;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_UsrClkCmdPllRst;
	rand uvm_reg_field UsrClkCmdPllRst;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_UsrClkCmdPllMgmtRst;
	rand uvm_reg_field UsrClkCmdPllMgmtRst;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_Reserved3;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_UsrClkCmdMmRst;
	rand uvm_reg_field UsrClkCmdMmRst;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_Reserved2;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_UsrClkCmdSeq;
	rand uvm_reg_field UsrClkCmdSeq;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_Reserved1;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_UsrClkCmdWr;
	rand uvm_reg_field UsrClkCmdWr;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_Reserved0;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_UsrClkCmdAdr;
	rand uvm_reg_field UsrClkCmdAdr;
	rand uvm_reg_field USER_CLK_FREQ_CMD0_UsrClkCmdDat;
	rand uvm_reg_field UsrClkCmdDat;
	rand uvm_reg_field USER_CLK_FREQ_CMD1_Reserved1;
	rand uvm_reg_field USER_CLK_FREQ_CMD1_FreqCntrClkSel;
	rand uvm_reg_field FreqCntrClkSel;
	rand uvm_reg_field USER_CLK_FREQ_CMD1_Reserved0;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStMmError;
	uvm_reg_field UsrClkStMmError;
	rand uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStPllActClk;
	rand uvm_reg_field UsrClkStPllActClk;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStPllLocked;
	uvm_reg_field UsrClkStPllLocked;
	rand uvm_reg_field USER_CLK_FREQ_STS0_Reserved4;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStPllRst;
	uvm_reg_field UsrClkStPllRst;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStPllMgmtRst;
	uvm_reg_field UsrClkStPllMgmtRst;
	rand uvm_reg_field USER_CLK_FREQ_STS0_Reserved3;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStMmRst;
	uvm_reg_field UsrClkStMmRst;
	rand uvm_reg_field USER_CLK_FREQ_STS0_Reserved2;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStSeq;
	uvm_reg_field UsrClkStSeq;
	rand uvm_reg_field USER_CLK_FREQ_STS0_Reserved1;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStWr;
	uvm_reg_field UsrClkStWr;
	rand uvm_reg_field USER_CLK_FREQ_STS0_Reserved0;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStAdr;
	uvm_reg_field UsrClkStAdr;
	uvm_reg_field USER_CLK_FREQ_STS0_UsrClkStDat;
	uvm_reg_field UsrClkStDat;
	uvm_reg_field USER_CLK_FREQ_STS1_FreqCntrVersion;
	uvm_reg_field FreqCntrVersion;
	uvm_reg_field USER_CLK_FREQ_STS1_Reserved;
	uvm_reg_field USER_CLK_FREQ_STS1_FreqPLLRef;
	uvm_reg_field FreqPLLRef;
	uvm_reg_field USER_CLK_FREQ_STS1_FreqCntrClkMeasured;
	uvm_reg_field FreqCntrClkMeasured;
	uvm_reg_field USER_CLK_FREQ_STS1_Reserved41;
	uvm_reg_field USER_CLK_FREQ_STS1_FreqCntrMeasuredFreq;
	uvm_reg_field FreqCntrMeasuredFreq;
	rand uvm_reg_field PORT_STP_DFH_FeatureType;
	rand uvm_reg_field PORT_STP_DFH_Reserved41;
	uvm_reg_field PORT_STP_DFH_EOL;
	uvm_reg_field PORT_STP_DFH_NextDfhByteOffset;
	uvm_reg_field PORT_STP_DFH_FeatureRev;
	uvm_reg_field PORT_STP_DFH_FeatureID;
	uvm_reg_field PORT_STP_STATUS_NumMmioResp;
	uvm_reg_field NumMmioResp;
	uvm_reg_field PORT_STP_STATUS_NumMmioReq;
	uvm_reg_field NumMmioReq;
	uvm_reg_field PORT_STP_STATUS_NumMmioWr;
	uvm_reg_field NumMmioWr;
	uvm_reg_field PORT_STP_STATUS_RxFifoUnderflow;
	uvm_reg_field RxFifoUnderflow;
	uvm_reg_field PORT_STP_STATUS_RxFifoOverflow;
	uvm_reg_field RxFifoOverflow;
	uvm_reg_field PORT_STP_STATUS_TxFifoUnderflow;
	uvm_reg_field TxFifoUnderflow;
	uvm_reg_field PORT_STP_STATUS_TxFifoOverflow;
	uvm_reg_field TxFifoOverflow;
	uvm_reg_field PORT_STP_STATUS_RxFifoCount;
	uvm_reg_field RxFifoCount;
	uvm_reg_field PORT_STP_STATUS_TxFifoCount;
	uvm_reg_field TxFifoCount;
	uvm_reg_field PORT_STP_STATUS_MmioTimeOut;
	uvm_reg_field MmioTimeOut;
	uvm_reg_field PORT_STP_STATUS_UnsupportedRD;
	uvm_reg_field UnsupportedRD;
	uvm_reg_field PORT_STP_STATUS_StpInReset;
	uvm_reg_field StpInReset;
	uvm_reg_field PORT_STP_STATUS_RwTimeOut;
	uvm_reg_field RwTimeOut;

	function new(string name = "ac_src_port_gasket_agilex_pg");
		super.new(name, build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.PG_PR_DFH = ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DFH::type_id::create("PG_PR_DFH",,get_full_name());
      this.PG_PR_DFH.configure(this, null, "");
      this.PG_PR_DFH.build();
      this.default_map.add_reg(this.PG_PR_DFH, `UVM_REG_ADDR_WIDTH'h70000, "RW", 0);
		this.PG_PR_DFH_FeatureType = this.PG_PR_DFH.FeatureType;
		this.PG_PR_DFH_Reserved52 = this.PG_PR_DFH.Reserved52;
		this.Reserved52 = this.PG_PR_DFH.Reserved52;
		this.PG_PR_DFH_AFUMinorRevNumber = this.PG_PR_DFH.AFUMinorRevNumber;
		this.AFUMinorRevNumber = this.PG_PR_DFH.AFUMinorRevNumber;
		this.PG_PR_DFH_Reserved41 = this.PG_PR_DFH.Reserved41;
		this.PG_PR_DFH_EOL = this.PG_PR_DFH.EOL;
		this.PG_PR_DFH_NextDfhByteOffset = this.PG_PR_DFH.NextDfhByteOffset;
		this.PG_PR_DFH_FeatureRev = this.PG_PR_DFH.FeatureRev;
		this.PG_PR_DFH_FeatureID = this.PG_PR_DFH.FeatureID;
      this.PG_PR_CTRL = ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_CTRL::type_id::create("PG_PR_CTRL",,get_full_name());
      this.PG_PR_CTRL.configure(this, null, "");
      this.PG_PR_CTRL.build();
      this.default_map.add_reg(this.PG_PR_CTRL, `UVM_REG_ADDR_WIDTH'h70008, "RW", 0);
		this.PG_PR_CTRL_TBD = this.PG_PR_CTRL.TBD;
		this.TBD = this.PG_PR_CTRL.TBD;
		this.PG_PR_CTRL_Reserved15 = this.PG_PR_CTRL.Reserved15;
		this.Reserved15 = this.PG_PR_CTRL.Reserved15;
		this.PG_PR_CTRL_PRKind = this.PG_PR_CTRL.PRKind;
		this.PRKind = this.PG_PR_CTRL.PRKind;
		this.PG_PR_CTRL_PRDataPushComplete = this.PG_PR_CTRL.PRDataPushComplete;
		this.PRDataPushComplete = this.PG_PR_CTRL.PRDataPushComplete;
		this.PG_PR_CTRL_PRStartRequest = this.PG_PR_CTRL.PRStartRequest;
		this.PRStartRequest = this.PG_PR_CTRL.PRStartRequest;
		this.PG_PR_CTRL_Reserved10 = this.PG_PR_CTRL.Reserved10;
		this.Reserved10 = this.PG_PR_CTRL.Reserved10;
		this.PG_PR_CTRL_PRRegionId = this.PG_PR_CTRL.PRRegionId;
		this.PRRegionId = this.PG_PR_CTRL.PRRegionId;
		this.PG_PR_CTRL_Reserved5 = this.PG_PR_CTRL.Reserved5;
		this.PG_PR_CTRL_PRResetAck = this.PG_PR_CTRL.PRResetAck;
		this.PRResetAck = this.PG_PR_CTRL.PRResetAck;
		this.PG_PR_CTRL_Reserved1 = this.PG_PR_CTRL.Reserved1;
		this.PG_PR_CTRL_PRReset = this.PG_PR_CTRL.PRReset;
		this.PRReset = this.PG_PR_CTRL.PRReset;
      this.PG_PR_STATUS = ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_STATUS::type_id::create("PG_PR_STATUS",,get_full_name());
      this.PG_PR_STATUS.configure(this, null, "");
      this.PG_PR_STATUS.build();
      this.default_map.add_reg(this.PG_PR_STATUS, `UVM_REG_ADDR_WIDTH'h70010, "RW", 0);
		this.PG_PR_STATUS_SecurityBlockStatus = this.PG_PR_STATUS.SecurityBlockStatus;
		this.SecurityBlockStatus = this.PG_PR_STATUS.SecurityBlockStatus;
		this.PG_PR_STATUS_Reserved28 = this.PG_PR_STATUS.Reserved28;
		this.Reserved28 = this.PG_PR_STATUS.Reserved28;
		this.PG_PR_STATUS_PRHostStatus = this.PG_PR_STATUS.PRHostStatus;
		this.PRHostStatus = this.PG_PR_STATUS.PRHostStatus;
		this.PG_PR_STATUS_Reserved23 = this.PG_PR_STATUS.Reserved23;
		this.Reserved23 = this.PG_PR_STATUS.Reserved23;
		this.PG_PR_STATUS_AlteraPRCrtlrStatus = this.PG_PR_STATUS.AlteraPRCrtlrStatus;
		this.AlteraPRCrtlrStatus = this.PG_PR_STATUS.AlteraPRCrtlrStatus;
		this.PG_PR_STATUS_Reserved17 = this.PG_PR_STATUS.Reserved17;
		this.Reserved17 = this.PG_PR_STATUS.Reserved17;
		this.PG_PR_STATUS_PRStatus = this.PG_PR_STATUS.PRStatus;
		this.PRStatus = this.PG_PR_STATUS.PRStatus;
		this.PG_PR_STATUS_Reserved9 = this.PG_PR_STATUS.Reserved9;
		this.Reserved9 = this.PG_PR_STATUS.Reserved9;
		this.PG_PR_STATUS_NumbCredits = this.PG_PR_STATUS.NumbCredits;
		this.NumbCredits = this.PG_PR_STATUS.NumbCredits;
      this.PG_PR_DATA = ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_DATA::type_id::create("PG_PR_DATA",,get_full_name());
      this.PG_PR_DATA.configure(this, null, "");
      this.PG_PR_DATA.build();
      this.default_map.add_reg(this.PG_PR_DATA, `UVM_REG_ADDR_WIDTH'h70018, "RW", 0);
		this.PG_PR_DATA_PRData = this.PG_PR_DATA.PRData;
		this.PRData = this.PG_PR_DATA.PRData;
      this.PG_PR_ERROR = ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_ERROR::type_id::create("PG_PR_ERROR",,get_full_name());
      this.PG_PR_ERROR.configure(this, null, "");
      this.PG_PR_ERROR.build();
      this.default_map.add_reg(this.PG_PR_ERROR, `UVM_REG_ADDR_WIDTH'h70020, "RW", 0);
		this.PG_PR_ERROR_Reserved7 = this.PG_PR_ERROR.Reserved7;
		this.Reserved7 = this.PG_PR_ERROR.Reserved7;
		this.PG_PR_ERROR_SecureLoadFailed = this.PG_PR_ERROR.SecureLoadFailed;
		this.SecureLoadFailed = this.PG_PR_ERROR.SecureLoadFailed;
		this.PG_PR_ERROR_HostInitTimeout = this.PG_PR_ERROR.HostInitTimeout;
		this.HostInitTimeout = this.PG_PR_ERROR.HostInitTimeout;
		this.PG_PR_ERROR_HostInitFIFOOverflow = this.PG_PR_ERROR.HostInitFIFOOverflow;
		this.HostInitFIFOOverflow = this.PG_PR_ERROR.HostInitFIFOOverflow;
		this.PG_PR_ERROR_IPInitProtocolError = this.PG_PR_ERROR.IPInitProtocolError;
		this.IPInitProtocolError = this.PG_PR_ERROR.IPInitProtocolError;
		this.PG_PR_ERROR_IPInitIncompatibleBitstream = this.PG_PR_ERROR.IPInitIncompatibleBitstream;
		this.IPInitIncompatibleBitstream = this.PG_PR_ERROR.IPInitIncompatibleBitstream;
		this.PG_PR_ERROR_IPInitCRCError = this.PG_PR_ERROR.IPInitCRCError;
		this.IPInitCRCError = this.PG_PR_ERROR.IPInitCRCError;
		this.PG_PR_ERROR_HostInitOperationError = this.PG_PR_ERROR.HostInitOperationError;
		this.HostInitOperationError = this.PG_PR_ERROR.HostInitOperationError;
      this.DUMMY_5028 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5028::type_id::create("DUMMY_5028",,get_full_name());
      this.DUMMY_5028.configure(this, null, "");
      this.DUMMY_5028.build();
      this.default_map.add_reg(this.DUMMY_5028, `UVM_REG_ADDR_WIDTH'h70028, "RO", 0);
		this.DUMMY_5028_Zero = this.DUMMY_5028.Zero;
      this.DUMMY_5030 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5030::type_id::create("DUMMY_5030",,get_full_name());
      this.DUMMY_5030.configure(this, null, "");
      this.DUMMY_5030.build();
      this.default_map.add_reg(this.DUMMY_5030, `UVM_REG_ADDR_WIDTH'h70030, "RO", 0);
		this.DUMMY_5030_Zero = this.DUMMY_5030.Zero;
      this.DUMMY_5038 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5038::type_id::create("DUMMY_5038",,get_full_name());
      this.DUMMY_5038.configure(this, null, "");
      this.DUMMY_5038.build();
      this.default_map.add_reg(this.DUMMY_5038, `UVM_REG_ADDR_WIDTH'h70038, "RO", 0);
		this.DUMMY_5038_Zero = this.DUMMY_5038.Zero;
      this.DUMMY_5040 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5040::type_id::create("DUMMY_5040",,get_full_name());
      this.DUMMY_5040.configure(this, null, "");
      this.DUMMY_5040.build();
      this.default_map.add_reg(this.DUMMY_5040, `UVM_REG_ADDR_WIDTH'h70040, "RO", 0);
		this.DUMMY_5040_Zero = this.DUMMY_5040.Zero;
      this.DUMMY_5048 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5048::type_id::create("DUMMY_5048",,get_full_name());
      this.DUMMY_5048.configure(this, null, "");
      this.DUMMY_5048.build();
      this.default_map.add_reg(this.DUMMY_5048, `UVM_REG_ADDR_WIDTH'h70048, "RO", 0);
		this.DUMMY_5048_Zero = this.DUMMY_5048.Zero;
      this.DUMMY_5050 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5050::type_id::create("DUMMY_5050",,get_full_name());
      this.DUMMY_5050.configure(this, null, "");
      this.DUMMY_5050.build();
      this.default_map.add_reg(this.DUMMY_5050, `UVM_REG_ADDR_WIDTH'h70050, "RO", 0);
		this.DUMMY_5050_Zero = this.DUMMY_5050.Zero;
      this.DUMMY_5058 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5058::type_id::create("DUMMY_5058",,get_full_name());
      this.DUMMY_5058.configure(this, null, "");
      this.DUMMY_5058.build();
      this.default_map.add_reg(this.DUMMY_5058, `UVM_REG_ADDR_WIDTH'h70058, "RO", 0);
		this.DUMMY_5058_Zero = this.DUMMY_5058.Zero;
      this.DUMMY_5060 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5060::type_id::create("DUMMY_5060",,get_full_name());
      this.DUMMY_5060.configure(this, null, "");
      this.DUMMY_5060.build();
      this.default_map.add_reg(this.DUMMY_5060, `UVM_REG_ADDR_WIDTH'h70060, "RO", 0);
		this.DUMMY_5060_Zero = this.DUMMY_5060.Zero;
      this.DUMMY_5068 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5068::type_id::create("DUMMY_5068",,get_full_name());
      this.DUMMY_5068.configure(this, null, "");
      this.DUMMY_5068.build();
      this.default_map.add_reg(this.DUMMY_5068, `UVM_REG_ADDR_WIDTH'h70068, "RO", 0);
		this.DUMMY_5068_Zero = this.DUMMY_5068.Zero;
      this.DUMMY_5070 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5070::type_id::create("DUMMY_5070",,get_full_name());
      this.DUMMY_5070.configure(this, null, "");
      this.DUMMY_5070.build();
      this.default_map.add_reg(this.DUMMY_5070, `UVM_REG_ADDR_WIDTH'h70070, "RO", 0);
		this.DUMMY_5070_Zero = this.DUMMY_5070.Zero;
      this.DUMMY_5078 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5078::type_id::create("DUMMY_5078",,get_full_name());
      this.DUMMY_5078.configure(this, null, "");
      this.DUMMY_5078.build();
      this.default_map.add_reg(this.DUMMY_5078, `UVM_REG_ADDR_WIDTH'h70078, "RO", 0);
		this.DUMMY_5078_Zero = this.DUMMY_5078.Zero;
      this.DUMMY_5080 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5080::type_id::create("DUMMY_5080",,get_full_name());
      this.DUMMY_5080.configure(this, null, "");
      this.DUMMY_5080.build();
      this.default_map.add_reg(this.DUMMY_5080, `UVM_REG_ADDR_WIDTH'h70080, "RO", 0);
		this.DUMMY_5080_Zero = this.DUMMY_5080.Zero;
      this.DUMMY_5088 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5088::type_id::create("DUMMY_5088",,get_full_name());
      this.DUMMY_5088.configure(this, null, "");
      this.DUMMY_5088.build();
      this.default_map.add_reg(this.DUMMY_5088, `UVM_REG_ADDR_WIDTH'h70088, "RO", 0);
		this.DUMMY_5088_Zero = this.DUMMY_5088.Zero;
      this.DUMMY_5090 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5090::type_id::create("DUMMY_5090",,get_full_name());
      this.DUMMY_5090.configure(this, null, "");
      this.DUMMY_5090.build();
      this.default_map.add_reg(this.DUMMY_5090, `UVM_REG_ADDR_WIDTH'h70090, "RO", 0);
		this.DUMMY_5090_Zero = this.DUMMY_5090.Zero;
      this.DUMMY_5098 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_5098::type_id::create("DUMMY_5098",,get_full_name());
      this.DUMMY_5098.configure(this, null, "");
      this.DUMMY_5098.build();
      this.default_map.add_reg(this.DUMMY_5098, `UVM_REG_ADDR_WIDTH'h70098, "RO", 0);
		this.DUMMY_5098_Zero = this.DUMMY_5098.Zero;
      this.DUMMY_50A0 = ral_reg_ac_src_port_gasket_agilex_pg_DUMMY_50A0::type_id::create("DUMMY_50A0",,get_full_name());
      this.DUMMY_50A0.configure(this, null, "");
      this.DUMMY_50A0.build();
      this.default_map.add_reg(this.DUMMY_50A0, `UVM_REG_ADDR_WIDTH'h700A0, "RO", 0);
		this.DUMMY_50A0_Zero = this.DUMMY_50A0.Zero;
      this.PG_PR_INTFC_ID_L = ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_L::type_id::create("PG_PR_INTFC_ID_L",,get_full_name());
      this.PG_PR_INTFC_ID_L.configure(this, null, "");
      this.PG_PR_INTFC_ID_L.build();
      this.default_map.add_reg(this.PG_PR_INTFC_ID_L, `UVM_REG_ADDR_WIDTH'h700A8, "RO", 0);
		this.PG_PR_INTFC_ID_L_InterfaceIdL = this.PG_PR_INTFC_ID_L.InterfaceIdL;
		this.InterfaceIdL = this.PG_PR_INTFC_ID_L.InterfaceIdL;
      this.PG_PR_INTFC_ID_H = ral_reg_ac_src_port_gasket_agilex_pg_PG_PR_INTFC_ID_H::type_id::create("PG_PR_INTFC_ID_H",,get_full_name());
      this.PG_PR_INTFC_ID_H.configure(this, null, "");
      this.PG_PR_INTFC_ID_H.build();
      this.default_map.add_reg(this.PG_PR_INTFC_ID_H, `UVM_REG_ADDR_WIDTH'h700B0, "RO", 0);
		this.PG_PR_INTFC_ID_H_InterfaceIdH = this.PG_PR_INTFC_ID_H.InterfaceIdH;
		this.InterfaceIdH = this.PG_PR_INTFC_ID_H.InterfaceIdH;
      this.PG_SCRATCHPAD = ral_reg_ac_src_port_gasket_agilex_pg_PG_SCRATCHPAD::type_id::create("PG_SCRATCHPAD",,get_full_name());
      this.PG_SCRATCHPAD.configure(this, null, "");
      this.PG_SCRATCHPAD.build();
      this.default_map.add_reg(this.PG_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h700B8, "RW", 0);
		this.PG_SCRATCHPAD_Reserved = this.PG_SCRATCHPAD.Reserved;
      this.PORT_DFH = ral_reg_ac_src_port_gasket_agilex_pg_PORT_DFH::type_id::create("PORT_DFH",,get_full_name());
      this.PORT_DFH.configure(this, null, "");
      this.PORT_DFH.build();
      this.default_map.add_reg(this.PORT_DFH, `UVM_REG_ADDR_WIDTH'h71000, "RW", 0);
		this.PORT_DFH_FeatureType = this.PORT_DFH.FeatureType;
		this.PORT_DFH_Reserved41 = this.PORT_DFH.Reserved41;
		this.PORT_DFH_EOL = this.PORT_DFH.EOL;
		this.PORT_DFH_NextDfhOffset = this.PORT_DFH.NextDfhOffset;
		this.PORT_DFH_AfuMajVersion = this.PORT_DFH.AfuMajVersion;
		this.AfuMajVersion = this.PORT_DFH.AfuMajVersion;
		this.PORT_DFH_CorefimVersion = this.PORT_DFH.CorefimVersion;
		this.CorefimVersion = this.PORT_DFH.CorefimVersion;
      this.PORT_AFU_ID_L = ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_L::type_id::create("PORT_AFU_ID_L",,get_full_name());
      this.PORT_AFU_ID_L.configure(this, null, "");
      this.PORT_AFU_ID_L.build();
      this.default_map.add_reg(this.PORT_AFU_ID_L, `UVM_REG_ADDR_WIDTH'h71008, "RO", 0);
		this.PORT_AFU_ID_L_PortIdLow = this.PORT_AFU_ID_L.PortIdLow;
		this.PortIdLow = this.PORT_AFU_ID_L.PortIdLow;
      this.PORT_AFU_ID_H = ral_reg_ac_src_port_gasket_agilex_pg_PORT_AFU_ID_H::type_id::create("PORT_AFU_ID_H",,get_full_name());
      this.PORT_AFU_ID_H.configure(this, null, "");
      this.PORT_AFU_ID_H.build();
      this.default_map.add_reg(this.PORT_AFU_ID_H, `UVM_REG_ADDR_WIDTH'h91010, "RO", 0);
		this.PORT_AFU_ID_H_PortIdHigh = this.PORT_AFU_ID_H.PortIdHigh;
		this.PortIdHigh = this.PORT_AFU_ID_H.PortIdHigh;
      this.FIRST_AFU_OFFSET = ral_reg_ac_src_port_gasket_agilex_pg_FIRST_AFU_OFFSET::type_id::create("FIRST_AFU_OFFSET",,get_full_name());
      this.FIRST_AFU_OFFSET.configure(this, null, "");
      this.FIRST_AFU_OFFSET.build();
      this.default_map.add_reg(this.FIRST_AFU_OFFSET, `UVM_REG_ADDR_WIDTH'h71018, "RW", 0);
		this.FIRST_AFU_OFFSET_Reserved24 = this.FIRST_AFU_OFFSET.Reserved24;
		this.FIRST_AFU_OFFSET_PortAfuDfhOffset = this.FIRST_AFU_OFFSET.PortAfuDfhOffset;
		this.PortAfuDfhOffset = this.FIRST_AFU_OFFSET.PortAfuDfhOffset;
      this.PORT_MAILBOX = ral_reg_ac_src_port_gasket_agilex_pg_PORT_MAILBOX::type_id::create("PORT_MAILBOX",,get_full_name());
      this.PORT_MAILBOX.configure(this, null, "");
      this.PORT_MAILBOX.build();
      this.default_map.add_reg(this.PORT_MAILBOX, `UVM_REG_ADDR_WIDTH'h71020, "RW", 0);
		this.PORT_MAILBOX_Mailbox = this.PORT_MAILBOX.Mailbox;
		this.Mailbox = this.PORT_MAILBOX.Mailbox;
      this.PORT_SCRATCHPAD0 = ral_reg_ac_src_port_gasket_agilex_pg_PORT_SCRATCHPAD0::type_id::create("PORT_SCRATCHPAD0",,get_full_name());
      this.PORT_SCRATCHPAD0.configure(this, null, "");
      this.PORT_SCRATCHPAD0.build();
      this.default_map.add_reg(this.PORT_SCRATCHPAD0, `UVM_REG_ADDR_WIDTH'h71028, "RW", 0);
		this.PORT_SCRATCHPAD0_Scratchpad = this.PORT_SCRATCHPAD0.Scratchpad;
		this.Scratchpad = this.PORT_SCRATCHPAD0.Scratchpad;
      this.PORT_CAPABILITY = ral_reg_ac_src_port_gasket_agilex_pg_PORT_CAPABILITY::type_id::create("PORT_CAPABILITY",,get_full_name());
      this.PORT_CAPABILITY.configure(this, null, "");
      this.PORT_CAPABILITY.build();
      this.default_map.add_reg(this.PORT_CAPABILITY, `UVM_REG_ADDR_WIDTH'h71030, "RW", 0);
		this.PORT_CAPABILITY_Reserved36 = this.PORT_CAPABILITY.Reserved36;
		this.Reserved36 = this.PORT_CAPABILITY.Reserved36;
		this.PORT_CAPABILITY_NumbSuppInterrupt = this.PORT_CAPABILITY.NumbSuppInterrupt;
		this.NumbSuppInterrupt = this.PORT_CAPABILITY.NumbSuppInterrupt;
		this.PORT_CAPABILITY_Reserved24 = this.PORT_CAPABILITY.Reserved24;
		this.PORT_CAPABILITY_MmioSize = this.PORT_CAPABILITY.MmioSize;
		this.MmioSize = this.PORT_CAPABILITY.MmioSize;
		this.PORT_CAPABILITY_Reserved0 = this.PORT_CAPABILITY.Reserved0;
      this.PORT_CONTROL = ral_reg_ac_src_port_gasket_agilex_pg_PORT_CONTROL::type_id::create("PORT_CONTROL",,get_full_name());
      this.PORT_CONTROL.configure(this, null, "");
      this.PORT_CONTROL.build();
      this.default_map.add_reg(this.PORT_CONTROL, `UVM_REG_ADDR_WIDTH'h71038, "RW", 0);
		this.PORT_CONTROL_Reserved5 = this.PORT_CONTROL.Reserved5;
		this.PORT_CONTROL_PortSoftResetAck = this.PORT_CONTROL.PortSoftResetAck;
		this.PortSoftResetAck = this.PORT_CONTROL.PortSoftResetAck;
		this.PORT_CONTROL_FlrPortReset = this.PORT_CONTROL.FlrPortReset;
		this.FlrPortReset = this.PORT_CONTROL.FlrPortReset;
		this.PORT_CONTROL_LatencyTolerance = this.PORT_CONTROL.LatencyTolerance;
		this.LatencyTolerance = this.PORT_CONTROL.LatencyTolerance;
		this.PORT_CONTROL_Reserved1 = this.PORT_CONTROL.Reserved1;
		this.PORT_CONTROL_PortSoftReset = this.PORT_CONTROL.PortSoftReset;
		this.PortSoftReset = this.PORT_CONTROL.PortSoftReset;
      this.PORT_STATUS = ral_reg_ac_src_port_gasket_agilex_pg_PORT_STATUS::type_id::create("PORT_STATUS",,get_full_name());
      this.PORT_STATUS.configure(this, null, "");
      this.PORT_STATUS.build();
      this.default_map.add_reg(this.PORT_STATUS, `UVM_REG_ADDR_WIDTH'h71040, "RW", 0);
		this.PORT_STATUS_Reserved1 = this.PORT_STATUS.Reserved1;
		this.PORT_STATUS_PortFreeze = this.PORT_STATUS.PortFreeze;
		this.PortFreeze = this.PORT_STATUS.PortFreeze;
      this.USER_CLOCK_DFH = ral_reg_ac_src_port_gasket_agilex_pg_USER_CLOCK_DFH::type_id::create("USER_CLOCK_DFH",,get_full_name());
      this.USER_CLOCK_DFH.configure(this, null, "");
      this.USER_CLOCK_DFH.build();
      this.default_map.add_reg(this.USER_CLOCK_DFH, `UVM_REG_ADDR_WIDTH'h72000, "RW", 0);
		this.USER_CLOCK_DFH_FeatureType = this.USER_CLOCK_DFH.FeatureType;
		this.USER_CLOCK_DFH_Reserved41 = this.USER_CLOCK_DFH.Reserved41;
		this.USER_CLOCK_DFH_EOL = this.USER_CLOCK_DFH.EOL;
		this.USER_CLOCK_DFH_NextDfhOffset = this.USER_CLOCK_DFH.NextDfhOffset;
		this.USER_CLOCK_DFH_CciMinorRev = this.USER_CLOCK_DFH.CciMinorRev;
		this.CciMinorRev = this.USER_CLOCK_DFH.CciMinorRev;
		this.USER_CLOCK_DFH_CciVersion = this.USER_CLOCK_DFH.CciVersion;
		this.CciVersion = this.USER_CLOCK_DFH.CciVersion;
      this.USER_CLK_FREQ_CMD0 = ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD0::type_id::create("USER_CLK_FREQ_CMD0",,get_full_name());
      this.USER_CLK_FREQ_CMD0.configure(this, null, "");
      this.USER_CLK_FREQ_CMD0.build();
      this.default_map.add_reg(this.USER_CLK_FREQ_CMD0, `UVM_REG_ADDR_WIDTH'h72008, "RW", 0);
		this.USER_CLK_FREQ_CMD0_Reserved4 = this.USER_CLK_FREQ_CMD0.Reserved4;
		this.USER_CLK_FREQ_CMD0_UsrClkCmdPllRst = this.USER_CLK_FREQ_CMD0.UsrClkCmdPllRst;
		this.UsrClkCmdPllRst = this.USER_CLK_FREQ_CMD0.UsrClkCmdPllRst;
		this.USER_CLK_FREQ_CMD0_UsrClkCmdPllMgmtRst = this.USER_CLK_FREQ_CMD0.UsrClkCmdPllMgmtRst;
		this.UsrClkCmdPllMgmtRst = this.USER_CLK_FREQ_CMD0.UsrClkCmdPllMgmtRst;
		this.USER_CLK_FREQ_CMD0_Reserved3 = this.USER_CLK_FREQ_CMD0.Reserved3;
		this.USER_CLK_FREQ_CMD0_UsrClkCmdMmRst = this.USER_CLK_FREQ_CMD0.UsrClkCmdMmRst;
		this.UsrClkCmdMmRst = this.USER_CLK_FREQ_CMD0.UsrClkCmdMmRst;
		this.USER_CLK_FREQ_CMD0_Reserved2 = this.USER_CLK_FREQ_CMD0.Reserved2;
		this.USER_CLK_FREQ_CMD0_UsrClkCmdSeq = this.USER_CLK_FREQ_CMD0.UsrClkCmdSeq;
		this.UsrClkCmdSeq = this.USER_CLK_FREQ_CMD0.UsrClkCmdSeq;
		this.USER_CLK_FREQ_CMD0_Reserved1 = this.USER_CLK_FREQ_CMD0.Reserved1;
		this.USER_CLK_FREQ_CMD0_UsrClkCmdWr = this.USER_CLK_FREQ_CMD0.UsrClkCmdWr;
		this.UsrClkCmdWr = this.USER_CLK_FREQ_CMD0.UsrClkCmdWr;
		this.USER_CLK_FREQ_CMD0_Reserved0 = this.USER_CLK_FREQ_CMD0.Reserved0;
		this.USER_CLK_FREQ_CMD0_UsrClkCmdAdr = this.USER_CLK_FREQ_CMD0.UsrClkCmdAdr;
		this.UsrClkCmdAdr = this.USER_CLK_FREQ_CMD0.UsrClkCmdAdr;
		this.USER_CLK_FREQ_CMD0_UsrClkCmdDat = this.USER_CLK_FREQ_CMD0.UsrClkCmdDat;
		this.UsrClkCmdDat = this.USER_CLK_FREQ_CMD0.UsrClkCmdDat;
      this.USER_CLK_FREQ_CMD1 = ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_CMD1::type_id::create("USER_CLK_FREQ_CMD1",,get_full_name());
      this.USER_CLK_FREQ_CMD1.configure(this, null, "");
      this.USER_CLK_FREQ_CMD1.build();
      this.default_map.add_reg(this.USER_CLK_FREQ_CMD1, `UVM_REG_ADDR_WIDTH'h72010, "RW", 0);
		this.USER_CLK_FREQ_CMD1_Reserved1 = this.USER_CLK_FREQ_CMD1.Reserved1;
		this.USER_CLK_FREQ_CMD1_FreqCntrClkSel = this.USER_CLK_FREQ_CMD1.FreqCntrClkSel;
		this.FreqCntrClkSel = this.USER_CLK_FREQ_CMD1.FreqCntrClkSel;
		this.USER_CLK_FREQ_CMD1_Reserved0 = this.USER_CLK_FREQ_CMD1.Reserved0;
      this.USER_CLK_FREQ_STS0 = ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS0::type_id::create("USER_CLK_FREQ_STS0",,get_full_name());
      this.USER_CLK_FREQ_STS0.configure(this, null, "");
      this.USER_CLK_FREQ_STS0.build();
      this.default_map.add_reg(this.USER_CLK_FREQ_STS0, `UVM_REG_ADDR_WIDTH'h72018, "RW", 0);
		this.USER_CLK_FREQ_STS0_UsrClkStMmError = this.USER_CLK_FREQ_STS0.UsrClkStMmError;
		this.UsrClkStMmError = this.USER_CLK_FREQ_STS0.UsrClkStMmError;
		this.USER_CLK_FREQ_STS0_UsrClkStPllActClk = this.USER_CLK_FREQ_STS0.UsrClkStPllActClk;
		this.UsrClkStPllActClk = this.USER_CLK_FREQ_STS0.UsrClkStPllActClk;
		this.USER_CLK_FREQ_STS0_UsrClkStPllLocked = this.USER_CLK_FREQ_STS0.UsrClkStPllLocked;
		this.UsrClkStPllLocked = this.USER_CLK_FREQ_STS0.UsrClkStPllLocked;
		this.USER_CLK_FREQ_STS0_Reserved4 = this.USER_CLK_FREQ_STS0.Reserved4;
		this.USER_CLK_FREQ_STS0_UsrClkStPllRst = this.USER_CLK_FREQ_STS0.UsrClkStPllRst;
		this.UsrClkStPllRst = this.USER_CLK_FREQ_STS0.UsrClkStPllRst;
		this.USER_CLK_FREQ_STS0_UsrClkStPllMgmtRst = this.USER_CLK_FREQ_STS0.UsrClkStPllMgmtRst;
		this.UsrClkStPllMgmtRst = this.USER_CLK_FREQ_STS0.UsrClkStPllMgmtRst;
		this.USER_CLK_FREQ_STS0_Reserved3 = this.USER_CLK_FREQ_STS0.Reserved3;
		this.USER_CLK_FREQ_STS0_UsrClkStMmRst = this.USER_CLK_FREQ_STS0.UsrClkStMmRst;
		this.UsrClkStMmRst = this.USER_CLK_FREQ_STS0.UsrClkStMmRst;
		this.USER_CLK_FREQ_STS0_Reserved2 = this.USER_CLK_FREQ_STS0.Reserved2;
		this.USER_CLK_FREQ_STS0_UsrClkStSeq = this.USER_CLK_FREQ_STS0.UsrClkStSeq;
		this.UsrClkStSeq = this.USER_CLK_FREQ_STS0.UsrClkStSeq;
		this.USER_CLK_FREQ_STS0_Reserved1 = this.USER_CLK_FREQ_STS0.Reserved1;
		this.USER_CLK_FREQ_STS0_UsrClkStWr = this.USER_CLK_FREQ_STS0.UsrClkStWr;
		this.UsrClkStWr = this.USER_CLK_FREQ_STS0.UsrClkStWr;
		this.USER_CLK_FREQ_STS0_Reserved0 = this.USER_CLK_FREQ_STS0.Reserved0;
		this.USER_CLK_FREQ_STS0_UsrClkStAdr = this.USER_CLK_FREQ_STS0.UsrClkStAdr;
		this.UsrClkStAdr = this.USER_CLK_FREQ_STS0.UsrClkStAdr;
		this.USER_CLK_FREQ_STS0_UsrClkStDat = this.USER_CLK_FREQ_STS0.UsrClkStDat;
		this.UsrClkStDat = this.USER_CLK_FREQ_STS0.UsrClkStDat;
      this.USER_CLK_FREQ_STS1 = ral_reg_ac_src_port_gasket_agilex_pg_USER_CLK_FREQ_STS1::type_id::create("USER_CLK_FREQ_STS1",,get_full_name());
      this.USER_CLK_FREQ_STS1.configure(this, null, "");
      this.USER_CLK_FREQ_STS1.build();
      this.default_map.add_reg(this.USER_CLK_FREQ_STS1, `UVM_REG_ADDR_WIDTH'h72020, "RO", 0);
		this.USER_CLK_FREQ_STS1_FreqCntrVersion = this.USER_CLK_FREQ_STS1.FreqCntrVersion;
		this.FreqCntrVersion = this.USER_CLK_FREQ_STS1.FreqCntrVersion;
		this.USER_CLK_FREQ_STS1_Reserved = this.USER_CLK_FREQ_STS1.Reserved;
		this.USER_CLK_FREQ_STS1_FreqPLLRef = this.USER_CLK_FREQ_STS1.FreqPLLRef;
		this.FreqPLLRef = this.USER_CLK_FREQ_STS1.FreqPLLRef;
		this.USER_CLK_FREQ_STS1_FreqCntrClkMeasured = this.USER_CLK_FREQ_STS1.FreqCntrClkMeasured;
		this.FreqCntrClkMeasured = this.USER_CLK_FREQ_STS1.FreqCntrClkMeasured;
		this.USER_CLK_FREQ_STS1_Reserved41 = this.USER_CLK_FREQ_STS1.Reserved41;
		this.USER_CLK_FREQ_STS1_FreqCntrMeasuredFreq = this.USER_CLK_FREQ_STS1.FreqCntrMeasuredFreq;
		this.FreqCntrMeasuredFreq = this.USER_CLK_FREQ_STS1.FreqCntrMeasuredFreq;
      this.PORT_STP_DFH = ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_DFH::type_id::create("PORT_STP_DFH",,get_full_name());
      this.PORT_STP_DFH.configure(this, null, "");
      this.PORT_STP_DFH.build();
      this.default_map.add_reg(this.PORT_STP_DFH, `UVM_REG_ADDR_WIDTH'h73000, "RW", 0);
		this.PORT_STP_DFH_FeatureType = this.PORT_STP_DFH.FeatureType;
		this.PORT_STP_DFH_Reserved41 = this.PORT_STP_DFH.Reserved41;
		this.PORT_STP_DFH_EOL = this.PORT_STP_DFH.EOL;
		this.PORT_STP_DFH_NextDfhByteOffset = this.PORT_STP_DFH.NextDfhByteOffset;
		this.PORT_STP_DFH_FeatureRev = this.PORT_STP_DFH.FeatureRev;
		this.PORT_STP_DFH_FeatureID = this.PORT_STP_DFH.FeatureID;
      this.PORT_STP_STATUS = ral_reg_ac_src_port_gasket_agilex_pg_PORT_STP_STATUS::type_id::create("PORT_STP_STATUS",,get_full_name());
      this.PORT_STP_STATUS.configure(this, null, "");
      this.PORT_STP_STATUS.build();
      this.default_map.add_reg(this.PORT_STP_STATUS, `UVM_REG_ADDR_WIDTH'h73008, "RO", 0);
		this.PORT_STP_STATUS_NumMmioResp = this.PORT_STP_STATUS.NumMmioResp;
		this.NumMmioResp = this.PORT_STP_STATUS.NumMmioResp;
		this.PORT_STP_STATUS_NumMmioReq = this.PORT_STP_STATUS.NumMmioReq;
		this.NumMmioReq = this.PORT_STP_STATUS.NumMmioReq;
		this.PORT_STP_STATUS_NumMmioWr = this.PORT_STP_STATUS.NumMmioWr;
		this.NumMmioWr = this.PORT_STP_STATUS.NumMmioWr;
		this.PORT_STP_STATUS_RxFifoUnderflow = this.PORT_STP_STATUS.RxFifoUnderflow;
		this.RxFifoUnderflow = this.PORT_STP_STATUS.RxFifoUnderflow;
		this.PORT_STP_STATUS_RxFifoOverflow = this.PORT_STP_STATUS.RxFifoOverflow;
		this.RxFifoOverflow = this.PORT_STP_STATUS.RxFifoOverflow;
		this.PORT_STP_STATUS_TxFifoUnderflow = this.PORT_STP_STATUS.TxFifoUnderflow;
		this.TxFifoUnderflow = this.PORT_STP_STATUS.TxFifoUnderflow;
		this.PORT_STP_STATUS_TxFifoOverflow = this.PORT_STP_STATUS.TxFifoOverflow;
		this.TxFifoOverflow = this.PORT_STP_STATUS.TxFifoOverflow;
		this.PORT_STP_STATUS_RxFifoCount = this.PORT_STP_STATUS.RxFifoCount;
		this.RxFifoCount = this.PORT_STP_STATUS.RxFifoCount;
		this.PORT_STP_STATUS_TxFifoCount = this.PORT_STP_STATUS.TxFifoCount;
		this.TxFifoCount = this.PORT_STP_STATUS.TxFifoCount;
		this.PORT_STP_STATUS_MmioTimeOut = this.PORT_STP_STATUS.MmioTimeOut;
		this.MmioTimeOut = this.PORT_STP_STATUS.MmioTimeOut;
		this.PORT_STP_STATUS_UnsupportedRD = this.PORT_STP_STATUS.UnsupportedRD;
		this.UnsupportedRD = this.PORT_STP_STATUS.UnsupportedRD;
		this.PORT_STP_STATUS_StpInReset = this.PORT_STP_STATUS.StpInReset;
		this.StpInReset = this.PORT_STP_STATUS.StpInReset;
		this.PORT_STP_STATUS_RwTimeOut = this.PORT_STP_STATUS.RwTimeOut;
		this.RwTimeOut = this.PORT_STP_STATUS.RwTimeOut;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_src_port_gasket_agilex_pg)


	function void sample_values();
	   super.sample_values();
		if (get_coverage(UVM_CVR_FIELD_VALS)) begin
			if (PG_PR_DFH.cg_vals != null) PG_PR_DFH.cg_vals.sample();
			if (PG_PR_CTRL.cg_vals != null) PG_PR_CTRL.cg_vals.sample();
			if (PG_PR_STATUS.cg_vals != null) PG_PR_STATUS.cg_vals.sample();
			if (PG_PR_DATA.cg_vals != null) PG_PR_DATA.cg_vals.sample();
			if (PG_PR_ERROR.cg_vals != null) PG_PR_ERROR.cg_vals.sample();
			if (DUMMY_5028.cg_vals != null) DUMMY_5028.cg_vals.sample();
			if (DUMMY_5030.cg_vals != null) DUMMY_5030.cg_vals.sample();
			if (DUMMY_5038.cg_vals != null) DUMMY_5038.cg_vals.sample();
			if (DUMMY_5040.cg_vals != null) DUMMY_5040.cg_vals.sample();
			if (DUMMY_5048.cg_vals != null) DUMMY_5048.cg_vals.sample();
			if (DUMMY_5050.cg_vals != null) DUMMY_5050.cg_vals.sample();
			if (DUMMY_5058.cg_vals != null) DUMMY_5058.cg_vals.sample();
			if (DUMMY_5060.cg_vals != null) DUMMY_5060.cg_vals.sample();
			if (DUMMY_5068.cg_vals != null) DUMMY_5068.cg_vals.sample();
			if (DUMMY_5070.cg_vals != null) DUMMY_5070.cg_vals.sample();
			if (DUMMY_5078.cg_vals != null) DUMMY_5078.cg_vals.sample();
			if (DUMMY_5080.cg_vals != null) DUMMY_5080.cg_vals.sample();
			if (DUMMY_5088.cg_vals != null) DUMMY_5088.cg_vals.sample();
			if (DUMMY_5090.cg_vals != null) DUMMY_5090.cg_vals.sample();
			if (DUMMY_5098.cg_vals != null) DUMMY_5098.cg_vals.sample();
			if (DUMMY_50A0.cg_vals != null) DUMMY_50A0.cg_vals.sample();
			if (PG_PR_INTFC_ID_L.cg_vals != null) PG_PR_INTFC_ID_L.cg_vals.sample();
			if (PG_PR_INTFC_ID_H.cg_vals != null) PG_PR_INTFC_ID_H.cg_vals.sample();
			if (PG_SCRATCHPAD.cg_vals != null) PG_SCRATCHPAD.cg_vals.sample();
			if (PORT_DFH.cg_vals != null) PORT_DFH.cg_vals.sample();
			if (PORT_AFU_ID_L.cg_vals != null) PORT_AFU_ID_L.cg_vals.sample();
			if (PORT_AFU_ID_H.cg_vals != null) PORT_AFU_ID_H.cg_vals.sample();
			if (FIRST_AFU_OFFSET.cg_vals != null) FIRST_AFU_OFFSET.cg_vals.sample();
			if (PORT_MAILBOX.cg_vals != null) PORT_MAILBOX.cg_vals.sample();
			if (PORT_SCRATCHPAD0.cg_vals != null) PORT_SCRATCHPAD0.cg_vals.sample();
			if (PORT_CAPABILITY.cg_vals != null) PORT_CAPABILITY.cg_vals.sample();
			if (PORT_CONTROL.cg_vals != null) PORT_CONTROL.cg_vals.sample();
			if (PORT_STATUS.cg_vals != null) PORT_STATUS.cg_vals.sample();
			if (USER_CLOCK_DFH.cg_vals != null) USER_CLOCK_DFH.cg_vals.sample();
			if (USER_CLK_FREQ_CMD0.cg_vals != null) USER_CLK_FREQ_CMD0.cg_vals.sample();
			if (USER_CLK_FREQ_CMD1.cg_vals != null) USER_CLK_FREQ_CMD1.cg_vals.sample();
			if (USER_CLK_FREQ_STS0.cg_vals != null) USER_CLK_FREQ_STS0.cg_vals.sample();
			if (USER_CLK_FREQ_STS1.cg_vals != null) USER_CLK_FREQ_STS1.cg_vals.sample();
			if (PORT_STP_DFH.cg_vals != null) PORT_STP_DFH.cg_vals.sample();
			if (PORT_STP_STATUS.cg_vals != null) PORT_STP_STATUS.cg_vals.sample();
		end
	endfunction
endclass : ral_block_ac_src_port_gasket_agilex_pg



`endif
