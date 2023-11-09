// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//QSFP slave auto response sequence
//
class qsfp_slave_auto_response_sequence extends uvm_sequence#(qsfp_slave_seq_item);
  
  `uvm_object_utils(qsfp_slave_auto_response_sequence)
  `uvm_declare_p_sequencer(qsfp_slave_sequencer)
 
  function new (string name = "qsfp_slave_auto_response_sequence");
    super.new(name);
  endfunction
  
  task body();
    qsfp_slave_seq_item m_req,m_item;
    int  _readdata;
    forever begin
    p_sequencer.h_req_fifo.get(m_req);
    _readdata = p_sequencer.qsfp_registry.get_read_data(m_req.address,m_req.read);
    if (m_req.qsfp_slv_pkt_type == QSFP_SLV_RD_HDR)  begin
        `uvm_do_with(m_item,{ m_item.readdata == _readdata; })
    end
    end      //end of forever loop
   endtask
endclass : qsfp_slave_auto_response_sequence


