## Copyright (C) 2023 Intel Corporation
## SPDX-License-Identifier: MIT

##
## Load the subset of interfaces and modules required for AFUs inside the port
## gasket. This is the minimal set of sources loaded when generating the
## out-of-tree PR build environment.
##

# Include files
set_global_assignment -name SEARCH_PATH $::env(BUILD_ROOT_REL)/src/includes/

set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/includes/ofs_fim_cfg_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/includes/ofs_pcie_ss_plat_cfg_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/src/includes/fabric_width_pkg.sv

# Common interface files
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/fpga_family/agilex/ofs_common_agilex_if_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/ofs_common_if_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/includes/pcie_afu_if_design_files.tcl

# FIM-provided PCIe stream transformations that may be useful in AFUs
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ofs-common/src/common/lib/pcie_shims/files_quartus.tcl

# Signal tap, available in the PR region
set_global_assignment -name SDC_FILE $::env(BUILD_ROOT_REL)/syn/shared_config/signaltap_clock_crossing.sdc

set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ipss/hssi/eth_afu_if_design_files.tcl
set_global_assignment -name SOURCE_TCL_SCRIPT_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/pcie_ss_design_files.tcl
