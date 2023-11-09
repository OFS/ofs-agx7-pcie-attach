// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_I2C_POLLER_DISABLE_TEST_SVH
`define QSFP_I2C_POLLER_DISABLE_TEST_SVH

class qsfp_i2c_poller_disable_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_i2c_poller_disable_test)

  qsfp_i2c_poller_disable_seq m_seq;
  qsfp_poller_enable_disable_seq pl_en_seq;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    m_seq = qsfp_i2c_poller_disable_seq::type_id::create("m_seq");
    pl_en_seq = qsfp_poller_enable_disable_seq::type_id::create("pl_en_seq");
        
    //----------------------------Enabling Poll_en bit for POLLER Operation ------------------------------ //
    #1000ns; 
    assert (pl_en_seq.randomize() with{ en==1;})
    pl_en_seq.start(tb_env0.v_sequencer); 
                         
    //#500000ns;
    #50ms;
    //--------------------Disable poller in between performing read's-----------//

    assert (pl_en_seq.randomize() with{ en==0;})
    pl_en_seq.start(tb_env0.v_sequencer); 
    
    //--------------------------Reeading from status register for fsm paused checking----------------------//

    #20ns;
    m_seq.start(tb_env0.v_sequencer);
    
    assert (pl_en_seq.randomize() with{ en==1;})
    pl_en_seq.start(tb_env0.v_sequencer);

    #500000ns;
    phase.drop_objection(this);

  endtask : run_phase

endclass : qsfp_i2c_poller_disable_test

`endif // QSFP_I2C_POLLER_DISABLE_TEST_SVH

