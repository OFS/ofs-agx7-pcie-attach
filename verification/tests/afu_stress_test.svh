//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef AFU_STRESS_TEST_SVH
`define AFU_STRESS_TEST_SVH

class afu_stress_test extends base_test;
    `uvm_component_utils(afu_stress_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        afu_stress_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = afu_stress_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : afu_stress_test

`endif // AFU_STRESS_TEST_SVH
