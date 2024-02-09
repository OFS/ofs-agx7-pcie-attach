// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef GUARD_ETHERNET_MAC_SB_CALLBACKS_SV 
 `define GUARD_ETHERNET_MAC_SB_CALLBACKS_SV 

/** 
 * Abstract: 
 * This class ethernet_mac_sb_callbacks is derived from Ethernet Txrx 
 * callback class. This class is instantiated in directed test class 
 * and is registered with the Ethernet MAC VIP class object. 
 * 
 */

 class ethernet_mac_sb_callbacks extends svt_ethernet_txrx_callback;
   svt_ethernet_link_transaction link_trans;
 
   /* Constructor method for the callback class */ 
   function new(string name = "ethernet_mac_sb_callbacks"); 
     super.new();
     this.link_trans = new();
   endfunction  
 
   virtual task svt_ethernet_txrx_fec_data_start(svt_ethernet_txrx driver,svt_ethernet_fec_transaction xact);
 
     static integer index = 0;
     svt_ethernet_fec_transaction_exception_list cust_exception_list;
     svt_ethernet_fec_transaction_exception      exception;
     
    
      index++;
      `uvm_info("svt_ethernet_txrx_fec_data_start", $sformatf("MAC FEC TRANSACTION INDEX =  %d.", index), UVM_LOW);
   endtask : svt_ethernet_txrx_fec_data_start

  /** Link Transaction callback task */
  virtual task svt_ethernet_txrx_link_transaction(svt_ethernet_txrx driver,ref svt_ethernet_link_transaction xact);

     xact =this.link_trans;
  /** This link_trans will get assigned with a user defined link transaction in the testcase file 
   * when non-default values are desired */

     `uvm_info("svt_ethernet_txrx_link_transaction", $sformatf("MAC_CL37_LINK_XACTION"), UVM_LOW);
     xact.print();
 endtask
 
 endclass : ethernet_mac_sb_callbacks 

`endif //GUARD_ETHERNET_MAC_SB_CALLBACKS_SV 
