// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_READ_WRITE_REGISTER_SEQ_SVH
`define QSFP_READ_WRITE_REGISTER_SEQ_SVH

class qsfp_read_write_register_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_read_write_register_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)

  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;
 
  function new(string name = "qsfp_read_write_register_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    `uvm_info(get_name(), $psprintf("Writing to CSR Registers"), UVM_LOW)
    
    #200ns;
                                                                                                                    
    //---------------------- CSR Write to Config Register---------------------------//
                                                                                                    
    address  =18'h0020;
    data     =64'h08;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //----------------------- CSR Read to Config Register---------------------------//
                                                                                                    
    address  =18'h0020;
    exp_data =64'h08;
    `uvm_info(get_name(), $psprintf("Reading from Config Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //----------------------- CSR Write to Scratch Pad Register----------------------//
 
    address  =18'h0030;
    data     =64'hDEAD_BEEF;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to Scratch Pad Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
 
    //------------------------ CSR Read to Scratch Pad Register-----------------------//
 
    address  =18'h0030;
    exp_data =64'hDEAD_BEEF;           
    `uvm_info(get_name(), $psprintf("Reading from Scratch PAD Register"), UVM_LOW)
    rd_tx_register(address,exp_data);    

    //------------------------ CSR Write to I2C Master CTRL Register--------------------//

    address  =18'h0048;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master CTRL Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master CTRL Register--------------------//

    address  =18'h0048;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master CTRL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //------------------------ CSR Write to I2C Master ISER Register--------------------//

    address  =18'h004C;
    data     =64'h10;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master ISER Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master ISER Register--------------------//

    address  =18'h004C;
    exp_data =64'h10;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISER Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
    
    //------------------------ CSR Write to I2C Master SCL LOW Register--------------------//

    address  =18'h0060;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL LOW Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL LOW Register--------------------//

    address  =18'h0060;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL LOW Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //------------------------ CSR Write to I2C Master SCL HIGH Register--------------------//

    address  =18'h0064;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL HIGH Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL HIGH Register--------------------//

    address  =18'h0064;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL HIGH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 


    //------------------------ CSR Write to I2C Master SCL HOLD Register--------------------//

    address  =18'h0068;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL HOLD Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL HOLD Register--------------------//

    address  =18'h0068;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL HOLD Register"), UVM_LOW)
    rd_tx_register(address,exp_data);


    //------------------------Writing transactions so that both 1->0 and 0->1 transitions are hit for coverage purpose-----// 
    address  =18'h0030;
    data     =64'hFFFF_FFFF_FFFF_FFFF;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to Scratch Pad Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h0030;
    exp_data =64'hFFFF_FFFF_FFFF_FFFF; 
    `uvm_info(get_name(), $psprintf("Reading from Scratchpad Register"), UVM_LOW)
    rd_tx_register(address,exp_data);
          
    address  =18'h0030;
    data     =64'h0000_0000_0000_0000;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to Scratch Pad Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h0030;
    exp_data     =64'h0000_0000_0000_0000;
   // exp_data =64'hFFFF_FFFF_FFFF_FFFF; 
    `uvm_info(get_name(), $psprintf("Reading from Scratchpad Register"), UVM_LOW)
    rd_tx_register(address,exp_data);
    
    //------------------------Writing transactions so that both 1->0 and 0->1 transitions are hit for coverage purpose-----// 
    address  =18'h0038;
    data     =32'hFFFF_FFFF;
    wstrb    =8'h0F;
    `uvm_info(get_name(), $psprintf("Writting to Delay register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h0038;
    exp_data =32'hFFFF_FFFF; 
    `uvm_info(get_name(), $psprintf("Reading from Delay Register"), UVM_LOW)
    rd_tx_register(address,exp_data);
          
    address  =18'h0038;
    data     =32'h0000_0000_0000_0000;
    wstrb    =8'h0F;
    `uvm_info(get_name(), $psprintf("Writting to Delay Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
    
    address  =18'h0038;
    exp_data     =32'h0000_0000_0000_0000;
   // exp_data =64'hFFFF_FFFF_FFFF_FFFF; 
    `uvm_info(get_name(), $psprintf("Reading from Delay Register"), UVM_LOW)
  endtask : body
 
endclass : qsfp_read_write_register_seq

`endif // QSFP_READ_WRITE_REGISTER_SEQ_SVH

        

