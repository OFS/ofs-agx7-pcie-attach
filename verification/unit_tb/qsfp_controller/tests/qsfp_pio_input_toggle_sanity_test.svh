// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_PIO_INPUT_TOGGLE_SANITY_TEST_SVH
`define QSFP_PIO_INPUT_TOGGLE_SANITY_TEST_SVH

class qsfp_pio_input_toggle_sanity_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_pio_input_toggle_sanity_test)
  qsfp_pio_input_toggle_sanity_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info("qsfp_pio_input_toggle_sanity_test"," Starting Read task for control & status Registers",UVM_LOW)
    dis_init_seq=1'b1;
    m_seq = qsfp_pio_input_toggle_sanity_seq::type_id::create("m_seq");
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);
  endtask : run_phase

endclass : qsfp_pio_input_toggle_sanity_test

`endif // QSFP_PIO_INPUT_TOGGLE_SANITY_TEST_SVH

