# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# PMCI pin and location assignments
#
#-----------------------------------------------------------------------------
set_location_assignment PIN_DC20 -to qspi_dclk
set_location_assignment PIN_CT17 -to qspi_ncs
set_location_assignment PIN_CY21 -to qspi_data[0]
set_location_assignment PIN_CT19 -to qspi_data[1]
set_location_assignment PIN_CU22 -to qspi_data[2]
set_location_assignment PIN_CR22 -to qspi_data[3]
set_location_assignment PIN_DA20 -to spi_ingress_sclk
set_location_assignment PIN_CY17 -to spi_ingress_csn
set_location_assignment PIN_CY19 -to spi_ingress_miso
set_location_assignment PIN_DB19 -to spi_ingress_mosi
set_location_assignment PIN_DA18 -to spi_egress_mosi
set_location_assignment PIN_DC18 -to spi_egress_csn
set_location_assignment PIN_CR24 -to spi_egress_sclk
set_location_assignment PIN_DB17 -to spi_egress_miso
set_location_assignment PIN_CU24 -to m10_gpio_fpga_usr_100m
set_location_assignment PIN_CT21 -to m10_gpio_fpga_m10_hb
set_location_assignment PIN_C30  -to m10_gpio_m10_seu_error
set_location_assignment PIN_J24  -to m10_gpio_fpga_therm_shdn
set_location_assignment PIN_B19  -to m10_gpio_fpga_seu_error
set_location_assignment PIN_G28  -to ncsi_rbt_ncsi_clk
set_location_assignment PIN_G30  -to ncsi_rbt_ncsi_txd[0]
set_location_assignment PIN_P31  -to ncsi_rbt_ncsi_txd[1]
set_location_assignment PIN_M31  -to ncsi_rbt_ncsi_tx_en
set_location_assignment PIN_H29  -to ncsi_rbt_ncsi_rxd[0]
set_location_assignment PIN_J30  -to ncsi_rbt_ncsi_rxd[1]
set_location_assignment PIN_L30  -to ncsi_rbt_ncsi_crs_dv 
set_location_assignment PIN_N30  -to ncsi_rbt_ncsi_arb_in 
set_location_assignment PIN_F29  -to ncsi_rbt_ncsi_arb_out
set_instance_assignment -name IO_STANDARD "1.2 V" -to qspi_ncs
set_instance_assignment -name IO_STANDARD "1.2 V" -to qspi_data
set_instance_assignment -name IO_STANDARD "1.2 V" -to qspi_dclk
set_instance_assignment -name IO_STANDARD "1.2 V" -to spi_ingress_sclk
set_instance_assignment -name IO_STANDARD "1.2 V" -to spi_ingress_csn
set_instance_assignment -name IO_STANDARD "1.2 V" -to spi_ingress_miso
set_instance_assignment -name IO_STANDARD "1.2 V" -to spi_ingress_mosi
set_instance_assignment -name IO_STANDARD "1.2 V" -to spi_egress_mosi
set_instance_assignment -name IO_STANDARD "1.2 V" -to spi_egress_csn
set_instance_assignment -name IO_STANDARD "1.2 V" -to spi_egress_sclk
set_instance_assignment -name IO_STANDARD "1.2 V" -to spi_egress_miso
set_instance_assignment -name IO_STANDARD "1.2 V" -to m10_gpio_fpga_usr_100m
set_instance_assignment -name IO_STANDARD "1.2 V" -to m10_gpio_fpga_m10_hb
set_instance_assignment -name IO_STANDARD "1.2 V" -to m10_gpio_m10_seu_error
set_instance_assignment -name IO_STANDARD "1.2 V" -to m10_gpio_fpga_seu_error
set_instance_assignment -name IO_STANDARD "1.2 V" -to m10_gpio_fpga_therm_shdn
set_instance_assignment -name IO_STANDARD "1.2 V" -to ncsi_rbt_ncsi_clk
set_instance_assignment -name IO_STANDARD "1.2 V" -to ncsi_rbt_ncsi_txd
set_instance_assignment -name IO_STANDARD "1.2 V" -to ncsi_rbt_ncsi_tx_en
set_instance_assignment -name IO_STANDARD "1.2 V" -to ncsi_rbt_ncsi_rxd
set_instance_assignment -name IO_STANDARD "1.2 V" -to ncsi_rbt_ncsi_crs_dv
set_instance_assignment -name IO_STANDARD "1.2 V" -to ncsi_rbt_ncsi_arb_in
set_instance_assignment -name IO_STANDARD "1.2 V" -to ncsi_rbt_ncsi_arb_out
set_instance_assignment -name SLEW_RATE 0 -to qspi_ncs
set_instance_assignment -name SLEW_RATE 0 -to qspi_data
set_instance_assignment -name SLEW_RATE 0 -to qspi_dclk
set_instance_assignment -name SLEW_RATE 0 -to spi_ingress_sclk
set_instance_assignment -name SLEW_RATE 0 -to spi_ingress_csn
set_instance_assignment -name SLEW_RATE 0 -to spi_ingress_miso
set_instance_assignment -name SLEW_RATE 0 -to spi_ingress_mosi
set_instance_assignment -name SLEW_RATE 0 -to spi_egress_mosi
set_instance_assignment -name SLEW_RATE 0 -to spi_egress_csn
set_instance_assignment -name SLEW_RATE 0 -to spi_egress_sclk
set_instance_assignment -name SLEW_RATE 0 -to spi_egress_miso
set_instance_assignment -name SLEW_RATE 0 -to m10_gpio_fpga_seu_error
set_instance_assignment -name SLEW_RATE 0 -to m10_gpio_fpga_therm_shdn
set_instance_assignment -name SLEW_RATE 0 -to ncsi_rbt_ncsi_clk
set_instance_assignment -name SLEW_RATE 0 -to ncsi_rbt_ncsi_txd
set_instance_assignment -name SLEW_RATE 0 -to ncsi_rbt_ncsi_tx_en
set_instance_assignment -name SLEW_RATE 0 -to ncsi_rbt_ncsi_rxd
set_instance_assignment -name SLEW_RATE 0 -to ncsi_rbt_ncsi_crs_dv
set_instance_assignment -name SLEW_RATE 0 -to ncsi_rbt_ncsi_arb_in
set_instance_assignment -name SLEW_RATE 0 -to ncsi_rbt_ncsi_arb_out
