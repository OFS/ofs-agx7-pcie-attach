//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class hssi_ss_seq is executed by hssi_ss_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 *  Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef HSSI_SS_SEQ_SVH
`define HSSI_SS_SEQ_SVH

class hssi_ss_seq extends base_seq;
   `uvm_object_utils(hssi_ss_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)

    uvm_reg m_regs[$];
    string m_regs_a[string];
    uvm_reg_data_t wdata, rdata;
    uvm_status_e   status;
    bit [63:0] r_array[string] ;
    bit [63:0] w_array[string] ;


    function new(string name = "hssi_ss_seq");
        super.new(name);
    endfunction : new
 
    task body();
        super.body();
      `ifdef FTILE_SIM
        r_array["FEATURE_CSR_SIZE_GROUP_HI"] = 64'h31c;
        //r_array["HSSI_PORT_0_STATUS"] = 64'h8000080;
        //r_array["HSSI_PORT_1_STATUS"] = 64'h8000080;
        //r_array["HSSI_PORT_2_STATUS"] = 64'h8000080;
        //r_array["HSSI_PORT_3_STATUS"] = 64'h8000080;
        //r_array["HSSI_PORT_4_STATUS"] = 64'h8000080;
        //r_array["HSSI_PORT_5_STATUS"] = 64'h8000080;
        //r_array["HSSI_PORT_6_STATUS"] = 64'h8000080;
        //r_array["HSSI_PORT_7_STATUS"] = 64'h8000080;
        r_array["HSSI_DBG_CTRL"] = 64'h62000;
        m_regs_a["HSSI_PORT_0_STATUS"] = "HSSI_PORT_0_STATUS_REG";
        m_regs_a["HSSI_PORT_1_STATUS"] = "HSSI_PORT_1_STATUS_REG";
        m_regs_a["HSSI_PORT_2_STATUS"] = "HSSI_PORT_2_STATUS_REG";
        m_regs_a["HSSI_PORT_3_STATUS"] = "HSSI_PORT_3_STATUS_REG";
        m_regs_a["HSSI_PORT_4_STATUS"] = "HSSI_PORT_4_STATUS_REG";
        m_regs_a["HSSI_PORT_5_STATUS"] = "HSSI_PORT_5_STATUS_REG";
        m_regs_a["HSSI_PORT_6_STATUS"] = "HSSI_PORT_6_STATUS_REG";
        m_regs_a["HSSI_PORT_7_STATUS"] = "HSSI_PORT_7_STATUS_REG";
        m_regs_a["HSSI_INDV_RST_ACK"] = "HSSI_INDV_RST_ACK_REG";
        m_regs_a["HSSI_COLD_RST"] = "HSSI_COLD_RST_REG";
        m_regs_a["HSSI_STATUS"] = "HSSI_STATUS_REG";
      `endif
        tb_env0.hssi_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
	m_regs_a["HSSI_READ_DATA"] = "HSSI_READ_DATA_REG";
	wr_rd_cmp(m_regs,m_regs_a,w_array);

    endtask : body

    
endclass : hssi_ss_seq

`endif // HSSI_SS_SEQ_SVH

