// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_PIO_INPUT_TOGGLE_PARALLEL_TEST
`define QSFP_PIO_INPUT_TOGGLE_PARALLEL_TEST

class qsfp_pio_input_toggle_parallel_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_pio_input_toggle_parallel_test)
  qsfp_pio_input_toggle_parallel_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info("qsfp_pio_input_toggle_parallel_test",":Perform read from the QSFP\Module modPRSL and int_qsfp bits  in parallel",UVM_LOW)
    dis_init_seq=1'b1;
    m_seq = qsfp_pio_input_toggle_parallel_seq::type_id::create("m_seq",this);
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);
  endtask : run_phase

endclass : qsfp_pio_input_toggle_parallel_test

`endif // QSFP_PIO_INPUT_TOGGLE_PARALLEL_TEST

