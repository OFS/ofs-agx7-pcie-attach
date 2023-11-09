// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_WRITE_RESET_TEST_SVH
`define QSFP_WRITE_RESET_TEST_SVH

class qsfp_write_reset_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_write_reset_test)

  qsfp_write_reset_seq m_seq, m_seq1;
  qsfp_init_seq init_seq;
  qsfp_poller_enable_disable_seq pl_en_seq;
  qsfp_axi_write_seq wr_seq;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    dis_sb=1'b1;
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    m_seq = qsfp_write_reset_seq::type_id::create("m_seq");
    init_seq = qsfp_init_seq::type_id::create("init_seq");
    m_seq1 = qsfp_write_reset_seq::type_id::create("m_seq1",this);
    wr_seq = qsfp_axi_write_seq::type_id::create("wr_seq",this);
    pl_en_seq = qsfp_poller_enable_disable_seq::type_id::create("pl_en_seq");
        
    //----------------------------Disabling Poll_en bit for POLLER Operation ------------------------------ //
    
    assert (pl_en_seq.randomize() with{ en==0;})
    pl_en_seq.start(tb_env0.v_sequencer); 
   
    fork
      begin
      
    //--------------Apply hard reset QSFPC in between performing read's------------------//
      
      #250000ns;
     
      `uvm_info(get_name(), $psprintf("Asserting Reset during AXI Write"), UVM_LOW)
      qsfp_tb_top.reset_n = 1'b0;
      end
      
      begin
      
    //----------------------- Wriiting to QSFP Module Registers----------------------//
            
      #10ns;
      assert (m_seq.randomize() with{ wr==1;})
      m_seq.start(tb_env0.v_sequencer);
      
      end
    join_any
    
    m_seq.kill();
    
    #10000ns;
    `uvm_info(get_name(), $psprintf("Deasserting Reset "), UVM_LOW)
    qsfp_tb_top.reset_n = 1'b1;
    
    //m_seq.kill();
    //----------------------Starting init sequence after every reset---------------//

    init_seq.start(tb_env0.v_sequencer);
    
    //----------------Resuming write transactions after HARD reset-----------------//
 
    //assert (m_seq1.randomize() with{ wr==1;})
    //m_seq1.start(tb_env0.v_sequencer);

    wr_seq.start(tb_env0.v_sequencer); 
   
    //----------------------------Enabling Poll_en bit for POLLER Operation ------------------------------ //
    
    assert (pl_en_seq.randomize() with{ en==1;})
    pl_en_seq.start(tb_env0.v_sequencer); 

    #500ns;
    assert (m_seq1.randomize() with{ wr==0;})
    m_seq1.start(tb_env0.v_sequencer);
    phase.drop_objection(this);
  
  endtask : run_phase

endclass : qsfp_write_reset_test

`endif // QSFP_WRITE_RESET_TEST_SVH

