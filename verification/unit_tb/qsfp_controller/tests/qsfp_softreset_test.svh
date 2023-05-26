// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SOFTRESET_TEST_SVH
`define QSFP_SOFTRESET_TEST_SVH

class qsfp_softreset_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_softreset_test)

  qsfp_softrst_seq m_seq;
  qsfp_init_seq init_seq;
  qsfp_poller_enable_disable_seq pl_en_seq;
  qsfp_axi_write_seq wr_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    dis_sb = 1'b1;
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    phase.raise_objection(this);
    m_seq = qsfp_softrst_seq::type_id::create("m_seq",this);
    pl_en_seq = qsfp_poller_enable_disable_seq::type_id::create("pl_en_seq");
    init_seq = qsfp_init_seq::type_id::create("init_seq",this);
    wr_seq = qsfp_axi_write_seq::type_id::create("wr_seq",this);
   
    `uvm_info(get_name(), $psprintf("qsfp_softreset_test START"), UVM_LOW)
    
    //---------access qsfpm register - AXI write -----------------------------//

    wr_seq.start(tb_env0.v_sequencer); 
    
    //----------------------------Enabling Poll_en bit for POLLER Operation ------------------------------ //
    
    assert (pl_en_seq.randomize() with{ en==1;})
    pl_en_seq.start(tb_env0.v_sequencer); 

    //--------apply poller reset in middle of issuing poller fsm read---//
    #20000ns; 
    #10000ns;

    assert (m_seq.randomize() with { s_reset == 1;})
    m_seq.start(tb_env0.v_sequencer);
    
    wr_seq.kill();

    #100ns;
    //--------add init sequence after every reset---//
    
    init_seq.start(tb_env0.v_sequencer);

    #100ns;
    //---------access qsfpm register write and shadow csr read--//
    
    assert (m_seq.randomize() with { s_reset == 0;})
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);

  endtask : run_phase

endclass : qsfp_softreset_test

`endif // QSFP_SOFTRESET_TEST_SVH

