// ***************************************************************************
//                               INTEL CONFIDENTIAL
//
// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//
// Platform-specific OFS AC configuration of the PCIe subsystem.
//
// This file exists mainly to associate a version tag with the values in
// ofs_pcie_ss_plat_cfg_pkg::. The version tag makes it easier to manage
// varation among platforms when importing the platform-specific configuration
// into the platform-independent ofs_pcie_ss_cfg_pkg::.
//

`ifndef __OFS_PCIE_SS_PLAT_CFG_VH__
`define __OFS_PCIE_SS_PLAT_CFG_VH__ 1

`define OFS_PCIE_SS_PLAT_CFG_AC 1
`define OFS_PCIE_SS_PLAT_CFG_V1 1

// Is completion reordering enabled in the PCIe SS? Set to either 0 (disabled)
// or 1 (enabled).
`define OFS_PCIE_SS_PLAT_CFG_FLAG_CPL_REORDER 1


// PKG_SORT_IGNORE_START --
//  This marker causes the PIM's sort_sv_packages.py to ignore everything
//  from here to the ignore end marker below. The package sorter uses a
//  very simple parser to detect what looks like a SystemVerilog package
//  reference in order to emit packages in dependence order. The code
//  or include files below contain macros that refer to packages but
//  do not represent true package to package dependence.

`define OFS_PCIE_SS_PLAT_CFG_FLAG_CPL_CHAN ofs_pcie_ss_cfg_pkg::PCIE_CHAN_B
`define OFS_PCIE_SS_PLAT_CFG_FLAG_WR_COMMIT_CHAN ofs_pcie_ss_cfg_pkg::PCIE_CHAN_A

// PKG_SORT_IGNORE_END

`endif // __OFS_PCIE_SS_PLAT_CFG_VH__
