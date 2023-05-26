//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef HE_MEM_WR_TEST_SVH
`define HE_MEM_WR_TEST_SVH

class he_mem_wr_test extends base_test;
    `uvm_component_utils(he_mem_wr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        he_mem_wr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = he_mem_wr_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : he_mem_wr_test

`endif // HE_MEM_WR_TEST_SVH
