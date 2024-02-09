// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef MSIX_SIZE_CSR_TEST_SVH
`define MSIX_SIZE_CSR_TEST_SVH

class msix_size_csr_test extends base_test;
    `uvm_component_utils(msix_size_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
      `ifdef INCLUDE_CVL
      `ifndef NO_MSIX   
        msix_size_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = msix_size_csr_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
      `endif	
      `endif
    endtask : run_phase

endclass : msix_size_csr_test

`endif // MSIX_SIZE_CSR_TEST_SVH
