// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SLAVE_UVC_PKG_SVH
`define QSFP_SLAVE_UVC_PKG_SVH

typedef enum {
	QSFP_SLV_WRITE    = 0,
	QSFP_SLV_READ     = 1,
	QSFP_SLV_RD_HDR   = 2
 } qsfp_slv_pkt_t;

    `include "qsfp_slave_interface.sv"
    `include "qsfp_slave_seq_item.sv"
    `include "qsfp_slave_cfg.sv"
    `include "qsfp_registry_component.sv"
    `include "qsfp_slave_driver.sv"
    `include "qsfp_slave_sequencer.sv"
    `include "qsfp_slave_monitor.sv"
    `include "qsfp_slave_agent.sv"
    `include "qsfp_slave_env.sv"
    `include "qsfp_slave_auto_response_sequence.sv"

`endif // QSFP_SLAVE_UVC_PKG_SVH
