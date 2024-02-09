//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class config_seq is executed from base sequence
 * 
 * This sequence initates the PCIE_VIP link-up sequence and enumeration sequence
 * Once enumeraion is done it generates the soft_reset
 *
 * Sequence is running on virtual_sequencer 
 *
 */
//===============================================================================================================


`ifndef CONFIG_SEQ_SVH
`define CONFIG_SEQ_SVH

class config_seq extends uvm_sequence;
    `uvm_object_utils(config_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    tb_config          tb_cfg0;
    pcie_device_bring_up_link_sequence bring_up_link_seq;
    enumerate_seq                      enumerate_seq;
    bit [2:0]                          tc;

    function new(string name = "config_seq");
        super.new(name);
    endfunction : new

    task body();
        bit status;
        super.body();
	`uvm_info(get_name(), "Entering config sequence", UVM_LOW)
	// linkup
	`uvm_info(get_name(), "Linking up...", UVM_LOW)
	`uvm_do_on(bring_up_link_seq, p_sequencer.root_virt_seqr)
	`uvm_info(get_name(), "Link is up now", UVM_LOW)
	// enumerating PCIe HIP
	`uvm_info(get_name(), "Enumerating...", UVM_LOW)
	`uvm_do_on_with(enumerate_seq, p_sequencer.root_virt_seqr.driver_transaction_seqr[0],{
          pf0_bar0     == tb_cfg0.PF0_BAR0;  
          pf0_bar4     == tb_cfg0.PF0_BAR4;  
          pf1_bar0     == tb_cfg0.PF1_BAR0;
          pf2_bar0     == tb_cfg0.PF2_BAR0;
          pf2_bar4     == tb_cfg0.PF2_BAR4;
          pf3_bar0     == tb_cfg0.PF3_BAR0;
          pf4_bar0     == tb_cfg0.PF4_BAR0;
          pf0_expansion_rom_bar == tb_cfg0.PF0_EXP_ROM_BAR0;
          pf0_vf0_bar0 == tb_cfg0.PF0_VF0_BAR0;
          pf0_vf0_bar4 == tb_cfg0.PF0_VF0_BAR4;
          pf0_vf1_bar0 == tb_cfg0.PF0_VF1_BAR0;
          pf0_vf2_bar0 == tb_cfg0.PF0_VF2_BAR0;
          pf1_vf0_bar0 == tb_cfg0.PF1_VF0_BAR0;
	`ifdef FIM_B     
          pf0_vf3_bar0 == tb_cfg0.PF0_VF3_BAR0;
	`endif											      
         })
         enumerate_seq.print();
	`uvm_info(get_name(), "Enumeration is done", UVM_LOW)

	status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "tc", tc);
	tc = (status) ? tc : 0;


	`uvm_info(get_name(), "Exiting config sequence", UVM_LOW)
    endtask : body

   
    function [31:0] changeEndian;   //transform data from the memory to big-endian form
        input [31:0] value;
        changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
    endfunction

endclass : config_seq

`endif // CONFIG_SEQ_SVH
