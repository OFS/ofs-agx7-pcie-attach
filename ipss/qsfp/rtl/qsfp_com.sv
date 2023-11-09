// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

module qsfp_com #(
   parameter bit [11:0] FEAT_ID = 12'h001,
   parameter bit [3:0]  FEAT_VER = 4'h1,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit END_OF_LIST = 1'b0
)(
output  reg config_softresetqsfpm,
output  reg config_softresetqsfpc,
output  reg config_modesel,
output  reg config_lpmode,
output  reg config_poll_en,
input   status_modprsl_i,
input   status_int_qsfp_i,
input   status_int_i2c_i,
input   status_tx_err_i,
input   status_rx_err_i,
input   status_snk_ready_i,
input   status_src_ready_i,
input   status_fsm_paused_i,
input [7:0] status_curr_rd_page_i,
input [7:0] status_curr_rd_addr_i,
input clk,
input reset,
input [63:0] writedata,
input read,
input write,
input [3:0] byteenable,
output reg [63:0] readdata,
output reg [31:0] delay_csr_in, 
output reg readdatavalid,
input [5:0] address
);

wire reset_n = !reset;	
reg [63:0] rdata_comb;
reg [63:0] scratch_reg;

always @(negedge reset_n ,posedge clk)  
   if (!reset_n) readdata[63:0] <= 64'h0; else readdata[63:0] <= rdata_comb[63:0];

always @(negedge reset_n , posedge clk)
   if (!reset_n) readdatavalid <= 1'b0; else readdatavalid <= read;

wire wr = write;
wire re = read;
wire [5:0] addr = address[5:0];
wire [63:0] din  = writedata [63:0];
wire wr_config = wr & (addr[5:0]== 6'h20)?	byteenable[0]:1'b0;
wire wr_scratch_reg = wr & (addr[5:0]  == 6'h30)? byteenable[0]:1'b0;
wire wr_delay_fsm_reg = wr & (addr[5:0]  == 6'h38)? byteenable[0]:1'b0;

always @( negedge  reset_n,  posedge clk)
   if (!reset_n)  begin
      config_softresetqsfpm <= 1'h0;
   end
   else begin
   if (wr_config) begin 
      config_softresetqsfpm   <=  din[0];  
   end
end

always @( negedge  reset_n,  posedge clk)
   if (!reset_n)  begin
      config_softresetqsfpc <= 1'h0;
   end
   else begin
   if (wr_config) begin 
      config_softresetqsfpc   <=  din[1];  
   end
end

always @( negedge  reset_n,  posedge clk)
   if (!reset_n)  begin
      config_modesel <= 1'h0;
   end
   else begin
   if (wr_config) begin 
      config_modesel   <=  din[2];  
   end
end

always @( negedge  reset_n,  posedge clk)
   if (!reset_n)  begin
      config_lpmode <= 1'h0;
   end
   else begin
   if (wr_config) begin 
      config_lpmode   <=  din[3];  
   end
end


always @( negedge  reset_n,  posedge clk)
   if (!reset_n)  begin
      config_poll_en <= 1'h0;
   end
   else begin
   if (wr_config) begin 
      config_poll_en   <=  din[4]; 
   end
end

// 64 bit scratch register
always @( negedge  reset_n,  posedge clk)
   if (!reset_n)  begin
      scratch_reg <= 64'h0;
   end
   else begin
   if (wr_scratch_reg) begin 
      scratch_reg <=  din;  
   end
end

always @( negedge  reset_n,  posedge clk)
   if (!reset_n)  begin
      delay_csr_in <= 32'hFFFFF;
   end
   else begin
   if (wr_delay_fsm_reg) begin 
      delay_csr_in <=  din[31:0];  
   end
end

always @ (*)
begin
rdata_comb = 64'h0000000000000000;
   if(re) begin
      case (addr)  
	6'h00 : begin
		rdata_comb [11:0]	= FEAT_ID ;  // dfh_feature_id 	is reserved or a constant value, a read access gives the reset value
		rdata_comb [15:12]	= FEAT_VER ;  // dfh_feature_rev 	is reserved or a constant value, a read access gives the reset value
		rdata_comb [39:16]	= NEXT_DFH_OFFSET ;  // dfh_dfh_ofst is reserved or a constant value, a read access gives the reset value
		rdata_comb [40]	    = END_OF_LIST ;        //dfh_end_of_list
		rdata_comb [59:40]	= 20'h00000 ;  // dfh_rsvd1 	is reserved or a constant value, a read access gives the reset value
		rdata_comb [63:60]	= 4'h3 ;  // dfh_feat_type 	is reserved or a constant value, a read access gives the reset value
	end
	6'h20 : begin
		rdata_comb [0]		= config_softresetqsfpm  ;		// readType = read   writeType =write
		rdata_comb [1]		= config_softresetqsfpc  ;		// readType = read   writeType =write
		rdata_comb [2]		= config_modesel  ;		// readType = read   writeType =write
		rdata_comb [3]		= config_lpmode  ;		// readType = read   writeType =write
		rdata_comb [4]		= config_poll_en  ;		// readType = read   writeType =write
		rdata_comb [63:5]	= 59'h000000000000000 ;  // config_rsvd2 	is reserved or a constant value, a read access gives the reset value
	end
	6'h28 : begin
		rdata_comb [0]		= status_modprsl_i  !== 1'b1 ? 1'b0:1'b1  ;			// readType = read   writeType =illegal
		rdata_comb [1]		= status_int_qsfp_i !== 1'b1 ? 1'b0:1'b1  ;			// readType = read   writeType =illegal
		rdata_comb [2]		= status_int_i2c_i  ;			// readType = read   writeType =illegal
		rdata_comb [3]		= status_tx_err_i  ;			// readType = read   writeType =illegal
		rdata_comb [4]		= status_rx_err_i  ;			// readType = read   writeType =illegal
		rdata_comb [5]		= status_snk_ready_i  ;			// readType = read   writeType =illegal
		rdata_comb [6]		= status_src_ready_i  ;			// readType = read   writeType =illegal
		rdata_comb [7]		= status_fsm_paused_i  ;		// readType = read   writeType =illegal
		rdata_comb [15:8]	= status_curr_rd_page_i ;	    // readType = read   writeType =illegal
		rdata_comb [23:16]	= status_curr_rd_addr_i ;	    // readType = read   writeType =illegal
		rdata_comb [63:24]	= 40'h0000000000;               // status_rsvd3 	is reserved or a constant value, a read access gives the reset value
	end
	6'h30 : begin
		rdata_comb [63:0]	= scratch_reg; 
	end
	6'h38 : begin
		rdata_comb [63:0]	= {32'b0,delay_csr_in}; 
	end
	default : begin
		rdata_comb = 64'h0000000000000000;
	end
      endcase
   end
end

endmodule
