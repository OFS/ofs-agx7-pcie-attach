// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Top level testbench with OFS top level module instantiated as DUT
//
//-----------------------------------------------------------------------------

`include "vendor_defines.vh"
`include "fpga_defines.vh"

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_hdr_def::*;
import ofs_fim_pcie_pkg::*;
import ofs_fim_eth_if_pkg::*;

module top_tb ();

logic SYS_REFCLK;
logic PCIE_REFCLK0;
logic PCIE_REFCLK1;
logic PCIE_RESET_N;
logic ETH_REFCLK;
logic flash_reset;
bit outclk_0 = 1'b0; 
bit outclk_1 = 1'b0;
bit outclk_2 = 1'b0;
bit outclk_3 = 1'b0;
bit outclk_4 = 1'b0;
bit outclk_5 = 1'b0;

initial begin
 `ifdef INCLUDE_PMCI
  force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.s10_mailbox_client_0.s10_mailbox_client_inst.rsp_fifo.in_valid = 1'b0;
  force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.s10_mailbox_client_0.s10_mailbox_client_inst.cmd_fifo.out_ready= 1'b0;
 `endif
end
initial begin
        // #20us;
         #1us;
        force {top_tb.DUT.sys_pll.locked} = 1'b1;
        force top_tb.DUT.sys_pll.outclk_0 = outclk_0; 
        force top_tb.DUT.sys_pll.outclk_1 = outclk_1; 
        force top_tb.DUT.sys_pll.outclk_2 = outclk_2;
        force top_tb.DUT.sys_pll.outclk_3 = outclk_3;
        force top_tb.DUT.sys_pll.outclk_4 = outclk_4;
        force top_tb.DUT.sys_pll.outclk_5 = outclk_5;

end 
     always #1063ps  outclk_0 = ~outclk_0; //470MHz
     always #4965ps  outclk_1 = ~outclk_1; //100.71MHz
     always #2127ps  outclk_2 = ~outclk_2; //235MHz
     always #3191ps  outclk_3 = ~outclk_3; //156.66MHz
     always #9929ps  outclk_4 = ~outclk_4; //50.358MHz
     always #4255ps  outclk_5 = ~outclk_5; //117.5MHz

initial begin
   SYS_REFCLK   = 0;
   PCIE_REFCLK0 = 0;
   PCIE_REFCLK1 = 0;
   PCIE_RESET_N = 0;
   ETH_REFCLK   = 0;
   flash_reset  = 0;
end

initial 
begin
`ifdef VCD_ON  
   `ifndef VCD_OFF
        $vcdpluson;
        $vcdplusmemon();
   `endif 
`endif
end        

`ifdef INCLUDE_DDR4
   ofs_fim_emif_ddr4_if ddr4_mem [ofs_fim_mem_if_pkg::NUM_MEM_CHANNELS-1:0] ();
`ifdef INCLUDE_HPS
   ofs_fim_hps_ddr4_if  ddr4_hps (); 
 `endif
`endif

`ifdef INCLUDE_HSSI
// HSSI serial data for loopback
ofs_fim_hssi_serial_if hssi_if [NUM_ETH_LANES-1:0] ();
`endif

`ifdef INCLUDE_PMCI                                                                              
  logic          qspi_dclk;                                                 
  logic          qspi_ncs;                                                  
  wire    [3:0]  qspi_data;
  wire           spi_ingress_sclk;  
  wire           spi_ingress_csn;   
  wire           spi_ingress_miso;  
  wire           spi_ingress_mosi;  
  wire           spi_egress_mosi;   
  wire           spi_egress_csn;    
  wire           spi_egress_sclk;   
  wire           spi_egress_miso;   
`endif

initial #2us PCIE_RESET_N = 1; //  IOPLL sim model requires at least 1us of reset
always #5000 SYS_REFCLK   = ~SYS_REFCLK;   // 100MHz
always #5000 PCIE_REFCLK0 = ~PCIE_REFCLK0; // 100MHz
always #5000 PCIE_REFCLK1 = ~PCIE_REFCLK1; // 100MHz
always #3200 ETH_REFCLK   = ~ETH_REFCLK;   // 156.25MHz
always #10000 flash_reset = 1;

top DUT (
   .SYS_REFCLK      (SYS_REFCLK),
   .PCIE_REFCLK0    (PCIE_REFCLK0),
   .PCIE_REFCLK1    (PCIE_REFCLK1),
   .PCIE_RESET_N    (PCIE_RESET_N),

 `ifdef INCLUDE_HSSI
    `ifdef PMCI_QSFP
       //to make QSFP connections without affecting HSSI operations
      .hssi_if          (hssi_if),
    `else
      .qsfp_ref_clk     (ETH_REFCLK),
      .hssi_if          (hssi_if),
    `endif
 `endif

`ifdef INCLUDE_DDR4
   .ddr4_mem     (ddr4_mem),
`ifdef INCLUDE_HPS
   .ddr4_hps     (ddr4_hps),
`endif
`endif 
 
`ifdef INCLUDE_PMCI                                                                              
  // AC FPGA - AC card BMC interface 
  .qspi_dclk (qspi_dclk),                                                 
  .qspi_ncs  (qspi_ncs),                                                  
  .qspi_data (qspi_data), 
`ifdef SPI_LB                                                                              
  .spi_ingress_sclk(spi_ingress_sclk),       
  .spi_ingress_csn(spi_ingress_csn),        
  .spi_ingress_miso(spi_ingress_miso),       
  .spi_ingress_mosi(spi_ingress_mosi),       
  .spi_egress_mosi(spi_ingress_mosi),        
  .spi_egress_csn(spi_ingress_csn),         
  .spi_egress_sclk(spi_ingress_sclk),        
  .spi_egress_miso(spi_ingress_miso),         
`endif 
`ifdef BMC_EN
  .spi_ingress_sclk(bmc_m10.ingr_spi_clk),       
  .spi_ingress_csn(bmc_m10.ingr_spi_csn),        
  .spi_ingress_miso(bmc_m10.ingr_spi_miso),       
  .spi_ingress_mosi(bmc_m10.ingr_spi_mosi),       
  .spi_egress_mosi(bmc_m10.egrs_spi_mosi),        
  .spi_egress_csn(bmc_m10.egrs_spi_csn),         
  .spi_egress_sclk(bmc_m10.egrs_spi_clk),        
  .spi_egress_miso(bmc_m10.egrs_spi_miso),         
`endif 
`endif  
 
   .PCIE_RX_P       ('0),
   .PCIE_RX_N       ('0),
   .PCIE_TX_P       (),
   .PCIE_TX_N       ()
);


`ifdef INCLUDE_PMCI                                                                              
// MT25QxxxTop DUT (S, C, HOLD_DQ3, DQ0, DQ1, Vcc, Vpp_W_DQ2, RESET2); 
   
/*   N25Qxxx N25Qxxx (.S (qspi_ncs), 
                    .C_ (qspi_dclk), 
               .HOLD_DQ3(qspi_data[3]),
               //.RESET_DQ3(qspi_data[3]), 
               .DQ0(qspi_data[0]), 
               .DQ1(qspi_data[1]), 
               .Vcc(1), 
               .Vpp_W_DQ2(qspi_data[2]));
*/

`ifdef BMC_EN
   bmc_top  bmc_m10 ();
`endif

`endif



// HSSI serial loopback
`ifdef INCLUDE_HSSI
  `ifdef PMCI_QSFP
  `else
      genvar i;
      generate
          for (i=0;i<NUM_ETH_LANES;i++) begin
              assign hssi_if[i].rx_p = hssi_if[i].tx_p;
              assign hssi_if[i].rx_n = hssi_if[i].tx_n;
          end
      endgenerate
  `endif
`endif

// EMIF memory model   
`ifdef INCLUDE_DDR4
`ifdef INCLUDE_HPS
   initial ddr4_hps.ref_clk = '0;
`endif
   genvar ch;
   generate
      for(ch=0; ch < ofs_fim_mem_if_pkg::NUM_MEM_CHANNELS; ch = ch+1) begin : mem_model
         initial ddr4_mem[ch].ref_clk = '0;
         always #833 ddr4_mem[ch].ref_clk = ~ddr4_mem[ch].ref_clk; // 1200 MHz
         ed_sim_mem ddr_mem_inst (
            .mem_ck     (ddr4_mem[ch].ck),
            .mem_ck_n   (ddr4_mem[ch].ck_n),
            .mem_a      (ddr4_mem[ch].a),
            .mem_act_n  (ddr4_mem[ch].act_n),
            .mem_ba     (ddr4_mem[ch].ba),
            .mem_bg     (ddr4_mem[ch].bg),
            .mem_cke    (ddr4_mem[ch].cke),
            .mem_cs_n   (ddr4_mem[ch].cs_n),
            .mem_odt    (ddr4_mem[ch].odt),
            .mem_reset_n(ddr4_mem[ch].reset_n),
            .mem_par    (ddr4_mem[ch].par),
            .mem_alert_n(ddr4_mem[ch].alert_n),
            .mem_dqs    (ddr4_mem[ch].dqs),
            .mem_dqs_n  (ddr4_mem[ch].dqs_n),
            .mem_dq     (ddr4_mem[ch].dq),
            .mem_dbi_n  (ddr4_mem[ch].dbi_n)
         );
      end
   endgenerate
`endif

`ifdef INCLUDE_PMCI
  pmci_if  pmci_if_1();
`endif

 //F-TILE IP Instance
`ifdef FTILE_SIM
ofs_top_auto_tiles ofs_top_auto_tiles();
`endif
  
endmodule
