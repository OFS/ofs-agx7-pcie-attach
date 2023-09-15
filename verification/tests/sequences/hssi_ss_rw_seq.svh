//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class hssi_ss_rw_seq is executed by afu_stress_seq
* The sequence extend the base_seq
*
* This sequence uses the RAL model for front-door access of registers 
* The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
* 
* Sequence is running on virtual_sequencer
*  
* */
//===============================================================================================================

`ifndef HSSI_SS_RW_SEQ_SVH
`define HSSI_SS_RW_SEQ_SVH

class  hssi_ss_rw_seq extends base_seq;     
 `uvm_object_utils(hssi_ss_rw_seq)
 `uvm_declare_p_sequencer(virtual_sequencer)

 function new(string name = "hssi_ss_rw_seq");
  super.new(name);
 endfunction : new

  task body();

   bit [63:0]   wdata, rdata, mask, addr;     
   bit[63:0] expdata;
        	 
   super.body();
    
  `uvm_info(get_name(), "Entering hssi_ss_rw_seq...", UVM_LOW)
		
    wdata =   64'hdead_beef;
    addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR +'hac;
    mmio_write32(.addr_(addr), .data_(wdata));
    mmio_read32 (.addr_(addr), .data_(rdata));
    if(wdata[31:0] !== rdata[31:0])
    `uvm_error(get_name(), $psprintf(" HSSI_CNTL_ADDR Data mismatch 32!addr = %0h, Exp = %0h, Act = %0h",addr, wdata, rdata))
     else
    `uvm_info(get_name(), $psprintf(" HSSI_CNTL_ADDR Data match 32! addr = %0h,EXP = %0h, data = %0h",addr,wdata, rdata), UVM_LOW)
								
    mask = 64'h00000002;
    wdata =   64'hdead_beef & mask;
    addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h100;
    mmio_write32(.addr_(addr), .data_(wdata));
    mmio_read32 (.addr_(addr), .data_(rdata));
 
   if(wdata[31:0] !== rdata[31:0])
   `uvm_error(get_name(), $psprintf(" HSSI_TSE_CTRL  Data mismatch 32!addr = %0h, Exp = %0h, Act = %0h",addr, wdata, rdata))
   else
    `uvm_info(get_name(), $psprintf("  HSSI_TSE_CTRL Data match 32! addr = %0h,Exp = %0h,data = %0h",addr, wdata, rdata), UVM_LOW)


   wdata = 64'hdeadbeefdeadbeef;
   addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h820;
   mmio_write64(.addr_(addr), .data_(wdata));
   mmio_read64 (.addr_(addr), .data_(rdata));
   if(wdata !== rdata)
    `uvm_error(get_name(), $psprintf("HSSI_SCRATCHPAD Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
   else
   `uvm_info(get_name(), $psprintf(" HSSI_SCRATCHPAD Data match 64! addr = %0h, exp = %0h, data = %0h", addr, wdata, rdata), UVM_LOW)

   endtask : body
endclass : hssi_ss_rw_seq 

`endif // HSSI_SS_RW_SEQ_SVH


