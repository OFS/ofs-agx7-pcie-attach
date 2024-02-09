// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

  `define PG_AXIL2MMIO tb_top.DUT.afu_top.pg_afu.port_gasket.axi_lite2mmio
  
  module pg_axil2mmio_bind(`AXI_IF axi_if);
  
  
    assign axi_if.common_aclk = `PG_AXIL2MMIO.clk;
  
  ////////////// ST2MM CSR AXI Lite Interface //////////////////////////////
  
  assign axi_if.master_if[0].aresetn =  `PG_AXIL2MMIO.rst_n;
  assign axi_if.master_if[0].awaddr  =  `PG_AXIL2MMIO.lite_if.awaddr;
  assign axi_if.master_if[0].awprot  =  `PG_AXIL2MMIO.lite_if.awprot;
  assign axi_if.master_if[0].awvalid =  `PG_AXIL2MMIO.lite_if.awvalid;
  assign axi_if.master_if[0].awready =  `PG_AXIL2MMIO.lite_if.awready;
  assign axi_if.master_if[0].wdata   =  `PG_AXIL2MMIO.lite_if.wdata;
  assign axi_if.master_if[0].wstrb   =  `PG_AXIL2MMIO.lite_if.wstrb;
  assign axi_if.master_if[0].wvalid  =  `PG_AXIL2MMIO.lite_if.wvalid; 
  assign axi_if.master_if[0].wready  =  `PG_AXIL2MMIO.lite_if.wready; 
  assign axi_if.master_if[0].bresp   =  `PG_AXIL2MMIO.lite_if.bresp; 
  assign axi_if.master_if[0].bvalid  =  `PG_AXIL2MMIO.lite_if.bvalid;
  assign axi_if.master_if[0].bready  =  `PG_AXIL2MMIO.lite_if.bready;
  assign axi_if.master_if[0].araddr  =  `PG_AXIL2MMIO.lite_if.araddr;
  assign axi_if.master_if[0].arprot  =  `PG_AXIL2MMIO.lite_if.arprot;
  assign axi_if.master_if[0].arvalid =  `PG_AXIL2MMIO.lite_if.arvalid;
  assign axi_if.master_if[0].arready =  `PG_AXIL2MMIO.lite_if.arready;
  assign axi_if.master_if[0].rdata   =  `PG_AXIL2MMIO.lite_if.rdata;
  assign axi_if.master_if[0].rresp   =  `PG_AXIL2MMIO.lite_if.rresp;
  assign axi_if.master_if[0].rvalid  =  `PG_AXIL2MMIO.lite_if.rvalid;
  assign axi_if.master_if[0].rready  =  `PG_AXIL2MMIO.lite_if.rready;
  
  assign axi_if.slave_if[0].aresetn =   `PG_AXIL2MMIO.rst_n;
  assign axi_if.slave_if[0].awaddr  =   `PG_AXIL2MMIO.lite_if.awaddr;                                    
  assign axi_if.slave_if[0].awprot  =   `PG_AXIL2MMIO.lite_if.awprot;
  assign axi_if.slave_if[0].awvalid =   `PG_AXIL2MMIO.lite_if.awvalid;
  assign axi_if.slave_if[0].awready =   `PG_AXIL2MMIO.lite_if.awready;
  assign axi_if.slave_if[0].wdata   =   `PG_AXIL2MMIO.lite_if.wdata;
  assign axi_if.slave_if[0].wstrb   =   `PG_AXIL2MMIO.lite_if.wstrb;
  assign axi_if.slave_if[0].wvalid  =   `PG_AXIL2MMIO.lite_if.wvalid; 
  assign axi_if.slave_if[0].wready  =   `PG_AXIL2MMIO.lite_if.wready; 
  assign axi_if.slave_if[0].bresp   =   `PG_AXIL2MMIO.lite_if.bresp;
  assign axi_if.slave_if[0].bvalid  =   `PG_AXIL2MMIO.lite_if.bvalid;
  assign axi_if.slave_if[0].bready  =   `PG_AXIL2MMIO.lite_if.bready ;
  assign axi_if.slave_if[0].araddr  =   `PG_AXIL2MMIO.lite_if.araddr; 
  assign axi_if.slave_if[0].arprot  =   `PG_AXIL2MMIO.lite_if.arprot;
  assign axi_if.slave_if[0].arvalid =   `PG_AXIL2MMIO.lite_if.arvalid;
  assign axi_if.slave_if[0].arready =   `PG_AXIL2MMIO.lite_if.arready ;
  assign axi_if.slave_if[0].rdata   =   `PG_AXIL2MMIO.lite_if.rdata;
  assign axi_if.slave_if[0].rresp   =   `PG_AXIL2MMIO.lite_if.rresp;
  assign axi_if.slave_if[0].rvalid  =   `PG_AXIL2MMIO.lite_if.rvalid;
  assign axi_if.slave_if[0].rready  =   `PG_AXIL2MMIO.lite_if.rready;
  
  ////////////// ST2MM CSR MMIO Interface //////////////////////////////
  assign axi_if.master_if[1].aresetn =  `PG_AXIL2MMIO.mmio_if.rst_n;
  assign axi_if.master_if[1].awaddr  =  `PG_AXIL2MMIO.mmio_if.awaddr;
  assign axi_if.master_if[1].awprot  =  `PG_AXIL2MMIO.mmio_if.awprot;
  assign axi_if.master_if[1].awvalid =  `PG_AXIL2MMIO.mmio_if.awvalid;
  assign axi_if.master_if[1].awready =  `PG_AXIL2MMIO.mmio_if.awready;
  assign axi_if.master_if[1].awid    =  `PG_AXIL2MMIO.mmio_if.awid   ;
  assign axi_if.master_if[1].awlen   =  `PG_AXIL2MMIO.mmio_if.awlen  ;
  assign axi_if.master_if[1].awsize  =  `PG_AXIL2MMIO.mmio_if.awsize ;
  assign axi_if.master_if[1].awburst =  `PG_AXIL2MMIO.mmio_if.awburst;
//assign axi_if.master_if[1].awlock  =  `PG_AXIL2MMIO.mmio_if.awlock ;
  assign axi_if.master_if[1].awcache =  `PG_AXIL2MMIO.mmio_if.awcache;
  assign axi_if.master_if[1].awqos   =  `PG_AXIL2MMIO.mmio_if.awqos  ;
//assign axi_if.master_if[1].awuser  =  `PG_AXIL2MMIO.mmio_if.awuser ;
  assign axi_if.master_if[1].wdata   =  `PG_AXIL2MMIO.mmio_if.wdata;
  assign axi_if.master_if[1].wstrb   =  `PG_AXIL2MMIO.mmio_if.wstrb;
  assign axi_if.master_if[1].wvalid  =  `PG_AXIL2MMIO.mmio_if.wvalid; 
  assign axi_if.master_if[1].wready  =  `PG_AXIL2MMIO.mmio_if.wready; 
  assign axi_if.master_if[1].wlast   =  `PG_AXIL2MMIO.mmio_if.wlast;
//assign axi_if.master_if[1].wuser   =  `PG_AXIL2MMIO.mmio_if.wuser;
  assign axi_if.master_if[1].bresp   =  `PG_AXIL2MMIO.mmio_if.bresp; 
  assign axi_if.master_if[1].bvalid  =  `PG_AXIL2MMIO.mmio_if.bvalid;
  assign axi_if.master_if[1].bready  =  `PG_AXIL2MMIO.mmio_if.bready;
  assign axi_if.master_if[1].bid     =  `PG_AXIL2MMIO.mmio_if.bid;
//assign axi_if.master_if[1].buser   =  `PG_AXIL2MMIO.mmio_if.buser;
  assign axi_if.master_if[1].araddr  =  `PG_AXIL2MMIO.mmio_if.araddr;
  assign axi_if.master_if[1].arprot  =  `PG_AXIL2MMIO.mmio_if.arprot;
  assign axi_if.master_if[1].arvalid =  `PG_AXIL2MMIO.mmio_if.arvalid;
  assign axi_if.master_if[1].arready =  `PG_AXIL2MMIO.mmio_if.arready;
  assign axi_if.master_if[1].arid    =  `PG_AXIL2MMIO.mmio_if.arid   ;
  assign axi_if.master_if[1].arlen   =  `PG_AXIL2MMIO.mmio_if.arlen  ;
  assign axi_if.master_if[1].arsize  =  `PG_AXIL2MMIO.mmio_if.arsize ;
  assign axi_if.master_if[1].arburst =  `PG_AXIL2MMIO.mmio_if.arburst;
//assign axi_if.master_if[1].arlock  =  `PG_AXIL2MMIO.mmio_if.arlock ;
  assign axi_if.master_if[1].arcache =  `PG_AXIL2MMIO.mmio_if.arcache;
  assign axi_if.master_if[1].arqos   =  `PG_AXIL2MMIO.mmio_if.arqos  ;
//assign axi_if.master_if[1].aruser  =  `PG_AXIL2MMIO.mmio_if.aruser ;
  assign axi_if.master_if[1].rdata   =  `PG_AXIL2MMIO.mmio_if.rdata;
  assign axi_if.master_if[1].rresp   =  `PG_AXIL2MMIO.mmio_if.rresp;
  assign axi_if.master_if[1].rvalid  =  `PG_AXIL2MMIO.mmio_if.rvalid;
  assign axi_if.master_if[1].rready  =  `PG_AXIL2MMIO.mmio_if.rready;
  assign axi_if.master_if[1].rid     =  `PG_AXIL2MMIO.mmio_if.rid;
  assign axi_if.master_if[1].rlast   =  `PG_AXIL2MMIO.mmio_if.rlast;
//assign axi_if.master_if[1].ruser   =  `PG_AXIL2MMIO.mmio_if.ruser;
  
  assign axi_if.slave_if[1].aresetn =  `PG_AXIL2MMIO.mmio_if.rst_n;
  assign axi_if.slave_if[1].awaddr  =  `PG_AXIL2MMIO.mmio_if.awaddr;
  assign axi_if.slave_if[1].awprot  =  `PG_AXIL2MMIO.mmio_if.awprot;
  assign axi_if.slave_if[1].awvalid =  `PG_AXIL2MMIO.mmio_if.awvalid;
  assign axi_if.slave_if[1].awready =  `PG_AXIL2MMIO.mmio_if.awready;
  assign axi_if.slave_if[1].awid    =  `PG_AXIL2MMIO.mmio_if.awid   ;
  assign axi_if.slave_if[1].awlen   =  `PG_AXIL2MMIO.mmio_if.awlen  ;
  assign axi_if.slave_if[1].awsize  =  `PG_AXIL2MMIO.mmio_if.awsize ;
  assign axi_if.slave_if[1].awburst =  `PG_AXIL2MMIO.mmio_if.awburst;
//assign axi_if.slave_if[1].awlock  =  `PG_AXIL2MMIO.mmio_if.awlock ;
  assign axi_if.slave_if[1].awcache =  `PG_AXIL2MMIO.mmio_if.awcache;
  assign axi_if.slave_if[1].awqos   =  `PG_AXIL2MMIO.mmio_if.awqos  ;
//assign axi_if.slave_if[1].awuser  =  `PG_AXIL2MMIO.mmio_if.awuser ;
  assign axi_if.slave_if[1].wdata   =  `PG_AXIL2MMIO.mmio_if.wdata;
  assign axi_if.slave_if[1].wstrb   =  `PG_AXIL2MMIO.mmio_if.wstrb;
  assign axi_if.slave_if[1].wvalid  =  `PG_AXIL2MMIO.mmio_if.wvalid; 
  assign axi_if.slave_if[1].wready  =  `PG_AXIL2MMIO.mmio_if.wready; 
  assign axi_if.slave_if[1].wlast   =  `PG_AXIL2MMIO.mmio_if.wlast;
//assign axi_if.slave_if[1].wuser   =  `PG_AXIL2MMIO.mmio_if.wuser;
  assign axi_if.slave_if[1].bresp   =  `PG_AXIL2MMIO.mmio_if.bresp; 
  assign axi_if.slave_if[1].bvalid  =  `PG_AXIL2MMIO.mmio_if.bvalid;
  assign axi_if.slave_if[1].bready  =  `PG_AXIL2MMIO.mmio_if.bready;
  assign axi_if.slave_if[1].bid     =  `PG_AXIL2MMIO.mmio_if.bid;
//assign axi_if.slave_if[1].buser   =  `PG_AXIL2MMIO.mmio_if.buser;
  assign axi_if.slave_if[1].araddr  =  `PG_AXIL2MMIO.mmio_if.araddr;
  assign axi_if.slave_if[1].arprot  =  `PG_AXIL2MMIO.mmio_if.arprot;
  assign axi_if.slave_if[1].arvalid =  `PG_AXIL2MMIO.mmio_if.arvalid;
  assign axi_if.slave_if[1].arready =  `PG_AXIL2MMIO.mmio_if.arready;
  assign axi_if.slave_if[1].arid    =  `PG_AXIL2MMIO.mmio_if.arid   ;
  assign axi_if.slave_if[1].arlen   =  `PG_AXIL2MMIO.mmio_if.arlen  ;
  assign axi_if.slave_if[1].arsize  =  `PG_AXIL2MMIO.mmio_if.arsize ;
  assign axi_if.slave_if[1].arburst =  `PG_AXIL2MMIO.mmio_if.arburst;
//assign axi_if.slave_if[1].arlock  =  `PG_AXIL2MMIO.mmio_if.arlock ;
  assign axi_if.slave_if[1].arcache =  `PG_AXIL2MMIO.mmio_if.arcache;
  assign axi_if.slave_if[1].arqos   =  `PG_AXIL2MMIO.mmio_if.arqos  ;
//assign axi_if.slave_if[1].aruser  =  `PG_AXIL2MMIO.mmio_if.aruser ;
  assign axi_if.slave_if[1].rdata   =  `PG_AXIL2MMIO.mmio_if.rdata;
  assign axi_if.slave_if[1].rresp   =  `PG_AXIL2MMIO.mmio_if.rresp;
  assign axi_if.slave_if[1].rvalid  =  `PG_AXIL2MMIO.mmio_if.rvalid;
  assign axi_if.slave_if[1].rready  =  `PG_AXIL2MMIO.mmio_if.rready;
  assign axi_if.slave_if[1].rid     =  `PG_AXIL2MMIO.mmio_if.rid;
  assign axi_if.slave_if[1].rlast   =  `PG_AXIL2MMIO.mmio_if.rlast;
//assign axi_if.slave_if[1].ruser   =  `PG_AXIL2MMIO.mmio_if.ruser;
  
  endmodule : pg_axil2mmio_bind
