// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  This package contains the parameter and struct definition for commonly used
//  PCIe TLP header
//
//----------------------------------------------------------------------------

`ifndef __OFS_FIM_PCIE_HDR_DEF_SV__
`define __OFS_FIM_PCIE_HDR_DEF_SV__

package ofs_fim_pcie_hdr_def;

// PCIe FMTTYPE 
localparam PCIE_TYPE_CPL = 5'b01010;
localparam PCIE_TYPE_MEM_RW = 5'b00000;
localparam PCIE_TYPE_MSG = 5'b10000;

localparam PCIE_FMTTYPE_MEM_READ32   = 7'b000_0000;
localparam PCIE_FMTTYPE_MEM_READ64   = 7'b010_0000;
localparam PCIE_FMTTYPE_MEM_WRITE32  = 7'b100_0000;
localparam PCIE_FMTTYPE_MEM_WRITE64  = 7'b110_0000;
localparam PCIE_FMTTYPE_CFG_WRITE    = 7'b100_0100;
localparam PCIE_FMTTYPE_CPL          = 7'b000_1010;
localparam PCIE_FMTTYPE_CPLD         = 7'b100_1010;
localparam PCIE_FMTTYPE_SWAP32       = 7'b100_1101;
localparam PCIE_FMTTYPE_SWAP64       = 7'b110_1101;
localparam PCIE_FMTTYPE_CAS32        = 7'b100_1110;
localparam PCIE_FMTTYPE_CAS64        = 7'b110_1110;

// 1st DW in TLP header
typedef struct packed {
   logic        rsvd0;
   logic [6:0]  fmttype;
   logic        rsvd1;
   logic [2:0]  tc;
   logic [2:0]  rsvd2;
   logic        th;
   logic        td;
   logic        ep;
   logic [1:0]  attr;
   logic [1:0]  rsvd3;
   logic [9:0]  length;
} t_tlp_hdr_dw0;

// PCIe memory request TLP header
typedef struct packed {
   t_tlp_hdr_dw0     dw0;
   logic [15:0]      requester_id;
   logic [7:0]       tag;
   logic [3:0]       last_be;
   logic [3:0]       first_be;
   logic [31:0]      addr;     // MWr64/MRd64:address[63:32]; MWr32/MRd32:address[31:0]
   // The interpretation of lsb_addr with 32-bit addresses varies by FIM vs. AFU
   // and by PCIe hardware. Some hardware (e.g. S10 H-Tile) treats the location as
   // the first DWORD. Other hardware (e.g. S10 P-Tile) ignores the location and
   // consumes data from the normal payload field. The FIM handles either case and
   // guarantees that the encoding of the AFU TLP stream is always consistent.
   // AFUs should simply clear lsb_addr for 32-bit requests and pass data in the
   // payload field.
   logic [31:0]      lsb_addr; // MWr64/MRd64:address[31:0];  MWr32:data[31:0]; MRd32:Rsvd
} t_tlp_mem_req_hdr;
localparam TLP_MEM_REQ_HDR_WIDTH = $bits(t_tlp_mem_req_hdr);

// PCIe completion TLP header
typedef struct packed {
   t_tlp_hdr_dw0     dw0;
   logic [15:0]      completer_id;
   logic [2:0]       status;
   logic             bcm;
   logic [11:0]      byte_count;
   logic [15:0]      requester_id;
   logic [7:0]       tag;
   logic             rsvd0;
   logic [6:0]       lower_addr;
   logic [31:0]      rsvd1;
} t_tlp_cpl_hdr;
localparam TLP_CPL_HDR_WIDTH = $bits(t_tlp_cpl_hdr);

// PCIe message TLP header
typedef struct packed {
   t_tlp_hdr_dw0     dw0;
   logic [15:0]      requester_id;
   logic [7:0]       tag;
   logic [7:0]       msg_code;
   logic [31:0]      lower_msg;
   logic [31:0]      upper_msg;
} t_tlp_msg_hdr;
localparam TLP_MSG_HDR_WIDTH = $bits(t_tlp_msg_hdr);

// PCIe message TLP header
typedef struct packed {
   t_tlp_hdr_dw0     dw0;
   logic [15:0]      requester_id;
   logic [7:0]       tag;
   logic [7:0]       msg_code;
   logic [15:0]      pci_target_id;
   logic [15:0]      vendor_id;
   logic [31:0]      upper_msg;
} t_tlp_vdm_msg_hdr;
localparam TLP_VDM_MSG_HDR_WIDTH = $bits(t_tlp_vdm_msg_hdr);

//--------------------------------
// Functions and tasks
//--------------------------------
function automatic bit func_is_addr32 (
   input logic [6:0] fmttype
);
   return (fmttype[5] == 1'b0);
endfunction

function automatic bit func_is_addr64 (
   input logic [6:0] fmttype
);
   return (fmttype[5] == 1'b1);
endfunction

function automatic bit func_has_data (
   input logic [6:0] fmttype
);
   return (fmttype[6] == 1'b1);
endfunction

function automatic bit func_is_completion (
   input logic [6:0] fmttype
);
   return (fmttype[4:0] == PCIE_TYPE_CPL ? 1'b1 : 1'b0);
endfunction

function automatic bit func_is_mem_req (
   input logic [6:0] fmttype
);
   return (fmttype[4:0] == PCIE_TYPE_MEM_RW ? 1'b1 : 1'b0);
endfunction

function automatic bit func_is_msg (
   input logic [6:0] fmttype
);
   return (fmttype[4:0] == PCIE_TYPE_MSG ? 1'b1 : 1'b0);
endfunction

function automatic bit func_is_mem_req64 (
   input logic [6:0] fmttype
);
   return (func_is_mem_req(fmttype) && func_is_addr64(fmttype));
endfunction

function automatic bit func_is_mem_req32 (
   input logic [6:0] fmttype
);
   return (func_is_mem_req(fmttype) && func_is_addr32(fmttype));
endfunction

function automatic bit func_is_mwr_req (
   input logic [6:0] fmttype
);
   return (func_is_mem_req(fmttype) && fmttype[6]) ? 1'b1 : 1'b0;
endfunction

function automatic bit func_is_mrd_req (
   input logic [6:0] fmttype
);
   return (func_is_mem_req(fmttype) && ~fmttype[6]) ? 1'b1 : 1'b0;
endfunction

function automatic bit func_is_msgD (
   input logic [6:0] fmttype
);
   return (func_is_msg(fmttype) && fmttype[6]) ? 1'b1 : 1'b0;
endfunction

// synthesis translate_off

function automatic string func_fmttype_to_string (
   input logic [6:0] fmttype
);
   string t;

   casex (fmttype)
      7'b000_0000 : t = "MRd";
      7'b010_0000 : t = "MRd";
      7'b000_0001 : t = "MRdLk";
      7'b010_0001 : t = "MRdLk";
      7'b100_0000 : t = "MWr";
      7'b110_0000 : t = "MWr";
      7'b000_0010 : t = "IORd";
      7'b100_0010 : t = "IOWr";
      7'b000_0100 : t = "CfgRd0";
      7'b100_0100 : t = "CfgWr0";
      7'b000_0101 : t = "CfgRd1";
      7'b100_0101 : t = "CfgWr1";
      7'b011_0XXX : t = "Msg";
      7'b111_0XXX : t = "MsgD";
      7'b000_1010 : t = "Cpl";
      7'b100_1010 : t = "CplD";
      7'b000_1011 : t = "CplLk";
      7'b100_1011 : t = "CplDLk";
      default     : t = "TDB";
   endcase

   if (func_is_mem_req32(fmttype)) t = { t, "32" };
   if (func_is_mem_req64(fmttype)) t = { t, "64" };

   return t;
endfunction

function automatic string func_dw0_to_string (
   input t_tlp_hdr_dw0 dw0
);
   return $sformatf("%6s len 0x%x [tc %0d th %0d td %0d ep %0d attr %0d]",
                    func_fmttype_to_string(dw0.fmttype),
                    dw0.length, dw0.tc, dw0.th, dw0.td, dw0.ep, dw0.attr);
endfunction

function automatic string func_mem_req_to_string (
   input t_tlp_mem_req_hdr hdr
);
   if (func_is_addr64(hdr.dw0.fmttype)) begin
      return $sformatf("%s req_id 0x%h tag 0x%h lbe 0x%h fbe 0x%h addr 0x%h%h",
                       func_dw0_to_string(hdr.dw0),
                       hdr.requester_id, hdr.tag, hdr.last_be, hdr.first_be,
                       hdr.addr, hdr.lsb_addr);
   end
   else if (func_has_data(hdr.dw0.fmttype)) begin
      return $sformatf("%s req_id 0x%h tag 0x%h lbe 0x%h fbe 0x%h addr 0x%h ht-data 0x%h",
                       func_dw0_to_string(hdr.dw0),
                       hdr.requester_id, hdr.tag, hdr.last_be, hdr.first_be,
                       hdr.addr, hdr.lsb_addr);
   end
   else begin
      return $sformatf("%s req_id 0x%h tag 0x%h lbe 0x%h fbe 0x%h addr 0x%h",
                       func_dw0_to_string(hdr.dw0),
                       hdr.requester_id, hdr.tag, hdr.last_be, hdr.first_be,
                       hdr.addr);
   end
endfunction

function automatic string func_cpl_to_string (
   input t_tlp_cpl_hdr hdr
);
   return $sformatf("%s cpl_id 0x%h st %h bcm %h bytes 0x%h req_id 0x%h tag 0x%h low_addr 0x%h",
                    func_dw0_to_string(hdr.dw0),
                    hdr.completer_id, hdr.status, hdr.bcm, hdr.byte_count,
                    hdr.requester_id, hdr.tag, hdr.lower_addr);
endfunction

function automatic string func_msg_to_string (
   input t_tlp_msg_hdr hdr
);
   return $sformatf("%s req_id 0x%h tag 0x%h code 0x%h lower 0x%h upper 0x%h",
                    func_dw0_to_string(hdr.dw0),
                    hdr.requester_id, hdr.tag, hdr.msg_code,
                    hdr.lower_msg, hdr.upper_msg);
endfunction

function automatic string func_hdr_to_string (
   input logic [127:0] hdr
);
   // Pick any header type to extract dw0 and the fmttype
   t_tlp_mem_req_hdr mem_req = hdr;
   t_tlp_hdr_dw0 dw0 = mem_req.dw0;

   string s;
   if (func_is_mem_req(dw0.fmttype)) begin
      s = func_mem_req_to_string(hdr);
   end
   else if (func_is_completion(dw0.fmttype)) begin
      s = func_cpl_to_string(hdr);
   end
   else begin
      s = func_msg_to_string(hdr);
   end

   return s;
endfunction

// Standard formatting of the contents of a channel
function automatic string func_flit_to_string (
   input logic sop,
   input logic eop,
   input t_tlp_mem_req_hdr hdr,
   input logic [255:0] payload
);
   string s;

   if (sop)
   begin
      // Format payload as a string if flit has data
      string payload_str = "";
      if (func_has_data(hdr.dw0.fmttype)) begin
         payload_str = $sformatf(" data 0x%x", payload);
      end

      s = $sformatf("%s%s%s%s",
                    (sop ? "sop " : ""),
                    (eop ? "eop " : ""),
                    func_hdr_to_string(hdr),
                    payload_str);
   end
   else
   begin
      s = $sformatf("    %s       data 0x%x",
                    (eop ? "eop " : ""),
                    payload);
   end

   return s;
endfunction

// synthesis translate_on

endpackage : ofs_fim_pcie_hdr_def

`endif // __OFS_FIM_PCIE_HDR_DEF_SV__
