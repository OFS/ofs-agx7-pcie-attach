// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

/**
 * Abstract:
 * The file contains the class extended from uvm_sequence. It is a no-operation sequence 
 * It has an empty virtual function body overriden as empty function.
*/

`ifndef GUARD_ETHERNET_NULL_VIRTUAL_SEQUENCE_SV
`define GUARD_ETHERNET_NULL_VIRTUAL_SEQUENCE_SV

class ethernet_null_virtual_sequence extends uvm_sequence#(uvm_sequence_item,uvm_sequence_item);

  /** UVM object utility macro */
  `uvm_object_utils(ethernet_null_virtual_sequence)

  /** Class constructor */
  function new (string name = "ethernet_null_virtual_sequence");
     super.new(name);
  endfunction : new

  /** Need an empty body function to override the warning from the UVM base class */
  virtual task body();
  endtask : body

endclass : ethernet_null_virtual_sequence 

`endif // GUARD_ETHERNET_NULL_VIRTUAL_SEQUENCE_UVM_SV

