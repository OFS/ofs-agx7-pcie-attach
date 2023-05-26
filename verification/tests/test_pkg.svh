//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
`ifndef TEST_PKG_SVH
`define TEST_PKG_SVH

//package test_pkg;
//    import uvm_pkg::*;
//    `include "uvm_macros.svh"

    `include "base_test.svh"
    `include "mmio_test.svh"
    `include "fme_csr_test.svh"
    `include "he_mem_csr_test.svh"
    `include "he_lpbk_csr_test.svh"
    `include "dfh_walking_test.svh"
    `include "he_lpbk_test.svh"
    `include "he_mem_lpbk_test.svh"
    `include "qsfp_csr_test.svh"
    `include "hssi_ss_test.svh"
    `include "pmci_qsfp_csr_test.svh"
    `include "pmci_fme_csr_test.svh"
    `include "he_mem_rd_test.svh"
    `include "he_mem_wr_test.svh"
    `include "he_mem_flr_rst_test.svh"
    `include "he_mem_lpbk_reqlen1_test.svh"
    `include "he_mem_lpbk_reqlen2_test.svh"
    `include "he_mem_lpbk_reqlen4_test.svh"
    `include "he_mem_lpbk_reqlen8_test.svh"
    `include "he_mem_lpbk_reqlen16_test.svh"
    `include "he_mem_thruput_test.svh"
    `include "he_mem_cont_test.svh"
    `include "he_mem_rd_cont_test.svh"
    `include "he_mem_wr_cont_test.svh"
    `include "he_mem_thruput_contmode_test.svh"
    `include "mini_smoke_test.svh"
    `include "he_lpbk_reqlen1_test.svh"
    `include "he_lpbk_reqlen2_test.svh"
    `include "he_lpbk_reqlen4_test.svh"
    `include "he_lpbk_reqlen8_test.svh"
    `include "he_lpbk_reqlen16_test.svh"
    `include "helb_rd_1cl_test.svh"
    `include "helb_rd_2cl_test.svh"
    `include "helb_rd_4cl_test.svh"
    `include "helb_wr_1cl_test.svh"
    `include "helb_wr_2cl_test.svh"
    `include "helb_wr_4cl_test.svh"
    `include "helb_thruput_1cl_test.svh"
    `include "helb_thruput_2cl_test.svh"
    `include "helb_thruput_4cl_test.svh"
    `include "he_random_test.svh"
    `include "pmci_pciess_csr_test.svh"
    
    `include "helb_thruput_4cl_5bit_tag_test.svh"
    `include "helb_thruput_4cl_8bit_tag_test.svh"

   
    `include "pmci_csr_test.svh"
    `include "afu_mmio_flr_pf0_test.svh"
    `include "afu_mmio_flr_pf2_test.svh"
    `include "afu_mmio_flr_pf3_test.svh"
    `include "afu_mmio_flr_pf4_test.svh"
    `include "afu_mmio_flr_pf0_vf0_test.svh"
    `include "afu_mmio_flr_pf0_vf1_test.svh"
    `include "afu_mmio_flr_pf0_vf2_test.svh"
    `include "he_lpbk_long_test.svh"
    `include "he_lpbk_rd_test.svh"
    `include "he_lpbk_wr_test.svh"
    `include "he_lpbk_thruput_test.svh"
    `include "he_lpbk_cont_test.svh"
    `include "he_lpbk_rd_cont_test.svh"
    `include "he_lpbk_wr_cont_test.svh"
    `include "he_lpbk_thruput_contmode_test.svh"
    `include "he_lpbk_long_rst_test.svh"
    `include "he_lpbk_flr_rst_test.svh"
    `include "mmio_stress_test.svh"
    `include "mmio_stress_nonblocking_test.svh"
    `include "mmio_unimp_test.svh"
    `include "mmio_pcie_mrrs_128B_mps_128B_test.svh"
    `include "mmio_pcie_mrrs_128B_mps_256B_test.svh"
    `include "mmio_pcie_mrrs_256B_mps_128B_test.svh"
    `include "mmio_pcie_mrrs_256B_mps_256B_test.svh"
    `include "port_gasket_csr_test.svh"
    `include "mem_tg_csr_test.svh"
    `include "emif_csr_test.svh"


  `ifdef INCLUDE_UART
    `include "uart_intr_test.svh"
  `endif

    `include "fme_intr_test.svh"
    `include "fme_err_intr_test.svh"
    `include "fme_multi_err_intr_test.svh"
    `include "fme_ras_no_fat_err_test.svh"  
    `include "fme_ras_cat_fat_err_test.svh" 
    `include "he_mem_user_intr_test.svh"
    `include "he_mem_multi_user_intr_test.svh"
    `include "he_lpbk_user_intr_test.svh"
    `include "he_lpbk_multi_user_intr_test.svh"
    `include "mix_intr_test.svh"


    `include "pcie_pmci_mctp_vdm_test.svh"
    `include "pcie_pmci_mctp_multi_vdm_test.svh"
    `include "pmci_pcie_mctp_vdm_test.svh"
    `include "pmci_pcie_mctp_multi_vdm_test.svh"
    `include "vdm_err_vid_test.svh"
    `include "bar_32b_test.svh"
    `include "bar_64b_test.svh"
    `include "protocol_checker_csr_test.svh"
    `include "pcie_csr_test.svh"

    `include "malformedtlp_test.svh"
    `include "malformedtlp_pcie_rst_test.svh"
    `include "MaxTagError_test.svh"
    `include "TxMWrDataPayloadOverrun_test.svh"
    `include "TxMWrInsufficientData_test.svh" 
    `include "UnexpMMIORspErr_test.svh"
    `include "MMIODataPayloadOverrun_test.svh"
    `include "MMIOInsufficientData_test.svh"
    `include "MMIOTimedout_test.svh"
    `include "he_mem_thruput_contmode_directed_test.svh"
    `include "mem_tg_traffic_gen_test.svh" 

    `ifdef FIM_B
       `include "fim_b_test_pkg.svh"
    `endif

//endpackage : test_pkg

`endif // TEST_PKG_SVH
