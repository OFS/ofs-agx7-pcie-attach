// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

    `timescale 1ps/1ps

`include "tb_pkg.svh"

module tb_top;
    ///** Include Util parms */
    //`include `SVC_SOURCE_MAP_SUITE_UTIL_V(pcie_svc,PCIE,latest,svc_util_parms)
    //`include `SVC_SOURCE_MAP_SUITE_MODEL_MODULE(pcie_svc,Include,latest,pciesvc_parms)
    //------------------------------------------------------------------------------
    // Serial interface signals
    //------------------------------------------------------------------------------
    logic [ofs_fim_cfg_pkg::PCIE_LANES-1:0] root0_tx_datap;
    logic [ofs_fim_cfg_pkg::PCIE_LANES-1:0] root0_tx_datan;
    logic [ofs_fim_cfg_pkg::PCIE_LANES-1:0] endpoint0_tx_datap;
    logic [ofs_fim_cfg_pkg::PCIE_LANES-1:0] endpoint0_tx_datan;

	ofs_fim_axi_lite_if                csr_lite_if();
   	ofs_fim_ace_lite_if                ace_lite_tx_if();
//ofs_fim_axi_lite_if              axi4mm_rx_if();
ofs_fim_axi_mmio_if                        axi4mm_rx_if();

    reg SYS_RefClk   = 0;
    reg PCIE_RefClk  = 0;
    reg ETH_RefClk   = 0;
    reg PCIE_RESET_N = 0;
    bit tbclk_1Ghz = 0;

`ifdef INCLUDE_HSSI
    wire [NUM_ETH_CHANNELS-1:0] qsfp1_lpbk_serial;
`endif

    `AXI_IF axi_if();
	`AXI_IF ace_if();

// clock signals
wire clk_sys;
wire clk_100m;
wire clk_csr;

// reset signals
logic pll_locked;
logic ninit_done;
logic pcie_reset_status;
logic pcie_cold_rst_ack_n;
logic pcie_warm_rst_ack_n;
logic pcie_cold_rst_n;
logic pcie_warm_rst_n;
logic rst_n_sys;
logic rst_n_100m;
logic rst_n_csr;
logic pwr_good_n;

`ifdef INCLUDE_DDR
    ofs_fim_emif_mem_if ddr4_mem[MC_CHANNEL-1:0](); // EMIF DDR4 x72 RDIMM (x8)
`endif  

    assign axi_if.common_aclk = clk_sys;
	assign ace_if.common_aclk = clk_sys;
    assign ace_if.slave_if[0] .aresetn = rst_n_100m;
    assign ace_if.slave_if[0].awvalid = ace_lite_tx_if.awvalid;
    assign ace_if.slave_if[0].awaddr = ace_lite_tx_if.awaddr;
    assign ace_if.slave_if[0].awprot = ace_lite_tx_if.awprot;
    assign ace_if.slave_if[0].wvalid = ace_lite_tx_if.wvalid;
    assign ace_if.slave_if[0].wdata  = ace_lite_tx_if.wdata;
    assign ace_if.slave_if[0].wstrb  = ace_lite_tx_if.wstrb;
    assign ace_if.slave_if[0].bready = ace_lite_tx_if.bready;
	assign ace_if.slave_if[0].wlast = ace_lite_tx_if.wlast;
    assign ace_if.slave_if[0].awlen = ace_lite_tx_if.awlen;
    assign ace_if.slave_if[0].awburst = ace_lite_tx_if.awburst;
    assign ace_if.slave_if[0].awsize = ace_lite_tx_if.awsize;
    //assign ace_if.slave_if[0].rready = ace_lite_tx_if.rready;

    assign ace_lite_tx_if.awready = ace_if.slave_if[0].awready; 
    assign ace_lite_tx_if.wready = ace_if.slave_if[0].wready;
    assign ace_lite_tx_if.bvalid = ace_if.slave_if[0].bvalid;
    assign ace_lite_tx_if.bresp = ace_if.slave_if[0].bresp;
    //assign ace_lite_tx_if.arready = axi_if.slave_if[0].arready;
    //assign ace_lite_tx_if.rvalid = axi_if.slave_if[0].rvalid;
    //assign ace_lite_tx_if.rdata = axi_if.slave_if[0].rdata;
    //assign ace_lite_tx_if.rresp = axi_if.slave_if[0].rresp;

    assign  ace_if.slave_if[0].awid       =5'd0  ;
    assign  ace_if.slave_if[0].awlock     =1'd0  ;
    assign  ace_if.slave_if[0].awcache    =4'd0  ;
    assign  ace_if.slave_if[0].awqos      =4'd0  ;
    assign  ace_if.slave_if[0].awuser     =23'd0 ;
    assign  ace_if.slave_if[0].arid       =5'd0  ;
    assign  ace_if.slave_if[0].arlock     =1'd0  ;
    assign  ace_if.slave_if[0].arcache    =4'd0  ;
    assign  ace_if.slave_if[0].arqos      =4'd0  ;
    assign  ace_if.slave_if[0].aruser     =23'd0 ;
    assign  ace_if.slave_if[0].arvalid    =1'd0  ;
    assign  ace_if.slave_if[0].araddr     ={32{1'h0}};
    assign  ace_if.slave_if[0].arprot     =3'd0  ;
    assign  ace_if.slave_if[0].arlen      =8'd0  ;
    assign  ace_if.slave_if[0].arsize     =3'd0  ;
    assign  ace_if.slave_if[0].arburst    =2'd0  ;
    assign  ace_if.slave_if[0].arsnoop    =4'd0  ;
    assign  ace_if.slave_if[0].ardomain   =2'd11 ;
    assign  ace_if.slave_if[0].arbar      =2'd0  ;
    assign  ace_if.slave_if[0].rready     =1'd0  ;
    assign  ace_if.slave_if[0].awdomain   =2'd11   ;
    assign  ace_if.slave_if[0].awbar      ='h0   ;
    assign  ace_if.slave_if[0].awsnoop    ='h0   ;

  // HPS AXI LITE INTERFACE

    assign axi_if.master_if[1].aresetn      = rst_n_100m;
    assign axi4mm_rx_if.awvalid      = axi_if.master_if[1].awvalid;
    assign axi4mm_rx_if.arvalid      = axi_if.master_if[1].arvalid;
    assign axi4mm_rx_if.awaddr       = axi_if.master_if[1].awaddr;
    assign axi4mm_rx_if.araddr       = axi_if.master_if[1].araddr;
    assign axi4mm_rx_if.awprot       = axi_if.master_if[1].awprot;
    assign axi4mm_rx_if.arprot       = axi_if.master_if[1].arprot;
    assign axi4mm_rx_if.wvalid       = axi_if.master_if[1].wvalid;
    assign axi4mm_rx_if.wdata        = axi_if.master_if[1].wdata;
    assign axi4mm_rx_if.wstrb        = axi_if.master_if[1].wstrb;
    assign axi4mm_rx_if.bready       = axi_if.master_if[1].bready;
    assign axi4mm_rx_if.rready       = axi_if.master_if[1].rready;
    
    
    assign axi_if.master_if[1].rvalid       = axi4mm_rx_if.rvalid;
    assign axi_if.master_if[1].awready      = axi4mm_rx_if.awready;
    assign axi_if.master_if[1].wready       = axi4mm_rx_if.wready;
    assign axi_if.master_if[1].arready      = axi4mm_rx_if.arready;
    assign axi_if.master_if[1].rdata        = axi4mm_rx_if.rdata;
    assign axi_if.master_if[1].rresp        = axi4mm_rx_if.rresp;
    assign axi_if.master_if[1].bresp        = axi4mm_rx_if.bresp;
    assign axi_if.master_if[1].bvalid       = axi4mm_rx_if.bvalid;
    assign axi_if.master_if[1].bid          = 'h0;

    //coverage interface
     coverage_intf  cov_intf();


    `PCIE_DEV_AGNT_X16_8G_HDL root0(
        .reset        (~PCIE_RESET_N),
        .rx_datap_0   ( endpoint0_tx_datap[0]), // inputs
        .rx_datap_1   ( endpoint0_tx_datap[1]),
        .rx_datap_2   ( endpoint0_tx_datap[2]),
        .rx_datap_3   ( endpoint0_tx_datap[3]),
        .rx_datap_4   ( endpoint0_tx_datap[4]),
        .rx_datap_5   ( endpoint0_tx_datap[5]),
        .rx_datap_6   ( endpoint0_tx_datap[6]),
        .rx_datap_7   ( endpoint0_tx_datap[7]),
        .rx_datap_8   ( endpoint0_tx_datap[8]),
        .rx_datap_9   ( endpoint0_tx_datap[9]),
        .rx_datap_10  ( endpoint0_tx_datap[10]),
        .rx_datap_11  ( endpoint0_tx_datap[11]),
        .rx_datap_12  ( endpoint0_tx_datap[12]),
        .rx_datap_13  ( endpoint0_tx_datap[13]),
        .rx_datap_14  ( endpoint0_tx_datap[14]),
        .rx_datap_15  ( endpoint0_tx_datap[15]),
        .rx_datan_0   ( endpoint0_tx_datan[0]), // inputs
        .rx_datan_1   ( endpoint0_tx_datan[1]),
        .rx_datan_2   ( endpoint0_tx_datan[2]),
        .rx_datan_3   ( endpoint0_tx_datan[3]),
        .rx_datan_4   ( endpoint0_tx_datan[4]),
        .rx_datan_5   ( endpoint0_tx_datan[5]),
        .rx_datan_6   ( endpoint0_tx_datan[6]),
        .rx_datan_7   ( endpoint0_tx_datan[7]),
        .rx_datan_8   ( endpoint0_tx_datan[8]),
        .rx_datan_9   ( endpoint0_tx_datan[9]),
        .rx_datan_10  ( endpoint0_tx_datan[10]),
        .rx_datan_11  ( endpoint0_tx_datan[11]),
        .rx_datan_12  ( endpoint0_tx_datan[12]),
        .rx_datan_13  ( endpoint0_tx_datan[13]),
        .rx_datan_14  ( endpoint0_tx_datan[14]),
        .rx_datan_15  ( endpoint0_tx_datan[15]),

        .tx_datap_0   (root0_tx_datap[0]),  // outputs
        .tx_datap_1   (root0_tx_datap[1]),
        .tx_datap_2   (root0_tx_datap[2]),
        .tx_datap_3   (root0_tx_datap[3]),
        .tx_datap_4   (root0_tx_datap[4]),
        .tx_datap_5   (root0_tx_datap[5]),
        .tx_datap_6   (root0_tx_datap[6]),
        .tx_datap_7   (root0_tx_datap[7]),
        .tx_datap_8   (root0_tx_datap[8]),
        .tx_datap_9   (root0_tx_datap[9]),
        .tx_datap_10  (root0_tx_datap[10]),
        .tx_datap_11  (root0_tx_datap[11]),
        .tx_datap_12  (root0_tx_datap[12]),
        .tx_datap_13  (root0_tx_datap[13]),
        .tx_datap_14  (root0_tx_datap[14]),
        .tx_datap_15  (root0_tx_datap[15])
   );


t_axis_pcie_flr   pcie_flr_req;
t_axis_pcie_flr   pcie_flr_rsp;
//pcie_ss_axis_if   pcie_ss_axis_rx_if(.clk (clk_sys), .rst_n(rst_n_sys));
//pcie_ss_axis_if   pcie_ss_axis_tx_if(.clk (clk_sys), .rst_n(rst_n_sys));

assign clk_csr   = clk_100m;
assign rst_n_csr = rst_n_100m;

//*******************************
// System PLL
//*******************************
// todo_lpchua : 
//   * clk_sys is currently 250Mhz because we are using PCIe Gen3x16
//               When we are integrating PCIe SS (Gen4x8), clk_sys needs to be updated to the targeted frequency (350Mhz)
//               Since all the CSR interfaces and APF/BPF are clocked by clk_sys, we may need to use a slower clock
//               for CSR interfaces and APF/BFP to help timing closure. When a slower clock is used, a CDC FIFO needs
//               to be added in ST2MM to cross the clock from PCIe clock to CSR clock.
//   * May need to add more clocks for other modules, e.g. PMCI, HPS

sys_pll sys_pll (
   .rst                (ninit_done                ),
   .refclk             (SYS_RefClk                ),
   .locked             (pll_locked                ),
   .outclk_0           (clk_sys                   ),
   .outclk_1           (clk_100m                  )
);

//*******************************
// Reset controller
//*******************************
// todo_rst :
//            May need to add more reset controls when PMCI, HPS and QSFP are integrated
rst_ctrl rst_ctrl (
   .clk_sys             (clk_sys                  ),
   .clk_100m            (clk_100m                 ),
   .pll_locked          (pll_locked               ),
   .pcie_reset_status   (pcie_reset_status        ),
   .pcie_cold_rst_ack_n (pcie_cold_rst_ack_n      ),
   .pcie_warm_rst_ack_n (pcie_warm_rst_ack_n      ),
                                                 
   .ninit_done          (ninit_done               ),
   .rst_n_sys           (rst_n_sys                ),  // system reset synchronous to clk_sys
   .rst_n_100m          (rst_n_100m               ),  // system reset synchronous to clk_100m
   .pwr_good_n          (pwr_good_n               ),  // system reset synchronous to clk_100m
   .pcie_cold_rst_n     (pcie_cold_rst_n          ),
   .pcie_warm_rst_n     (pcie_warm_rst_n          )
); 

pcie_wrapper_ce #(
     .PCIE_LANES               (16        ),
     .MM_ADDR_WIDTH            (19        ),
     .MM_DATA_WIDTH            (64        ),
     .FEAT_ID                  (12'h0     ),
     .FEAT_VER                 (4'h0      ),
     .NEXT_DFH_OFFSET          (24'h1000  ),
     .END_OF_LIST              (1'b0      ),  
     .CE_FEAT_ID               (12'h1     ),   
     .CE_FEAT_VER              (4'h1      ),
     .CE_NEXT_DFH_OFFSET       (24'h1000  ),
     .CE_END_OF_LIST           (1'b0      ),
     .CE_BUS_ADDR_WIDTH        (32        ),
     .CE_BUS_DATA_WIDTH        (512       ),
     .CE_BUS_USER_WIDTH        (10        ),
     .CE_MMIO_RSP_FIFO_DEPTH   (4         ),
     .CE_HST2HPS_FIFO_DEPTH    (8         ),
     .CE_RDY_LOW_THRESHOLD     (200000    ),
     .CE_PF_ID                 (4         ),
     .CE_VF_ID                 (0         ),
     .CE_VF_ACTIVE             (0         ))
DUT (
   .fim_clk                      (clk_sys                    ),
   .fim_rst_n                    (rst_n_sys                  ),
   .csr_clk                      (clk_csr                                      ),
   .csr_rst_n                    (rst_n_csr                            ),
   .ninit_done                   (ninit_done                           ),
   .p0_subsystem_cold_rst_n      (pcie_cold_rst_n                      ),     
   .p0_subsystem_warm_rst_n      (pcie_warm_rst_n                      ),
   .p0_subsystem_cold_rst_ack_n  (pcie_cold_rst_ack_n   ),
   .p0_subsystem_warm_rst_ack_n  (pcie_warm_rst_ack_n   ),
   .reset_status                 (pcie_reset_status     ),   
   .pin_pcie_refclk0_p           (PCIE_RefClk                   ),
   .pin_pcie_refclk1_p           (PCIE_RefClk                   ),
   .pin_pcie_in_perst_n          (PCIE_RESET_N                  ),                           
   .pin_pcie_rx_p                (root0_tx_datap                ),
   .pin_pcie_rx_n                ('0                ),
   .pin_pcie_tx_p                (endpoint0_tx_datap            ),                
   .pin_pcie_tx_n                (endpoint0_tx_datan            ),                
   .csr_lite_if                  (csr_lite_if.slave             ), //TODO  
   .ace_lite_tx_if               (ace_lite_tx_if         ), //TODO
  // .hps2host_hps_rdy_gpio        (1'b1                          ),
  // .hps2host_ssbl_vfy_gpio       (2'd0                          ),
  // .hps2host_kernel_vfy_gpio     (2'd0                          ),
   //.axi_st_rx_if                 (pcie_ss_axis_rx_if    ),
   //.axi_st_tx_if                 (pcie_ss_axis_tx_if    ),
   .axi4mm_rx_if               (axi4mm_rx_if         ),
   .axi_st_flr_req               (pcie_flr_req),
   .axi_st_flr_rsp               (pcie_flr_rsp) //TODO
	);


always #500ps tbclk_1Ghz = ~tbclk_1Ghz;

   initial begin
      #1ps;
      `ifdef FIM_C
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_aibaux_cnoc_clk_occ.uu_wrdft_ckmux21_inst.ck1 = tbclk_1Ghz;
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_aibaux_cnoc_clk_occ.uu_wrdft_ckmux21_inst.s0=1;
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_config_avmm_clk_div_mux.s0=1;
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_mpllb_sel[15:0] ='hFFFF;
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_rate[47:0]= 'h6db6db6db6db;
         #1ps;

         fork
         begin
            @(posedge `PCIE_DUT.u_core16.u_ip.u_cfg.u_cfg_dbi_if.cfg_blk_done_o);
            #1ps;
            if( DUT.pcie_wrapper.pcie_ss_top.pcie_ss.pcie_ss.hssi_ctp_topology =="pcie_x8x8") begin
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_rate[23:0];
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_mpllb_sel[7:0];
            end 
            else begin
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_rate[47:0];
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_mpllb_sel[15:0];
            end
         end
         begin
            if(DUT.pcie_wrapper.pcie_ss_top.pcie_ss.pcie_ss.hssi_ctp_topology =="pcie_x8x8") begin
               @(posedge `PCIE_DUT.u_core8.u_ip.u_cfg.u_cfg_dbi_if.cfg_blk_done_o);
               #1ps;
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_rate[47:24];
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_mpllb_sel[15:8];
            end
         end
         join
         release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_aibaux_cnoc_clk_occ.uu_wrdft_ckmux21_inst.s0;
         release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_config_avmm_clk_div_mux.s0;
         //enable the DWIP to run in Fast link mode by forcing. 
         force `PCIE_DUT.u_core16.u_ip.u_dwc.diag_ctrl_bus[2] = 1'b1;
         force `PCIE_DUT.u_core8.u_ip.u_dwc.diag_ctrl_bus[2] = 1'b1;
      `else
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_aibaux_cnoc_clk_occ.uu_wrdft_ckmux21_inst.ck1 = tbclk_1Ghz;
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_aibaux_cnoc_clk_occ.uu_wrdft_ckmux21_inst.s0=1;
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_config_avmm_clk_div_mux.s0=1;
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_mpllb_sel[15:0] ='hFFFF;
         force `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_rate[47:0]= 'h6db6db6db6db;
         #1ps;

         fork
         begin
            @(posedge `PCIE_DUT.u_core16.u_ip.u_cfg.u_cfg_dbi_if.cfg_blk_done_o);
            #1ps;
            if( DUT.pcie_wrapper.pcie_ss_top.pcie_ss.pcie_ss.hssi_ctp_topology =="pcie_x8x8") begin
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_rate[23:0];
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_mpllb_sel[7:0];
            end 
            else begin
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_rate[47:0];
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_mpllb_sel[15:0];
            end
         end
         begin
            if(DUT.pcie_wrapper.pcie_ss_top.pcie_ss.pcie_ss.hssi_ctp_topology =="pcie_x8x8") begin
               @(posedge `PCIE_DUT.u_core8.u_ip.u_cfg.u_cfg_dbi_if.cfg_blk_done_o);
               #1ps;
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_rate[47:24];
               release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrphy_top.pcs.i_pcie_pcs.upcs_clk_ctl.pcs_laneX_mpllb_sel[15:8];
            end
         end
         join
         release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_aibaux_cnoc_clk_occ.uu_wrdft_ckmux21_inst.s0;
         release `PCIE_QHIP.intel_pcie_ptile_ast_qhip.inst.inst.maib_and_tile.z1565a.ctp_tile_encrypted_inst.z1565a_inst.u_wrtilectrl.wrssm_config_avmm_clk_div_mux.s0;
         //enable the DWIP to run in Fast link mode by forcing. 
         force `PCIE_DUT.u_core16.u_ip.u_dwc.diag_ctrl_bus[2] = 1'b1;
         force `PCIE_DUT.u_core8.u_ip.u_dwc.diag_ctrl_bus[2] = 1'b1;
      `endif
 
   end
    initial #1us //Min RESET period is 1us
        PCIE_RESET_N = 1;
    always #5ns SYS_RefClk  = ~SYS_RefClk;
    always #5ns PCIE_RefClk = ~PCIE_RefClk;
    //always #775ps ETH_RefClk = ~ETH_RefClk;
    always #3200 ETH_RefClk = ~ETH_RefClk;

    initial begin
    uvm_config_db#(virtual coverage_intf)::set(uvm_root::get(), "*", "cov_intf", cov_intf); //coverage 
    end

    initial begin
        uvm_config_db#(virtual `AXI_IF)::set(uvm_root::get(), "uvm_test_top.tb_env0.axi_system_env", "vif", axi_if);
        uvm_config_db#(virtual `AXI_IF)::set(uvm_root::get(), "uvm_test_top.tb_env0.ace_system_env", "vif", ace_if);
    end

    initial
        run_test();

endmodule : tb_top

