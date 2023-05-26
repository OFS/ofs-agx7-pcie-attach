// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
// AFU module instantiates User Logic
//-----------------------------------------------------------------------------

module  afu_host_channel 
   import pcie_ss_axis_pkg::*;
(
   input logic              clk,
   input logic              rst_n,
   pcie_ss_axis_if.source   mx2ho_tx_port,
   pcie_ss_axis_if.source   ho2mx_rx_remap,
   pcie_ss_axis_if.sink     ho2mx_rx_port,

   pcie_ss_axis_if.sink     ho2mx_rxreq_port,
   pcie_ss_axis_if.source   arb2mx_rxreq_port,

   pcie_ss_axis_if.sink     mx2ho_tx_remap [1:0],
   input  t_pcie_tag_mode   tag_mode
);

localparam PCIE_TDATA_WIDTH  = ofs_fim_cfg_pkg::PCIE_TDATA_WIDTH;
localparam PCIE_TUSER_WIDTH  = ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH;

// A/B arbiter to local commit generator
pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) arb2ho_tx_port(.clk(clk), .rst_n(rst_n));

pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) arb2mx_rx_if(.clk(clk), .rst_n(rst_n));

// Host side of both A and B PF/VF TX MUXes
pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) mx2ho_tx_ab[2](.clk(clk), .rst_n(rst_n));

// join write commit and rxreq ports in an interface array to pass to rx arb
pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) rxreq_arb[2] (.clk(clk), .rst_n(rst_n));

//
// There are two independent TX PF/VF MUX trees, labeled "A" and "B".
// Both an A and a B port are passed to each AFU. AFUs can either send
// all requests to the primary A port or partition requests across
// both A and B ports. A typical high-performance AFU will send
// read requests to the B port and everything else to the A port,
// giving the arbiter here freedom to keep both the host TX and RX
// channels busy.
//
// Here, the A and B TX trees have been multiplexed down to a single
// channel for A and another for B. The A/B multiplexer merges them
// into a single TX stream that will be passed to the tag remapper.
//
pcie_ss_axis_mux #(
   .NUM_CH ( 2 )
) mx2ho_tx_ab_mux (
   .clk    ( clk           ),
   .rst_n  ( rst_n         ),

   .sink   ( mx2ho_tx_ab   ),
   .source ( arb2ho_tx_port)
);

// Generate local commits for writes that have passed A/B MUX
// arbitration. This way AFUs can know when writes on A and reads
// on B have been committed to a fixed order.
pcie_arb_local_commit local_commit
(
   .clk    ( clk           ),
   .rst_n  ( rst_n         ),
   .sink   ( arb2ho_tx_port),
   .source ( mx2ho_tx_port ),
   .commit ( arb2mx_rx_if )
);


// For the PCIe subsystem with completion reordering, RX traffic 
// is split into two TLP streams. DM CPLs are on the rx interface
//  and VDM & MMIO requests are on rxreq. Since there are also two 
// independent RX MUX trees the FIM maps the rx streams as follows:
//    Mux "A": rxreq stream + local commits
//    Mux "B": DM completions with remapped tags

always_comb begin
   rxreq_arb[0].tvalid       = ho2mx_rxreq_port.tvalid;
   rxreq_arb[0].tdata        = ho2mx_rxreq_port.tdata;
   rxreq_arb[0].tlast        = ho2mx_rxreq_port.tlast;
   rxreq_arb[0].tkeep        = ho2mx_rxreq_port.tkeep;
   rxreq_arb[0].tuser_vendor = ho2mx_rxreq_port.tuser_vendor;
   
   rxreq_arb[1].tvalid       = arb2mx_rx_if.tvalid;
   rxreq_arb[1].tdata        = arb2mx_rx_if.tdata;
   rxreq_arb[1].tlast        = arb2mx_rx_if.tlast;
   rxreq_arb[1].tkeep        = arb2mx_rx_if.tkeep;
   rxreq_arb[1].tuser_vendor = arb2mx_rx_if.tuser_vendor;

   ho2mx_rxreq_port.tready   = rxreq_arb[0].tready;
   arb2mx_rx_if.tready       = rxreq_arb[1].tready;
end

pcie_ss_axis_mux #(
   .NUM_CH ( 2 )
) ho2mx_rxreq_mux (
   .clk    ( clk           ),
   .rst_n  ( rst_n         ),
   .sink   ( rxreq_arb     ),
   .source ( arb2mx_rxreq_port)
);

//----------------------------------------------------------------
// Tag remap module
//----------------------------------------------------------------

// Tag remap is needed because outstanding requests can not have
// same tag as per pcie spec. Subsystem does not handle this situation
// by itself. It is responsibility of application to have unique tags

tag_remap_multi_tx #(
   .REMAP            (  1  ),              // Enable/Disable Tag Remap function
   .N_TX_PORTS       (  2  )               // Map both A and B ports
) tag_remap (
   .clk               ( clk             ),
   .rst_n             ( rst_n           ),
   .ho2mx_rx_port     ( ho2mx_rx_port   ), // axis interface from host (PCIE)
   .mx2ho_tx_port     ( mx2ho_tx_ab     ), // axis interface to host (PCIE)
   .ho2mx_rx_remap    ( ho2mx_rx_remap  ), // axis interface to pf_vf_mux
   .mx2ho_tx_remap    ( mx2ho_tx_remap  ), // axis interface from pf_vf_mux
   .tag_mode          ( tag_mode        ) // Number of PCIe SS tags (dynamic)
);

endmodule
