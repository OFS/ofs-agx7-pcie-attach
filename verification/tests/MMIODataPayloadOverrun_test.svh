//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef MMIODATAPAYLOADOVERRUN_TEST_SVH
`define MMIODATAPAYLOADOVERRUN_TEST_SVH


class MMIODataPayloadOverrun_test extends base_test;
  `uvm_component_utils(MMIODataPayloadOverrun_test)

   function new(string name = "MMIODataPayloadOverrun_test", uvm_component parent=null);
     super.new(name,parent);
   endfunction : new
 
   task run_phase(uvm_phase phase);
    	MMIODataPayloadOverrun_seq m_seq;
     	super.run_phase(phase);
     	phase.raise_objection(this);
     	m_seq =MMIODataPayloadOverrun_seq::type_id::create("m_seq");
     	m_seq.start(tb_env0.v_sequencer);
     	phase.drop_objection(this);
   endtask : run_phase   

endclass
`endif








