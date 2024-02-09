//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class 32b_bar_seq is executed by 32b_bar_test
* Sequence is running on virtual_sequencer
* mmio sequence is executed by configuring 32bit BAR address 
* */
//===============================================================================================================

//`ifndef BAR_32B_SEQ_SVH
//`define BAR_32B_SEQ_SVH

class bar_32b_seq extends base_seq;
    `uvm_object_utils(bar_32b_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "bar_32b_seq");
        super.new(name);
    endfunction : new

    task body();
     `uvm_info(get_name(), "Entering 32b_bar_seq...", UVM_LOW)
      super.body();
      mmio_seq_task();
    endtask : body

   task mmio_seq_task();
   mmio_seq mmio_seq_;
   `uvm_do_on_with(mmio_seq_, p_sequencer, {
	    bypass_config_seq == 1;
       })
    endtask : mmio_seq_task

endclass : bar_32b_seq

//`endif // BAR_32B_SEQ_SVH
