//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_lpbk_wr_cont_seq is executed by he_lpbk_wr_cont_test
* 
* This sequence verifies the write cont mode functionality of the HE-LPBK module  
* The sequence extends the he_lpbk_seq  
* The number of write continuous transactions is verified comparing with DSM status register
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================

`ifndef HE_LPBK_WR_CONT_SEQ_SVH
`define HE_LPBK_WR_CONT_SEQ_SVH

class he_lpbk_wr_cont_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_wr_cont_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b010; } // WR only
    constraint mode_cont { cont_mode == 1; } // cont mode 1


    function new(string name = "he_lpbk_wr_cont_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_wr_cont_seq

`endif // HE_LPBK_WR_CONT_SEQ_SVH
