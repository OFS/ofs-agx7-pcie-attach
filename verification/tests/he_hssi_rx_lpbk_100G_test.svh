// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

/**
 * Abstract:
 * The file contains the class extended from ethernet_base_test
 * A simple directed test showcases the use of the directed sequence.
 * It disables the base test case virtual sequence on the virtual sequencer.
 * Aftet that a directed sequence is set on the agent's  txrx sequencer.
 *
 * The intention of the test is to employ the usage of user configurable align marker for CSBI interface
*/

`ifdef n6000_10G
`include "ethernet_base_test_10_25.sv"

`elsif n6000_25G
`include "ethernet_base_test_CVL25G.sv"

`elsif n6000_100G
`include "ethernet_base_test_CVL100G.sv"
`endif

`include "ethernet_directed_sequence.sv"
`include "ethernet_null_virtual_sequence.sv"
`include "ethernet_mac_sb_callbacks.sv"
//`include "ethernet_phy_sb_callbacks.sv"
//`include "ethernet_phy_monitor_callbacks.sv"
`include "ethernet_mac_monitor_callbacks.sv"

class he_hssi_rx_lpbk_100G_test extends ethernet_base_test;

  /** UVM component utility macro */
  `uvm_component_utils(he_hssi_rx_lpbk_100G_test)

  /** Declare a handle of the mac callback class */
  ethernet_mac_sb_callbacks mac_callback_0;
  ethernet_mac_sb_callbacks mac_callback_1;
  `ifdef n6000_10G
  ethernet_mac_sb_callbacks mac_callback_2;
  ethernet_mac_sb_callbacks mac_callback_3;
  ethernet_mac_sb_callbacks mac_callback_4;
  ethernet_mac_sb_callbacks mac_callback_5;
  ethernet_mac_sb_callbacks mac_callback_6;
  ethernet_mac_sb_callbacks mac_callback_7;
  `elsif n6000_25G
  ethernet_mac_sb_callbacks mac_callback_2;
  ethernet_mac_sb_callbacks mac_callback_3;
  `endif
  /** Declare a handle of the phy callback class */
 // ethernet_phy_sb_callbacks phy_callback;

  /** Declare a handle of the mac monitor class */
  ethernet_mac_monitor_callbacks mac_mon_callback_0;
  ethernet_mac_monitor_callbacks mac_mon_callback_1;
  `ifdef n6000_10G
  ethernet_mac_monitor_callbacks mac_mon_callback_2;
  ethernet_mac_monitor_callbacks mac_mon_callback_3;
  ethernet_mac_monitor_callbacks mac_mon_callback_4;
  ethernet_mac_monitor_callbacks mac_mon_callback_5;
  ethernet_mac_monitor_callbacks mac_mon_callback_6;
  ethernet_mac_monitor_callbacks mac_mon_callback_7;
  `elsif n6000_25G
  ethernet_mac_monitor_callbacks mac_mon_callback_2;
  ethernet_mac_monitor_callbacks mac_mon_callback_3;
  `endif
  /** Declare a handle of the phy monoitor class */
ethernet_directed_sequence eth_seq;
he_hssi_rx_lpbk_seq rx_lpbk_seq;
int Lane;
bit Enable_scb;
bit CVL_100G;
bit CVL_25G;
bit MODE_25G_10G;
bit run_multiport;
  /** Class constructor */
  function new(string name = "he_hssi_rx_lpbk_100G_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  /** build() - Method to build various component */
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Entered ...", UVM_LOW)

    super.build_phase(phase);
 
    /** Disable the virtual default sequence on the the virtual sequencer started in the ethernet_base_test */
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_0.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_1.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    `ifdef n6000_10G
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_2.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_3.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_4.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_5.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_6.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_7.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    Enable_scb=1; //HSD raised 16014835098.1: [N6000] HSSI RX LOOPBACK:Ethernet Protocol compliance Errors ,once solved will make scb=1 ,for now visually datacheck done
    MODE_25G_10G=1;
    `elsif n6000_25G
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_2.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_3.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    Enable_scb=1;//HSD raised 16014835098.1: [N6000] HSSI RX/CVL LOOPBACK:Ethernet Protocol compliance Errors ,once solved will make scb=1 ,for now visually datacheck done 
    CVL_25G=1;
    `elsif n6000_100G
    Enable_scb=1;//HSD raised 16014835098.1: [N6000] HSSI RX/CVL LOOPBACK:Ethernet Protocol compliance Errors ,once solved will make scb=1 ,for now visually datacheck done
    CVL_100G=1;
    `endif
    run_multiport=1;
    `ifdef n6000_10G
    uvm_config_db#(bit)::set(this, "*tb_env0*", "MODE_25G_10G", MODE_25G_10G);
   `uvm_info("build_phase", $sformatf("MODE SELECTED MODE_25G_10G ::%d", MODE_25G_10G), UVM_LOW);
    `elsif n6000_25G
    uvm_config_db#(bit)::set(this, "*tb_env0*", "CVL_25G", CVL_25G);
   `uvm_info("build_phase", $sformatf("MODE SELECTED CVL_25G ::%d", CVL_25G), UVM_LOW);
    `elsif n6000_100G
    uvm_config_db#(bit)::set(this, "*tb_env0*", "CVL_100G", CVL_100G);
   `uvm_info("build_phase", $sformatf("CVL_100G SELECTED ::%d", CVL_100G), UVM_LOW);
    `endif
    uvm_config_db#(bit)::set(this, "*tb_env0*", "run_multiport", run_multiport);
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_0", "enable", Enable_scb);
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_1", "enable", Enable_scb);
    `ifdef n6000_10G
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_2", "enable", Enable_scb);
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_3", "enable", Enable_scb);
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_4", "enable", Enable_scb);
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_5", "enable", Enable_scb);
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_6", "enable", Enable_scb);
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_7", "enable", Enable_scb);
    `elsif n6000_25G
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_2", "enable", Enable_scb);
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_3", "enable", Enable_scb);
    `endif
   `uvm_info("build_phase", $sformatf("SCOREBOARD ENABLE VALUE ::%b", Enable_scb), UVM_LOW);
   
    /** Construct the mac callback class */
    mac_callback_0 = new("mac_callback_0");
    mac_callback_1 = new("mac_callback_1");
    `ifdef n6000_10G
    mac_callback_2 = new("mac_callback_2");
    mac_callback_3 = new("mac_callback_3");
    mac_callback_4 = new("mac_callback_4");
    mac_callback_5 = new("mac_callback_5");
    mac_callback_6 = new("mac_callback_6");
    mac_callback_7 = new("mac_callback_7");
    `elsif
    mac_callback_2 = new("mac_callback_2");
    mac_callback_3 = new("mac_callback_3");
    `endif

   // /** Construct the phy callback class */
   // phy_callback = new("phy_callback");

   // /** Construct the mac monitor callback class */
    mac_mon_callback_0 = new("mac_mon_callback_0");
    mac_mon_callback_1 = new("mac_mon_callback_1");
    `ifdef n6000_10G
    mac_mon_callback_2 = new("mac_mon_callback_2");
    mac_mon_callback_3 = new("mac_mon_callback_3");
    mac_mon_callback_4 = new("mac_mon_callback_4");
    mac_mon_callback_5 = new("mac_mon_callback_5");
    mac_mon_callback_6 = new("mac_mon_callback_6");
    mac_mon_callback_7 = new("mac_mon_callback_7");
    `elsif n6000_25G
    mac_mon_callback_2 = new("mac_mon_callback_2");
    mac_mon_callback_3 = new("mac_mon_callback_3");
    `endif

   // /** Construct the phy monitor callback class */
   // phy_mon_callback = new("phy_mon_callback");

    /** Set the Configuration values for CSBI Interface for MAC and PHY agents in environment */
    //mac_cfg.set_25g_parallel_default_cfg();
   // phy_cfg.set_25g_parallel_default_cfg();

    /** Set configuration objects for MAC & PHY agents in environment */
   // uvm_config_db#(cust_svt_ethernet_agent_configuration)::set(this, "*", "mac_cfg", mac_cfg);
   // uvm_config_db#(cust_svt_ethernet_agent_configuration)::set(this, "env", "phy_cfg", phy_cfg);
    

    /** Apply the directed ethernet sequence to the ethernet txrx sequencer */
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[0].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[1].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    `ifdef n6000_10G
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[2].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[3].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[4].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[5].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[6].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[7].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    `elsif n6000_25G
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[2].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac[3].sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());
    `endif

    `uvm_info("build_phase", "Exited ...", UVM_LOW)
  endfunction : build_phase
  
  /** Connect phase **/
  function void connect_phase(uvm_phase phase);
    `uvm_info("connect_phase", "Entered ...",UVM_LOW)
    super.connect_phase(phase);
    
    /** Attaching the txrx callback on both the drivers */
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[0].driver,mac_callback_0);
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[1].driver,mac_callback_1);
    `ifdef n6000_10G
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[2].driver,mac_callback_2);
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[3].driver,mac_callback_3);
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[4].driver,mac_callback_4);
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[5].driver,mac_callback_5);
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[6].driver,mac_callback_6);
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[7].driver,mac_callback_7);
    `elsif n6000_25G
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[2].driver,mac_callback_2);
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac[3].driver,mac_callback_3);   
    `endif
   // uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(env.vip_ethernet_phy.driver,phy_callback);
   // 
   // /** Attaching the monitor callback on both the monitors */
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[0].monitor,mac_mon_callback_0);
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[1].monitor,mac_mon_callback_1);
    `ifdef n6000_10G
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[2].monitor,mac_mon_callback_2);
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[3].monitor,mac_mon_callback_3);
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[4].monitor,mac_mon_callback_4);
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[5].monitor,mac_mon_callback_5);
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[6].monitor,mac_mon_callback_6);
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[7].monitor,mac_mon_callback_7);
    `elsif n6000_25G
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[2].monitor,mac_mon_callback_2);
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac[3].monitor,mac_mon_callback_3);
    `endif
   // uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(env.vip_ethernet_phy.monitor,phy_mon_callback);
    
    `uvm_info("connect_phase", "Exited ...",UVM_LOW)
  endfunction : connect_phase

            

  task main_phase(uvm_phase phase);
    `ifdef SVT_UVM_1800_2_2017_OR_HIGHER
        uvm_objection phase_over;
    `endif
    static integer i_0=0 ;
    static integer j_0=0 ;
    static integer k_0=0 ;
    static integer i_1=0 ;
    static integer j_1=0 ;
    static integer k_1=0 ;
    `ifdef n6000_10G
    static integer i_2=0 ;
    static integer j_2=0 ;
    static integer k_2=0 ;


    static integer i_3=0 ;
    static integer j_3=0 ;
    static integer k_3=0 ;

    static integer i_4=0 ;
    static integer j_4=0 ;
    static integer k_4=0 ;
   
    static integer i_5=0 ;
    static integer j_5=0 ;
    static integer k_5=0 ;
   
    static integer i_6=0 ;
    static integer j_6=0 ;
    static integer k_6=0 ;
   
    static integer i_7=0 ;
    static integer j_7=0 ;
    static integer k_7=0 ;
    `endif
    int pkt = 10;
    phase.raise_objection(this);
    `uvm_info("main_phase", "Entered ...",UVM_LOW)
    `uvm_info("main_phase", $sformatf("Setting the drain time in the main_phase of the base test to 24 NS"), UVM_NONE)

`ifdef SVT_UVM_1800_2_2017_OR_HIGHER
    phase_over = phase.get_objection();
    phase_over.set_drain_time(this, (24000));
`else
    phase.phase_done.set_drain_time(this, (24000));
`endif




    `uvm_info("main_phase", "Exited ...",UVM_LOW)
    phase.drop_objection(this);
  endtask


//task run_phase(uvm_phase phase);
task pre_main_phase(uvm_phase phase);
        `uvm_info("RUN_phase", "Entered ...",UVM_LOW)
        super.pre_main_phase(phase);
     	phase.raise_objection(this);
    `uvm_info("SNPS_ERROR_DISABLE_START", "...",UVM_LOW)
        // disable_VIP_ERR();


    `uvm_info("SNPS_ERROR_DISABLE_END", "...",UVM_LOW)
    `ifdef n6000_25G
     Enable_scb=1'b1;
    `endif
        
    fork 
        begin
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_0 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[0].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_0_LINK_UP DONE"), UVM_LOW)
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_1 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[1].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_1_LINK_UP DONE"), UVM_LOW)
             `ifdef n6000_10G
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_2 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[2].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_2_LINK_UP DONE"), UVM_LOW)
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_3 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[3].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_3_LINK_UP DONE"), UVM_LOW)
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_4 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[4].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_4_LINK_UP DONE"), UVM_LOW)
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_5 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[5].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_5_LINK_UP DONE"), UVM_LOW)
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_6 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[6].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_6_LINK_UP DONE"), UVM_LOW)
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_7 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[7].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_7_LINK_UP DONE"), UVM_LOW)
             `elsif n6000_25G
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_2 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[2].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_2_LINK_UP DONE"), UVM_LOW)
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_3 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[3].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_3_LINK_UP DONE"), UVM_LOW)
             `endif
        end

        //begin
        //     `uvm_info("25G_DIRECTED_TEST", $sformatf("Waiting for TX_LANE_STABLE and PCS READY STABLE"), UVM_LOW)
        //    wait(n6000_tb_top.DUT.hssi_wrapper.hssi_ss.p0_tx_lanes_stable);
        //     `uvm_info("25G_DIRECTED_TEST", $sformatf("TX_LANE_STABLE:DONE"), UVM_LOW)
        //    wait(n6000_tb_top.DUT.hssi_wrapper.hssi_ss.p0_rx_pcs_ready);                         
        //     `uvm_info("25G_DIRECTED_TEST", $sformatf("PCS_READY_STABLE:DONE"), UVM_LOW)
        //    #50us;
        //end
        begin 
               `uvm_info("START THE RX_LPBK_SEQUECE", "...",UVM_LOW)
	//base_seq =n6000_base_seq::type_id::create("base_seq");
	//base_seq.start(tb_env0.v_sequencer);
	//eth_seq =ethernet_directed_sequence::type_id::create("eth_seq");
	//eth_seq.start(tb_env0.v_sequencer);
	//eth_seq.start(tb_env0.env.sequencer);
         rx_lpbk_seq=he_hssi_rx_lpbk_seq::type_id::create("rx_lpbk_seq");
	 rx_lpbk_seq.start(tb_env0.v_sequencer);
       
      `uvm_info("RX_LPBK_SEQUECE_COMPLETED", "...",UVM_LOW)
      `ifdef n6000_10G
        #200us;
      `elsif n6000_25G
        #200us;
      `elsif n6000_100G
      //Check for all pcs_ready HIGH
      wait(tb_top.DUT.hssi_wrapper.hssi_ss.p0_rx_pcs_ready &&  tb_top.DUT.hssi_wrapper.hssi_ss.p4_rx_pcs_ready && tb_top.DUT.hssi_wrapper.hssi_ss.p8_rx_pcs_ready && tb_top.DUT.hssi_wrapper.hssi_ss.p12_rx_pcs_ready) ;
      `uvm_info("PCS_READY_HIGH", "...",UVM_LOW)
      #10us;
      `endif
      end
   join
  `uvm_info("PRE_MAIN_PHASE_ENDED", "..25G_DIRECTED_TEST.",UVM_LOW)

	phase.drop_objection(this);

    endtask : pre_main_phase


endclass
