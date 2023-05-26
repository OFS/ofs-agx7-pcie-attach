// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  This package defines platform-specific parameters and types for
//  AXI-S interfaces to an Ethernet MAC. It is consumed by a platform-
//  independent wrapper, ofs_fim_eth_if_pkg.sv.
//
//----------------------------------------------------------------------------

`include "ofs_fim_eth_plat_defines.svh"

package ofs_fim_eth_plat_if_pkg;


localparam MAX_NUM_ETH_CHANNELS = 16; // Ethernet Ports
localparam NUM_QSFP_PORTS       = 2; // QSFP cage on board
`ifdef ETH_100G
   localparam NUM_ETH_CHANNELS     = 2; // Ethernet Ports
   localparam NUM_QSFP_LANES       = 4; // Lanes/QSFP
   localparam NUM_LANES            = 4; // XCVR Lanes/Port
   localparam ETH_PACKET_WIDTH     = 512;
`elsif ETH_10G
   localparam NUM_ETH_CHANNELS     = 8;  // Ethernet Ports
   localparam NUM_QSFP_LANES       = 4; // Lanes/QSFP
   localparam NUM_LANES            = 1; // XCVR Lanes/Port
   localparam ETH_PACKET_WIDTH     = 64;
`else // 25G as default
   localparam NUM_ETH_CHANNELS     = 8; // Ethernet Ports
   localparam NUM_QSFP_LANES       = 4; // Lanes/QSFP
   localparam NUM_LANES            = 1; // XCVR Lanes/Port
   localparam ETH_PACKET_WIDTH     = 64;
`endif

localparam ETH_RX_ERROR_WIDTH = 6;
localparam ETH_TX_ERROR_WIDTH = 1;

localparam ETH_RX_USER_CLIENT_WIDTH       = 7;
localparam ETH_RX_USER_STS_WIDTH          = 5;
localparam ETH_TX_USER_CLIENT_WIDTH       = 2;
localparam ETH_TX_USER_PTP_WIDTH          = 94;
localparam ETH_TX_USER_PTP_EXTENDED_WIDTH = 328;

//----------------HE-HSSI related---------
typedef struct packed {
   // Error
   logic [ETH_RX_ERROR_WIDTH-1:0] error;
} t_axis_eth_rx_tuser;

typedef struct packed {
   // Error
   logic [ETH_TX_ERROR_WIDTH-1:0] error;
} t_axis_eth_tx_tuser;

typedef struct packed {
   // Mapped to MAC's avalon_st_pause_data[1]
   logic pause_xoff;
   // Mapped to MAC's avalon_st_pause_data[0]
   logic pause_xon;
   logic [7:0] pfc_xoff;
} t_eth_sideband_to_mac;

// Not currently used
typedef struct packed {
   logic pfc_pause;
} t_eth_sideband_from_mac;

//----------------HSSI SS related---------

// SS user bits
typedef struct packed {
   logic [ETH_RX_USER_STS_WIDTH-1:0]    sts;
   logic [ETH_RX_USER_CLIENT_WIDTH-1:0] client;
} t_axis_hssi_ss_rx_tuser;

typedef struct packed {
`ifdef INCLUDE_PTP
   logic [ETH_TX_USER_PTP_EXTENDED_WIDTH-1:0] ptp_extended;
   logic [ETH_TX_USER_PTP_WIDTH-1:0]          ptp;
`endif
   logic [ETH_TX_USER_CLIENT_WIDTH-1:0]       client;
} t_axis_hssi_ss_tx_tuser;


// Clocks exported by the MAC for use by the AFU. The primary "clk" is
// guaranteed. Others are platform-specific.
typedef struct packed {
   logic clk;
   logic rst_n;

   logic clkDiv2;
   logic rstDiv2_n;
} t_eth_clocks;

endpackage
