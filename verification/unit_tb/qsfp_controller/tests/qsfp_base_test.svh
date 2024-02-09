// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_BASE_TEST_SVH
`define QSFP_BASE_TEST_SVH



class qsfp_base_test extends uvm_test;
    `uvm_component_utils(qsfp_base_test)

    qsfp_tb_config tb_cfg0;
    virtual qsfp_intf qsfpif;
    virtual qsfp_slave_interface qsfp_slv_if;
    virtual `AXI_IF  axi_if;
    qsfp_tb_env    tb_env0;
    uvm_table_printer printer;
    int               regress_mode_en;
    int               timeout;
    int               test_pass = 1;
    int               sim_length_reached;
    uvm_report_object reporter;
    bit               exp_timeout = 0;
    bit               dis_init_seq;
    bit               dis_sb;
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        string regress_mode_en_str;
        super.build_phase(phase);

        `uvm_info("qsfp_base_test","Base test : Entered build phase ",UVM_LOW)    
  
	tb_cfg0 = qsfp_tb_config::type_id::create("tb_cfg0", this);
        tb_cfg0.has_sb = dis_sb;
       // randomize(tb_cfg0);
	uvm_config_db #(qsfp_tb_config)::set(this, "*","tb_cfg0", tb_cfg0);
       uvm_config_db#(virtual qsfp_intf)::get(this, "", "qsfpif",tb_cfg0.qsfp_if);
       uvm_config_db#(virtual qsfp_slave_interface)::get(this, "", "vif",tb_cfg0.qsfp_slv_if);
       uvm_config_db#(virtual `AXI_IF)::get(this, "", "vif",tb_cfg0.axi_if);
	
	tb_env0 = qsfp_tb_env::type_id::create("tb_env0", this);


	/** Set the default_sequence for slave vip */
        //uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.axi_system_env.slave[0].sequencer.run_phase", "default_sequence", axi_slave_mem_response_sequence::type_id::get());
        /** Apply the default reset sequence */
        //uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.v_sequencer.hssi_axi4_lt_mst_seqr.reset_phase", "default_sequence", axi_simple_reset_sequence::type_id::get());
        //uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.v_sequencer.configure_phase", "default_sequence", qsfp_init_seq::type_id::get());
        uvm_config_db#(uvm_object_wrapper)::set(this, "tb_env0.qsfp_slv_env.qsfp_agent.sequencer.run_phase", "default_sequence", qsfp_slave_auto_response_sequence::type_id::get());

        printer = new();
        printer.knobs.depth = 5;
        printer.knobs.name_width = 40;
        printer.knobs.type_width = 32;
        printer.knobs.value_width = 32;

        if($value$plusargs("REGRESS_MODE=%s", regress_mode_en_str)) begin
            regress_mode_en = regress_mode_en_str.atoi();   //1-Regress Mode 0-Smoke Mode
            set_config_int("*.v_sequencer", "regress_mode_en", regress_mode_en);
        end		
	
        `uvm_info("qsfp_base_test","Base test : Exiting build phase ",UVM_LOW)    
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
	uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

    task configure_phase(uvm_phase phase);
       if(!dis_init_seq) begin
         qsfp_init_seq init_seq;
         super.configure_phase(phase);
         phase.raise_objection(this);
         `uvm_info("qsfp_base_test","Base test : Starting configure task ",UVM_LOW)    
         init_seq = qsfp_init_seq::type_id::create("init_seq");
         init_seq.start(tb_env0.v_sequencer);
         `uvm_info("qsfp_base_test","Base test : Exiting configure task ",UVM_LOW)    
	 phase.drop_objection(this);
       end
       else begin 
         `uvm_info("qsfp_base_test","Base test : Starting configure task ",UVM_LOW)    
         `uvm_info("qsfp_base_test","Base test : Exiting configure task ",UVM_LOW)    
       end
    endtask : configure_phase


    task main_phase(uvm_phase phase);
        super.main_phase(phase);
        phase.raise_objection(this);
        `uvm_info("qsfp_base_test","Base test : Entered RUN PHASE ",UVM_LOW)    
         #10ns;
        `uvm_info("qsfp_base_test","Base test : Exiting RUN PHASE ",UVM_LOW)    
	phase.drop_objection(this);
      
	//uvm_top.print_topology();
    endtask : main_phase


    virtual task timeout_watch(uvm_phase phase);
        string msgid;
        int timeout,flush_timeout;
        string timeout_str;
        
        msgid = get_name();
        timeout=this.timeout;

        if(!timeout) begin
            if($value$plusargs("TIMEOUT=%s", timeout_str)) begin
                timeout = timeout_str.atoi();   // in us
            end else
                timeout = 2000;
        end

        reporter.uvm_report_info(msgid, $psprintf("TIMEOUT = %d", timeout), UVM_LOW);            
        repeat(timeout) begin
            # 1us;         
        end
        sim_length_reached = 1;
        reporter.uvm_report_info(msgid, "Reached simulation duration, finishing test...", UVM_LOW);
 
        //Regress mode tests run for 'timeout', so need larger flush times       
        flush_timeout=(timeout>2000)?2*timeout:2000;

        repeat(flush_timeout) begin
            # 1us;         
        end
        test_pass = 0;
        if(regress_mode_en) phase.phase_done.display_objections();
        if (exp_timeout) begin
            `uvm_warning(msgid, "*** TIMED OUT! ***")   
            phase.phase_done.display_objections();
        end else begin
            `uvm_fatal(msgid, "*** TIMED OUT! ***")    
        end
    endtask : timeout_watch
endclass : qsfp_base_test

`endif // QSFP_BASE_TEST_SVH
