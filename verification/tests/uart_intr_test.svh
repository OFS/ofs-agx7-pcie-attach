//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef UART_INTR_TEST_SVH
`define UART_INTR_TEST_SVH

class uart_intr_test extends base_test;
    `uvm_component_utils(uart_intr_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
      `ifndef NO_MSIX  
        uart_intr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = uart_intr_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
       `endif
    endtask : run_phase

endclass : uart_intr_test

`endif // UART_INTR_TEST_SVH
