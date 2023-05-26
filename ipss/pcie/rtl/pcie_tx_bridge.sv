// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Functions:
//    Adapt AXI4-S TX streaming interface to PCIe HIP IP AVST TX interface
//       * The AVST TX interface contains two 256-bit data channels
//       * The AXI4-S TX interface contains single AXI4-S channel with multiple TLP data streams
//         (See fim_if_pkg.sv for details)
//
//    FIM requirement:
//      1) CPL timeout checker in pcie_checker can only handles one MRd per cycle. 
//         Bridge or downstream TX arbiter needs to make sure only one MRd is sent to pcie_checker per cycle
//
//    PCIe HIP IP requirements:
//      1) The bridge needs to check for RX buffer credit (i.e. cpl_pending_data_cnt < credit limit) before sending non-posted request (MRd)   
//         If there is not enough credit for non-posted request, the bridge should stop sending non-posted request
//         while continue sending other TLP packets 
//         One possible implementation is to move non-posted requests and other TLPs into separate FIFO and arbitrate between the two FIFOs
//      2) The bridge needs to make sure no idle cycle when transmitting packets of the same TLP, except when avl_tx_ready is de-asserted.
//         One possible implementation is to buffer MWr packets until EOP is received before sending the packtes to PCIe IP
//      3) The bridge can only send packets to PCIe IP 3 cycles after avl_tx_ready is asserted. 
//         The bridge can send packets to PCIe IP for another 3 cycles following avl_tx_ready de-assertion.
//         Add 2 pipeline stages to avl_tx_ready signal in the bridge to fulfill this requirement.
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"

module pcie_tx_bridge (
   input  logic                           avl_clk,
   input  logic                           avl_rst_n,
   output ofs_fim_pcie_pkg::t_avst_txs    avl_tx_st,
   input  logic                           avl_tx_ready,

   ofs_fim_pcie_txs_axis_if.slave         axis_tx_st,

   output logic                           tx_mrd_valid,
   output logic [10:0]                    tx_mrd_length,
   output logic [PCIE_EP_TAG_WIDTH-1:0]   tx_mrd_tag,
   output logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]            tx_mrd_pfn,
   output logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]            tx_mrd_vfn,
   output logic                           tx_mrd_vf_act,
   input  logic [CPL_CREDIT_WIDTH-1:0]    cpl_pending_data_cnt
);

import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

`ifdef PTILE 
   pcie_tx_bridge_ptile pcie_tx_bridge_ptile (
      .avl_clk                (avl_clk),
      .avl_rst_n              (avl_rst_n),
      .avl_tx_st              (avl_tx_st),
      .avl_tx_ready           (avl_tx_ready),

      .axis_tx_st             (axis_tx_st),

      .tx_mrd_valid           (tx_mrd_valid),
      .tx_mrd_length          (tx_mrd_length),
      .tx_mrd_tag             (tx_mrd_tag),
      .tx_mrd_pfn             (tx_mrd_pfn),
      .tx_mrd_vfn             (tx_mrd_vfn),
      .tx_mrd_vf_act          (tx_mrd_vf_act),

      .cpl_pending_data_cnt   (cpl_pending_data_cnt)
   );
`else 
   pcie_tx_bridge_htile pcie_tx_bridge_htile (
      .avl_clk                (avl_clk),
      .avl_rst_n              (avl_rst_n),
      .avl_tx_st              (avl_tx_st),
      .avl_tx_ready           (avl_tx_ready),

      .axis_tx_st             (axis_tx_st),

      .tx_mrd_valid           (tx_mrd_valid),
      .tx_mrd_length          (tx_mrd_length),
      .tx_mrd_tag             (tx_mrd_tag),
      .tx_mrd_pfn             (tx_mrd_pfn),
      .tx_mrd_vfn             (tx_mrd_vfn),
      .tx_mrd_vf_act          (tx_mrd_vf_act),

      .cpl_pending_data_cnt   (cpl_pending_data_cnt)
   );
`endif


// synthesis translate_off

initial
begin : tx_logger
   static int log_fd = $fopen("log_ofs_fim_pcie_tx_bridge.tsv", "w");
   int cycle = 0;
   forever @(posedge avl_clk) begin
      if (avl_rst_n) begin
         if (axis_tx_st.tready && axis_tx_st.tx.tvalid) begin
            log_axis_tx_st(log_fd, "axis_tx_st", cycle, axis_tx_st.tx);
         end

         log_avl_tx_st(log_fd, "avl_tx_st", cycle, avl_tx_st);

         cycle = cycle + 1;
      end
   end
end

task log_axis_tx_st;
   input int log_fd;
   input string ctx_name;
   input int cycle;
   input t_axis_pcie_txs tx;
begin
   for (int i = 0; i < FIM_PCIE_TLP_CH; i = i + 1)
   begin
      if (tx.tdata[i].valid)
      begin
         $fwrite(log_fd, "%s:\t%t [%d] ch%0d %s\n",
                 ctx_name, $time, cycle, i,
                 ofs_fim_pcie_hdr_def::func_flit_to_string(tx.tdata[i].sop,
                                                           tx.tdata[i].eop,
                                                           tx.tdata[i].hdr,
                                                           tx.tdata[i].payload));
         $fflush(log_fd);
      end
   end
end
endtask // log_afu_tx_st

task log_avl_tx_st;
   input int log_fd;
   input string ctx_name;
   input int cycle;
   input t_avst_txs tx;
begin
   for (int i = 0; i < FIM_PCIE_TLP_CH; i = i + 1)
   begin
      if (tx[i].valid)
      begin
         $fwrite(log_fd, "%s:\t%t [%d] ch%0d %s\n",
                 ctx_name, $time, cycle, i,
                 ofs_fim_pcie_pkg::func_tx_to_string(tx[i]));

         $fflush(log_fd);
      end
   end
end
endtask // log_avl_tx_st

// synthesis translate_on

endmodule
