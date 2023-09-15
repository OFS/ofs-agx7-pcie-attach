// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
// Transformations on the AFU PCIe interface
//-----------------------------------------------------------------------------

module afu_host_channel 
(
   input logic              clk,
   input logic              rst_n,
   pcie_ss_axis_if.source   mx2ho_tx_port,
   pcie_ss_axis_if.source   mx2ho_txreq_port,

   pcie_ss_axis_if.source   ho2mx_rx_remap,
   pcie_ss_axis_if.sink     ho2mx_rx_port,

   pcie_ss_axis_if.sink     ho2mx_rxreq_port,
   pcie_ss_axis_if.source   ho2mx_rxreq_remap,

   pcie_ss_axis_if.sink     mx2ho_tx_remap [1:0],
   input pcie_ss_axis_pkg::t_pcie_tag_mode tag_mode
);

//
// There is no transformation on the RXREQ port. Route the incoming
// port directly to the output port.
//
always_comb begin
   ho2mx_rxreq_remap.tvalid       = ho2mx_rxreq_port.tvalid;
   ho2mx_rxreq_remap.tdata        = ho2mx_rxreq_port.tdata;
   ho2mx_rxreq_remap.tlast        = ho2mx_rxreq_port.tlast;
   ho2mx_rxreq_remap.tkeep        = ho2mx_rxreq_port.tkeep;
   ho2mx_rxreq_remap.tuser_vendor = ho2mx_rxreq_port.tuser_vendor;

   ho2mx_rxreq_port.tready        = ho2mx_rxreq_remap.tready;
end


//
// Tag remap is needed because all outstanding tags must be unique,
// even across PF/VFs. The PCIe SS does not handle remapping
// by itself.
//
// TX and TXREQ are first mapped to a vector of ports and then passed
// to the tag remapper. Both streams need remapping since tagged
// requests may be present on either port.
//
pcie_ss_axis_if #(
   .DATA_W (ofs_fim_cfg_pkg::PCIE_TDATA_WIDTH),
   .USER_W (ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH)
) mx2ho_tx_ab[2](.clk(clk), .rst_n(rst_n));

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


// ------------------------------------------------------------------------
//
//  TX/TXREQ routing after tag remapping
//
// ------------------------------------------------------------------------

//
// The PCIe SS accepts only DM-encoded reads on TXREQ. Force all other
// TX-B requests to TX-A, which connects to the PCIe SS TX port.
// The PCIe SS would accept interrupts on TXREQ, but OFS moves them
// to TX in order to generate commit responses.
//

pcie_ss_axis_if #(
   .DATA_W (ofs_fim_cfg_pkg::PCIE_TDATA_WIDTH),
   .USER_W (ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH)
) arb_tx_in[2](.clk(clk), .rst_n(rst_n));

pcie_ss_axis_mux #(
   .NUM_CH ( 2 )
) mx2ho_tx_ab_mux (
   .clk    ( clk           ),
   .rst_n  ( rst_n         ),

   .sink   ( arb_tx_in     ),
   .source ( mx2ho_tx_port )
);


//
// TX-A port to A/B MUX
//
assign mx2ho_tx_ab[0].tready = arb_tx_in[0].tready;
assign arb_tx_in[0].tvalid = mx2ho_tx_ab[0].tvalid;
always_comb begin
   arb_tx_in[0].tlast = mx2ho_tx_ab[0].tlast;
   arb_tx_in[0].tuser_vendor = mx2ho_tx_ab[0].tuser_vendor;
   arb_tx_in[0].tdata = mx2ho_tx_ab[0].tdata;
   arb_tx_in[0].tkeep = mx2ho_tx_ab[0].tkeep;
end


//
// Is TX-B a DM-encoded read?
//
logic mx2ho_tx_ab1_is_sop;
pcie_ss_hdr_pkg::PCIe_ReqHdr_t mx2ho_tx_ab1_hdr;
assign mx2ho_tx_ab1_hdr = ($bits(pcie_ss_hdr_pkg::PCIe_ReqHdr_t))'(mx2ho_tx_ab[1].tdata);
wire mx2ho_tx_ab1_to_txreq =
   mx2ho_tx_ab1_is_sop &&
   // Routing from mx2ho_tx_ab1 doesn't matter when it is not valid and we don't
   // want routing logic to depend on whether it is actually valid. When not valid,
   // the header may be undefined, so the tests here ignore undefined values. If
   // the bus actually is valid while the header is undefined other assertions will
   // trigger.
   (pcie_ss_hdr_pkg::func_hdr_is_dm_mode(mx2ho_tx_ab[1].tuser_vendor) === 1'b1) &&
   (mx2ho_tx_ab1_hdr.fmt_type === pcie_ss_hdr_pkg::DM_RD);

always_ff @(posedge clk)
begin
   if (mx2ho_tx_ab[1].tvalid && mx2ho_tx_ab[1].tready)
      mx2ho_tx_ab1_is_sop <= mx2ho_tx_ab[1].tlast;

   if (!rst_n)
      mx2ho_tx_ab1_is_sop <= 1'b1;
end


//
// DM-encoded reads to TXREQ
//
assign mx2ho_txreq_port.tvalid = mx2ho_tx_ab[1].tvalid && mx2ho_tx_ab1_to_txreq;
always_comb begin
   mx2ho_txreq_port.tlast = mx2ho_tx_ab[1].tlast;
   mx2ho_txreq_port.tuser_vendor = mx2ho_tx_ab[1].tuser_vendor;
   // The TXREQ port is just the width of a header
   mx2ho_txreq_port.tdata = (pcie_ss_hdr_pkg::HDR_WIDTH)'(mx2ho_tx_ab[1].tdata);
   mx2ho_txreq_port.tkeep = (pcie_ss_hdr_pkg::HDR_WIDTH / 8)'(mx2ho_tx_ab[1].tkeep);
end


//
// All other TX-B traffic to TX
//
assign arb_tx_in[1].tvalid = mx2ho_tx_ab[1].tvalid && !mx2ho_tx_ab1_to_txreq;
always_comb begin
   arb_tx_in[1].tlast = mx2ho_tx_ab[1].tlast;
   arb_tx_in[1].tuser_vendor = mx2ho_tx_ab[1].tuser_vendor;
   arb_tx_in[1].tdata = mx2ho_tx_ab[1].tdata;
   arb_tx_in[1].tkeep = mx2ho_tx_ab[1].tkeep;
end

assign mx2ho_tx_ab[1].tready =
   mx2ho_tx_ab1_to_txreq ? mx2ho_txreq_port.tready : arb_tx_in[1].tready;

endmodule
