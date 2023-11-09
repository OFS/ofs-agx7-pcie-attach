// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef SEQ_LIB_SVH
`define SEQ_LIB_SVH

`include "axi_vip_seq.sv"
`include "pcie_hip_defines.svh"
`include "pcie_device_report_catcher.sv"
`include "vip_seq/enumerate_seq.sv"
`include "pcie_vip_seq.svh"
`include "pcie_device_sequence_library.sv"
`include "axi_slave_mem_response_sequence.sv"
`include "config_seq.svh"
`include "base_seq.svh"
`include "mmio_seq.svh"
`include "hps2ce_base_seq.svh"
`include "hps2ce_gpio_seq.svh"
`include "hps2ce_skv_seq.svh"
`include "ce_csr_seq.svh"
`include  "ce_basic_dma_seq.svh"
`include "ce_ssbl_krnl_vfy_seq.svh"
`include "ce_advance_dma_seq.svh"
`include "ce_bad_bresp_seq.svh"
`include "ce_error_seq.svh"
`include "ce_bkp_seq.svh"
`include "ce_drl_seq.svh"
`include "ce_128drl_seq.svh"
`include "ce_512drl_seq.svh"
`include "ce_1024drl_seq.svh"
`include "ce_b2b_wr_rd_seq.svh"
`include "ce_illegal_desc_seq.svh"



`endif // SEQ_LIB_SVH
