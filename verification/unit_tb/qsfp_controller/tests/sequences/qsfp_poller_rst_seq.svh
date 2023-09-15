// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_POLLER_RST_SEQ_SVH
`define QSFP_POLLER_RST_SEQ_SVH

class qsfp_poller_rst_seq extends qsfp_base_seq;
    `uvm_object_utils(qsfp_poller_rst_seq)
    `uvm_declare_p_sequencer(qsfp_virtual_sequencer)

    logic [17:0] address;
    logic [63:0] data,exp_data;
    logic [7:0]  wstrb;
    rand  bit    poller_rst;

    function new(string name = "qsfp_poller_rst_seq");
        super.new(name);
    endfunction : new

    task body();
      super.body();

     `uvm_info(get_name(), $psprintf("qsfp_poller_reset_test START"), UVM_LOW)
     `uvm_info(get_name(), $psprintf("Initializing QSFP registry with values done from env"), UVM_LOW)
     if(!poller_rst) 
     begin
       `uvm_info(get_name(), $psprintf("Add a value of 500ns after initializing"), UVM_LOW)
       #1000ns;
       data    = 64'h0000_0018;
       address = 18'h0020;
       wstrb    =  8'hFF;
       wr_tx_register(address,data,wstrb);

       #50000000ns;
       //clearing tfr_cmd fifo_thd
       data=64'h0000_0000_0000_0023;
       address =18'h0048;
       wstrb=8'hFF;
       wr_tx_register(address,data,wstrb);

       //setting tx_ready_en as 1. clearing all other bits
       data = 64'h0000_0000_0000_0001;
       address =18'h4c;
       wstrb=8'hFF;
       wr_tx_register(address,data,wstrb);


       wait(qsfp_tb_top.qsfp_dut_i.qsfp_ctrl_inst.i2c_0.i2c_0.u_csr.tx_ready==1);

       data    = 64'h0000_000a;
       address = 18'h0020;
       wstrb    =  8'hFF;
       wr_tx_register(address,data,wstrb);

       #50000ns;

       data    = 64'h0000_0008;
       address = 18'h0020;
       wstrb    =  8'hFF;
       wr_tx_register(address,data,wstrb);
     end
     else
     begin
       `uvm_info(get_name(), $psprintf("Resume operations after the reset assertion and init_seq"), UVM_LOW)
        #500000ns;
       address  =18'h0020;
       data     =64'h0000_0018;
       wstrb    =8'hFF;
       `uvm_info(get_name(), $psprintf("Setting Poll_en bit to 1"), UVM_LOW)
       wr_tx_register(address,data,wstrb);

       #500000ns;
       
     end
     endtask : body


endclass:qsfp_poller_rst_seq

`endif
