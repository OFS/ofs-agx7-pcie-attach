// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_BASE_SEQ_SVH
`define QSFP_BASE_SEQ_SVH

class qsfp_base_seq extends uvm_sequence;
  `uvm_object_utils(qsfp_base_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
  `include "VIP/vip_task.sv"

  qsfp_tb_config  tb_cfg0;
  virtual qsfp_intf qsfp_if;
  virtual qsfp_slave_interface qsfp_slv_if;
  virtual `AXI_IF   axi_if;

  function new(string name = "qsfp_base_seq");
      super.new(name);
  endfunction : new


  virtual task body ();

    if(!uvm_config_db #(qsfp_tb_config)::get(get_sequencer(),"*","tb_cfg0",tb_cfg0)) begin
       `uvm_fatal(get_name(),"Couldnt able to get config handle")
    end

    qsfp_if = tb_cfg0.qsfp_if;
    qsfp_slv_if = tb_cfg0.qsfp_slv_if;
    axi_if      = tb_cfg0.axi_if;
  endtask:body

  task rd_tx_register(input [17:0] address,input [63:0] rdata);                              
      qsfp_axi_master_read(.address(address), .ex_rdata(rdata));
      `uvm_info(get_name(), $psprintf(" data from base sequence Addr = %0h, Exp = %0h ", address, rdata), UVM_LOW)
  endtask:rd_tx_register
  
  task rd_rand_tx_register(input [17:0] address,input [63:0] rdata);                              
      qsfp_axi_master_read_rand(.address(address), .ex_rdata(rdata));
  endtask:rd_rand_tx_register

  task wr_tx_register(input [17:0] address,input [63:0] wdata,input [7:0] wstrobe);             
      qsfp_axi_master_write(.address(address), .wdata(wdata), .wstrobe(wstrobe));
  endtask:wr_tx_register

 endclass : qsfp_base_seq

`endif // QSFP_BASE_SEQ_SVH






