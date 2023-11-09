// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// This package defines the global parameters of FIM
//
//----------------------------------------------------------------------------


`ifndef __FABRIC_WIDTH_PKG_SV__
`define __FABRIC_WIDTH_PKG_SV__

// IP configuration database, generated by OFS script gen_pkg.sh after
// IP generation.

package fabric_width_pkg;

localparam apf_bpf_mst_address_width = 20;

localparam apf_st2mm_mst_address_width = 20;

localparam apf_mctp_mst_address_width = 20;

localparam apf_uart_mst_address_width = 20;

localparam apf_bpf_slv_baseaddress = 'h00000;
localparam apf_bpf_slv_address_width = 18;

localparam apf_st2mm_slv_baseaddress = 'h40000;
localparam apf_st2mm_slv_address_width = 16;

localparam apf_uart_slv_baseaddress = 'h60000;
localparam apf_uart_slv_address_width = 12;

localparam apf_pr_slv_baseaddress = 'h70000;
localparam apf_pr_slv_address_width = 16;

localparam apf_achk_slv_baseaddress = 'h80000;
localparam apf_achk_slv_address_width = 16;

localparam bpf_apf_mst_address_width = 18;

localparam bpf_fme_mst_address_width = 20;

localparam bpf_pmci_mst_address_width = 21;

localparam bpf_pmci_lpbk_mst_address_width = 20;

localparam bpf_fme_slv_baseaddress = 'h00000;
localparam bpf_fme_slv_address_width = 16;

localparam bpf_apf_slv_baseaddress = 'h00000;
localparam bpf_apf_slv_address_width = 20;

localparam bpf_pcie_slv_baseaddress = 'h10000;
localparam bpf_pcie_slv_address_width = 12;

localparam bpf_qsfp0_slv_baseaddress = 'h12000;
localparam bpf_qsfp0_slv_address_width = 12;

localparam bpf_qsfp1_slv_baseaddress = 'h13000;
localparam bpf_qsfp1_slv_address_width = 12;

localparam bpf_hssi_slv_baseaddress = 'h14000;
localparam bpf_hssi_slv_address_width = 12;

localparam bpf_emif_slv_baseaddress = 'h15000;
localparam bpf_emif_slv_address_width = 12;

localparam bpf_pmci_slv_baseaddress = 'h20000;
localparam bpf_pmci_slv_address_width = 17;

localparam bpf_pmci_lpbk_slv_baseaddress = 'h100000;
localparam bpf_pmci_lpbk_slv_address_width = 20;


localparam apf_bpf_slv_next_dfh_offset = 'h0;
localparam apf_bpf_slv_eol = 'b0;

localparam bpf_apf_slv_next_dfh_offset = 'h0;
localparam bpf_apf_slv_eol = 'b0;

localparam bpf_fme_slv_next_dfh_offset = 'h12000;
localparam bpf_fme_slv_eol = 'b0;

localparam bpf_pcie_slv_next_dfh_offset = 'h2000;
localparam bpf_pcie_slv_eol = 'b0;

localparam bpf_qsfp0_slv_next_dfh_offset = 'h1000;
localparam bpf_qsfp0_slv_eol = 'b0;

localparam bpf_qsfp1_slv_next_dfh_offset = 'h1000;
localparam bpf_qsfp1_slv_eol = 'b0;

localparam bpf_hssi_slv_next_dfh_offset = 'h1000;
localparam bpf_hssi_slv_eol = 'b0;

localparam bpf_emif_slv_next_dfh_offset = 'hB000;
localparam bpf_emif_slv_eol = 'b0;

localparam bpf_pmci_slv_next_dfh_offset = 'h20000;
localparam bpf_pmci_slv_eol = 'b0;

localparam apf_st2mm_slv_next_dfh_offset = 'h20000;
localparam apf_st2mm_slv_eol = 'b0;

localparam apf_uart_slv_next_dfh_offset = 'h10000;
localparam apf_uart_slv_eol = 'b0;

localparam apf_pr_slv_next_dfh_offset = 'h10000;
localparam apf_pr_slv_eol = 'b0;

localparam apf_achk_slv_next_dfh_offset = 'h80000;
localparam apf_achk_slv_eol = 'b1;

// Hardcoded from ofs-common/src/common/fme/fme_csr.sv
// To modify, do so in ofs-common/tools/fabric_generation/gen_fabric_width_pkg.sh
localparam fme_csr_fme_dfh_index = 'h001000;
localparam fme_csr_therm_mngm_dfh = 'h002000;
localparam fme_csr_glbl_perf = 'h001000;
localparam fme_csr_glbl_error = 'h00e000;

// Hardcoded from ofs-common/src/common/port_gasket/pg_csr.sv
// To modify, do so in ofs-common/tools/fabric_generation/gen_fabric_width_pkg.sh
localparam port_pg_pr_dfh = 'h001000;
localparam fme_csr_fme_pr = 'h001000;
localparam port_csr_port = 'h001000;
localparam port_csr_port_stp = 'h00d000;

endpackage

`endif // __FABRIC_WIDTH_PKG_SV__