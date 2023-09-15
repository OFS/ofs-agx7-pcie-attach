// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_TEST_PKG_SVH
`define QSFP_TEST_PKG_SVH

//    `include "uvm_macros.svh"
    `include "sequences/qsfp_seq_lib.svh"
    `include "qsfp_base_test.svh"
    `include "qsfp_init_test.svh"
    `include "qsfp_pio_output_toggle_parallel_test.svh"
    `include "qsfp_pio_input_toggle_parallel_test.svh"
    `include "qsfp_pio_output_toggle_sanity_test.svh"
    `include "qsfp_pio_input_toggle_sanity_test.svh"
    `include "qsfp_i2c_read_write_b2b_test.svh"
    `include "qsfp_poller_reset_test.svh"
    `include "qsfp_por_register_test.svh"
    `include "qsfp_read_write_register_test.svh"
    `include "qsfp_i2c_read_write_sanity_lower_upper_page_test.svh"
    `include "qsfp_softreset_test.svh"
    `include "qsfp_i2c_poller_disable_test.svh"
    `include "qsfp_write_reset_test.svh"
    `include "qsfp_backpress_dut_test.svh"
    `include "qsfp_i2c_read_write_sanity_page0203_test.svh"
    `include "qsfp_i2c_read_write_sanity_page2021_test.svh"
    `include "qsfp_nack_det_test.svh"
    `include "qsfp_dis_wait_test.svh"
    `include "qsfp_i2c_write_rand_read_test.svh"

`endif // QSFP_TEST_PKG_SVH
