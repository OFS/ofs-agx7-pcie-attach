//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef  EMIF_CSR_TEST_SVH
`define  EMIF_CSR_TEST_SVH

class  emif_csr_test extends base_test;
    `uvm_component_utils(emif_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        emif_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq =emif_csr_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : emif_csr_test
`endif //  EMIF_CSR_SVH
