# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Ethernet
#--------------------

set_global_assignment -name SEARCH_PATH "$::env(BUILD_ROOT_REL)/ipss"
set_global_assignment -name SEARCH_PATH "$::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc"

#-----------------
# HSSI Common Files
#-----------------
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_plat_defines.svh 
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_plat_if_pkg.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_if_pkg.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_if.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_avst_if_pkg.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_avst_if.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/lib/ofs_fim_eth_afu_avst_to_fim_axis_bridge.sv 
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/lib/ofs_fim_eth_sb_afu_avst_to_fim_axis_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/lib/mm_ctrl_xcvr.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/lib/rst_ack.sv

#-----------------
# HSSI SS IP
#-----------------
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/hssi_ss/hssi_ss.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/ptp_iopll/ptp_sample_clk_pll.ip
# Add the HSSI SS to the dictionary of IP files that will be parsed by OFS
# into the project's ofs_ip_cfg_db directory. Parameters from the configured
# IP will be turned into Verilog macros.
dict set ::ofs_ip_cfg_db::ip_db $::env(BUILD_ROOT_REL)/ipss/hssi/qip/hssi_ss/hssi_ss.ip [list hssi_ss hssi_ss_get_cfg.tcl]

#----------------------------------
# HSSI SS CSR Interconnect
#----------------------------------
set_global_assignment -name QSYS_FILE             $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/hssi_ss_csr_ic.qsys
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_ic_clock_in.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_ic_reset_in.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_mst.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_ip_slv.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_wrapper_slv.ip

#-----------------
# HSSI SS top
#-----------------
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/hssi_wrapper_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/hssi_wrapper.sv

#-----------------
# QSFP Controller
#-----------------
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl.qsys
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl_reset_in.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl_i2c_0.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl_onchip_memory2_0.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl_clock_in.ip

set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/qsfp/rtl/csr_wr_logic.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/qsfp/rtl/poller_fsm.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/qsfp/rtl/qsfp_com.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/qsfp/rtl/qsfp_top.sv

