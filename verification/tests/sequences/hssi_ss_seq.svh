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
    uvm_reg m_regs_m[$];
    string m_regs_a[string],m_regs_b[string];
    uvm_reg_data_t wdata, rdata;
    uvm_status_e   status;
    bit [63:0] r_array[string],r_a_array[string] ;
    bit [63:0] w_array[string] ;


    function new(string name = "hssi_ss_seq");
        super.new(name);
    endfunction : new
 
    task body();
        super.body();
      `ifdef FTILE_SIM
      `ifdef ETH_200G
	 m_regs_m[0] = tb_env0.hssi_regs.get_reg_by_name("HSSI_FEATURE");
         r_a_array["HSSI_FEATURE"] = 32'h00044005;
	 m_regs_m[1] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_0_ATTR");
         r_a_array["HSSI_PORT_0_ATTR"] = 32'h0;
         m_regs_m[2] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_1_ATTR");
         r_a_array["HSSI_PORT_1_ATTR"] = 32'h0;
         m_regs_m[3] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_2_ATTR");
         r_a_array["HSSI_PORT_2_ATTR"] = 32'h0;
         m_regs_m[4] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_3_ATTR");
         r_a_array["HSSI_PORT_3_ATTR"] = 32'h0;
         m_regs_m[5] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_4_ATTR");
         r_a_array["HSSI_PORT_4_ATTR"] = 32'h0;
         m_regs_m[6] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_5_ATTR");
         r_a_array["HSSI_PORT_5_ATTR"] = 32'h0;
         m_regs_m[7] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_6_ATTR");
         r_a_array["HSSI_PORT_6_ATTR"] = 32'h0;
         m_regs_m[8] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_7_ATTR");
         r_a_array["HSSI_PORT_7_ATTR"] = 32'h0;
	 m_regs_m[9] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_8_ATTR");
         r_a_array["HSSI_PORT_8_ATTR"] = 32'h0024_101D;
         m_regs_m[10] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_9_ATTR");
         r_a_array["HSSI_PORT_9_ATTR"] = 32'h0;
         m_regs_m[11] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_10_ATTR");
         r_a_array["HSSI_PORT_10_ATTR"] = 32'h0;
         m_regs_m[12] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_11_ATTR");
         r_a_array["HSSI_PORT_11_ATTR"] = 32'h0;
         m_regs_m[13] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_12_ATTR");
         r_a_array["HSSI_PORT_12_ATTR"] = 32'h0024_101D;
         m_regs_m[14] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_13_ATTR");
         r_a_array["HSSI_PORT_13_ATTR"] = 32'h0;
         m_regs_m[15] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_14_ATTR");
         r_a_array["HSSI_PORT_14_ATTR"] = 32'h0;
         m_regs_m[16] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_15_ATTR");
         r_a_array["HSSI_PORT_15_ATTR"] = 32'h0;
	 check_reset_value(m_regs_m,m_regs_b,r_a_array);
      `elsif ETH_400G
	 m_regs_m[0] = tb_env0.hssi_regs.get_reg_by_name("HSSI_FEATURE");
         r_a_array["HSSI_FEATURE"] = 32'h00004003;
	 m_regs_m[1] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_0_ATTR");
         r_a_array["HSSI_PORT_0_ATTR"] = 32'h0;
         m_regs_m[2] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_1_ATTR");
         r_a_array["HSSI_PORT_1_ATTR"] = 32'h0;
         m_regs_m[3] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_2_ATTR");
         r_a_array["HSSI_PORT_2_ATTR"] = 32'h0;
         m_regs_m[4] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_3_ATTR");
         r_a_array["HSSI_PORT_3_ATTR"] = 32'h0;
         m_regs_m[5] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_4_ATTR");
         r_a_array["HSSI_PORT_4_ATTR"] = 32'h0;
         m_regs_m[6] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_5_ATTR");
         r_a_array["HSSI_PORT_5_ATTR"] = 32'h0;
         m_regs_m[7] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_6_ATTR");
         r_a_array["HSSI_PORT_6_ATTR"] = 32'h0;
         m_regs_m[8] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_7_ATTR");
         r_a_array["HSSI_PORT_7_ATTR"] = 32'h0;
	 m_regs_m[9] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_8_ATTR");
         r_a_array["HSSI_PORT_8_ATTR"] = 32'h0024_1420;
         m_regs_m[10] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_9_ATTR");
         r_a_array["HSSI_PORT_9_ATTR"] = 32'h0;
         m_regs_m[11] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_10_ATTR");
         r_a_array["HSSI_PORT_10_ATTR"] = 32'h0;
         m_regs_m[12] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_11_ATTR");
         r_a_array["HSSI_PORT_11_ATTR"] = 32'h0;
         m_regs_m[13] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_12_ATTR");
         r_a_array["HSSI_PORT_12_ATTR"] = 32'h0;
         m_regs_m[14] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_13_ATTR");
         r_a_array["HSSI_PORT_13_ATTR"] = 32'h0;
         m_regs_m[15] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_14_ATTR");
         r_a_array["HSSI_PORT_14_ATTR"] = 32'h0;
         m_regs_m[16] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_15_ATTR");
         r_a_array["HSSI_PORT_15_ATTR"] = 32'h0;
	 check_reset_value(m_regs_m,m_regs_b,r_a_array);
      `endif
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
      `ifdef ENABLE_8_TO_15_PORTS
	m_regs_a["HSSI_FEATURE"] = "HSSI_FEATURE_REG";
	m_regs_a["HSSI_PORT_0_ATTR"] = "HSSI_PORT_0_ATTR_REG";
	m_regs_a["HSSI_PORT_1_ATTR"] = "HSSI_PORT_1_ATTR_REG";
	m_regs_a["HSSI_PORT_2_ATTR"] = "HSSI_PORT_2_ATTR_REG";
	m_regs_a["HSSI_PORT_3_ATTR"] = "HSSI_PORT_3_ATTR_REG";
	m_regs_a["HSSI_PORT_4_ATTR"] = "HSSI_PORT_4_ATTR_REG";
	m_regs_a["HSSI_PORT_5_ATTR"] = "HSSI_PORT_5_ATTR_REG";
	m_regs_a["HSSI_PORT_6_ATTR"] = "HSSI_PORT_6_ATTR_REG";
	m_regs_a["HSSI_PORT_7_ATTR"] = "HSSI_PORT_7_ATTR_REG";
	m_regs_a["HSSI_PORT_8_ATTR"] = "HSSI_PORT_8_ATTR_REG";
	m_regs_a["HSSI_PORT_9_ATTR"] = "HSSI_PORT_9_ATTR_REG";
	m_regs_a["HSSI_PORT_10_ATTR"] = "HSSI_PORT_10_ATTR_REG";
	m_regs_a["HSSI_PORT_11_ATTR"] = "HSSI_PORT_11_ATTR_REG";
	m_regs_a["HSSI_PORT_12_ATTR"] = "HSSI_PORT_12_ATTR_REG";
	m_regs_a["HSSI_PORT_13_ATTR"] = "HSSI_PORT_13_ATTR_REG";
	m_regs_a["HSSI_PORT_14_ATTR"] = "HSSI_PORT_14_ATTR_REG";
	m_regs_a["HSSI_PORT_15_ATTR"] = "HSSI_PORT_15_ATTR_REG";
	m_regs_a["HSSI_PORT_8_STATUS"] = "HSSI_PORT_8_STATUS_REG";
	m_regs_a["HSSI_PORT_9_STATUS"] = "HSSI_PORT_9_STATUS_REG";
	m_regs_a["HSSI_PORT_10_STATUS"] = "HSSI_PORT_10_STATUS_REG";
	m_regs_a["HSSI_PORT_11_STATUS"] = "HSSI_PORT_11_STATUS_REG";
	m_regs_a["HSSI_PORT_12_STATUS"] = "HSSI_PORT_12_STATUS_REG";
	m_regs_a["HSSI_PORT_13_STATUS"] = "HSSI_PORT_13_STATUS_REG";
	m_regs_a["HSSI_PORT_14_STATUS"] = "HSSI_PORT_14_STATUS_REG";
	m_regs_a["HSSI_PORT_15_STATUS"] = "HSSI_PORT_15_STATUS_REG";
      `endif
      `endif
       `ifndef INCLUDE_CVL
        tb_env0.hssi_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
	m_regs_a["HSSI_READ_DATA"] = "HSSI_READ_DATA_REG";
	wr_rd_cmp(m_regs,m_regs_a,w_array);
       `else       
	m_regs_a["HSSI_FEATURE"] = "HSSI_FEATURE_REG";
	m_regs_a["HSSI_PORT_0_ATTR"] = "HSSI_PORT_0_ATTR_REG";
	m_regs_a["HSSI_PORT_1_ATTR"] = "HSSI_PORT_1_ATTR_REG";
	m_regs_a["HSSI_PORT_2_ATTR"] = "HSSI_PORT_2_ATTR_REG";
	m_regs_a["HSSI_PORT_3_ATTR"] = "HSSI_PORT_3_ATTR_REG";
	m_regs_a["HSSI_PORT_4_ATTR"] = "HSSI_PORT_4_ATTR_REG";
	m_regs_a["HSSI_PORT_5_ATTR"] = "HSSI_PORT_5_ATTR_REG";
	m_regs_a["HSSI_PORT_6_ATTR"] = "HSSI_PORT_6_ATTR_REG";
	m_regs_a["HSSI_PORT_7_ATTR"] = "HSSI_PORT_7_ATTR_REG";
	m_regs_a["HSSI_PORT_8_ATTR"] = "HSSI_PORT_8_ATTR_REG";
	m_regs_a["HSSI_PORT_9_ATTR"] = "HSSI_PORT_9_ATTR_REG";
	m_regs_a["HSSI_PORT_10_ATTR"] = "HSSI_PORT_10_ATTR_REG";
	m_regs_a["HSSI_PORT_11_ATTR"] = "HSSI_PORT_11_ATTR_REG";
	m_regs_a["HSSI_PORT_12_ATTR"] = "HSSI_PORT_12_ATTR_REG";
	m_regs_a["HSSI_PORT_13_ATTR"] = "HSSI_PORT_13_ATTR_REG";
	m_regs_a["HSSI_PORT_14_ATTR"] = "HSSI_PORT_14_ATTR_REG";
	m_regs_a["HSSI_PORT_15_ATTR"] = "HSSI_PORT_15_ATTR_REG";
	m_regs_a["HSSI_READ_DATA"] = "HSSI_READ_DATA_REG";
	m_regs_a["HSSI_PORT_0_STATUS"] = "HSSI_PORT_0_STATUS_REG";
	m_regs_a["HSSI_PORT_1_STATUS"] = "HSSI_PORT_1_STATUS_REG";
	m_regs_a["HSSI_PORT_2_STATUS"] = "HSSI_PORT_2_STATUS_REG";
	m_regs_a["HSSI_PORT_3_STATUS"] = "HSSI_PORT_3_STATUS_REG";
	m_regs_a["HSSI_PORT_4_STATUS"] = "HSSI_PORT_4_STATUS_REG";
	m_regs_a["HSSI_PORT_5_STATUS"] = "HSSI_PORT_5_STATUS_REG";
	m_regs_a["HSSI_PORT_6_STATUS"] = "HSSI_PORT_6_STATUS_REG";
	m_regs_a["HSSI_PORT_7_STATUS"] = "HSSI_PORT_7_STATUS_REG";
	m_regs_a["HSSI_PORT_8_STATUS"] = "HSSI_PORT_8_STATUS_REG";
	m_regs_a["HSSI_PORT_9_STATUS"] = "HSSI_PORT_9_STATUS_REG";
	m_regs_a["HSSI_PORT_10_STATUS"] = "HSSI_PORT_10_STATUS_REG";
	m_regs_a["HSSI_PORT_11_STATUS"] = "HSSI_PORT_11_STATUS_REG";
	m_regs_a["HSSI_PORT_12_STATUS"] = "HSSI_PORT_12_STATUS_REG";
	m_regs_a["HSSI_PORT_13_STATUS"] = "HSSI_PORT_13_STATUS_REG";
	m_regs_a["HSSI_PORT_14_STATUS"] = "HSSI_PORT_14_STATUS_REG";
	m_regs_a["HSSI_PORT_15_STATUS"] = "HSSI_PORT_15_STATUS_REG";

	tb_env0.hssi_regs.get_registers(m_regs);
	      check_reset_value(m_regs,m_regs_a,r_array);
	      wr_rd_cmp(m_regs,m_regs_a,w_array);

`ifdef n6000_10G     // m_regs_b is irrelevant if we have to check a default value
    m_regs_m[0] = tb_env0.hssi_regs.get_reg_by_name("HSSI_FEATURE");
    r_a_array["HSSI_FEATURE"] = 32'h00003FD1;
    m_regs_m[1] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_0_ATTR");
    r_a_array["HSSI_PORT_0_ATTR"] = 32'h040414;
    m_regs_m[2] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_1_ATTR");
    r_a_array["HSSI_PORT_1_ATTR"] = 32'h040414;
    m_regs_m[3] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_2_ATTR");
    r_a_array["HSSI_PORT_2_ATTR"] = 32'h040414;
    m_regs_m[4] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_3_ATTR");
    r_a_array["HSSI_PORT_3_ATTR"] = 32'h040414;
    m_regs_m[5] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_4_ATTR");
    r_a_array["HSSI_PORT_4_ATTR"] = 32'h040414;
    m_regs_m[6] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_5_ATTR");
    r_a_array["HSSI_PORT_5_ATTR"] = 32'h040414;
    m_regs_m[7] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_6_ATTR");
    r_a_array["HSSI_PORT_6_ATTR"] = 32'h040414;
    m_regs_m[8] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_7_ATTR");
    r_a_array["HSSI_PORT_7_ATTR"] = 32'h040414;
    m_regs_m[9] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_8_ATTR");
    r_a_array["HSSI_PORT_8_ATTR"] = 32'h00000000;
    m_regs_m[10] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_9_ATTR");
    r_a_array["HSSI_PORT_9_ATTR"] = 32'h00000000;
    m_regs_m[11] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_10_ATTR");
    r_a_array["HSSI_PORT_10_ATTR"] = 32'h00000000;
    m_regs_m[12] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_11_ATTR");
    r_a_array["HSSI_PORT_11_ATTR"] = 32'h00000000;
    m_regs_m[13] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_12_ATTR");
    r_a_array["HSSI_PORT_12_ATTR"] = 32'h00000000;
    m_regs_m[14] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_13_ATTR");
    r_a_array["HSSI_PORT_13_ATTR"] = 32'h00000000;
    m_regs_m[15] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_14_ATTR");
    r_a_array["HSSI_PORT_14_ATTR"] = 32'h00000000;
    m_regs_m[16] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_15_ATTR");
    r_a_array["HSSI_PORT_15_ATTR"] = 32'h00000000;

    m_regs_m[17] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_0_STATUS");
    r_a_array["HSSI_PORT_0_STATUS"] = 32'h00000000;
    m_regs_m[18] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_1_STATUS");
    r_a_array["HSSI_PORT_1_STATUS"] = 32'h00000000;
    m_regs_m[19] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_2_STATUS");
    r_a_array["HSSI_PORT_2_STATUS"] = 32'h00000000;
    m_regs_m[20] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_3_STATUS");
    r_a_array["HSSI_PORT_3_STATUS"] = 32'h00000000;
    m_regs_m[21] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_4_STATUS");
    r_a_array["HSSI_PORT_4_STATUS"] = 32'h00000000;
    m_regs_m[22] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_5_STATUS");
    r_a_array["HSSI_PORT_5_STATUS"] = 32'h00000000;
    m_regs_m[23] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_6_STATUS");
    r_a_array["HSSI_PORT_6_STATUS"] = 32'h00000000;
    m_regs_m[24] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_7_STATUS");
    r_a_array["HSSI_PORT_7_STATUS"] = 32'h00000000;
    m_regs_m[25] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_8_STATUS");
    r_a_array["HSSI_PORT_8_STATUS"] = 32'h00000000;
    m_regs_m[26] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_9_STATUS");
    r_a_array["HSSI_PORT_9_STATUS"] = 32'h00000000;
    m_regs_m[27] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_10_STATUS");
    r_a_array["HSSI_PORT_10_STATUS"] = 32'h00000000;
    m_regs_m[28] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_11_STATUS");
    r_a_array["HSSI_PORT_11_STATUS"] = 32'h00000000;
    m_regs_m[29] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_12_STATUS");
    r_a_array["HSSI_PORT_12_STATUS"] = 32'h00000000;
    m_regs_m[30] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_13_STATUS");
    r_a_array["HSSI_PORT_13_STATUS"] = 32'h00000000;
    m_regs_m[31] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_14_STATUS");
    r_a_array["HSSI_PORT_14_STATUS"] = 32'h00000000;
    m_regs_m[32] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_15_STATUS");
    r_a_array["HSSI_PORT_15_STATUS"] = 32'h00000000;
    check_reset_value(m_regs_m,m_regs_b,r_a_array);

  `elsif n6000_25G
    m_regs_m[0] = tb_env0.hssi_regs.get_reg_by_name("HSSI_FEATURE");
    r_a_array["HSSI_FEATURE"] = 32'h000F03D1;
    m_regs_m[1] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_0_ATTR");
    r_a_array["HSSI_PORT_0_ATTR"] = 32'h00A40415;
    m_regs_m[2] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_1_ATTR");
    r_a_array["HSSI_PORT_1_ATTR"] = 32'h00A40415;
    m_regs_m[3] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_2_ATTR");
    r_a_array["HSSI_PORT_2_ATTR"] = 32'h00A40415;
    m_regs_m[4] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_3_ATTR");
    r_a_array["HSSI_PORT_3_ATTR"] = 32'h00A40415;
    m_regs_m[5] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_4_ATTR");
    r_a_array["HSSI_PORT_4_ATTR"] = 32'h00000000;
    m_regs_m[6] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_5_ATTR");
    r_a_array["HSSI_PORT_5_ATTR"] = 32'h00000000;
    m_regs_m[7] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_6_ATTR");
    r_a_array["HSSI_PORT_6_ATTR"] = 32'h00000000;
    m_regs_m[8] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_7_ATTR");
    r_a_array["HSSI_PORT_7_ATTR"] = 32'h00000000;
    m_regs_m[9] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_8_ATTR");
    r_a_array["HSSI_PORT_8_ATTR"] = 32'h00000000;
    m_regs_m[10] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_9_ATTR");
    r_a_array["HSSI_PORT_9_ATTR"] = 32'h00000000;
    m_regs_m[11] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_10_ATTR");
    r_a_array["HSSI_PORT_10_ATTR"] = 32'h00A40415;
    m_regs_m[12] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_11_ATTR");
    r_a_array["HSSI_PORT_11_ATTR"] = 32'h00A40415;
    m_regs_m[13] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_12_ATTR");
    r_a_array["HSSI_PORT_12_ATTR"] = 32'h00A40415;
    m_regs_m[14] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_13_ATTR");
    r_a_array["HSSI_PORT_13_ATTR"] = 32'h00A40415;
    m_regs_m[15] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_14_ATTR");
    r_a_array["HSSI_PORT_14_ATTR"] = 32'h00000000;
    m_regs_m[16] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_15_ATTR");
    r_a_array["HSSI_PORT_15_ATTR"] = 32'h00000000;

    m_regs_m[17] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_0_STATUS");
    r_a_array["HSSI_PORT_0_STATUS"] = 32'h00000000;
    m_regs_m[18] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_1_STATUS");
    r_a_array["HSSI_PORT_1_STATUS"] = 32'h00000000;
    m_regs_m[19] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_2_STATUS");
    r_a_array["HSSI_PORT_2_STATUS"] = 32'h00000000;
    m_regs_m[20] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_3_STATUS");
    r_a_array["HSSI_PORT_3_STATUS"] = 32'h00000000;
    m_regs_m[21] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_4_STATUS");
    r_a_array["HSSI_PORT_4_STATUS"] = 32'h00000000;
    m_regs_m[22] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_5_STATUS");
    r_a_array["HSSI_PORT_5_STATUS"] = 32'h00000000;
    m_regs_m[23] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_6_STATUS");
    r_a_array["HSSI_PORT_6_STATUS"] = 32'h00000000;
    m_regs_m[24] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_7_STATUS");
    r_a_array["HSSI_PORT_7_STATUS"] = 32'h00000000;
    m_regs_m[25] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_8_STATUS");
    r_a_array["HSSI_PORT_8_STATUS"] = 32'h00000000;
    m_regs_m[26] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_9_STATUS");
    r_a_array["HSSI_PORT_9_STATUS"] = 32'h00000000;
    m_regs_m[27] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_10_STATUS");
    r_a_array["HSSI_PORT_10_STATUS"] = 32'h00000000;
    m_regs_m[28] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_11_STATUS");
    r_a_array["HSSI_PORT_11_STATUS"] = 32'h00000000;
    m_regs_m[29] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_12_STATUS");
    r_a_array["HSSI_PORT_12_STATUS"] = 32'h00000000;
    m_regs_m[30] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_13_STATUS");
    r_a_array["HSSI_PORT_13_STATUS"] = 32'h00000000;
    m_regs_m[31] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_14_STATUS");
    r_a_array["HSSI_PORT_14_STATUS"] = 32'h00000000;
    m_regs_m[32] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_15_STATUS");
    r_a_array["HSSI_PORT_15_STATUS"] = 32'h00000000;
	  check_reset_value(m_regs_m,m_regs_b,r_a_array);    

  `elsif n6000_100G
    m_regs_m[0] = tb_env0.hssi_regs.get_reg_by_name("HSSI_FEATURE");
    r_a_array["HSSI_FEATURE"] = 32'h00044449;
    m_regs_m[1] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_0_ATTR");
    r_a_array["HSSI_PORT_0_ATTR"] = 32'h0024101b;
    m_regs_m[2] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_4_ATTR");
    r_a_array["HSSI_PORT_4_ATTR"] = 32'h0024101b;
    m_regs_m[3] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_8_ATTR");
    r_a_array["HSSI_PORT_8_ATTR"] = 32'h0024101b;
    m_regs_m[4] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_12_ATTR");
    r_a_array["HSSI_PORT_12_ATTR"] = 32'h0024101b;

    m_regs_m[5] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_0_STATUS");
    r_a_array["HSSI_PORT_0_STATUS"] = 32'h8000080;
    m_regs_m[6] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_1_STATUS");
    r_a_array["HSSI_PORT_1_STATUS"] = 32'h00000000;
    m_regs_m[7] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_2_STATUS");
    r_a_array["HSSI_PORT_2_STATUS"] = 32'h00000000;
    m_regs_m[8] = tb_env0.hssi_regs.get_reg_by_name("HSSI_PORT_3_STATUS");
    r_a_array["HSSI_PORT_3_STATUS"] = 32'h00000000;
	  check_reset_value(m_regs_m,m_regs_b,r_a_array);    
    `endif
   `endif
    endtask : body

    
endclass : hssi_ss_seq

`endif // HSSI_SS_SEQ_SVH

