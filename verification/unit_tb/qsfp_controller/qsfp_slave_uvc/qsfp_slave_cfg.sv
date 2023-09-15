// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SLAVE_CFG
`define QSFP_SLAVE_CFG
//File : QSFP slave config file

class qsfp_slave_cfg extends uvm_object;
  `uvm_object_utils(qsfp_slave_cfg)
  
  //bit has_scoreboard=1;
  //bit has_sagent=1;
  
  //qsfp_slave_config qsfp_agent_cfg;
  
  
  function new(string name="qsfp_env_config");
  super.new(name);
  endfunction

endclass : qsfp_slave_cfg

`endif // QSFP_SLAVE_CFG
