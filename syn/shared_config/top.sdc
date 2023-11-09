# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
#   Platform top level SDC 
#
#-----------------------------------------------------------------------------

set file_path [file normalize [info script]]
set file_dir [file dirname $file_path]

source $file_dir/top_sdc_util.tcl

#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************
derive_clock_uncertainty

create_clock -name SYS_REFCLK             -period  10.000 -waveform {0.000  5.000} [get_ports {SYS_REFCLK}]
create_clock -name PCIE_REFCLK0           -period  10.000 -waveform {0.000  5.000} [get_ports {PCIE_REFCLK0}]
create_clock -name PCIE_REFCLK1           -period  10.000 -waveform {0.000  5.000} [get_ports {PCIE_REFCLK1}]
create_clock -name {altera_reserved_tck}  -period 100.000 -waveform {0.000 50.000} [get_ports {altera_reserved_tck}]

#**************************************************************
# Create Generated Clock
#**************************************************************
create_generated_clock -add -name pcie_wrapper|pcie_ss_top|*|pcie_ss|avmm_clock0 \
                       -source      [get_pins {pcie_wrapper|pcie_ss_top|*|pcie_ss|u_pciess_p0|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|inclk}] \
                       -divide_by 2 [get_pins {pcie_wrapper|pcie_ss_top|*|pcie_ss|u_pciess_p0|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2}]


#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -asynchronous -group {altera_reserved_tck}
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_sys}
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_sys} -group { pcie_wrapper|pcie_ss_top|*|pcie_ss|*|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15}
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m } -group {pcie_wrapper|pcie_ss_top|*|pcie_ss|*|intel_pcie_*_ast_qhip|rx_clkout|ch5}
set_clock_groups -asynchronous -group {altera_int_osc_clk} -group {pcie_wrapper|pcie_ss_top|*|pcie_ss|*|intel_pcie_*_ast_qhip|rx_clkout|ch5}
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m } -group {pcie_wrapper|pcie_ss_top|*|pcie_ss|*|intel_pcie_rtile_ast_qhip_pld_clkout_slow}
set_clock_groups -asynchronous -group {pcie_wrapper|pcie_ss_top|*|pcie_ss|avmm_clock0} -group {pcie_wrapper|pcie_ss_top|*|pcie_ss|*|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15}
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m} -group {pcie_wrapper|pcie_ss_top|*|pcie_ss|*|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15}
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m} -group {pcie_wrapper|pcie_ss_top|*|pcie_ss|avmm_clock0}
# temporary constraint while mem_tg is fixed to not instantiate dbg fabric
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m} -group {mem_ss_top|mem_ss_fm_inst|mem_ss_fm_0|intf_0_core_usr_clk}


#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -setup -end -from [get_clocks {*avmm_clock0}] -to [get_clocks {sys_pll|iopll_0_clk_100m}] 2
set_multicycle_path -hold -end -from [get_clocks {*avmm_clock0}] -to [get_clocks {sys_pll|iopll_0_clk_100m}] 1
set_multicycle_path -setup -start -from [get_clocks {sys_pll|iopll_0_clk_100m}] -to [get_clocks {*avmm_clock0}] 2
set_multicycle_path -hold -start -from [get_clocks {sys_pll|iopll_0_clk_100m}] -to [get_clocks {*avmm_clock0}] 1

#**************************************************************
# Set False Path
#**************************************************************

#**************************************************************
# Set Maximum Delay
# Set Minimum Delay
#**************************************************************
#set qsfp_clk sys_pll|iopll_0_clk_100m

#set_output_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_resetn}]
#set_output_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_resetn}]

#set_output_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_modeseln}]
#set_output_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_modeseln}]

#set_output_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_lpmode}]
#set_output_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_lpmode}]

#set_input_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_modprsln}]
#set_input_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_modprsln}]

#set_input_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_intn}]
#set_input_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpa_intn}]


#set_output_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_resetn}]
#set_output_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_resetn}]

#set_output_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_modeseln}]
#set_output_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_modeseln}]

#set_output_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_lpmode}]
#set_output_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_lpmode}]

#set_input_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_modprsln}]
#set_input_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_modprsln}]

#set_input_delay -max 0.1 -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_intn}]
#set_input_delay -min 0  -source_latency_included -clock $qsfp_clk [get_ports {qsfpb_intn}]



#---------------------------------------------
# CDC constraints for reset synchronizers
#---------------------------------------------
add_reset_sync_sdc {rst_ctrl|rst_clk100m_resync|resync_chains[0].synchronizer_nocut|*|clrn}	
add_reset_sync_sdc {rst_ctrl|rst_clk50m_resync|resync_chains[0].synchronizer_nocut|*|clrn}	
add_reset_sync_sdc {rst_ctrl|rst_clk_sys_resync|resync_chains[0].synchronizer_nocut|*|clrn}	
add_reset_sync_sdc {rst_ctrl|pwr_good_n_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {rst_ctrl|pwr_good_csr_clk_n_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {rst_ctrl|rst_in_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {rst_ctrl|rst_warm_in_resync|resync_chains[0].synchronizer_nocut*|*|clrn}
add_reset_sync_sdc {rst_ctrl|rst_clk_ptp_slv_resync|resync_chains[0].synchronizer_nocut*|*|clrn}

add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_bridge|pcie_bridge_cdc|rx_cdc|rx_avst_dcfifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_bridge|pcie_bridge_cdc|rx_cdc|rx_avst_dcfifo|dcfifo|dcfifo_component|auto_generated|wraclr|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_bridge|pcie_bridge_cdc|tx_cdc|tx_axis_dcfifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_bridge|pcie_bridge_cdc|tx_cdc|tx_axis_dcfifo|dcfifo|dcfifo_component|auto_generated|rdaclr|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_flr_resync|flr_req_fifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_flr_resync|flr_req_fifo|dcfifo|dcfifo_component|auto_generated|rdaclr|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_flr_resync|flr_rsp_fifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {pcie_wrapper|pcie_top|pcie_flr_resync|flr_rsp_fifo|dcfifo|dcfifo_component|auto_generated|wraclr|*|clrn}

add_reset_sync_sdc {afu_top|flr_rst_ctrl|*pf_flr_resync*|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {afu_top|flr_rst_ctrl|*vf_flr_resync*|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {afu_top|st2mm|tx_cdc_fifo|fifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {afu_top|st2mm|tx_cdc_fifo|fifo|dcfifo|dcfifo_component|auto_generated|rdaclr|*|clrn}
add_reset_sync_sdc {afu_top|st2mm|rx_cdc_fifo|fifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {afu_top|st2mm|rx_cdc_fifo|fifo|dcfifo|dcfifo_component|auto_generated|rdaclr|*|clrn}

add_reset_sync_sdc {afu_top|*|*he_hssi_top|GenRstSync[*].*_reset_synchronizer|resync_chains[*].*|*|clrn}
add_reset_sync_sdc {afu_top|*|*|*|he_hssi_top|GenRstSync[*].*_reset_synchronizer|resync_chains[*].*|*|clrn}
add_reset_sync_sdc {afu_top|fim_afu_instances|*GenCPR[*].cvl_data_sync|fifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {afu_top|fim_afu_instances|*GenCPR[*].cvl_data_sync|fifo|dcfifo|dcfifo_component|auto_generated|rdaclr|*|clrn}
add_reset_sync_sdc {afu_top|*|*he_hssi_top|GenCPR[*].cvl_data_sync|fifo|rst_rclk_resync|resync_chains[0].synchronizer_nocut|*|clrn}
add_reset_sync_sdc {afu_top|*|*he_hssi_top|GenCPR[*].cvl_data_sync|fifo|dcfifo|dcfifo_component|auto_generated|rdaclr|*|clrn}
add_reset_sync_sdc {mem_ss_top|rst_hs_resync|resync_chains[*].*|*|clrn}

#---------------------------------------------
# CDC constraints for synchronizers
#---------------------------------------------
add_sync_sdc {pcie_wrapper|pcie_top|csr_resync|resync_chains[*].synchronizer_nocut|din_s1}
add_sync_sdc {rst_ctrl|pcie_cold_rst_ack_sync|resync_chains[*].synchronizer_nocut|din_s1}
add_sync_sdc {afu_top|flr_rst_ctrl|flr_ack_resync|resync_chains[*].synchronizer_nocut|din_s1}
add_sync_sdc {afu_top|flr_rst_ctrl|clr_ack_resync|resync_chains[*].synchronizer_nocut|din_s1}

add_sync_sdc {afu_top|he_hssi_top|*|resync_chains[*].synchronizer_nocut|din_s1}
add_sync_sdc {afu_top|*|*|*|he_hssi_top|*|resync_chains[*].synchronizer_nocut|din_s1}

add_sync_sdc {mem_ss_top|mem_ss_cal_success_resync|resync_chains[*].synchronizer_nocut|din_s1}
add_sync_sdc {mem_ss_top|mem_ss_cal_fail_resync|resync_chains[*].synchronizer_nocut|din_s1}

#---------------------------------------------
# Multicycle path 
#---------------------------------------------
   
#**************************************************************
# Set Input Delay
#**************************************************************

#**************************************************************
# Set Output Delay
#**************************************************************


