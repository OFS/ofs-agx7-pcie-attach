# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Pin and location assignments
#
#-----------------------------------------------------------------------------
set_location_assignment PIN_CU26 -to hssi_rec_clk[0]
set_location_assignment PIN_CR26 -to "hssi_rec_clk[0](n)"
set_location_assignment PIN_CN20 -to hssi_rec_clk[1]
set_location_assignment PIN_CL20 -to "hssi_rec_clk[1](n)"
set_location_assignment PIN_CG26 -to hssi_rec_clk[2]
set_location_assignment PIN_CE26 -to "hssi_rec_clk[2](n)"

set_location_assignment PIN_CF17 -to qsfpa_resetn
set_location_assignment PIN_CH17 -to qsfpa_lpmode
set_location_assignment PIN_CE18 -to qsfpa_modeseln
set_location_assignment PIN_CG18 -to qsfpa_intn
set_location_assignment PIN_CF19 -to qsfpa_modprsln
set_location_assignment PIN_CE22 -to qsfpa_power_good
set_location_assignment PIN_CH19 -to qsfpb_resetn
set_location_assignment PIN_CE20 -to qsfpb_lpmode
set_location_assignment PIN_CG20 -to qsfpb_modeseln
set_location_assignment PIN_CF21 -to qsfpb_intn
set_location_assignment PIN_CH21 -to qsfpb_modprsln
set_location_assignment PIN_CG22 -to qsfpb_power_good
set_location_assignment PIN_CK17 -to qsfpa_i2c_scl
set_location_assignment PIN_CM17 -to qsfpa_i2c_sda

set_location_assignment PIN_CE24 -to "tod_fpga_clk(n)"
set_location_assignment PIN_CG24 -to tod_fpga_clk
set_location_assignment PIN_CH25 -to b_1pps_fpga_clk
set_location_assignment PIN_CL18 -to qsfpb_i2c_scl
set_location_assignment PIN_CM19 -to qsfpb_i2c_sda
set_location_assignment PIN_V19  -to b_sel_1pps_inout
set_location_assignment PIN_CH27 -to b_shdn_1pps_to_10mhz
set_location_assignment PIN_CG28 -to b_shdn_10mhz_in
set_location_assignment PIN_CH29 -to b_shdn_10mhz_out
set_location_assignment PIN_CR20 -to rmii_crs_dv
set_location_assignment PIN_CU18 -to rmii_rxd[0]
set_location_assignment PIN_CV17 -to rmii_rxd[1]
set_location_assignment PIN_CR18 -to rmii_txd[0]
set_location_assignment PIN_CU20 -to rmii_txd[1]
set_location_assignment PIN_CV19 -to rmii_tx_en
set_location_assignment PIN_CV21 -to rmii_rxer
set_location_assignment PIN_CN24 -to arb_in
set_location_assignment PIN_CK25 -to arb_out
set_location_assignment PIN_CM25 -to fm61_testio_d[0]
set_location_assignment PIN_CL26 -to fm61_testio_d[1]
set_location_assignment PIN_CN26 -to fm61_testio_d[2]
set_location_assignment PIN_CK27 -to fm61_testio_d[3]
set_location_assignment PIN_CM27 -to fm61_testio_d[4]
set_location_assignment PIN_CL28 -to fm61_testio_d[5]
set_location_assignment PIN_CN28 -to fm61_testio_d[6]
set_location_assignment PIN_CK29 -to fm61_testio_d[7]
set_location_assignment PIN_CM29 -to fm61_testio_clkout
set_location_assignment PIN_DA22 -to "fpga_pcie_refclk3_100m(n)"
set_location_assignment PIN_DC22 -to fpga_pcie_refclk3_100m
set_location_assignment PIN_CN22 -to rmii_ref_clk
set_location_assignment PIN_CV27 -to fpga_fabric_reset_n
set_location_assignment PIN_CU28 -to m10_conf_done
set_location_assignment PIN_DC24 -to b_fpga_hps_zl_gpout[0]
set_location_assignment PIN_DA26 -to qsfpa_act_r
set_location_assignment PIN_DC26 -to qsfpa_act_g
set_location_assignment PIN_CY27 -to qsfpb_act_r
set_location_assignment PIN_DB27 -to qsfpb_act_g
set_location_assignment PIN_DA28 -to qsfpa_speed_y
set_location_assignment PIN_DC28 -to qsfpa_speed_g
set_location_assignment PIN_CY29 -to qsfpb_speed_y
set_location_assignment PIN_DB29 -to qsfpb_speed_g
# set_location_assignment PIN_AG6 -to hps_uart_tx
# set_location_assignment PIN_AB1 -to hps_uart_rx
# set_location_assignment PIN_V1 -to b_fpga_hps_zl_ho
# set_location_assignment PIN_AD11 -to fpga_hps_clkin
# set_location_assignment PIN_AC12 -to b_zl_spi_sck
# set_location_assignment PIN_H3 -to b_zl_spi_si
# set_location_assignment PIN_AD13 -to b_zl_spi_so
# set_location_assignment PIN_F3 -to b_zl_spi_cs

####CVL RX serial connections to lower ports 0-7 of hssi_ss ####

set_location_assignment PIN_AK7  -to hssi_if[0].rx_p
set_location_assignment PIN_AL10 -to hssi_if[1].rx_p
set_location_assignment PIN_AP7  -to hssi_if[2].rx_p
set_location_assignment PIN_AR10 -to hssi_if[3].rx_p
set_location_assignment PIN_AV7  -to hssi_if[4].rx_p
set_location_assignment PIN_AW10 -to hssi_if[5].rx_p
set_location_assignment PIN_BB7  -to hssi_if[6].rx_p
set_location_assignment PIN_BC10 -to hssi_if[7].rx_p

####QSFP RX serial connections to upper ports 8-15 of hssi_ss ####

set_location_assignment PIN_BF7  -to hssi_if[8].rx_p
set_location_assignment PIN_BG10 -to hssi_if[9].rx_p
set_location_assignment PIN_BK7  -to hssi_if[10].rx_p
set_location_assignment PIN_BL10 -to hssi_if[11].rx_p
set_location_assignment PIN_BP7  -to hssi_if[12].rx_p
set_location_assignment PIN_BR10 -to hssi_if[13].rx_p
set_location_assignment PIN_BV7  -to hssi_if[14].rx_p
set_location_assignment PIN_BW10 -to hssi_if[15].rx_p

set_location_assignment PIN_AK13 -to qsfp_ref_clk
set_location_assignment PIN_AH13 -to "qsfp_ref_clk(n)"
set_location_assignment PIN_AR14 -to cr3_cpri_refclk_clk[1]
set_location_assignment PIN_AN14 -to "cr3_cpri_refclk_clk[1](n)"
set_location_assignment PIN_AJ12 -to cr3_cpri_refclk_clk[2]
set_location_assignment PIN_AH11 -to "cr3_cpri_refclk_clk[2](n)"
set_location_assignment PIN_AT13 -to cr3_cpri_reflclk_clk[0]
set_location_assignment PIN_AP13 -to "cr3_cpri_reflclk_clk[0](n)"
set_location_assignment PIN_AJ14 -to cr3_cpri_reflclk_clk_184_32m
set_location_assignment PIN_AL14 -to "cr3_cpri_reflclk_clk_184_32m(n)"
set_location_assignment PIN_AR16 -to cr3_cpri_reflclk_clk_153_6m
set_location_assignment PIN_AN16 -to "cr3_cpri_reflclk_clk_153_6m(n)"

####CVL TX serial connections to lower ports 0-7 of hssi_ss ####


set_location_assignment PIN_AK1 -to hssi_if[0].tx_p
set_location_assignment PIN_AL4 -to hssi_if[1].tx_p
set_location_assignment PIN_AP1 -to hssi_if[2].tx_p
set_location_assignment PIN_AR4 -to hssi_if[3].tx_p
set_location_assignment PIN_AV1 -to hssi_if[4].tx_p
set_location_assignment PIN_AW4 -to hssi_if[5].tx_p
set_location_assignment PIN_BB1 -to hssi_if[6].tx_p
set_location_assignment PIN_BC4 -to hssi_if[7].tx_p

####QSFP TX serial connections to upper ports 8-15 of hssi_ss ####

set_location_assignment PIN_BF1 -to hssi_if[8].tx_p
set_location_assignment PIN_BG4 -to hssi_if[9].tx_p
set_location_assignment PIN_BK1 -to hssi_if[10].tx_p
set_location_assignment PIN_BL4 -to hssi_if[11].tx_p
set_location_assignment PIN_BP1 -to hssi_if[12].tx_p
set_location_assignment PIN_BR4 -to hssi_if[13].tx_p
set_location_assignment PIN_BV1 -to hssi_if[14].tx_p
set_location_assignment PIN_BW4 -to hssi_if[15].tx_p

set_location_assignment PIN_BP61 -to PCIE_RX_P[0]
set_location_assignment PIN_BN58 -to PCIE_RX_P[1]
set_location_assignment PIN_BK61 -to PCIE_RX_P[2]
set_location_assignment PIN_BJ58 -to PCIE_RX_P[3]
set_location_assignment PIN_BF61 -to PCIE_RX_P[4]
set_location_assignment PIN_BE58 -to PCIE_RX_P[5]
set_location_assignment PIN_BB61 -to PCIE_RX_P[6]
set_location_assignment PIN_BA58 -to PCIE_RX_P[7]
set_location_assignment PIN_AV61 -to PCIE_RX_P[8]
set_location_assignment PIN_AU58 -to PCIE_RX_P[9]
set_location_assignment PIN_AP61 -to PCIE_RX_P[10]
set_location_assignment PIN_AN58 -to PCIE_RX_P[11]
set_location_assignment PIN_AK61 -to PCIE_RX_P[12]
set_location_assignment PIN_AJ58 -to PCIE_RX_P[13]
set_location_assignment PIN_AF61 -to PCIE_RX_P[14]
set_location_assignment PIN_AE58 -to PCIE_RX_P[15]
set_location_assignment PIN_BR62 -to PCIE_RX_N[0]
set_location_assignment PIN_BM59 -to PCIE_RX_N[1]
set_location_assignment PIN_BL62 -to PCIE_RX_N[2]
set_location_assignment PIN_BH59 -to PCIE_RX_N[3]
set_location_assignment PIN_BG62 -to PCIE_RX_N[4]
set_location_assignment PIN_BD59 -to PCIE_RX_N[5]
set_location_assignment PIN_BC62 -to PCIE_RX_N[6]
set_location_assignment PIN_AY59 -to PCIE_RX_N[7]
set_location_assignment PIN_AW62 -to PCIE_RX_N[8]
set_location_assignment PIN_AT59 -to PCIE_RX_N[9]
set_location_assignment PIN_AR62 -to PCIE_RX_N[10]
set_location_assignment PIN_AM59 -to PCIE_RX_N[11]
set_location_assignment PIN_AL62 -to PCIE_RX_N[12]
set_location_assignment PIN_AH59 -to PCIE_RX_N[13]
set_location_assignment PIN_AG62 -to PCIE_RX_N[14]
set_location_assignment PIN_AD59 -to PCIE_RX_N[15]
set_location_assignment PIN_BU58 -to PCIE_RESET_N
set_location_assignment PIN_AH49 -to "PCIE_REFCLK0(n)"
set_location_assignment PIN_AJ48 -to PCIE_REFCLK0
set_location_assignment PIN_AD49 -to "PCIE_REFCLK1(n)"
set_location_assignment PIN_AE48 -to PCIE_REFCLK1
set_location_assignment PIN_BP55 -to PCIE_TX_P[0]
set_location_assignment PIN_BN52 -to PCIE_TX_P[1]
set_location_assignment PIN_BK55 -to PCIE_TX_P[2]
set_location_assignment PIN_BJ52 -to PCIE_TX_P[3]
set_location_assignment PIN_BF55 -to PCIE_TX_P[4]
set_location_assignment PIN_BE52 -to PCIE_TX_P[5]
set_location_assignment PIN_BB55 -to PCIE_TX_P[6]
set_location_assignment PIN_BA52 -to PCIE_TX_P[7]
set_location_assignment PIN_AV55 -to PCIE_TX_P[8]
set_location_assignment PIN_AU52 -to PCIE_TX_P[9]
set_location_assignment PIN_AP55 -to PCIE_TX_P[10]
set_location_assignment PIN_AN52 -to PCIE_TX_P[11]
set_location_assignment PIN_AK55 -to PCIE_TX_P[12]
set_location_assignment PIN_AJ52 -to PCIE_TX_P[13]
set_location_assignment PIN_AF55 -to PCIE_TX_P[14]
set_location_assignment PIN_AE52 -to PCIE_TX_P[15]
set_location_assignment PIN_BR56 -to PCIE_TX_N[0]
set_location_assignment PIN_BM53 -to PCIE_TX_N[1]
set_location_assignment PIN_BL56 -to PCIE_TX_N[2]
set_location_assignment PIN_BH53 -to PCIE_TX_N[3]
set_location_assignment PIN_BG56 -to PCIE_TX_N[4]
set_location_assignment PIN_BD53 -to PCIE_TX_N[5]
set_location_assignment PIN_BC56 -to PCIE_TX_N[6]
set_location_assignment PIN_AY53 -to PCIE_TX_N[7]
set_location_assignment PIN_AW56 -to PCIE_TX_N[8]
set_location_assignment PIN_AT53 -to PCIE_TX_N[9]
set_location_assignment PIN_AR56 -to PCIE_TX_N[10]
set_location_assignment PIN_AM53 -to PCIE_TX_N[11]
set_location_assignment PIN_AL56 -to PCIE_TX_N[12]
set_location_assignment PIN_AH53 -to PCIE_TX_N[13]
set_location_assignment PIN_AG56 -to PCIE_TX_N[14]
set_location_assignment PIN_AD53 -to PCIE_TX_N[15]
set_location_assignment PIN_DB21 -to rzq_2c
set_location_assignment PIN_D29 -to fpga_cvl_sdp20
set_location_assignment PIN_L22 -to fpga_cvl_sdp21
set_location_assignment PIN_N24 -to fpga_cvl_clk_out_n
set_location_assignment PIN_L24 -to fpga_cvl_clk_out_p
set_location_assignment PIN_G28 -to fpga_cvl_rmii_clkin
set_location_assignment PIN_M31 -to fpga_cvl_rmii_txen
set_location_assignment PIN_G30 -to fpga_cvl_rmii_txd[0]
set_location_assignment PIN_P31 -to fpga_cvl_rmii_txd[1]
set_location_assignment PIN_H29 -to fpga_cvl_rmii_rxd[0]
set_location_assignment PIN_J30 -to fpga_cvl_rmii_rxd[1]
set_location_assignment PIN_L30 -to fpga_cvl_rmii_crsdv
set_location_assignment PIN_N30 -to fpga_cvl_rmii_arb_in
set_location_assignment PIN_F29 -to fpga_cvl_rmii_arb_out
set_location_assignment PIN_T19 -to fm61_smclk
set_location_assignment PIN_P19 -to fm61_smdat
set_location_assignment PIN_H19 -to fpga_cvl_sdp0
set_location_assignment PIN_F19 -to fpga_cvl_sdp1
set_location_assignment PIN_J20 -to fpga_cvl_sdp2
set_location_assignment PIN_G20 -to fpga_cvl_sdp3
set_location_assignment PIN_H21 -to fpga_cvl_sdp4
set_location_assignment PIN_F21 -to fpga_cvl_sdp5
set_location_assignment PIN_J22 -to fpga_cvl_sdp6
set_location_assignment PIN_G22 -to fpga_cvl_sdp7
set_location_assignment PIN_C28 -to fpga_cvl_i2cclk[1]
set_location_assignment PIN_B29 -to fpga_cvl_i2cdat[1]
set_location_assignment PIN_C24 -to "SYS_REFCLK(n)"
set_location_assignment PIN_A24 -to SYS_REFCLK
set_location_assignment PIN_F31 -to fm61_scl
set_location_assignment PIN_H31 -to fm61_sda
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to qsfp_ref_clk
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_refclk_clk[1]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_refclk_clk[1]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to cr3_cpri_refclk_clk[1]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_refclk_clk[1]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=184320000" -to cr3_cpri_refclk_clk[1]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_refclk_clk[1]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_refclk_clk[1]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_refclk_clk[2]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_refclk_clk[2]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to cr3_cpri_refclk_clk[2]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_refclk_clk[2]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=153600000" -to cr3_cpri_refclk_clk[2]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_refclk_clk[2]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_refclk_clk[2]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_reflclk_clk[0]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_reflclk_clk[0]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to cr3_cpri_reflclk_clk[0]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_reflclk_clk[0]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=245760000" -to cr3_cpri_reflclk_clk[0]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_reflclk_clk[0]
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_reflclk_clk[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_reflclk_clk_184_32m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_reflclk_clk_184_32m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=enable_3p3v_tol" -to cr3_cpri_reflclk_clk_184_32m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_reflclk_clk_184_32m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=184320000" -to cr3_cpri_reflclk_clk_184_32m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_reflclk_clk_184_32m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_reflclk_clk_184_32m
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to cr3_cpri_reflclk_clk_153_6m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to cr3_cpri_reflclk_clk_153_6m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=enable_3p3v_tol" -to cr3_cpri_reflclk_clk_153_6m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to cr3_cpri_reflclk_clk_153_6m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=153600000" -to cr3_cpri_reflclk_clk_153_6m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to cr3_cpri_reflclk_clk_153_6m
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=FALSE" -to cr3_cpri_reflclk_clk_153_6m

set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to hssi_rec_clk[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to hssi_rec_clk[1]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to hssi_rec_clk[2]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 34 OHM WITH CALIBRATION" -to hssi_rec_clk[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 34 OHM WITH CALIBRATION" -to hssi_rec_clk[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 34 OHM WITH CALIBRATION" -to hssi_rec_clk[2]
set_instance_assignment -name RZQ_GROUP RZQ_2C -to hssi_rec_clk[0]
set_instance_assignment -name RZQ_GROUP RZQ_2C -to hssi_rec_clk[1]
set_instance_assignment -name RZQ_GROUP RZQ_2C -to hssi_rec_clk[2]
set_instance_assignment -name RZQ_GROUP RZQ_2C -to "hssi_rec_clk[0](n)"
set_instance_assignment -name RZQ_GROUP RZQ_2C -to "hssi_rec_clk[1](n)"
set_instance_assignment -name RZQ_GROUP RZQ_2C -to "hssi_rec_clk[2](n)"
# Agilex only supports the fastest Slew Rate for GPIO with this voltage-referenced standard [UG-20214 2.2.1] 
set_instance_assignment -name SLEW_RATE 2 -to hssi_rec_clk[0]
set_instance_assignment -name SLEW_RATE 2 -to hssi_rec_clk[1]
set_instance_assignment -name SLEW_RATE 2 -to hssi_rec_clk[2]
# Select de-emphasis as requested by hardware team:
set_instance_assignment -name PROGRAMMABLE_DEEMPHASIS LOW_LP -to hssi_rec_clk[0]
set_instance_assignment -name PROGRAMMABLE_DEEMPHASIS LOW_LP -to hssi_rec_clk[1]
set_instance_assignment -name PROGRAMMABLE_DEEMPHASIS LOW_LP -to hssi_rec_clk[2]

set_instance_assignment -name IO_STANDARD "1.2 V" -to b_sel_1pps_inout
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_1pps_to_10mhz
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_10mhz_in
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_10mhz_out
set_instance_assignment -name SLEW_RATE 0 -to b_sel_1pps_inout
set_instance_assignment -name SLEW_RATE 0 -to b_shdn_1pps_to_10mhz
set_instance_assignment -name SLEW_RATE 0 -to b_shdn_10mhz_in
set_instance_assignment -name SLEW_RATE 0 -to b_shdn_10mhz_out
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to cvl_serial_rx_p[*]
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to cvl_serial_tx_p[*]
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to hssi_if[*].tx_p
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to hssi_if[*].rx_p
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_resetn -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_lpmode -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_modeseln -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_intn -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_modprsln -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_power_good -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_resetn -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_lpmode -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_modeseln -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_intn -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_modprsln -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_power_good -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_i2c_scl -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_i2c_sda -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_i2c_scl -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_i2c_sda -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_resetn -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_lpmode -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_modeseln -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_resetn -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_lpmode -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_modeseln -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_i2c_scl -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_i2c_sda -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_i2c_scl -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_i2c_sda -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_act_g -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_act_r -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_act_g -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_act_r -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_speed_g -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_speed_y -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_speed_g -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_speed_y -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_act_g -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_act_r -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_act_g -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_act_r -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_speed_g -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_speed_y -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_speed_g -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_speed_y -entity top
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK0
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK1
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to fpga_pcie_refclk3_100m
set_instance_assignment -name IO_STANDARD 1.8V -to PCIE_RESET_N
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_RX_P
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_TX_P
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to SYS_REFCLK
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to SYS_REFCLK
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_cs_n
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_d
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_oe
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_clk
set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_cs_n
set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_d
set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_oe
set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_clk
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_m10_ibus
set_instance_assignment -name SLEW_RATE 0 -to fpga_m10_ibus
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_fabric_reset_n
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_seu_error
set_instance_assignment -name SLEW_RATE 0 -to fpga_seu_error
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp20
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp21
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_clk_out_n
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_clk_out_p
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_clkin
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_txen
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_txd
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_rxd
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_crsdv
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_arb_in
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_rmii_arb_out
set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_en
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp0
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp1
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp2
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp3
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp4
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp5
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp6
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_sdp7
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_i2cclk[1]
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_cvl_i2cdat[1]
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp20
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp21
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_rmii_txen
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_rmii_txd
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_rmii_arb_in
set_instance_assignment -name SLEW_RATE 0 -to rmii_en
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp0
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp1
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp2
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp3
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp4
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp5
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp6
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_sdp7
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_i2cclk[1]
set_instance_assignment -name SLEW_RATE 0 -to fpga_cvl_i2cdat[1]
set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_crs_dv
set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_ref_clk
set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_rxd
set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_rxer
set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_txd
set_instance_assignment -name IO_STANDARD "1.2 V" -to rmii_tx_en
set_instance_assignment -name IO_STANDARD "1.2 V" -to arb_in
set_instance_assignment -name IO_STANDARD "1.2 V" -to arb_out
set_instance_assignment -name SLEW_RATE 0 -to rmii_txd
set_instance_assignment -name SLEW_RATE 0 -to arb_in
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_1pps_fpga_clk
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to tod_fpga_clk
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_d
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_clkout
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_clkin
set_instance_assignment -name SLEW_RATE 0 -to fm61_testio_d
set_instance_assignment -name SLEW_RATE 0 -to fm61_testio_clkout
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_m10_crc_error
set_instance_assignment -name IO_STANDARD "1.2 V" -to m10_conf_done
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_fpga_hps_zl_gpout
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_smclk
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_smdat
set_instance_assignment -name SLEW_RATE 0 -to fm61_smdat
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_scl
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_sda
set_instance_assignment -name SLEW_RATE 0 -to fm61_scl
set_instance_assignment -name SLEW_RATE 0 -to fm61_sda
