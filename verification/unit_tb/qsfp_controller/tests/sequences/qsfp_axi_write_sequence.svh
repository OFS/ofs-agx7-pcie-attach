// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_AXI_WRITE_SEQUENCE_SVH
`define QSFP_AXI_WRITE_SEQUENCE_SVH

class qsfp_axi_write_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_axi_write_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)

  logic [17:0] address;
  logic [63:0] data;
  logic [7:0]  wstrb;
 
  function new(string name = "qsfp_axi_write_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    `uvm_info(get_name(), $psprintf("Resume operations after the reset assertion and init_seq"), UVM_LOW)
       address  =18'h0020;
       data     =64'h0000_0008;
       wstrb    =8'hFF;
       `uvm_info(get_name(), $psprintf("Clearing Poll_en bit to 0"), UVM_LOW)
       wr_tx_register(address,data,wstrb);
      
      #1000ns; 
       for (int i='h000;i<='h15;i=i+'h4) begin

           address  =18'h0040;
           data     =64'h02a0;
           wstrb    =8'hFF;
           `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
           wr_tx_register(address,data,wstrb);
       
           address  =18'h0040;
           data     =i;
           wstrb    =8'hFF;
           `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
           wr_tx_register(address,data,wstrb);
           
           address  =18'h0040;
           data     =64'h012;
           wstrb    =8'hFF;
           `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
           wr_tx_register(address,data,wstrb);
           
           address  =18'h0040;
           data     =64'h013;
           wstrb    =8'hFF;
           `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
           wr_tx_register(address,data,wstrb);
            
           address  =18'h0040;
           data     =64'h014;
           wstrb    =8'hFF;
           `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
           wr_tx_register(address,data,wstrb);
            
           address  =18'h0040;
           data     =64'h115; //stop condition for i2c txn - msb bits should be "01"
           wstrb    =8'hFF;
           `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
           wr_tx_register(address,data,wstrb);
       
       end 
  
  endtask : body

endclass : qsfp_axi_write_seq

`endif  // QSFP_AXI_WRITE_SEQUENCE_SVH
