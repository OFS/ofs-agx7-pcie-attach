//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef HE_HSSI_TX_LPBK_P1_TEST_SVH
`define HE_HSSI_TX_LPBK_P1_TEST_SVH

class he_hssi_tx_lpbk_P1_test extends base_test;
    `uvm_component_utils(he_hssi_tx_lpbk_P1_test)
    int len;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Entered ...", UVM_LOW)
    super.build_phase(phase);
    len=1;
	uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "LANE_NUM",len);
	`uvm_info("body", $sformatf("TX_LOOP_TEST:  %d ", len), UVM_LOW);

endfunction
    task run_phase(uvm_phase phase);
        he_hssi_tx_lpbk_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = he_hssi_tx_lpbk_seq::type_id::create("m_seq");
    m_seq.randomize();
    `uvm_info("INFO", $sformatf("TG_DATA_PATTERN_VAL: %b,TG_PKT_LEN_TYPE_VAL: %b ",m_seq.TG_DATA_PATTERN_VAL,m_seq.TG_PKT_LEN_TYPE_VAL ),UVM_LOW);
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : he_hssi_tx_lpbk_P1_test

`endif // HE_HSSI_TX_LPBK_P1_TEST_SVH
