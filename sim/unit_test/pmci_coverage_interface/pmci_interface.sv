// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  Coverage Interface for PMCI_SS
//
//-----------------------------------------------------------------------------

interface  pmci_if;

  `define PMCI_IF      top_tb.DUT.pmci_wrapper
  `define FLASH_INTF   top_tb.DUT.pmci_wrapper.pmci_ss.flash_burst_master
  
  int addr_flag[8];
  int spi_addr_hit;
 
  covergroup QSFP_PMCI_TELE_VAL @(posedge `PMCI_IF.clk_csr);
    qsfp0_pmci_high_wrng_trsh_val : coverpoint `PMCI_IF.csr_lite_slv_if.rdata iff (addr_flag[0]==1 && `PMCI_IF.csr_lite_slv_if.rvalid==1 && `PMCI_IF.csr_lite_slv_if.rready==1) {bins temp_wrn0[] = {180};}
    qsfp0_pmci_high_ftl_trsh_val  : coverpoint `PMCI_IF.csr_lite_slv_if.rdata iff (addr_flag[1]==1 && `PMCI_IF.csr_lite_slv_if.rvalid==1 && `PMCI_IF.csr_lite_slv_if.rready==1) {bins temp_ftl0[] = {190};}
    qsfp1_pmci_high_wrng_trsh_val : coverpoint `PMCI_IF.csr_lite_slv_if.rdata iff (addr_flag[2]==1 && `PMCI_IF.csr_lite_slv_if.rvalid==1 && `PMCI_IF.csr_lite_slv_if.rready==1) {bins temp_wrn1[] = {180};}
    qsfp1_pmci_high_ftl_trsh_val  : coverpoint `PMCI_IF.csr_lite_slv_if.rdata iff (addr_flag[3]==1 && `PMCI_IF.csr_lite_slv_if.rvalid==1 && `PMCI_IF.csr_lite_slv_if.rready==1) {bins temp_ftl1[] = {190};}
    qsfp0_pmci_temp_val : coverpoint `PMCI_IF.csr_lite_slv_if.rdata iff (addr_flag[4]==1 && `PMCI_IF.csr_lite_slv_if.rvalid==1 && `PMCI_IF.csr_lite_slv_if.rready==1) {bins temp_0[] = {90};}
    qsfp0_pmci_volt_val : coverpoint `PMCI_IF.csr_lite_slv_if.rdata iff (addr_flag[5]==1 && `PMCI_IF.csr_lite_slv_if.rvalid==1 && `PMCI_IF.csr_lite_slv_if.rready==1) {bins vol_0[] = {6553};}
    qsfp1_pmci_temp_val : coverpoint `PMCI_IF.csr_lite_slv_if.rdata iff (addr_flag[6]==1 && `PMCI_IF.csr_lite_slv_if.rvalid==1 && `PMCI_IF.csr_lite_slv_if.rready==1) {bins temp_1[] = {90};}
    qsfp1_pmci_volt_val : coverpoint `PMCI_IF.csr_lite_slv_if.rdata iff (addr_flag[7]==1 && `PMCI_IF.csr_lite_slv_if.rvalid==1 && `PMCI_IF.csr_lite_slv_if.rready==1) {bins vol_1[] = {6553};}
  endgroup


  covergroup MCTP_ERR_VAL @(posedge `PMCI_IF.clk_csr);
    mctp_b2b_drop_err_val  :coverpoint `PMCI_IF.pmci_ss.mctp_pcievdm.mctp_pcievdm_ctrlr_0.mctp_pcievdm_ingr_inst.genblk1.b2b_drop_dbg_i     {bins b2b_err_hit={1};}
    mctp_multi_err_val     :coverpoint `PMCI_IF.pmci_ss.mctp_pcievdm.mctp_pcievdm_ctrlr_0.mctp_pcievdm_ingr_inst.genblk1.multipkt_mis_dbg_i {bins multi_err_hit={1};}
    mctp_tlp_mis_err_val   :coverpoint `PMCI_IF.pmci_ss.mctp_pcievdm.mctp_pcievdm_ctrlr_0.mctp_pcievdm_ingr_inst.genblk1.tlp_hdr_mis_dbg_i {bins tlp_err_hit={1};}
  endgroup   


  covergroup SPI_RD_WR_VAL @(posedge `PMCI_IF.clk_csr);
   spi_mode: coverpoint `PMCI_IF.csr_lite_slv_if.wdata[1:0] iff(`PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 && spi_addr_hit==1) {bins rd_mode ={'d1}; bins wr_mode ={'d2};}
  endgroup
  
  covergroup PMCI_MBX_VAL @(posedge `PMCI_IF.clk_csr);
  
    pmci_mbx_addr_val : coverpoint `PMCI_IF.csr_lite_slv_if.wdata[31:0] iff (`PMCI_IF.csr_lite_slv_if.awvalid=='h1 && `PMCI_IF.csr_lite_slv_if.awaddr == 'h404) {bins temp0[] = {32'h8000_0000,32'h8000_0004,32'h8000_0008}; 
bins temp1[] = {32'h8000_1000,32'h8000_1004,32'h8000_1010,32'h8000_1014,32'h8000_1018,32'h8000_101C,32'h8000_1020,32'h8000_1024,32'h8000_1028,32'h8000_102C,32'h8000_1030,32'h8000_1034,32'h8000_1038,32'h8000_103C,32'h8000_1040,32'h8000_1044,32'h8000_1048,32'h8000_104C};
bins temp2[] = {32'h8000_1050,32'h8000_1070,32'h8000_1074,32'h8000_1078,32'h8000_107C,32'h8000_1080,32'h8000_1084,32'h8000_1088,32'h8000_108C,32'h8000_1090,32'h8000_1094,32'h8000_1098,32'h8000_109C};
bins temp3[] = {32'h8000_10A0,32'h8000_10A4,32'h8000_10A8,32'h8000_10AC,32'h8000_10B0,32'h8000_10B4,32'h8000_10B8,32'h8000_10BC,32'h8000_10F0,32'h8000_10F4,32'h8000_10F8,32'h8000_10FC};
  }
  
  endgroup

  covergroup FLASH_BURST_COUNT_VAL @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.flash_burst_master.clk);
  
    flash_addr_val : coverpoint `FLASH_INTF.flash_addr {bins ADDR[] = {'h0C80_0000};}
    flash_read_val : coverpoint `FLASH_INTF.read_mode {bins READ[] = {'h1};}
  

    flash_count_val: coverpoint `PMCI_IF.csr_lite_slv_if.wdata[25:16] iff (`PMCI_IF.csr_lite_slv_if.awvalid == 'h1 && `PMCI_IF.csr_lite_slv_if.awaddr == 'h0_0040 && `PMCI_IF.csr_lite_slv_if.awvalid == 'h1) {bins count0 = {[1:127]};
                                                              bins count1 = {[128:255]};
                                                              bins count2 = {[256:383]};
                                                              bins count3 = {[384:512]};
                                                              }

  endgroup

  always@(posedge `PMCI_IF.clk_csr)
  begin
    if(`PMCI_IF.csr_lite_slv_if.wdata[63:32]=='h8000_1048 && `PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 )begin
        addr_flag[0]=1;
     end
    if(`PMCI_IF.csr_lite_slv_if.wdata[63:32]=='h8000_104c && `PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 )begin
        addr_flag[1]=1; 
     end
    if(`PMCI_IF.csr_lite_slv_if.wdata[63:32]=='h8000_1050 && `PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 )begin
        addr_flag[2]=1; 
     end
    if(`PMCI_IF.csr_lite_slv_if.wdata[63:32]=='h8000_1054 && `PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 )begin
        addr_flag[3]=1; 
     end
    if(`PMCI_IF.csr_lite_slv_if.wdata[63:32]=='h8000_10b0 && `PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 )begin
        addr_flag[4]=1; 
     end
    if(`PMCI_IF.csr_lite_slv_if.wdata[63:32]=='h8000_10b4 && `PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 )begin
        addr_flag[5]=1; 
     end
    if(`PMCI_IF.csr_lite_slv_if.wdata[63:32]=='h8000_10b8 && `PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 )begin
        addr_flag[6]=1; 
     end
    if(`PMCI_IF.csr_lite_slv_if.wdata[63:32]=='h8000_10bc && `PMCI_IF.csr_lite_slv_if.wvalid==1 && `PMCI_IF.csr_lite_slv_if.wready==1 )begin
        addr_flag[7]=1;
     end
  end
  

  
  always @(posedge `PMCI_IF.clk_csr)
  begin
    if(`PMCI_IF.csr_lite_slv_if.awaddr[16:0]=='h400 && `PMCI_IF.csr_lite_slv_if.awvalid==1 && `PMCI_IF.csr_lite_slv_if.awready==1) begin
      spi_addr_hit=1'b1;
    end
  end

  QSFP_PMCI_TELE_VAL tel_val=new();
  MCTP_ERR_VAL       mctp_val=new();
  SPI_RD_WR_VAL      spi_val=new();
  PMCI_MBX_VAL       mbx_val=new();
  FLASH_BURST_COUNT_VAL flash_val=new();
endinterface
