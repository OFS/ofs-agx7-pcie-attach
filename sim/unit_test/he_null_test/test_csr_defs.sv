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

   localparam HE_NULL_SCRATCHPAD = 32'h18;
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
