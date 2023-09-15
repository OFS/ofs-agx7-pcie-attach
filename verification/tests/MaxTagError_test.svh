//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef MAXTAGERROR_TEST_SVH
`define MAXTAGERROR_TEST_SVH

class MaxTagError_test extends base_test;
  `uvm_component_utils(MaxTagError_test)
  
  function new(string name = "MaxTagError_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build();
    super.build();
     assert(this.randomize());
     uvm_config_db#(int)::set(this, "*tb_env0*", "rx_err_enable", 8'b0000_1000);
     uvm_config_db#(int)::set(this, "*tb_env0*", "flush_disable", 1);
  endfunction : build 

  task run_phase(uvm_phase phase);
      	MaxTagError_seq m_seq; 
      	super.run_phase(phase);
      	phase.raise_objection(this);
      	m_seq =MaxTagError_seq::type_id::create("m_seq");
      	m_seq.randomize();
      	m_seq.start(tb_env0.v_sequencer);
      	phase.drop_objection(this);
  endtask : run_phase         

endclass

`endif
