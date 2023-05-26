// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// AXI-MM passthrough for memory front-end
//
//-----------------------------------------------------------------------------

module axi_mem_pass (
   // AXI-MM source interfaces
   ofs_fim_emif_axi_mm_if.emif    in_mem_if,

   // External Memory I/F
   ofs_fim_emif_axi_mm_if.user    out_mem_if
);

   // Write address channel
   assign out_mem_if.awid    = in_mem_if.awid;
   assign out_mem_if.awaddr  = in_mem_if.awaddr;
   assign out_mem_if.awlen   = in_mem_if.awlen;
   assign out_mem_if.awsize  = in_mem_if.awsize;
   assign out_mem_if.awburst = in_mem_if.awburst;
   assign out_mem_if.awlock  = in_mem_if.awlock;
   assign out_mem_if.awcache = in_mem_if.awcache;
   assign out_mem_if.awprot  = in_mem_if.awprot;
   assign out_mem_if.awuser  = in_mem_if.awuser; 
   assign out_mem_if.awvalid = in_mem_if.awvalid; 

   assign in_mem_if.awready  = out_mem_if.awready;

   // Write data channel
   assign out_mem_if.wdata   = in_mem_if.wdata;
   assign out_mem_if.wstrb   = in_mem_if.wstrb;
   assign out_mem_if.wlast   = in_mem_if.wlast;
   assign out_mem_if.wvalid  = in_mem_if.wvalid;

   assign in_mem_if.wready   = out_mem_if.wready;
   
   // Write response channel
   assign out_mem_if.bready  = in_mem_if.bready;
   
   assign in_mem_if.bvalid   = out_mem_if.bvalid;
   assign in_mem_if.bid      = out_mem_if.bid;
   assign in_mem_if.bresp    = out_mem_if.bresp;
   assign in_mem_if.buser    = out_mem_if.buser;
   
   // Read address channel
   assign out_mem_if.arvalid = in_mem_if.arvalid;
   assign out_mem_if.arid    = in_mem_if.arid;
   assign out_mem_if.araddr  = in_mem_if.araddr;
   assign out_mem_if.arlen   = in_mem_if.arlen;
   assign out_mem_if.arsize  = in_mem_if.arsize;
   assign out_mem_if.arburst = in_mem_if.arburst;
   assign out_mem_if.arlock  = in_mem_if.arlock;
   assign out_mem_if.arcache = in_mem_if.arcache;
   assign out_mem_if.arprot  = in_mem_if.arprot;
   assign out_mem_if.aruser  = in_mem_if.aruser;

   assign in_mem_if.arready  = out_mem_if.arready;
   
   //Read response channel
   assign out_mem_if.rready  = in_mem_if.rready;
      
   assign in_mem_if.rvalid   = out_mem_if.rvalid;
   assign in_mem_if.rid      = out_mem_if.rid;
   assign in_mem_if.rdata    = out_mem_if.rdata;
   assign in_mem_if.rresp    = out_mem_if.rresp;
   assign in_mem_if.rlast    = out_mem_if.rlast;
   assign in_mem_if.ruser    = out_mem_if.ruser;

   // Clock & Reset
   assign in_mem_if.clk      = out_mem_if.clk;
   assign in_mem_if.rst_n    = out_mem_if.rst_n;

endmodule
