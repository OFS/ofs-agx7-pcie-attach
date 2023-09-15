// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef  CE_B2B_WR_RD_TEST_SVH
`define  CE_B2B_WR_RD_TEST_SVH

class  ce_b2b_wr_rd_test extends base_test;
    `uvm_component_utils(ce_b2b_wr_rd_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     tb_cfg0.has_sb = 0;
    endfunction : build_phase

    task run_phase(uvm_phase phase);
     ce_b2b_wr_rd_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq =ce_b2b_wr_rd_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : ce_b2b_wr_rd_test
`endif //  ce_b2b_wr_rd_SVH
