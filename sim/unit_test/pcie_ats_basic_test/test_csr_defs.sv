// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  CSR address 
//
//-----------------------------------------------------------------------------

package test_csr_defs;
   localparam FME_DFH            = 32'h0;
   localparam FME_SCRATCHPAD0    = FME_DFH + 32'h28;

   localparam PCIE_DFH           = 32'h10000;
   localparam PCIE_SCRATCHPAD    = PCIE_DFH + 32'h8;
   localparam PCIE_TESTPAD       = PCIE_DFH + 32'h28;
endpackage
