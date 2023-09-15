// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef TB_ENV_SVH
`define TB_ENV_SVH

class tb_env extends uvm_env;
    `uvm_component_utils(tb_env)

    // AXI System ENV
    `AXI_SYS_ENV axi_system_env;
    `AXI_SYS_ENV ace_system_env;

    // Virtual Sequencer
    virtual_sequencer v_sequencer;

    // AXI System Configuration
    cust_axi_system_configuration cfg;
    cust_axi_system_configuration cfg1;


    tb_config      tb_cfg0;


    // Scoreboard
    ce_scoreboard ce_scbd;


    // PCIe agent instance
    `PCIE_DEV_AGENT  root;
    `PCIE_DEV_STATUS root_status;
    ral_block_ofs	   fpga_regs;
    ral_block_ac_fme       fme_regs;
    ral_block_ac_pcie      pcie_regs;
    ral_block_ac_qsfp      qsfp0_regs;
    ral_block_ac_qsfp      qsfp1_regs;
    ral_block_ac_pmci      pmci_regs;
    ral_block_pr           pr_regs;
    ral_block_ac_st2mm     st2mm_regs;
    ral_block_ac_he_hssi   he_hssi_regs;
    ral_block_ac_hssi      hssi_regs;
    ral_block_ac_he_lpbk   he_lpbk_regs;
    ral_block_ac_he_lpbk   pr_he_lpbk_regs;
    ral_block_ac_he_mem    mem_regs;
`ifndef AGILEX
    ral_block_ac_emif      emif_regs;
//SSS    ral_block_ac_mem_tg    mem_tg_regs;
`else
    ral_block_dk_emif      emif_regs;
//SSS    ral_block_ac_mem_tg    mem_tg_regs;
`endif
    
    ral_block_ac_ce        ce_regs;
//    reg2vip_fme_adapter fme_adapter;
    reg2vip_fme_adapter fme_adapter ;
    reg2vip_fme_adapter mem_adapter ;
//SSS    reg2vip_fme_adapter mem_tg_adapter ;
    reg2vip_fme_adapter pr_adapter ;
    reg2vip_fme_adapter he_hssi_adapter ;
    reg2vip_fme_adapter hssi_adapter ;
    reg2vip_fme_adapter emif_adapter ;
    reg2vip_fme_adapter st2mm_adapter ;
    reg2vip_fme_adapter pcie_adapter ;
    reg2vip_fme_adapter pmci_adapter ;
    reg2vip_fme_adapter he_lpbk_adapter ;
    reg2vip_fme_adapter pr_he_lpbk_adapter ;
    reg2vip_fme_adapter ce_adapter ;
    reg2vip_fme_adapter qsfp0_adapter ;
    reg2vip_fme_adapter qsfp1_adapter ;

    ce_coverage  cov_ce;

    rand int p_hdr_credit, np_hdr_credit, cpl_hdr_credit;
    rand int p_data_credit, np_data_credit, cpl_data_credit;
    rand bit en_dsbp;
    rand bit enable_bp_credit;

    constraint root_credit {
       p_hdr_credit inside {[10:100]};
       np_hdr_credit inside {[10:100]};
       cpl_hdr_credit inside {[10:100]};
       p_data_credit inside {[100:1000]};
       np_data_credit inside {[100:1000]};
       cpl_data_credit inside {[100:1000]};
       en_dsbp dist { 1 := 10, 0 := 90};
       enable_bp_credit  == 1;
    }


    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        bit status1, status2;
	int max_payload_size, max_read_request_size;
        super.build_phase(phase);

        if(!uvm_config_db#(tb_config)::get(this,"","tb_cfg0",tb_cfg0))
            `uvm_fatal(get_name(), "failed to get tb_cfg ");


        // create an instance of env
        axi_system_env = `AXI_SYS_ENV::type_id::create("axi_system_env", this);
        ace_system_env = `AXI_SYS_ENV::type_id::create("ace_system_env", this);

        // CE Scoreboard
        ce_scbd = ce_scoreboard::type_id::create("ce_scbd", this);

	v_sequencer = virtual_sequencer::type_id::create("v_sequencer", this);
	v_sequencer.tb_cfg0 = tb_cfg0;
        // Register configurations for Root and Endpoint devices.
        uvm_config_db#(`PCIE_DEV_CFG_CLASS)::set(this, "root", "cfg", this.tb_cfg0.pcie_cfg.root_cfg);

        // Construct Root complex device namely root.
        `ifdef GEN3
            this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.pl_cfg.highest_enabled_equalization_phase = 1;
        `else
            this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.pl_cfg.highest_enabled_equalization_phase = 0;
	`endif // GEN3
        //Set max_read_request_size in VIP/BFM
        status1 = uvm_config_db #(int unsigned)::get(this, "*", "max_read_request_size", max_read_request_size);
        if(status1) begin
          `uvm_info("body", $sformatf("ENV: max_read_request_size %d ", max_read_request_size), UVM_LOW);
           this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.remote_max_read_request_size = max_read_request_size;
        end
        status2 = uvm_config_db #(int unsigned)::get(this, "*", "max_payload_size", max_payload_size);
	//Set max_payload_size in VIP/BFM
        if(status2) begin
          `uvm_info("body", $sformatf("SDEBUG: max_payload_size %d", max_payload_size), UVM_LOW);
           this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.remote_max_payload_size = max_payload_size;
           this.tb_cfg0.pcie_cfg.root_cfg.target_cfg[0].max_payload_size_in_bytes = max_payload_size; 
           
           this.tb_cfg0.pcie_cfg.root_cfg.target_cfg[0].max_read_cpl_data_size_in_bytes = (max_payload_size > 256)? 256 :  max_payload_size; //TODO: 256B vs. 512B
        end
   // set uninit_mem_read_resp as rand
        this.tb_cfg0.pcie_cfg.root_cfg.target_cfg[0].uninit_mem_read_resp = 2;
   // set flag uninit mem read as 0i
        this.tb_cfg0.pcie_cfg.root_cfg.target_cfg[0].flag_uninitialized_mem_read = 1'b0; 
	// Set max_payload_size in root_cfg
        this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.dl_cfg.max_payload_size = 4096;
	// To enable extended tag in the VIP
        this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.remote_extended_tag_field_enabled = 1'b1;

        if (enable_bp_credit || ($test$plusargs("BP_CREDIT")) )begin
           if(en_dsbp == 1) begin
             `uvm_info("body", $sformatf("SDEBUG: controlling Root header and data credits to create down stream back pressure "), UVM_LOW);
              for(int i=0; i<8; i++) begin
                 assert(this.randomize());
                 //post credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_p_hdr_tx_credits[i] = 1;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_p_data_tx_credits[i] = 16;

                 //Non-post credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_np_hdr_tx_credits[i] = 1;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_np_data_tx_credits[i] = np_data_credit;

                 //Completion credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_cpl_hdr_tx_credits[i] = 2;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_cpl_data_tx_credits[i] = 32;
              end
           end
           else begin
             `uvm_info("body", $sformatf("SDEBUG: Randomized Root posted, non-posted, completion credits "), UVM_LOW);
              for(int i=0; i<8; i++) begin
                 assert(this.randomize());
                 //post credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_p_hdr_tx_credits[i] = p_hdr_credit;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_p_data_tx_credits[i] = p_data_credit;

                 //Non-post credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_np_hdr_tx_credits[i] = np_hdr_credit;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_np_data_tx_credits[i] = np_data_credit;

                 //Completion credits
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_cpl_hdr_tx_credits[i] = cpl_hdr_credit;
                 this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.init_cpl_data_tx_credits[i] = cpl_data_credit;
              end
           end
        end //end plusargs

        //Set the model instance scope
        this.tb_cfg0.pcie_cfg.root_cfg.model_instance_scope = "tb_top.root0";

        //Create status objects for Root and Endpoint devices 
        root_status = `PCIE_DEV_STATUS::type_id::create("root_status");

        // Register configurations for Root and Endpoint devices.
        uvm_config_db#(`PCIE_DEV_CFG_CLASS)::set(this, "root", "cfg", this.tb_cfg0.pcie_cfg.root_cfg);

        // Register status objects for Root and Endpoint devices.
        uvm_config_db#(`PCIE_DEV_STATUS)::set(this, "root", "shared_status", this.root_status);

	root = `PCIE_DEV_AGENT::type_id::create("root", this);
         if (fpga_regs == null) begin
            fpga_regs = ral_block_ofs::type_id::create("fpga_regs",this);
            fpga_regs.build();

            fpga_regs.lock_model();
            fme_regs =fpga_regs.fme_regs;
            pr_regs =fpga_regs.pr_regs[0];
            pcie_regs =fpga_regs.pcie_regs;
            qsfp0_regs =fpga_regs.qsfp0_regs;
            qsfp1_regs =fpga_regs.qsfp1_regs;
            pmci_regs =fpga_regs.pmci_regs;
            st2mm_regs =fpga_regs.st2mm_regs;
            he_hssi_regs =fpga_regs.he_hssi_regs;
            hssi_regs =fpga_regs.hssi_regs;
            mem_regs =fpga_regs.mem_regs;
            emif_regs    =fpga_regs.emif_regs;
      //SSS      mem_tg_regs    =fpga_regs.he_emif_regs;
            he_lpbk_regs =fpga_regs.he_lpbk_regs;
            pr_he_lpbk_regs =fpga_regs.pr_he_lpbk_regs;
            ce_regs    =fpga_regs.ce_regs;
        end
        
        // AXI ACE LITE CFG
        cfg = cust_axi_system_configuration::type_id::create("cfg");
        cfg1 = cust_axi_system_configuration::type_id::create("cfg1");
        config_axi_system();
        config_ace_system();
	uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "ace_system_env", "cfg", cfg);
	uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "axi_system_env", "cfg", cfg1);
     
     cov_ce= ce_coverage::type_id::create("cov_ce", this); //coverage      

    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
	v_sequencer.root_virt_seqr = root.virt_seqr;
        v_sequencer.acelite_slv_seqr = ace_system_env.slave[0].sequencer;
	v_sequencer.hps2ce_axi4_lt_mst_seqr= axi_system_env.master[1].sequencer;
       
        if (tb_cfg0.has_sb == 1) begin  
           //ace_system_env.slave[0].monitor.item_started_port.connect(ce_scbd.axi_port_rx);
           ace_system_env.slave[0].monitor.item_observed_port.connect(ce_scbd.axi_port_rx);
           //root.port.dl.received_tlp_observed_port.connect(ce_scbd.pcie_port_rx);// Not used    
           root.port.dl.sent_tlp_observed_port.connect(ce_scbd.pcie_port_tx);    
        end

        fme_adapter =  reg2vip_fme_adapter::type_id::create();
        pr_adapter =  reg2vip_fme_adapter::type_id::create();
        he_hssi_adapter =  reg2vip_fme_adapter::type_id::create();
        hssi_adapter =  reg2vip_fme_adapter::type_id::create();
        emif_adapter =  reg2vip_fme_adapter::type_id::create();
        mem_adapter =  reg2vip_fme_adapter::type_id::create();
//SSS        mem_tg_adapter =  reg2vip_fme_adapter::type_id::create();
        st2mm_adapter =  reg2vip_fme_adapter::type_id::create();
        pcie_adapter =  reg2vip_fme_adapter::type_id::create();
        pmci_adapter =  reg2vip_fme_adapter::type_id::create();
        he_lpbk_adapter =  reg2vip_fme_adapter::type_id::create();
        pr_he_lpbk_adapter =  reg2vip_fme_adapter::type_id::create();
        ce_adapter =  reg2vip_fme_adapter::type_id::create();
        qsfp0_adapter =  reg2vip_fme_adapter::type_id::create();
        qsfp1_adapter =  reg2vip_fme_adapter::type_id::create();
        if (fpga_regs.get_parent() == null) begin
           fme_adapter.bar =     `PF0_BAR0;
           pr_adapter.bar =      `PF1_VF0_BAR0;
           he_hssi_adapter.bar = `PF2_VF1_BAR0;
           hssi_adapter.bar =    `PF0_BAR0;
           mem_adapter.bar =     `PF2_VF0_BAR0;
           emif_adapter.bar =    `PF2_BAR0;
       //    mem_tg_adapter.bar =  `PF2_VF2_BAR0;
           st2mm_adapter.bar =   `PF0_BAR0;
           pcie_adapter.bar =    `PF0_BAR0;
           pmci_adapter.bar =    `PF0_BAR0;
           he_lpbk_adapter.bar = `PF2_BAR0;
           pr_he_lpbk_adapter.bar = `PF1_VF0_BAR0;
           ce_adapter.bar      = `PF4_BAR0;
           qsfp0_adapter.bar   = `PF0_BAR0;
           qsfp1_adapter.bar   = `PF0_BAR0;

           
          
           fpga_regs.fme_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],fme_adapter);
           fpga_regs.fme_map.set_auto_predict(1);

           fpga_regs.pcie_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],pcie_adapter);
           fpga_regs.pcie_map.set_auto_predict(1);

           fpga_regs.pmci_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],pmci_adapter);
           fpga_regs.pmci_map.set_auto_predict(1);


           fpga_regs.st2mm_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],st2mm_adapter);
           fpga_regs.st2mm_map.set_auto_predict(1);

           fpga_regs.he_hssi_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],he_hssi_adapter);
           fpga_regs.he_hssi_map.set_auto_predict(1);


           fpga_regs.hssi_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],hssi_adapter);
           fpga_regs.hssi_map.set_auto_predict(1);

           fpga_regs.emif_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],emif_adapter);
           fpga_regs.emif_map.set_auto_predict(1);

//SSS           fpga_regs.mem_tg_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],mem_tg_adapter);
//SSS           fpga_regs.mem_tg_map.set_auto_predict(1);


           fpga_regs.mem_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],mem_adapter);
           fpga_regs.mem_map.set_auto_predict(1);


           fpga_regs.he_lpbk_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],he_lpbk_adapter);
           fpga_regs.he_lpbk_map.set_auto_predict(1);


           fpga_regs.pr_he_lpbk_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],pr_he_lpbk_adapter);
           fpga_regs.pr_he_lpbk_map.set_auto_predict(1);

           fpga_regs.pr_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],pr_adapter);
           fpga_regs.pr_map.set_auto_predict(1);


           fpga_regs.qsfp0_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],qsfp0_adapter);
           fpga_regs.qsfp0_map.set_auto_predict(1);


           fpga_regs.qsfp1_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],qsfp1_adapter);
           fpga_regs.qsfp1_map.set_auto_predict(1);


           fpga_regs.ce_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],ce_adapter);
           fpga_regs.ce_map.set_auto_predict(1);
       end


    endfunction : connect_phase

    //Function for configuring the AXI ENV as AXI4 Lite Master
    virtual function void config_axi_system();

    cfg1.num_masters = `NUM_MASTERS;
    cfg1.num_slaves  = 1;
	cfg1.create_sub_cfgs(`NUM_MASTERS, `NUM_SLAVES);
     cfg1.master_cfg[1].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;

     cfg1.master_cfg[1].awlen_enable   = 0;
     cfg1.master_cfg[1].arlen_enable   = 0;
     cfg1.master_cfg[1].awsize_enable  = 0;
     cfg1.master_cfg[1].arsize_enable  = 0;
     cfg1.master_cfg[1].awburst_enable = 0;
     cfg1.master_cfg[1].arburst_enable = 0;
     cfg1.master_cfg[1].awlock_enable  = 0;
     cfg1.master_cfg[1].arlock_enable  = 0;
     cfg1.master_cfg[1].awcache_enable = 0;
     cfg1.master_cfg[1].arcache_enable = 0;
     cfg1.master_cfg[1].wlast_enable   = 0;
     cfg1.master_cfg[1].rlast_enable   = 0;

     cfg1.master_cfg[1].is_active = 1;
     //cfg.master_cfg[1].tdata_width = 32;
     cfg1.master_cfg[1].data_width = 32;
     cfg1.master_cfg[1].addr_width = 21;
     //cfg.master_cfg[1].data_user_width = 32;
     //cfg.master_cfg[1].snoop_data_width = 32;

    endfunction : config_axi_system


virtual function void config_ace_system();

        cfg.num_masters = `NUM_MASTERS;
	cfg.num_slaves  = 1;
	cfg.create_sub_cfgs(`NUM_MASTERS, `NUM_SLAVES);

        //cfg.enable_complex_memory_map=1; 
        //cfg.set_addr_range(0,32'h0008_0000,32'h0009_FFFF);
        //cfg.set_addr_range(1,32'h0009_0000,32'h0009_FFFF);

    for(int i=0; i<1 ;i++) begin
       cfg.slave_cfg[i].is_active = 1;
       cfg.slave_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::ACE_LITE;
       //cfg.slave_cfg[i].protocol_checks_enable = 1;
       //cfg.slave_cfg[i].id_width = 8;
       //cfg.slave_cfg[i].tdata_width = 512;
       cfg.slave_cfg[i].data_width = 512; 
       cfg.slave_cfg[i].addr_width = 32; 
       //cfg.slave_cfg[i].read_data_reordering_depth = 2;
       //cfg.slave_cfg[i].enable_xml_gen = 1;
       //cfg.slave_cfg[i].exclusive_access_enable = 1;
       //cfg.slave_cfg[i].transaction_coverage_enable = 1;
       //cfg.slave_cfg[i].default_arready = 0;
      //cfg.slave_cfg[i].num_outstanding_xact = 20;
      cfg.slave_cfg[i].data_user_width = 64;
      cfg.slave_cfg[i].snoop_data_width = 64;

       cfg.slave_cfg[i].awlen_enable = 1;
      cfg.slave_cfg[i].arlen_enable = 1;
      cfg.slave_cfg[i].awsize_enable = 1;
      cfg.slave_cfg[i].arsize_enable = 1;
      cfg.slave_cfg[i].awburst_enable = 1;
      cfg.slave_cfg[i].arburst_enable = 1;
      cfg.slave_cfg[i].awlock_enable = 1;
      cfg.slave_cfg[i].arlock_enable = 1;
      cfg.slave_cfg[i].awcache_enable = 1;
      cfg.slave_cfg[i].arcache_enable = 1;
      cfg.slave_cfg[i].wlast_enable = 1;
      cfg.slave_cfg[i].rlast_enable = 1;
    end

        //the transactions are always routed to slave port 0. The below statement indciates the routing info of interconnect. 
        //slave_port_ids[0]=0; 

        //no addr translation. The below statement indicates any addr translation performed by interconnect. 
        //slave_addr = global_addr; //note that global_addr will be tagged with the non-secure bit if address tagging is enabled.
        
        //return 1
        //get_dest_slave_addr_from_global_addr=1;

    endfunction : config_ace_system

endclass : tb_env

`endif // TB_ENV_SVH
