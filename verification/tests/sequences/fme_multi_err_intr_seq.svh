//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class fme_multi_err_intr_seq is executed by fme_multi_err_intr_test 
 * 
 * This sequence verifies the functionality of the interrupt by extending the fme_intr_seq 
 * RAS and FME error is introduced from this sequence
 * Sequence is running on virtual_sequencer 
 *
 *
**/
//===============================================================================================================



`ifndef FME_MULTI_ERR_INTR_SEQ_SVH
`define FME_MULTI_ERR_INTR_SEQ_SVH

class fme_multi_err_intr_seq extends fme_intr_seq;
    `uvm_object_utils(fme_multi_err_intr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint err_type_cons{
      inj_ras_err==1;
      inj_fme_err==1;
    }

    function new(string name = "fme_multi_err_intr_seq");
        super.new(name);
    endfunction : new

endclass : fme_multi_err_intr_seq

`endif // FME_MULTI_ERR_INTR_SEQ_SVH
