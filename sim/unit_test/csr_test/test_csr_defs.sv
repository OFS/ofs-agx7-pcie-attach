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

import top_cfg_pkg::*;
package test_csr_defs;
   localparam FME_DFH            = 32'h0;
   localparam FME_SCRATCHPAD0    = FME_DFH + 32'h28;

   localparam PCIE_DFH           = 32'h10000;
   localparam PCIE_SCRATCHPAD    = PCIE_DFH + 32'h8;
   localparam PCIE_TESTPAD       = PCIE_DFH + 32'h38;

   localparam HE_LB_SCRATCHPAD   = 32'h100;
   localparam HE_LB_STUBSCRATCHPAD = 32'h18;

   localparam HSSI_DFH           = 32'h60000;
   localparam HSSI_RCFG_DATA     = HSSI_DFH + 32'h30;

   localparam VIRTIO_DFH         = 32'h20000;
   localparam VIRTIO_GUID_L      = VIRTIO_DFH + 32'h8;
   localparam VIRTIO_GUID_H      = VIRTIO_DFH + 32'h10;
   localparam VIRTIO_SCRATCHPAD  = VIRTIO_DFH + 32'h18;

   localparam HEM_TG_PF          = 0; 
   localparam HEM_TG_VF          = 2; 
   localparam HEM_TG_VA          = 1; 
   localparam HEH_PF             = 0; 
   localparam HEH_VF             = 1; 
   localparam HEH_VA             = 1; 
   localparam HEM_PF             = 0; 
   localparam HEM_VF             = 0; 
   localparam HEM_VA             = 1; 
   localparam HPS_PF             = 4; 
   localparam HPS_VF             = 0; 
   localparam HPS_VA             = 0; 
   localparam VIO_PF             = 3; 
   localparam VIO_VF             = 0; 
   localparam VIO_VA             = 0; 
   localparam HLB_PF             = 2; 
   localparam HLB_VF             = 0; 
   localparam HLB_VA             = 0; 
   localparam PF1_PF             = 1; 
   localparam PF1_VF             = 0; 
   localparam PF1_VA             = 0; 
   localparam ST2MM_PF           = 0; 
   localparam ST2MM_VF           = 0; 
   localparam ST2MM_VA           = 0; 

endpackage

`endif
