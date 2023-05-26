//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class fme_err_intr_seq is executed by fme_err_intr_test 
 * 
 * This sequence verifies the functionality of the interrputs by extending the fme_intr_seq 
 * FME error is introduced from this sequence
 * Sequence is running on virtual_sequencer 
 *
 *
**/
//==============================================================================================================


`ifndef FME_ERR_INTR_SEQ_SVH
`define FME_ERR_INTR_SEQ_SVH

class fme_err_intr_seq extends fme_intr_seq;
    `uvm_object_utils(fme_err_intr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint err_type_cons{
      inj_ras_err==0;
      inj_fme_err==1;
    }

    function new(string name = "fme_err_intr_seq");
        super.new(name);
    endfunction : new

endclass : fme_err_intr_seq

`endif // FME_ERR_INTR_SEQ_SVH
