// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Top level module of HSSI subsystem.
// Port and signals use continuous index irrespective IP configuration.
// For example is HSSI SS IP enables port-0 and port-4, then all port/signal in
// shell have index-0 mapped to port 0 and index-1 mapped to port 4
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"
`include "ofs_fim_eth_plat_defines.svh"
import ofs_fim_eth_if_pkg::*;

module hssi_wrapper #(
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit        END_OF_LIST     = 1'b0
) (
   // CSR interfaces
   input  logic                               clk_csr,
   input  logic                               rst_n_csr,
   ofs_fim_axi_lite_if.slave                  csr_lite_if,
   // Streaming data interfaces
   ofs_fim_hssi_ss_tx_axis_if.mac             hssi_ss_st_tx [MAX_NUM_ETH_CHANNELS-1:0],
   ofs_fim_hssi_ss_rx_axis_if.mac             hssi_ss_st_rx [MAX_NUM_ETH_CHANNELS-1:0],
   // Streaming PTP interfaces
   `ifdef INCLUDE_PTP
   input  logic                               sys_pll_locked,
   ofs_fim_hssi_ptp_tx_tod_if.mac             hssi_ptp_tx_tod [MAX_NUM_ETH_CHANNELS-1:0],
   ofs_fim_hssi_ptp_rx_tod_if.mac             hssi_ptp_rx_tod [MAX_NUM_ETH_CHANNELS-1:0],
   ofs_fim_hssi_ptp_tx_egrts_if.mac           hssi_ptp_tx_egrts [MAX_NUM_ETH_CHANNELS-1:0],
   ofs_fim_hssi_ptp_rx_ingrts_if.mac          hssi_ptp_rx_ingrts [MAX_NUM_ETH_CHANNELS-1:0],
   output logic                               o_ehip_clk_806,
   output logic                               o_ehip_clk_403,
   output logic                               o_ehip_pll_locked,
   `endif
   // Flow control interfaces
   ofs_fim_hssi_fc_if.mac                     hssi_fc [MAX_NUM_ETH_CHANNELS-1:0],
   // Serial Pins
   ofs_fim_hssi_serial_if.qsfp                qsfp_serial [NUM_QSFP_PORTS-1:0],
   // Clock interfaces
   input  logic [2:0]                         i_hssi_clk_ref,
   output logic [2:0]                         o_hssi_rec_clk,
   output logic [MAX_NUM_ETH_CHANNELS-1:0]    o_hssi_clk_pll,
   // Speed and activity LEDS
   output logic [1:0]                         o_qsfp_speed_green,       // Link up in Nx25G or 2x56G or 1x100G speed
   output logic [1:0]                         o_qsfp_speed_yellow,      // Link up in Nx10G speed
   output logic [1:0]                         o_qsfp_activity_green,    // Link up and activity seen
   output logic [1:0]                         o_qsfp_activity_red       // LOS, TX Fault etc
);

localparam NUM_PORT    = NUM_ETH_CHANNELS;                        // Number of Ethernet ports
localparam UNUSED_PORT = MAX_NUM_ETH_CHANNELS - NUM_ETH_CHANNELS; // Number of Ethernet ports not unused

logic [NUM_ETH_CHANNELS-1:0][NUM_LANES-1:0] serial_tx_p,serial_tx_n;
logic [NUM_ETH_CHANNELS-1:0][NUM_LANES-1:0] serial_rx_p,serial_rx_n;

logic [MAX_NUM_ETH_CHANNELS-1:0]        axis_tx_areset,csr_axis_tx_areset;
logic [MAX_NUM_ETH_CHANNELS-1:0]        axis_rx_areset,csr_axis_rx_areset;
logic [MAX_NUM_ETH_CHANNELS-1:0]        tx_rst;
logic [MAX_NUM_ETH_CHANNELS-1:0]        rx_rst;
logic [MAX_NUM_ETH_CHANNELS-1:0]        tx_rst_ack_n,sync_tx_rst_ack_n;
logic [MAX_NUM_ETH_CHANNELS-1:0]        rx_rst_ack_n,sync_rx_rst_ack_n;
logic                                   cold_rst;
logic                                   cold_rst_ack_n,sync_cold_rst_ack_n;
logic [MAX_NUM_ETH_CHANNELS-1:0]        tx_pll_locked,sync_tx_pll_locked;
logic [MAX_NUM_ETH_CHANNELS-1:0]        tx_lanes_stable,sync_tx_lanes_stable;
logic [MAX_NUM_ETH_CHANNELS-1:0]        rx_pcs_ready,sync_rx_pcs_ready;
logic [MAX_NUM_ETH_CHANNELS-1:0]        handshaked_tx_rst;
logic [MAX_NUM_ETH_CHANNELS-1:0]        handshaked_rx_rst;
logic                                   handshaked_cold_rst;
logic [MAX_NUM_ETH_CHANNELS-1:0][2:0]   led_speed, led_status;

wire [NUM_ETH_CHANNELS-1:0]             clk_pll;
wire                                    ehip0_ptp_clk_pll,ehip1_ptp_clk_pll;
wire                                    ehip0_ptp_clk_tx_div,ehip1_ptp_clk_tx_div;
wire                                    ehip0_ptp_clk_rec_div,ehip1_ptp_clk_rec_div;
wire                                    ehip0_ptp_clk_rec_div64,ehip1_ptp_clk_rec_div64;
wire                                    ehip2_ptp_clk_pll,ehip3_ptp_clk_pll;
wire                                    ehip2_ptp_clk_tx_div,ehip3_ptp_clk_tx_div;
wire                                    ehip2_ptp_clk_rec_div,ehip3_ptp_clk_rec_div;
wire                                    ehip2_ptp_clk_rec_div64,ehip3_ptp_clk_rec_div64;

wire  [NUM_ETH_CHANNELS-1:0]            tx_ptp_ready,sync_tx_ptp_ready;
wire  [NUM_ETH_CHANNELS-1:0]            rx_ptp_ready,sync_rx_ptp_ready;

wire                                    clk_ptp_sample;
wire                                    p0_clk_ptp_sample;
wire                                    p4_clk_ptp_sample;
wire                                    p8_clk_ptp_sample;
wire                                    p10_clk_ptp_sample;
wire                                    p12_clk_ptp_sample;

wire  [NUM_ETH_CHANNELS-1:0]            st_tx_clk = clk_pll;
wire  [NUM_ETH_CHANNELS-1:0]            st_rx_clk = clk_pll;
wire  [NUM_ETH_CHANNELS-1:0]            clk_tx_div,clk_rec_div64,clk_rec_div;
wire  [NUM_ETH_CHANNELS-1:0]            clk_tx_tod=clk_tx_div;
wire  [NUM_ETH_CHANNELS-1:0]            clk_rx_tod=clk_rec_div;

ofs_fim_axi_lite_if #(.AWADDR_WIDTH(11), .WDATA_WIDTH(32), .ARADDR_WIDTH(11), .RDATA_WIDTH(32)) ss_ip_csr_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(11), .ARADDR_WIDTH(11)) wrapper_csr_if();

// Enumeration of port index based on which ports are enabled for a particular configuration
// This ensures that irrespective of HSSI SS IP configuration, shell signals have continus active index
// For example is HSSI SS IP enables port-0 and port-4, then all port/signal in
// shell have index-0 mapped to port 0 and index-1 mapped to port 4
enum { 
   `ifdef INCLUDE_HSSI_PORT_0
      PORT_0
   `endif
   `ifdef INCLUDE_HSSI_PORT_1
      ,PORT_1
   `endif
   `ifdef INCLUDE_HSSI_PORT_2
      ,PORT_2
   `endif
   `ifdef INCLUDE_HSSI_PORT_3
      ,PORT_3
   `endif
   `ifdef INCLUDE_HSSI_PORT_4
      ,PORT_4
   `endif
   `ifdef INCLUDE_HSSI_PORT_5
      ,PORT_5
   `endif
   `ifdef INCLUDE_HSSI_PORT_6
      ,PORT_6
   `endif
   `ifdef INCLUDE_HSSI_PORT_7
      ,PORT_7
   `endif
   `ifdef INCLUDE_HSSI_PORT_8
      ,PORT_8
   `endif
   `ifdef INCLUDE_HSSI_PORT_9
      ,PORT_9
   `endif
   `ifdef INCLUDE_HSSI_PORT_10
      ,PORT_10
   `endif
   `ifdef INCLUDE_HSSI_PORT_11
      ,PORT_11
   `endif
   `ifdef INCLUDE_HSSI_PORT_12
      ,PORT_12
   `endif
   `ifdef INCLUDE_HSSI_PORT_13
      ,PORT_13
   `endif
   `ifdef INCLUDE_HSSI_PORT_14
      ,PORT_14
   `endif
   `ifdef INCLUDE_HSSI_PORT_15
      ,PORT_15
   `endif
   ,PORT_MAX
} port_index;

assign o_hssi_clk_pll = st_tx_clk;

for (genvar nump=0; nump < NUM_ETH_CHANNELS; nump++) begin : GenClkRst
   
   fim_resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (1),
    .INIT_VALUE         (1),
    .NO_CUT             (0)
   ) st_tx_rst_sync(
    .clk                (st_tx_clk[nump]),
    .reset              (~rst_n_csr || csr_axis_tx_areset[nump]),
    .d                  (1'b0),
    .q                  (axis_tx_areset[nump])
);

 fim_resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (1),
    .INIT_VALUE         (1),
    .NO_CUT             (0)
   ) st_rx_rst_sync(
    .clk                (st_tx_clk[nump]),
    .reset              (~rst_n_csr || csr_axis_rx_areset[nump]),
    .d                  (1'b0),
    .q                  (axis_rx_areset[nump])
);

   assign hssi_ss_st_tx[nump].clk   = st_tx_clk[nump];
   assign hssi_ss_st_tx[nump].rst_n = ~axis_tx_areset[nump];
   
   assign hssi_ss_st_rx[nump].clk   = st_rx_clk[nump];
   assign hssi_ss_st_rx[nump].rst_n = ~axis_rx_areset[nump];
   
end

// AXI4Lite interconnect to split CSR space between HSSI SS IP and shell CSR
   hssi_ss_csr_ic hssi_ss_csr_ic (
      .clk_clk                     (clk_csr),                     //   input,   width = 1,                 clk.clk
      .hssi_ss_csr_mst_awaddr      (csr_lite_if.awaddr[11:0]),    //   input,  width = 12,     hssi_ss_csr_mst.awaddr
      .hssi_ss_csr_mst_awprot      (csr_lite_if.awprot),          //   input,   width = 3,                    .awprot
      .hssi_ss_csr_mst_awvalid     (csr_lite_if.awvalid),         //   input,   width = 1,                    .awvalid
      .hssi_ss_csr_mst_awready     (csr_lite_if.awready),         //  output,   width = 1,                    .awready
      .hssi_ss_csr_mst_wdata       (csr_lite_if.wdata),           //   input,  width = 64,                    .wdata
      .hssi_ss_csr_mst_wstrb       (csr_lite_if.wstrb),           //   input,   width = 8,                    .wstrb
      .hssi_ss_csr_mst_wvalid      (csr_lite_if.wvalid),          //   input,   width = 1,                    .wvalid
      .hssi_ss_csr_mst_wready      (csr_lite_if.wready),          //  output,   width = 1,                    .wready
      .hssi_ss_csr_mst_bresp       (csr_lite_if.bresp),           //  output,   width = 2,                    .bresp
      .hssi_ss_csr_mst_bvalid      (csr_lite_if.bvalid),          //  output,   width = 1,                    .bvalid
      .hssi_ss_csr_mst_bready      (csr_lite_if.bready),          //   input,   width = 1,                    .bready
      .hssi_ss_csr_mst_araddr      (csr_lite_if.araddr[11:0]),    //   input,  width = 12,                    .araddr
      .hssi_ss_csr_mst_arprot      (csr_lite_if.arprot),          //   input,   width = 3,                    .arprot
      .hssi_ss_csr_mst_arvalid     (csr_lite_if.arvalid),         //   input,   width = 1,                    .arvalid
      .hssi_ss_csr_mst_arready     (csr_lite_if.arready),         //  output,   width = 1,                    .arready
      .hssi_ss_csr_mst_rdata       (csr_lite_if.rdata),           //  output,  width = 64,                    .rdata
      .hssi_ss_csr_mst_rresp       (csr_lite_if.rresp),           //  output,   width = 2,                    .rresp
      .hssi_ss_csr_mst_rvalid      (csr_lite_if.rvalid),          //  output,   width = 1,                    .rvalid
      .hssi_ss_csr_mst_rready      (csr_lite_if.rready),          //   input,   width = 1,                    .rready
      .hssi_ss_ip_slv_awaddr       (ss_ip_csr_if.awaddr[10:0]),   //  output,  width = 11,      hssi_ss_ip_slv.awaddr
      .hssi_ss_ip_slv_awprot       (ss_ip_csr_if.awprot),         //  output,   width = 3,                    .awprot
      .hssi_ss_ip_slv_awvalid      (ss_ip_csr_if.awvalid),        //  output,   width = 1,                    .awvalid
      .hssi_ss_ip_slv_awready      (ss_ip_csr_if.awready),        //   input,   width = 1,                    .awready
      .hssi_ss_ip_slv_wdata        (ss_ip_csr_if.wdata),          //  output,  width = 64,                    .wdata
      .hssi_ss_ip_slv_wstrb        (ss_ip_csr_if.wstrb),          //  output,   width = 8,                    .wstrb
      .hssi_ss_ip_slv_wvalid       (ss_ip_csr_if.wvalid),         //  output,   width = 1,                    .wvalid
      .hssi_ss_ip_slv_wready       (ss_ip_csr_if.wready),         //   input,   width = 1,                    .wready
      .hssi_ss_ip_slv_bresp        (ss_ip_csr_if.bresp),          //   input,   width = 2,                    .bresp
      .hssi_ss_ip_slv_bvalid       (ss_ip_csr_if.bvalid),         //   input,   width = 1,                    .bvalid
      .hssi_ss_ip_slv_bready       (ss_ip_csr_if.bready),         //  output,   width = 1,                    .bready
      .hssi_ss_ip_slv_araddr       (ss_ip_csr_if.araddr[10:0]),   //  output,  width = 11,                    .araddr
      .hssi_ss_ip_slv_arprot       (ss_ip_csr_if.arprot),         //  output,   width = 3,                    .arprot
      .hssi_ss_ip_slv_arvalid      (ss_ip_csr_if.arvalid),        //  output,   width = 1,                    .arvalid
      .hssi_ss_ip_slv_arready      (ss_ip_csr_if.arready),        //   input,   width = 1,                    .arready
      .hssi_ss_ip_slv_rdata        (ss_ip_csr_if.rdata),          //   input,  width = 64,                    .rdata
      .hssi_ss_ip_slv_rresp        (ss_ip_csr_if.rresp),          //   input,   width = 2,                    .rresp
      .hssi_ss_ip_slv_rvalid       (ss_ip_csr_if.rvalid),         //   input,   width = 1,                    .rvalid
      .hssi_ss_ip_slv_rready       (ss_ip_csr_if.rready),         //  output,   width = 1,                    .rready
      .hssi_ss_wrapper_slv_awaddr  (wrapper_csr_if.awaddr[10:0]), //  output,  width = 11, hssi_ss_wrapper_slv.awaddr
      .hssi_ss_wrapper_slv_awprot  (wrapper_csr_if.awprot),       //  output,   width = 3,                    .awprot
      .hssi_ss_wrapper_slv_awvalid (wrapper_csr_if.awvalid),      //  output,   width = 1,                    .awvalid
      .hssi_ss_wrapper_slv_awready (wrapper_csr_if.awready),      //   input,   width = 1,                    .awready
      .hssi_ss_wrapper_slv_wdata   (wrapper_csr_if.wdata),        //  output,  width = 64,                    .wdata
      .hssi_ss_wrapper_slv_wstrb   (wrapper_csr_if.wstrb),        //  output,   width = 8,                    .wstrb
      .hssi_ss_wrapper_slv_wvalid  (wrapper_csr_if.wvalid),       //  output,   width = 1,                    .wvalid
      .hssi_ss_wrapper_slv_wready  (wrapper_csr_if.wready),       //   input,   width = 1,                    .wready
      .hssi_ss_wrapper_slv_bresp   (wrapper_csr_if.bresp),        //   input,   width = 2,                    .bresp
      .hssi_ss_wrapper_slv_bvalid  (wrapper_csr_if.bvalid),       //   input,   width = 1,                    .bvalid
      .hssi_ss_wrapper_slv_bready  (wrapper_csr_if.bready),       //  output,   width = 1,                    .bready
      .hssi_ss_wrapper_slv_araddr  (wrapper_csr_if.araddr[10:0]), //  output,  width = 11,                    .araddr
      .hssi_ss_wrapper_slv_arprot  (wrapper_csr_if.arprot),       //  output,   width = 3,                    .arprot
      .hssi_ss_wrapper_slv_arvalid (wrapper_csr_if.arvalid),      //  output,   width = 1,                    .arvalid
      .hssi_ss_wrapper_slv_arready (wrapper_csr_if.arready),      //   input,   width = 1,                    .arready
      .hssi_ss_wrapper_slv_rdata   (wrapper_csr_if.rdata),        //   input,  width = 64,                    .rdata
      .hssi_ss_wrapper_slv_rresp   (wrapper_csr_if.rresp),        //   input,   width = 2,                    .rresp
      .hssi_ss_wrapper_slv_rvalid  (wrapper_csr_if.rvalid),       //   input,   width = 1,                    .rvalid
      .hssi_ss_wrapper_slv_rready  (wrapper_csr_if.rready),       //  output,   width = 1,                    .rready
      .reset_reset_n               (rst_n_csr)                    //   input,   width = 1,               reset.reset_n
   );

//----------------------------
// HSSI Wrapper CSR instantiation
//----------------------------

hssi_wrapper_csr hssi_wrapper_csr (
   .clk                 (clk_csr),
   .rst_n               (rst_n_csr),
   .csr_lite_if         (wrapper_csr_if),
   .o_axis_tx_areset    (csr_axis_tx_areset),
   .o_axis_rx_areset    (csr_axis_rx_areset),
   .o_tx_rst            (tx_rst),
   .o_rx_rst            (rx_rst),
   .i_tx_rst_ack        (~sync_tx_rst_ack_n),
   .i_rx_rst_ack        (~sync_rx_rst_ack_n),
   .o_cold_rst          (cold_rst),
   .i_cold_rst_ack      (~sync_cold_rst_ack_n),
   .i_tx_pll_locked     (sync_tx_pll_locked),
   .i_tx_lanes_stable   (sync_tx_lanes_stable),
   .i_rx_pcs_ready      (sync_rx_pcs_ready),
   .i_tx_ptp_ready      (sync_tx_ptp_ready), 
   .i_rx_ptp_ready      (sync_rx_ptp_ready)
);

//------------------------------------------------------------------------------------
// Assign zero to unused port status signal to avoid 'x' propagation in sim 
//------------------------------------------------------------------------------------
generate
   if (UNUSED_PORT != 0) begin : GenUnusedPort
      always_comb begin
         tx_pll_locked[MAX_NUM_ETH_CHANNELS-1:NUM_PORT]   = {UNUSED_PORT{1'b0}};
         tx_lanes_stable[MAX_NUM_ETH_CHANNELS-1:NUM_PORT] = {UNUSED_PORT{1'b0}};
         rx_pcs_ready[MAX_NUM_ETH_CHANNELS-1:NUM_PORT]    = {UNUSED_PORT{1'b0}};
         tx_rst_ack_n[MAX_NUM_ETH_CHANNELS-1:NUM_PORT]    = {UNUSED_PORT{1'b0}};
         rx_rst_ack_n[MAX_NUM_ETH_CHANNELS-1:NUM_PORT]    = {UNUSED_PORT{1'b0}};
      end
   end
endgenerate

//----------------------------
// Reset-Ack handshake 
//----------------------------
generate

   for (genvar nump=0; nump<NUM_PORT; nump++) begin : GenRst
      rst_ack tx_rst_ack(
         .i_clk(clk_csr),
         .i_rst(~rst_n_csr | tx_rst[nump]),
         .i_ack(sync_tx_pll_locked[nump] & ~sync_tx_rst_ack_n[nump]),
         .o_rst(handshaked_tx_rst[nump])
      );

      rst_ack rx_rst_ack(
         .i_clk(clk_csr),
         .i_rst(~rst_n_csr | rx_rst[nump]),
         .i_ack(sync_tx_pll_locked[nump] & ~sync_rx_rst_ack_n[nump]),
         .o_rst(handshaked_rx_rst[nump])
      );
   end
endgenerate

rst_ack cold_rst_ack(
   .i_clk(clk_csr),
   .i_rst(~rst_n_csr | cold_rst),
   .i_ack(~sync_cold_rst_ack_n),
   .o_rst(handshaked_cold_rst)
);

//--------------------------------
// Synchronizers for CSR module
//--------------------------------
fim_resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (33),
    .INIT_VALUE         (0),
    .NO_CUT             (0)
   ) inst_sync_ack (
    .clk                (clk_csr),
    .reset              (~rst_n_csr),
    .d                  ({cold_rst_ack_n,rx_rst_ack_n,tx_rst_ack_n}),
    .q                  ({sync_cold_rst_ack_n,sync_rx_rst_ack_n,sync_tx_rst_ack_n})
);

fim_resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (48),
    .INIT_VALUE         (0),
    .NO_CUT             (0)
   ) inst_sync_stats (
    .clk                (clk_csr),
    .reset              (~rst_n_csr),
    .d                  ({rx_pcs_ready,tx_lanes_stable,tx_pll_locked}),
    .q                  ({sync_rx_pcs_ready,sync_tx_lanes_stable,sync_tx_pll_locked})
);

//--------------------------------
// PTP-CSR interface logic
//--------------------------------
`ifdef INCLUDE_PTP
fim_resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (32),
    .INIT_VALUE         (0),
    .NO_CUT             (0)
   ) inst_sync_ptp_ready (
    .clk                (clk_csr),
    .reset              (~rst_n_csr),
    .d                  ({rx_ptp_ready,tx_ptp_ready}),
    .q                  ({sync_rx_ptp_ready,sync_tx_ptp_ready})
);

   //generate 114.285714MHz
   `ifndef ETH_100G
   ptp_sample_clk_pll  ptp_sample_clk_pll (
      .rst        (~rst_n_csr),
      .refclk     (clk_csr),
      .locked     (),
      .permit_cal (sys_pll_locked),
      .outclk_0  (clk_ptp_sample)
   );

   assign p0_clk_ptp_sample  = clk_ptp_sample;
   assign p3_clk_ptp_sample  = clk_ptp_sample;
   assign p4_clk_ptp_sample  = clk_ptp_sample;
   assign p8_clk_ptp_sample  = clk_ptp_sample;
   assign p10_clk_ptp_sample = clk_ptp_sample;
   assign p11_clk_ptp_sample = clk_ptp_sample;
   assign p12_clk_ptp_sample = clk_ptp_sample;
   `endif
`else
   assign sync_tx_ptp_ready      = 'h0;
   assign sync_rx_ptp_ready      = 'h0;
`endif

//----------------------------
// HSSI SS instantiation
//----------------------------
`ifdef INCLUDE_PTP
   `ifdef ETH_10G
      hssi_ss_8x10g_ptp
    `elsif ETH_100G
      hssi_ss_2x100g_ptp
    `else
      hssi_ss_8x25g_ptp
   `endif
`else
   `ifdef ETH_10G
      hssi_ss_8x10g
   `elsif ETH_100G
      hssi_ss_2x100g
   `else
      hssi_ss_8x25g
   `endif
`endif
	#( `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1),
      .DFHv0_FEA_EOL                 (END_OF_LIST),
      .DFHv0_FEA_NXT                 (NEXT_DFH_OFFSET)
   )
	hssi_ss (
   .app_ss_lite_clk                    (clk_csr),
   .app_ss_lite_areset_n               (rst_n_csr),
   .app_ss_lite_awaddr                 ({15'h0,ss_ip_csr_if.awaddr[10:0]}),
   .app_ss_lite_awprot                 (ss_ip_csr_if.awprot),
   .app_ss_lite_awvalid                (ss_ip_csr_if.awvalid),
   .ss_app_lite_awready                (ss_ip_csr_if.awready),
   .app_ss_lite_wdata                  (ss_ip_csr_if.wdata),
   .app_ss_lite_wstrb                  (ss_ip_csr_if.wstrb),
   .app_ss_lite_wvalid                 (ss_ip_csr_if.wvalid),
   .ss_app_lite_wready                 (ss_ip_csr_if.wready),
   .ss_app_lite_bresp                  (ss_ip_csr_if.bresp),
   .ss_app_lite_bvalid                 (ss_ip_csr_if.bvalid),
   .app_ss_lite_bready                 (ss_ip_csr_if.bready),
   .app_ss_lite_araddr                 ({15'h0,ss_ip_csr_if.araddr[10:0]}),
   .app_ss_lite_arprot                 (ss_ip_csr_if.arprot),
   .app_ss_lite_arvalid                (ss_ip_csr_if.arvalid),
   .ss_app_lite_arready                (ss_ip_csr_if.arready),
   .ss_app_lite_rdata                  (ss_ip_csr_if.rdata),
   .ss_app_lite_rvalid                 (ss_ip_csr_if.rvalid),
   .app_ss_lite_rready                 (ss_ip_csr_if.rready),
   .ss_app_lite_rresp                  (ss_ip_csr_if.rresp),
`ifdef INCLUDE_HSSI_PORT_0
   .p0_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_0].clk),
   .p0_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_0].rst_n),
   .p0_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_0].tx.tvalid),
   .p0_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_0].tready),
   .p0_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_0].tx.tdata),
   .p0_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_0].tx.tkeep),
   .p0_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_0].tx.tlast),
   .p0_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_0].tx.tuser.client),
   .p0_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_0].clk),
   .p0_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_0].rst_n),
   .p0_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_0].rx.tvalid),
   .p0_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_0].rx.tdata),
   .p0_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_0].rx.tkeep),
   .p0_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_0].rx.tlast),
   .p0_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_0].rx.tuser.client),
   .p0_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_0].rx.tuser.sts),
   .i_p0_tx_pause                      (hssi_fc[PORT_0].tx_pause),
   .i_p0_tx_pfc                        (hssi_fc[PORT_0].tx_pfc),
   .o_p0_rx_pause                      (hssi_fc[PORT_0].rx_pause),
   .o_p0_rx_pfc                        (hssi_fc[PORT_0].rx_pfc),
   .p0_tx_serial                       (serial_tx_p[PORT_0]),
   .p0_tx_serial_n                     (serial_tx_n[PORT_0]),
   .p0_rx_serial                       (serial_rx_p[PORT_0]),
   .p0_rx_serial_n                     (serial_rx_n[PORT_0]),
   .p0_tx_lanes_stable                 (tx_lanes_stable[PORT_0]),
   .p0_rx_pcs_ready                    (rx_pcs_ready[PORT_0]),
   .o_p0_tx_pll_locked                 (tx_pll_locked[PORT_0]),
   .i_p0_tx_rst_n                      (~handshaked_tx_rst[PORT_0]),
   .i_p0_rx_rst_n                      (~handshaked_rx_rst[PORT_0]),
   .o_p0_rx_rst_ack_n                  (rx_rst_ack_n[PORT_0]),
   .o_p0_tx_rst_ack_n                  (tx_rst_ack_n[PORT_0]),
   .o_p0_ereset_n                      (),
   .o_p0_clk_pll                       (clk_pll[PORT_0]),
   .o_p0_clk_tx_div                    (clk_tx_div[PORT_0]),
   .o_p0_clk_rec_div64                 (clk_rec_div64[PORT_0]),
   .o_p0_clk_rec_div                   (clk_rec_div[PORT_0]),
   .port0_led_speed                    (led_speed[PORT_0]),
   .port0_led_status                   (led_status[PORT_0]),
`endif
`ifdef INCLUDE_HSSI_PORT_1
   .p1_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_1].clk),
   .p1_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_1].rst_n),
   .p1_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_1].tx.tvalid),
   .p1_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_1].tready),
   .p1_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_1].tx.tdata),
   .p1_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_1].tx.tkeep),
   .p1_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_1].tx.tlast),
   .p1_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_1].tx.tuser.client),
   .p1_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_1].clk),
   .p1_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_1].rst_n),
   .p1_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_1].rx.tvalid),
   .p1_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_1].rx.tdata),
   .p1_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_1].rx.tkeep),
   .p1_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_1].rx.tlast),
   .p1_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_1].rx.tuser.client),
   .p1_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_1].rx.tuser.sts),
   .i_p1_tx_pause                      (hssi_fc[PORT_1].tx_pause),
   .i_p1_tx_pfc                        (hssi_fc[PORT_1].tx_pfc),
   .o_p1_rx_pause                      (hssi_fc[PORT_1].rx_pause),
   .o_p1_rx_pfc                        (hssi_fc[PORT_1].rx_pfc),
   .p1_tx_serial                       (serial_tx_p[PORT_1]),
   .p1_tx_serial_n                     (serial_tx_n[PORT_1]),
   .p1_rx_serial                       (serial_rx_p[PORT_1]),
   .p1_rx_serial_n                     (serial_rx_n[PORT_1]),
   .p1_tx_lanes_stable                 (tx_lanes_stable[PORT_1]),
   .p1_rx_pcs_ready                    (rx_pcs_ready[PORT_1]),
   .o_p1_tx_pll_locked                 (tx_pll_locked[PORT_1]),
   .i_p1_tx_rst_n                      (~handshaked_tx_rst[PORT_1]),
   .i_p1_rx_rst_n                      (~handshaked_rx_rst[PORT_1]),
   .o_p1_rx_rst_ack_n                  (rx_rst_ack_n[PORT_1]),
   .o_p1_tx_rst_ack_n                  (tx_rst_ack_n[PORT_1]),
   .o_p1_ereset_n                      (),
   .o_p1_clk_pll                       (clk_pll[PORT_1]),
   .o_p1_clk_tx_div                    (clk_tx_div[PORT_1]),
   .o_p1_clk_rec_div64                 (clk_rec_div64[PORT_1]),
   .o_p1_clk_rec_div                   (clk_rec_div[PORT_1]),
   .port1_led_speed                    (led_speed[PORT_1]),
   .port1_led_status                   (led_status[PORT_1]),
`endif
`ifdef INCLUDE_HSSI_PORT_2
   .p2_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_2].clk),
   .p2_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_2].rst_n),
   .p2_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_2].tx.tvalid),
   .p2_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_2].tready),
   .p2_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_2].tx.tdata),
   .p2_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_2].tx.tkeep),
   .p2_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_2].tx.tlast),
   .p2_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_2].tx.tuser.client),
   .p2_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_2].clk),
   .p2_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_2].rst_n),
   .p2_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_2].rx.tvalid),
   .p2_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_2].rx.tdata),
   .p2_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_2].rx.tkeep),
   .p2_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_2].rx.tlast),
   .p2_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_2].rx.tuser.client),
   .p2_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_2].rx.tuser.sts),
   .i_p2_tx_pause                      (hssi_fc[PORT_2].tx_pause),
   .i_p2_tx_pfc                        (hssi_fc[PORT_2].tx_pfc),
   .o_p2_rx_pause                      (hssi_fc[PORT_2].rx_pause),
   .o_p2_rx_pfc                        (hssi_fc[PORT_2].rx_pfc),
   .p2_tx_serial                       (serial_tx_p[PORT_2]),
   .p2_tx_serial_n                     (serial_tx_n[PORT_2]),
   .p2_rx_serial                       (serial_rx_p[PORT_2]),
   .p2_rx_serial_n                     (serial_rx_n[PORT_2]),
   .p2_tx_lanes_stable                 (tx_lanes_stable[PORT_2]),
   .p2_rx_pcs_ready                    (rx_pcs_ready[PORT_2]),
   .o_p2_tx_pll_locked                 (tx_pll_locked[PORT_2]),
   .i_p2_tx_rst_n                      (~handshaked_tx_rst[PORT_2]),
   .i_p2_rx_rst_n                      (~handshaked_rx_rst[PORT_2]),
   .o_p2_rx_rst_ack_n                  (rx_rst_ack_n[PORT_2]),
   .o_p2_tx_rst_ack_n                  (tx_rst_ack_n[PORT_2]),
   .o_p2_ereset_n                      (),
   .o_p2_clk_pll                       (clk_pll[PORT_2]),
   .o_p2_clk_tx_div                    (clk_tx_div[PORT_2]),
   .o_p2_clk_rec_div64                 (clk_rec_div64[PORT_2]),
   .o_p2_clk_rec_div                   (clk_rec_div[PORT_2]),
   .port2_led_speed                    (led_speed[PORT_2]),
   .port2_led_status                   (led_status[PORT_2]),
`endif
`ifdef INCLUDE_HSSI_PORT_3
   .p3_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_3].clk),
   .p3_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_3].rst_n),
   .p3_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_3].tx.tvalid),
   .p3_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_3].tready),
   .p3_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_3].tx.tdata),
   .p3_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_3].tx.tkeep),
   .p3_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_3].tx.tlast),
   .p3_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_3].tx.tuser.client),
   .p3_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_3].clk),
   .p3_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_3].rst_n),
   .p3_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_3].rx.tvalid),
   .p3_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_3].rx.tdata),
   .p3_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_3].rx.tkeep),
   .p3_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_3].rx.tlast),
   .p3_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_3].rx.tuser.client),
   .p3_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_3].rx.tuser.sts),
   .i_p3_tx_pause                      (hssi_fc[PORT_3].tx_pause),
   .i_p3_tx_pfc                        (hssi_fc[PORT_3].tx_pfc),
   .o_p3_rx_pause                      (hssi_fc[PORT_3].rx_pause),
   .o_p3_rx_pfc                        (hssi_fc[PORT_3].rx_pfc),
   .p3_tx_serial                       (serial_tx_p[PORT_3]),
   .p3_tx_serial_n                     (serial_tx_n[PORT_3]),
   .p3_rx_serial                       (serial_rx_p[PORT_3]),
   .p3_rx_serial_n                     (serial_rx_n[PORT_3]),
   .p3_tx_lanes_stable                 (tx_lanes_stable[PORT_3]),
   .p3_rx_pcs_ready                    (rx_pcs_ready[PORT_3]),
   .o_p3_tx_pll_locked                 (tx_pll_locked[PORT_3]),
   .i_p3_tx_rst_n                      (~handshaked_tx_rst[PORT_3]),
   .i_p3_rx_rst_n                      (~handshaked_rx_rst[PORT_3]),
   .o_p3_rx_rst_ack_n                  (rx_rst_ack_n[PORT_3]),
   .o_p3_tx_rst_ack_n                  (tx_rst_ack_n[PORT_3]),
   .o_p3_ereset_n                      (),
   .o_p3_clk_pll                       (clk_pll[PORT_3]),
   .o_p3_clk_tx_div                    (clk_tx_div[PORT_3]),
   .o_p3_clk_rec_div64                 (clk_rec_div64[PORT_3]),
   .o_p3_clk_rec_div                   (clk_rec_div[PORT_3]),
   .port3_led_speed                    (led_speed[PORT_3]),
   .port3_led_status                   (led_status[PORT_3]),
`endif
`ifdef INCLUDE_HSSI_PORT_4
   .p4_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_4].clk),
   .p4_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_4].rst_n),
   .p4_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_4].tx.tvalid),
   .p4_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_4].tready),
   .p4_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_4].tx.tdata),
   .p4_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_4].tx.tkeep),
   .p4_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_4].tx.tlast),
   .p4_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_4].tx.tuser.client),
   .p4_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_4].clk),
   .p4_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_4].rst_n),
   .p4_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_4].rx.tvalid),
   .p4_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_4].rx.tdata),
   .p4_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_4].rx.tkeep),
   .p4_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_4].rx.tlast),
   .p4_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_4].rx.tuser.client),
   .p4_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_4].rx.tuser.sts),
   .i_p4_tx_pause                      (hssi_fc[PORT_4].tx_pause),
   .i_p4_tx_pfc                        (hssi_fc[PORT_4].tx_pfc),
   .o_p4_rx_pause                      (hssi_fc[PORT_4].rx_pause),
   .o_p4_rx_pfc                        (hssi_fc[PORT_4].rx_pfc),
   .p4_tx_serial                       (serial_tx_p[PORT_4]),
   .p4_tx_serial_n                     (serial_tx_n[PORT_4]),
   .p4_rx_serial                       (serial_rx_p[PORT_4]),
   .p4_rx_serial_n                     (serial_rx_n[PORT_4]),
   .p4_tx_lanes_stable                 (tx_lanes_stable[PORT_4]),
   .p4_rx_pcs_ready                    (rx_pcs_ready[PORT_4]),
   .o_p4_tx_pll_locked                 (tx_pll_locked[PORT_4]),
   .i_p4_tx_rst_n                      (~handshaked_tx_rst[PORT_4]),
   .i_p4_rx_rst_n                      (~handshaked_rx_rst[PORT_4]),
   .o_p4_rx_rst_ack_n                  (rx_rst_ack_n[PORT_4]),
   .o_p4_tx_rst_ack_n                  (tx_rst_ack_n[PORT_4]),
   .o_p4_ereset_n                      (),
   .o_p4_clk_pll                       (clk_pll[PORT_4]),
   .o_p4_clk_tx_div                    (clk_tx_div[PORT_4]),
   .o_p4_clk_rec_div64                 (clk_rec_div64[PORT_4]),
   .o_p4_clk_rec_div                   (clk_rec_div[PORT_4]),
   .port4_led_speed                    (led_speed[PORT_4]),
   .port4_led_status                   (led_status[PORT_4]),
`endif
`ifdef INCLUDE_HSSI_PORT_5
   .p5_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_5].clk),
   .p5_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_5].rst_n),
   .p5_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_5].tx.tvalid),
   .p5_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_5].tready),
   .p5_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_5].tx.tdata),
   .p5_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_5].tx.tkeep),
   .p5_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_5].tx.tlast),
   .p5_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_5].tx.tuser.client),
   .p5_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_5].clk),
   .p5_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_5].rst_n),
   .p5_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_5].rx.tvalid),
   .p5_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_5].rx.tdata),
   .p5_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_5].rx.tkeep),
   .p5_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_5].rx.tlast),
   .p5_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_5].rx.tuser.client),
   .p5_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_5].rx.tuser.sts),
   .i_p5_tx_pause                      (hssi_fc[PORT_5].tx_pause),
   .i_p5_tx_pfc                        (hssi_fc[PORT_5].tx_pfc),
   .o_p5_rx_pause                      (hssi_fc[PORT_5].rx_pause),
   .o_p5_rx_pfc                        (hssi_fc[PORT_5].rx_pfc),
   .p5_tx_serial                       (serial_tx_p[PORT_5]),
   .p5_tx_serial_n                     (serial_tx_n[PORT_5]),
   .p5_rx_serial                       (serial_rx_p[PORT_5]),
   .p5_rx_serial_n                     (serial_rx_n[PORT_5]),
   .p5_tx_lanes_stable                 (tx_lanes_stable[PORT_5]),
   .p5_rx_pcs_ready                    (rx_pcs_ready[PORT_5]),
   .o_p5_tx_pll_locked                 (tx_pll_locked[PORT_5]),
   .i_p5_tx_rst_n                      (~handshaked_tx_rst[PORT_5]),
   .i_p5_rx_rst_n                      (~handshaked_rx_rst[PORT_5]),
   .o_p5_rx_rst_ack_n                  (rx_rst_ack_n[PORT_5]),
   .o_p5_tx_rst_ack_n                  (tx_rst_ack_n[PORT_5]),
   .o_p5_ereset_n                      (),
   .o_p5_clk_pll                       (clk_pll[PORT_5]),
   .o_p5_clk_tx_div                    (clk_tx_div[PORT_5]),
   .o_p5_clk_rec_div64                 (clk_rec_div64[PORT_5]),
   .o_p5_clk_rec_div                   (clk_rec_div[PORT_5]),
   .port5_led_speed                    (led_speed[PORT_5]),
   .port5_led_status                   (led_status[PORT_5]),
`endif
`ifdef INCLUDE_HSSI_PORT_6
   .p6_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_6].clk),
   .p6_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_6].rst_n),
   .p6_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_6].tx.tvalid),
   .p6_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_6].tready),
   .p6_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_6].tx.tdata),
   .p6_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_6].tx.tkeep),
   .p6_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_6].tx.tlast),
   .p6_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_6].tx.tuser.client),
   .p6_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_6].clk),
   .p6_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_6].rst_n),
   .p6_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_6].rx.tvalid),
   .p6_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_6].rx.tdata),
   .p6_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_6].rx.tkeep),
   .p6_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_6].rx.tlast),
   .p6_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_6].rx.tuser.client),
   .p6_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_6].rx.tuser.sts),
   .i_p6_tx_pause                      (hssi_fc[PORT_6].tx_pause),
   .i_p6_tx_pfc                        (hssi_fc[PORT_6].tx_pfc),
   .o_p6_rx_pause                      (hssi_fc[PORT_6].rx_pause),
   .o_p6_rx_pfc                        (hssi_fc[PORT_6].rx_pfc),
   .p6_tx_serial                       (serial_tx_p[PORT_6]),
   .p6_tx_serial_n                     (serial_tx_n[PORT_6]),
   .p6_rx_serial                       (serial_rx_p[PORT_6]),
   .p6_rx_serial_n                     (serial_rx_n[PORT_6]),
   .p6_tx_lanes_stable                 (tx_lanes_stable[PORT_6]),
   .p6_rx_pcs_ready                    (rx_pcs_ready[PORT_6]),
   .o_p6_tx_pll_locked                 (tx_pll_locked[PORT_6]),
   .i_p6_tx_rst_n                      (~handshaked_tx_rst[PORT_6]),
   .i_p6_rx_rst_n                      (~handshaked_rx_rst[PORT_6]),
   .o_p6_rx_rst_ack_n                  (rx_rst_ack_n[PORT_6]),
   .o_p6_tx_rst_ack_n                  (tx_rst_ack_n[PORT_6]),
   .o_p6_ereset_n                      (),
   .o_p6_clk_pll                       (clk_pll[PORT_6]),
   .o_p6_clk_tx_div                    (clk_tx_div[PORT_6]),
   .o_p6_clk_rec_div64                 (clk_rec_div64[PORT_6]),
   .o_p6_clk_rec_div                   (clk_rec_div[PORT_6]),
   .port6_led_speed                    (led_speed[PORT_6]),
   .port6_led_status                   (led_status[PORT_6]),
`endif
`ifdef INCLUDE_HSSI_PORT_7
   .p7_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_7].clk),
   .p7_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_7].rst_n),
   .p7_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_7].tx.tvalid),
   .p7_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_7].tready),
   .p7_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_7].tx.tdata),
   .p7_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_7].tx.tkeep),
   .p7_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_7].tx.tlast),
   .p7_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_7].tx.tuser.client),
   .p7_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_7].clk),
   .p7_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_7].rst_n),
   .p7_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_7].rx.tvalid),
   .p7_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_7].rx.tdata),
   .p7_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_7].rx.tkeep),
   .p7_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_7].rx.tlast),
   .p7_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_7].rx.tuser.client),
   .p7_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_7].rx.tuser.sts),
   .i_p7_tx_pause                      (hssi_fc[PORT_7].tx_pause),
   .i_p7_tx_pfc                        (hssi_fc[PORT_7].tx_pfc),
   .o_p7_rx_pause                      (hssi_fc[PORT_7].rx_pause),
   .o_p7_rx_pfc                        (hssi_fc[PORT_7].rx_pfc),
   .p7_tx_serial                       (serial_tx_p[PORT_7]),
   .p7_tx_serial_n                     (serial_tx_n[PORT_7]),
   .p7_rx_serial                       (serial_rx_p[PORT_7]),
   .p7_rx_serial_n                     (serial_rx_n[PORT_7]),
   .p7_tx_lanes_stable                 (tx_lanes_stable[PORT_7]),
   .p7_rx_pcs_ready                    (rx_pcs_ready[PORT_7]),
   .o_p7_tx_pll_locked                 (tx_pll_locked[PORT_7]),
   .i_p7_tx_rst_n                      (~handshaked_tx_rst[PORT_7]),
   .i_p7_rx_rst_n                      (~handshaked_rx_rst[PORT_7]),
   .o_p7_rx_rst_ack_n                  (rx_rst_ack_n[PORT_7]),
   .o_p7_tx_rst_ack_n                  (tx_rst_ack_n[PORT_7]),
   .o_p7_ereset_n                      (),
   .o_p7_clk_pll                       (clk_pll[PORT_7]),
   .o_p7_clk_tx_div                    (clk_tx_div[PORT_7]),
   .o_p7_clk_rec_div64                 (clk_rec_div64[PORT_7]),
   .o_p7_clk_rec_div                   (clk_rec_div[PORT_7]),
   .port7_led_speed                    (led_speed[PORT_7]),
   .port7_led_status                   (led_status[PORT_7]),
`endif
`ifdef INCLUDE_HSSI_PORT_8
   .p8_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_8].clk),
   .p8_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_8].rst_n),
   .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_8].tx.tvalid),
   .p8_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_8].tready),
   .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_8].tx.tdata),
   .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_8].tx.tkeep),
   .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_8].tx.tlast),
   .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_8].tx.tuser.client),
   .p8_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_8].clk),
   .p8_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_8].rst_n),
   .p8_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_8].rx.tvalid),
   .p8_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_8].rx.tdata),
   .p8_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_8].rx.tkeep),
   .p8_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_8].rx.tlast),
   .p8_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_8].rx.tuser.client),
   .p8_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_8].rx.tuser.sts),
   .i_p8_tx_pause                      (hssi_fc[PORT_8].tx_pause),
   .i_p8_tx_pfc                        (hssi_fc[PORT_8].tx_pfc),
   .o_p8_rx_pause                      (hssi_fc[PORT_8].rx_pause),
   .o_p8_rx_pfc                        (hssi_fc[PORT_8].rx_pfc),
   .p8_tx_serial                       (serial_tx_p[PORT_8]),
   .p8_tx_serial_n                     (serial_tx_n[PORT_8]),
   .p8_rx_serial                       (serial_rx_p[PORT_8]),
   .p8_rx_serial_n                     (serial_rx_n[PORT_8]),
   .p8_tx_lanes_stable                 (tx_lanes_stable[PORT_8]),
   .p8_rx_pcs_ready                    (rx_pcs_ready[PORT_8]),
   .o_p8_tx_pll_locked                 (tx_pll_locked[PORT_8]),
   .i_p8_tx_rst_n                      (~handshaked_tx_rst[PORT_8]),
   .i_p8_rx_rst_n                      (~handshaked_rx_rst[PORT_8]),
   .o_p8_rx_rst_ack_n                  (rx_rst_ack_n[PORT_8]),
   .o_p8_tx_rst_ack_n                  (tx_rst_ack_n[PORT_8]),
   .o_p8_ereset_n                      (),
   .o_p8_clk_pll                       (clk_pll[PORT_8]),
   .o_p8_clk_tx_div                    (clk_tx_div[PORT_8]),
   .o_p8_clk_rec_div64                 (clk_rec_div64[PORT_8]),
   .o_p8_clk_rec_div                   (clk_rec_div[PORT_8]),
   .port8_led_speed                    (led_speed[PORT_8]),
   .port8_led_status                   (led_status[PORT_8]),
`endif
`ifdef INCLUDE_HSSI_PORT_9
   .p9_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_9].clk),
   .p9_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_9].rst_n),
   .p9_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_9].tx.tvalid),
   .p9_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_9].tready),
   .p9_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_9].tx.tdata),
   .p9_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_9].tx.tkeep),
   .p9_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_9].tx.tlast),
   .p9_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_9].tx.tuser.client),
   .p9_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_9].clk),
   .p9_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_9].rst_n),
   .p9_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_9].rx.tvalid),
   .p9_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_9].rx.tdata),
   .p9_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_9].rx.tkeep),
   .p9_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_9].rx.tlast),
   .p9_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_9].rx.tuser.client),
   .p9_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_9].rx.tuser.sts),
   .i_p9_tx_pause                      (hssi_fc[PORT_9].tx_pause),
   .i_p9_tx_pfc                        (hssi_fc[PORT_9].tx_pfc),
   .o_p9_rx_pause                      (hssi_fc[PORT_9].rx_pause),
   .o_p9_rx_pfc                        (hssi_fc[PORT_9].rx_pfc),
   .p9_tx_serial                       (serial_tx_p[PORT_9]),
   .p9_tx_serial_n                     (serial_tx_n[PORT_9]),
   .p9_rx_serial                       (serial_rx_p[PORT_9]),
   .p9_rx_serial_n                     (serial_rx_n[PORT_9]),
   .p9_tx_lanes_stable                 (tx_lanes_stable[PORT_9]),
   .p9_rx_pcs_ready                    (rx_pcs_ready[PORT_9]),
   .o_p9_tx_pll_locked                 (tx_pll_locked[PORT_9]),
   .i_p9_tx_rst_n                      (~handshaked_tx_rst[PORT_9]),
   .i_p9_rx_rst_n                      (~handshaked_rx_rst[PORT_9]),
   .o_p9_rx_rst_ack_n                  (rx_rst_ack_n[PORT_9]),
   .o_p9_tx_rst_ack_n                  (tx_rst_ack_n[PORT_9]),
   .o_p9_ereset_n                      (),
   .o_p9_clk_pll                       (clk_pll[PORT_9]),
   .o_p9_clk_tx_div                    (clk_tx_div[PORT_9]),
   .o_p9_clk_rec_div64                 (clk_rec_div64[PORT_9]),
   .o_p9_clk_rec_div                   (clk_rec_div[PORT_9]),
   .port9_led_speed                    (led_speed[PORT_9]),
   .port9_led_status                   (led_status[PORT_9]),
`endif
`ifdef INCLUDE_HSSI_PORT_10
   .p10_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_10].clk),
   .p10_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_10].rst_n),
   .p10_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_10].tx.tvalid),
   .p10_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_10].tready),
   .p10_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_10].tx.tdata),
   .p10_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_10].tx.tkeep),
   .p10_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_10].tx.tlast),
   .p10_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_10].tx.tuser.client),
   .p10_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_10].clk),
   .p10_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_10].rst_n),
   .p10_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_10].rx.tvalid),
   .p10_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_10].rx.tdata),
   .p10_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_10].rx.tkeep),
   .p10_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_10].rx.tlast),
   .p10_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_10].rx.tuser.client),
   .p10_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_10].rx.tuser.sts),
   .i_p10_tx_pause                      (hssi_fc[PORT_10].tx_pause),
   .i_p10_tx_pfc                        (hssi_fc[PORT_10].tx_pfc),
   .o_p10_rx_pause                      (hssi_fc[PORT_10].rx_pause),
   .o_p10_rx_pfc                        (hssi_fc[PORT_10].rx_pfc),
   .p10_tx_serial                       (serial_tx_p[PORT_10]),
   .p10_tx_serial_n                     (serial_tx_n[PORT_10]),
   .p10_rx_serial                       (serial_rx_p[PORT_10]),
   .p10_rx_serial_n                     (serial_rx_n[PORT_10]),
   .p10_tx_lanes_stable                 (tx_lanes_stable[PORT_10]),
   .p10_rx_pcs_ready                    (rx_pcs_ready[PORT_10]),
   .o_p10_tx_pll_locked                 (tx_pll_locked[PORT_10]),
   .i_p10_tx_rst_n                      (~handshaked_tx_rst[PORT_10]),
   .i_p10_rx_rst_n                      (~handshaked_rx_rst[PORT_10]),
   .o_p10_rx_rst_ack_n                  (rx_rst_ack_n[PORT_10]),
   .o_p10_tx_rst_ack_n                  (tx_rst_ack_n[PORT_10]),
   .o_p10_ereset_n                      (),
   .o_p10_clk_pll                       (clk_pll[PORT_10]),
   .o_p10_clk_tx_div                    (clk_tx_div[PORT_10]),
   .o_p10_clk_rec_div64                 (clk_rec_div64[PORT_10]),
   .o_p10_clk_rec_div                   (clk_rec_div[PORT_10]),
   .port10_led_speed                    (led_speed[PORT_10]),
   .port10_led_status                   (led_status[PORT_10]),
`endif
`ifdef INCLUDE_HSSI_PORT_11
   .p11_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_11].clk),
   .p11_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_11].rst_n),
   .p11_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_11].tx.tvalid),
   .p11_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_11].tready),
   .p11_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_11].tx.tdata),
   .p11_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_11].tx.tkeep),
   .p11_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_11].tx.tlast),
   .p11_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_11].tx.tuser.client),
   .p11_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_11].clk),
   .p11_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_11].rst_n),
   .p11_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_11].rx.tvalid),
   .p11_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_11].rx.tdata),
   .p11_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_11].rx.tkeep),
   .p11_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_11].rx.tlast),
   .p11_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_11].rx.tuser.client),
   .p11_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_11].rx.tuser.sts),
   .i_p11_tx_pause                      (hssi_fc[PORT_11].tx_pause),
   .i_p11_tx_pfc                        (hssi_fc[PORT_11].tx_pfc),
   .o_p11_rx_pause                      (hssi_fc[PORT_11].rx_pause),
   .o_p11_rx_pfc                        (hssi_fc[PORT_11].rx_pfc),
   .p11_tx_serial                       (serial_tx_p[PORT_11]),
   .p11_tx_serial_n                     (serial_tx_n[PORT_11]),
   .p11_rx_serial                       (serial_rx_p[PORT_11]),
   .p11_rx_serial_n                     (serial_rx_n[PORT_11]),
   .p11_tx_lanes_stable                 (tx_lanes_stable[PORT_11]),
   .p11_rx_pcs_ready                    (rx_pcs_ready[PORT_11]),
   .o_p11_tx_pll_locked                 (tx_pll_locked[PORT_11]),
   .i_p11_tx_rst_n                      (~handshaked_tx_rst[PORT_11]),
   .i_p11_rx_rst_n                      (~handshaked_rx_rst[PORT_11]),
   .o_p11_rx_rst_ack_n                  (rx_rst_ack_n[PORT_11]),
   .o_p11_tx_rst_ack_n                  (tx_rst_ack_n[PORT_11]),
   .o_p11_ereset_n                      (),
   .o_p11_clk_pll                       (clk_pll[PORT_11]),
   .o_p11_clk_tx_div                    (clk_tx_div[PORT_11]),
   .o_p11_clk_rec_div64                 (clk_rec_div64[PORT_11]),
   .o_p11_clk_rec_div                   (clk_rec_div[PORT_11]),
   .port11_led_speed                    (led_speed[PORT_11]),
   .port11_led_status                   (led_status[PORT_11]),
`endif
`ifdef INCLUDE_HSSI_PORT_12
   .p12_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_12].clk),
   .p12_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_12].rst_n),
   .p12_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_12].tx.tvalid),
   .p12_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_12].tready),
   .p12_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_12].tx.tdata),
   .p12_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_12].tx.tkeep),
   .p12_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_12].tx.tlast),
   .p12_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_12].tx.tuser.client),
   .p12_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_12].clk),
   .p12_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_12].rst_n),
   .p12_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_12].rx.tvalid),
   .p12_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_12].rx.tdata),
   .p12_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_12].rx.tkeep),
   .p12_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_12].rx.tlast),
   .p12_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_12].rx.tuser.client),
   .p12_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_12].rx.tuser.sts),
   .i_p12_tx_pause                      (hssi_fc[PORT_12].tx_pause),
   .i_p12_tx_pfc                        (hssi_fc[PORT_12].tx_pfc),
   .o_p12_rx_pause                      (hssi_fc[PORT_12].rx_pause),
   .o_p12_rx_pfc                        (hssi_fc[PORT_12].rx_pfc),
   .p12_tx_serial                       (serial_tx_p[PORT_12]),
   .p12_tx_serial_n                     (serial_tx_n[PORT_12]),
   .p12_rx_serial                       (serial_rx_p[PORT_12]),
   .p12_rx_serial_n                     (serial_rx_n[PORT_12]),
   .p12_tx_lanes_stable                 (tx_lanes_stable[PORT_12]),
   .p12_rx_pcs_ready                    (rx_pcs_ready[PORT_12]),
   .o_p12_tx_pll_locked                 (tx_pll_locked[PORT_12]),
   .i_p12_tx_rst_n                      (~handshaked_tx_rst[PORT_12]),
   .i_p12_rx_rst_n                      (~handshaked_rx_rst[PORT_12]),
   .o_p12_rx_rst_ack_n                  (rx_rst_ack_n[PORT_12]),
   .o_p12_tx_rst_ack_n                  (tx_rst_ack_n[PORT_12]),
   .o_p12_ereset_n                      (),
   .o_p12_clk_pll                       (clk_pll[PORT_12]),
   .o_p12_clk_tx_div                    (clk_tx_div[PORT_12]),
   .o_p12_clk_rec_div64                 (clk_rec_div64[PORT_12]),
   .o_p12_clk_rec_div                   (clk_rec_div[PORT_12]),
   .port12_led_speed                    (led_speed[PORT_12]),
   .port12_led_status                   (led_status[PORT_12]),
`endif
`ifdef INCLUDE_HSSI_PORT_13
   .p13_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_13].clk),
   .p13_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_13].rst_n),
   .p13_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_13].tx.tvalid),
   .p13_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_13].tready),
   .p13_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_13].tx.tdata),
   .p13_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_13].tx.tkeep),
   .p13_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_13].tx.tlast),
   .p13_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_13].tx.tuser.client),
   .p13_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_13].clk),
   .p13_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_13].rst_n),
   .p13_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_13].rx.tvalid),
   .p13_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_13].rx.tdata),
   .p13_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_13].rx.tkeep),
   .p13_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_13].rx.tlast),
   .p13_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_13].rx.tuser.client),
   .p13_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_13].rx.tuser.sts),
   .i_p13_tx_pause                      (hssi_fc[PORT_13].tx_pause),
   .i_p13_tx_pfc                        (hssi_fc[PORT_13].tx_pfc),
   .o_p13_rx_pause                      (hssi_fc[PORT_13].rx_pause),
   .o_p13_rx_pfc                        (hssi_fc[PORT_13].rx_pfc),
   .p13_tx_serial                       (serial_tx_p[PORT_13]),
   .p13_tx_serial_n                     (serial_tx_n[PORT_13]),
   .p13_rx_serial                       (serial_rx_p[PORT_13]),
   .p13_rx_serial_n                     (serial_rx_n[PORT_13]),
   .p13_tx_lanes_stable                 (tx_lanes_stable[PORT_13]),
   .p13_rx_pcs_ready                    (rx_pcs_ready[PORT_13]),
   .o_p13_tx_pll_locked                 (tx_pll_locked[PORT_13]),
   .i_p13_tx_rst_n                      (~handshaked_tx_rst[PORT_13]),
   .i_p13_rx_rst_n                      (~handshaked_rx_rst[PORT_13]),
   .o_p13_rx_rst_ack_n                  (rx_rst_ack_n[PORT_13]),
   .o_p13_tx_rst_ack_n                  (tx_rst_ack_n[PORT_13]),
   .o_p13_ereset_n                      (),
   .o_p13_clk_pll                       (clk_pll[PORT_13]),
   .o_p13_clk_tx_div                    (clk_tx_div[PORT_13]),
   .o_p13_clk_rec_div64                 (clk_rec_div64[PORT_13]),
   .o_p13_clk_rec_div                   (clk_rec_div[PORT_13]),
   .port13_led_speed                    (led_speed[PORT_13]),
   .port13_led_status                   (led_status[PORT_13]),
`endif
`ifdef INCLUDE_HSSI_PORT_14
   .p14_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_14].clk),
   .p14_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_14].rst_n),
   .p14_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_14].tx.tvalid),
   .p14_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_14].tready),
   .p14_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_14].tx.tdata),
   .p14_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_14].tx.tkeep),
   .p14_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_14].tx.tlast),
   .p14_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_14].tx.tuser.client),
   .p14_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_14].clk),
   .p14_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_14].rst_n),
   .p14_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_14].rx.tvalid),
   .p14_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_14].rx.tdata),
   .p14_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_14].rx.tkeep),
   .p14_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_14].rx.tlast),
   .p14_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_14].rx.tuser.client),
   .p14_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_14].rx.tuser.sts),
   .i_p14_tx_pause                      (hssi_fc[PORT_14].tx_pause),
   .i_p14_tx_pfc                        (hssi_fc[PORT_14].tx_pfc),
   .o_p14_rx_pause                      (hssi_fc[PORT_14].rx_pause),
   .o_p14_rx_pfc                        (hssi_fc[PORT_14].rx_pfc),
   .p14_tx_serial                       (serial_tx_p[PORT_14]),
   .p14_tx_serial_n                     (serial_tx_n[PORT_14]),
   .p14_rx_serial                       (serial_rx_p[PORT_14]),
   .p14_rx_serial_n                     (serial_rx_n[PORT_14]),
   .p14_tx_lanes_stable                 (tx_lanes_stable[PORT_14]),
   .p14_rx_pcs_ready                    (rx_pcs_ready[PORT_14]),
   .o_p14_tx_pll_locked                 (tx_pll_locked[PORT_14]),
   .i_p14_tx_rst_n                      (~handshaked_tx_rst[PORT_14]),
   .i_p14_rx_rst_n                      (~handshaked_rx_rst[PORT_14]),
   .o_p14_rx_rst_ack_n                  (rx_rst_ack_n[PORT_14]),
   .o_p14_tx_rst_ack_n                  (tx_rst_ack_n[PORT_14]),
   .o_p14_ereset_n                      (),
   .o_p14_clk_pll                       (clk_pll[PORT_14]),
   .o_p14_clk_tx_div                    (clk_tx_div[PORT_14]),
   .o_p14_clk_rec_div64                 (clk_rec_div64[PORT_14]),
   .o_p14_clk_rec_div                   (clk_rec_div[PORT_14]),
   .port14_led_speed                    (led_speed[PORT_14]),
   .port14_led_status                   (led_status[PORT_14]),
`endif
`ifdef INCLUDE_HSSI_PORT_15
   .p15_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_15].clk),
   .p15_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_15].rst_n),
   .p15_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_15].tx.tvalid),
   .p15_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_15].tready),
   .p15_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_15].tx.tdata),
   .p15_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_15].tx.tkeep),
   .p15_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_15].tx.tlast),
   .p15_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_15].tx.tuser.client),
   .p15_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_15].clk),
   .p15_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_15].rst_n),
   .p15_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_15].rx.tvalid),
   .p15_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_15].rx.tdata),
   .p15_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_15].rx.tkeep),
   .p15_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_15].rx.tlast),
   .p15_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_15].rx.tuser.client),
   .p15_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_15].rx.tuser.sts),
   .i_p15_tx_pause                      (hssi_fc[PORT_15].tx_pause),
   .i_p15_tx_pfc                        (hssi_fc[PORT_15].tx_pfc),
   .o_p15_rx_pause                      (hssi_fc[PORT_15].rx_pause),
   .o_p15_rx_pfc                        (hssi_fc[PORT_15].rx_pfc),
   .p15_tx_serial                       (serial_tx_p[PORT_15]),
   .p15_tx_serial_n                     (serial_tx_n[PORT_15]),
   .p15_rx_serial                       (serial_rx_p[PORT_15]),
   .p15_rx_serial_n                     (serial_rx_n[PORT_15]),
   .p15_tx_lanes_stable                 (tx_lanes_stable[PORT_15]),
   .p15_rx_pcs_ready                    (rx_pcs_ready[PORT_15]),
   .o_p15_tx_pll_locked                 (tx_pll_locked[PORT_15]),
   .i_p15_tx_rst_n                      (~handshaked_tx_rst[PORT_15]),
   .i_p15_rx_rst_n                      (~handshaked_rx_rst[PORT_15]),
   .o_p15_rx_rst_ack_n                  (rx_rst_ack_n[PORT_15]),
   .o_p15_tx_rst_ack_n                  (tx_rst_ack_n[PORT_15]),
   .o_p15_ereset_n                      (),
   .o_p15_clk_pll                       (clk_pll[PORT_15]),
   .o_p15_clk_tx_div                    (clk_tx_div[PORT_15]),
   .o_p15_clk_rec_div64                 (clk_rec_div64[PORT_15]),
   .o_p15_clk_rec_div                   (clk_rec_div[PORT_15]),
   .port15_led_speed                    (led_speed[PORT_15]),
   .port15_led_status                   (led_status[PORT_15]),
`endif
   .subsystem_cold_rst_n               (~handshaked_cold_rst),
   .subsystem_cold_rst_ack_n           (cold_rst_ack_n),
   .i_clk_ref                          (i_hssi_clk_ref)
`ifdef INCLUDE_HSSI_PORT_0_PTP
   ,.p0_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_0].tvalid),
   .p0_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_0].tdata),
   `ifndef ETH_100G
   .p0_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_0].tvalid),
   .p0_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_0].tdata),
   .i_p0_clk_tx_tod                    (clk_tx_tod[PORT_0]),
   .i_p0_clk_rx_tod                    (clk_rx_tod[PORT_0]),
   .i_p0_clk_ptp_sample                (p0_clk_ptp_sample),
   `endif
   .o_ehip0_ptp_clk_pll                (ehip0_ptp_clk_pll),
   .o_ehip0_ptp_clk_tx_div             (ehip0_ptp_clk_tx_div),
   .o_ehip0_ptp_clk_rec_div64          (ehip0_ptp_clk_rec_div64),
   .o_ehip0_ptp_clk_rec_div            (ehip0_ptp_clk_rec_div),
   .p0_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_0].tx.tuser.ptp),
   .p0_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_0].tx.tuser.ptp_extended),
   .p0_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_0].tvalid),
   .p0_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_0].tdata),
   .p0_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_0].tvalid),
   .p0_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_0].tdata),
   .o_p0_tx_ptp_ready                  (tx_ptp_ready[PORT_0]),
   .o_p0_rx_ptp_ready                  (rx_ptp_ready[PORT_0])
`endif
`ifdef INCLUDE_HSSI_PORT_1_PTP
   ,.p1_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_1].tvalid),
   .p1_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_1].tdata),
   .p1_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_1].tvalid),
   .p1_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_1].tdata),
   .i_p1_clk_tx_tod                    (clk_tx_tod[PORT_1]),
   .i_p1_clk_rx_tod                    (clk_rx_tod[PORT_1]),
   .p1_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_1].tx.tuser.ptp),
   .p1_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_1].tx.tuser.ptp_extended),
   .p1_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_1].tvalid),
   .p1_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_1].tdata),
   .p1_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_1].tvalid),
   .p1_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_1].tdata),
   .o_p1_tx_ptp_ready                  (tx_ptp_ready[PORT_1]),
   .o_p1_rx_ptp_ready                  (rx_ptp_ready[PORT_1])
`endif
`ifdef INCLUDE_HSSI_PORT_2_PTP
   ,.p2_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_2].tvalid),
   .p2_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_2].tdata),
   .p2_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_2].tvalid),
   .p2_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_2].tdata),
   .i_p2_clk_tx_tod                    (clk_tx_tod[PORT_2]),
   .i_p2_clk_rx_tod                    (clk_rx_tod[PORT_2]),
   .p2_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_2].tx.tuser.ptp),
   .p2_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_2].tx.tuser.ptp_extended),
   .p2_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_2].tvalid),
   .p2_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_2].tdata),
   .p2_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_2].tvalid),
   .p2_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_2].tdata),
   .o_p2_tx_ptp_ready                  (tx_ptp_ready[PORT_2]),
   .o_p2_rx_ptp_ready                  (rx_ptp_ready[PORT_2])
`endif
`ifdef INCLUDE_HSSI_PORT_3_PTP
   ,.p3_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_3].tvalid),
   .p3_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_3].tdata),
   .p3_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_3].tvalid),
   .p3_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_3].tdata),
   .i_p3_clk_tx_tod                    (clk_tx_tod[PORT_3]),
   .i_p3_clk_rx_tod                    (clk_rx_tod[PORT_3]),
   .p3_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_3].tx.tuser.ptp),
   .p3_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_3].tx.tuser.ptp_extended),
   .p3_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_3].tvalid),
   .p3_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_3].tdata),
   .p3_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_3].tvalid),
   .p3_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_3].tdata),
   .o_p3_tx_ptp_ready                  (tx_ptp_ready[PORT_3]),
   .o_p3_rx_ptp_ready                  (rx_ptp_ready[PORT_3])
`endif
`ifdef INCLUDE_HSSI_PORT_4_PTP
   ,.p4_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_4].tvalid),
   .p4_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_4].tdata),
   .o_ehip1_ptp_clk_pll                (ehip1_ptp_clk_pll),
   .o_ehip1_ptp_clk_tx_div             (ehip1_ptp_clk_tx_div),
   .o_ehip1_ptp_clk_rec_div64          (ehip1_ptp_clk_rec_div64),
   .o_ehip1_ptp_clk_rec_div            (ehip1_ptp_clk_rec_div),
   `ifndef ETH_100G
   .p4_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_4].tvalid),
   .p4_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_4].tdata),
   .i_p4_clk_tx_tod                    (clk_tx_tod[PORT_4]),
   .i_p4_clk_rx_tod                    (clk_rx_tod[PORT_4]),
   .i_p4_clk_ptp_sample                (p4_clk_ptp_sample),
   `endif
   .p4_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_4].tx.tuser.ptp),
   .p4_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_4].tx.tuser.ptp_extended),
   .p4_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_4].tvalid),
   .p4_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_4].tdata),
   .p4_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_4].tvalid),
   .p4_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_4].tdata),
   .o_p4_tx_ptp_ready                  (tx_ptp_ready[PORT_4]),
   .o_p4_rx_ptp_ready                  (rx_ptp_ready[PORT_4])
`endif
`ifdef INCLUDE_HSSI_PORT_5_PTP
   ,.p5_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_5].tvalid),
   .p5_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_5].tdata),
   .p5_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_5].tvalid),
   .p5_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_5].tdata),
   .i_p5_clk_tx_tod                    (clk_tx_tod[PORT_5]),
   .i_p5_clk_rx_tod                    (clk_rx_tod[PORT_5]),
   .p5_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_5].tx.tuser.ptp),
   .p5_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_5].tx.tuser.ptp_extended),
   .p5_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_5].tvalid),
   .p5_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_5].tdata),
   .p5_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_5].tvalid),
   .p5_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_5].tdata),
   .o_p5_tx_ptp_ready                  (tx_ptp_ready[PORT_5]),
   .o_p5_rx_ptp_ready                  (rx_ptp_ready[PORT_5])
`endif
`ifdef INCLUDE_HSSI_PORT_6_PTP
   ,.p6_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_6].tvalid),
   .p6_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_6].tdata),
   .p6_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_6].tvalid),
   .p6_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_6].tdata),
   .i_p6_clk_tx_tod                    (clk_tx_tod[PORT_6]),
   .i_p6_clk_rx_tod                    (clk_rx_tod[PORT_6]),
   .p6_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_6].tx.tuser.ptp),
   .p6_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_6].tx.tuser.ptp_extended),
   .p6_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_6].tvalid),
   .p6_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_6].tdata),
   .p6_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_6].tvalid),
   .p6_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_6].tdata),
   .o_p6_tx_ptp_ready                  (tx_ptp_ready[PORT_6]),
   .o_p6_rx_ptp_ready                  (rx_ptp_ready[PORT_6])
`endif
`ifdef INCLUDE_HSSI_PORT_7_PTP
   ,.p7_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_7].tvalid),
   .p7_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_7].tdata),
   .p7_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_7].tvalid),
   .p7_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_7].tdata),
   .i_p7_clk_tx_tod                    (clk_tx_tod[PORT_7]),
   .i_p7_clk_rx_tod                    (clk_rx_tod[PORT_7]),
   .p7_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_7].tx.tuser.ptp),
   .p7_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_7].tx.tuser.ptp_extended),
   .p7_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_7].tvalid),
   .p7_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_7].tdata),
   .p7_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_7].tvalid),
   .p7_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_7].tdata),
   .o_p7_tx_ptp_ready                  (tx_ptp_ready[PORT_7]),
   .o_p7_rx_ptp_ready                  (rx_ptp_ready[PORT_7])
`endif
`ifdef INCLUDE_HSSI_PORT_8_PTP
   ,.p8_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_8].tvalid),
   .p8_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_8].tdata),
   .o_ehip2_ptp_clk_pll                (ehip2_ptp_clk_pll),
   .o_ehip2_ptp_clk_tx_div             (ehip2_ptp_clk_tx_div),
   .o_ehip2_ptp_clk_rec_div64          (ehip2_ptp_clk_rec_div64),
   .o_ehip2_ptp_clk_rec_div            (ehip2_ptp_clk_rec_div),
   `ifndef ETH_100G
   .p8_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_8].tvalid),
   .p8_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_8].tdata),
   .i_p8_clk_tx_tod                    (clk_tx_tod[PORT_8]),
   .i_p8_clk_rx_tod                    (clk_rx_tod[PORT_8]),
   .i_p8_clk_ptp_sample                (p8_clk_ptp_sample),
   `endif
   .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_8].tx.tuser.ptp),
   .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_8].tx.tuser.ptp_extended),
   .p8_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_8].tvalid),
   .p8_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_8].tdata),
   .p8_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_8].tvalid),
   .p8_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_8].tdata),
   .o_p8_tx_ptp_ready                  (tx_ptp_ready[PORT_8]),
   .o_p8_rx_ptp_ready                  (rx_ptp_ready[PORT_8])
`endif
`ifdef INCLUDE_HSSI_PORT_9_PTP
   ,.p9_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_9].tvalid),
   .p9_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_9].tdata),   
   .p9_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_9].tvalid),
   .p9_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_9].tdata),
   .i_p9_clk_tx_tod                    (clk_tx_tod[PORT_9]),
   .i_p9_clk_rx_tod                    (clk_rx_tod[PORT_9]),
   .p9_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_9].tx.tuser.ptp),
   .p9_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_9].tx.tuser.ptp_extended),
   .p9_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_9].tvalid),
   .p9_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_9].tdata),
   .p9_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_9].tvalid),
   .p9_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_9].tdata),
   .o_p9_tx_ptp_ready                  (tx_ptp_ready[PORT_9]),
   .o_p9_rx_ptp_ready                  (rx_ptp_ready[PORT_9])
`endif
`ifdef INCLUDE_HSSI_PORT_10_PTP
   ,.p10_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_10].tvalid),
   .p10_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_10].tdata),
   .p10_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_10].tvalid),
   .p10_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_10].tdata),
   .i_p10_clk_tx_tod                    (clk_tx_tod[PORT_10]),
   .i_p10_clk_rx_tod                    (clk_rx_tod[PORT_10]),
   `ifdef ETH_25G
   .i_p10_clk_ptp_sample                (p10_clk_ptp_sample),
   `endif
   .p10_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_10].tx.tuser.ptp),
   .p10_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_10].tx.tuser.ptp_extended),
   .p10_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_10].tvalid),
   .p10_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_10].tdata),
   .p10_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_10].tvalid),
   .p10_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_10].tdata),
   .o_p10_tx_ptp_ready                  (tx_ptp_ready[PORT_10]),
   .o_p10_rx_ptp_ready                  (rx_ptp_ready[PORT_10])
`endif
`ifdef INCLUDE_HSSI_PORT_11_PTP
   ,.p11_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_11].tvalid),
   .p11_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_11].tdata),
   .p11_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_11].tvalid),
   .p11_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_11].tdata),
   .i_p11_clk_tx_tod                    (clk_tx_tod[PORT_11]),
   .i_p11_clk_rx_tod                    (clk_rx_tod[PORT_11]),
   .p11_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_11].tx.tuser.ptp),
   .p11_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_11].tx.tuser.ptp_extended),
   .p11_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_11].tvalid),
   .p11_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_11].tdata),
   .p11_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_11].tvalid),
   .p11_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_11].tdata),
   .o_p11_tx_ptp_ready                  (tx_ptp_ready[PORT_11]),
   .o_p11_rx_ptp_ready                  (rx_ptp_ready[PORT_11])
`endif
`ifdef INCLUDE_HSSI_PORT_12_PTP
   ,.p12_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_12].tvalid),
   .p12_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_12].tdata),
   .o_ehip3_ptp_clk_pll                 (ehip3_ptp_clk_pll),
   .o_ehip3_ptp_clk_tx_div              (ehip3_ptp_clk_tx_div),
   .o_ehip3_ptp_clk_rec_div64           (ehip3_ptp_clk_rec_div64),
   .o_ehip3_ptp_clk_rec_div             (ehip3_ptp_clk_rec_div),
   `ifndef ETH_100G
   .p12_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_12].tvalid),
   .p12_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_12].tdata),
   .i_p12_clk_tx_tod                    (clk_tx_tod[PORT_12]),
   .i_p12_clk_rx_tod                    (clk_rx_tod[PORT_12]),
   .i_p12_clk_ptp_sample                (p12_clk_ptp_sample),
   `endif
   .p12_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_12].tx.tuser.ptp),
   .p12_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_12].tx.tuser.ptp_extended),
   .p12_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_12].tvalid),
   .p12_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_12].tdata),
   .p12_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_12].tvalid),
   .p12_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_12].tdata),
   .o_p12_tx_ptp_ready                  (tx_ptp_ready[PORT_12]),
   .o_p12_rx_ptp_ready                  (rx_ptp_ready[PORT_12])
`endif
`ifdef INCLUDE_HSSI_PORT_13_PTP
   ,.p13_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_13].tvalid),
   .p13_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_13].tdata),   
   .p13_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_13].tvalid),
   .p13_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_13].tdata),
   .i_p13_clk_tx_tod                    (clk_tx_tod[PORT_13]),
   .i_p13_clk_rx_tod                    (clk_rx_tod[PORT_13]),
   .p13_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_13].tx.tuser.ptp),
   .p13_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_13].tx.tuser.ptp_extended),
   .p13_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_13].tvalid),
   .p13_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_13].tdata),
   .p13_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_13].tvalid),
   .p13_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_13].tdata),
   .o_p13_tx_ptp_ready                  (tx_ptp_ready[PORT_13]),
   .o_p13_rx_ptp_ready                  (rx_ptp_ready[PORT_13])
`endif
`ifdef INCLUDE_HSSI_PORT_14_PTP
   ,.p14_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_14].tvalid),
   .p14_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_14].tdata),
   .p14_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_14].tvalid),
   .p14_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_14].tdata),
   .i_p14_clk_tx_tod                    (clk_tx_tod[PORT_14]),
   .i_p14_clk_rx_tod                    (clk_rx_tod[PORT_14]),
   .p14_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_14].tx.tuser.ptp),
   .p14_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_14].tx.tuser.ptp_extended),
   .p14_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_14].tvalid),
   .p14_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_14].tdata),
   .p14_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_14].tvalid),
   .p14_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_14].tdata),
   .o_p14_tx_ptp_ready                  (tx_ptp_ready[PORT_14]),
   .o_p14_rx_ptp_ready                  (rx_ptp_ready[PORT_14])
`endif
`ifdef INCLUDE_HSSI_PORT_15_PTP
   ,.p15_app_ss_st_txtod_tvalid         (hssi_ptp_tx_tod[PORT_15].tvalid),
   .p15_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod[PORT_15].tdata),
   .p15_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod[PORT_15].tvalid),
   .p15_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod[PORT_15].tdata),
   .i_p15_clk_tx_tod                    (clk_tx_tod[PORT_15]),
   .i_p15_clk_rx_tod                    (clk_rx_tod[PORT_15]),
   .p15_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx[PORT_15].tx.tuser.ptp),
   .p15_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx[PORT_15].tx.tuser.ptp_extended),
   .p15_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts[PORT_15].tvalid),
   .p15_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts[PORT_15].tdata),
   .p15_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts[PORT_15].tvalid),
   .p15_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts[PORT_15].tdata),
   .o_p15_tx_ptp_ready                  (tx_ptp_ready[PORT_15]),
   .o_p15_rx_ptp_ready                  (rx_ptp_ready[PORT_15])
`endif
);

//----------------------------------------
// Serial signal mapping to QSFP
//----------------------------------------
`ifdef ETH_100G //QSFP 2x1,
	// QSFP
	`ifdef INCLUDE_HSSI_PORT_0
	assign serial_rx_p[PORT_0]      = qsfp_serial[0].rx_p;
	assign serial_rx_n[PORT_0]      = 1'b0;
	assign qsfp_serial[0].tx_p      = serial_tx_p[PORT_0];
	`endif
	`ifdef INCLUDE_HSSI_PORT_4
	assign serial_rx_p[PORT_4]      = qsfp_serial[1].rx_p;
	assign serial_rx_n[PORT_4]      = 1'b0;
	assign qsfp_serial[1].tx_p      = serial_tx_p[PORT_4];
	`endif
`else
	// QSFP
	`ifdef INCLUDE_HSSI_PORT_0
	assign serial_rx_p[PORT_0]      = qsfp_serial[0].rx_p[0];
	assign serial_rx_n[PORT_0]      = 1'b0;
	assign qsfp_serial[0].tx_p[0]   = serial_tx_p[PORT_0];
	`endif
	`ifdef INCLUDE_HSSI_PORT_1
	assign serial_rx_p[PORT_1]      = qsfp_serial[0].rx_p[1];
	assign serial_rx_n[PORT_1]      = 1'b0;
	assign qsfp_serial[0].tx_p[1]   = serial_tx_p[PORT_1];
	`endif
	`ifdef INCLUDE_HSSI_PORT_2
	assign serial_rx_p[PORT_2]      = qsfp_serial[0].rx_p[2];
	assign serial_rx_n[PORT_2]      = 1'b0;
	assign qsfp_serial[0].tx_p[2]   = serial_tx_p[PORT_2];
	`endif
	`ifdef INCLUDE_HSSI_PORT_3
	assign serial_rx_p[PORT_3]      = qsfp_serial[0].rx_p[3];
	assign serial_rx_n[PORT_3]      = 1'b0;
	assign qsfp_serial[0].tx_p[3]   = serial_tx_p[PORT_3];
	`endif
	`ifdef INCLUDE_HSSI_PORT_4
	assign serial_rx_p[PORT_4]     = qsfp_serial[1].rx_p[0];
	assign serial_rx_n[PORT_4]     = 1'b0;
	assign qsfp_serial[1].tx_p[0]  = serial_tx_p[PORT_4];
	`endif
	`ifdef INCLUDE_HSSI_PORT_5
	assign serial_rx_p[PORT_5]     = qsfp_serial[1].rx_p[1];
	assign serial_rx_n[PORT_5]     = 1'b0;
	assign qsfp_serial[1].tx_p[1]  = serial_tx_p[PORT_5];
	`endif
	`ifdef INCLUDE_HSSI_PORT_6
	assign serial_rx_p[PORT_6]      = qsfp_serial[1].rx_p[2];
	assign serial_rx_n[PORT_6]      = 1'b0;
	assign qsfp_serial[1].tx_p[2]   = serial_tx_p[PORT_6];
	`endif
	`ifdef INCLUDE_HSSI_PORT_7
	assign serial_rx_p[PORT_7]      = qsfp_serial[1].rx_p[3];
	assign serial_rx_n[PORT_7]      = 1'b0;
	assign qsfp_serial[1].tx_p[3]   = serial_tx_p[PORT_7];
	`endif
`endif
assign o_qsfp_speed_green[0]    = 1'b1
											 `ifdef INCLUDE_HSSI_PORT_0 & led_speed[PORT_0][2] `endif
											 `ifdef INCLUDE_HSSI_PORT_1 & led_speed[PORT_1][2] `endif
											 `ifdef INCLUDE_HSSI_PORT_2 & led_speed[PORT_2][2] `endif
											 `ifdef INCLUDE_HSSI_PORT_3 & led_speed[PORT_3][2] `endif;
assign o_qsfp_speed_yellow[0]    = 1'b1
											  `ifdef INCLUDE_HSSI_PORT_0 & led_speed[PORT_0][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_1 & led_speed[PORT_1][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_2 & led_speed[PORT_2][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_3 & led_speed[PORT_3][1] `endif;
assign o_qsfp_activity_green[0]  = 1'b1
											  `ifdef INCLUDE_HSSI_PORT_0 & led_status[PORT_0][2] `endif
											  `ifdef INCLUDE_HSSI_PORT_1 & led_status[PORT_1][2] `endif
											  `ifdef INCLUDE_HSSI_PORT_2 & led_status[PORT_2][2] `endif
											  `ifdef INCLUDE_HSSI_PORT_3 & led_status[PORT_3][2] `endif;
assign o_qsfp_activity_red[0]    = 1'b0
											  `ifdef INCLUDE_HSSI_PORT_0 | led_status[PORT_0][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_1 | led_status[PORT_1][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_2 | led_status[PORT_2][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_3 | led_status[PORT_3][1] `endif;
assign o_qsfp_speed_green[1]    = 1'b1
											 `ifdef INCLUDE_HSSI_PORT_4 & led_speed[PORT_4][2] `endif
											 `ifdef INCLUDE_HSSI_PORT_5 & led_speed[PORT_5][2] `endif
											 `ifdef INCLUDE_HSSI_PORT_6 & led_speed[PORT_6][2] `endif
											 `ifdef INCLUDE_HSSI_PORT_7 & led_speed[PORT_7][2] `endif;
assign o_qsfp_speed_yellow[1]    = 1'b1
											  `ifdef INCLUDE_HSSI_PORT_4 & led_speed[PORT_4][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_5 & led_speed[PORT_5][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_6 & led_speed[PORT_6][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_7 & led_speed[PORT_7][1] `endif;
assign o_qsfp_activity_green[1]  = 1'b1
											  `ifdef INCLUDE_HSSI_PORT_4 & led_status[PORT_4][2] `endif
											  `ifdef INCLUDE_HSSI_PORT_5 & led_status[PORT_5][2] `endif
											  `ifdef INCLUDE_HSSI_PORT_6 & led_status[PORT_6][2] `endif
											  `ifdef INCLUDE_HSSI_PORT_7 & led_status[PORT_7][2] `endif;
assign o_qsfp_activity_red[1]    = 1'b0
											  `ifdef INCLUDE_HSSI_PORT_4 | led_status[PORT_4][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_5 | led_status[PORT_5][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_6 | led_status[PORT_6][1] `endif
											  `ifdef INCLUDE_HSSI_PORT_7 | led_status[PORT_7][1] `endif;

//----------------------------------------
// Recover clock mapping for SYNCE
//----------------------------------------
if (NUM_ETH_CHANNELS < 3) begin
   assign o_hssi_rec_clk[NUM_ETH_CHANNELS-1:0] = clk_rec_div64[NUM_ETH_CHANNELS-1:0];
   assign o_hssi_rec_clk[2:NUM_ETH_CHANNELS]   = {(3-NUM_ETH_CHANNELS){clk_rec_div64[NUM_ETH_CHANNELS-1:0]}};
end
else begin
   assign o_hssi_rec_clk = clk_rec_div64[2:0];
end

//----------------------------------------
// EHIP PLL clock and lock mapping for CPRI
//----------------------------------------
assign o_ehip_clk_806    = ehip0_ptp_clk_pll;
assign o_ehip_clk_403    = ehip0_ptp_clk_tx_div;
assign o_ehip_pll_locked = tx_pll_locked[0];

endmodule
