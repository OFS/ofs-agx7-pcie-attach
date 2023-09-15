//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef HELB_RD_4CL_TEST_SVH
`define HELB_RD_4CL_TEST_SVH

class helb_rd_4cl_test extends base_test;
    `uvm_component_utils(helb_rd_4cl_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
     virtual function void build_phase(uvm_phase phase);
	int max_payload_size;
	bit[2:0] max_rd_req;
 	super.build_phase(phase);
	max_payload_size = 256;
	uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_payload_size", max_payload_size);
       `uvm_info("body", $sformatf("ENV: max_payload_size %d ", max_payload_size), UVM_LOW);

    endfunction: build_phase


    task run_phase(uvm_phase phase);
        helb_rd_4cl_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = helb_rd_4cl_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : helb_rd_4cl_test

`endif // HELB_RD_4CL_TEST_SVH
