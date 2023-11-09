// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef HPS2CE_SKV_SEQ_SVH
`define HPS2CE_SKV_SEQ_SVH

class hps2ce_skv_seq extends hps2ce_base_seq;
  `uvm_object_utils(hps2ce_skv_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)


  logic [20:0] address;
  logic [31:0] data,exp_data;
  logic [3:0]  wstrb;
  int cnt=0;

  
  function new(string name = "hps2ce_skv_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    `uvm_info(get_name(), "Entering hp2ce0_csr_seq...", UVM_LOW)
    //----------------------- CSR WRITE to HPS2HOST Register---------------------------//
    
    /*address  =21'h158;
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
    rd_tx_register(address,exp_data); */
   repeat (100) begin  
#2000ns;
   do begin
   address  =21'h158;
    data     =32'h10;
    wstrb    =4'hF;
    `uvm_info(get_name(), $psprintf("Writing to HPS2HOST Register - HPS_RDY"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
   end while (!(tb_top.DUT.ce_top_inst.ce_csr_inst.csr_host2hps_img_xfr_st[0]));

    repeat(5) begin 
    address  =21'h158;
    data     =32'hA;
    wstrb    =4'hF;
    `uvm_info(get_name(), $psprintf("Writing to HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
#100ns;
    end

repeat(5) begin
     address  =21'h158;
    data     =32'h1;
    wstrb    =4'hF;
    `uvm_info(get_name(), $psprintf("Writing to HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
#100ns;
    end

repeat(5) begin
     address  =21'h158;
    data     =32'h5;
    wstrb    =4'hF;
    `uvm_info(get_name(), $psprintf("Writing to HPS2HOST Register - KERNEL_VFY & SSBL_VFY"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
#100ns;
    end
    
 end

  endtask : body

endclass : hps2ce_skv_seq

`endif // HPS2CE_CiCSR_SEQ_SVH



