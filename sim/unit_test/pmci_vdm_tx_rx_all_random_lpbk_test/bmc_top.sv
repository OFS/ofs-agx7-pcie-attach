// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`timescale 1ps/1ps


module bmc_top ();

//`include "m10_parameters.sv"
`include "declarations.sv"
//Clock-generation logic
always
begin
   //#10;
   #10000ps;
   m10_clk = ~m10_clk;
end

//Reset-generation logic
initial begin
   //m10_reset =1'b1;
   repeat (10) @ (posedge m10_clk);
   m10_reset <= 1'b1;
   repeat (10) @ (posedge m10_clk);
   m10_reset <= 1'b0;
end



initial begin
   wait (!m10_reset);
   forever begin
      repeat (999) @ (posedge m10_clk); //every 20us in simulation
      pulse_1ms <= 1'b1;
      @ (posedge m10_clk);
      pulse_1ms <= 1'b0;
   end
end

//M10_PCIEVDM_BUFFER
mctp_pcievdm_buffer #(
   .NIOS_ADDR_WIDTH        (NIOS_ADDR_WIDTH        ),
   .INGR_SLV_ADDR_WIDTH    (INGR_SLV_ADDR_WIDTH    ),
   .EGRS_MSTR_ADDR_WIDTH   (EGRS_MSTR_ADDR_WIDTH   ),
   .EGRS_MSTR_BRST_WIDTH   (EGRS_MSTR_BRST_WIDTH   ),
   .DEBUG_REG_EN           (DEBUG_REG_EN           ),
   .DEBUG_REG_WIDTH        (DEBUG_REG_WIDTH        )
)m10_pcie_vdm(
   .clk                    (m10_clk                ),
   .reset                  (m10_reset              ),
   
   .pulse_1ms              (pulse_1ms              ),
   .pci_vdm_intr           (pci_vdm_intr           ),
   .pcie_vdm_sts1_dbg      (m_pcie_vdm_sts1_dbg    ),
   .pcie_vdm_sts2_dbg      (m_pcie_vdm_sts2_dbg    ),
   
   .avmm_nios_addr         (avmm_nios_addr         ),
   .avmm_nios_write        (avmm_nios_write        ),
   .avmm_nios_read         (avmm_nios_read         ),
 //.avmm_nios_burstcnt     (avmm_nios_burstcnt     ),
   .avmm_nios_wrdata       (avmm_nios_wrdata       ),
   .avmm_nios_rddata       (avmm_nios_rddata       ),
   .avmm_nios_rddvld       (avmm_nios_rddvld       ),
   .avmm_nios_waitreq      (avmm_nios_waitreq      ),

   //Ingress AVMM Slave (connected to SPI Slave)
   .avmm_ingr_slv_addr     (m_avmm_ingr_slv_addr     ),
   .avmm_ingr_slv_write    (m_avmm_ingr_slv_write    ),
   .avmm_ingr_slv_read     (m_avmm_ingr_slv_read     ),
   .avmm_ingr_slv_wrdata   (m_avmm_ingr_slv_wrdata   ),
   .avmm_ingr_slv_rddata   (m_avmm_ingr_slv_rddata   ),
   .avmm_ingr_slv_rddvld   (m_avmm_ingr_slv_rddvld   ),
   .avmm_ingr_slv_waitreq  (m_avmm_ingr_slv_waitreq  ),
   
   //Egress AVMM Master (connected to SPI Master)
   .avmm_egrs_mstr_addr    (m_avmm_egrs_mstr_addr    ),
   .avmm_egrs_mstr_write   (m_avmm_egrs_mstr_write   ),
   .avmm_egrs_mstr_read    (m_avmm_egrs_mstr_read    ),
   .avmm_egrs_mstr_burstcnt(m_avmm_egrs_mstr_burstcnt),
   .avmm_egrs_mstr_wrdata  (m_avmm_egrs_mstr_wrdata  ),
   .avmm_egrs_mstr_rddata  (m_avmm_egrs_mstr_rddata  ),
   .avmm_egrs_mstr_rddvld  (m_avmm_egrs_mstr_rddvld  ),
   .avmm_egrs_mstr_waitreq (m_avmm_egrs_mstr_waitreq )
);


//SPI_TX-Master


avmms_2_spim_bridge #(
   .CSR_DATA_WIDTH    (32                     ),
   .DIR_BASE_ADDR     (EGRS_DIR_BASE_ADDR     ),
   .DIR_ADDR_WIDTH    (EGRS_MSTR_ADDR_WIDTH-2 ),
   .DIR_BRST_WIDTH    (EGRS_MSTR_BRST_WIDTH   ),
   .USE_MEMORY_BLOCKS (1                      ),
   .SCLK_CLK_DIV      (EGRS_SCLK_CLK_DIV      ),  
   .CSR_ADDR_WIDTH    (3                      ),  
   .SLV_CSR_AWIDTH    (EGRS_SLV_CSR_AWIDTH    )   
                                                  
)egrs_spi_master(
   .clk               (m10_clk                ),
   .reset             (m10_reset              ),

   .avmm_csr_addr     (egrs_avmm_csr_addr     ),
   .avmm_csr_write    (egrs_avmm_csr_write    ),
   .avmm_csr_read     (egrs_avmm_csr_read     ),
   .avmm_csr_byteen   (egrs_avmm_csr_byteen   ),
   .avmm_csr_wrdata   (egrs_avmm_csr_wrdata   ),
   .avmm_csr_rddata   (egrs_avmm_csr_rddata   ),
   .avmm_csr_rddvld   (egrs_avmm_csr_rddvld   ),
   .avmm_csr_waitreq  (egrs_avmm_csr_waitreq  ),
   
   .avmm_dir_addr     (m_avmm_egrs_mstr_addr[EGRS_MSTR_ADDR_WIDTH-1:2]),
   .avmm_dir_write    (m_avmm_egrs_mstr_write   ),
   .avmm_dir_read     (m_avmm_egrs_mstr_read    ),
   .avmm_dir_burstcnt (m_avmm_egrs_mstr_burstcnt),
   .avmm_dir_wrdata   (m_avmm_egrs_mstr_wrdata  ),
   .avmm_dir_rddata   (m_avmm_egrs_mstr_rddata  ),
   .avmm_dir_rddvld   (m_avmm_egrs_mstr_rddvld  ),
   .avmm_dir_waitreq  (m_avmm_egrs_mstr_waitreq ),

   .spim_clk          (egrs_spi_clk           ),
   .spim_csn          (egrs_spi_csn           ),
   .spim_miso         (egrs_spi_miso          ),
   .spim_mosi         (egrs_spi_mosi          )
);

//SPI_RX-SLAVE


SPISlaveToAvalonMasterBridge #(
	.SYNC_DEPTH (2)
) ingr_spi_slave (
	.clk                                                                    (m10_clk                ),
	.reset_n                                                                (~m10_reset             ),
	.mosi_to_the_spislave_inst_for_spichain                                 (ingr_spi_mosi          ),
	.nss_to_the_spislave_inst_for_spichain                                  (ingr_spi_csn           ),
	.miso_to_and_from_the_spislave_inst_for_spichain                        (ingr_spi_miso          ),
	.sclk_to_the_spislave_inst_for_spichain                                 (ingr_spi_clk           ),
	.address_from_the_altera_avalon_packets_to_master_inst_for_spichain     (ingr_spis_avmm_addr    ),
	.byteenable_from_the_altera_avalon_packets_to_master_inst_for_spichain  (ingr_spis_avmm_byteen  ),
	.read_from_the_altera_avalon_packets_to_master_inst_for_spichain        (ingr_spis_avmm_read    ),
	.readdata_to_the_altera_avalon_packets_to_master_inst_for_spichain      (ingr_spis_avmm_rddata  ),
	.readdatavalid_to_the_altera_avalon_packets_to_master_inst_for_spichain (ingr_spis_avmm_rdvld   ),
	.waitrequest_to_the_altera_avalon_packets_to_master_inst_for_spichain   (ingr_spis_avmm_waitreq ),
	.write_from_the_altera_avalon_packets_to_master_inst_for_spichain       (ingr_spis_avmm_write   ),
	.writedata_from_the_altera_avalon_packets_to_master_inst_for_spichain   (ingr_spis_avmm_wrdata  ) 
);

assign m_avmm_ingr_slv_addr   = ingr_spis_avmm_addr[INGR_SLV_ADDR_WIDTH+1:2];
assign m_avmm_ingr_slv_write  = ingr_spis_avmm_write && (ingr_spis_avmm_addr[31:INGR_SLV_CSR_AWIDTH] != 'd0) && (ingr_spis_avmm_byteen == 4'hF);
assign m_avmm_ingr_slv_read   = ingr_spis_avmm_read  && (ingr_spis_avmm_addr[31:INGR_SLV_CSR_AWIDTH] != 'd0) && (ingr_spis_avmm_byteen == 4'hF);
assign m_avmm_ingr_slv_wrdata = ingr_spis_avmm_wrdata;
assign ingr_spis_avmm_rddata  = m_avmm_ingr_slv_rddata;
assign ingr_spis_avmm_rdvld   = m_avmm_ingr_slv_rddvld;
assign ingr_spis_avmm_waitreq = m_avmm_ingr_slv_waitreq;

//assign avmm_egrs_slv_addr     = egrs_spis_avmm_addr[EGRS_SLV_ADDR_WIDTH+1:2];
//assign avmm_egrs_slv_write    = egrs_spis_avmm_write && (egrs_spis_avmm_addr[31:EGRS_SLV_CSR_AWIDTH] != 'd0) && (egrs_spis_avmm_byteen == 4'hF);
//assign avmm_egrs_slv_read     = egrs_spis_avmm_read  && (egrs_spis_avmm_addr[31:EGRS_SLV_CSR_AWIDTH] != 'd0) && (egrs_spis_avmm_byteen == 4'hF);
//assign avmm_egrs_slv_wrdata   = egrs_spis_avmm_wrdata;
//assign egrs_spis_avmm_rddata  = avmm_egrs_slv_rddata;
//assign egrs_spis_avmm_rdvld   = avmm_egrs_slv_rddvld;
//assign egrs_spis_avmm_waitreq = avmm_egrs_slv_waitreq; 


endmodule
