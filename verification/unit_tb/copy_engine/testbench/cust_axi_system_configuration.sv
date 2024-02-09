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



`ifndef CUST_AXI_SYSTEM_CONFIGURATION_SVH
`define CUST_AXI_SYSTEM_CONFIGURATION_SVH

class cust_axi_system_configuration extends `AXI_SYS_CFG_CLASS;
    `uvm_object_utils(cust_axi_system_configuration)

    function new(string name = "cust_axi_system_configuration");
        super.new(name);

	this.num_masters = `NUM_MASTERS;
	this.num_slaves  = `NUM_SLAVES;

	this.create_sub_cfgs(`NUM_MASTERS, `NUM_SLAVES);

	this.master_cfg[ HIA_AXI4_ST_MST  ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
	this.master_cfg[HSSI_AXI4_ST_MST_0].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
	this.master_cfg[HSSI_AXI4_ST_MST_1].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
	this.master_cfg[HSSI_AXI4_ST_MST_2].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
	this.master_cfg[PMCI_AXI4_LT_MST  ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;
	this.master_cfg[HSSI_AXI4_LT_MST  ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;

	this.slave_cfg[ HIA_AXI4_ST_SLV   ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
	this.slave_cfg[HSSI_AXI4_ST_SLV_0 ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
	this.slave_cfg[HSSI_AXI4_ST_SLV_1 ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
	this.slave_cfg[HSSI_AXI4_ST_SLV_2 ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
	this.slave_cfg[PMCI_AXI4_LT_SLV   ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;
	this.slave_cfg[ HIA_AXI4_LT_SLV   ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;

        this.master_cfg[PMCI_AXI4_LT_MST  ].awlen_enable   = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].arlen_enable   = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].awsize_enable  = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].arsize_enable  = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].awburst_enable = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].arburst_enable = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].awlock_enable  = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].arlock_enable  = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].awcache_enable = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].arcache_enable = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].wlast_enable   = 0;
        this.master_cfg[PMCI_AXI4_LT_MST  ].rlast_enable   = 0;  	

        this.master_cfg[HSSI_AXI4_LT_MST].awlen_enable = 0 ;
        this.master_cfg[HSSI_AXI4_LT_MST].arlen_enable = 0 ;
        this.master_cfg[HSSI_AXI4_LT_MST].awsize_enable = 0 ;
        this.master_cfg[HSSI_AXI4_LT_MST].arsize_enable = 0;
        this.master_cfg[HSSI_AXI4_LT_MST].awburst_enable = 0;
        this.master_cfg[HSSI_AXI4_LT_MST].arburst_enable = 0;
        this.master_cfg[HSSI_AXI4_LT_MST].awlock_enable = 0 ;
        this.master_cfg[HSSI_AXI4_LT_MST].arlock_enable = 0 ;
        this.master_cfg[HSSI_AXI4_LT_MST].awcache_enable = 0 ;
        this.master_cfg[HSSI_AXI4_LT_MST].arcache_enable = 0;
        this.master_cfg[HSSI_AXI4_LT_MST].wlast_enable = 0 ;
        this.master_cfg[HSSI_AXI4_LT_MST].rlast_enable = 0 ;  	

        this.slave_cfg[PMCI_AXI4_LT_SLV].awlen_enable = 0 ;
        this.slave_cfg[PMCI_AXI4_LT_SLV].arlen_enable = 0 ;
        this.slave_cfg[PMCI_AXI4_LT_SLV].awsize_enable = 0 ;
        this.slave_cfg[PMCI_AXI4_LT_SLV].arsize_enable = 0;
        this.slave_cfg[PMCI_AXI4_LT_SLV].awburst_enable = 0;
        this.slave_cfg[PMCI_AXI4_LT_SLV].arburst_enable = 0;
        this.slave_cfg[PMCI_AXI4_LT_SLV].awlock_enable = 0 ;
        this.slave_cfg[PMCI_AXI4_LT_SLV].arlock_enable = 0 ;
        this.slave_cfg[PMCI_AXI4_LT_SLV].awcache_enable = 0 ;
        this.slave_cfg[PMCI_AXI4_LT_SLV].arcache_enable = 0;
        this.slave_cfg[PMCI_AXI4_LT_SLV].wlast_enable = 0 ;
        this.slave_cfg[PMCI_AXI4_LT_SLV].rlast_enable = 0 ;  	

        this.slave_cfg[ HIA_AXI4_LT_SLV].awlen_enable = 0 ;
        this.slave_cfg[ HIA_AXI4_LT_SLV].arlen_enable = 0 ;
        this.slave_cfg[ HIA_AXI4_LT_SLV].awsize_enable = 0 ;
        this.slave_cfg[ HIA_AXI4_LT_SLV].arsize_enable = 0;
        this.slave_cfg[ HIA_AXI4_LT_SLV].awburst_enable = 0;
        this.slave_cfg[ HIA_AXI4_LT_SLV].arburst_enable = 0;
        this.slave_cfg[ HIA_AXI4_LT_SLV].awlock_enable = 0 ;
        this.slave_cfg[ HIA_AXI4_LT_SLV].arlock_enable = 0 ;
        this.slave_cfg[ HIA_AXI4_LT_SLV].awcache_enable = 0 ;
        this.slave_cfg[ HIA_AXI4_LT_SLV].arcache_enable = 0;
        this.slave_cfg[ HIA_AXI4_LT_SLV].wlast_enable = 0 ;

	this.master_cfg[ HIA_AXI4_ST_MST  ].is_active = 1;
	this.master_cfg[ HIA_AXI4_ST_MST  ].tdata_width = 512;
	this.master_cfg[ HIA_AXI4_ST_MST  ].tuser_width = 5;
	this.master_cfg[HSSI_AXI4_ST_MST_0].is_active = 1;
	this.master_cfg[HSSI_AXI4_ST_MST_1].is_active = 1;
	this.master_cfg[HSSI_AXI4_ST_MST_2].is_active = 1;
	this.master_cfg[PMCI_AXI4_LT_MST  ].is_active = 1;
	this.master_cfg[HSSI_AXI4_LT_MST  ].is_active = 1;

	this.slave_cfg[ HIA_AXI4_ST_SLV   ].is_active = 1;
	this.slave_cfg[HSSI_AXI4_ST_SLV_0 ].is_active = 1;
	this.slave_cfg[HSSI_AXI4_ST_SLV_1 ].is_active = 1;
	this.slave_cfg[HSSI_AXI4_ST_SLV_2 ].is_active = 1;
	this.slave_cfg[PMCI_AXI4_LT_SLV   ].is_active = 1;
	this.slave_cfg[ HIA_AXI4_LT_SLV   ].is_active = 1;

    endfunction : new

endclass : cust_axi_system_configuration

`endif // CUST_AXI_SYSTEM_CONFIGURATION_SVH
