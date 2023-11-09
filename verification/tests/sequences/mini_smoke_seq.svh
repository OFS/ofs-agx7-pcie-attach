//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class mini_smoke_seq is executed by mini_smoke_test
* This sequence is extended from base_seq
* This sequence perform multiple iteration on he_lpbk and he_mem modules
* Simultaniously running mmio, he_lpbk and he_mem with  mode constraints
* Sequence is running on virtual_sequencer 
*/
//===========================================================================================================
`ifndef MINI_SMOKE_SEQ_SVH
`define MINI_SMOKE_SEQ_SVH

class mini_smoke_seq extends base_seq;
    `uvm_object_utils(mini_smoke_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "mini_smoke_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] src_addr, dst_addr, dsm_addr;
        super.body();
	//src_addr = alloc_mem(1024);
	//dst_addr = alloc_mem(1024);
	//dsm_addr = alloc_mem(1);
	//$display("Yang src = %0h dst = %0h dsm = %0h", src_addr, dst_addr, dsm_addr);
	
	fork
	    he_lpbk_traffic(); // he-lpbk
	    he_mem_traffic(); // he-mem
	    background_mmio();
	join
    endtask : body

    task he_lpbk_traffic();
        he_lpbk_seq         helb_seq;
	`uvm_do_on_with(helb_seq, p_sequencer, {
	    mode == 3'b000;
	    bypass_config_seq == 1;
	    num_lines == 32;
	    req_len == 2'b00;
	})
    endtask : he_lpbk_traffic

    task he_mem_traffic();
        he_mem_lpbk_seq     hemem_seq;
	`uvm_do_on_with(hemem_seq, p_sequencer, {
	    mode == 3'b000;
	    bypass_config_seq == 1;
	    num_lines == 32;
	    req_len == 2'b10;
	})
    endtask : he_mem_traffic

    task background_mmio();
        mmio_seq mmio_seq;
	`uvm_do_on_with(mmio_seq, p_sequencer, {
	    bypass_config_seq == 1;
	})
    endtask : background_mmio

endclass : mini_smoke_seq

`endif // MINI_SMOKE_SEQ_SVH
