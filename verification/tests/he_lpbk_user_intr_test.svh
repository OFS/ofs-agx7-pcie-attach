//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef HE_LPBK_USER_INTR_TEST_SVH
`define HE_LPBK_USER_INTR_TEST_SVH

class he_lpbk_user_intr_test extends base_test;
    `uvm_component_utils(he_lpbk_user_intr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
      `ifndef NO_MSIX
        he_lpbk_user_intr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = he_lpbk_user_intr_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
       `endif
    endtask : run_phase

endclass : he_lpbk_user_intr_test

`endif // HE_LPBK_USER_INTR_TEST_SVH
