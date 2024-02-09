// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_DRL_TEST_SVH
`define CE_DRL_TEST_SVH

class ce_drl_test extends base_test;
   `uvm_component_utils(ce_drl_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   /*virtual function void build_phase(uvm_phase phase);

  // uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.axi_system_env.slave[0].sequencer.run_phase", "default_sequence", axi_slave_mem_response_sequence::type_id::get());

endfunction : build_phase*/


   task run_phase(uvm_phase phase);
      ce_drl_seq m_seq;
      super.run_phase(phase);
      phase.raise_objection(this);
      m_seq=ce_drl_seq::type_id::create("m_seq");
      m_seq.start(tb_env0.v_sequencer);
      phase.drop_objection(this);
   endtask : run_phase

endclass : ce_drl_test

`endif //CE_DRL_TEST_SVH
