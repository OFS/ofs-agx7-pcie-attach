//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class pmci_qsfp_csr_seq is executed by pmci_qsfp_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef PMCI_QSFP_CSR_SEQ_SVH
`define PMCI_QSFP_CSR_SEQ_SVH

class pmci_qsfp_csr_seq extends base_seq;
  `uvm_object_utils(pmci_qsfp_csr_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)


  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;
  
  function new(string name = "pmci_qsfp_csr_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    `uvm_info(get_name(), "Entering qsfp0_csr_seq...", UVM_LOW)

    address  = QSFP0_BASE_ADDR;
    exp_data =64'h3000_0000_1000_0013;
    `uvm_info(get_name(), $psprintf("Reading from DFH Register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    address  = QSFP0_BASE_ADDR +18'h20;
    exp_data =64'h00;
    `uvm_info(get_name(), $psprintf("Reading from Config Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR +18'h28;
    exp_data =64'he0;     
    `uvm_info(get_name(), $psprintf("Reading from Status Register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    address  = QSFP0_BASE_ADDR+18'h30;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from Scratch Pad Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR+18'h48;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master CTRL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
 
    address  = QSFP0_BASE_ADDR+18'h4C;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISER Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR+18'h50;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR+18'h54;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master STATUS Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR+18'h58;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master TFR_CMD_FIFO_LVL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR+18'h5C;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master RX_DATA_FIFO_LVL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR+18'h60;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL_LOW Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR+18'h64;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL_HIGH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP0_BASE_ADDR+18'h68;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SDA_HOLD Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Addr:100-120"), UVM_LOW)
    for (int i='h0;i<='h127;i=i+'h8) begin
      address= QSFP0_BASE_ADDR+'h100+i;
      exp_data=0;
      rd_tx_register(address,exp_data);
    end

    `uvm_info(get_name(), $psprintf("Writing to CSR Registers"), UVM_LOW)
    
    #200ns;
                                                                                                                    
    //---------------------- CSR Write to Config Register---------------------------//
                                                                                                    
    address  = QSFP0_BASE_ADDR+18'h20;
    data     =64'h08;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //----------------------- CSR Read to Config Register---------------------------//
                                                                                                    
    address  = QSFP0_BASE_ADDR+18'h20;
    exp_data =64'h08;
    `uvm_info(get_name(), $psprintf("Reading from Config Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //----------------------- CSR Write to Scratch Pad Register----------------------//
 
    address  = QSFP0_BASE_ADDR+18'h30;
    data     =64'hDEAD_BEEF;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to Scratch Pad Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
 
    //------------------------ CSR Read to Scratch Pad Register-----------------------//
 
    address  = QSFP0_BASE_ADDR+18'h30;
    exp_data =64'hDEAD_BEEF;           
    `uvm_info(get_name(), $psprintf("Reading from Scratch PAD Register"), UVM_LOW)
    rd_tx_register(address,exp_data);    

    //------------------------ CSR Write to I2C Master CTRL Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h48;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master CTRL Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master CTRL Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h48;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master CTRL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //------------------------ CSR Write to I2C Master ISER Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h4C;
    data     =64'h10;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master ISER Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master ISER Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h4C;
    exp_data =64'h10;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISER Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
    
    //------------------------ CSR Write to I2C Master SCL LOW Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h60;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL LOW Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL LOW Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h60;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL LOW Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //------------------------ CSR Write to I2C Master SCL HIGH Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h64;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL HIGH Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL HIGH Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h64;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL HIGH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 


    //------------------------ CSR Write to I2C Master SCL HOLD Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h68;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL HOLD Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL HOLD Register--------------------//

    address  = QSFP0_BASE_ADDR+18'h68;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL HOLD Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    `uvm_info(get_name(), "Entering qsfp1_csr_seq...", UVM_LOW)

    address  = QSFP1_BASE_ADDR ;
    exp_data =64'h3000_0000_1000_0013;
    `uvm_info(get_name(), $psprintf("Reading from DFH Register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    address  = QSFP1_BASE_ADDR +18'h20;
    exp_data =64'h00;
    `uvm_info(get_name(), $psprintf("Reading from Config Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP1_BASE_ADDR+ 18'h28;
    exp_data =64'he0;     
    `uvm_info(get_name(), $psprintf("Reading from Status Register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    address  = QSFP1_BASE_ADDR+ 18'h30;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from Scratch Pad Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
 
    address  = QSFP1_BASE_ADDR  +18'h48;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master CTRL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
 
    address  = QSFP1_BASE_ADDR +18'h4C;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISER Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP1_BASE_ADDR +18'h50;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP1_BASE_ADDR + 18'h54;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master STATUS Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =QSFP1_BASE_ADDR + 18'h58;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master TFR_CMD_FIFO_LVL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =QSFP1_BASE_ADDR + 18'h5C;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master RX_DATA_FIFO_LVL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = QSFP1_BASE_ADDR + 18'h60;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL_LOW Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =18'h13064;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL_HIGH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  =QSFP1_BASE_ADDR + 18'h68;
    exp_data =64'h0000_0000_0000_0001;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SDA_HOLD Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Addr:100-120"), UVM_LOW)
      for (int i='h0;i<='h127;i=i+'h8) begin
      address=QSFP1_BASE_ADDR + 'h100+i;
      exp_data=0;
      rd_tx_register(address,exp_data);
    end

    `uvm_info(get_name(), $psprintf("Writing to CSR Registers"), UVM_LOW)
    
    #200ns;
                                                                                                                    
    //---------------------- CSR Write to Config Register---------------------------//
                                                                                                    
    address  =QSFP1_BASE_ADDR + 18'h20;
    data     =64'h08;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to Config Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //----------------------- CSR Read to Config Register---------------------------//
                                                                                                    
    address  =QSFP1_BASE_ADDR + 18'h20;
    exp_data =64'h08;
    `uvm_info(get_name(), $psprintf("Reading from Config Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //----------------------- CSR Write to Scratch Pad Register----------------------//
 
    address  =QSFP1_BASE_ADDR + 18'h30;
    data     =64'hDEAD_BEEF;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to Scratch Pad Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
 
    //------------------------ CSR Read to Scratch Pad Register-----------------------//
 
    address  =QSFP1_BASE_ADDR + 18'h30;
    exp_data =64'hDEAD_BEEF;           
    `uvm_info(get_name(), $psprintf("Reading from Scratch PAD Register"), UVM_LOW)
    rd_tx_register(address,exp_data);    

    //------------------------ CSR Write to I2C Master CTRL Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h48;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master CTRL Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master CTRL Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h48;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master CTRL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //------------------------ CSR Write to I2C Master ISER Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h4C;
    data     =64'h10;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master ISER Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master ISER Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h4C;
    exp_data =64'h10;
    `uvm_info(get_name(), $psprintf("Reading from I2C Master ISER Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
    
    //------------------------ CSR Write to I2C Master SCL LOW Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h60;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL LOW Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL LOW Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h60;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL LOW Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //------------------------ CSR Write to I2C Master SCL HIGH Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h64;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL HIGH Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL HIGH Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h64;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL HIGH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 


    //------------------------ CSR Write to I2C Master SCL HOLD Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h68;
    data     =64'h2F;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to I2C Master SCL HOLD Register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //------------------------ CSR Read to I2C Master SCL HOLD Register--------------------//

    address  =QSFP1_BASE_ADDR + 18'h68;
    exp_data =64'h2F; 
    `uvm_info(get_name(), $psprintf("Reading from I2C Master SCL HOLD Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 


  endtask : body

endclass : pmci_qsfp_csr_seq

`endif // PMCI_QSFP_CSR_SEQ_SVH



