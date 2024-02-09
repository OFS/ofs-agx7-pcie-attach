// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_I2C_READ_WRITE_B2B_TEST_SVH
`define QSFP_I2C_READ_WRITE_B2B_TEST_SVH

class qsfp_i2c_read_write_b2b_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_i2c_read_write_b2b_test)
  qsfp_i2c_read_write_b2b_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info("qsfp_i2c_read_write_b2b_test",": Starting Read and Write task for CSR Registers",UVM_LOW)
    m_seq = qsfp_i2c_read_write_b2b_seq::type_id::create("m_seq",this);
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);
  endtask : run_phase

endclass : qsfp_i2c_read_write_b2b_test

`endif // QSFP_I2C_READ_WRITE_B2B_TEST_SVH

