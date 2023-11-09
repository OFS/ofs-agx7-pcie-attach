// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef GUARD_ETHERNET_MAC_SB_CALLBACKS_ERR_SV 
 `define GUARD_ETHERNET_MAC_SB_CALLBACKS_ERR_SV 

/** 
 * Abstract: 
 * This class ethernet_mac_crc_err_inject_callback is derived from Ethernet Txrx 
 * callback class. This class is instantiated in class ethernet_env 
 * and is registered with the Ethernet MAC VIP class object. 
 * 
 * This callback class is used to inject CRC error in the MAC agent frames
 */

 class ethernet_mac_crc_err_inject_callback extends svt_ethernet_txrx_callback;
 
 
   /* Constructor method for the callback class */ 
   function new(string name = "ethernet_mac_crc_err_inject_callback"); 
     super.new();
   endfunction  
 
   
   virtual task svt_ethernet_txrx_post_get ( svt_ethernet_txrx    driver,
 					     `ETH_TRANSACTION_CLASS   xact);

    static integer index=0;
    svt_ethernet_transaction_exception_list cust_exception_list;
    svt_ethernet_transaction_exception      exception;
      
    
       index++;
       /** Create the exception class */
       exception = new("cust_exception");

       /** Create the exception list */
       cust_exception_list = new("cust_exception_list",exception);

       /** Assign the type of error to be inserted in exception class */
       exception.error_kind = svt_ethernet_transaction_exception::FRAME_ERROR_KIND;
       exception.frame_error_kind = svt_ethernet_transaction_exception::FRAME_INCORRECT_FCS;
       exception.frame_incorrect_fcs_error = 32'h77778888;
       cust_exception_list.add_exception(exception);

       /** Write the handle of the exception list on the trans class handle */
       xact.exception_list = cust_exception_list;
       `uvm_info("svt_ethernet_txrx_post_get", $sformatf("ERROR_FRAME INDEX =  %d.", index), UVM_LOW);
       xact.print();
   endtask : svt_ethernet_txrx_post_get
 
 endclass : ethernet_mac_crc_err_inject_callback 


`endif //GUARD_ETHERNET_MAC_SB_CALLBACKS_ERR_SV 
