// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   HSSI Wrapper AXI-lite CSR module
//   - Support upto 16 channels
//-----------------------------------------------------------------------------

module hssi_wrapper_csr (
   input                       clk,
   input                       rst_n,
   ofs_fim_axi_lite_if.slave   csr_lite_if,

   output  [15:0]           o_axis_tx_areset,
   output  [15:0]           o_axis_rx_areset,
   output  [15:0]           o_tx_rst,
   output  [15:0]           o_rx_rst,
   input   [15:0]           i_tx_rst_ack,
   input   [15:0]           i_rx_rst_ack,
   output                   o_cold_rst,
   input                    i_cold_rst_ack,
   input   [15:0]           i_tx_pll_locked,
   input   [15:0]           i_tx_lanes_stable,
   input   [15:0]           i_rx_pcs_ready,
   input   [15:0]           i_tx_ptp_ready,
   input   [15:0]           i_rx_ptp_ready
);

import ofs_fim_cfg_pkg::*;
import ofs_csr_pkg::*;

localparam DATA_WIDTH   = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;
localparam WSTRB_WIDTH  = (DATA_WIDTH/8);

//-------------------------------------
// Number of feature and register
//-------------------------------------

// To add a register, append a new register ID to e_csr_offset
// The register address offset is calculated in CALC_CSR_OFFSET() in 8 bytes increment
//    based on the position of the register ID in e_csr_offset. 
// The calculated offset is stored in CSR_OFFSET and can be indexed using the register ID 
enum {
   HSSI_INDIVIDUAL_RST,             // 'h000
   HSSI_INDIVIDUAL_ACK,             // 'h008
   HSSI_COLD_RST_ACK,               // 'h010
   HSSI_STATUS,                     // 'h018
   HSSI_SCRATCHPAD,                 // 'h020
   HSSI_PTP_STATUS,                 // 'h028
   HSSI_MAX_OFFSET
} e_csr_id;


localparam CSR_NUM_REG        = HSSI_MAX_OFFSET; 
localparam CSR_REG_ADDR_WIDTH = $clog2(CSR_NUM_REG) + 3;

localparam MAX_CSR_REG_NUM    = 256; // 2KB address space - 256 x 8B register
localparam CSR_ADDR_WIDTH     = $clog2(MAX_CSR_REG_NUM) + 3;
localparam ADDR_WIDTH         = 11;

//-------------------------------------
// Register address
//-------------------------------------
function automatic bit [CSR_NUM_REG-1:0][ADDR_WIDTH-1:0] CALC_CSR_OFFSET ();
   bit [31:0] offset;
   for (int i=0; i<CSR_NUM_REG; ++i) begin
      offset = i*8;
      CALC_CSR_OFFSET[i] = offset[ADDR_WIDTH-1:0];
   end
endfunction

localparam bit [CSR_NUM_REG-1:0][ADDR_WIDTH-1:0] CSR_OFFSET = CALC_CSR_OFFSET();

//-------------------------------------
// Signals
//-------------------------------------
logic [ADDR_WIDTH-1:0]  csr_waddr;
logic [DATA_WIDTH-1:0]  csr_wdata;
logic [WSTRB_WIDTH-1:0] csr_wstrb;
logic                   csr_write;
csr_access_type_t       csr_write_type;

logic [ADDR_WIDTH-1:0]  csr_raddr;
logic                   csr_read;
logic                   csr_read_32b;
logic [DATA_WIDTH-1:0]  csr_readdata;
logic                   csr_readdata_valid;

//--------------------------------------------------------------

// AXI-M CSR interfaces
ofs_fim_axi_mmio_if #(
   .AWID_WIDTH   (ofs_fim_cfg_pkg::MMIO_TID_WIDTH),
   .AWADDR_WIDTH (ADDR_WIDTH),
   .WDATA_WIDTH  (ofs_fim_cfg_pkg::MMIO_DATA_WIDTH),
   .ARID_WIDTH   (ofs_fim_cfg_pkg::MMIO_TID_WIDTH),
   .ARADDR_WIDTH (ADDR_WIDTH),
   .RDATA_WIDTH  (ofs_fim_cfg_pkg::MMIO_DATA_WIDTH)
) csr_if();

// AXI4-lite to AXI-M adapter
axi_lite2mmio axi_lite2mmio (
   .clk       (clk),
   .rst_n     (rst_n),
   .lite_if   (csr_lite_if),
   .mmio_if   (csr_if)
);

//---------------------------------
// Map AXI write/read request to CSR write/read,
// and send the write/read response back
//---------------------------------
ofs_fim_axi_csr_slave #(
   .ADDR_WIDTH (ADDR_WIDTH)
   ) csr_slave (
   .csr_if             (csr_if),

   .csr_write          (csr_write),
   .csr_waddr          (csr_waddr),
   .csr_write_type     (csr_write_type),
   .csr_wdata          (csr_wdata),
   .csr_wstrb          (csr_wstrb),

   .csr_read           (csr_read),
   .csr_raddr          (csr_raddr),
   .csr_read_32b       (csr_read_32b),
   .csr_readdata       (csr_readdata),
   .csr_readdata_valid (csr_readdata_valid)
);

//---------------------------------
// CSR Registers
//---------------------------------
ofs_csr_hw_state_t     hw_state;
logic                  range_valid;
logic                  csr_read_reg;
logic [ADDR_WIDTH-1:0] csr_raddr_reg;
logic                  csr_read_32b_reg;

logic [DATA_WIDTH-1:0] csr_reg [CSR_NUM_REG-1:0];

//-------------------
// CSR read interface
//-------------------
// Register read control signals to spare 1 clock cycle 
// for address range checking
always_ff @(posedge clk) begin
   csr_read_reg  <= csr_read;
   csr_raddr_reg <= csr_raddr;
   csr_read_32b_reg <= csr_read_32b;

   if (~rst_n) begin
      csr_read_reg <= 1'b0;
   end
end

// CSR address range check 
always_ff @(posedge clk) begin
   range_valid <= (csr_raddr[CSR_ADDR_WIDTH-1:3] < CSR_NUM_REG) ? 1'b1 : 1'b0; 
end

// CSR readdata
always_ff @(posedge clk) begin
   csr_readdata <= '0;

   if (csr_read_reg && range_valid) begin
      if (csr_read_32b_reg) begin
         if (csr_raddr_reg[2]) begin
            csr_readdata[63:32] <= csr_reg[csr_raddr_reg[CSR_REG_ADDR_WIDTH-1:3]][63:32];
         end else begin
            csr_readdata[31:0] <= csr_reg[csr_raddr_reg[CSR_REG_ADDR_WIDTH-1:3]][31:0];
         end
      end else begin
         csr_readdata <= csr_reg[csr_raddr_reg[CSR_REG_ADDR_WIDTH-1:3]];
      end
   end
end

// CSR readatavalid
always_ff @(posedge clk) begin
   csr_readdata_valid <= csr_read_reg;
end

//-------------------
// CSR Definition 
//-------------------
assign hw_state.reset_n    = rst_n;
assign hw_state.pwr_good_n = rst_n;
assign hw_state.wr_data    = csr_wdata;
assign hw_state.write_type = csr_write_type; 

always_ff @(posedge clk) begin

   def_reg (CSR_OFFSET[HSSI_INDIVIDUAL_RST],
               {64{RW}},
               64'h0,
               {o_rx_rst,
                o_tx_rst,
                o_axis_rx_areset,
                o_axis_tx_areset
               }
               );
   def_reg (CSR_OFFSET[HSSI_INDIVIDUAL_ACK],
               {64{RO}},
               64'h0,
               {32'h0,
                i_rx_rst_ack,
                i_tx_rst_ack
               }
               );
   def_reg (CSR_OFFSET[HSSI_COLD_RST_ACK],
               {{62{RsvdZ}},
                {1{RO}},
                {1{RW}}
               },
               64'h0,
               {62'h0,
                i_cold_rst_ack,
                o_cold_rst
               }
               );
   def_reg (CSR_OFFSET[HSSI_STATUS],
               {64{RO}},
               64'h0,
               {16'h0,
                i_rx_pcs_ready,
                i_tx_lanes_stable,
                i_tx_pll_locked
               }
               );
   def_reg (CSR_OFFSET[HSSI_PTP_STATUS],
               {64{RO}},
               64'h0,
               {32'h0,
                i_rx_ptp_ready,
                i_tx_ptp_ready
               }
               );
   def_reg (CSR_OFFSET[HSSI_SCRATCHPAD],
               {64{RW}},
               64'h0,
               64'h0
               );

end

//-----------------------
 // CSR outputs
//-----------------------
assign o_cold_rst              = csr_reg[HSSI_COLD_RST_ACK][0];
assign o_rx_rst                = csr_reg[HSSI_INDIVIDUAL_RST][63:48];
assign o_tx_rst                = csr_reg[HSSI_INDIVIDUAL_RST][47:32];
assign o_axis_rx_areset        = csr_reg[HSSI_INDIVIDUAL_RST][31:16];
assign o_axis_tx_areset        = csr_reg[HSSI_INDIVIDUAL_RST][15:0];

//--------------------------------
// Function & Task
//--------------------------------
// Check if address matches
function automatic bit f_addr_hit (
   input logic [ADDR_WIDTH-1:0] csr_addr, 
   input logic [ADDR_WIDTH-1:0] ref_addr
);
   return (csr_addr[CSR_ADDR_WIDTH-1:3] == ref_addr[CSR_ADDR_WIDTH-1:3]);
endfunction

// Task to update CSR register bit based on bit attribute
task def_reg;
   input logic [ADDR_WIDTH-1:0] addr;
   input csr_bit_attr_t [63:0]  attr;
   input logic [63:0]           reset_val;
   input logic [63:0]           update_val;
begin
   csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]] <= ofs_csr_pkg::update_reg (
      attr,
      reset_val,
      update_val,
      csr_reg[addr[CSR_REG_ADDR_WIDTH-1:3]],
      (csr_write && f_addr_hit(csr_waddr, addr)),
      hw_state
   );
end
endtask

endmodule
