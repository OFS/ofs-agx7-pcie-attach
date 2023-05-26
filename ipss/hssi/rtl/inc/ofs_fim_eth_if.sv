// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// Platform-independent AXI streams between an Ethernet MAC and an AFU.
// TX is AFU to FIM, RX is FIM to AFU.
//
// All clocks can be assumed to be common, coming from the MAC.
//
//-----------------------------------------------------------------------------

`ifdef OFS_FIM_ASSERT_OFF
   `define OFS_FIM_AXIS_IF_ASSERT_OFF
`endif  // OFS_FIM_ASSERT_OFF

//----------------HE-HSSI related---------

// Interface of Eth RX AXIS channel (MAC -> AFU)
interface ofs_fim_eth_rx_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_if_pkg::*;

   // struct declaration contains tvalid, tlast, tdata, and tuser signals of the AXIS channel
   t_axis_eth_rx rx;

   // Ready signal
   logic tready;

   // AXI-S channel master (MAC side)
   modport master (
        input  tready,
        output clk,
        output rst_n,
        output rx
   );

   // AXI-S channel slave
   modport slave (
        output tready,
        input  clk,
        input  rst_n,
        input  rx
   );

`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synthesis translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2)
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);

      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(rx.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tvalid is undefined", $time));

   assert_tready_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tready)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tready is undefined", $time));

   assert_payload_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (rx.tvalid) |-> (!$isunknown(rx)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx contains undefined bits when tvalid is asserted", $time));
// synthesis translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF

endinterface : ofs_fim_eth_rx_axis_if


// Interface of Eth TX AXIS channel (AFU -> MAC)
interface ofs_fim_eth_tx_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_if_pkg::*;

   // struct declaration contains tvalid, tlast, tdata, and tuser signals of the AXIS channel
   t_axis_eth_tx tx;

   // Ready signal
   logic tready;

   // AXI-S channel master
   modport master (
        input  tready,
        input  clk,
        input  rst_n,
        output tx
   );

   // AXI-S channel slave (MAC side)
   modport slave (
        output tready,
        output clk,
        output rst_n,
        input  tx
   );

`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synthesis translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2)
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);

      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tx.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tvalid is undefined", $time));

   assert_tready_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tready)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tready is undefined", $time));

   assert_payload_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (tx.tvalid) |-> (!$isunknown(tx)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx contains undefined bits when tvalid is asserted", $time));
// synthesis translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF

endinterface : ofs_fim_eth_tx_axis_if


//
// RX Interface of Eth sideband AXIS channel (MAC -> AFU).
//
// There is no tready flow control on this interface. The payload may be
// time-sensitive.
//
interface ofs_fim_eth_sideband_rx_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_if_pkg::*;

   // struct declaration contains tvalid, tdata, signals of the AXIS channel
   t_axis_eth_sideband_rx sb;

   // AXI-S channel master (MAC side)
   modport master (
        output clk,
        output rst_n,
        output sb
   );

   // AXI-S channel slave
   modport slave (
        input  clk,
        input  rst_n,
        input  sb
   );

`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synthesis translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2)
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);

      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(sb.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tvalid is undefined", $time));

   assert_payload_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (sb.tvalid) |-> (!$isunknown(sb)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, sb contains undefined bits when tvalid is asserted", $time));
// synthesis translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF

endinterface : ofs_fim_eth_sideband_rx_axis_if


//
// Tx Interface of Eth sideband AXIS channel (AFU -> MAC)
//
// There is no tready flow control on this interface. The payload may be
// time-sensitive.
//
interface ofs_fim_eth_sideband_tx_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_if_pkg::*;

   // struct declaration contains tvalid, tdata, signals of the AXIS channel
   t_axis_eth_sideband_tx sb;

   // AXI-S channel master
   modport master (
        input  clk,
        input  rst_n,
        output sb
   );

   // AXI-S channel slave (MAC side)
   modport slave (
        output clk,
        output rst_n,
        input  sb
   );

`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synthesis translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2)
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);

      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(sb.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tvalid is undefined", $time));

   assert_payload_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (sb.tvalid) |-> (!$isunknown(sb)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, sb contains undefined bits when tvalid is asserted", $time));
// synthesis translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF

endinterface : ofs_fim_eth_sideband_tx_axis_if

//----------------HSSI SS related---------

// Interface of HSSI SS RX AXIS channel (HSSI SS -> HE-HSSI)
interface ofs_fim_hssi_ss_rx_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_if_pkg::*;

   // struct declaration contains tvalid, tlast, tdata, and tuser signals of the AXIS channel
   t_axis_hssi_ss_rx rx;

   // AXI-S channel SS side
   modport mac (
        output clk,
        output rst_n,
        output rx
   );

   // AXI-S channel HE side
   modport client (
        input  clk,
        input  rst_n,
        input  rx
   );

`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synthesis translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2)
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);

      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(rx.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tvalid is undefined", $time));

   assert_payload_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (rx.tvalid) |-> (!$isunknown(rx)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx contains undefined bits when tvalid is asserted", $time));
// synthesis translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF

endinterface : ofs_fim_hssi_ss_rx_axis_if


// Interface of HSSI SS TX AXIS channel (HE-HSSI-> HSSI SS)
interface ofs_fim_hssi_ss_tx_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   import ofs_fim_eth_if_pkg::*;

   // struct declaration contains tvalid, tlast, tdata, and tuser signals of the AXIS channel
   t_axis_hssi_ss_tx tx;

   // Ready signal
   logic tready;

   // AXI-S channel HE side
   modport client (
        input  tready,
        input  clk,
        input  rst_n,
        output tx
   );

   // AXI-S channel SS side
   modport mac (
        output tready,
        output clk,
        output rst_n,
        input  tx
   );

`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synthesis translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2)
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);

      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tx.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tvalid is undefined", $time));

   assert_tready_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tready)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tready is undefined", $time));

   assert_payload_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (tx.tvalid) |-> (!$isunknown(tx)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx contains undefined bits when tvalid is asserted", $time));
// synthesis translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF

endinterface : ofs_fim_hssi_ss_tx_axis_if

// Serial interface for HSSI SS
interface  ofs_fim_hssi_serial_if #(
 parameter NUM_LANES = ofs_fim_eth_plat_if_pkg::NUM_QSFP_LANES
);
   logic [NUM_LANES-1:0] tx_p;
   // logic [NUM_LANES-1:0] tx_n;
   logic [NUM_LANES-1:0] rx_p;
   // logic [NUM_LANES-1:0] rx_n;
   
    // AXI-S channel master
   modport qsfp (
        output  tx_p,
        // output  tx_n,
        input   rx_p
        // input   rx_n
   );
endinterface : ofs_fim_hssi_serial_if

// Flow Control interface for HSSI SS
interface  ofs_fim_hssi_fc_if ();
   logic       tx_pause;
   logic [7:0] tx_pfc;
   logic       rx_pause;
   logic [7:0] rx_pfc;
   
    // Connected to HSSI SS/MAC
   modport mac (
        input   tx_pause,
        input   tx_pfc,
        output  rx_pause,
        output  rx_pfc
   );
    // Connected AFU/Client
   modport client (
        output tx_pause,
        output tx_pfc,
        input  rx_pause,
        input  rx_pfc
   );
endinterface : ofs_fim_hssi_fc_if

//----------------PTP & TOD related---------

// TOD interface for HSSI SS
interface  ofs_fim_hssi_ptp_tx_tod_if ();
   logic        tvalid;
   logic [95:0] tdata;
   
    // Connected to HSSI SS/MAC
   modport mac (
        input   tvalid,
        input   tdata
   );
    // Connected AFU/Client 
   modport client (
        output tvalid,
        output tdata
   );
endinterface : ofs_fim_hssi_ptp_tx_tod_if

interface  ofs_fim_hssi_ptp_rx_tod_if ();
   logic        tvalid;
   logic [95:0] tdata;
   
    // Connected to HSSI SS/MAC 
   modport mac (
        input   tvalid,
        input   tdata
   );
    // Connected AFU/Client 
   modport client (
        output tvalid,
        output tdata
   );
endinterface : ofs_fim_hssi_ptp_rx_tod_if

// TS interface for HSSI SS
interface  ofs_fim_hssi_ptp_tx_egrts_if ();
   logic        tvalid;
   logic [103:0] tdata;
   
    // Connected to HSSI SS/MAC 
   modport mac (
        output   tvalid,
        output   tdata
   );
    // Connected AFU/Client 
   modport client (
        input tvalid,
        input tdata
   );
endinterface : ofs_fim_hssi_ptp_tx_egrts_if

interface  ofs_fim_hssi_ptp_rx_ingrts_if ();
   logic        tvalid;
   logic [95:0] tdata;
   
    // Connected to HSSI SS/MAC 
   modport mac (
        output   tvalid,
        output   tdata
   );
    // Connected AFU/Client
   modport client (
        input tvalid,
        input tdata
   );
endinterface : ofs_fim_hssi_ptp_rx_ingrts_if
