// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SLAVE_SEQ_ITEM
`define QSFP_SLAVE_SEQ_ITEM
//Class : QSFP slave sequence item

class qsfp_slave_seq_item extends uvm_sequence_item;
  
  // variable: address
  rand logic [31:0]     address;
  
  // variable: data
  rand logic [31:0]    writedata;
  
  // variable: data
  rand logic [31:0]    readdata;

  rand logic write;

  rand logic read;

  rand qsfp_slv_pkt_t   qsfp_slv_pkt_type; //QSFP_SLV_WRITE, QSFP_SLV_READ, QSFP_SLV_RD_HDR

  //Wait request
  rand logic waitrequest ;
  //Byte Enable
  rand logic [3:0] byteenable ;

 
  `uvm_object_utils_begin (qsfp_slave_seq_item)
    `uvm_field_int( address,    UVM_ALL_ON) 
    `uvm_field_int( writedata,  UVM_ALL_ON)
    `uvm_field_int( readdata,   UVM_ALL_ON)
    `uvm_field_enum (qsfp_slv_pkt_t, qsfp_slv_pkt_type, UVM_ALL_ON)
    `uvm_field_int( read,       UVM_ALL_ON)
    `uvm_field_int( write,      UVM_ALL_ON)
    `uvm_field_int( waitrequest,UVM_ALL_ON)
    `uvm_field_int( byteenable, UVM_ALL_ON)
  `uvm_object_utils_end

  //Constructor
  function  new(string name = "qsfp_slave_seq_item");
   super.new(name);
  endfunction: new

endclass: qsfp_slave_seq_item

`endif // QSFP_SLAVE_SEQ_ITEM
