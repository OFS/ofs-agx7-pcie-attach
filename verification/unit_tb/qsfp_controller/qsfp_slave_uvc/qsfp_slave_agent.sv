// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//class : QSFP slave agent
//        The slave agent will contain I2C BFM , QSFP slave monitor to pass the
//        data packet to QSFP register array component
//
class qsfp_slave_agent extends uvm_agent;
  
  //Declaring agent components
  qsfp_slave_driver    driver;
  qsfp_slave_sequencer sequencer;
  qsfp_slave_monitor   monitor;
 
  // UVM automation macros for general components
  `uvm_component_utils(qsfp_slave_agent)

  virtual qsfp_slave_interface vif; 

  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
 
    if(get_is_active() == UVM_ACTIVE) begin
      driver = qsfp_slave_driver::type_id::create("driver", this);
      sequencer = qsfp_slave_sequencer::type_id::create("sequencer", this);
    end
 
    monitor = qsfp_slave_monitor::type_id::create("monitor", this);
    
    //Get vif and set to Driver /monitor
    if (!uvm_config_db#(virtual qsfp_slave_interface)::get(this, "", "vif", vif)) begin
      `uvm_fatal("build phase", "No virtual interface specified for this agent instance")
     end
    uvm_config_db#(virtual qsfp_slave_interface)::set( this, "sequencer", "vif", vif);
    uvm_config_db#(virtual qsfp_slave_interface)::set( this, "driver", "vif", vif);
    uvm_config_db#(virtual qsfp_slave_interface)::set( this, "monitor", "vif", vif);


  endfunction : build_phase
 
  // connect_phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      monitor.ap_seqitem_port.connect(sequencer.m_request_export);
    end
    
  endfunction : connect_phase
 
endclass : qsfp_slave_agent
