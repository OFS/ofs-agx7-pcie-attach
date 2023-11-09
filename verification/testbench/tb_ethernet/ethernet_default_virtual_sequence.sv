// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

/**
 * Abstract:
 * The file contains the class extended from uvm_sequence. It is a virtual sequence 
 * that encapsulate the default sequence and tie it to the virtual sequencer. It also,
 * determines the sequence length of the underlying sequence. It is started in the base 
 * test case on the virtual sequencer.
*/

`ifndef GUARD_ETHERNET_DEFAULT_VIRTUAL_SEQUENCE_SV
`define GUARD_ETHERNET_DEFAULT_VIRTUAL_SEQUENCE_SV

class ethernet_default_virtual_sequence extends uvm_sequence#(uvm_sequence_item,uvm_sequence_item);

  /** Sequence Length in Virtual Sequence, to set to the actual default sequence */
  int unsigned sequence_length = 10;

  /** UVM object utility macro */
  `uvm_object_utils(ethernet_default_virtual_sequence)

  /** This macro is used to declare a variable p_sequencer whose type is ethernet_virtual_sequencer */
  `uvm_declare_p_sequencer(`ETH_VSQR)

  /** Class constructor */
  function new (string name = "ethernet_default_virtual_sequence");
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
    bit status;
    int local_sequence_length;

    /** Instance of default sequence, to be started on the virtual sequencer. */
    ethernet_default_sequence seq;

    `uvm_info("body", "Entered ...", UVM_DEBUG)

    status = uvm_config_db#(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "config DB" : "randomization"), UVM_LOW);

    /**
     * Since the contained sequence and this one have the same property name, the
     * inline constraint was not able to resolve to the correct scope.  Therefore the
     * sequence length of the virtual sequencer is assigned to a local property which
     * is used in the constraint.
     */
    local_sequence_length = sequence_length;

`ifdef SVT_UVM_1800_2_2017_OR_HIGHER
//ieee uvm 1800.2 follows `uvm_do(SEQ_OR_ITEM, SEQR=get_sequencer(), PRIORITY=-1, CONSTRAINTS={})
    `uvm_do(seq, p_sequencer.sequencer, -1, {seq.sequence_length == local_sequence_length;})
`else
    `uvm_do_on_with(seq, p_sequencer.sequencer, {seq.sequence_length == local_sequence_length;})
`endif

    `uvm_info("body", "Exiting ...", UVM_DEBUG)
  endtask : body

endclass : ethernet_default_virtual_sequence 

`endif // GUARD_ETHERNET_VIRTUAL_DEFAULT_SEQUENCE_UVM_SV

