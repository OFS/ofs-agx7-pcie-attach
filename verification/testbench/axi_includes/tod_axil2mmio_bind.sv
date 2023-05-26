// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifdef INCLUDE_TOD
  `define TOD_AXIL2MMIO tb_top.DUT.afu_top.tod_top_inst.axi_lite2mmio
  
  module tod_axil2mmio_bind(`AXI_IF axi_if);
  
  
    assign axi_if.common_aclk = `TOD_AXIL2MMIO.clk;
  
  ////////////// ST2MM CSR AXI Lite Interface //////////////////////////////
  
  assign axi_if.master_if[0].aresetn =  `TOD_AXIL2MMIO.rst_n;
  assign axi_if.master_if[0].awaddr  =  `TOD_AXIL2MMIO.lite_if.awaddr;
  assign axi_if.master_if[0].awprot  =  `TOD_AXIL2MMIO.lite_if.awprot;
  assign axi_if.master_if[0].awvalid =  `TOD_AXIL2MMIO.lite_if.awvalid;
  assign axi_if.master_if[0].awready =  `TOD_AXIL2MMIO.lite_if.awready;
  assign axi_if.master_if[0].wdata   =  `TOD_AXIL2MMIO.lite_if.wdata;
  assign axi_if.master_if[0].wstrb   =  `TOD_AXIL2MMIO.lite_if.wstrb;
  assign axi_if.master_if[0].wvalid  =  `TOD_AXIL2MMIO.lite_if.wvalid; 
  assign axi_if.master_if[0].wready  =  `TOD_AXIL2MMIO.lite_if.wready; 
  assign axi_if.master_if[0].bresp   =  `TOD_AXIL2MMIO.lite_if.bresp; 
  assign axi_if.master_if[0].bvalid  =  `TOD_AXIL2MMIO.lite_if.bvalid;
  assign axi_if.master_if[0].bready  =  `TOD_AXIL2MMIO.lite_if.bready;
  assign axi_if.master_if[0].araddr  =  `TOD_AXIL2MMIO.lite_if.araddr;
  assign axi_if.master_if[0].arprot  =  `TOD_AXIL2MMIO.lite_if.arprot;
  assign axi_if.master_if[0].arvalid =  `TOD_AXIL2MMIO.lite_if.arvalid;
  assign axi_if.master_if[0].arready =  `TOD_AXIL2MMIO.lite_if.arready;
  assign axi_if.master_if[0].rdata   =  `TOD_AXIL2MMIO.lite_if.rdata;
  assign axi_if.master_if[0].rresp   =  `TOD_AXIL2MMIO.lite_if.rresp;
  assign axi_if.master_if[0].rvalid  =  `TOD_AXIL2MMIO.lite_if.rvalid;
  assign axi_if.master_if[0].rready  =  `TOD_AXIL2MMIO.lite_if.rready;
  
  assign axi_if.slave_if[0].aresetn =   `TOD_AXIL2MMIO.rst_n;
  assign axi_if.slave_if[0].awaddr  =   `TOD_AXIL2MMIO.lite_if.awaddr;                                    
  assign axi_if.slave_if[0].awprot  =   `TOD_AXIL2MMIO.lite_if.awprot;
  assign axi_if.slave_if[0].awvalid =   `TOD_AXIL2MMIO.lite_if.awvalid;
  assign axi_if.slave_if[0].awready =   `TOD_AXIL2MMIO.lite_if.awready;
  assign axi_if.slave_if[0].wdata   =   `TOD_AXIL2MMIO.lite_if.wdata;
  assign axi_if.slave_if[0].wstrb   =   `TOD_AXIL2MMIO.lite_if.wstrb;
  assign axi_if.slave_if[0].wvalid  =   `TOD_AXIL2MMIO.lite_if.wvalid; 
  assign axi_if.slave_if[0].wready  =   `TOD_AXIL2MMIO.lite_if.wready; 
  assign axi_if.slave_if[0].bresp   =   `TOD_AXIL2MMIO.lite_if.bresp;
  assign axi_if.slave_if[0].bvalid  =   `TOD_AXIL2MMIO.lite_if.bvalid;
  assign axi_if.slave_if[0].bready  =   `TOD_AXIL2MMIO.lite_if.bready ;
  assign axi_if.slave_if[0].araddr  =   `TOD_AXIL2MMIO.lite_if.araddr; 
  assign axi_if.slave_if[0].arprot  =   `TOD_AXIL2MMIO.lite_if.arprot;
  assign axi_if.slave_if[0].arvalid =   `TOD_AXIL2MMIO.lite_if.arvalid;
  assign axi_if.slave_if[0].arready =   `TOD_AXIL2MMIO.lite_if.arready ;
  assign axi_if.slave_if[0].rdata   =   `TOD_AXIL2MMIO.lite_if.rdata;
  assign axi_if.slave_if[0].rresp   =   `TOD_AXIL2MMIO.lite_if.rresp;
  assign axi_if.slave_if[0].rvalid  =   `TOD_AXIL2MMIO.lite_if.rvalid;
  assign axi_if.slave_if[0].rready  =   `TOD_AXIL2MMIO.lite_if.rready;
  
  ////////////// ST2MM CSR MMIO Interface //////////////////////////////
  assign axi_if.master_if[1].aresetn =  `TOD_AXIL2MMIO.mmio_if.rst_n;
  assign axi_if.master_if[1].awaddr  =  `TOD_AXIL2MMIO.mmio_if.awaddr;
  assign axi_if.master_if[1].awprot  =  `TOD_AXIL2MMIO.mmio_if.awprot;
  assign axi_if.master_if[1].awvalid =  `TOD_AXIL2MMIO.mmio_if.awvalid;
  assign axi_if.master_if[1].awready =  `TOD_AXIL2MMIO.mmio_if.awready;
  assign axi_if.master_if[1].awid    =  `TOD_AXIL2MMIO.mmio_if.awid   ;
  assign axi_if.master_if[1].awlen   =  `TOD_AXIL2MMIO.mmio_if.awlen  ;
  assign axi_if.master_if[1].awsize  =  `TOD_AXIL2MMIO.mmio_if.awsize ;
  assign axi_if.master_if[1].awburst =  `TOD_AXIL2MMIO.mmio_if.awburst;
//assign axi_if.master_if[1].awlock  =  `TOD_AXIL2MMIO.mmio_if.awlock ;
  assign axi_if.master_if[1].awcache =  `TOD_AXIL2MMIO.mmio_if.awcache;
  assign axi_if.master_if[1].awqos   =  `TOD_AXIL2MMIO.mmio_if.awqos  ;
//assign axi_if.master_if[1].awuser  =  `TOD_AXIL2MMIO.mmio_if.awuser ;
  assign axi_if.master_if[1].wdata   =  `TOD_AXIL2MMIO.mmio_if.wdata;
  assign axi_if.master_if[1].wstrb   =  `TOD_AXIL2MMIO.mmio_if.wstrb;
  assign axi_if.master_if[1].wvalid  =  `TOD_AXIL2MMIO.mmio_if.wvalid; 
  assign axi_if.master_if[1].wready  =  `TOD_AXIL2MMIO.mmio_if.wready; 
  assign axi_if.master_if[1].wlast   =  `TOD_AXIL2MMIO.mmio_if.wlast;
//assign axi_if.master_if[1].wuser   =  `TOD_AXIL2MMIO.mmio_if.wuser;
  assign axi_if.master_if[1].bresp   =  `TOD_AXIL2MMIO.mmio_if.bresp; 
  assign axi_if.master_if[1].bvalid  =  `TOD_AXIL2MMIO.mmio_if.bvalid;
  assign axi_if.master_if[1].bready  =  `TOD_AXIL2MMIO.mmio_if.bready;
  assign axi_if.master_if[1].bid     =  `TOD_AXIL2MMIO.mmio_if.bid;
//assign axi_if.master_if[1].buser   =  `TOD_AXIL2MMIO.mmio_if.buser;
  assign axi_if.master_if[1].araddr  =  `TOD_AXIL2MMIO.mmio_if.araddr;
  assign axi_if.master_if[1].arprot  =  `TOD_AXIL2MMIO.mmio_if.arprot;
  assign axi_if.master_if[1].arvalid =  `TOD_AXIL2MMIO.mmio_if.arvalid;
  assign axi_if.master_if[1].arready =  `TOD_AXIL2MMIO.mmio_if.arready;
  assign axi_if.master_if[1].arid    =  `TOD_AXIL2MMIO.mmio_if.arid   ;
  assign axi_if.master_if[1].arlen   =  `TOD_AXIL2MMIO.mmio_if.arlen  ;
  assign axi_if.master_if[1].arsize  =  `TOD_AXIL2MMIO.mmio_if.arsize ;
  assign axi_if.master_if[1].arburst =  `TOD_AXIL2MMIO.mmio_if.arburst;
//assign axi_if.master_if[1].arlock  =  `TOD_AXIL2MMIO.mmio_if.arlock ;
  assign axi_if.master_if[1].arcache =  `TOD_AXIL2MMIO.mmio_if.arcache;
  assign axi_if.master_if[1].arqos   =  `TOD_AXIL2MMIO.mmio_if.arqos  ;
//assign axi_if.master_if[1].aruser  =  `TOD_AXIL2MMIO.mmio_if.aruser ;
  assign axi_if.master_if[1].rdata   =  `TOD_AXIL2MMIO.mmio_if.rdata;
  assign axi_if.master_if[1].rresp   =  `TOD_AXIL2MMIO.mmio_if.rresp;
  assign axi_if.master_if[1].rvalid  =  `TOD_AXIL2MMIO.mmio_if.rvalid;
  assign axi_if.master_if[1].rready  =  `TOD_AXIL2MMIO.mmio_if.rready;
  assign axi_if.master_if[1].rid     =  `TOD_AXIL2MMIO.mmio_if.rid;
  assign axi_if.master_if[1].rlast   =  `TOD_AXIL2MMIO.mmio_if.rlast;
//assign axi_if.master_if[1].ruser   =  `TOD_AXIL2MMIO.mmio_if.ruser;
  
  assign axi_if.slave_if[1].aresetn =  `TOD_AXIL2MMIO.mmio_if.rst_n;
  assign axi_if.slave_if[1].awaddr  =  `TOD_AXIL2MMIO.mmio_if.awaddr;
  assign axi_if.slave_if[1].awprot  =  `TOD_AXIL2MMIO.mmio_if.awprot;
  assign axi_if.slave_if[1].awvalid =  `TOD_AXIL2MMIO.mmio_if.awvalid;
  assign axi_if.slave_if[1].awready =  `TOD_AXIL2MMIO.mmio_if.awready;
  assign axi_if.slave_if[1].awid    =  `TOD_AXIL2MMIO.mmio_if.awid   ;
  assign axi_if.slave_if[1].awlen   =  `TOD_AXIL2MMIO.mmio_if.awlen  ;
  assign axi_if.slave_if[1].awsize  =  `TOD_AXIL2MMIO.mmio_if.awsize ;
  assign axi_if.slave_if[1].awburst =  `TOD_AXIL2MMIO.mmio_if.awburst;
//assign axi_if.slave_if[1].awlock  =  `TOD_AXIL2MMIO.mmio_if.awlock ;
  assign axi_if.slave_if[1].awcache =  `TOD_AXIL2MMIO.mmio_if.awcache;
  assign axi_if.slave_if[1].awqos   =  `TOD_AXIL2MMIO.mmio_if.awqos  ;
//assign axi_if.slave_if[1].awuser  =  `TOD_AXIL2MMIO.mmio_if.awuser ;
  assign axi_if.slave_if[1].wdata   =  `TOD_AXIL2MMIO.mmio_if.wdata;
  assign axi_if.slave_if[1].wstrb   =  `TOD_AXIL2MMIO.mmio_if.wstrb;
  assign axi_if.slave_if[1].wvalid  =  `TOD_AXIL2MMIO.mmio_if.wvalid; 
  assign axi_if.slave_if[1].wready  =  `TOD_AXIL2MMIO.mmio_if.wready; 
  assign axi_if.slave_if[1].wlast   =  `TOD_AXIL2MMIO.mmio_if.wlast;
//assign axi_if.slave_if[1].wuser   =  `TOD_AXIL2MMIO.mmio_if.wuser;
  assign axi_if.slave_if[1].bresp   =  `TOD_AXIL2MMIO.mmio_if.bresp; 
  assign axi_if.slave_if[1].bvalid  =  `TOD_AXIL2MMIO.mmio_if.bvalid;
  assign axi_if.slave_if[1].bready  =  `TOD_AXIL2MMIO.mmio_if.bready;
  assign axi_if.slave_if[1].bid     =  `TOD_AXIL2MMIO.mmio_if.bid;
//assign axi_if.slave_if[1].buser   =  `TOD_AXIL2MMIO.mmio_if.buser;
  assign axi_if.slave_if[1].araddr  =  `TOD_AXIL2MMIO.mmio_if.araddr;
  assign axi_if.slave_if[1].arprot  =  `TOD_AXIL2MMIO.mmio_if.arprot;
  assign axi_if.slave_if[1].arvalid =  `TOD_AXIL2MMIO.mmio_if.arvalid;
  assign axi_if.slave_if[1].arready =  `TOD_AXIL2MMIO.mmio_if.arready;
  assign axi_if.slave_if[1].arid    =  `TOD_AXIL2MMIO.mmio_if.arid   ;
  assign axi_if.slave_if[1].arlen   =  `TOD_AXIL2MMIO.mmio_if.arlen  ;
  assign axi_if.slave_if[1].arsize  =  `TOD_AXIL2MMIO.mmio_if.arsize ;
  assign axi_if.slave_if[1].arburst =  `TOD_AXIL2MMIO.mmio_if.arburst;
//assign axi_if.slave_if[1].arlock  =  `TOD_AXIL2MMIO.mmio_if.arlock ;
  assign axi_if.slave_if[1].arcache =  `TOD_AXIL2MMIO.mmio_if.arcache;
  assign axi_if.slave_if[1].arqos   =  `TOD_AXIL2MMIO.mmio_if.arqos  ;
//assign axi_if.slave_if[1].aruser  =  `TOD_AXIL2MMIO.mmio_if.aruser ;
  assign axi_if.slave_if[1].rdata   =  `TOD_AXIL2MMIO.mmio_if.rdata;
  assign axi_if.slave_if[1].rresp   =  `TOD_AXIL2MMIO.mmio_if.rresp;
  assign axi_if.slave_if[1].rvalid  =  `TOD_AXIL2MMIO.mmio_if.rvalid;
  assign axi_if.slave_if[1].rready  =  `TOD_AXIL2MMIO.mmio_if.rready;
  assign axi_if.slave_if[1].rid     =  `TOD_AXIL2MMIO.mmio_if.rid;
  assign axi_if.slave_if[1].rlast   =  `TOD_AXIL2MMIO.mmio_if.rlast;
//assign axi_if.slave_if[1].ruser   =  `TOD_AXIL2MMIO.mmio_if.ruser;
  
  endmodule : tod_axil2mmio_bind

`endif
