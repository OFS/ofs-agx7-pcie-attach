// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

/**
 * Abstract:
 * The file contains the class extended from uvm_test
 * A simple ethernet_base_test does the following:
 * 1. Instantiates & creates the environment class.
 * 2. Instantiate & sets "mac_address" as a part of configuration,
 *    and passes the MAC/PHY configuration for the two agnets inside 
 *    the environment.
 * 3. Configure the ethernet_simple_reset_sequence as the default sequence
 *    for the reset phase of the TB ENV virtual sequencer
 * 4. Set the default_sequence in the run_phase of virtual sequencer in the environment.
 * 5. Set the default sequence length = 1.
 * 6. Set the Pass/Fail criterion in the final_phase() using report_server. 
 */

`ifndef GUARD_ETHERNET_BASE_TEST_SV
`define GUARD_ETHERNET_BASE_TEST_SV

`include "cust_ethernet_transaction.sv"
`include "cust_ethernet_agent_configuration.sv"
`include "ethernet_intermediate_env_CVL25G.sv"
`include "ethernet_default_sequence.sv"
`include "ethernet_default_virtual_sequence.sv"
`include "ethernet_simple_reset_sequence.sv"

//class ethernet_base_test extends uvm_test;
class ethernet_base_test extends base_test;

  /** UVM component utility macro */
  `uvm_component_utils(ethernet_base_test)

  /** Instance of the environment */
  ethernet_intermediate_env env;



  /** Class constructor */
  function new(string name = "ethernet_base_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  /** build() - Method to build various component */
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Entered ...", UVM_LOW)
    super.build_phase(phase);

    `uvm_info("build_phase", "Exited ...", UVM_LOW)
  endfunction : build_phase
  
  function void final_phase(uvm_phase phase);
    uvm_report_server svr;
    `uvm_info("final_phase", "Entered ...",UVM_LOW)

    super.final_phase(phase);

    svr = uvm_report_server::get_server();

    `uvm_info("final_phase", "Exited ...",UVM_LOW)
  endfunction

endclass

`endif
