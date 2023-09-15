//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_mem_wr_seq is executed by he_mem_wr_test
* 
* This sequence verifies the write-mode functionality of the HE-MEM module 
* The sequence extends the he_mem_lpbk_seq  
* The number of write transactions is verified comparing with DSM status register
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================

`ifndef HE_MEM_WR_SEQ_SVH
`define HE_MEM_WR_SEQ_SVH

class he_mem_wr_seq extends he_mem_lpbk_seq;
    `uvm_object_utils(he_mem_wr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b010; } // WR only

    function new(string name = "he_mem_wr_seq");
        super.new(name);
    endfunction : new

endclass : he_mem_wr_seq

`endif // HE_MEM_WR_SEQ_SVH
