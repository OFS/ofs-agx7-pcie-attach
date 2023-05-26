// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_READ_WRITE_REGISTER_TEST_SVH
`define QSFP_READ_WRITE_REGISTER_TEST_SVH

class qsfp_read_write_register_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_read_write_register_test)

  qsfp_read_write_register_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    dis_init_seq=1'b1;
    `uvm_info("qsfp_read_write_register_test",": Starting Read and Write task for CSR Registers",UVM_LOW)
    m_seq = qsfp_read_write_register_seq::type_id::create("m_seq");
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);

  endtask : run_phase

endclass : qsfp_read_write_register_test

`endif // QSFP_READ_WRITE_REGISTER_TEST_SVH

