//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef HELB_WR_2CL_TEST_SVH
`define HELB_WR_2CL_TEST_SVH

class helb_wr_2cl_test extends base_test;
    `uvm_component_utils(helb_wr_2cl_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        helb_wr_2cl_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = helb_wr_2cl_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : helb_wr_2cl_test

`endif // HELB_WR_2CL_TEST_SVH
