// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef TEST_PKG_SVH
`define TEST_PKG_SVH

//package test_pkg;

    `include "base_test.svh"
    `include "ce_csr_test.svh"
    `include "ce_advance_dma_test.svh"
    `include "ce_bad_bresp_test.svh"
    `include "ce_error_test.svh"
    `include "ce_basic_dma_test.svh"
    `include "ce_ssbl_krnl_vfy_test.svh"
    `include "ce_128drl_test.svh"
    `include "ce_512drl_test.svh"
    `include "ce_1024drl_test.svh"
    `include "ce_bkp_test.svh"
    `include "ce_b2b_wr_rd_test.svh"
    `include "ce_illegal_desc_test.svh"


//endpackage : test_pkg

`endif // TEST_PKG_SVH
