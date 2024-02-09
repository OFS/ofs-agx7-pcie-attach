// Copyright 2022 Intel Corporation
// SPDX-License-Identifier: MIT

// Disable this afu_main() when the FIM provides a shared version of the module.
// A shared afu_main() instantiates port_afu_instances(), just like the one here.
`ifndef SHARED_AFU_MAIN_TO_PORT_AFU_INSTANCES

`include "ofs_plat_if.vh"

// Merge HSSI macros from various platforms into a single AFU_MAIN_HAS_HSSI
`ifdef INCLUDE_HSSI
  `define AFU_MAIN_HAS_HSSI 1
`endif
`ifdef PLATFORM_FPGA_FAMILY_S10
  `ifdef INCLUDE_HE_HSSI
    `define AFU_MAIN_HAS_HSSI 1
  `endif
`endif

// ========================================================================
//
//  The ports in this implementation of afu_main() are complicated because
//  the code is expected to compile on multiple platforms, each with
//  subtle variations.
//
//  An implementation for a single platform should be simplified by
//  reducing the ports to only those of the target.
//
//  This example currently compiles on OFS for d5005 and n6000.
//
// ========================================================================

module afu_main 
#(
   parameter PG_NUM_PORTS    = 1,
   // PF/VF to which each port is mapped
   parameter pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t[PG_NUM_PORTS-1:0] PORT_PF_VF_INFO =
                {PG_NUM_PORTS{pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t'(0)}},

   parameter NUM_MEM_CH      = 0,
   parameter MAX_ETH_CH      = ofs_fim_eth_plat_if_pkg::MAX_NUM_ETH_CHANNELS
)(
   input  logic clk,
   input  logic clk_div2,
   input  logic clk_div4,
   input  logic uclk_usr,
   input  logic uclk_usr_div2,

   input  logic rst_n,
`ifdef PLATFORM_FPGA_FAMILY_S10
   input  logic port_rst_n [PG_NUM_PORTS-1:0],
   input  logic rst_n_100M,
`else
   input  logic [PG_NUM_PORTS-1:0] port_rst_n,
`endif

   // PCIe A ports are the standard TLP channels. All host responses
   // arrive on the RX A port.
   pcie_ss_axis_if.source        afu_axi_tx_a_if [PG_NUM_PORTS-1:0],
   pcie_ss_axis_if.sink          afu_axi_rx_a_if [PG_NUM_PORTS-1:0],
   // PCIe B ports are a second channel on which reads and interrupts
   // may be sent from the AFU. To improve throughput, reads on B may flow
   // around writes on A through PF/VF MUX trees until writes are committed
   // to the PCIe subsystem. AFUs may tie off the B port and send all
   // messages to A.
   pcie_ss_axis_if.source        afu_axi_tx_b_if [PG_NUM_PORTS-1:0],
   // Write commits are signaled here on the RX B port, indicating the
   // point at which the A and B channels become ordered within the FIM.
   // Commits are signaled after tlast of a write on TX A, after arbitration
   // with TX B within the FIM. The commit is a Cpl (without data),
   // returning the tag value from the write request. AFUs that do not
   // need local write commits may ignore this port, but must set
   // tready to 1.
   pcie_ss_axis_if.sink          afu_axi_rx_b_if [PG_NUM_PORTS-1:0]

   `ifdef INCLUDE_DDR4
      // Local memory
     ,ofs_fim_emif_axi_mm_if.user ext_mem_if [NUM_MEM_CH-1:0]
   `endif
   `ifdef PLATFORM_FPGA_FAMILY_S10
      // S10 uses AVMM for DDR
     ,ofs_fim_emif_avmm_if.user   ext_mem_if [NUM_MEM_CH-1:0]
   `endif

   `ifdef AFU_MAIN_HAS_HSSI
     ,ofs_fim_hssi_ss_tx_axis_if.client hssi_ss_st_tx [MAX_ETH_CH-1:0],
      ofs_fim_hssi_ss_rx_axis_if.client hssi_ss_st_rx [MAX_ETH_CH-1:0],
      ofs_fim_hssi_fc_if.client         hssi_fc [MAX_ETH_CH-1:0],
      input logic [MAX_ETH_CH-1:0]      i_hssi_clk_pll
   `endif

    // S10 HSSI PTP interface
   `ifdef INCLUDE_PTP
     ,ofs_fim_hssi_ptp_tx_tod_if.client       hssi_ptp_tx_tod [MAX_ETH_CH-1:0],
      ofs_fim_hssi_ptp_rx_tod_if.client       hssi_ptp_rx_tod [MAX_ETH_CH-1:0],
      ofs_fim_hssi_ptp_tx_egrts_if.client     hssi_ptp_tx_egrts [MAX_ETH_CH-1:0],
      ofs_fim_hssi_ptp_rx_ingrts_if.client    hssi_ptp_rx_ingrts [MAX_ETH_CH-1:0]
   `endif

   // JTAG interface for PR region debug
   `ifdef PLATFORM_FPGA_FAMILY_S10
      // Old JTAG interface: just wires
     ,input  logic               sr2pr_tms,
      input  logic               sr2pr_tdi,
      output logic               pr2sr_tdo,
      input  logic               sr2pr_tck,
      input  logic               sr2pr_tckena
   `else
     ,ofs_jtag_if.sink           remote_stp_jtag_if
   `endif
   );

    //----------------------------------------------
    // Merge soft reset and power on reset
    //----------------------------------------------

    logic rst_n_q1 = 1'b0;
    logic [PG_NUM_PORTS-1:0] port_rst_n_q1 = {PG_NUM_PORTS{1'b0}};
    logic [PG_NUM_PORTS-1:0] port_rst_n_q2 = {PG_NUM_PORTS{1'b0}};

    always @(posedge clk) begin
        rst_n_q1 <= rst_n;
    end

    for (genvar p = 0; p < PG_NUM_PORTS; p = p + 1) begin : reg_rst
        always @(posedge clk) begin
            port_rst_n_q1[p] <= port_rst_n[p] && rst_n_q1;
            port_rst_n_q2[p] <= port_rst_n_q1[p];
        end
    end


    //----------------------------------------------
    // AFUs
    //----------------------------------------------

    // Instantiate port_afu_instances, using the same interface that the
    // default afu_main() would use.

    port_afu_instances
      #(
        .PG_NUM_PORTS(PG_NUM_PORTS),
        .PORT_PF_VF_INFO(PORT_PF_VF_INFO),
        .NUM_MEM_CH(NUM_MEM_CH),
        .MAX_ETH_CH(MAX_ETH_CH)
        )
      port_afu_instances
       (
        .port_rst_n(port_rst_n_q2),

        .*
        );


    //----------------------------------------------
    // Remote Debug JTAG IP instantiation
    //----------------------------------------------

    wire remote_stp_conf_reset = ~rst_n_q1;
    `include "ofs_fim_remote_stp_node.vh"

endmodule : afu_main

`endif //  `ifndef SHARED_AFU_MAIN_TO_PORT_AFU_INSTANCES
