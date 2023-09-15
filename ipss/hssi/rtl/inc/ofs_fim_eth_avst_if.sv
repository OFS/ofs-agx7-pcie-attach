// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// Avalon stream wrappers around the same payloads as the Ethernet AXI
// streams in ofs_fim_eth_if.sv. While AXI-S is used as the transport
// from the MAC to the AFU across the PR boundary, AFUs may be written
// using Avalon interfaces. The Platform Interface Manager provides a shim
// for mapping between the two protocols.
//
//-----------------------------------------------------------------------------

// Interface of Eth RX AVST channel (MAC -> AFU)
interface ofs_fim_eth_rx_avst_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_avst_if_pkg::*;

   t_avst_eth_rx rx;

   // Ready signal
   logic ready;

   // AVST channel master (MAC side)
   modport master (
        input  ready,
        output clk,
        output rst_n,
        output rx
   );

   // AVST channel slave
   modport slave (
        output ready,
        input  clk,
        input  rst_n,
        input  rx
   );

endinterface : ofs_fim_eth_rx_avst_if


// Interface of Eth TX AVST channel (MAC -> AFU)
interface ofs_fim_eth_tx_avst_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_avst_if_pkg::*;

   t_avst_eth_tx tx;

   // Ready signal
   logic ready;

   // AVST channel master (MAC side)
   modport master (
        input  ready,
        input  clk,
        input  rst_n,
        output tx
   );

   // AVST channel slave
   modport slave (
        output ready,
        output clk,
        output rst_n,
        input  tx
   );

endinterface : ofs_fim_eth_tx_avst_if


//
// RX Interface of Eth sideband AVST channel (MAC -> AFU).
//
// There is no tready flow control on this interface. The payload may be
// time-sensitive.
//
interface ofs_fim_eth_sideband_rx_avst_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_avst_if_pkg::*;

   t_avst_eth_sideband_rx sb;

   // AVST channel master (MAC side)
   modport master (
        output clk,
        output rst_n,
        output sb
   );

   // AVST channel slave
   modport slave (
        input  clk,
        input  rst_n,
        input  sb
   );

endinterface : ofs_fim_eth_sideband_rx_avst_if


//
// Tx Interface of Eth sideband AVST channel (AFU -> MAC)
//
// There is no tready flow control on this interface. The payload may be
// time-sensitive.
//
interface ofs_fim_eth_sideband_tx_avst_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_avst_if_pkg::*;

   t_avst_eth_sideband_tx sb;

   // AVST channel master
   modport master (
        input  clk,
        input  rst_n,
        output sb
   );

   // AVST channel slave (MAC side)
   modport slave (
        output clk,
        output rst_n,
        input  sb
   );

endinterface : ofs_fim_eth_sideband_tx_avst_if
