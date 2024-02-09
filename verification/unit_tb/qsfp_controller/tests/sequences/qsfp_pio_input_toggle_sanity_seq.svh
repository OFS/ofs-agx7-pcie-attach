// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_PIO_INPUT_TOGGLE_SANITY_SEQ_SVH
`define QSFP_PIO_INPUT_TOGGLE_SANITY_SEQ_SVH

class qsfp_pio_input_toggle_sanity_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_pio_input_toggle_sanity_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstb;
 
 
  function new(string name = "qsfp_pio_input_toggle_sanity_seq");
    super.new(name);
  endfunction : new
 
  task body();
    super.body();
    `uvm_info(get_name(), $psprintf("qsfp_pio_input_toggle_sanity_test START"), UVM_LOW)
    `uvm_info(get_name(), $psprintf("Driving modPRSL pin to 1"), UVM_LOW)
    qsfp_if.modprsl  = 1'b1;
    qsfp_if.int_qsfp = 1'b0;
  
    address = 18'h0028;
    exp_data =64'h0000_00e1;
    `uvm_info(get_name(), $psprintf("Reading from Status Register Address for modPRSL 0x028"), UVM_LOW)
    rd_tx_register(address,exp_data);
    
    if ( exp_data[0] == 1'b1)
        `uvm_info(get_name(),$psprintf("MODPRSL READ SUCCESSFUL"),UVM_LOW)
    else
        `uvm_error("PIO_ERROR","PIO_INPUT:MODPRSL READ FAILED")
   
    `uvm_info(get_name(), $psprintf("Driving int_qsfp pin to 1"), UVM_LOW)
    qsfp_if.int_qsfp = 1'b1;
   `uvm_info(get_name(), $psprintf("Reading from Status Register Address for int_qsfp 0x028"), UVM_LOW)
    address = 18'h0028;
    exp_data = 64'h0000_00e3;
    rd_tx_register ( address,exp_data);
    
    if ( exp_data[0] == 1'b1)
        `uvm_info(get_name(),$psprintf("INT_QSFP READ SUCCESSFUL"),UVM_LOW)
    else
        `uvm_error("PIO_ERROR","PIO_INPUT:INT_QSFP READ FAILED")
    
    `uvm_info(get_name(), $psprintf("Driving modPRSL pin to 0"), UVM_LOW)
    qsfp_if.modprsl = 1'b0;
    address = 18'h0028;
    exp_data =64'h0000_00e2;
    `uvm_info(get_name(), $psprintf("Reading from Status Register Address for modPRSL 0x028"), UVM_LOW)
    rd_tx_register(address,exp_data);

    if ( exp_data[0] == 1'b0)
        `uvm_info(get_name(),$psprintf("MODPRSL CLEARED SUCCESSFUL"),UVM_LOW)
    else
        `uvm_error("PIO_ERROR","PIO_INPUT:MODPRSL READ FAILED")
    
    `uvm_info(get_name(), $psprintf("Driving int_qsfp pin to 0"), UVM_LOW)
    qsfp_if.int_qsfp = 1'b0;
   `uvm_info(get_name(), $psprintf("Reading from Status Register Address for int_qsfp 0x028"), UVM_LOW)
    address = 18'h0028;
    exp_data = 64'h0000_00e0;
    rd_tx_register ( address,exp_data);
    
    if ( exp_data[1] == 1'b0)
        `uvm_info(get_name(),$psprintf("INT_QSFP CLEARED SUCCESSFUL"),UVM_LOW)
    else
        `uvm_error("PIO_ERROR","PIO_INPUT:INT_QSFP READ FAILED")
  
  endtask : body
 
 endclass : qsfp_pio_input_toggle_sanity_seq

`endif // QSFP_PIO_OUTPUT_TOGGLE_SANITY_SEQ_SVH

