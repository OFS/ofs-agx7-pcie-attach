// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef AXI_PKG_SVH
`define AXI_PKG_SVH

  // `include "`AXI_IF.svi"
   `include "svt.uvm.pkg" 

    package axi_pkg;
        import uvm_pkg::*;
        `include "uvm_macros.svh"
        `include "svc_util_parms.v"
        `include "svt_uvm_util.svi"
        import svt_uvm_pkg::*;
        import svt_axi_uvm_pkg::*;
    //////
    endpackage

`endif

