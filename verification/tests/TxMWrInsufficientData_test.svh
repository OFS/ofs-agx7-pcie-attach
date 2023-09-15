//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef  TXMWRINSUFFICIENTDATA_TEST_SVH
`define  TXMWRINSUFFICIENTDATA_TEST_SVH

class TxMWrInsufficientData_test extends base_test;
 `uvm_component_utils(TxMWrInsufficientData_test)

  function new(string name = "TxMWrInsufficientData_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build();
    super.build();
    assert(this.randomize());
    uvm_config_db#(int)::set(this, "*tb_env0*", "rx_err_enable", 8'b0000_1000);
    uvm_config_db#(int)::set(this, "*tb_env0*", "flush_disable", 1);
  endfunction : build 

  task run_phase(uvm_phase phase);
    	TxMWrInsufficientData_seq   m_seq;
    	super.run_phase(phase);
    	phase.raise_objection(this);
    	m_seq =TxMWrInsufficientData_seq::type_id::create("m_seq");
    	m_seq.randomize();
    	m_seq.start(tb_env0.v_sequencer);
    	phase.drop_objection(this);
  endtask : run_phase         

endclass

`endif
