// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT



//
// Description
//-----------------------------------------------------------------------------------------------
//
//   Platform top level module
//
//-----------------------------------------------------------------------------------------------

                   `include "fpga_defines.vh"
                    import   ofs_fim_cfg_pkg::*      ;
                    import   ofs_fim_if_pkg::*       ;
                    import   pcie_ss_axis_pkg::*     ;

`ifdef INCLUDE_HSSI
                   `include  "ofs_fim_eth_plat_defines.svh"
                    import   ofs_fim_eth_if_pkg::*   ;
`endif

//-----------------------------------------------------------------------------------------------
// Module ports
//-----------------------------------------------------------------------------------------------

module top 
   import ofs_fim_mem_if_pkg::*;
(
                    input                                       SYS_REFCLK                        ,// System Reference Clock (100MHz)
                                      
`ifdef INCLUDE_DDR4
                    ofs_fim_emif_ddr4_if.emif                      ddr4_mem     [NUM_DDR4_CHANNELS-1:0]      ,// EMIF DDR4 x32 RDIMM (x8)
`ifdef INCLUDE_HPS
                    ofs_fim_hps_ddr4_if.emif                       ddr4_hps                          ,
`endif
`endif


`ifdef INCLUDE_HSSI                                                                              
                    //QSFP control signals
                    input  wire                                 qsfp_ref_clk                      ,// QSFP Ethernet reference clock
                    inout  wire                                 qsfpa_i2c_scl                     , // QSFPA I2C SCL
                    inout  wire                                 qsfpa_i2c_sda                     , // QSFPA I2C SDA
                    inout  wire                                 qsfpb_i2c_scl                     , // QSFPB I2C SCL
                    inout  wire                                 qsfpb_i2c_sda                     , // QSFPB I2C SDA
                    output wire                                 qsfpa_resetn                      , // QSFPA control
                    output wire                                 qsfpa_modeseln                    , // QSFPA control
                    input  wire                                 qsfpa_modprsln                    , // QSFPA control
                    output wire                                 qsfpa_lpmode                      , // QSFPA control
                    input  wire                                 qsfpa_intn                        , // QSFPA control
                    output wire                                 qsfpb_resetn                      , // QSFPB control
                    output wire                                 qsfpb_modeseln                    , // QSFPB control
                    input  wire                                 qsfpb_modprsln                    , // QSFPB control
                    output wire                                 qsfpb_lpmode                      , // QSFPB control
                    input  wire                                 qsfpb_intn                        , // QSFPB control
                    output wire                                 qsfpa_act_g                       , // QSFPA activity green LED
                    output wire                                 qsfpa_act_r                       , // QSFPA activity red LED
                    output wire                                 qsfpb_act_g                       , // QSFPB activity green LED
                    output wire                                 qsfpb_act_r                       , // QSFPB activity red LED
                    output wire                                 qsfpa_speed_g                     , // QSFPA speed green LED
                    output wire                                 qsfpa_speed_y                     , // QSFPA speed yellow LED
                    output wire                                 qsfpb_speed_g                     , // QSFPB speed green LED
                    output wire                                 qsfpb_speed_y                     , // QSFPB speed yellow LED
                    ofs_fim_hssi_serial_if.hssi                 hssi_if [NUM_ETH_LANES-1:0]       , // QSFP serial data
`endif
                    input                                       PCIE_REFCLK0                      ,// PCIe clock
                    input                                       PCIE_REFCLK1                      ,// PCIe clock
                    input                                       PCIE_RESET_N                      ,// PCIe reset
                    input  [ofs_fim_cfg_pkg::PCIE_LANES-1:0]    PCIE_RX_P                         ,// PCIe RX_P pins 
                    input  [ofs_fim_cfg_pkg::PCIE_LANES-1:0]    PCIE_RX_N                         ,// PCIe RX_N pins 
                    output [ofs_fim_cfg_pkg::PCIE_LANES-1:0]    PCIE_TX_P                         ,// PCIe TX_P pins 
                    output [ofs_fim_cfg_pkg::PCIE_LANES-1:0]    PCIE_TX_N                         // PCIe TX_N pins 

`ifdef INCLUDE_PMCI                                                                              
                    // AC FPGA - AC card BMC interface                                    
                    ,output wire                                qspi_dclk,                
                    output wire                                 qspi_ncs,                 
                    inout  wire [3:0]                           qspi_data,                
                    input  wire                                 ncsi_rbt_ncsi_clk,        
                    input  wire [1:0]                           ncsi_rbt_ncsi_txd,        
                    input  wire                                 ncsi_rbt_ncsi_tx_en,      
                    output wire [1:0]                           ncsi_rbt_ncsi_rxd,        
                    output wire                                 ncsi_rbt_ncsi_crs_dv,     
                    input  wire                                 ncsi_rbt_ncsi_arb_in,     
                    output wire                                 ncsi_rbt_ncsi_arb_out,    
                    input  wire                                 m10_gpio_fpga_usr_100m,   
                    input  wire                                 m10_gpio_fpga_m10_hb,     
                    input  wire                                 m10_gpio_m10_seu_error,   
                    output wire                                 m10_gpio_fpga_therm_shdn, 
                    output wire                                 m10_gpio_fpga_seu_error,  
                    output wire                                 spi_ingress_sclk,         
                    output wire                                 spi_ingress_csn,          
                    input  wire                                 spi_ingress_miso,         
                    output wire                                 spi_ingress_mosi,         
                    input  wire                                 spi_egress_mosi,          
                    input  wire                                 spi_egress_csn,           
                    input  wire                                 spi_egress_sclk,          
                    output wire                                 spi_egress_miso         
`endif                                                                                    

`ifdef INCLUDE_HPS                                                                              
 
                    ,input                                      hps_uart_rx,
		            output                                      hps_uart_tx,
		            inout                                       b_fpga_hps_zl_ho,                       
		            inout                                       b_ptp_clk_lol,                       
		            input                                       fpga_hps_clkin,                       
		            output                                      b_zl_spi_sck,
		            output                                      b_zl_spi_si,
		            input                                       b_zl_spi_so,                       
		            output                                      b_zl_spi_cs
`endif
);

localparam MM_ADDR_WIDTH = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH;
localparam MM_DATA_WIDTH = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;

//-----------------------------------------------------------------------------------------------
// Internal signals
//-----------------------------------------------------------------------------------------------

// clock signals
wire clk_sys, clk_sys_div2, clk_sys_div4, clk_ptp_slv;
wire clk_100m;
wire clk_50m;
wire clk_csr;

logic h2f_reset, h2f_reset_q;

// reset signals
logic pll_locked;
logic ninit_done;
logic pcie_reset_status;
logic pcie_cold_rst_ack_n;
logic pcie_warm_rst_ack_n;
logic pcie_cold_rst_n;
logic pcie_warm_rst_n;
logic rst_n_sys;
logic rst_n_sys_pcie;
logic rst_n_sys_afu;
logic rst_n_sys_mem;
logic rst_n_sys_hps;
logic rst_n_100m;
logic rst_n_50m;
logic rst_n_ptp_slv;
logic rst_n_csr;
logic pwr_good_n;
logic pwr_good_csr_clk_n;

//Ctrl Shadow ports
logic         p0_ss_app_st_ctrlshadow_tvalid;
logic [39:0]  p0_ss_app_st_ctrlshadow_tdata;

always_ff @(posedge clk_sys) begin
  rst_n_sys_pcie <= rst_n_sys;
  rst_n_sys_afu  <= rst_n_sys;
  rst_n_sys_mem  <= rst_n_sys;
  rst_n_sys_hps  <= rst_n_sys;

  h2f_reset_q <= h2f_reset;
end

`ifdef INCLUDE_HPS
//-----------------------------------------------------------------------------------------------
//Copy Engine Interfaces 
//to be connected to HPS
ofs_fim_ace_lite_if         hps_ace_lite_if() ; //ACE-Lite Interface between hps and copy engine
ofs_fim_axi_mmio_if #(.AWADDR_WIDTH(21), .ARADDR_WIDTH(21), .WDATA_WIDTH(32), .RDATA_WIDTH(32), .AWID_WIDTH(4), .ARID_WIDTH(4)) hps_axi4_mm_if() ; //AXI4 MM- Interface between hps and copy engine
assign hps_axi4_mm_if.awqos =4'd0;
assign hps_axi4_mm_if.arqos =4'd0;
`endif

//-----------------------------------------------------------------------------------------------
// Instantiation of the AXI_L fabric interfaces on PF0 that address maps all the components on 
// the DFL list.Each of the components connected on the DFL have an AXI-L fabric connection that 
// allows the host to read registers, traverse the list to discover these componets and load the 
// associated drivers etc.
// The fabric is divided into 2 interconnected sections: the Board Peripheral fabric(BPF) that 
// maps the subsystems that control the board interfaces (PCIe, Memory, HSSI, PMCI etc) and the 
// AFU Peripheral fabric (APF) which maps components in the AFU region (Protocol checker, 
// port gasket etc). 
// The fabrics are generated using scripts with a text file, with the components and the address 
// map, as the input. Please refer to the README in $OFS_ROOTDIR/src/pd_qsys for more details. This
// script also generates the fabric_width_pkg used below so that the widths of address busses are 
// consistent with the input specified. 
// In order to remove/add components to the DFL list, modify the qsys fabric in 
// src/pd_qsys to add/delete the component and then edit the list below to add/remove the interface. 
// If adding a component connect up the port to the new instance.
//-----------------------------------------------------------------------------------------------
// AXI4-lite interfaces
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_apf_mst_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_apf_mst_address_width)) bpf_apf_mst_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_apf_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_apf_slv_address_width)) bpf_apf_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_fme_mst_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_fme_mst_address_width)) bpf_fme_mst_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_fme_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_fme_slv_address_width)) bpf_fme_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_pmci_mst_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_pmci_mst_address_width)) bpf_pmci_mst_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_pmci_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_pmci_slv_address_width)) bpf_pmci_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_pcie_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_pcie_slv_address_width)) bpf_pcie_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_qsfp0_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_qsfp0_slv_address_width)) bpf_qsfp0_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_qsfp1_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_qsfp1_slv_address_width)) bpf_qsfp1_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_pmci_lpbk_mst_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_pmci_lpbk_mst_address_width)) bpf_pmci_lpbk_mst_if ();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_qsfp0_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_qsfp0_slv_address_width)) bpf_hssi_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_emif_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_emif_slv_address_width)) bpf_emif_slv_if();

// AXIS PCIe Subsystem Interface
pcie_ss_axis_if   pcie_ss_axis_rx_if(.clk (clk_sys), .rst_n(rst_n_sys_pcie));
pcie_ss_axis_if   pcie_ss_axis_tx_if(.clk (clk_sys), .rst_n(rst_n_sys_pcie));
pcie_ss_axis_if   pcie_ss_axis_rxreq_if(.clk (clk_sys), .rst_n(rst_n_sys_pcie));
// TXREQ is only headers (read requests)
pcie_ss_axis_if #(
   .DATA_W(pcie_ss_hdr_pkg::HDR_WIDTH),
   .USER_W(ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH)
) pcie_ss_axis_txreq_if(.clk (clk_sys), .rst_n(rst_n_sys_pcie));
t_axis_pcie_flr   pcie_flr_req;
t_axis_pcie_flr   pcie_flr_rsp;

// Partial Reconfiguration FIFO Parity Error from PR Controller
logic pr_parity_error;

// AVST interface
ofs_fim_axi_lite_if m_afu_lite();
ofs_fim_axi_lite_if s_afu_lite();

// UART interface
`ifdef INCLUDE_UART
ofs_uart_if hps_uart_if();
ofs_uart_if host_uart_if();
`endif

//Completion Timeout Interface
t_axis_pcie_cplto         axis_cpl_timeout;

//Tag Mode
t_pcie_tag_mode    tag_mode;

`ifdef INCLUDE_DDR4
localparam AFU_MEM_CHANNELS = ofs_fim_mem_if_pkg::NUM_MEM_CHANNELS;

logic [4095:0] hps2emif;
logic [4095:0] emif2hps;
logic [1:0]    hps2emif_gp;
logic          emif2hps_gp;

//AFU EMIF AXI-MM IF
ofs_fim_emif_axi_mm_if #(
   .WDATA_WIDTH (ofs_fim_mem_if_pkg::AXI_MEM_WDATA_WIDTH),
   .RDATA_WIDTH (ofs_fim_mem_if_pkg::AXI_MEM_RDATA_WIDTH),
   .AWID_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_ID_WIDTH),
   .ARID_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_ID_WIDTH),
   .AWADDR_WIDTH(ofs_fim_mem_if_pkg::AXI_MEM_ADDR_WIDTH),
   .ARADDR_WIDTH(ofs_fim_mem_if_pkg::AXI_MEM_ADDR_WIDTH)
) afu_ext_mem_if [AFU_MEM_CHANNELS-1:0] ();

`endif

//-----------------------------------------------------------------------------------------------
// Connections
//-----------------------------------------------------------------------------------------------
assign clk_csr   = clk_100m;
assign rst_n_csr = rst_n_100m;

//-----------------------------------------------------------------------------------------------
// Modules instances
//-----------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------
// HSSI Subsystem - includes MAC, PCS, PMA etc functionality for transceivers. Exact functionality
// depends on the tile on the device. The subsystem also provides a standard AXI interface to the 
// AFU which, along with a standard register set, makes porting across devices and families easier.
//-----------------------------------------------------------------------------------------------
`ifndef INCLUDE_HSSI  
// When the HSSI interface is not enabled, the "dummy" csr module is instantiated instead. This is 
// because of the fabric that makes up the DFL list and which the subsystems are connected to. 
// When a feature is disabled, the slave interface that connects to it on the fabric does not going 
// away and something must still be mapped to the address and respond to transactions. This function
// is done by the dummy module. It has its own DFH GUID and implements a couple of registers.
//-----------------------------------------------------------------------------------------------
dummy_csr #(
   .FEAT_ID          (12'h00f),
   .FEAT_VER         (4'h1),
   .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_hssi_slv_next_dfh_offset),
   .END_OF_LIST      (fabric_width_pkg::bpf_hssi_slv_eol)
) hssi_dummy_csr (
   .clk         (clk_csr),
   .rst_n       (rst_n_csr),
   .csr_lite_if (bpf_hssi_slv_if)
);

dummy_csr #(
   .FEAT_ID          (12'h13),
   .FEAT_VER         (4'h0),
   .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_qsfp0_slv_next_dfh_offset),
   .END_OF_LIST      (fabric_width_pkg::bpf_qsfp0_slv_eol)
) qsfp0_dummy_csr (
   .clk         (clk_csr),
   .rst_n       (rst_n_csr),
   .csr_lite_if (bpf_qsfp0_slv_if)
);

dummy_csr #(
   .FEAT_ID          (12'h13),
   .FEAT_VER         (4'h0),
   .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_qsfp1_slv_next_dfh_offset),
   .END_OF_LIST      (fabric_width_pkg::bpf_qsfp1_slv_eol)
) qsfp1_dummy_csr (
   .clk         (clk_csr),
   .rst_n       (rst_n_csr),
   .csr_lite_if (bpf_qsfp1_slv_if)
);
`else

ofs_fim_hssi_ss_tx_axis_if        hssi_ss_st_tx [MAX_NUM_ETH_CHANNELS-1:0]();
ofs_fim_hssi_ss_rx_axis_if        hssi_ss_st_rx [MAX_NUM_ETH_CHANNELS-1:0]();
ofs_fim_hssi_fc_if                hssi_fc [MAX_NUM_ETH_CHANNELS-1:0]();
logic [MAX_NUM_ETH_CHANNELS-1:0]  hssi_clk_pll;
logic [MAX_NUM_ETH_CHANNELS-1:0]  qsfp_speed_green;
logic [MAX_NUM_ETH_CHANNELS-1:0]  qsfp_speed_yellow;
logic [MAX_NUM_ETH_CHANNELS-1:0]  qsfp_activity_green;
logic [MAX_NUM_ETH_CHANNELS-1:0]  qsfp_activity_red;
`ifdef INCLUDE_PTP
ofs_fim_hssi_ptp_tx_tod_if        hssi_ptp_tx_tod [MAX_NUM_ETH_CHANNELS-1:0]();
ofs_fim_hssi_ptp_rx_tod_if        hssi_ptp_rx_tod [MAX_NUM_ETH_CHANNELS-1:0]();
ofs_fim_hssi_ptp_tx_egrts_if      hssi_ptp_tx_egrts [MAX_NUM_ETH_CHANNELS-1:0]();
ofs_fim_hssi_ptp_rx_ingrts_if     hssi_ptp_rx_ingrts [MAX_NUM_ETH_CHANNELS-1:0]();
`endif

hssi_wrapper hssi_wrapper (
   .clk_csr                (clk_csr),
   .rst_n_csr              (rst_n_csr),
   .csr_lite_if            (bpf_hssi_slv_if),
   .hssi_ss_st_tx          (hssi_ss_st_tx),
   .hssi_ss_st_rx          (hssi_ss_st_rx),
   .hssi_fc                (hssi_fc),
   .hssi_if                (hssi_if),
   `ifdef INCLUDE_PTP
   .sys_pll_locked         (pll_locked),
   .hssi_ptp_tx_tod        (hssi_ptp_tx_tod),
   .hssi_ptp_rx_tod        (hssi_ptp_rx_tod),
   .hssi_ptp_tx_egrts      (hssi_ptp_tx_egrts),
   .hssi_ptp_rx_ingrts     (hssi_ptp_rx_ingrts),
   .o_ehip_clk_806         (ehip_clk_806),
   .o_ehip_clk_403         (ehip_clk_403),
   .o_ehip_pll_locked      (ehip_pll_locked),
   `endif
   .i_hssi_clk_ref         ({3{qsfp_ref_clk}}),
   .o_hssi_rec_clk         (),
   .o_hssi_clk_pll         (hssi_clk_pll),
   .o_qsfp_speed_green     ({qsfpb_speed_g,qsfpa_speed_g}),
   .o_qsfp_speed_yellow    ({qsfpb_speed_y,qsfpa_speed_y}),
   .o_qsfp_activity_green  ({qsfpb_act_g,qsfpa_act_g}),
   .o_qsfp_activity_red    ({qsfpb_act_r,qsfpa_act_r})
);

//-----------------------------------------------------------------------------------------------
// QSFP Controller - responsible for managing the QSFP module(s) on the board. It includes an I2C 
// master used to access the QSFP module registers. One controller is instanatied per module. It 
// also has a CSR module that is used to drive or read pins assosciated with the QSFP such as 
// Reset, LPMode etc. 
//-----------------------------------------------------------------------------------------------

wire qsfpa_i2c_scl_in            /* synthesis keep */;
wire qsfpa_i2c_sda_in            /* synthesis keep */;
wire qsfpa_i2c_scl_oe            /* synthesis keep */;
wire qsfpa_i2c_sda_oe            /* synthesis keep */;
wire qsfpa_modesel;
wire qsfpa_reset;

wire qsfpb_i2c_scl_in            /* synthesis keep */;
wire qsfpb_i2c_sda_in            /* synthesis keep */;
wire qsfpb_i2c_scl_oe            /* synthesis keep */;
wire qsfpb_i2c_sda_oe            /* synthesis keep */;
wire qsfpb_modesel;
wire qsfpb_reset;


assign qsfpa_i2c_scl_in = qsfpa_i2c_scl;
assign qsfpa_i2c_sda_in = qsfpa_i2c_sda;
assign qsfpa_i2c_scl    = qsfpa_i2c_scl_oe ? 1'b0 : 1'bz;
assign qsfpa_i2c_sda    = qsfpa_i2c_sda_oe ? 1'b0 : 1'bz;

assign qsfpb_i2c_scl_in = qsfpb_i2c_scl;
assign qsfpb_i2c_sda_in = qsfpb_i2c_sda;
assign qsfpb_i2c_scl    = qsfpb_i2c_scl_oe ? 1'b0 : 1'bz;
assign qsfpb_i2c_sda    = qsfpb_i2c_sda_oe ? 1'b0 : 1'bz;

assign qsfpa_resetn     = ~qsfpa_reset;
assign qsfpa_modeseln   = ~qsfpa_modesel;

assign qsfpb_resetn     = ~qsfpb_reset;
assign qsfpb_modeseln   = ~qsfpb_modesel;


qsfp_top #(
   .ADDR_WIDTH       (fabric_width_pkg::bpf_qsfp0_slv_address_width),
   .DATA_WIDTH       (64),
   .FEAT_ID          (12'h13),
   .FEAT_VER         (4'h0),
   .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_qsfp0_slv_next_dfh_offset),
   .END_OF_LIST      (fabric_width_pkg::bpf_qsfp0_slv_eol)
) qsfp_0 (
   .clk (clk_csr),
   .reset(~rst_n_csr),
`ifdef INCLUDE_FTILE
   .modprsl(~qsfpa_modprsln),
`else
   .modprsl(qsfpa_modprsln),
`endif
   .int_qsfp(~qsfpa_intn),
   .i2c_0_i2c_serial_sda_in(qsfpa_i2c_sda_in),
   .i2c_0_i2c_serial_scl_in(qsfpa_i2c_scl_in),
   .i2c_0_i2c_serial_sda_oe(qsfpa_i2c_sda_oe),
   .i2c_0_i2c_serial_scl_oe(qsfpa_i2c_scl_oe),
   .modesel(qsfpa_modesel),
   .lpmode(qsfpa_lpmode),
   .softresetqsfpm(qsfpa_reset),
   .csr_lite_if (bpf_qsfp0_slv_if)
);

qsfp_top #(
   .ADDR_WIDTH       (fabric_width_pkg::bpf_qsfp1_slv_address_width),
   .DATA_WIDTH       (64),
   .FEAT_ID          (12'h13),
   .FEAT_VER         (4'h0),
   .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_qsfp1_slv_next_dfh_offset),
   .END_OF_LIST      (fabric_width_pkg::bpf_qsfp1_slv_eol)
) qsfp_1 (
   .clk (clk_csr),
   .reset(~rst_n_csr),
`ifdef INCLUDE_FTILE
   .modprsl(~qsfpb_modprsln),
`else
   .modprsl(qsfpb_modprsln),
`endif
   .int_qsfp(~qsfpb_intn),
   .i2c_0_i2c_serial_sda_in(qsfpb_i2c_sda_in),
   .i2c_0_i2c_serial_scl_in(qsfpb_i2c_scl_in),
   .i2c_0_i2c_serial_sda_oe(qsfpb_i2c_sda_oe),
   .i2c_0_i2c_serial_scl_oe(qsfpb_i2c_scl_oe),
   .modesel(qsfpb_modesel),
   .lpmode(qsfpb_lpmode),
   .softresetqsfpm(qsfpb_reset),
   .csr_lite_if (bpf_qsfp1_slv_if)
);

`endif

//-----------------------------------------------------------------------------------------------
// Configuration reset release IP
//-----------------------------------------------------------------------------------------------
`ifdef SIM_MODE
   assign ninit_done = 1'b0;
`else
   cfg_mon cfg_mon (
      .ninit_done (ninit_done)
   );
`endif

//-----------------------------------------------------------------------------------------------
// System PLL - instantiation of IOPLL to derive various clocks needed for the design.
// It derives the main design clock (470 MHz for the x16 design for e.g.) on which the majority 
// of the logic runs
// It also derives the ~100 MHz CSR clock along with a couple of related clocks to pass to the 
// port gasket for use by the AFUs
//-----------------------------------------------------------------------------------------------

sys_pll sys_pll (
   .rst                (ninit_done                ),
   .refclk             (SYS_REFCLK                ), // 100 MHz
   .locked             (pll_locked                ),
   .outclk_0           (clk_sys                   ), // 350 MHz for x8 and 470 MHz for x16
   .outclk_1           (clk_100m                  ), // 100 MHz
   .outclk_2           (clk_sys_div2              ), // 175 MHz for x8 and 235 MHz for x16
   .outclk_3           (clk_ptp_slv               ), // 155.56MHz
   .outclk_4           (clk_50m                   ), // 50 MHz
   .outclk_5           (clk_sys_div4              )  // 87.5 MHz for x8 and 117.5 MHz for x16
);

//-----------------------------------------------------------------------------------------------
// Reset controller
//-----------------------------------------------------------------------------------------------
rst_ctrl rst_ctrl (
   .clk_sys             (clk_sys                  ),
   .clk_100m            (clk_100m                 ),
   .clk_50m             (clk_50m                  ),
   .clk_ptp_slv         (clk_ptp_slv              ),
   .pll_locked          (pll_locked               ),
   .pcie_reset_status   (pcie_reset_status        ),
   .pcie_cold_rst_ack_n (pcie_cold_rst_ack_n      ),
   .pcie_warm_rst_ack_n (pcie_warm_rst_ack_n      ),
                                                 
   .ninit_done          (ninit_done               ),
   .rst_n_sys           (rst_n_sys                ),  // system reset synchronous to clk_sys
   .rst_n_100m          (rst_n_100m               ),  // system reset synchronous to clk_100m
   .rst_n_50m           (rst_n_50m                ),  // system reset synchronous to clk_50m
   .rst_n_ptp_slv       (rst_n_ptp_slv            ),  // system reset synchronous to clk_ptp_slv 
   .pwr_good_n          (pwr_good_n               ),  // system reset synchronous to clk_100m
   .pwr_good_csr_clk_n  (pwr_good_csr_clk_n       ),  // power good reset synchronous to clk_sys 
   .pcie_cold_rst_n     (pcie_cold_rst_n          ),
   .pcie_warm_rst_n     (pcie_warm_rst_n          )
); 

//-----------------------------------------------------------------------------------------------
// PCIe Subsystem - this IP instantiates the QHIP and builds various features around it such
// as a standard AXI interface, standardized register interface for the driver, interrupt support
// data mover mode(hides complexity of TLPs while implementing functionality such as completion 
// combining etc). The AXI user clock is asynchronous to the reference and the QHIP clock.
//-----------------------------------------------------------------------------------------------
 pcie_wrapper #(  
`ifdef INCLUDE_PCIE_SS
     .PCIE_LANES       (ofs_fim_cfg_pkg::PCIE_LANES),
`else
     .PCIE_LANES       (16),
`endif
     .MM_ADDR_WIDTH    (MM_ADDR_WIDTH),
     .MM_DATA_WIDTH    (MM_DATA_WIDTH),
     .FEAT_ID          (12'h020),
     .FEAT_VER         (4'h0),
     .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_pcie_slv_next_dfh_offset),
     .END_OF_LIST      (fabric_width_pkg::bpf_pcie_slv_eol)  
) pcie_wrapper (
   .fim_clk                        (clk_sys                  ),
   .fim_rst_n                      (rst_n_sys_pcie           ),
   .csr_clk                        (clk_csr                  ),
   .csr_rst_n                      (rst_n_csr                ),
   .ninit_done                     (ninit_done               ),
   .reset_status                   (pcie_reset_status        ),  
   .p0_subsystem_cold_rst_n        (pcie_cold_rst_n          ),     
   .p0_subsystem_warm_rst_n        (pcie_warm_rst_n          ),
   .p0_subsystem_cold_rst_ack_n    (pcie_cold_rst_ack_n      ),
   .p0_subsystem_warm_rst_ack_n    (pcie_warm_rst_ack_n      ),
   .pin_pcie_refclk0_p             (PCIE_REFCLK0             ),
   .pin_pcie_refclk1_p             (PCIE_REFCLK1             ),
   .pin_pcie_in_perst_n            (PCIE_RESET_N             ),   // connected to HIP
   .pin_pcie_rx_p                  (PCIE_RX_P                ),
   .pin_pcie_rx_n                  (PCIE_RX_N                ),
   .pin_pcie_tx_p                  (PCIE_TX_P                ),                
   .pin_pcie_tx_n                  (PCIE_TX_N                ),   
   .p0_ss_app_st_ctrlshadow_tvalid (p0_ss_app_st_ctrlshadow_tvalid ),
   .p0_ss_app_st_ctrlshadow_tdata  (p0_ss_app_st_ctrlshadow_tdata  ),
   .axi_st_rxreq_if                (pcie_ss_axis_rxreq_if    ),
   .axi_st_rx_if                   (pcie_ss_axis_rx_if       ),
   .axi_st_tx_if                   (pcie_ss_axis_tx_if       ),
   .axi_st_txreq_if                (pcie_ss_axis_txreq_if    ),
   .csr_lite_if                    (bpf_pcie_slv_if          ),
   .axi_st_flr_req                 (pcie_flr_req             ),
   .axi_st_flr_rsp                 (pcie_flr_rsp             ),
   .axis_cpl_timeout               (axis_cpl_timeout         ),
   .tag_mode                       (tag_mode                 )
);


//-----------------------------------------------------------------------------------------------
// PMCI Subsystem - This subsystem works closely with the BMC and is responsible for manageability,
// telemetry, support for PLDM over MCTP via PCIe and error logging. It provides the path 
// through the FPGA for rsu functions as well.
//-----------------------------------------------------------------------------------------------
`ifdef INCLUDE_PMCI                                                                              
pmci_wrapper #(
     .FEAT_ID          (12'h012),
     .FEAT_VER         (4'h1),
     .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_pmci_slv_next_dfh_offset),
     .END_OF_LIST      (fabric_width_pkg::bpf_pmci_slv_eol),
     .pmci_csr_PCIE_SS_ADDR    (fabric_width_pkg::bpf_pcie_slv_baseaddress),
     .pmci_csr_HSSI_SS_ADDR    (fabric_width_pkg::bpf_hssi_slv_baseaddress),
     .pmci_csr_PCIEVDM_AFU_ADDR(fabric_width_pkg::bpf_pmci_lpbk_slv_baseaddress + fabric_width_pkg::apf_st2mm_slv_baseaddress + 'h2000),
     .pmci_csr_QSFPA_CTRL_ADDR (fabric_width_pkg::bpf_qsfp0_slv_baseaddress),
     .pmci_csr_QSFPB_CTRL_ADDR (fabric_width_pkg::bpf_qsfp1_slv_baseaddress),
     .pmci_csr_END_OF_LIST     (fabric_width_pkg::bpf_pmci_slv_eol),
     .pmci_csr_NEXT_DFH_OFFSET (fabric_width_pkg::bpf_pmci_slv_next_dfh_offset),
     .pmci_csr_FEAT_VER        (1),
     .pmci_csr_FEAT_ID         (18)
) pmci_wrapper (
      .clk_csr                   (clk_csr                 ),                               
      .reset_csr                 (!rst_n_csr              ),                               
      .csr_lite_slv_if           (bpf_pmci_slv_if         ),
      .csr_lite_mst_if           (bpf_pmci_mst_if         ),
      .qspi_dclk                 (qspi_dclk               ),                               
      .qspi_ncs                  (qspi_ncs                ),                               
      .qspi_data                 (qspi_data               ),                               
      .ncsi_rbt_ncsi_clk         (ncsi_rbt_ncsi_clk       ),                               
      .ncsi_rbt_ncsi_txd         (ncsi_rbt_ncsi_txd       ),                               
      .ncsi_rbt_ncsi_tx_en       (ncsi_rbt_ncsi_tx_en     ),                               
      .ncsi_rbt_ncsi_rxd         (ncsi_rbt_ncsi_rxd       ),                               
      .ncsi_rbt_ncsi_crs_dv      (ncsi_rbt_ncsi_crs_dv    ),                               
      .ncsi_rbt_ncsi_arb_in      (ncsi_rbt_ncsi_arb_in    ),                               
      .ncsi_rbt_ncsi_arb_out     (ncsi_rbt_ncsi_arb_out   ),                               
      .m10_gpio_fpga_usr_100m    (m10_gpio_fpga_usr_100m  ),                               
      .m10_gpio_fpga_m10_hb      (m10_gpio_fpga_m10_hb    ),                               
      .m10_gpio_m10_seu_error    (m10_gpio_m10_seu_error  ),                               
      .m10_gpio_fpga_therm_shdn  (m10_gpio_fpga_therm_shdn),                               
      .m10_gpio_fpga_seu_error   (m10_gpio_fpga_seu_error ),                               
      .spi_ingress_sclk          (spi_ingress_sclk        ),                               
      .spi_ingress_csn           (spi_ingress_csn         ),                               
      .spi_ingress_miso          (spi_ingress_miso        ),                               
      .spi_ingress_mosi          (spi_ingress_mosi        ),                               
      .spi_egress_mosi           (spi_egress_mosi         ),
      .spi_egress_csn            (spi_egress_csn          ),
      .spi_egress_sclk           (spi_egress_sclk         ),        
      .spi_egress_miso           (spi_egress_miso         ) 
 );

`else
   // dummy csr slv if incase PMCI is not used
   dummy_csr #(
      .FEAT_ID          (12'h012),
      .FEAT_VER         (4'h1),
      //.NEXT_DFH_OFFSET  (24'h1000),
      .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_pmci_slv_next_dfh_offset),
      .END_OF_LIST      (fabric_width_pkg::bpf_pmci_slv_eol)
   ) pmci_dummy_csr (
      .clk         (clk_csr),
      .rst_n       (rst_n_csr),
      .csr_lite_if (bpf_pmci_slv_if)
   );
  `ifdef SIM_VIP   
    // if VIP is used for simulation then bpf_pmci_mst_if will be driven by the VIP
  `else  
    always_comb
    begin  
      bpf_pmci_mst_if.awaddr   = 21'h0;
      bpf_pmci_mst_if.awprot   = 3'h0;
      bpf_pmci_mst_if.awvalid  = 1'b0;
      bpf_pmci_mst_if.wdata    = 32'h0;
      bpf_pmci_mst_if.wstrb    = 4'h0;
      bpf_pmci_mst_if.wvalid   = 1'b0;
      bpf_pmci_mst_if.bready   = 1'b0;  
      bpf_pmci_mst_if.araddr   = 21'h0;
      bpf_pmci_mst_if.arprot   = 3'h0; 
      bpf_pmci_mst_if.arvalid  = 1'b0;
      bpf_pmci_mst_if.rready   = 1'b0;
    end
  `endif
`endif

//-----------------------------------------------------------------------------------------------
// FME
//-----------------------------------------------------------------------------------------------
  fme_top #(
     .ST2MM_MSIX_ADDR (fabric_width_pkg::apf_st2mm_slv_baseaddress + 'h10),
     .NEXT_DFH_OFFSET (fabric_width_pkg::bpf_fme_slv_next_dfh_offset)
  ) fme_top(
          .clk               (clk_csr                   ),
          .rst_n             (rst_n_csr                 ),
          .pr_parity_error   (pr_parity_error           ),
          .pwr_good_n        (pwr_good_n                ),
          .axi_lite_m_if     (bpf_fme_mst_if            ),
          .axi_lite_s_if     (bpf_fme_slv_if            )
         );


//-----------------------------------------------------------------------------------------------
// AFU - The AFU_top hierarchy contains the following
// * protocol checker  - Module responsible for error handling and debug. 
// * st2mm             - Module that primarily handles streaming to AXI-MM conversion 
// * fim_afu_instances - This hierarchy contains the workloads that are instantiated in the static 
//                       region. This file is expected to be modified by the customer to instantiate
//                       other workloads as needed
// * port gasket and port_afu_instances - this hierarchy instanties the PR controller and assosciated 
//                       logic needed for partial reconfiguration. The workloads in the PR region 
//                       are instanted in port_afu_instances hierarchy. This is expected to be modified
//                       by the customer to instantiate the PR workloads
//-----------------------------------------------------------------------------------------------
  afu_top #(
`ifdef INCLUDE_DDR4
         .AFU_MEM_CHANNEL     (AFU_MEM_CHANNELS   )
`endif
  )afu_top(
         .SYS_REFCLK          (SYS_REFCLK                   ),
         .clk                 (clk_sys                      ),
         .rst_n               (rst_n_sys_afu                ),
         .clk_csr             (clk_csr                      ),
         .rst_n_csr           (rst_n_csr                    ),
         .clk_50m             (clk_50m                      ),
         .rst_n_50m           (rst_n_50m                    ),
         .pwr_good_csr_clk_n  (pwr_good_csr_clk_n           ), // power good reset synchronous to csr_clk
         .clk_div2            (clk_sys_div2                 ),
         .clk_div4            (clk_sys_div4                 ),

         .cpri_refclk_184_32m (cr3_cpri_reflclk_clk_184_32m ),
         .cpri_refclk_153_6m  (cr3_cpri_reflclk_clk_153_6m  ),
         
         .pcie_flr_req        (pcie_flr_req                 ),
         .pcie_flr_rsp        (pcie_flr_rsp                 ),
         .pr_parity_error     (pr_parity_error              ),
         .tag_mode            (tag_mode                     ),

         .apf_bpf_slv_if      (bpf_apf_mst_if               ),
         .apf_bpf_mst_if      (bpf_apf_slv_if               ),
         
`ifdef INCLUDE_HPS 
         .hps_axi4_mm_if      (hps_axi4_mm_if               ),
         .hps_ace_lite_if     (hps_ace_lite_if              ), 
         .h2f_reset           (h2f_reset_q                  ),
`endif

         .pcie_ss_axis_rxreq  (pcie_ss_axis_rxreq_if        ),
         .pcie_ss_axis_rx     (pcie_ss_axis_rx_if           ),
         .pcie_ss_axis_tx     (pcie_ss_axis_tx_if           ),
         .pcie_ss_axis_txreq  (pcie_ss_axis_txreq_if        )
        
`ifdef INCLUDE_UART
         ,.host_uart_if        (host_uart_if)
`endif
`ifdef INCLUDE_DDR4
         ,.ext_mem_if          (afu_ext_mem_if)
`endif

`ifdef INCLUDE_HSSI
         ,.hssi_ss_st_tx       (hssi_ss_st_tx           ),
         .hssi_ss_st_rx        (hssi_ss_st_rx           ),
         .hssi_fc              (hssi_fc                 ),
         `ifdef INCLUDE_PTP
         .hssi_ptp_tx_tod      (hssi_ptp_tx_tod         ),
         .hssi_ptp_rx_tod      (hssi_ptp_rx_tod         ),
         .hssi_ptp_tx_egrts    (hssi_ptp_tx_egrts       ),
         .hssi_ptp_rx_ingrts   (hssi_ptp_rx_ingrts      ),
         .i_ehip_clk_806       (ehip_clk_806            ),
         .i_ehip_clk_403       (ehip_clk_403            ),
         .i_ehip_pll_locked    (ehip_pll_locked         ),
         `endif
         .i_hssi_clk_pll       (hssi_clk_pll            )
`endif 
         );
//-----------------------------------------------------------------------------------------------
// HPS SS - the HPS SS instantiates the embedded Hard Processor that is available on the device.
// The HPS is connected to a DRAM and also some peripherals such as UART, SPI Master etc.
//-----------------------------------------------------------------------------------------------

`ifdef INCLUDE_HPS                                                                              
`ifdef INCLUDE_UART
// Connect HPS UART to virtual HOST UART
assign hps_uart_if.rx = host_uart_if.tx;
assign hps_uart_if.cts_n = host_uart_if.rts_n;
assign hps_uart_if.dsr_n = 1'b0;
assign hps_uart_if.dcd_n = 1'b0;
assign hps_uart_if.ri_n = 1'b0;

assign host_uart_if.rx = hps_uart_if.tx;
assign host_uart_if.cts_n = hps_uart_if.rts_n;
assign host_uart_if.dsr_n = 1'b0;
assign host_uart_if.dcd_n = 1'b0;
assign host_uart_if.ri_n = 1'b0;
`endif
   
	hps_ss 
	hps_ss (
		.clk_clk                                      (clk_sys                    ),         
		.intel_agilex_hps_1_hps_emif_emif_to_hps      (emif2hps                   ),        
		.intel_agilex_hps_1_hps_emif_hps_to_emif      (hps2emif                   ),        
		.intel_agilex_hps_1_hps_emif_emif_to_gp       (emif2hps_gp                ),     
		.intel_agilex_hps_1_hps_emif_gp_to_emif       (hps2emif_gp                ),     
`ifdef INCLUDE_UART
        .intel_agilex_hps_1_uart1_cts_n               (hps_uart_if.cts_n          ),   
        .intel_agilex_hps_1_uart1_dsr_n               (hps_uart_if.dsr_n          ),   
        .intel_agilex_hps_1_uart1_dcd_n               (hps_uart_if.dcd_n          ),   
        .intel_agilex_hps_1_uart1_ri_n                (hps_uart_if.ri_n           ),    
        .intel_agilex_hps_1_uart1_rx                  (hps_uart_if.rx             ),      
        .intel_agilex_hps_1_uart1_dtr_n               (hps_uart_if.dtr_n          ),   
        .intel_agilex_hps_1_uart1_rts_n               (hps_uart_if.rts_n          ),   
        .intel_agilex_hps_1_uart1_out1_n              (hps_uart_if.out1_n         ),  
        .intel_agilex_hps_1_uart1_out2_n              (hps_uart_if.out2_n         ),  
        .intel_agilex_hps_1_uart1_tx                  (hps_uart_if.tx             ),      
`endif
		.intel_agilex_hps_1_hps_io_SPIM0_CLK          (b_zl_spi_sck               ),       
		.intel_agilex_hps_1_hps_io_SPIM0_MOSI         (b_zl_spi_si                ),        
		.intel_agilex_hps_1_hps_io_SPIM0_MISO         (b_zl_spi_so                ),        
		.intel_agilex_hps_1_hps_io_SPIM0_SS0_N        (b_zl_spi_cs                ),        
		.intel_agilex_hps_1_hps_io_gpio0_io13         (b_fpga_hps_zl_ho           ),   
		.intel_agilex_hps_1_hps_io_gpio0_io14         (b_ptp_clk_lol              ),      
		.intel_agilex_hps_1_hps_io_UART0_RX           (hps_uart_rx                ),         
		.intel_agilex_hps_1_hps_io_UART0_TX           (hps_uart_tx                ),         
		.intel_agilex_hps_1_hps_io_hps_osc_clk        (fpga_hps_clkin             ),     
		.intel_agilex_hps_1_h2f_reset_reset           (h2f_reset                  ),           
		.intel_agilex_hps_1_h2f_lw_axi_master_awid    (hps_axi4_mm_if.awid        ),   
		.intel_agilex_hps_1_h2f_lw_axi_master_awaddr  (hps_axi4_mm_if.awaddr      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_awlen   (hps_axi4_mm_if.awlen       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_awsize  (hps_axi4_mm_if.awsize      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_awburst (hps_axi4_mm_if.awburst     ),
		.intel_agilex_hps_1_h2f_lw_axi_master_awlock  (hps_axi4_mm_if.awlock      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_awcache (hps_axi4_mm_if.awcache     ),
		.intel_agilex_hps_1_h2f_lw_axi_master_awprot  (hps_axi4_mm_if.awprot      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_awvalid (hps_axi4_mm_if.awvalid     ),
		.intel_agilex_hps_1_h2f_lw_axi_master_awready (hps_axi4_mm_if.awready     ),
		.intel_agilex_hps_1_h2f_lw_axi_master_wdata   (hps_axi4_mm_if.wdata       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_wstrb   (hps_axi4_mm_if.wstrb       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_wlast   (hps_axi4_mm_if.wlast       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_wvalid  (hps_axi4_mm_if.wvalid      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_wready  (hps_axi4_mm_if.wready      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_bid     (hps_axi4_mm_if.bid         ),    
		.intel_agilex_hps_1_h2f_lw_axi_master_bresp   (hps_axi4_mm_if.bresp       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_bvalid  (hps_axi4_mm_if.bvalid      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_bready  (hps_axi4_mm_if.bready      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_arid    (hps_axi4_mm_if.arid        ),   
		.intel_agilex_hps_1_h2f_lw_axi_master_araddr  (hps_axi4_mm_if.araddr      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_arlen   (hps_axi4_mm_if.arlen       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_arsize  (hps_axi4_mm_if.arsize      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_arburst (hps_axi4_mm_if.arburst     ),
		.intel_agilex_hps_1_h2f_lw_axi_master_arlock  (hps_axi4_mm_if.arlock      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_arcache (hps_axi4_mm_if.arcache     ),
		.intel_agilex_hps_1_h2f_lw_axi_master_arprot  (hps_axi4_mm_if.arprot      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_arvalid (hps_axi4_mm_if.arvalid     ),
		.intel_agilex_hps_1_h2f_lw_axi_master_arready (hps_axi4_mm_if.arready     ),
		.intel_agilex_hps_1_h2f_lw_axi_master_rid     (hps_axi4_mm_if.rid         ),    
		.intel_agilex_hps_1_h2f_lw_axi_master_rdata   (hps_axi4_mm_if.rdata       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_rresp   (hps_axi4_mm_if.rresp       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_rlast   (hps_axi4_mm_if.rlast       ),  
		.intel_agilex_hps_1_h2f_lw_axi_master_rvalid  (hps_axi4_mm_if.rvalid      ), 
		.intel_agilex_hps_1_h2f_lw_axi_master_rready  (hps_axi4_mm_if.rready      ), 
		.intel_agilex_hps_1_f2h_axi_slave_awid        (hps_ace_lite_if.awid       ),         
		.intel_agilex_hps_1_f2h_axi_slave_awaddr      (hps_ace_lite_if.awaddr     ), 
		.intel_agilex_hps_1_f2h_axi_slave_awlen       (hps_ace_lite_if.awlen      ),  
		.intel_agilex_hps_1_f2h_axi_slave_awsize      (hps_ace_lite_if.awsize     ), 
		.intel_agilex_hps_1_f2h_axi_slave_awburst     (hps_ace_lite_if.awburst    ),
		.intel_agilex_hps_1_f2h_axi_slave_awlock      (hps_ace_lite_if.awlock     ),      
		.intel_agilex_hps_1_f2h_axi_slave_awcache     (hps_ace_lite_if.awcache    ),        
		.intel_agilex_hps_1_f2h_axi_slave_awprot      (hps_ace_lite_if.awprot     ), 
		.intel_agilex_hps_1_f2h_axi_slave_awvalid     (hps_ace_lite_if.awvalid    ),
		.intel_agilex_hps_1_f2h_axi_slave_awready     (hps_ace_lite_if.awready    ),
		.intel_agilex_hps_1_f2h_axi_slave_awqos       (hps_ace_lite_if.awqos      ),       
		.intel_agilex_hps_1_f2h_axi_slave_wdata       (hps_ace_lite_if.wdata      ),  
		.intel_agilex_hps_1_f2h_axi_slave_wstrb       (hps_ace_lite_if.wstrb      ),  
		.intel_agilex_hps_1_f2h_axi_slave_wlast       (hps_ace_lite_if.wlast      ),  
		.intel_agilex_hps_1_f2h_axi_slave_wvalid      (hps_ace_lite_if.wvalid     ), 
		.intel_agilex_hps_1_f2h_axi_slave_wready      (hps_ace_lite_if.wready     ), 
		.intel_agilex_hps_1_f2h_axi_slave_bid         (hps_ace_lite_if.bid        ),            
		.intel_agilex_hps_1_f2h_axi_slave_bresp       (hps_ace_lite_if.bresp      ),  
		.intel_agilex_hps_1_f2h_axi_slave_bvalid      (hps_ace_lite_if.bvalid     ), 
		.intel_agilex_hps_1_f2h_axi_slave_bready      (hps_ace_lite_if.bready     ), 
		.intel_agilex_hps_1_f2h_axi_slave_arid        (hps_ace_lite_if.arid       ),        
		.intel_agilex_hps_1_f2h_axi_slave_araddr      (hps_ace_lite_if.araddr     ), 
		.intel_agilex_hps_1_f2h_axi_slave_arlen       (hps_ace_lite_if.arlen      ),  
		.intel_agilex_hps_1_f2h_axi_slave_arsize      (hps_ace_lite_if.arsize     ), 
		.intel_agilex_hps_1_f2h_axi_slave_arburst     (hps_ace_lite_if.arburst    ),
		.intel_agilex_hps_1_f2h_axi_slave_arlock      (hps_ace_lite_if.arlock     ),         
		.intel_agilex_hps_1_f2h_axi_slave_arcache     (hps_ace_lite_if.arcache    ),       
		.intel_agilex_hps_1_f2h_axi_slave_arprot      (hps_ace_lite_if.arprot     ), 
		.intel_agilex_hps_1_f2h_axi_slave_arvalid     (hps_ace_lite_if.arvalid    ),
		.intel_agilex_hps_1_f2h_axi_slave_arready     (hps_ace_lite_if.arready    ),
		.intel_agilex_hps_1_f2h_axi_slave_arqos       (hps_ace_lite_if.arqos      ),        
		.intel_agilex_hps_1_f2h_axi_slave_rid         (hps_ace_lite_if.rid        ),            
		.intel_agilex_hps_1_f2h_axi_slave_rdata       (hps_ace_lite_if.rdata      ),      
		.intel_agilex_hps_1_f2h_axi_slave_rresp       (hps_ace_lite_if.rresp      ),      
		.intel_agilex_hps_1_f2h_axi_slave_rlast       (hps_ace_lite_if.rlast      ),      
		.intel_agilex_hps_1_f2h_axi_slave_rvalid      (hps_ace_lite_if.rvalid     ),     
		.intel_agilex_hps_1_f2h_axi_slave_rready      (hps_ace_lite_if.rready     ),     
		.intel_agilex_hps_1_f2h_axi_slave_awdomain    (hps_ace_lite_if.awdomain   ),   
		.intel_agilex_hps_1_f2h_axi_slave_awbar       (hps_ace_lite_if.awbar      ),      
		.intel_agilex_hps_1_f2h_axi_slave_ardomain    (hps_ace_lite_if.ardomain   ),   
		.intel_agilex_hps_1_f2h_axi_slave_arbar       (hps_ace_lite_if.arbar      ),      
		.intel_agilex_hps_1_f2h_axi_slave_arsnoop     (hps_ace_lite_if.arsnoop    ),    
		.intel_agilex_hps_1_f2h_axi_slave_awsnoop     (hps_ace_lite_if.awsnoop    ),    
		.intel_agilex_hps_1_f2h_axi_slave_aruser      (hps_ace_lite_if.aruser     ),      
		.intel_agilex_hps_1_f2h_axi_slave_awuser      (hps_ace_lite_if.awuser     ),     
		.reset_reset                                  (!rst_n_sys_hps)
	);

`endif

//-----------------------------------------------------------------------------------------------
// BPF - Board Peripheral Fabric. This is a 64-b AXI-Lite Qsys generated interconnect fabric which
// (with the APF) address maps and connects up the components that form the DFL list to the host. 
// This fabric is clocked by the clk_csr. The components connected on the BPF include the subsystems
// (HSSI, PCIe, QSFP, MEM), the PMCI, FME etc
// The address space is assigned in Qsys based on the number of bits needed by the slave
//-----------------------------------------------------------------------------------------------
   bpf 
   bpf (
          .clk_clk              (clk_csr                   ),
          .rst_n_reset_n        (rst_n_csr                 ),
          
          .bpf_apf_mst_awaddr   (bpf_apf_mst_if.awaddr     ),
          .bpf_apf_mst_awprot   (bpf_apf_mst_if.awprot     ),
          .bpf_apf_mst_awvalid  (bpf_apf_mst_if.awvalid    ),
          .bpf_apf_mst_awready  (bpf_apf_mst_if.awready    ),
          .bpf_apf_mst_wdata    (bpf_apf_mst_if.wdata      ),
          .bpf_apf_mst_wstrb    (bpf_apf_mst_if.wstrb      ),
          .bpf_apf_mst_wvalid   (bpf_apf_mst_if.wvalid     ),
          .bpf_apf_mst_wready   (bpf_apf_mst_if.wready     ),
          .bpf_apf_mst_bresp    (bpf_apf_mst_if.bresp      ),
          .bpf_apf_mst_bvalid   (bpf_apf_mst_if.bvalid     ),
          .bpf_apf_mst_bready   (bpf_apf_mst_if.bready     ),
          .bpf_apf_mst_araddr   (bpf_apf_mst_if.araddr     ),
          .bpf_apf_mst_arprot   (bpf_apf_mst_if.arprot     ),
          .bpf_apf_mst_arvalid  (bpf_apf_mst_if.arvalid    ),
          .bpf_apf_mst_arready  (bpf_apf_mst_if.arready    ),
          .bpf_apf_mst_rdata    (bpf_apf_mst_if.rdata      ),
          .bpf_apf_mst_rresp    (bpf_apf_mst_if.rresp      ),
          .bpf_apf_mst_rvalid   (bpf_apf_mst_if.rvalid     ),
          .bpf_apf_mst_rready   (bpf_apf_mst_if.rready     ),
          
          .bpf_apf_slv_awaddr   (bpf_apf_slv_if.awaddr     ),
          .bpf_apf_slv_awprot   (bpf_apf_slv_if.awprot     ),
          .bpf_apf_slv_awvalid  (bpf_apf_slv_if.awvalid    ),
          .bpf_apf_slv_awready  (bpf_apf_slv_if.awready    ),
          .bpf_apf_slv_wdata    (bpf_apf_slv_if.wdata      ),
          .bpf_apf_slv_wstrb    (bpf_apf_slv_if.wstrb      ),
          .bpf_apf_slv_wvalid   (bpf_apf_slv_if.wvalid     ),
          .bpf_apf_slv_wready   (bpf_apf_slv_if.wready     ),
          .bpf_apf_slv_bresp    (bpf_apf_slv_if.bresp      ),
          .bpf_apf_slv_bvalid   (bpf_apf_slv_if.bvalid     ),
          .bpf_apf_slv_bready   (bpf_apf_slv_if.bready     ),
          .bpf_apf_slv_araddr   (bpf_apf_slv_if.araddr     ),
          .bpf_apf_slv_arprot   (bpf_apf_slv_if.arprot     ),
          .bpf_apf_slv_arvalid  (bpf_apf_slv_if.arvalid    ),
          .bpf_apf_slv_arready  (bpf_apf_slv_if.arready    ),
          .bpf_apf_slv_rdata    (bpf_apf_slv_if.rdata      ),
          .bpf_apf_slv_rresp    (bpf_apf_slv_if.rresp      ),
          .bpf_apf_slv_rvalid   (bpf_apf_slv_if.rvalid     ),
          .bpf_apf_slv_rready   (bpf_apf_slv_if.rready     ),
                
          .bpf_fme_slv_awaddr   (bpf_fme_slv_if.awaddr     ),
          .bpf_fme_slv_awprot   (bpf_fme_slv_if.awprot     ),
          .bpf_fme_slv_awvalid  (bpf_fme_slv_if.awvalid    ),
          .bpf_fme_slv_awready  (bpf_fme_slv_if.awready    ),
          .bpf_fme_slv_wdata    (bpf_fme_slv_if.wdata      ),
          .bpf_fme_slv_wstrb    (bpf_fme_slv_if.wstrb      ),
          .bpf_fme_slv_wvalid   (bpf_fme_slv_if.wvalid     ),
          .bpf_fme_slv_wready   (bpf_fme_slv_if.wready     ),
          .bpf_fme_slv_bresp    (bpf_fme_slv_if.bresp      ),
          .bpf_fme_slv_bvalid   (bpf_fme_slv_if.bvalid     ),
          .bpf_fme_slv_bready   (bpf_fme_slv_if.bready     ),
          .bpf_fme_slv_araddr   (bpf_fme_slv_if.araddr     ),
          .bpf_fme_slv_arprot   (bpf_fme_slv_if.arprot     ),
          .bpf_fme_slv_arvalid  (bpf_fme_slv_if.arvalid    ),
          .bpf_fme_slv_arready  (bpf_fme_slv_if.arready    ),
          .bpf_fme_slv_rdata    (bpf_fme_slv_if.rdata      ),
          .bpf_fme_slv_rresp    (bpf_fme_slv_if.rresp      ),
          .bpf_fme_slv_rvalid   (bpf_fme_slv_if.rvalid     ),
          .bpf_fme_slv_rready   (bpf_fme_slv_if.rready     ),
          
          .bpf_pcie_slv_awaddr  (bpf_pcie_slv_if.awaddr    ), 
          .bpf_pcie_slv_awprot  (bpf_pcie_slv_if.awprot    ), 
          .bpf_pcie_slv_awvalid (bpf_pcie_slv_if.awvalid   ), 
          .bpf_pcie_slv_awready (bpf_pcie_slv_if.awready   ), 
          .bpf_pcie_slv_wdata   (bpf_pcie_slv_if.wdata     ), 
          .bpf_pcie_slv_wstrb   (bpf_pcie_slv_if.wstrb     ), 
          .bpf_pcie_slv_wvalid  (bpf_pcie_slv_if.wvalid    ), 
          .bpf_pcie_slv_wready  (bpf_pcie_slv_if.wready    ), 
          .bpf_pcie_slv_bresp   (bpf_pcie_slv_if.bresp     ), 
          .bpf_pcie_slv_bvalid  (bpf_pcie_slv_if.bvalid    ), 
          .bpf_pcie_slv_bready  (bpf_pcie_slv_if.bready    ), 
          .bpf_pcie_slv_araddr  (bpf_pcie_slv_if.araddr    ), 
          .bpf_pcie_slv_arprot  (bpf_pcie_slv_if.arprot    ), 
          .bpf_pcie_slv_arvalid (bpf_pcie_slv_if.arvalid   ), 
          .bpf_pcie_slv_arready (bpf_pcie_slv_if.arready   ), 
          .bpf_pcie_slv_rdata   (bpf_pcie_slv_if.rdata     ), 
          .bpf_pcie_slv_rresp   (bpf_pcie_slv_if.rresp     ), 
          .bpf_pcie_slv_rvalid  (bpf_pcie_slv_if.rvalid    ), 
          .bpf_pcie_slv_rready  (bpf_pcie_slv_if.rready    ), 

          .bpf_pmci_mst_awaddr   (bpf_pmci_mst_if.awaddr   ),
          .bpf_pmci_mst_awprot   (bpf_pmci_mst_if.awprot   ),
          .bpf_pmci_mst_awvalid  (bpf_pmci_mst_if.awvalid  ),
          .bpf_pmci_mst_awready  (bpf_pmci_mst_if.awready  ),
          .bpf_pmci_mst_wdata    (bpf_pmci_mst_if.wdata    ),
          .bpf_pmci_mst_wstrb    (bpf_pmci_mst_if.wstrb    ),
          .bpf_pmci_mst_wvalid   (bpf_pmci_mst_if.wvalid   ),
          .bpf_pmci_mst_wready   (bpf_pmci_mst_if.wready   ),
          .bpf_pmci_mst_bresp    (bpf_pmci_mst_if.bresp    ),
          .bpf_pmci_mst_bvalid   (bpf_pmci_mst_if.bvalid   ),
          .bpf_pmci_mst_bready   (bpf_pmci_mst_if.bready   ),
          .bpf_pmci_mst_araddr   (bpf_pmci_mst_if.araddr   ),
          .bpf_pmci_mst_arprot   (bpf_pmci_mst_if.arprot   ),
          .bpf_pmci_mst_arvalid  (bpf_pmci_mst_if.arvalid  ),
          .bpf_pmci_mst_arready  (bpf_pmci_mst_if.arready  ),
          .bpf_pmci_mst_rdata    (bpf_pmci_mst_if.rdata    ),
          .bpf_pmci_mst_rresp    (bpf_pmci_mst_if.rresp    ),
          .bpf_pmci_mst_rvalid   (bpf_pmci_mst_if.rvalid   ),
          .bpf_pmci_mst_rready   (bpf_pmci_mst_if.rready   ),

          .bpf_pmci_lpbk_mst_awaddr   (bpf_pmci_lpbk_mst_if.awaddr   ),
          .bpf_pmci_lpbk_mst_awprot   (bpf_pmci_lpbk_mst_if.awprot   ),
          .bpf_pmci_lpbk_mst_awvalid  (bpf_pmci_lpbk_mst_if.awvalid  ),
          .bpf_pmci_lpbk_mst_awready  (bpf_pmci_lpbk_mst_if.awready  ),
          .bpf_pmci_lpbk_mst_wdata    (bpf_pmci_lpbk_mst_if.wdata    ),
          .bpf_pmci_lpbk_mst_wstrb    (bpf_pmci_lpbk_mst_if.wstrb    ),
          .bpf_pmci_lpbk_mst_wvalid   (bpf_pmci_lpbk_mst_if.wvalid   ),
          .bpf_pmci_lpbk_mst_wready   (bpf_pmci_lpbk_mst_if.wready   ),
          .bpf_pmci_lpbk_mst_bresp    (bpf_pmci_lpbk_mst_if.bresp    ),
          .bpf_pmci_lpbk_mst_bvalid   (bpf_pmci_lpbk_mst_if.bvalid   ),
          .bpf_pmci_lpbk_mst_bready   (bpf_pmci_lpbk_mst_if.bready   ),
          .bpf_pmci_lpbk_mst_araddr   (bpf_pmci_lpbk_mst_if.araddr   ),
          .bpf_pmci_lpbk_mst_arprot   (bpf_pmci_lpbk_mst_if.arprot   ),
          .bpf_pmci_lpbk_mst_arvalid  (bpf_pmci_lpbk_mst_if.arvalid  ),
          .bpf_pmci_lpbk_mst_arready  (bpf_pmci_lpbk_mst_if.arready  ),
          .bpf_pmci_lpbk_mst_rdata    (bpf_pmci_lpbk_mst_if.rdata    ),
          .bpf_pmci_lpbk_mst_rresp    (bpf_pmci_lpbk_mst_if.rresp    ),
          .bpf_pmci_lpbk_mst_rvalid   (bpf_pmci_lpbk_mst_if.rvalid   ),
          .bpf_pmci_lpbk_mst_rready   (bpf_pmci_lpbk_mst_if.rready   ),

          .bpf_pmci_lpbk_slv_awaddr   (bpf_pmci_lpbk_mst_if.awaddr   ),
          .bpf_pmci_lpbk_slv_awprot   (bpf_pmci_lpbk_mst_if.awprot   ),
          .bpf_pmci_lpbk_slv_awvalid  (bpf_pmci_lpbk_mst_if.awvalid  ),
          .bpf_pmci_lpbk_slv_awready  (bpf_pmci_lpbk_mst_if.awready  ),
          .bpf_pmci_lpbk_slv_wdata    (bpf_pmci_lpbk_mst_if.wdata    ),
          .bpf_pmci_lpbk_slv_wstrb    (bpf_pmci_lpbk_mst_if.wstrb    ),
          .bpf_pmci_lpbk_slv_wvalid   (bpf_pmci_lpbk_mst_if.wvalid   ),
          .bpf_pmci_lpbk_slv_wready   (bpf_pmci_lpbk_mst_if.wready   ),
          .bpf_pmci_lpbk_slv_bresp    (bpf_pmci_lpbk_mst_if.bresp    ),
          .bpf_pmci_lpbk_slv_bvalid   (bpf_pmci_lpbk_mst_if.bvalid   ),
          .bpf_pmci_lpbk_slv_bready   (bpf_pmci_lpbk_mst_if.bready   ),
          .bpf_pmci_lpbk_slv_araddr   (bpf_pmci_lpbk_mst_if.araddr   ),
          .bpf_pmci_lpbk_slv_arprot   (bpf_pmci_lpbk_mst_if.arprot   ),
          .bpf_pmci_lpbk_slv_arvalid  (bpf_pmci_lpbk_mst_if.arvalid  ),
          .bpf_pmci_lpbk_slv_arready  (bpf_pmci_lpbk_mst_if.arready  ),
          .bpf_pmci_lpbk_slv_rdata    (bpf_pmci_lpbk_mst_if.rdata    ),
          .bpf_pmci_lpbk_slv_rresp    (bpf_pmci_lpbk_mst_if.rresp    ),
          .bpf_pmci_lpbk_slv_rvalid   (bpf_pmci_lpbk_mst_if.rvalid   ),
          .bpf_pmci_lpbk_slv_rready   (bpf_pmci_lpbk_mst_if.rready   ),




          .bpf_pmci_slv_awaddr  (bpf_pmci_slv_if.awaddr    ),
          .bpf_pmci_slv_awprot  (bpf_pmci_slv_if.awprot    ),
          .bpf_pmci_slv_awvalid (bpf_pmci_slv_if.awvalid   ),
          .bpf_pmci_slv_awready (bpf_pmci_slv_if.awready   ),
          .bpf_pmci_slv_wdata   (bpf_pmci_slv_if.wdata     ),
          .bpf_pmci_slv_wstrb   (bpf_pmci_slv_if.wstrb     ),
          .bpf_pmci_slv_wvalid  (bpf_pmci_slv_if.wvalid    ),
          .bpf_pmci_slv_wready  (bpf_pmci_slv_if.wready    ),
          .bpf_pmci_slv_bresp   (bpf_pmci_slv_if.bresp     ),
          .bpf_pmci_slv_bvalid  (bpf_pmci_slv_if.bvalid    ),
          .bpf_pmci_slv_bready  (bpf_pmci_slv_if.bready    ),
          .bpf_pmci_slv_araddr  (bpf_pmci_slv_if.araddr    ),
          .bpf_pmci_slv_arprot  (bpf_pmci_slv_if.arprot    ),
          .bpf_pmci_slv_arvalid (bpf_pmci_slv_if.arvalid   ),
          .bpf_pmci_slv_arready (bpf_pmci_slv_if.arready   ),
          .bpf_pmci_slv_rdata   (bpf_pmci_slv_if.rdata     ),
          .bpf_pmci_slv_rresp   (bpf_pmci_slv_if.rresp     ),
          .bpf_pmci_slv_rvalid  (bpf_pmci_slv_if.rvalid    ),
          .bpf_pmci_slv_rready  (bpf_pmci_slv_if.rready    ),

          .bpf_qsfp0_slv_awaddr  (bpf_qsfp0_slv_if.awaddr  ),
          .bpf_qsfp0_slv_awprot  (bpf_qsfp0_slv_if.awprot  ),
          .bpf_qsfp0_slv_awvalid (bpf_qsfp0_slv_if.awvalid ),
          .bpf_qsfp0_slv_awready (bpf_qsfp0_slv_if.awready ),
          .bpf_qsfp0_slv_wdata   (bpf_qsfp0_slv_if.wdata   ),
          .bpf_qsfp0_slv_wstrb   (bpf_qsfp0_slv_if.wstrb   ),
          .bpf_qsfp0_slv_wvalid  (bpf_qsfp0_slv_if.wvalid  ),
          .bpf_qsfp0_slv_wready  (bpf_qsfp0_slv_if.wready  ),
          .bpf_qsfp0_slv_bresp   (bpf_qsfp0_slv_if.bresp   ),
          .bpf_qsfp0_slv_bvalid  (bpf_qsfp0_slv_if.bvalid  ),
          .bpf_qsfp0_slv_bready  (bpf_qsfp0_slv_if.bready  ),
          .bpf_qsfp0_slv_araddr  (bpf_qsfp0_slv_if.araddr  ),
          .bpf_qsfp0_slv_arprot  (bpf_qsfp0_slv_if.arprot  ),
          .bpf_qsfp0_slv_arvalid (bpf_qsfp0_slv_if.arvalid ),
          .bpf_qsfp0_slv_arready (bpf_qsfp0_slv_if.arready ),
          .bpf_qsfp0_slv_rdata   (bpf_qsfp0_slv_if.rdata   ),
          .bpf_qsfp0_slv_rresp   (bpf_qsfp0_slv_if.rresp   ),
          .bpf_qsfp0_slv_rvalid  (bpf_qsfp0_slv_if.rvalid  ),
          .bpf_qsfp0_slv_rready  (bpf_qsfp0_slv_if.rready  ),

          .bpf_qsfp1_slv_awaddr  (bpf_qsfp1_slv_if.awaddr  ),
          .bpf_qsfp1_slv_awprot  (bpf_qsfp1_slv_if.awprot  ),
          .bpf_qsfp1_slv_awvalid (bpf_qsfp1_slv_if.awvalid ),
          .bpf_qsfp1_slv_awready (bpf_qsfp1_slv_if.awready ),
          .bpf_qsfp1_slv_wdata   (bpf_qsfp1_slv_if.wdata   ),
          .bpf_qsfp1_slv_wstrb   (bpf_qsfp1_slv_if.wstrb   ),
          .bpf_qsfp1_slv_wvalid  (bpf_qsfp1_slv_if.wvalid  ),
          .bpf_qsfp1_slv_wready  (bpf_qsfp1_slv_if.wready  ),
          .bpf_qsfp1_slv_bresp   (bpf_qsfp1_slv_if.bresp   ),
          .bpf_qsfp1_slv_bvalid  (bpf_qsfp1_slv_if.bvalid  ),
          .bpf_qsfp1_slv_bready  (bpf_qsfp1_slv_if.bready  ),
          .bpf_qsfp1_slv_araddr  (bpf_qsfp1_slv_if.araddr  ),
          .bpf_qsfp1_slv_arprot  (bpf_qsfp1_slv_if.arprot  ),
          .bpf_qsfp1_slv_arvalid (bpf_qsfp1_slv_if.arvalid ),
          .bpf_qsfp1_slv_arready (bpf_qsfp1_slv_if.arready ),
          .bpf_qsfp1_slv_rdata   (bpf_qsfp1_slv_if.rdata   ),
          .bpf_qsfp1_slv_rresp   (bpf_qsfp1_slv_if.rresp   ),
          .bpf_qsfp1_slv_rvalid  (bpf_qsfp1_slv_if.rvalid  ),
          .bpf_qsfp1_slv_rready  (bpf_qsfp1_slv_if.rready  ),

          .bpf_hssi_slv_awaddr   (bpf_hssi_slv_if.awaddr  ),
          .bpf_hssi_slv_awprot   (bpf_hssi_slv_if.awprot  ),
          .bpf_hssi_slv_awvalid  (bpf_hssi_slv_if.awvalid ),
          .bpf_hssi_slv_awready  (bpf_hssi_slv_if.awready ),
          .bpf_hssi_slv_wdata    (bpf_hssi_slv_if.wdata   ),
          .bpf_hssi_slv_wstrb    (bpf_hssi_slv_if.wstrb   ),
          .bpf_hssi_slv_wvalid   (bpf_hssi_slv_if.wvalid  ),
          .bpf_hssi_slv_wready   (bpf_hssi_slv_if.wready  ),
          .bpf_hssi_slv_bresp    (bpf_hssi_slv_if.bresp   ),
          .bpf_hssi_slv_bvalid   (bpf_hssi_slv_if.bvalid  ),
          .bpf_hssi_slv_bready   (bpf_hssi_slv_if.bready  ),
          .bpf_hssi_slv_araddr   (bpf_hssi_slv_if.araddr  ),
          .bpf_hssi_slv_arprot   (bpf_hssi_slv_if.arprot  ),
          .bpf_hssi_slv_arvalid  (bpf_hssi_slv_if.arvalid ),
          .bpf_hssi_slv_arready  (bpf_hssi_slv_if.arready ),
          .bpf_hssi_slv_rdata    (bpf_hssi_slv_if.rdata   ),
          .bpf_hssi_slv_rresp    (bpf_hssi_slv_if.rresp   ),
          .bpf_hssi_slv_rvalid   (bpf_hssi_slv_if.rvalid  ),
          .bpf_hssi_slv_rready   (bpf_hssi_slv_if.rready  ),

          .bpf_emif_slv_awaddr   (bpf_emif_slv_if.awaddr  ),
          .bpf_emif_slv_awprot   (bpf_emif_slv_if.awprot  ),
          .bpf_emif_slv_awvalid  (bpf_emif_slv_if.awvalid ),
          .bpf_emif_slv_awready  (bpf_emif_slv_if.awready ),
          .bpf_emif_slv_wdata    (bpf_emif_slv_if.wdata   ),
          .bpf_emif_slv_wstrb    (bpf_emif_slv_if.wstrb   ),
          .bpf_emif_slv_wvalid   (bpf_emif_slv_if.wvalid  ),
          .bpf_emif_slv_wready   (bpf_emif_slv_if.wready  ),
          .bpf_emif_slv_bresp    (bpf_emif_slv_if.bresp   ),
          .bpf_emif_slv_bvalid   (bpf_emif_slv_if.bvalid  ),
          .bpf_emif_slv_bready   (bpf_emif_slv_if.bready  ),
          .bpf_emif_slv_araddr   (bpf_emif_slv_if.araddr  ),
          .bpf_emif_slv_arprot   (bpf_emif_slv_if.arprot  ),
          .bpf_emif_slv_arvalid  (bpf_emif_slv_if.arvalid ),
          .bpf_emif_slv_arready  (bpf_emif_slv_if.arready ),
          .bpf_emif_slv_rdata    (bpf_emif_slv_if.rdata   ),
          .bpf_emif_slv_rresp    (bpf_emif_slv_if.rresp   ),
          .bpf_emif_slv_rvalid   (bpf_emif_slv_if.rvalid  ),
          .bpf_emif_slv_rready   (bpf_emif_slv_if.rready  ),

          .bpf_fme_mst_awaddr   (bpf_fme_mst_if.awaddr     ),
          .bpf_fme_mst_awprot   (bpf_fme_mst_if.awprot     ),
          .bpf_fme_mst_awvalid  (bpf_fme_mst_if.awvalid    ),
          .bpf_fme_mst_awready  (bpf_fme_mst_if.awready    ),
          .bpf_fme_mst_wdata    (bpf_fme_mst_if.wdata      ),
          .bpf_fme_mst_wstrb    (bpf_fme_mst_if.wstrb      ),
          .bpf_fme_mst_wvalid   (bpf_fme_mst_if.wvalid     ),
          .bpf_fme_mst_wready   (bpf_fme_mst_if.wready     ),
          .bpf_fme_mst_bresp    (bpf_fme_mst_if.bresp      ),
          .bpf_fme_mst_bvalid   (bpf_fme_mst_if.bvalid     ),
          .bpf_fme_mst_bready   (bpf_fme_mst_if.bready     ),
          .bpf_fme_mst_araddr   (bpf_fme_mst_if.araddr     ),
          .bpf_fme_mst_arprot   (bpf_fme_mst_if.arprot     ),
          .bpf_fme_mst_arvalid  (bpf_fme_mst_if.arvalid    ),
          .bpf_fme_mst_arready  (bpf_fme_mst_if.arready    ),
          .bpf_fme_mst_rdata    (bpf_fme_mst_if.rdata      ),
          .bpf_fme_mst_rresp    (bpf_fme_mst_if.rresp      ),
          .bpf_fme_mst_rvalid   (bpf_fme_mst_if.rvalid     ),
          .bpf_fme_mst_rready   (bpf_fme_mst_if.rready     )

   );

//-----------------------------------------------------------------------------------------------
// Memory Subsystem - the memory SS wraps the memory channels on the board and sets up the 
// timing parameters etc. It provides a standard AXI interface to connect to workloads.
//-----------------------------------------------------------------------------------------------
`ifdef INCLUDE_DDR4
   mem_ss_top #(
      .FEAT_ID          (12'h009),
      .FEAT_VER         (4'h1),
      .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_emif_slv_next_dfh_offset),
      .END_OF_LIST      (fabric_width_pkg::bpf_emif_slv_eol)
   ) mem_ss_top (
      .clk      (clk_sys),
      .reset    (~rst_n_sys_mem),

       // AFU ext mem interfaces
      .afu_mem_if   (afu_ext_mem_if),
      .ddr4_mem_if  (ddr4_mem),
      // .ddr4_ecc     (ddr4_ecc_mem),

`ifdef INCLUDE_HPS
       // HPS mem interfaces
      .hps2emif    (hps2emif),
      .hps2emif_gp (hps2emif_gp),
      .emif2hps    (emif2hps),
      .emif2hps_gp (emif2hps_gp),
      .ddr4_hps_if (ddr4_hps),
`endif

       // CSR interfaces
      .clk_csr     (clk_csr),
      .rst_n_csr   (rst_n_csr),
      .csr_lite_if (bpf_emif_slv_if)
   );
`else
   // Placeholder logic incase HSSI is not used
   dummy_csr #(
      .FEAT_ID          (12'h009),
      .FEAT_VER         (4'h1),
      .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_emif_slv_next_dfh_offset),
      .END_OF_LIST      (fabric_width_pkg::bpf_emif_slv_eol)
   ) emif_dummy_csr (
      .clk         (clk_csr),
      .rst_n       (rst_n_csr),
      .csr_lite_if (bpf_emif_slv_if)
   );
`endif
endmodule
