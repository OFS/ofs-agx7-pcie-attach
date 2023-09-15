// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  AVST equivalent of the AXI-S Ethernet interface data structures. Types
//  are derived from the AXI-S configuration.
//
//----------------------------------------------------------------------------

package ofs_fim_eth_avst_if_pkg;

localparam MAX_NUM_AVST_ETH_CHANNELS = ofs_fim_eth_plat_if_pkg::MAX_NUM_ETH_CHANNELS;
localparam NUM_AVST_ETH_CHANNELS     = ofs_fim_eth_plat_if_pkg::NUM_ETH_CHANNELS;

localparam AVST_ETH_PACKET_WIDTH = ofs_fim_eth_plat_if_pkg::ETH_PACKET_WIDTH;
// Unlike AXI-S "tkeep", which is a mask, "empty" is a count of the number
// of unused bytes at the end of "data".
localparam AVST_ETH_EMPTY_WIDTH = $clog2(AVST_ETH_PACKET_WIDTH/8);

localparam AVST_ETH_RX_ERROR_WIDTH = ofs_fim_eth_plat_if_pkg::ETH_RX_ERROR_WIDTH;
localparam AVST_ETH_TX_ERROR_WIDTH = ofs_fim_eth_plat_if_pkg::ETH_TX_ERROR_WIDTH;

// Clocks exported by the MAC for use by the AFU. The primary "clk" is
// guaranteed. Others are platform-specific.
typedef ofs_fim_eth_plat_if_pkg::t_eth_clocks t_avst_eth_clocks;

typedef ofs_fim_eth_plat_if_pkg::t_axis_eth_rx_tuser t_avst_eth_rx_user;
typedef ofs_fim_eth_plat_if_pkg::t_axis_eth_tx_tuser t_avst_eth_tx_user;

// AVST RX channel (MAC -> AFU)
typedef struct packed {
   logic                             valid;
   logic                             sop;
   logic                             eop;
   logic [AVST_ETH_PACKET_WIDTH-1:0] data;
   logic [AVST_ETH_EMPTY_WIDTH-1:0]  empty;
   t_avst_eth_rx_user                user;
} t_avst_eth_rx;
localparam AVST_ETH_RX_WIDTH = $bits(t_avst_eth_rx);

// AVST TX channel (AFU -> MAC)
typedef struct packed {
   logic                             valid;
   logic                             sop;
   logic                             eop;
   logic [AVST_ETH_PACKET_WIDTH-1:0] data;
   logic [AVST_ETH_EMPTY_WIDTH-1:0]  empty;
   t_avst_eth_tx_user                user;
} t_avst_eth_tx;
localparam AVST_ETH_TX_WIDTH = $bits(t_avst_eth_tx);

// AVST sideband RX channel (MAC -> AFU)
typedef ofs_fim_eth_plat_if_pkg::t_eth_sideband_from_mac t_eth_sideband_from_mac;
localparam AVST_ETH_SIDEBAND_RX_PACKET_WIDTH = $bits(t_eth_sideband_from_mac);

typedef struct packed {
   logic                   valid;
   t_eth_sideband_from_mac data;
} t_avst_eth_sideband_rx;

// AVST sideband TX channel (AFU -> MAC)
typedef ofs_fim_eth_plat_if_pkg::t_eth_sideband_to_mac t_eth_sideband_to_mac;
localparam AVST_ETH_SIDEBAND_TX_PACKET_WIDTH = $bits(t_eth_sideband_to_mac);

typedef struct packed {
   logic                   valid;
   t_eth_sideband_to_mac   data;
} t_avst_eth_sideband_tx;


// Convert an AXI-S data payload to an AVST payload. The two use opposite byte
// order.
function automatic logic [AVST_ETH_PACKET_WIDTH-1:0] eth_axi_to_avst_data(logic [AVST_ETH_PACKET_WIDTH-1:0] i_data);
   logic [AVST_ETH_PACKET_WIDTH-1:0] o_data;

   for (int b = 0; b < AVST_ETH_PACKET_WIDTH/8; b = b + 1) begin
      o_data[8 * (AVST_ETH_PACKET_WIDTH/8 - 1 - b) +: 8] = i_data[8 * b +: 8];
   end

   return o_data;
endfunction

// Convert an AVST data payload to an AXI-S payload.
function automatic logic [AVST_ETH_PACKET_WIDTH-1:0] eth_avst_to_axi_data(logic [AVST_ETH_PACKET_WIDTH-1:0] i_data);
   // Reversing is the same operation in both directions
   return eth_axi_to_avst_data(i_data);
endfunction


// Convert an AXI-S tkeep mask to an AVST empty. Empty is the count of unused
// bytes at the end of data. Tkeep is a byte mask. The MAC uses the empty encoding,
// so only the highest group of 0's in tkeep can act as a mask.
function automatic logic [AVST_ETH_EMPTY_WIDTH-1:0] eth_tkeep_to_empty(logic [ofs_fim_eth_if_pkg::ETH_TKEEP_WIDTH-1:0] tkeep);
   logic [AVST_ETH_EMPTY_WIDTH-1:0] num_empty = 0;

   for (int b = ofs_fim_eth_if_pkg::ETH_TKEEP_WIDTH-1; b >= 0; b = b - 1) begin
      if (tkeep[b]) break;
      num_empty = num_empty + 1;
   end

   return num_empty;
endfunction // eth_tkeep_to_empty

// Reverse of eth_tkeep_to_empty above
function automatic logic [ofs_fim_eth_if_pkg::ETH_TKEEP_WIDTH-1:0] eth_empty_to_tkeep(logic [AVST_ETH_EMPTY_WIDTH-1:0] empty);
   return {ofs_fim_eth_if_pkg::ETH_TKEEP_WIDTH{1'b1}} >> empty;
endfunction // eth_tkeep_to_empty

endpackage
