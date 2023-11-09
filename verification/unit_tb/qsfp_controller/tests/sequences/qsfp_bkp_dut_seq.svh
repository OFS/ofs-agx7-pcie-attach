// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_BKP_DUT_SEQ_SVH
`define QSFP_BKP_DUT_SEQ_SVH

class qsfp_bkp_dut_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_bkp_dut_seq)
 
  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;
 
  function new(string name = "qsfp_bkp_dut_seq");
    super.new(name);
  endfunction : new
 
  task body();
    super.body();
    
    #1000ns;
    
    address  =18'h0020;
    data     =64'h0000_0000_0000_0018;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Enabling Poll_en bit to enable POLLER_FSM"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
   
    
    uvm_hdl_force("qsfp_tb_top.axi_if.master_if[0].rready",1'b0);
    #500000ns;
    #500000ns;
    #500000ns;
    #500000ns;
    #5000ns; 
    #50000ns;
    #500000ns;

    fork
    begin
      address  =18'h0100;
      exp_data     ='d0;
      `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Register"), UVM_LOW)
      rd_rand_tx_register(address,exp_data);
      
      address  =18'h0108;
      exp_data     ='d0;
      `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Register"), UVM_LOW)
      rd_rand_tx_register(address,exp_data);
    end
    begin
      #2000ns;
      uvm_hdl_force("qsfp_tb_top.axi_if.master_if[0].rready",1'b0);
      #2000.5ns;
      uvm_hdl_force("qsfp_tb_top.axi_if.master_if[0].rready",1'b1);
    end
    join

    address      =18'h0110;
    exp_data     ='d0;
    `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Register"), UVM_LOW)
    rd_rand_tx_register(address,exp_data);
    

    address      =18'h0118;
    exp_data     ='d0;
    `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Register"), UVM_LOW)
    rd_rand_tx_register(address,exp_data);

    address      =18'h0120;
    exp_data     ='d0;
    `uvm_info(get_name(), $psprintf("Reading from Shadow CSR Register"), UVM_LOW)
    rd_rand_tx_register(address,exp_data);

    
  endtask : body
 
endclass : qsfp_bkp_dut_seq

`endif // QSFP_INIT_SEQ_SVH






