// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef ETHERNET_DEFAULT_SEQUENCE
`define ETHERNET_DEFAULT_SEQUENCE

class ethernet_default_sequence extends uvm_sequence #(`ETH_TRANSACTION_CLASS); 

  rand int unsigned sequence_length =1;

  /** UVM object utility macro */
  `uvm_object_utils(ethernet_default_sequence)
   
  /** Class constructor */
  function new(string name="ethernet_default_sequence");
     super.new(name);
  endfunction 

  /** Raise an objection if this is the parent sequence */
  virtual task pre_body();
  uvm_phase phase;
  super.pre_body();
`ifdef SVT_UVM_12_OR_HIGHER
       phase = get_starting_phase();
`else
       phase = starting_phase;
`endif
  if (phase!=null) begin
    phase.raise_objection(this);
  end
  endtask: pre_body
  
  /** Drop an objection if this is the parent sequence */
  virtual task post_body();
  uvm_phase phase;
  super.post_body();
`ifdef SVT_UVM_12_OR_HIGHER
       phase = get_starting_phase();
`else
       phase = starting_phase;
`endif
  if (phase!=null) begin
    phase.drop_objection(this);
  end
  endtask: post_body
  
  virtual task body();
    `uvm_info("body", "Entered ...", UVM_DEBUG)
    `uvm_do(req)
  endtask 
endclass

`endif //  `ifndef ETHERNET_DEFAULT_SEQUENCE
