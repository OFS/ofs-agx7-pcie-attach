// *****************************************************************************
//                               INTEL CONFIDENTIAL
//
// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// *****************************************************************************
//
// Create Date : September 2020
// Module Name : axi_s_adapter
// Project     : Arror Creek (Xeon + FPGA)
// Description : Converts AXI EA to AXI SS Interface format. This block will be
//               temporarily used until the AC PCIe SS is available. Until that
//               happens we are using AXI EA PCIe SS with this block to convert
//               AXI EA format to AXI SS format so that underlying RTL can
//               comply with AC PCIe SS. 
//
// *****************************************************************************
//
// ===========================================================================================================================================================
// Notes 
// ===========================================================================================================================================================
// Length Limit 256 Bytes per req
// Tag restricted to 8 bits because PCIe supports that.
//
// When there are back to back MMIO requests on the same cycle, the PCIe checker will delay the MMIO request on channel 1 to the next cycle. 
// So you won't see two MMIO requests on the AXIS RX interface.
//
// The only scenarios where you could have two SOPs on AXI-S RX is when you have :
//   - SOP of a MMIO request on channel 0, and a CPLD SOP on channel 1, or vice versa
//   - SOP of a CPLD on channel 0 (followed by EOP) and SOP of another CPLD on channel 1 that is not ending on the same cycle.
//
// RX Path   
// - The axi_ea_rx_q has a ready allowance of AXI_EA_Q_FULL_TH = 4. This means it can accept 4 cycles once full is asserted. 
// - There are 2 FIFOs, 1 for each channel. Both FIFO's are written into if the valid is high. So it is possible to have anvalid entry at [0] but not an [1] 
//   in any given clock cycle. (and vice versa)
// - ea_ser_q is the serialization FIFO. It is a quad port FIFO(2 i/p, 2 o/p). Entries from axi_ea_rx_q enter ea_ser_q based on whether they are valid or not. 
//   Invalid entries get filtered out at this stage. 
// - The output from ea_ser_q drives the downstream output. Whether we read 1 or both output ports depends on where there is an SOP/EOP or data. This is
//   because in the case of an SOP on [0], only 0 can be read becase the header will consume 256 bits and it's accompanying data will consume the remaining 
//   256 bits of the st_rx_tdata bus. The different combinations are considered in a case statement and ea_ser_q is read accordingly. 
//    
// TX Path
// - The axi_ea_tx_q stores all upstream traffic coming from the st_tx_* interface. There are 2 FIFOs, one for each AXI EA channel. Conversion from AXI AC to 
//   AXI EA format happens at the input of the FIFO. 
// - The tx_state state machine consideres various combinations of SOP/EOP and data while loading the FIFOs. 
//  
// ===========================================================================================================================================================
//
//                  axi_ea_rx_tvalid                                                                                  
//                                                                                                                    
//                         |                                                                                          
//                         |                                                                                          
//                         |                                                                                          
//                        \/                                                                                          
//            +------------------------+                                                 axi_ea_tx_tvalid             
//  tuser[1]  |                        |  tuser[0]                                                                    
//  tdata[1]  |                        |  tdata[0]                                              ^                     
//           \/                       \/                                                        |                     
//       +--------+               +--------+                                                    |                     
//       |axi_ea  |               |axi_ea  |                                                    |                     
//       |_rx_q_1 |               |_rx_q_0 |                                   +----------------|----------------+    
//       |        |               |        |                                   |                                 |    
//       |        |               |        |                                   |   Decode & Realignment Block    |    
//       |        |               |        |                                   |                                 |    
//       +----|---+               +----|---+                                   +--------------------------------+     
//            |                        |                                           ^                         ^        
//            |                        |                                           |                         |        
//            |      +--------+        |                                       +---|----+               +----|---+    
//            +----->|ea_rx   |<-------+                                       |axi_ea  |               |axi_ea  |    
//                   |_ser_q  |                                                |_tx_q_1 |               |_tx_q_0 |    
//                   |        |                                                |        |               |        |    
//                   |        |                                                |        |               |        |    
//              +-----        -----+                                           |        |               |        |    
//              |    +--------+    |                                           +--------+               +--------+    
//              |                  |                                                ^                        ^        
//              |                  |                                                |                        |        
//             \/                 \/                                                |                        |        
//        +------------------------------+                                          +------------------------+        
//        |                              |                                                       ^                    
//        |  Decode & Realignment Block  |                                                       |                    
//        |                              |                                                       |                    
//        +---------------|--------------+                                                       |                    
//                        |                                                                st_tx_tvalid               
//                        |                                                                                           
//                       \/                                                                                           
//                   st_rx_tvalid                                                                                     
//
// ===========================================================================================================================================================
// 
// Done: Byte Count 
// Done: Request ID RAM
// Done: TX Tuser bits on IOFS EA interface is different from RX. Not fixed for
//       uniformity in TX/RX direction. 2:0 used in pcie_top. 
// Done: FLR
//       Handled outside this adapter. 
// Done: Questions for Vaibhav: 1. DMRd[20] and DMWr[60] So read/writes will always use 64 bit addressing ?
//       Yes. Requests from HEs will always be DM_RD/DM_WR. This adapter checks address and decides which (3DW or 4DW) Fmttype and format to use.
// Done: Request ID is saved on oncoming request from Host. Returned back with completion.
// Done: What is slot number ? 
//       For multiple PCIe slots. Always kept 0.
// FUTURE_IMPROVEMENT: EA VF is 13b while IOFS SS is 11b. Wassup ? 
//                         
// ===========================================================================================================================================================

`include "vendor_defines.vh"

module axi_s_adapter #(  
  parameter        PASSTHRU_MODE   = 0,
  
  parameter        PU_CPL          = PASSTHRU_MODE,

  parameter        UNIQUE_TAG_WA   = 0,
  
  parameter        EA_CH           = 2,
  parameter        AXI_EA_DATA_W   = 392,
  parameter        AXI_EA_USER_W   = 24,

  parameter        SS_USER_W       = 2,
  parameter        SS_DATA_W       = 512,
  localparam       SS_KEEP_W       = SS_DATA_W/8,

  parameter        NUM_PF          = 4, //Number of PFs
  parameter        NUM_VF          = 3  //Number of VFs
)
(
  input  logic                     clk,
  input  logic                     resetb,

  output logic                     axi_ea_rx_tready,
  input  logic                     axi_ea_rx_tvalid,
  input  logic                     axi_ea_rx_tlast,
  input  logic [AXI_EA_USER_W-1:0] axi_ea_rx_tuser [EA_CH-1:0],
  input  logic [AXI_EA_DATA_W-1:0] axi_ea_rx_tdata [EA_CH-1:0],
  
  input  logic                     axi_ea_tx_tready,
  output logic                     axi_ea_tx_tvalid,
  output logic                     axi_ea_tx_tlast,
  output logic [AXI_EA_USER_W-1:0] axi_ea_tx_tuser [EA_CH-1:0], //[2:0] are used
  output logic [AXI_EA_DATA_W-1:0] axi_ea_tx_tdata [EA_CH-1:0],

  input  logic                     st_rx_tready,
  output logic                     st_rx_tvalid,
  output logic                     st_rx_tlast,
  output logic [SS_USER_W-1:0]     st_rx_tuser_vendor,
  output logic [SS_DATA_W-1:0]     st_rx_tdata,
  output logic [SS_KEEP_W-1:0]     st_rx_tkeep,

  output logic                     st_tx_tready,
  input  logic                     st_tx_tvalid,
  input  logic                     st_tx_tlast,
  input  logic [SS_USER_W-1:0]     st_tx_tuser_vendor,
  input  logic [SS_DATA_W-1:0]     st_tx_tdata,
  input  logic [SS_KEEP_W-1:0]     st_tx_tkeep
);

  localparam TX_PASSTHRU       = PASSTHRU_MODE;
  localparam RX_PASSTHRU       = PASSTHRU_MODE;

  localparam EA_DATA_VALID     = 0;                      // 0
  localparam EA_DATA_SOP       = EA_DATA_VALID + 1;      // 1
  localparam EA_DATA_EOP       = EA_DATA_SOP + 1;        // 2
  localparam EA_DATA_RSVD_L    = EA_DATA_EOP + 1;        // 3
  localparam EA_DATA_RSVD_H    = EA_DATA_EOP + 5;        // 7
  localparam EA_DATA_HDR_L     = EA_DATA_RSVD_H + 1;     // 8
  localparam EA_DATA_HDR_H     = EA_DATA_RSVD_H + 128;   // 135
  localparam EA_DATA_PYLD_L    = EA_DATA_HDR_H + 1;      // 136
  localparam EA_DATA_PYLD_H    = EA_DATA_HDR_H + 256;    // 391
  //User vendor bit
  localparam EA_DATA_MODE      = EA_DATA_PYLD_H + 1;     // 392
  localparam EA_FC_BIT         = EA_DATA_PYLD_H + 2;     // 393
  localparam EA_DATA_VF_ACTIVE = EA_DATA_PYLD_H + 3 ;    // 394
 

  //RX Specific parameters
  localparam EA_DATA_PFN_L     = EA_DATA_VF_ACTIVE + 1;  // 395  
  localparam EA_DATA_PFN_H     = EA_DATA_VF_ACTIVE + 3;  // 397
  localparam EA_DATA_VFN_L     = EA_DATA_PFN_H + 1;      // 398
  localparam EA_DATA_VFN_H     = EA_DATA_PFN_H + 13;     // 410
  localparam EA_DATA_BAR_L     = EA_DATA_VFN_H + 1;      // 411 
  localparam EA_DATA_BAR_H     = EA_DATA_VFN_H + 3;      // 413
  localparam EA_DATA_UMMIO_RD  = EA_DATA_BAR_H + 1;      // 414
  localparam EA_DATA_MMIO_REQ  = EA_DATA_UMMIO_RD + 1;   // 415
  localparam EA_DATA_LAST      = EA_DATA_MMIO_REQ + 1;   // 416

  //TX Specific parameters
  localparam EA_DATA_TX_AFU_IRQ         = EA_DATA_PYLD_H + 3;             //394
  localparam EA_DATA_TX_AFU_PORT_CSR_WR = EA_DATA_TX_AFU_IRQ + 1;         //395
  localparam EA_DATA_TX_VF_ACTIVE       = EA_DATA_TX_AFU_PORT_CSR_WR + 1; //396
  localparam EA_DATA_TX_LAST            = EA_DATA_TX_VF_ACTIVE + 1;       //397

  //PCIe TLP Header  (First 2 DWs. The 2nd and 3rd depend on the type)
  localparam FIRST_DW_BE_L = 64;                 // 64 
  localparam FIRST_DW_BE_H = FIRST_DW_BE_L + 3;  // 67
  localparam LAST_DW_BE_L  = FIRST_DW_BE_H + 1;  // 68 
  localparam LAST_DW_BE_H  = FIRST_DW_BE_H + 4;  // 71
  localparam TAG_L         = LAST_DW_BE_H + 1;   // 72
  localparam TAG_H         = LAST_DW_BE_H + 8;   // 79
  localparam REQ_ID_L      = TAG_H + 1;          // 80    
  localparam REQ_ID_H      = TAG_H + 16;         // 95
  localparam LENGTH_L      = REQ_ID_H + 1;       // 96
  localparam LENGTH_H      = REQ_ID_H + 10;      // 105
  localparam AT_L          = LENGTH_H + 1;       // 106
  localparam AT_H          = LENGTH_H + 2;       // 107
  localparam ATTR_0        = AT_H + 1;           // 108
  localparam ATTR_1        = ATTR_0 + 1;         // 109
  localparam EP            = ATTR_1 + 1;         // 110
  localparam TD            = EP + 1;             // 111
  localparam TH            = TD + 1;             // 112
  localparam LN            = TH + 1;             // 113
  localparam ATTR_2        = LN + 1;             // 114
  localparam TAG_8         = ATTR_2 + 1;         // 115
  localparam TC_L          = TAG_8 + 1;          // 116
  localparam TC_H          = TAG_8 + 3;          // 118
  localparam TAG_9         = TC_H + 1;           // 119
  localparam FMTTYPE_L     = TAG_9 + 1;          // 120
  localparam FMTTYPE_H     = TAG_9 + 8;          // 127  

  //PCIe SS Interface
  localparam SS_TDATA_L    = 0;                      // 0
  localparam SS_TDATA_H    = SS_TDATA_L + 511;       // 511
  localparam SS_TKEEP_L    = SS_TDATA_H + 1;         // 512
  localparam SS_TKEEP_H    = SS_TDATA_H + SS_KEEP_W; // 575
  localparam SS_TUSER_L    = SS_TKEEP_H + 1;         // 576
  localparam SS_TUSER_H    = SS_TKEEP_H + SS_USER_W; // 585
  localparam SS_TLAST      = SS_TUSER_H + 1;         // 586

  //EA FIFO paramaters
  localparam AXI_EA_Q_W        = 1 + AXI_EA_USER_W + AXI_EA_DATA_W ; //+1 for tlast
  localparam AXI_EA_Q_D_B2     = 4;  
  localparam AXI_EA_Q_FULL_TH  = 4;  
  
  //EA SER FIFO paramaters
  localparam EA_SER_Q_W        = AXI_EA_Q_W; 
  localparam EA_SER_Q_D_B2     = 5;  
  localparam EA_SER_Q_FULL_TH  = (2**EA_SER_Q_D_B2) - 8; 

  //PCIe SS FIFO parameters
  localparam SS_DATA_Q_W       = 1 + SS_USER_W + SS_KEEP_W + SS_DATA_W ; //+1 for tlast
  localparam SS_DATA_Q_D_B2    = 4;
  localparam SS_DATA_Q_FULL_TH = 4;

  localparam NUM_TAGS    = 256; //8-bit tag supported by EA
  localparam NUM_TAGS_B2 = $clog2(NUM_TAGS);

  localparam PF_W              = (NUM_PF > 1) ? $clog2(NUM_PF) : 1;
  localparam VF_W              = (NUM_VF > 1) ? $clog2(NUM_VF) : 1;

  //Header format RAM parameters
  localparam HDR_FORMAT_W      = 1;                             // {0-PU/1-DM)
  localparam HDR_FORMAT_D_B2   = 1 + PF_W + VF_W + NUM_TAGS_B2; // Extra bit needed for PF0

  //TX States
  localparam SOP  = 0;
  localparam DATA = 1;

  // ---------------------------------------------------------------------------
  // AXI EA INPUT QUEUEs
  // ---------------------------------------------------------------------------
  logic [AXI_EA_Q_W-1:0]   axi_ea_rx_din   [EA_CH-1:0] ;//
  logic [EA_CH-1:0]        axi_ea_rx_wen               ;//
  logic [EA_CH-1:0]        axi_ea_rx_ren               ;//
  logic [AXI_EA_Q_W-1:0]   axi_ea_rx_dout  [EA_CH-1:0] ;//
  logic [EA_CH-1:0]        axi_ea_rx_full              ;//
  logic [EA_CH-1:0]        axi_ea_rx_nemp              ;//
  logic [1:0]              axi_ea_rx_ecc   [EA_CH-1:0] ;//
  logic [EA_CH-1:0]        axi_ea_rx_err               ;//


  // ---------------------------------------------------------------------------
  // AXI EA SERIAL QUEUE
  // ---------------------------------------------------------------------------
  logic  [EA_SER_Q_W-1:0]  ea_ser_din  [1:0] ;//
  logic  [1:0]             ea_ser_wen        ;//
  logic  [1:0]             ea_ser_ren        ;//
  logic  [EA_SER_Q_W-1:0]  ea_ser_dout [1:0] ;//
  logic  [1:0]             ea_ser_nemp       ;//
  logic                    ea_ser_full       ;//
  logic                    ea_ser_err        ;//
  logic                    ea_ser_perr       ;//

  // ---------------------------------------------------------------------------
  // AXI EA OUTPUT QUEUEs
  // ---------------------------------------------------------------------------
  logic [AXI_EA_Q_W-1:0]   axi_ea_tx_din   [EA_CH-1:0] ;//
  logic [EA_CH-1:0]        axi_ea_tx_wen               ;//
  logic [EA_CH-1:0]        axi_ea_tx_ren               ;//
  logic [AXI_EA_Q_W-1:0]   axi_ea_tx_dout  [EA_CH-1:0] ;//
  logic [EA_CH-1:0]        axi_ea_tx_full              ;//
  logic [EA_CH-1:0]        axi_ea_tx_nemp              ;//
  logic [1:0]              axi_ea_tx_ecc   [EA_CH-1:0] ;//
  logic [EA_CH-1:0]        axi_ea_tx_err               ;//

  // ---------------------------------------------------------------------------
  // PCIe SS TX INPUT PIPE
  // ---------------------------------------------------------------------------
  logic                    st_tx_tvalid_T1       ;
  logic                    st_tx_tlast_T1        ;
  logic [SS_USER_W-1:0]    st_tx_tuser_vendor_T1 ;
  logic [SS_DATA_W-1:0]    st_tx_tdata_T1        ;
  logic [SS_KEEP_W-1:0]    st_tx_tkeep_T1        ;

  logic                    st_tx_tvalid_T2       ;
  logic                    st_tx_tlast_T2        ;
  logic [SS_USER_W-1:0]    st_tx_tuser_vendor_T2 ;
  logic [SS_DATA_W-1:0]    st_tx_tdata_T2        ;
  logic [SS_KEEP_W-1:0]    st_tx_tkeep_T2        ;

  // ---------------------------------------------------------------------------
  // PCIe SS RX OUTPUT PIPE
  // ---------------------------------------------------------------------------
  logic                    st_rx_tready_p;
  logic                    st_rx_tvalid_p;
  logic                    st_rx_sop_p;
  logic                    st_rx_tlast_p;
  logic [SS_USER_W-1:0]    st_rx_tuser_vendor_p;
  logic [SS_DATA_W-1:0]    st_rx_tdata_p;
  logic [SS_KEEP_W-1:0]    st_rx_tkeep_p;

  logic                    st_rx_tready_p1;
  logic                    st_rx_tvalid_p1;
  logic                    st_rx_sop_p1;
  logic                    st_rx_tlast_p1;
  logic [SS_USER_W-1:0]    st_rx_tuser_vendor_p1;
  logic [SS_DATA_W-1:0]    st_rx_tdata_p1;
  logic [SS_KEEP_W-1:0]    st_rx_tkeep_p1;

  logic                    st_rx_tready_p2;
  logic                    st_rx_tvalid_p2;
  logic                    st_rx_tlast_p2;
  logic [SS_USER_W-1:0]    st_rx_tuser_vendor_p2;
  logic [SS_DATA_W-1:0]    st_rx_tdata_p2;
  logic [SS_KEEP_W-1:0]    st_rx_tkeep_p2;

  logic [SS_USER_W-1:0]    st_rx_tuser_vendor_p3;
  
  // ---------------------------------------------------------------------------
  // AXI EA TX OUTPUT 
  // ---------------------------------------------------------------------------
  logic                     axi_ea_tx_tready_p;
  logic                     axi_ea_tx_tvalid_p;
  logic                     axi_ea_tx_tlast_p;
  logic [AXI_EA_USER_W-1:0] axi_ea_tx_tuser_p [EA_CH-1:0];
  logic [AXI_EA_DATA_W-1:0] axi_ea_tx_tdata_p [EA_CH-1:0];


  // ---------------------------------------------------------------------------
  // AXI EA OUTPUT QUEUEs
  // ---------------------------------------------------------------------------
  logic [15:0]             req_id_din  ;  //Request ID width
  logic [NUM_TAGS_B2-1:0]  req_id_wad  ;  //Width for 256 Tags
  logic                    req_id_wen  ;
  logic [NUM_TAGS_B2-1:0]  req_id_rad  ; 
  logic                    req_id_ren  ; 
  logic [15:0]             req_id_dout ;
  logic                    req_id_perr ;

  // ---------------------------------------------------------------------------
  // HDR FORMAT RAM
  // ---------------------------------------------------------------------------
  logic [HDR_FORMAT_W-1:0]     hdr_format_din  ;  //
  logic [HDR_FORMAT_D_B2-1:0]  hdr_format_wad  ;  //
  logic                        hdr_format_wen  ;
  logic [HDR_FORMAT_D_B2-1:0]  hdr_format_rad  ; 
  logic [HDR_FORMAT_W-1:0]     hdr_format_dout ;
  logic [HDR_FORMAT_D_B2-1:0]  hdr_func_wr_addr;
  logic [HDR_FORMAT_D_B2-1:0]  hdr_func_rd_addr;
  logic [HDR_FORMAT_D_B2-1:0]  hdr_format_rad_reg  ; 


  // ---------------------------------------------------------------------------
  // AXI TX variables
  // ---------------------------------------------------------------------------
  logic         tx_state, next_tx_state;
  logic [127:0] ea_ser_hdr [1:0];

  integer i, j;

  // ---------------------------------------------------------------------------
  // Write to EA AXI RX FIFOs
  // ---------------------------------------------------------------------------
  always @ (posedge clk)
  begin
    for(i=0; i<EA_CH; i++)
    begin
      //Both FIFOs are written if tvalid is high
      axi_ea_rx_wen[i] <= axi_ea_rx_tvalid & axi_ea_rx_tready;
      axi_ea_rx_din[i] <= {axi_ea_rx_tlast, axi_ea_rx_tuser[i], axi_ea_rx_tdata[i]};
    end
  end

  assign axi_ea_rx_tready = !(|axi_ea_rx_full);


  // ---------------------------------------------------------------------------
  // Read EA AXI RX FIFOs
  // Write to EA SER FIFO (RX Output FIFO)
  // ---------------------------------------------------------------------------
  always_comb
  begin
    ea_ser_wen[0] = 1'b0;
    ea_ser_wen[1] = 1'b0;
	ea_ser_din[0] = {AXI_EA_Q_W{1'b0}};
    ea_ser_din[1] = {AXI_EA_Q_W{1'b0}};
	 
    axi_ea_rx_ren[0] = 1'b0; 
    axi_ea_rx_ren[1] = 1'b0;

    // Checking only 0 because both get written together i.e. both will either be 
    // empty or not empty.
    if(axi_ea_rx_nemp[0] & !ea_ser_full) 
    begin
      case({axi_ea_rx_dout[1][EA_DATA_VALID], axi_ea_rx_dout[0][EA_DATA_VALID]})
        2'b00:
        begin
          //Not possible
        end

        2'b01:
        begin
          //Either EOP in [0] or SOP+EOP in [0] 
          ea_ser_wen[0] = 1'b1;
          ea_ser_din[0] = axi_ea_rx_dout[0];
          axi_ea_rx_ren[0] = 1'b1; 
          axi_ea_rx_ren[1] = 1'b1;
        end

        2'b10:
        begin
          //Either SOP or SOP+EOP in [1]
          ea_ser_wen[0] = 1'b1;
          ea_ser_din[0] = axi_ea_rx_dout[1];
          axi_ea_rx_ren[0] = 1'b1;
          axi_ea_rx_ren[1] = 1'b1;
        end

        2'b11:
        begin
          //SOP[0] and EOP[1]
          //SOP+EOP[0] and SOP+EOP[1]
          //EOP[0] and SOP[1]
          //Data[0] and Data[1]
          ea_ser_wen[0] = 1'b1;
          ea_ser_wen[1] = 1'b1;
          ea_ser_din[0] = axi_ea_rx_dout[0];
          ea_ser_din[1] = axi_ea_rx_dout[1];
          axi_ea_rx_ren[0] = 1'b1;
          axi_ea_rx_ren[1] = 1'b1;
        end
      endcase
    end //if
  end //always

  // ---------------------------------------------------------------------------
  // Read EA SER FIFO (RX Output FIFO) and decipher SOP,EOP and Data Phases
  // Drive on SS AXI streaming signals
  // Header translation happens a cycle later because 1 cycle is needed for
  // format RAM lookup.
  // ---------------------------------------------------------------------------
  assign ea_ser_hdr[0] = ea_ser_dout[0][EA_DATA_HDR_H:EA_DATA_HDR_L];
  assign ea_ser_hdr[1] = ea_ser_dout[1][EA_DATA_HDR_H:EA_DATA_HDR_L];

  always_comb
  begin
    st_rx_tvalid_p       = 1'b0;
    st_rx_tlast_p        = 1'b0;
    st_rx_sop_p          = 1'b0;
    st_rx_tkeep_p        = {SS_KEEP_W{1'b1}};
    st_rx_tuser_vendor_p = 2'b00;             
    st_rx_tdata_p        = {SS_DATA_W{1'b0}};

    ea_ser_ren[0] = 0;
    ea_ser_ren[1] = 0;

    if(ea_ser_nemp[0])
    begin
      if(ea_ser_dout[0][EA_DATA_SOP])
      begin
        //Read only Port 0. SOP + Data(if any) will consume 512b
        ea_ser_ren[0] = st_rx_tready_p;
        //Drive SOP
        st_rx_tvalid_p        = ea_ser_ren[0];
        st_rx_tdata_p[255:0]  = {ea_ser_dout[0][EA_DATA_BAR_H:EA_DATA_VF_ACTIVE], ea_ser_hdr[0]}; //{bar,vf,pf,vfa,hdr}
        st_rx_sop_p           = 1'b1;

        // If FC bit is set, make remaining byte_cont=0, such that 
        st_rx_tuser_vendor_p[1]  = ea_ser_dout[0][EA_FC_BIT];
       // if(RX_PASSTHRU)
        st_rx_tuser_vendor_p[0]  = ea_ser_dout[0][EA_DATA_MODE]; //user mode
       // else
      //  if(ea_ser_hdr[0][FMTTYPE_L+:4] == 4'ha) //Cpl/CplD
      //    st_rx_tuser_vendor_p  = 2'b01; //Data Mover Mode
      //  else //Requests
       //   st_rx_tuser_vendor_p  = 2'b00; //Power user mode

        st_rx_tdata_p[511:256]  = ea_ser_dout[0][EA_DATA_PYLD_H:EA_DATA_PYLD_L];

        if(ea_ser_dout[0][EA_DATA_EOP])
          st_rx_tlast_p = 1'b1;
      end
      else if(ea_ser_dout[0][EA_DATA_EOP])
      begin
        //Read Port 0
        //Fill 256b
        //Drive EOP, tlast
        ea_ser_ren[0]          = st_rx_tready_p;
        st_rx_tvalid_p         = ea_ser_ren[0];
        st_rx_tdata_p[255:0]   = ea_ser_dout[0][EA_DATA_PYLD_H:EA_DATA_PYLD_L];
        st_rx_tdata_p[511:256] = 0;
        st_rx_tlast_p          = 1'b1;
        st_rx_tkeep_p          = {32'h0, {32{1'b1}}};
      end
      else //Data on [0]
      begin
        //Read Port 0 and Port 1
        //Drive 512b Data
        ea_ser_ren[0]           = st_rx_tready_p & (ea_ser_nemp[0] & ea_ser_nemp[1]);
        ea_ser_ren[1]           = st_rx_tready_p & (ea_ser_nemp[0] & ea_ser_nemp[1]);
        st_rx_tvalid_p          = ea_ser_ren[0]; 
        st_rx_tdata_p[255:0]    = ea_ser_dout[0][EA_DATA_PYLD_H:EA_DATA_PYLD_L];
        st_rx_tdata_p[511:256]  = ea_ser_dout[1][EA_DATA_PYLD_H:EA_DATA_PYLD_L];

        if(ea_ser_dout[1][EA_DATA_EOP])
          st_rx_tlast_p = 1'b1;
      end
    end //if (ea_ser_nemp[0])
  end //always_comb

  //Register stage to create 1 clk delay for Header RAM look-up
  axis_register #( 
    .MODE(0), .ENABLE_TKEEP(1), .ENABLE_TLAST(1), .ENABLE_TUSER(1),
    .TDATA_WIDTH(SS_DATA_W+1), .TUSER_WIDTH(SS_USER_W)
  )  
  axi_ss_rx_reg (
    .clk      ( clk                           ),
    .rst_n    ( resetb                        ),

    .s_tready ( st_rx_tready_p                ),  
    .s_tvalid ( st_rx_tvalid_p                ),  
    .s_tdata  ( {st_rx_sop_p, st_rx_tdata_p}  ),  
    .s_tkeep  ( st_rx_tkeep_p                 ),  
    .s_tlast  ( st_rx_tlast_p                 ),   
    .s_tid    (                               ), 
    .s_tdest  (                               ),  
    .s_tuser  ( st_rx_tuser_vendor_p          ),  
    
    .m_tready ( st_rx_tready_p1               ), 
    .m_tvalid ( st_rx_tvalid_p1               ),
    .m_tdata  ( {st_rx_sop_p1,st_rx_tdata_p1} ),
    .m_tkeep  ( st_rx_tkeep_p1                ),
    .m_tlast  ( st_rx_tlast_p1                ),
    .m_tid    (                               ),
    .m_tdest  (                               ),
    .m_tuser  ( st_rx_tuser_vendor_p1         )
  );

  // Header translation
  // Conversion of EA AXI format to AC AXI Format
  always @ (posedge clk)
  begin
    st_rx_tuser_vendor_p3       <= st_rx_tuser_vendor_p2;
  end
  
  always_comb
  begin
    st_rx_tready_p1 = st_rx_tready_p2;
    st_rx_tvalid_p2 = st_rx_tvalid_p1;
    st_rx_tdata_p2  = st_rx_tdata_p1;

    st_rx_tkeep_p2        = st_rx_tkeep_p1;
    st_rx_tlast_p2        = st_rx_tlast_p1;
    st_rx_tuser_vendor_p2 = st_rx_tuser_vendor_p3;

    //Header translation on SOP
    if(st_rx_sop_p1)
    begin
      if(st_rx_tdata_p1[FMTTYPE_L+:4] == 4'ha) //Cpl
      begin
        st_rx_tdata_p2[255:0] = hdr_format_dout ? rx_dm_cpl_packer(st_rx_tdata_p1[255:0]) : 
                                                  rx_pu_cpl_packer(st_rx_tdata_p1[255:0]) ;
    
        st_rx_tuser_vendor_p2 = hdr_format_dout ? 2'b01 : 2'b00;
      end
      else if((st_rx_tdata_p1[FMTTYPE_L+:8] == 8'h70) || (st_rx_tdata_p1[FMTTYPE_L+:8] == 8'h72) || (st_rx_tdata_p1[FMTTYPE_L+:8] == 8'h73)) //MsgD
      begin
        st_rx_tdata_p2[255:0] = rx_pu_msgD_packer(st_rx_tdata_p1[255:0]) ;

        st_rx_tuser_vendor_p2 = 2'b00;
      end
      else //Req
      begin
        st_rx_tdata_p2[255:0] = (st_rx_tuser_vendor_p1[0]) ? rx_dm_req_packer(st_rx_tdata_p1[255:0]) : 
                                                             rx_pu_req_packer(st_rx_tdata_p1[255:0]) ;
    
        st_rx_tuser_vendor_p2 = st_rx_tuser_vendor_p1;
      end
    end
  end

  //Output Register
  axis_register #( 
    .MODE(0), .ENABLE_TKEEP(1), .ENABLE_TLAST(1), .ENABLE_TUSER(1),
    .TDATA_WIDTH(SS_DATA_W), .TUSER_WIDTH(SS_USER_W)
  )  
  axi_ss_rx_reg1 (
    .clk      (clk                  ),
    .rst_n    (resetb               ),

    .s_tready (st_rx_tready_p2      ),  
    .s_tvalid (st_rx_tvalid_p2      ),  
    .s_tdata  (st_rx_tdata_p2       ),  
    .s_tkeep  (st_rx_tkeep_p2       ), 
    .s_tlast  (st_rx_tlast_p2       ),   
    .s_tid    (                     ), 
    .s_tdest  (                     ),  
    .s_tuser  (st_rx_tuser_vendor_p2),  
    
    .m_tready (st_rx_tready        ), 
    .m_tvalid (st_rx_tvalid        ),
    .m_tdata  (st_rx_tdata         ),
    .m_tkeep  (st_rx_tkeep         ),
    .m_tlast  (st_rx_tlast         ),
    .m_tid    (                    ),
    .m_tdest  (                    ),
    .m_tuser  (st_rx_tuser_vendor  )
  );

  // ---------------------------------------------------------------------------
  // Save Request ID in RAM
  // ---------------------------------------------------------------------------
  always_comb
  begin
    req_id_wen = 1'b0;
    req_id_ren = 1'b0;
    req_id_wad = ea_ser_hdr[0][TAG_H:TAG_L]; 
    req_id_din = ea_ser_hdr[0][REQ_ID_H:REQ_ID_L];

    //Write to RAM during requests to AFU
    if( (ea_ser_ren[0] && ea_ser_dout[0][EA_DATA_SOP]) & 
        (ea_ser_dout[0][135:128] == 8'h00 | ea_ser_dout[0][135:128] == 8'h20 | // MRd
         ea_ser_dout[0][135:128] == 8'h4c | ea_ser_dout[0][135:128] == 8'h6c | // FetchAdd
         ea_ser_dout[0][135:128] == 8'h4d | ea_ser_dout[0][135:128] == 8'h6d | // SWAP
         ea_ser_dout[0][135:128] == 8'h4e | ea_ser_dout[0][135:128] == 8'h6e)  // CAS
      )
    begin
      req_id_wen = 1'b1;
    end

    //Read RAM during AFU completions
    if ( st_tx_tuser_vendor_T1[0] == 1'b0 ) //PU Cpl Format
      req_id_rad = st_tx_tdata_T1[79:72];   //Tag[7:0]. [9:8] are don't care because they are not supported by EA
    else //DM Cpl format     
      req_id_rad = st_tx_tdata_T1[125:118]; //Tag[7:0]. [9:8] are don't care because they are not supported by EA

    req_id_ren = axi_ea_tx_din[1][EA_DATA_VALID] & axi_ea_tx_din[1][EA_DATA_SOP];
  end

  // ---------------------------------------------------------------------------
  // Save Format Type (PU/DM) in RAM
  // ---------------------------------------------------------------------------
  always_comb
  begin
    hdr_format_wen   = 1'b0;
    hdr_func_wr_addr = 'h0;
    hdr_func_wr_addr = (st_tx_tdata_T2[174]) ? {st_tx_tdata_T2[163+:VF_W]+st_tx_tdata_T2[174],st_tx_tdata_T2[160+:PF_W]} : 
                                               {'0, st_tx_tdata_T2[160+:PF_W]}                                          ;   
    
    //{VF+VFA,PF}
    hdr_format_wad   = {hdr_func_wr_addr, st_tx_tdata_T2[47:40]}; //VF,PF,Tag
    hdr_format_din   = st_tx_tuser_vendor_T2[0];

    //Write during AFU TX request 
    if(st_tx_tvalid_T2 & (tx_state == SOP) &
       (st_tx_tdata_T2[31:24] == 8'h00 | st_tx_tdata_T2[31:24] == 8'h20 | // MRd
        st_tx_tdata_T2[31:24] == 8'h4c | st_tx_tdata_T2[31:24] == 8'h6c | // FetchAdd
        st_tx_tdata_T2[31:24] == 8'h4d | st_tx_tdata_T2[31:24] == 8'h6d | // SWAP
        st_tx_tdata_T2[31:24] == 8'h4e | st_tx_tdata_T2[31:24] == 8'h6e)) // CAS
    begin
      hdr_format_wen = 1'b1;
    end

    //Read Address provided when completion is received from host
    hdr_func_rd_addr = st_rx_tdata_p[128] ? {st_rx_tdata_p[132+:VF_W]+st_rx_tdata_p[128],st_rx_tdata_p[129+:PF_W]} : 
                                            {'0, st_rx_tdata_p[129+:PF_W]}                                        ;

    if(UNIQUE_TAG_WA)
      hdr_format_rad = (st_rx_tready_p & st_rx_sop_p) ? {hdr_func_rd_addr, 2'b00, st_rx_tdata_p[45:40]} : hdr_format_rad_reg;  //VF,PF,Tag   
    else
      hdr_format_rad = (st_rx_tready_p & st_rx_sop_p) ? {hdr_func_rd_addr, st_rx_tdata_p[47:40]}        : hdr_format_rad_reg;  //VF,PF,Tag   
  end

  always @ (posedge clk)
  begin
    hdr_format_rad_reg <= hdr_format_rad;
  end

  // ---------------------------------------------------------------------------
  // TX Pipelining
  // ---------------------------------------------------------------------------
  hf_pipe # (
    .WIDTH($bits({st_tx_tvalid, st_tx_tdata, st_tx_tkeep, st_tx_tlast, st_tx_tuser_vendor})),
    .DEPTH(2)
  )
  st_tx_reg (
    .clk  (clk),
    .Din  ({(st_tx_tvalid & st_tx_tready), st_tx_tdata,     st_tx_tkeep,     st_tx_tlast,     st_tx_tuser_vendor  }),
    .Qout ({st_tx_tvalid_T1,               st_tx_tdata_T1,  st_tx_tkeep_T1,  st_tx_tlast_T1,  st_tx_tuser_vendor_T1})
  );

  always @ (posedge clk)
  begin
    st_tx_tvalid_T2       <= st_tx_tvalid_T1;        
    st_tx_tlast_T2        <= st_tx_tlast_T1;       
    st_tx_tuser_vendor_T2 <= st_tx_tuser_vendor_T1;
    st_tx_tdata_T2        <= st_tx_tdata_T1;       
    st_tx_tkeep_T2        <= st_tx_tkeep_T1;       
  end


  // ---------------------------------------------------------------------------
  // EA Tx FIFO Write ( DMRd, DMWr, Cpl/CplD(MMIO) )
  // Write to both axi_ea_tx FIFOs even if only 1 segment of data is available
  // ---------------------------------------------------------------------------
  always_comb
  begin
    axi_ea_tx_wen[0] = 1'b0;
    axi_ea_tx_din[0] = {AXI_EA_Q_W{1'b0}};
    axi_ea_tx_wen[1] = 1'b0;
    axi_ea_tx_din[1] = {AXI_EA_Q_W{1'b0}};

    case(tx_state)
      // Channel 0 valid  = 0
      // Channel 1 gets SOP Header + 256 Byte payload = 1 full tx req from st_tx_*
      SOP:
      begin
        if(st_tx_tvalid_T2)
        begin
          axi_ea_tx_wen[0] = 1'b1;
          axi_ea_tx_wen[1] = 1'b1;

          axi_ea_tx_din[0][EA_DATA_VALID]                 = 1'b0;

          axi_ea_tx_din[1][EA_DATA_VALID]                 = 1'b1;
          axi_ea_tx_din[1][EA_DATA_SOP]                   = 1'b1;
          axi_ea_tx_din[1][EA_DATA_EOP]                   = st_tx_tlast_T2;
          axi_ea_tx_din[1][EA_DATA_TX_LAST]               = st_tx_tlast_T2;
          axi_ea_tx_din[1][EA_DATA_RSVD_H:EA_DATA_RSVD_L] = 5'h00;
          axi_ea_tx_din[1][EA_DATA_MODE]                  = st_tx_tuser_vendor_T2[0];
          axi_ea_tx_din[1][EA_FC_BIT]                     = (st_tx_tdata_T2[31:24] == 'h4A) & st_tx_tdata_T2[117];
         

          if ( TX_PASSTHRU )
          begin
            axi_ea_tx_din[1][EA_DATA_PFN_H:EA_DATA_PFN_L]   = st_tx_tdata_T2[162:160];  // PF Num
            axi_ea_tx_din[1][EA_DATA_VFN_H:EA_DATA_VFN_L]   = st_tx_tdata_T2[173:163];  // VF Num
            axi_ea_tx_din[1][EA_DATA_VF_ACTIVE]             = st_tx_tdata_T2[174];      // VF Active
            axi_ea_tx_din[1][EA_DATA_BAR_H:EA_DATA_BAR_L]   = st_tx_tdata_T2[178:175];  // Bar Number 
          end
          else
          begin
            axi_ea_tx_din[1][EA_DATA_TX_AFU_IRQ]            = 1'b0;                   //392 - afu_irq
            axi_ea_tx_din[1][EA_DATA_TX_AFU_PORT_CSR_WR]    = 1'b0;                   //393 - afu_status_port_csr_wr
            axi_ea_tx_din[1][EA_DATA_TX_VF_ACTIVE]          = st_tx_tdata_T2[174];    //394 - vf_active
          end
          
          case(st_tx_tdata_T2[31:24])
          
            // READ
            8'h00, 8'h20:
              if (st_tx_tuser_vendor_T2[0] == 1'b0)
                axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_pu_req_packer();
              else
                axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_dm_req_packer();
            
            // WRITE or atomic
            8'h40, 8'h60, 8'h4c, 8'h6c, 8'h4d, 8'h6d, 8'h4e, 8'h6e:
              if (st_tx_tuser_vendor_T2[0] == 1'b0)
                axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_pu_req_packer();
              else
                axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_dm_req_packer();
            
            // INTR
            8'h30:
            begin
              axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L]   = tx_dm_intr_packer();
              axi_ea_tx_din[1][EA_DATA_TX_AFU_IRQ]            = 1'b1;                 //392 - afu_irq
            end

            // MSGD, MSGD will always be in PU mode
            8'h70, 8'h72, 8'h73:
              axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_pu_msgD_packer();
            
            
            // CPLD
            default:
            begin
              if ( st_tx_tuser_vendor_T2[0] == 1'b0 ) //PU format
                axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_pu_cpl_packer();
              else
                axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_dm_cpl_packer();
            end
          endcase
/*
          if(st_tx_tdata_T2[31:24] == 8'h20 | st_tx_tdata_T2[31:24] == 8'h60)    // DMRd/DMWr
            axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_dm_req_packer();
          else //Cpl
            axi_ea_tx_din[1][EA_DATA_HDR_H:EA_DATA_HDR_L] = tx_pu_cpl_packer();
*/
          axi_ea_tx_din[1][EA_DATA_PYLD_H:EA_DATA_PYLD_L] = st_tx_tdata_T2[511:256];

          if(st_tx_tlast_T2)
            next_tx_state = SOP;
          else
            next_tx_state = DATA;

        end //valid TX
        else
        begin
          next_tx_state = tx_state;
        end
      end //case SOP

      DATA:
      begin
        if(st_tx_tvalid_T2)
        begin
          axi_ea_tx_wen[0] = 1'b1;
          axi_ea_tx_wen[1] = 1'b1;

          axi_ea_tx_din[0][EA_DATA_VALID] = 1'b1;

          if(st_tx_tkeep_T2[32])
          begin
            axi_ea_tx_din[1][EA_DATA_VALID]    = 1'b1;
            axi_ea_tx_din[1][EA_DATA_EOP]      = st_tx_tlast_T2;
            axi_ea_tx_din[1][EA_DATA_TX_LAST]  = st_tx_tlast_T2;
          end
          else
          begin
            axi_ea_tx_din[1][EA_DATA_VALID]    = 1'b0;
            axi_ea_tx_din[0][EA_DATA_EOP]      = st_tx_tlast_T2;
            axi_ea_tx_din[0][EA_DATA_TX_LAST]  = st_tx_tlast_T2;
          end //if (tkeep)

          axi_ea_tx_din[0][EA_DATA_SOP]                   = 1'b0;
          axi_ea_tx_din[1][EA_DATA_SOP]                   = 1'b0;
          axi_ea_tx_din[0][EA_DATA_RSVD_H:EA_DATA_RSVD_L] = 5'h00;
          axi_ea_tx_din[1][EA_DATA_RSVD_H:EA_DATA_RSVD_L] = 5'h00;
          axi_ea_tx_din[0][EA_DATA_PYLD_H:EA_DATA_PYLD_L] = st_tx_tdata_T2[255:0];
          axi_ea_tx_din[1][EA_DATA_PYLD_H:EA_DATA_PYLD_L] = st_tx_tdata_T2[511:256];

          if(st_tx_tlast_T2)
            next_tx_state = SOP;
          else
            next_tx_state = DATA;

        end // if (tvalid)
        else
        begin
          next_tx_state = tx_state;
        end
      end //case DATA
		
      default:
      begin
        next_tx_state = tx_state;
      end
    endcase

    if(!resetb)
    begin
      next_tx_state = SOP;
    end
  end //always

  always @ (posedge clk)
  begin
    tx_state <= next_tx_state;

    if(!resetb)
    begin
      tx_state <= SOP;
    end
  end

  // ---------------------------------------------------------------------------
  // EA Tx FIFO Read ( DMRd, DMWr, Cpl/CplD(MMIO) )
  // Drive AXI EA TX Interface
  // ---------------------------------------------------------------------------
  always_comb
  begin
    axi_ea_tx_ren[0]     = |axi_ea_tx_nemp & axi_ea_tx_tready_p;
    axi_ea_tx_ren[1]     = |axi_ea_tx_nemp & axi_ea_tx_tready_p;
    
    axi_ea_tx_tvalid_p   = |axi_ea_tx_ren;
    axi_ea_tx_tdata_p[0] = axi_ea_tx_dout[0][0+:AXI_EA_DATA_W];
    axi_ea_tx_tdata_p[1] = axi_ea_tx_dout[1][0+:AXI_EA_DATA_W];
    axi_ea_tx_tuser_p[0] = axi_ea_tx_dout[0][AXI_EA_DATA_W+:AXI_EA_USER_W];
    axi_ea_tx_tuser_p[1] = axi_ea_tx_dout[1][AXI_EA_DATA_W+:AXI_EA_USER_W];
    axi_ea_tx_tlast_p    = axi_ea_tx_dout[0][EA_DATA_TX_LAST] | axi_ea_tx_dout[1][EA_DATA_TX_LAST];
  end
 
  axis_register #(
    .MODE(0), .ENABLE_TKEEP(1), .ENABLE_TLAST(1), .ENABLE_TUSER(1),
    .TDATA_WIDTH(AXI_EA_DATA_W*2), .TUSER_WIDTH(AXI_EA_USER_W*2) 
  ) 
  axi_ea_tx_reg (
    .clk      (clk),
    .rst_n    (resetb),

    .s_tready (axi_ea_tx_tready_p),    
    .s_tvalid (axi_ea_tx_tvalid_p),    
    .s_tdata  ({axi_ea_tx_tdata_p[1], axi_ea_tx_tdata_p[0]}),    
    .s_tkeep  (),    
    .s_tlast  (axi_ea_tx_tlast_p),    
    .s_tid    (),    
    .s_tdest  (),    
    .s_tuser  ({axi_ea_tx_tuser_p[1], axi_ea_tx_tuser_p[0]}),    
    
    .m_tready (axi_ea_tx_tready),   
    .m_tvalid (axi_ea_tx_tvalid),   
    .m_tdata  ({axi_ea_tx_tdata[1], axi_ea_tx_tdata[0]}),   
    .m_tkeep  (),   
    .m_tlast  (axi_ea_tx_tlast),   
    .m_tid    (),   
    .m_tdest  (),   
    .m_tuser  ({axi_ea_tx_tuser[1], axi_ea_tx_tuser[0]})
  );

  assign st_tx_tready = !axi_ea_tx_full;

  // ---------------------------------------------------------------------------
  // Pack RX Req Hdr (Data Mover Format)
  // ---------------------------------------------------------------------------
  function logic [255:0] rx_dm_req_packer(input logic [255:0] ser_dout);

    logic [127:0] pcie_hdr;
    logic [11:0]  len_bytes;
    logic [255:0] dm_hdr;
    logic         vfa;
    logic [2:0]   pf;
    logic [10:0]  vf;
    logic [2:0]   bar;

    pcie_hdr  = ser_dout[127:0];
    vfa       = ser_dout[128];
    pf        = ser_dout[131:129];
    vf        = ser_dout[144:132];
    bar       = ser_dout[147:145];
    len_bytes = pcie_hdr[LENGTH_H:LENGTH_L] * 4;                    //Convert DW to bytes


    //DW 0
    dm_hdr[9:0]    = len_bytes[11:2];                        // Length[11:2] //Max 256 Byte support
    dm_hdr[11:10]  = pcie_hdr[AT_H:AT_L];                           // AT
    dm_hdr[13:12]  = {pcie_hdr[ATTR_1], pcie_hdr[ATTR_0]};          // Attr
    dm_hdr[14]     = pcie_hdr[EP];                                  // EP
    dm_hdr[15]     = pcie_hdr[TD];                                  // TD
    dm_hdr[16]     = pcie_hdr[TH];                                  // TH
    dm_hdr[17]     = pcie_hdr[LN];                                  // LN
    dm_hdr[18]     = pcie_hdr[ATTR_2];                              // Attr
    dm_hdr[19]     = pcie_hdr[TAG_8];                               // Tag_8
    dm_hdr[22:20]  = pcie_hdr[TC_H:TC_L];                           // TC
    dm_hdr[23]     = pcie_hdr[TAG_9];                               // Tag_9
    dm_hdr[31:24]  = pcie_hdr[FMTTYPE_H:FMTTYPE_L];                 // MWr/Mrd (MMIO only). Never DMRd/DMWr

    //DW 1
    /*if ( RX_PASSTHRU )
    begin
      dm_hdr[39:32]  = pcie_hdr[LAST_DW_BE_H:FIRST_DW_BE_L];        // Last/First DW BE
      dm_hdr[47:40]  = pcie_hdr[TAG_H:TAG_L];                       // Tag_7_0
      dm_hdr[63:48]  = pcie_hdr[REQ_ID_H:REQ_ID_L];                 // Requester ID
    end
    else*/
    begin
      dm_hdr[39:32]  = 0;                                           // Rsvd
      dm_hdr[47:40]  = pcie_hdr[TAG_H:TAG_L];                       // Tag_7_0
      dm_hdr[49:48]  = len_bytes[1:0];                              // Length_1_0
      dm_hdr[61:50]  = 0;                                           // Length_23_12
      dm_hdr[63:62]  = 0;                                           // Host_addr_1_0
    end

    
    //DW 2
    //if (pcie_hdr[(FMTTYPE_L+5)+:3] == 3'h0) //3DW Req
      //dm_hdr[95:64]  = {pcie_hdr[63:34], pcie_hdr[33:32]};        // {Addr_31_2, PH}
    //else
    dm_hdr[95:64]   = pcie_hdr[63:32];                              // Addr_63_32

    //DW 3
    dm_hdr[127:96]  = pcie_hdr[31:0];                               // Addr_31_2, PH

    //DW 4
    dm_hdr[151:128] = 0;                                            // Prefix
    dm_hdr[156:152] = 0;                                            // Prefix Type
    dm_hdr[157]     = 0;                                            // Prefix Present
    dm_hdr[159:158] = 0;                                            // 2'b00

    //DW 5
    if ( RX_PASSTHRU )
    begin
      dm_hdr[162:160] = pcie_hdr[REQ_ID_L+2:REQ_ID_L];                // PF Num
      dm_hdr[173:163] = pcie_hdr[REQ_ID_H:REQ_ID_H-11];               // VF Num
      dm_hdr[174]     = ser_dout[130];                                // VF Active
      //dm_hdr[174]     = ea_ser_dout[0][EA_DATA_TX_VF_ACTIVE];       // VF Active    
    end
    else
    begin
      dm_hdr[162:160] = pf;                                         // PF Num
      dm_hdr[173:163] = vf;                                         // VF Num
      dm_hdr[174]     = vfa;                                        // VF Active

    end
    dm_hdr[178:175] = 0;                                            // Rsvd
    dm_hdr[183:179] = 0;                                            // Slot Number
    dm_hdr[184]     = 0;                                            // MM Mode
    dm_hdr[191:185] = 7'h0;                                         // Rsvd
   
    //DW 6
    dm_hdr[223:192] = 32'h0;                                        // Local Addr/Meta Data[63:32] 

    //DW 7
    dm_hdr[255:224] = 32'h0;                                        // Local Addr/Meta Data[31:0] 
	 
	rx_dm_req_packer = dm_hdr;
  endfunction: rx_dm_req_packer

  // ---------------------------------------------------------------------------
  // Pack RX Req Hdr (PU Format)
  // ---------------------------------------------------------------------------
  function logic [255:0] rx_pu_req_packer(input logic [255:0] ser_dout);

    logic [127:0] pcie_hdr;
    logic [11:0]  len_bytes;
    logic [255:0] dm_hdr;
    logic         vfa;
    logic [2:0]   pf;
    logic [10:0]  vf;
    logic [2:0]   bar;

    pcie_hdr  = ser_dout[127:0];
    vfa       = ser_dout[128];
    pf        = ser_dout[131:129];
    vf        = ser_dout[144:132];
    bar       = ser_dout[147:145];
    len_bytes = pcie_hdr[LENGTH_H:LENGTH_L] * 4;                    //Convert DW to bytes

    //DW 0
    dm_hdr[9:0]    = pcie_hdr[LENGTH_H:LENGTH_L];                   // Length[11:2] //in DWs
    dm_hdr[11:10]  = pcie_hdr[AT_H:AT_L];                           // AT
    dm_hdr[13:12]  = {pcie_hdr[ATTR_1], pcie_hdr[ATTR_0]};          // Attr
    dm_hdr[14]     = pcie_hdr[EP];                                  // EP
    dm_hdr[15]     = pcie_hdr[TD];                                  // TD
    dm_hdr[16]     = pcie_hdr[TH];                                  // TH
    dm_hdr[17]     = pcie_hdr[LN];                                  // LN
    dm_hdr[18]     = pcie_hdr[ATTR_2];                              // Attr
    dm_hdr[19]     = pcie_hdr[TAG_8];                               // Tag_8
    dm_hdr[22:20]  = pcie_hdr[TC_H:TC_L];                           // TC
    dm_hdr[23]     = pcie_hdr[TAG_9];                               // Tag_9
    dm_hdr[31:24]  = pcie_hdr[FMTTYPE_H:FMTTYPE_L];                 // MWr/Mrd (MMIO only). Never DMRd/DMWr

    //DW 1
    dm_hdr[39:32]  = pcie_hdr[LAST_DW_BE_H:FIRST_DW_BE_L];          // Last/First DW BE

    dm_hdr[47:40]  = pcie_hdr[TAG_H:TAG_L];                         // Tag_7_0
    if(UNIQUE_TAG_WA)
      dm_hdr[47:46] = 2'b00;     // Clear tag bits used by make request unique

    dm_hdr[63:48]  = pcie_hdr[REQ_ID_H:REQ_ID_L];                   // Requester ID

    //DW 2
    dm_hdr[95:64]  = pcie_hdr[63:32];                               // Addr_63_32

    //DW 3
    dm_hdr[127:96] = pcie_hdr[31:0];                                // Addr_31_2, PH

    //DW 4
    dm_hdr[151:128] = 0;                                            // Prefix
    dm_hdr[156:152] = 0;                                            // Prefix Type
    dm_hdr[157]     = 0;                                            // Prefix Present
    dm_hdr[159:158] = 0;                                            // 2'b00

    //DW 5
    if ( RX_PASSTHRU )
    begin
      dm_hdr[162:160] = pcie_hdr[REQ_ID_L+2:REQ_ID_L];                // PF Num
      dm_hdr[173:163] = pcie_hdr[REQ_ID_H:REQ_ID_H-11];               // VF Num
      dm_hdr[174]     = ser_dout[130];                                // VF Active
      //dm_hdr[174]     = ea_ser_dout[0][EA_DATA_TX_VF_ACTIVE];       // VF Active    
    end
    else
    begin
      dm_hdr[162:160] = pf;                                         // PF Num
      dm_hdr[173:163] = vf;                                         // VF Num
      dm_hdr[174]     = vfa;                                        // VF Active
    end
 
    dm_hdr[178:175] = bar;                                          // Bar Number
    dm_hdr[183:179] = 0;                                            // Slot Number
    dm_hdr[184]     = 0;                                            // MM Mode
    dm_hdr[191:185] = 7'h0;                                         // Rsvd
   
    //DW 6
    dm_hdr[223:192] = 32'h0;                                        // Local Addr/Meta Data[63:32] 

    //DW 7
    dm_hdr[255:224] = 32'h0;                                        // Local Addr/Meta Data[31:0] 
	 
	rx_pu_req_packer = dm_hdr;
  endfunction: rx_pu_req_packer

// ---------------------------------------------------------------------------
  // Pack RX MSGD Hdr (PU Format)
  // ---------------------------------------------------------------------------
  function logic [255:0] rx_pu_msgD_packer(input logic [255:0] ser_dout);

    logic [127:0] pcie_hdr;
    logic [8:0]   len_bytes;
    logic [255:0] dm_hdr;
    logic         vfa;
    logic [2:0]   pf;
    logic [10:0]  vf;
    logic [2:0]   bar;

    pcie_hdr  = ser_dout[127:0];
    vfa       = ser_dout[128];
    pf        = ser_dout[131:129];
    vf        = ser_dout[144:132];
    bar       = ser_dout[147:145];
    len_bytes = pcie_hdr[LENGTH_H:LENGTH_L] * 4;                    //Convert DW to bytes

    //DW 0
    dm_hdr[9:0]    = pcie_hdr[LENGTH_H:LENGTH_L];                   // Length[11:2] //in DWs
    dm_hdr[11:10]  = pcie_hdr[AT_H:AT_L];                           // AT
    dm_hdr[13:12]  = {pcie_hdr[ATTR_1], pcie_hdr[ATTR_0]};          // Attr
    dm_hdr[14]     = pcie_hdr[EP];                                  // EP
    dm_hdr[15]     = pcie_hdr[TD];                                  // TD
    dm_hdr[16]     = pcie_hdr[TH];                                  // TH
    dm_hdr[17]     = pcie_hdr[LN];                                  // LN
    dm_hdr[18]     = pcie_hdr[ATTR_2];                              // Attr
    dm_hdr[19]     = pcie_hdr[TAG_8];                               // Tag_8
    dm_hdr[22:20]  = pcie_hdr[TC_H:TC_L];                           // TC
    dm_hdr[23]     = pcie_hdr[TAG_9];                               // Tag_9
    dm_hdr[31:24]  = pcie_hdr[FMTTYPE_H:FMTTYPE_L];                 // MWr/Mrd (MMIO only). Never DMRd/DMWr

    //DW 1
    dm_hdr[39:32]  = pcie_hdr[LAST_DW_BE_H:FIRST_DW_BE_L];          // Message code

    dm_hdr[47:40]  = pcie_hdr[TAG_H:TAG_L];                         // Tag_7_0

    dm_hdr[63:48]  = pcie_hdr[REQ_ID_H:REQ_ID_L];                   // Requester ID

    //DW 2
    dm_hdr[95:64]  = pcie_hdr[63:32];                               // Vendor ID, Target ID

    //DW 3
    dm_hdr[127:96] = pcie_hdr[31:0];                                // MCTP Transport header

    //DW 4
    dm_hdr[151:128] = 0;                                            // Prefix
    dm_hdr[156:152] = 0;                                            // Prefix Type
    dm_hdr[157]     = 0;                                            // Prefix Present
    dm_hdr[159:158] = 0;                                            // 2'b00

    //DW 5
    dm_hdr[162:160] = pf;                                           // PF Num
    dm_hdr[173:163] = vf;                                           // VF Num
    dm_hdr[174]     = vfa;                                          // VF Active
    dm_hdr[178:175] = bar;                                          // Bar Number
    dm_hdr[183:179] = 0;                                            // Slot Number
    dm_hdr[184]     = 0;                                            // MM Mode
    dm_hdr[191:185] = 7'h0;                                         // Rsvd

    //DW 6
    dm_hdr[223:192] = 32'h0;                                        // Rsvd

    //DW 7
    dm_hdr[255:224] = 32'h0;                                        // Rsvd

	rx_pu_msgD_packer = dm_hdr;
  endfunction: rx_pu_msgD_packer


  // ---------------------------------------------------------------------------
  // Pack RX Cpl Hdr
  // Will always be Data Completions in response to read requests from HE
  // ---------------------------------------------------------------------------
  function logic[255:0] rx_dm_cpl_packer(input logic [255:0] ser_dout);

    logic [127:0] pcie_hdr;
    logic [11:0]  len_bytes; //256 max
    logic [255:0] dm_hdr;
    logic [11:0]  byte_cnt;
    logic         vfa;
    logic [2:0]   pf;
    logic [10:0]  vf;

    pcie_hdr  = ser_dout[127:0];
    vfa       = ser_dout[128];
    pf        = ser_dout[131:129];
    vf        = ser_dout[144:132];
    len_bytes = pcie_hdr[LENGTH_H:LENGTH_L] * 4;                     // Convert DW to bytes
    byte_cnt  = pcie_hdr[75:64];                                     // Byte Count Field

    // DW 0
    dm_hdr[9:0]     = len_bytes[11:2];                        // Length[11:2] //Max 256 Byte support
    dm_hdr[11:10]   = 2'b00;                                         // 2'b00
    dm_hdr[13:12]   = {pcie_hdr[ATTR_1], pcie_hdr[ATTR_0]};          // Attr
    dm_hdr[14]      = pcie_hdr[EP];                                  // EP
    dm_hdr[15]      = pcie_hdr[TD];                                  // TD
    dm_hdr[16]      = pcie_hdr[TH];                                  // TH
    dm_hdr[17]      = pcie_hdr[LN];                                  // LN
    dm_hdr[18]      = pcie_hdr[ATTR_2];                              // Attr
    dm_hdr[19]      = 1'b0;                                          // Rsvd
    dm_hdr[22:20]   = pcie_hdr[TC_H:TC_L];                           // TC
    dm_hdr[23]      = 1'b0;                                          // Rsvd
    dm_hdr[31:24]   = 8'h4a;                                         // DMCpl

    // DW 1
    if ( PU_CPL )
      dm_hdr[43:32]   = byte_cnt;                                      // Byte Count
    else
      dm_hdr[43:32]   = 1'h0;                                          // RsvdP
      
    dm_hdr[44]      = 1'h0;                                          // RsvdP
    dm_hdr[47:45]   = pcie_hdr[79:77];                               // Compl Status
    dm_hdr[63:48]   = 32'h0;                                         // RsvdP

    // DW 2
    dm_hdr[71:64]   = {1'b0, pcie_hdr[38:32]};                       // Lower Address_7_0
    
    if ( PU_CPL )
    begin
      dm_hdr[79:72]   = pcie_hdr[47:40];                               // Tag
      dm_hdr[95:80]   = pcie_hdr[63:48];                               // Req ID
    end
    else
    begin
      dm_hdr[79:72]   = 0;                                             // RsvdP
      dm_hdr[95:80]   = 0;                                             // RsvdP
    end
    
    // DW 3
    dm_hdr[111:96]  = 0;                                             // Lower Address_23_8
    dm_hdr[113:112] = 0;                                             // Length_1_0
    dm_hdr[115:114] = 0;                                             // Length_12_12
    dm_hdr[116]     = 1'b0;                                          // RsvdP
    dm_hdr[117]     = st_rx_tuser_vendor_p1[1];//(len_bytes == byte_cnt);                       // FC - Final Completion

    if(UNIQUE_TAG_WA)
      dm_hdr[127:118] = {pcie_hdr[119], pcie_hdr[115], 2'b00, pcie_hdr[45:40]}; // Tag
    else
      dm_hdr[127:118] = {pcie_hdr[119], pcie_hdr[115], pcie_hdr[47:40]};        // Tag

    // DW 4
    dm_hdr[151:128] = 0;                                             // Prefix
    dm_hdr[156:152] = 0;                                             // Prefix Type
    dm_hdr[157]     = 0;                                             // Prefix Present
    dm_hdr[159:158] = 0;                                             // 2'b00

    // DW 5
    if ( RX_PASSTHRU )
    begin
      dm_hdr[162:160] = pcie_hdr[REQ_ID_L+2:REQ_ID_L];                // PF Num
      dm_hdr[173:163] = pcie_hdr[REQ_ID_H:REQ_ID_H-11];               // VF Num
      dm_hdr[174]     = ser_dout[130];                                // VF Active 
      //dm_hdr[174]     = ea_ser_dout[0][EA_DATA_TX_VF_ACTIVE];       // VF Active    
    end
    else
    begin
      dm_hdr[162:160] = pf;                                          // PF Num
      dm_hdr[173:163] = vf;                                          // VF Num
      dm_hdr[174]     = vfa;                                         // VF Active
    end
    
    dm_hdr[178:175] = 0;                                             // Rsvd
    dm_hdr[183:179] = 0;                                             // Slot Number
    dm_hdr[184]     = 0;                                             // MM Mode
    dm_hdr[191:185] = 0;                                             // 7'h0
    
    // DW 6 
    dm_hdr[223:192] = 0;                                             // Meta Data[63:32]

    // DW 7
    dm_hdr[255:224] = 0;                                             // Meta Data[31:0]
	 
	rx_dm_cpl_packer = dm_hdr;
  endfunction: rx_dm_cpl_packer
 
  // ---------------------------------------------------------------------------
  // Pack RX Cpl Hdr (Power User Format)
  // Will always be Data Completions in response to read requests from HE
  // ---------------------------------------------------------------------------
  function logic[255:0] rx_pu_cpl_packer(input logic [255:0] ser_dout);

    logic [127:0] pcie_hdr;
    logic [11:0]  len_bytes; //256 max
    logic [255:0] dm_hdr;
    logic [11:0]  byte_cnt;
    logic         vfa;
    logic [2:0]   pf;
    logic [10:0]  vf;

    pcie_hdr  = ser_dout[127:0];
    vfa       = ser_dout[128];
    pf        = ser_dout[131:129];
    vf        = ser_dout[144:132];
    len_bytes = pcie_hdr[LENGTH_H:LENGTH_L] * 4;                     // Convert DW to bytes
    byte_cnt  = pcie_hdr[75:64];                                     // Byte Count Field

    // DW 0
    dm_hdr[9:0]     = pcie_hdr[LENGTH_H:LENGTH_L];                   // Length[11:2] //Max 256 Byte support
    dm_hdr[11:10]   = 2'b00;                                         // 2'b00
    dm_hdr[13:12]   = {pcie_hdr[ATTR_1], pcie_hdr[ATTR_0]};          // Attr
    dm_hdr[14]      = pcie_hdr[EP];                                  // EP
    dm_hdr[15]      = pcie_hdr[TD];                                  // TD
    dm_hdr[16]      = pcie_hdr[TH];                                  // TH
    dm_hdr[17]      = pcie_hdr[LN];                                  // LN
    dm_hdr[18]      = pcie_hdr[ATTR_2];                              // Attr
    dm_hdr[19]      = 1'b0;                                          // Rsvd
    dm_hdr[22:20]   = pcie_hdr[TC_H:TC_L];                           // TC
    dm_hdr[23]      = 1'b0;                                          // Rsvd
    dm_hdr[31:24]   = pcie_hdr[FMTTYPE_H:FMTTYPE_L];                 // DMCpl

    // DW 1
    dm_hdr[43:32]   = byte_cnt;                                      // Byte Count
    dm_hdr[44]      = pcie_hdr[76];                                  // BCM
    dm_hdr[47:45]   = pcie_hdr[79:77];                               // Compl Status
    dm_hdr[63:48]   = pcie_hdr[95:80];                               // Completer ID

    // DW 2
    dm_hdr[71:64]   = {1'b0, pcie_hdr[38:32]};                       // Lower Address_7_0
    dm_hdr[79:72]   = pcie_hdr[47:40];                               // Tag
    dm_hdr[95:80]   = pcie_hdr[63:48];                               // Req ID
    
    // DW 3
    dm_hdr[127:96]  = 'h0;                                           // Empty

    // DW 4
    dm_hdr[151:128] = 0;                                             // Prefix
    dm_hdr[156:152] = 0;                                             // Prefix Type
    dm_hdr[157]     = 0;                                             // Prefix Present
    dm_hdr[159:158] = 0;                                             // 2'b00

    // DW 5
    if ( RX_PASSTHRU )
    begin
      dm_hdr[162:160] = pcie_hdr[REQ_ID_L+2:REQ_ID_L];                // PF Num
      dm_hdr[173:163] = pcie_hdr[REQ_ID_H:REQ_ID_H-11];               // VF Num
      dm_hdr[174]     = ser_dout[130];                                // VF Active 
      //dm_hdr[174]     = ea_ser_dout[0][EA_DATA_TX_VF_ACTIVE];       // VF Active    
    end
    else
    begin
      dm_hdr[162:160] = pf;                                          // PF Num
      dm_hdr[173:163] = vf;                                          // VF Num
      dm_hdr[174]     = vfa;                                         // VF Active
    end
    
    dm_hdr[178:175] = 0;                                             // Rsvd
    dm_hdr[183:179] = 0;                                             // Slot Number
    dm_hdr[184]     = 0;                                             // MM Mode
    dm_hdr[191:185] = 0;                                             // 7'h0
    
    // DW 6 
    dm_hdr[223:192] = 0;                                             // Meta Data[63:32]

    // DW 7
    dm_hdr[255:224] = 0;                                             // Meta Data[31:0]
	 
	rx_pu_cpl_packer = dm_hdr;
  endfunction: rx_pu_cpl_packer



  // ---------------------------------------------------------------------------
  // Pack TX Req Hdr (Data Mover Format)
  // DMRd/DMWr
  // ---------------------------------------------------------------------------
  function logic [127:0] tx_dm_req_packer();
    
    logic [127:0] pcie_hdr;

    pcie_hdr                              = {128{1'b0}};

    pcie_hdr[FMTTYPE_H:FMTTYPE_L]         = st_tx_tdata_T2[31:24];                // Format type
    pcie_hdr[TAG_9]                       = st_tx_tdata_T2[23];                   // T9
    pcie_hdr[TC_H:TC_L]                   = st_tx_tdata_T2[22:20];                // TC
    pcie_hdr[TAG_8]                       = st_tx_tdata_T2[19];                   // T8
    pcie_hdr[ATTR_2]                      = st_tx_tdata_T2[18];                   // Attr_2
    pcie_hdr[LN]                          = st_tx_tdata_T2[17];                   // LN
    pcie_hdr[TH]                          = st_tx_tdata_T2[16];                   // TH
    pcie_hdr[TD]                          = st_tx_tdata_T2[15];                   // TD
    pcie_hdr[EP]                          = st_tx_tdata_T2[14];                   // EP
    pcie_hdr[ATTR_0]                      = st_tx_tdata_T2[12];                   // Attr_0
    pcie_hdr[ATTR_1]                      = st_tx_tdata_T2[13];                   // Attr_1
    pcie_hdr[AT_H:AT_L]                   = st_tx_tdata_T2[11:10];                // AT
    pcie_hdr[LENGTH_H:LENGTH_L]           = st_tx_tdata_T2[9:0];                  // DW because Length[11:2]

    // DW 1
    pcie_hdr[REQ_ID_H:REQ_ID_L]           = {st_tx_tdata_T2[173:163], 1'b0, st_tx_tdata_T2[162:160]};  // {VF,PF} - H-tile Spec

    if(UNIQUE_TAG_WA)
      pcie_hdr[TAG_H:TAG_L]               = {st_tx_tdata_T2[164:163], st_tx_tdata_T2[45:40]};          // VF, Tag[5:0]
    else
      pcie_hdr[TAG_H:TAG_L]               = st_tx_tdata_T2[47:40];                // Tag[7:0]

    if ( pcie_hdr[LENGTH_H:LENGTH_L] == 'd1 )
      pcie_hdr[LAST_DW_BE_H:LAST_DW_BE_L]   = 4'h0;                                 // BE
    else
      pcie_hdr[LAST_DW_BE_H:LAST_DW_BE_L]   = 4'hF;                                 // BE
    
    pcie_hdr[FIRST_DW_BE_H:FIRST_DW_BE_L] = 4'hF;                                 // BE

    // Was address mode switched to 32 bit?
    if (st_tx_tdata_T2[24+5] != pcie_hdr[FMTTYPE_L+5])
    begin
      // DW 2
      pcie_hdr[63:32]                       = '0;

      // DW 3
      pcie_hdr[31:0]                        = st_tx_tdata_T2[127:96];
    end
    else //DM_RD/DM_WR
    begin
      // DW 2
      pcie_hdr[63:32]                       = st_tx_tdata_T2[95:64];              // Host Address[63:32]

      // DW 3
      pcie_hdr[31:0]                        = st_tx_tdata_T2[127:96];             // Host Address[31:2], PH[1:0]
    end


    tx_dm_req_packer = pcie_hdr;
  endfunction : tx_dm_req_packer
  
  // ---------------------------------------------------------------------------
  // Pack TX Req Hdr (PU Format)
  // Rd/Wr
  // ---------------------------------------------------------------------------
  function logic [127:0] tx_pu_req_packer();
    
    logic [127:0] pcie_hdr;

    pcie_hdr                              = {128{1'b0}};

    // DW 0
    pcie_hdr[FMTTYPE_H:FMTTYPE_L]         = st_tx_tdata_T2[31:24];                // 4DW MRd, 4DW MWr 

    pcie_hdr[TAG_9]                       = st_tx_tdata_T2[23];                   // T9
    pcie_hdr[TC_H:TC_L]                   = st_tx_tdata_T2[22:20];                // TC
    pcie_hdr[TAG_8]                       = st_tx_tdata_T2[19];                   // T8
    pcie_hdr[ATTR_2]                      = st_tx_tdata_T2[18];                   // Attr_2
    pcie_hdr[LN]                          = st_tx_tdata_T2[17];                   // LN
    pcie_hdr[TH]                          = st_tx_tdata_T2[16];                   // TH
    pcie_hdr[TD]                          = st_tx_tdata_T2[15];                   // TD
    pcie_hdr[EP]                          = st_tx_tdata_T2[14];                   // EP
    pcie_hdr[ATTR_0]                      = st_tx_tdata_T2[12];                   // Attr_0
    pcie_hdr[ATTR_1]                      = st_tx_tdata_T2[13];                   // Attr_1
    pcie_hdr[AT_H:AT_L]                   = st_tx_tdata_T2[11:10];                // AT
    pcie_hdr[LENGTH_H:LENGTH_L]           = st_tx_tdata_T2[9:0];                  // DW because Length[11:2]

    // DW 1
    pcie_hdr[LAST_DW_BE_H:FIRST_DW_BE_L]  = st_tx_tdata_T2[39:32];                // Last/First DW BE

    if(UNIQUE_TAG_WA)
      pcie_hdr[TAG_H:TAG_L]               = {st_tx_tdata_T2[164:163], st_tx_tdata_T2[45:40]}; // VF, Tag[5:0]
    else
      pcie_hdr[TAG_H:TAG_L]               = st_tx_tdata_T2[47:40];                // Tag[7:0]

    pcie_hdr[REQ_ID_H:REQ_ID_L]           = st_tx_tdata_T2[63:48];                // Requester ID

    // DW 2
    pcie_hdr[63:32]                       = st_tx_tdata_T2[95:64];                // Host Address[63:32]

    // DW 3
    pcie_hdr[31:0]                        = st_tx_tdata_T2[127:96];               // Host Address[31:2], PH[1:0]


    tx_pu_req_packer = pcie_hdr;
  endfunction: tx_pu_req_packer

  // ---------------------------------------------------------------------------
  // Pack TX MsgD Hdr (PU Format)
  // Rd/Wr
  // ---------------------------------------------------------------------------
  function logic [127:0] tx_pu_msgD_packer();

    logic [127:0] pcie_hdr;

    pcie_hdr                              = {128{1'b0}};

    // DW 0
    pcie_hdr[FMTTYPE_H:FMTTYPE_L]         = st_tx_tdata_T2[31:24];                // msgD- 0x70,0x72,0x73

    pcie_hdr[TAG_9]                       = st_tx_tdata_T2[23];                   // T9
    pcie_hdr[TC_H:TC_L]                   = st_tx_tdata_T2[22:20];                // TC
    pcie_hdr[TAG_8]                       = st_tx_tdata_T2[19];                   // T8
    pcie_hdr[ATTR_2]                      = st_tx_tdata_T2[18];                   // Attr_2
    pcie_hdr[LN]                          = st_tx_tdata_T2[17];                   // LN
    pcie_hdr[TH]                          = st_tx_tdata_T2[16];                   // TH
    pcie_hdr[TD]                          = st_tx_tdata_T2[15];                   // TD
    pcie_hdr[EP]                          = st_tx_tdata_T2[14];                   // EP
    pcie_hdr[ATTR_0]                      = st_tx_tdata_T2[12];                   // Attr_0
    pcie_hdr[ATTR_1]                      = st_tx_tdata_T2[13];                   // Attr_1
    pcie_hdr[AT_H:AT_L]                   = st_tx_tdata_T2[11:10];                // AT
    pcie_hdr[LENGTH_H:LENGTH_L]           = st_tx_tdata_T2[9:0];                  // DW because Length[11:2]

    // DW 1
    pcie_hdr[LAST_DW_BE_H:FIRST_DW_BE_L]  = st_tx_tdata_T2[39:32];                // Message code

    pcie_hdr[TAG_H:TAG_L]                 = st_tx_tdata_T2[47:40];                // Tag[7:0]

    pcie_hdr[REQ_ID_H:REQ_ID_L]           = st_tx_tdata_T2[63:48];                // Requester ID

    // DW 2
    pcie_hdr[63:32]                       = st_tx_tdata_T2[95:64];                // Vendor ID, PCIe Target ID

    // DW 3
    pcie_hdr[31:0]                        = st_tx_tdata_T2[127:96];               // MCTP Transport Header


    tx_pu_msgD_packer = pcie_hdr;
  endfunction: tx_pu_msgD_packer


  // ---------------------------------------------------------------------------
  // Pack TX Cpl Hdr
  // CplD to MMIO REquests from the Host
  // ---------------------------------------------------------------------------
  function logic [127:0] tx_pu_cpl_packer();
    
    logic [127:0] pcie_hdr;

    pcie_hdr                              = {128{1'b0}};

    // DW 0
    pcie_hdr[FMTTYPE_H:FMTTYPE_L]         = st_tx_tdata_T2[31:24];   // CplD 
    pcie_hdr[TAG_9]                       = st_tx_tdata_T2[23];      // T9
    pcie_hdr[TC_H:TC_L]                   = st_tx_tdata_T2[22:20];   // TC
    pcie_hdr[TAG_8]                       = st_tx_tdata_T2[19];      // T8
    pcie_hdr[ATTR_2]                      = st_tx_tdata_T2[18];      // Attr_2
    pcie_hdr[LN]                          = st_tx_tdata_T2[17];      // LN
    pcie_hdr[TH]                          = st_tx_tdata_T2[16];      // TH
    pcie_hdr[TD]                          = st_tx_tdata_T2[15];      // TD
    pcie_hdr[EP]                          = st_tx_tdata_T2[14];      // EP
    pcie_hdr[ATTR_1]                      = st_tx_tdata_T2[13];      // Attr_1
    pcie_hdr[ATTR_0]                      = st_tx_tdata_T2[12];      // Attr_0
    pcie_hdr[AT_H:AT_L]                   = 2'b00;                   // AT
    pcie_hdr[LENGTH_H:LENGTH_L]           = st_tx_tdata_T2[9:0];     // DW because Length[11:2]

    // DW 1
    pcie_hdr[95:80]                       = st_tx_tdata_T2[63:48];   // Completer ID {VF, VF_ACTIVE, PF} - PCIe SS power user mode

`ifndef R1_UNIT_TEST_ENV    

    `ifdef HTILE
       pcie_hdr[83]                       = 1'b0;                    // Completer ID {VF,PF} - H-Tile Spec
    `endif

`endif // R1_UNIT_TEST_ENV

    pcie_hdr[79:77]                       = st_tx_tdata_T2[47:45];   // Cpl Status
    pcie_hdr[76]                          = 1'b0;                    // BCM
    pcie_hdr[75:64]                       = st_tx_tdata_T2[43:32];   // Byte Count - MMIO responses will always be 4 -or- 8 bytes

    // DW 2
    if ( st_tx_tuser_vendor_T2[0] == 1'b0 ) //PU format
      pcie_hdr[63:48]                     = st_tx_tdata_T2[95:80];   // Req ID comes from HE
    else
      pcie_hdr[63:48]                     = req_id_dout;             // Req ID comes from this adapter

    pcie_hdr[47:40]                       = st_tx_tdata_T2[79:72];   // Tag (only using 8-bit tag. Data Mover supports 10-bit)
    pcie_hdr[39]                          = 1'b0;                    // Rsvd
    pcie_hdr[38:32]                       = st_tx_tdata_T2[70:64];   // Lower Address (only using 7-bit lower address)

    tx_pu_cpl_packer = pcie_hdr;
  endfunction: tx_pu_cpl_packer
  
  // ---------------------------------------------------------------------------
  // Pack TX Cpl Hdr
  // CplD to MMIO REquests from the Host
  // ---------------------------------------------------------------------------
  function logic [127:0] tx_dm_cpl_packer();
    
    logic [127:0] pcie_hdr;

    pcie_hdr                              = {128{1'b0}};

    // DW 0
    pcie_hdr[FMTTYPE_H:FMTTYPE_L]         = st_tx_tdata_T2[31:24];   // CplD 
    pcie_hdr[TAG_9]                       = st_tx_tdata_T2[127];     // T9
    pcie_hdr[TC_H:TC_L]                   = st_tx_tdata_T2[22:20];   // TC
    pcie_hdr[TAG_8]                       = st_tx_tdata_T2[126];     // T8
    pcie_hdr[ATTR_2]                      = st_tx_tdata_T2[18];      // Attr_2
    pcie_hdr[LN]                          = st_tx_tdata_T2[17];      // LN
    pcie_hdr[TH]                          = st_tx_tdata_T2[16];      // TH
    pcie_hdr[TD]                          = st_tx_tdata_T2[15];      // TD
    pcie_hdr[EP]                          = st_tx_tdata_T2[14];      // EP
    pcie_hdr[ATTR_0]                      = st_tx_tdata_T2[12];      // Attr_0
    pcie_hdr[ATTR_1]                      = st_tx_tdata_T2[13];      // Attr_1
    pcie_hdr[AT_H:AT_L]                   = 2'b00;                   // AT
    pcie_hdr[LENGTH_H:LENGTH_L]           = st_tx_tdata_T2[9:0];     // DW because Length[11:2]

    // DW 1
    pcie_hdr[95:80]                       = {st_tx_tdata_T2[173:163], 1'b0, st_tx_tdata_T2[162:160]}; //Completer ID - {VF,PF} - H-Tile Spec
    pcie_hdr[79:77]                       = st_tx_tdata_T2[47:45];               // Cpl Status
    pcie_hdr[76]                          = 1'b0;                                // BCM
    if ( TX_PASSTHRU )
      pcie_hdr[75:64]                     = st_tx_tdata_T2[43:32];               // Byte Count
    else
      pcie_hdr[75:64]                     = {st_tx_tdata_T2[9:0], 2'b00};        // Byte Count
    
    // DW 2
    //if ( TX_PASSTHRU )
    //  pcie_hdr[63:48]                     = st_tx_tdata_T2[95:80];   // Req ID comes from HE
    //else
      pcie_hdr[63:48]                     = req_id_dout;             // Req ID comes from this adapter
    
    pcie_hdr[47:40]                       = st_tx_tdata_T2[125:118]; // Tag (only using 8-bit tag. Data Mover supports 10-bit)
    pcie_hdr[39]                          = 1'b0;                    // Rsvd
    pcie_hdr[38:32]                       = st_tx_tdata_T2[70:64];   // Lower Address (only using 7-bit lower address)

    tx_dm_cpl_packer = pcie_hdr;
  endfunction: tx_dm_cpl_packer
  
  // ---------------------------------------------------------------------------
  // Pack TX Intr Hdr
  // Data Mover Interrupt from the Host
  // ---------------------------------------------------------------------------
  function logic [127:0] tx_dm_intr_packer();
    
    logic [127:0] pcie_hdr;

    pcie_hdr                              = {128{1'b0}};

    // DW 0
    pcie_hdr[15:0]                        = {st_tx_tdata_T2[174:163],
                                             1'b0, 
                                             st_tx_tdata_T2[162:160]};  // Requester ID - (VF Active, VF, PF)
    pcie_hdr[23:16]                       = st_tx_tdata_T2[71:64];      // Interrupt ID
    
    tx_dm_intr_packer = pcie_hdr;
  endfunction

  // ---------------------------------------------------------------------------
  // Error Flags
  // ---------------------------------------------------------------------------
  /*synthesis translate_off */
  always @ (posedge clk)
  begin
    if(resetb & ((|axi_ea_rx_err) | (|axi_ea_tx_err) | ea_ser_err))
    begin
      $display("======================================================================================================");
      $display("*** ERROR: AXI_S_ADAPTER: FIFO ERROR   ***");
      $display("======================================================================================================");
      #100;
      $finish() ;
    end
  end//always @ (posedge)
  /*synthesis translate_on */
  

  // ---------------------------------------------------------------------------
  // AXI EA FIFO 
  // ---------------------------------------------------------------------------
  generate
  genvar n;

  for(n=0; n<EA_CH; n=n+1)
  begin:EA_FIFO

  quartus_bfifo
  #(.WIDTH             ( AXI_EA_Q_W        ),
    .DEPTH             ( AXI_EA_Q_D_B2     ),
    .FULL_THRESHOLD    ( AXI_EA_Q_FULL_TH  ),
    .REG_OUT           ( 1                 ), 
    .RAM_STYLE         ( "AUTO"            ),
    .ECC_EN            ( 0                 )      
  )
  axi_ea_rx_q
  (
    .fifo_din          ( axi_ea_rx_din[n]  ),
    .fifo_wen          ( axi_ea_rx_wen[n]  ),
    .fifo_ren          ( axi_ea_rx_ren[n]  ),

    .clk               ( clk               ),
    .Resetb            ( resetb            ),
                   
    .fifo_dout         ( axi_ea_rx_dout[n] ),       
    .almost_full       ( axi_ea_rx_full[n] ),
    .not_empty         ( axi_ea_rx_nemp[n] ),

    .fifo_eccstatus    ( axi_ea_rx_ecc[n]  ),
    .fifo_err          ( axi_ea_rx_err[n]  )
  );


  quartus_bfifo 
  #(.WIDTH             ( AXI_EA_Q_W       )     ,// 
    .DEPTH             ( AXI_EA_Q_D_B2    )     ,// 
    .FULL_THRESHOLD    ( AXI_EA_Q_FULL_TH )     ,// 
    .REG_OUT           ( 1                )     ,// 
    .RAM_STYLE         ( "AUTO"           )     ,//
    .ECC_EN            ( 0                )      //
  )  
  axi_ea_tx_q 
  (
    .fifo_din          ( axi_ea_tx_din[n] )     ,// FIFO write data in
    .fifo_wen          ( axi_ea_tx_wen[n] )     ,// FIFO write enable
    .fifo_ren          ( axi_ea_tx_ren[n] )     ,// FIFO read enable

    .clk               ( clk              )     ,// clock
    .Resetb            ( resetb           )     ,// Reset active low

    .fifo_dout         ( axi_ea_tx_dout[n])     ,// FIFO read data out registered
    .almost_full       ( axi_ea_tx_full[n])     ,// FIFO count > FULL_THRESHOLD
    .not_empty         ( axi_ea_tx_nemp[n])     ,// FIFO is not empty

    .fifo_eccstatus    ( axi_ea_tx_ecc[n] )     ,// FIFO parity error
    .fifo_err          ( axi_ea_tx_err[n] )      // FIFO overflow/underflow error
  );

  end //for EA_FIFO
  endgenerate

  qfifo  
  #(.WIDTH             ( EA_SER_Q_W       )     ,// 
    .DEPTH             ( EA_SER_Q_D_B2    )     ,// 
    .FULL_THRESHOLD    ( EA_SER_Q_FULL_TH )     ,// 
    .REG_OUT           ( 0                )     ,// 
    .GRAM_STYLE        ( `GRAM_AUTO       )     ,// 
    .BITS_PER_PARITY   ( 32               ) 
  )  
  ea_ser_rx_q                                                  
  (                                                              
  .din0                 ( ea_ser_din[0]   )     ,// [WIDTH-1:0] data in port 0
  .wen0                 ( ea_ser_wen[0]   )     ,//             write enable port 0
  .ren0                 ( ea_ser_ren[0]   )     ,//             read enable port 0
  .din1                 ( ea_ser_din[1]   )     ,// [WIDTH-1:0] data in port 1
  .wen1                 ( ea_ser_wen[1]   )     ,//             write enable port 1
  .ren1                 ( ea_ser_ren[1]   )     ,//             read enable port 1
  
  .resetb               ( resetb          )     ,//             resetb (active low)
  .clk                  ( clk             )     ,//             1x clock

  .out0                 (                 )     ,// [WIDTH-1:0] read data output prot0 (comb out)
  .out1                 (                 )     ,// [WIDTH-1:0] read data output port1 (comb out)    
  .dout0                ( ea_ser_dout[0]  )     ,// [WIDTH-1:0] read data output port0
  .dout1                ( ea_ser_dout[1]  )     ,// [WIDTH-1:0]  read data output raddr0+1
  .not_empty0           ( ea_ser_nemp[0]  )     ,//             fifo is not empty
  .not_empty1           ( ea_ser_nemp[1]  )     ,//             fifo is not empty
  .full                 ( ea_ser_full     )     ,//             fifo_count > FULL_THRESHOLD
  .fifo_err             ( ea_ser_err      )     ,//             fifo overflow/underflow error
  .fifo_perr            ( ea_ser_perr     )      //             fifo overflow/underflow error
  );


  // ---------------------------------------------------------------------------
  // Requester ID RAM 
  // ---------------------------------------------------------------------------
  ram_1r1w  
  #(.DEPTH             ( NUM_TAGS_B2 )         ,// number of bits of address bus
    .WIDTH             ( 16          )         ,// number of bits of data bus
    .GRAM_MODE         ( 2'd2        )         ,// RdLatency = 1 and Wr2RdLatency = 2 
    .GRAM_STYLE        ( `GRAM_AUTO  )         ,// GRAM_AUTO, GRAM_AUTO, GRAM_AUTO
    .BITS_PER_PARITY   ( 32          )         ,// number of data BITS PER parity bit
    .PIPELINE_PERR     ( 1           )          // Adds one pipeline register stage in parity error detection logic.
  )
  req_id_ram
  (                                                                            //
    .din               ( req_id_din  )         ,// [WIDTH-1:0] data in port 0
    .waddr             ( req_id_wad  )         ,// [DEPTH-1:0] write address port 0
    .we                ( req_id_wen  )         ,//             write enable port 0
    .raddr             ( req_id_rad  )         ,// read address port a
    .re                ( req_id_ren  )         ,//
    .clk               ( clk         )         ,// 1x clock                                                                               
    .dout              ( req_id_dout )         ,// output port a  
    .perr              ( req_id_perr )          // parity error read prota or portb 
  );  

  // ---------------------------------------------------------------------------
  // Header Format RAM 
  // ---------------------------------------------------------------------------
  altera_syncram  hdr_format_ram (
    .address_a      (hdr_format_wad),
    .address_b      (hdr_format_rad),
    .clock0         (clk),
    .data_a         (hdr_format_din),
    .wren_a         (hdr_format_wen),
    .q_b            (hdr_format_dout),
    .aclr0          (1'b0),
    .aclr1          (1'b0),
    .address2_a     (1'b1),
    .address2_b     (1'b1),
    .addressstall_a (1'b0),
    .addressstall_b (1'b0),
    .byteena_a      (1'b1),
    .byteena_b      (1'b1),
    .clock1         (1'b1),
    .clocken0       (1'b1),
    .clocken1       (1'b1),
    .clocken2       (1'b1),
    .clocken3       (1'b1),
    .data_b         ({2{1'b1}}),
    .eccencbypass   (1'b0),
    .eccencparity   (8'b0),
    .eccstatus      (),
    .q_a            (),
    .rden_a         (1'b1),
    .rden_b         (1'b1),
    .sclr           (1'b0),
    .wren_b         (1'b0));
  defparam
    hdr_format_ram.address_aclr_b         = "NONE",
    hdr_format_ram.address_reg_b          = "CLOCK0",
    hdr_format_ram.clock_enable_input_a   = "BYPASS",
    hdr_format_ram.clock_enable_input_b   = "BYPASS",
    hdr_format_ram.clock_enable_output_b  = "BYPASS",
    `ifdef DEVICE_FAMILY
    hdr_format_ram.intended_device_family = `DEVICE_FAMILY,
    `else
    hdr_format_ram.intended_device_family = "Stratix 10",
    `endif
    hdr_format_ram.lpm_type               = "altera_syncram",
    hdr_format_ram.numwords_a             = (2**HDR_FORMAT_D_B2),
    hdr_format_ram.numwords_b             = (2**HDR_FORMAT_D_B2),
    hdr_format_ram.operation_mode         = "DUAL_PORT",
    hdr_format_ram.outdata_aclr_b         = "NONE",
    hdr_format_ram.outdata_sclr_b         = "NONE",
    hdr_format_ram.outdata_reg_b          = "UNREGISTERED",
    hdr_format_ram.power_up_uninitialized = "FALSE",
    hdr_format_ram.read_during_write_mode_mixed_ports  = "DONT_CARE",
    hdr_format_ram.widthad_a              = HDR_FORMAT_D_B2,
    hdr_format_ram.widthad_b              = HDR_FORMAT_D_B2,
    hdr_format_ram.width_a                = HDR_FORMAT_W,
    hdr_format_ram.width_b                = HDR_FORMAT_W,
    hdr_format_ram.width_byteena_a        = 1;

endmodule
