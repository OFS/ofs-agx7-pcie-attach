//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef MMIO_PCIE_MRRS_256B_MPS_256B_TEST_SVH
`define MMIO_PCIE_MRRS_256B_MPS_256B_TEST_SVH

class mmio_pcie_mrrs_256B_mps_256B_test extends base_test;
    `uvm_component_utils(mmio_pcie_mrrs_256B_mps_256B_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
	int max_payload_size;
	bit[2:0] max_rd_req;
 	super.build_phase(phase);
	max_payload_size = 256;
	max_rd_req = 3'b001;

	uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_rd_req", max_rd_req);
	`uvm_info("body", $sformatf("ENV: max_rd_req %d ", max_rd_req), UVM_LOW);

	uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_payload_size", max_payload_size);
	`uvm_info("body", $sformatf("ENV: max_payload_size %d ", max_payload_size), UVM_LOW);

    endfunction: build_phase

    task run_phase(uvm_phase phase);
        mmio_pcie_max_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = mmio_pcie_max_seq::type_id::create("m_seq");
	m_seq.randomize();
	//assert(m_seq.randomize() with {m_seq.req_len == 2'b10;});
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : mmio_pcie_mrrs_256B_mps_256B_test

`endif // MMIO_PCIE_MRRS_256B_MPS_256B_TEST_SVH

