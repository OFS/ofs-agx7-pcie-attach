// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef TB_PKG_SVH
`define TB_PKG_SVH

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import svt_uvm_pkg::*;
    import svt_axi_uvm_pkg::*;

    `define NUM_MASTERS 6
    `define NUM_SLAVES  6
    typedef enum {
        HIA_AXI4_ST_MST   = 0,
	HSSI_AXI4_ST_MST_0 = 1,
	HSSI_AXI4_ST_MST_1 = 2,
	HSSI_AXI4_ST_MST_2 = 3,
	PMCI_AXI4_LT_MST   = 4,
	HSSI_AXI4_LT_MST   = 5
    } mst_id_t;
    typedef enum {
        HIA_AXI4_ST_SLV   = 0,
	HSSI_AXI4_ST_SLV_0 = 1,
	HSSI_AXI4_ST_SLV_1 = 2,
	HSSI_AXI4_ST_SLV_2 = 3,
	PMCI_AXI4_LT_SLV   = 4,
	HIA_AXI4_LT_SLV   = 5
    } slv_id_t;

    `define NUM_PFS      5
    `define PF0_BAR0     'h8000_0000
    `define PF1_BAR0     'h9000_0000 //Page Size 4K
    `define PF1_VF0_BAR0 'hA000_0000 //Page Size 4K
    `define PF2_BAR0     'hB000_0000 //Page Size 4K
    `define PF2_VF0_BAR0 'hC000_0000 //Page Size 4K
    `define PF2_VF1_BAR0 'hC000_1000 //Page Size 4K
    `define PF3_BAR0     'hD000_0000
    `define PF4_BAR0     'hE000_0000
    `define HE_HSSI_BASE `PF2_VF1_BAR0
    `define HE_LB_BASE   `PF2_BAR0
    `define HE_MEM_BASE  `PF2_VF0_BAR0
`ifdef FIM_C
      `define PCIE_DUT      DUT.pcie_wrapper.pcie_ss_top.pcie_ss.pcie_ss.gen_ptile.u_ptile.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrpcie_top
      `define PCIE_QHIP  DUT.pcie_wrapper.pcie_ss_top.pcie_ss.pcie_ss.gen_ptile.u_ptile
    `else
      `define PCIE_DUT      DUT.pcie_wrapper.pcie_ss_top.host_pcie.pcie_ss.pcie_ss.gen_ptile.u_ptile.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrpcie_top
      `define PCIE_QHIP  DUT.pcie_wrapper.pcie_ss_top.host_pcie.pcie_ss.pcie_ss.gen_ptile.u_ptile
    `endif



    `include "svt_axi_if.svi"
    `include "svt_axi_port_defines.svi"

    `include "svt_axi_system_env.sv"
    `include "cust_axi_system_configuration.sv"

    `include "svt_pcie_defines.svi"
    `include "svt_pcie_device_configuration.sv"
    `include "svt_pcie_device_agent.sv"
    `include "svt_pcie.uvm.pkg"
    import svt_pcie_uvm_pkg::*;
    //`include "pciesvc_device_serdes_x16_model_8g.v"

    `include "tb_config.svh"
    `include "virtual_sequencer.svh"
    `include "ral_ofs.sv"
    `include "reg2vip_fme_adapter.svh"
    `include "../cov/ce_coverage_interface.sv"
    `include "../cov/ce_cov_class.sv"
    `include "ce_scoreboard.sv" 
    `include "seq_lib.svh"
    `include "tb_env.svh"
    `include "test_pkg.svh"

    //import test_pkg::*;

`endif // TB_PKG_SVH
