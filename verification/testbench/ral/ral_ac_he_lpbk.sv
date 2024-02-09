// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_HE_LPBK
`define RAL_AC_HE_LPBK

import uvm_pkg::*;

class ral_reg_ac_he_lpbk_HE_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	uvm_reg_field Rsvd_59_52;
	uvm_reg_field AfuMinVersion;
	rand uvm_reg_field Rsvd_47_41;
	uvm_reg_field EOL;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field AfuMajVersion;
	uvm_reg_field FeatureID;

	function new(string name = "ac_he_lpbk_HE_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h1, 1, 0, 0);
      this.Rsvd_59_52 = uvm_reg_field::type_id::create("Rsvd_59_52",,get_full_name());
      this.Rsvd_59_52.configure(this, 8, 52, "RO", 0, 8'h0, 1, 0, 0);
      this.AfuMinVersion = uvm_reg_field::type_id::create("AfuMinVersion",,get_full_name());
      this.AfuMinVersion.configure(this, 4, 48, "RO", 0, 4'h0, 1, 0, 0);
      this.Rsvd_47_41 = uvm_reg_field::type_id::create("Rsvd_47_41",,get_full_name());
      this.Rsvd_47_41.configure(this, 7, 41, "WO", 0, 7'h0, 1, 0, 0);
      this.EOL = uvm_reg_field::type_id::create("EOL",,get_full_name());
      this.EOL.configure(this, 1, 40, "RO", 0, 1'h1, 1, 0, 0);
      this.NextDfhOffset = uvm_reg_field::type_id::create("NextDfhOffset",,get_full_name());
      this.NextDfhOffset.configure(this, 24, 16, "RO", 0, 24'h0, 1, 0, 1);
      this.AfuMajVersion = uvm_reg_field::type_id::create("AfuMajVersion",,get_full_name());
      this.AfuMajVersion.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_HE_DFH)

endclass : ral_reg_ac_he_lpbk_HE_DFH


class ral_reg_ac_he_lpbk_HE_ID_L extends uvm_reg;
	uvm_reg_field HEIDLow;

	function new(string name = "ac_he_lpbk_HE_ID_L");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.HEIDLow = uvm_reg_field::type_id::create("HEIDLow",,get_full_name());
      this.HEIDLow.configure(this, 64, 0, "RO", 0, 64'hb94b12284c31e02b, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_HE_ID_L)

endclass : ral_reg_ac_he_lpbk_HE_ID_L


class ral_reg_ac_he_lpbk_HE_ID_H extends uvm_reg;
	uvm_reg_field HEIDHigh;

	function new(string name = "ac_he_lpbk_HE_ID_H");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.HEIDHigh = uvm_reg_field::type_id::create("HEIDHigh",,get_full_name());
      this.HEIDHigh.configure(this, 64, 0, "RO", 0, 64'h56e203e9864f49a7, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_HE_ID_H)

endclass : ral_reg_ac_he_lpbk_HE_ID_H


class ral_reg_ac_he_lpbk_DFH_RSVD0 extends uvm_reg;
	rand uvm_reg_field DfhRsvd0;

	function new(string name = "ac_he_lpbk_DFH_RSVD0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DfhRsvd0 = uvm_reg_field::type_id::create("DfhRsvd0",,get_full_name());
      this.DfhRsvd0.configure(this, 64, 0, "WO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_DFH_RSVD0)

endclass : ral_reg_ac_he_lpbk_DFH_RSVD0


class ral_reg_ac_he_lpbk_DFH_RSVD1 extends uvm_reg;
	rand uvm_reg_field DfhRsvd1;

	function new(string name = "ac_he_lpbk_DFH_RSVD1");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DfhRsvd1 = uvm_reg_field::type_id::create("DfhRsvd1",,get_full_name());
      this.DfhRsvd1.configure(this, 64, 0, "WO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_DFH_RSVD1)

endclass : ral_reg_ac_he_lpbk_DFH_RSVD1


class ral_reg_ac_he_lpbk_SCRATCHPAD0 extends uvm_reg;
	rand uvm_reg_field Scratchpad0;

	function new(string name = "ac_he_lpbk_SCRATCHPAD0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scratchpad0 = uvm_reg_field::type_id::create("Scratchpad0",,get_full_name());
      this.Scratchpad0.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_SCRATCHPAD0)

endclass : ral_reg_ac_he_lpbk_SCRATCHPAD0


class ral_reg_ac_he_lpbk_SCRATCHPAD1 extends uvm_reg;
	rand uvm_reg_field Scratchpad1;

	function new(string name = "ac_he_lpbk_SCRATCHPAD1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scratchpad1 = uvm_reg_field::type_id::create("Scratchpad1",,get_full_name());
      this.Scratchpad1.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_SCRATCHPAD1)

endclass : ral_reg_ac_he_lpbk_SCRATCHPAD1


class ral_reg_ac_he_lpbk_SCRATCHPAD2 extends uvm_reg;
	rand uvm_reg_field Scratchpad2;

	function new(string name = "ac_he_lpbk_SCRATCHPAD2");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scratchpad2 = uvm_reg_field::type_id::create("Scratchpad2",,get_full_name());
      this.Scratchpad2.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_SCRATCHPAD2)

endclass : ral_reg_ac_he_lpbk_SCRATCHPAD2


class ral_reg_ac_he_lpbk_DSM_BASEL extends uvm_reg;
	rand uvm_reg_field DsmBaseL;

	function new(string name = "ac_he_lpbk_DSM_BASEL");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DsmBaseL = uvm_reg_field::type_id::create("DsmBaseL",,get_full_name());
      this.DsmBaseL.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_DSM_BASEL)

endclass : ral_reg_ac_he_lpbk_DSM_BASEL


class ral_reg_ac_he_lpbk_DSM_BASEH extends uvm_reg;
	rand uvm_reg_field DsmBaseH;

	function new(string name = "ac_he_lpbk_DSM_BASEH");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DsmBaseH = uvm_reg_field::type_id::create("DsmBaseH",,get_full_name());
      this.DsmBaseH.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_DSM_BASEH)

endclass : ral_reg_ac_he_lpbk_DSM_BASEH


class ral_reg_ac_he_lpbk_SRC_ADDR extends uvm_reg;
	rand uvm_reg_field SrcAddr;

	function new(string name = "ac_he_lpbk_SRC_ADDR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.SrcAddr = uvm_reg_field::type_id::create("SrcAddr",,get_full_name());
      this.SrcAddr.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_SRC_ADDR)

endclass : ral_reg_ac_he_lpbk_SRC_ADDR


class ral_reg_ac_he_lpbk_DST_ADDR extends uvm_reg;
	rand uvm_reg_field DstAddr;

	function new(string name = "ac_he_lpbk_DST_ADDR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DstAddr = uvm_reg_field::type_id::create("DstAddr",,get_full_name());
      this.DstAddr.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_DST_ADDR)

endclass : ral_reg_ac_he_lpbk_DST_ADDR


class ral_reg_ac_he_lpbk_NUM_LINES extends uvm_reg;
	rand uvm_reg_field Rsvd_31_10;
	rand uvm_reg_field NumCacheLines;

	function new(string name = "ac_he_lpbk_NUM_LINES");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Rsvd_31_10 = uvm_reg_field::type_id::create("Rsvd_31_10",,get_full_name());
      this.Rsvd_31_10.configure(this, 22, 10, "WO", 0, 22'h0, 1, 0, 0);
      this.NumCacheLines = uvm_reg_field::type_id::create("NumCacheLines",,get_full_name());
      this.NumCacheLines.configure(this, 10, 0, "RW", 0, 10'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_NUM_LINES)

endclass : ral_reg_ac_he_lpbk_NUM_LINES


class ral_reg_ac_he_lpbk_CTL extends uvm_reg;
	rand uvm_reg_field Rsvd_31_3;
	rand uvm_reg_field ForcedTestCmpl;
	rand uvm_reg_field Start;
	rand uvm_reg_field ResetL;

	function new(string name = "ac_he_lpbk_CTL");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Rsvd_31_3 = uvm_reg_field::type_id::create("Rsvd_31_3",,get_full_name());
      this.Rsvd_31_3.configure(this, 29, 3, "WO", 0, 29'h0, 1, 0, 0);
      this.ForcedTestCmpl = uvm_reg_field::type_id::create("ForcedTestCmpl",,get_full_name());
      this.ForcedTestCmpl.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
      this.Start = uvm_reg_field::type_id::create("Start",,get_full_name());
      this.Start.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.ResetL = uvm_reg_field::type_id::create("ResetL",,get_full_name());
      this.ResetL.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_CTL)

endclass : ral_reg_ac_he_lpbk_CTL


class ral_reg_ac_he_lpbk_CFG extends uvm_reg;
	rand uvm_reg_field Rsvd_63_32;
	rand uvm_reg_field ReqLen_H;
	rand uvm_reg_field IntrTestMode;
	rand uvm_reg_field IntrOnErr;
	rand uvm_reg_field TestCfg;
	rand uvm_reg_field TputInterleave;
	rand uvm_reg_field Rsvd_19_12;
	rand uvm_reg_field Atomic;
	rand uvm_reg_field ReqLen;
	rand uvm_reg_field TestMode;
	rand uvm_reg_field ContinuousMode;
	rand uvm_reg_field DelayEn;

	function new(string name = "ac_he_lpbk_CFG");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Rsvd_63_32 = uvm_reg_field::type_id::create("Rsvd_63_32",,get_full_name());
      this.Rsvd_63_32.configure(this, 32, 32, "WO", 0, 32'h0, 1, 0, 1);
      this.ReqLen_H = uvm_reg_field::type_id::create("ReqLen_H",,get_full_name());
      this.ReqLen_H.configure(this, 2, 30, "RW", 0, 2'h0, 1, 0, 0);
      this.IntrTestMode = uvm_reg_field::type_id::create("IntrTestMode",,get_full_name());
      this.IntrTestMode.configure(this, 1, 29, "RW", 0, 1'h0, 1, 0, 0);
      this.IntrOnErr = uvm_reg_field::type_id::create("IntrOnErr",,get_full_name());
      this.IntrOnErr.configure(this, 1, 28, "RW", 0, 1'h0, 1, 0, 0);
      this.TestCfg = uvm_reg_field::type_id::create("TestCfg",,get_full_name());
      this.TestCfg.configure(this, 5, 23, "RW", 0, 5'h0, 1, 0, 0);
      this.TputInterleave = uvm_reg_field::type_id::create("TputInterleave",,get_full_name());
      this.TputInterleave.configure(this, 3, 20, "RW", 0, 3'h0, 1, 0, 0);
      this.Rsvd_19_12 = uvm_reg_field::type_id::create("Rsvd_19_12",,get_full_name());
      this.Rsvd_19_12.configure(this, 8, 12, "WO", 0, 8'h0, 1, 0, 0);
      this.Atomic = uvm_reg_field::type_id::create("Atomic",,get_full_name());
      this.Atomic.configure(this, 5, 7, "RW", 0, 5'h0, 1, 0, 0);
      this.ReqLen = uvm_reg_field::type_id::create("ReqLen",,get_full_name());
      this.ReqLen.configure(this, 2, 5, "RW", 0, 2'h0, 1, 0, 0);
      this.TestMode = uvm_reg_field::type_id::create("TestMode",,get_full_name());
      this.TestMode.configure(this, 3, 2, "RW", 0, 3'h0, 1, 0, 0);
      this.ContinuousMode = uvm_reg_field::type_id::create("ContinuousMode",,get_full_name());
      this.ContinuousMode.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.DelayEn = uvm_reg_field::type_id::create("DelayEn",,get_full_name());
      this.DelayEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_CFG)

endclass : ral_reg_ac_he_lpbk_CFG


class ral_reg_ac_he_lpbk_INACT_THRESH extends uvm_reg;
	rand uvm_reg_field InactivtyThreshold;

	function new(string name = "ac_he_lpbk_INACT_THRESH");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.InactivtyThreshold = uvm_reg_field::type_id::create("InactivtyThreshold",,get_full_name());
      this.InactivtyThreshold.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_INACT_THRESH)

endclass : ral_reg_ac_he_lpbk_INACT_THRESH


class ral_reg_ac_he_lpbk_INTERRUPT0 extends uvm_reg;
	rand uvm_reg_field VectorNum;
	rand uvm_reg_field ApicID;

	function new(string name = "ac_he_lpbk_INTERRUPT0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.VectorNum = uvm_reg_field::type_id::create("VectorNum",,get_full_name());
      this.VectorNum.configure(this, 16, 16, "RW", 0, 16'h0, 1, 0, 1);
      this.ApicID = uvm_reg_field::type_id::create("ApicID",,get_full_name());
      this.ApicID.configure(this, 16, 0, "RW", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_INTERRUPT0)

endclass : ral_reg_ac_he_lpbk_INTERRUPT0


class ral_reg_ac_he_lpbk_SWTEST_MSG extends uvm_reg;
	rand uvm_reg_field SwTestMsg;

	function new(string name = "ac_he_lpbk_SWTEST_MSG");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.SwTestMsg = uvm_reg_field::type_id::create("SwTestMsg",,get_full_name());
      this.SwTestMsg.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_SWTEST_MSG)

endclass : ral_reg_ac_he_lpbk_SWTEST_MSG


class ral_reg_ac_he_lpbk_STATUS0 extends uvm_reg;
	uvm_reg_field NumReads;
	uvm_reg_field NumWrites;

	function new(string name = "ac_he_lpbk_STATUS0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.NumReads = uvm_reg_field::type_id::create("NumReads",,get_full_name());
      this.NumReads.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.NumWrites = uvm_reg_field::type_id::create("NumWrites",,get_full_name());
      this.NumWrites.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_STATUS0)

endclass : ral_reg_ac_he_lpbk_STATUS0


class ral_reg_ac_he_lpbk_STATUS1 extends uvm_reg;
	uvm_reg_field NumPendEmifReads;
	uvm_reg_field NumPendEmifWrites;
	uvm_reg_field NumPendHostReads;
	uvm_reg_field NumPendHostWrites;

	function new(string name = "ac_he_lpbk_STATUS1");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.NumPendEmifReads = uvm_reg_field::type_id::create("NumPendEmifReads",,get_full_name());
      this.NumPendEmifReads.configure(this, 16, 48, "RO", 0, 16'h0, 1, 0, 1);
      this.NumPendEmifWrites = uvm_reg_field::type_id::create("NumPendEmifWrites",,get_full_name());
      this.NumPendEmifWrites.configure(this, 16, 32, "RO", 0, 16'h0, 1, 0, 1);
      this.NumPendHostReads = uvm_reg_field::type_id::create("NumPendHostReads",,get_full_name());
      this.NumPendHostReads.configure(this, 16, 16, "RO", 0, 16'h0, 1, 0, 1);
      this.NumPendHostWrites = uvm_reg_field::type_id::create("NumPendHostWrites",,get_full_name());
      this.NumPendHostWrites.configure(this, 16, 0, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_STATUS1)

endclass : ral_reg_ac_he_lpbk_STATUS1


class ral_reg_ac_he_lpbk_ERROR extends uvm_reg;
	uvm_reg_field Rsvd_63_32;
	uvm_reg_field Error;

	function new(string name = "ac_he_lpbk_ERROR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Rsvd_63_32 = uvm_reg_field::type_id::create("Rsvd_63_32",,get_full_name());
      this.Rsvd_63_32.configure(this, 32, 32, "RO", 0, 32'h0, 1, 0, 1);
      this.Error = uvm_reg_field::type_id::create("Error",,get_full_name());
      this.Error.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_ERROR)

endclass : ral_reg_ac_he_lpbk_ERROR


class ral_reg_ac_he_lpbk_STRIDE extends uvm_reg;
	uvm_reg_field Stride;

	function new(string name = "ac_he_lpbk_STRIDE");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Stride = uvm_reg_field::type_id::create("Stride",,get_full_name());
      this.Stride.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_STRIDE)

endclass : ral_reg_ac_he_lpbk_STRIDE


class ral_reg_ac_he_lpbk_INFO0 extends uvm_reg;
	uvm_reg_field Rsvd_63_25;
	uvm_reg_field AtomicsNotSupported;
	uvm_reg_field APIVersion;
	uvm_reg_field ClkFreq;

	function new(string name = "ac_he_lpbk_INFO0");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Rsvd_63_25 = uvm_reg_field::type_id::create("Rsvd_63_25",,get_full_name());
      this.Rsvd_63_25.configure(this, 39, 25, "RO", 0, 39'h000000000, 1, 0, 0);
      this.AtomicsNotSupported = uvm_reg_field::type_id::create("AtomicsNotSupported",,get_full_name());
      this.AtomicsNotSupported.configure(this, 1, 24, "RO", 0, 1'h0, 1, 0, 0);
      this.APIVersion = uvm_reg_field::type_id::create("APIVersion",,get_full_name());
      this.APIVersion.configure(this, 8, 16, "RO", 0, 8'h1, 1, 0, 1);
      this.ClkFreq = uvm_reg_field::type_id::create("ClkFreq",,get_full_name());
      this.ClkFreq.configure(this, 16, 0, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_he_lpbk_INFO0)

endclass : ral_reg_ac_he_lpbk_INFO0


class ral_block_ac_he_lpbk extends uvm_reg_block;
	rand ral_reg_ac_he_lpbk_HE_DFH HE_DFH;
	rand ral_reg_ac_he_lpbk_HE_ID_L HE_ID_L;
	rand ral_reg_ac_he_lpbk_HE_ID_H HE_ID_H;
	rand ral_reg_ac_he_lpbk_DFH_RSVD0 DFH_RSVD0;
	rand ral_reg_ac_he_lpbk_DFH_RSVD1 DFH_RSVD1;
	rand ral_reg_ac_he_lpbk_SCRATCHPAD0 SCRATCHPAD0;
	rand ral_reg_ac_he_lpbk_SCRATCHPAD1 SCRATCHPAD1;
	rand ral_reg_ac_he_lpbk_SCRATCHPAD2 SCRATCHPAD2;
	rand ral_reg_ac_he_lpbk_DSM_BASEL DSM_BASEL;
	rand ral_reg_ac_he_lpbk_DSM_BASEH DSM_BASEH;
	rand ral_reg_ac_he_lpbk_SRC_ADDR SRC_ADDR;
	rand ral_reg_ac_he_lpbk_DST_ADDR DST_ADDR;
	rand ral_reg_ac_he_lpbk_NUM_LINES NUM_LINES;
	rand ral_reg_ac_he_lpbk_CTL CTL;
	rand ral_reg_ac_he_lpbk_CFG CFG;
	rand ral_reg_ac_he_lpbk_INACT_THRESH INACT_THRESH;
	rand ral_reg_ac_he_lpbk_INTERRUPT0 INTERRUPT0;
	rand ral_reg_ac_he_lpbk_SWTEST_MSG SWTEST_MSG;
	rand ral_reg_ac_he_lpbk_STATUS0 STATUS0;
	rand ral_reg_ac_he_lpbk_STATUS1 STATUS1;
	rand ral_reg_ac_he_lpbk_ERROR ERROR;
	rand ral_reg_ac_he_lpbk_STRIDE STRIDE;
	rand ral_reg_ac_he_lpbk_INFO0 INFO0;
	uvm_reg_field HE_DFH_FeatureType;
	uvm_reg_field FeatureType;
	uvm_reg_field HE_DFH_Rsvd_59_52;
	uvm_reg_field Rsvd_59_52;
	uvm_reg_field HE_DFH_AfuMinVersion;
	uvm_reg_field AfuMinVersion;
	rand uvm_reg_field HE_DFH_Rsvd_47_41;
	rand uvm_reg_field Rsvd_47_41;
	uvm_reg_field HE_DFH_EOL;
	uvm_reg_field EOL;
	uvm_reg_field HE_DFH_NextDfhOffset;
	uvm_reg_field NextDfhOffset;
	uvm_reg_field HE_DFH_AfuMajVersion;
	uvm_reg_field AfuMajVersion;
	uvm_reg_field HE_DFH_FeatureID;
	uvm_reg_field FeatureID;
	uvm_reg_field HE_ID_L_HEIDLow;
	uvm_reg_field HEIDLow;
	uvm_reg_field HE_ID_H_HEIDHigh;
	uvm_reg_field HEIDHigh;
	rand uvm_reg_field DFH_RSVD0_DfhRsvd0;
	rand uvm_reg_field DfhRsvd0;
	rand uvm_reg_field DFH_RSVD1_DfhRsvd1;
	rand uvm_reg_field DfhRsvd1;
	rand uvm_reg_field SCRATCHPAD0_Scratchpad0;
	rand uvm_reg_field Scratchpad0;
	rand uvm_reg_field SCRATCHPAD1_Scratchpad1;
	rand uvm_reg_field Scratchpad1;
	rand uvm_reg_field SCRATCHPAD2_Scratchpad2;
	rand uvm_reg_field Scratchpad2;
	rand uvm_reg_field DSM_BASEL_DsmBaseL;
	rand uvm_reg_field DsmBaseL;
	rand uvm_reg_field DSM_BASEH_DsmBaseH;
	rand uvm_reg_field DsmBaseH;
	rand uvm_reg_field SRC_ADDR_SrcAddr;
	rand uvm_reg_field SrcAddr;
	rand uvm_reg_field DST_ADDR_DstAddr;
	rand uvm_reg_field DstAddr;
	rand uvm_reg_field NUM_LINES_Rsvd_31_10;
	rand uvm_reg_field Rsvd_31_10;
	rand uvm_reg_field NUM_LINES_NumCacheLines;
	rand uvm_reg_field NumCacheLines;
	rand uvm_reg_field CTL_Rsvd_31_3;
	rand uvm_reg_field Rsvd_31_3;
	rand uvm_reg_field CTL_ForcedTestCmpl;
	rand uvm_reg_field ForcedTestCmpl;
	rand uvm_reg_field CTL_Start;
	rand uvm_reg_field Start;
	rand uvm_reg_field CTL_ResetL;
	rand uvm_reg_field ResetL;
	rand uvm_reg_field CFG_Rsvd_63_32;
	rand uvm_reg_field CFG_ReqLen_H;
	rand uvm_reg_field ReqLen_H;
	rand uvm_reg_field CFG_IntrTestMode;
	rand uvm_reg_field IntrTestMode;
	rand uvm_reg_field CFG_IntrOnErr;
	rand uvm_reg_field IntrOnErr;
	rand uvm_reg_field CFG_TestCfg;
	rand uvm_reg_field TestCfg;
	rand uvm_reg_field CFG_TputInterleave;
	rand uvm_reg_field TputInterleave;
	rand uvm_reg_field CFG_Rsvd_19_12;
	rand uvm_reg_field Rsvd_19_12;
	rand uvm_reg_field CFG_Atomic;
	rand uvm_reg_field Atomic;
	rand uvm_reg_field CFG_ReqLen;
	rand uvm_reg_field ReqLen;
	rand uvm_reg_field CFG_TestMode;
	rand uvm_reg_field TestMode;
	rand uvm_reg_field CFG_ContinuousMode;
	rand uvm_reg_field ContinuousMode;
	rand uvm_reg_field CFG_DelayEn;
	rand uvm_reg_field DelayEn;
	rand uvm_reg_field INACT_THRESH_InactivtyThreshold;
	rand uvm_reg_field InactivtyThreshold;
	rand uvm_reg_field INTERRUPT0_VectorNum;
	rand uvm_reg_field VectorNum;
	rand uvm_reg_field INTERRUPT0_ApicID;
	rand uvm_reg_field ApicID;
	rand uvm_reg_field SWTEST_MSG_SwTestMsg;
	rand uvm_reg_field SwTestMsg;
	uvm_reg_field STATUS0_NumReads;
	uvm_reg_field NumReads;
	uvm_reg_field STATUS0_NumWrites;
	uvm_reg_field NumWrites;
	uvm_reg_field STATUS1_NumPendEmifReads;
	uvm_reg_field NumPendEmifReads;
	uvm_reg_field STATUS1_NumPendEmifWrites;
	uvm_reg_field NumPendEmifWrites;
	uvm_reg_field STATUS1_NumPendHostReads;
	uvm_reg_field NumPendHostReads;
	uvm_reg_field STATUS1_NumPendHostWrites;
	uvm_reg_field NumPendHostWrites;
	uvm_reg_field ERROR_Rsvd_63_32;
	uvm_reg_field ERROR_Error;
	uvm_reg_field Error;
	uvm_reg_field STRIDE_Stride;
	uvm_reg_field Stride;
	uvm_reg_field INFO0_Rsvd_63_25;
	uvm_reg_field Rsvd_63_25;
	uvm_reg_field INFO0_AtomicsNotSupported;
	uvm_reg_field AtomicsNotSupported;
	uvm_reg_field INFO0_APIVersion;
	uvm_reg_field APIVersion;
	uvm_reg_field INFO0_ClkFreq;
	uvm_reg_field ClkFreq;

	function new(string name = "ac_he_lpbk");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.HE_DFH = ral_reg_ac_he_lpbk_HE_DFH::type_id::create("HE_DFH",,get_full_name());
      this.HE_DFH.configure(this, null, "");
      this.HE_DFH.build();
      this.default_map.add_reg(this.HE_DFH, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.HE_DFH_FeatureType = this.HE_DFH.FeatureType;
		this.FeatureType = this.HE_DFH.FeatureType;
		this.HE_DFH_Rsvd_59_52 = this.HE_DFH.Rsvd_59_52;
		this.Rsvd_59_52 = this.HE_DFH.Rsvd_59_52;
		this.HE_DFH_AfuMinVersion = this.HE_DFH.AfuMinVersion;
		this.AfuMinVersion = this.HE_DFH.AfuMinVersion;
		this.HE_DFH_Rsvd_47_41 = this.HE_DFH.Rsvd_47_41;
		this.Rsvd_47_41 = this.HE_DFH.Rsvd_47_41;
		this.HE_DFH_EOL = this.HE_DFH.EOL;
		this.EOL = this.HE_DFH.EOL;
		this.HE_DFH_NextDfhOffset = this.HE_DFH.NextDfhOffset;
		this.NextDfhOffset = this.HE_DFH.NextDfhOffset;
		this.HE_DFH_AfuMajVersion = this.HE_DFH.AfuMajVersion;
		this.AfuMajVersion = this.HE_DFH.AfuMajVersion;
		this.HE_DFH_FeatureID = this.HE_DFH.FeatureID;
		this.FeatureID = this.HE_DFH.FeatureID;
      this.HE_ID_L = ral_reg_ac_he_lpbk_HE_ID_L::type_id::create("HE_ID_L",,get_full_name());
      this.HE_ID_L.configure(this, null, "");
      this.HE_ID_L.build();
      this.default_map.add_reg(this.HE_ID_L, `UVM_REG_ADDR_WIDTH'h8, "RO", 0);
		this.HE_ID_L_HEIDLow = this.HE_ID_L.HEIDLow;
		this.HEIDLow = this.HE_ID_L.HEIDLow;
      this.HE_ID_H = ral_reg_ac_he_lpbk_HE_ID_H::type_id::create("HE_ID_H",,get_full_name());
      this.HE_ID_H.configure(this, null, "");
      this.HE_ID_H.build();
      this.default_map.add_reg(this.HE_ID_H, `UVM_REG_ADDR_WIDTH'h10, "RO", 0);
		this.HE_ID_H_HEIDHigh = this.HE_ID_H.HEIDHigh;
		this.HEIDHigh = this.HE_ID_H.HEIDHigh;
      this.DFH_RSVD0 = ral_reg_ac_he_lpbk_DFH_RSVD0::type_id::create("DFH_RSVD0",,get_full_name());
      this.DFH_RSVD0.configure(this, null, "");
      this.DFH_RSVD0.build();
      this.default_map.add_reg(this.DFH_RSVD0, `UVM_REG_ADDR_WIDTH'h18, "RW", 0);
		this.DFH_RSVD0_DfhRsvd0 = this.DFH_RSVD0.DfhRsvd0;
		this.DfhRsvd0 = this.DFH_RSVD0.DfhRsvd0;
      this.DFH_RSVD1 = ral_reg_ac_he_lpbk_DFH_RSVD1::type_id::create("DFH_RSVD1",,get_full_name());
      this.DFH_RSVD1.configure(this, null, "");
      this.DFH_RSVD1.build();
      this.default_map.add_reg(this.DFH_RSVD1, `UVM_REG_ADDR_WIDTH'h20, "RW", 0);
		this.DFH_RSVD1_DfhRsvd1 = this.DFH_RSVD1.DfhRsvd1;
		this.DfhRsvd1 = this.DFH_RSVD1.DfhRsvd1;
      this.SCRATCHPAD0 = ral_reg_ac_he_lpbk_SCRATCHPAD0::type_id::create("SCRATCHPAD0",,get_full_name());
      this.SCRATCHPAD0.configure(this, null, "");
      this.SCRATCHPAD0.build();
      this.default_map.add_reg(this.SCRATCHPAD0, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
		this.SCRATCHPAD0_Scratchpad0 = this.SCRATCHPAD0.Scratchpad0;
		this.Scratchpad0 = this.SCRATCHPAD0.Scratchpad0;
      this.SCRATCHPAD1 = ral_reg_ac_he_lpbk_SCRATCHPAD1::type_id::create("SCRATCHPAD1",,get_full_name());
      this.SCRATCHPAD1.configure(this, null, "");
      this.SCRATCHPAD1.build();
      this.default_map.add_reg(this.SCRATCHPAD1, `UVM_REG_ADDR_WIDTH'h104, "RW", 0);
		this.SCRATCHPAD1_Scratchpad1 = this.SCRATCHPAD1.Scratchpad1;
		this.Scratchpad1 = this.SCRATCHPAD1.Scratchpad1;
      this.SCRATCHPAD2 = ral_reg_ac_he_lpbk_SCRATCHPAD2::type_id::create("SCRATCHPAD2",,get_full_name());
      this.SCRATCHPAD2.configure(this, null, "");
      this.SCRATCHPAD2.build();
      this.default_map.add_reg(this.SCRATCHPAD2, `UVM_REG_ADDR_WIDTH'h108, "RW", 0);
		this.SCRATCHPAD2_Scratchpad2 = this.SCRATCHPAD2.Scratchpad2;
		this.Scratchpad2 = this.SCRATCHPAD2.Scratchpad2;
      this.DSM_BASEL = ral_reg_ac_he_lpbk_DSM_BASEL::type_id::create("DSM_BASEL",,get_full_name());
      this.DSM_BASEL.configure(this, null, "");
      this.DSM_BASEL.build();
      this.default_map.add_reg(this.DSM_BASEL, `UVM_REG_ADDR_WIDTH'h110, "RW", 0);
		this.DSM_BASEL_DsmBaseL = this.DSM_BASEL.DsmBaseL;
		this.DsmBaseL = this.DSM_BASEL.DsmBaseL;
      this.DSM_BASEH = ral_reg_ac_he_lpbk_DSM_BASEH::type_id::create("DSM_BASEH",,get_full_name());
      this.DSM_BASEH.configure(this, null, "");
      this.DSM_BASEH.build();
      this.default_map.add_reg(this.DSM_BASEH, `UVM_REG_ADDR_WIDTH'h114, "RW", 0);
		this.DSM_BASEH_DsmBaseH = this.DSM_BASEH.DsmBaseH;
		this.DsmBaseH = this.DSM_BASEH.DsmBaseH;
      this.SRC_ADDR = ral_reg_ac_he_lpbk_SRC_ADDR::type_id::create("SRC_ADDR",,get_full_name());
      this.SRC_ADDR.configure(this, null, "");
      this.SRC_ADDR.build();
      this.default_map.add_reg(this.SRC_ADDR, `UVM_REG_ADDR_WIDTH'h120, "RW", 0);
		this.SRC_ADDR_SrcAddr = this.SRC_ADDR.SrcAddr;
		this.SrcAddr = this.SRC_ADDR.SrcAddr;
      this.DST_ADDR = ral_reg_ac_he_lpbk_DST_ADDR::type_id::create("DST_ADDR",,get_full_name());
      this.DST_ADDR.configure(this, null, "");
      this.DST_ADDR.build();
      this.default_map.add_reg(this.DST_ADDR, `UVM_REG_ADDR_WIDTH'h128, "RW", 0);
		this.DST_ADDR_DstAddr = this.DST_ADDR.DstAddr;
		this.DstAddr = this.DST_ADDR.DstAddr;
      this.NUM_LINES = ral_reg_ac_he_lpbk_NUM_LINES::type_id::create("NUM_LINES",,get_full_name());
      this.NUM_LINES.configure(this, null, "");
      this.NUM_LINES.build();
      this.default_map.add_reg(this.NUM_LINES, `UVM_REG_ADDR_WIDTH'h130, "RW", 0);
		this.NUM_LINES_Rsvd_31_10 = this.NUM_LINES.Rsvd_31_10;
		this.Rsvd_31_10 = this.NUM_LINES.Rsvd_31_10;
		this.NUM_LINES_NumCacheLines = this.NUM_LINES.NumCacheLines;
		this.NumCacheLines = this.NUM_LINES.NumCacheLines;
      this.CTL = ral_reg_ac_he_lpbk_CTL::type_id::create("CTL",,get_full_name());
      this.CTL.configure(this, null, "");
      this.CTL.build();
      this.default_map.add_reg(this.CTL, `UVM_REG_ADDR_WIDTH'h138, "RW", 0);
		this.CTL_Rsvd_31_3 = this.CTL.Rsvd_31_3;
		this.Rsvd_31_3 = this.CTL.Rsvd_31_3;
		this.CTL_ForcedTestCmpl = this.CTL.ForcedTestCmpl;
		this.ForcedTestCmpl = this.CTL.ForcedTestCmpl;
		this.CTL_Start = this.CTL.Start;
		this.Start = this.CTL.Start;
		this.CTL_ResetL = this.CTL.ResetL;
		this.ResetL = this.CTL.ResetL;
      this.CFG = ral_reg_ac_he_lpbk_CFG::type_id::create("CFG",,get_full_name());
      this.CFG.configure(this, null, "");
      this.CFG.build();
      this.default_map.add_reg(this.CFG, `UVM_REG_ADDR_WIDTH'h140, "RW", 0);
		this.CFG_Rsvd_63_32 = this.CFG.Rsvd_63_32;
		this.CFG_ReqLen_H = this.CFG.ReqLen_H;
		this.ReqLen_H = this.CFG.ReqLen_H;
		this.CFG_IntrTestMode = this.CFG.IntrTestMode;
		this.IntrTestMode = this.CFG.IntrTestMode;
		this.CFG_IntrOnErr = this.CFG.IntrOnErr;
		this.IntrOnErr = this.CFG.IntrOnErr;
		this.CFG_TestCfg = this.CFG.TestCfg;
		this.TestCfg = this.CFG.TestCfg;
		this.CFG_TputInterleave = this.CFG.TputInterleave;
		this.TputInterleave = this.CFG.TputInterleave;
		this.CFG_Rsvd_19_12 = this.CFG.Rsvd_19_12;
		this.Rsvd_19_12 = this.CFG.Rsvd_19_12;
		this.CFG_Atomic = this.CFG.Atomic;
		this.Atomic = this.CFG.Atomic;
		this.CFG_ReqLen = this.CFG.ReqLen;
		this.ReqLen = this.CFG.ReqLen;
		this.CFG_TestMode = this.CFG.TestMode;
		this.TestMode = this.CFG.TestMode;
		this.CFG_ContinuousMode = this.CFG.ContinuousMode;
		this.ContinuousMode = this.CFG.ContinuousMode;
		this.CFG_DelayEn = this.CFG.DelayEn;
		this.DelayEn = this.CFG.DelayEn;
      this.INACT_THRESH = ral_reg_ac_he_lpbk_INACT_THRESH::type_id::create("INACT_THRESH",,get_full_name());
      this.INACT_THRESH.configure(this, null, "");
      this.INACT_THRESH.build();
      this.default_map.add_reg(this.INACT_THRESH, `UVM_REG_ADDR_WIDTH'h148, "RW", 0);
		this.INACT_THRESH_InactivtyThreshold = this.INACT_THRESH.InactivtyThreshold;
		this.InactivtyThreshold = this.INACT_THRESH.InactivtyThreshold;
      this.INTERRUPT0 = ral_reg_ac_he_lpbk_INTERRUPT0::type_id::create("INTERRUPT0",,get_full_name());
      this.INTERRUPT0.configure(this, null, "");
      this.INTERRUPT0.build();
      this.default_map.add_reg(this.INTERRUPT0, `UVM_REG_ADDR_WIDTH'h150, "RW", 0);
		this.INTERRUPT0_VectorNum = this.INTERRUPT0.VectorNum;
		this.VectorNum = this.INTERRUPT0.VectorNum;
		this.INTERRUPT0_ApicID = this.INTERRUPT0.ApicID;
		this.ApicID = this.INTERRUPT0.ApicID;
      this.SWTEST_MSG = ral_reg_ac_he_lpbk_SWTEST_MSG::type_id::create("SWTEST_MSG",,get_full_name());
      this.SWTEST_MSG.configure(this, null, "");
      this.SWTEST_MSG.build();
      this.default_map.add_reg(this.SWTEST_MSG, `UVM_REG_ADDR_WIDTH'h158, "RW", 0);
		this.SWTEST_MSG_SwTestMsg = this.SWTEST_MSG.SwTestMsg;
		this.SwTestMsg = this.SWTEST_MSG.SwTestMsg;
      this.STATUS0 = ral_reg_ac_he_lpbk_STATUS0::type_id::create("STATUS0",,get_full_name());
      this.STATUS0.configure(this, null, "");
      this.STATUS0.build();
      this.default_map.add_reg(this.STATUS0, `UVM_REG_ADDR_WIDTH'h160, "RO", 0);
		this.STATUS0_NumReads = this.STATUS0.NumReads;
		this.NumReads = this.STATUS0.NumReads;
		this.STATUS0_NumWrites = this.STATUS0.NumWrites;
		this.NumWrites = this.STATUS0.NumWrites;
      this.STATUS1 = ral_reg_ac_he_lpbk_STATUS1::type_id::create("STATUS1",,get_full_name());
      this.STATUS1.configure(this, null, "");
      this.STATUS1.build();
      this.default_map.add_reg(this.STATUS1, `UVM_REG_ADDR_WIDTH'h168, "RO", 0);
		this.STATUS1_NumPendEmifReads = this.STATUS1.NumPendEmifReads;
		this.NumPendEmifReads = this.STATUS1.NumPendEmifReads;
		this.STATUS1_NumPendEmifWrites = this.STATUS1.NumPendEmifWrites;
		this.NumPendEmifWrites = this.STATUS1.NumPendEmifWrites;
		this.STATUS1_NumPendHostReads = this.STATUS1.NumPendHostReads;
		this.NumPendHostReads = this.STATUS1.NumPendHostReads;
		this.STATUS1_NumPendHostWrites = this.STATUS1.NumPendHostWrites;
		this.NumPendHostWrites = this.STATUS1.NumPendHostWrites;
      this.ERROR = ral_reg_ac_he_lpbk_ERROR::type_id::create("ERROR",,get_full_name());
      this.ERROR.configure(this, null, "");
      this.ERROR.build();
      this.default_map.add_reg(this.ERROR, `UVM_REG_ADDR_WIDTH'h170, "RO", 0);
		this.ERROR_Rsvd_63_32 = this.ERROR.Rsvd_63_32;
		this.ERROR_Error = this.ERROR.Error;
		this.Error = this.ERROR.Error;
      this.STRIDE = ral_reg_ac_he_lpbk_STRIDE::type_id::create("STRIDE",,get_full_name());
      this.STRIDE.configure(this, null, "");
      this.STRIDE.build();
      this.default_map.add_reg(this.STRIDE, `UVM_REG_ADDR_WIDTH'h178, "RO", 0);
		this.STRIDE_Stride = this.STRIDE.Stride;
		this.Stride = this.STRIDE.Stride;
      this.INFO0 = ral_reg_ac_he_lpbk_INFO0::type_id::create("INFO0",,get_full_name());
      this.INFO0.configure(this, null, "");
      this.INFO0.build();
      this.default_map.add_reg(this.INFO0, `UVM_REG_ADDR_WIDTH'h180, "RO", 0);
		this.INFO0_Rsvd_63_25 = this.INFO0.Rsvd_63_25;
		this.Rsvd_63_25 = this.INFO0.Rsvd_63_25;
		this.INFO0_AtomicsNotSupported = this.INFO0.AtomicsNotSupported;
		this.AtomicsNotSupported = this.INFO0.AtomicsNotSupported;
		this.INFO0_APIVersion = this.INFO0.APIVersion;
		this.APIVersion = this.INFO0.APIVersion;
		this.INFO0_ClkFreq = this.INFO0.ClkFreq;
		this.ClkFreq = this.INFO0.ClkFreq;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_he_lpbk)

endclass : ral_block_ac_he_lpbk



`endif
