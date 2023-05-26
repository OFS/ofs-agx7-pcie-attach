//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef AFU_MMIO_FLR_PF1_VF0_TEST_SVH
`define AFU_MMIO_FLR_PF1_VF0_TEST_SVH

///////////////////////////////////////////////////////////////////////////////////
// test sequence
///////////////////////////////////////////////////////////////////////////////////

class afu_mmio_flr_pf1_vf0_test_seq extends base_seq;
  `uvm_object_utils(afu_mmio_flr_pf1_vf0_test_seq)

    rand int                test_length;
    rand int                ITR_COUNT;
    rand bit                length_in_dw;
    rand bit  [63:0]        BAR_OFFSET ;       
    rand bit  [63:0]        ADDR;  
    string                  msgid;     

    constraint length_c {
    soft test_length  inside {[100:200]};
    }

    constraint itr_count_c {
    ITR_COUNT  inside {[10:20]};
    }

  function new(string name = "afu_mmio_flr_pf1_vf0_test_seq");
      super.new(name); 
  endfunction    
    
  task body(); 
      mmio_flr_pf_vf_seq test_seq;  
      set_response_queue_depth (50);
	  `uvm_do_on(test_seq,  tb_env0.v_sequencer);
	  `uvm_info(msgid, "Exited Fabric_lpbk test sequence", UVM_LOW);
  endtask
 
endclass : afu_mmio_flr_pf1_vf0_test_seq



class afu_mmio_flr_pf1_vf0_test extends base_test;

    rand bit[1:0] wrrd_randcode;
    rand bit[2:0] tc;
    constraint t_avmmdma {
    wrrd_randcode inside {0, 1};
    tc dist {0 := 50, [1:7] := 50};
   }

    `uvm_component_utils(afu_mmio_flr_pf1_vf0_test)
  function new(string name = "afu_mmio_flr_pf1_vf0_test", uvm_component parent=null);
      super.new(name,parent);
  endfunction : new

  virtual function void build();
      super.build();
      uvm_config_db#( bit[3:0])::set(null,"uvm_test_top.*", "PF_NUMB", 8);
  endfunction : build  

  task run_phase(uvm_phase phase);
      afu_mmio_flr_pf1_vf0_test_seq m_seq;
      super.run_phase(phase);
	  phase.raise_objection(this);
	  m_seq = afu_mmio_flr_pf1_vf0_test_seq::type_id::create("m_seq");
	  m_seq.start(tb_env0.v_sequencer);
	  phase.drop_objection(this);
  endtask : run_phase

endclass

`endif
