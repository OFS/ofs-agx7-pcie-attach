
/**
 * Abstract:
 * The file contains the class extended from ethernet_base_test
 * A simple directed test showcases the use of the directed sequence.
 * It disables the base test case virtual sequence on the virtual sequencer.
 * Aftet that a directed sequence is set on the agent's  txrx sequencer.
 *
 * The intention of the test is to employ the usage of user configurable align marker for CSBI interface
*/

`include "ethernet_base_test_400G.sv"

`include "ethernet_directed_sequence.sv"
`include "ethernet_null_virtual_sequence.sv"
`include "ethernet_mac_sb_callbacks.sv"
//`include "ethernet_phy_sb_callbacks.sv"
//`include "ethernet_phy_monitor_callbacks.sv"
`include "ethernet_mac_monitor_callbacks.sv"

class he_hssi_rx_lpbk_400G_test extends ethernet_base_test;

  /** UVM component utility macro */
  `uvm_component_utils(he_hssi_rx_lpbk_400G_test)

  /** Declare a handle of the mac callback class */
  ethernet_mac_sb_callbacks mac_callback_0;

  /** Declare a handle of the phy callback class */
 // ethernet_phy_sb_callbacks phy_callback;

  /** Declare a handle of the mac monitor class */
  ethernet_mac_monitor_callbacks mac_mon_callback_0;

  /** Declare a handle of the phy monoitor class */
ethernet_directed_sequence eth_seq;
he_hssi_rx_lpbk_seq rx_lpbk_seq;
int Lane;
bit Enable_scb;
  /** Class constructor */
  function new(string name = "he_hssi_rx_lpbk_400G_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  /** build() - Method to build various component */
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Entered ...", UVM_LOW)

    super.build_phase(phase);
 
    /** Disable the virtual default sequence on the the virtual sequencer started in the ethernet_base_test */
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.sequencer_0.main_phase", "default_sequence", ethernet_null_virtual_sequence::type_id::get());
    Enable_scb=1; //HSD raised 16014835098.1: [N6000] HSSI RX LOOPBACK:Ethernet Protocol compliance Errors ,once solved will make scb=1 ,for now visually datacheck done
    uvm_config_db#(bit)::set(this, "tb_env0.env.ethernet_scoreboard_0", "enable", Enable_scb);

   `uvm_info("build_phase", $sformatf("SCOREBOARD ENABLE VALUE ::%b", Enable_scb), UVM_LOW);
   
    /** Construct the mac callback class */
    mac_callback_0 = new("mac_callback_0");

   // /** Construct the phy callback class */
   // phy_callback = new("phy_callback");

   // /** Construct the mac monitor callback class */
    mac_mon_callback_0 = new("mac_mon_callback_0");

   // /** Construct the phy monitor callback class */
   // phy_mon_callback = new("phy_mon_callback");

    /** Set the Configuration values for CSBI Interface for MAC and PHY agents in environment */
    //mac_cfg.set_25g_parallel_default_cfg();
   // phy_cfg.set_25g_parallel_default_cfg();

    /** Set configuration objects for MAC & PHY agents in environment */
   // uvm_config_db#(cust_svt_ethernet_agent_configuration)::set(this, "*", "mac_cfg", mac_cfg);
   // uvm_config_db#(cust_svt_ethernet_agent_configuration)::set(this, "env", "phy_cfg", phy_cfg);
    

    /** Apply the directed ethernet sequence to the ethernet txrx sequencer */
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.env.vip_ethernet_mac.sequencer.main_phase", "default_sequence", ethernet_directed_sequence::type_id::get());

    `uvm_info("build_phase", "Exited ...", UVM_LOW)
  endfunction : build_phase
  
  /** Connect phase **/
  function void connect_phase(uvm_phase phase);
    `uvm_info("connect_phase", "Entered ...",UVM_LOW)
    super.connect_phase(phase);
    
    /** Attaching the txrx callback on both the drivers */
    uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(tb_env0.env.vip_ethernet_mac.driver,mac_callback_0);

    // uvm_callbacks#(svt_ethernet_txrx,svt_ethernet_txrx_callback)::add(env.vip_ethernet_phy.driver,phy_callback);
   // 
   // /** Attaching the monitor callback on both the monitors */
    uvm_callbacks#(svt_ethernet_monitor,svt_ethernet_monitor_callback)::add(tb_env0.env.vip_ethernet_mac.monitor,mac_mon_callback_0);

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
        
    fork 
        begin
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_0 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac.monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_0_LINK_UP DONE"), UVM_LOW)
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
        #200us;
      end
   join
  `uvm_info("PRE_MAIN_PHASE_ENDED", "..25G_DIRECTED_TEST.",UVM_LOW)

	phase.drop_objection(this);

    endtask : pre_main_phase


endclass
