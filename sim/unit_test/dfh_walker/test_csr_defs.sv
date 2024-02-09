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

import fme_csr_pkg::*;
import pg_csr_pkg::*;

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

   typedef enum {
      FME_DFH_IDX,
      THERM_MNGM_DFH_IDX,
      GLBL_PERF_DFH_IDX,
      GLBL_ERROR_DFH_IDX,
      QSFP0_DFH_IDX,
      QSFP1_DFH_IDX,
      HSSI_DFH_IDX,
      EMIF_DFH_IDX,
      PMCI_DFH_IDX,
      ST2MM_DFH_IDX,
      VUART_DFH_IDX,
      PG_PR_DFH_IDX,
      PG_PORT_DFH_IDX,
      PG_USER_CLK_DFH_IDX,
      PG_REMOTE_STP_DFH_IDX,
      AFU_ERR_DFH_IDX,
      MAX_DFH_IDX
   } t_dfh_idx;


   typedef logic [8*100-1:0] dfh_name;

   localparam BAR = 3'h0; 
   localparam DFH_START_OFFSET = 32'h0; 
   
   function automatic dfh_name[MAX_DFH_IDX-1:0] get_dfh_names();
      dfh_name[MAX_DFH_IDX-1:0] dfh_names;

      dfh_names[FME_DFH_IDX]         = "FME_DFH";
      dfh_names[THERM_MNGM_DFH_IDX]  = "THERM_MNGM_DFH";
      dfh_names[GLBL_PERF_DFH_IDX]   = "GLBL_PERF_DFH";
      dfh_names[GLBL_ERROR_DFH_IDX]  = "GLBL_ERROR_DFH";
      dfh_names[QSFP0_DFH_IDX]       = "QSFP0_DFH";
      dfh_names[QSFP1_DFH_IDX]       = "QSFP1_DFH";
      dfh_names[PMCI_DFH_IDX]        = "PMCI_DFH";
      dfh_names[ST2MM_DFH_IDX]       = "ST2MM_DFH";
      dfh_names[HSSI_DFH_IDX]        = "HSSI_DFH";
      dfh_names[VUART_DFH_IDX]       = "VUART_DFH";
      dfh_names[EMIF_DFH_IDX]        = "EMIF_DFH";
      dfh_names[PG_PR_DFH_IDX]       = "PG_PR_DFH";
      dfh_names[PG_PORT_DFH_IDX]     = "PG_PORT_DFH";
      dfh_names[PG_USER_CLK_DFH_IDX] = "PG_USER_CLK_DFH";
      dfh_names[PG_REMOTE_STP_DFH_IDX] = "PG_REMOTE_STP_DFH";
      dfh_names[AFU_ERR_DFH_IDX] = "AFU_ERR_DFH";

      return dfh_names;
   endfunction

   function automatic [MAX_DFH_IDX-1:0][63:0] get_dfh_values();
      logic[MAX_DFH_IDX-1:0][63:0] dfh_values;

      dfh_values[FME_DFH_IDX]        = 64'h4_00000_xxxxxx_0000;
      dfh_values[FME_DFH_IDX][39:16] = fme_csr_pkg::FME_CSR_NEXT_DFH_OFFSET;

      dfh_values[THERM_MNGM_DFH_IDX] = 64'h3_00000_xxxxxx_0001;
      dfh_values[THERM_MNGM_DFH_IDX][39:16] = fme_csr_pkg::FME_CSR_THERM_MNGM_NEXT_DFH_OFFSET;

      dfh_values[GLBL_PERF_DFH_IDX]  = 64'h3_00000_xxxxxx_0000;
      dfh_values[GLBL_PERF_DFH_IDX][39:16] = fme_csr_pkg::FME_CSR_GLBL_PERF_NEXT_DFH_OFFSET;

      dfh_values[GLBL_ERROR_DFH_IDX] = 64'h3_00000_xxxxxx_1004;
      dfh_values[GLBL_ERROR_DFH_IDX][39:16] = fabric_width_pkg::fme_csr_glbl_error;

      dfh_values[QSFP0_DFH_IDX]      = 64'h3_00000_xxxxxx_0000;
      dfh_values[QSFP0_DFH_IDX][39:16] = fabric_width_pkg::bpf_qsfp0_slv_next_dfh_offset;

      dfh_values[QSFP1_DFH_IDX]      = 64'h3_00000_xxxxxx_0000;
      dfh_values[QSFP1_DFH_IDX][39:16] = fabric_width_pkg::bpf_qsfp1_slv_next_dfh_offset;

      dfh_values[HSSI_DFH_IDX]       = 64'h3_00000_xxxxxx_1000;
      dfh_values[HSSI_DFH_IDX][39:16] = fabric_width_pkg::bpf_hssi_slv_next_dfh_offset;

      dfh_values[EMIF_DFH_IDX]       = 64'h3_00000_xxxxxx_1000;
      dfh_values[EMIF_DFH_IDX][39:16] = fabric_width_pkg::bpf_emif_slv_next_dfh_offset;

      dfh_values[PMCI_DFH_IDX]       = 64'h3_00000_xxxxxx_1000;
      dfh_values[PMCI_DFH_IDX][39:16] = fabric_width_pkg::bpf_pmci_slv_next_dfh_offset;

      dfh_values[ST2MM_DFH_IDX]      = 64'h3_00000_xxxxxx_0014;
      dfh_values[ST2MM_DFH_IDX][39:16] = fabric_width_pkg::apf_st2mm_slv_next_dfh_offset;

      dfh_values[VUART_DFH_IDX]      = 64'h3_00000_xxxxxx_0024;
      dfh_values[VUART_DFH_IDX][39:16] = fabric_width_pkg::apf_uart_slv_next_dfh_offset;

      dfh_values[PG_PR_DFH_IDX]      = 64'h3_00000_xxxxxx_1005;
      dfh_values[PG_PR_DFH_IDX][39:16] = fabric_width_pkg::port_pg_pr_dfh;

      dfh_values[PG_PORT_DFH_IDX]     = 64'h4_00000_xxxxxx_2001;
      dfh_values[PG_PORT_DFH_IDX][39:16] = pg_csr_pkg::FME_CSR_FME_PR_NEXT_DFH_OFFSET;

      dfh_values[PG_USER_CLK_DFH_IDX] = 64'h3_00000_xxxxxx_1014;
      dfh_values[PG_USER_CLK_DFH_IDX][39:16] = pg_csr_pkg::PORT_CSR_NEXT_DFH_OFFSET;

      dfh_values[PG_REMOTE_STP_DFH_IDX] = 64'h3_00000_xxxxxx_2013;
      dfh_values[PG_REMOTE_STP_DFH_IDX][39:16] = fabric_width_pkg::port_csr_port_stp;

      dfh_values[AFU_ERR_DFH_IDX] = 64'h3_00001_000000_2010;

      return dfh_values;
   endfunction

endpackage

`endif
