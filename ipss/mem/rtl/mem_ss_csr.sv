// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Memory Subsystem AC FIM CSR module 
//
//-----------------------------------------------------------------------------


module mem_ss_csr 
   import mem_ss_pkg::*;
   import ofs_fim_cfg_pkg::*;
   import ofs_csr_pkg::*;
#(
   parameter bit [11:0] FEAT_ID = 12'h0,
   parameter bit [3:0]  FEAT_VER = 4'h1,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit END_OF_LIST = 1'b0
)(
   input                       clk,
   input                       rst_n,
   ofs_fim_axi_lite_if.slave   csr_lite_if,
 
   input   [mem_ss_pkg::DDR_CHANNEL-1:0]    cal_success,
   input   [mem_ss_pkg::DDR_CHANNEL-1:0]    cal_fail
);

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
   EMIF_DFH,            // 'h0
   EMIF_STATUS,         // 'h8
   EMIF_CAPABILITY,     // 'h10
   EMIF_MAX_OFFSET
} e_csr_id;

localparam CSR_NUM_REG        = EMIF_MAX_OFFSET; 
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
   .ADDR_WIDTH (ADDR_WIDTH),
   .DATA_WIDTH (DATA_WIDTH)
)
csr_slave (
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
   def_reg (CSR_OFFSET[EMIF_DFH],
               {64{RO}},
                /* 
                   [63:60]: Feature Type
                   [59:52]: Reserved
                   [51:48]: If AFU - AFU Minor Revision Number (else, reserved)
                   [47:41]: Reserved
                   [40   ]: EOL (End of DFH list)
                   [39:16]: Next DFH Byte Offset
                   [15:12]: If AfU, AFU Major version number (else feature #)
                   [11:0 ]: Feature ID
                */
               {4'h3, 8'h0, 4'h0, 7'h0, END_OF_LIST, NEXT_DFH_OFFSET, FEAT_VER, FEAT_ID},
               {4'h3, 8'h0, 4'h0, 7'h0, END_OF_LIST, NEXT_DFH_OFFSET, FEAT_VER, FEAT_ID}
   );

   def_reg (CSR_OFFSET[EMIF_STATUS],
               {64{RO}},
               64'h0,
               {{64-2*MC_CHANNEL{1'b0}},
                cal_fail,
                cal_success
                }
   );
    
   def_reg (CSR_OFFSET[EMIF_CAPABILITY],
               {64{RO}},
               64'h0,
               {'0,
                {MC_CHANNEL{1'b1}}
               }
   );
end

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
