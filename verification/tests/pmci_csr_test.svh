//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef PMCI_CSR_TEST_SVH
`define PMCI_CSR_TEST_SVH

class pmci_csr_test extends base_test;
    `uvm_component_utils(pmci_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        pmci_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
        `ifdef INCLUDE_PMCI
	  m_seq = pmci_csr_seq::type_id::create("m_seq");
	  m_seq.start(tb_env0.v_sequencer);
        `endif
	phase.drop_objection(this);
    endtask : run_phase

endclass : pmci_csr_test

`endif // FME_CSR_TEST_SVH
