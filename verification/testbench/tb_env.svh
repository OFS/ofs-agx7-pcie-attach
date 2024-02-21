//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract: 
 * class 'tb_env' is extended from  uvm_env class.  It implements
 * the build phase to construct the structural elements of this environment.
 *
 * tb_env is the testbench environment, which contains instances of VIP env (AXI VIP ENV,PCIE VIP ENV ,ETHERNET VIP) 
 *
 * svt_axi_system_env uses cust_svt_axi_system_configuration for configuration to use VIP in MASTER/SLAVE MODE
 *
 * ethernet_intermediate_env uses cust_svt_ethernet_agent_configuration to configure ETHERNET_VIP in mac mode
 *
 * svt_pcie_device_agent is the top level component provided by the PCIE VIP ,where PCIE VIP is used as root port
 *
 * tb_env also constructs the virtual sequencer and UVM_RAL blocks
 *
 */ 
//===============================================================================================================

`ifndef TB_ENV_SVH
`define TB_ENV_SVH

class tb_env extends uvm_env;
   `uvm_component_utils(tb_env)

   // AXI System ENV
   `AXI_SYS_ENV axi_system_env;
   ethernet_intermediate_env env;
   cust_ethernet_agent_configuration mac_cfg;
   `AXI_SYS_ENV axi_streaming_monitor[4];
   `AXI_SYS_ENV axis_HSSI_env;
   `AXI_SYS_ENV st2mm_csr_axil2mmio_env;
   `AXI_SYS_ENV fme_axil2mmio_env;
   `AXI_SYS_ENV pg_axil2mmio_env;
   `ifdef INCLUDE_TOD
   `AXI_SYS_ENV tod_axil2mmio_env;
   `endif
   bit CVL_100G;
   bit CVL_25G;
   bit MODE_25G_10G;
   bit run_multiport;
   // Virtual Sequencer
   virtual_sequencer v_sequencer;

   // AXI System Configuration
   `AXI_SYS_CFG_CLASS cfg;
   
   `AXI_SYS_CFG_CLASS passive_cfg;
   `AXI_SYS_CFG_CLASS passive_HSSI_cfg;
   `AXI_SYS_CFG_CLASS passive_BPF_cfg;
   
   `AXI_SYS_CFG_CLASS axis_HSSI_cfg;
   cust_axil2mmio_system_configuration axil2mmio_cfg[4];

   //HSSI Scoreboard
    hssi_scoreboard hssi_scbd[8];

   //PMCI Scoreboard
   pmci_scoreboard pmci_scbd;
   tb_config      tb_cfg0;
   int Lane;
   bit pmci_master;
   bit bmc_en;
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
   ral_block_ac_AFU_INTF  afu_intf_regs;
   ral_block_ac_msix      msix_regs;  
   rand ral_block_ac_src_port_gasket_agilex_pg     pr_gasket_regs;

 `ifndef AGILEX
   ral_block_ac_emif      emif_regs;
   ral_block_ac_mem_tg    mem_tg_regs;
 `else
   ral_block_dk_emif      emif_regs;
   ral_block_dk_mem_tg    mem_tg_regs;
 `endif
   
   ral_block_ac_ce        ce_regs;
   reg2vip_fme_adapter fme_adapter ;
   reg2vip_fme_adapter mem_adapter ;
   reg2vip_fme_adapter mem_tg_adapter ;
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
   reg2vip_fme_adapter afu_intf_adapter;
   reg2vip_fme_adapter msix_adapter;
   reg2vip_fme_adapter pr_gasket_adapter;
   //COVERAGE   
 `ifdef ENABLE_AC_COVERAGE
   ofs_coverage  cov_ac;
 `endif

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
      bit  status1, status2;
      int  max_payload_size, max_read_request_size;
      super.build_phase(phase);

      if(!uvm_config_db#(tb_config)::get(this,"","tb_cfg0",tb_cfg0))
        `uvm_fatal(get_name(), "failed to get tb_cfg ");

      cfg = `AXI_SYS_CFG_CLASS::type_id::create("cfg");
      passive_cfg = `AXI_SYS_CFG_CLASS::type_id::create("passive_cfg");
      passive_HSSI_cfg = `AXI_SYS_CFG_CLASS::type_id::create("passive_HSSI_cfg");
      passive_BPF_cfg = `AXI_SYS_CFG_CLASS::type_id::create("passive_BPF_cfg");
      
      axis_HSSI_cfg = `AXI_SYS_CFG_CLASS::type_id::create("axis_HSSI_cfg");
      foreach(axil2mmio_cfg[i])
        axil2mmio_cfg[i] = cust_axil2mmio_system_configuration::type_id::create($sformatf("axil2mmio_cfg_%0d",i));
       
      config_axis_hssi();
      config_axi_system();
      config_axi_passive();
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "axi_system_env", "cfg", cfg);
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "st2mm_csr_axil2mmio_env", "cfg", axil2mmio_cfg[0]);
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "pg_axil2mmio_env", "cfg", axil2mmio_cfg[2]);
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "fme_axil2mmio_env", "cfg", axil2mmio_cfg[1]);
      `ifdef INCLUDE_TOD
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "tod_axil2mmio_env", "cfg", axil2mmio_cfg[3]);
      `endif

      // create an instance of env
      axi_system_env = `AXI_SYS_ENV::type_id::create("axi_system_env", this);
      axis_HSSI_env = `AXI_SYS_ENV::type_id::create("axis_HSSI_env", this);
      st2mm_csr_axil2mmio_env = `AXI_SYS_ENV::type_id::create("st2mm_csr_axil2mmio_env", this);
      fme_axil2mmio_env = `AXI_SYS_ENV::type_id::create("fme_axil2mmio_env", this);
      pg_axil2mmio_env = `AXI_SYS_ENV::type_id::create("pg_axil2mmio_env", this);
      `ifdef INCLUDE_TOD
      tod_axil2mmio_env = `AXI_SYS_ENV::type_id::create("tod_axil2mmio_env", this);
      `endif
      //CREATE PASSIVE MONITORS///////////////////////////////
      axi_streaming_monitor[0] = `AXI_SYS_ENV::type_id::create("PCie2AFU_BRIDGE", this);
      axi_streaming_monitor[1] = `AXI_SYS_ENV::type_id::create("MUX2HE_HSSI_BRIDGE", this);
      axi_streaming_monitor[2] = `AXI_SYS_ENV::type_id::create("HE_HSSI2HSSI_BRIDGE", this);
      axi_streaming_monitor[3] = `AXI_SYS_ENV::type_id::create("BPF_BRIDGE", this);
      ////////////////////////////////////////////////////////
      //Create instance of pmci_scoreboard and pass tb_cfg0 to scoreboard
      if(tb_cfg0.has_tx_sb||tb_cfg0.has_rx_sb) begin
         pmci_scbd = pmci_scoreboard::type_id::create("pmci_scbd", this);
         pmci_scbd.tb_cfg0= tb_cfg0;
      end
      //////////////////////////////////////////////////////
   //SET PASSIVE_CFG to MONITORS
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "PCie2AFU_BRIDGE", "cfg", passive_cfg);
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "MUX2HE_HSSI_BRIDGE", "cfg", passive_cfg);
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "HE_HSSI2HSSI_BRIDGE", "cfg", passive_HSSI_cfg);
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "BPF_BRIDGE", "cfg", passive_BPF_cfg);
      uvm_config_db#(`AXI_SYS_CFG_CLASS)::set(this, "axis_HSSI_env", "cfg", axis_HSSI_cfg);
      
      ///////////////////////////////////////////////////////////////
     `ifdef LPBK_WITHOUT_HSSI 
        foreach(hssi_scbd[i])
          hssi_scbd[i] = hssi_scoreboard::type_id::create($sformatf("hssi_scbd_%0d",i), this);
      `endif
      

      v_sequencer = virtual_sequencer::type_id::create("v_sequencer", this);
      v_sequencer.tb_cfg0 = tb_cfg0;
      // Register configurations for Root and Endpoint devices.
      uvm_config_db#(`PCIE_DEV_CFG_CLASS)::set(this, "root", "cfg", this.tb_cfg0.pcie_cfg.root_cfg);
     `ifdef ENABLE_AC_COVERAGE
       cov_ac= ofs_coverage::type_id::create("cov_ac", this);
     `endif
      // Construct Root complex device namely root.
     //`ifdef GEN3
     //     this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.pl_cfg.highest_enabled_equalization_phase = 1;
     //`else
     //     this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.pl_cfg.highest_enabled_equalization_phase = 0;
     //`endif // GEN3
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
         this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.remote_max_payload_size = 512; //DUT has max_payload_size to 512
         this.tb_cfg0.pcie_cfg.root_cfg.target_cfg[0].max_payload_size_in_bytes = max_payload_size; 
         this.tb_cfg0.pcie_cfg.root_cfg.target_cfg[0].max_read_cpl_data_size_in_bytes = (max_payload_size > 256)? 256 :  max_payload_size; //TODO: 256B vs. 512B
      end
      // Set max_payload_size in root_cfg
      this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.dl_cfg.max_payload_size = 4096;
      this.tb_cfg0.pcie_cfg.root_cfg.pcie_cfg.tl_cfg.remote_max_read_request_size = 512;
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
         mem_tg_regs    =fpga_regs.mem_tg_regs;
         he_lpbk_regs =fpga_regs.he_lpbk_regs;
         pr_he_lpbk_regs =fpga_regs.pr_he_lpbk_regs;
         ce_regs    =fpga_regs.ce_regs;
         afu_intf_regs =fpga_regs.afu_intf_regs;
	 msix_regs  = fpga_regs.msix_regs;
	 pr_gasket_regs =fpga_regs.pr_gasket_regs;
      end

      ///ETHERNET_ENV/////
      mac_cfg = cust_ethernet_agent_configuration::type_id::create("mac_cfg");
      /** Set the configuration values for MAC agent */
      mac_cfg.mac_address[0] = 48'h000000004455;
 `ifndef INCLUDE_CVL
  `ifdef ETH_10G
      mac_cfg.set_kr_default_cfg();
      mac_cfg.disable_entry_to_fault_state = 1'b1;
      mac_cfg.enable_vip_cdr = 1;
    `elsif ETH_400G
      mac_cfg.set_400g_serial_8_lane_default_cfg();
      mac_cfg.enable_autoadaptation_pam =0 ;
      mac_cfg.enable_pam4_precoding = 0;
      mac_cfg.enable_pam4_gray_coding=1;
      mac_cfg.enable_pam4 = 1;
      mac_cfg.enable_kp4_rs_fec =1;     
     // mac_cfg.enable_vip_parallel_interface_width_configurable = 1;
      mac_cfg.cdbi_rs_fec_mode_align_timer = 128;
     // mac_cfg.mac_expected_minimum_ipg = 1;
       mac_cfg.enable_mon_pkt_drop_on_framing_error=0;
       mac_cfg.disable_entry_to_fault_state = 1'b1;
       mac_cfg.enable_vip_cdr = 1;  // TODO randomize ??       
  `else
      mac_cfg.set_25g_serial_default_cfg();
      mac_cfg.enable_xxvsbi_lsbi_rs_fec = 1;
      mac_cfg.xxvsbi_rs_fec_mode_align_timer = 16;
      mac_cfg.disable_entry_to_fault_state = 1'b1;
      mac_cfg.enable_vip_cdr = 1; 
  `endif
 `endif
      
 `ifdef INCLUDE_CVL
  `ifdef n6000_10G 
      mac_cfg.set_kr_default_cfg();
      mac_cfg.enable_mon_pkt_drop_on_framing_error=0;
      mac_cfg.disable_entry_to_fault_state = 1'b1;
      mac_cfg.enable_vip_cdr = 1;  // TODO randomize ??
  `elsif n6000_25G
      mac_cfg.set_25g_serial_default_cfg();
      mac_cfg.enable_xxvsbi_lsbi_rs_fec = 1;
      mac_cfg.xxvsbi_rs_fec_mode_align_timer = 16;
      mac_cfg.disable_entry_to_fault_state = 1'b1;
      //   mac_cfg.enable_complete_data_frame_with_preamble_rx = 1;
      mac_cfg.enable_mon_pkt_drop_on_framing_error=0;
      mac_cfg.enable_vip_cdr = 1;  // TODO randomize ??
      // mac_cfg.enable_mon_pkt_retain_on_framing_error=1;
      //mac_cfg.enable_vip_cdr = 1;  // TODO randomize ??
      //    mac_cfg.enable_mac_transaction_cov = 1; 
      //    mac_cfg.enable_detailed_transaction_print_tx = 1; 
      //mac_cfg.disable_pause_mode = 1;
  `elsif n6000_100G
      mac_cfg.set_ETH_CSBI_4_LANE_cfg();
      mac_cfg.enable_rs_fec =1;                       
      mac_cfg.enable_kp4_rs_fec =0;
      mac_cfg.enable_vip_usr_defined_cdr_clock  =1;   
      mac_cfg.vip_usr_defined_cdr_clock =38.8;        
      //mac_cfg.enable_fec_cov =1;                      
      mac_cfg.csbi_100g_align_timer = 32'd256; 
      mac_cfg.enable_mon_pkt_drop_on_framing_error=0;
      mac_cfg.disable_entry_to_fault_state = 1'b1;
      mac_cfg.enable_vip_cdr = 1;  // TODO randomize ??
   `elsif FIM_B
       mac_cfg.set_kr_default_cfg();
       mac_cfg.enable_mon_pkt_drop_on_framing_error=0;
       mac_cfg.disable_entry_to_fault_state = 1'b1;
       mac_cfg.enable_vip_cdr = 1;  // TODO randomize ??       
   `endif
      
 `endif //  `ifdef INCLUDE_CVL
      


      
      /////////////////////////////////////////////////////////////////////////////////////



      ///////////////////////////////////////////////////////////////////////////////////////
      /** Set MAC configuration in environment */
      uvm_config_db#(cust_ethernet_agent_configuration)::set(this,"*","mac_cfg",mac_cfg);
      /** Create the environment */
      env = ethernet_intermediate_env::type_id::create("env", this);
   endfunction : build_phase

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      v_sequencer.root_virt_seqr = root.virt_seqr;
      v_sequencer.pmci_axi4_lt_mst_seqr=axi_system_env.master[4].sequencer;
      v_sequencer.HSSI_AXIS_mst_seqr=axis_HSSI_env.master[0].sequencer;
      if (tb_cfg0.has_tx_sb == 1) begin 
         axi_streaming_monitor[3].slave[2].monitor.item_observed_port.connect(pmci_scbd.axi_port_rx);
         root.port.dl.sent_tlp_observed_port.connect(pmci_scbd.pcie_port_tx);    
      end
      if (tb_cfg0.has_rx_sb == 1) begin  
         axi_streaming_monitor[3].master[2].monitor.item_observed_port.connect(pmci_scbd.axi_port_rx);
         root.port.dl.received_tlp_observed_port.connect(pmci_scbd.pcie_port_rx);    
      end 
      `ifdef LPBK_WITHOUT_HSSI 
        for(int i=0; i<8; i++) begin
          axis_HSSI_env.slave[i].monitor.item_observed_port.connect(hssi_scbd[i].axi_port_tx_hssi);
          axis_HSSI_env.master[0].monitor.item_observed_port.connect(hssi_scbd[i].axi_port_rx_hssi);
        end
      `endif 
      fme_adapter =  reg2vip_fme_adapter::type_id::create();
      pr_adapter =  reg2vip_fme_adapter::type_id::create();
      he_hssi_adapter =  reg2vip_fme_adapter::type_id::create();
      hssi_adapter =  reg2vip_fme_adapter::type_id::create();
      emif_adapter =  reg2vip_fme_adapter::type_id::create();
      mem_adapter =  reg2vip_fme_adapter::type_id::create();
      mem_tg_adapter =  reg2vip_fme_adapter::type_id::create();
      st2mm_adapter =  reg2vip_fme_adapter::type_id::create();
      pcie_adapter =  reg2vip_fme_adapter::type_id::create();
      pmci_adapter =  reg2vip_fme_adapter::type_id::create();
      he_lpbk_adapter =  reg2vip_fme_adapter::type_id::create();
      pr_he_lpbk_adapter =  reg2vip_fme_adapter::type_id::create();
      ce_adapter =  reg2vip_fme_adapter::type_id::create();
      qsfp0_adapter =  reg2vip_fme_adapter::type_id::create();
      qsfp1_adapter =  reg2vip_fme_adapter::type_id::create();
      afu_intf_adapter = reg2vip_fme_adapter::type_id::create();
      msix_adapter = reg2vip_fme_adapter::type_id::create();    
      pr_gasket_adapter =  reg2vip_fme_adapter::type_id::create();

      if (fpga_regs.get_parent() == null) begin
         fme_adapter.bar =     tb_cfg0.PF0_BAR0;
         pr_adapter.bar =      tb_cfg0.PF1_VF0_BAR0;
         he_hssi_adapter.bar = tb_cfg0.PF0_VF1_BAR0;
         hssi_adapter.bar =    tb_cfg0.PF0_BAR0;
         mem_adapter.bar =     tb_cfg0.PF0_VF0_BAR0;
         emif_adapter.bar =    tb_cfg0.PF0_BAR0;
         mem_tg_adapter.bar =  tb_cfg0.PF0_VF2_BAR0;
         st2mm_adapter.bar =   tb_cfg0.PF0_BAR0;
         pcie_adapter.bar =    tb_cfg0.PF0_BAR0;
         pmci_adapter.bar =    tb_cfg0.PF0_BAR0;
         he_lpbk_adapter.bar = tb_cfg0.PF2_BAR0;
         pr_he_lpbk_adapter.bar = tb_cfg0.PF1_VF0_BAR0;
         ce_adapter.bar      = tb_cfg0.PF4_BAR0;
         qsfp0_adapter.bar   = tb_cfg0.PF0_BAR0;
         qsfp1_adapter.bar   = tb_cfg0.PF0_BAR0;
	 afu_intf_adapter.bar  = tb_cfg0.PF0_BAR0;
	 msix_adapter.bar  =     tb_cfg0.PF0_BAR4;    
	 pr_gasket_adapter.bar = tb_cfg0.PF0_BAR0; 
         
         
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

         fpga_regs.mem_tg_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],mem_tg_adapter);
         fpga_regs.mem_tg_map.set_auto_predict(1);


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
	 
 	 fpga_regs.afu_intf_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],afu_intf_adapter);
         fpga_regs.afu_intf_map.set_auto_predict(1);
	 
   	 fpga_regs.msix_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],msix_adapter);
         fpga_regs.msix_map.set_auto_predict(1);

	 fpga_regs.pr_gasket_map.set_sequencer(v_sequencer.root_virt_seqr.driver_transaction_seqr[0],pr_gasket_adapter);
         fpga_regs.pr_gasket_map.set_auto_predict(1);

      end

   endfunction : connect_phase

   function void start_of_simulation_phase(uvm_phase phase);
      int default_report;
      `ifndef RUNSIM
         default_report = $fopen("runsim.log", "w");
         // Set report file handling
         //set_report_default_file(default_report);		
         uvm_top.set_report_default_file_hier (default_report) ;
         uvm_top.set_report_severity_action_hier (UVM_INFO, UVM_DISPLAY + UVM_LOG);
         uvm_top.set_report_severity_action_hier(UVM_WARNING, UVM_DISPLAY + UVM_LOG);
         uvm_top.set_report_severity_action_hier(UVM_ERROR, UVM_DISPLAY + UVM_LOG + UVM_COUNT);
         uvm_top.set_report_severity_action_hier(UVM_FATAL, UVM_DISPLAY + UVM_LOG + UVM_STOP);
         `uvm_info("SEED:", $sformatf("random seed = %0d \n", $get_initial_random_seed()), UVM_LOW);
     `endif 
   endfunction: start_of_simulation_phase

   //Function for configuring the AXI ENV as AXI4 Lite Master
   virtual function void config_axi_system();

      cfg.num_masters = `NUM_MASTERS;
      cfg.num_slaves  = `NUM_SLAVES;

      cfg.create_sub_cfgs(`NUM_MASTERS, `NUM_SLAVES);

      cfg.master_cfg[PMCI_AXI4_LT_MST].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;
      cfg.slave_cfg[PMCI_AXI4_LT_SLV].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;

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
   virtual function void config_axi_passive();

      passive_cfg.num_masters = 1;
      passive_cfg.num_slaves  = 1 ;
      passive_cfg.tready_watchdog_timeout = 0;	

      passive_cfg.create_sub_cfgs(1,1);

      passive_cfg.master_cfg[0].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
      passive_cfg.slave_cfg[0].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;

      passive_cfg.master_cfg[0].tdata_width = 512;
      passive_cfg.master_cfg[0].tuser_width = 8;
      passive_cfg.master_cfg[0].is_active = 0;
      passive_cfg.master_cfg[0].default_tready=1;
      passive_cfg.master_cfg[0].tstrb_enable=0;
      passive_cfg.master_cfg[0].tdest_enable=0;
      passive_cfg.master_cfg[0].tid_enable=0;
      

      passive_cfg.slave_cfg[0].default_tready=1;
      passive_cfg.slave_cfg[0].is_active = 0;
      passive_cfg.slave_cfg[0].tdata_width = 512;
      passive_cfg.slave_cfg[0].tuser_width = 8;
      passive_cfg.slave_cfg[0].tstrb_enable=0;
      passive_cfg.slave_cfg[0].tdest_enable=0;
      passive_cfg.slave_cfg[0].tid_enable=0;
      ////////////////////////////////////////PASSIVE_HSSI_CFG////////////////////////////////////////
      passive_HSSI_cfg.num_masters = 16;
      passive_HSSI_cfg.num_slaves  = 16 ;
      passive_HSSI_cfg.tready_watchdog_timeout=0;

      passive_HSSI_cfg.create_sub_cfgs(16,16);
      for(int i=0; i<16; i++) begin

        passive_HSSI_cfg.master_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
        passive_HSSI_cfg.slave_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;

        passive_HSSI_cfg.master_cfg[i].tdata_width = 512;
        passive_HSSI_cfg.master_cfg[i].tuser_width = 8;
        passive_HSSI_cfg.master_cfg[i].is_active = 0;
        passive_HSSI_cfg.master_cfg[i].default_tready=1;
        passive_HSSI_cfg.master_cfg[i].tstrb_enable=0;
        passive_HSSI_cfg.master_cfg[i].tid_enable=0;
        passive_HSSI_cfg.master_cfg[i].tdest_enable=0;

        passive_HSSI_cfg.slave_cfg[i].default_tready=1;
        passive_HSSI_cfg.slave_cfg[i].is_active = 0;
        passive_HSSI_cfg.slave_cfg[i].tdata_width = 512;
        passive_HSSI_cfg.slave_cfg[i].tuser_width = 8;
        passive_HSSI_cfg.slave_cfg[i].tstrb_enable=0;
        passive_HSSI_cfg.slave_cfg[i].tid_enable=0;
        passive_HSSI_cfg.slave_cfg[i].tdest_enable=0;
     end


      ////////////////////////////////////////PASSIVE_BPF_CFG////////////////////////////////////////
      passive_BPF_cfg.num_masters = 3;
      passive_BPF_cfg.num_slaves  = 6 ;

      passive_BPF_cfg.create_sub_cfgs(3,6);
      for(int i=0; i<3; i++) begin
        passive_BPF_cfg.master_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE;
        passive_BPF_cfg.master_cfg[i].awlen_enable   = 0;
        passive_BPF_cfg.master_cfg[i].arlen_enable   = 0;
        passive_BPF_cfg.master_cfg[i].awsize_enable  = 0;
        passive_BPF_cfg.master_cfg[i].arsize_enable  = 0;
        passive_BPF_cfg.master_cfg[i].awburst_enable = 0;
        passive_BPF_cfg.master_cfg[i].arburst_enable = 0;
        passive_BPF_cfg.master_cfg[i].awlock_enable  = 0;
        passive_BPF_cfg.master_cfg[i].arlock_enable  = 0;
        passive_BPF_cfg.master_cfg[i].awcache_enable = 0;
        passive_BPF_cfg.master_cfg[i].arcache_enable = 0;
        passive_BPF_cfg.master_cfg[i].wlast_enable   = 0;
        passive_BPF_cfg.master_cfg[i].rlast_enable   = 0; 
        passive_BPF_cfg.master_cfg[i].is_active      = 0;
        passive_BPF_cfg.master_cfg[i].tdata_width    = 64;
        passive_BPF_cfg.master_cfg[i].data_width     = 64;
        passive_BPF_cfg.master_cfg[i].data_user_width = 64;
        passive_BPF_cfg.master_cfg[i].snoop_data_width = 64;

      end

      for(int i=0; i<6; i++) begin
        passive_BPF_cfg.slave_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_LITE; 
        passive_BPF_cfg.slave_cfg[i].awlen_enable = 0;
        passive_BPF_cfg.slave_cfg[i].arlen_enable = 0;
        passive_BPF_cfg.slave_cfg[i].awsize_enable = 0;
        passive_BPF_cfg.slave_cfg[i].arsize_enable = 0;
        passive_BPF_cfg.slave_cfg[i].awburst_enable = 0;
        passive_BPF_cfg.slave_cfg[i].arburst_enable = 0;
        passive_BPF_cfg.slave_cfg[i].awlock_enable = 0;
        passive_BPF_cfg.slave_cfg[i].arlock_enable = 0;
        passive_BPF_cfg.slave_cfg[i].awcache_enable = 0;
        passive_BPF_cfg.slave_cfg[i].arcache_enable = 0;
        passive_BPF_cfg.slave_cfg[i].wlast_enable = 0;
        passive_BPF_cfg.slave_cfg[i].rlast_enable = 0; 
        passive_BPF_cfg.slave_cfg[i].is_active = 0;
        passive_BPF_cfg.slave_cfg[i].tdata_width = 64;
        passive_BPF_cfg.slave_cfg[i].data_width = 64;
        passive_BPF_cfg.slave_cfg[i].data_user_width = 64;
        passive_BPF_cfg.slave_cfg[i].snoop_data_width = 64;
      end
      
   endfunction : config_axi_passive

   function config_axis_hssi();
      axis_HSSI_cfg.num_masters = 1;
      axis_HSSI_cfg.num_slaves  = 8 ;

      axis_HSSI_cfg.create_sub_cfgs(1,8);

      axis_HSSI_cfg.master_cfg[0].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
      axis_HSSI_cfg.slave_cfg[0].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;

      axis_HSSI_cfg.master_cfg[0].tdata_width = 64;
      axis_HSSI_cfg.master_cfg[0].tuser_width = 8;
      axis_HSSI_cfg.master_cfg[0].is_active = 1;
      axis_HSSI_cfg.master_cfg[0].default_tready=1;
      axis_HSSI_cfg.master_cfg[0].tstrb_enable=0;
      axis_HSSI_cfg.master_cfg[0].tid_enable=0;
      axis_HSSI_cfg.master_cfg[0].tdest_enable=0;
    for(int i=0;i<8;i++)begin
      axis_HSSI_cfg.slave_cfg[i].axi_interface_type = `AXI_PORT_CFG_CLASS::AXI4_STREAM;
      axis_HSSI_cfg.slave_cfg[i].default_tready=1;
      axis_HSSI_cfg.slave_cfg[i].is_active = 0;
      axis_HSSI_cfg.slave_cfg[i].tdata_width = 64;
      axis_HSSI_cfg.slave_cfg[i].tuser_width = 8;
      axis_HSSI_cfg.slave_cfg[i].tstrb_enable=0;
      axis_HSSI_cfg.slave_cfg[i].tid_enable=0;
      axis_HSSI_cfg.slave_cfg[i].tdest_enable=0;
    end
   
   endfunction

   function tb_config getCfg();
      return tb_cfg0; 
   endfunction

endclass : tb_env

 `endif // TB_ENV_SVH
