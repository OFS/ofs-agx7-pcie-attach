// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

module pmci_axi(`AXI_IF axi_if,m10_interface m10_intf);

     

     assign axi_if.common_aclk = tb_top.DUT.clk_100m;

     assign axi_if.master_if[4].aresetn      = tb_top.DUT.rst_n_100m; 
     
    
   always@(*)
   begin
 

   if(tb_top.pmci_master) begin 
      force  tb_top.DUT.bpf_pmci_mst_if.awvalid      =axi_if.master_if[4].awvalid;
      force  tb_top.DUT.bpf_pmci_mst_if.arvalid      =axi_if.master_if[4].arvalid;
      force  tb_top.DUT.bpf_pmci_mst_if.awaddr       =axi_if.master_if[4].awaddr;
      force  tb_top.DUT.bpf_pmci_mst_if.araddr       =axi_if.master_if[4].araddr;
      force  tb_top.DUT.bpf_pmci_mst_if.awprot       =axi_if.master_if[4].awprot;
      force  tb_top.DUT.bpf_pmci_mst_if.arprot       =axi_if.master_if[4].arprot;
      force  tb_top.DUT.bpf_pmci_mst_if.wvalid       =axi_if.master_if[4].wvalid;
      force  tb_top.DUT.bpf_pmci_mst_if.wdata        =axi_if.master_if[4].wdata; 
      force  tb_top.DUT.bpf_pmci_mst_if.wstrb        =axi_if.master_if[4].wstrb; 
      force  tb_top.DUT.bpf_pmci_mst_if.bready       =axi_if.master_if[4].bready;
      force  tb_top.DUT.bpf_pmci_mst_if.rready       =axi_if.master_if[4].rready;
   end  
 
   force  axi_if.master_if[4].rvalid       = (tb_top.pmci_master)?tb_top.DUT.bpf_pmci_mst_if.rvalid:'h0;
   force  axi_if.master_if[4].awready      = (tb_top.pmci_master)?tb_top.DUT.bpf_pmci_mst_if.awready:'h0;
   force  axi_if.master_if[4].wready       = (tb_top.pmci_master)?tb_top.DUT.bpf_pmci_mst_if.wready:'h0;
   force  axi_if.master_if[4].arready      = (tb_top.pmci_master)?tb_top.DUT.bpf_pmci_mst_if.arready:'h0;
   force  axi_if.master_if[4].rdata        = (tb_top.pmci_master)?tb_top.DUT.bpf_pmci_mst_if.rdata:'h0;
   force  axi_if.master_if[4].rresp        = (tb_top.pmci_master)?tb_top.DUT.bpf_pmci_mst_if.rresp:'h0;
   force  axi_if.master_if[4].bresp        = (tb_top.pmci_master)?tb_top.DUT.bpf_pmci_mst_if.bresp:'h0;
   force  axi_if.master_if[4].bvalid       = (tb_top.pmci_master)?tb_top.DUT.bpf_pmci_mst_if.bvalid:'h0; 

   
   if(tb_top.bmc_en) begin
     force m10_intf.ingr_spi_clk                 =  tb_top.DUT.spi_ingress_sclk;
     force m10_intf.ingr_spi_csn                 =  tb_top.DUT.spi_ingress_csn;
     force m10_intf.ingr_spi_mosi                =  tb_top.DUT.spi_ingress_mosi;
     force tb_top.DUT.spi_ingress_miso   =  m10_intf.ingr_spi_miso;
     force tb_top.DUT.spi_egress_sclk    =  m10_intf.egrs_spi_clk;
     force tb_top.DUT.spi_egress_csn     =  m10_intf.egrs_spi_csn;
     force m10_intf.egrs_spi_miso                = tb_top.DUT.spi_egress_miso;
     force tb_top.DUT.spi_egress_mosi    =  m10_intf.egrs_spi_mosi;
   end 


   end

endmodule 
     
