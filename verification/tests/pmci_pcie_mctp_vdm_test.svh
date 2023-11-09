//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef PMCI_PCIE_MCTP_VDM_TEST
`define PMCI_PCIE_MCTP_VDM_TEST

class pmci_pcie_mctp_vdm_test extends base_test;
    `uvm_component_utils(pmci_pcie_mctp_vdm_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     uvm_config_db#(int)::set(this,"*tb_env0*","bmc_en",1);
     tb_cfg0.has_rx_sb = 1;
    endfunction : build_phase


    task run_phase(uvm_phase phase);
        pmci_pcie_mctp_vdm_seq m_seq;
        super.run_phase(phase);
	phase.raise_objection(this);
        `ifdef INCLUDE_PMCI
	  m_seq = pmci_pcie_mctp_vdm_seq::type_id::create("m_seq");
          assert(m_seq.randomize() with {m_seq.source_id==1;}); //rx_length- between 1 to 256DW's;source_id-1(null SID),0-(Configured CSR source ID) 
	  m_seq.start(tb_env0.v_sequencer);
        `endif
	phase.drop_objection(this);
    endtask : run_phase

endclass : pmci_pcie_mctp_vdm_test

`endif // PMCI_PCIE_MCTP_VDM_TEST
