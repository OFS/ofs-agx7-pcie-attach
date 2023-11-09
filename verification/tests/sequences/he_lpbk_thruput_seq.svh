//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_lpbk_thruput_seq is executed by he_lpbk_thruput_test
* 
* This sequence verifies the thruput functionality of the HE-LPBK module  
* The sequence extends the he_lpbk_seq  
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================


`ifndef HE_LPBK_THRUPUT_SEQ_SVH
`define HE_LPBK_THRUPUT_SEQ_SVH

class he_lpbk_thruput_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_thruput_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b011; } // Thruput only

    function new(string name = "he_lpbk_thruput_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_thruput_seq

`endif // HE_LPBK_THRUPUT_SEQ_SVH
