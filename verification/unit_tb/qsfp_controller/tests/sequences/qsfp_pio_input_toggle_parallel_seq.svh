// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_PIO_INPUT_TOGGLE_PARALLEL_SEQ_SVH
`define QSFP_PIO_INPUT_TOGGLE_PARALLEL_SEQ_SVH

class qsfp_pio_input_toggle_parallel_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_pio_input_toggle_parallel_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
  logic [17:0] address;
  logic [63:0] data,exp_data;


  function new(string name = "qsfp_pio_input_toggle_parallel_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();
 
   `uvm_info(get_name(), $psprintf("qsfp_pio_input_toggle_parallel_test START"), UVM_LOW)
   `uvm_info(get_name(), $psprintf("Driving modprsl and int_qsfp to 1"), UVM_LOW)
 
   qsfp_if.modprsl=1;
   qsfp_if.int_qsfp=1;
 
   address = 18'h0028;
   exp_data =64'h0000_00e3;
   `uvm_info(get_name(), $psprintf("Reading from Status Register Address for modPRSL 0x028"), UVM_LOW)
   rd_tx_register(address,exp_data);
 
   if ( exp_data[0] == 1'b1 && exp_data[1] == 1'b1)
       `uvm_info(get_name(),$psprintf("MODPRSL and INT_QSFP READ SUCCESSFUL"),UVM_LOW)
   else
       `uvm_error("PIO_ERROR","PIO_INPUT READ FAILED")
   
   `uvm_info(get_name(), $psprintf("Driving modprsl and int_qsfp to 0"), UVM_LOW)
   qsfp_if.modprsl=0;
   qsfp_if.int_qsfp=0;
 
   `uvm_info(get_name(), $psprintf("Reading from Status Register Address for int_qsfp 0x028"), UVM_LOW)
    address = 18'h0028;
    exp_data = 64'h0000_00e0;
    rd_tx_register ( address,exp_data);
 
    if ( exp_data[0] == 1'b0 && exp_data[1] == 1'b0)
        `uvm_info(get_name(),$psprintf("MODPRSL and INT_QSFP CLEARED SUCCESSFUL"),UVM_LOW)
    else
        `uvm_error("PIO_ERROR","PIO_INPUT READ FAILED")
 
  endtask : body

 endclass : qsfp_pio_input_toggle_parallel_seq

`endif // QSFP_PIO_INPUT_TOGGLE_PARALLEL_SEQ_SVH

