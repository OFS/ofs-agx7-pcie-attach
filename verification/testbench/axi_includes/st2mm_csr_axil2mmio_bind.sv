// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

  `define ST2MM_CSR_AXIL2MMIO tb_top.DUT.afu_top.st2mm.st2mm_csr.axi_lite2mmio
  
  module st2mm_csr_axil2mmio_bind(`AXI_IF axi_if);
  
  
    assign axi_if.common_aclk = `ST2MM_CSR_AXIL2MMIO.clk;
  
  ////////////// ST2MM CSR AXI Lite Interface //////////////////////////////
  
  assign axi_if.master_if[0].aresetn =  `ST2MM_CSR_AXIL2MMIO.rst_n;
  assign axi_if.master_if[0].awaddr  =  `ST2MM_CSR_AXIL2MMIO.lite_if.awaddr;
  assign axi_if.master_if[0].awprot  =  `ST2MM_CSR_AXIL2MMIO.lite_if.awprot;
  assign axi_if.master_if[0].awvalid =  `ST2MM_CSR_AXIL2MMIO.lite_if.awvalid;
  assign axi_if.master_if[0].awready =  `ST2MM_CSR_AXIL2MMIO.lite_if.awready;
  assign axi_if.master_if[0].wdata   =  `ST2MM_CSR_AXIL2MMIO.lite_if.wdata;
  assign axi_if.master_if[0].wstrb   =  `ST2MM_CSR_AXIL2MMIO.lite_if.wstrb;
  assign axi_if.master_if[0].wvalid  =  `ST2MM_CSR_AXIL2MMIO.lite_if.wvalid; 
  assign axi_if.master_if[0].wready  =  `ST2MM_CSR_AXIL2MMIO.lite_if.wready; 
  assign axi_if.master_if[0].bresp   =  `ST2MM_CSR_AXIL2MMIO.lite_if.bresp; 
  assign axi_if.master_if[0].bvalid  =  `ST2MM_CSR_AXIL2MMIO.lite_if.bvalid;
  assign axi_if.master_if[0].bready  =  `ST2MM_CSR_AXIL2MMIO.lite_if.bready;
  assign axi_if.master_if[0].araddr  =  `ST2MM_CSR_AXIL2MMIO.lite_if.araddr;
  assign axi_if.master_if[0].arprot  =  `ST2MM_CSR_AXIL2MMIO.lite_if.arprot;
  assign axi_if.master_if[0].arvalid =  `ST2MM_CSR_AXIL2MMIO.lite_if.arvalid;
  assign axi_if.master_if[0].arready =  `ST2MM_CSR_AXIL2MMIO.lite_if.arready;
  assign axi_if.master_if[0].rdata   =  `ST2MM_CSR_AXIL2MMIO.lite_if.rdata;
  assign axi_if.master_if[0].rresp   =  `ST2MM_CSR_AXIL2MMIO.lite_if.rresp;
  assign axi_if.master_if[0].rvalid  =  `ST2MM_CSR_AXIL2MMIO.lite_if.rvalid;
  assign axi_if.master_if[0].rready  =  `ST2MM_CSR_AXIL2MMIO.lite_if.rready;
  
  assign axi_if.slave_if[0].aresetn =   `ST2MM_CSR_AXIL2MMIO.rst_n;
  assign axi_if.slave_if[0].awaddr  =   `ST2MM_CSR_AXIL2MMIO.lite_if.awaddr;                                    
  assign axi_if.slave_if[0].awprot  =   `ST2MM_CSR_AXIL2MMIO.lite_if.awprot;
  assign axi_if.slave_if[0].awvalid =   `ST2MM_CSR_AXIL2MMIO.lite_if.awvalid;
  assign axi_if.slave_if[0].awready =   `ST2MM_CSR_AXIL2MMIO.lite_if.awready;
  assign axi_if.slave_if[0].wdata   =   `ST2MM_CSR_AXIL2MMIO.lite_if.wdata;
  assign axi_if.slave_if[0].wstrb   =   `ST2MM_CSR_AXIL2MMIO.lite_if.wstrb;
  assign axi_if.slave_if[0].wvalid  =   `ST2MM_CSR_AXIL2MMIO.lite_if.wvalid; 
  assign axi_if.slave_if[0].wready  =   `ST2MM_CSR_AXIL2MMIO.lite_if.wready; 
  assign axi_if.slave_if[0].bresp   =   `ST2MM_CSR_AXIL2MMIO.lite_if.bresp;
  assign axi_if.slave_if[0].bvalid  =   `ST2MM_CSR_AXIL2MMIO.lite_if.bvalid;
  assign axi_if.slave_if[0].bready  =   `ST2MM_CSR_AXIL2MMIO.lite_if.bready ;
  assign axi_if.slave_if[0].araddr  =   `ST2MM_CSR_AXIL2MMIO.lite_if.araddr; 
  assign axi_if.slave_if[0].arprot  =   `ST2MM_CSR_AXIL2MMIO.lite_if.arprot;
  assign axi_if.slave_if[0].arvalid =   `ST2MM_CSR_AXIL2MMIO.lite_if.arvalid;
  assign axi_if.slave_if[0].arready =   `ST2MM_CSR_AXIL2MMIO.lite_if.arready ;
  assign axi_if.slave_if[0].rdata   =   `ST2MM_CSR_AXIL2MMIO.lite_if.rdata;
  assign axi_if.slave_if[0].rresp   =   `ST2MM_CSR_AXIL2MMIO.lite_if.rresp;
  assign axi_if.slave_if[0].rvalid  =   `ST2MM_CSR_AXIL2MMIO.lite_if.rvalid;
  assign axi_if.slave_if[0].rready  =   `ST2MM_CSR_AXIL2MMIO.lite_if.rready;
  
  ////////////// ST2MM CSR MMIO Interface //////////////////////////////
  assign axi_if.master_if[1].aresetn =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rst_n;
  assign axi_if.master_if[1].awaddr  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awaddr;
  assign axi_if.master_if[1].awprot  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awprot;
  assign axi_if.master_if[1].awvalid =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awvalid;
  assign axi_if.master_if[1].awready =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awready;
  assign axi_if.master_if[1].awid    =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awid   ;
  assign axi_if.master_if[1].awlen   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awlen  ;
  assign axi_if.master_if[1].awsize  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awsize ;
  assign axi_if.master_if[1].awburst =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awburst;
//assign axi_if.master_if[1].awlock  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awlock ;
  assign axi_if.master_if[1].awcache =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awcache;
  assign axi_if.master_if[1].awqos   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awqos  ;
//assign axi_if.master_if[1].awuser  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awuser ;
  assign axi_if.master_if[1].wdata   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wdata;
  assign axi_if.master_if[1].wstrb   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wstrb;
  assign axi_if.master_if[1].wvalid  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wvalid; 
  assign axi_if.master_if[1].wready  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wready; 
  assign axi_if.master_if[1].wlast   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wlast;
//assign axi_if.master_if[1].wuser   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wuser;
  assign axi_if.master_if[1].bresp   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.bresp; 
  assign axi_if.master_if[1].bvalid  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.bvalid;
  assign axi_if.master_if[1].bready  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.bready;
  assign axi_if.master_if[1].bid     =  `ST2MM_CSR_AXIL2MMIO.mmio_if.bid;
//assign axi_if.master_if[1].buser   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.buser;
  assign axi_if.master_if[1].araddr  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.araddr;
  assign axi_if.master_if[1].arprot  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arprot;
  assign axi_if.master_if[1].arvalid =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arvalid;
  assign axi_if.master_if[1].arready =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arready;
  assign axi_if.master_if[1].arid    =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arid   ;
  assign axi_if.master_if[1].arlen   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arlen  ;
  assign axi_if.master_if[1].arsize  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arsize ;
  assign axi_if.master_if[1].arburst =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arburst;
//assign axi_if.master_if[1].arlock  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arlock ;
  assign axi_if.master_if[1].arcache =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arcache;
  assign axi_if.master_if[1].arqos   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arqos  ;
//assign axi_if.master_if[1].aruser  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.aruser ;
  assign axi_if.master_if[1].rdata   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rdata;
  assign axi_if.master_if[1].rresp   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rresp;
  assign axi_if.master_if[1].rvalid  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rvalid;
  assign axi_if.master_if[1].rready  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rready;
  assign axi_if.master_if[1].rid     =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rid;
  assign axi_if.master_if[1].rlast   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rlast;
//assign axi_if.master_if[1].ruser   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.ruser;
  
  assign axi_if.slave_if[1].aresetn =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rst_n;
  assign axi_if.slave_if[1].awaddr  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awaddr;
  assign axi_if.slave_if[1].awprot  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awprot;
  assign axi_if.slave_if[1].awvalid =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awvalid;
  assign axi_if.slave_if[1].awready =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awready;
  assign axi_if.slave_if[1].awid    =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awid   ;
  assign axi_if.slave_if[1].awlen   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awlen  ;
  assign axi_if.slave_if[1].awsize  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awsize ;
  assign axi_if.slave_if[1].awburst =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awburst;
//assign axi_if.slave_if[1].awlock  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awlock ;
  assign axi_if.slave_if[1].awcache =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awcache;
  assign axi_if.slave_if[1].awqos   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awqos  ;
//assign axi_if.slave_if[1].awuser  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.awuser ;
  assign axi_if.slave_if[1].wdata   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wdata;
  assign axi_if.slave_if[1].wstrb   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wstrb;
  assign axi_if.slave_if[1].wvalid  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wvalid; 
  assign axi_if.slave_if[1].wready  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wready; 
  assign axi_if.slave_if[1].wlast   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wlast;
//assign axi_if.slave_if[1].wuser   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.wuser;
  assign axi_if.slave_if[1].bresp   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.bresp; 
  assign axi_if.slave_if[1].bvalid  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.bvalid;
  assign axi_if.slave_if[1].bready  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.bready;
  assign axi_if.slave_if[1].bid     =  `ST2MM_CSR_AXIL2MMIO.mmio_if.bid;
//assign axi_if.slave_if[1].buser   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.buser;
  assign axi_if.slave_if[1].araddr  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.araddr;
  assign axi_if.slave_if[1].arprot  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arprot;
  assign axi_if.slave_if[1].arvalid =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arvalid;
  assign axi_if.slave_if[1].arready =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arready;
  assign axi_if.slave_if[1].arid    =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arid   ;
  assign axi_if.slave_if[1].arlen   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arlen  ;
  assign axi_if.slave_if[1].arsize  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arsize ;
  assign axi_if.slave_if[1].arburst =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arburst;
//assign axi_if.slave_if[1].arlock  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arlock ;
  assign axi_if.slave_if[1].arcache =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arcache;
  assign axi_if.slave_if[1].arqos   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.arqos  ;
//assign axi_if.slave_if[1].aruser  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.aruser ;
  assign axi_if.slave_if[1].rdata   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rdata;
  assign axi_if.slave_if[1].rresp   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rresp;
  assign axi_if.slave_if[1].rvalid  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rvalid;
  assign axi_if.slave_if[1].rready  =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rready;
  assign axi_if.slave_if[1].rid     =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rid;
  assign axi_if.slave_if[1].rlast   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.rlast;
//assign axi_if.slave_if[1].ruser   =  `ST2MM_CSR_AXIL2MMIO.mmio_if.ruser;
  
  endmodule : st2mm_csr_axil2mmio_bind
