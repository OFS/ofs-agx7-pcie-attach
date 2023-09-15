//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_random_seq is executed by he_random_test
* This sequence is extended from base_seq
* This sequence perform multiple iteration on he_lpbk and he_mem modules
* Simultaniously running mmio, he_lpbk and he_mem with all the modes constraints
* Sequence is running on virtual_sequencer 
*/
//===========================================================================================================

`ifndef HE_RANDOM_SEQ_SVH
`define HE_RANDOM_SEQ_SVH

class he_random_seq extends base_seq;
    `uvm_object_utils(he_random_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    rand int loop;

    constraint loop_c { loop inside {[3:5]}; }

    function new(string name = "he_random_seq");
        super.new(name);
    endfunction : new

    task body();
        super.body();
	fork
	    he_lpbk_traffic(); // he-lpbk
	    he_mem_traffic(); // he-mem
	    background_mmio();
	join
    endtask : body

    task he_lpbk_traffic();
        he_lpbk_seq         lpbk_seq;
	for(int i = 0; i < loop; i++) begin
	    `uvm_do_on_with(lpbk_seq, p_sequencer, {
	        mode inside {3'b000, 3'b001, 3'b010, 3'b011};
		bypass_config_seq == 1;
	    })
	    //mmio_write64(.addr_(he_lb_base_addr+'h138), .data_(64'h1));
        mmio_write64(.addr_(tb_cfg0.HE_LB_BASE+'h138), .data_(64'h1));
        
        
	end
    endtask : he_lpbk_traffic

    task he_mem_traffic();
        he_mem_lpbk_seq     mem_lpbk_seq;
	for(int i = 0; i < loop; i++) begin
	    `uvm_do_on_with(mem_lpbk_seq, p_sequencer, {
	        mode inside {3'b000, 3'b001, 3'b010, 3'b011};
		bypass_config_seq == 1;
	    })
	    //mmio_write64(.addr_(he_mem_base_addr+'h138), .data_(64'h1));
        mmio_write64(.addr_(tb_cfg0.HE_MEM_BASE+'h138), .data_(64'h1));
        

	end
    endtask : he_mem_traffic

    task background_mmio();
        mmio_stress_seq mmio_seq;
	`uvm_do_on_with(mmio_seq, p_sequencer, {
	    bypass_config_seq == 1;
	})
    endtask : background_mmio

endclass : he_random_seq

`endif // HE_RANDOM_SEQ_SVH
