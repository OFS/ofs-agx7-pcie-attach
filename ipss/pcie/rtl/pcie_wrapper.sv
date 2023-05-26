// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Top level module of PCIe subsystem.
//
//-----------------------------------------------------------------------------

`include "fpga_defines.vh"


module pcie_wrapper 
import ofs_fim_cfg_pkg::*;
import pcie_ss_axis_pkg::*;
import ofs_fim_pcie_hdr_def::*;
#(
   parameter            PCIE_LANES      = 16,
   parameter            MM_ADDR_WIDTH   = 19,
   parameter            MM_DATA_WIDTH   = 64,
   parameter bit [11:0] FEAT_ID         = 12'h0,
   parameter bit [3:0]  FEAT_VER        = 4'h0,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit        END_OF_LIST     = 1'b0,
   parameter            SOC_ATTACH      = 0
)(
   input  logic                     fim_clk,
   input  logic                     fim_rst_n,

   input  logic                     csr_clk,
   input  logic                     csr_rst_n,

   input  logic                     ninit_done,
   output logic                     reset_status,

   input  logic                     p0_subsystem_cold_rst_n,    
   input  logic                     p0_subsystem_warm_rst_n,    
   output logic                     p0_subsystem_cold_rst_ack_n,
   output logic                     p0_subsystem_warm_rst_ack_n,
   
   // PCIe pins
   input  logic                     pin_pcie_refclk0_p,
   input  logic                     pin_pcie_refclk1_p,
   input  logic                     pin_pcie_in_perst_n,   // connected to HIP
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_p,
   input  logic [PCIE_LANES-1:0]    pin_pcie_rx_n,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_p,
   output logic [PCIE_LANES-1:0]    pin_pcie_tx_n,

   //TXREQ ports
   output logic                     p0_ss_app_st_txreq_tready,
   input  logic                     p0_app_ss_st_txreq_tvalid,
   input  logic [255:0]             p0_app_ss_st_txreq_tdata,
   input  logic                     p0_app_ss_st_txreq_tlast,

   //Ctrl Shadow ports
   output logic                     p0_ss_app_st_ctrlshadow_tvalid,
   output logic [39:0]              p0_ss_app_st_ctrlshadow_tdata,

   // AXI-S data interfaces
   pcie_ss_axis_if.source           axi_st_rxreq_if,
   pcie_ss_axis_if.source           axi_st_rx_if,
   pcie_ss_axis_if.sink             axi_st_tx_if,

   // AXI4-lite CSR interface
   ofs_fim_axi_lite_if.slave        csr_lite_if,
   ofs_fim_axi_lite_if.master       ss_init_lite_if,


   //Completion Timeout Interface
   output pcie_ss_axis_pkg::t_axis_pcie_cplto axis_cpl_timeout,
 
   output pcie_ss_axis_pkg::t_pcie_tag_mode tag_mode,

   // FLR 
   output pcie_ss_axis_pkg::t_axis_pcie_flr    axi_st_flr_req,
   input  pcie_ss_axis_pkg::t_axis_pcie_flr    axi_st_flr_rsp
);


t_axis_pcie         axis_tx;
logic               axis_tx_tready;

logic               pcie_linkup;
logic [31:0]        pcie_rx_err_code;

t_pcie_ctrl_shdw    ctrl_shdw_reg;
t_pcie_tag_mode     tag_mode_sync;

ofs_fim_axi_lite_if #(.AWADDR_WIDTH(18), .ARADDR_WIDTH(18), .WDATA_WIDTH(64), .RDATA_WIDTH(64)) ss_csr_lite_if();

always_comb begin
   axis_tx.tvalid = axi_st_tx_if.tvalid;
   axis_tx.tdata  = axi_st_tx_if.tdata;
   axis_tx.tkeep  = axi_st_tx_if.tkeep;
   axis_tx.tlast  = axi_st_tx_if.tlast;
   axis_tx.tuser  = axi_st_tx_if.tuser_vendor;

   axis_tx_tready = axi_st_tx_if.tready;
end

pcie_ss_if #(
   .MM_ADDR_WIDTH   (MM_ADDR_WIDTH), 
   .MM_DATA_WIDTH   (MM_DATA_WIDTH),
   .FEAT_ID         (FEAT_ID),
   .FEAT_VER        (FEAT_VER),
   .NEXT_DFH_OFFSET (NEXT_DFH_OFFSET),
   .END_OF_LIST     (END_OF_LIST)   
) pcie_ss_if (
   .fim_clk            (fim_clk),
   .fim_rst_n          (fim_rst_n),

   .csr_clk            (csr_clk),
   .csr_rst_n          (csr_rst_n),

   .i_axis_tx          (axis_tx),
   .i_axis_tx_tready   (axis_tx_tready),

   .i_axis_cpl_timeout (axis_cpl_timeout),
   
   .i_pcie_linkup      (pcie_linkup),
   .i_rx_err_code      (pcie_rx_err_code),
 
   .csr_lite_if        (csr_lite_if),
   .ss_csr_lite_if     (ss_csr_lite_if)
);


//
// PCIe TLP streams between the PCIe SS top and the MSI-X MUX.
// These are defined and used even when INCLUDE_MSIX is disabled
// to simplify the code. When INCLUDE_MSIX is disabled, the
// axi_st_tx_if/axi_st_rx_if streams are assigned to mux2ho/ho2mux.
//
pcie_ss_axis_if           mux2ho_tx_st(.clk(fim_clk), .rst_n(fim_rst_n));
pcie_ss_axis_if           ho2mux_rx_st(.clk(fim_clk), .rst_n(fim_rst_n));


`ifdef INCLUDE_PCIE_SS
   import ofs_fim_if_pkg::*;

   t_sideband_from_pcie   pcie_p2c_sideband;

   assign pcie_linkup = pcie_p2c_sideband.pcie_linkup;
   assign pcie_rx_err_code = pcie_p2c_sideband.pcie_chk_rx_err_code;

   pcie_ss_top #(
      .PCIE_LANES       (ofs_fim_cfg_pkg::PCIE_LANES),
      .SOC_ATTACH       (SOC_ATTACH)
   ) pcie_ss_top (
      .fim_clk                        (fim_clk                    ),
      .fim_rst_n                      (fim_rst_n                  ),
      .csr_clk                        (csr_clk                    ),
      .csr_rst_n                      (csr_rst_n                  ),
      .ninit_done                     (ninit_done                 ),
      .reset_status                   (reset_status               ),
      .p0_subsystem_cold_rst_n        (p0_subsystem_cold_rst_n    ),  
      .p0_subsystem_warm_rst_n        (p0_subsystem_warm_rst_n    ),    
      .p0_subsystem_cold_rst_ack_n    (p0_subsystem_cold_rst_ack_n),
      .p0_subsystem_warm_rst_ack_n    (p0_subsystem_warm_rst_ack_n),
      .pin_pcie_refclk0_p             (pin_pcie_refclk0_p         ),
      .pin_pcie_refclk1_p             (pin_pcie_refclk1_p         ),
      .pin_pcie_in_perst_n            (pin_pcie_in_perst_n        ),   
      .pin_pcie_rx_p                  (pin_pcie_rx_p              ),
      .pin_pcie_rx_n                  (pin_pcie_rx_n              ),
      .pin_pcie_tx_p                  (pin_pcie_tx_p              ),                
      .pin_pcie_tx_n                  (pin_pcie_tx_n              ), 
      .p0_ss_app_st_txreq_tready      (p0_ss_app_st_txreq_tready  ), 
      .p0_app_ss_st_txreq_tvalid      (p0_app_ss_st_txreq_tvalid  ),
      .p0_app_ss_st_txreq_tdata       (p0_app_ss_st_txreq_tdata   ),
      .p0_app_ss_st_txreq_tlast       (p0_app_ss_st_txreq_tlast   ),
      .axi_st_rxreq_if                (axi_st_rxreq_if),
      .p0_ss_app_st_ctrlshadow_tvalid (p0_ss_app_st_ctrlshadow_tvalid ),
      .p0_ss_app_st_ctrlshadow_tdata  (p0_ss_app_st_ctrlshadow_tdata  ),
      .axi_st_rx_if                   (ho2mux_rx_st               ),
      .axi_st_tx_if                   (mux2ho_tx_st               ),
      .ss_csr_lite_if                 (ss_csr_lite_if             ),
      .ss_init_lite_if                (ss_init_lite_if            ),
      .flr_req_if                     (axi_st_flr_req             ),
      .flr_rsp_if                     (axi_st_flr_rsp             ),
      .cpl_timeout_if                 (axis_cpl_timeout           ),
      .pcie_p2c_sideband              (pcie_p2c_sideband          )
   );

   // synthesis translate_off
   // Log TLP AXI-S traffic at the PCIe SS edge
   logic ho2mux_rx_st_sop, mux2ho_tx_st_sop;

   initial
   begin : log
      static int log_fd = $fopen("log_pcie_ss_edge.tsv", "w");

      // Write module hierarchy to the top of the log
      $fwrite(log_fd, "pcie_wrapper.sv: %m\n\n");

      forever @(posedge fim_clk) begin
         if (fim_rst_n && ho2mux_rx_st.tvalid && ho2mux_rx_st.tready) begin
            $fwrite(log_fd, "RX: %s\n",
            pcie_ss_pkg::func_pcie_ss_flit_to_string(
            ho2mux_rx_st_sop, ho2mux_rx_st.tlast,
            pcie_ss_hdr_pkg::func_hdr_is_pu_mode(ho2mux_rx_st.tuser_vendor),
            ho2mux_rx_st.tdata, ho2mux_rx_st.tkeep));
            $fflush(log_fd);
         end

         if (fim_rst_n && mux2ho_tx_st.tvalid && mux2ho_tx_st.tready) begin
            $fwrite(log_fd, "TX: %s\n",
            pcie_ss_pkg::func_pcie_ss_flit_to_string(
            mux2ho_tx_st_sop, mux2ho_tx_st.tlast,
            pcie_ss_hdr_pkg::func_hdr_is_pu_mode(mux2ho_tx_st.tuser_vendor),
            mux2ho_tx_st.tdata, mux2ho_tx_st.tkeep));
            $fflush(log_fd);
         end
      end
   end

   always_ff @(posedge fim_clk) begin
      if (ho2mux_rx_st.tvalid && ho2mux_rx_st.tready)
         ho2mux_rx_st_sop <= ho2mux_rx_st.tlast;
      if (mux2ho_tx_st.tvalid && mux2ho_tx_st.tready)
         mux2ho_tx_st_sop <= mux2ho_tx_st.tlast;

      if (!fim_rst_n) begin
         ho2mux_rx_st_sop <= 1'b1;
         mux2ho_tx_st_sop <= 1'b1;
      end
   end
   // synthesis translate_on

`else //Used only for Unit sim testing
import ofs_fim_if_pkg::*;
t_sideband_from_pcie   pcie_p2c_sideband;
assign pcie_linkup = pcie_p2c_sideband.pcie_linkup;
assign pcie_rx_err_code = pcie_p2c_sideband.pcie_chk_rx_err_code;

pcie_top #(
   .PCIE_LANES       (16),
   .NUM_PF           (ofs_fim_pcie_pkg::NUM_PF),
   .NUM_VF           (ofs_fim_pcie_pkg::NUM_VF),
   .MAX_NUM_VF       (ofs_fim_pcie_pkg::MAX_NUM_VF),
   .MM_ADDR_WIDTH    (MM_ADDR_WIDTH),
   .MM_DATA_WIDTH    (MM_DATA_WIDTH),
   .FEAT_ID          (12'h020),
   .FEAT_VER         (4'h0),
   .NEXT_DFH_OFFSET  (24'h1000),
   .END_OF_LIST      (1'b0)  
) pcie_top (
   .fim_clk               (fim_clk                    ),
   .fim_rst_n             (fim_rst_n                  ),
   .csr_clk               (csr_clk                    ),
   .csr_rst_n             (csr_rst_n                  ),
   .ninit_done            (ninit_done                 ),
   .reset_status          (reset_status               ),                 
   .pin_pcie_refclk0_p    (pin_pcie_refclk0_p         ),
   .pin_pcie_refclk1_p    (pin_pcie_refclk1_p         ),
   .pin_pcie_in_perst_n   (pin_pcie_in_perst_n        ),   // connected to HIP
   .pin_pcie_rx_p         (pin_pcie_rx_p              ),
   .pin_pcie_rx_n         (pin_pcie_rx_n              ),
   .pin_pcie_tx_p         (pin_pcie_tx_p              ),                
   .pin_pcie_tx_n         (pin_pcie_tx_n              ),                
   .axi_st_rx_if          (ho2mux_rx_st               ),
   .axi_st_tx_if          (mux2ho_tx_st               ),
   .axi_st_rxreq_if       (axi_st_rxreq_if            ),
   .csr_lite_if           (ss_csr_lite_if             ),
   .flr_req_if            (axi_st_flr_req             ),
   .flr_rsp_if            (axi_st_flr_rsp             ),
   .cpl_timeout_if        (axis_cpl_timeout           ),
   .pcie_p2c_sideband     (pcie_p2c_sideband          )

);
`endif

`ifdef INCLUDE_PCIE_SS
always_ff@(posedge csr_clk) begin
   if(~csr_rst_n) begin
      ctrl_shdw_reg.tvalid               <= '0;
   end else begin
      ctrl_shdw_reg.tvalid               <=  p0_ss_app_st_ctrlshadow_tvalid;
   end 

   ctrl_shdw_reg.tdata.pf_num            <=  p0_ss_app_st_ctrlshadow_tdata[2:0];
   ctrl_shdw_reg.tdata.vf_num            <=  p0_ss_app_st_ctrlshadow_tdata[13:3];
   ctrl_shdw_reg.tdata.vf_active         <=  p0_ss_app_st_ctrlshadow_tdata[14];
   ctrl_shdw_reg.tdata.tag_enable_10bit  <=  p0_ss_app_st_ctrlshadow_tdata[30];
   ctrl_shdw_reg.tdata.extended_tag      <=  p0_ss_app_st_ctrlshadow_tdata[29];
end

// Track dynamic PCIe request tag size. This state is valid only for PF0.
always_ff@(posedge csr_clk) begin
   // Always guarantee that the tag mode encoding is 1 hot
   if(~csr_rst_n) begin
      tag_mode_sync.tag_5bit  <= 1'b1;
      tag_mode_sync.tag_8bit  <= 1'b0;
      tag_mode_sync.tag_10bit <= 1'b0;
   end else if(ctrl_shdw_reg.tvalid && ctrl_shdw_reg.tdata.pf_num == 3'b0 &&
               !ctrl_shdw_reg.tdata.vf_active) begin
      if(ctrl_shdw_reg.tdata.extended_tag && ctrl_shdw_reg.tdata.tag_enable_10bit) begin
         // PCIe extended, with 10 bit tags
         tag_mode_sync.tag_5bit  <= 1'b0;
         tag_mode_sync.tag_8bit  <= 1'b0;
         tag_mode_sync.tag_10bit <= 1'b1;
      end else if (ctrl_shdw_reg.tdata.extended_tag) begin
         // PCIe extended, without 10 bit tags
         tag_mode_sync.tag_5bit  <= 1'b0;
         tag_mode_sync.tag_8bit  <= 1'b1;
         tag_mode_sync.tag_10bit <= 1'b0;
      end else begin
         // Not extended -- old 5 bit tag mode
         tag_mode_sync.tag_5bit  <= 1'b1;
         tag_mode_sync.tag_8bit  <= 1'b0;
         tag_mode_sync.tag_10bit <= 1'b0;
      end 
   end
end

localparam CSR_STAT_SYNC_WIDTH = 3;
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(CSR_STAT_SYNC_WIDTH),
   .INIT_VALUE(0),
   .NO_CUT(1)
) csr_resync (
   .clk   (fim_clk),
   .reset (1'b0),
   .d     (tag_mode_sync),
   .q     (tag_mode)
);
`else 
always_comb begin
   tag_mode.tag_5bit  = 1'b0;
   tag_mode.tag_8bit  = 1'b1;
   tag_mode.tag_10bit = 1'b0;
end
`endif


always_comb begin
   mux2ho_tx_st.tvalid = axi_st_tx_if.tvalid;
   mux2ho_tx_st.tdata  = axi_st_tx_if.tdata;
   mux2ho_tx_st.tkeep  = axi_st_tx_if.tkeep;
   mux2ho_tx_st.tlast  = axi_st_tx_if.tlast;
   mux2ho_tx_st.tuser_vendor = axi_st_tx_if.tuser_vendor;

   axi_st_tx_if.tready = mux2ho_tx_st.tready;
end

always_comb begin
   axi_st_rx_if.tvalid = ho2mux_rx_st.tvalid;
   axi_st_rx_if.tdata  = ho2mux_rx_st.tdata;
   axi_st_rx_if.tkeep  = ho2mux_rx_st.tkeep;
   axi_st_rx_if.tlast  = ho2mux_rx_st.tlast;
   axi_st_rx_if.tuser_vendor = ho2mux_rx_st.tuser_vendor;

   ho2mux_rx_st.tready = axi_st_rx_if.tready;
end

endmodule : pcie_wrapper
