// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_TB_PKG_SVH
`define QSFP_TB_PKG_SVH

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import svt_uvm_pkg::*;
    import svt_axi_uvm_pkg::*;

    `define NUM_MASTERS 1
    `define NUM_SLAVES  1
    typedef enum {
	PMCI_AXI4_LT_MST   = 0
    } mst_id_t;
    typedef enum {
	PMCI_AXI4_LT_SLV   = 0
    } slv_id_t;


    `include "svt_axi_if.svi"
    `include "svt_axi_port_defines.svi"

    `include "svt_axi_system_env.sv"
    `include "../qsfp_slave_uvc/qsfp_slave_uvc_pkg.svh"

    `include "qsfp_intf.sv"
    `include "qsfp_coverage_interface.sv"
    `include "qsfp_tb_config.svh"
    `include "qsfp_virtual_sequencer.svh"
    `include "qsfp_scoreboard.sv"
    `include "qsfp_coverage.sv"
    `include "qsfp_tb_env.svh"
    `include "../qsfp_test_pkg.svh"


`endif // QSFP_TB_PKG_SVH
