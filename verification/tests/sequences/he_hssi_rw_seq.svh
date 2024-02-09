//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class he_hssi_rw_seq is executed by afu_stress_seq
 * 
 * The sequence  uses mmio_read/write tasks for 32/64bit access  defined in base_sequence
 *
 * Sequence is running on virtual_sequencer
 */
//===============================================================================================================

`ifndef HE_HSSI_RW_SEQ_SVH
`define HE_HSSI_RW_SEQ_SVH

class he_hssi_rw_seq extends base_seq;
    `uvm_object_utils(he_hssi_rw_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "he_hssi_rw_seq");
       super.new(name);
    endfunction : new

   task body();
     bit [63:0]  wdata, rdata, mask, addr, exp_data;     
     
     super.body();
    
    mask = 64'h0000ffff00000003 ;
    wdata =   64'hffffffffffffffff & mask;
    addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR +'h30;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    if(wdata !== rdata)
    `uvm_error(get_name(), $psprintf("TRAFFIC_CTRL_CMD Data mismatch 32!addr = %0h, exp_data = %0h, rdata = %0h",addr, wdata, rdata))
    else
    `uvm_info(get_name(), $psprintf("TRAFFIC_CTRL_CMD Data match 32! addr = %0h,exp_data = %0h, rdata = %0h",addr,wdata, rdata), UVM_LOW)

    mask =  64'hffffffff00000000;
    wdata =   64'hffff_ffff_ffff_ffff & mask; 
    addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR +'h38;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64(.addr_(addr), .data_(rdata));
    if(wdata !== rdata )
    `uvm_error(get_name(), $psprintf("TRAFFIC_CTRL_DATA Data mismatch 32!addr = %0h, exp_data = %0h, rdata = %0h",addr, wdata, rdata))
    else
    `uvm_info(get_name(), $psprintf("TRAFFIC_CTRL_DATA Data match 32! addr = %0h,exp_data = %0h, rdata = %0h",addr,wdata, rdata), UVM_LOW)
    
    mask = 64'h000000000000000f ;
    wdata =   64'hffff_ffff_ffff_ffff & mask; 
    addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR +'h40;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    if(wdata  !== rdata )
    `uvm_error(get_name(), $psprintf("TRAFFIC_CTRL_CH_SEL Data mismatch 32!addr = %0h, exp_data = %0h, rdata = %0h",addr, wdata, rdata))
    else
   `uvm_info(get_name(), $psprintf("TRAFFIC_CTRL_CH_SEL Data match 32! addr = %0h,exp_data = %0h, rdata = %0h",addr,wdata, rdata), UVM_LOW)

    mask = 64'hffff_ffff_ffff_ffff;
    wdata =   64'hffff_ffff_ffff_ffff & mask;    
    addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR +'h48;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    if( wdata !== rdata )
    `uvm_error(get_name(), $psprintf("AFU_SCRATCHPAD Data mismatch 32!addr = %0h, exp_data = %0h, rdata = %0h",addr, wdata, rdata))
    else
   `uvm_info(get_name(), $psprintf("AFU_SCRATCHPAD Data match 32! addr = %0h, exp_data = %0h, rdata = %0h",addr,wdata, rdata), UVM_LOW)

                    
    endtask : body
endclass: he_hssi_rw_seq
`endif
