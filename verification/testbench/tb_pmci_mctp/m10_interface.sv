// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef M10_INTERFACE
`define M10_INTERFACE


interface m10_interface ( output wire clk,output wire reset);

  bit      ingr_spi_clk ;
  bit      ingr_spi_csn ;
  tri0     ingr_spi_miso;
  bit      ingr_spi_mosi;
  bit      egrs_spi_clk ;
  bit      egrs_spi_csn ;
  tri0     egrs_spi_miso;
  bit      egrs_spi_mosi;

endinterface

`endif
