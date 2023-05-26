# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

set_global_assignment -name SEARCH_PATH "$::env(BUILD_ROOT_REL)/ipss"

#--------------------
# Packages
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_pcie_hdr_def.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_pcie_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_axis_if.sv

#--------------------
# PCIE IP
#--------------------
set_global_assignment -name IP_FILE ../ip_lib/ipss/pcie/qip/pcie_ss.ip

#--------------------
# PCIE bridge
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/axis_reg_pcie_txs.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/tx_aligner.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_bridge_cdc.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_rx_bridge_cdc.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_bridge_cdc.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_checker.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_rx_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_rx_bridge_ptile.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_bridge_ptile.sv

#----------
# PCIE CSR
#----------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_csr.sv

#----------
# PCIE SS IF
#----------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_err_checker.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_ss_csr_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_ss_if.sv

#----------
# PCIE top
#----------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_tx_arbiter.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_flr_resync.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_ss_top.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/pcie_wrapper.sv

#----------
# PCIE Adapter
#----------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/axi_s_adapter.sv


#----------
# SDC
#----------

