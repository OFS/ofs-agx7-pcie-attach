// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  This file contains SystemVerilog interface definitions defining
//  EMIF/DDR4 related interfaces
//
//----------------------------------------------------------------------------

`ifndef __OFS_FIM_EMIF_IF_SV__
`define __OFS_FIM_EMIF_IF_SV__

//import ofs_fim_emif_cfg_pkg::*;
import mem_ss_pkg::*;

//Interface defining the signals between the EMIF IP and external memory.
interface ofs_ddr_no_ecc_if #(
    parameter ADDR_WIDTH = mem_ss_pkg::DDR4_A_WIDTH,
    parameter BA_WIDTH   = mem_ss_pkg::DDR4_BA_WIDTH,
    parameter BG_WIDTH   = mem_ss_pkg::DDR4_BG_WIDTH,
    parameter CK_WIDTH   = mem_ss_pkg::DDR4_CK_WIDTH,
    parameter CKE_WIDTH  = mem_ss_pkg::DDR4_CKE_WIDTH,
    parameter CS_WIDTH   = mem_ss_pkg::DDR4_CS_WIDTH,
    parameter ODT_WIDTH  = mem_ss_pkg::DDR4_ODT_WIDTH,
    parameter DQS_WIDTH  = mem_ss_pkg::DDR4_DQS_WIDTH, 
    parameter DQ_WIDTH   = mem_ss_pkg::DDR4_DQ_WIDTH
);
    logic [CK_WIDTH-1:0]   ck;
    logic [CK_WIDTH-1:0]   ck_n;
    logic [ADDR_WIDTH-1:0] a;
    logic                  act_n;
    logic [BA_WIDTH-1:0]   ba;
    logic [BG_WIDTH-1:0]   bg;
    logic [CKE_WIDTH-1:0]  cke;
    logic [CS_WIDTH-1:0]   cs_n;
    logic [ODT_WIDTH-1:0]  odt;
    logic                  reset_n;
    logic                  par;    
    logic                  alert_n;
    wire  [DQS_WIDTH-1:0]  dqs;
    wire  [DQS_WIDTH-1:0]  dqs_n;
    wire  [DQS_WIDTH-1:0]  dbi_n;
    wire  [DQ_WIDTH-1:0]   dq;
   
    logic                  oct_rzqin;
    logic                  ref_clk;
    
    modport emif (
        input  alert_n, oct_rzqin, ref_clk,
        output ck, ck_n, cke, reset_n, 
               a, act_n, ba, bg, cs_n, odt, par,
        inout  dqs, dqs_n, dq, dbi_n
    );
endinterface : ofs_ddr_no_ecc_if

interface ofs_ddr_ecc_if #(
    parameter ADDR_WIDTH = mem_ss_pkg::DDR4_A_WIDTH,
    parameter BA_WIDTH   = mem_ss_pkg::DDR4_BA_WIDTH,
    parameter BG_WIDTH   = mem_ss_pkg::DDR4_BG_WIDTH,
    parameter CK_WIDTH   = mem_ss_pkg::DDR4_CK_WIDTH,
    parameter CKE_WIDTH  = mem_ss_pkg::DDR4_CKE_WIDTH,
    parameter CS_WIDTH   = mem_ss_pkg::DDR4_CS_WIDTH,
    parameter ODT_WIDTH  = mem_ss_pkg::DDR4_ODT_WIDTH,
    parameter DQS_WIDTH  = mem_ss_pkg::DDR4_ECC_DQS_WIDTH, 
    parameter DQ_WIDTH   = mem_ss_pkg::DDR4_ECC_DQ_WIDTH
);
    logic [CK_WIDTH-1:0]   ck;
    logic [CK_WIDTH-1:0]   ck_n;
    logic [ADDR_WIDTH-1:0] a;
    logic                  act_n;
    logic [BA_WIDTH-1:0]   ba;
    logic [BG_WIDTH-1:0]   bg;
    logic [CKE_WIDTH-1:0]  cke;
    logic [CS_WIDTH-1:0]   cs_n;
    logic [ODT_WIDTH-1:0]  odt;
    logic                  reset_n;
    logic                  par;    
    logic                  alert_n;
    wire  [DQS_WIDTH-1:0]  dqs;
    wire  [DQS_WIDTH-1:0]  dqs_n;
    wire  [DQS_WIDTH-1:0]  dbi_n;
    wire  [DQ_WIDTH-1:0]   dq;
   
    logic                  oct_rzqin;
    logic                  ref_clk;
    
    modport emif (
        input  alert_n, oct_rzqin, ref_clk,
        output ck, ck_n, cke, reset_n, 
               a, act_n, ba, bg, cs_n, odt, par,
        inout  dqs, dqs_n, dq, dbi_n
    );
endinterface : ofs_ddr_ecc_if

`endif // __OFS_FIM_EMIF_IF_SV__
