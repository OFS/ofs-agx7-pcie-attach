// Copyright (C) 2021 Intel Corporation
// SPDX-License-Identifier: MIT

//--------------------------------------------------------------------------



`define QSFP_POLLER qsfp_tb_top.qsfp_dut_i.poller_fsm_inst
`define QSFP_COM qsfp_tb_top.qsfp_dut_i.qsfp_com_inst
`define QSFP_CSR qsfp_tb_top.qsfp_dut_i.csr_wr_logic_inst
`define QSFP_I2C qsfp_tb_top.qsfp_dut_i.qsfp_ctrl_inst.i2c_0.i2c_0



interface qsfp_coverage_intf ();
  
  logic clk;
  logic poll_en;
  logic fsm_paused;
  logic softresetqsfpc;
  logic [3:0] poller_state;
  logic [1:0]  csr_state;
  logic [7:0] curr_rd_page;

//I2C signals
  logic [15:0] scl_lcnt;
  logic [15:0] scl_hcnt;
  logic [15:0] sda_hold;
  logic speed_mode;



assign clk = `QSFP_COM.clk;

always@(posedge clk) begin


 poll_en =`QSFP_POLLER.poll_en;
 fsm_paused =`QSFP_POLLER.fsm_paused;
 softresetqsfpc = `QSFP_COM.config_softresetqsfpc;
 poller_state = `QSFP_POLLER.state[3:0];
 csr_state = `QSFP_CSR.state[1:0];
 curr_rd_page = `QSFP_POLLER.curr_rd_page[7:0];

 scl_lcnt = `QSFP_I2C.scl_lcnt[15:0];
 scl_hcnt = `QSFP_I2C.scl_hcnt[15:0];
 sda_hold = `QSFP_I2C.sda_hold[15:0];
 speed_mode = `QSFP_I2C.speed_mode;



end

endinterface




