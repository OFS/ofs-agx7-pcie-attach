// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_SEQ_LIB_SVH
`define QSFP_SEQ_LIB_SVH

`include "axi_vip_seq.sv"
`include "qsfp_base_seq.svh"
`include "qsfp_init_seq.svh"
`include "qsfp_pio_output_toggle_parallel_seq.svh"
`include "qsfp_pio_input_toggle_parallel_seq.svh"
`include "qsfp_pio_output_toggle_sanity_seq.svh"
`include "qsfp_pio_input_toggle_sanity_seq.svh"
`include "qsfp_poller_rst_seq.svh"
`include "qsfp_softrst_seq.svh"
`include "qsfp_poller_enable_disable_seq.svh"
`include "qsfp_i2c_read_write_b2b_seq.svh"
`include "qsfp_por_register_seq.svh"
`include "qsfp_read_write_register_seq.svh"
`include "qsfp_softrst_seq.svh"
`include "qsfp_i2c_poller_disable_seq.svh"
`include "qsfp_write_reset_seq.svh"
`include "qsfp_axi_write_sequence.svh"
`include "qsfp_bkp_dut_seq.svh"
`include "qsfp_nack_det_seq.svh"
`include "qsfp_i2c_read_write_sanity_lower_upper_page_seq.svh"
`include "qsfp_i2c_read_write_sanity_page0203_seq.svh"
`include "qsfp_i2c_read_write_sanity_page2021_seq.svh"
`include "qsfp_i2c_write_rand_read_seq.svh"

`endif // QSFP_SEQ_LIB_SVH
