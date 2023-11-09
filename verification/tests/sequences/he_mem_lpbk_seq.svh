//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_mem_lpbk_seq is executed by he_mem_lpbk_test
* 
* This sequence verifies when he_mem is set to 1 and DDR4 is included ,transcation will loopback through DDR memory   
* The sequence extends the he_lpbk_seq   
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================

`ifndef HE_MEM_LPBK_SEQ_SVH
`define HE_MEM_LPBK_SEQ_SVH

class he_mem_lpbk_seq extends he_lpbk_seq;
    `uvm_object_utils(he_mem_lpbk_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint he_mem_c { he_mem == 1; }

    function new(string name = "he_mem_lpbk_seq");
        super.new(name);
    endfunction : new

endclass : he_mem_lpbk_seq

`endif // HE_MEM_LPBK_SEQ_SVH
