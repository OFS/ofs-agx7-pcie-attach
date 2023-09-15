//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_mem_thruput_contmode_directed_seq is executed by he_mem_thruput_contmode_directed_seq_test
* 
* This sequence verifies the thruputcontinuous functionality of the HE-MEM module  
* The sequence extends the he_mem_lpbk_seq     
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================
`ifndef HE_MEM_THRUPUT_CONTMODE_DIRECTED_SEQ_SVH
`define HE_MEM_THRUPUT_CONTMODE_DIRECTED_SEQ_SVH


class he_mem_thruput_contmode_directed_seq extends he_mem_lpbk_seq;
    `uvm_object_utils(he_mem_thruput_contmode_directed_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b011; } // Thruput only
    
    constraint cont_mode_c {
        cont_mode == 1;
    }                                     //Continuous Mode enabled


   constraint req_len_c  { 	req_len  == 2'b01; } 
      constraint num_lines_c  { num_lines  == 40; } 
      constraint tput_interleave_c {  tput_interleave == 3'b000; } 


    function new(string name = "he_mem_thruput_contmode_directed_seq");
        super.new(name);
    endfunction : new

endclass : he_mem_thruput_contmode_directed_seq

`endif // HE_MEM_THRUPUT_CONTMODE_DIRECTED_SEQ_SVH
