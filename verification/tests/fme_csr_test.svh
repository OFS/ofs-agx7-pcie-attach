//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef FME_CSR_TEST_SVH
`define FME_CSR_TEST_SVH

class fme_csr_test extends base_test;
    `uvm_component_utils(fme_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        fme_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = fme_csr_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : fme_csr_test

`endif // FME_CSR_TEST_SVH
