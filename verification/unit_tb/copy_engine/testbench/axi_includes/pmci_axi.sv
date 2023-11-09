// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef INCLUDE_PMCI
  `ifdef SIM_VIP
     assign axi_if.common_aclk = DUT.clk_100m;
     assign axi_if.master_if[4].aresetn      = DUT.rst_n_100m; 
     assign axi_if.slave_if[4] .aresetn = 0;
     
     
     assign DUT.bpf_pmci_mst_if.awvalid      = axi_if.master_if[4].awvalid;
     assign DUT.bpf_pmci_mst_if.arvalid      = axi_if.master_if[4].arvalid;
     assign DUT.bpf_pmci_mst_if.awaddr       = axi_if.master_if[4].awaddr;
     assign DUT.bpf_pmci_mst_if.araddr       = axi_if.master_if[4].araddr;
     assign DUT.bpf_pmci_mst_if.awprot       = axi_if.master_if[4].awprot;
     assign DUT.bpf_pmci_mst_if.arprot       = axi_if.master_if[4].arprot;
     assign DUT.bpf_pmci_mst_if.wvalid       = axi_if.master_if[4].wvalid;
     assign DUT.bpf_pmci_mst_if.wdata        = axi_if.master_if[4].wdata;
     assign DUT.bpf_pmci_mst_if.wstrb        = axi_if.master_if[4].wstrb;
     assign DUT.bpf_pmci_mst_if.bready       = axi_if.master_if[4].bready;
     assign DUT.bpf_pmci_mst_if.rready       = axi_if.master_if[4].rready;
     
     
     assign axi_if.master_if[4].rvalid       = DUT.bpf_pmci_mst_if.rvalid;
     assign axi_if.master_if[4].awready      = DUT.bpf_pmci_mst_if.awready;
     assign axi_if.master_if[4].wready       = DUT.bpf_pmci_mst_if.wready;
     assign axi_if.master_if[4].arready      = DUT.bpf_pmci_mst_if.arready;
     assign axi_if.master_if[4].rdata        = DUT.bpf_pmci_mst_if.rdata;
     assign axi_if.master_if[4].rresp        = DUT.bpf_pmci_mst_if.rresp;
     assign axi_if.master_if[4].bresp        = DUT.bpf_pmci_mst_if.bresp;
     assign axi_if.master_if[4].bvalid       = DUT.bpf_pmci_mst_if.bvalid; 
     
     
     //assign axi_if.slave_if[0].awvalid       = DUT.bpf_pmci_slv_if.awvalid;
     //assign axi_if.slave_if[0].awaddr        = DUT.bpf_pmci_slv_if.awaddr;
     //assign axi_if.slave_if[0].awprot        = DUT.bpf_pmci_slv_if.awprot;
     //assign axi_if.slave_if[0].wvalid        = DUT.bpf_pmci_slv_if.wvalid;
     //assign axi_if.slave_if[0].wdata         = DUT.bpf_pmci_slv_if.wdata;
     //assign axi_if.slave_if[0].wstrb         = DUT.bpf_pmci_slv_if.wstrb;
     //assign axi_if.slave_if[0].bready        = DUT.bpf_pmci_slv_if.bready;
     //assign axi_if.slave_if[0].arvalid       = DUT.bpf_pmci_slv_if.arvalid;
     //assign axi_if.slave_if[0].araddr        = DUT.bpf_pmci_slv_if.araddr;
     //assign axi_if.slave_if[0].arprot        = DUT.bpf_pmci_slv_if.arprot;
     //assign axi_if.slave_if[0].rready        = DUT.bpf_pmci_slv_if.rready;
     //
     //assign DUT.bpf_pmci_slv_if.awready          = axi_if.slave_if[0].awready; 
     //assign DUT.bpf_pmci_slv_if.wready           = axi_if.slave_if[0].wready;
     //assign DUT.bpf_pmci_slv_if.bvalid           = axi_if.slave_if[0].bvalid;
     //assign DUT.bpf_pmci_slv_if.bresp            = axi_if.slave_if[0].bresp;
     //assign DUT.bpf_pmci_slv_if.arready          = axi_if.slave_if[0].arready;
     //assign DUT.bpf_pmci_slv_if.rvalid           = axi_if.slave_if[0].rvalid;
     //assign DUT.bpf_pmci_slv_if.rdata            = axi_if.slave_if[0].rdata;
     //assign DUT.bpf_pmci_slv_if.rresp            = axi_if.slave_if[0].rresp;
  `endif
`endif
