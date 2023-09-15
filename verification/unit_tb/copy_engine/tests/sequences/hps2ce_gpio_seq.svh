// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef PMCI_QSFP_CSR_SEQ_SVH
`define PMCI_QSFP_CSR_SEQ_SVH

class hps2ce_gpio_seq extends hps2ce_base_seq;
  `uvm_object_utils(hps2ce_gpio_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)


  logic [20:0] address;
  logic [31:0] data,exp_data;
  logic [3:0]  wstrb;
  
  function new(string name = "hps2ce_gpio_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    `uvm_info(get_name(), "Entering hp2ce0_csr_seq...", UVM_LOW)
    
    //----------------------- CSR READ to HPS2HOST Register---------------------------//
    address  =20'h158;
    exp_data =32'h00;
    `uvm_info(get_name(), $psprintf("Reading from HPS2HOST Register - HPS_RDY"), UVM_LOW)
    rd_tx_register(address,exp_data);
    //----------------------- CSR WRITE to HPS2HOST Register---------------------------//
    
    address  =21'h158;
    data     =32'h10;
    wstrb    =4'hF;
    `uvm_info(get_name(), $psprintf("Writing to HPS2HOST Register - HPS_RDY"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //----------------------- CSR READ to HPS2HOST Register---------------------------//
                                                                                                    
    address  =20'h158;
    exp_data =32'h10;
    `uvm_info(get_name(), $psprintf("Reading from HPS2HOST Register - HPS_RDY"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //----------------------- CSR WRITE to HPS2HOST Register---------------------------//

    address  =21'h158;
    data     =32'h00;
    wstrb    =4'hF;
    `uvm_info(get_name(), $psprintf("Writing to HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //----------------------- CSR READ to HPS2HOST Register---------------------------//
                                                                                                    
    address  =20'h158;
    exp_data =32'h10;
    `uvm_info(get_name(), $psprintf("Reading from HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //----------------------- CSR WRITE to HPS2HOST Register---------------------------//

    address  =21'h158;
    data     =32'h05;
    wstrb    =4'hF;
    `uvm_info(get_name(), $psprintf("Writing to HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //----------------------- CSR READ to HPS2HOST Register---------------------------//
                                                                                                    
    address  =20'h158;
    exp_data =32'h15;
    `uvm_info(get_name(), $psprintf("Reading from HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    //----------------------- CSR WRITE to HPS2HOST Register---------------------------//

    address  =21'h158;
    data     =32'h0A;
    wstrb    =4'hF;
    `uvm_info(get_name(), $psprintf("Writing to HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    //----------------------- CSR READ to HPS2HOST Register---------------------------//
                                                                                                    
    address  =20'h158;
    exp_data =32'h1A;
    `uvm_info(get_name(), $psprintf("Reading from HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    rd_tx_register(address,exp_data); 

  endtask : body

endclass : hps2ce_gpio_seq

`endif // HPS2CE_CiCSR_SEQ_SVH



