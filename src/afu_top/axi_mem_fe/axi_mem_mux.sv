// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// Simple AXI-MM mux to ext mem that uses sideband signal to switch if
// control between HE-MEM block and traffic generator(s)
//
//-----------------------------------------------------------------------------

module axi_mem_mux (
   // Signal to select test channel
   input logic sel,

   // AXI-MM source interfaces
   ofs_fim_emif_axi_mm_if.emif in0_mem_if,
   ofs_fim_emif_axi_mm_if.emif in1_mem_if,

   // External Memory I/F
   ofs_fim_emif_axi_mm_if.user out_mem_if
);

   // Write address channel
   assign out_mem_if.awid    = sel ? in1_mem_if.awid    : in0_mem_if.awid;
   assign out_mem_if.awaddr  = sel ? in1_mem_if.awaddr  : in0_mem_if.awaddr;
   assign out_mem_if.awlen   = sel ? in1_mem_if.awlen   : in0_mem_if.awlen;
   assign out_mem_if.awsize  = sel ? in1_mem_if.awsize  : in0_mem_if.awsize;
   assign out_mem_if.awburst = sel ? in1_mem_if.awburst : in0_mem_if.awburst;
   assign out_mem_if.awlock  = sel ? in1_mem_if.awlock  : in0_mem_if.awlock;
   assign out_mem_if.awcache = sel ? in1_mem_if.awcache : in0_mem_if.awcache;
   assign out_mem_if.awprot  = sel ? in1_mem_if.awprot  : in0_mem_if.awprot;
   assign out_mem_if.awuser  = sel ? in1_mem_if.awuser  : in0_mem_if.awuser; 
   assign out_mem_if.awvalid = sel ? in1_mem_if.awvalid : in0_mem_if.awvalid; 

   assign in1_mem_if.awready = sel ? out_mem_if.awready : 1'b0;
   assign in0_mem_if.awready = sel ? 1'b0 : out_mem_if.awready;
   
   // Write data channel
   assign out_mem_if.wdata   = sel ? in1_mem_if.wdata  : in0_mem_if.wdata;
   assign out_mem_if.wstrb   = sel ? in1_mem_if.wstrb  : in0_mem_if.wstrb;
   assign out_mem_if.wlast   = sel ? in1_mem_if.wlast  : in0_mem_if.wlast;
   assign out_mem_if.wvalid  = sel ? in1_mem_if.wvalid : in0_mem_if.wvalid;

   assign in1_mem_if.wready  = sel ? out_mem_if.wready : 1'b0;
   assign in0_mem_if.wready  = sel ? 1'b0 : out_mem_if.wready;
   
   // Write response channel
   assign out_mem_if.bready  =  sel ? in1_mem_if.bready : in0_mem_if.bready;
   
   assign in1_mem_if.bvalid  =  sel ? out_mem_if.bvalid : '0;
   assign in1_mem_if.bid     =  sel ? out_mem_if.bid    : '0;
   assign in1_mem_if.bresp   =  sel ? out_mem_if.bresp  : '0;
   assign in1_mem_if.buser   =  sel ? out_mem_if.buser  : '0;

   assign in0_mem_if.bvalid  = !sel ? out_mem_if.bvalid : '0;
   assign in0_mem_if.bid     = !sel ? out_mem_if.bid    : '0;
   assign in0_mem_if.bresp   = !sel ? out_mem_if.bresp  : '0;
   assign in0_mem_if.buser   = !sel ? out_mem_if.buser  : '0;
   
   // Read address channel
   assign out_mem_if.arvalid =  sel ? in1_mem_if.arvalid : in0_mem_if.arvalid;
   assign out_mem_if.arid    =  sel ? in1_mem_if.arid    : in0_mem_if.arid;
   assign out_mem_if.araddr  =  sel ? in1_mem_if.araddr  : in0_mem_if.araddr;
   assign out_mem_if.arlen   =  sel ? in1_mem_if.arlen   : in0_mem_if.arlen;
   assign out_mem_if.arsize  =  sel ? in1_mem_if.arsize  : in0_mem_if.arsize;
   assign out_mem_if.arburst =  sel ? in1_mem_if.arburst : in0_mem_if.arburst;
   assign out_mem_if.arlock  =  sel ? in1_mem_if.arlock  : in0_mem_if.arlock;
   assign out_mem_if.arcache =  sel ? in1_mem_if.arcache : in0_mem_if.arcache;
   assign out_mem_if.arprot  =  sel ? in1_mem_if.arprot  : in0_mem_if.arprot;
   assign out_mem_if.aruser  =  sel ? in1_mem_if.aruser  : in0_mem_if.aruser;

   assign in1_mem_if.arready =  sel ? out_mem_if.arready : 1'b0;
   assign in0_mem_if.arready = !sel ? out_mem_if.arready : 1'b0;
   
   //Read response channel
   assign out_mem_if.rready  = sel ? in1_mem_if.rready : in0_mem_if.rready;
   
   assign in1_mem_if.rvalid  =  sel ? out_mem_if.rvalid : '0;
   assign in1_mem_if.rid     =  sel ? out_mem_if.rid    : '0;
   assign in1_mem_if.rdata   =  sel ? out_mem_if.rdata  : '0;
   assign in1_mem_if.rresp   =  sel ? out_mem_if.rresp  : '0;
   assign in1_mem_if.rlast   =  sel ? out_mem_if.rlast  : '0;
   assign in1_mem_if.ruser   =  sel ? out_mem_if.ruser  : '0;

   assign in0_mem_if.rvalid  = !sel ? out_mem_if.rvalid : '0;
   assign in0_mem_if.rid     = !sel ? out_mem_if.rid    : '0;
   assign in0_mem_if.rdata   = !sel ? out_mem_if.rdata  : '0;
   assign in0_mem_if.rresp   = !sel ? out_mem_if.rresp  : '0;
   assign in0_mem_if.rlast   = !sel ? out_mem_if.rlast  : '0;
   assign in0_mem_if.ruser   = !sel ? out_mem_if.ruser  : '0;

   // clock & reset
   assign in0_mem_if.clk     = out_mem_if.clk;
   assign in0_mem_if.rst_n   = out_mem_if.rst_n;

   assign in1_mem_if.clk     = out_mem_if.clk;
   assign in1_mem_if.rst_n   = out_mem_if.rst_n;

endmodule // axi_mem_fe

