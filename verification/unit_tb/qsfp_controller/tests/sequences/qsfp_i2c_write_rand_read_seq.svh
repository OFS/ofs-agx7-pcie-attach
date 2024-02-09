// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_I2C_WRITE_RAND_READ_SEQ
`define QSFP_I2C_WRITE_RAND_READ_SEQ

class qsfp_i2c_write_rand_read_seq extends qsfp_base_seq;

  `uvm_object_utils(qsfp_i2c_write_rand_read_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
 
  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  exp_data_byte1,exp_data_byte2,exp_data_byte3,exp_data_byte4,exp_data_byte5,exp_data_byte6,exp_data_byte7,exp_data_byte8;
  logic [7:0]  wstrb;
 
  function new(string name = "qsfp_i2c_write_rand_read_seq");
      super.new(name);
  endfunction : new
 
  task body();
    super.body();
 
    `uvm_info(get_name(), $psprintf("Writing values to QSFPModule Registers"), UVM_LOW)
    #1000ns;
    //-------Start Writing to Lower Pg00--------------//
    for(int i='h0;i<'h80;i=i+'h4)
    begin

      address  =18'h0040;
      data     =64'h02a0;
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Starting I2C Transfer"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =i; //address bit of QSFP Module
      wstrb    =8'hFF;
      `uvm_info(get_name(), $psprintf("Writing address of QSFPM register"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
  
      if( data  == 'h7c) begin  //Writing data as 0000 to select Upper_pg0

        address  =18'h0040;
        data     =0; // Data byte of QSFPModule
        wstrb    =8'hFF;
        wr_tx_register(address,data,wstrb);
        
        address  =18'h0040;
        data     =0;
        wstrb    =8'hFF;
        wr_tx_register(address,data,wstrb);
        
        address  =18'h0040;
        data     =0;
        wstrb    =8'hFF;
        wr_tx_register(address,data,wstrb);
        
        address  =18'h0040;
        data     ={2'(1),8'(0)}; //stop condition for i2c txn - msb bits should be "01"
        wstrb    =8'hFF;
        wr_tx_register(address,data,wstrb);
    
      end
      else begin
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

    end

    //-------Start Writing to Upper Pg00--------------//

    for(int i='h0;i<'h80;i=i+'h4)
    begin

      address  =18'h0040;
      data     =64'h02a0;
      wstrb    =8'hFF;
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =i+'h80; //address bit of QSFP Module
      wstrb    =8'hFF;
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =8'(i); // Data byte of QSFPModule
      wstrb    =8'hFF;
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =8'(i+1);
      wstrb    =8'hFF;
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =8'(i+2);
      wstrb    =8'hFF;
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     ={2'(1),8'(i+3)}; //stop condition for i2c txn - msb bits should be "01"
      wstrb    =8'hFF;
      wr_tx_register(address,data,wstrb);
 
    end


    `uvm_info(get_name(), $psprintf(" Enabling the poller before read operation "), UVM_LOW)
      
    address  =18'h0020;
    data     =64'h0000_0000_0000_0018;
    wstrb     ='hFF;
    `uvm_info(get_name(), $psprintf("Writing to Config Register to enable poller"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
 
    `uvm_info(get_name(), $psprintf(" Add delay before doing shadow_csr read operation so that state fsm in csr_wr_logic reaches MEM_WRITE state "), UVM_LOW)
     
       
    while(qsfp_slv_if.read ==0 )
    begin
      @(posedge qsfp_if.clk);
    end

    #103ms;
 
    `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Registers"), UVM_LOW)
     
      address='h130;
      exp_data ='h0;
      rd_rand_tx_register(address,exp_data);
      
      address='h100;
      exp_data ='h0;
      rd_rand_tx_register(address,exp_data);
      
      address='h1f8;
      exp_data ='h0;
      rd_rand_tx_register(address,exp_data);
      
      address='h1a0;
      exp_data ='h0;
      rd_rand_tx_register(address,exp_data);
      
      address='h160;
      exp_data ='h0;
      rd_rand_tx_register(address,exp_data);


  endtask : body

endclass : qsfp_i2c_write_rand_read_seq

`endif      //  QSFP_I2C_WRITE_RAND_READ_SEQ


