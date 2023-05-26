// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CONFIG_SEQ_SVH
`define CONFIG_SEQ_SVH

class config_seq extends uvm_sequence;
    `uvm_object_utils(config_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    pcie_device_bring_up_link_sequence bring_up_link_seq;
    enumerate_seq                      enumerate_seq;
    bit [2:0]                          tc;

    function new(string name = "config_seq");
        super.new(name);
    endfunction : new

    task body();
        bit status;
        super.body();
	`uvm_info(get_name(), "Entering config sequence", UVM_LOW)
	// linkup
	`uvm_info(get_name(), "Linking up...", UVM_LOW)
	`uvm_do_on(bring_up_link_seq, p_sequencer.root_virt_seqr)
	`uvm_info(get_name(), "Link is up now", UVM_LOW)
	// enumerating PCIe HIP
	`uvm_info(get_name(), "Enumerating...", UVM_LOW)
	`uvm_do_on(enumerate_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0])
	`uvm_info(get_name(), "Enumeration is done", UVM_LOW)

	status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "tc", tc);
	tc = (status) ? tc : 0;

        // initial port reset
	`uvm_info(get_name(), "Port reseting", UVM_LOW)
	// TODO
	`uvm_info(get_name(), "Port reset is done", UVM_LOW)

	`uvm_info(get_name(), "Exiting config sequence", UVM_LOW)
    endtask : body


endclass : config_seq

`endif // CONFIG_SEQ_SVH
