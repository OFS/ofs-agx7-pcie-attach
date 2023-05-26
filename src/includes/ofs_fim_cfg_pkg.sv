// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// This package defines the global parameters of FIM
//
//----------------------------------------------------------------------------

`ifndef __OFS_FIM_CFG_PKG_SV__
`define __OFS_FIM_CFG_PKG_SV__

package ofs_fim_cfg_pkg;


//*****************
// PCIe host parameters
//*****************
`ifdef SIM_USE_PCIE_GEN3X16_BFM
   localparam PCIE_LANES = 16; 
`else
   localparam PCIE_LANES = 16;
`endif

localparam NUM_PCIE_HOST      = 1;
localparam PCIE_HOST_WIDTH    = $clog2(NUM_PCIE_HOST);

localparam PCIE_TDATA_WIDTH  = 512;
localparam PCIE_TUSER_WIDTH  = 10;

localparam PCIE_RP_MAX_TAGS   = (1<<10);
localparam PCIE_RP_TAG_WIDTH  = $clog2(PCIE_RP_MAX_TAGS);

localparam MAX_PAYLOAD_SIZE   = 128; // DW
localparam MAX_RD_REQ_SIZE    = 128; // DW

//*****************
// MMIO parameters
//*****************
localparam PORTS              = 1;
localparam MMIO_TID_WIDTH     = PCIE_HOST_WIDTH + PCIE_RP_TAG_WIDTH; // Matches PCIe TLP tag width 
localparam MMIO_DATA_WIDTH    = 64;
localparam MMIO_ADDR_WIDTH    = 20; // PF0 bar 0 addr width 1MB, VF under this PF has same address width
localparam NONPF0_MMIO_ADDR_WIDTH      = 12; // non PF0 bar 0 addr width 4KB


//MSIX
`ifdef NUM_AFUS
localparam   NUM_AFUS    = 2;
`else
localparam   NUM_AFUS    = 1;
`endif
localparam LNUM_AFUS = NUM_AFUS>1?$clog2(NUM_AFUS):1'h1;
localparam NUM_AFU_INTERRUPTS = 7;
localparam L_NUM_AFU_INTERRUPTS = $clog2(NUM_AFU_INTERRUPTS);


endpackage

`endif // __OFS_FIM_CFG_PKG_SV__
