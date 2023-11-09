// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef GUARD_ETHERNET_MAC_MONITOR_CALLBACKS_SV 
`define GUARD_ETHERNET_MAC_MONITOR_CALLBACKS_SV 

/** 
 * Abstract: 
 * This class ethernet_mac_monitor_callbacks is derived from Ethernet Monitor 
 * callback class. This class is instantiated in class ethernet_env 
 * and is registered with the Ethernet MAC VIP class object. 
 * 
 */

 class ethernet_mac_monitor_callbacks extends svt_ethernet_monitor_callback;
   /* Constructor method for the callback class */ 
   function new(string name = "ethernet_mac_monitor_callbacks"); 
     super.new();
   endfunction 

  virtual function void port_tx_mac_transaction_cov(svt_ethernet_monitor monitor, `ETH_TRANSACTION_CLASS xact);
    static integer index=0;
    index ++;
    `uvm_info("port_tx_mac_transaction_cov", $psprintf(" TX monitor callback =  %d ", index), UVM_LOW);
  endfunction

endclass
`endif //GUARD_ETHERNET_MAC_MONITOR_CALLBACKS_SV
