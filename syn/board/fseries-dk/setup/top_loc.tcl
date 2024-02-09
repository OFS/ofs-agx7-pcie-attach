# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Pin and location assignments
#
#-----------------------------------------------------------------------------

set_location_assignment PIN_P36 -to qsfpa_resetn
set_location_assignment PIN_R35 -to qsfpa_lpmode
set_location_assignment PIN_M36 -to qsfpa_modeseln
set_location_assignment PIN_L35 -to qsfpa_intn
set_location_assignment PIN_P34 -to qsfpa_modprsln
set_location_assignment PIN_R33 -to qsfpa_power_good
set_location_assignment PIN_P32 -to qsfpb_resetn
set_location_assignment PIN_R31 -to qsfpb_lpmode
set_location_assignment PIN_M32 -to qsfpb_modeseln
set_location_assignment PIN_L31 -to qsfpb_intn
set_location_assignment PIN_Y36 -to qsfpb_modprsln
set_location_assignment PIN_W35 -to qsfpb_power_good
set_location_assignment PIN_K44 -to qsfpa_i2c_scl
set_location_assignment PIN_J43 -to qsfpa_i2c_sda

set_location_assignment PIN_CE24 -to "tod_fpga_clk(n)"
set_location_assignment PIN_CG24 -to tod_fpga_clk
set_location_assignment PIN_CH25 -to b_1pps_fpga_clk
set_location_assignment PIN_B32 -to qsfpb_i2c_scl
set_location_assignment PIN_A31 -to qsfpb_i2c_sda
set_location_assignment PIN_V19  -to b_sel_1pps_inout
set_location_assignment PIN_CH27 -to b_shdn_1pps_to_10mhz
set_location_assignment PIN_CG28 -to b_shdn_10mhz_in
set_location_assignment PIN_CH29 -to b_shdn_10mhz_out
#set_location_assignment PIN_CR20 -to rmii_crs_dv
#set_location_assignment PIN_CU18 -to rmii_rxd[0]
#set_location_assignment PIN_CV17 -to rmii_rxd[1]
#set_location_assignment PIN_CR18 -to rmii_txd[0]
#set_location_assignment PIN_CU20 -to rmii_txd[1]
#set_location_assignment PIN_CV19 -to rmii_tx_en
#set_location_assignment PIN_CV21 -to rmii_rxer
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

set_location_assignment PIN_B48 -to qsfpa_act_r
set_location_assignment PIN_A47 -to qsfpa_act_g
set_location_assignment PIN_F36 -to qsfpa_speed_y
set_location_assignment PIN_G35 -to qsfpa_speed_g

set_location_assignment PIN_G49 -to qsfpb_act_r
set_location_assignment PIN_F48 -to qsfpb_act_g
set_location_assignment PIN_F32 -to qsfpb_speed_y
set_location_assignment PIN_G31 -to qsfpb_speed_g

# set_location_assignment PIN_AG6 -to hps_uart_tx
# set_location_assignment PIN_AB1 -to hps_uart_rx
# set_location_assignment PIN_V1 -to b_fpga_hps_zl_ho
# set_location_assignment PIN_AD11 -to fpga_hps_clkin
# set_location_assignment PIN_AC12 -to b_zl_spi_sck
# set_location_assignment PIN_H3 -to b_zl_spi_si
# set_location_assignment PIN_AD13 -to b_zl_spi_so
# set_location_assignment PIN_F3 -to b_zl_spi_cs

#set_location_assignment PIN_AK7  -to cvl_serial_rx_p[0]
#set_location_assignment PIN_AL10 -to cvl_serial_rx_p[1]
#set_location_assignment PIN_AP7  -to cvl_serial_rx_p[2]
#set_location_assignment PIN_AR10 -to cvl_serial_rx_p[3]
#set_location_assignment PIN_AV7  -to cvl_serial_rx_p[4]
#set_location_assignment PIN_AW10 -to cvl_serial_rx_p[5]
#set_location_assignment PIN_BB7  -to cvl_serial_rx_p[6]
#set_location_assignment PIN_BC10 -to cvl_serial_rx_p[7]
#
#set_location_assignment PIN_BL55 -to hssi_if[0].rx_p
#set_location_assignment PIN_AW55 -to hssi_if[1].rx_p
#set_location_assignment PIN_BG55 -to hssi_if[2].rx_p
#set_location_assignment PIN_BC55 -to hssi_if[3].rx_p
#
#set_location_assignment PIN_BM54 -to hssi_if[0].rx_n
#set_location_assignment PIN_AY54 -to hssi_if[1].rx_n
#set_location_assignment PIN_BH54 -to hssi_if[2].rx_n
#set_location_assignment PIN_BD54 -to hssi_if[3].rx_n
#
#set_location_assignment PIN_AR55 -to hssi_if[4].rx_p
#set_location_assignment PIN_K52  -to hssi_if[5].rx_p
#set_location_assignment PIN_AL55 -to hssi_if[6].rx_p
#set_location_assignment PIN_P52  -to hssi_if[7].rx_p
#
#set_location_assignment PIN_AT54 -to hssi_if[4].rx_n
#set_location_assignment PIN_J51  -to hssi_if[5].rx_n
#set_location_assignment PIN_AM54 -to hssi_if[6].rx_n
#set_location_assignment PIN_N51  -to hssi_if[7].rx_n
#set_location_assignment PIN_AW49 -to qsfp_ref_clk
#set_location_assignment PIN_AV48 -to "qsfp_ref_clk(n)"
#
#set_location_assignment PIN_BL49 -to hssi_if[0].tx_p
#set_location_assignment PIN_BB52 -to hssi_if[1].tx_p
#set_location_assignment PIN_BK52 -to hssi_if[2].tx_p
#set_location_assignment PIN_BF52 -to hssi_if[3].tx_p
#
#set_location_assignment PIN_BM48 -to hssi_if[0].tx_n
#set_location_assignment PIN_BA51 -to hssi_if[1].tx_n
#set_location_assignment PIN_BJ51 -to hssi_if[2].tx_n
#set_location_assignment PIN_BE51 -to hssi_if[3].tx_n
#
#set_location_assignment PIN_AV52 -to hssi_if[4].tx_p
#set_location_assignment PIN_R49 -to  hssi_if[5].tx_p
#set_location_assignment PIN_AP52 -to hssi_if[6].tx_p
#set_location_assignment PIN_V52 -to  hssi_if[7].tx_p
#
#set_location_assignment PIN_AU51 -to hssi_if[4].tx_n
#set_location_assignment PIN_T48 -to  hssi_if[5].tx_n
#set_location_assignment PIN_AN51 -to hssi_if[6].tx_n
#set_location_assignment PIN_U51 -to  hssi_if[7].tx_n



# qsfp dd connections for 400G, 200G and 25G  

set_location_assignment PIN_K52  -to hssi_if[0].rx_p
set_location_assignment PIN_P52  -to hssi_if[1].rx_p
set_location_assignment PIN_R55  -to hssi_if[2].rx_p
set_location_assignment PIN_W55  -to hssi_if[3].rx_p

set_location_assignment PIN_J51  -to hssi_if[0].rx_n
set_location_assignment PIN_N51  -to hssi_if[1].rx_n
set_location_assignment PIN_T54  -to hssi_if[2].rx_n
set_location_assignment PIN_Y54  -to hssi_if[3].rx_n

set_location_assignment PIN_AC55 -to hssi_if[4].rx_p
set_location_assignment PIN_AG55 -to hssi_if[5].rx_p
set_location_assignment PIN_AL55 -to hssi_if[6].rx_p
set_location_assignment PIN_AR55 -to hssi_if[7].rx_p

set_location_assignment PIN_AD54 -to hssi_if[4].rx_n
set_location_assignment PIN_AH54 -to hssi_if[5].rx_n
set_location_assignment PIN_AM54 -to hssi_if[6].rx_n
set_location_assignment PIN_AT54 -to hssi_if[7].rx_n


set_location_assignment PIN_AD48 -to qsfp_ref_clk
set_location_assignment PIN_AC49 -to "qsfp_ref_clk(n)"

set_location_assignment PIN_R49  -to hssi_if[0].tx_p
set_location_assignment PIN_V52  -to hssi_if[1].tx_p
set_location_assignment PIN_W49  -to hssi_if[2].tx_p
set_location_assignment PIN_AB52 -to hssi_if[3].tx_p

set_location_assignment PIN_T48  -to hssi_if[0].tx_n
set_location_assignment PIN_U51  -to hssi_if[1].tx_n
set_location_assignment PIN_Y48  -to hssi_if[2].tx_n
set_location_assignment PIN_AA51 -to hssi_if[3].tx_n

set_location_assignment PIN_AF52 -to hssi_if[4].tx_p
set_location_assignment PIN_AK52 -to hssi_if[5].tx_p
set_location_assignment PIN_AP52 -to hssi_if[6].tx_p
set_location_assignment PIN_AV52 -to hssi_if[7].tx_p

set_location_assignment PIN_AE51 -to hssi_if[4].tx_n
set_location_assignment PIN_AJ51 -to hssi_if[5].tx_n
set_location_assignment PIN_AN51 -to hssi_if[6].tx_n
set_location_assignment PIN_AU51 -to hssi_if[7].tx_n

set_location_assignment PIN_AF4 -to PCIE_RX_P[0]
set_location_assignment PIN_AJ1 -to PCIE_RX_P[1]
set_location_assignment PIN_AN1 -to PCIE_RX_P[2]
set_location_assignment PIN_AU1 -to PCIE_RX_P[3]
set_location_assignment PIN_BA1 -to PCIE_RX_P[4]
set_location_assignment PIN_BE1 -to PCIE_RX_P[5]
set_location_assignment PIN_BJ1 -to PCIE_RX_P[6]
set_location_assignment PIN_BN1 -to PCIE_RX_P[7]
set_location_assignment PIN_BU1 -to PCIE_RX_P[8]
set_location_assignment PIN_CA1 -to PCIE_RX_P[9]
set_location_assignment PIN_CE1 -to PCIE_RX_P[10]
set_location_assignment PIN_CJ1 -to PCIE_RX_P[11]
set_location_assignment PIN_CN1 -to PCIE_RX_P[12]
set_location_assignment PIN_CP4 -to PCIE_RX_P[13]
set_location_assignment PIN_CU1 -to PCIE_RX_P[14]
set_location_assignment PIN_CV4 -to PCIE_RX_P[15]
set_location_assignment PIN_AG5 -to PCIE_RX_N[0]
set_location_assignment PIN_AH2 -to PCIE_RX_N[1]
set_location_assignment PIN_AM2 -to PCIE_RX_N[2]
set_location_assignment PIN_AT2 -to PCIE_RX_N[3]
set_location_assignment PIN_AY2 -to PCIE_RX_N[4]
set_location_assignment PIN_BD2 -to PCIE_RX_N[5]
set_location_assignment PIN_BH2 -to PCIE_RX_N[6]
set_location_assignment PIN_BM2 -to PCIE_RX_N[7]
set_location_assignment PIN_BT2 -to PCIE_RX_N[8]
set_location_assignment PIN_BY2 -to PCIE_RX_N[9]
set_location_assignment PIN_CD2 -to PCIE_RX_N[10]
set_location_assignment PIN_CH2 -to PCIE_RX_N[11]
set_location_assignment PIN_CM2 -to PCIE_RX_N[12]
set_location_assignment PIN_CR5 -to PCIE_RX_N[13]
set_location_assignment PIN_CT2 -to PCIE_RX_N[14]
set_location_assignment PIN_CW5 -to PCIE_RX_N[15]
set_location_assignment PIN_CG13 -to PCIE_RESET_N
set_location_assignment PIN_BU7 -to "PCIE_REFCLK0(n)"
set_location_assignment PIN_BR7 -to PCIE_REFCLK0
#set_location_assignment PIN_AD49 -to "PCIE_REFCLK1(n)"
#set_location_assignment PIN_AE48 -to PCIE_REFCLK1
set_location_assignment PIN_AK4 -to PCIE_TX_P[0]
set_location_assignment PIN_AN7 -to PCIE_TX_P[1]
set_location_assignment PIN_AP4 -to PCIE_TX_P[2]
set_location_assignment PIN_AU7 -to PCIE_TX_P[3]
set_location_assignment PIN_AV4 -to PCIE_TX_P[4]
set_location_assignment PIN_BA7 -to PCIE_TX_P[5]
set_location_assignment PIN_BB4 -to PCIE_TX_P[6]
set_location_assignment PIN_BF4 -to PCIE_TX_P[7]
set_location_assignment PIN_BK4 -to PCIE_TX_P[8]
set_location_assignment PIN_BP4 -to PCIE_TX_P[9]
set_location_assignment PIN_BV4 -to PCIE_TX_P[10]
set_location_assignment PIN_CB4 -to PCIE_TX_P[11]
set_location_assignment PIN_CF4 -to PCIE_TX_P[12]
set_location_assignment PIN_CK4 -to PCIE_TX_P[13]
set_location_assignment PIN_CN7 -to PCIE_TX_P[14]
set_location_assignment PIN_CU7 -to PCIE_TX_P[15]
set_location_assignment PIN_AL5 -to PCIE_TX_N[0]
set_location_assignment PIN_AM8 -to PCIE_TX_N[1]
set_location_assignment PIN_AR5 -to PCIE_TX_N[2]
set_location_assignment PIN_AT8 -to PCIE_TX_N[3]
set_location_assignment PIN_AW5 -to PCIE_TX_N[4]
set_location_assignment PIN_AY8 -to PCIE_TX_N[5]
set_location_assignment PIN_BC5 -to PCIE_TX_N[6]
set_location_assignment PIN_BG5 -to PCIE_TX_N[7]
set_location_assignment PIN_BL5 -to PCIE_TX_N[8]
set_location_assignment PIN_BR5 -to PCIE_TX_N[9]
set_location_assignment PIN_BW5 -to PCIE_TX_N[10]
set_location_assignment PIN_CC5 -to PCIE_TX_N[11]
set_location_assignment PIN_CG5 -to PCIE_TX_N[12]
set_location_assignment PIN_CL5 -to PCIE_TX_N[13]
set_location_assignment PIN_CM8 -to PCIE_TX_N[14]
set_location_assignment PIN_CT8 -to PCIE_TX_N[15]
set_location_assignment PIN_CY24 -to rzq_2c
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
set_location_assignment PIN_CL19 -to "SYS_REFCLK(n)"
set_location_assignment PIN_CK18 -to SYS_REFCLK
set_location_assignment PIN_F31 -to fm61_scl
set_location_assignment PIN_H31 -to fm61_sda
set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=156250000" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=TRUE" -to qsfp_ref_clk

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

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to hssi_if[*].rx_p -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to hssi_if[*].rx_p -entity top
#set_location_assignment PIN_A50 -to master_tod_top_0_pulse_per_second
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to hssi_if[*].tx_p -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to hssi_if[*].tx_p -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to hssi_if[*].tx_p -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to hssi_if[*].tx_p -entity top
#set_instance_assignment -name HSSI_PARAMETER "rx_invert_p_and_n=RX_INVERT_PN_EN" -to hssi_if[*].rx_p -entity top
