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
   localparam PMCI_DFH           = 64'h20000;
   localparam PMCI_FBM_CSR       = PMCI_DFH + 64'h40;
   localparam PMCI_FBM_AR        = PMCI_DFH + 64'h44;
   localparam PMCI_SEU_ERR       = PMCI_DFH + 64'h48;
   localparam PMCI_PXE_DBG_STS   = PMCI_DFH + 64'h50;
   localparam PMCI_VDM_BA        = PMCI_DFH + 64'h80;
   localparam PMCI_PCIE_SS_BA    = PMCI_DFH + 64'h88;
   localparam PMCI_HSSI_SS_BA    = PMCI_DFH + 64'h8C;
   localparam PMCI_QSFP_BA       = PMCI_DFH + 64'h90;
   localparam PMCI_QSFP2_BA      = PMCI_DFH + 64'h94;
   localparam PMCI_SPI_CSR       = PMCI_DFH + 64'h400;
   localparam PMCI_SPI_AR        = PMCI_DFH + 64'h404;
   localparam PMCI_SPI_RD_DR     = PMCI_DFH + 64'h408;
   localparam PMCI_SPI_WR_DR     = PMCI_DFH + 64'h40C;
   localparam PMCI_FBM_FIFO      = PMCI_DFH + 64'h800;
   localparam PMCI_VDM_FCR       = PMCI_DFH + 64'h2000;
   localparam PMCI_VDM_PDR       = PMCI_DFH + 64'h2008;
   localparam PMCI_PXE_OROM_CONT = PMCI_DFH + 64'h10000;
endpackage

`endif
