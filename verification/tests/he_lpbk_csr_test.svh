//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef HE_LPBK_CSR_TEST_SVH
`define HE_LPBK_CSR_TEST_SVH

class he_lpbk_csr_test extends base_test;
    `uvm_component_utils(he_lpbk_csr_test)
    `VIP_ERR_CATCHER_CLASS err_catcher;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build();
    super.build();
    err_catcher=new();
  //add error message string to error catcher 
    err_catcher.add_message_id_to_demote("/register_fail:ACTIVE_DRIVER_APP:COMPLETION:appl_driver_missing_good_status/");
    uvm_report_cb::add(null,err_catcher);
  endfunction : build 

    task run_phase(uvm_phase phase);
        he_lpbk_csr_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = he_lpbk_csr_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : he_lpbk_csr_test

`endif // HE_LPBK_CSR_TEST_SVH
