//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_lpbk_long_rst_seq is executed by he_lpbk_long_rst_test
* The sequence extends base_sequence  
* This sequences perform multiple iteration of he_lpbk.Once the transcations is completed ,reset is asserted/deasstered  by writing to the config register and again he_lpbk is restarted 
* Sequence is running on virtual_sequencer 
*/
//===========================================================================================================

`ifndef HE_LPBK_LONG_RST_SEQ_SVH
`define HE_LPBK_LONG_RST_SEQ_SVH

class he_lpbk_long_rst_seq extends base_seq;
    `uvm_object_utils(he_lpbk_long_rst_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    he_lpbk_seq lpbk_seq;
    rand int loop;

    constraint loop_c { loop inside {[10:20]}; }

    function new(string name = "he_lpbk_long_rst_seq");
        super.new(name);
    endfunction : new

    task body();
        super.body();
	for(int i = 0; i < loop; i++) begin
	    `uvm_do_on_with(lpbk_seq, p_sequencer, {
	        mode inside {3'b000, 3'b001, 3'b010, 3'b011};
		bypass_config_seq == 1;                  
	    })
	    mmio_write64(.addr_(tb_cfg0.HE_LB_BASE+'h138), .data_(64'h0));
	    #100ns;
	    mmio_write64(.addr_(tb_cfg0.HE_LB_BASE+'h138), .data_(64'h1));
	end
    endtask : body

endclass : he_lpbk_long_rst_seq

`endif // HE_LPBK_LONG_RST_SEQ_SVH
