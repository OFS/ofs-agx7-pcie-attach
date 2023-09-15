//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef VDM_ERR_VID_TEST_SVH
`define VDM_ERR_VID_TEST_SVH

class vdm_err_vid_test extends base_test;
    `uvm_component_utils(vdm_err_vid_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        vdm_err_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = vdm_err_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
        #500ns;
	phase.drop_objection(this);
    endtask : run_phase

endclass : vdm_err_vid_test

`endif // VDM_ERR_VID_TEST_SVH
