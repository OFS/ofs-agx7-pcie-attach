//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_lpbk_reqlen1_seq is executed by he_lpbk_reqlen1_test
* 
* The sequence extends the he_lpbk_seq and it is constraint for req_len 1 
* This sequence verifies loopback functionality of req_len 1 
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================
`ifndef HE_LPBK_REQLEN1_SEQ_SVH
`define HE_LPBK_REQLEN1_SEQ_SVH

class he_lpbk_reqlen1_seq extends he_lpbk_seq;
    `uvm_object_utils(he_lpbk_reqlen1_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint req_len_c   { req_len == 2'b00; }
    constraint num_lines_c { num_lines == 1024; }

    function new(string name = "he_lpbk_reqlen1_seq");
        super.new(name);
    endfunction : new

endclass : he_lpbk_reqlen1_seq

`endif // HE_LPBK_REQLEN1_SEQ_SVH
