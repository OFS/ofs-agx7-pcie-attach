// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  Derived defines for HSSI SS
//
//----------------------------------------------------------------------------

`ifndef ofs_fim_eth_plat_defines
`define ofs_fim_eth_plat_defines

   `ifdef ETH_100G
		`define INCLUDE_HSSI_PORT_0
		`define INCLUDE_HSSI_PORT_4
   `elsif ETH_10G
         `define INCLUDE_HSSI_PORT_0
         `define INCLUDE_HSSI_PORT_1
         `define INCLUDE_HSSI_PORT_2
         `define INCLUDE_HSSI_PORT_3
         `define INCLUDE_HSSI_PORT_4
         `define INCLUDE_HSSI_PORT_5
         `define INCLUDE_HSSI_PORT_6
         `define INCLUDE_HSSI_PORT_7
   `else // 25G as default
      `ifndef ETH_25G
      `define ETH_25G
      `endif
		`define INCLUDE_HSSI_PORT_0
		`define INCLUDE_HSSI_PORT_1
		`define INCLUDE_HSSI_PORT_2
		`define INCLUDE_HSSI_PORT_3
		`define INCLUDE_HSSI_PORT_4
		`define INCLUDE_HSSI_PORT_5
		`define INCLUDE_HSSI_PORT_6
		`define INCLUDE_HSSI_PORT_7
   `endif
`endif
