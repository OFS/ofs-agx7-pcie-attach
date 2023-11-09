// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef GUARD_ETHERNET_BASIC_ENV_SV
`define GUARD_ETHERNET_BASIC_ENV_SV 
/**
 * Abstract: 
 * class 'ethernet_intermediate_env' is extended from  base class.  It implements
 * the build phase to construct the structural elements of this environment.
 *
 * ethernet_intermediate_env is the testbench environment, which constructs the Ethernet
 * System ENV in the build_phase method using the UVM factory service.  
 * The Ethernet ENV is the top level component which instantiates two agents namely
 * MAC and PHY agent.
 *
 * Ethernet agent is the top level component provided by the Ethernet VIP.   
 *
 * ethernet_intermediate_env also constructs the virtual sequencer. This virtual sequencer
 * in the testbench environment obtains a handle to the reset interface using
 * the config db.  This allows reset sequences to be written for this virtual
 * sequencer.
 *
 * The simulation ends after all the objections are dropped.  This is done by
 * using objections provided by phase arguments.
 */

`include "cust_ethernet_agent_configuration.sv"
`include "ethernet_virtual_sequencer.sv"
`include "ethernet_mac_sb_callbacks.sv"
//`include "ethernet_phy_sb_callbacks.sv"
//`include "ethernet_phy_monitor_callbacks.sv"
`include "ethernet_mac_monitor_callbacks.sv"
`include "ethernet_env_scoreboard.sv"

 class ethernet_intermediate_env extends uvm_env;

  /** Declare Customized System configuration for MAC */
  cust_ethernet_agent_configuration mac_cfg;


  /** Declare MAC VIP agent  */
    
  `ETH_AGENT_CLSS vip_ethernet_mac[4];
  

  /** Declare the handle of the Virtual Sequencer */
    
  `ETH_VSQR sequencer[4];
  
  /** Define scoreboard class **/
 
 
  ethernet_env_scoreboard ethernet_scoreboard[4];

  /** UVM object utility macro */
  `uvm_component_utils(ethernet_intermediate_env)
  
  /** Class constructor */
  function new( string  name = "ethernet_intermediate_env", uvm_component parent = null);
     super.new(name, parent);
  endfunction : new 

  /** Build Phase for the environment.  */
  virtual function void build_phase(uvm_phase phase) ;
    `uvm_info("build_phase", "Entered ...", UVM_LOW)
    super.build_phase(phase);

    /** Check if the ENV has passed the MAC configuration (in base/directed/random test file). 
      * If yes, then set the same to the MAC agent, else, create a new configuration and then 
      * pass it to the MAC agent. 
      */
    if (uvm_config_db#(cust_ethernet_agent_configuration)::get(this, "", "mac_cfg", mac_cfg)) begin
       for( int index=0; index<4; index++) begin
         uvm_config_db#(`ETH_AGENT_CFG_CLASS)::set(this,$sformatf("vip_ethernet_mac[%0d]*",index), "cfg", mac_cfg);
       end

    end
    else begin
      mac_cfg = cust_ethernet_agent_configuration::type_id::create("mac_cfg"); 
       for( int index=0; index<4; index++) begin
         uvm_config_db#(`ETH_AGENT_CFG_CLASS)::set(this,$sformatf("vip_ethernet_mac[%0d]*",index), "cfg", mac_cfg);
       end


    end

       /** Create MAC agent */
      
    foreach(vip_ethernet_mac[i])
          vip_ethernet_mac[i] = `ETH_AGENT_CLSS::type_id::create($sformatf("vip_ethernet_mac[%0d]",i), this);


    uvm_config_db#(int)::set(this, "*","is_active",UVM_ACTIVE);

    /** Construct the virtual sequencer */
        foreach(sequencer[i])
          sequencer[i] = `ETH_VSQR::type_id::create($sformatf("sequencer[%0d]",i), this);

    /** Create the scoreboard */ 
       foreach(ethernet_scoreboard[i])
          ethernet_scoreboard[i] = ethernet_env_scoreboard::type_id::create($sformatf("ethernet_scoreboard[%0d]",i), this);

    `uvm_info("build_phase",  "Exiting ...", UVM_LOW)
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    `uvm_info("connect_phase", "Entered ...",UVM_LOW)
    super.connect_phase(phase);

    /** Connect the agent's sequencer handle to the virtual sequencer's handle */
    
    for (int i=0; i<4; i++)
     begin
      sequencer[i].sequencer = vip_ethernet_mac[i].sequencer;
      vip_ethernet_mac[i].monitor.item_collected_port_tx.connect(ethernet_scoreboard[i].item_collected_vip_tx);
      vip_ethernet_mac[i].monitor.item_collected_port_rx.connect(ethernet_scoreboard[i].item_collected_vip_rx);
     end
    
    /** Connect the MAC agent's monitor analysis port to the scoreboard */

    
    `uvm_info("connect_phase", "Exited ...",UVM_LOW)
  endfunction : connect_phase

 endclass : ethernet_intermediate_env
`endif

