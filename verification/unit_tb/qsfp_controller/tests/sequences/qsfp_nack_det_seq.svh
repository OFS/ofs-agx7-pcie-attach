// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_NACK_DET_SEQ_SVH
`define QSFP_NACK_DET_SEQ_SVH

class qsfp_nack_det_seq extends qsfp_base_seq;

  `uvm_object_utils(qsfp_nack_det_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
 
  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;
 
  function new(string name = "qsfp_read_write_b2b_seq");
      super.new(name);
  endfunction : new
 
  task body();
    super.body();
 
    `uvm_info(get_name(), $psprintf("Writing values to QSFPModule Registers"), UVM_LOW)
    #1000ns;
    //-------Start Writing to Lower Pg00--------------//
    for(int i='h0;i<'h30;i=i+'h4)
    begin

      address  =18'h0040;
      data     =64'h0210;
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Starting I2C Transfer with wrong BFM address to generate nack_det condition"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =i; //address bit of QSFP Module
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Writing address of QSFPM register"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
  
      address  =18'h0040;
      data     =8'(i); // Data byte of QSFPModule
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Writing first data byte to the QSFPM register address"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =8'(i+1);
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Writing second data byte to the QSFPM register address"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =8'(i+2);
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Writing  third data byte to QSFPM Register address"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     ={2'(1),8'(i+3)}; //stop condition for i2c txn - msb bits should be "01"
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Writing fourth data byte to QSFPM Register address together with Stop I2C Transfer command"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
    
    end
      
    address  =18'h0050;
    exp_data = 'h5;//Checking for both nack_det and tx_ready interrupt
    `uvm_info(get_name(), $psprintf("Read from nack_det bit of ISR"), UVM_LOW)
    rd_rand_tx_register(address,exp_data);

    if( exp_data[2] == 1'b1) 
      `uvm_info(get_name(), $psprintf("nack_det bit is asserted"), UVM_LOW)
    else
      `uvm_error("NACK_BIT ERROR", "nack_det bit is not set")
    
    if( exp_data[0] == 1'b1) 
      `uvm_info(get_name(), $psprintf("tx_ready bit is asserted"), UVM_LOW)
    else
      `uvm_error("TX_READY_BIT ERROR", "tx_ready is not set")

  endtask : body

endclass : qsfp_nack_det_seq

`endif      //  QSFP_NACK_DET_SEQ_SVH


