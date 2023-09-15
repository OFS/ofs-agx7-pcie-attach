//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class helb_wr_1cl_seq is executed by helb_wr_1cl_test
* 
* This sequence verifies the write-mode functionality of the HE-LPBK module  
* The sequence extends the he_lpbk_seq and it is constraint for 1-cache-line write
* The number of write transactions is verified comparing with DSM status register
* Sequence is running on virtual_sequencer 
*/
//===========================================================================================================

`ifndef HELB_WR_1CL_SEQ_SVH
`define HELB_WR_1CL_SEQ_SVH

class helb_wr_1cl_seq extends he_lpbk_seq;
    `uvm_object_utils(helb_wr_1cl_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint mode_c { mode == 3'b010; } // write 
    constraint num_lines_c { num_lines == 1024; }
    constraint req_len_c { req_len == 2'b00; }
    constraint report_perf_data_c { report_perf_data == 1; }

    function new(string name = "helb_wr_1cl_seq");
        super.new(name);
    endfunction : new

endclass : helb_wr_1cl_seq

`endif // HELB_WR_1CL_SEQ_SVH
