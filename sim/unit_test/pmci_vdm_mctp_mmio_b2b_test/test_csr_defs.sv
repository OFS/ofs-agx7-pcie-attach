// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  CSR address 
//
//-----------------------------------------------------------------------------
`ifndef __TEST_CSR_DEFS__
`define __TEST_CSR_DEFS__

package test_csr_defs;
   localparam PMCI_DFH           = 32'h20000;
   localparam PMCI_FBM_CSR       = PMCI_DFH + 32'h40;
   localparam PMCI_FBM_AR        = PMCI_DFH + 32'h44;
   localparam PMCI_SEU_ERR       = PMCI_DFH + 32'h48;
   localparam PMCI_VDM_BA        = PMCI_DFH + 32'h80;
   localparam PMCI_PCIE_SS_BA    = PMCI_DFH + 32'h88;
   localparam PMCI_HSSI_SS_BA    = PMCI_DFH + 32'h8C;
   localparam PMCI_QSFP_BA       = PMCI_DFH + 32'h90;
   localparam PMCI_QSFP2_BA      = PMCI_DFH + 32'h94;
   localparam PMCI_SPI_CSR       = PMCI_DFH + 32'h400;
   localparam PMCI_SPI_AR        = PMCI_DFH + 32'h404;
   localparam PMCI_SPI_RD_DR     = PMCI_DFH + 32'h408;
   localparam PMCI_SPI_WR_DR     = PMCI_DFH + 32'h40C;
   localparam PMCI_FBM_FIFO      = PMCI_DFH + 32'h800;
   localparam PMCI_VDM_FCR       = PMCI_DFH + 32'h2000;
   localparam PMCI_VDM_PDR       = PMCI_DFH + 32'h2008;
   localparam ST2MM_DFH               = 32'h40000;
   localparam ST2MM_SCRATCHPAD         = ST2MM_DFH + 32'h8;
   localparam ST2MM_PCIE_VDM_FCR      = ST2MM_DFH + 32'h2000;
   localparam ST2MM_PCIE_VDM_TX_DR    = ST2MM_DFH + 32'h2008;
endpackage

`endif
