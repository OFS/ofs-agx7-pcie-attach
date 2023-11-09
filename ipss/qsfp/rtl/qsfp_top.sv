// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Engineer     : 
// Create Date  : Sept 2020
// Module Name  : qsfp_top.sv
// Project      : IOFS
// -----------------------------------------------------------------------------
//
// Description: 
// qsfp_controller top module instantiates all sub modules
// implementes AVMM address decoding logic


module qsfp_top  #(
   parameter ADDR_WIDTH  = 12, 
   parameter DATA_WIDTH = 64, 
   parameter bit [11:0] FEAT_ID = 12'h001,
   parameter bit [3:0]  FEAT_VER = 4'h1,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit END_OF_LIST = 1'b0
)(
   input  logic    clk,
   input  logic    reset,
   input  wire     modprsl,
   input  wire     int_qsfp,
   input  wire     i2c_0_i2c_serial_sda_in,
   input  wire     i2c_0_i2c_serial_scl_in,
   output wire     i2c_0_i2c_serial_sda_oe,
   output wire     i2c_0_i2c_serial_scl_oe,
   output wire     modesel,
   output wire     lpmode,
   output wire     softresetqsfpm,
// -----------------------------------------------------------
//  AXI4LITE Interface
// -----------------------------------------------------------
   ofs_fim_axi_lite_if.slave   csr_lite_if
);

import ofs_fim_cfg_pkg::*;
import ofs_csr_pkg::*;

//-------------------------------------
// Signals
//-------------------------------------
   logic [ADDR_WIDTH-1:0]              csr_waddr;
   logic [DATA_WIDTH-1:0]              csr_wdata;
   logic [DATA_WIDTH/8-1:0]            csr_wstrb;
   logic                               csr_write;
   logic                               csr_slv_wready;
   csr_access_type_t                   csr_write_type;

   logic [ADDR_WIDTH-1:0]              csr_raddr;
   logic                               csr_read;
   logic                               csr_read_32b;
   logic [DATA_WIDTH-1:0]              csr_readdata;
   logic                               csr_readdata_valid;

   logic [ADDR_WIDTH-1:0]              csr_addr;
   logic [31:0]                        delay_csr_in;
   logic                               src_valid;
   logic [7:0]                         src_data;
   logic                               src_ready;
   logic                               wren_logic;
   logic                               rd_done;
   logic [7:0]                         curr_rd_addr;
   logic [7:0]                         curr_rd_page;
   logic                               rd_done_ack;
   logic                               mem_wren ;
   logic [63:0]                        mem_wdata;
   logic [7:0]                         mem_waddr ;
   logic                               mem_chipsel;
   logic [15:0]                        sink_data ;
   logic                               sink_valid;
   logic                               sink_ready;

   logic                               config_softresetqsfpm;
   logic                               config_softresetqsfpc;
   logic                               config_modesel;
   logic                               config_lpmode;
   logic                               config_poll_en;
   logic                               status_int_i2c_i;
   logic                               tx_err;
   logic                               rx_err;
   logic [63:0]                        com_csr_writedata;
   logic                               com_csr_read;
   logic                               com_csr_write;
   logic [63:0]                        com_csr_readdata;
   logic                               com_csr_readdatavalid;
   logic [5:0]                         com_csr_address;

   logic [63:0]                        com_csr_writedata_nxt;
   logic                               com_csr_read_nxt;
   logic                               com_csr_write_nxt;
   logic                               com_csr_readdatavalid_nxt;
   logic [5:0]                         com_csr_address_nxt;
   logic                               fsm_paused;
   logic                               reset_hard_soft;
   
   logic [3:0]                         i2c_0_csr_address;
   logic                               i2c_0_csr_read;
   logic                               i2c_0_csr_write;
   logic                               com_csr_unused;
   logic [31:0]                        i2c_0_csr_writedata;
   logic [31:0]                        i2c_0_csr_readdata;
   logic                               i2c_0_csr_readdata_valid;
   logic                               i2c_0_csr_read_q;
   logic [63:0]                        i2c_0_csr_writedata_64;
   logic [63:0]                        i2c_0_csr_readdata_64;

   logic [7:0]                         onchip_memory2_0_s1_address;       
   logic                               onchip_memory2_0_s1_clken;         
   logic                               onchip_memory2_0_s1_chipselect;    
   logic                               onchip_memory2_0_s1_write;         
   logic [63:0]                        onchip_memory2_0_s1_readdata;      
   logic                               onchip_memory2_0_s1_readdata_valid;


   assign reset_hard_soft = reset || config_softresetqsfpc;
   assign poll_en         = config_poll_en;

   assign modesel        = config_modesel;
   assign lpmode         = config_lpmode;
   assign softresetqsfpm = config_softresetqsfpm;

   assign tx_err         = ~sink_ready && sink_valid;     
   assign rx_err         = ~src_ready & src_valid & sink_data[0] & sink_data[9] ;     





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
   .rst_n     (~reset),
   .lite_if   (csr_lite_if),
   .mmio_if   (csr_if)
);

//---------------------------------
// Map AXI write/read request to CSR write/read,
// and send the write/read response back
//---------------------------------
ofs_fim_axi_csr_slave #(
   .ADDR_WIDTH (ADDR_WIDTH),
   .USE_SLV_READY (1'b1)
   
   ) csr_slave (
   .csr_if             (csr_if),

   .csr_write          (csr_write),
   .csr_waddr          (csr_waddr),
   .csr_write_type     (csr_write_type),
   .csr_wdata          (csr_wdata),
   .csr_wstrb          (csr_wstrb),
   .csr_slv_wready     (csr_slv_wready),
   .csr_read           (csr_read),
   .csr_raddr          (csr_raddr),
   .csr_read_32b       (csr_read_32b),
   .csr_readdata       (csr_readdata),
   .csr_readdata_valid (csr_readdata_valid)
);

// Address mapping
assign csr_addr                     = csr_write ? csr_waddr : csr_raddr;
assign com_csr_address              = csr_addr[5:0];  // byte address
assign i2c_0_csr_address            = csr_addr[5:2];  // 32-bit address
assign onchip_memory2_0_s1_address  = csr_addr[10:3] - 8'h20; //64-bit address

assign csr_slv_wready = (csr_waddr == 12'h040) ? sink_ready : 1'b1; 
// Write data mapping
assign i2c_0_csr_writedata_64  = csr_wdata;
assign com_csr_writedata       = csr_wdata;


// I2C controller 64<->32 mapping
always_comb
begin
   if(i2c_0_csr_address[0]) begin // Upper/Odd
      i2c_0_csr_writedata   = i2c_0_csr_writedata_64[63:32];
      i2c_0_csr_readdata_64 = {i2c_0_csr_readdata,32'h0};
   end
   else begin // Lower/Even
      i2c_0_csr_writedata   = i2c_0_csr_writedata_64[31:0];
      i2c_0_csr_readdata_64 = {32'h0,i2c_0_csr_readdata};
   end
end   


// Read-Write mapping
always_comb
begin
   com_csr_read                     = 1'b0;
   com_csr_write                    = 1'b0;
   onchip_memory2_0_s1_chipselect   = 1'b0;
   onchip_memory2_0_s1_write        = 1'b0;
   i2c_0_csr_read                   = 1'b0;
   i2c_0_csr_write                  = 1'b0;
   com_csr_read                     = 1'b0;
   casez (csr_addr[11:6])
      6'h00 : begin // Common CSR
         com_csr_read                     = csr_read;
         com_csr_write                    = csr_write;
         onchip_memory2_0_s1_chipselect   = 1'b0;
         onchip_memory2_0_s1_write        = 1'b0;
         i2c_0_csr_read                   = 1'b0;
         i2c_0_csr_write                  = 1'b0;
         com_csr_unused                   = 1'b0;
      end   
      6'h01 : begin   // I2C controller CSR
         com_csr_read                     = 1'b0;
         com_csr_write                    = 1'b0;
         onchip_memory2_0_s1_chipselect   = 1'b0;
         onchip_memory2_0_s1_write        = 1'b0;
         i2c_0_csr_read                   = csr_read;
         i2c_0_csr_write                  = csr_write;
         com_csr_unused                   = 1'b0;
      end
      6'b0001??,
      6'b001???: begin // Shadow register memory
         com_csr_read                     = 1'b0;
         com_csr_write                    = 1'b0;
         onchip_memory2_0_s1_chipselect   = csr_read;
         onchip_memory2_0_s1_write        = ~csr_read;
         i2c_0_csr_read                   = 1'b0;
         i2c_0_csr_write                  = 1'b0;
         com_csr_unused                   = 1'b0;
      end
      default: begin
         com_csr_read                     = 1'b0;
         com_csr_write                    = 1'b0;
         onchip_memory2_0_s1_chipselect   = 1'b0;
         onchip_memory2_0_s1_write        = 1'b0;
         i2c_0_csr_read                   = 1'b0;
         i2c_0_csr_write                  = 1'b0;
         com_csr_unused                   = 1'b1;
      end
   endcase
end

//Read Valid generation
always_ff @(posedge clk) begin
   // 2 clk latency for I2C controller read
   i2c_0_csr_read_q                   <= i2c_0_csr_read;
   i2c_0_csr_readdata_valid           <= i2c_0_csr_read_q;
   // 1 clk latency for on-chip mem
   onchip_memory2_0_s1_readdata_valid <= onchip_memory2_0_s1_chipselect 
                                         & (~onchip_memory2_0_s1_write);
end

// Read data mapping
always_comb begin
   if (com_csr_readdatavalid) begin
      csr_readdata       = com_csr_readdata;
      csr_readdata_valid = 1'b1;
   end
   else if (i2c_0_csr_readdata_valid) begin
      csr_readdata       = i2c_0_csr_readdata_64;
      csr_readdata_valid = 1'b1;
   end
   else if (onchip_memory2_0_s1_readdata_valid) begin
      csr_readdata       = onchip_memory2_0_s1_readdata;
      csr_readdata_valid = 1'b1;
   end
   else if (com_csr_unused) begin
      csr_readdata       = '0;
      csr_readdata_valid = 1'b1;
   end
   else begin
      csr_readdata       = '0;
      csr_readdata_valid = 1'b0;
   end
end


poller_fsm poller_fsm_inst(
   .clk           (clk         ),  
   .reset         (reset_hard_soft),  
   .poll_en       (poll_en     ),  
   .sink_data     (sink_data   ),  
   .sink_valid    (sink_valid  ),  
   .sink_ready    (sink_ready  ),  
   .wren_logic    (wren_logic  ),  
   .curr_rd_addr  (curr_rd_addr),  
   .curr_rd_page  (curr_rd_page),  
   .rd_done       (rd_done     ),  
   .rd_done_ack   (rd_done_ack ),  
   .wr_cnt_rst    (wr_cnt_rst  ),
   .csr_wdata     (i2c_0_csr_writedata),
   .csr_write     (csr_write),
   .csr_addr      (csr_addr),
   .delay_csr_in  (delay_csr_in),
   .fsm_paused    (fsm_paused)
);


csr_wr_logic csr_wr_logic_inst (
   .clk           (clk         ),
   .reset         (reset_hard_soft),
   .src_valid     (src_valid   ),
   .src_data      (src_data    ),
   .src_ready     (src_ready   ),
   .wren_logic    (wren_logic  ),
   .curr_rd_addr  (curr_rd_addr),  
   .rd_done       (rd_done     ),
   .poll_en       (poll_en     ),
   .rd_done_ack   (rd_done_ack ),
   .mem_wren      (mem_wren    ),
   .mem_chipsel   (mem_chipsel ),
   .mem_wdata     (mem_wdata   ),
   .mem_waddr     (mem_waddr    ),
   .wr_cnt_rst    (wr_cnt_rst   )
   );

qsfp_ctrl qsfp_ctrl_inst (
   .clk_clk                           (clk),
   .i2c_0_interrupt_sender_irq        (status_int_i2c_i),    // To be connected from output of decoder
   .i2c_0_csr_address                 (i2c_0_csr_address   ),
   .i2c_0_csr_read                    (i2c_0_csr_read      ),
   .i2c_0_csr_write                   (i2c_0_csr_write     ),
   .i2c_0_csr_writedata               (i2c_0_csr_writedata ),
   .i2c_0_csr_readdata                (i2c_0_csr_readdata  ), //Latency 2 clk
   .i2c_0_i2c_serial_sda_in           (i2c_0_i2c_serial_sda_in),
   .i2c_0_i2c_serial_scl_in           (i2c_0_i2c_serial_scl_in),
   .i2c_0_i2c_serial_sda_oe           (i2c_0_i2c_serial_sda_oe),
   .i2c_0_i2c_serial_scl_oe           (i2c_0_i2c_serial_scl_oe),
   .i2c_0_rx_data_source_data         (src_data),
   .i2c_0_rx_data_source_valid        (src_valid),
   .i2c_0_rx_data_source_ready        (src_ready),
   .i2c_0_transfer_command_sink_data  (sink_data),
   .i2c_0_transfer_command_sink_valid (sink_valid),
   .i2c_0_transfer_command_sink_ready (sink_ready),
   .onchip_memory2_0_s1_address       (onchip_memory2_0_s1_address),
   .onchip_memory2_0_s1_clken         (1'b1),
   .onchip_memory2_0_s1_chipselect    (onchip_memory2_0_s1_chipselect),
   .onchip_memory2_0_s1_write         (onchip_memory2_0_s1_write),
   .onchip_memory2_0_s1_readdata      (onchip_memory2_0_s1_readdata), //Latency 1 clk
   .onchip_memory2_0_s1_writedata     (64'b0),
   .onchip_memory2_0_s1_byteenable    (8'hff),    // 
   .onchip_memory2_0_s2_address       (mem_waddr),
   .onchip_memory2_0_s2_chipselect    (mem_chipsel),
   .onchip_memory2_0_s2_clken         (1'b1),
   .onchip_memory2_0_s2_write         (mem_wren),
   .onchip_memory2_0_s2_readdata      (),
   .onchip_memory2_0_s2_writedata     (mem_wdata),
   .onchip_memory2_0_s2_byteenable    (8'hff),    // 
   .reset_reset                       (reset_hard_soft)
   );

qsfp_com  #(
   .FEAT_ID          (FEAT_ID),
   .FEAT_VER         (FEAT_VER),
   .NEXT_DFH_OFFSET  (NEXT_DFH_OFFSET),
   .END_OF_LIST      (END_OF_LIST)
) qsfp_com_inst (
   .config_softresetqsfpm (config_softresetqsfpm   ),
   .config_softresetqsfpc (config_softresetqsfpc   ),
   .config_modesel        (config_modesel          ),
   .config_lpmode         (config_lpmode           ),
   .config_poll_en        (config_poll_en          ),
   .status_modprsl_i      (modprsl                 ),
   .status_int_qsfp_i     (int_qsfp                ),
   .status_int_i2c_i      (status_int_i2c_i        ),
   .status_tx_err_i       (tx_err                  ),
   .status_rx_err_i       (rx_err                  ),
   .status_snk_ready_i    (sink_ready              ),
   .status_src_ready_i    (src_ready               ),
   .status_fsm_paused_i   (fsm_paused              ),
   .status_curr_rd_page_i (curr_rd_page            ),
   .status_curr_rd_addr_i (curr_rd_addr            ),
   .clk                   (clk                     ),
   .reset                 (reset                   ),
   .writedata             (com_csr_writedata       ),
   .delay_csr_in          (delay_csr_in            ),
   .read                  (com_csr_read            ),
   .write                 (com_csr_write           ),
   .byteenable            (4'hF                    ),
   .readdata              (com_csr_readdata        ),
   .readdatavalid         (com_csr_readdatavalid   ),
   .address               (com_csr_address         )
   );

endmodule
