# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT


#-----------------------------------------------------------------------------
# Description
#-----------------------------------------------------------------------------
#
#   PMCI Controller SDC 
#
#-----------------------------------------------------------------------------
set PMCI_CLK sys_pll|iopll_0_clk_100m

#**************************************************************
# Egress SPI
#**************************************************************
create_clock -name spi_egress_sclk -period 40 -waveform {0.000 20} [get_ports {spi_egress_sclk}]

#set_input_delay  -max 10 -clock { spi_egress_sclk } [get_ports {spi_egress_csn}]
#set_input_delay  -min 0  -clock { spi_egress_sclk } [get_ports {spi_egress_csn}]
#set_input_delay  -max 10 -clock { spi_egress_sclk } [get_ports {spi_egress_mosi}]
#set_input_delay  -min 0  -clock { spi_egress_sclk } [get_ports {spi_egress_mosi}]
set_output_delay -max 5  -clock { spi_egress_sclk }  -clock_fall [get_ports {spi_egress_miso}]
set_output_delay -min 0  -clock { spi_egress_sclk }  -clock_fall [get_ports {spi_egress_miso}]

set_false_path -from [get_ports {spi_egress_csn}] -to [get_ports {spi_egress_miso}]

set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m} -group {spi_egress_sclk}

# Fix broken constraint for async path from spiphyslave.sdc
set_false_path -to [get_pins -no_case -compatibility_mode *SPIPhy_MISOctl\|rdshiftreg*\|*]

# Reset sync constraint for spi_csn->MISO st ready
set_false_path -to [get_pins -compatibility_mode *|SPIPhy_MISOctl|*stsinkready*|clrn]

# Lots of reset paths have broken timing because shifter logic running on SCLK uses async reset from PMCI_CLK
set_false_path -from $PMCI_CLK -to [get_pins -compatibility_mode *spi_slave|*the_SPIPhy|*clrn]

#**************************************************************
# Ingress SPI
#**************************************************************
create_generated_clock \
 -source [get_pins {pmci_wrapper|pmci_ss|spi_master|avmms_2_spim_bridge_0|spim_clk|clk}] \
 -divide_by 4 -multiply_by 1 -duty_cycle 50 -phase 0 -offset 0 \
 -name ingrs_spi_clk_int [get_pins {pmci_wrapper|pmci_ss|spi_master|avmms_2_spim_bridge_0|spim_clk|q}]

create_generated_clock \
 -source [get_pins {pmci_wrapper|pmci_ss|spi_master|avmms_2_spim_bridge_0|spim_clk|q}] \
 -name ingrs_spi_clk [get_ports {spi_ingress_sclk}]

set_multicycle_path 2 -setup -start -from $PMCI_CLK -to ingrs_spi_clk
set_multicycle_path 2 -setup -end -from ingrs_spi_clk -to $PMCI_CLK

set_multicycle_path 3 -hold -start -from $PMCI_CLK -to ingrs_spi_clk
set_multicycle_path 3 -hold -end -from ingrs_spi_clk -to $PMCI_CLK

set_output_delay -max 10 -clock [get_clocks ingrs_spi_clk] -clock_fall [get_ports {spi_ingress_csn}]
set_output_delay -min 0  -clock [get_clocks ingrs_spi_clk] -clock_fall [get_ports {spi_ingress_csn}]
set_output_delay -max 10 -clock [get_clocks ingrs_spi_clk] -clock_fall [get_ports {spi_ingress_mosi}]
set_output_delay -min 0  -clock [get_clocks ingrs_spi_clk] -clock_fall [get_ports {spi_ingress_mosi}]
set_input_delay  -max 5  -clock [get_clocks ingrs_spi_clk] [get_ports {spi_ingress_miso}]
set_input_delay  -min 0  -clock [get_clocks ingrs_spi_clk] [get_ports {spi_ingress_miso}]


#**************************************************************
# Flash QSPI
#**************************************************************
create_generated_clock \
 -source [get_pins {pmci_wrapper|pmci_ss|flash_ctrlr|intel_generic_serial_flash_interface_top_0|qspi_inf_inst|flash_clk_reg|clk}] \
 -divide_by 4 -multiply_by 1 -duty_cycle 50 -phase 0 -offset 0 \
 -name flash_qspi_clk_int [get_pins {pmci_wrapper|pmci_ss|flash_ctrlr|intel_generic_serial_flash_interface_top_0|qspi_inf_inst|flash_clk_reg|q}]

create_generated_clock \
 -source [get_pins {pmci_wrapper|pmci_ss|flash_ctrlr|intel_generic_serial_flash_interface_top_0|qspi_inf_inst|flash_clk_reg|q}] \
 -name flash_qspi_clk [get_ports {qspi_dclk}]

set_multicycle_path 2 -setup -start -from $PMCI_CLK -to flash_qspi_clk
set_multicycle_path 2 -setup -end -from flash_qspi_clk -to $PMCI_CLK

set_multicycle_path 3 -hold -start -from $PMCI_CLK -to flash_qspi_clk
set_multicycle_path 3 -hold -end -from flash_qspi_clk -to $PMCI_CLK

set_output_delay -max 10 -clock [get_clocks flash_qspi_clk] [get_ports {qspi_ncs}]
set_output_delay -min 0  -clock [get_clocks flash_qspi_clk] [get_ports {qspi_ncs}]
set_output_delay -max 10 -clock [get_clocks flash_qspi_clk] [get_ports {qspi_data[*]}]
set_output_delay -min 0  -clock [get_clocks flash_qspi_clk] [get_ports {qspi_data[*]}]
set_input_delay  -max 10 -clock [get_clocks flash_qspi_clk] -clock_fall [get_ports {qspi_data[*]}]
set_input_delay  -min 0  -clock [get_clocks flash_qspi_clk] -clock_fall [get_ports {qspi_data[*]}]
#**************************************************************
# Other Inputs/Outputs
#**************************************************************

#set_input_delay  -clock $PMCI_CLK -max 20 [get_ports {m10_gpio_fpga_usr_100m}]
#set_input_delay  -clock $PMCI_CLK -min  0 [get_ports {m10_gpio_fpga_usr_100m}]
set_input_delay  -clock $PMCI_CLK -max 20 -source_latency_included [get_ports {m10_gpio_fpga_m10_hb}]
set_input_delay  -clock $PMCI_CLK -min  0 -source_latency_included [get_ports {m10_gpio_fpga_m10_hb}]
set_input_delay  -clock $PMCI_CLK -max 20 -source_latency_included [get_ports {m10_gpio_m10_seu_error}]
set_input_delay  -clock $PMCI_CLK -min  0 -source_latency_included [get_ports {m10_gpio_m10_seu_error}]
#set_output_delay -clock $PMCI_CLK -max 20 -source_latency_included [get_ports {m10_gpio_fpga_therm_shdn}]
#set_output_delay -clock $PMCI_CLK -min 0 -source_latency_included [get_ports {m10_gpio_fpga_therm_shdn}]
