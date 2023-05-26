// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//
//
//-----------------------------------------------------------------------------

`ifndef __PFVF_SIM_PKG__
`define __PFVF_SIM_PKG__

import top_cfg_pkg::*;

package pfvf_sim_pkg;
// FIM Configuration Tool Begin
localparam HEM_TG_PF = 0; 
localparam HEM_TG_VF = 2; 
localparam HEM_TG_VA = 1; 
localparam HEH_PF    = 0; 
localparam HEH_VF    = 1; 
localparam HEH_VA    = 1; 
localparam HEM_PF    = 0; 
localparam HEM_VF    = 0; 
localparam HEM_VA    = 1; 
localparam HPS_PF    = 4; 
localparam HPS_VF    = 0; 
localparam HPS_VA    = 0; 
localparam VIO_PF    = 3; 
localparam VIO_VF    = 0; 
localparam VIO_VA    = 0; 
localparam HLB_PF    = 2; 
localparam HLB_VF    = 0; 
localparam HLB_VA    = 0; 
localparam PF1_PF    = 1; 
localparam PF1_VF    = 0; 
localparam PF1_VA    = 0; 
localparam ST2MM_PF  = 0; 
localparam ST2MM_VF  = 0; 
localparam ST2MM_VA  = 0; 
// FIM Configuration tool end

endpackage
`endif
