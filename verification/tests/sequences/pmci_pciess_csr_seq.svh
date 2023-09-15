//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class pmci_pciess_csr_seq is executed by pmci_pciess_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef PMCI_PCIESS_CSR_SEQ_SVH
`define PMCI_PCIESS_CSR_SEQ_SVH

class pmci_pciess_csr_seq extends base_seq;
  `uvm_object_utils(pmci_pciess_csr_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)


  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;
  
  function new(string name = "pmci_pciess_csr_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    `uvm_info(get_name(), "Entering pciess_csr_seq...", UVM_LOW)
	
	address  =PCIE_BASE_ADDR;
    exp_data     =64'h3000000020000020;
    `uvm_info(get_name(), $psprintf("Reading from PCIE DFH"), UVM_LOW)
    rd_tx_register(address,exp_data);

                                                                                                         
	address  =PCIE_BASE_ADDR+'h8;
    exp_data =64'h0000000000000000;           
    `uvm_info(get_name(), $psprintf("Reading from PCIE scratchpad register"), UVM_LOW)
    rd_tx_register(address,exp_data); 


    address  =PCIE_BASE_ADDR+'h10;
    exp_data   =64'h0000_0000_0000_0001;     
    `uvm_info(get_name(), $psprintf("Reading from PCIE status register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

  
    address  =PCIE_BASE_ADDR+'h18;
    exp_data =64'h0000_0000_0000_0000; 
    `uvm_info(get_name(), $psprintf("Reading from PCIE error masking register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
	
	
	address  =PCIE_BASE_ADDR+'h20;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from PCIE error status register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    
	address  =PCIE_BASE_ADDR+'h8;
    data     =64'hdead_beef;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to PCIE scratchpad register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
	
	address  =PCIE_BASE_ADDR+'h8;
    exp_data =64'hdead_beef;           
    `uvm_info(get_name(), $psprintf("Reading from PCIE scratchpad register"), UVM_LOW)
    rd_tx_register(address,exp_data);
	
	address  =PCIE_BASE_ADDR+'h18;
    data     =64'hdead_beef;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to PCIE error masking register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
	
	address  =PCIE_BASE_ADDR+'h18;
    exp_data =64'hdead_beef;
    `uvm_info(get_name(), $psprintf("Reading from PCIE error masking register"), UVM_LOW)
    rd_tx_register(address,exp_data);
	
	address  =PCIE_BASE_ADDR+'h20;
    data     =64'h0000_0000_0000_01ff;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to PCIE error status register"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

	address  =PCIE_BASE_ADDR+'h18;
    data     =64'h0000_0000_0000_0000;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Clearing off error masking registers"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
 
	address  =PCIE_BASE_ADDR+'h20;
    exp_data =64'h0000_0000_0000_0000;
    `uvm_info(get_name(), $psprintf("Reading from PCIE error status register"), UVM_LOW)
    rd_tx_register(address,exp_data);
    
    `uvm_info(get_name(), "Exiting pciess_csr_seq...", UVM_LOW)
	
	endtask : body


     task err_pcie_inj();
     begin
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ca_postedreq_s3 = 1'b1; 
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ca_postedreq_s2 = 1'b1;    
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ca_postedreq_s1 = 1'b1; 
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ca_postedreq_s0 = 1'b1; 
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ur_postedreq_s3 = 1'b1; 
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ur_postedreq_s2 = 1'b1; 
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ur_postedreq_s1 = 1'b1; 
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ur_postedreq_s0 = 1'b1; 
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedcompl_s3 =1'b1;  
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedcompl_s2 =1'b1;
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedcompl_s1 =1'b1;
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedcompl_s0 =1'b1;
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedwrreq_s3 =1'b1;
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedwrreq_s2 =1'b1;
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedwrreq_s1 =1'b1;
             force `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedwrreq_s0 =1'b1;

             #1us;

	     address  =PCIE_BASE_ADDR+'h20;
             exp_data =64'h0000_0000_0000_ffff;
             `uvm_info(get_name(), $psprintf("Reading from PCIE error status register"), UVM_LOW)
             rd_tx_register(address,exp_data);
              
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ca_postedreq_s3; 
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ca_postedreq_s2;    
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ca_postedreq_s1; 
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ca_postedreq_s0; 
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ur_postedreq_s3; 
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ur_postedreq_s2; 
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ur_postedreq_s1; 
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_ur_postedreq_s0; 
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedcompl_s3;  
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedcompl_s2;
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedcompl_s1;
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedcompl_s0;
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedwrreq_s3;
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedwrreq_s2;
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedwrreq_s1;
             release `PCIE_SS_TOP.pcie_ss.pcie_ss.p0_tileif.ss_app_vf_err_poisonedwrreq_s0; 

     end
     endtask

endclass : pmci_pciess_csr_seq

`endif // PMCI_PCIESS_CSR_SEQ_SVH
