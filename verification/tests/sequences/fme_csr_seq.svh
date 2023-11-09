//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class fme_csr_seq is executed by fme_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 *  Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef FME_CSR_SEQ_SVH
`define FME_CSR_SEQ_SVH

class fme_csr_seq extends base_seq;
   `uvm_object_utils(fme_csr_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)

    uvm_reg m_regs[$];
    string m_regs_a[string];
    uvm_reg_data_t wdata, rdata;
    uvm_status_e   status;
    bit [63:0] r_array[string] ;
    bit [63:0] w_array[string] ;


    function new(string name = "fme_csr_seq");
        super.new(name);
    endfunction : new
 
    task body();
        super.body();
        r_array["BITSTREAM_ID"] = 64'h123450789abcdef;
        tb_env0.fme_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
	wr_rd_cmp(m_regs,m_regs_a,w_array);

    endtask : body

    
endclass : fme_csr_seq

`endif // FME_CSR_SEQ_SVH

