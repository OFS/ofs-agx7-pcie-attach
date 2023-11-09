# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT
#-----------------------------------------------------------------------------
# Description
#-----------------------------------------------------------------------------
#
#   Eth Top SDC 
#
#-----------------------------------------------------------------------------
#**************************************************************
# Create Clock
#**************************************************************
create_clock -name qsfp_ref_clk -period   6.400 -waveform {0.000  3.200} [get_ports {qsfp_ref_clk}]
#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -exclusive -group  {get_clocks ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk}
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m} -group {hssi_wrapper|hssi_ss|hssi_ss|U_eth_f_inst_p*|eth_f_top_p*|tx_clkout|ch*}
#**************************************************************
# Constraints for HSSI SS paths
#**************************************************************
add_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|U_hssi_ss_ip_wrapper|*|resync_chains[*].synchronizer_nocut|din_s1}
add_reset_sync_sdc {hssi_wrapper|GenClkRst[*].st_*_rst_sync|resync_chains[*].synchronizer|dreg[*]|clrn}
set_false_path -from [get_keepers -no_duplicates {hssi_wrapper|hssi_ss|hssi_ss|U_SRC_RST_CONTROLLER|SS_RST_SEQ|gen_resp_rst_sync[*].resp_rst_sync|dreg[*]}] -to [get_keepers -no_duplicates {hssi_wrapper|hssi_ss|hssi_ss|U_SRC_RST_CONTROLLER|p*_out_sync_*|din_s1}]
add_reset_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|U_SRC_RST_CONTROLLER|p*_out_sync_*|dreg[*]|clrn}
add_reset_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|U_hssi_ss_ip_wrapper|U_hssi_ss_ip_top_p*|alt_ehipc3_fm_0|alt_ehipc3_fm_top_p*|SL_SOFT.SL_SOFT_I[*].sl_soft|SL_RST_CTRL.csr_reset_sync_tx_clk|resync_chains[*].synchronizer_nocut|dreg[*]|clrn}
add_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|U_SRC_RST_CONTROLLER|SS_RST_SEQ|gen_resp_rst_sync[*].resp_rst_sync|din_s1}
add_reset_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|U_SRC_RST_CONTROLLER|SS_RST_SEQ|gen_resp_rst_sync[*].resp_rst_sync|dreg[*]|clrn}
add_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|*hssi_ss_led*|*_pulse_sync|din_s1}
add_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|*hssi_ss_led_p*|pulse_10msec_*x_d1}
add_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|*hssi_ss_led_p*|*sig_det*}
add_sync_sdc {hssi_wrapper|hssi_ss|hssi_ss|*hssi_ss_led_p*|led_status[*]}
#Timing for 100G
set_false_path -from [get_clocks {sys_pll|iopll_0_clk_100m}] -to [get_clocks {hssi_wrapper|hssi_ss|hssi_ss|U_hssi_ss_ip_wrapper|U_hssi_ss_ip_top_p*|alt_ehipc3_fm_0|alt_ehipc3_fm_top_p*|alt_ehipc3_fm_hard_inst|E100GX4_FEC.altera_xcvr_native_inst|xcvr_native_s10_etile_0_example_design_4ln_ptp|tx_clkout|ch0}]; 
set_false_path -from [get_clocks {hssi_wrapper|hssi_ss|hssi_ss|U_hssi_ss_ip_wrapper|U_hssi_ss_ip_top_p*|alt_ehipc3_fm_0|alt_ehipc3_fm_top_p*|alt_ehipc3_fm_hard_inst|E100GX4_FEC.altera_xcvr_native_inst|xcvr_native_s10_etile_0_example_design_4ln_ptp|tx_clkout|ch0}] -to [get_clocks {sys_pll|iopll_0_clk_100m}];
