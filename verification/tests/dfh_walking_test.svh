//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef DFH_WALKING_TEST_SVH
`define DFH_WALKING_TEST_SVH

class dfh_walking_test extends base_test;
    `uvm_component_utils(dfh_walking_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        dfh_walking_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = dfh_walking_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : dfh_walking_test

`endif // DFH_WALKING_TEST_SVH
