// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_I2C_READ_WRITE_SANITY_LOWER_UPPER_PAGE_SEQ
`define QSFP_I2C_READ_WRITE_SANITY_LOWER_UPPER_PAGE_SEQ

class qsfp_i2c_read_write_sanity_lower_upper_page_seq extends qsfp_base_seq;

  `uvm_object_utils(qsfp_i2c_read_write_sanity_lower_upper_page_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
 
  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  exp_data_byte1,exp_data_byte2,exp_data_byte3,exp_data_byte4,exp_data_byte5,exp_data_byte6,exp_data_byte7,exp_data_byte8;
  logic [7:0]  wstrb;
 
  function new(string name = "qsfp_read_write_b2b_seq");
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
      `uvm_info(get_name(), $psprintf("Starting I2C Transfer"), UVM_LOW)
      wr_tx_register(address,data,wstrb);
      
      address  =18'h0040;
      data     =i+'h80; //address bit of QSFP Module
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

    //It takes just above 100ms (with default csr value) to complete one iteration of poller_fsm operation (i.e lower,upper page00,upper page02,upper page03,upper page20,upper page 21).
    #103ms;
    //Initiating read requests after the delay  
    `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Registers"), UVM_LOW)
    for ( int j=0;j<'h100;j=j+'h8) begin

      address =18'h100+j;
      if(j<'h80) begin
        exp_data_byte1=j+7;
        exp_data_byte2=j+6;
        exp_data_byte3=j+5;
        exp_data_byte4=j+4;
        exp_data_byte5=j+3;
        exp_data_byte6=j+2;
        exp_data_byte7=j+1;
        exp_data_byte8=j;
      end
      else
      begin
        exp_data_byte1=(j+7)-'h80;
        exp_data_byte2=(j+6)-'h80;
        exp_data_byte3=(j+5)-'h80;
        exp_data_byte4=(j+4)-'h80;
        exp_data_byte5=(j+3)-'h80;
        exp_data_byte6=(j+2)-'h80;
        exp_data_byte7=(j+1)-'h80;
        exp_data_byte8=j-'h80;
      end

      if (address == 'h170) begin
        exp_data = {8'hFF,exp_data_byte2,exp_data_byte3,exp_data_byte4,exp_data_byte5,exp_data_byte6,exp_data_byte7,exp_data_byte8};
      end
      else if (address == 'h178) begin
        exp_data = 64'hFFFF_FFFF_FFFF_FFFF; //For page select byte no:127 expected data is given as FFFF's.
      end
      else begin
        exp_data = {exp_data_byte1,exp_data_byte2,exp_data_byte3,exp_data_byte4,exp_data_byte5,exp_data_byte6,exp_data_byte7,exp_data_byte8};
      end

      if( address < 'h178 || address >= 'h180) begin  //Read should not happen to lowe page 00 address byte 119-127,if we read page select byte we will get only FF as the data
        rd_tx_register(address,exp_data);
      end
    end 


  endtask : body

endclass : qsfp_i2c_read_write_sanity_lower_upper_page_seq

`endif      //  QSFP_I2C_READ_WRITE_SANITY_LOWER_UPPER_PAGE_SEQ


