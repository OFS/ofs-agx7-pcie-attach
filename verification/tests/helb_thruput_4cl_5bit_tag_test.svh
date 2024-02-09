//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef HELB_THRUPUT_4CL_5BIT_TAG_TEST_SVH
`define HELB_THRUPUT_4CL_5BIT_TAG_TEST_SVH

class helb_thruput_4cl_5bit_tag_test extends base_test;
    `uvm_component_utils(helb_thruput_4cl_5bit_tag_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
     virtual function void build_phase(uvm_phase phase);
	int max_payload_size;
	bit[2:0] max_rd_req;
	bit[3:0] enable_tag_5= 5;
 	super.build_phase(phase);
	max_payload_size = 1024;
	//max_rd_req = 3'b001;

	//uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_rd_req", max_rd_req);
	//`uvm_info("body", $sformatf("ENV: max_rd_req %d ", max_rd_req), UVM_LOW);
    
    uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "enable_tag_5", enable_tag_5);
	`uvm_info("body", $sformatf("TAG: enable_tag %d ", enable_tag_5), UVM_LOW);

	uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_payload_size", max_payload_size);
	`uvm_info("body", $sformatf("ENV: max_payload_size %d ", max_payload_size), UVM_LOW);

    endfunction: build_phase

    task run_phase(uvm_phase phase);
        helb_thruput_4cl_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = helb_thruput_4cl_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : helb_thruput_4cl_5bit_tag_test

`endif // HELB_THRUPUT_4CL_5BIT_TAG_TEST_SVH
