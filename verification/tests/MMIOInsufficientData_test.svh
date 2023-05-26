//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef MMIOINSUFFICIENTDATA_TEST_SVH
`define MMIOINSUFFICIENTDATA_TEST_SVH

class MMIOInsufficientData_test extends base_test;
  `uvm_component_utils(MMIOInsufficientData_test)

   function new(string name = "MMIOInsufficientData_test", uvm_component parent=null);
      super.new(name,parent);
   endfunction : new
  
   task run_phase(uvm_phase phase);
    	MMIOInsufficientData_seq m_seq;
    	super.run_phase(phase);
    	phase.raise_objection(this);
    	m_seq =MMIOInsufficientData_seq::type_id::create("m_seq");
    	m_seq.start(tb_env0.v_sequencer);
    	phase.drop_objection(this);
   endtask : run_phase         

endclass
`endif








