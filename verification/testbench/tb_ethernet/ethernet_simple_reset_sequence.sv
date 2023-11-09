// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

/**
 * Abstract:
 * class ethernet_simple_reset_sequence defines a virtual sequence.
 * 
 * The ethernet_simple_reset_sequence drives the reset pin through one
 * activation cycle.
 *
 * The ethernet_simple_reset_sequence is configured as the default sequence for the
 * reset_phase of the testbench environment virtual sequencer, in the ethernet_base_test.
 *
 * The reset sequence obtains the handle to the reset interface through the
 * virtual sequencer. The reset interface is set in the virtual sequencer using
 * configuration database, in file top.sv.
 *
 * Execution phase: reset_phase
 * Sequencer: ethernet_virtual_sequencer in testbench environment
 */

`ifndef GUARD_ETHERNET_SIMPLE_RESET_SEQUENCE_SV
`define GUARD_ETHERNET_SIMPLE_RESET_SEQUENCE_SV

class ethernet_simple_reset_sequence extends uvm_sequence#(uvm_sequence_item,uvm_sequence_item);

  /** UVM Object Utility macro */
  `uvm_object_utils(ethernet_simple_reset_sequence)

  /** Declare a typed sequencer object that the sequence can access */
  `uvm_declare_p_sequencer(`ETH_VSQR)

  /** Class Constructor */
  function new (string name = "ethernet_simple_reset_sequence");
     super.new(name);
  endfunction : new

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
    `uvm_info("body", "Entered...", UVM_LOW)

    p_sequencer.reset_mp.reset <= 1'b0;

    @(posedge p_sequencer.reset_mp.clk);
    p_sequencer.reset_mp.reset <= 1'b1;

    @(posedge p_sequencer.reset_mp.clk);
    p_sequencer.reset_mp.reset <= 1'b0;

    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: ethernet_simple_reset_sequence

`endif // GUARD_ETHERNET_SIMPLE_RESET_SEQUENCE_SV
