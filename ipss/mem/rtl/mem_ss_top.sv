// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Memory Subsystem PO FIM wrapper
//
//-----------------------------------------------------------------------------


module mem_ss_top 
   import mem_ss_pkg::*;
#(
   parameter bit [11:0] FEAT_ID         = 12'h00f,
   parameter bit [3:0]  FEAT_VER        = 4'h1,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit        END_OF_LIST     = 1'b0
)(
   input                        clk,
   input                        reset,

   ofs_fim_emif_axi_mm_if.emif  afu_mem  [MC_CHANNEL-1:0],

   ofs_ddr_no_ecc_if.emif  ddr4_no_ecc [DDR_CHANNEL-1:0],
   // ofs_ddr_ecc_if.emif     ddr4_ecc [DDR_ECC_CHANNEL-1:0],

   // HPS interfaces
   input  logic [4095:0]        hps2emif,
   input  logic [1:0]           hps2emif_gp,
   output logic [4095:0]        emif2hps,
   output logic                 emif2hps_gp,

   ofs_ddr_ecc_if.emif     hps_ddr_mem,

   // CSR interfaces
   input                        clk_csr,
   input                        rst_n_csr,
   ofs_fim_axi_lite_if.slave    csr_lite_if
);
   logic 			mem_ss_rst_n;
   logic 			mem_ss_rst_req;
   logic 			mem_ss_rst_rdy;
   logic 			mem_ss_rst_ack_n;
   logic 			mem_ss_rst_init;

   logic [MC_CHANNEL-1:0] 	mem_ss_cal_fail;
   logic [MC_CHANNEL-1:0] 	mem_ss_cal_success;

   logic [MC_CHANNEL-1:0] 	csr_cal_fail;
   logic [MC_CHANNEL-1:0] 	csr_cal_success;
   
   ofs_fim_axi_lite_if #(.AWADDR_WIDTH(11), .ARADDR_WIDTH(11), .WDATA_WIDTH(32)) ss_csr_lite_32b_if();
   ofs_fim_axi_lite_if #(.AWADDR_WIDTH(11), .ARADDR_WIDTH(11), .WDATA_WIDTH(64)) emif_dfh_if();

fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(0)
) rst_hs_resync (
   .clk   (ddr4_no_ecc[0].ref_clk),
   .reset (1'b0),
   .d     (reset),
   .q     (mem_ss_rst_init)
);

fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(MC_CHANNEL),
   .INIT_VALUE(0),
   .NO_CUT(0)
) mem_ss_cal_success_resync (
   .clk   (clk_csr),
   .reset (!rst_n_csr),
   .d     (mem_ss_cal_success),
   .q     (csr_cal_success)
);

fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(MC_CHANNEL),
   .INIT_VALUE(0),
   .NO_CUT(0)
) mem_ss_cal_fail_resync (
   .clk   (clk_csr),
   .reset (!rst_n_csr),
   .d     (mem_ss_cal_fail),
   .q     (csr_cal_fail)
);
   
rst_hs rst_hs_inst (
   .clk      (ddr4_no_ecc[0].ref_clk),
   .rst_init (mem_ss_rst_init),
   .rst_req  (mem_ss_rst_req),
   .rst_rdy  (mem_ss_rst_rdy),
   .rst_n    (mem_ss_rst_n),
   .rst_ack_n(mem_ss_rst_ack_n)
);

mem_ss_csr #(
   .FEAT_ID          (FEAT_ID),
   .FEAT_VER         (FEAT_VER),
   .NEXT_DFH_OFFSET  (NEXT_DFH_OFFSET),
   .END_OF_LIST      (END_OF_LIST)
) mem_ss_csr_inst (
   .clk              (clk_csr),
   .rst_n            (rst_n_csr),
   .csr_lite_if      (emif_dfh_if),

   .cal_fail         (csr_cal_fail),
   .cal_success      (csr_cal_success)
);

emif_csr_ic emif_csr_interconnect (
   .clk_clk     (clk_csr),
   .reset_reset (!rst_n_csr),

   // APF MemSS CSR interface (64b)
   .emif_csr_slv_awaddr      (csr_lite_if.awaddr),
   .emif_csr_slv_awprot      (csr_lite_if.awprot),
   .emif_csr_slv_awvalid     (csr_lite_if.awvalid),
   .emif_csr_slv_awready     (csr_lite_if.awready),
   .emif_csr_slv_wdata       (csr_lite_if.wdata),
   .emif_csr_slv_wstrb       (csr_lite_if.wstrb),
   .emif_csr_slv_wvalid      (csr_lite_if.wvalid),
   .emif_csr_slv_wready      (csr_lite_if.wready),
   .emif_csr_slv_bresp       (csr_lite_if.bresp),
   .emif_csr_slv_bvalid      (csr_lite_if.bvalid),
   .emif_csr_slv_bready      (csr_lite_if.bready),
   .emif_csr_slv_araddr      (csr_lite_if.araddr),
   .emif_csr_slv_arprot      (csr_lite_if.arprot),
   .emif_csr_slv_arvalid     (csr_lite_if.arvalid),
   .emif_csr_slv_arready     (csr_lite_if.arready),
   .emif_csr_slv_rdata       (csr_lite_if.rdata),
   .emif_csr_slv_rresp       (csr_lite_if.rresp),
   .emif_csr_slv_rvalid      (csr_lite_if.rvalid),
   .emif_csr_slv_rready      (csr_lite_if.rready),

   // Local DFH interface (32b)			  
   .emif_dfh_mst_awaddr  (emif_dfh_if.awaddr),
   .emif_dfh_mst_awprot  (emif_dfh_if.awprot),
   .emif_dfh_mst_awvalid (emif_dfh_if.awvalid),
   .emif_dfh_mst_awready (emif_dfh_if.awready),
   .emif_dfh_mst_wdata   (emif_dfh_if.wdata),
   .emif_dfh_mst_wstrb   (emif_dfh_if.wstrb),
   .emif_dfh_mst_wvalid  (emif_dfh_if.wvalid),
   .emif_dfh_mst_wready  (emif_dfh_if.wready),
   .emif_dfh_mst_bresp   (emif_dfh_if.bresp),
   .emif_dfh_mst_bvalid  (emif_dfh_if.bvalid),
   .emif_dfh_mst_bready  (emif_dfh_if.bready),
   .emif_dfh_mst_araddr  (emif_dfh_if.araddr),
   .emif_dfh_mst_arprot  (emif_dfh_if.arprot),
   .emif_dfh_mst_arvalid (emif_dfh_if.arvalid),
   .emif_dfh_mst_arready (emif_dfh_if.arready),
   .emif_dfh_mst_rdata   (emif_dfh_if.rdata),
   .emif_dfh_mst_rresp   (emif_dfh_if.rresp),
   .emif_dfh_mst_rvalid  (emif_dfh_if.rvalid),
   .emif_dfh_mst_rready  (emif_dfh_if.rready),

   // MemSS CSR interface (32b)			  
   .mem_ss_csr_mst_awaddr  (ss_csr_lite_32b_if.awaddr),
   .mem_ss_csr_mst_awprot  (ss_csr_lite_32b_if.awprot),
   .mem_ss_csr_mst_awvalid (ss_csr_lite_32b_if.awvalid),
   .mem_ss_csr_mst_awready (ss_csr_lite_32b_if.awready),
   .mem_ss_csr_mst_wdata   (ss_csr_lite_32b_if.wdata),
   .mem_ss_csr_mst_wstrb   (ss_csr_lite_32b_if.wstrb),
   .mem_ss_csr_mst_wvalid  (ss_csr_lite_32b_if.wvalid),
   .mem_ss_csr_mst_wready  (ss_csr_lite_32b_if.wready),
   .mem_ss_csr_mst_bresp   (ss_csr_lite_32b_if.bresp),
   .mem_ss_csr_mst_bvalid  (ss_csr_lite_32b_if.bvalid),
   .mem_ss_csr_mst_bready  (ss_csr_lite_32b_if.bready),
   .mem_ss_csr_mst_araddr  (ss_csr_lite_32b_if.araddr),
   .mem_ss_csr_mst_arprot  (ss_csr_lite_32b_if.arprot),
   .mem_ss_csr_mst_arvalid (ss_csr_lite_32b_if.arvalid),
   .mem_ss_csr_mst_arready (ss_csr_lite_32b_if.arready),
   .mem_ss_csr_mst_rdata   (ss_csr_lite_32b_if.rdata),
   .mem_ss_csr_mst_rresp   (ss_csr_lite_32b_if.rresp),
   .mem_ss_csr_mst_rvalid  (ss_csr_lite_32b_if.rvalid),
   .mem_ss_csr_mst_rready  (ss_csr_lite_32b_if.rready)
);
   


mem_ss_fm mem_ss_fm_inst (
   // MemSS Reset request
`ifdef SIM_MODE_NO_MSS_RST
   .app_ss_rst_req        (1'b0),
   .app_ss_cold_rst_n     (1'b1),
`else
   .app_ss_rst_req        (mem_ss_rst_req),
   .app_ss_cold_rst_n     (mem_ss_rst_n),
`endif
   .ss_app_rst_rdy        (mem_ss_rst_rdy),
   .ss_app_cold_rst_ack_n (mem_ss_rst_ack_n),

   // Subsystem CSR AXI4-lite interface
   .csr_app_ss_lite_aclk     (clk_csr),
   .csr_app_ss_lite_areset_n (rst_n_csr),
   .csr_app_ss_lite_awvalid  (    ss_csr_lite_32b_if.awvalid),
   .csr_app_ss_lite_awaddr   ({'b0,ss_csr_lite_32b_if.awaddr}),
   .csr_app_ss_lite_awprot   (    ss_csr_lite_32b_if.awprot),
   .csr_ss_app_lite_awready  (    ss_csr_lite_32b_if.awready),
   .csr_app_ss_lite_arvalid  (    ss_csr_lite_32b_if.arvalid),
   .csr_app_ss_lite_araddr   ({'b0,ss_csr_lite_32b_if.araddr}),
   .csr_app_ss_lite_arprot   (    ss_csr_lite_32b_if.arprot),
   .csr_ss_app_lite_arready  (    ss_csr_lite_32b_if.arready),
   .csr_app_ss_lite_wvalid   (    ss_csr_lite_32b_if.wvalid),
   .csr_app_ss_lite_wdata    (    ss_csr_lite_32b_if.wdata),
   .csr_app_ss_lite_wstrb    (    ss_csr_lite_32b_if.wstrb),
   .csr_ss_app_lite_wready   (    ss_csr_lite_32b_if.wready),
   .csr_ss_app_lite_bvalid   (    ss_csr_lite_32b_if.bvalid),
   .csr_ss_app_lite_bresp    (    ss_csr_lite_32b_if.bresp),
   .csr_app_ss_lite_bready   (    ss_csr_lite_32b_if.bready),
   .csr_ss_app_lite_rvalid   (    ss_csr_lite_32b_if.rvalid),
   .csr_ss_app_lite_rdata    (    ss_csr_lite_32b_if.rdata),
   .csr_ss_app_lite_rresp    (    ss_csr_lite_32b_if.rresp),
   .csr_app_ss_lite_rready   (    ss_csr_lite_32b_if.rready),

   // DDR4 CH0 interface (x32)
   .mem0_pll_ref_clk  (ddr4_no_ecc[0].ref_clk),
   .mem0_oct_rzqin    (ddr4_no_ecc[0].oct_rzqin),
   .mem0_ddr4_ck      (ddr4_no_ecc[0].ck),
   .mem0_ddr4_ck_n    (ddr4_no_ecc[0].ck_n),
   .mem0_ddr4_a       (ddr4_no_ecc[0].a),
   .mem0_ddr4_act_n   (ddr4_no_ecc[0].act_n),
   .mem0_ddr4_ba      (ddr4_no_ecc[0].ba),
   .mem0_ddr4_bg      (ddr4_no_ecc[0].bg),
   .mem0_ddr4_cke     (ddr4_no_ecc[0].cke),
   .mem0_ddr4_cs_n    (ddr4_no_ecc[0].cs_n),
   .mem0_ddr4_odt     (ddr4_no_ecc[0].odt),
   .mem0_ddr4_reset_n (ddr4_no_ecc[0].reset_n),
   .mem0_ddr4_par     (ddr4_no_ecc[0].par),
   .mem0_ddr4_alert_n (ddr4_no_ecc[0].alert_n),
   .mem0_ddr4_dqs     (ddr4_no_ecc[0].dqs),
   .mem0_ddr4_dqs_n   (ddr4_no_ecc[0].dqs_n),
   .mem0_ddr4_dq      (ddr4_no_ecc[0].dq),
   .mem0_ddr4_dbi_n   (ddr4_no_ecc[0].dbi_n),

   // DDR4 CH1 interface (x32)
   .mem1_pll_ref_clk  (ddr4_no_ecc[1].ref_clk),
   .mem1_oct_rzqin    (ddr4_no_ecc[1].oct_rzqin),
   .mem1_ddr4_ck      (ddr4_no_ecc[1].ck),
   .mem1_ddr4_ck_n    (ddr4_no_ecc[1].ck_n),
   .mem1_ddr4_a       (ddr4_no_ecc[1].a),
   .mem1_ddr4_act_n   (ddr4_no_ecc[1].act_n),
   .mem1_ddr4_ba      (ddr4_no_ecc[1].ba),
   .mem1_ddr4_bg      (ddr4_no_ecc[1].bg),
   .mem1_ddr4_cke     (ddr4_no_ecc[1].cke),
   .mem1_ddr4_cs_n    (ddr4_no_ecc[1].cs_n),
   .mem1_ddr4_odt     (ddr4_no_ecc[1].odt),
   .mem1_ddr4_reset_n (ddr4_no_ecc[1].reset_n),
   .mem1_ddr4_par     (ddr4_no_ecc[1].par),
   .mem1_ddr4_alert_n (ddr4_no_ecc[1].alert_n),
   .mem1_ddr4_dqs     (ddr4_no_ecc[1].dqs),
   .mem1_ddr4_dqs_n   (ddr4_no_ecc[1].dqs_n),
   .mem1_ddr4_dq      (ddr4_no_ecc[1].dq),
   .mem1_ddr4_dbi_n   (ddr4_no_ecc[1].dbi_n),
			  
   // DDR4 CH2 interface (x40)
   .mem2_pll_ref_clk  (ddr4_no_ecc[2].ref_clk),
   .mem2_oct_rzqin    (ddr4_no_ecc[2].oct_rzqin),
   .mem2_ddr4_ck      (ddr4_no_ecc[2].ck),
   .mem2_ddr4_ck_n    (ddr4_no_ecc[2].ck_n),
   .mem2_ddr4_a       (ddr4_no_ecc[2].a),
   .mem2_ddr4_act_n   (ddr4_no_ecc[2].act_n),
   .mem2_ddr4_ba      (ddr4_no_ecc[2].ba),
   .mem2_ddr4_bg      (ddr4_no_ecc[2].bg),
   .mem2_ddr4_cke     (ddr4_no_ecc[2].cke),
   .mem2_ddr4_cs_n    (ddr4_no_ecc[2].cs_n),
   .mem2_ddr4_odt     (ddr4_no_ecc[2].odt),
   .mem2_ddr4_reset_n (ddr4_no_ecc[2].reset_n),
   .mem2_ddr4_par     (ddr4_no_ecc[2].par),
   .mem2_ddr4_alert_n (ddr4_no_ecc[2].alert_n),
   .mem2_ddr4_dqs     (ddr4_no_ecc[2].dqs),
   .mem2_ddr4_dqs_n   (ddr4_no_ecc[2].dqs_n),
   .mem2_ddr4_dq      (ddr4_no_ecc[2].dq),
   .mem2_ddr4_dbi_n   (ddr4_no_ecc[2].dbi_n),

   // DDR4 CH3 interface
   .mem3_pll_ref_clk  (ddr4_no_ecc[3].ref_clk),
   .mem3_oct_rzqin    (ddr4_no_ecc[3].oct_rzqin),
   .mem3_ddr4_ck      (ddr4_no_ecc[3].ck),
   .mem3_ddr4_ck_n    (ddr4_no_ecc[3].ck_n),
   .mem3_ddr4_a       (ddr4_no_ecc[3].a),
   .mem3_ddr4_act_n   (ddr4_no_ecc[3].act_n),
   .mem3_ddr4_ba      (ddr4_no_ecc[3].ba),
   .mem3_ddr4_bg      (ddr4_no_ecc[3].bg),
   .mem3_ddr4_cke     (ddr4_no_ecc[3].cke),
   .mem3_ddr4_cs_n    (ddr4_no_ecc[3].cs_n),
   .mem3_ddr4_odt     (ddr4_no_ecc[3].odt),
   .mem3_ddr4_reset_n (ddr4_no_ecc[3].reset_n),
   .mem3_ddr4_par     (ddr4_no_ecc[3].par),
   .mem3_ddr4_alert_n (ddr4_no_ecc[3].alert_n),
   .mem3_ddr4_dqs     (ddr4_no_ecc[3].dqs),
   .mem3_ddr4_dqs_n   (ddr4_no_ecc[3].dqs_n),
   .mem3_ddr4_dq      (ddr4_no_ecc[3].dq),
   .mem3_ddr4_dbi_n   (ddr4_no_ecc[3].dbi_n),

   // DDR4 CH4 interface (HPS)
   .mem4_pll_ref_clk  (hps_ddr_mem.ref_clk),
   .mem4_oct_rzqin    (hps_ddr_mem.oct_rzqin),
   .mem4_ddr4_ck      (hps_ddr_mem.ck),
   .mem4_ddr4_ck_n    (hps_ddr_mem.ck_n),
   .mem4_ddr4_a       (hps_ddr_mem.a),
   .mem4_ddr4_act_n   (hps_ddr_mem.act_n),
   .mem4_ddr4_ba      (hps_ddr_mem.ba),
   .mem4_ddr4_bg      (hps_ddr_mem.bg),
   .mem4_ddr4_cke     (hps_ddr_mem.cke),
   .mem4_ddr4_cs_n    (hps_ddr_mem.cs_n),
   .mem4_ddr4_odt     (hps_ddr_mem.odt),
   .mem4_ddr4_reset_n (hps_ddr_mem.reset_n),
   .mem4_ddr4_par     (hps_ddr_mem.par),
   .mem4_ddr4_alert_n (hps_ddr_mem.alert_n),
   .mem4_ddr4_dqs     (hps_ddr_mem.dqs),
   .mem4_ddr4_dqs_n   (hps_ddr_mem.dqs_n),
   .mem4_ddr4_dq      (hps_ddr_mem.dq),
   .mem4_ddr4_dbi_n   (hps_ddr_mem.dbi_n),
			  
   // CH0 EMIF AXI-MM slave
   .mem0_ss_app_usr_reset_n(afu_mem[0].rst_n),
   .mem0_ss_app_usr_clk    (afu_mem[0].clk),

   // With the current MemSS config CC happens in the subsystem
   // .i0_app_ss_mm_aclk     (afu_mem[0].clk),
   // .i0_app_ss_mm_areset_n (afu_mem[0].rst_n),

   // Write address channel
   .i0_app_ss_mm_awid    (afu_mem[0].awid),
   .i0_app_ss_mm_awaddr  (afu_mem[0].awaddr),
   .i0_app_ss_mm_awlen   (afu_mem[0].awlen),
   .i0_app_ss_mm_awsize  (afu_mem[0].awsize),
   .i0_app_ss_mm_awburst (afu_mem[0].awburst),
   .i0_app_ss_mm_awlock  (afu_mem[0].awlock),
   .i0_app_ss_mm_awcache (afu_mem[0].awcache),
   .i0_app_ss_mm_awprot  (afu_mem[0].awprot),
   .i0_app_ss_mm_awuser  (afu_mem[0].awuser),
   .i0_app_ss_mm_awvalid (afu_mem[0].awvalid),
   .i0_ss_app_mm_awready (afu_mem[0].awready),
   
   // Write data channel
   .i0_app_ss_mm_wdata   (afu_mem[0].wdata),
   .i0_app_ss_mm_wstrb   (afu_mem[0].wstrb),
   .i0_app_ss_mm_wlast   (afu_mem[0].wlast),
   .i0_app_ss_mm_wvalid  (afu_mem[0].wvalid),
   .i0_ss_app_mm_wready  (afu_mem[0].wready),
   
   // Write response channel
   .i0_app_ss_mm_bready  (afu_mem[0].bready),
   .i0_ss_app_mm_bvalid  (afu_mem[0].bvalid),
   .i0_ss_app_mm_bid     (afu_mem[0].bid),
   .i0_ss_app_mm_bresp   (afu_mem[0].bresp),
   .i0_ss_app_mm_buser   (afu_mem[0].buser),
   
   // Read address channel
   .i0_ss_app_mm_arready (afu_mem[0].arready),
   .i0_app_ss_mm_arvalid (afu_mem[0].arvalid),
   .i0_app_ss_mm_arid    (afu_mem[0].arid),
   .i0_app_ss_mm_araddr  (afu_mem[0].araddr),
   .i0_app_ss_mm_arlen   (afu_mem[0].arlen),
   .i0_app_ss_mm_arsize  (afu_mem[0].arsize),
   .i0_app_ss_mm_arburst (afu_mem[0].arburst),
   .i0_app_ss_mm_arlock  (afu_mem[0].arlock),
   .i0_app_ss_mm_arcache (afu_mem[0].arcache),
   .i0_app_ss_mm_arprot  (afu_mem[0].arprot),
   .i0_app_ss_mm_aruser  (afu_mem[0].aruser),

   //Read response channel
   .i0_app_ss_mm_rready  (afu_mem[0].rready),
   .i0_ss_app_mm_rvalid  (afu_mem[0].rvalid),
   .i0_ss_app_mm_rid     (afu_mem[0].rid),
   .i0_ss_app_mm_rdata   (afu_mem[0].rdata),
   .i0_ss_app_mm_rresp   (afu_mem[0].rresp),
   .i0_ss_app_mm_rlast   (afu_mem[0].rlast),
   .i0_ss_app_mm_ruser   (afu_mem[0].ruser),

   // CH0 EMIF Calibration status
   .mem0_local_cal_success(mem_ss_cal_success[0]),
   .mem0_local_cal_fail(mem_ss_cal_fail[0]),

   // CH1 EMIF AXI-MM slave
   .mem1_ss_app_usr_reset_n(afu_mem[1].rst_n),
   .mem1_ss_app_usr_clk    (afu_mem[1].clk),

   // With the current MemSS config CC happens in the subsystem
   // .i1_app_ss_mm_aclk     (afu_mem[1].clk),
   // .i1_app_ss_mm_areset_n (afu_mem[1].rst_n),

   // Write address channel
   .i1_app_ss_mm_awid    (afu_mem[1].awid),
   .i1_app_ss_mm_awaddr  (afu_mem[1].awaddr),
   .i1_app_ss_mm_awlen   (afu_mem[1].awlen),
   .i1_app_ss_mm_awsize  (afu_mem[1].awsize),
   .i1_app_ss_mm_awburst (afu_mem[1].awburst),
   .i1_app_ss_mm_awlock  (afu_mem[1].awlock),
   .i1_app_ss_mm_awcache (afu_mem[1].awcache),
   .i1_app_ss_mm_awprot  (afu_mem[1].awprot),
   .i1_app_ss_mm_awuser  (afu_mem[1].awuser),
   .i1_app_ss_mm_awvalid (afu_mem[1].awvalid),
   .i1_ss_app_mm_awready (afu_mem[1].awready),
   
   // Write data channel
   .i1_app_ss_mm_wdata   (afu_mem[1].wdata),
   .i1_app_ss_mm_wstrb   (afu_mem[1].wstrb),
   .i1_app_ss_mm_wlast   (afu_mem[1].wlast),
   .i1_app_ss_mm_wvalid  (afu_mem[1].wvalid),
   .i1_ss_app_mm_wready  (afu_mem[1].wready),
   
   // Write response channel
   .i1_app_ss_mm_bready  (afu_mem[1].bready),
   .i1_ss_app_mm_bvalid  (afu_mem[1].bvalid),
   .i1_ss_app_mm_bid     (afu_mem[1].bid),
   .i1_ss_app_mm_bresp   (afu_mem[1].bresp),
   .i1_ss_app_mm_buser   (afu_mem[1].buser),
   
   // Read address channel
   .i1_ss_app_mm_arready (afu_mem[1].arready),
   .i1_app_ss_mm_arvalid (afu_mem[1].arvalid),
   .i1_app_ss_mm_arid    (afu_mem[1].arid),
   .i1_app_ss_mm_araddr  (afu_mem[1].araddr),
   .i1_app_ss_mm_arlen   (afu_mem[1].arlen),
   .i1_app_ss_mm_arsize  (afu_mem[1].arsize),
   .i1_app_ss_mm_arburst (afu_mem[1].arburst),
   .i1_app_ss_mm_arlock  (afu_mem[1].arlock),
   .i1_app_ss_mm_arcache (afu_mem[1].arcache),
   .i1_app_ss_mm_arprot  (afu_mem[1].arprot),
   .i1_app_ss_mm_aruser  (afu_mem[1].aruser),

   //Read response channel
   .i1_app_ss_mm_rready  (afu_mem[1].rready),
   .i1_ss_app_mm_rvalid  (afu_mem[1].rvalid),
   .i1_ss_app_mm_rid     (afu_mem[1].rid),
   .i1_ss_app_mm_rdata   (afu_mem[1].rdata),
   .i1_ss_app_mm_rresp   (afu_mem[1].rresp),
   .i1_ss_app_mm_rlast   (afu_mem[1].rlast),
   .i1_ss_app_mm_ruser   (afu_mem[1].ruser),

   // CH1 EMIF Calibration status
   .mem1_local_cal_success(mem_ss_cal_success[1]),
   .mem1_local_cal_fail(mem_ss_cal_fail[1]),

   // CH2 EMIF AXI-MM slave
   .mem2_ss_app_usr_reset_n(afu_mem[2].rst_n),
   .mem2_ss_app_usr_clk    (afu_mem[2].clk),

   // With the current MemSS config CC happens in the subsystem
   // .i2_app_ss_mm_aclk     (afu_mem[2].clk),
   // .i2_app_ss_mm_areset_n (afu_mem[2].rst_n),

   // Write address channel
   .i2_app_ss_mm_awid    (afu_mem[2].awid),
   .i2_app_ss_mm_awaddr  (afu_mem[2].awaddr),
   .i2_app_ss_mm_awlen   (afu_mem[2].awlen),
   .i2_app_ss_mm_awsize  (afu_mem[2].awsize),
   .i2_app_ss_mm_awburst (afu_mem[2].awburst),
   .i2_app_ss_mm_awlock  (afu_mem[2].awlock),
   .i2_app_ss_mm_awcache (afu_mem[2].awcache),
   .i2_app_ss_mm_awprot  (afu_mem[2].awprot),
   .i2_app_ss_mm_awuser  (afu_mem[2].awuser),
   .i2_app_ss_mm_awvalid (afu_mem[2].awvalid),
   .i2_ss_app_mm_awready (afu_mem[2].awready),
   
   // Write data channel
   .i2_app_ss_mm_wdata   (afu_mem[2].wdata),
   .i2_app_ss_mm_wstrb   (afu_mem[2].wstrb),
   .i2_app_ss_mm_wlast   (afu_mem[2].wlast),
   .i2_app_ss_mm_wvalid  (afu_mem[2].wvalid),
   .i2_ss_app_mm_wready  (afu_mem[2].wready),
   
   // Write response channel
   .i2_app_ss_mm_bready  (afu_mem[2].bready),
   .i2_ss_app_mm_bvalid  (afu_mem[2].bvalid),
   .i2_ss_app_mm_bid     (afu_mem[2].bid),
   .i2_ss_app_mm_bresp   (afu_mem[2].bresp),
   .i2_ss_app_mm_buser   (afu_mem[2].buser),
   
   // Read address channel
   .i2_ss_app_mm_arready (afu_mem[2].arready),
   .i2_app_ss_mm_arvalid (afu_mem[2].arvalid),
   .i2_app_ss_mm_arid    (afu_mem[2].arid),
   .i2_app_ss_mm_araddr  (afu_mem[2].araddr),
   .i2_app_ss_mm_arlen   (afu_mem[2].arlen),
   .i2_app_ss_mm_arsize  (afu_mem[2].arsize),
   .i2_app_ss_mm_arburst (afu_mem[2].arburst),
   .i2_app_ss_mm_arlock  (afu_mem[2].arlock),
   .i2_app_ss_mm_arcache (afu_mem[2].arcache),
   .i2_app_ss_mm_arprot  (afu_mem[2].arprot),
   .i2_app_ss_mm_aruser  (afu_mem[2].aruser),

   //Read response channel
   .i2_app_ss_mm_rready  (afu_mem[2].rready),
   .i2_ss_app_mm_rvalid  (afu_mem[2].rvalid),
   .i2_ss_app_mm_rid     (afu_mem[2].rid),
   .i2_ss_app_mm_rdata   (afu_mem[2].rdata),
   .i2_ss_app_mm_rresp   (afu_mem[2].rresp),
   .i2_ss_app_mm_rlast   (afu_mem[2].rlast),
   .i2_ss_app_mm_ruser   (afu_mem[2].ruser),

   // CH2 EMIF Calibration status
   .mem2_local_cal_success(mem_ss_cal_success[2]),
   .mem2_local_cal_fail(mem_ss_cal_fail[2]),

   // CH3 EMIF AXI-MM slave
   .mem3_ss_app_usr_reset_n(afu_mem[3].rst_n),
   .mem3_ss_app_usr_clk    (afu_mem[3].clk),

   // With the current MemSS config CC happens in the subsystem
   // .i3_app_ss_mm_aclk     (afu_mem[3].clk),
   // .i3_app_ss_mm_areset_n (afu_mem[3].rst_n),

   // Write address channel
   .i3_app_ss_mm_awid    (afu_mem[3].awid),
   .i3_app_ss_mm_awaddr  (afu_mem[3].awaddr),
   .i3_app_ss_mm_awlen   (afu_mem[3].awlen),
   .i3_app_ss_mm_awsize  (afu_mem[3].awsize),
   .i3_app_ss_mm_awburst (afu_mem[3].awburst),
   .i3_app_ss_mm_awlock  (afu_mem[3].awlock),
   .i3_app_ss_mm_awcache (afu_mem[3].awcache),
   .i3_app_ss_mm_awprot  (afu_mem[3].awprot),
   .i3_app_ss_mm_awuser  (afu_mem[3].awuser),
   .i3_app_ss_mm_awvalid (afu_mem[3].awvalid),
   .i3_ss_app_mm_awready (afu_mem[3].awready),
   
   // Write data channel
   .i3_app_ss_mm_wdata   (afu_mem[3].wdata),
   .i3_app_ss_mm_wstrb   (afu_mem[3].wstrb),
   .i3_app_ss_mm_wlast   (afu_mem[3].wlast),
   .i3_app_ss_mm_wvalid  (afu_mem[3].wvalid),
   .i3_ss_app_mm_wready  (afu_mem[3].wready),
   
   // Write response channel
   .i3_app_ss_mm_bready  (afu_mem[3].bready),
   .i3_ss_app_mm_bvalid  (afu_mem[3].bvalid),
   .i3_ss_app_mm_bid     (afu_mem[3].bid),
   .i3_ss_app_mm_bresp   (afu_mem[3].bresp),
   .i3_ss_app_mm_buser   (afu_mem[3].buser),
   
   // Read address channel
   .i3_ss_app_mm_arready (afu_mem[3].arready),
   .i3_app_ss_mm_arvalid (afu_mem[3].arvalid),
   .i3_app_ss_mm_arid    (afu_mem[3].arid),
   .i3_app_ss_mm_araddr  (afu_mem[3].araddr),
   .i3_app_ss_mm_arlen   (afu_mem[3].arlen),
   .i3_app_ss_mm_arsize  (afu_mem[3].arsize),
   .i3_app_ss_mm_arburst (afu_mem[3].arburst),
   .i3_app_ss_mm_arlock  (afu_mem[3].arlock),
   .i3_app_ss_mm_arcache (afu_mem[3].arcache),
   .i3_app_ss_mm_arprot  (afu_mem[3].arprot),
   .i3_app_ss_mm_aruser  (afu_mem[3].aruser),

   //Read response channel
   .i3_app_ss_mm_rready  (afu_mem[3].rready),
   .i3_ss_app_mm_rvalid  (afu_mem[3].rvalid),
   .i3_ss_app_mm_rid     (afu_mem[3].rid),
   .i3_ss_app_mm_rdata   (afu_mem[3].rdata),
   .i3_ss_app_mm_rresp   (afu_mem[3].rresp),
   .i3_ss_app_mm_rlast   (afu_mem[3].rlast),
   .i3_ss_app_mm_ruser   (afu_mem[3].ruser),

   // CH3 EMIF Calibration status
   .mem3_local_cal_success(mem_ss_cal_success[3]),
   .mem3_local_cal_fail(mem_ss_cal_fail[3]),

   // CH4 EMIF HPS conduit
   .mem4_hps_to_emif     (hps2emif),
   .mem4_emif_to_hps     (emif2hps),
   .mem4_hps_to_emif_gp  (hps2emif_gp),
   .mem4_emif_to_hps_gp  (emif2hps_gp)
);
   
endmodule // mem_ss_top

