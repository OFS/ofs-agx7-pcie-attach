// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_INIT_SEQ_SVH
`define QSFP_INIT_SEQ_SVH

class qsfp_init_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_init_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
 
  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;
 
  function new(string name = "qsfp_init_seq");
    super.new(name);
  endfunction : new
 
  task body();
    super.body();
    
    #200ns;
    
    address  =18'h0048;
    data     =64'h0000_0000_0000_002a;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Clearing ctrl_en bit to I2C-CTRL Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h004c;
    data     =64'h0000_0000_0000_0003;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to I2C-ISER Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h0060;
    data     ='d125;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to I2C-SCLLow Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h0064;
    data     ='d125;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to I2C-SCLHigh Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h0068;
    data     ='d60;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to I2C-SDAHold Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h0048;
    data     =64'h0000_0000_0000_002b;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to I2C-CTRL Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    
  endtask : body
 
endclass : qsfp_init_seq

`endif // QSFP_INIT_SEQ_SVH






