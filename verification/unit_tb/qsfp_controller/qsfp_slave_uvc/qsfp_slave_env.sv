// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SLAVE_ENV
`define QSFP_SLAVE_ENV

//QSFP slave ENV contains the QSFP slave agent and the QSFP registry component
//connecet QSFp block in connect phase 

class qsfp_slave_env extends uvm_env;
 
  qsfp_slave_agent qsfp_agent;
  qsfp_registry_component qsfp1;

  virtual qsfp_slave_interface vif;
  //imp  -> connect to agent. monport
  `uvm_component_utils(qsfp_slave_env)
     
  // new - constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    qsfp_agent = qsfp_slave_agent::type_id::create("qsfp_agent", this);
    qsfp1 = qsfp_registry_component::type_id::create(.name("qsfp1"), .parent(this));

    //uvm_config_db#(virtual qsfp_slave_interface)::set(null, "qsfp_tb_top.qsfp_slave_env.agent*", "VIRTUAL_INTERFACE", intf0);
    if (!uvm_config_db#(virtual qsfp_slave_interface)::get(this, "", "vif", vif)) begin
       `uvm_fatal("build phase", "No virtual interface specified for this env instance")
     end
     uvm_config_db#(virtual qsfp_slave_interface)::set( this, "qsfp_agent", "vif", vif);

 
  endfunction : build_phase
  
   //connect phase
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      //Connecting monitor analysis port with QSFP Registry component 
      qsfp_agent.monitor.ap_seqitem_port.connect(qsfp1.item_collected_export);
      if(qsfp_agent.get_is_active() == UVM_ACTIVE) begin
          qsfp_agent.sequencer.qsfp_registry = qsfp1;
      end
   endfunction: connect_phase
  //run phase
endclass : qsfp_slave_env

`endif // QSFP_SLAVE_ENV
