//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef PCIE_PMCI_MCTP_MULTI_VDM_TEST_SVH
`define PCIE_PMCI_MCTP_MULTI_VDM_TEST_SVH

class pcie_pmci_mctp_multi_vdm_test extends base_test;
    `uvm_component_utils(pcie_pmci_mctp_multi_vdm_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db#(int)::set(this,"*tb_env0*","bmc_en",1);
      tb_cfg0.has_tx_sb=1;
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        pcie_pmci_mctp_multi_vdm_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
        `ifdef INCLUDE_PMCI
	  m_seq = pcie_pmci_mctp_multi_vdm_seq::type_id::create("m_seq");
          assert(m_seq.randomize() with {m_seq.csr_cfg==0;}); //tx_length-between 1 to 256. csr_cfg to select configured EID/not 
	  m_seq.start(tb_env0.v_sequencer);
          #500ns;
        `endif
	phase.drop_objection(this);
    endtask : run_phase

endclass : pcie_pmci_mctp_multi_vdm_test

`endif // PCIE_PMCI_MCTP_MULTI_VDM_TEST
