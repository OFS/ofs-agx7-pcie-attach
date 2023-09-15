// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_WATCHDOG_TIMER_SEQ_SVH
`define CE_WATCHDOG_TIMER_SEQ_SVH

class ce_watchdog_timer_seq extends base_seq;
    `uvm_object_utils(ce_watchdog_timer_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "ce_watchdog_timer_seq");
        super.new(name);
    endfunction : new
	task body();
	bit [64:0] wdata, rdata;
	super.body();

	//Deasserting hps2host_hps_rdy_gpio
	//force tb_top.DUT.ce_inst.ce_acelite_tx_inst.hps2host_hps_rdy_gpio = 1'b0;
/*	wdata=1'b0;
	 mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata)); 
	      `uvm_info(get_name(), "checking for HPS_RDY bit to be not asserted", UVM_LOW) */

	/*if( CE_RDY_LOW_THRESHOLD >=100 )begin
	`uvm_error(get_name(), $psprintf ("ERROR:Timeout"))
	end else begin
	`uvm_info(get_name(), "", UVM_LOW) //to do

	end*/
   force tb_top.DUT.ce_top_inst.ce_csr_inst.csr_hps2host_rsp[4] = 1'b0;
#600us;

      mmio_read64(.addr_(`PF4_BAR0+'h0108), .data_(rdata));
	 if(rdata[0] == 1'b1) begin
	`uvm_info(get_name(), "Memory copy fault.This is expected", UVM_LOW)

         end else begin
	`uvm_error(get_name(), $psprintf ("ERROR "))
	end


 

endtask : body
endclass : ce_watchdog_timer_seq
`endif


