// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SOFTRST_SEQ_SVH
`define QSFP_SOFTRST_SEQ_SVH

class qsfp_softrst_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_softrst_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)

  logic [17:0] address;
  logic [63:0] exp_data, data;
  logic [7:0]  wstrb;
  rand bit s_reset;

  function new(string name = "qsfp_softrst_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    `uvm_info(get_name(), $psprintf("qsfp_softreset_test START"), UVM_LOW)
    `uvm_info(get_name(), $psprintf("Initializing QSFP registry with values done from env"), UVM_LOW)
    
    if(s_reset) 
      begin
        `uvm_info(get_name(), $psprintf("Add a value of 500ns after initializing"), UVM_LOW)
        
        `uvm_info(get_name(), $psprintf("Applying soft reset to QSFPC"), UVM_LOW)
        
        data    = 64'h0000_000a;
        address = 18'h0020;
        wstrb    =  8'hFF;
        wr_tx_register(address,data,wstrb);

        #1000ns;
        `uvm_info(get_name(), $psprintf("Deasserting soft reset to QSFPC"), UVM_LOW)
        data    = 64'h0000_0008;
        address = 18'h0020;
        wstrb    =  8'hFF;
        wr_tx_register(address,data,wstrb);

      end
     
     else
     begin
      
      address  =18'h0054;
      exp_data =64'h0000_0000_0000_0001;
      `uvm_info(get_name(), $psprintf("Reading from I2C Master STATUS Register"), UVM_LOW)
      rd_tx_register(address,exp_data);


      if(exp_data ==64'h0000_0000_0000_0001) begin

      #100ns;

       address  =18'h0040;
       data     =64'h02a0;
       wstrb    =8'hFF;
       `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
       wr_tx_register(address,data,wstrb);
   
       address  =18'h0040;
       data     ='h000;
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
       data     =64'h015;
       wstrb    =8'hFF;
       `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
       wr_tx_register(address,data,wstrb);
        
       address  =18'h0040;
       data     =64'h116; //stop condition for i2c txn - msb bits should be "01"
       wstrb    =8'hFF;
       `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
       wr_tx_register(address,data,wstrb);
       

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
           data     =64'h015;
           wstrb    =8'hFF;
           `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
           wr_tx_register(address,data,wstrb);
            
           address  =18'h0040;
           data     =64'h116; //stop condition for i2c txn - msb bits should be "01"
           wstrb    =8'hFF;
           `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
           wr_tx_register(address,data,wstrb);
       
       end
       end
       
       address  =18'h0020;
       data     =64'h0000_0018;
       wstrb    =8'hFF;
       `uvm_info(get_name(), $psprintf("setting Poll_en bit to 1"), UVM_LOW)
       wr_tx_register(address,data,wstrb);
       
    //It takes just above 100ms (with default csr value) to complete one iteration of poller_fsm operation (i.e lower,upper page00,upper page02,upper page03,upper page20,upper page 21).
        #103ms;
    //Initiating read requests after the delay  
       address =18'h100;
       exp_data=64'h1615_1413_1615_1413;
       rd_tx_register(address,exp_data);
   
     end
  
  endtask : body

endclass:qsfp_softrst_seq

`endif  // QSFP_SOFTRST_SEQ_SVH
