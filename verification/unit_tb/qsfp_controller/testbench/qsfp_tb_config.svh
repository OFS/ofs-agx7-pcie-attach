// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_TB_CONFIG_SVH
`define QSFP_TB_CONFIG_SVH


class qsfp_tb_config extends uvm_object;
    `uvm_object_utils(qsfp_tb_config)

    virtual qsfp_intf qsfp_if   ;
    virtual qsfp_slave_interface qsfp_slv_if;
    virtual `AXI_IF axi_if;
    bit     has_sb;
    function new(string name = "qsfp_tb_config");
        super.new(name);
    endfunction : new

endclass : qsfp_tb_config

`endif // QSFP_TB_CONFIG_SVH
