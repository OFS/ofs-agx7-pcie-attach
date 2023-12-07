// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
// Static Region AFU - Instantiates HE-Null, HE-LB, VirtIO, and HPS Copy Engine
//
// Created for use of the PF/VF Configuration tool, where only AFU endpoints are
// connected. The user is instructed to utilize the PFVF_ROUTING_TABLE parameter
// to access all information regarding a specific endpoint with a PID.
// 
// The default PID mapping is as follows:
//    PID 0  - PF1       - HE-NULL
//    PID 2  - PF2       - HE-LB
//    PID 3  - PF3       - VIO
//    PID 4  - PF4       - HPS-CE
//    PID 5+ - PF5+/VF1+ - HE-NULL
//    

`include "fpga_defines.vh"
import top_cfg_pkg::*;
import pcie_ss_axis_pkg::*;

module fim_afu_instances # (
   // System PF/VF configuration info for generating port reset vectors.
   // The reset generation logic produces a Max PF x Max VF table of reset signals
   parameter NUM_PF        = 1,
   parameter NUM_VF        = 1,
   parameter MAX_NUM_VF    = 1,

   // PF/VF routing: the OFS configuration package provides a routing table structure of 1 port
   // per PV/VF of this partition, meaning that NUM_MUX_PORTS = the number of routing table entries
   parameter NUM_MUX_PORTS = top_cfg_pkg::NUM_SR_PORTS,
   parameter pf_vf_mux_pkg::t_pfvf_rtable_entry [NUM_MUX_PORTS-1:0] PFVF_ROUTING_TABLE
)(
   input  logic clk,
   input  logic rst_n,

   input  t_axis_pcie_flr flr_req,
   output t_axis_pcie_flr flr_rsp,

   input  logic clk_csr,
   input  logic rst_n_csr,      

`ifdef INCLUDE_HPS
    //HPS Interfaces 
   ofs_fim_axi_mmio_if.slave  hps_axi4_mm_if,
   ofs_fim_ace_lite_if.master hps_ace_lite_if,
   input                      h2f_reset,
`endif

   // PCIe A ports are the standard TLP channels. All host responses
   // arrive on the RX A port.
   pcie_ss_axis_if.source        afu_axi_tx_a_if,
   pcie_ss_axis_if.sink          afu_axi_rx_a_if,
   // PCIe B ports are a second channel on which reads and interrupts
   // may be sent from the AFU. To improve throughput, reads on B may flow
   // around writes on A through PF/VF MUX trees until writes are committed
   // to the PCIe subsystem. AFUs may tie off the B port and send all
   // messages to A.
   pcie_ss_axis_if.source        afu_axi_tx_b_if,
   // Write commits are signaled here on the RX B port, indicating the
   // point at which the A and B channels become ordered within the FIM.
   // Commits are signaled after tlast of a write on TX A, after arbitration
   // with TX B within the FIM. The commit is a Cpl (without data),
   // returning the tag value from the write request. AFUs that do not
   // need local write commits may ignore this port, but must set
   // tready to 1.
   pcie_ss_axis_if.sink          afu_axi_rx_b_if
);
   
// Port definitions
`ifdef USE_NULL_HE_LB
localparam HLB_PID = -1;
`else
localparam HLB_PID = (top_cfg_pkg::PG_VFS > 0) ? 1 : 0; 
`endif
localparam VIO_PID = (top_cfg_pkg::PG_VFS > 0) ? 2 : 1; 
localparam HPS_PID = (top_cfg_pkg::PG_VFS > 0) ? 3 : 2; 

localparam TDATA_WIDTH = afu_axi_rx_a_if.DATA_W;
localparam TUSER_WIDTH = afu_axi_rx_a_if.USER_W;

// AXI-ST ports
pcie_ss_axis_if #(
   .DATA_W (TDATA_WIDTH),
   .USER_W (TUSER_WIDTH))
   mux_rx_a_if [NUM_MUX_PORTS-1:0] (.clk(clk), .rst_n(rst_n)),
   mux_rx_b_if [NUM_MUX_PORTS-1:0] (.clk(clk), .rst_n(rst_n)),
   mux_tx_a_if [NUM_MUX_PORTS-1:0] (.clk(clk), .rst_n(rst_n)),
   mux_tx_b_if [NUM_MUX_PORTS-1:0] (.clk(clk), .rst_n(rst_n));

// Primary PF/VF MUX ("A" ports). Map individual TX A ports from
// AFUs down to a single, merged A channel. The RX port from host
// to FPGA is demultiplexed and individual connections are forwarded
// to AFUs.
pf_vf_mux_w_params  #(
   .MUX_NAME("SR_A"),
   .NUM_PORT           (NUM_MUX_PORTS),
   .NUM_RTABLE_ENTRIES (NUM_MUX_PORTS),
   .PFVF_ROUTING_TABLE (PFVF_ROUTING_TABLE)
) pf_vf_mux_a (
   .clk             (clk             ),
   .rst_n           (rst_n           ),
   .ho2mx_rx_port   (afu_axi_rx_a_if ),
   .mx2ho_tx_port   (afu_axi_tx_a_if ),
   .mx2fn_rx_port   (mux_rx_a_if     ),
   .fn2mx_tx_port   (mux_tx_a_if     ),
   .out_fifo_err    (),
   .out_fifo_perr   ()
);

// Secondary PF/VF MUX ("B" ports). Only TX is implemented, since a
// single RX stream is sufficient. The RX input to the MUX is tied off.
// AFU B TX ports are multiplexed into a single TX B channel that is
// passed to the A/B MUX above.
pf_vf_mux_w_params   #(
   .MUX_NAME ("SR_B"),
   .NUM_PORT           (NUM_MUX_PORTS),
   .NUM_RTABLE_ENTRIES (NUM_MUX_PORTS),
   .PFVF_ROUTING_TABLE (PFVF_ROUTING_TABLE)
) pf_vf_mux_b (
   .clk             (clk             ),
   .rst_n           (rst_n           ),
   .ho2mx_rx_port   (afu_axi_rx_b_if ),
   .mx2ho_tx_port   (afu_axi_tx_b_if ),
   .mx2fn_rx_port   (mux_rx_b_if     ),
   .fn2mx_tx_port   (mux_tx_b_if     ),
   .out_fifo_err    (),
   .out_fifo_perr   ()
);

// FLR to reset vector 
//
// Macros for mapping port defintions to PF/VF resets. We use macros instead
// of functions to avoid problems with continuous assignment.
//

// Get the VF function level reset if VF is active for the function.
// If VF is not active, return a constant: not in reset.
`define GET_FUNC_VF_RST_N(PF, VF, VF_ACTIVE) ((VF_ACTIVE != 0) ? vf_flr_rst_n[PF][VF] : 1'b1)

// Construct the full reset for a function, combining PF and VF resets.
`define GET_FUNC_RST_N(PF, VF, VF_ACTIVE) (pf_flr_rst_n[PF] & `GET_FUNC_VF_RST_N(PF, VF, VF_ACTIVE))

logic [NUM_MUX_PORTS-1:0]       func_pf_rst_n;
logic [NUM_MUX_PORTS-1:0]       func_vf_rst_n;
logic [NUM_MUX_PORTS-1:0]       port_rst_n;

logic [NUM_PF-1:0]              pf_flr_rst_n;
logic [NUM_PF-1:0][NUM_VF-1:0]  vf_flr_rst_n;

 flr_rst_mgr #(
    .NUM_PF     (NUM_PF),
    .NUM_VF     (NUM_VF),
    .MAX_NUM_VF (MAX_NUM_VF)
 ) flr_rst_mgr (
    .clk_sys      (clk),
    .rst_n_sys    (rst_n),

    // Clock for pcie_flr_req/rsp
    .clk_csr      (clk_csr), 
    .rst_n_csr    (rst_n_csr),

    .pcie_flr_req (flr_req),
    .pcie_flr_rsp (flr_rsp),

    .pf_flr_rst_n (pf_flr_rst_n),
    .vf_flr_rst_n (vf_flr_rst_n)
 );

generate for (genvar p = 0; p < NUM_MUX_PORTS; p++) begin : sr_flr_port_map
   assign func_pf_rst_n[p] =       pf_flr_rst_n[PFVF_ROUTING_TABLE[p].pf];
   assign func_vf_rst_n[p] = `GET_FUNC_VF_RST_N(PFVF_ROUTING_TABLE[p].pf,
                                                PFVF_ROUTING_TABLE[p].vf,
                                                PFVF_ROUTING_TABLE[p].vf_active);

   // Reset generation for each PCIe port 
   // Reset sources
   // - PF Flr 
   // - VF Flr
   // - PCIe system reset
   always @(posedge clk) port_rst_n[p] <= func_pf_rst_n[p] && func_vf_rst_n[p] && rst_n;
end : sr_flr_port_map
endgenerate 
   
// ---------------------------------------------------------------------------
// Generate the AFU on a given port. A loop is used to simplify the inclusion
// of null exercisers on ports with no explicitly attached behavior.
// ---------------------------------------------------------------------------
generate for(genvar p = 0; p < NUM_MUX_PORTS; p++) begin : afu_gen
   if (p == HLB_PID) begin : hlb_gen
      he_lb_top #(
         .PF_ID       (PFVF_ROUTING_TABLE[p].pf),
         .VF_ID       (PFVF_ROUTING_TABLE[p].vf),
         .VF_ACTIVE   (PFVF_ROUTING_TABLE[p].vf_active)
      ) he_lb_top (
         .clk         (clk),
         .rst_n       (port_rst_n  [p]),
         .axi_rx_a_if (mux_rx_a_if [p]),
         .axi_rx_b_if (mux_rx_b_if [p]),
         .axi_tx_a_if (mux_tx_a_if [p]),
         .axi_tx_b_if (mux_tx_b_if [p])
      );
   end : hlb_gen

   else if (p == VIO_PID) begin : vio_gen
      he_null #(
         .CSR_ADDR_WIDTH  (16),
         .PF_ID           (PFVF_ROUTING_TABLE[p].pf),
         .VF_ID           (PFVF_ROUTING_TABLE[p].vf),
         .VF_ACTIVE       (PFVF_ROUTING_TABLE[p].vf_active),
         .USE_VIRTIO_GUID (1)
      ) virtio_top_inst (
         .clk     (clk),
         .rst_n   (port_rst_n  [p]),
         .i_rx_if (mux_rx_a_if [p]),
         .o_tx_if (mux_tx_a_if [p])
      );
      // Tie off TX/RX B port
      assign mux_tx_b_if[p].tvalid = 1'b0;
      assign mux_rx_b_if[p].tready = 1'b1;
   end : vio_gen

`ifdef INCLUDE_HPS
   else if (p == HPS_PID) begin : hps_ce_gen
      // Add host interface timing stage
      pcie_ss_axis_if #(
         .DATA_W (TDATA_WIDTH),
         .USER_W (TUSER_WIDTH))
         ce_rx_a_if (.clk(clk), .rst_n(rst_n)),
         ce_rx_b_if (.clk(clk), .rst_n(rst_n)),
         ce_tx_a_if (.clk(clk), .rst_n(rst_n));
      
      axis_pipeline #(
         .TUSER_WIDTH (TUSER_WIDTH),
         .TDATA_WIDTH (TDATA_WIDTH)
      ) ce_rx_a_bridge (
         .clk,
         .rst_n,
         .axis_s  (mux_rx_a_if[p]),
         .axis_m  (ce_rx_a_if)
      );

      axis_pipeline #(
         .TUSER_WIDTH (TUSER_WIDTH),
         .TDATA_WIDTH (TDATA_WIDTH)
      ) ce_rx_b_bridge (
         .clk,
         .rst_n,
         .axis_s  (mux_rx_b_if[p]),
         .axis_m  (ce_rx_b_if)
      );

      axis_pipeline #(
         .TUSER_WIDTH (TUSER_WIDTH),
         .TDATA_WIDTH (TDATA_WIDTH)
      ) ce_tx_a_bridge (
         .clk,
         .rst_n,
         .axis_s  (ce_tx_a_if),
         .axis_m  (mux_tx_a_if[p])
      );

      ce_top #(
         .CE_PF_ID               (PFVF_ROUTING_TABLE[p].pf),
         .CE_VF_ID               (PFVF_ROUTING_TABLE[p].vf),
         .CE_VF_ACTIVE           (PFVF_ROUTING_TABLE[p].vf_active),
         .CE_FEAT_ID             (12'h1    ),
         .CE_FEAT_VER            (4'h1     ),
         .CE_NEXT_DFH_OFFSET     (24'h1000 ),
         .CE_END_OF_LIST         (1'b1     ),
         .CE_BUS_ADDR_WIDTH      (32       ),
         .CE_AXI4MM_ADDR_WIDTH   (21       ),
         .CE_AXI4MM_DATA_WIDTH   (32       ),
         .CE_BUS_DATA_WIDTH      (512      ),
         .CE_BUS_USER_WIDTH      (10       ),
         .CE_MMIO_RSP_FIFO_DEPTH (4        ),
         .CE_HST2HPS_FIFO_DEPTH  (5        )
      ) ce_top (
         .clk                (clk                ),
         .rst                (~port_rst_n     [p]),
         .axis_rxreq_if      (ce_rx_a_if         ),
         .axis_rx_if         (ce_rx_b_if         ),
         .axis_tx_if         (ce_tx_a_if         ),
         .ace_lite_tx_if     (hps_ace_lite_if    ),
         .h2f_reset          (h2f_reset          ),
         .axi4mm_rx_if       (hps_axi4_mm_if     )
      );
      // Tie off the TX B port
      assign mux_tx_b_if[p].tvalid = 1'b0;
   end : hps_ce_gen
`endif

   else begin : null_gen
      he_null #(
         .PF_ID     (PFVF_ROUTING_TABLE[p].pf),
         .VF_ID     (PFVF_ROUTING_TABLE[p].vf),
         .VF_ACTIVE (PFVF_ROUTING_TABLE[p].vf_active)
      ) he_null_prr (
         .clk     (clk),
         .rst_n   (port_rst_n  [p]),
         .i_rx_if (mux_rx_a_if [p]),
         .o_tx_if (mux_tx_a_if [p])
      );
      // Tie off the TX/RX B port
      assign mux_tx_b_if[p].tvalid = 1'b0;
      assign mux_rx_b_if[p].tready = 1'b1;
   end : null_gen
end : afu_gen
endgenerate
   
endmodule
