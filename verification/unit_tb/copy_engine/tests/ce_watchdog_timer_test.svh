// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_WATCHDOG_TIMER_TEST_SVH
`define CE_WATCHDOG_TIMER_TEST_SVH

class ce_watchdog_timer_test extends base_test;
    `uvm_component_utils(ce_watchdog_timer_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
     ce_watchdog_timer_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq =ce_watchdog_timer_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase
endclass:ce_watchdog_timer_test
`endif //CE_WATCHDOG_TIMER_TEST_SVH

