// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//  Instantiates ST2MM, HE-LB Dummy, HE-LB, VirtIO, and HPS in FIM base compile 
//  static region
// -----------------------------------------------------------------------------
//
// Created for use of the PF/VF Configuration tool, where only AFU endpoints are
// connected. The user is instructed to utilize the PORT_PF_VF_INFO parameter
// to access all information regarding a specific endpoint with a PID.
// 
// The default PID mapping is as follows:
//    PID 0  - PF0       - ST2MM
//    PID 1  - PF1       - HE-LB Dummy 
//    PID 2  - PF2       - HE-LB
//    PID 3  - PF3       - VIO
//    PID 4  - PF4       - HPS-CE
//    PID 5+ - PF5+/VF1+ - NULL AFUs
//    

`include "fpga_defines.vh"
`ifdef INCLUDE_HSSI
   `include "ofs_fim_eth_plat_defines.svh"
   import ofs_fim_eth_if_pkg::*;
`endif 
import top_cfg_pkg::*;
import pcie_ss_axis_pkg::*;

module fim_afu_instances # (
   parameter NUM_SR_PORTS = 1,
   parameter NUM_PF       = top_cfg_pkg::FIM_NUM_PF,
   parameter NUM_VF       = top_cfg_pkg::FIM_NUM_VF,
   // PF/VF to which each port is mapped
   parameter pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t[NUM_SR_PORTS-1:0] SR_PF_VF_INFO =
                {NUM_SR_PORTS{pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t'(0)}},

   parameter NUM_MEM_CH      = 0,
   parameter MAX_ETH_CH      = ofs_fim_eth_plat_if_pkg::MAX_NUM_ETH_CHANNELS
)(
   input  logic clk,
   input  logic clk_div2,
   input  logic clk_div4,
   input  logic uclk_usr,
   input  logic uclk_usr_div2,

   input  logic rst_n,
   input  logic [NUM_SR_PORTS-1:0] func_pf_rst_n,
   input  logic [NUM_SR_PORTS-1:0] func_vf_rst_n,
   input  logic [NUM_SR_PORTS-1:0] port_rst_n,
   input  logic clk_csr,
   input  logic rst_n_csr,      
   ofs_fim_axi_lite_if       apf_mctp_mst_if,
   ofs_fim_axi_lite_if       apf_st2mm_mst_if,
   ofs_fim_axi_lite_if.slave apf_st2mm_slv_if,

    //HPS Interfaces 
   ofs_fim_axi_mmio_if.slave             hps_axi4_mm_if,
   ofs_fim_ace_lite_if.master            hps_ace_lite_if,

   input                                h2f_reset,

   pcie_ss_axis_if.sink   afu_axi_rx_a_if[NUM_SR_PORTS-1:0], 
   pcie_ss_axis_if.source afu_axi_tx_a_if[NUM_SR_PORTS-1:0],
   pcie_ss_axis_if.sink   afu_axi_rx_b_if[NUM_SR_PORTS-1:0], 
   pcie_ss_axis_if.source afu_axi_tx_b_if[NUM_SR_PORTS-1:0]
);

import ofs_fim_cfg_pkg::*;

localparam MM_ADDR_WIDTH     = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH;
localparam MM_DATA_WIDTH     = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;
localparam NUM_TAGS  = ofs_pcie_ss_cfg_pkg::PCIE_EP_MAX_TAGS;

//
// Macros for mapping port defintions to PF/VF resets. We use macros instead
// of functions to avoid problems with continuous assignment.
//

localparam ST2MM_PID = 0; 
localparam HLB_DUMMY_PID = 1; 
localparam HLB_PID = 2; 
localparam VIO_PID = 3; 
localparam HPS_PID = 4; 
localparam FIRST_NULL_PID = 5;

//----------------------------------------------------------------
// ST2MM
//----------------------------------------------------------------
st2mm #(
   .PF_NUM          (SR_PF_VF_INFO[ST2MM_PID].pf_num),
   .VF_NUM          (SR_PF_VF_INFO[ST2MM_PID].vf_num),
   .VF_ACTIVE       (SR_PF_VF_INFO[ST2MM_PID].vf_active),
   .MM_ADDR_WIDTH   (MM_ADDR_WIDTH),
   .MM_DATA_WIDTH   (MM_DATA_WIDTH),
   .PMCI_BASEADDR   (fabric_width_pkg::bpf_pmci_slv_baseaddress),
   .TX_VDM_OFFSET   (16'h2000), 
   .RX_VDM_OFFSET   (16'h2000), 
   .READ_ALLOWANCE  (1),
   .WRITE_ALLOWANCE (1),
   .FEAT_ID         (12'h14),
   .FEAT_VER        (4'h0),
   .END_OF_LIST     (fabric_width_pkg::apf_st2mm_slv_eol),
   .NEXT_DFH_OFFSET (fabric_width_pkg::apf_st2mm_slv_next_dfh_offset)
) st2mm (
   .clk               (clk                         ),
   .rst_n             (rst_n                       ),
   .clk_csr           (clk_csr                     ),
   .rst_n_csr         (rst_n_csr                   ),
   .axis_rx_if        (afu_axi_rx_a_if[ST2MM_PID]), // pipe2fn_rx_a_port[0]
   .axis_tx_if        (afu_axi_tx_a_if[ST2MM_PID]),
   .axi_m_pmci_vdm_if (apf_mctp_mst_if             ),
   .axi_m_if          (apf_st2mm_mst_if            ),
   .axi_s_if          (apf_st2mm_slv_if            )   
);

// we do not use the TX B port
assign afu_axi_tx_b_if[ST2MM_PID].tvalid = 1'b0;
assign afu_axi_rx_b_if[ST2MM_PID].tready = 1'b1;

//----------------------------------------------------------------
//HE-LB Dummy 
//----------------------------------------------------------------

generate if (HLB_DUMMY_PID < NUM_SR_PORTS) begin : hlb_gen
   he_null #(
      .CSR_DATA_WIDTH (64),
      .CSR_ADDR_WIDTH (16),
      .CSR_DEPTH      (4),
      .PF_ID          (SR_PF_VF_INFO[HLB_DUMMY_PID].pf_num),
      .VF_ID          (SR_PF_VF_INFO[HLB_DUMMY_PID].vf_num),
      .VF_ACTIVE      (SR_PF_VF_INFO[HLB_DUMMY_PID].vf_active)
   ) he_lb_dummy_wrapper (
      .clk                (clk),
      .rst_n       (port_rst_n[HLB_DUMMY_PID]),
      .i_rx_if     (afu_axi_rx_a_if[HLB_DUMMY_PID]), // pipe2fn_rx_a_port[2]
      .o_tx_if     (afu_axi_tx_a_if[HLB_DUMMY_PID])
   );

   // we do not use the TX B port
   assign afu_axi_tx_b_if[HLB_DUMMY_PID].tvalid = 1'b0;
   assign afu_axi_rx_b_if[HLB_DUMMY_PID].tready = 1'b1;
end
endgenerate
//----------------------------------------------------------------
//HE-LB 
//----------------------------------------------------------------
   `ifdef USE_NULL_HE_LB
		generate if (HLB_PID < NUM_SR_PORTS) begin : hlb_null_gen
			he_null #(
				 .CSR_DATA_WIDTH (64),
				 .CSR_ADDR_WIDTH (16),
				 .CSR_DEPTH      (4),
				 .PF_ID          (SR_PF_VF_INFO[HLB_PID].pf_num),
				 .VF_ID          (SR_PF_VF_INFO[HLB_PID].vf_num),
				 .VF_ACTIVE      (SR_PF_VF_INFO[HLB_PID].vf_active)
			) null_he_lb (
				 .clk                (clk),
				 .rst_n       (port_rst_n[HLB_PID]),
				 .i_rx_if     (afu_axi_rx_a_if[HLB_PID]),
				 .o_tx_if     (afu_axi_tx_a_if[HLB_PID])
			);

                        // we do not use the TX B port
                        assign afu_axi_tx_b_if[HLB_PID].tvalid = 1'b0;
                        assign afu_axi_rx_b_if[HLB_PID].tready = 1'b1;
		end
		endgenerate
   `else // (not) USE_NULL_HE_LB
		generate if (HLB_PID < NUM_SR_PORTS) begin : hlb_top_gen
			he_lb_top #(
				.PF_ID(SR_PF_VF_INFO[HLB_PID].pf_num),
				.VF_ID(SR_PF_VF_INFO[HLB_PID].vf_num),
				.VF_ACTIVE(SR_PF_VF_INFO[HLB_PID].vf_active)
			) he_lb_top (
				.clk        (clk),
			        .rst_n      (port_rst_n[HLB_PID]),
				.axi_rx_a_if(afu_axi_rx_a_if[HLB_PID]),
				.axi_rx_b_if(afu_axi_rx_b_if[HLB_PID]),
				.axi_tx_a_if(afu_axi_tx_a_if[HLB_PID]),
				.axi_tx_b_if(afu_axi_tx_b_if[HLB_PID])
			);
		end
		endgenerate
   `endif // USE_NULL_HE_LB
//----------------------------------------------------------------
// VIRTIO LB
//----------------------------------------------------------------
generate if (VIO_PID < NUM_SR_PORTS) begin : gen_vio
   he_null #(
      .CSR_DATA_WIDTH (64),
      .CSR_ADDR_WIDTH (16),
      .CSR_DEPTH      (4),
      .PF_ID          (SR_PF_VF_INFO[VIO_PID].pf_num),
      .VF_ID          (SR_PF_VF_INFO[VIO_PID].vf_num),
      .VF_ACTIVE      (SR_PF_VF_INFO[VIO_PID].vf_active),
      .USE_VIRTIO_GUID(1)
   ) virtio_top_inst (
      .clk                (clk),
      .rst_n       (port_rst_n[VIO_PID]),
      .i_rx_if     (afu_axi_rx_a_if[VIO_PID]),
      .o_tx_if     (afu_axi_tx_a_if[VIO_PID])
   );

   // we do not use the TX B port
   assign afu_axi_tx_b_if[VIO_PID].tvalid = 1'b0;
   assign afu_axi_rx_b_if[VIO_PID].tready = 1'b1;
end
endgenerate
//----------------------------------------------------------------
// HPS Copy Engine
//----------------------------------------------------------------
   `ifdef INCLUDE_HPS
		generate if (HPS_PID < NUM_SR_PORTS) begin : hps_gen
			ce_top #(
				 .CE_PF_ID               (SR_PF_VF_INFO[HPS_PID].pf_num   ),
				 .CE_VF_ID               (SR_PF_VF_INFO[HPS_PID].vf_num   ),
				 .CE_VF_ACTIVE           (SR_PF_VF_INFO[HPS_PID].vf_active),
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
				.clk                (clk                       ),
				.rst                (~port_rst_n[HPS_PID]      ),
				.axis_rxreq_if      (afu_axi_rx_a_if[HPS_PID]  ),
				.axis_rx_if         (afu_axi_rx_b_if[HPS_PID]  ),
				.axis_tx_if         (afu_axi_tx_a_if[HPS_PID]  ),
				.ace_lite_tx_if     (hps_ace_lite_if           ),
				.h2f_reset          (h2f_reset                 ),
				.axi4mm_rx_if       (hps_axi4_mm_if            )
			);

                        // we do not use the TX B port
                        assign afu_axi_tx_b_if[HPS_PID].tvalid = 1'b0;
		end
		endgenerate
   `else // (not) INCLUDE_HPS
		generate if (HPS_PID < NUM_SR_PORTS) begin : hps_gen
			he_null #(
				 .CSR_DATA_WIDTH (64),
				 .CSR_ADDR_WIDTH (16),
				 .CSR_DEPTH      (4),
				 .PF_ID          (SR_PF_VF_INFO[HPS_PID].pf_num),
				 .VF_ID          (SR_PF_VF_INFO[HPS_PID].vf_num),
				 .VF_ACTIVE      (SR_PF_VF_INFO[HPS_PID].vf_active)
			) null_ce (
				 .clk                (clk),
				 .rst_n       (port_rst_n[HPS_PID]),
				 .i_rx_if     (afu_axi_rx_a_if[HPS_PID]),
				 .o_tx_if     (afu_axi_tx_a_if[HPS_PID])
			);

                        // we do not use the TX B port
                        assign afu_axi_tx_b_if[HPS_PID].tvalid = 1'b0;
                        assign afu_axi_rx_b_if[HPS_PID].tready = 1'b1;

			// Tieoff HPS ports
			always_comb
			begin
				 hps_ace_lite_if.rready  = 1'b0;
				 hps_ace_lite_if.bready  = 1'b0;
				 hps_ace_lite_if.wvalid  = 1'b0;
				 hps_ace_lite_if.arvalid = 1'b0;
				 hps_axi4_mm_if.awready  = 1'b0;
				 hps_axi4_mm_if.wready   = 1'b0;
				 hps_axi4_mm_if.arready  = 1'b0;
				 hps_axi4_mm_if.bvalid   = 1'b0;
				 hps_axi4_mm_if.rvalid   = 1'b0;
			end
		end
		endgenerate
   `endif // INCLUDE_HPS
//----------------------------------------------------------------
//HE-HSSI 
//----------------------------------------------------------------
`ifdef INCLUDE_HSSI
	`ifdef INCLUDE_PTP
		generate
			for (genvar nump=0; nump<MAX_NUM_ETH_CHANNELS; nump++) begin : GenRst
				assign hssi_ptp_tx_tod[nump].tdata               = 'h0;
				assign hssi_ptp_tx_tod[nump].tvalid              = 1'b0;
				assign hssi_ptp_rx_tod[nump].tdata               = 'h0;
				assign hssi_ptp_rx_tod[nump].tvalid              = 1'b0;
				assign hssi_ss_st_tx[nump].tx.tuser.ptp          = 'h0;
				assign hssi_ss_st_tx[nump].tx.tuser.ptp_extended = 1'h0;
			end
		endgenerate
	`endif //INCLUDE_PTP
`endif

genvar i;
generate
    for(i=FIRST_NULL_PID; i<NUM_SR_PORTS; i=i+1)  begin : gen_he_null
      he_null #(
         .PF_ID (SR_PF_VF_INFO[i].pf_num),
         .VF_ID (SR_PF_VF_INFO[i].vf_num),
         .VF_ACTIVE (SR_PF_VF_INFO[i].vf_active)
      ) he_null_sr (
         .clk (clk),
         .rst_n (port_rst_n[i]),
         .i_rx_if (afu_axi_rx_a_if[i]),
         .o_tx_if (afu_axi_tx_a_if[i])
      );

      // we do not use the TX B port
      assign afu_axi_tx_b_if[i].tvalid = 1'b0;
      assign afu_axi_rx_b_if[i].tready = 1'b1;
    end
endgenerate

endmodule
