// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef GUARD_ETHERNET_DIRECTED_SEQUENCE_UVM_SV
`define GUARD_ETHERNET_DIRECTED_SEQUENCE_UVM_SV


class ethernet_directed_sequence extends uvm_sequence #(`ETH_TRANSACTION_CLASS); 
  parameter PKT_CNT=25;
  `ETH_TRANSACTION_CLASS tx_xacts[PKT_CNT];
  base_seq base_seq;
  /** UVM object utility macro */
  `uvm_object_utils(ethernet_directed_sequence)
  tb_env   tb_env0;

  `uvm_declare_p_sequencer(`ETH_TRANSACTION_SQR)

ethernet_intermediate_env env;
  /** Class constructor */
  function new (string name = "ethernet_directed_sequence");
     super.new(name);
     get_tb_env();
  endfunction : new

  /** Raise an objection if this is the parent sequence */
  virtual task pre_body();
  uvm_phase phase;
  super.pre_body();
       phase = get_starting_phase();
  if (phase!=null) begin
    phase.raise_objection(this);
  end
  endtask: pre_body
  
  /** Drop an objection if this is the parent sequence */
  virtual task post_body();
  uvm_phase phase;
  super.post_body();
       phase = get_starting_phase();
  if (phase!=null) begin
    phase.drop_objection(this);
  end
  endtask: post_body
  
  virtual task body();
    super.body();
    `uvm_info("body", "Entered ...", UVM_LOW)
    `uvm_info("body", "EnteredDirected_SEQ ...", UVM_LOW)
  for(int i=0;i<PKT_CNT;i++)begin
      `uvm_do_with(tx_xacts[i], {byte_count inside {[1000:1400]}; address == 48'h112233445566; command_type == ETH_MAC_DATA_FRAME; }) 
    `uvm_info("body", "DATA_FRAME has finished", UVM_NONE)
    #1us;
  end

#100us;
    `uvm_info("body", "Exiting ...", UVM_DEBUG)
  endtask : body
//Accessing Env handle
  virtual function void get_tb_env();                
        uvm_component   env_seq;

        env_seq = uvm_top.find("uvm_test_top.tb_env0"); 
        assert(env_seq) else uvm_report_fatal("eth_dir_seq", "failed finding env"); 
        
        assert ($cast(tb_env0,env_seq)) else 
        uvm_report_fatal("ether_dir_seq", "failed in obtaining env!");
    endfunction

endclass : ethernet_directed_sequence 

`endif // GUARD_ETHERNET_DIRECTED_SEQUENCE_UVM_SV
