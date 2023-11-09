//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef MMIO_UNIMP_TEST_SVH
`define MMIO_UNIMP_TEST_SVH

class mmio_unimp_test extends base_test;
    `uvm_component_utils(mmio_unimp_test)
	`VIP_ERR_CATCHER_CLASS err_catcher;
         err_demoter demote;
   function new(string name, uvm_component parent);
        super.new(name, parent);
   endfunction : new

   virtual function void build();
        super.build();
        err_catcher=new();
         demote=new();
        //add error message string to error catcher 
        err_catcher.add_message_id_to_demote("/register_fail:ACTIVE_DRIVER_APP:COMPLETION:appl_driver_missing_good_status/");
        uvm_report_cb::add(null,demote);
   endfunction : build 


   task run_phase(uvm_phase phase);
     mmio_unimp_seq m_seq;
     super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = mmio_unimp_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
   endtask : run_phase

endclass : mmio_unimp_test

`endif // MMIO_UNIMP_TEST_SVH
