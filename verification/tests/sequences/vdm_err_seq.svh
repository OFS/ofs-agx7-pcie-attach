//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class vdm_err_seq is executed by vdm_err_test 
 * 
 * This sequence generates the VDM_ERR MSG and sends the PKTs to PMCI
 * The error msg is generated using vdm_err_msg task ,which corrupts the VENDOR_ID Field
 * Sequence is running on virtual_sequencer 
 *
 */
//===============================================================================================================

`ifndef VDM_ERR_SEQ_SVH
`define VDM_ERR_SEQ_SVH

class vdm_err_seq extends base_seq;
    `uvm_object_utils(vdm_err_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "vdm_err_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] length;
        super.body();
        `uvm_info(get_name(), "Entering vdm_err_seq...", UVM_LOW)
        vdm_err_msg(.length_(16));
        #2000ns; 
       `uvm_info(get_name(), "Exiting vdm_err_seq...", UVM_LOW)

    endtask : body

endclass : vdm_err_seq

`endif // VDM_ERR_SEQ_SVH
