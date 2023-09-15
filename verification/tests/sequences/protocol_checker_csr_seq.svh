//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class protocol_checker_csr_seq is executed by protocol_checker_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef AFU_INTF_CSR_SEQ_SVH
`define AFU_INTF_CSR_SEQ_SVH

class protocol_checker_csr_seq extends base_seq;
    `uvm_object_utils(protocol_checker_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    uvm_reg m_regs[$];
    string m_regs_a[string];
    uvm_reg_data_t wdata, rdata;
    uvm_status_e   status;
    bit [63:0] r_array[string] ;
    bit [63:0] w_array[string] ;

    function new(string name = "protocol_checker_csr_seq");
        super.new(name);
    endfunction : new

    task body();
        super.body();
        tb_env0.afu_intf_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
	wr_rd_cmp(m_regs,m_regs_a,w_array);
    endtask : body

    
endclass :protocol_checker_csr_seq 
`endif
