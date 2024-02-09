// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef GUARD_PCIE_HIP_DEFINES_SVH
`define GUARD_PCIE_HIP_DEFINES_SVH   
   `define     PCIE_HIP                           tb_top.DUT.fpga_top.inst_fiu_top.inst_pcie0_ccib_top.pcie_hip0.pcie_a10_hip_0
   `define     SRIOV2_EN                          `PCIE_HIP.sriov2_en
   `undef      AFU_TOP_REQUIRES_LOCAL_MEMORY_AVALON_MM
   `define EXPERTIO_PCIESVC_INCLUDE_16G


   localparam SR_IOV_CAP_BASE_ADDR = 10'h230 ;
   localparam BAR0_REG_NUM  = 'h4;
   localparam BAR1_REG_NUM  = 'h5;
   localparam BAR2_REG_NUM  = 'h6;
   localparam BAR3_REG_NUM  = 'h7;
   localparam BAR4_REG_NUM  = 'h8;
   localparam BAR5_REG_NUM  = 'h9;
   /*localparam NUM_VFS_REG_NUM  =  (SR_IOV_CAP_BASE_ADDR +'hC8)/4 ;
   localparam SR_IOV_CNTRL_STATUS_REG_NUM  = (SR_IOV_CAP_BASE_ADDR +'hC0) /4 ;
   localparam PAGE_SIZE_REG_NUM  = (SR_IOV_CAP_BASE_ADDR +'hD8) /4 ;
   localparam SR_IOV_VF_BAR0_ADDR = SR_IOV_CAP_BASE_ADDR + 'hDC;
   localparam SR_IOV_VF_BAR1_ADDR = SR_IOV_CAP_BASE_ADDR + 'hE0;
   localparam SR_IOV_VF_BAR2_ADDR = SR_IOV_CAP_BASE_ADDR + 'hE4;
   localparam SR_IOV_VF_BAR3_ADDR = SR_IOV_CAP_BASE_ADDR + 'hE8;
   localparam SR_IOV_VF_BAR4_ADDR = SR_IOV_CAP_BASE_ADDR + 'hEC;
   localparam SR_IOV_VF_BAR5_ADDR = SR_IOV_CAP_BASE_ADDR + 'hF0;
   localparam SR_IOV_VF_BAR0_REG_NUM  = SR_IOV_VF_BAR0_ADDR/4;
   localparam SR_IOV_VF_BAR1_REG_NUM  = SR_IOV_VF_BAR1_ADDR/4;
   localparam SR_IOV_VF_BAR2_REG_NUM  = SR_IOV_VF_BAR2_ADDR/4;
   localparam SR_IOV_VF_BAR3_REG_NUM  = SR_IOV_VF_BAR3_ADDR/4;
   localparam SR_IOV_VF_BAR4_REG_NUM  = SR_IOV_VF_BAR4_ADDR/4;
   localparam SR_IOV_VF_BAR5_REG_NUM  = SR_IOV_VF_BAR5_ADDR/4;
   localparam SR_IOV_MSIX_CAP_POINTER  = 'h2C;*/
   //localparam  BAR0_RANGE ='h0000_0000_8000_0000; 
   //localparam  BAR2_RANGE ='h0000_0000_8010_0000; 
   //localparam  BAR4_RANGE ='h0000_0000_8020_0000; 
   //localparam  BAR0_VF0_RANGE ='h0000_0000_9000_0000; 
   //localparam  BAR2_VF0_RANGE ='h0000_0000_9010_0000; 
   //localparam  BAR4_VF0_RANGE ='h0000_0000_9020_0000;

//Testbench Defines
localparam     DATA_32BIT = 'h1;
localparam     DATA_64BIT = 'h2;
localparam     NO = 'h0;
localparam     YES = 'h1;

 

  // CSR Address Map
//------------------------------------------------------------------------------------------
// Byte Address       Attribute         Name                 Width   Comments
//     'h0000          RO                DFH                 64b     AFU Device Feature Header
//     'h0008          RO                AFU_ID_L            64b     AFU ID low 64b
//     'h0010          RO                AFU_ID_H            64b     AFU ID high 64b
//     'h0018          RsvdZ             CSR_DFH_RSVD0       64b     Mandatory Reserved 0
//     'h0020          RO                CSR_DFH_RSVD1       64b     Mandatory Reserved 1
//     'h0100          RW                CSR_SCRATCHPAD0     64b     Scratchpad register 0
//     'h0108          RW                CSR_SCRATCHPAD0     64b     Scratchpad register 2
//     'h0110          RW                CSR_AFU_DSM_BASEL   32b     Lower 32-bits of AFU DSM base address. The lower 6-bbits are 4x00 since the address is cache aligned.
//     'h0114          RW                CSR_AFU_DSM_BASEH   32b     Upper 32-bits of AFU DSM base address.
//     'h0120:         RW                CSR_SRC_ADDR        64b     Start physical address for source buffer. All read requests are targetted to this region.
//     'h0128:         RW                CSR_DST_ADDR        64b     Start physical address for destination buffer. All write requests are targetted to this region.
//     'h0130:         RW                CSR_NUM_LINES       32b     Number of cache lines
//     'h0138:         RW                CSR_CTL             32b     Controls test flow, start, stop, force completion
//     'h0140:         RW                CSR_CFG             32b     Configures test parameters
//     'h0148:         RW                CSR_INACT_THRESH    32b     inactivity threshold limit
//     'h0150          RW                CSR_INTERRUPT0      32b     SW allocates Interrupt APIC ID & Vector to device
//     

   localparam  USER_AFU = 'h40000;  
//   localparam  DFH = 'h0000;  
//   localparam  AFU_ID_L = 'h0008;  
//   localparam  AFU_ID_H = 'h0010;  
//   localparam  CSR_DFH_RSVD0 = 'h0018;  
//   localparam  CSR_DFH_RSVD1 = 'h0020;  
//   localparam  CSR_SCRATCHPAD0 = 'h0100;  
//   localparam  CSR_SCRATCHPAD1 = 'h0108;  
//   localparam  CSR_AFU_DSM_BASEL = 'h0110;  
//   localparam  CSR_AFU_DSM_BASEH = 'h0114;  
//   localparam  CSR_SRC_ADDR = 'h0120;  
//   localparam  CSR_DST_ADDR = 'h0128;  
//   localparam  CSR_NUM_LINES = 'h0130;  
//   localparam  CSR_CTL = 'h0138;  
//   localparam  CSR_CFG = 'h0140;  
//   localparam  CSR_INACT_THRESH = 'h0148;  
//   localparam  CSR_INTERRUPT0 = 'h0150; 

   localparam  M2S_DMA = USER_AFU+'h100; 
   localparam  S2M_DMA = USER_AFU+'h200; 
   localparam  NULL_DFH = USER_AFU+'h040; 
   localparam  PATTERN_CHECKER_MEM_SLAVE = USER_AFU+'h1000; 
   localparam  PATTERN_GEN_MEM_SLAVE = USER_AFU+'h2000; 
   localparam  PATTERN_CHECKER_CSR_SLAVE = USER_AFU+'h3000; 
   localparam  PATTERN_GEN_CSR_SLAVE = USER_AFU+'h3010; 
 
   localparam  M2S_DMA_BBB_DFH = 'h00;  
   localparam  M2S_DMA_DISPATCHER_CSR = 'h40;  
   localparam  M2S_DMA_DESCRIPTOR = 'h60;  
   localparam  M2S_DMA_FRONTEND = 'h80;  

   localparam  S2M_DMA_BBB_DFH = 'h00;  
   localparam  S2M_DMA_DISPATCHER_CSR = 'h40;  
   localparam  S2M_DMA_DESCRIPTOR = 'h60;  
   localparam  S2M_DMA_FRONTEND = 'h80;  
   localparam  DMA_CTRL_FMT_BLK_OWNERSHIP = 'h0;  
   localparam  DMA_SRC = 'h8;  
   localparam  DMA_DST = 'h10;  
   localparam  DMA_LENGTH = 'h18;  
   localparam  DMA_STRIDES_BURSTS_SEQ = 'h20;  
   localparam  DMA_EOP_ERROR_TRANSFER_INFO = 'h28;  


   localparam  FETCH_CONTROL = 'h00;  
   localparam  FETCH_START_LOCATION = 'h08;  
   localparam  FETCH_CURR_LOCATION = 'h10;  
   localparam  FETCH_CURR_STORE_LOCATION = 'h18;  
   localparam  DMA_STATUS = 'h20;  
   localparam  FIFO_LEVEL = 'h28; 

   // Defines for old DMA BB
   localparam  DMA_BBB_DFH = USER_AFU+ 'h20000 +'h00;  
   localparam  DMA_BBB_ID_L = USER_AFU+ 'h20000 +'h08;  
   localparam  DMA_BBB_ID_H = USER_AFU+ 'h20000 +'h10;  
   localparam  MSGDMA_CSR = USER_AFU+ 'h20000 +'h40;  
   localparam  MSGDMA_DESCRIPTOR = USER_AFU+ 'h20000 +'h60;  
   localparam  DMA_SPAN_EXTEND_CTRL = USER_AFU+ 'h20000 +'h200;  
   localparam  DMA_SPAN_EXTEND_DATA = USER_AFU+ 'h20000 +'h1000;  

   // Defines Old DMA extended descripter fields  
   localparam  LEGACY_DMA_EXT_FMT_RD_ADDR_L = 'h00;  
   localparam  LEGACY_DMA_EXT_FMT_WR_ADDR_L = 'h04;  
   localparam  LEGACY_DMA_EXT_FMT_LENGTH = 'h08;  
   localparam  LEGACY_DMA_EXT_FMT_DMA_BURSTS_SEQ = 'h0C;  
   localparam  LEGACY_DMA_EXT_FMT_DMA_STRIDES = 'h10;  
   localparam  LEGACY_DMA_EXT_FMT_RD_ADDR_U = 'h14;  
   localparam  LEGACY_DMA_EXT_FMT_WR_ADDR_U = 'h18;  
   localparam  LEGACY_DMA_EXT_FMT_CTRL = 'h1C;  
`endif 

  
