// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_I2C_READ_WRITE_SANITY_TEST_SVH
`define QSFP_I2C_READ_WRITE_SANITY_TEST_SVH

class qsfp_i2c_read_write_sanity_lower_upper_page_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_i2c_read_write_sanity_lower_upper_page_test)
    
  qsfp_i2c_read_write_sanity_lower_upper_page_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
     
    phase.raise_objection(this);
    m_seq = qsfp_i2c_read_write_sanity_lower_upper_page_seq::type_id::create("m_seq");
    `uvm_info("qsfp_i2c_read_write_sanity_lower_upper_page_test:"," Starting Read and Write task for CSR Registers",UVM_LOW)
    m_seq = qsfp_i2c_read_write_sanity_lower_upper_page_seq::type_id::create("m_seq");
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);

  endtask : run_phase

endclass : qsfp_i2c_read_write_sanity_lower_upper_page_test

`endif // QSFP_I2C_READ_WRITE_SANITY_LOWER_UPPER_PAGE_TEST_SVH

