// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef PMCI_QSFP_CSR_TEST_SVH
`define PMCI_QSFP_CSR_TEST_SVH

class hps2ce_gpio_test extends base_test;
    `uvm_component_utils(hps2ce_gpio_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        mmio_seq          vip_seq;
	hps2ce_gpio_seq   axi_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	vip_seq = mmio_seq::type_id::create("vip_seq");
	axi_seq = hps2ce_gpio_seq::type_id::create("axi_seq"); 
	//m_vseq = hps2ce_virtual_seq::type_id::create("m_vseq");
	//m_vseq.start(tb_env0.v_sequencer);
        fork
	  //vip_seq.start (tb_env0.v_sequencer);
          axi_seq.start (tb_env0.v_sequencer);
        join
	phase.drop_objection(this);
    endtask : run_phase

endclass : hps2ce_gpio_test

`endif // PMCI_QSFP_CSR_TEST_SVH
