// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_POLLER_RESET_TEST_SVH
`define QSFP_POLLER_RESET_TEST_SVH

class qsfp_poller_reset_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_poller_reset_test)

  qsfp_poller_rst_seq m_seq;
  qsfp_init_seq                      init_seq;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    m_seq = qsfp_poller_rst_seq::type_id::create("m_seq",this);
    init_seq = qsfp_init_seq::type_id::create("init_seq",this);
    
    //--------apply poller reset in middle of issuing poller fsm read---//
    assert (m_seq.randomize() with { poller_rst == 0;})
    m_seq.start(tb_env0.v_sequencer);

    //--------add init sequence after every reset---//
    init_seq.start(tb_env0.v_sequencer);

    //---------access qsfpm register write and shadow csr read--//
    assert (m_seq.randomize() with { poller_rst == 1;})
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);

  endtask : run_phase

endclass : qsfp_poller_reset_test

`endif // QSFP_POLLER_RESET_TEST_SVH

