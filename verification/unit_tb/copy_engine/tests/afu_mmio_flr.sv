// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

///////////////////////////////////////////////////////////////////////////////////////////////
// Description:
//     fabric  Multi cacheline 138 B RCB - lpbk tests across pcie
//
// Author: Shalini Asopa  
// Date:   
//
// $Id: 
////////////////////////////////////////////////////////////////////////////////////////////////


`ifndef AFU_MMIO_FLR_SV
`define AFU_MMIO_FLR_SV

`include "base_test.svh"
`include "seq_lib.svh"



///////////////////////////////////////////////////////////////////////////////////
// test sequence
///////////////////////////////////////////////////////////////////////////////////

class afu_mmio_flr_test_seq extends base_seq;
//class afu_mmio_flr_seq extends uvm_sequence;
rand int                test_length;
rand int                ITR_COUNT;
rand bit                length_in_dw;
rand bit  [63:0]        BAR_OFFSET ;       
rand bit  [63:0]        ADDR;  
string                  msgid;     
/rand `PCIE_DRIVER_TRANSACTION_CLASS::transaction_type_enum  pcie_trans_type;
`PCIE_DEV_CFG_CLASS cfg;

constraint length_c {
    //cache_length != CL_192;     
    soft test_length  inside {[100:200]};
//  test_length == 10;
 //fff   soft cache_length == CL_256;  
}

constraint itr_count_c {
    ITR_COUNT  inside {[10:20]};
}


    `uvm_object_utils(afu_mmio_flr_test_seq)


    function new(string name = "afu_mmio_flr_test_seq");
        super.new(name); 
    endfunction    
    
    virtual task body(); 
      mmio_flr_seq test_seq;  

      super.body();
       set_response_queue_depth (50);
		`uvm_do_on(test_seq,  tb_env0.v_sequencer);
  
		`uvm_info(msgid, "Exited Fabric_lpbk test sequence", UVM_LOW);
    endtask
      


	
	
    
endclass : afu_mmio_flr_test_seq 



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test - set configs for all sequencers used in this test
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class afu_mmio_flr extends base_test;

    rand bit[1:0] wrrd_randcode;
     rand bit[2:0] tc;
     constraint t_avmmdma {
      wrrd_randcode inside {0, 1};
      tc dist {0 := 50, [1:7] := 50};
   }


    constraint vf_c {
//      tb_cfg0.use_afu_vf_access == 1;
    }

    `uvm_component_utils(afu_mmio_flr)

    function new(string name = "afu_mmio_flr", uvm_component parent=null);
        super.new(name,parent);
    endfunction : new

 task run_phase(uvm_phase phase);
        afu_mmio_flr_test_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
	m_seq = afu_mmio_flr_test_seq::type_id::create("m_seq");
	m_seq.start(tb_env0.v_sequencer);
	phase.drop_objection(this);
    endtask : run_phase
       
        

endclass

`endif

