// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_NACK_DET_TEST_SVH
`define QSFP_NACK_DET_TEST_SVH

class qsfp_nack_det_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_nack_det_test)
  qsfp_nack_det_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info("qsfp_nack_det_test",": Starting Read and Write task for CSR Registers",UVM_LOW)
    m_seq = qsfp_nack_det_seq::type_id::create("m_seq",this);
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);
  endtask : run_phase

endclass : qsfp_nack_det_test

`endif // QSFP_NACK_DET_TEST_SVH

