// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//

//
// Platform-specific OFS AC configuration of the PCIe subsystem.
//
// This is the platform-specific PCIe configuration package. It is imported
// by the platform-independent ofs_pcie_ss_cfg_pkg::.
//
// In general, code SHOULD NOT import this file. Instead, import
// ofs_pcie_ss_cfg_pkg::, which imports this file and enforces a common
// configuration across all platforms.
//

`include "ofs_pcie_ss_plat_cfg.vh"

package ofs_pcie_ss_plat_cfg_pkg;

    //
    // Descriptions of these fields can be found in the platform-independent
    // parent: ofs_pcie_ss_cfg_pkg.sv
    //

    localparam TDATA_WIDTH = ofs_fim_cfg_pkg::PCIE_TDATA_WIDTH;
    localparam TUSER_VENDOR_WIDTH = ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH;

    localparam MAX_RD_REQ_BYTES = ofs_fim_cfg_pkg::MAX_RD_REQ_SIZE * 4;
    localparam MAX_WR_PAYLOAD_BYTES = ofs_fim_cfg_pkg::MAX_PAYLOAD_SIZE * 4;

    localparam NUM_OF_SOP = 1;
    localparam NUM_OF_SEG = 1;

    localparam PCIE_EP_MAX_TAGS = 256;
    localparam PCIE_RP_MAX_TAGS = ofs_fim_cfg_pkg::PCIE_RP_MAX_TAGS;
    localparam PCIE_TILE_MAX_TAGS = 512;

    localparam NUM_OF_STREAMS = 1;

endpackage // ofs_pcie_ss_plat_cfg_pkg
