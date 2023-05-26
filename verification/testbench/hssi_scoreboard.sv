// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef HSSI_SCOREBOARD
`define HSSI_SCOREBOARD

`uvm_analysis_imp_decl(_axi_port_tx_hssi)
`uvm_analysis_imp_decl(_axi_port_rx_hssi)

class hssi_scoreboard extends uvm_scoreboard;

    `AXI_TRANSACTION_CLASS axi_tx_trans;
    `AXI_TRANSACTION_CLASS axi_rx_trans;
    
   // int count_mismatch_tx;
  //  bit enable;
    bit[63:0] axi_payload_tx_q[$];
    bit[63:0] axi_payload_rx_q[$];
    bit[63:0] axi_payload1;
    bit[63:0] axi_payload2;
    bit[31:0] awlength;
    bit [1:0] cnt= 1;

    `uvm_component_utils(hssi_scoreboard)

     //Port from axi interface
     uvm_analysis_imp_axi_port_tx_hssi#(`AXI_TRANSACTION_CLASS, hssi_scoreboard) axi_port_tx_hssi;
     uvm_analysis_imp_axi_port_rx_hssi#(`AXI_TRANSACTION_CLASS, hssi_scoreboard) axi_port_rx_hssi;


     //TLM FIFO for axi rx and tx
      uvm_tlm_analysis_fifo #(`AXI_TRANSACTION_CLASS) axi_tx_fifo;
      uvm_tlm_analysis_fifo #(`AXI_TRANSACTION_CLASS) axi_rx_fifo;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new


   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      axi_port_tx_hssi  = new("axi_port_tx_hssi", this);
      axi_port_rx_hssi  = new("axi_port_rx_hssi", this);
      axi_tx_fifo     = new("axi_tx_fifo", this);
      axi_rx_fifo     = new("axi_rx_fifo", this);
      // uvm_config_db #(bit)::get(this, "", "enable", enable);  
   //`uvm_info(get_type_name(), $sformatf("SCOREBOARD ENABLE VALUE ::%b", enable), UVM_LOW);
   endfunction : build_phase

 function void write_axi_port_tx_hssi(`AXI_TRANSACTION_CLASS trans);
    $cast(axi_tx_trans , trans.clone());
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from AXI Lite slave ENV \n %s",axi_tx_trans.sprint()),UVM_LOW)
    axi_tx_fifo.write(axi_tx_trans);
 endfunction // write_axi_port_tx_hssi

function void write_axi_port_rx_hssi(`AXI_TRANSACTION_CLASS trans);
    $cast(axi_rx_trans , trans.clone());
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from AXI Lite master ENV \n %s",axi_rx_trans.sprint()),UVM_LOW)
    axi_rx_fifo.write(axi_rx_trans);
endfunction // write_axi_port_rx_hssi


task run_phase(uvm_phase phase);
    `AXI_TRANSACTION_CLASS axi_tx_pkt;
    `AXI_TRANSACTION_CLASS axi_rx_pkt;   
    int i;
    int check_counter=0; 
    super.run_phase(phase);
   
    forever begin
     axi_tx_fifo.get(axi_tx_pkt);
        if(axi_tx_pkt.transmitted_channel == (`AXI_TRANSACTION_CLASS::DATA_STREAM)) begin
         // awlength = axi_tx_pkt.burst_length;
          for (i=0; i<=64; i= i+1) begin
            axi_payload_tx_q.push_back(axi_tx_pkt.tdata[i]);
           `uvm_info(get_type_name(), $sformatf("AXI PAYLOAD TX: `h%h", axi_tx_pkt.tdata[i]), UVM_LOW);
           `uvm_info(get_type_name(), $sformatf("AXI PAYLOAD TX Q: %p", axi_payload_tx_q), UVM_LOW);
          end
        end
     axi_rx_fifo.get(axi_rx_pkt);
        if(axi_rx_pkt.transmitted_channel == (`AXI_TRANSACTION_CLASS::DATA_STREAM)) begin
         // awlength = axi_rx_pkt.burst_length;
          for (i=0; i<=64; i= i+1) begin
            axi_payload_rx_q.push_back(axi_rx_pkt.tdata[i]);
           `uvm_info(get_type_name(), $sformatf("AXI PAYLOAD RX: `h%h", axi_rx_pkt.tdata[i]), UVM_LOW); 
            `uvm_info(get_type_name(), $sformatf("AXI PAYLOAD RX Q: %p", axi_payload_rx_q), UVM_LOW);

          end
         // compare_data();
         end
     //compare_data();
     check_counter++;
    
    begin
    `uvm_info(get_type_name(),$sformatf(" FOREACH COUNTER = %d \n",check_counter),UVM_LOW)
    compare_data();
    end
    end

   endtask:run_phase

 function compare_data;
     bit [63:0] exp_data, obs_data;     
       
     while (axi_payload_tx_q.size()!==0 && axi_payload_rx_q.size()!==0) begin
          `uvm_info(get_type_name(),$sformatf(" AXI TX DATA SIZE = \n %h",axi_payload_tx_q.size()),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf(" AXI RX DATA SIZE = \n %h",axi_payload_rx_q.size()),UVM_LOW)
          exp_data = axi_payload_tx_q.pop_front();
          obs_data = axi_payload_rx_q.pop_front();
          if (exp_data == obs_data) begin
             `uvm_info(get_type_name(),$sformatf("HSSI DATA MATCHED EXP_DATA = 'h%h: OBS_DATA = `h%h", exp_data, obs_data),UVM_LOW);
          end 
          else begin
             `uvm_error(get_type_name(), $sformatf("HSSI DATA MISMATCHED EXP_DATA = `h%h, OBS_DATA = `h%h ",exp_data, obs_data));
          end
       end
   endfunction : compare_data

endclass: hssi_scoreboard

`endif // HSSI_SCOREBOARD
