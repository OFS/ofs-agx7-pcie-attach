// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
// AFU module instantiates User Logic
//-----------------------------------------------------------------------------

`ifdef INCLUDE_HSSI
   `include "ofs_fim_eth_plat_defines.svh"
   import ofs_fim_eth_if_pkg::*;
`endif 

import pcie_ss_axis_pkg::*;

module afu_top #(
`ifdef INCLUDE_DDR4
   parameter AFU_MEM_CHANNEL = 1
`else
   parameter AFU_MEM_CHANNEL = 0
`endif
)(
   input wire                            SYS_REFCLK,
   input wire                            clk,
   input wire                            rst_n,
   input wire                            clk_div2,
   input wire                            rst_n_clk_div2,
      
   input wire                            clk_csr,
   input wire                            rst_n_csr,
   input wire                            pwr_good_csr_clk_n,
   input wire                            clk_50m,
   input wire                            rst_n_50m,

   input wire                            cpri_refclk_184_32m, // CPRI reference clock 184.32 MHz
   input wire                            cpri_refclk_153_6m , // CPRI reference clock 153.6 MHz

   //HPS Interfaces 
   ofs_fim_axi_mmio_if.slave             hps_axi4_mm_if ,
   ofs_fim_ace_lite_if.master            hps_ace_lite_if,

   // FLR 
   input  t_axis_pcie_flr                pcie_flr_req,
   output t_axis_pcie_flr                pcie_flr_rsp,
   output logic                          pr_parity_error,
   input  t_pcie_tag_mode                tag_mode,

   ofs_fim_axi_lite_if.master            apf_bpf_slv_if,
   ofs_fim_axi_lite_if.slave             apf_bpf_mst_if,

`ifdef INCLUDE_UART
   // UART
   ofs_uart_if.source	host_uart_if,
`endif

`ifdef INCLUDE_DDR4
   ofs_fim_emif_axi_mm_if.user         ext_mem_if [AFU_MEM_CHANNEL-1:0],
`endif

`ifdef INCLUDE_HPS
   input                                h2f_reset,
`endif

`ifdef INCLUDE_HSSI
   ofs_fim_hssi_ss_tx_axis_if.client    hssi_ss_st_tx [MAX_NUM_ETH_CHANNELS-1:0],
   ofs_fim_hssi_ss_rx_axis_if.client     hssi_ss_st_rx [MAX_NUM_ETH_CHANNELS-1:0],
   ofs_fim_hssi_fc_if.client             hssi_fc [MAX_NUM_ETH_CHANNELS-1:0],
   `ifdef INCLUDE_PTP
      ofs_fim_hssi_ptp_tx_tod_if.client     hssi_ptp_tx_tod [MAX_NUM_ETH_CHANNELS-1:0],
      ofs_fim_hssi_ptp_rx_tod_if.client     hssi_ptp_rx_tod [MAX_NUM_ETH_CHANNELS-1:0],
      ofs_fim_hssi_ptp_tx_egrts_if.client   hssi_ptp_tx_egrts [MAX_NUM_ETH_CHANNELS-1:0],
      ofs_fim_hssi_ptp_rx_ingrts_if.client  hssi_ptp_rx_ingrts [MAX_NUM_ETH_CHANNELS-1:0],
      input logic                           i_ehip_clk_806,
      input logic                           i_ehip_clk_403,
      input logic                           i_ehip_pll_locked,
   `endif
   input logic [MAX_NUM_ETH_CHANNELS-1:0] i_hssi_clk_pll,
`endif

   // PCIE AXI-S interfaces
   pcie_ss_axis_if.sink                  pcie_ss_axis_rxreq,
   pcie_ss_axis_if.sink                  pcie_ss_axis_rx,
   pcie_ss_axis_if.source                pcie_ss_axis_tx
);

pcie_ss_axis_if #(
    .DATA_W (PCIE_TDATA_WIDTH),
    .USER_W (PCIE_TUSER_WIDTH)
 ) mx2ho_tx_port (.clk(clk), .rst_n(rst_n));

pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
)  ho2mx_rxreq_port (.clk(clk), .rst_n(rst_n));

import ofs_fim_cfg_pkg::*;

import top_cfg_pkg::*;

//-------------------------------------------------------------------
// PF/VF Mapping Table 
//
//    +---------------------------------+
//    + Module          | PF/VF         +
//    +---------------------------------+
//    | ST2MM           | PF0           | 
//    | HE-MEM          | PF0-VF0       |
//    | HE-HSSI         | PF0-VF1       |
//    | HE-MEM_TG       | PF0-VF2       |
//    | HE-LB Dummy     | PF1-VF0       |
//    | HE-LB           | PF2           |
//    | <VirtIO LB>     | PF3           |
//    | HPS Copy Engine | PF4           |
//    +---------------------------------+
//
//-------------------------------------------------------------------

localparam MM_ADDR_WIDTH     = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH;
localparam MM_DATA_WIDTH     = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;
localparam NONPF0_MM_ADDR_WIDTH = ofs_fim_cfg_pkg::NONPF0_MMIO_ADDR_WIDTH;

localparam NUM_PF            = top_cfg_pkg::FIM_NUM_PF;
localparam NUM_VF            = top_cfg_pkg::FIM_NUM_VF;
localparam MAX_NUM_VF        = top_cfg_pkg::FIM_MAX_NUM_VF;

localparam MUX_NUM_FUNC      = NUM_PF + 1 + NUM_VF - PG_AFU_NUM_PORTS;
localparam PF_WIDTH          = (NUM_PF > 1) ? $clog2(NUM_PF) : 1;
localparam VF_WIDTH          = (NUM_VF > 1) ? $clog2(NUM_VF) : 1;

localparam PCIE_TDATA_WIDTH  = ofs_fim_cfg_pkg::PCIE_TDATA_WIDTH;
localparam PCIE_TUSER_WIDTH  = ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH;

localparam NUM_TAGS  = ofs_pcie_ss_cfg_pkg::PCIE_EP_MAX_TAGS;

localparam NUM_RTABLE_ENTRIES  = top_cfg_pkg::NUM_RTABLE_ENTRIES;
localparam pf_vf_mux_pkg::t_pfvf_rtable_entry [NUM_RTABLE_ENTRIES-1:0] PFVF_ROUTING_TABLE = top_cfg_pkg::get_pf_vf_entry_info();

//-------------------------------------
// Preserve clocks
//-------------------------------------

// Make sure all clocks are consumed, in case AFUs don't use them,
// to avoid Quartus problems.
(* noprune *) logic clk_div2_q1, clk_div2_q2;

always_ff @(posedge clk_div2) begin
   clk_div2_q1 <= clk_div2_q2;
   clk_div2_q2 <= !clk_div2_q1;
end

//-------------------------------------
// Internal signals
//-------------------------------------

// // A ports (PCIe SS RX traffic)
 pcie_ss_axis_if #(
    .DATA_W (PCIE_TDATA_WIDTH),
    .USER_W (PCIE_TUSER_WIDTH)
 ) pipe2fn_rx_a_port [NUM_SR_PORTS-1:0](.clk(clk), .rst_n(rst_n));

pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) mx2pipe_rx_a_port [MUX_NUM_FUNC-1:0](.clk(clk), .rst_n(rst_n));

// A ports (first tree of AFU TX ports)
pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) fn2pipe_tx_a_port [NUM_SR_PORTS-1:0](.clk(clk), .rst_n(rst_n));

pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) fn2mx_tx_a_port [MUX_NUM_FUNC-1:0](.clk(clk), .rst_n(rst_n));

// B PF/VF AFU side (local write completions)
pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) mx2fn_rx_b_port [MUX_NUM_FUNC-1:0](.clk(clk), .rst_n(rst_n));

// B ports (second tree of AFU TX ports)
pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) fn2mx_tx_b_port [MUX_NUM_FUNC-1:0](.clk(clk), .rst_n(rst_n));

pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) ho2mx_rx_remap (.clk(clk), .rst_n(rst_n));

pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) mx2ho_tx_remap[2](.clk(clk), .rst_n(rst_n));

// A/B arbiter local write commits to AFU
pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) arb2mx_rxreq_port(.clk(clk), .rst_n(rst_n));

pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) sr_afu_rx_b_port [NUM_SR_PORTS-1:0]( .clk(clk), .rst_n(rst_n));

pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH)
) sr_afu_tx_b_port [NUM_SR_PORTS-1:0](.clk(clk), .rst_n(rst_n));            // B AFU


logic [PG_AFU_NUM_PORTS-1:0] pg_func_pf_rst_n;       // Port gasket FLR PF reset
logic [PG_AFU_NUM_PORTS-1:0] pg_func_vf_rst_n;       // Port gasket FLR VF reset

logic [NUM_SR_PORTS-1:0] fim_afu_func_pf_rst_n;       // fim_afu_instances FLR PF reset
logic [NUM_SR_PORTS-1:0] fim_afu_func_vf_rst_n;       // fim_afu_instances FLR VF reset
logic [NUM_SR_PORTS-1:0] fim_afu_port_rst_n;
logic [NUM_SR_PORTS-1:0] fim_afu_port_rst_n_csr;

// AXI4-lite interfaces
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(MM_ADDR_WIDTH), .ARADDR_WIDTH(MM_ADDR_WIDTH)) apf_st2mm_mst_if(.clk(clk), .rst_n(rst_n));
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16))                       apf_st2mm_slv_if(.clk(clk), .rst_n(rst_n));
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16))                       apf_pgsk_slv_if(.clk(clk), .rst_n(rst_n));
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(MM_ADDR_WIDTH), .ARADDR_WIDTH(MM_ADDR_WIDTH)) apf_mctp_mst_if(.clk(clk), .rst_n(rst_n));
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(MM_ADDR_WIDTH), .ARADDR_WIDTH(MM_ADDR_WIDTH)) apf_uart_mst_if(.clk(clk), .rst_n(rst_n));
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(12), .ARADDR_WIDTH(12))                       apf_uart_slv_if(.clk(clk), .rst_n(rst_n));
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16))                       apf_achk_slv_if(.clk(clk), .rst_n(rst_n));
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16))                       apf_tod_slv_if(.clk(clk), .rst_n(rst_n));

logic [NUM_PF-1:0]              pf_flr_rst_n;
logic [NUM_PF-1:0][NUM_VF-1:0]  vf_flr_rst_n;

logic [1:0] pf_vf_fifo_err;
logic [1:0] pf_vf_fifo_perr;

    logic       sel_mmio_rsp;
    logic       read_flush_done;
    logic       afu_softreset;


//---------------------------------------------------------------------------------------

//                                  Modules instances
//---------------------------------------------------------------------------------------

//----------------------------------------------------------------
// FLR reset controller 
//----------------------------------------------------------------
flr_rst_mgr #(
   .NUM_PF (NUM_PF),
   .NUM_VF (NUM_VF),
   .MAX_NUM_VF (MAX_NUM_VF)
) flr_rst_mgr (
   .clk_sys      (clk),             // Global clock
   .rst_n_sys    (rst_n),

   .clk_csr      (clk_csr),         // Clock for pcie_flr_req/rsp
   .rst_n_csr    (rst_n_csr),

   .pcie_flr_req (pcie_flr_req),
   .pcie_flr_rsp (pcie_flr_rsp),

   .pf_flr_rst_n (pf_flr_rst_n),
   .vf_flr_rst_n (vf_flr_rst_n)
);

//
// Macros for mapping port defintions to PF/VF resets. We use macros instead
// of functions to avoid problems with continuous assignment.
//

// Get the VF function level reset if VF is active for the function.
// If VF is not active, return a constant: not in reset.
`define GET_FUNC_VF_RST_N(PF, VF, VF_ACTIVE) ((VF_ACTIVE != 0) ? vf_flr_rst_n[PF][VF] : 1'b1)

// Construct the full reset for a function, combining PF and VF resets.
`define GET_FUNC_RST_N(PF, VF, VF_ACTIVE) (pf_flr_rst_n[PF] & `GET_FUNC_VF_RST_N(PF, VF, VF_ACTIVE))


// This is the AC file...
//----------------------------------------------------------------
// AFU Interface and Protocol Checker
//----------------------------------------------------------------
   afu_intf #( .ENABLE (1'b1),
               // The tag mapper is free to use all available tags in the
               // PCIe SS, independent of the limit imposed on AFUs by
               // ofs_pcie_ss_cfg_pkg::PCIE_EP_MAX_TAGS. The maximum tag
               // value has to take into account that 10 bit mode tags
               // shift to 256 and above.
               .PCIE_EP_MAX_TAGS (ofs_pcie_ss_cfg_pkg::PCIE_TILE_MAX_TAGS + 256)
   ) afu_intf_inst (
      .clk                (clk),
      .rst_n              (rst_n),
                          
      .clk_csr            (clk_csr), // Clock 100 MHz
      .rst_n_csr          (rst_n_csr),
      .pwr_good_csr_clk_n (pwr_good_csr_clk_n),
      
      .i_afu_softreset      (afu_softreset),

      .o_sel_mmio_rsp     ( sel_mmio_rsp    ),
      .o_read_flush_done  ( read_flush_done ),
      
      // MMIO req  
      .h2a_axis_rx        ( pcie_ss_axis_rxreq ),

      .a2h_axis_tx        ( pcie_ss_axis_tx ),
                          
      .csr_if             ( apf_achk_slv_if ),
                          
      .afu_axis_rx        ( ho2mx_rxreq_port ),
      .afu_axis_tx        ( mx2ho_tx_port )
  );

// Moving tag remap,arb & mux into this module
   afu_host_channel afu_host_channel_inst (
     .clk            (clk),
     .rst_n          (rst_n),
     .mx2ho_tx_port  (mx2ho_tx_port),
     .ho2mx_rx_remap (ho2mx_rx_remap),
     .ho2mx_rx_port  (pcie_ss_axis_rx),
     .ho2mx_rxreq_port (ho2mx_rxreq_port),
     .arb2mx_rxreq_port (arb2mx_rxreq_port),
     .mx2ho_tx_remap (mx2ho_tx_remap),
     .tag_mode       (tag_mode)
   );

// Primary PF/VF MUX ("A" ports). Map individual TX A ports from
// AFUs down to a single, merged A channel. The RX port from host
// to FPGA is demultiplexed and individual connections are forwarded
// to AFUs.
pf_vf_mux_w_params  #(
   .MUX_NAME("A"),
   .NUM_PORT(top_cfg_pkg::NUM_PORT),
   .NUM_RTABLE_ENTRIES(NUM_RTABLE_ENTRIES),
   .PFVF_ROUTING_TABLE(PFVF_ROUTING_TABLE)
) pf_vf_mux_a (
   .clk             (clk               ),
   .rst_n           (rst_n             ),
   .ho2mx_rx_port   (arb2mx_rxreq_port ),
   .mx2ho_tx_port   (mx2ho_tx_remap[0] ),
   .mx2fn_rx_port   (mx2pipe_rx_a_port ),
   .fn2mx_tx_port   (fn2mx_tx_a_port   ),
   .out_fifo_err    (pf_vf_fifo_err[0] ),
   .out_fifo_perr   (pf_vf_fifo_perr[0])
);

// Secondary PF/VF MUX ("B" ports). Only TX is implemented, since a
// single RX stream is sufficient. The RX input to the MUX is tied off.
// AFU B TX ports are multiplexed into a single TX B channel that is
// passed to the A/B MUX above.
pf_vf_mux_w_params   #(
   .MUX_NAME ("B"),
   .NUM_PORT(top_cfg_pkg::NUM_PORT),
   .NUM_RTABLE_ENTRIES(NUM_RTABLE_ENTRIES),
   .PFVF_ROUTING_TABLE(PFVF_ROUTING_TABLE)
) pf_vf_mux_b (
   .clk             (clk               ),
   .rst_n           (rst_n             ),
   .ho2mx_rx_port   (ho2mx_rx_remap    ),
   .mx2ho_tx_port   (mx2ho_tx_remap[1] ),
   .mx2fn_rx_port   (mx2fn_rx_b_port   ),
   .fn2mx_tx_port   (fn2mx_tx_b_port   ),
   .out_fifo_err    (pf_vf_fifo_err[1] ),
   .out_fifo_perr   (pf_vf_fifo_perr[1])
);


// Create AXI-S Pipeline for Static Region (SR) PIDs 
genvar i;
generate
   for (i = 0; i < NUM_SR_PORTS; i = i + 1) begin : srp 
      axis_pipeline #(
         .TDATA_WIDTH (PCIE_TDATA_WIDTH),
         .TUSER_WIDTH (PCIE_TUSER_WIDTH)
      ) afu_sr_tx_pipeline (
         .clk    (clk),
         .rst_n  (rst_n),
         .axis_m (fn2mx_tx_a_port[AFU_SR_MUX_PID[i]]),
         .axis_s (fn2pipe_tx_a_port[i])
      );

      axis_pipeline #(
         .TDATA_WIDTH (PCIE_TDATA_WIDTH),
         .TUSER_WIDTH (PCIE_TUSER_WIDTH)
      ) afu_sr_rx_pipeline (
         .clk    (clk),
         .rst_n  (rst_n),
         .axis_m (pipe2fn_rx_a_port[i]),
         .axis_s (mx2pipe_rx_a_port[AFU_SR_MUX_PID[i]]) 
      );

      assign mx2fn_rx_b_port[AFU_SR_MUX_PID[i]].tready = sr_afu_rx_b_port[i].tready;
      assign sr_afu_rx_b_port[i].tvalid       = mx2fn_rx_b_port[AFU_SR_MUX_PID[i]].tvalid;
      assign sr_afu_rx_b_port[i].tlast        = mx2fn_rx_b_port[AFU_SR_MUX_PID[i]].tlast;
      assign sr_afu_rx_b_port[i].tuser_vendor = mx2fn_rx_b_port[AFU_SR_MUX_PID[i]].tuser_vendor;
      assign sr_afu_rx_b_port[i].tdata        = mx2fn_rx_b_port[AFU_SR_MUX_PID[i]].tdata;
      assign sr_afu_rx_b_port[i].tkeep        = mx2fn_rx_b_port[AFU_SR_MUX_PID[i]].tkeep;

      assign sr_afu_tx_b_port[i].tready                   = fn2mx_tx_b_port[AFU_SR_MUX_PID[i]].tready;
      assign fn2mx_tx_b_port[AFU_SR_MUX_PID[i]].tvalid       = sr_afu_tx_b_port[i].tvalid;
      assign fn2mx_tx_b_port[AFU_SR_MUX_PID[i]].tlast        = sr_afu_tx_b_port[i].tlast;
      assign fn2mx_tx_b_port[AFU_SR_MUX_PID[i]].tuser_vendor = sr_afu_tx_b_port[i].tuser_vendor;
      assign fn2mx_tx_b_port[AFU_SR_MUX_PID[i]].tdata        = sr_afu_tx_b_port[i].tdata;
      assign fn2mx_tx_b_port[AFU_SR_MUX_PID[i]].tkeep        = sr_afu_tx_b_port[i].tkeep;

   end
endgenerate

//----------------------------------------------------------------

// Map the PF/VF association of Static Region and PR Region ports 
// to the parameters that will be passed to the port gasket and 
// fim_afu_instances.
typedef pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t[NUM_SR_PORTS-1:0] t_afu_sr_pf_vf_map;
function automatic t_afu_sr_pf_vf_map gen_sr_pf_vf_map();
   t_afu_sr_pf_vf_map map;
   for (int p = 0; p < NUM_SR_PORTS; p = p + 1) begin
      map[p].pf_num = PG_SR_PORTS_PF_NUM[p];
      map[p].vf_num = PG_SR_PORTS_VF_NUM[p];
      map[p].vf_active = PG_SR_PORTS_VF_ACTIVE[p];
   end
   return map;
endfunction // gen_pf_vf_map

localparam pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t[NUM_SR_PORTS-1:0] SR_PF_VF_INFO =
   gen_sr_pf_vf_map();

// Mapping FLR rst to fim_afu vector
generate
   for (genvar p = 0; p < NUM_SR_PORTS; p = p + 1)
   begin : fim_afu_rst_vector
      assign fim_afu_func_pf_rst_n[p] = pf_flr_rst_n[PG_SR_PORTS_PF_NUM[p]];
      assign fim_afu_func_vf_rst_n[p] = `GET_FUNC_VF_RST_N(PG_SR_PORTS_PF_NUM[p],
                                                      PG_SR_PORTS_VF_NUM[p],
                                                      PG_SR_PORTS_VF_ACTIVE[p]);
      // Reset generation for each PCIe port 
      // Reset sources
      // - PF Flr 
      // - VF Flr
      // - PCIe system reset
      always @(posedge clk) fim_afu_port_rst_n[p] <= fim_afu_func_pf_rst_n[p] && fim_afu_func_vf_rst_n[p] && rst_n;

      // Sync to clk_csr
      fim_resync #(
         .SYNC_CHAIN_LENGTH (2),
         .WIDTH             (1),
         .INIT_VALUE        (1),
         .NO_CUT            (0)
       ) port_rst_csr_sync (
        .clk   (clk_csr),
        .reset (1'b0),
        .d     (fim_afu_port_rst_n[p]),
        .q     (fim_afu_port_rst_n_csr[p])
      );
   end
endgenerate 
   fim_afu_instances #(
      .NUM_SR_PORTS  (NUM_SR_PORTS),
      .SR_PF_VF_INFO (SR_PF_VF_INFO),
      .NUM_PF        (NUM_PF),
      .NUM_VF        (NUM_VF)
   ) fim_afu_instances (
      .clk                (clk),
      .rst_n             (rst_n),
      .func_pf_rst_n      (fim_afu_func_pf_rst_n),
      .func_vf_rst_n      (fim_afu_func_vf_rst_n),
      .port_rst_n         (fim_afu_port_rst_n),  
      .clk_csr           (clk_csr),
      .rst_n_csr         (rst_n_csr),
      .apf_mctp_mst_if   (apf_mctp_mst_if),
      .apf_st2mm_mst_if  (apf_st2mm_mst_if),
      .apf_st2mm_slv_if  (apf_st2mm_slv_if),
      .hps_axi4_mm_if    (hps_axi4_mm_if),
      .hps_ace_lite_if   (hps_ace_lite_if),
      .h2f_reset         (h2f_reset),
      .afu_axi_rx_a_if (pipe2fn_rx_a_port),
      .afu_axi_tx_a_if (fn2pipe_tx_a_port),
      .afu_axi_rx_b_if (sr_afu_rx_b_port),
      .afu_axi_tx_b_if (sr_afu_tx_b_port) 
   );

//----------------------------------------------------------------
// Port Gasket
//----------------------------------------------------------------
localparam PG_NUM_RTABLE_ENTRIES = top_cfg_pkg::PG_NUM_RTABLE_ENTRIES;
localparam pf_vf_mux_pkg::t_pfvf_rtable_entry [PG_NUM_RTABLE_ENTRIES-1:0] PG_PFVF_ROUTING_TABLE = top_cfg_pkg::get_prr_pf_vf_entry_info();


typedef pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t[PG_AFU_NUM_PORTS-1:0] t_afu_prr_pf_vf_map;
function automatic t_afu_prr_pf_vf_map gen_prr_pf_vf_map();
   t_afu_prr_pf_vf_map map;
   for (int p = 0; p < PG_AFU_NUM_PORTS; p = p + 1) begin
      map[p].pf_num = PG_AFU_PORTS_PF_NUM[p];
      map[p].vf_num = PG_AFU_PORTS_VF_NUM[p];
      map[p].vf_active = PG_AFU_PORTS_VF_ACTIVE[p];
   end
   return map;
endfunction // gen_pf_vf_map

localparam pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t[PG_AFU_NUM_PORTS-1:0] PRR_PF_VF_INFO =
   gen_prr_pf_vf_map();


// Mapping FLR rst to port vector
generate
   for (genvar p = 0; p < PG_AFU_NUM_PORTS; p = p + 1)
   begin : port_afu_flr_vector
      assign pg_func_pf_rst_n[p] = pf_flr_rst_n[PG_AFU_PORTS_PF_NUM[p]];
      assign pg_func_vf_rst_n[p] = `GET_FUNC_VF_RST_N(PG_AFU_PORTS_PF_NUM[p],
                                                      PG_AFU_PORTS_VF_NUM[p],
                                                      PG_AFU_PORTS_VF_ACTIVE[p]);
   end
endgenerate

port_gasket #( 
   .PG_NUM_PORTS(PG_AFU_NUM_PORTS),              // Number of PCIe ports to PR region
   .PORT_PF_VF_INFO(PRR_PF_VF_INFO),             // PCIe port data
   .NUM_MEM_CH(AFU_MEM_CHANNEL),                 // Number of Memory Porst to PR region
   .END_OF_LIST    (1'b0),                       // port_gasket DFH end of list field
   .NEXT_DFH_OFFSET(24'h10000),                   // Next offset in OFS management DFH
   .PG_NUM_RTABLE_ENTRIES (PG_NUM_RTABLE_ENTRIES),
   .PG_PFVF_ROUTING_TABLE (PG_PFVF_ROUTING_TABLE)
) port_gasket(
   .refclk              (SYS_REFCLK),            // 100 MHz refclk for user clk pll
   .clk                 ,                        // PCIe Clk
   .clk_div2,                                    // Half frequency of PCIe clk
   .clk_div4           (clk),
   .clk_100            (clk_csr),                // 100 MHz for user clk logic
   .clk_csr            (clk_csr),                // 100 MHz CSR interface clock

   `ifdef INCLUDE_DDR4
      .afu_mem_if      (ext_mem_if),             // Memory interface
   `endif

   `ifdef INCLUDE_HSSI                           // Instantiates HE-HSSI in PR region   
      .hssi_ss_st_tx  (hssi_ss_st_tx),           // HSSI Tx
      .hssi_ss_st_rx  (hssi_ss_st_rx),           // HSSI Rx
      .hssi_fc        (hssi_fc),                 // Flow control interface
      .i_hssi_clk_pll (i_hssi_clk_pll),          // HSSI clocks
   `endif

   .rst_n,                                      // Reset from hip
   .rst_n_100          (rst_n_csr),             // Reset from hip on csr clk
   .rst_n_csr          (rst_n_csr),             // Reset from hip on csr clk
   .func_pf_rst_n      (pg_func_pf_rst_n),      // PF FLR 
   .func_vf_rst_n      (pg_func_vf_rst_n),      // VF FLR for each port

   .i_sel_mmio_rsp     (sel_mmio_rsp),
   .i_read_flush_done  (read_flush_done),
   .o_afu_softreset    (afu_softreset),
   .o_pr_parity_error  (pr_parity_error),       // Partial Reconfiguration FIFO Parity Error Indication from PR Controller.

   .axi_rx_a_if        (mx2pipe_rx_a_port[PG_SHARED_VF_PID]),  // PCIe intf on clk_2x
   .axi_tx_a_if        (fn2mx_tx_a_port[PG_SHARED_VF_PID]),    // PCIe intf on clk_2x
   .axi_rx_b_if        (mx2fn_rx_b_port[PG_SHARED_VF_PID]),    // PCIe intf on clk_2x
   .axi_tx_b_if        (fn2mx_tx_b_port[PG_SHARED_VF_PID]),   // PCIe intf on clk_2x

   .axi_s_if           (apf_pgsk_slv_if)        // CSR interface from APF
);






//----------------------------------------------------------------
// MCTP management interface 
//----------------------------------------------------------------
always_comb 
begin
   apf_mctp_mst_if.bready  = 1'b1;
   apf_mctp_mst_if.rready  = 1'b1;
end


//----------------------------------------------------------------
// vUART interface 
//----------------------------------------------------------------
`ifdef INCLUDE_UART

   vuart_top # (
                              .ST2MM_DFH_MSIX_ADDR (20'h40000)
   ) vuart_top (
                              .clk_csr       (clk_csr),
                              .rst_n_csr     (rst_n_csr),
                              .clk_50m       (clk_50m),
                              .rst_n_50m     (rst_n_50m),
                              .pwr_good_csr_clk_n (pwr_good_csr_clk_n),
                              
                              .csr_lite_m_if (apf_uart_mst_if),
                              .csr_lite_if   (apf_uart_slv_if),
                              .host_uart_if  (host_uart_if)
                              );
   
`else
dummy_csr #(
   .FEAT_ID          (12'h24),
   .FEAT_VER         (4'h0),
   .NEXT_DFH_OFFSET  (24'h10000),
   .END_OF_LIST      (1'b0)
) uart_dummy_csr (
   .clk         (clk_csr),
   .rst_n       (rst_n_csr),
   .csr_lite_if (apf_uart_slv_if)
);

always_comb
begin  
  apf_uart_mst_if.awaddr   = 21'h0;
  apf_uart_mst_if.awprot   = 3'h0;
  apf_uart_mst_if.awvalid  = 1'b0;
  apf_uart_mst_if.wdata    = 32'h0;
  apf_uart_mst_if.wstrb    = 4'h0;
  apf_uart_mst_if.wvalid   = 1'b0;
  apf_uart_mst_if.bready   = 1'b0;  
  apf_uart_mst_if.araddr   = 21'h0;
  apf_uart_mst_if.arprot   = 3'h0; 
  apf_uart_mst_if.arvalid  = 1'b0;
  apf_uart_mst_if.rready   = 1'b0;
end


`endif


//----------------------------------------------------------------
// AFU Peripheral Fabric
//----------------------------------------------------------------
apf apf(
   .clk_clk               (clk_csr     ),
   .rst_n_reset_n         (rst_n_csr   ),
   
   .apf_bpf_slv_awaddr    (apf_bpf_slv_if.awaddr   ),
   .apf_bpf_slv_awprot    (apf_bpf_slv_if.awprot   ),
   .apf_bpf_slv_awvalid   (apf_bpf_slv_if.awvalid  ),
   .apf_bpf_slv_awready   (apf_bpf_slv_if.awready  ),
   .apf_bpf_slv_wdata     (apf_bpf_slv_if.wdata    ),
   .apf_bpf_slv_wstrb     (apf_bpf_slv_if.wstrb    ),
   .apf_bpf_slv_wvalid    (apf_bpf_slv_if.wvalid   ),
   .apf_bpf_slv_wready    (apf_bpf_slv_if.wready   ),
   .apf_bpf_slv_bresp     (apf_bpf_slv_if.bresp    ),
   .apf_bpf_slv_bvalid    (apf_bpf_slv_if.bvalid   ),
   .apf_bpf_slv_bready    (apf_bpf_slv_if.bready   ),
   .apf_bpf_slv_araddr    (apf_bpf_slv_if.araddr   ),
   .apf_bpf_slv_arprot    (apf_bpf_slv_if.arprot   ),
   .apf_bpf_slv_arvalid   (apf_bpf_slv_if.arvalid  ),
   .apf_bpf_slv_arready   (apf_bpf_slv_if.arready  ),
   .apf_bpf_slv_rdata     (apf_bpf_slv_if.rdata    ),
   .apf_bpf_slv_rresp     (apf_bpf_slv_if.rresp    ),
   .apf_bpf_slv_rvalid    (apf_bpf_slv_if.rvalid   ),
   .apf_bpf_slv_rready    (apf_bpf_slv_if.rready   ),

   .apf_bpf_mst_awaddr    (apf_bpf_mst_if.awaddr   ),
   .apf_bpf_mst_awprot    (apf_bpf_mst_if.awprot   ),
   .apf_bpf_mst_awvalid   (apf_bpf_mst_if.awvalid  ),
   .apf_bpf_mst_awready   (apf_bpf_mst_if.awready  ),
   .apf_bpf_mst_wdata     (apf_bpf_mst_if.wdata    ),
   .apf_bpf_mst_wstrb     (apf_bpf_mst_if.wstrb    ),
   .apf_bpf_mst_wvalid    (apf_bpf_mst_if.wvalid   ),
   .apf_bpf_mst_wready    (apf_bpf_mst_if.wready   ),
   .apf_bpf_mst_bresp     (apf_bpf_mst_if.bresp    ),
   .apf_bpf_mst_bvalid    (apf_bpf_mst_if.bvalid   ),
   .apf_bpf_mst_bready    (apf_bpf_mst_if.bready   ),
   .apf_bpf_mst_araddr    (apf_bpf_mst_if.araddr   ),
   .apf_bpf_mst_arprot    (apf_bpf_mst_if.arprot   ),
   .apf_bpf_mst_arvalid   (apf_bpf_mst_if.arvalid  ),
   .apf_bpf_mst_arready   (apf_bpf_mst_if.arready  ),
   .apf_bpf_mst_rdata     (apf_bpf_mst_if.rdata    ),
   .apf_bpf_mst_rresp     (apf_bpf_mst_if.rresp    ),
   .apf_bpf_mst_rvalid    (apf_bpf_mst_if.rvalid   ),
   .apf_bpf_mst_rready    (apf_bpf_mst_if.rready   ),

   .apf_mctp_mst_awaddr   (apf_mctp_mst_if.awaddr  ),
   .apf_mctp_mst_awprot   (apf_mctp_mst_if.awprot  ),
   .apf_mctp_mst_awvalid  (apf_mctp_mst_if.awvalid ),
   .apf_mctp_mst_awready  (apf_mctp_mst_if.awready ),
   .apf_mctp_mst_wdata    (apf_mctp_mst_if.wdata   ),
   .apf_mctp_mst_wstrb    (apf_mctp_mst_if.wstrb   ),
   .apf_mctp_mst_wvalid   (apf_mctp_mst_if.wvalid  ),
   .apf_mctp_mst_wready   (apf_mctp_mst_if.wready  ),
   .apf_mctp_mst_bresp    (apf_mctp_mst_if.bresp   ),
   .apf_mctp_mst_bvalid   (apf_mctp_mst_if.bvalid  ),
   .apf_mctp_mst_bready   (apf_mctp_mst_if.bready  ),
   .apf_mctp_mst_araddr   (apf_mctp_mst_if.araddr  ),
   .apf_mctp_mst_arprot   (apf_mctp_mst_if.arprot  ),
   .apf_mctp_mst_arvalid  (apf_mctp_mst_if.arvalid ),
   .apf_mctp_mst_arready  (apf_mctp_mst_if.arready ),
   .apf_mctp_mst_rdata    (apf_mctp_mst_if.rdata   ),
   .apf_mctp_mst_rresp    (apf_mctp_mst_if.rresp   ),
   .apf_mctp_mst_rvalid   (apf_mctp_mst_if.rvalid  ),
   .apf_mctp_mst_rready   (apf_mctp_mst_if.rready  ),

   .apf_pr_slv_awaddr     (apf_pgsk_slv_if.awaddr    ),
   .apf_pr_slv_awprot     (apf_pgsk_slv_if.awprot    ),
   .apf_pr_slv_awvalid    (apf_pgsk_slv_if.awvalid   ),
   .apf_pr_slv_awready    (apf_pgsk_slv_if.awready   ),
   .apf_pr_slv_wdata      (apf_pgsk_slv_if.wdata     ),
   .apf_pr_slv_wstrb      (apf_pgsk_slv_if.wstrb     ),
   .apf_pr_slv_wvalid     (apf_pgsk_slv_if.wvalid    ),
   .apf_pr_slv_wready     (apf_pgsk_slv_if.wready    ),
   .apf_pr_slv_bresp      (apf_pgsk_slv_if.bresp     ),
   .apf_pr_slv_bvalid     (apf_pgsk_slv_if.bvalid    ),
   .apf_pr_slv_bready     (apf_pgsk_slv_if.bready    ),
   .apf_pr_slv_araddr     (apf_pgsk_slv_if.araddr    ),
   .apf_pr_slv_arprot     (apf_pgsk_slv_if.arprot    ),
   .apf_pr_slv_arvalid    (apf_pgsk_slv_if.arvalid   ),
   .apf_pr_slv_arready    (apf_pgsk_slv_if.arready   ),
   .apf_pr_slv_rdata      (apf_pgsk_slv_if.rdata     ),
   .apf_pr_slv_rresp      (apf_pgsk_slv_if.rresp     ),
   .apf_pr_slv_rvalid     (apf_pgsk_slv_if.rvalid    ),
   .apf_pr_slv_rready     (apf_pgsk_slv_if.rready    ),

   .apf_uart_mst_awaddr   (apf_uart_mst_if.awaddr  ),
   .apf_uart_mst_awprot   (apf_uart_mst_if.awprot  ),
   .apf_uart_mst_awvalid  (apf_uart_mst_if.awvalid ),
   .apf_uart_mst_awready  (apf_uart_mst_if.awready ),
   .apf_uart_mst_wdata    (apf_uart_mst_if.wdata   ),
   .apf_uart_mst_wstrb    (apf_uart_mst_if.wstrb   ),
   .apf_uart_mst_wvalid   (apf_uart_mst_if.wvalid  ),
   .apf_uart_mst_wready   (apf_uart_mst_if.wready  ),
   .apf_uart_mst_bresp    (apf_uart_mst_if.bresp   ),
   .apf_uart_mst_bvalid   (apf_uart_mst_if.bvalid  ),
   .apf_uart_mst_bready   (apf_uart_mst_if.bready  ),
   .apf_uart_mst_araddr   (apf_uart_mst_if.araddr  ),
   .apf_uart_mst_arprot   (apf_uart_mst_if.arprot  ),
   .apf_uart_mst_arvalid  (apf_uart_mst_if.arvalid ),
   .apf_uart_mst_arready  (apf_uart_mst_if.arready ),
   .apf_uart_mst_rdata    (apf_uart_mst_if.rdata   ),
   .apf_uart_mst_rresp    (apf_uart_mst_if.rresp   ),
   .apf_uart_mst_rvalid   (apf_uart_mst_if.rvalid  ),
   .apf_uart_mst_rready   (apf_uart_mst_if.rready  ),


   .apf_uart_slv_awaddr   (apf_uart_slv_if.awaddr    ),
   .apf_uart_slv_awprot   (apf_uart_slv_if.awprot    ),
   .apf_uart_slv_awvalid  (apf_uart_slv_if.awvalid   ),
   .apf_uart_slv_awready  (apf_uart_slv_if.awready   ),
   .apf_uart_slv_wdata    (apf_uart_slv_if.wdata     ),
   .apf_uart_slv_wstrb    (apf_uart_slv_if.wstrb     ),
   .apf_uart_slv_wvalid   (apf_uart_slv_if.wvalid    ),
   .apf_uart_slv_wready   (apf_uart_slv_if.wready    ),
   .apf_uart_slv_bresp    (apf_uart_slv_if.bresp     ),
   .apf_uart_slv_bvalid   (apf_uart_slv_if.bvalid    ),
   .apf_uart_slv_bready   (apf_uart_slv_if.bready    ),
   .apf_uart_slv_araddr   (apf_uart_slv_if.araddr    ),
   .apf_uart_slv_arprot   (apf_uart_slv_if.arprot    ),
   .apf_uart_slv_arvalid  (apf_uart_slv_if.arvalid   ),
   .apf_uart_slv_arready  (apf_uart_slv_if.arready   ),
   .apf_uart_slv_rdata    (apf_uart_slv_if.rdata     ),
   .apf_uart_slv_rresp    (apf_uart_slv_if.rresp     ),
   .apf_uart_slv_rvalid   (apf_uart_slv_if.rvalid    ),
   .apf_uart_slv_rready   (apf_uart_slv_if.rready    ),

   .apf_st2mm_mst_awaddr  (apf_st2mm_mst_if.awaddr ),
   .apf_st2mm_mst_awprot  (apf_st2mm_mst_if.awprot ),
   .apf_st2mm_mst_awvalid (apf_st2mm_mst_if.awvalid),
   .apf_st2mm_mst_awready (apf_st2mm_mst_if.awready),
   .apf_st2mm_mst_wdata   (apf_st2mm_mst_if.wdata  ),
   .apf_st2mm_mst_wstrb   (apf_st2mm_mst_if.wstrb  ),
   .apf_st2mm_mst_wvalid  (apf_st2mm_mst_if.wvalid ),
   .apf_st2mm_mst_wready  (apf_st2mm_mst_if.wready ),
   .apf_st2mm_mst_bresp   (apf_st2mm_mst_if.bresp  ),
   .apf_st2mm_mst_bvalid  (apf_st2mm_mst_if.bvalid ),
   .apf_st2mm_mst_bready  (apf_st2mm_mst_if.bready ),
   .apf_st2mm_mst_araddr  (apf_st2mm_mst_if.araddr ),
   .apf_st2mm_mst_arprot  (apf_st2mm_mst_if.arprot ),
   .apf_st2mm_mst_arvalid (apf_st2mm_mst_if.arvalid),
   .apf_st2mm_mst_arready (apf_st2mm_mst_if.arready),
   .apf_st2mm_mst_rdata   (apf_st2mm_mst_if.rdata  ),
   .apf_st2mm_mst_rresp   (apf_st2mm_mst_if.rresp  ),
   .apf_st2mm_mst_rvalid  (apf_st2mm_mst_if.rvalid ),
   .apf_st2mm_mst_rready  (apf_st2mm_mst_if.rready ),
   
   .apf_st2mm_slv_awaddr  (apf_st2mm_slv_if.awaddr ),
   .apf_st2mm_slv_awprot  (apf_st2mm_slv_if.awprot ),
   .apf_st2mm_slv_awvalid (apf_st2mm_slv_if.awvalid),
   .apf_st2mm_slv_awready (apf_st2mm_slv_if.awready),
   .apf_st2mm_slv_wdata   (apf_st2mm_slv_if.wdata  ),
   .apf_st2mm_slv_wstrb   (apf_st2mm_slv_if.wstrb  ),
   .apf_st2mm_slv_wvalid  (apf_st2mm_slv_if.wvalid ),
   .apf_st2mm_slv_wready  (apf_st2mm_slv_if.wready ),
   .apf_st2mm_slv_bresp   (apf_st2mm_slv_if.bresp  ),
   .apf_st2mm_slv_bvalid  (apf_st2mm_slv_if.bvalid ),
   .apf_st2mm_slv_bready  (apf_st2mm_slv_if.bready ),
   .apf_st2mm_slv_araddr  (apf_st2mm_slv_if.araddr ),
   .apf_st2mm_slv_arprot  (apf_st2mm_slv_if.arprot ),
   .apf_st2mm_slv_arvalid (apf_st2mm_slv_if.arvalid),
   .apf_st2mm_slv_arready (apf_st2mm_slv_if.arready),
   .apf_st2mm_slv_rdata   (apf_st2mm_slv_if.rdata  ),
   .apf_st2mm_slv_rresp   (apf_st2mm_slv_if.rresp  ),
   .apf_st2mm_slv_rvalid  (apf_st2mm_slv_if.rvalid ),
   .apf_st2mm_slv_rready  (apf_st2mm_slv_if.rready ),
      
   .apf_achk_slv_awaddr   (apf_achk_slv_if.awaddr  ),
   .apf_achk_slv_awprot   (apf_achk_slv_if.awprot  ),
   .apf_achk_slv_awvalid  (apf_achk_slv_if.awvalid ),
   .apf_achk_slv_awready  (apf_achk_slv_if.awready ),
   .apf_achk_slv_wdata    (apf_achk_slv_if.wdata   ),
   .apf_achk_slv_wstrb    (apf_achk_slv_if.wstrb   ),
   .apf_achk_slv_wvalid   (apf_achk_slv_if.wvalid  ),
   .apf_achk_slv_wready   (apf_achk_slv_if.wready  ),
   .apf_achk_slv_bresp    (apf_achk_slv_if.bresp   ),
   .apf_achk_slv_bvalid   (apf_achk_slv_if.bvalid  ),
   .apf_achk_slv_bready   (apf_achk_slv_if.bready  ),
   .apf_achk_slv_araddr   (apf_achk_slv_if.araddr  ),
   .apf_achk_slv_arprot   (apf_achk_slv_if.arprot  ),
   .apf_achk_slv_arvalid  (apf_achk_slv_if.arvalid ),
   .apf_achk_slv_arready  (apf_achk_slv_if.arready ),
   .apf_achk_slv_rdata    (apf_achk_slv_if.rdata   ),
   .apf_achk_slv_rresp    (apf_achk_slv_if.rresp   ),
   .apf_achk_slv_rvalid   (apf_achk_slv_if.rvalid  ),
   .apf_achk_slv_rready   (apf_achk_slv_if.rready  )
);

endmodule
