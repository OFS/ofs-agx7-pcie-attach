// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_PIO_OUTPUT_TOGGLE_PARALLEL_TEST_SVH
`define QSFP_PIO_OUTPUT_TOGGLE_PARALLEL_TEST_SVH

class qsfp_pio_output_toggle_parallel_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_pio_output_toggle_parallel_test)
      
  qsfp_pio_output_toggle_parallel_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    dis_init_seq=1'b1;
    m_seq = qsfp_pio_output_toggle_parallel_seq::type_id::create("m_seq",this);
    m_seq.start(tb_env0.v_sequencer);
    `uvm_info("qsfp_pio_output_toggle_parallel_test","qsfp_pio_output_toggle_parallel_test:Perform Write to the QSFP Module Interface Config register outputs namely softresetqsfpm,  modesel and lpmode bits are set in parallel",UVM_LOW)
    phase.drop_objection(this);

   endtask : run_phase

endclass : qsfp_pio_output_toggle_parallel_test

`endif // QSFP_PIO_OUTPUT_TOGGLE_PARALLEL_TEST

