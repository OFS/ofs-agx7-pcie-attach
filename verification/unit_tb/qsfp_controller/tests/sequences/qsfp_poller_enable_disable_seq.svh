// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_POLLER_ENABLE_DISABLE_SEQ_SVH
`define QSFP_POLLER_ENABLE_DISABLE_SEQ_SVH

class qsfp_poller_enable_disable_seq extends qsfp_base_seq;
    `uvm_object_utils(qsfp_poller_enable_disable_seq)
    `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
    logic [17:0] address;
    logic [7:0]  strb;
    logic [63:0] data;

    rand bit en;
    function new(string name = "qsfp_poller_enable_disable_seq");
        super.new(name);
    endfunction : new

    task body();
      super.body();
      if (!en)
      begin
        address =18'h0020;
        data = 64'h0000_0008;  
        strb = 8'hFF;
        wr_tx_register (address,data,strb);
      end
      else
      begin
        address =18'h0020;
        data = 64'h0000_0018;  
        strb = 8'hFF;
        wr_tx_register (address,data,strb);
      end
    endtask:body


endclass:qsfp_poller_enable_disable_seq


`endif 
