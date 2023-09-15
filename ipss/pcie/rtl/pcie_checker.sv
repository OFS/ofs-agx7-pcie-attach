// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Functions:
//   PCIe TLP checker & completion tracker
//
//   The checker can only process 1 TLP of the same type on a single clock cycle. 
//   Examples of TLP combinations on AVST channel 0 and channel 1 that can't be processed in single cycle
//  ---------------------------------
//  | No |     CH0     |    CH1     |
//  ---------------------------------
//  | 1  |  {MMIO SOP} | {MMIO SOP} |
//  | 2  |  {CPL* SOP} | {CPL* SOP} |
//  | 3  |  {CPLD EOP} | {CPL* SOP} |
//  ---------------------------------
//
//  The checker supports:
//     * H-TILE and P-TILE x8 and x16 PCIe IP interface format
//          * H-TILE: avst data channel contains both header and data
//          * P-TILE: separate avst channel for header and data
//     * H-TILE and P-TILE PCIe IP variants with single 256-bit channel (PCIe Gen3x8, PCIe Gen4x8)
//     * H-TILE and P-TILE PCIe IP variants with two 256-bit channels (PCIe Gen3x16, PCIe Gen4x16)
//
//  Clock domain : avl_clk
//  Reset        : avl_rst_n
//
//-----------------------------------------------------------------------------

`include "vendor_defines.vh"
`include "fpga_defines.vh"

module pcie_checker #(
   parameter ENABLE_MALFORMED_TLP_CHECK = 0,      // 0:DISABLE 1:ENABLE
   parameter ENABLE_COMPLETION_TIMEOUT_CHECK = 0  // 0:DISABLE 1:ENABLE
)(
   input  logic                            avl_clk,
   input  logic                            avl_rst_n,   

   // Input RX TLP from upstream
   input  ofs_fim_pcie_pkg::t_avst_rxs     i_avl_rx_st,    // AVST RX channels carrying Rx TLP from upstream logic 
   output logic                            o_avl_rx_ready, // Backpressure signal to upstream logic

   // Output RX TLP to downstream
   output ofs_fim_pcie_pkg::t_avst_rxs     o_avl_rx_st,    // AVST RX channels carrying Rx TLP to downstream logic
   input  logic                            i_avl_rx_ready, // Backpressure signal from downstream logic

   // Header fields of MRd requests that are sent upstream
   //    The header info is stored in mrd_rid_ram and is used to track unexpected cpl/cpld
   //    When a MRd request is sent upstream, the cpl_pending_data_cnt counter is incremented with the data length in the MRd request
   input  logic                            tx_mrd_valid,   // Write to mrd_rid_ram; increment pending MRd data count
   input  logic [PCIE_MAX_LEN_WIDTH-1:0]   tx_mrd_length,  // MRd request data length
   input  logic [PCIE_EP_TAG_WIDTH-1:0]    tx_mrd_tag,     // MRd request tag
   input  logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]             tx_mrd_pfn,     // MRd request requester ID (PF)
   input  logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]             tx_mrd_vfn,     // MRd request requester ID (VF)
   input  logic                            tx_mrd_vf_act,  // MRd request is sent by PF or VF

   // Current amount of data pending completion from host (for MRd requests sent to host)
   output logic [CPL_CREDIT_WIDTH-1:0]     cpl_pending_data_cnt,
   
   // Error sideband signals to upstream PCIe IP
   output logic                            b2a_app_err_valid,    // Error is detected in the incoming TLP
   output logic [31:0]                     b2a_app_err_hdr,      // Header of the erroneous TLP
   output logic [10:0]                     b2a_app_err_info,     // Info of the error
   output logic [1:0]                      b2a_app_err_func_num, // Function number associated with the erroneous TLP

   // Error signals to PCIe error status registers
   output logic                            chk_rx_err,           // Error is detected in the incoming TLP
   output logic                            chk_rx_err_vf_act,    // Indicates if error is associated with PF or VF
   output logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]             chk_rx_err_pfn,       // PF associated with the erroneous TLP
   output logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]             chk_rx_err_vfn,       // VF associated with the erroneous TLP
   output ofs_fim_pcie_pkg::t_tlp_err                        chk_rx_err_code       // Error info
);

import ofs_fim_cfg_pkg::*;
import ofs_fim_pcie_pkg::*;
import ofs_fim_pcie_hdr_def::*;

enum {T0, T1, T2} e_pipeln_stage;
localparam PIPELN = 2;

enum {CH0, CH1} e_channel;
enum {MEM_WR, MEM_RD, CPL, CPLD, MSG, MAX_TLP_TYPE} e_tlp_type;
typedef logic [NUM_AVST_CH-1:0] t_ch;

// MMIO struct
typedef struct packed {
   logic       mmio_req;
   logic [2:0] bar;
   t_tlp_func  func;
} t_mmio_info;

// Maximum data length in a non-SOP packet
localparam bit [PCIE_MAX_LEN_WIDTH-1:0] L_MAX_DATA_LEN = NON_SOP_DWORD_LEN[PCIE_MAX_LEN_WIDTH-1:0];
localparam bit [PCIE_MAX_LEN_WIDTH-1:0] L_MAX_DATA_LEN_X2 = L_MAX_DATA_LEN*2;

//-------------------
// Backpressure 
//-------------------
logic  dn_ready; // Downstream channel ready status to checker
logic  ready;    // Checker ready status back to upstream logic 

//-------------------
// Error status  
//-------------------
t_tlp_err                   err_status_reg;
t_tlp_err [NUM_AVST_CH-1:0] err_status_t0, err_status;

// Completion timeout error
logic                err_cpl_timeout;
logic                err_cpl_timeout_vf_act;
logic [PF_WIDTH-1:0] err_cpl_timeout_pfn;
logic [VF_WIDTH-1:0] err_cpl_timeout_vfn;

// Unsupported request/response
t_ch  err_fmttype_c;

// Unexpected CPL/CPLD
t_ch  err_unexp_cpl_c;

// CPL status error
t_ch err_cpl_status_c;

// Poison bit error
t_ch err_poison_c;

// Malformed packet
t_ch  err_sop;             // Unexpected SOP in single cycle TLP
t_ch  err_eop;             // Unexpected EOP in single cycle TLP
t_ch  err_sop_mc;          // Unexpected SOP in multi-cycle TLP
t_ch  err_eop_mc;          // Unexpected EOP in multi-cycle TLP

//-------------------
// Block erroneous TLP  
//-------------------
t_ch   block_err_tlp;       // Block erroneous TLP from going downstream
t_ch   block_unexp_cpl;     // Block unexpected completion from going downstream
t_ch   block_tlp;
logic  invalid_prev_tlp;    // Indicates if current TLP is part of an erroneous TLP detected earlier

//-------------------
// RX TLP processing
//-------------------
// Detect if two cycles is required to process the incoming TLPs
logic enable_split; 
logic second_tlp_valid;
logic first_tlp_cycle;   // New TLP is received (or the first TLP in a two-cycle processing)
logic second_tlp_cycle;  // Second cycle of TLP processing

// Two-stage pipelines of incoming RX TLP
//    (input)      (stage 1)    (stage 2) 
//    rx_tlp_pipeln[T0]-> rx_tlp_pipeln[T1]-> rx_tlp_pipeln[T2] (rx_tlp)-> rx_tlp_out
//
t_avst_rxs [PIPELN:0] rx_tlp_pipeln;
t_avst_rxs            rx_tlp;

t_ch sop; // Start-of-packet
t_ch sop_has_payload; // Current TLP contains data payload
t_ch eop_t1, eop; // End-of-packet

// DW0 in TLP header of each pipeline stage
t_tlp_hdr_dw0 [NUM_AVST_CH-1:0] rx_hdr_dw0_t0, rx_hdr_dw0_t1, rx_hdr_dw0;

// fmttype field in TLP header of each pipeline stage
logic [NUM_AVST_CH-1:0][6:0] rx_fmttype_t0, rx_fmttype_t1, rx_fmttype;

// TLP type 1-hot bit vector : the corresponding bit in the vector is set 
//  based on the type of current TLP in rx_tlp and rx_tlp_pipeln[T1]
logic [NUM_AVST_CH-1:0][MAX_TLP_TYPE-1:0] tlp_type, tlp_type_t1;

// TLP header
t_tlp_cpl_hdr [NUM_AVST_CH-1:0]     cpl_hdr_t0, cpl_hdr_t1, cpl_hdr; // CPL/CPLD  
t_tlp_msg_hdr [NUM_AVST_CH-1:0]     msg_hdr; // MSG        

t_ch  is_mmio_t1, is_mmio;

t_ch  rx_poison; // Poison bit is set in current TLP     
t_ch  is_completion_t0, is_completion_t1, is_completion; // Is CPL/CPLD?
logic cpld_active;   // Is multi-cycle CPLD active?

// Function associated with current TLP stream the checker is processing 
t_tlp_func [NUM_AVST_CH-1:0] rx_func, rx_func_q; 
// Stores the function of an active multi-cycle TLP stream
t_tlp_func mc_rx_func, mc_rx_func_q;
// Function number of a MRd request that has hit completion timeout
t_tlp_func cpl_timeout_func;
// Function associated with current erroneous TLP
t_tlp_func err_func_reg;


//-----------------------------------------------------------------------------
// 'i_avl_rx_ready' is driven by FIFO almfull flag downstream, we can safely assume
//    it will be asserted when FIFO almost full flag is de-asserted
//    and there is enough buffer in the FIFO to accept additional packets after almfull
//    due to pipeline stages on the FIFO input datapath
//
// Checker accepts new TLP from upstream when the following conditions are TRUE, indicated by ready=1
//   * No active TLP downstream pending acknolwedgement (i_avl_rx_ready=1)
//   * Current TLP packet(s) on the channel(s) does not require split transaction (two-cycle processing)
//   * Checker has finished processing the second TLP of a split transaction

// Backpressure signal from downstream
assign dn_ready = i_avl_rx_ready;

// Backpressure signal to upstream
assign o_avl_rx_ready = ready;

// Ready to consume next TLP 
assign ready = ~enable_split && dn_ready; 

// RX TLP pipelines
assign rx_tlp     = rx_tlp_pipeln[T2];

always_ff @(posedge avl_clk) begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (ready) begin
         rx_tlp_pipeln[T0][ch]     <= i_avl_rx_st[ch];
         rx_tlp_pipeln[T1][ch]     <= rx_tlp_pipeln[T0][ch];
         rx_tlp_pipeln[T2][ch]     <= rx_tlp_pipeln[T1][ch];
         rx_tlp_pipeln[T2][ch].sop <= rx_tlp_pipeln[T1][ch].sop && rx_tlp_pipeln[T1][ch].valid;
         rx_tlp_pipeln[T2][ch].eop <= rx_tlp_pipeln[T1][ch].eop && rx_tlp_pipeln[T1][ch].valid;
      end

      if (~avl_rst_n) begin
         rx_tlp_pipeln[T0][ch].valid <= 1'b0;
         rx_tlp_pipeln[T1][ch].valid <= 1'b0;
         rx_tlp_pipeln[T2][ch].valid <= 1'b0;
         rx_tlp_pipeln[T2][ch].sop   <= 1'b0;
         rx_tlp_pipeln[T2][ch].eop   <= 1'b0;
      end
   end
end

logic [NUM_AVST_CH-1:0]                         cpl_1dw_remain_t0, cpl_1dw_remain_t1;
logic [NUM_AVST_CH-1:0][PCIE_MAX_LEN_WIDTH-1:0] cpl_pend_dw_t1, cpl_pend_dw;

// Extract TLP header fields from the packets for processing in each pipeline stage
// Pipeline stage 0
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      rx_hdr_dw0_t0[ch] = func_get_hdr_dw0(rx_tlp_pipeln[T0][ch]);
      rx_fmttype_t0[ch] = rx_hdr_dw0_t0[ch].fmttype;
      
      // Mapping TLP header to CPL header and UMSG header
      cpl_hdr_t0[ch]        = func_get_hdr(rx_tlp_pipeln[T0][ch]);
      is_completion_t0[ch]  = rx_tlp_pipeln[T0][ch].valid && rx_tlp_pipeln[T0][ch].sop && func_is_completion(rx_fmttype_t0[ch]);
      cpl_1dw_remain_t0[ch] = |cpl_hdr_t0[ch].byte_count[1:0]; 
   end
end

// Pipeline stage 1
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      eop_t1[ch]         = rx_tlp_pipeln[T1][ch].valid && rx_tlp_pipeln[T1][ch].eop;
      cpl_hdr_t1[ch]     = func_get_hdr(rx_tlp_pipeln[T1][ch]);
      rx_hdr_dw0_t1[ch]  = func_get_hdr_dw0(rx_tlp_pipeln[T1][ch]);
      rx_fmttype_t1[ch]  = rx_hdr_dw0_t1[ch].fmttype;
      cpl_pend_dw_t1[ch] = cpl_hdr_t1[ch].byte_count[11:2] + cpl_1dw_remain_t1[ch];
   end
end

// Pipeline stage 2
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      // Current packet on the channel is the start-of-packet
      sop[ch] = rx_tlp[ch].sop;
      // Current packet on the channel is the end-of-packet
      eop[ch] = rx_tlp[ch].eop;

      // 1st DW in TLP header
      rx_hdr_dw0[ch]  = func_get_hdr_dw0(rx_tlp[ch]);
      
      // FMTTYPE field in TLP header
      rx_fmttype[ch]  = rx_hdr_dw0[ch].fmttype;
      
      // Mapping TLP header to CPL header and UMSG header
      cpl_hdr[ch]     = func_get_hdr(rx_tlp[ch]);
      msg_hdr[ch]     = func_get_hdr(rx_tlp[ch]); 

      // Correspondence function to which current TLP on the channel is to be sent
      rx_func[ch]     = is_completion[ch] ? {cpl_hdr[ch].requester_id[3+:VF_WIDTH], cpl_hdr[ch].requester_id[0+:PF_WIDTH], rx_tlp[ch].vf_active}
                           : {rx_tlp[ch].vfn, rx_tlp[ch].pfn, rx_tlp[ch].vf_active};
      // Poison bit in the TLP header
      rx_poison[ch]   = sop[ch] && rx_hdr_dw0[ch].ep; 

      // Mark the start-of-packet of a request/reponse with data payload (e.g. Memory write, completion with data) 
      sop_has_payload[ch] = sop[ch] && rx_fmttype[ch][6];    
   end
end

// Pipeline some of the information needed for the checks to ease timing
always_ff @(posedge avl_clk) begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (~avl_rst_n) begin
         // First pipeline stage
         tlp_type_t1[ch]       <= '0;
         is_completion_t1[ch]  <= 1'b0; 
         is_mmio_t1[ch]        <= 1'b0; 
         cpl_1dw_remain_t1[ch] <= 1'b0;
         // Second pipeline stage
         tlp_type[ch]         <= '0;
         is_completion[ch]    <= 1'b0;
         is_mmio[ch]          <= 1'b0;
         cpl_pend_dw[ch]      <= '0;
      end else if (ready) begin
         // First pipeline stage        
         tlp_type_t1[ch][CPL]    <= rx_tlp_pipeln[T0][ch].valid && rx_tlp_pipeln[T0][ch].sop && (rx_fmttype_t0[ch] == PCIE_FMTTYPE_CPL);
         tlp_type_t1[ch][CPLD]   <= rx_tlp_pipeln[T0][ch].valid && rx_tlp_pipeln[T0][ch].sop && (rx_fmttype_t0[ch] == PCIE_FMTTYPE_CPLD);
         tlp_type_t1[ch][MSG]    <= rx_tlp_pipeln[T0][ch].valid && rx_tlp_pipeln[T0][ch].sop && (rx_fmttype_t0[ch][4:3] == 2'b10);
         tlp_type_t1[ch][MEM_WR] <= rx_tlp_pipeln[T0][ch].valid && rx_tlp_pipeln[T0][ch].sop && func_is_mwr_req(rx_fmttype_t0[ch]);
         tlp_type_t1[ch][MEM_RD] <= rx_tlp_pipeln[T0][ch].valid && rx_tlp_pipeln[T0][ch].sop && func_is_mrd_req(rx_fmttype_t0[ch]);
         is_completion_t1[ch]    <= is_completion_t0[ch];
         is_mmio_t1[ch]          <= rx_tlp_pipeln[T0][ch].valid && rx_tlp_pipeln[T0][ch].sop && func_is_mem_req(rx_fmttype_t0[ch]);
         cpl_1dw_remain_t1[ch]   <= cpl_1dw_remain_t0[ch];
         // Second pipeline stage       
         tlp_type[ch]            <= tlp_type_t1[ch];
         is_completion[ch]       <= is_completion_t1[ch];
         is_mmio[ch]             <= (tlp_type_t1[ch][MEM_WR] | tlp_type_t1[ch][MEM_RD]);
         cpl_pend_dw[ch]         <= cpl_pend_dw_t1[ch];
      end
   end
end

// Populate {vf_active, pf, vf, bar} on every beat of a multi-cycle TLP
t_mmio_info [NUM_AVST_CH-1:0] rx_mmio_info_t1, rx_mmio_info;
t_mmio_info mc_rx_mmio_info;

always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ++ch) begin
      rx_mmio_info_t1[ch].mmio_req       = is_mmio_t1[ch];
      rx_mmio_info_t1[ch].func.vf_active = rx_tlp_pipeln[T1][ch].vf_active;
      rx_mmio_info_t1[ch].func.pfn       = rx_tlp_pipeln[T1][ch].pfn;
      rx_mmio_info_t1[ch].func.vfn       = rx_tlp_pipeln[T1][ch].vfn;
      rx_mmio_info_t1[ch].bar            = rx_tlp_pipeln[T1][ch].bar;
   end
end

always_ff @(posedge avl_clk) begin
   if (ready) begin
      if (NUM_AVST_CH == 1) begin
         if (rx_tlp_pipeln[T1][CH0].sop) begin
            rx_mmio_info[CH0] <= rx_mmio_info_t1[CH0];
         end
      end else begin
         // Channel 0
         if (rx_tlp_pipeln[T1][CH0].sop) 
            rx_mmio_info[CH0] <= rx_mmio_info_t1[CH0];
         else 
            rx_mmio_info[CH0] <= mc_rx_mmio_info;

         // Channel 1
         if (rx_tlp_pipeln[T1][CH1].sop) 
            rx_mmio_info[CH1] <= rx_mmio_info_t1[CH1];
         else if (rx_tlp_pipeln[T1][CH0].sop && ~rx_tlp_pipeln[T1][CH0].eop)
            rx_mmio_info[CH1] <= rx_mmio_info_t1[CH0];
         else 
            rx_mmio_info[CH1] <= mc_rx_mmio_info;

         // Multi-cycle TLP
         if (rx_tlp_pipeln[T1][CH0].sop && ~rx_tlp_pipeln[T1][CH0].eop 
               && ~rx_tlp_pipeln[T1][CH1].sop) 
         begin
            mc_rx_mmio_info <= rx_mmio_info_t1[CH0];
         end 
         else if (rx_tlp_pipeln[T1][CH1].sop && ~rx_tlp_pipeln[T1][CH1].eop)
         begin
            mc_rx_mmio_info <= rx_mmio_info_t1[CH1];
         end 
      end
   end

   if (~avl_rst_n) begin
      mc_rx_mmio_info <= '0;
   end
end

// Keep tracks of the function of a multi-cycle TLP
// The function information is needed when we need to report an error found on subsequent packets in the TLP stream
always_ff @(posedge avl_clk) begin
   if (NUM_AVST_CH == 1) begin
      if (sop[CH0] && ~eop[CH0])
         mc_rx_func <= rx_func[CH0];
   end else begin
      if (sop[CH0] && ~eop[CH0] && ~sop[CH1])
         mc_rx_func <= rx_func[CH0];
      else if (sop[CH1] && ~eop[CH1])
         mc_rx_func <= rx_func[CH1];
   end   
end

// Assert cpld_active when the incoming CPLD spans multiple cycles
always_ff @(posedge avl_clk) begin
   if (NUM_AVST_CH == 1) begin
      if (ready) begin
         if (tlp_type_t1[CH0][CPLD]) 
            cpld_active <= ~eop_t1[CH0];
         else if (cpld_active && eop_t1[CH0])
            cpld_active <= 1'b0;
      end
   end else begin
      if (ready) begin
         if (tlp_type_t1[CH1][CPLD])
            cpld_active <= ~eop_t1[CH1];
         else if (tlp_type_t1[CH0][CPLD])
            cpld_active <= ~eop_t1[CH0] && ~eop_t1[CH1];
         else if (cpld_active && |eop_t1)
            cpld_active <= 1'b0;
      end
   end

   if (~avl_rst_n) 
      cpld_active <= 1'b0;
end

//------------------------------------------------
// Check if current TLP packets on the two AVST channels require two cycles to be processed
// Following TLP combinations on the two channels require two-cycle processing
//
//  ------------------------------------------
//  | No |     CH0     |    CH1     | Reason
//  ------------------------------------------
//  | 1  |  {MMIO SOP} | {MMIO SOP} | Downstream memory decoder processes 1 MMIO per cycle
//  | 2  |  {CPL* SOP} | {CPL* SOP} | PCIe checker processes 1 CPL/CPLD per cycle
//  | 3  |  {CPLD EOP} | {CPL* SOP} | PCIe checker processes 1 CPL/CPLD per cycle
//  ------------------------------------------
//
always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      enable_split <= 1'b0;
   end else begin
      if (NUM_AVST_CH > 1) begin
         if (dn_ready) begin
            if (enable_split) 
            begin
               enable_split <= 1'b0;
            end else if (&is_mmio_t1 || &is_completion_t1) 
            begin // Two MMIO requests on the same cycle OR two CPL/CPLD on the same cycle               
               enable_split <= 1'b1;
            end else if (cpld_active && is_completion_t1[CH1]) 
            begin // End of multi-cycle CPLD on channel 0 and start of CPL/CPLD on channel 1               
               enable_split <= 1'b1;
            end
         end 
      end
   end
end

// second_tlp_valid indicates it is ok to process the packet on channel 1 in a two-cycle processing
// second_tlp_valid is asserted on the same cycle the TLP on channel 0 is sent downstream (if not blocked due to error)
// and remains asserted until the first TLP is acknowledged by downstream receiver (downstream ready signal is asserted)
always_ff @(posedge avl_clk) begin
   if (NUM_AVST_CH > 1) begin
      if (~avl_rst_n)
         second_tlp_valid <= 1'b0;
      else if (dn_ready)
         second_tlp_valid <= enable_split;
   end
end

assign first_tlp_cycle  = dn_ready && ~second_tlp_valid;
assign second_tlp_cycle = dn_ready && second_tlp_valid;


//---------------------------------------------------------------
// Check FMTTYPE
//---------------------------------------------------------------
//
// Error detection:
//    Detect fmttype that's not supported by downstream logic (FIM)
// 
// Error handling:
//    Drop illegal request and log the error
//    Drop subsequent packets of the unsupported request
//
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      err_fmttype_c[ch] = 1'b0;
      if (sop[ch]) begin
         if (tlp_type[ch][MSG]) begin
            // Error out if UMSG is received and the message code is not part of the white-listed code
            err_fmttype_c[ch] = (msg_hdr[ch].msg_code != UMSG_CODE_PM_PME)
                                 && (msg_hdr[ch].msg_code != UMSG_CODE_ATS_INVAL_REQ)
                                 && (msg_hdr[ch].msg_code != UMSG_CODE_ATS_INVAL_CPL)
                                 && (msg_hdr[ch].msg_code != UMSG_CODE_SET_SLOT_PWR_LIMIT)
                                 && (msg_hdr[ch].msg_code != UMSG_CODE_VENDOR_TYPE_1);
         end else begin
            // Error out if the TLP is not a MMIO request and not a completion (w/ and w/o data)
            err_fmttype_c[ch] = ~is_mmio[ch] && ~is_completion[ch];
         end
      end
   end
end

//---------------------------------------------------------------
// Catch sop/eop violation
//---------------------------------------------------------------
//
// Error detection:
//    Detect unexpected start-of-packet
//      - SOP is received in the middle of a TLP stream that has not ended yet
//    Detect unexpected end-of-packet
//      - EOP is received earlier than expected, e.g. when more data payload is expected to be received
//      - EOP is received later than expected, e.g. no more data is expected to be received
// 
// Error handling:
//    Illegal SOP and SOP is logged as malformed TLP error, which is uncorrectable fatal error
//    that requires system reboot and reprogramming the FPGA
//

generate
if (ENABLE_MALFORMED_TLP_CHECK == 1) begin : malformed_tlp
   // Maximum payload allowed in header packet
   logic [NUM_AVST_CH-1:0][PCIE_MAX_LEN_WIDTH-1:0]  hdr_packet_max_data_len_t1;                                                      
   
   // Indicate if there is pending payload for current TLP When packet is received on single channel
   t_ch  tlp_pending;
   logic [NUM_AVST_CH-1:0][PCIE_MAX_LEN_WIDTH-1:0] tlp_pending_payload; 
   
   // Indicate if there is pending payload for current TLP When packets of the same TLP 
   // are received on both RX channels on the same cycle i.e. SOP on CH0 and data packet on CH1
   logic tlp_pending_2ch;    
   logic [PCIE_MAX_LEN_WIDTH-1:0] tlp_pending_payload_2ch; 
   
   // Indicates if current TLP has data length set to the maximum payload allowed by PCIe standard
   t_ch  max_pcie_payload; 
   
   // Multi-cycle TLP stream is active 
   logic tlp_active;   
   
   // Pending data (DW) to complete the transfer
   logic [PCIE_MAX_LEN_WIDTH-1:0] pending_dword_cnt; 
   
   always_comb begin
      for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
         // The effective payload length on a channel for start-of-packet TLP 
         //    e.g. On H-TILE, the effective payload length for SOP packet is 3DW/4DW less since the data channel also
         //         carries TLP header of 3DW/4DW
         `ifdef PTILE
            hdr_packet_max_data_len_t1[ch] = AVST_DWORD_LEN[PCIE_MAX_LEN_WIDTH-1:0]; 
         `else
            hdr_packet_max_data_len_t1[ch] = rx_fmttype_t1[ch][5] ? SOP_4DW_DWORD_LEN[PCIE_MAX_LEN_WIDTH-1:0] : SOP_3DW_DWORD_LEN[PCIE_MAX_LEN_WIDTH-1:0];
         `endif
      end
   end
   
   always_ff @(posedge avl_clk) begin
      if (ready) begin
         for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
            // length=0 in PCIe TLP header indicates max data length 1024 DW (4096 bytes)
            max_pcie_payload[ch]    <= (rx_hdr_dw0_t1[ch].length == 10'd0);
            tlp_pending_payload[ch] <= (rx_hdr_dw0_t1[ch].length - hdr_packet_max_data_len_t1[ch]);
            tlp_pending[ch]         <= (rx_hdr_dw0_t1[ch].length > hdr_packet_max_data_len_t1[ch]);
         end
   
         if (NUM_AVST_CH > 1) begin 
            tlp_pending_payload_2ch <= (rx_hdr_dw0_t1[CH0].length - hdr_packet_max_data_len_t1[CH0] - L_MAX_DATA_LEN);
            tlp_pending_2ch         <= (rx_hdr_dw0_t1[CH0].length > (hdr_packet_max_data_len_t1[CH0] + L_MAX_DATA_LEN));
         end
      end
   end
   
   always_ff @(posedge avl_clk) begin
      if (NUM_AVST_CH == 1) begin
         if (first_tlp_cycle && tlp_active && rx_tlp[CH0].valid)
            pending_dword_cnt <= pending_dword_cnt - L_MAX_DATA_LEN;
         else if (first_tlp_cycle && sop_has_payload[CH0])
            pending_dword_cnt <= max_pcie_payload[CH0] ? 11'h400 : tlp_pending_payload[CH0]; 
      end else begin
         if (first_tlp_cycle) begin
            if (tlp_active) begin // Multi-cycle packet
               if (rx_tlp[CH0].valid && rx_tlp[CH1].valid)
                  pending_dword_cnt <= pending_dword_cnt - L_MAX_DATA_LEN_X2;
               else if (rx_tlp[CH0].valid || rx_tlp[CH1].valid)
                  pending_dword_cnt <= pending_dword_cnt - L_MAX_DATA_LEN;
            end
   
            // Request/Response with data
            if (sop_has_payload[CH1])                
               pending_dword_cnt <= max_pcie_payload[CH1] ? 11'h400 : tlp_pending_payload[CH1];
            else if (sop_has_payload[CH0])
               pending_dword_cnt <= max_pcie_payload[CH0] ? 11'h400 
                                       : rx_tlp[CH0].valid ? tlp_pending_payload_2ch : tlp_pending_payload[CH0];
         end
      end
   end
   
   // Track multi-cycle TLP
   always_ff @(posedge avl_clk) begin
      if (~avl_rst_n) begin
         tlp_active <= 1'b0;
      end else begin
         if (NUM_AVST_CH == 1) begin
            if (first_tlp_cycle && rx_tlp[CH0].valid) begin
               tlp_active <= 1'b0;
               if (sop_has_payload[CH0]) begin
                  if (~eop[CH0])
                     tlp_active <= (max_pcie_payload[CH0] || tlp_pending[CH0]);
               end else if (tlp_active && ~sop[CH0] && ~eop[CH0]) begin
                  tlp_active <= (pending_dword_cnt > L_MAX_DATA_LEN);
               end
            end
         end else begin
            if (first_tlp_cycle && (rx_tlp[CH0].valid || rx_tlp[CH1].valid)) begin
               tlp_active <= 1'b0;
   
               if (sop_has_payload[CH1]) begin
                  if (~eop[CH1]) 
                     tlp_active <= (max_pcie_payload[CH1] || tlp_pending[CH1]);
               end else if (sop_has_payload[CH0]) begin
                  if (~eop[CH0]) begin
                     if (~rx_tlp[CH1].valid)
                        tlp_active <= (max_pcie_payload[CH0] || tlp_pending[CH0]);
                     else if (~sop[CH1] && ~eop[CH1])
                        tlp_active <= (max_pcie_payload[CH0] || tlp_pending_2ch);
                  end
               end else if (tlp_active) begin
                  if (~sop[CH0] && ~eop[CH0] && ~sop[CH1] && ~eop[CH1]) begin
                     if (rx_tlp[CH0].valid && rx_tlp[CH1].valid)
                        tlp_active <= (pending_dword_cnt > L_MAX_DATA_LEN_X2);
                     else 
                        tlp_active <= (pending_dword_cnt > L_MAX_DATA_LEN);
                  end
               end
            end
         end
      end
   end
   
   always_ff @(posedge avl_clk) begin
      err_sop    <= '0;
      err_eop    <= '0;
      err_sop_mc <= '0;
      err_eop_mc <= '0;
      
      if (NUM_AVST_CH == 1) begin
         if (first_tlp_cycle) begin
            if (tlp_active && rx_tlp[CH0].valid) begin // Multi-cycle packet         
               err_sop_mc[CH0] <= sop[CH0];
               err_eop_mc[CH0] <= (pending_dword_cnt <= L_MAX_DATA_LEN) ? ~eop[CH0] : eop[CH0];
            end
            
            if (sop_has_payload[CH0]) begin // Request/Response with data            
               if (max_pcie_payload[CH0] || tlp_pending[CH0])
                  err_eop[CH0] <= eop[CH0];
               else
                  err_eop[CH0] <= ~eop[CH0];
            end else if (sop[CH0]) begin // Request/Response without data
               err_eop[CH0] <= ~eop[CH0];
            end
         end
      end else begin      
         if (first_tlp_cycle) begin
            // Multi-cycle packet transfer is active
            if (tlp_active) begin
               // Packets received on both channel 0 and channel 1
               if (rx_tlp[CH0].valid && rx_tlp[CH1].valid) begin
                  if (pending_dword_cnt <= L_MAX_DATA_LEN) begin
                     err_eop_mc[CH0] <= ~eop[CH0];
                     err_sop_mc[CH0] <= sop[CH0];
                  end else if (pending_dword_cnt <= L_MAX_DATA_LEN_X2) begin
                     err_eop_mc <= {~eop[CH1], eop[CH0]};
                     err_sop_mc <= sop;
                  end else begin
                     err_eop_mc <= eop;
                     err_sop_mc <= sop;
                  end
               // Packets received on either channel 0 or channel 1
               end else if (rx_tlp[CH0].valid || rx_tlp[CH1].valid) begin
                  if (pending_dword_cnt <= L_MAX_DATA_LEN) begin
                     err_sop_mc    <= sop;
                     err_eop_mc[CH0] <= rx_tlp[CH0].valid && ~eop[CH0];
                     err_eop_mc[CH1] <= rx_tlp[CH1].valid && ~eop[CH1];                  
                  end else begin
                     err_eop_mc <= eop;
                  end
               end 
            end 
            
            // Request/Response received on channel 0
            if (sop_has_payload[CH0]) begin // with data
               if (~max_pcie_payload[CH0] && ~tlp_pending[CH0]) begin
                  err_eop[CH0] <= ~eop[CH0];
               end else if (rx_tlp[CH1].valid && ~max_pcie_payload[CH0] && ~tlp_pending_2ch) begin
                  err_sop[CH1] <= sop[CH1];
                  err_eop    <= {~eop[CH1], eop[CH0]};
               end else begin
                  err_eop    <= eop;
                  err_sop[CH1] <= sop[CH1];
               end
            end else if (sop[CH0]) begin // without data
               err_eop[CH0] <= ~eop[CH0];
            end
         
            // Request/Response received on channel 1
            if (sop_has_payload[CH1]) begin // with data         
               if (max_pcie_payload[CH1] || tlp_pending[CH1])
                  err_eop[CH1] <= eop[CH1];
               else
                  err_eop[CH1] <= ~eop[CH1];
            end else if (sop[CH1]) begin // without data
               err_eop[CH1] <= ~eop[CH1];
            end
         end
      end
   
      if (~avl_rst_n) begin
         err_sop <= '0;
         err_eop <= '0;
         err_sop_mc <= '0;
         err_eop_mc <= '0;
      end
   end
end else begin : malformed_tlp_off
   assign err_eop = 1'b0;
   assign err_sop = 1'b0;
   assign err_sop_mc = 1'b0;
   assign err_eop_mc = 1'b0;
end
endgenerate

//---------------------------------------------------------------
// Pending CPL data counter
//---------------------------------------------------------------
// Total of pending read data that has been requested so far
//
// The counter is incremented with the data length in the memory read request TLP
// when the read request is sent to the host
//
// The counter is decremented with the data length in a read completion TLP
// when the completion is received
//
// The count is used to decide whether the CPLD buffer in PCIe IP
// has enough credit to take in more completion data
//
// PCIe TX bridge will stop sending memory read request if the amount 
// of pending data hits the credit limit
//

logic                          cpl_pending_data_add;     // Increment pending data count
logic [PCIE_MAX_LEN_WIDTH-1:0] cpl_pending_data_add_val; // Pending data count value to be added
logic                          cpl_pending_data_sub_t0;  // Decrement pending data count
logic                          cpl_pending_data_sub;     
logic [PCIE_MAX_LEN_WIDTH-1:0] cpl_pending_data_sub_val_t0; // Completion payload to be decremented from pending data count
logic [PCIE_MAX_LEN_WIDTH-1:0] cpl_pending_data_sub_val; 

assign cpl_pending_data_add     = tx_mrd_valid;
assign cpl_pending_data_add_val = tx_mrd_length;

// Substract completion payload from pending data count
always_ff @(posedge avl_clk) begin
   cpl_pending_data_sub_val_t0 <= '0;
   
   if (NUM_AVST_CH == 1) begin
      if (tlp_type[CH0][CPL])
         cpl_pending_data_sub_val_t0 <= cpl_pend_dw[CH0];
      else if (tlp_type[CH0][CPLD])
         cpl_pending_data_sub_val_t0 <= cpl_hdr[CH0].dw0.length;
   end else begin
      // When new CPL/CPLD packet is received on channel 0 
      if (first_tlp_cycle) begin
         if (tlp_type[CH0][CPL])
            cpl_pending_data_sub_val_t0 <= cpl_pend_dw[CH0];
         else if (tlp_type[CH0][CPLD])
            cpl_pending_data_sub_val_t0 <= cpl_hdr[CH0].dw0.length;
      end

      // When new CPL/CPLD is received on channel 1 and not channel 0 
      // (OR) the CPL/CPLD on channel 1 is the second TLP of a split transaction
      if (ready) begin
         if (tlp_type[CH1][CPL])
            cpl_pending_data_sub_val_t0 <= cpl_pend_dw[CH1];
         if (tlp_type[CH1][CPLD])
            cpl_pending_data_sub_val_t0 <= cpl_hdr[CH1].dw0.length;
      end
   end
end

always_ff @(posedge avl_clk) begin 
   cpl_pending_data_sub_val <= cpl_pending_data_sub_val_t0;
end

always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      cpl_pending_data_sub_t0 <= 1'b0;
   end else begin
      cpl_pending_data_sub_t0 <= 1'b0;
      if (first_tlp_cycle && is_completion[CH0]) 
      begin
         cpl_pending_data_sub_t0 <= 1'b1;
      end

      if (NUM_AVST_CH > 1) begin
         if (ready && is_completion[CH1]) 
         begin
            cpl_pending_data_sub_t0 <= 1'b1;
         end
      end
   end
end

always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      cpl_pending_data_sub <= 1'b0;
   end else begin
      // Don't substract unexpected completions from pending data count
      if (|block_unexp_cpl) begin
         cpl_pending_data_sub <= 1'b0;
      end else begin
         cpl_pending_data_sub <= cpl_pending_data_sub_t0;
      end
   end
end

always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      cpl_pending_data_cnt <= '0; 
   end else begin
      case ({cpl_pending_data_add, cpl_pending_data_sub})
         2'b10 : begin
            cpl_pending_data_cnt <= cpl_pending_data_cnt + cpl_pending_data_add_val;
         end
         2'b01 : begin
            cpl_pending_data_cnt <= cpl_pending_data_cnt - cpl_pending_data_sub_val;
         end
         2'b11 : begin
            cpl_pending_data_cnt <= cpl_pending_data_cnt + cpl_pending_data_add_val - cpl_pending_data_sub_val;
         end
      endcase
   end
end

//---------------------------------------------------------------
// Track active MRd request
//---------------------------------------------------------------
// Bit vector of size MAX TAG count to indicate if a tag is already used in a pending MRd request
logic [PCIE_EP_MAX_TAGS-1:0]  tr_tag_active;
t_ch                          cpl_tag_active;    // If the tag in current CPL/CPLD exists in tr_tag_active

t_ch      last_cpl;                           // Is current completion the last completion of a MRd request?
logic     last_cpl_active, last_cpl_active_q; // Is multi-cycle last completion TLP active? 
t_tlp_tag last_cpl_tag, last_cpl_tag_q;       // Tag in last completion TLP

// Last packet of the last completion of a MRd request has been received
t_ch  cpl_complete;     
logic cpl_complete_q;
logic prev_cpl_complete;

// Tag to be released to the tag pool
t_tlp_tag [NUM_AVST_CH-1:0] cpl_complete_tag;
t_tlp_tag                   cpl_complete_tag_q;
t_tlp_tag                   prev_cpl_complete_tag;

always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1)
      last_cpl[ch] = (cpl_hdr[ch].dw0.length >= cpl_hdr[ch].byte_count[11:2]);
end

// A tag is released when the last completion packet of a memory read request is received 
always_comb begin
   cpl_complete     = '0;
   cpl_complete_tag = '0;
   last_cpl_active  = last_cpl_active_q;
   last_cpl_tag     = last_cpl_tag_q;

   if (first_tlp_cycle) begin
      // CPL is received on channel 0, release the tag
      if (tlp_type[CH0][CPL]) begin
         cpl_complete[CH0]     = 1'b1;
         cpl_complete_tag[CH0] = cpl_hdr[CH0].tag[PCIE_EP_TAG_WIDTH-1:0];
      end else if(tlp_type[CH0][CPLD] && last_cpl[CH0]) begin    
         if ( |eop ) begin 
            // CPLD received on channel 0 is the last completion of a read request
            // and the last packet is received on channel 0 or channel 1
            // Release the tag
            cpl_complete[CH0]     = 1'b1;
            cpl_complete_tag[CH0] = cpl_hdr[CH0].tag[PCIE_EP_TAG_WIDTH-1:0];
         end else begin
            // CPLD received on channel 0 is the last completion of a read request
            // but the last packet has not been received yet either on channel 0 or channel 1
            // Store the CPL tag in the header and assert last_cpl_active_q to notify checker
            // that subsequent packets are part of the last completion for a memory read
            // De-assert last_cpl_active_q when the last packet is eventually received
            last_cpl_active = 1'b1;
            last_cpl_tag    = cpl_hdr[CH0].tag[PCIE_EP_TAG_WIDTH-1:0];
         end
      end else if (last_cpl_active_q && |eop) begin
         // The last packet of a multi-cycle last completion of a memory read has been received
         // Release the pre-stored tag and de-assert last_cpl_active_q
         cpl_complete[CH0]     = 1'b1;
         cpl_complete_tag[CH0] = last_cpl_tag_q;
         last_cpl_active       = 1'b0;
      end
   end
   
   if (NUM_AVST_CH > 1) begin     
      if (ready) begin
         // CPL is received on channel 1, release the tag
         if (tlp_type[CH1][CPL]) begin
            cpl_complete[CH1]     = 1'b1;
            cpl_complete_tag[CH1] = cpl_hdr[CH1].tag[PCIE_EP_TAG_WIDTH-1:0];
         end else if (tlp_type[CH1][CPLD] && last_cpl[CH1]) begin
            if (eop[CH1]) begin
               cpl_complete[CH1]     = 1'b1;
               cpl_complete_tag[CH1] = cpl_hdr[CH1].tag[PCIE_EP_TAG_WIDTH-1:0];
            end else begin
               last_cpl_active = 1'b1;
               last_cpl_tag    = cpl_hdr[CH1].tag[PCIE_EP_TAG_WIDTH-1:0];
            end
         end 
      end
   end
end

always_ff @(posedge avl_clk) begin
   if (~avl_rst_n)
      last_cpl_active_q <= 1'b0;
   else
      last_cpl_active_q <= last_cpl_active;
end

always_ff @(posedge avl_clk) begin
   last_cpl_tag_q <= last_cpl_tag;
end

always_ff @(posedge avl_clk) begin
   cpl_complete_q <= |cpl_complete;
   if (dn_ready) 
      prev_cpl_complete <= |cpl_complete;

   if (NUM_AVST_CH == 1) begin
      cpl_complete_tag_q <= cpl_complete_tag[CH0];
      if (dn_ready) 
         prev_cpl_complete_tag <= cpl_complete_tag[CH0];
   end else begin
      cpl_complete_tag_q <= cpl_complete[CH0] ? cpl_complete_tag[CH0] : cpl_complete_tag[CH1];
      if (dn_ready) 
         prev_cpl_complete_tag <= cpl_complete[CH0] ? cpl_complete_tag[CH0] : cpl_complete_tag[CH1];
   end
end

always @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      tr_tag_active <= '0;
   end else begin
      if (tx_mrd_valid) 
         tr_tag_active[tx_mrd_tag] <= 1'b1; 
      if (cpl_complete_q) 
         tr_tag_active[cpl_complete_tag_q] <= 1'b0;
   end
end

//---------------------------------------------------------------
// Catch unexpected CPL/CPLD 
//---------------------------------------------------------------
//
// Error detection:
//    Detect unexpected CPL/CPLD when no memory read is sent with the tag
// 
// Error handling:
//    Log the error as unexpected completion status in AER
//    Drop illegal request and subsequent packets of the unsupported request
//
always_ff @(posedge avl_clk) begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (ready)
         cpl_tag_active[ch] <= tr_tag_active[cpl_hdr_t1[ch].tag];
   end
end

// If CPL/CPLD is received on channel 0 and channel 1 on the same cycle, which requires split transaction
// assert the unexpected completion error for each CPL/CPLD in separate clock cycle
always_comb begin
   err_unexp_cpl_c = '0;
   
   // Channel 0
   if (first_tlp_cycle && is_completion[CH0]) 
   begin
      // (1) CPL tag is not active (no pending MRd request) -OR-
      // (2) The tag is about to be de-activated in the next cycle 
      //     because the final packet of a completion with similar tag has been received
      //     in previous cycle. It takes two cycles to de-activate a tag.
      if (~cpl_tag_active[CH0] 
            || (prev_cpl_complete && (cpl_hdr[CH0].tag == prev_cpl_complete_tag)))
      begin
         err_unexp_cpl_c[CH0] = 1'b1;
      end
   end

   // Channel 1
   if (NUM_AVST_CH > 1) begin
      if (ready && is_completion[CH1]) 
      begin
         // (1) CPL tag is not active (no pending MRd request) -OR-
         // (2) The tag is about to be de-activated in the next cycle 
         //     because the final packet of a completion with similar tag has been received
         //     in previous cycle. It takes two cycles to de-activate a tag.
         if (~cpl_tag_active[CH1]
               || (prev_cpl_complete && (cpl_hdr[CH1].tag == prev_cpl_complete_tag)))
         begin
            err_unexp_cpl_c[CH1] = 1'b1;
         end
      end
   end
end

//---------------------------------------------------------------
// Memory read completion timeout
//---------------------------------------------------------------
generate 
if (ENABLE_COMPLETION_TIMEOUT_CHECK == 1) begin : cpl_timeout
   logic      ttq_start_time_valid;     // Tag is associated with an active MRd request pending completion
   logic      ttq_start_time_valid_t1, ttq_start_time_valid_t2;   
   t_tlp_tag  ttq_tp;                   // Tag to check for completion timeout
   t_tlp_tag  ttq_start_time_raddr;      
   
   logic [CPL_TIME_WIDTH-1:0]    ttq_timer;         // Free running timer
   logic                         ttq_start_time_re; // Read the timestamp of an active MRd request  
   
   logic [CPL_TIME_WIDTH-1:0]    ttq_st_dout;       // Timestamp of an active MRd request
   logic                         ttq_vf_act;        // Is MRd request sent by a VF?
   logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]          ttq_pfn;           // PF number associated with the MRd request
   logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]          ttq_vfn;           // VF number associated with the MRd request
   
   logic [CPL_TIME_WIDTH+1:0]    ttq_elapsed_time;   // How long a MRd request has been waiting for completion
   logic                         ttq_elapsed_vf_act; // Is MRd request sent by VF?
   logic [PF_WIDTH-1:0]          ttq_elapsed_pfn;    // PF number associated with the MRd request
   logic [VF_WIDTH-1:0]          ttq_elapsed_vfn;    // VF number associated with the MRd request
   
   // Free-running timer
   always_ff @(posedge avl_clk) begin
      if (~avl_rst_n)
         ttq_timer <= 26'h0;        
      else
         ttq_timer <= ttq_timer + 1'b1;
   end
   
   // In a round-robin fasion, check if the wait time for any in-flight memory read request
   // has exceeded the timeout limit for host to return the completion
   always_ff @(posedge avl_clk) begin
      if (~avl_rst_n) begin
         ttq_tp                  <= t_tlp_tag'(0);
         ttq_elapsed_time        <= 28'b0;
         ttq_start_time_valid    <= 1'b0;
         ttq_start_time_valid_t1 <= 1'b0;
         ttq_start_time_valid_t2 <= 1'b0;
         ttq_start_time_raddr    <= t_tlp_tag'(0);
      end
      else begin
         // Check if there is an in-flight memory read request associated with the round-robin tag
         ttq_start_time_valid <= tr_tag_active[ttq_tp];        
         
         // Read the start time of the in-flight memory read request from RAM, using the round-robin tag
         // It takes 1 cycle to read from the ram
         ttq_start_time_raddr <= ttq_tp;
         ttq_start_time_valid_t1 <= ttq_start_time_valid;
         ttq_start_time_valid_t2 <= ttq_start_time_valid_t1;
         
         // Register the start time and function for the memory read request that are retrieved from the ram
         if (ttq_start_time_valid_t1) begin // memory read request pending for completion  
            ttq_elapsed_time      <= {2'b01, ttq_timer} - {2'b00,ttq_st_dout};
            ttq_elapsed_vf_act    <= ttq_vf_act;
            ttq_elapsed_pfn       <= ttq_pfn;
            ttq_elapsed_vfn       <= ttq_vfn;
         end
         
         // Increement the round-robin tag
         ttq_tp <= incr_tlp_tag(ttq_tp);
      end
   end  
   
   // Gate read with avl_rst_n since clk may not be active during reset, and ram is not driven by reset
   assign ttq_start_time_re = (~avl_rst_n) ? 1'b0 : ttq_start_time_valid; 
      
   ram_1r1w #(
      .DEPTH(PCIE_EP_TAG_WIDTH),
      .WIDTH(1+VF_WIDTH+PF_WIDTH+CPL_TIME_WIDTH),
      .GRAM_MODE(2'd1),
      .GRAM_STYLE(`GRAM_AUTO),
      .INCLUDE_PARITY(0)
   )
   ttq_start_time_buf (
      .clk   (avl_clk),
      .din   ({tx_mrd_vf_act, tx_mrd_vfn, tx_mrd_pfn, ttq_timer}),
      .waddr (tx_mrd_tag),
      .we    (tx_mrd_valid),
      .raddr (ttq_start_time_raddr),
      .re    (ttq_start_time_re),
      .dout  ({ttq_vf_act, ttq_vfn, ttq_pfn, ttq_st_dout})
   );
   
   // Check if the waiting time has exceeded the completion timeout limit
   always_ff @(posedge avl_clk) begin
      if (~avl_rst_n) begin
         err_cpl_timeout <= 1'b0;
      end else begin
         err_cpl_timeout <= 1'b0;
         if (ttq_start_time_valid_t2) begin
            if ({2'b0, ttq_elapsed_time[CPL_TIME_WIDTH-1:0]} > PCIE_CPL_TIMEOUT) begin
               err_cpl_timeout    <= 1'b1;
               cpl_timeout_func   <= {ttq_elapsed_vfn, ttq_elapsed_pfn, ttq_elapsed_vf_act}; 
            end
         end
      end
   end
end else begin : cpl_timeout_off
   assign err_cpl_timeout = 1'b0;
   assign cpl_timeout_func = '0;
end
endgenerate

//---------------------------------------------------------------
//    Block illegal packets below from going downstream
//       * TLP with unsupported fmttype
//       * Unexpected completion
//
//    Malformed packets with illegal sop/eop can't be gracefully handled
//    and will be flagged as uncorrectable fatal error that requires
//    a system reboot/reprogram the FPGA
//
//---------------------------------------------------------------
t_avst_rxs rx_tlp_out;

always_ff @(posedge avl_clk) begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (~avl_rst_n) begin
         block_err_tlp[ch]   <= 1'b0;
         block_unexp_cpl[ch] <= 1'b0;
      end else if (dn_ready) begin
         //block_err_tlp[ch]   <= (err_fmttype_c[ch] || tlp_type[ch][MSG]);
         block_err_tlp[ch]   <= (err_fmttype_c[ch]); // || tlp_type[ch][MSG]); Commented for VDM TLP MSG to be unblocked
         block_unexp_cpl[ch] <= err_unexp_cpl_c[ch];
      end
   end
end
assign block_tlp = (block_err_tlp | block_unexp_cpl);

// Ths is the last stage of the pipeline before sending the TLPs downstream
// If concurrent TLPs on channel 0 and channel 1 can't be consumed by downstream in a single cycle, 
// split the transaction into two cycles by sending channel 0 TLP first followed by channel 1 TLP on the next cycle
always_ff @(posedge avl_clk) begin
   if (first_tlp_cycle) begin
      rx_tlp_out <= rx_tlp;
      for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
         rx_tlp_out[ch].mmio_req  <= rx_mmio_info[ch].mmio_req;
         rx_tlp_out[ch].vf_active <= rx_mmio_info[ch].func.vf_active;
         rx_tlp_out[ch].pfn       <= rx_mmio_info[ch].func.pfn;
         rx_tlp_out[ch].vfn       <= rx_mmio_info[ch].func.vfn;
         rx_tlp_out[ch].bar       <= rx_mmio_info[ch].bar;
      end
   end

   // Channel 1
   if (NUM_AVST_CH > 1) begin
      if (first_tlp_cycle && enable_split) // Delay sending packet on channel 1
      begin
         rx_tlp_out[CH1].valid <= 1'b0; 
      end       
      else if (second_tlp_cycle) // second cycle of two-cycle processing
      begin
         // Send the channel 1 packet which was delayed, de-activate channel 0 packet 
         rx_tlp_out[CH0].valid <= 1'b0;
         rx_tlp_out[CH1].valid <= 1'b1;
      end
   end

   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      if (~avl_rst_n) begin
         rx_tlp_out[ch].valid <= 1'b0;
      end
   end
end

// Detect if subsequent packets need to be blocked for an erroneous TLP
// e.g. multi-cycle memory write, multi-cycle completion
always_ff @(posedge avl_clk) begin
   if (NUM_AVST_CH == 1) begin
      if (block_tlp[CH0]) 
         invalid_prev_tlp <= ~rx_tlp_out[CH0].eop;
      else if (invalid_prev_tlp && rx_tlp_out[CH0].sop)
         invalid_prev_tlp <= 1'b0;
   end else begin
      if (dn_ready) begin
         if (rx_tlp_out[CH1].valid && block_tlp[CH1])
            invalid_prev_tlp <= ~rx_tlp_out[CH1].eop;
         else if (rx_tlp_out[CH0].valid && block_tlp[CH0])
            invalid_prev_tlp <= ~rx_tlp_out[CH0].eop 
                                 && (~rx_tlp_out[CH1].valid || ~rx_tlp_out[CH1].sop);
         else if (invalid_prev_tlp && 
                     ((rx_tlp_out[CH0].valid && rx_tlp_out[CH0].sop) // New TLP stream received on channel 0
                        || (rx_tlp_out[CH1].valid && rx_tlp_out[CH1].sop))) // New TLP stream received on channel 1
            invalid_prev_tlp <= 1'b0;
      end
   end

   if(~avl_rst_n) 
      invalid_prev_tlp <= '0;
end

// Sending packets downstream if they are not blocked
always_ff @(posedge avl_clk) begin
   if (dn_ready) begin
      o_avl_rx_st <= rx_tlp_out;
   end   

   // Channel 0
   if (dn_ready && rx_tlp_out[CH0].valid) begin // dn_ready && ~second_tlp_valid
      // Block the TLP if error is found on the packet on channel 0 or the packet is part of an illegal multi-cycle TLP
      if (block_tlp[CH0]) // error found on current packet
         o_avl_rx_st[CH0].valid <= 1'b0;
      else if (invalid_prev_tlp && ~rx_tlp_out[CH0].sop) // part of an illegal multi-cycle TLP
         o_avl_rx_st[CH0].valid <= 1'b0;
   end 
   // Packet on channel 0 is acknowledged by downstream receiver, de-assert valid
   else if (dn_ready) begin 
      o_avl_rx_st[CH0].valid <= 1'b0;
   end
   
   // Channel 1
   if (NUM_AVST_CH > 1) begin
      if (dn_ready && rx_tlp_out[CH1].valid) 
      begin
         // Block the TLP if error is found on the packet on channel 1 or the packet is part of an illegal multi-cycle TLP
         if (block_tlp[CH1])
            o_avl_rx_st[CH1].valid <= 1'b0;
         // Current packet is part of an illegal TLP, block it
         else if ((block_tlp[CH0] || (invalid_prev_tlp && rx_tlp_out[CH0].valid && ~rx_tlp_out[CH0].sop))
                     && ~rx_tlp_out[CH1].sop)
            o_avl_rx_st[CH1].valid <= 1'b0;
      end
      // Packet on channel 1 is acknowledged by downstream receiver, de-assert valid
      else if (dn_ready) begin
         o_avl_rx_st[CH1].valid <= 1'b0;
      end
   end
end

//---------------------------------------------------------------
// Error output assignment
//---------------------------------------------------------------
always_comb begin
   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      err_cpl_status_c[ch] = tlp_type[ch][CPL];
      err_poison_c[ch]     = rx_poison[ch];
   end
end

always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      err_status_t0 <= '0;
   end else begin
      err_status_t0 <= '0;

      // When two completions are received on the same cycle, err_unexp_cpl_c[CH0] is only valid 
      // on the first cycle and err_unexp_cpl_c[CH1] is only valid on the second cycle
      if (first_tlp_cycle) begin
         err_status_t0[CH0].err_poison     <= err_poison_c         [CH0];
         err_status_t0[CH0].err_cpl_status <= err_cpl_status_c     [CH0];
         err_status_t0[CH0].err_unexp_cpl  <= err_unexp_cpl_c      [CH0];
         err_status_t0[CH0].err_fmttype    <= err_fmttype_c        [CH0];
      end 

      if (NUM_AVST_CH > 1) begin
         if (ready) begin
            err_status_t0[CH1].err_poison     <= err_poison_c         [CH1];
            err_status_t0[CH1].err_cpl_status <= err_cpl_status_c     [CH1];
            err_status_t0[CH1].err_unexp_cpl  <= err_unexp_cpl_c      [CH1];
            err_status_t0[CH1].err_fmttype    <= err_fmttype_c        [CH1];
         end
      end
   end
end

always_comb begin
   err_status = err_status_t0;
   
   err_status[CH0].err_cpl_timeout = err_cpl_timeout;
   if (NUM_AVST_CH > 1) begin
      err_status[CH1].err_cpl_timeout = 1'b0;
   end

   for (int ch=0; ch<NUM_AVST_CH; ch=ch+1) begin
      err_status[ch].err_malformed_sop = (err_sop[ch] | err_sop_mc[ch]);
      err_status[ch].err_malformed_eop = (err_eop[ch] | err_eop_mc[ch]);
   end
end

always_ff @(posedge avl_clk) begin
   if (NUM_AVST_CH == 1) begin
      err_status_reg <= err_status[CH0];
   end else begin
      for (int i=0; i<TLP_ERR_WIDTH; i=i+1) begin 
         err_status_reg[i] <= (err_status[CH0][i] | err_status[CH1][i]);
      end
   end
end

// Function associated with the error
//----------------------
// If multiple errors are found on the same clock cycle, the function associated with the error will be reported
// based on the following order of priority
//    * Function associated with malformed TLP
//    * Function associated with completion timeout 
//    * Function associated with erroneous TLP on channel 0
//    * Function associated with erroneous TLP on channel 1
always_ff @(posedge avl_clk) begin
   rx_func_q    <= rx_func;
   mc_rx_func_q <= mc_rx_func;
end

always_ff @(posedge avl_clk) begin
   if (|err_sop_mc || |err_eop_mc) begin
      err_func_reg <= mc_rx_func_q;
   end else if (err_cpl_timeout) begin
      err_func_reg <= cpl_timeout_func;
   end else begin
      if (NUM_AVST_CH == 1) begin
         err_func_reg <= rx_func_q[CH0];
      end else begin
         err_func_reg <= (|err_status[CH0]) ? rx_func_q[CH0] : rx_func_q[CH1];
      end
   end
end

always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      chk_rx_err       <= 1'b0;
      chk_rx_err_code  <= '0;
      chk_rx_err_vf_act <= 1'b0;
      chk_rx_err_pfn    <= '0;
      chk_rx_err_vfn    <= '0;
      b2a_app_err_info  <= '0;
   end
   else begin
      //--------------------------
      // Error status sent to PCIe HIP IP
      //--------------------------
      b2a_app_err_info[0] <= (err_status_reg.err_malformed_sop | err_status_reg.err_malformed_eop); // Malformed TLP 
      b2a_app_err_info[2] <= err_status_reg.err_unexp_cpl;         // Unexpected Completion
      b2a_app_err_info[3] <= err_status_reg.err_cpl_status;        // Completion Abort
      b2a_app_err_info[4] <= err_status_reg.err_cpl_timeout;       // Completion Timeout
      
      // Unsupported Request
      b2a_app_err_info[5] <= err_status_reg.err_fmttype;
      
      // Poisoned TLP received
      b2a_app_err_info[6] <= err_status_reg.err_poison;              
      
      //--------------------------
      // Error status sent to FIM 
      //--------------------------
      chk_rx_err        <= |err_status_reg;        
      chk_rx_err_vf_act <= err_func_reg.vf_active;
      chk_rx_err_pfn    <= err_func_reg.pfn;  
      chk_rx_err_vfn    <= err_func_reg.vfn; 
      chk_rx_err_code   <= err_status_reg;
   end
end

assign b2a_app_err_hdr      = 32'h0;
assign b2a_app_err_valid    = |b2a_app_err_info;
assign b2a_app_err_func_num = chk_rx_err_pfn; 


// synthesis translate_off

initial
begin : rx_logger
   static int log_fd = $fopen("log_ofs_fim_pcie_checker.tsv", "w");
   int cycle = 0;
   forever @(posedge avl_clk) begin
      if (avl_rst_n) begin
         if (o_avl_rx_ready) begin
            log_avl_rx_st(log_fd, "i_avl_rx_st", cycle, i_avl_rx_st);
         end

         if (i_avl_rx_ready) begin
            log_avl_rx_st(log_fd, "o_avl_rx_st", cycle, o_avl_rx_st);
         end

         cycle = cycle + 1;
      end
   end
end

task log_avl_rx_st;
   input int log_fd;
   input string crx_name;
   input int cycle;
   input t_avst_rxs rx;
begin
   for (int i = 0; i < FIM_PCIE_TLP_CH; i = i + 1)
   begin
      if (rx[i].valid)
      begin
         $fwrite(log_fd, "%s:\t%t [%d] ch%0d %s\n",
                 crx_name, $time, cycle, i,
                 ofs_fim_pcie_pkg::func_rx_to_string(rx[i]));

         $fflush(log_fd);
      end
   end
end
endtask // log_avl_rx_st

// synthesis translate_on

endmodule
