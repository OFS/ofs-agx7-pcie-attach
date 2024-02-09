// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_PMCI
`define RAL_AC_PMCI

import uvm_pkg::*;

class ral_reg_ac_pmci_PMCI_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EndOfList;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	function new(string name = "ac_pmci_PMCI_DFH");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FeatureType = uvm_reg_field::type_id::create("FeatureType",,get_full_name());
      this.FeatureType.configure(this, 4, 60, "RO", 0, 4'h3, 1, 0, 0);
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 19, 41, "WO", 0, 19'h0, 1, 0, 0);
      this.EndOfList = uvm_reg_field::type_id::create("EndOfList",,get_full_name());
      this.EndOfList.configure(this, 1, 40, "RO", 0, 1'h0, 1, 0, 0);
      this.NextDfhByteOffset = uvm_reg_field::type_id::create("NextDfhByteOffset",,get_full_name());
      this.NextDfhByteOffset.configure(this, 24, 16, "RO", 0, 24'h1000, 1, 0, 1);
      this.FeatureRev = uvm_reg_field::type_id::create("FeatureRev",,get_full_name());
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h1, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h12, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_PMCI_DFH)

endclass : ral_reg_ac_pmci_PMCI_DFH


class ral_reg_ac_pmci_FBM_CSR extends uvm_reg;
	rand uvm_reg_field Reserved26;
	rand uvm_reg_field RdCnt;
	rand uvm_reg_field Reserved14;
	uvm_reg_field FbmFifoAvl;
	rand uvm_reg_field Reserved3;
	uvm_reg_field FbmBsy;
	rand uvm_reg_field FbmRdMode;
	rand uvm_reg_field WriteMode;

	function new(string name = "ac_pmci_FBM_CSR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved26 = uvm_reg_field::type_id::create("Reserved26",,get_full_name());
      this.Reserved26.configure(this, 6, 26, "WO", 0, 6'h0, 1, 0, 0);
      this.RdCnt = uvm_reg_field::type_id::create("RdCnt",,get_full_name());
      this.RdCnt.configure(this, 10, 16, "RW", 0, 10'h0, 1, 0, 0);
      this.Reserved14 = uvm_reg_field::type_id::create("Reserved14",,get_full_name());
      this.Reserved14.configure(this, 2, 14, "WO", 0, 2'h0, 1, 0, 0);
      this.FbmFifoAvl = uvm_reg_field::type_id::create("FbmFifoAvl",,get_full_name());
      this.FbmFifoAvl.configure(this, 10, 4, "RO", 0, 10'h0, 1, 0, 0);
      this.Reserved3 = uvm_reg_field::type_id::create("Reserved3",,get_full_name());
      this.Reserved3.configure(this, 1, 3, "WO", 0, 1'h0, 1, 0, 0);
      this.FbmBsy = uvm_reg_field::type_id::create("FbmBsy",,get_full_name());
      this.FbmBsy.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.FbmRdMode = uvm_reg_field::type_id::create("FbmRdMode",,get_full_name());
      this.FbmRdMode.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.WriteMode = uvm_reg_field::type_id::create("WriteMode",,get_full_name());
      this.WriteMode.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_FBM_CSR)

endclass : ral_reg_ac_pmci_FBM_CSR


class ral_reg_ac_pmci_FBM_AR extends uvm_reg;
	rand uvm_reg_field Reserved;
	rand uvm_reg_field StAdrFRW;

	function new(string name = "ac_pmci_FBM_AR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 4, 28, "WO", 0, 4'h0, 1, 0, 0);
      this.StAdrFRW = uvm_reg_field::type_id::create("StAdrFRW",,get_full_name());
      this.StAdrFRW.configure(this, 28, 0, "RW", 0, 28'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_FBM_AR)

endclass : ral_reg_ac_pmci_FBM_AR


class ral_reg_ac_pmci_PMCI_ERR_IND extends uvm_reg;
	uvm_reg_field Reserved;
	uvm_reg_field PmciNiosStuck;
	uvm_reg_field M10NiosStuck;
	uvm_reg_field FpgaSeuEr;
	uvm_reg_field M10SeuEr;

	function new(string name = "ac_pmci_PMCI_ERR_IND");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 28, 4, "RO", 0, 28'h0, 1, 0, 0);
      this.PmciNiosStuck = uvm_reg_field::type_id::create("PmciNiosStuck",,get_full_name());
      this.PmciNiosStuck.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.M10NiosStuck = uvm_reg_field::type_id::create("M10NiosStuck",,get_full_name());
      this.M10NiosStuck.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.FpgaSeuEr = uvm_reg_field::type_id::create("FpgaSeuEr",,get_full_name());
      this.FpgaSeuEr.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.M10SeuEr = uvm_reg_field::type_id::create("M10SeuEr",,get_full_name());
      this.M10SeuEr.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_PMCI_ERR_IND)

endclass : ral_reg_ac_pmci_PMCI_ERR_IND


class ral_reg_ac_pmci_PCIE_VDM_BA extends uvm_reg;
	uvm_reg_field Reserved;
	rand uvm_reg_field PcieVdmCRBA;

	function new(string name = "ac_pmci_PCIE_VDM_BA");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 12, 20, "RO", 0, 12'h0, 1, 0, 0);
      this.PcieVdmCRBA = uvm_reg_field::type_id::create("PcieVdmCRBA",,get_full_name());
      this.PcieVdmCRBA.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_PCIE_VDM_BA)

endclass : ral_reg_ac_pmci_PCIE_VDM_BA


class ral_reg_ac_pmci_PCIE_SS_BA extends uvm_reg;
	uvm_reg_field Reserved;
	rand uvm_reg_field PcieSSRegAccBA;

	function new(string name = "ac_pmci_PCIE_SS_BA");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 12, 20, "RO", 0, 12'h0, 1, 0, 0);
      this.PcieSSRegAccBA = uvm_reg_field::type_id::create("PcieSSRegAccBA",,get_full_name());
      this.PcieSSRegAccBA.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_PCIE_SS_BA)

endclass : ral_reg_ac_pmci_PCIE_SS_BA


class ral_reg_ac_pmci_HSSI_SS_BA extends uvm_reg;
	uvm_reg_field Reserved;
	rand uvm_reg_field HssiSSRegAccBA;

	function new(string name = "ac_pmci_HSSI_SS_BA");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 12, 20, "RO", 0, 12'h0, 1, 0, 0);
      this.HssiSSRegAccBA = uvm_reg_field::type_id::create("HssiSSRegAccBA",,get_full_name());
      this.HssiSSRegAccBA.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_HSSI_SS_BA)

endclass : ral_reg_ac_pmci_HSSI_SS_BA


class ral_reg_ac_pmci_QSFP_A_BA extends uvm_reg;
	uvm_reg_field Reserved;
	rand uvm_reg_field QsfpARegAccBA;

	function new(string name = "ac_pmci_QSFP_A_BA");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 12, 20, "RO", 0, 12'h0, 1, 0, 0);
      this.QsfpARegAccBA = uvm_reg_field::type_id::create("QsfpARegAccBA",,get_full_name());
      this.QsfpARegAccBA.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_QSFP_A_BA)

endclass : ral_reg_ac_pmci_QSFP_A_BA


class ral_reg_ac_pmci_QSFP_B_BA extends uvm_reg;
	uvm_reg_field Reserved;
	rand uvm_reg_field QsfpBRegAccBA;

	function new(string name = "ac_pmci_QSFP_B_BA");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved = uvm_reg_field::type_id::create("Reserved",,get_full_name());
      this.Reserved.configure(this, 12, 20, "RO", 0, 12'h0, 1, 0, 0);
      this.QsfpBRegAccBA = uvm_reg_field::type_id::create("QsfpBRegAccBA",,get_full_name());
      this.QsfpBRegAccBA.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_QSFP_B_BA)

endclass : ral_reg_ac_pmci_QSFP_B_BA


class ral_reg_ac_pmci_SPI_CSR extends uvm_reg;
	rand uvm_reg_field Reserved3;
	rand uvm_reg_field AckTrans;
	rand uvm_reg_field WrCmd;
	rand uvm_reg_field RdCmd;

	function new(string name = "ac_pmci_SPI_CSR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Reserved3 = uvm_reg_field::type_id::create("Reserved3",,get_full_name());
      this.Reserved3.configure(this, 29, 3, "WO", 0, 29'h0, 1, 0, 0);
      this.AckTrans = uvm_reg_field::type_id::create("AckTrans",,get_full_name());
      this.AckTrans.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
      this.WrCmd = uvm_reg_field::type_id::create("WrCmd",,get_full_name());
      this.WrCmd.configure(this, 1, 1, "WO", 0, 1'h0, 1, 0, 0);
      this.RdCmd = uvm_reg_field::type_id::create("RdCmd",,get_full_name());
      this.RdCmd.configure(this, 1, 0, "WO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_SPI_CSR)

endclass : ral_reg_ac_pmci_SPI_CSR


class ral_reg_ac_pmci_SPI_AR extends uvm_reg;
	rand uvm_reg_field M10AR;

	function new(string name = "ac_pmci_SPI_AR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.M10AR = uvm_reg_field::type_id::create("M10AR",,get_full_name());
      this.M10AR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_SPI_AR)

endclass : ral_reg_ac_pmci_SPI_AR


class ral_reg_ac_pmci_SPI_RD_DR extends uvm_reg;
	uvm_reg_field M10RD;

	function new(string name = "ac_pmci_SPI_RD_DR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.M10RD = uvm_reg_field::type_id::create("M10RD",,get_full_name());
      this.M10RD.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_SPI_RD_DR)

endclass : ral_reg_ac_pmci_SPI_RD_DR


class ral_reg_ac_pmci_SPI_WR_DR extends uvm_reg;
	rand uvm_reg_field M10WD;

	function new(string name = "ac_pmci_SPI_WR_DR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.M10WD = uvm_reg_field::type_id::create("M10WD",,get_full_name());
      this.M10WD.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_SPI_WR_DR)

endclass : ral_reg_ac_pmci_SPI_WR_DR


class ral_reg_ac_pmci_FBM_FIFO extends uvm_reg;
	rand uvm_reg_field FbrFifoRdWrAdr;

	function new(string name = "ac_pmci_FBM_FIFO");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FbrFifoRdWrAdr = uvm_reg_field::type_id::create("FbrFifoRdWrAdr",,get_full_name());
      this.FbrFifoRdWrAdr.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_FBM_FIFO)

endclass : ral_reg_ac_pmci_FBM_FIFO


class ral_reg_ac_pmci_PCIE_VDM_FCR extends uvm_reg;
	rand uvm_reg_field VdmTlpEop;
	rand uvm_reg_field VdmTlpSop;

	function new(string name = "ac_pmci_PCIE_VDM_FCR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.VdmTlpEop = uvm_reg_field::type_id::create("VdmTlpEop",,get_full_name());
      this.VdmTlpEop.configure(this, 1, 1, "WO", 0, 1'h0, 1, 0, 0);
      this.VdmTlpSop = uvm_reg_field::type_id::create("VdmTlpSop",,get_full_name());
      this.VdmTlpSop.configure(this, 1, 0, "WO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_PCIE_VDM_FCR)

endclass : ral_reg_ac_pmci_PCIE_VDM_FCR


class ral_reg_ac_pmci_PCIE_VDM_PDR extends uvm_reg;
	rand uvm_reg_field VdmTlpDR;

	function new(string name = "ac_pmci_PCIE_VDM_PDR");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.VdmTlpDR = uvm_reg_field::type_id::create("VdmTlpDR",,get_full_name());
      this.VdmTlpDR.configure(this, 64, 0, "WO", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_pmci_PCIE_VDM_PDR)

endclass : ral_reg_ac_pmci_PCIE_VDM_PDR


class ral_block_ac_pmci extends uvm_reg_block;
	rand ral_reg_ac_pmci_PMCI_DFH PMCI_DFH;
	rand ral_reg_ac_pmci_FBM_CSR FBM_CSR;
	rand ral_reg_ac_pmci_FBM_AR FBM_AR;
	rand ral_reg_ac_pmci_PMCI_ERR_IND PMCI_ERR_IND;
	rand ral_reg_ac_pmci_PCIE_VDM_BA PCIE_VDM_BA;
	rand ral_reg_ac_pmci_PCIE_SS_BA PCIE_SS_BA;
	rand ral_reg_ac_pmci_HSSI_SS_BA HSSI_SS_BA;
	rand ral_reg_ac_pmci_QSFP_A_BA QSFP_A_BA;
	rand ral_reg_ac_pmci_QSFP_B_BA QSFP_B_BA;
	rand ral_reg_ac_pmci_SPI_CSR SPI_CSR;
	rand ral_reg_ac_pmci_SPI_AR SPI_AR;
	rand ral_reg_ac_pmci_SPI_RD_DR SPI_RD_DR;
	rand ral_reg_ac_pmci_SPI_WR_DR SPI_WR_DR;
	rand ral_reg_ac_pmci_FBM_FIFO FBM_FIFO;
	rand ral_reg_ac_pmci_PCIE_VDM_FCR PCIE_VDM_FCR;
	rand ral_reg_ac_pmci_PCIE_VDM_PDR PCIE_VDM_PDR;
	uvm_reg_field PMCI_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field PMCI_DFH_Reserved;
	uvm_reg_field PMCI_DFH_EndOfList;
	uvm_reg_field EndOfList;
	uvm_reg_field PMCI_DFH_NextDfhByteOffset;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field PMCI_DFH_FeatureRev;
	uvm_reg_field FeatureRev;
	uvm_reg_field PMCI_DFH_FeatureID;
	uvm_reg_field FeatureID;
	rand uvm_reg_field FBM_CSR_Reserved26;
	rand uvm_reg_field Reserved26;
	rand uvm_reg_field FBM_CSR_RdCnt;
	rand uvm_reg_field RdCnt;
	rand uvm_reg_field FBM_CSR_Reserved14;
	rand uvm_reg_field Reserved14;
	uvm_reg_field FBM_CSR_FbmFifoAvl;
	uvm_reg_field FbmFifoAvl;
	rand uvm_reg_field FBM_CSR_Reserved3;
	uvm_reg_field FBM_CSR_FbmBsy;
	uvm_reg_field FbmBsy;
	rand uvm_reg_field FBM_CSR_FbmRdMode;
	rand uvm_reg_field FbmRdMode;
	rand uvm_reg_field FBM_CSR_WriteMode;
	rand uvm_reg_field WriteMode;
	rand uvm_reg_field FBM_AR_Reserved;
	rand uvm_reg_field FBM_AR_StAdrFRW;
	rand uvm_reg_field StAdrFRW;
	uvm_reg_field PMCI_ERR_IND_Reserved;
	uvm_reg_field PMCI_ERR_IND_PmciNiosStuck;
	uvm_reg_field PmciNiosStuck;
	uvm_reg_field PMCI_ERR_IND_M10NiosStuck;
	uvm_reg_field M10NiosStuck;
	uvm_reg_field PMCI_ERR_IND_FpgaSeuEr;
	uvm_reg_field FpgaSeuEr;
	uvm_reg_field PMCI_ERR_IND_M10SeuEr;
	uvm_reg_field M10SeuEr;
	uvm_reg_field PCIE_VDM_BA_Reserved;
	rand uvm_reg_field PCIE_VDM_BA_PcieVdmCRBA;
	rand uvm_reg_field PcieVdmCRBA;
	uvm_reg_field PCIE_SS_BA_Reserved;
	rand uvm_reg_field PCIE_SS_BA_PcieSSRegAccBA;
	rand uvm_reg_field PcieSSRegAccBA;
	uvm_reg_field HSSI_SS_BA_Reserved;
	rand uvm_reg_field HSSI_SS_BA_HssiSSRegAccBA;
	rand uvm_reg_field HssiSSRegAccBA;
	uvm_reg_field QSFP_A_BA_Reserved;
	rand uvm_reg_field QSFP_A_BA_QsfpARegAccBA;
	rand uvm_reg_field QsfpARegAccBA;
	uvm_reg_field QSFP_B_BA_Reserved;
	rand uvm_reg_field QSFP_B_BA_QsfpBRegAccBA;
	rand uvm_reg_field QsfpBRegAccBA;
	rand uvm_reg_field SPI_CSR_Reserved3;
	rand uvm_reg_field SPI_CSR_AckTrans;
	rand uvm_reg_field AckTrans;
	rand uvm_reg_field SPI_CSR_WrCmd;
	rand uvm_reg_field WrCmd;
	rand uvm_reg_field SPI_CSR_RdCmd;
	rand uvm_reg_field RdCmd;
	rand uvm_reg_field SPI_AR_M10AR;
	rand uvm_reg_field M10AR;
	uvm_reg_field SPI_RD_DR_M10RD;
	uvm_reg_field M10RD;
	rand uvm_reg_field SPI_WR_DR_M10WD;
	rand uvm_reg_field M10WD;
	rand uvm_reg_field FBM_FIFO_FbrFifoRdWrAdr;
	rand uvm_reg_field FbrFifoRdWrAdr;
	rand uvm_reg_field PCIE_VDM_FCR_VdmTlpEop;
	rand uvm_reg_field VdmTlpEop;
	rand uvm_reg_field PCIE_VDM_FCR_VdmTlpSop;
	rand uvm_reg_field VdmTlpSop;
	rand uvm_reg_field PCIE_VDM_PDR_VdmTlpDR;
	rand uvm_reg_field VdmTlpDR;

	function new(string name = "ac_pmci");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.PMCI_DFH = ral_reg_ac_pmci_PMCI_DFH::type_id::create("PMCI_DFH",,get_full_name());
      this.PMCI_DFH.configure(this, null, "");
      this.PMCI_DFH.build();
      this.default_map.add_reg(this.PMCI_DFH, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.PMCI_DFH_FeatureType = this.PMCI_DFH.FeatureType;
		this.FeatureType = this.PMCI_DFH.FeatureType;
		this.PMCI_DFH_Reserved = this.PMCI_DFH.Reserved;
		this.PMCI_DFH_EndOfList = this.PMCI_DFH.EndOfList;
		this.EndOfList = this.PMCI_DFH.EndOfList;
		this.PMCI_DFH_NextDfhByteOffset = this.PMCI_DFH.NextDfhByteOffset;
		this.NextDfhByteOffset = this.PMCI_DFH.NextDfhByteOffset;
		this.PMCI_DFH_FeatureRev = this.PMCI_DFH.FeatureRev;
		this.FeatureRev = this.PMCI_DFH.FeatureRev;
		this.PMCI_DFH_FeatureID = this.PMCI_DFH.FeatureID;
		this.FeatureID = this.PMCI_DFH.FeatureID;
      this.FBM_CSR = ral_reg_ac_pmci_FBM_CSR::type_id::create("FBM_CSR",,get_full_name());
      this.FBM_CSR.configure(this, null, "");
      this.FBM_CSR.build();
      this.default_map.add_reg(this.FBM_CSR, `UVM_REG_ADDR_WIDTH'h40, "RW", 0);
		this.FBM_CSR_Reserved26 = this.FBM_CSR.Reserved26;
		this.Reserved26 = this.FBM_CSR.Reserved26;
		this.FBM_CSR_RdCnt = this.FBM_CSR.RdCnt;
		this.RdCnt = this.FBM_CSR.RdCnt;
		this.FBM_CSR_Reserved14 = this.FBM_CSR.Reserved14;
		this.Reserved14 = this.FBM_CSR.Reserved14;
		this.FBM_CSR_FbmFifoAvl = this.FBM_CSR.FbmFifoAvl;
		this.FbmFifoAvl = this.FBM_CSR.FbmFifoAvl;
		this.FBM_CSR_Reserved3 = this.FBM_CSR.Reserved3;
		this.FBM_CSR_FbmBsy = this.FBM_CSR.FbmBsy;
		this.FbmBsy = this.FBM_CSR.FbmBsy;
		this.FBM_CSR_FbmRdMode = this.FBM_CSR.FbmRdMode;
		this.FbmRdMode = this.FBM_CSR.FbmRdMode;
		this.FBM_CSR_WriteMode = this.FBM_CSR.WriteMode;
		this.WriteMode = this.FBM_CSR.WriteMode;
      this.FBM_AR = ral_reg_ac_pmci_FBM_AR::type_id::create("FBM_AR",,get_full_name());
      this.FBM_AR.configure(this, null, "");
      this.FBM_AR.build();
      this.default_map.add_reg(this.FBM_AR, `UVM_REG_ADDR_WIDTH'h44, "RW", 0);
		this.FBM_AR_Reserved = this.FBM_AR.Reserved;
		this.FBM_AR_StAdrFRW = this.FBM_AR.StAdrFRW;
		this.StAdrFRW = this.FBM_AR.StAdrFRW;
      this.PMCI_ERR_IND = ral_reg_ac_pmci_PMCI_ERR_IND::type_id::create("PMCI_ERR_IND",,get_full_name());
      this.PMCI_ERR_IND.configure(this, null, "");
      this.PMCI_ERR_IND.build();
      this.default_map.add_reg(this.PMCI_ERR_IND, `UVM_REG_ADDR_WIDTH'h48, "RO", 0);
		this.PMCI_ERR_IND_Reserved = this.PMCI_ERR_IND.Reserved;
		this.PMCI_ERR_IND_PmciNiosStuck = this.PMCI_ERR_IND.PmciNiosStuck;
		this.PmciNiosStuck = this.PMCI_ERR_IND.PmciNiosStuck;
		this.PMCI_ERR_IND_M10NiosStuck = this.PMCI_ERR_IND.M10NiosStuck;
		this.M10NiosStuck = this.PMCI_ERR_IND.M10NiosStuck;
		this.PMCI_ERR_IND_FpgaSeuEr = this.PMCI_ERR_IND.FpgaSeuEr;
		this.FpgaSeuEr = this.PMCI_ERR_IND.FpgaSeuEr;
		this.PMCI_ERR_IND_M10SeuEr = this.PMCI_ERR_IND.M10SeuEr;
		this.M10SeuEr = this.PMCI_ERR_IND.M10SeuEr;
      this.PCIE_VDM_BA = ral_reg_ac_pmci_PCIE_VDM_BA::type_id::create("PCIE_VDM_BA",,get_full_name());
      this.PCIE_VDM_BA.configure(this, null, "");
      this.PCIE_VDM_BA.build();
      this.default_map.add_reg(this.PCIE_VDM_BA, `UVM_REG_ADDR_WIDTH'h80, "RW", 0);
		this.PCIE_VDM_BA_Reserved = this.PCIE_VDM_BA.Reserved;
		this.PCIE_VDM_BA_PcieVdmCRBA = this.PCIE_VDM_BA.PcieVdmCRBA;
		this.PcieVdmCRBA = this.PCIE_VDM_BA.PcieVdmCRBA;
      this.PCIE_SS_BA = ral_reg_ac_pmci_PCIE_SS_BA::type_id::create("PCIE_SS_BA",,get_full_name());
      this.PCIE_SS_BA.configure(this, null, "");
      this.PCIE_SS_BA.build();
      this.default_map.add_reg(this.PCIE_SS_BA, `UVM_REG_ADDR_WIDTH'h88, "RW", 0);
		this.PCIE_SS_BA_Reserved = this.PCIE_SS_BA.Reserved;
		this.PCIE_SS_BA_PcieSSRegAccBA = this.PCIE_SS_BA.PcieSSRegAccBA;
		this.PcieSSRegAccBA = this.PCIE_SS_BA.PcieSSRegAccBA;
      this.HSSI_SS_BA = ral_reg_ac_pmci_HSSI_SS_BA::type_id::create("HSSI_SS_BA",,get_full_name());
      this.HSSI_SS_BA.configure(this, null, "");
      this.HSSI_SS_BA.build();
      this.default_map.add_reg(this.HSSI_SS_BA, `UVM_REG_ADDR_WIDTH'h8C, "RW", 0);
		this.HSSI_SS_BA_Reserved = this.HSSI_SS_BA.Reserved;
		this.HSSI_SS_BA_HssiSSRegAccBA = this.HSSI_SS_BA.HssiSSRegAccBA;
		this.HssiSSRegAccBA = this.HSSI_SS_BA.HssiSSRegAccBA;
      this.QSFP_A_BA = ral_reg_ac_pmci_QSFP_A_BA::type_id::create("QSFP_A_BA",,get_full_name());
      this.QSFP_A_BA.configure(this, null, "");
      this.QSFP_A_BA.build();
      this.default_map.add_reg(this.QSFP_A_BA, `UVM_REG_ADDR_WIDTH'h90, "RW", 0);
		this.QSFP_A_BA_Reserved = this.QSFP_A_BA.Reserved;
		this.QSFP_A_BA_QsfpARegAccBA = this.QSFP_A_BA.QsfpARegAccBA;
		this.QsfpARegAccBA = this.QSFP_A_BA.QsfpARegAccBA;
      this.QSFP_B_BA = ral_reg_ac_pmci_QSFP_B_BA::type_id::create("QSFP_B_BA",,get_full_name());
      this.QSFP_B_BA.configure(this, null, "");
      this.QSFP_B_BA.build();
      this.default_map.add_reg(this.QSFP_B_BA, `UVM_REG_ADDR_WIDTH'h94, "RW", 0);
		this.QSFP_B_BA_Reserved = this.QSFP_B_BA.Reserved;
		this.QSFP_B_BA_QsfpBRegAccBA = this.QSFP_B_BA.QsfpBRegAccBA;
		this.QsfpBRegAccBA = this.QSFP_B_BA.QsfpBRegAccBA;
      this.SPI_CSR = ral_reg_ac_pmci_SPI_CSR::type_id::create("SPI_CSR",,get_full_name());
      this.SPI_CSR.configure(this, null, "");
      this.SPI_CSR.build();
      this.default_map.add_reg(this.SPI_CSR, `UVM_REG_ADDR_WIDTH'h400, "RW", 0);
		this.SPI_CSR_Reserved3 = this.SPI_CSR.Reserved3;
		this.SPI_CSR_AckTrans = this.SPI_CSR.AckTrans;
		this.AckTrans = this.SPI_CSR.AckTrans;
		this.SPI_CSR_WrCmd = this.SPI_CSR.WrCmd;
		this.WrCmd = this.SPI_CSR.WrCmd;
		this.SPI_CSR_RdCmd = this.SPI_CSR.RdCmd;
		this.RdCmd = this.SPI_CSR.RdCmd;
      this.SPI_AR = ral_reg_ac_pmci_SPI_AR::type_id::create("SPI_AR",,get_full_name());
      this.SPI_AR.configure(this, null, "");
      this.SPI_AR.build();
      this.default_map.add_reg(this.SPI_AR, `UVM_REG_ADDR_WIDTH'h404, "RW", 0);
		this.SPI_AR_M10AR = this.SPI_AR.M10AR;
		this.M10AR = this.SPI_AR.M10AR;
      this.SPI_RD_DR = ral_reg_ac_pmci_SPI_RD_DR::type_id::create("SPI_RD_DR",,get_full_name());
      this.SPI_RD_DR.configure(this, null, "");
      this.SPI_RD_DR.build();
      this.default_map.add_reg(this.SPI_RD_DR, `UVM_REG_ADDR_WIDTH'h408, "RO", 0);
		this.SPI_RD_DR_M10RD = this.SPI_RD_DR.M10RD;
		this.M10RD = this.SPI_RD_DR.M10RD;
      this.SPI_WR_DR = ral_reg_ac_pmci_SPI_WR_DR::type_id::create("SPI_WR_DR",,get_full_name());
      this.SPI_WR_DR.configure(this, null, "");
      this.SPI_WR_DR.build();
      this.default_map.add_reg(this.SPI_WR_DR, `UVM_REG_ADDR_WIDTH'h40C, "RW", 0);
		this.SPI_WR_DR_M10WD = this.SPI_WR_DR.M10WD;
		this.M10WD = this.SPI_WR_DR.M10WD;
      this.FBM_FIFO = ral_reg_ac_pmci_FBM_FIFO::type_id::create("FBM_FIFO",,get_full_name());
      this.FBM_FIFO.configure(this, null, "");
      this.FBM_FIFO.build();
      this.default_map.add_reg(this.FBM_FIFO, `UVM_REG_ADDR_WIDTH'h800, "RW", 0);
		this.FBM_FIFO_FbrFifoRdWrAdr = this.FBM_FIFO.FbrFifoRdWrAdr;
		this.FbrFifoRdWrAdr = this.FBM_FIFO.FbrFifoRdWrAdr;
      this.PCIE_VDM_FCR = ral_reg_ac_pmci_PCIE_VDM_FCR::type_id::create("PCIE_VDM_FCR",,get_full_name());
      this.PCIE_VDM_FCR.configure(this, null, "");
      this.PCIE_VDM_FCR.build();
      this.default_map.add_reg(this.PCIE_VDM_FCR, `UVM_REG_ADDR_WIDTH'h2000, "RW", 0);
		this.PCIE_VDM_FCR_VdmTlpEop = this.PCIE_VDM_FCR.VdmTlpEop;
		this.VdmTlpEop = this.PCIE_VDM_FCR.VdmTlpEop;
		this.PCIE_VDM_FCR_VdmTlpSop = this.PCIE_VDM_FCR.VdmTlpSop;
		this.VdmTlpSop = this.PCIE_VDM_FCR.VdmTlpSop;
      this.PCIE_VDM_PDR = ral_reg_ac_pmci_PCIE_VDM_PDR::type_id::create("PCIE_VDM_PDR",,get_full_name());
      this.PCIE_VDM_PDR.configure(this, null, "");
      this.PCIE_VDM_PDR.build();
      this.default_map.add_reg(this.PCIE_VDM_PDR, `UVM_REG_ADDR_WIDTH'h2008, "RW", 0);
		this.PCIE_VDM_PDR_VdmTlpDR = this.PCIE_VDM_PDR.VdmTlpDR;
		this.VdmTlpDR = this.PCIE_VDM_PDR.VdmTlpDR;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_pmci)

endclass : ral_block_ac_pmci



`endif
