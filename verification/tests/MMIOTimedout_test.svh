//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef MMIOTIMEDOUT_TEST_SVH
`define MMIOTIMEDOUT_TEST_SVH

class MMIOTimedout_test extends base_test;
 `uvm_component_utils(MMIOTimedout_test)
  
  function new(string name = "MMIOTimedout_test", uvm_component parent=null);
     super.new(name,parent);
  endfunction : new

  task run_phase(uvm_phase phase);
     	MMIOTimedOut_seq m_seq;
    	super.run_phase(phase);
     	phase.raise_objection(this);
    	m_seq =MMIOTimedOut_seq::type_id::create("m_seq");
     	m_seq.start(tb_env0.v_sequencer);
     	phase.drop_objection(this);
  endtask : run_phase         

endclass

`endif








