//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef BAR_64B_TEST_SVH
`define BAR_64B_TEST_SVH

class bar_64b_test extends base_test;
    `uvm_component_utils(bar_64b_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   
      tb_cfg0.PF0_BAR0 = 'h8000_0000_0000_0000;
      tb_cfg0.PF0_BAR4 = 'h8020_0000_0000_0000;
      tb_cfg0.PF0_VF0_BAR0 = 'h9000_0000_0000_0000;
      tb_cfg0.PF0_VF1_BAR0 = tb_cfg0.PF0_VF0_BAR0 + 'h10_0000; //Page Size is 1MB
      tb_cfg0.PF0_VF2_BAR0 = tb_cfg0.PF0_VF1_BAR0 + 'h10_0000; //Page Size is 1MB
      tb_cfg0.PF1_BAR0 = 'hA000_0000_0000_0000;
      tb_cfg0.PF1_VF0_BAR0 = 'hB000_0000_0000_0000;
      tb_cfg0.PF2_BAR0 = 'hC000_0000_0000_0000;
      tb_cfg0.PF3_BAR0 = 'hD000_0000_0000_0000;
      tb_cfg0.PF4_BAR0 = 'hE000_0000_0000_0000;
      tb_cfg0.HE_MEM_BASE = tb_cfg0.PF0_VF0_BAR0; 
      tb_cfg0.HE_HSSI_BASE = tb_cfg0.PF0_VF1_BAR0;
      tb_cfg0.HE_MEM_TG_BASE = tb_cfg0.PF0_VF2_BAR0;
      tb_cfg0.HE_LB_BASE = tb_cfg0.PF2_BAR0;

 endfunction: build_phase

    task run_phase(uvm_phase phase);
        bar_64b_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = bar_64b_seq::type_id::create("m_seq");
	m_seq.randomize();
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase

endclass : bar_64b_test

`endif // BAR_64B_TEST_SVH
