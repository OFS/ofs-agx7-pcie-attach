//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef TEST_LONG_PKG_SVH
`define TEST_LONG_PKG_SVH

//package test_long_pkg;
//    import uvm_pkg::*;
//    `include "uvm_macros.svh"

    `include "base_test.svh"

    `include "he_mem_lpbk_long_test.svh"
    `include "he_mem_lpbk_long_rst_test.svh"
    `include "afu_stress_test.svh"
    `include "afu_stress_5bit_tag_test.svh"
    `include "afu_stress_8bit_tag_test.svh"



//endpackage : test_long_pkg

`endif // TEST_LONG_PKG_SVH
