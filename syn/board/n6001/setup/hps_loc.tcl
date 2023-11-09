# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Memory pin and location assignments
#
#-----------------------------------------------------------------------------

set_location_assignment PIN_AG6  -to hps_uart_tx
set_location_assignment PIN_AB1  -to hps_uart_rx
set_location_assignment PIN_V1   -to b_fpga_hps_zl_ho
set_location_assignment PIN_AA4  -to b_ptp_clk_lol
set_location_assignment PIN_AD11 -to fpga_hps_clkin
set_location_assignment PIN_AC12 -to b_zl_spi_sck
set_location_assignment PIN_H3   -to b_zl_spi_si
set_location_assignment PIN_AD13 -to b_zl_spi_so
set_location_assignment PIN_F3   -to b_zl_spi_cs

# ------------------------------------------------
