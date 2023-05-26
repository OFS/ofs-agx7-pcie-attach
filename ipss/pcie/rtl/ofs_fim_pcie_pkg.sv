// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Package contains parameter and struct definition used in PCIe subsystem
//
//-----------------------------------------------------------------------------

`ifndef __OFS_FIM_PCIE_PKG_SV__
`define __OFS_FIM_PCIE_PKG_SV__

`include "fpga_defines.vh"

package ofs_fim_pcie_pkg;
   import ofs_fim_pcie_hdr_def::*;

// PCIe AVST channel parameters
localparam NUM_AVST_CH = 2;

localparam NUM_PF     = top_cfg_pkg::FIM_NUM_PF;
localparam NUM_VF     = top_cfg_pkg::FIM_NUM_VF;
localparam MAX_NUM_VF = top_cfg_pkg::FIM_MAX_NUM_VF;

localparam PF_WIDTH = (NUM_PF < 2) ? 1 : $clog2(NUM_PF);
localparam VF_WIDTH = (NUM_VF < 2) ? 1 : $clog2(NUM_VF);

localparam PCIE_EP_MAX_TAGS   = 256;//96;
localparam PCIE_EP_TAG_WIDTH  = $clog2(PCIE_EP_MAX_TAGS);

localparam PCIE_HDR_WIDTH       = 128;
localparam PCIE_MAX_LEN         = 1024; // DW
localparam PCIE_MAX_LEN_WIDTH   = $clog2(PCIE_MAX_LEN)+1;

localparam AVST_HW              = PCIE_HDR_WIDTH;
localparam AVST_DW              = 256; // AVST data width
localparam AVST_EW              = $clog2(AVST_DW/32);
localparam AVST_DWORD_LEN       = (AVST_DW/32); // DWords in AVST data
localparam AVST_DWORD_LEN_WIDTH = $clog2(AVST_DWORD_LEN);

localparam HDR_3DW_LEN = 3;
localparam HDR_4DW_LEN = 4;
localparam NON_SOP_DWORD_LEN = AVST_DWORD_LEN; 
localparam SOP_3DW_DWORD_LEN = (AVST_DWORD_LEN - HDR_3DW_LEN);
localparam SOP_4DW_DWORD_LEN = (AVST_DWORD_LEN - HDR_4DW_LEN);

localparam PCIE_CPL_CREDIT  = 2500; // 16B (4DW) unit
localparam CPL_CREDIT_DWORD = PCIE_CPL_CREDIT*4; // PCIE_CPL_CREDIT is in 4DW unit, change it to DW unit
localparam CPL_CREDIT_WIDTH = $clog2(CPL_CREDIT_DWORD);
`ifdef SIM_PCIE_CPL_TIMEOUT
   `ifdef SIM_PCIE_CPL_TIMEOUT_CYCLES
      localparam PCIE_CPL_TIMEOUT = `SIM_PCIE_CPL_TIMEOUT_CYCLES;
   `else
      localparam PCIE_CPL_TIMEOUT = 26'd256;
   `endif
`else
   localparam PCIE_CPL_TIMEOUT = 26'd12500000;
`endif
localparam CPL_TIME_WIDTH   = 26;

typedef enum logic {HDR_3DW, HDR_4DW} t_hdr_len;

typedef logic [PCIE_EP_TAG_WIDTH-1:0] t_tlp_tag;

typedef logic [NUM_AVST_CH-1:0] t_avst_ch;

typedef struct packed {
   logic [VF_WIDTH-1:0] vfn;
   logic [PF_WIDTH-1:0] pfn;
   logic                vf_active;
} t_tlp_func;

typedef struct packed {
   logic err_malformed_eop;
   logic err_malformed_sop;
   logic err_poison;
   logic err_parity;
   logic err_cpl_timeout;
   logic err_cpl_status;
   logic err_unexp_cpl;
   logic err_fmttype;
} t_tlp_err;
localparam TLP_ERR_WIDTH = $bits(t_tlp_err);

typedef struct packed {
   logic     rx_fifo_overflow;
   t_tlp_err tlp_err;
} t_pcie_err;
localparam PCIE_ERR_WIDTH = $bits(t_pcie_err);

// UMSG code to be ignored by PCIe checker
typedef enum logic [7:0] {
   UMSG_CODE_PM_PME = 8'h19,
   UMSG_CODE_SET_SLOT_PWR_LIMIT = 8'h50,
   UMSG_CODE_VENDOR_TYPE_1 = 8'h7f
} umsg_code_t;

// PCIe IP AVST RX interface signals
`ifdef HTILE 
   typedef struct packed {
      logic                 valid;
      logic                 sop;
      logic                 eop;
      logic [AVST_EW-1:0]   empty;
      logic [AVST_DW-1:0]   data;
      logic [2:0]           bar;
      logic                 vf_active;
      logic [PF_WIDTH-1:0]  pfn;
      logic [VF_WIDTH-1:0]  vfn;
      logic                 mmio_req;
   } t_avst_pcie_rx;
`elsif PTILE
   typedef struct packed {
      logic                 valid;
      logic                 sop;
      logic                 eop;
      logic [AVST_HW-1:0]   hdr;
      logic [AVST_EW-1:0]   empty;
      logic [AVST_DW-1:0]   data;
      logic [2:0]           bar;
      logic                 vf_active;
      logic [PF_WIDTH-1:0]  pfn;
      logic [VF_WIDTH-1:0]  vfn;
      logic                 mmio_req;
   } t_avst_pcie_rx;
`endif
localparam PCIE_RX_AVST_IF_WIDTH = $bits(t_avst_pcie_rx);

typedef t_avst_pcie_rx [NUM_AVST_CH-1:0] t_avst_rxs;

// PCIe IP AVST TX interface signals
`ifdef HTILE 
   typedef struct packed {
      logic               valid;
      logic               sop;
      logic               eop;
      logic [AVST_DW-1:0] data;
      logic               vf_active;
   } t_avst_pcie_tx;
`elsif PTILE
   typedef struct packed {
      logic               valid;
      logic               sop;
      logic               eop;
      logic [AVST_HW-1:0] hdr;
      logic [AVST_DW-1:0] data;
      logic               vf_active;
   } t_avst_pcie_tx;
`endif
localparam PCIE_TX_AVST_IF_WIDTH = $bits(t_avst_pcie_tx);

typedef t_avst_pcie_tx [NUM_AVST_CH-1:0] t_avst_txs;

//--------------------------------
// Functions and tasks
//--------------------------------
// Increment a tag, which may have a space that isn't a power of 2.
function automatic t_tlp_tag incr_tlp_tag(t_tlp_tag tag);
   t_tlp_tag tag_next;
   tag_next = tag + 1'b1;

   // If the tag space isn't a power of 2 and the current tag is
   // the maximum value, wrap to 0.
   if (  (PCIE_EP_MAX_TAGS != 2 ** PCIE_EP_TAG_WIDTH) &&
         (tag == t_tlp_tag'(PCIE_EP_MAX_TAGS - 1)))
   begin
      tag_next = t_tlp_tag'(0);
   end
   
   return tag_next;
endfunction

function automatic logic [127:0] func_get_hdr (
   input t_avst_pcie_rx rx
);
   `ifdef HTILE
      for (int i=0; i<=3; i=i+1) begin
         func_get_hdr[i*32+:32] = rx.data[(3-i)*32+:32];
      end
   `else
      func_get_hdr = rx.hdr;
   `endif
endfunction

function automatic logic [127:0] func_get_tx_hdr (
   input t_avst_pcie_tx tx
);
   `ifdef HTILE
      for (int i=0; i<=3; i=i+1) begin
         func_get_tx_hdr[i*32+:32] = tx.data[(3-i)*32+:32];
      end
   `else
      func_get_tx_hdr = tx.hdr;
   `endif
endfunction

function automatic logic [31:0] func_get_hdr_dw0 (
   input t_avst_pcie_rx rx
);
   `ifdef HTILE
      func_get_hdr_dw0 = rx.data[31:0];
   `else
      func_get_hdr_dw0 = rx.hdr[127:96];
   `endif
endfunction


// synthesis translate_off

// Standard formatting of the contents of an RX channel
function automatic string func_rx_to_string (
   input t_avst_pcie_rx rx
);
   string s;

   if (rx.sop)
   begin
      logic [127:0] hdr;
      hdr = func_get_hdr(rx);

      s = $sformatf("%s%s%s raw data 0x%x",
                    (rx.sop ? "sop " : ""),
                    (rx.eop ? "eop " : ""),
                    ofs_fim_pcie_hdr_def::func_hdr_to_string(hdr),
                    rx.data);
   end
   else
   begin
      s = $sformatf("    %s       data 0x%x",
                    (rx.eop ? "eop " : ""),
                    rx.data);
   end

   return s;
endfunction

// Standard formatting of the contents of a TX channel
function automatic string func_tx_to_string (
   input t_avst_pcie_tx tx
);
   string s;

   if (tx.sop)
   begin
      logic [127:0] hdr;
      hdr = func_get_tx_hdr(tx);

      s = $sformatf("%s%s%s raw data 0x%x",
                    (tx.sop ? "sop " : ""),
                    (tx.eop ? "eop " : ""),
                    ofs_fim_pcie_hdr_def::func_hdr_to_string(hdr),
                    tx.data);
   end
   else
   begin
      s = $sformatf("    %s       data 0x%x",
                    (tx.eop ? "eop " : ""),
                    tx.data);
   end

   return s;
endfunction

// synthesis translate_on

endpackage : ofs_fim_pcie_pkg

`endif // __OFS_FIM_PCIE_PKG_SV__
