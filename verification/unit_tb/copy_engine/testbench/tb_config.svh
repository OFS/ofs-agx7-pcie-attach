// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef TB_CONFIG_SVH
`define TB_CONFIG_SVH

`include "pcie_shared_cfg.sv"

class tb_config extends uvm_object;
    `uvm_object_utils(tb_config)

    // address map 
    rand bit [63:0] bfm_mem_start;
    rand bit [63:0] bfm_mem_end;
    rand bit [63:0] dut_mem_start;
    rand bit [63:0] dut_mem_end;
    bit has_sb;
    pcie_shared_cfg pcie_cfg;

    constraint bfm_mem_c {
        bfm_mem_start   == 64'h0_0000_0000_0000;
        bfm_mem_end     == 64'h0_3fff_ffff_ffff; // 46-bit HPA
    };
    //Supported Memory Range in SKX-P
    //48-bit GPA - Sim with IOMMU
    //46-bit HPA - Sim without IOMMU
    //TODO: Change constraint once IOMMU support enabled
    constraint dut_mem_c {
        dut_mem_start   == 64'h0_0000_1000_0000;
        dut_mem_end     == 64'h0_3fff_ffff_ffff; 
    };

    function new(string name = "tb_config");
        super.new(name);
	pcie_cfg = pcie_shared_cfg::type_id::create("pcie_cfg");
    endfunction : new

endclass : tb_config

`endif // TB_CONFIG_SVH
