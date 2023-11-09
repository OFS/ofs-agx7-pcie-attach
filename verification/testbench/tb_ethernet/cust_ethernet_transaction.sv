// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

/** 
 * Abstract:
 * This file defines a class that represents a customized transaction class 
 * which is extended from `ETH_TRANSACTION_CLASS class. This extended class
 * adds pre-defined fields which are used as distribution weights to constrain 
 * frame type field in the transactions, and adds constraints on  frame type and 
 * address fields. The default transaction instance of the generator is 
 * replaced by an instance of this class in random test cases.
 */

`ifndef GUARD_CUST_ETHERNET_TRANSACTION_SV
`define GUARD_CUST_ETHERNET_TRANSACTION_SV 

class cust_ethernet_transaction extends `ETH_TRANSACTION_CLASS ;

  /* Weights used to control the frame type value */
  int mac_data_frame_wt     = 50; 
  int mac_vlan_frame_wt     = 50;  
  
  /** 
   * UVM object utility macro which implements the create() and get_type_name() methods. 
   * Field macros registeration provides default implementation of utility functions, 
   * print() & copy().
  */
  /** UVM object utility macro */
  `uvm_object_utils_begin(cust_ethernet_transaction)
    `uvm_field_int(mac_data_frame_wt, UVM_PRINT | UVM_COPY)
    `uvm_field_int(mac_vlan_frame_wt, UVM_PRINT | UVM_COPY)
  `uvm_object_utils_end

   constraint cmd_type {
       command_type dist {ETH_MAC_DATA_FRAME := this.mac_data_frame_wt,
                        ETH_MAC_VLAN_FRAME := this.mac_vlan_frame_wt, ETH_MAC_JUMBO_DATA_FRAME := this.mac_vlan_frame_wt};
     //SNPS address  == 48'h001122334455;
   }

  /** Class constructor */
  function new(string name ="cust_ethernet_transaction" );
    super.new(name);
    //this.reasonable_address.constraint_mode(0);
    this.reasonable_command_type.constraint_mode(0);
   endfunction

endclass
`endif // GUARD_CUST_ETHERNET_TRANSACTION_SV
 
