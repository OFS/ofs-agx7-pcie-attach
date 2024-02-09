//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT

/**
 * Abstract:
 * The file contains the class extended from ethernet_base_test
 * A simple directed test showcases the use of the directed sequence.
 * It disables the base test case virtual sequence on the virtual sequencer.
 * Aftet that a directed sequence is set on the agent's  txrx sequencer.
 *
 * The intention of the test is to employ the usage of user configurable align marker for CSBI interface
*/

`include "ethernet_base_test_10_25.sv"
`include "ethernet_directed_sequence.sv"

class he_hssi_rx_lpbk_25G_10G_test extends ethernet_base_test;

  /** UVM component utility macro */
  `uvm_component_utils(he_hssi_rx_lpbk_25G_10G_test)

   
  /** Declare a handle of the phy monoitor class */
ethernet_directed_sequence eth_seq;
he_hssi_rx_lpbk_seq rx_lpbk_seq;
bit Enable_scb;
bit MODE_25G_10G;
bit run_multiport;
  /** Class constructor */
  function new(string name = "he_hssi_rx_lpbk_25G_10G_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  /** build() - Method to build various component */
  virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Entered ...", UVM_LOW)

    super.build_phase(phase);
 
       Enable_scb=1; 
    MODE_25G_10G=1;
    run_multiport=1;
    uvm_config_db#(bit)::set(this, "*tb_env0*", "MODE_25G_10G", MODE_25G_10G);
   `uvm_info("build_phase", $sformatf("MODE SELECTED MODE_25G_10G ::%d", MODE_25G_10G), UVM_LOW);
    uvm_config_db#(bit)::set(this, "*tb_env0*", "run_multiport", run_multiport);
      `uvm_info("build_phase", $sformatf("SCOREBOARD ENABLE VALUE ::%b", Enable_scb), UVM_LOW);
   
     

    /** Apply the directed ethernet sequence to the ethernet txrx sequencer */
   
     for(int i=0 ;i<8 ; i++)
      begin
         uvm_config_db#(bit)::set(this, $sformatf("tb_env0.env.ethernet_scoreboard[%0d]",i), "enable", Enable_scb);
         uvm_config_db#(uvm_object_wrapper)::set(this, $sformatf("tb_env0.env.vip_ethernet_mac[%0d].sequencer.main_phase",i), "default_sequence", ethernet_directed_sequence::type_id::get());
      end

    `uvm_info("build_phase", "Exited ...", UVM_LOW)
  endfunction : build_phase
  
  /** Connect phase **/
  function void connect_phase(uvm_phase phase);
    `uvm_info("connect_phase", "Entered ...",UVM_LOW)
    super.connect_phase(phase);
    
       
    `uvm_info("connect_phase", "Exited ...",UVM_LOW)
  endfunction : connect_phase

            

  task main_phase(uvm_phase phase);
       
   int pkt=10;

    phase.raise_objection(this);
    `uvm_info("main_phase", "Entered ...",UVM_LOW)
    `uvm_info("main_phase", $sformatf("Setting the drain time in the main_phase of the base test to 24 NS"), UVM_NONE)


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
   `ifndef ETH_400G    
    fork 
        begin
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_0 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[0].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_0_LINK_UP DONE"), UVM_LOW)
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_1 LINK_UP STARTED"), UVM_LOW)
               tb_env0.env.vip_ethernet_mac[1].monitor.EVENT_LINK_UP.wait_trigger();
             `uvm_info("25G_DIRECTED_TEST", $sformatf("VIP_1_LINK_UP DONE"), UVM_LOW)
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
        end

        begin 
         `uvm_info("START THE RX_LPBK_SEQUECE", "...",UVM_LOW)
         rx_lpbk_seq=he_hssi_rx_lpbk_seq::type_id::create("rx_lpbk_seq");
	 rx_lpbk_seq.start(tb_env0.v_sequencer);
       
      `uvm_info("RX_LPBK_SEQUECE_COMPLETED", "...",UVM_LOW)
        end 
   join
     #100us;
   `endif
  `uvm_info("PRE_MAIN_PHASE_ENDED", "..25G_DIRECTED_TEST.",UVM_LOW)

	phase.drop_objection(this);

    endtask : pre_main_phase


endclass
