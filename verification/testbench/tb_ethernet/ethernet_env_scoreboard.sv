// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`uvm_analysis_imp_decl(_vip_tx)
`uvm_analysis_imp_decl(_dut_tx)
`uvm_analysis_imp_decl(_vip_rx)
`uvm_analysis_imp_decl(_dut_rx)

/** 
  * The scoreboard compares data transmitted from the VIP Tx and DUT Tx with the data received at DUT Rx and VIP Rx respectively. <br/>
  *
  */
   class ethernet_env_scoreboard extends uvm_scoreboard;

   /**
     * enable : Parameter to enable scoreboard. <br/>
     * Default Value: 1
     */
   bit enable;
   /**
     * Integer counters: <br/>
     * count_mismatch_tx: This is the nummber of data mismaches counter in 1 simulation. <br/>
     * This mismatch is between VIP Tx and DUT Rx. <br/>
     * This counter is displayed in scoreboard report. <br/>
     */
   int count_mismatch_tx;
   /**
     * Integer counters: <br/>
     * count_mismatch_rx: This is the nummber of data mismaches counter in 1 simulation. <br/>
     * This mismatch is between VIP Rx and DUT Tx. <br/>
     * This counter is displayed in scoreboard report. <br/>
     */
   int count_mismatch_rx;
   /**
     * Integer counters: <br/>
     * count_vip_tx: Number of Data Packets Transmitted by VIP.
     */
   int count_vip_tx;
   /**
     * Integer counters: <br/>
     * count_dut_tx: Number of Data Packets Transmitted by DUT.
     */
   int count_dut_tx;
   /**
     * Integer counters: <br/>
     * count_vip_rx: Number of Data Packets Received by VIP.
     */
   int count_vip_rx;
   /**
     * Integer counters: <br/>
     * count_dut_rx: Number of Data Packets Received by DUT.
     */
   int count_dut_rx;
  
   // -------------------------------------------------------------------------------------------------
   // Analysis Ports
   // -------------------------------------------------------------------------------------------------
   
   /**
     * Analysis port to collect data from tx side of vip.
     */
    uvm_analysis_imp_vip_tx #(`ETH_TRANSACTION_CLASS, ethernet_env_scoreboard) item_collected_vip_tx;
    uvm_component reporter = this;
   
   /**
     * Analysis port to collect data from tx side of DUT.
     */
     uvm_analysis_imp_dut_tx #(`ETH_TRANSACTION_CLASS, ethernet_env_scoreboard) item_collected_dut_tx;
   
   /**
     * Analysis port to collect data from rx side of vip.
     */
     uvm_analysis_imp_vip_rx #(`ETH_TRANSACTION_CLASS, ethernet_env_scoreboard) item_collected_vip_rx;
   
   /**
     * Analysis port to collect data from rx side of DUT.
     */
     uvm_analysis_imp_dut_rx #(`ETH_TRANSACTION_CLASS, ethernet_env_scoreboard) item_collected_dut_rx;
  
   /**
    * Queue to store transactions from vip TX side
    */
   `ETH_TRANSACTION_CLASS vip_tx_trans[$];
  
   /**
    * Queue to store transactions from DUT TX side
    */
   `ETH_TRANSACTION_CLASS dut_tx_trans[$];
  
   /**
    * Queue to store transactions from vip RX side
    */
   `ETH_TRANSACTION_CLASS vip_rx_trans[$];
  
   /**
    * Queue to store transactions from DUT RX side
    */
   `ETH_TRANSACTION_CLASS dut_rx_trans[$];
  
   /**
    * This event is triggered when the VIP transmits a data packet and is received in Scoreboard.
    */
   event vip_tx_get_event ; 
   /**
    * This event is triggered when the DUT transmits a data packet and is received in Scoreboard.
    */
   event dut_tx_get_event ; 
   /**
    * This event is triggered when the VIP receives a data packet and is received in Scoreboard.
    */
   event vip_rx_get_event ; 
   /**
    * This event is triggered when the DUT receives a data packet and is received in Scoreboard.
    */
   event dut_rx_get_event ;

   /** @cond PRIVATE */
   /**
    * This event is triggered when the Scoreboard finishes comparison of Tx packet.
    */
   event sb_compare_done_tx;

   /**
    * This event is triggered when the Scoreboard finishes comparison of Rx packet.
    */
   event sb_compare_done_rx;
   /** @endcond */
   
  /**
    * Counter to keep track of the number of packets droped from the VIP Tx queue. <br/>
    * This value is printed in the scoreboard report in the end. 
    */
   int packet_drop_vip_tx;
  
   /**
    * Counter to keep track of the number of packets droped from the VIP Rx queue. <br/>
    * This value is printed in the scoreboard report in the end. 
    */
   int packet_drop_vip_rx;
   // -------------------------------------------------------------------------------------------------
   // ovm utility
   // -------------------------------------------------------------------------------------------------
      `uvm_component_utils_begin(ethernet_env_scoreboard)
       `uvm_field_int(packet_drop_vip_tx, UVM_ALL_ON|UVM_DEC|UVM_NOPRINT)
       `uvm_field_int(packet_drop_vip_rx, UVM_ALL_ON|UVM_DEC|UVM_NOPRINT)
      `uvm_component_utils_end

   // ---------------------------------------------------------------------------------------------
   // new - constructor
   // ---------------------------------------------------------------------------------------------
   /**
     * This is the constructor of the scoreboard. <br/>
     * In this pahse a counters are initialized to 0.
     */
     extern function new (string name="ethernet_env_scoreboard", uvm_component parent=null);
   /**
     * This is the build phase of the Scoreboard. <br/>
     * All the analysis ports are created in this phase. 
     */
     extern function void build_phase(uvm_phase phase);
   
   /** This is the run phase of the Scoreboard. <br/>
     * The packet comparison tasks and packet drop tasks are porked in this phase.
     */
     extern task run_phase(uvm_phase phase);
   
   /**
    * This task compares the vip transactions transmitted and dut transactions received.
    */
   extern task vip_tx_dut_rx_comparator();
   
   /**
    * This task compares the dut transactions transmitted and vip transactions received.
    */
   extern task dut_tx_vip_rx_comparator();

   /**
     * The compare task compares the two transactions from TX and RX queue. <br/>
     * It prints out the data bytes which are mismached. <br/>
     * It prints a 'MATCHED' print if trsactions are matched.
     */
   extern function bit scb_compare(`ETH_TRANSACTION_CLASS tr,`ETH_TRANSACTION_CLASS pkt);
   
   extern task vip_tx_vip_rx_comparator(); //chavanvx
   /**
     * This is the report phase of Scoreboard.
     * In this phase the scoreboard report is printed.
     */
     extern virtual function void report_phase(uvm_phase phase);
   
   /**
     * The write function implementaions for the analysis port item_collected_vip_tx.
     */
     extern virtual function void write_vip_tx(`ETH_TRANSACTION_CLASS tr)      ;
   
   /**
     * The write function implementaions for the analysis port item_collected_dut_tx.
     */
     extern virtual function void write_dut_tx(`ETH_TRANSACTION_CLASS tr)      ;
   
   /**
     * The write function implementaions for the analysis port item_collected_vip_rx.
     */
     extern virtual function void write_vip_rx(`ETH_TRANSACTION_CLASS tr)      ;
   
   /**
     * The write function implementaions for the analysis port item_collected_dut_rx.
     */
     extern virtual function void write_dut_rx(`ETH_TRANSACTION_CLASS tr)      ;

   extern virtual function void drop_packet_vip_tx();

   /** 
     * The drop_packet_vip_rx is a function with flushes the latest data packet for comparison from the VIP Rx queue. <br/>
     * For details of the function refer to #drop_packet_vip_tx.
     */
   extern virtual function void drop_packet_vip_rx();

   /** 
     * The print_transaction is a function which prints the data frame accumulated in the transaction. <br/>
     */
   extern virtual function void print_transaction(`ETH_TRANSACTION_CLASS trans, bit [95:0] side = "VIP TX TRANS");
endclass

`protect
function ethernet_env_scoreboard::new (string name="ethernet_env_scoreboard", uvm_component parent=null);
    super.new(name, parent);
  enable=0;
  count_mismatch_tx=0;
  count_mismatch_rx=0;
  count_vip_tx=0;
  count_dut_tx=0;
  count_vip_rx=0;
  count_dut_rx=0;
endfunction : new

// -------------------------------------------------------------------------------------------------
task ethernet_env_scoreboard::run_phase(uvm_phase phase);
  begin
    fork
      //vip_tx_dut_rx_comparator();
      //dut_tx_vip_rx_comparator();
        vip_tx_vip_rx_comparator();
    join_none
  end
endtask

// ---------------------------------------------------------------------------------------------
function void ethernet_env_scoreboard::build_phase(uvm_phase phase);
   uvm_config_db #(bit)::get(this, "", "enable", enable);  
   `uvm_info("build_phase", $sformatf("SCOREBOARD ENABLE VALUE ::%b", enable), UVM_LOW);
      item_collected_vip_rx = new("item_collected_vip_tx", this);
      item_collected_dut_rx = new("item_collected_dut_tx", this);
      item_collected_vip_tx = new("item_collected_vip_rx", this);
      item_collected_dut_tx = new("item_collected_dut_rx", this);
endfunction
//-------------------------------------------------------------------------------------------------------
task ethernet_env_scoreboard::vip_tx_vip_rx_comparator();//chavanvx
  `ETH_TRANSACTION_CLASS      vip_tr;
  `ETH_TRANSACTION_CLASS      vip_rx;
  vip_tr=new();
  vip_rx=new();
   
   forever
     begin
       wait(vip_tx_trans.size > 0 && vip_rx_trans.size > 0); 
       vip_tr = vip_tx_trans.pop_front();
       vip_rx = vip_rx_trans.pop_front();
       print_transaction(vip_tr,"VIP TX TRANS"); 
       print_transaction(vip_rx,"VIP RX TRANS"); 
       
       if(!scb_compare(vip_tr,vip_rx))
         begin
          count_mismatch_tx++;
          `uvm_error("vip_tx_vip_rx_comparator",
            $sformatf("Tx Packet Id From vip %d Not Matched",vip_tr.packet_id ));
         end
       else
        `uvm_info("vip_tx_dut_rx_comparator",
           $psprintf("Tx Packet Id From vip %d Matched",vip_tr.packet_id ),UVM_LOW);
       -> sb_compare_done_tx;
     end
endtask // vip_tx_dut_rx_comparator


//-------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
task ethernet_env_scoreboard::vip_tx_dut_rx_comparator();
  `ETH_TRANSACTION_CLASS      vip_tr;
  `ETH_TRANSACTION_CLASS      dut_tr;
  vip_tr=new();
  dut_tr=new();
   
   forever
     begin
       wait(vip_tx_trans.size > 0 && dut_rx_trans.size > 0); 
       vip_tr = vip_tx_trans.pop_front();
       dut_tr = dut_rx_trans.pop_front();
       if(!scb_compare(vip_tr,dut_tr))
         begin
          count_mismatch_tx++;
          `uvm_error("vip_tx_dut_rx_comparator",
            $sformatf("Tx Packet Id From vip %d Not Matched",vip_tr.packet_id ));
         end
       else
        `uvm_info("vip_tx_dut_rx_comparator",
           $psprintf("Tx Packet Id From vip %d Matched",vip_tr.packet_id ),UVM_LOW);
       -> sb_compare_done_tx;
     end
endtask // vip_tx_dut_rx_comparator

//--------------------------------------------------------------------------------------------------
task ethernet_env_scoreboard::dut_tx_vip_rx_comparator();
  `ETH_TRANSACTION_CLASS      vip_tr;
  `ETH_TRANSACTION_CLASS      dut_tr;
  vip_tr=new();
  dut_tr=new();
  forever
    begin
      wait(vip_rx_trans.size > 0 && dut_tx_trans.size > 0);
      dut_tr = dut_tx_trans.pop_front();
      vip_tr = vip_rx_trans.pop_front();
      if(!scb_compare(vip_tr,dut_tr))
       begin
        count_mismatch_rx++;
        `uvm_error("dut_tx_vip_rx_comparator",
          $psprintf("Rx Packet Id From vip %d Not Matched",vip_tr.packet_id ));
       end
      else
       `uvm_info("dut_tx_vip_rx_comparator",
         $psprintf("Rx Packet Id From vip %d Matched",vip_tr.packet_id ),UVM_LOW);
      -> sb_compare_done_rx;
    end
endtask // dut_tx_vip_rx_comparator

// ------------------------------------------------------------------------------------------------
function bit ethernet_env_scoreboard::scb_compare(
                                              `ETH_TRANSACTION_CLASS tr,
                                              `ETH_TRANSACTION_CLASS pkt
                                              );
   //object of class nvs_eth_sv_mac_tans
   bit [7:0] rx_data,tx_data;
   int       loop_int;
   scb_compare = 1;
   
   loop_int = pkt.complete_data_frame.size();
   //for(int i=0;i<loop_int;i++)
   foreach(pkt.complete_data_frame[i])
    begin
     rx_data = pkt.complete_data_frame[i];
     tx_data = tr.complete_data_frame[i];
     if (rx_data !== tx_data) 
      begin
       `uvm_error("scb_compare",
         $psprintf("Frame Byte at location %d Mismatch:  TX byte := %h RX byte := %h.\n",i, rx_data, tx_data));
       scb_compare = 0;
      end
    end
endfunction: scb_compare
  
function void ethernet_env_scoreboard::report_phase(uvm_phase phase);
 if(enable) begin
  if(count_mismatch_tx || count_mismatch_rx) begin
    `uvm_info("scb_compare",
                    $psprintf("No Of Mismatch In Transactions = %d",count_mismatch_tx + count_mismatch_rx),UVM_LOW);
    end
  else    
    begin
  `uvm_info("report_phase",
                  $psprintf(" \n\
                       Scoreboard : ---------------------------------------------------------------------\n\
                       Scoreboard : NO mismatch in transaction object \n\
                       Scoreboard : ---------------------------------------------------------------------"),UVM_LOW) ;
     
    end               
  `uvm_info("report_phase",
                  $psprintf(" \n\
 ------------------------------------------------ \n\
| Scoreboard Report                              |\n\
 ------------------------------------------------ \n\
| Transactions transmitted by VIP    %5d       |\n\
| Transactions received    by DUT    %5d       |\n\
| Transactions received    by VIP    %5d       |\n\
| Transactions transmitted by DUT    %5d       |\n\
| Transactions dropped     by VIP Tx %5d       |\n\
| Transactions dropped     by VIP Rx %5d       |\n\
| Transactions Not Matched by VIP Tx %5d       |\n\
| Transactions Not Matched by VIP Rx %5d       |\n\
 ------------------------------------------------ ",
                            count_vip_tx, 
                            count_dut_rx,
                            count_vip_rx,
                            count_dut_tx,
                            packet_drop_vip_tx,
                            packet_drop_vip_rx,
                            count_mismatch_tx,count_mismatch_rx),UVM_LOW);
 end
 endfunction 
     
// ------------------------------------------------------------------------------------------------
 function void ethernet_env_scoreboard::write_vip_tx(`ETH_TRANSACTION_CLASS tr)      ;
  `ETH_TRANSACTION_CLASS trans_scoreboard;
  print_transaction(tr,"VIP TX TRANS");    
  if(enable) begin
     trans_scoreboard =new();
     trans_scoreboard.complete_data_frame = new[tr.complete_data_frame.size](tr.complete_data_frame);
     trans_scoreboard.packet_id = tr.packet_id; 
     vip_tx_trans.push_back(trans_scoreboard);
     trans_scoreboard = null; 
     count_vip_tx++;
     ->vip_tx_get_event;   
  end
 endfunction // write_vip_tx

// ------------------------------------------------------------------------------------------------
function void ethernet_env_scoreboard::write_dut_tx(`ETH_TRANSACTION_CLASS tr)      ;
     `ETH_TRANSACTION_CLASS trans_scoreboard;
  print_transaction(tr,"DUT TX TRANS");    
   if(enable) begin
     trans_scoreboard =new();
     trans_scoreboard.complete_data_frame = new[tr.complete_data_frame.size](tr.complete_data_frame);
     trans_scoreboard.packet_id = tr.packet_id; 
      dut_tx_trans.push_back(trans_scoreboard);
     trans_scoreboard = null; 
      count_dut_tx++;
      ->dut_tx_get_event;
   end
endfunction // write_dut_tx

// ------------------------------------------------------------------------------------------------
function void ethernet_env_scoreboard::write_vip_rx(`ETH_TRANSACTION_CLASS tr)      ;
     `ETH_TRANSACTION_CLASS trans_scoreboard;
  print_transaction(tr,"VIP RX TRANS");    
   if(enable) begin
     trans_scoreboard =new();
     trans_scoreboard.complete_data_frame = new[tr.complete_data_frame.size](tr.complete_data_frame);
     trans_scoreboard.packet_id = tr.packet_id; 
      vip_rx_trans.push_back(trans_scoreboard);
     trans_scoreboard = null; 
      count_vip_rx++;
      ->vip_rx_get_event;   
   end
endfunction // write_vip_rx


// ------------------------------------------------------------------------------------------------
function void ethernet_env_scoreboard::write_dut_rx(`ETH_TRANSACTION_CLASS tr)      ;
     `ETH_TRANSACTION_CLASS trans_scoreboard;
  print_transaction(tr,"DUT RX TRANS");    
   if(enable) begin
     trans_scoreboard =new();
     trans_scoreboard.complete_data_frame = new[tr.complete_data_frame.size](tr.complete_data_frame);
     trans_scoreboard.packet_id = tr.packet_id; 
      dut_rx_trans.push_back(trans_scoreboard);
     trans_scoreboard = null; 
      count_dut_rx++;
      ->dut_rx_get_event;
   end
endfunction // write_dut_rx
     
// ------------------------------------------------------------------------------------------------
function void ethernet_env_scoreboard::drop_packet_vip_tx();
  `ETH_TRANSACTION_CLASS trans_trash;
  if(vip_tx_trans.size == 0) begin
    `uvm_error("drop_packet_vip_tx",
      $psprintf("Drop packet for VIP Tx queue triggered when queue is empty: Nothing to pop"));
  end
  else begin
    trans_trash = vip_tx_trans.pop_front();
    `uvm_info("drop_packet_vip_tx",
                    $psprintf("Packet ID %d droped from VIP Tx queue",trans_trash.packet_id),UVM_LOW);
    packet_drop_vip_tx = packet_drop_vip_tx + 1; 
  end
endfunction

// ------------------------------------------------------------------------------------------------
function void ethernet_env_scoreboard::drop_packet_vip_rx();
  `ETH_TRANSACTION_CLASS trans_trash;
  if(vip_rx_trans.size == 0) begin
    `uvm_error("drop_packet_vip_rx",
      $psprintf("Drop packet for VIP Rx queue triggered when queue is empty: Nothing to pop"));
  end
  else begin
    trans_trash = vip_rx_trans.pop_front();
    `uvm_info("drop_packet_vip_rx",
                    $psprintf("Packet ID %d droped from VIP Rx queue",trans_trash.packet_id),UVM_LOW);
    packet_drop_vip_rx = packet_drop_vip_rx + 1; 
  end
endfunction


// ------------------------------------------------------------------------------------------------
function void ethernet_env_scoreboard::print_transaction(`ETH_TRANSACTION_CLASS trans,bit [95:0] side = "VIP TX TRANS");
  reg [79:0] print_buffer;
  bit [7:0] temp_buffer_reg;
  int temp_pointer;
  bit [11:0] column_length; 
  string print_message;

  print_message = {print_message,"\n"};
  print_message = {print_message,"+-----+--+--+--+--+--+--+--+--+--+--+\n"};
  print_message = {print_message,$psprintf("|           %s            |\n",side)};
  print_message = {print_message,"+-----+--+--+--+--+--+--+--+--+--+--+\n"};
  print_message = {print_message,$psprintf("| Source Add   :   %h     |\n",trans.source_address_mac)};
  print_message = {print_message,$psprintf("| Dest.  Add   :   %h     |\n",trans.destination_address_mac)};
  print_message = {print_message,"+-----+--+--+--+--+--+--+--+--+--+--+\n"};
  print_message = {print_message,"| NDX | 0| 1| 2| 3| 4| 5| 6| 7| 8| 9|\n"};
  print_message = {print_message,"+-----+--+--+--+--+--+--+--+--+--+--+\n"};
  foreach(trans.complete_data_frame[i]) begin
    temp_buffer_reg = trans.complete_data_frame[i];
    print_buffer = {temp_buffer_reg,print_buffer[79:8]};
    temp_pointer = temp_pointer + 1;

    if(i == (trans.complete_data_frame.size() - 1)) begin
      while(temp_pointer != 10) begin
        print_buffer = {8'hxx,print_buffer[79:8]};
        temp_pointer = temp_pointer + 1;
      end
      print_message = {print_message,$psprintf("|%d |%h|%h|%h|%h|%h|%h|%h|%h|%h|%h|\n",column_length,
                                                                                       print_buffer[7:0],
                                                                                       print_buffer[15:8],
                                                                                       print_buffer[23:16],
                                                                                       print_buffer[31:24],
                                                                                       print_buffer[39:32],
                                                                                       print_buffer[47:40],
                                                                                       print_buffer[55:48],
                                                                                       print_buffer[63:56],
                                                                                       print_buffer[71:64], 
                                                                                       print_buffer[79:72])}; 
    end
    else begin
      if(temp_pointer == 10) begin
        print_message = {print_message,$psprintf("|%d |%h|%h|%h|%h|%h|%h|%h|%h|%h|%h|\n",column_length,
                                                                                         print_buffer[7:0],
                                                                                         print_buffer[15:8],
                                                                                         print_buffer[23:16],
                                                                                         print_buffer[31:24],
                                                                                         print_buffer[39:32],
                                                                                         print_buffer[47:40],
                                                                                         print_buffer[55:48],
                                                                                         print_buffer[63:56],
                                                                                         print_buffer[71:64], 
                                                                                         print_buffer[79:72])}; 
        temp_pointer = 0;
        print_buffer = {80{1'bx}};
        column_length = column_length + 1;
      end
    end  
  end  
  print_message = {print_message,"+-----+--+--+--+--+--+--+--+--+--+--+\n"};
  `uvm_info("print_transaction",$psprintf("%s",print_message),UVM_LOW);
endfunction

`endprotect
//************************ END OF FILE ********************************
