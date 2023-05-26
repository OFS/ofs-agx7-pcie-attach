//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef  MEM_TG_CSR_TEST_SVH
`define  MEM_TG_CSR_TEST_SVH

class  mem_tg_csr_test extends base_test;
   `uvm_component_utils(mem_tg_csr_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
     `ifdef INCLUDE_DDR4
      mem_tg_csr_seq m_seq;
      super.run_phase(phase);
      phase.raise_objection(this);
      m_seq = mem_tg_csr_seq::type_id::create("m_seq");
      m_seq.start(tb_env0.v_sequencer);
      phase.drop_objection(this);
    `else
      `uvm_info("INFO", "Test will run only with INCLUDE_DDR4 define, else it's an empty run", UVM_LOW);
    `endif

   endtask : run_phase

endclass : mem_tg_csr_test
`endif //  MEM_TG_CSR_TEST_SVH
