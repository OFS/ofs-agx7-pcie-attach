// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_WRITE_RESET_SEQ_SVH
`define QSFP_WRITE_RESET_SEQ_SVH

class qsfp_write_reset_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_write_reset_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)

  logic [17:0] address;
  logic [63:0] data, exp_data;
  logic [7:0]  wstrb;
  rand bit wr;

  qsfp_axi_derived_write_sequence wr_trans;

  function new(string name = "qsfp_write_reset_seq");
        super.new(name);
  endfunction : new

  task body();
    super.body();
 
    `uvm_info(get_name(), $psprintf("qsfp_write_reset_sequence START"), UVM_LOW)
 
    `uvm_info(get_name(), $psprintf("Writting to QSFP Module Registry"), UVM_LOW)
       
    if(wr) begin
      #200ns; 
      for (int i='h000;i<='h15;i=i+'h4) begin
        
        address  =18'h0040;
        data     =64'h02a0;
        wstrb    =8'hFF;
        `uvm_info(get_name(), $psprintf("Writting to I2C Register"), UVM_LOW)
        wr_tx_register(address,data,wstrb);
       
        address  =18'h0040;
        data     =i;
        wstrb    =8'hFF;
        `uvm_info(get_name(), $psprintf("Writting to I2C Register"), UVM_LOW)
        wr_tx_register(address,data,wstrb);
        
        address  =18'h0040;
        data     =64'h013;
        wstrb    =8'hFF;
        `uvm_info(get_name(), $psprintf("Writting to I2C Register"), UVM_LOW)
        wr_tx_register(address,data,wstrb);
        
        address  =18'h0040;
        data     =64'h014;
        wstrb    =8'hFF;
        `uvm_info(get_name(), $psprintf("Writting to I2C Register"), UVM_LOW)
        wr_tx_register(address,data,wstrb);
        
        address  =18'h0040;
        data     =64'h015;
        wstrb    =8'hFF;
        `uvm_info(get_name(), $psprintf("Writting to I2C Register"), UVM_LOW)
        wr_tx_register(address,data,wstrb);
        
        address  =18'h0040;
        data     =64'h116; //stop condition for i2c txn - msb bits should be "01"
        wstrb    =8'hFF;
        `uvm_info(get_name(), $psprintf("Writting to I2C Register"), UVM_LOW)
        wr_tx_register(address,data,wstrb);
      end

    end
    
    else begin
      
    //It takes just above 100ms (with default csr value) to complete one iteration of poller_fsm operation (i.e lower,upper page00,upper page02,upper page03,upper page20,upper page 21).
      #103ms;
    //Initiating read requests after the delay  
      address  =18'h0100;
      exp_data=64'h1514_1312_1514_1312;
      `uvm_info(get_name(), $psprintf("Reading from QSFP Module Register"), UVM_LOW)
      rd_tx_register(address,exp_data);
    
    end

  endtask:body

endclass:qsfp_write_reset_seq

`endif       // QSFP_WRITE_RESET_SEQ_SVH
