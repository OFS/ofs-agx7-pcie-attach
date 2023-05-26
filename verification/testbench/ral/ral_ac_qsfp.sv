// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_QSFP
`define RAL_AC_QSFP

import uvm_pkg::*;

class ral_reg_ac_qsfp_QSFP_CTRL_DFH extends uvm_reg;
	uvm_reg_field FeatureType;
	rand uvm_reg_field Reserved;
	uvm_reg_field EndOfList;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field FeatureRev;
	uvm_reg_field FeatureID;

	function new(string name = "ac_qsfp_QSFP_CTRL_DFH");
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
      this.FeatureRev.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.FeatureID = uvm_reg_field::type_id::create("FeatureID",,get_full_name());
      this.FeatureID.configure(this, 12, 0, "RO", 0, 12'h13, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_qsfp_QSFP_CTRL_DFH)

endclass : ral_reg_ac_qsfp_QSFP_CTRL_DFH


class ral_reg_ac_qsfp_QSFP_CONTROLLER_CONFIG_REG extends uvm_reg;
	rand uvm_reg_field Ctrl_rsvd;
	rand uvm_reg_field Poll_en;
	rand uvm_reg_field LPMode;
	rand uvm_reg_field ModSel;
	rand uvm_reg_field SoftResetQSFPC;
	rand uvm_reg_field SoftResetQSFPM;

	function new(string name = "ac_qsfp_QSFP_CONTROLLER_CONFIG_REG");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Ctrl_rsvd = uvm_reg_field::type_id::create("Ctrl_rsvd",,get_full_name());
      this.Ctrl_rsvd.configure(this, 59, 5, "WO", 0, 59'h000000000, 1, 0, 0);
      this.Poll_en = uvm_reg_field::type_id::create("Poll_en",,get_full_name());
      this.Poll_en.configure(this, 1, 4, "RW", 0, 1'h0, 1, 0, 0);
      this.LPMode = uvm_reg_field::type_id::create("LPMode",,get_full_name());
      this.LPMode.configure(this, 1, 3, "RW", 0, 1'h0, 1, 0, 0);
      this.ModSel = uvm_reg_field::type_id::create("ModSel",,get_full_name());
      this.ModSel.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
      this.SoftResetQSFPC = uvm_reg_field::type_id::create("SoftResetQSFPC",,get_full_name());
      this.SoftResetQSFPC.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.SoftResetQSFPM = uvm_reg_field::type_id::create("SoftResetQSFPM",,get_full_name());
      this.SoftResetQSFPM.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_qsfp_QSFP_CONTROLLER_CONFIG_REG)

endclass : ral_reg_ac_qsfp_QSFP_CONTROLLER_CONFIG_REG


class ral_reg_ac_qsfp_QSFP_CONTROLLER_STATUS_REG extends uvm_reg;
	rand uvm_reg_field Status_rsvd;
	uvm_reg_field Curr_fsm_state;
	uvm_reg_field Curr_rd_addr;
	uvm_reg_field Curr_rd_page;
	uvm_reg_field Fsm_paused;
	uvm_reg_field Src_ready;
	uvm_reg_field Snk_ready;
	uvm_reg_field Rx_err;
	uvm_reg_field Tx_err;
	uvm_reg_field Int_I2C;
	uvm_reg_field Int_QSFP;
	uvm_reg_field ModPRSL;

	function new(string name = "ac_qsfp_QSFP_CONTROLLER_STATUS_REG");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Status_rsvd = uvm_reg_field::type_id::create("Status_rsvd",,get_full_name());
      this.Status_rsvd.configure(this, 36, 28, "WO", 0, 36'h000000000, 1, 0, 0);
      this.Curr_fsm_state = uvm_reg_field::type_id::create("Curr_fsm_state",,get_full_name());
      this.Curr_fsm_state.configure(this, 4, 24, "RO", 0, 4'h0, 1, 0, 0);
      this.Curr_rd_addr = uvm_reg_field::type_id::create("Curr_rd_addr",,get_full_name());
      this.Curr_rd_addr.configure(this, 8, 16, "RO", 0, 8'h0, 1, 0, 1);
      this.Curr_rd_page = uvm_reg_field::type_id::create("Curr_rd_page",,get_full_name());
      this.Curr_rd_page.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.Fsm_paused = uvm_reg_field::type_id::create("Fsm_paused",,get_full_name());
      this.Fsm_paused.configure(this, 1, 7, "RO", 0, 1'h1, 1, 0, 0);
      this.Src_ready = uvm_reg_field::type_id::create("Src_ready",,get_full_name());
      this.Src_ready.configure(this, 1, 6, "RO", 0, 1'h1, 1, 0, 0);
      this.Snk_ready = uvm_reg_field::type_id::create("Snk_ready",,get_full_name());
      this.Snk_ready.configure(this, 1, 5, "RO", 0, 1'h1, 1, 0, 0);
      this.Rx_err = uvm_reg_field::type_id::create("Rx_err",,get_full_name());
      this.Rx_err.configure(this, 1, 4, "RO", 0, 1'h0, 1, 0, 0);
      this.Tx_err = uvm_reg_field::type_id::create("Tx_err",,get_full_name());
      this.Tx_err.configure(this, 1, 3, "RO", 0, 1'h0, 1, 0, 0);
      this.Int_I2C = uvm_reg_field::type_id::create("Int_I2C",,get_full_name());
      this.Int_I2C.configure(this, 1, 2, "RO", 0, 1'h0, 1, 0, 0);
      this.Int_QSFP = uvm_reg_field::type_id::create("Int_QSFP",,get_full_name());
      this.Int_QSFP.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.ModPRSL = uvm_reg_field::type_id::create("ModPRSL",,get_full_name());
      this.ModPRSL.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_qsfp_QSFP_CONTROLLER_STATUS_REG)

endclass : ral_reg_ac_qsfp_QSFP_CONTROLLER_STATUS_REG


class ral_reg_ac_qsfp_QSFP_CONTROLLER_SCRATCHPAD extends uvm_reg;
	rand uvm_reg_field Scratch_reg;

	function new(string name = "ac_qsfp_QSFP_CONTROLLER_SCRATCHPAD");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Scratch_reg = uvm_reg_field::type_id::create("Scratch_reg",,get_full_name());
      this.Scratch_reg.configure(this, 64, 0, "RW", 0, 64'h000000000, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_qsfp_QSFP_CONTROLLER_SCRATCHPAD)

endclass : ral_reg_ac_qsfp_QSFP_CONTROLLER_SCRATCHPAD


class ral_reg_ac_qsfp_QSFP_CONTROLLER_I2C_REG extends uvm_reg;
	rand uvm_reg_field TRF_CMD;
	rand uvm_reg_field RX_DATA;
	rand uvm_reg_field CTRL;
	rand uvm_reg_field ISER;
	rand uvm_reg_field STATUS;
	rand uvm_reg_field TFR_CMD_FIFO_LVL;
	rand uvm_reg_field RX_DATA_FIFO_LVL;

	function new(string name = "ac_qsfp_QSFP_CONTROLLER_I2C_REG");
		super.new(name, 64,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.TRF_CMD = uvm_reg_field::type_id::create("TRF_CMD",,get_full_name());
      this.TRF_CMD.configure(this, 8, 56, "RW", 0, 8'h0, 1, 0, 1);
      this.RX_DATA = uvm_reg_field::type_id::create("RX_DATA",,get_full_name());
      this.RX_DATA.configure(this, 8, 48, "RW", 0, 8'h0, 1, 0, 1);
      this.CTRL = uvm_reg_field::type_id::create("CTRL",,get_full_name());
      this.CTRL.configure(this, 8, 40, "RW", 0, 8'h0, 1, 0, 1);
      this.ISER = uvm_reg_field::type_id::create("ISER",,get_full_name());
      this.ISER.configure(this, 8, 32, "RW", 0, 8'h0, 1, 0, 1);
      this.STATUS = uvm_reg_field::type_id::create("STATUS",,get_full_name());
      this.STATUS.configure(this, 8, 24, "RW", 0, 8'h0, 1, 0, 1);
      this.TFR_CMD_FIFO_LVL = uvm_reg_field::type_id::create("TFR_CMD_FIFO_LVL",,get_full_name());
      this.TFR_CMD_FIFO_LVL.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.RX_DATA_FIFO_LVL = uvm_reg_field::type_id::create("RX_DATA_FIFO_LVL",,get_full_name());
      this.RX_DATA_FIFO_LVL.configure(this, 16, 0, "RW", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_qsfp_QSFP_CONTROLLER_I2C_REG)

endclass : ral_reg_ac_qsfp_QSFP_CONTROLLER_I2C_REG


class ral_block_ac_qsfp extends uvm_reg_block;
	rand ral_reg_ac_qsfp_QSFP_CTRL_DFH QSFP_CTRL_DFH;
	rand ral_reg_ac_qsfp_QSFP_CONTROLLER_CONFIG_REG QSFP_CONTROLLER_CONFIG_REG;
	rand ral_reg_ac_qsfp_QSFP_CONTROLLER_STATUS_REG QSFP_CONTROLLER_STATUS_REG;
	rand ral_reg_ac_qsfp_QSFP_CONTROLLER_SCRATCHPAD QSFP_CONTROLLER_SCRATCHPAD;
	rand ral_reg_ac_qsfp_QSFP_CONTROLLER_I2C_REG QSFP_CONTROLLER_I2C_REG;
	uvm_reg_field QSFP_CTRL_DFH_FeatureType;
	uvm_reg_field FeatureType;
	rand uvm_reg_field QSFP_CTRL_DFH_Reserved;
	rand uvm_reg_field Reserved;
	uvm_reg_field QSFP_CTRL_DFH_EndOfList;
	uvm_reg_field EndOfList;
	uvm_reg_field QSFP_CTRL_DFH_NextDfhByteOffset;
	uvm_reg_field NextDfhByteOffset;
	uvm_reg_field QSFP_CTRL_DFH_FeatureRev;
	uvm_reg_field FeatureRev;
	uvm_reg_field QSFP_CTRL_DFH_FeatureID;
	uvm_reg_field FeatureID;
	rand uvm_reg_field QSFP_CONTROLLER_CONFIG_REG_Ctrl_rsvd;
	rand uvm_reg_field Ctrl_rsvd;
	rand uvm_reg_field QSFP_CONTROLLER_CONFIG_REG_Poll_en;
	rand uvm_reg_field Poll_en;
	rand uvm_reg_field QSFP_CONTROLLER_CONFIG_REG_LPMode;
	rand uvm_reg_field LPMode;
	rand uvm_reg_field QSFP_CONTROLLER_CONFIG_REG_ModSel;
	rand uvm_reg_field ModSel;
	rand uvm_reg_field QSFP_CONTROLLER_CONFIG_REG_SoftResetQSFPC;
	rand uvm_reg_field SoftResetQSFPC;
	rand uvm_reg_field QSFP_CONTROLLER_CONFIG_REG_SoftResetQSFPM;
	rand uvm_reg_field SoftResetQSFPM;
	rand uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Status_rsvd;
	rand uvm_reg_field Status_rsvd;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Curr_fsm_state;
	uvm_reg_field Curr_fsm_state;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Curr_rd_addr;
	uvm_reg_field Curr_rd_addr;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Curr_rd_page;
	uvm_reg_field Curr_rd_page;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Fsm_paused;
	uvm_reg_field Fsm_paused;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Src_ready;
	uvm_reg_field Src_ready;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Snk_ready;
	uvm_reg_field Snk_ready;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Rx_err;
	uvm_reg_field Rx_err;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Tx_err;
	uvm_reg_field Tx_err;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Int_I2C;
	uvm_reg_field Int_I2C;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_Int_QSFP;
	uvm_reg_field Int_QSFP;
	uvm_reg_field QSFP_CONTROLLER_STATUS_REG_ModPRSL;
	uvm_reg_field ModPRSL;
	rand uvm_reg_field QSFP_CONTROLLER_SCRATCHPAD_Scratch_reg;
	rand uvm_reg_field Scratch_reg;
	rand uvm_reg_field QSFP_CONTROLLER_I2C_REG_TRF_CMD;
	rand uvm_reg_field TRF_CMD;
	rand uvm_reg_field QSFP_CONTROLLER_I2C_REG_RX_DATA;
	rand uvm_reg_field RX_DATA;
	rand uvm_reg_field QSFP_CONTROLLER_I2C_REG_CTRL;
	rand uvm_reg_field CTRL;
	rand uvm_reg_field QSFP_CONTROLLER_I2C_REG_ISER;
	rand uvm_reg_field ISER;
	rand uvm_reg_field QSFP_CONTROLLER_I2C_REG_STATUS;
	rand uvm_reg_field STATUS;
	rand uvm_reg_field QSFP_CONTROLLER_I2C_REG_TFR_CMD_FIFO_LVL;
	rand uvm_reg_field TFR_CMD_FIFO_LVL;
	rand uvm_reg_field QSFP_CONTROLLER_I2C_REG_RX_DATA_FIFO_LVL;
	rand uvm_reg_field RX_DATA_FIFO_LVL;

	function new(string name = "ac_qsfp");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.QSFP_CTRL_DFH = ral_reg_ac_qsfp_QSFP_CTRL_DFH::type_id::create("QSFP_CTRL_DFH",,get_full_name());
      this.QSFP_CTRL_DFH.configure(this, null, "");
      this.QSFP_CTRL_DFH.build();
      this.default_map.add_reg(this.QSFP_CTRL_DFH, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.QSFP_CTRL_DFH_FeatureType = this.QSFP_CTRL_DFH.FeatureType;
		this.FeatureType = this.QSFP_CTRL_DFH.FeatureType;
		this.QSFP_CTRL_DFH_Reserved = this.QSFP_CTRL_DFH.Reserved;
		this.Reserved = this.QSFP_CTRL_DFH.Reserved;
		this.QSFP_CTRL_DFH_EndOfList = this.QSFP_CTRL_DFH.EndOfList;
		this.EndOfList = this.QSFP_CTRL_DFH.EndOfList;
		this.QSFP_CTRL_DFH_NextDfhByteOffset = this.QSFP_CTRL_DFH.NextDfhByteOffset;
		this.NextDfhByteOffset = this.QSFP_CTRL_DFH.NextDfhByteOffset;
		this.QSFP_CTRL_DFH_FeatureRev = this.QSFP_CTRL_DFH.FeatureRev;
		this.FeatureRev = this.QSFP_CTRL_DFH.FeatureRev;
		this.QSFP_CTRL_DFH_FeatureID = this.QSFP_CTRL_DFH.FeatureID;
		this.FeatureID = this.QSFP_CTRL_DFH.FeatureID;
      this.QSFP_CONTROLLER_CONFIG_REG = ral_reg_ac_qsfp_QSFP_CONTROLLER_CONFIG_REG::type_id::create("QSFP_CONTROLLER_CONFIG_REG",,get_full_name());
      this.QSFP_CONTROLLER_CONFIG_REG.configure(this, null, "");
      this.QSFP_CONTROLLER_CONFIG_REG.build();
      this.default_map.add_reg(this.QSFP_CONTROLLER_CONFIG_REG, `UVM_REG_ADDR_WIDTH'h20, "RW", 0);
		this.QSFP_CONTROLLER_CONFIG_REG_Ctrl_rsvd = this.QSFP_CONTROLLER_CONFIG_REG.Ctrl_rsvd;
		this.Ctrl_rsvd = this.QSFP_CONTROLLER_CONFIG_REG.Ctrl_rsvd;
		this.QSFP_CONTROLLER_CONFIG_REG_Poll_en = this.QSFP_CONTROLLER_CONFIG_REG.Poll_en;
		this.Poll_en = this.QSFP_CONTROLLER_CONFIG_REG.Poll_en;
		this.QSFP_CONTROLLER_CONFIG_REG_LPMode = this.QSFP_CONTROLLER_CONFIG_REG.LPMode;
		this.LPMode = this.QSFP_CONTROLLER_CONFIG_REG.LPMode;
		this.QSFP_CONTROLLER_CONFIG_REG_ModSel = this.QSFP_CONTROLLER_CONFIG_REG.ModSel;
		this.ModSel = this.QSFP_CONTROLLER_CONFIG_REG.ModSel;
		this.QSFP_CONTROLLER_CONFIG_REG_SoftResetQSFPC = this.QSFP_CONTROLLER_CONFIG_REG.SoftResetQSFPC;
		this.SoftResetQSFPC = this.QSFP_CONTROLLER_CONFIG_REG.SoftResetQSFPC;
		this.QSFP_CONTROLLER_CONFIG_REG_SoftResetQSFPM = this.QSFP_CONTROLLER_CONFIG_REG.SoftResetQSFPM;
		this.SoftResetQSFPM = this.QSFP_CONTROLLER_CONFIG_REG.SoftResetQSFPM;
      this.QSFP_CONTROLLER_STATUS_REG = ral_reg_ac_qsfp_QSFP_CONTROLLER_STATUS_REG::type_id::create("QSFP_CONTROLLER_STATUS_REG",,get_full_name());
      this.QSFP_CONTROLLER_STATUS_REG.configure(this, null, "");
      this.QSFP_CONTROLLER_STATUS_REG.build();
      this.default_map.add_reg(this.QSFP_CONTROLLER_STATUS_REG, `UVM_REG_ADDR_WIDTH'h28, "RW", 0);
		this.QSFP_CONTROLLER_STATUS_REG_Status_rsvd = this.QSFP_CONTROLLER_STATUS_REG.Status_rsvd;
		this.Status_rsvd = this.QSFP_CONTROLLER_STATUS_REG.Status_rsvd;
		this.QSFP_CONTROLLER_STATUS_REG_Curr_fsm_state = this.QSFP_CONTROLLER_STATUS_REG.Curr_fsm_state;
		this.Curr_fsm_state = this.QSFP_CONTROLLER_STATUS_REG.Curr_fsm_state;
		this.QSFP_CONTROLLER_STATUS_REG_Curr_rd_addr = this.QSFP_CONTROLLER_STATUS_REG.Curr_rd_addr;
		this.Curr_rd_addr = this.QSFP_CONTROLLER_STATUS_REG.Curr_rd_addr;
		this.QSFP_CONTROLLER_STATUS_REG_Curr_rd_page = this.QSFP_CONTROLLER_STATUS_REG.Curr_rd_page;
		this.Curr_rd_page = this.QSFP_CONTROLLER_STATUS_REG.Curr_rd_page;
		this.QSFP_CONTROLLER_STATUS_REG_Fsm_paused = this.QSFP_CONTROLLER_STATUS_REG.Fsm_paused;
		this.Fsm_paused = this.QSFP_CONTROLLER_STATUS_REG.Fsm_paused;
		this.QSFP_CONTROLLER_STATUS_REG_Src_ready = this.QSFP_CONTROLLER_STATUS_REG.Src_ready;
		this.Src_ready = this.QSFP_CONTROLLER_STATUS_REG.Src_ready;
		this.QSFP_CONTROLLER_STATUS_REG_Snk_ready = this.QSFP_CONTROLLER_STATUS_REG.Snk_ready;
		this.Snk_ready = this.QSFP_CONTROLLER_STATUS_REG.Snk_ready;
		this.QSFP_CONTROLLER_STATUS_REG_Rx_err = this.QSFP_CONTROLLER_STATUS_REG.Rx_err;
		this.Rx_err = this.QSFP_CONTROLLER_STATUS_REG.Rx_err;
		this.QSFP_CONTROLLER_STATUS_REG_Tx_err = this.QSFP_CONTROLLER_STATUS_REG.Tx_err;
		this.Tx_err = this.QSFP_CONTROLLER_STATUS_REG.Tx_err;
		this.QSFP_CONTROLLER_STATUS_REG_Int_I2C = this.QSFP_CONTROLLER_STATUS_REG.Int_I2C;
		this.Int_I2C = this.QSFP_CONTROLLER_STATUS_REG.Int_I2C;
		this.QSFP_CONTROLLER_STATUS_REG_Int_QSFP = this.QSFP_CONTROLLER_STATUS_REG.Int_QSFP;
		this.Int_QSFP = this.QSFP_CONTROLLER_STATUS_REG.Int_QSFP;
		this.QSFP_CONTROLLER_STATUS_REG_ModPRSL = this.QSFP_CONTROLLER_STATUS_REG.ModPRSL;
		this.ModPRSL = this.QSFP_CONTROLLER_STATUS_REG.ModPRSL;
      this.QSFP_CONTROLLER_SCRATCHPAD = ral_reg_ac_qsfp_QSFP_CONTROLLER_SCRATCHPAD::type_id::create("QSFP_CONTROLLER_SCRATCHPAD",,get_full_name());
      this.QSFP_CONTROLLER_SCRATCHPAD.configure(this, null, "");
      this.QSFP_CONTROLLER_SCRATCHPAD.build();
      this.default_map.add_reg(this.QSFP_CONTROLLER_SCRATCHPAD, `UVM_REG_ADDR_WIDTH'h30, "RW", 0);
		this.QSFP_CONTROLLER_SCRATCHPAD_Scratch_reg = this.QSFP_CONTROLLER_SCRATCHPAD.Scratch_reg;
		this.Scratch_reg = this.QSFP_CONTROLLER_SCRATCHPAD.Scratch_reg;
      this.QSFP_CONTROLLER_I2C_REG = ral_reg_ac_qsfp_QSFP_CONTROLLER_I2C_REG::type_id::create("QSFP_CONTROLLER_I2C_REG",,get_full_name());
      this.QSFP_CONTROLLER_I2C_REG.configure(this, null, "");
      this.QSFP_CONTROLLER_I2C_REG.build();
      this.default_map.add_reg(this.QSFP_CONTROLLER_I2C_REG, `UVM_REG_ADDR_WIDTH'h40, "RW", 0);
		this.QSFP_CONTROLLER_I2C_REG_TRF_CMD = this.QSFP_CONTROLLER_I2C_REG.TRF_CMD;
		this.TRF_CMD = this.QSFP_CONTROLLER_I2C_REG.TRF_CMD;
		this.QSFP_CONTROLLER_I2C_REG_RX_DATA = this.QSFP_CONTROLLER_I2C_REG.RX_DATA;
		this.RX_DATA = this.QSFP_CONTROLLER_I2C_REG.RX_DATA;
		this.QSFP_CONTROLLER_I2C_REG_CTRL = this.QSFP_CONTROLLER_I2C_REG.CTRL;
		this.CTRL = this.QSFP_CONTROLLER_I2C_REG.CTRL;
		this.QSFP_CONTROLLER_I2C_REG_ISER = this.QSFP_CONTROLLER_I2C_REG.ISER;
		this.ISER = this.QSFP_CONTROLLER_I2C_REG.ISER;
		this.QSFP_CONTROLLER_I2C_REG_STATUS = this.QSFP_CONTROLLER_I2C_REG.STATUS;
		this.STATUS = this.QSFP_CONTROLLER_I2C_REG.STATUS;
		this.QSFP_CONTROLLER_I2C_REG_TFR_CMD_FIFO_LVL = this.QSFP_CONTROLLER_I2C_REG.TFR_CMD_FIFO_LVL;
		this.TFR_CMD_FIFO_LVL = this.QSFP_CONTROLLER_I2C_REG.TFR_CMD_FIFO_LVL;
		this.QSFP_CONTROLLER_I2C_REG_RX_DATA_FIFO_LVL = this.QSFP_CONTROLLER_I2C_REG.RX_DATA_FIFO_LVL;
		this.RX_DATA_FIFO_LVL = this.QSFP_CONTROLLER_I2C_REG.RX_DATA_FIFO_LVL;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_qsfp)

endclass : ral_block_ac_qsfp



`endif
