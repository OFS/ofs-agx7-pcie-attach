// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  This package defines the following interfaces/channels in CoreFIM
//     1. Platform-independent Ethernet data streams
//     2. Platform-independent Ethernet sideband streams
//
//  The interface is derived from platform-specific configuration in
//  ofs_fim_eth_plat_if_pkg.
//
//----------------------------------------------------------------------------

`include "ofs_fim_eth_plat_defines.svh"

package ofs_fim_eth_if_pkg;

localparam MAX_NUM_ETH_CHANNELS = ofs_fim_eth_plat_if_pkg::MAX_NUM_ETH_CHANNELS;
localparam NUM_ETH_CHANNELS     = ofs_fim_eth_plat_if_pkg::NUM_ETH_CHANNELS;
localparam NUM_LANES            = ofs_fim_eth_plat_if_pkg::NUM_LANES;
localparam NUM_QSFP_PORTS       = ofs_fim_eth_plat_if_pkg::NUM_QSFP_PORTS;
localparam NUM_QSFP_LANES       = ofs_fim_eth_plat_if_pkg::NUM_QSFP_LANES;

localparam ETH_PACKET_WIDTH = ofs_fim_eth_plat_if_pkg::ETH_PACKET_WIDTH;
localparam ETH_TKEEP_WIDTH = ETH_PACKET_WIDTH/8;

localparam ETH_RX_ERROR_WIDTH = ofs_fim_eth_plat_if_pkg::ETH_RX_ERROR_WIDTH;
localparam ETH_TX_ERROR_WIDTH = ofs_fim_eth_plat_if_pkg::ETH_TX_ERROR_WIDTH;

// Clocks exported by the MAC for use by the AFU. The primary "clk" is
// guaranteed. Others are platform-specific.
typedef ofs_fim_eth_plat_if_pkg::t_eth_clocks t_axis_eth_clocks;

typedef ofs_fim_eth_plat_if_pkg::t_axis_eth_rx_tuser t_axis_eth_rx_tuser;
typedef ofs_fim_eth_plat_if_pkg::t_axis_eth_tx_tuser t_axis_eth_tx_tuser;

typedef ofs_fim_eth_plat_if_pkg::t_axis_hssi_ss_rx_tuser t_axis_hssi_ss_rx_tuser;
typedef ofs_fim_eth_plat_if_pkg::t_axis_hssi_ss_tx_tuser t_axis_hssi_ss_tx_tuser;

// AXIS RX channel (MAC -> AFU)
typedef struct packed {
   logic                        tvalid;
   logic                        tlast;
   logic [ETH_PACKET_WIDTH-1:0] tdata;
   logic [ETH_TKEEP_WIDTH-1 :0] tkeep;
   t_axis_eth_rx_tuser          tuser;
} t_axis_eth_rx;
localparam AXIS_ETH_RX_WIDTH = $bits(t_axis_eth_rx);

// AXIS TX channel (AFU -> MAC)
typedef struct packed {
   logic                        tvalid;
   logic                        tlast;
   logic [ETH_PACKET_WIDTH-1:0] tdata;
   logic [ETH_TKEEP_WIDTH-1 :0] tkeep;
   t_axis_eth_tx_tuser          tuser;
} t_axis_eth_tx;
localparam AXIS_ETH_TX_WIDTH = $bits(t_axis_eth_tx);

// AXIS sideband RX channel (MAC -> AFU)
typedef ofs_fim_eth_plat_if_pkg::t_eth_sideband_from_mac t_eth_sideband_from_mac;
localparam ETH_SIDEBAND_RX_PACKET_WIDTH = $bits(t_eth_sideband_from_mac);

typedef struct packed {
   logic                   tvalid;
   t_eth_sideband_from_mac tdata;
} t_axis_eth_sideband_rx;

// AXIS sideband TX channel (AFU -> MAC)
typedef ofs_fim_eth_plat_if_pkg::t_eth_sideband_to_mac t_eth_sideband_to_mac;
localparam ETH_SIDEBAND_TX_PACKET_WIDTH = $bits(t_eth_sideband_to_mac);

typedef struct packed {
   logic                   tvalid;
   t_eth_sideband_to_mac   tdata;
} t_axis_eth_sideband_tx;


// AXIS RX channel (HSSI SS -> Client)
typedef struct packed {
   logic                        tvalid;
   logic                        tlast;
   logic [ETH_PACKET_WIDTH-1:0] tdata;
   logic [ETH_TKEEP_WIDTH-1 :0] tkeep;
   t_axis_hssi_ss_rx_tuser      tuser;
} t_axis_hssi_ss_rx;
localparam AXIS_HSSI_SS_RX_WIDTH = $bits(t_axis_hssi_ss_rx);

// AXIS TX channel (Client -> HSSI SS)
typedef struct packed {
   logic                        tvalid;
   logic                        tlast;
   logic [ETH_PACKET_WIDTH-1:0] tdata;
   logic [ETH_TKEEP_WIDTH-1 :0] tkeep;
   t_axis_hssi_ss_tx_tuser      tuser;
} t_axis_hssi_ss_tx;
localparam AXIS_HSSI_SS_TX_WIDTH = $bits(t_axis_hssi_ss_tx);

//----------------------------------------------
// Debugging functions
//----------------------------------------------

function automatic string func_axis_eth_rx_to_string (
   input t_axis_eth_rx rx
);
   return $sformatf("tlast %x tuser 0x%x tkeep 0x%x tdata 0x%x",
                    rx.tlast, rx.tuser, rx.tkeep, rx.tdata);
endfunction

function automatic string func_axis_eth_tx_to_string (
   input t_axis_eth_tx tx
);
   return $sformatf("tlast %x tuser 0x%x tkeep 0x%x tdata 0x%x",
                    tx.tlast, tx.tuser, tx.tkeep, tx.tdata);
endfunction

function automatic string func_axis_eth_sb_rx_to_string (
   input t_axis_eth_sideband_rx rx
);
   return $sformatf("tdata 0x%x", rx.tdata);
endfunction

function automatic string func_axis_eth_sb_tx_to_string (
   input t_axis_eth_sideband_tx tx
);
   return $sformatf("tdata 0x%x", tx.tdata);
endfunction

endpackage
