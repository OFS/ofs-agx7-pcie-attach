// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_I2C_READ_WRITE_SANITY_SEQ_SVH
`define QSFP_I2C_READ_WRITE_SANITY_SEQ_SVH

class qsfp_i2c_read_write_sanity_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_i2c_read_write_sanity_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)

  logic [17:0] address;
  logic [63:0] data,exp_data, i, j;
  logic [7:0]  wstrb;

  qsfp_poller_enable_disable_seq pl_en_seq;

  function new(string name = "qsfp_i2c_read_write_sanity_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    pl_en_seq = qsfp_poller_enable_disable_seq::type_id::create("pl_en_seq");
    `uvm_info(get_name(), $psprintf("Writing to & Reading from CSR Registers "), UVM_LOW)
   
    //------------------------CSR Write to QSFP Module Register -------------------------//
     
    //for (int i='h000,j='h100;i<='hFF,j<=120;i=i+'h8,j=j+'h8) begin
      
    for (int i='h000;i<='hFF;i=i+'h8) begin

    //------------------------------------Disabling Poller-------------------------------//

      assert (pl_en_seq.randomize() with{ en==0;})      
      pl_en_seq.start(p_sequencer, this);

      #20ns;

      address  =i;
      data     =64'h0000_0000_0000_1111;
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Writting to QSFP Module Registers"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
      `uvm_info(get_name(), $psprintf("Write to QSFP Module Register Address: %h Completed", address), UVM_LOW)
 
    //------------------------------------Enabling Poller-----------------------------//

      assert (pl_en_seq.randomize() with{ en==1;})
      pl_en_seq.start(p_sequencer, this);

      #100ns;

      `uvm_info(get_name(), $psprintf("Reading From Shadow CSR Registers"), UVM_LOW)
      j=i+100;
      address =j;
      exp_data =64'h0000_0000_0000_1111;             
      rd_tx_register(address,exp_data);
      `uvm_info(get_name(), $psprintf("Read from Shadow CSR Register Address: %h Completed", address), UVM_LOW)
      #100ns;
        
    end

  endtask : body

endclass :  qsfp_i2c_read_write_sanity_seq

`endif // QSFP_I2C_READ_WRITE_SANITY_SEQ_SVH








