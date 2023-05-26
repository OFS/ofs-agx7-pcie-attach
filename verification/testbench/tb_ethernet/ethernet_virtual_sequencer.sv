// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef GUARD_ETHERNET_VIRTUAL_SEQUENCER_SV
`define GUARD_ETHERNET_VIRTUAL_SEQUENCER_SV

/**
 * This class is Virtual Sequencer class, which encapsulates the 
 * agent's sequencers and allows a fine grain control over the user's
 * stimulus application to the selective sequencer.
 */
class `ETH_VSQR extends uvm_sequencer#(uvm_sequence_item,uvm_sequence_item);
  
   /** Typedef of the reset modport to simplify access */
   typedef virtual ethernet_reset_if.ethernet_reset_modport ETHERNET_RESET_MP;

   /** Reset modport provides access to the reset signal */
   ETHERNET_RESET_MP reset_mp;

   /** UVM component utility macro */
   `uvm_component_utils(`ETH_VSQR)

   /** Instance of txrx sequencer */
   `ETH_TRANSACTION_SQR sequencer;

   /** Class constructor */
   function new(string name="`ETH_VSQR",uvm_component parent = null);
     super.new(name,parent);
   endfunction
   
   virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Entered...", UVM_LOW)

    super.build_phase(phase);

    //if (!uvm_config_db#(ETHERNET_RESET_MP)::get(this, "", "reset_mp", reset_mp)) begin
    //  `uvm_fatal("build_phase", "An ethernet_reset_modport must be set using the config db.");
    //end

    `uvm_info("build_phase", "Exiting...", UVM_LOW)
  endfunction
   
endclass
`endif
