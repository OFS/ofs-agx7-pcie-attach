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


`ifndef CUST_AXIL2MMIO_SYSTEM_CONFIGURATION_SVH
`define CUST_AXIL2MMIO_SYSTEM_CONFIGURATION_SVH

class cust_axil2mmio_system_configuration extends `AXI_SYS_CFG_CLASS;
    `uvm_object_utils(cust_axil2mmio_system_configuration)

    function new(string name = "cust_axil2mmio_system_configuration");
        super.new(name);

	this.num_masters = 2; //One AXI Lite and One AXI-MM Master in each AXIL2MMIO bridge
	this.num_slaves  = 2; //One AXI Lite and One AXI-MM Slave in each AXIL2MMIO bridge

	this.create_sub_cfgs(2,2);

      for(int i=0; i<this.num_masters; i++)begin
	if(i == 0)begin
	  this.master_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;
          this.master_cfg[i].transaction_coverage_enable = 0;
          this.master_cfg[i].awlen_enable = 0 ;
          this.master_cfg[i].arlen_enable = 0 ;
          this.master_cfg[i].awsize_enable = 0 ;
          this.master_cfg[i].arsize_enable = 0;
          this.master_cfg[i].awburst_enable = 0;
          this.master_cfg[i].arburst_enable = 0;
          this.master_cfg[i].awlock_enable = 0 ;
          this.master_cfg[i].arlock_enable = 0 ;
          this.master_cfg[i].awcache_enable = 0 ;
          this.master_cfg[i].arcache_enable = 0;
          this.master_cfg[i].wlast_enable = 0 ;
          this.master_cfg[i].rlast_enable = 0 ;  	
	  this.master_cfg[i].is_active = 0;
          this.master_cfg[i].addr_width = 21;
          this.master_cfg[i].data_width = 64;
          this.master_cfg[i].id_width = 0;

	  this.slave_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;
          this.slave_cfg[i].transaction_coverage_enable = 0;
          this.slave_cfg[i].awlen_enable = 0 ;
          this.slave_cfg[i].arlen_enable = 0 ;
          this.slave_cfg[i].awsize_enable = 0 ;
          this.slave_cfg[i].arsize_enable = 0;
          this.slave_cfg[i].awburst_enable = 0;
          this.slave_cfg[i].arburst_enable = 0;
          this.slave_cfg[i].awlock_enable = 0 ;
          this.slave_cfg[i].arlock_enable = 0 ;
          this.slave_cfg[i].awcache_enable = 0 ;
          this.slave_cfg[i].arcache_enable = 0;
          this.slave_cfg[i].wlast_enable = 0 ;
          this.slave_cfg[i].rlast_enable = 0 ;  	
	  this.slave_cfg[i].is_active = 0;
          this.slave_cfg[i].addr_width = 21;
          this.slave_cfg[i].data_width = 64;
          this.slave_cfg[i].id_width = 0;
        end

	if(i == 1)begin
	  this.master_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4;
          this.master_cfg[i].is_active = 0;
          this.master_cfg[i].transaction_coverage_enable = 0;
          this.master_cfg[i].awlock_enable = 0 ;
          this.master_cfg[i].arlock_enable = 0 ;
          this.master_cfg[i].awuser_enable = 0 ;
          this.master_cfg[i].wuser_enable = 0 ;
          this.master_cfg[i].buser_enable = 0 ;
          this.master_cfg[i].aruser_enable = 0 ;
          this.master_cfg[i].ruser_enable = 0 ;
          this.master_cfg[i].addr_width = 21;
          this.master_cfg[i].data_width = 64;
          this.master_cfg[i].id_width = 8;
          this.master_cfg[i].addr_user_width = 1;
          this.master_cfg[i].data_user_width = 1;

	  this.slave_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4;
	  this.slave_cfg[i].is_active = 0;
          this.slave_cfg[i].transaction_coverage_enable = 0;
          this.slave_cfg[i].awlock_enable = 0 ;
          this.slave_cfg[i].arlock_enable = 0 ;
          this.slave_cfg[i].awuser_enable = 0 ;
          this.slave_cfg[i].wuser_enable = 0 ;
          this.slave_cfg[i].buser_enable = 0 ;
          this.slave_cfg[i].aruser_enable = 0 ;
          this.slave_cfg[i].ruser_enable = 0 ;
          this.slave_cfg[i].addr_width = 21;
          this.slave_cfg[i].data_width = 64;
          this.slave_cfg[i].id_width = 8;
          this.slave_cfg[i].addr_user_width = 1;
          this.slave_cfg[i].data_user_width = 1;
        end
      end

    endfunction : new

endclass : cust_axil2mmio_system_configuration

`endif // CUST_AXIL2MMIO_SYSTEM_CONFIGURATION_SVH
