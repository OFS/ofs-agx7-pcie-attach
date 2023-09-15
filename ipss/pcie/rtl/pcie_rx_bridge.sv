// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Adapt PCIe AVST RX interface to AXI4-S RX streaming interface  
//
//   ------- 
//   Clock domain 
//   ------- 
//   All the inputs and outputs are synchronous to input clock : avl_clk
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"
import ofs_fim_pcie_pkg::*;
import ofs_fim_if_pkg::*;

module pcie_rx_bridge (
   input  logic                     avl_clk,
   input  logic                     avl_rst_n,
   input  t_avst_rxs                avl_rx_st,
   output logic                     avl_rx_ready,  
   
   ofs_fim_pcie_rxs_axis_if.master  axis_rx_st
);

`ifdef PTILE 
   pcie_rx_bridge_ptile pcie_rx_bridge_ptile
   (
      .avl_clk        (avl_clk),
      .avl_rst_n      (avl_rst_n),
      .avl_rx_st      (avl_rx_st),
      .avl_rx_ready   (avl_rx_ready),
      .axis_rx_st     (axis_rx_st)
   );
`else 
   pcie_rx_bridge_htile pcie_rx_bridge_htile
   (
      .avl_clk        (avl_clk),
      .avl_rst_n      (avl_rst_n),
      .avl_rx_st      (avl_rx_st),
      .avl_rx_ready   (avl_rx_ready),
      .axis_rx_st     (axis_rx_st)
   );
`endif


// synthesis translate_off

initial
begin : rx_logger
   static int log_fd = $fopen("log_ofs_fim_pcie_rx_bridge.tsv", "w");
   int cycle = 0;
   forever @(posedge avl_clk) begin
      if (avl_rst_n) begin
         if (axis_rx_st.tready && axis_rx_st.rx.tvalid) begin
            log_axis_rx_st(log_fd, "axis_rx_st", cycle, axis_rx_st.rx);
         end

         if (avl_rx_ready) begin
            log_avl_rx_st(log_fd, "avl_rx_st", cycle, avl_rx_st);
         end

         cycle = cycle + 1;
      end
   end
end

task log_axis_rx_st;
   input int log_fd;
   input string crx_name;
   input int cycle;
   input t_axis_pcie_rxs rx;
begin
   for (int i = 0; i < FIM_PCIE_TLP_CH; i = i + 1)
   begin
      if (rx.tdata[i].valid)
      begin
         $fwrite(log_fd, "%s:\t%t [%d] ch%0d %s\n",
                 crx_name, $time, cycle, i,
                 ofs_fim_pcie_hdr_def::func_flit_to_string(rx.tdata[i].sop,
                                                           rx.tdata[i].eop,
                                                           rx.tdata[i].hdr,
                                                           rx.tdata[i].payload));
         $fflush(log_fd);
      end
   end
end
endtask // log_afu_rx_st

task log_avl_rx_st;
   input int log_fd;
   input string crx_name;
   input int cycle;
   input t_avst_rxs rx;
begin
   for (int i = 0; i < FIM_PCIE_TLP_CH; i = i + 1)
   begin
      if (rx[i].valid)
      begin
         $fwrite(log_fd, "%s:\t%t [%d] ch%0d %s\n",
                 crx_name, $time, cycle, i,
                 ofs_fim_pcie_pkg::func_rx_to_string(rx[i]));

         $fflush(log_fd);
      end
   end
end
endtask // log_avl_rx_st

// synthesis translate_on

endmodule
