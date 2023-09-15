// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_BACKPRESS_DUT_TEST_SVH
`define QSFP_BACKPRESS_DUT_TEST_SVH

class qsfp_backpress_dut_test extends qsfp_base_test;
  `uvm_component_utils(qsfp_backpress_dut_test)
  qsfp_bkp_dut_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    dis_sb=1'b1;
  endfunction : new

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("qsfp_backpress_dut_test",": reached end of elaboration phase",UVM_LOW)
    tb_env0.axi_system_env.master[0].set_report_severity_id_override(UVM_ERROR,"sample()",UVM_INFO);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info("qsfp_backpress_dut_test",": Starting Read and Write task for CSR Registers",UVM_LOW)
    m_seq = qsfp_bkp_dut_seq::type_id::create("m_seq",this);
    m_seq.start(tb_env0.v_sequencer);
    phase.drop_objection(this);
  endtask : run_phase

endclass : qsfp_backpress_dut_test

`endif // QSFP_BACKPRESS_DUT_TEST_SVH

