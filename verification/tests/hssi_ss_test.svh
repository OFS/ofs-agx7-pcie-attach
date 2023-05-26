//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef HSSI_SS_TEST_SVH
`define HSSI_SS_TEST_SVH

class hssi_ss_test extends base_test;
    `uvm_component_utils(hssi_ss_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        hssi_ss_seq  h_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	h_seq = hssi_ss_seq::type_id::create("h_seq");
	h_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : hssi_ss_test

`endif // HSSI_SS_TEST_SVH
