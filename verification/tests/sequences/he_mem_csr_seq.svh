//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class he_mem_csr_seq is executed by he_mem_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef HE_MEM_CSR_SEQ_SVH
`define HE_MEM_CSR_SEQ_SVH

class he_mem_csr_seq extends base_seq;
    `uvm_object_utils(he_mem_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    uvm_reg m_regs[$];
    uvm_reg m_regs_m[$];
    string m_regs_a[string],m_regs_b[string];
    uvm_reg_data_t wdata, rdata;
    uvm_status_e   status;
    bit [63:0] r_array[string] ;
    bit [63:0] w_array[string], w_a_array[string];


    function new(string name = "he_mem_csr_seq");
        super.new(name);
    endfunction : new
 
    task body();
       super.body();
       `ifdef INCLUDE_DDR4
        r_array["HE_ID_L"] = 64'hbb652a578330a8eb;
        r_array["HE_ID_H"] = 64'h8568ab4e6ba54616;
       `endif
	m_regs_a["INFO0"] = "INFO0_REG";
        tb_env0.mem_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
     // HE-MEM Configuration is allowed only when CSR_CTL [0] = 1 & CSR_CTL [1] = 0.
       	m_regs_m[0] = tb_env0.mem_regs.get_reg_by_name("CTL");
        w_a_array["CTL"] = 64'h0000_0000_0000_0001; // Program CSR_CTL to remove reset HE-MEM
	wr_rd_cmp(m_regs_m,m_regs_b,w_a_array);
	m_regs_a["CTL"] = "CTL_REG";
     	wr_rd_cmp(m_regs,m_regs_a,w_array);
    endtask : body

       
endclass : he_mem_csr_seq

`endif // HE_MEM_CSR_SEQ_SVH
 


