// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_BKP_TEST_SVH
`define CE_BKP_TEST_SVH

class ce_bkp_test extends base_test;
   `uvm_component_utils(ce_bkp_test)
    
    `VIP_ERR_CATCHER_CLASS err_catcher;
   
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   virtual function void build_phase(uvm_phase phase);
 	super.build_phase(phase);
    tb_cfg0.has_sb = 1;
    
    err_catcher=new();
  //add error message string to error catcher 
    err_catcher.add_message_id_to_demote("/register_fail:AMBA:AXI3:wlast_asserted_for_last_write_data_beat/");
    err_catcher.add_message_id_to_demote("/register_fail:AMBA:AXI3:wdata_awlen_match_for_corresponding_awaddr_check/");
    uvm_report_cb::add(null,err_catcher);

    endfunction: build_phase

   task run_phase(uvm_phase phase);
      ce_bkp_seq m_seq;
      hps2ce_gpio_seq p_seq;
      super.run_phase(phase);
      phase.raise_objection(this);
      m_seq=ce_bkp_seq::type_id::create("m_seq");
      p_seq=hps2ce_gpio_seq::type_id::create("p_seq");
      fork
      m_seq.start(tb_env0.v_sequencer);
     p_seq.start(tb_env0.v_sequencer);
	  join
     phase.drop_objection(this);
   endtask : run_phase

endclass : ce_bkp_test

`endif //CE_BKP_TEST_SVH
