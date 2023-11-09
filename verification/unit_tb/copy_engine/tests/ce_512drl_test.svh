// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_512DRL_TEST_SVH
`define CE_512DRL_TEST_SVH

class ce_512drl_test extends base_test;
   `uvm_component_utils(ce_512drl_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   virtual function void build_phase(uvm_phase phase);
     int max_payload_size;
     int max_read_request_size;
     bit[2:0] max_pl_size;
     bit[2:0] max_rd_req;
     super.build_phase(phase);
     tb_cfg0.has_sb = 1;
     max_payload_size = 512;
     max_read_request_size = 512;
     max_pl_size = 3'b010;
     max_rd_req = 3'b010;

    uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_pl_size", max_pl_size);
   `uvm_info("body", $sformatf("ENV: max_pl_size %d ", max_pl_size), UVM_LOW);

    uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_read_request_size", max_read_request_size);
   `uvm_info("body", $sformatf("ENV: max_read_request_size %d ", max_read_request_size), UVM_LOW);

    uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_rd_req", max_rd_req);
   `uvm_info("body", $sformatf("ENV: max_rd_req %d ", max_rd_req), UVM_LOW);

    uvm_config_db#(int unsigned)::set(uvm_root::get(), "*", "max_payload_size", max_payload_size);
   `uvm_info("body", $sformatf("ENV: max_payload_size %d ", max_payload_size), UVM_LOW);

    endfunction : build_phase


   task run_phase(uvm_phase phase);
      ce_512drl_seq m_seq;
      hps2ce_gpio_seq p_seq;
      super.run_phase(phase);
      phase.raise_objection(this);
      m_seq=ce_512drl_seq::type_id::create("m_seq");
      p_seq=hps2ce_gpio_seq::type_id::create("p_seq");
	  fork   
	    m_seq.start(tb_env0.v_sequencer); 	
	    p_seq.start(tb_env0.v_sequencer);
	  join
      phase.drop_objection(this);
   endtask : run_phase

endclass : ce_512drl_test

`endif //CE_512DRL_TEST_SVH
