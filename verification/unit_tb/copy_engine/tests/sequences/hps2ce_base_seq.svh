// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef HPS2CE_BASE_SEQ_SVH
`define HPS2CE_BASE_SEQ_SVH
`include "tb_env.svh"

class hps2ce_base_seq extends uvm_sequence;
  `uvm_object_utils(hps2ce_base_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)
  `include "VIP/vip_task.sv"
  
  virtual `AXI_IF axi_if;

  function new(string name = "hps2ce_base_seq");
      super.new(name);
  endfunction : new
 
  task rd_tx_register(input [20:0] address,input [31:0] rdata);                              
      hps2ce_axi_master_read(.address(address), .ex_rdata(rdata));
  endtask:rd_tx_register
  
  task wr_tx_register(input [63:0] address,input [1023:0] wdata,input [128:0] wstrobe);             
      hps2ce_axi_master_write(.address(address), .wdata(wdata), .wstrobe(wstrobe));
  endtask:wr_tx_register

 endclass : hps2ce_base_seq

`endif // HPS2CE_BASE_SEQ_SVH






