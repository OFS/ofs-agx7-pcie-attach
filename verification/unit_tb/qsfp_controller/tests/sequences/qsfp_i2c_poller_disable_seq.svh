// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_I2C_POLLER_DISABLE_SEQ_SVH
`define QSFP_I2C_POLLER_DISABLE_SEQ_SVH


class qsfp_i2c_poller_disable_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_i2c_poller_disable_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)

  logic [17:0] address;
  logic [63:0] exp_data, data;
  logic [7:0]  wstrb;
  

  function new(string name = "qsfp_poller_rst_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    `uvm_info(get_name(), $psprintf("qsfp_i2c_poller_disable_test START"), UVM_LOW)
    #500000ns;
    address  =18'h0028;
    exp_data =64'h0000_0000_0080_03e4;     ///fsm_paused 1
   `uvm_info(get_name(), $psprintf("Reading from Status Register to check for fsm_paused"), UVM_LOW)
    rd_tx_register(address,exp_data);


    #20ns;

          
  endtask : body

endclass : qsfp_i2c_poller_disable_seq

`endif
