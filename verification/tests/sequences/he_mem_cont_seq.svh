//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_mem_cont_seq is executed by he_mem_cont_test
* 
* The sequence extends from he_mem_lpbk_seq  
* This sequences perform continuous functionality of he_mem module 
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================

`ifndef HE_MEM_CONT_SEQ_SVH
`define HE_MEM_CONT_SEQ_SVH


class he_mem_cont_seq extends he_mem_lpbk_seq;
    `uvm_object_utils(he_mem_cont_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint cont_mode_c {
        cont_mode == 1;
    }

    constraint num_lines_c {
        num_lines inside {[1:16]};
	if(mode != 3'b011) {
	    (num_lines % (2**req_len)) == 0;
	    (num_lines / (2**req_len)) >  0;
	}
	else {
	    num_lines % 2 == 0;
	    ((num_lines/2) % (2**req_len)) == 0;
	    ((num_lines/2) / (2**req_len)) >  0;
	}
	solve mode before num_lines;
	solve req_len before num_lines;
    }
    
    constraint cont_mode_dly_c {cont_mode_dly == 18000;}

    function new(string name = "he_mem_cont_seq");
        super.new(name);
    endfunction : new

endclass : he_mem_cont_seq

`endif // HE_MEM_CONT_SEQ_SVH

