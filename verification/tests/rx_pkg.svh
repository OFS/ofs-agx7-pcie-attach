//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef RX_TEST_PKG_SVH
`define RX_TEST_PKG_SVH

//package test_pkg;
//    import uvm_pkg::*;
//    `include "uvm_macros.svh"
   `include "base_test.svh"
   `include "he_hssi_rx_lpbk_25G_10G_test.svh" //all 8 ports are exercised in this test so removing he_hssi_rx_lpbk_* port specific test as they are no longer applicable 
`endif // RX_TEST_PKG_SVH
