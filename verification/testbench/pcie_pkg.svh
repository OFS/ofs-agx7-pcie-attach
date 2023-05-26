// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef PCIE_PKG_SVH
`define PCIE_PKG_SVH

//  `include "svc_util_parms.v"
//  `include "svt_pcie.uvm.pkg"
   // import svt_uvm_pkg::*;
   package pcie_pkg;
    //  `include "svt_pcie.uvm.pkg"
       import svt_uvm_pkg::*;
       import svt_pcie_uvm_pkg::*;
       `include "svc_util_parms.v"
       `include "svt_pcie_defines.svi"
       `include "svt_pcie_device_configuration.sv"
       `include "svt_pcie_device_agent.sv"
      //`include "svt_pcie_common_defines.svi"
       //`include "pciesvc_device_serdes_x16_model_8g.v"
   endpackage

`endif

