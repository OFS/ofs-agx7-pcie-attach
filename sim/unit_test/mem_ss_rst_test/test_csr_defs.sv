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
   // ******************************************************************************************
   // DFH logic
   // ******************************************************************************************
   typedef struct packed {
      logic [3:0]  feat_type;
      logic [7:0]  rsvd1;
      logic [3:0]  afu_minor_ver;
      logic [6:0]  rsvd0;
      logic        eol;
      logic [23:0] nxt_dfh_offset;
      logic [3:0]  afu_major_ver;
      logic [11:0] feat_id;
   } t_dfh;

   localparam DFH_START_OFFSET = 32'h0; 
   localparam EMIF_DFH_FEAT_ID = 12'h9; 

   // ******************************************************************************************
   // EMIF feature registers
   // ******************************************************************************************
   localparam EMIF_STATUS_OFFSET     = 32'h8;
   localparam EMIF_CAPABILITY_OFFSET = EMIF_STATUS_OFFSET + 32'h8;
   localparam EMIF_DFH_VAL           = 64'h3_00000_00B000_1009;

endpackage

`endif
