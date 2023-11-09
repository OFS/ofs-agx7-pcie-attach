// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

localparam DEBUG_REG_EN             = 0;
localparam DEBUG_REG_WIDTH          = 8;

localparam MCTP_BASELINE_MTU        = 16;

localparam INGR_MSTR_ADDR_WIDTH     = 12;
localparam INGR_MSTR_BRST_WIDTH     = 9;
localparam EGRS_SLV_ADDR_WIDTH      = 9;
localparam SS_ADDR_WIDTH            = 20;

localparam INGR_DIR_BASE_ADDR       = 32'h0001_0000;
localparam INGR_SCLK_CLK_DIV        = 4;
localparam INGR_SLV_CSR_AWIDTH      = 16;

localparam EGRS_DIR_BASE_ADDR       = 32'h0001_0000;
localparam EGRS_SCLK_CLK_DIV        = 0;
localparam EGRS_SLV_CSR_AWIDTH      = 16;

localparam NIOS_ADDR_WIDTH          = 10;
localparam INGR_SLV_ADDR_WIDTH      = 10;
localparam EGRS_MSTR_ADDR_WIDTH     = 11;
localparam EGRS_MSTR_BRST_WIDTH     = 9;

`define PMCI_INGR pmci_pcie_vdm.mctp_pcievdm_ingr_inst

reg                              m10_clk = 1'b0;
reg                              m10_reset = 1'b1;
reg                              pmci_clk = 1'b0;
reg                              pmci_reset = 1'b1;
reg                              pulse_1ms = 1'b0;

reg   [SS_ADDR_WIDTH-1:0]        pcievdm_afu_addr = 'd0;
reg   [SS_ADDR_WIDTH-1:0]        pcievdm_afu_addr_r1 = 'd0;
reg                              pcievdm_afu_addr_vld = 1'b0;
//bit   [7:0]                      pcievdm_mctp_mtu;
reg   [7:0]                      pcievdm_mctp_eid = 'd0;
reg   [63:0]                     pcie_vdm_sts1_dbg;
reg   [63:0]                     pcie_vdm_sts2_dbg;
reg   [63:0]                     pcie_vdm_sts3_dbg;
reg   [63:0]                     pcie_vdm_sts4_dbg;
reg   [63:0]                     pcie_vdm_sts5_dbg;
reg   [31:0]                     m_pcie_vdm_sts1_dbg;
reg   [31:0]                     m_pcie_vdm_sts2_dbg;

reg   [0:0]                      avmm_ingr_slv_addr   = 'd0;   //Tb side
reg                              avmm_ingr_slv_write  = 'd0;
reg                              avmm_ingr_slv_read   = 'd0;
reg   [63:0]                     avmm_ingr_slv_wrdata = 'd0;
reg   [7:0]                      avmm_ingr_slv_byteen = 'd0;
bit   [63:0]                     avmm_ingr_slv_rddata; 
bit                              avmm_ingr_slv_rddvld;
bit                              avmm_ingr_slv_waitreq;

bit   [INGR_MSTR_ADDR_WIDTH-1:0] avmm_ingr_mstr_addr;
bit                              avmm_ingr_mstr_write;
bit                              avmm_ingr_mstr_read;
bit   [INGR_MSTR_BRST_WIDTH-1:0] avmm_ingr_mstr_burstcnt;
bit   [31:0]                     avmm_ingr_mstr_wrdata;
bit   [31:0]                     avmm_ingr_mstr_rddata;
bit                              avmm_ingr_mstr_rddvld;
bit                              avmm_ingr_mstr_waitreq;

bit   [EGRS_SLV_ADDR_WIDTH-1:0]  avmm_egrs_slv_addr;
bit                              avmm_egrs_slv_write;
bit                              avmm_egrs_slv_read;
bit   [31:0]                     avmm_egrs_slv_wrdata;
bit   [31:0]                     avmm_egrs_slv_rddata;
bit                              avmm_egrs_slv_rddvld;
bit                              avmm_egrs_slv_waitreq;

bit   [SS_ADDR_WIDTH-1:0]        avmm_egrs_mstr_addr;   //Tb side
bit                              avmm_egrs_mstr_write;
bit                              avmm_egrs_mstr_read;
bit   [63:0]                     avmm_egrs_mstr_wrdata;
bit   [7:0]                      avmm_egrs_mstr_byteen;
reg   [63:0]                     avmm_egrs_mstr_rddata = 'd0;
reg                              avmm_egrs_mstr_rddvld = 'd0;
reg                              avmm_egrs_mstr_waitreq= 'd0;

bit   [1:0]                      ingr_avmm_csr_addr;
bit                              ingr_avmm_csr_write;
bit                              ingr_avmm_csr_read;
bit   [7:0]                      ingr_avmm_csr_byteen;
bit   [63:0]                     ingr_avmm_csr_wrdata;
bit   [63:0]                     ingr_avmm_csr_rddata;
bit                              ingr_avmm_csr_rddvld;
bit                              ingr_avmm_csr_waitreq;

bit                              ingr_spi_clk ;
bit                              ingr_spi_csn ;
tri0                             ingr_spi_miso;
bit                              ingr_spi_mosi;

bit   [31:0]                     ingr_spis_avmm_addr;
bit   [3:0]                      ingr_spis_avmm_byteen;
bit                              ingr_spis_avmm_read;
bit   [31:0]                     ingr_spis_avmm_rddata; 
bit                              ingr_spis_avmm_rdvld;
bit                              ingr_spis_avmm_waitreq;
bit                              ingr_spis_avmm_write;
bit   [31:0]                     ingr_spis_avmm_wrdata;     

bit   [2:0]                      egrs_avmm_csr_addr;
bit                              egrs_avmm_csr_write;
bit                              egrs_avmm_csr_read;
bit   [3:0]                      egrs_avmm_csr_byteen;
bit   [31:0]                     egrs_avmm_csr_wrdata;
bit   [31:0]                     egrs_avmm_csr_rddata;
bit                              egrs_avmm_csr_rddvld;
bit                              egrs_avmm_csr_waitreq;

bit                              egrs_spi_clk ;
bit                              egrs_spi_csn ;
tri0                             egrs_spi_miso;
bit                              egrs_spi_mosi;

bit   [31:0]                     egrs_spis_avmm_addr;
bit   [3:0]                      egrs_spis_avmm_byteen;
bit                              egrs_spis_avmm_read;
bit   [31:0]                     egrs_spis_avmm_rddata; 
bit                              egrs_spis_avmm_rdvld;
bit                              egrs_spis_avmm_waitreq;
bit                              egrs_spis_avmm_write;
bit   [31:0]                     egrs_spis_avmm_wrdata;     

bit                              pci_vdm_msg_rx_intr;
bit                              pci_vdm_bdf_intr;
bit                              pci_vdm_intr;

reg   [NIOS_ADDR_WIDTH-1:0]      avmm_nios_addr   = 'd0;   //Tb side
reg                              avmm_nios_write  = 'd0;
reg                              avmm_nios_read   = 'd0;
//bit   [NIOS_BRST_WIDTH-1:0]      avmm_nios_burstcnt;
reg   [31:0]                     avmm_nios_wrdata = 'd0;
bit   [31:0]                     avmm_nios_rddata;
bit                              avmm_nios_rddvld;
bit                              avmm_nios_waitreq;

bit   [INGR_SLV_ADDR_WIDTH-1:0]  m_avmm_ingr_slv_addr;
bit                              m_avmm_ingr_slv_write;
bit                              m_avmm_ingr_slv_read;
bit   [31:0]                     m_avmm_ingr_slv_wrdata;
reg   [31:0]                     m_avmm_ingr_slv_rddata;
reg                              m_avmm_ingr_slv_rddvld;
reg                              m_avmm_ingr_slv_waitreq;

bit   [EGRS_MSTR_ADDR_WIDTH-1:0] m_avmm_egrs_mstr_addr;
bit                              m_avmm_egrs_mstr_write;
bit                              m_avmm_egrs_mstr_read;
bit   [EGRS_MSTR_BRST_WIDTH-1:0] m_avmm_egrs_mstr_burstcnt;
bit   [31:0]                     m_avmm_egrs_mstr_wrdata;
bit   [31:0]                     m_avmm_egrs_mstr_rddata;
bit                              m_avmm_egrs_mstr_rddvld;
bit                              m_avmm_egrs_mstr_waitreq;


//----------TB specific--------------------
int          log_fptr, rslt_fptr;
int          tc_error=0, tc_pass=0, ingr_pkt_num=0, egrs_pkt_num=0;
