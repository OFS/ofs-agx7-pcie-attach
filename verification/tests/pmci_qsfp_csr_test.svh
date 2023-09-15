//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef PMCI_QSFP_CSR_TEST_SVH
`define PMCI_QSFP_CSR_TEST_SVH

class pmci_qsfp_csr_test extends base_test;
    `uvm_component_utils(pmci_qsfp_csr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db#(int)::set(this,"*tb_env0*","pmci_master",1);
    endfunction : build_phase


    task run_phase(uvm_phase phase);
      pmci_qsfp_csr_seq   axi_seq;
      super.run_phase(phase);
      phase.raise_objection(this);
      `ifdef INCLUDE_PMCI
        axi_seq = pmci_qsfp_csr_seq::type_id::create("axi_seq"); 
        axi_seq.start (tb_env0.v_sequencer);
      `endif
     phase.drop_objection(this);
    endtask : run_phase

endclass : pmci_qsfp_csr_test

`endif // PMCI_QSFP_CSR_TEST_SVH
