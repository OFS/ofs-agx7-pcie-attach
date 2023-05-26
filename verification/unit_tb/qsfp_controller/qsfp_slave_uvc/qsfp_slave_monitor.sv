// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SLAVE_MONITOR
`define QSFP_SLAVE_MONITOR
//Class: qsfp_slave_monitor
//       The slave monitor will receive the incoming transaction and send it to
//       the QSFP registry component outside the agent
//


class qsfp_slave_monitor extends uvm_monitor;
  `uvm_component_utils (qsfp_slave_monitor);
 
  // Virtual Interface
  virtual qsfp_slave_interface vif;

  uvm_analysis_port #(qsfp_slave_seq_item) ap_seqitem_port;

  function new (string name, uvm_component parent = null);
      super.new(name, parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap_seqitem_port = new("ap_seqitem_port", this);
      if(!uvm_config_db#(virtual qsfp_slave_interface)::get(this, "", "vif", vif))
         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
      qsfp_slave_seq_item _req_item, _read_item;
      super.run_phase(phase);
     
      forever begin
       @( posedge this.vif.clk);
        if((this.vif.write == 1) || (this.vif.read == 1) ) begin
        _req_item = qsfp_slave_seq_item::type_id::create ("_req_item",this);
        _req_item = create_req_item();
        //Send data object through the analysis port
        ap_seqitem_port.write(_req_item);
        @( this.vif.clk);
        wait(this.vif.waitrequest == 1'b0);
        if (this.vif.read == 1) begin  //Read operation
           $cast(_read_item, _req_item.clone());
             //read_from_mem_array();
           _read_item.qsfp_slv_pkt_type = QSFP_SLV_READ;
           _read_item.readdata = this.vif.readdata; 
           ap_seqitem_port.write(_read_item);//Complete Read packet  
        end
        end     
       end         //End of forever loop
  endtask :run_phase


  virtual function qsfp_slave_seq_item create_req_item();
       qsfp_slave_seq_item req_item = qsfp_slave_seq_item::type_id::create ("req_item",this);
       req_item.qsfp_slv_pkt_type  = this.vif.write? QSFP_SLV_WRITE : QSFP_SLV_RD_HDR;
       req_item.writedata = this.vif.writedata;
       req_item.byteenable = this.vif.byteenable;
       req_item.address = this.vif.address;
       req_item.read   = this.vif.read;
       req_item.write   = this.vif.write;
       return(req_item);
  endfunction 



endclass:qsfp_slave_monitor
`endif // QSFP_SLAVE_MONITOR
