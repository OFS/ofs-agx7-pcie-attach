// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_TB_ENV_SVH
`define QSFP_TB_ENV_SVH

class qsfp_tb_env extends uvm_env;
    `uvm_component_utils(qsfp_tb_env)

    // AXI System ENV
    `AXI_SYS_ENV axi_system_env;

    // AXI System Configuration
    `AXI_SYS_CFG_CLASS cfg;

    // QSFP Slave agent instance
    qsfp_slave_env         qsfp_slv_env; 

    // Virtual Sequencer
    qsfp_virtual_sequencer v_sequencer;


    qsfp_tb_config      tb_cfg0;

    //Scoreboard
    qsfp_scoreboard qsfp_sb;

    //QSFP Coverage collector
    `ifdef ENABLE_COVERAGE
    qsfp_coverage_collector qsfp_cov;
    `endif
   

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(qsfp_tb_config)::get(this,"","tb_cfg0",tb_cfg0))
            `uvm_fatal(get_name(), "failed to get tb_cfg ");

	cfg = `AXI_SYS_CFG_CLASS::type_id::create("cfg");
        config_axi_system();
	uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "axi_system_env", "cfg", cfg);

        // create an instance of AXI Env
        axi_system_env = `AXI_SYS_ENV::type_id::create("axi_system_env", this);
        
        qsfp_slv_env   = qsfp_slave_env::type_id::create("qsfp_slv_env", this);
        uvm_config_db #(int)::set(this, "*.qsfp_slv_env.qsfp_agent", "is_active", UVM_ACTIVE);
        qsfp_sb   = qsfp_scoreboard::type_id::create("qsfp_sb", this);
        
        `ifdef ENABLE_COVERAGE
	qsfp_cov   = qsfp_coverage_collector::type_id::create("qsfp_cov", this);
	`endif

	v_sequencer = qsfp_virtual_sequencer::type_id::create("v_sequencer", this);
	v_sequencer.tb_cfg0 = tb_cfg0;

    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if( tb_cfg0.has_sb == 0) begin
          qsfp_slv_env.qsfp_agent.monitor.ap_seqitem_port.connect(qsfp_sb.qsfp_item_collected_export);
          axi_system_env.master[0].monitor.item_started_port.connect(qsfp_sb.axi4lite_item_collected_export);  //TODO check monitor analysis port
	    end

        `ifdef ENABLE_COVERAGE
	qsfp_slv_env.qsfp_agent.monitor.ap_seqitem_port.connect(qsfp_cov.qsfp_item_collected_export);
        axi_system_env.master[0].monitor.item_started_port.connect(qsfp_cov.axi4lite_item_collected_export);  //TODO check monitor analysis port
	`endif

	v_sequencer.axi4_lt_mst_seqr = axi_system_env.master[0].sequencer;

        qsfp_sb.qsfp_sb_mem = qsfp_slv_env.qsfp1;

    endfunction : connect_phase
   
    //Function for configuring the AXI ENV as AXI4 Lite Master
    virtual function void config_axi_system();

        cfg.num_masters = `NUM_MASTERS;
	cfg.num_slaves  = `NUM_SLAVES;

	cfg.create_sub_cfgs(`NUM_MASTERS, `NUM_SLAVES);

	cfg.master_cfg[PMCI_AXI4_LT_MST  ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;

	cfg.slave_cfg[PMCI_AXI4_LT_SLV   ].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;

        cfg.master_cfg[PMCI_AXI4_LT_MST  ].awlen_enable   = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].arlen_enable   = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].awsize_enable  = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].arsize_enable  = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].awburst_enable = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].arburst_enable = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].awlock_enable  = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].arlock_enable  = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].awcache_enable = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].arcache_enable = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].wlast_enable   = 0;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].rlast_enable   = 0;  	


        cfg.slave_cfg[PMCI_AXI4_LT_SLV].awlen_enable = 0 ;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].arlen_enable = 0 ;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].awsize_enable = 0 ;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].arsize_enable = 0;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].awburst_enable = 0;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].arburst_enable = 0;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].awlock_enable = 0 ;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].arlock_enable = 0 ;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].awcache_enable = 0 ;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].arcache_enable = 0;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].wlast_enable = 0 ;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV].rlast_enable = 0 ; 

	cfg.master_cfg[PMCI_AXI4_LT_MST  ].is_active = 1;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].tdata_width = 64;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].data_width = 64;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].data_user_width = 64;
        cfg.master_cfg[PMCI_AXI4_LT_MST  ].snoop_data_width = 64;



	cfg.slave_cfg[PMCI_AXI4_LT_SLV   ].is_active = 1;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV   ].tdata_width = 64;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV   ].data_width = 64;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV   ].data_user_width = 64;
        cfg.slave_cfg[PMCI_AXI4_LT_SLV   ].snoop_data_width = 64;

    endfunction : config_axi_system

endclass : qsfp_tb_env

`endif // QSFP_TB_ENV_SVH
