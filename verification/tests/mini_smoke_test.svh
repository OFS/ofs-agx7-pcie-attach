//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef MINI_SMOKE_TEST_SVH
`define MINI_SMOKE_TEST_SVH

class mini_smoke_test extends base_test;
    `uvm_component_utils(mini_smoke_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        mini_smoke_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = mini_smoke_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : mini_smoke_test

`endif // MINI_SMOKE_TEST_SVH
