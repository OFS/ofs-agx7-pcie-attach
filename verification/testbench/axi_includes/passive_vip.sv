// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`define DUT tb_top.DUT 
`define AFU_TOP tb_top.DUT.afu_top.port_gasket.pr_slot.afu_main.port_afu_instances.afu_gen[1].heh_gen.he_hssi_inst

module passive_vip(`AXI_IF PCie2AFU_if0,`AXI_IF MUX2HE_HSSI_if1,`AXI_IF HE_HSSI2HSSI_if2,`AXI_IF BPF_if3);

     

     //assign axi_if.common_aclk = tb_top.DUT.clk_100m;
    // assign axi_if.slave_if[6].aresetn      = tb_top.DUT.rst_n_100m;

  assign PCie2AFU_if0.common_aclk = `DUT.pcie_wrapper.axi_st_tx_if.clk;
  assign PCie2AFU_if0.master_if[0].aresetn = `DUT.pcie_wrapper.axi_st_tx_if.rst_n;
  assign PCie2AFU_if0.slave_if[0].aresetn =  `DUT.pcie_wrapper.axi_st_rx_if.rst_n;

  
  assign MUX2HE_HSSI_if1.common_aclk          = `AFU_TOP.axis_rx_if.clk;
  assign MUX2HE_HSSI_if1.master_if[0].aresetn = `AFU_TOP.axis_rx_if.rst_n;
  assign MUX2HE_HSSI_if1.slave_if[0].aresetn  = `AFU_TOP.axis_tx_if.rst_n;
`ifdef FIM_B
  assign HE_HSSI2HSSI_if2.common_aclk          = `AFU_TOP.hssi_ss_st_tx_cpri[0].clk;
  assign HE_HSSI2HSSI_if2.slave_if[0].aresetn  = `AFU_TOP.hssi_ss_st_tx_cpri[0].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[1].aresetn  = `AFU_TOP.hssi_ss_st_tx_cpri[1].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[2].aresetn  = `AFU_TOP.hssi_ss_st_tx_cpri[2].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[3].aresetn  = `AFU_TOP.hssi_ss_st_tx_cpri[3].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[4].aresetn  = `AFU_TOP.hssi_ss_st_tx_cpri[4].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[5].aresetn  = `AFU_TOP.hssi_ss_st_tx_cpri[5].rst_n;
`endif
  assign HE_HSSI2HSSI_if2.common_aclk          = `AFU_TOP.hssi_ss_st_tx[0].clk;
  assign HE_HSSI2HSSI_if2.slave_if[0].aresetn  = `AFU_TOP.hssi_ss_st_tx[0].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[1].aresetn  = `AFU_TOP.hssi_ss_st_tx[1].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[2].aresetn  = `AFU_TOP.hssi_ss_st_tx[2].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[3].aresetn  = `AFU_TOP.hssi_ss_st_tx[3].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[4].aresetn  = `AFU_TOP.hssi_ss_st_tx[4].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[5].aresetn  = `AFU_TOP.hssi_ss_st_tx[5].rst_n;

  assign HE_HSSI2HSSI_if2.master_if[0].aresetn = `AFU_TOP.hssi_ss_st_rx[0].rst_n;
  assign HE_HSSI2HSSI_if2.master_if[1].aresetn = `AFU_TOP.hssi_ss_st_rx[1].rst_n;
  assign HE_HSSI2HSSI_if2.master_if[2].aresetn = `AFU_TOP.hssi_ss_st_rx[2].rst_n;
  assign HE_HSSI2HSSI_if2.master_if[3].aresetn = `AFU_TOP.hssi_ss_st_rx[3].rst_n;
  assign HE_HSSI2HSSI_if2.master_if[4].aresetn = `AFU_TOP.hssi_ss_st_rx[4].rst_n;
  assign HE_HSSI2HSSI_if2.master_if[5].aresetn = `AFU_TOP.hssi_ss_st_rx[5].rst_n;
  
  assign HE_HSSI2HSSI_if2.master_if[6].aresetn = `AFU_TOP.hssi_ss_st_rx[6].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[6].aresetn  = `AFU_TOP.hssi_ss_st_tx[6].rst_n;
  assign HE_HSSI2HSSI_if2.master_if[7].aresetn = `AFU_TOP.hssi_ss_st_rx[7].rst_n;
  assign HE_HSSI2HSSI_if2.slave_if[7].aresetn  = `AFU_TOP.hssi_ss_st_tx[7].rst_n;
  assign BPF_if3.common_aclk = tb_top.DUT.clk_100m;
  assign BPF_if3.master_if[0].aresetn = tb_top.DUT.rst_n_100m;
  //assign BPF_if3.master_if[1].aresetn = tb_top.DUT.rst_n_100m;
  assign BPF_if3.master_if[2].aresetn = tb_top.DUT.rst_n_100m;
  //assign BPF_if3.slave_if[0].aresetn =  tb_top.DUT.rst_n_100m;
  assign BPF_if3.slave_if[1].aresetn =  tb_top.DUT.rst_n_100m;
  assign BPF_if3.slave_if[2].aresetn =  tb_top.DUT.rst_n_100m;
  assign BPF_if3.slave_if[3].aresetn =  tb_top.DUT.rst_n_100m;
  assign BPF_if3.slave_if[4].aresetn =  tb_top.DUT.rst_n_100m;
  assign BPF_if3.slave_if[5].aresetn =  tb_top.DUT.rst_n_100m;

//////////////////PCIE2AFU PASSIVE CONNECTION////////////////////////////////////////
//clk               =`DUT.pcie_wrapper.axi_st_rx_if.clk
//rst_n             =`DUT.pcie_wrapper.axi_st_rx_if.rst_n
assign PCie2AFU_if0.slave_if[0].tvalid            =`DUT.pcie_wrapper.axi_st_rx_if.tvalid;
assign PCie2AFU_if0.slave_if[0].tlast             =`DUT.pcie_wrapper.axi_st_rx_if.tlast;
assign PCie2AFU_if0.slave_if[0].tuser             =`DUT.pcie_wrapper.axi_st_rx_if.tuser_vendor[9:0];
assign PCie2AFU_if0.slave_if[0].tdata[511:0]      =`DUT.pcie_wrapper.axi_st_rx_if.tdata[511:0];
assign PCie2AFU_if0.slave_if[0].tkeep[63:0]       =`DUT.pcie_wrapper.axi_st_rx_if.tkeep[63:0];
assign PCie2AFU_if0.slave_if[0].tready            =`DUT.pcie_wrapper.axi_st_rx_if.tready;
assign PCie2AFU_if0.slave_if[0].tdest             = 4'b0000;
assign PCie2AFU_if0.slave_if[0].tstrb             ='b0;
assign PCie2AFU_if0.slave_if[0].tid               =8'b0000_0000;

assign PCie2AFU_if0.master_if[0].tvalid            =`DUT.pcie_wrapper.axi_st_tx_if.tvalid;
assign PCie2AFU_if0.master_if[0].tlast             =`DUT.pcie_wrapper.axi_st_tx_if.tlast;
assign PCie2AFU_if0.master_if[0].tuser             =`DUT.pcie_wrapper.axi_st_tx_if.tuser_vendor[9:0];
assign PCie2AFU_if0.master_if[0].tdata[511:0]      =`DUT.pcie_wrapper.axi_st_tx_if.tdata[511:0];
assign PCie2AFU_if0.master_if[0].tkeep[63:0]       =`DUT.pcie_wrapper.axi_st_tx_if.tkeep[63:0];
assign PCie2AFU_if0.master_if[0].tready            =`DUT.pcie_wrapper.axi_st_tx_if.tready;
assign PCie2AFU_if0.master_if[0].tdest             = 4'b0000;
assign PCie2AFU_if0.master_if[0].tstrb             ='b0;
assign PCie2AFU_if0.master_if[0].tid               =8'b0000_0000;


/////////////////////////MUX2HE_HSSI_PASSIVE_CONNECTION////////////////////////////
assign MUX2HE_HSSI_if1.slave_if[0].tvalid            =`AFU_TOP.axis_tx_if.tvalid;
assign MUX2HE_HSSI_if1.slave_if[0].tlast             =`AFU_TOP.axis_tx_if.tlast;
assign MUX2HE_HSSI_if1.slave_if[0].tuser             =`AFU_TOP.axis_tx_if.tuser_vendor[9:0];
assign MUX2HE_HSSI_if1.slave_if[0].tdata[511:0]      =`AFU_TOP.axis_tx_if.tdata[511:0];
assign MUX2HE_HSSI_if1.slave_if[0].tkeep[63:0]       =`AFU_TOP.axis_tx_if.tkeep[63:0];
assign MUX2HE_HSSI_if1.slave_if[0].tready            =`AFU_TOP.axis_tx_if.tready;
assign MUX2HE_HSSI_if1.slave_if[0].tdest             = 4'b0000;
assign MUX2HE_HSSI_if1.slave_if[0].tstrb             ='b0;
assign MUX2HE_HSSI_if1.slave_if[0].tid               =8'b0000_0000;

assign MUX2HE_HSSI_if1.master_if[0].tvalid            =`AFU_TOP.axis_rx_if.tvalid;
assign MUX2HE_HSSI_if1.master_if[0].tlast             =`AFU_TOP.axis_rx_if.tlast;
assign MUX2HE_HSSI_if1.master_if[0].tuser             =`AFU_TOP.axis_rx_if.tuser_vendor[9:0];
assign MUX2HE_HSSI_if1.master_if[0].tdata[511:0]      =`AFU_TOP.axis_rx_if.tdata[511:0];
assign MUX2HE_HSSI_if1.master_if[0].tkeep[63:0]       =`AFU_TOP.axis_rx_if.tkeep[63:0];
assign MUX2HE_HSSI_if1.master_if[0].tready            =`AFU_TOP.axis_rx_if.tready;
assign MUX2HE_HSSI_if1.master_if[0].tdest             = 4'b0000;
assign MUX2HE_HSSI_if1.master_if[0].tstrb             ='b0;
assign MUX2HE_HSSI_if1.master_if[0].tid               =8'b0000_0000;
/////////////////////////////////////HE-HSSI2HSSI_PASIVE_CONNETION///////////////////////////////////
`ifdef FIM_B
assign HE_HSSI2HSSI_if2.slave_if[0].tvalid            =`AFU_TOP.hssi_ss_st_tx_cpri[0].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[0].tlast             =`AFU_TOP.hssi_ss_st_tx_cpri[0].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[0].tuser[1:0]        =`AFU_TOP.hssi_ss_st_tx_cpri[0].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[0].tdata[63:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[0].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[0].tkeep[7:0]        =`AFU_TOP.hssi_ss_st_tx_cpri[0].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[0].tready            =`AFU_TOP.hssi_ss_st_tx_cpri[0].tready;
`endif
assign HE_HSSI2HSSI_if2.slave_if[0].tvalid            =`AFU_TOP.hssi_ss_st_tx[0].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[0].tlast             =`AFU_TOP.hssi_ss_st_tx[0].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[0].tuser[1:0]        =`AFU_TOP.hssi_ss_st_tx[0].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[0].tdata[63:0]       =`AFU_TOP.hssi_ss_st_tx[0].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[0].tkeep[7:0]        =`AFU_TOP.hssi_ss_st_tx[0].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[0].tready            =`AFU_TOP.hssi_ss_st_tx[0].tready;

assign HE_HSSI2HSSI_if2.slave_if[0].tdest             = 4'b0000;
assign HE_HSSI2HSSI_if2.slave_if[0].tstrb             ='b0;
assign HE_HSSI2HSSI_if2.slave_if[0].tid               =8'b0000_0000;

assign HE_HSSI2HSSI_if2.master_if[0].tvalid           =`AFU_TOP.hssi_ss_st_rx[0].rx.tvalid;
assign HE_HSSI2HSSI_if2.master_if[0].tlast            =`AFU_TOP.hssi_ss_st_rx[0].rx.tlast;
assign HE_HSSI2HSSI_if2.master_if[0].tuser            =`AFU_TOP.hssi_ss_st_rx[0].rx.tuser[11:0];
assign HE_HSSI2HSSI_if2.master_if[0].tdata[63:0]      =`AFU_TOP.hssi_ss_st_rx[0].rx.tdata[63:0];
assign HE_HSSI2HSSI_if2.master_if[0].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_rx[0].rx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.master_if[0].tdest             = 4'b0000;
assign HE_HSSI2HSSI_if2.master_if[0].tstrb             ='b0;
assign HE_HSSI2HSSI_if2.master_if[0].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[0].tready            =1'b1;
/////////////////////////////////////BPF2APF_PASIVE_CONNECTION///////////////////////////////////
assign BPF_if3.master_if[0].awaddr  =  `DUT.bpf_apf_mst_if.awaddr[17:0];
assign BPF_if3.master_if[0].awprot  =  `DUT.bpf_apf_mst_if.awprot[2:0];
assign BPF_if3.master_if[0].awvalid =  `DUT.bpf_apf_mst_if.awvalid;
assign BPF_if3.master_if[0].awready =  `DUT.bpf_apf_mst_if.awready;
assign BPF_if3.master_if[0].wdata   =  `DUT.bpf_apf_mst_if.wdata[63:0];
assign BPF_if3.master_if[0].wstrb   =  `DUT.bpf_apf_mst_if.wstrb[7:0];
assign BPF_if3.master_if[0].wvalid  =  `DUT.bpf_apf_mst_if.wvalid; 
assign BPF_if3.master_if[0].wready  =  `DUT.bpf_apf_mst_if.wready; 
assign BPF_if3.master_if[0].bresp   =  `DUT.bpf_apf_mst_if.bresp[1:0]; 
assign BPF_if3.master_if[0].bvalid  =  `DUT.bpf_apf_mst_if.bvalid;
assign BPF_if3.master_if[0].bready  =  `DUT.bpf_apf_mst_if.bready;
assign BPF_if3.master_if[0].araddr  =  `DUT.bpf_apf_mst_if.araddr[17:0];
assign BPF_if3.master_if[0].arprot  =  `DUT.bpf_apf_mst_if.arprot[2:0];
assign BPF_if3.master_if[0].arvalid =  `DUT.bpf_apf_mst_if.arvalid;
assign BPF_if3.master_if[0].arready =  `DUT.bpf_apf_mst_if.arready;
assign BPF_if3.master_if[0].rdata   =  `DUT.bpf_apf_mst_if.rdata[63:0];
assign BPF_if3.master_if[0].rresp   =  `DUT.bpf_apf_mst_if.rresp[1:0];
assign BPF_if3.master_if[0].rvalid  =  `DUT.bpf_apf_mst_if.rvalid;
assign BPF_if3.master_if[0].rready  =  `DUT.bpf_apf_mst_if.rready;

/////////////////////////////////////BPF2FME_PASIVE_CONNECTION///////////////////////////////////
assign BPF_if3.slave_if[1].awaddr  =  `DUT.bpf_fme_slv_if.awaddr[15:0];                                    //master 1 will be here
assign BPF_if3.slave_if[1].awprot  =  `DUT.bpf_fme_slv_if.awprot[2:0];
assign BPF_if3.slave_if[1].awvalid =  `DUT.bpf_fme_slv_if.awvalid;
assign BPF_if3.slave_if[1].awready =  `DUT.bpf_fme_slv_if.awready;
assign BPF_if3.slave_if[1].wdata   =  `DUT.bpf_fme_slv_if.wdata[63:0];
assign BPF_if3.slave_if[1].wstrb   =  `DUT.bpf_fme_slv_if.wstrb[7:0];
assign BPF_if3.slave_if[1].wvalid  =  `DUT.bpf_fme_slv_if.wvalid; 
assign BPF_if3.slave_if[1].wready  =  `DUT.bpf_fme_slv_if.wready; 
assign BPF_if3.slave_if[1].bresp   =  `DUT.bpf_fme_slv_if.bresp[1:0];
assign BPF_if3.slave_if[1].bvalid  =  `DUT.bpf_fme_slv_if.bvalid;
assign BPF_if3.slave_if[1].bready  =  `DUT.bpf_fme_slv_if.bready ;
assign BPF_if3.slave_if[1].araddr  =  `DUT.bpf_fme_slv_if.araddr[15:0]; 
assign BPF_if3.slave_if[1].arprot  =  `DUT.bpf_fme_slv_if.arprot[2:0];
assign BPF_if3.slave_if[1].arvalid =  `DUT.bpf_fme_slv_if.arvalid;
assign BPF_if3.slave_if[1].arready =  `DUT.bpf_fme_slv_if.arready ;
assign BPF_if3.slave_if[1].rdata   =  `DUT.bpf_fme_slv_if.rdata[63:0];
assign BPF_if3.slave_if[1].rresp   =  `DUT.bpf_fme_slv_if.rresp[1:0];
assign BPF_if3.slave_if[1].rvalid  =  `DUT.bpf_fme_slv_if.rvalid;
assign BPF_if3.slave_if[1].rready  =  `DUT.bpf_fme_slv_if.rready;

//////////////////////////////////BPF2PMCI_PASIVE_CONNECTION///////////////////////////////////
assign BPF_if3.master_if[2].awaddr  =  `DUT.bpf_pmci_mst_if.awaddr; 
assign BPF_if3.master_if[2].awprot  =  `DUT.bpf_pmci_mst_if.awprot;
assign BPF_if3.master_if[2].awvalid =  `DUT.bpf_pmci_mst_if.awvalid;
assign BPF_if3.master_if[2].awready =  `DUT.bpf_pmci_mst_if.awready;
assign BPF_if3.master_if[2].wdata   =  `DUT.bpf_pmci_mst_if.wdata;
assign BPF_if3.master_if[2].wstrb   =  `DUT.bpf_pmci_mst_if.wstrb;
assign BPF_if3.master_if[2].wvalid  =  `DUT.bpf_pmci_mst_if.wvalid ;
assign BPF_if3.master_if[2].wready  =  `DUT.bpf_pmci_mst_if.wready;
assign BPF_if3.master_if[2].bresp   =  `DUT.bpf_pmci_mst_if.bresp;
assign BPF_if3.master_if[2].bvalid  =  `DUT.bpf_pmci_mst_if.bvalid;
assign BPF_if3.master_if[2].bready  =  `DUT.bpf_pmci_mst_if.bready ;
assign BPF_if3.master_if[2].araddr  =  `DUT.bpf_pmci_mst_if.araddr;
assign BPF_if3.master_if[2].arprot  =  `DUT.bpf_pmci_mst_if.arprot;
assign BPF_if3.master_if[2].arvalid =  `DUT.bpf_pmci_mst_if.arvalid;
assign BPF_if3.master_if[2].arready =  `DUT.bpf_pmci_mst_if.arready;
assign BPF_if3.master_if[2].rdata   =  `DUT.bpf_pmci_mst_if.rdata;
assign BPF_if3.master_if[2].rresp   =  `DUT.bpf_pmci_mst_if.rresp;
assign BPF_if3.master_if[2].rvalid  =  `DUT.bpf_pmci_mst_if.rvalid;
assign BPF_if3.master_if[2].rready  =  `DUT.bpf_pmci_mst_if.rready;

assign BPF_if3.slave_if[2].awaddr  =  `DUT.bpf_pmci_slv_if.awaddr;
assign BPF_if3.slave_if[2].awprot  =  `DUT.bpf_pmci_slv_if.awprot;
assign BPF_if3.slave_if[2].awvalid =  `DUT.bpf_pmci_slv_if.awvalid;
assign BPF_if3.slave_if[2].awready =  `DUT.bpf_pmci_slv_if.awready ;
assign BPF_if3.slave_if[2].wdata   =  `DUT.bpf_pmci_slv_if.wdata;
assign BPF_if3.slave_if[2].wstrb   =  `DUT.bpf_pmci_slv_if.wstrb;
assign BPF_if3.slave_if[2].wvalid  =  `DUT.bpf_pmci_slv_if.wvalid;
assign BPF_if3.slave_if[2].wready  =  `DUT.bpf_pmci_slv_if.wready;
assign BPF_if3.slave_if[2].bresp   =  `DUT.bpf_pmci_slv_if.bresp;
assign BPF_if3.slave_if[2].bvalid  =  `DUT.bpf_pmci_slv_if.bvalid;
assign BPF_if3.slave_if[2].bready  =  `DUT.bpf_pmci_slv_if.bready;
assign BPF_if3.slave_if[2].araddr  =  `DUT.bpf_pmci_slv_if.araddr;
assign BPF_if3.slave_if[2].arprot  =  `DUT.bpf_pmci_slv_if.arprot;
assign BPF_if3.slave_if[2].arvalid =  `DUT.bpf_pmci_slv_if.arvalid ;
assign BPF_if3.slave_if[2].arready =  `DUT.bpf_pmci_slv_if.arready;
assign BPF_if3.slave_if[2].rdata   =  `DUT.bpf_pmci_slv_if.rdata;
assign BPF_if3.slave_if[2].rresp   =  `DUT.bpf_pmci_slv_if.rresp;
assign BPF_if3.slave_if[2].rvalid  =  `DUT.bpf_pmci_slv_if.rvalid; 
assign BPF_if3.slave_if[2].rready  =  `DUT.bpf_pmci_slv_if.rready;

/////////////////////////////////////BPF2PCIe_PASIVE_CONNECTION///////////////////////////////////
assign BPF_if3.slave_if[3].awaddr  =  `DUT.bpf_pcie_slv_if.awaddr;
assign BPF_if3.slave_if[3].awprot  =  `DUT.bpf_pcie_slv_if.awprot;
assign BPF_if3.slave_if[3].awvalid =  `DUT.bpf_pcie_slv_if.awvalid ;
assign BPF_if3.slave_if[3].awready =  `DUT.bpf_pcie_slv_if.awready ;
assign BPF_if3.slave_if[3].wdata   =  `DUT.bpf_pcie_slv_if.wdata;
assign BPF_if3.slave_if[3].wstrb   =  `DUT.bpf_pcie_slv_if.wstrb;
assign BPF_if3.slave_if[3].wvalid  =  `DUT.bpf_pcie_slv_if.wvalid;
assign BPF_if3.slave_if[3].wready  =  `DUT.bpf_pcie_slv_if.wready;
assign BPF_if3.slave_if[3].bresp   =  `DUT.bpf_pcie_slv_if.bresp; 
assign BPF_if3.slave_if[3].bvalid  =  `DUT.bpf_pcie_slv_if.bvalid ;
assign BPF_if3.slave_if[3].bready  =  `DUT.bpf_pcie_slv_if.bready;
assign BPF_if3.slave_if[3].araddr  =  `DUT.bpf_pcie_slv_if.araddr;
assign BPF_if3.slave_if[3].arprot  =  `DUT.bpf_pcie_slv_if.arprot;
assign BPF_if3.slave_if[3].arvalid =  `DUT.bpf_pcie_slv_if.arvalid;
assign BPF_if3.slave_if[3].arready =  `DUT.bpf_pcie_slv_if.arready ;
assign BPF_if3.slave_if[3].rdata   =  `DUT.bpf_pcie_slv_if.rdata;
assign BPF_if3.slave_if[3].rresp   =  `DUT.bpf_pcie_slv_if.rresp;
assign BPF_if3.slave_if[3].rvalid  =  `DUT.bpf_pcie_slv_if.rvalid; 
assign BPF_if3.slave_if[3].rready  =  `DUT.bpf_pcie_slv_if.rready; 
/////////////////////////////////////BPF2QSFP0_PASIVE_CONNECTION///////////////////////////////////
assign BPF_if3.slave_if[4].awaddr  =   `DUT.bpf_qsfp0_slv_if.awaddr; 
assign BPF_if3.slave_if[4].awprot  =   `DUT.bpf_qsfp0_slv_if.awprot; 
assign BPF_if3.slave_if[4].awvalid =   `DUT.bpf_qsfp0_slv_if.awvalid;
assign BPF_if3.slave_if[4].awready =   `DUT.bpf_qsfp0_slv_if.awready;
assign BPF_if3.slave_if[4].wdata   =   `DUT.bpf_qsfp0_slv_if.wdata ; 
assign BPF_if3.slave_if[4].wstrb   =   `DUT.bpf_qsfp0_slv_if.wstrb ; 
assign BPF_if3.slave_if[4].wvalid  =   `DUT.bpf_qsfp0_slv_if.wvalid; 
assign BPF_if3.slave_if[4].wready  =   `DUT.bpf_qsfp0_slv_if.wready; 
assign BPF_if3.slave_if[4].bresp   =   `DUT.bpf_qsfp0_slv_if.bresp ; 
assign BPF_if3.slave_if[4].bvalid  =   `DUT.bpf_qsfp0_slv_if.bvalid; 
assign BPF_if3.slave_if[4].bready  =   `DUT.bpf_qsfp0_slv_if.bready; 
assign BPF_if3.slave_if[4].araddr  =   `DUT.bpf_qsfp0_slv_if.araddr; 
assign BPF_if3.slave_if[4].arprot  =   `DUT.bpf_qsfp0_slv_if.arprot; 
assign BPF_if3.slave_if[4].arvalid =   `DUT.bpf_qsfp0_slv_if.arvalid;
assign BPF_if3.slave_if[4].arready =   `DUT.bpf_qsfp0_slv_if.arready;
assign BPF_if3.slave_if[4].rdata   =   `DUT.bpf_qsfp0_slv_if.rdata ; 
assign BPF_if3.slave_if[4].rresp   =   `DUT.bpf_qsfp0_slv_if.rresp ; 
assign BPF_if3.slave_if[4].rvalid  =   `DUT.bpf_qsfp0_slv_if.rvalid; 
assign BPF_if3.slave_if[4].rready  =   `DUT.bpf_qsfp0_slv_if.rready;


/////////////////////////////////////BPF2QSFP1_PASIVE_CONNECTION///////////////////////////////////
assign BPF_if3.slave_if[5].awaddr  =   `DUT.bpf_qsfp1_slv_if.awaddr; 
assign BPF_if3.slave_if[5].awprot  =   `DUT.bpf_qsfp1_slv_if.awprot;                            
assign BPF_if3.slave_if[5].awvalid =   `DUT.bpf_qsfp1_slv_if.awvalid;
assign BPF_if3.slave_if[5].awready =   `DUT.bpf_qsfp1_slv_if.awready;
assign BPF_if3.slave_if[5].wdata   =   `DUT.bpf_qsfp1_slv_if.wdata ; 
assign BPF_if3.slave_if[5].wstrb   =   `DUT.bpf_qsfp1_slv_if.wstrb ; 
assign BPF_if3.slave_if[5].wvalid  =   `DUT.bpf_qsfp1_slv_if.wvalid; 
assign BPF_if3.slave_if[5].wready  =   `DUT.bpf_qsfp1_slv_if.wready; 
assign BPF_if3.slave_if[5].bresp   =   `DUT.bpf_qsfp1_slv_if.bresp ; 
assign BPF_if3.slave_if[5].bvalid  =   `DUT.bpf_qsfp1_slv_if.bvalid; 
assign BPF_if3.slave_if[5].bready  =   `DUT.bpf_qsfp1_slv_if.bready; 
assign BPF_if3.slave_if[5].araddr  =   `DUT.bpf_qsfp1_slv_if.araddr; 
assign BPF_if3.slave_if[5].arprot  =   `DUT.bpf_qsfp1_slv_if.arprot; 
assign BPF_if3.slave_if[5].arvalid =   `DUT.bpf_qsfp1_slv_if.arvalid;
assign BPF_if3.slave_if[5].arready =   `DUT.bpf_qsfp1_slv_if.arready;
assign BPF_if3.slave_if[5].rdata   =   `DUT.bpf_qsfp1_slv_if.rdata ; 
assign BPF_if3.slave_if[5].rresp   =   `DUT.bpf_qsfp1_slv_if.rresp ; 
assign BPF_if3.slave_if[5].rvalid  =   `DUT.bpf_qsfp1_slv_if.rvalid; 
assign BPF_if3.slave_if[5].rready  =   `DUT.bpf_qsfp1_slv_if.rready;

//////////////////////////////////////HE_HSSI2HSSI REMAINING PORT//////////////

`ifdef FIM_B
assign HE_HSSI2HSSI_if2.slave_if[1].tvalid           =`AFU_TOP.hssi_ss_st_tx_cpri[1].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[1].tlast            =`AFU_TOP.hssi_ss_st_tx_cpri[1].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[1].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[1].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[1].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx_cpri[1].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[1].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[1].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[1].tready           =`AFU_TOP.hssi_ss_st_tx_cpri[1].tready;
`endif
assign HE_HSSI2HSSI_if2.slave_if[1].tvalid           =`AFU_TOP.hssi_ss_st_tx[1].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[1].tlast            =`AFU_TOP.hssi_ss_st_tx[1].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[1].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx[1].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[1].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx[1].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[1].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx[1].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[1].tready           =`AFU_TOP.hssi_ss_st_tx[1].tready;

  
assign HE_HSSI2HSSI_if2.master_if[1].tvalid          =`AFU_TOP.hssi_ss_st_rx[1].rx.tvalid;
assign HE_HSSI2HSSI_if2.master_if[1].tlast           =`AFU_TOP.hssi_ss_st_rx[1].rx.tlast;
assign HE_HSSI2HSSI_if2.master_if[1].tuser           =`AFU_TOP.hssi_ss_st_rx[1].rx.tuser[11:0];
assign HE_HSSI2HSSI_if2.master_if[1].tdata[63:0]     =`AFU_TOP.hssi_ss_st_rx[1].rx.tdata[63:0];
assign HE_HSSI2HSSI_if2.master_if[1].tkeep[7:0]      =`AFU_TOP.hssi_ss_st_rx[1].rx.tkeep[7:0];
 assign HE_HSSI2HSSI_if2.slave_if[1].tdest             = 4'b0000;
 assign HE_HSSI2HSSI_if2.slave_if[1].tstrb             ='b0;
 assign HE_HSSI2HSSI_if2.slave_if[1].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[1].tdest             = 4'b0000;
assign HE_HSSI2HSSI_if2.master_if[1].tstrb             ='b0;
assign HE_HSSI2HSSI_if2.master_if[1].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[1].tready            =1'b1; 

`ifdef FIM_B
assign HE_HSSI2HSSI_if2.slave_if[2].tvalid           =`AFU_TOP.hssi_ss_st_tx_cpri[2].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[2].tlast            =`AFU_TOP.hssi_ss_st_tx_cpri[2].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[2].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[2].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[2].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx_cpri[2].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[2].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[2].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[2].tready           =`AFU_TOP.hssi_ss_st_tx_cpri[2].tready;
`endif
assign HE_HSSI2HSSI_if2.slave_if[2].tvalid           =`AFU_TOP.hssi_ss_st_tx[2].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[2].tlast            =`AFU_TOP.hssi_ss_st_tx[2].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[2].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx[2].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[2].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx[2].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[2].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx[2].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[2].tready           =`AFU_TOP.hssi_ss_st_tx[2].tready;

  
assign HE_HSSI2HSSI_if2.master_if[2].tvalid          =`AFU_TOP.hssi_ss_st_rx[2].rx.tvalid;
assign HE_HSSI2HSSI_if2.master_if[2].tlast           =`AFU_TOP.hssi_ss_st_rx[2].rx.tlast;
assign HE_HSSI2HSSI_if2.master_if[2].tuser           =`AFU_TOP.hssi_ss_st_rx[2].rx.tuser[11:0];
assign HE_HSSI2HSSI_if2.master_if[2].tdata[63:0]     =`AFU_TOP.hssi_ss_st_rx[2].rx.tdata[63:0];
assign HE_HSSI2HSSI_if2.master_if[2].tkeep[7:0]      =`AFU_TOP.hssi_ss_st_rx[2].rx.tkeep[7:0];
 assign HE_HSSI2HSSI_if2.slave_if[2].tdest           = 4'b0000;
 assign HE_HSSI2HSSI_if2.slave_if[2].tstrb           ='b0;
 assign HE_HSSI2HSSI_if2.slave_if[2].tid             =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[2].tdest           = 4'b0000;
assign HE_HSSI2HSSI_if2.master_if[2].tstrb           ='b0;
assign HE_HSSI2HSSI_if2.master_if[2].tid             =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[2].tready          = 1'b1;
`ifdef FIM_B
assign HE_HSSI2HSSI_if2.slave_if[3].tvalid           =`AFU_TOP.hssi_ss_st_tx_cpri[3].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[3].tlast            =`AFU_TOP.hssi_ss_st_tx_cpri[3].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[3].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[3].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[3].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx_cpri[3].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[3].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[3].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[3].tready           =`AFU_TOP.hssi_ss_st_tx_cpri[3].tready;
`endif
assign HE_HSSI2HSSI_if2.slave_if[3].tvalid           =`AFU_TOP.hssi_ss_st_tx[3].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[3].tlast            =`AFU_TOP.hssi_ss_st_tx[3].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[3].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx[3].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[3].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx[3].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[3].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx[3].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[3].tready           =`AFU_TOP.hssi_ss_st_tx[3].tready;


assign HE_HSSI2HSSI_if2.master_if[3].tvalid          =`AFU_TOP.hssi_ss_st_rx[3].rx.tvalid;
assign HE_HSSI2HSSI_if2.master_if[3].tlast           =`AFU_TOP.hssi_ss_st_rx[3].rx.tlast;
assign HE_HSSI2HSSI_if2.master_if[3].tuser           =`AFU_TOP.hssi_ss_st_rx[3].rx.tuser[11:0];
assign HE_HSSI2HSSI_if2.master_if[3].tdata[63:0]     =`AFU_TOP.hssi_ss_st_rx[3].rx.tdata[63:0];
assign HE_HSSI2HSSI_if2.master_if[3].tkeep[7:0]      =`AFU_TOP.hssi_ss_st_rx[3].rx.tkeep[7:0];
 assign HE_HSSI2HSSI_if2.slave_if[3].tdest           = 4'b0000;
 assign HE_HSSI2HSSI_if2.slave_if[3].tstrb           ='b0;
 assign HE_HSSI2HSSI_if2.slave_if[3].tid             =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[3].tdest           = 4'b0000;
assign HE_HSSI2HSSI_if2.master_if[3].tstrb           ='b0;
assign HE_HSSI2HSSI_if2.master_if[3].tid             =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[3].tready          = 1'b1;
`ifdef FIM_B
assign HE_HSSI2HSSI_if2.slave_if[4].tvalid           =`AFU_TOP.hssi_ss_st_tx_cpri[4].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[4].tlast            =`AFU_TOP.hssi_ss_st_tx_cpri[4].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[4].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[4].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[4].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx_cpri[4].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[4].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[4].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[4].tready           =`AFU_TOP.hssi_ss_st_tx_cpri[4].tready;
`endif
assign HE_HSSI2HSSI_if2.slave_if[4].tvalid           =`AFU_TOP.hssi_ss_st_tx[4].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[4].tlast            =`AFU_TOP.hssi_ss_st_tx[4].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[4].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx[4].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[4].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx[4].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[4].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx[4].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[4].tready           =`AFU_TOP.hssi_ss_st_tx[4].tready;


assign HE_HSSI2HSSI_if2.master_if[4].tvalid          =`AFU_TOP.hssi_ss_st_rx[4].rx.tvalid;
assign HE_HSSI2HSSI_if2.master_if[4].tlast           =`AFU_TOP.hssi_ss_st_rx[4].rx.tlast;
assign HE_HSSI2HSSI_if2.master_if[4].tuser           =`AFU_TOP.hssi_ss_st_rx[4].rx.tuser[11:0];
assign HE_HSSI2HSSI_if2.master_if[4].tdata[63:0]     =`AFU_TOP.hssi_ss_st_rx[4].rx.tdata[63:0];
assign HE_HSSI2HSSI_if2.master_if[4].tkeep[7:0]      =`AFU_TOP.hssi_ss_st_rx[4].rx.tkeep[7:0];
 assign HE_HSSI2HSSI_if2.slave_if[4].tdest            = 4'b0000;
 assign HE_HSSI2HSSI_if2.slave_if[4].tstrb            ='b0;
 assign HE_HSSI2HSSI_if2.slave_if[4].tid              =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[4].tdest            = 4'b0000;
assign HE_HSSI2HSSI_if2.master_if[4].tstrb            ='b0;
assign HE_HSSI2HSSI_if2.master_if[4].tid              =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[4].tready           = 1'b1;
`ifdef FIM_B
assign HE_HSSI2HSSI_if2.slave_if[5].tvalid           =`AFU_TOP.hssi_ss_st_tx_cpri[5].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[5].tlast            =`AFU_TOP.hssi_ss_st_tx_cpri[5].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[5].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[5].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[5].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx_cpri[5].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[5].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx_cpri[5].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[5].tready           =`AFU_TOP.hssi_ss_st_tx_cpri[5].tready;
`endif
assign HE_HSSI2HSSI_if2.slave_if[5].tvalid           =`AFU_TOP.hssi_ss_st_tx[5].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[5].tlast            =`AFU_TOP.hssi_ss_st_tx[5].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[5].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx[5].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[5].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx[5].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[5].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx[5].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[5].tready           =`AFU_TOP.hssi_ss_st_tx[5].tready;


assign HE_HSSI2HSSI_if2.master_if[5].tvalid          =`AFU_TOP.hssi_ss_st_rx[5].rx.tvalid;
assign HE_HSSI2HSSI_if2.master_if[5].tlast           =`AFU_TOP.hssi_ss_st_rx[5].rx.tlast;
assign HE_HSSI2HSSI_if2.master_if[5].tuser           =`AFU_TOP.hssi_ss_st_rx[5].rx.tuser[11:0];
assign HE_HSSI2HSSI_if2.master_if[5].tdata[63:0]     =`AFU_TOP.hssi_ss_st_rx[5].rx.tdata[63:0];

assign HE_HSSI2HSSI_if2.master_if[5].tkeep[7:0]      =`AFU_TOP.hssi_ss_st_rx[5].rx.tkeep[7:0];
 assign HE_HSSI2HSSI_if2.slave_if[5].tdest             = 4'b0000;
 assign HE_HSSI2HSSI_if2.slave_if[5].tstrb             ='b0;
 assign HE_HSSI2HSSI_if2.slave_if[5].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[5].tdest             = 4'b0000;
assign HE_HSSI2HSSI_if2.master_if[5].tstrb             ='b0;
assign HE_HSSI2HSSI_if2.master_if[5].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[5].tready            =1'b1;

assign HE_HSSI2HSSI_if2.slave_if[6].tvalid            =`AFU_TOP.hssi_ss_st_tx[6].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[6].tlast             =`AFU_TOP.hssi_ss_st_tx[6].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[6].tuser[1:0]        =`AFU_TOP.hssi_ss_st_tx[6].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[6].tdata[63:0]       =`AFU_TOP.hssi_ss_st_tx[6].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[6].tkeep[7:0]        =`AFU_TOP.hssi_ss_st_tx[6].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[6].tready            =`AFU_TOP.hssi_ss_st_tx[6].tready;

assign HE_HSSI2HSSI_if2.master_if[6].tvalid           =`AFU_TOP.hssi_ss_st_rx[6].rx.tvalid;
assign HE_HSSI2HSSI_if2.master_if[6].tlast            =`AFU_TOP.hssi_ss_st_rx[6].rx.tlast;
assign HE_HSSI2HSSI_if2.master_if[6].tuser            =`AFU_TOP.hssi_ss_st_rx[6].rx.tuser[11:0];
assign HE_HSSI2HSSI_if2.master_if[6].tdata[63:0]      =`AFU_TOP.hssi_ss_st_rx[6].rx.tdata[63:0];
assign HE_HSSI2HSSI_if2.master_if[6].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_rx[6].rx.tkeep[7:0];
 assign HE_HSSI2HSSI_if2.slave_if[6].tdest             = 4'b0000;
 assign HE_HSSI2HSSI_if2.slave_if[6].tstrb             ='b0;
 assign HE_HSSI2HSSI_if2.slave_if[6].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[6].tdest             = 4'b0000;
assign HE_HSSI2HSSI_if2.master_if[6].tstrb             ='b0;
assign HE_HSSI2HSSI_if2.master_if[6].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[6].tready            =1'b1;

assign HE_HSSI2HSSI_if2.slave_if[7].tvalid           =`AFU_TOP.hssi_ss_st_tx[7].tx.tvalid;
assign HE_HSSI2HSSI_if2.slave_if[7].tlast            =`AFU_TOP.hssi_ss_st_tx[7].tx.tlast;
assign HE_HSSI2HSSI_if2.slave_if[7].tuser[1:0]       =`AFU_TOP.hssi_ss_st_tx[7].tx.tuser[1:0];
assign HE_HSSI2HSSI_if2.slave_if[7].tdata[63:0]      =`AFU_TOP.hssi_ss_st_tx[7].tx.tdata[63:0];
assign HE_HSSI2HSSI_if2.slave_if[7].tkeep[7:0]       =`AFU_TOP.hssi_ss_st_tx[7].tx.tkeep[7:0];
assign HE_HSSI2HSSI_if2.slave_if[7].tready           =`AFU_TOP.hssi_ss_st_tx[7].tready;

assign HE_HSSI2HSSI_if2.master_if[7].tvalid          =`AFU_TOP.hssi_ss_st_rx[7].rx.tvalid;
assign HE_HSSI2HSSI_if2.master_if[7].tlast           =`AFU_TOP.hssi_ss_st_rx[7].rx.tlast;
assign HE_HSSI2HSSI_if2.master_if[7].tuser           =`AFU_TOP.hssi_ss_st_rx[7].rx.tuser[11:0];
assign HE_HSSI2HSSI_if2.master_if[7].tdata[63:0]     =`AFU_TOP.hssi_ss_st_rx[7].rx.tdata[63:0];
assign HE_HSSI2HSSI_if2.master_if[7].tkeep[7:0]      =`AFU_TOP.hssi_ss_st_rx[7].rx.tkeep[7:0];
 assign HE_HSSI2HSSI_if2.slave_if[7].tdest             = 4'b0000;
 assign HE_HSSI2HSSI_if2.slave_if[7].tstrb             ='b0;
 assign HE_HSSI2HSSI_if2.slave_if[7].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[7].tdest             = 4'b0000;
assign HE_HSSI2HSSI_if2.master_if[7].tstrb             ='b0;
assign HE_HSSI2HSSI_if2.master_if[7].tid               =8'b0000_0000;
assign HE_HSSI2HSSI_if2.master_if[7].tready            = 1'b1;
//8 bit tkeep is used ,remaining tied to 0
assign HE_HSSI2HSSI_if2.master_if[0].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[1].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[2].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[3].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[4].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[5].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[6].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[7].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[8].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[9].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[10].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[11].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[12].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[13].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[14].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.master_if[15].tkeep[15:8] ='b0;

assign HE_HSSI2HSSI_if2.slave_if[0].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[1].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[2].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[3].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[4].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[5].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[6].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[7].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[8].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[9].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[10].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[11].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[12].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[13].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[14].tkeep[15:8] ='b0;
assign HE_HSSI2HSSI_if2.slave_if[15].tkeep[15:8] ='b0;
//2 bit field of client is monitored remaing tied to 0 to avoid x prop 
assign HE_HSSI2HSSI_if2.slave_if[0].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[1].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[2].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[3].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[4].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[5].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[6].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[7].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[8].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[9].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[10].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[11].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[12].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[13].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[14].tuser[7:2]='b0;
assign HE_HSSI2HSSI_if2.slave_if[15].tuser[7:2]='b0;

endmodule 
