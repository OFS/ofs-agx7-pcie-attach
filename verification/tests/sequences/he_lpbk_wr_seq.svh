//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_lpbk_wr_seq is executed by he_lpbk_wr_test
* This sequence verifies the write functionality of the HE-LPBK module  
* The sequence extends the he_lpbk_seq  
* The number of write transactions is verified comparing with DSM status register
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================

`ifndef HE_LPBK_WR_SEQ_SVH
`define HE_LPBK_WR_SEQ_SVH

class he_lpbk_wr_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_wr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b010; } // WR only

    function new(string name = "he_lpbk_wr_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_wr_seq

`endif // HE_LPBK_WR_SEQ_SVH
