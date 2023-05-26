// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Dummy CSR module for testing purpose, only support RW register mode 
`include "fpga_defines.vh"

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;

module pcie_dummy_csr #(
   parameter CSR_REGS = 10 // 64-bit register
)(
   input  logic               clk,
   input  logic               rst_n,
   ofs_fim_axi_mmio_if.slave  csr_if
);

localparam LCL_ADDR_WIDTH = (CSR_REGS < 2) ? 1 : $clog2(CSR_REGS);
localparam bit [LCL_ADDR_WIDTH-1:0] MAX_REG_IDX = CSR_REGS -1;

logic [MMIO_DATA_WIDTH-1:0] csr_reg[CSR_REGS-1:0];
logic [MMIO_DATA_WIDTH-1:0] csr_out;

logic [MMIO_TID_WIDTH-1:0]  awid_reg, wr_id;
logic [MMIO_ADDR_WIDTH-1:0] awaddr_reg, wr_addr;
logic [2:0] awsize_reg, wr_size;

assign csr_if.wready  = ~csr_if.bvalid || csr_if.bready;
assign csr_if.awready = ~csr_if.bvalid || csr_if.bready;
assign csr_if.arready = ~csr_if.rvalid || csr_if.rready;

// Write logic
always_ff @(posedge clk) begin
   if (~csr_if.bvalid || csr_if.bready) begin
      if (csr_if.awvalid) begin
         awaddr_reg <= csr_if.awaddr;
         awid_reg   <= csr_if.awid;
         awsize_reg <= csr_if.awsize;
      end
   end
end

assign wr_addr = csr_if.awvalid ? csr_if.awaddr : awaddr_reg;
assign wr_size = csr_if.awvalid ? csr_if.awsize : awsize_reg;
assign wr_id   = csr_if.awvalid ? csr_if.awid   : awid_reg;

always_ff @(posedge clk) begin
   if (~csr_if.bvalid || csr_if.bready) begin
      if (csr_if.wvalid) begin
         if (wr_addr[3+:LCL_ADDR_WIDTH] <= MAX_REG_IDX) begin
            csr_if.bid <= wr_id;
            csr_if.bvalid <= 1'b1;
            csr_if.bresp <= RESP_OKAY;
            if (wr_size == 3'b011) begin
               csr_reg[wr_addr[3+:LCL_ADDR_WIDTH]] <= csr_if.wdata; 
            end else if (wr_size == 3'b010) begin
               if (wr_addr[2])			
                  csr_reg[wr_addr[3+:LCL_ADDR_WIDTH]][63:32] <= csr_if.wdata[63:32];
               else 
		  csr_reg[wr_addr[3+:LCL_ADDR_WIDTH]][31:0] <= csr_if.wdata[31:0];
            end else begin
	       csr_if.bresp <= RESP_SLVERR;
	    end				
         end
      end else begin
         csr_if.bvalid <= 1'b0;
      end
   end
   
   if (~rst_n) begin
      csr_if.bvalid <= 1'b0;
`ifdef SIM_MODE
      csr_reg <= '{default:0};
`endif
   end 
end

// Read logic
always_ff @(posedge clk) begin
   if (~csr_if.rvalid || csr_if.rready) begin
      if (csr_if.arvalid) begin
         csr_if.rvalid <= 1'b1;
         csr_if.rlast <= 1'b1;
         csr_if.rresp <= RESP_OKAY;
         csr_if.rdata <= '0;
         csr_if.rid   <= csr_if.arid;
         if (csr_if.arsize == 3'b010 || csr_if.arsize == 3'b011) begin
            if (csr_if.araddr[3+:LCL_ADDR_WIDTH] <= MAX_REG_IDX) begin
               if (csr_if.arsize == 3'b010) begin
                  if (csr_if.araddr[2]) 
                     csr_if.rdata <= {csr_reg[csr_if.araddr[3+:LCL_ADDR_WIDTH]][63:32], 32'h0};
                  else
                     csr_if.rdata <= {'0, csr_reg[csr_if.araddr[3+:LCL_ADDR_WIDTH]][31:0]};
               end else begin
                  csr_if.rdata <= csr_reg[csr_if.araddr[3+:LCL_ADDR_WIDTH]];
               end
            end 
         end else begin
            csr_if.rresp <= RESP_SLVERR;            
         end
      end else begin
         csr_if.rvalid <= 1'b0;
         csr_if.rlast  <= 1'b0;
      end
   end

   if (~rst_n) begin
      csr_if.rvalid <= 1'b0;
      csr_if.rlast  <= 1'b0;
   end
end

endmodule
