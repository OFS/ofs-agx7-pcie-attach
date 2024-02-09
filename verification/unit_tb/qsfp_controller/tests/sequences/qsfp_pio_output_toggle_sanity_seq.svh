// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_PIO_OUTPUT_TOGGLE_SANITY_SEQ_SVH
`define QSFP_PIO_OUTPUT_TOGGLE_SANITY_SEQ_SVH

class qsfp_pio_output_toggle_sanity_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_pio_output_toggle_sanity_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;


  function new(string name = "qsfp_pio_output_toggle_sanity_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();
    `uvm_info(get_name(), $psprintf("Writing to I2C Config Register to set SoftResetQSFPM = 1 "), UVM_LOW)

    address = 18'h0020;
    data    = 64'h0000_0001;
    wstrb   = 8'hFF;
    wr_tx_register(address,data,wstrb);
  
    //Check the SoftresetQSFPM signal is asserted on QSFP interface
    if (qsfp_if.softresetqsfm == 1)
      `uvm_info(get_name(),$psprintf("ALL the PIO-SOFTRESET pins are set"),UVM_LOW)
    else
      `uvm_error("PIO_ERROR","PIO PINS ARE NOT SET---ERROR")
    

    `uvm_info(get_name(), $psprintf("Writing to I2C Config Register to set ModSel=1 "), UVM_LOW)
    address = 18'h0020;
    data    = 64'h0000_0005;
    wstrb   = 8'hFF;
    wr_tx_register(address,data,wstrb);
    
    if (qsfp_if.modsel == 1)
      `uvm_info(get_name(),$psprintf("ALL the PIO-MODSEL pins are set"),UVM_LOW)
    else
      `uvm_error("PIO_ERROR","PIO PINS ARE NOT SET---ERROR")
  


    `uvm_info(get_name(), $psprintf("Writing to I2C Config Register to set LPMode=1 "), UVM_LOW)
    address = 18'h0020;
    data    = 64'h0000_000D;
    wstrb   = 8'hFF;
    wr_tx_register(address,data,wstrb);
    
    if (qsfp_if.lpmode == 1)
      `uvm_info(get_name(),$psprintf("ALL the PIO-LPMODE pins are set"),UVM_LOW)
    else
      `uvm_error("PIO_ERROR","PIO PINS ARE NOT SET---ERROR")
  

    `uvm_info(get_name(), $psprintf("Writing to I2C Config Register to set SoftResetQSFPM = 0 "), UVM_LOW)
    address = 18'h0020;
    data    = 64'h0000_000C;
    wstrb   = 8'hFF;
    wr_tx_register(address,data,wstrb);
  
    if (qsfp_if.softresetqsfm == 0 )
      `uvm_info(get_name(),$psprintf(" PIO-SOFTRESET pins are CLEARED"),UVM_LOW)
    else
      `uvm_error("PIO_ERROR","PIO PINS ARE NOT SET---ERROR")
    
    `uvm_info(get_name(), $psprintf("Writing to I2C Config Register to set Modsel = 0 "), UVM_LOW)
    address = 18'h0020;
    data    = 64'h0000_0008;
    wstrb   = 8'hFF;
    wr_tx_register(address,data,wstrb);
  
    if (qsfp_if.modsel == 0 )
      `uvm_info(get_name(),$psprintf(" PIO-MODSEL pins are CLEARED"),UVM_LOW)
    else
      `uvm_error("PIO_ERROR","PIO PINS ARE NOT SET---ERROR")

    `uvm_info(get_name(), $psprintf("Writing to I2C Config Register to set lpmode = 0 "), UVM_LOW)
    address = 18'h0020;
    data    = 64'h0000_0000;
    wstrb   = 8'hFF;
    wr_tx_register(address,data,wstrb);
  
    if (qsfp_if.lpmode == 0 )
      `uvm_info(get_name(),$psprintf(" PIO-LPMODE pins are CLEARED"),UVM_LOW)
    else
      `uvm_error("PIO_ERROR","PIO PINS ARE NOT SET---ERROR")
          
  endtask : body

 endclass : qsfp_pio_output_toggle_sanity_seq

`endif // QSFP_PIO_OUTPUT_TOGGLE_SANITY_SEQ_SVH

