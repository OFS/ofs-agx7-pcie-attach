//=======================================================================
// COPYRIGHT (C) 2013 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * This file contains the class extended from `ETH_AGENT_CFG_CLASS class.
 * Here the user has customized the configuration parameters as per test case requirement.
 * Additionally, the class encapsulates the configuration for the GMII interface
*/

`ifndef GUARD_CUST_ETHERNET_CONFIGURATION_SV
`define GUARD_CUST_ETHERNET_CONFIGURATION_SV

class cust_ethernet_agent_configuration extends `ETH_AGENT_CFG_CLASS;

  /** UVM object utility macro */
  `uvm_object_utils_begin(cust_ethernet_agent_configuration)
  `uvm_object_utils_end


  /** Class constructor */
  function new(string name ="cust_ethernet_agent_configuration" );
    super.new(name);
  endfunction

  /** Function to Set the configuration values for GMII */
  function void set_gmii_default_cfg();
    /** Set the Interface Type :: GMII */
    interface_select = ETH_GMII;
  /** Enable functional coverage for Frame Transactions */
    enable_mac_transaction_cov = 1'b1;
    `uvm_info("set_gmii_default_cfg", $sformatf("GMII_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for 25 G */
  function void set_25g_serial_default_cfg();
    /** Set the Interface Type :: 25G SERIAL */
    interface_select = ETH_25G_SERIAL;
   /** Enable functional coverage for Frame Transactions */
    //enable_mac_transaction_cov = 1'b1;
   /** Enabling IEEE By standard  by setting the below cfg attribute to 0 */
   enable_xxvsbi_lsbi_consortium_mode =0;
    `uvm_info("set_25g_serial_default_cfg", $sformatf("25G_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for 25 G */
  function void set_xxvgmii_default_cfg();
    /** Set the Interface Type :: XXVGMII */
    interface_select = ETH_XXVGMII_128B;
  /** Enable functional coverage for Frame Transactions */
    enable_mac_transaction_cov = 1'b1;
    `uvm_info("set_xxvgmii_serial_default_cfg", $sformatf("XXVGMII_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction
  
  /** Function to Set the configuration values for 50 G */
  function void set_50g_serial_default_cfg();
    /** Set the Interface Type :: 50 G SERIAL */
    interface_select = ETH_50G_SERIAL;
  /** Enable functional coverage for Frame Transactions */
    enable_mac_transaction_cov = 1'b1;
   enable_xxvsbi_lsbi_consortium_mode =0;
    `uvm_info("set_50g_serial_default_cfg", $sformatf("50G_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for 50 G */
  function void set_lgmii_default_cfg();
    /** Set the Interface Type :: LGMII */
    interface_select = ETH_LGMII;
  /** Enable functional coverage for Frame Transactions */
    enable_mac_transaction_cov = 1'b1;
    `uvm_info("set_lgmii_default_cfg", $sformatf("LGMII_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for 25 G */
  function void set_25g_parallel_default_cfg();
    /** Set the Interface Type :: GMII */
    interface_select = ETH_25G_PARALLEL;
    /** Enable functional coverage for Frame Transactions */
    enable_mac_transaction_cov = 1'b1;
   /** Enabling IEEE By standard  by setting the below cfg attribute to 0 */
   enable_xxvsbi_lsbi_consortium_mode =0;

   /** Enabling Parallel interfaces */
   enable_vip_parallel_interface_width_configurable = 1;
    `uvm_info("set_25g_parallel_default_cfg", $sformatf("25G_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction
  
  /** Function to Set the configuration values for 50 G */
  function void set_50g_parallel_default_cfg();
    /** Set the Interface Type :: GMII */
    interface_select = ETH_50G_PARALLEL;
    /** Enable functional coverage for Frame Transactions */
    enable_mac_transaction_cov = 1'b1;
    `uvm_info("set_50g_parallel_default_cfg", $sformatf("50G_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction
  
  /** Function to Set the configuration values for MII */
  function void set_mii_default_cfg();
    /** Set the Interface Type :: MII 100M 4 BIT*/
    interface_select = ETH_MII_100M_4BIT;
    `uvm_info("set_mii_default_cfg", $sformatf("MII_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for RGMII */
  function void set_rgmii_default_cfg();
    /** Set the Interface Type :: RGMII 1G */
    interface_select = ETH_RGMII;
    `uvm_info("set_rgmii_default_cfg", $sformatf("RGMII_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for XGMII */
  function void set_xgmii_default_cfg();
    /** Set the Interface Type :: XGMII SDR */
    interface_select = ETH_XGMII_SDR;
    `uvm_info("set_xgmii_default_cfg", $sformatf("XGMII_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for XLGMII */
  function void set_xlgmii_default_cfg();
    /** Set the Interface Type :: XLGMII */
     interface_select = ETH_XLGMII;
    `uvm_info("set_xlgmii_default_cfg", $sformatf("XLGMII_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for CGMII 64-bit Interface*/
  function void set_cgmii_default_cfg();
    /** Set the Interface Type :: CGMII */
    interface_select = ETH_CGMII;
    `uvm_info("set_cgmii_default_cfg", $sformatf("CGMII_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for XAUI */
  function void set_xaui_default_cfg();
    /** Set the Interface Type :: XAUI */
    interface_select = ETH_10G_BASEX_1BIT;
    `uvm_info("set_xaui_default_cfg", $sformatf("XAUI_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for CAUI */
  function void set_caui_default_cfg();
    /** Set the Interface Type :: CAUI */
    interface_select = ETH_CAUI;
    `uvm_info("set_caui_default_cfg", $sformatf("CAUI_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for CSBI (20 lane interface) */
  function void set_csbi_default_cfg();
    /** Set the Interface Type :: CSBI */
    interface_select = ETH_CSBI;
    /** Enable functional coverage for Frame Transactions */
    enable_mac_transaction_cov = 1'b1;
    `uvm_info("set_csbi_default_cfg", $sformatf("CSBI_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction
function void set_ETH_CSBI_4_LANE_cfg();
    /** Set the Interface Type :: CSBI */
    interface_select = ETH_CSBI_4_LANE;
    /** Enable functional coverage for Frame Transactions */
   // enable_mac_transaction_cov = 1'b1;
   enable_vip_parallel_interface_width_configurable = 1;
    `uvm_info("set_ETH_CSBI_4_LANE_cfg", $sformatf("set_ETH_CSBI_4_LANE =  %d.", interface_select), UVM_LOW);
  endfunction
 

  /** Function to Set the configuration values for KR interface */
  function void set_kr_default_cfg();
    /** Set the Interface Type :: KR */
    interface_select = ETH_XSBI_SERIAL;
    /** Enabling fec */
   // enable_fec = 1; 
    `uvm_info("set_kr_default_cfg", $sformatf("XSBI_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for AN Clause 37 */
  function void set_an_cl37_default_cfg();
    /** Set the Interface Type :: SGMII 1G & AN_CL37 */
    interface_select = ETH_1G_BASEX_1BIT;
    enable_an37_mode = 1'b1;
    enable_an37_reneg = 1'b0;
    `uvm_info("set_an_cl37_default_cfg", $sformatf("AN_CL37_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction

  /** Function to Set the configuration values for AN Clause 73 */
  function void set_an_cl73_default_cfg();
   enable_xxvsbi_lsbi_consortium_mode =0;
    /** Set the Interface Type :: AN_CL73 */
    interface_select = ETH_AN_CL73;
    enable_fec = 2'h0;
    enable_an73_reneg = 0;
    `uvm_info("set_an_cl73_default_cfg", $sformatf("AN_CL73_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction
 
  /** Function to Set the configuration values for 400G Serial*/
  function void set_400g_serial_8_lane_default_cfg();
  /** Set the Interface Type :: 400G Serial with 8 Lanes */
    //interface_select = ETH_400G_SERIAL_8_LANE;
    interface_select = ETH_400G_SERIAL;
  /** Enable functional coverage for Frame Transactions */
    //enable_mac_transaction_cov = 1'b1;
    `uvm_info("set_400g_serial_default_cfg", $sformatf("400G_8_LANES_INTF_SEL =  %d.", interface_select), UVM_LOW);
  endfunction


endclass
`endif //GUARD_CUST_ETHERNET_CONFIGURATION_SV
