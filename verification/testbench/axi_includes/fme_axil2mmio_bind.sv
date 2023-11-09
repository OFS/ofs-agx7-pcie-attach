// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

  `define FME_AXIL2MMIO tb_top.DUT.fme_top.axi_lite2mmio
  
  module fme_axil2mmio_bind(`AXI_IF axi_if);
  
  
    assign axi_if.common_aclk = `FME_AXIL2MMIO.clk;
  
  ////////////// ST2MM CSR AXI Lite Interface //////////////////////////////
  
  assign axi_if.master_if[0].aresetn =  `FME_AXIL2MMIO.rst_n;
  assign axi_if.master_if[0].awaddr  =  `FME_AXIL2MMIO.lite_if.awaddr;
  assign axi_if.master_if[0].awprot  =  `FME_AXIL2MMIO.lite_if.awprot;
  assign axi_if.master_if[0].awvalid =  `FME_AXIL2MMIO.lite_if.awvalid;
  assign axi_if.master_if[0].awready =  `FME_AXIL2MMIO.lite_if.awready;
  assign axi_if.master_if[0].wdata   =  `FME_AXIL2MMIO.lite_if.wdata;
  assign axi_if.master_if[0].wstrb   =  `FME_AXIL2MMIO.lite_if.wstrb;
  assign axi_if.master_if[0].wvalid  =  `FME_AXIL2MMIO.lite_if.wvalid; 
  assign axi_if.master_if[0].wready  =  `FME_AXIL2MMIO.lite_if.wready; 
  assign axi_if.master_if[0].bresp   =  `FME_AXIL2MMIO.lite_if.bresp; 
  assign axi_if.master_if[0].bvalid  =  `FME_AXIL2MMIO.lite_if.bvalid;
  assign axi_if.master_if[0].bready  =  `FME_AXIL2MMIO.lite_if.bready;
  assign axi_if.master_if[0].araddr  =  `FME_AXIL2MMIO.lite_if.araddr;
  assign axi_if.master_if[0].arprot  =  `FME_AXIL2MMIO.lite_if.arprot;
  assign axi_if.master_if[0].arvalid =  `FME_AXIL2MMIO.lite_if.arvalid;
  assign axi_if.master_if[0].arready =  `FME_AXIL2MMIO.lite_if.arready;
  assign axi_if.master_if[0].rdata   =  `FME_AXIL2MMIO.lite_if.rdata;
  assign axi_if.master_if[0].rresp   =  `FME_AXIL2MMIO.lite_if.rresp;
  assign axi_if.master_if[0].rvalid  =  `FME_AXIL2MMIO.lite_if.rvalid;
  assign axi_if.master_if[0].rready  =  `FME_AXIL2MMIO.lite_if.rready;
  
  assign axi_if.slave_if[0].aresetn =   `FME_AXIL2MMIO.rst_n;
  assign axi_if.slave_if[0].awaddr  =   `FME_AXIL2MMIO.lite_if.awaddr;                                    
  assign axi_if.slave_if[0].awprot  =   `FME_AXIL2MMIO.lite_if.awprot;
  assign axi_if.slave_if[0].awvalid =   `FME_AXIL2MMIO.lite_if.awvalid;
  assign axi_if.slave_if[0].awready =   `FME_AXIL2MMIO.lite_if.awready;
  assign axi_if.slave_if[0].wdata   =   `FME_AXIL2MMIO.lite_if.wdata;
  assign axi_if.slave_if[0].wstrb   =   `FME_AXIL2MMIO.lite_if.wstrb;
  assign axi_if.slave_if[0].wvalid  =   `FME_AXIL2MMIO.lite_if.wvalid; 
  assign axi_if.slave_if[0].wready  =   `FME_AXIL2MMIO.lite_if.wready; 
  assign axi_if.slave_if[0].bresp   =   `FME_AXIL2MMIO.lite_if.bresp;
  assign axi_if.slave_if[0].bvalid  =   `FME_AXIL2MMIO.lite_if.bvalid;
  assign axi_if.slave_if[0].bready  =   `FME_AXIL2MMIO.lite_if.bready ;
  assign axi_if.slave_if[0].araddr  =   `FME_AXIL2MMIO.lite_if.araddr; 
  assign axi_if.slave_if[0].arprot  =   `FME_AXIL2MMIO.lite_if.arprot;
  assign axi_if.slave_if[0].arvalid =   `FME_AXIL2MMIO.lite_if.arvalid;
  assign axi_if.slave_if[0].arready =   `FME_AXIL2MMIO.lite_if.arready ;
  assign axi_if.slave_if[0].rdata   =   `FME_AXIL2MMIO.lite_if.rdata;
  assign axi_if.slave_if[0].rresp   =   `FME_AXIL2MMIO.lite_if.rresp;
  assign axi_if.slave_if[0].rvalid  =   `FME_AXIL2MMIO.lite_if.rvalid;
  assign axi_if.slave_if[0].rready  =   `FME_AXIL2MMIO.lite_if.rready;
  
  ////////////// ST2MM CSR MMIO Interface //////////////////////////////
  assign axi_if.master_if[1].aresetn =  `FME_AXIL2MMIO.mmio_if.rst_n;
  assign axi_if.master_if[1].awaddr  =  `FME_AXIL2MMIO.mmio_if.awaddr;
  assign axi_if.master_if[1].awprot  =  `FME_AXIL2MMIO.mmio_if.awprot;
  assign axi_if.master_if[1].awvalid =  `FME_AXIL2MMIO.mmio_if.awvalid;
  assign axi_if.master_if[1].awready =  `FME_AXIL2MMIO.mmio_if.awready;
  assign axi_if.master_if[1].awid    =  `FME_AXIL2MMIO.mmio_if.awid   ;
  assign axi_if.master_if[1].awlen   =  `FME_AXIL2MMIO.mmio_if.awlen  ;
  assign axi_if.master_if[1].awsize  =  `FME_AXIL2MMIO.mmio_if.awsize ;
  assign axi_if.master_if[1].awburst =  `FME_AXIL2MMIO.mmio_if.awburst;
//assign axi_if.master_if[1].awlock  =  `FME_AXIL2MMIO.mmio_if.awlock ;
  assign axi_if.master_if[1].awcache =  `FME_AXIL2MMIO.mmio_if.awcache;
  assign axi_if.master_if[1].awqos   =  `FME_AXIL2MMIO.mmio_if.awqos  ;
//assign axi_if.master_if[1].awuser  =  `FME_AXIL2MMIO.mmio_if.awuser ;
  assign axi_if.master_if[1].wdata   =  `FME_AXIL2MMIO.mmio_if.wdata;
  assign axi_if.master_if[1].wstrb   =  `FME_AXIL2MMIO.mmio_if.wstrb;
  assign axi_if.master_if[1].wvalid  =  `FME_AXIL2MMIO.mmio_if.wvalid; 
  assign axi_if.master_if[1].wready  =  `FME_AXIL2MMIO.mmio_if.wready; 
  assign axi_if.master_if[1].wlast   =  `FME_AXIL2MMIO.mmio_if.wlast;
//assign axi_if.master_if[1].wuser   =  `FME_AXIL2MMIO.mmio_if.wuser;
  assign axi_if.master_if[1].bresp   =  `FME_AXIL2MMIO.mmio_if.bresp; 
  assign axi_if.master_if[1].bvalid  =  `FME_AXIL2MMIO.mmio_if.bvalid;
  assign axi_if.master_if[1].bready  =  `FME_AXIL2MMIO.mmio_if.bready;
  assign axi_if.master_if[1].bid     =  `FME_AXIL2MMIO.mmio_if.bid;
//assign axi_if.master_if[1].buser   =  `FME_AXIL2MMIO.mmio_if.buser;
  assign axi_if.master_if[1].araddr  =  `FME_AXIL2MMIO.mmio_if.araddr;
  assign axi_if.master_if[1].arprot  =  `FME_AXIL2MMIO.mmio_if.arprot;
  assign axi_if.master_if[1].arvalid =  `FME_AXIL2MMIO.mmio_if.arvalid;
  assign axi_if.master_if[1].arready =  `FME_AXIL2MMIO.mmio_if.arready;
  assign axi_if.master_if[1].arid    =  `FME_AXIL2MMIO.mmio_if.arid   ;
  assign axi_if.master_if[1].arlen   =  `FME_AXIL2MMIO.mmio_if.arlen  ;
  assign axi_if.master_if[1].arsize  =  `FME_AXIL2MMIO.mmio_if.arsize ;
  assign axi_if.master_if[1].arburst =  `FME_AXIL2MMIO.mmio_if.arburst;
//assign axi_if.master_if[1].arlock  =  `FME_AXIL2MMIO.mmio_if.arlock ;
  assign axi_if.master_if[1].arcache =  `FME_AXIL2MMIO.mmio_if.arcache;
  assign axi_if.master_if[1].arqos   =  `FME_AXIL2MMIO.mmio_if.arqos  ;
//assign axi_if.master_if[1].aruser  =  `FME_AXIL2MMIO.mmio_if.aruser ;
  assign axi_if.master_if[1].rdata   =  `FME_AXIL2MMIO.mmio_if.rdata;
  assign axi_if.master_if[1].rresp   =  `FME_AXIL2MMIO.mmio_if.rresp;
  assign axi_if.master_if[1].rvalid  =  `FME_AXIL2MMIO.mmio_if.rvalid;
  assign axi_if.master_if[1].rready  =  `FME_AXIL2MMIO.mmio_if.rready;
  assign axi_if.master_if[1].rid     =  `FME_AXIL2MMIO.mmio_if.rid;
  assign axi_if.master_if[1].rlast   =  `FME_AXIL2MMIO.mmio_if.rlast;
//assign axi_if.master_if[1].ruser   =  `FME_AXIL2MMIO.mmio_if.ruser;
  
  assign axi_if.slave_if[1].aresetn =  `FME_AXIL2MMIO.mmio_if.rst_n;
  assign axi_if.slave_if[1].awaddr  =  `FME_AXIL2MMIO.mmio_if.awaddr;
  assign axi_if.slave_if[1].awprot  =  `FME_AXIL2MMIO.mmio_if.awprot;
  assign axi_if.slave_if[1].awvalid =  `FME_AXIL2MMIO.mmio_if.awvalid;
  assign axi_if.slave_if[1].awready =  `FME_AXIL2MMIO.mmio_if.awready;
  assign axi_if.slave_if[1].awid    =  `FME_AXIL2MMIO.mmio_if.awid   ;
  assign axi_if.slave_if[1].awlen   =  `FME_AXIL2MMIO.mmio_if.awlen  ;
  assign axi_if.slave_if[1].awsize  =  `FME_AXIL2MMIO.mmio_if.awsize ;
  assign axi_if.slave_if[1].awburst =  `FME_AXIL2MMIO.mmio_if.awburst;
//assign axi_if.slave_if[1].awlock  =  `FME_AXIL2MMIO.mmio_if.awlock ;
  assign axi_if.slave_if[1].awcache =  `FME_AXIL2MMIO.mmio_if.awcache;
  assign axi_if.slave_if[1].awqos   =  `FME_AXIL2MMIO.mmio_if.awqos  ;
//assign axi_if.slave_if[1].awuser  =  `FME_AXIL2MMIO.mmio_if.awuser ;
  assign axi_if.slave_if[1].wdata   =  `FME_AXIL2MMIO.mmio_if.wdata;
  assign axi_if.slave_if[1].wstrb   =  `FME_AXIL2MMIO.mmio_if.wstrb;
  assign axi_if.slave_if[1].wvalid  =  `FME_AXIL2MMIO.mmio_if.wvalid; 
  assign axi_if.slave_if[1].wready  =  `FME_AXIL2MMIO.mmio_if.wready; 
  assign axi_if.slave_if[1].wlast   =  `FME_AXIL2MMIO.mmio_if.wlast;
//assign axi_if.slave_if[1].wuser   =  `FME_AXIL2MMIO.mmio_if.wuser;
  assign axi_if.slave_if[1].bresp   =  `FME_AXIL2MMIO.mmio_if.bresp; 
  assign axi_if.slave_if[1].bvalid  =  `FME_AXIL2MMIO.mmio_if.bvalid;
  assign axi_if.slave_if[1].bready  =  `FME_AXIL2MMIO.mmio_if.bready;
  assign axi_if.slave_if[1].bid     =  `FME_AXIL2MMIO.mmio_if.bid;
//assign axi_if.slave_if[1].buser   =  `FME_AXIL2MMIO.mmio_if.buser;
  assign axi_if.slave_if[1].araddr  =  `FME_AXIL2MMIO.mmio_if.araddr;
  assign axi_if.slave_if[1].arprot  =  `FME_AXIL2MMIO.mmio_if.arprot;
  assign axi_if.slave_if[1].arvalid =  `FME_AXIL2MMIO.mmio_if.arvalid;
  assign axi_if.slave_if[1].arready =  `FME_AXIL2MMIO.mmio_if.arready;
  assign axi_if.slave_if[1].arid    =  `FME_AXIL2MMIO.mmio_if.arid   ;
  assign axi_if.slave_if[1].arlen   =  `FME_AXIL2MMIO.mmio_if.arlen  ;
  assign axi_if.slave_if[1].arsize  =  `FME_AXIL2MMIO.mmio_if.arsize ;
  assign axi_if.slave_if[1].arburst =  `FME_AXIL2MMIO.mmio_if.arburst;
//assign axi_if.slave_if[1].arlock  =  `FME_AXIL2MMIO.mmio_if.arlock ;
  assign axi_if.slave_if[1].arcache =  `FME_AXIL2MMIO.mmio_if.arcache;
  assign axi_if.slave_if[1].arqos   =  `FME_AXIL2MMIO.mmio_if.arqos  ;
//assign axi_if.slave_if[1].aruser  =  `FME_AXIL2MMIO.mmio_if.aruser ;
  assign axi_if.slave_if[1].rdata   =  `FME_AXIL2MMIO.mmio_if.rdata;
  assign axi_if.slave_if[1].rresp   =  `FME_AXIL2MMIO.mmio_if.rresp;
  assign axi_if.slave_if[1].rvalid  =  `FME_AXIL2MMIO.mmio_if.rvalid;
  assign axi_if.slave_if[1].rready  =  `FME_AXIL2MMIO.mmio_if.rready;
  assign axi_if.slave_if[1].rid     =  `FME_AXIL2MMIO.mmio_if.rid;
  assign axi_if.slave_if[1].rlast   =  `FME_AXIL2MMIO.mmio_if.rlast;
//assign axi_if.slave_if[1].ruser   =  `FME_AXIL2MMIO.mmio_if.ruser;
  
  endmodule : fme_axil2mmio_bind
