// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SLAVE_SEQUENCER
`define QSFP_SLAVE_SEQUENCER
//Class: qsfp_slave_sequencer
//
class qsfp_slave_sequencer extends uvm_sequencer#(qsfp_slave_seq_item);
 
   `uvm_sequencer_utils(qsfp_slave_sequencer)
   
    uvm_analysis_export #(qsfp_slave_seq_item) m_request_export;
    //Creating a TLM FIFO for receiving seq items from monitor and create an auto response sequence
    uvm_tlm_analysis_fifo #(qsfp_slave_seq_item)	h_req_fifo; 

    qsfp_registry_component qsfp_registry;
   
    function new (string name, uvm_component parent);
      super.new(name, parent);
      h_req_fifo = new("h_req_fifo", this);
      m_request_export = new("m_request_export", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("qsfp_slave_sequencer", $sformatf("BUILD PHASE from sequencer called"), UVM_LOW);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      m_request_export.connect(h_req_fifo.analysis_export);
    endfunction :connect_phase

endclass : qsfp_slave_sequencer

`endif // QSFP_SLAVE_SEQUENCER
