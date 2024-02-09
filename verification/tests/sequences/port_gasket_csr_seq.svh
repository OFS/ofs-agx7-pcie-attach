//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class port_gasket_csr_seq is executed by port_gasket_csr_test
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef PORT_GASKET_CSR_SEQ_SVH
`define PORT_GASKET_CSR_SEQ_SVH

 class port_gasket_csr_seq extends base_seq;
  `uvm_object_utils(port_gasket_csr_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)

    uvm_reg m_regs[$];
    string m_regs_a[string];
    uvm_reg_data_t wdata, rdata;
    uvm_status_e   status;
    bit [63:0] r_array[string] ;
    bit [63:0] w_array[string] ;

   function new(string name = "port_gasket_csr_seq");
   	super.new(name);
   endfunction : new

   task body();
       super.body();
        m_regs_a["PG_PR_STATUS"] = "PG_PR_STATUS_REG";
        m_regs_a["PG_PR_INTFC_ID_L"] = "PG_PR_INTFC_ID_L_REG";
        m_regs_a["PG_PR_INTFC_ID_H"] = "PG_PR_INTFC_ID_H_REG";
        r_array["PORT_CONTROL"] = 64'h0000_0000_0000_0004;
        tb_env0.pr_gasket_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
       	wr_rd_cmp(m_regs,m_regs_a,w_array);
   endtask : body

 endclass :  port_gasket_csr_seq

`endif //  PORT_GASKET_CSR_SEQ_SVH


