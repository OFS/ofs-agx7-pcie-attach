// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_POR_REGISTER_SEQ_SVH
`define QSFP_POR_REGISTER_SEQ_SVH

class qsfp_por_register_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_por_register_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)

  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;
  
  function new(string name = "qsfp_por_register_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    address  =18'h0000;
    exp_data =64'h3000_0000_1000_1001;
    `uvm_info(get_name(), $psprintf("Reading from DFH Register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    address  =18'h0020;
    //exp_data =64'h08;
    exp_data =64'h00;
    `uvm_info(get_name(), $psprintf("Reading from Config Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h0028;
    exp_data =64'he0;     
    `uvm_info(get_name(), $psprintf("Reading from Status Register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    address  =18'h0030;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from Scratch Pad Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    /*address  =18'h0044;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master RX_DATA Register"), UVM_LOW)
    rd_tx_register(address,exp_data); */

    address  =18'h0048;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master CTRL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
 
    address  =18'h004C;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISER Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h0050;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h0054;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master STATUS Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h0058;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master TFR_CMD_FIFO_LVL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h005C;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master RX_DATA_FIFO_LVL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h0060;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL_LOW Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h0064;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL_HIGH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h0068;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SDA_HOLD Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Addr:100-120"), UVM_LOW)
    for (int i='h100;i<='h120;i=i+'h8) begin
      address=i;
      exp_data=0;
      rd_tx_register(address,exp_data);
    end

  endtask : body

endclass : qsfp_por_register_seq

`endif // QSFP_POR_REGISTER_SEQ_SVH



