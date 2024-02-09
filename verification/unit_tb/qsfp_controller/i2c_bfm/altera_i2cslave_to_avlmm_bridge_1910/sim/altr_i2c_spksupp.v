// Copyright (C) 2001-2020 Intel Corporation
// SPDX-License-Identifier: MIT


`timescale 1 ps / 1 ps
module altr_i2c_spksupp (
    input       i2c_clk,
    input       i2c_rst_n,
    input [7:0] ic_fs_spklen,
    input       sda_in,
    input       scl_in,
    output      sda_int,
    output      scl_int
);

// Status Register bit definition


// wires & registers declaration
reg [7:0]   scl_spike_cnt;
reg         scl_int_reg;
reg         scl_doublesync_a;
reg [7:0]   sda_spike_cnt;
reg         sda_int_reg;
reg         sda_doublesync_a;
reg         scl_in_synced;
reg         sda_in_synced;

wire        scl_clear_cnt;
wire        scl_cnt_limit;
wire        scl_int_next;
wire        sda_clear_cnt;
wire        sda_cnt_limit;
wire        sda_int_next; 
 
 
// double sync flops for scl  
always @(posedge i2c_clk or negedge i2c_rst_n) begin
    if (!i2c_rst_n) begin
        scl_doublesync_a    <= 1'b1;
        scl_in_synced       <= 1'b1;
    end
    else begin
        scl_doublesync_a    <= scl_in;
        scl_in_synced       <= scl_doublesync_a;
    end
end
  
  
//assign scl_in_synced = scl_doublesync_b;
// XOR: return 1 to increase counter ; return 0 to reset counter
assign scl_clear_cnt = ~(scl_in_synced ^ scl_int_next) ;

// scl counter
always @(posedge i2c_clk or negedge i2c_rst_n) begin
    if(!i2c_rst_n)
        scl_spike_cnt <= 8'h0;
    else if(scl_clear_cnt)
        scl_spike_cnt <= 8'h0;
    else 
        scl_spike_cnt <= scl_spike_cnt + 8'h1;
end

// to allow scl_in pass through to scl_int when the comparator returns 1
// if disallow to pass through, scl_int returns the prev value
// to make the scl_in pass through at the same clock as the counter reaching the limit value of suppression length
assign scl_cnt_limit = (scl_spike_cnt >= ic_fs_spklen);

always @(posedge i2c_clk or negedge i2c_rst_n) begin
    if (!i2c_rst_n)
        scl_int_reg <= 1'b1;
    else 
        scl_int_reg <= scl_int_next;
end

assign scl_int_next = scl_cnt_limit ? scl_in_synced : scl_int_reg; 
//assign scl_int = scl_cnt_limit ? scl_in_synced : scl_int_reg ;
assign scl_int = scl_int_reg; // Using the registered version to improve timing



// double sync flops for sda
always @(posedge i2c_clk or negedge i2c_rst_n) begin
    if (!i2c_rst_n) begin
        sda_doublesync_a <= 1'b1;
        sda_in_synced <= 1'b1;
    end
    else begin
        sda_doublesync_a <= sda_in;
        sda_in_synced <=sda_doublesync_a;
    end
end


//  assign sda_in_synced = sda_doublesync_b;
// XOR: return 1 to increase counter ; return 0 to reset counter
assign sda_clear_cnt = ~(sda_in_synced ^ sda_int_next) ;

// sda counter
always @(posedge i2c_clk or negedge i2c_rst_n) begin
    if(!i2c_rst_n)
        sda_spike_cnt <= 8'h0;
    else if(sda_clear_cnt)
        sda_spike_cnt <= 8'h0;
    else
        sda_spike_cnt <= sda_spike_cnt + 8'h1;
end

// to allow scl_in pass through to scl_int when the comparator returns 1
// if disallow to pass through, scl_int returns the prev value
// to make the scl_in pass through at the same clock as the counter reaching the limit value of suppression length
assign sda_cnt_limit = (sda_spike_cnt >= ic_fs_spklen);

always @(posedge i2c_clk or negedge i2c_rst_n) begin
    if (!i2c_rst_n)
        sda_int_reg <= 1'b1;
    else
        sda_int_reg <= sda_int_next;
end

assign sda_int_next = sda_cnt_limit ? sda_in_synced : sda_int_reg;
//assign sda_int = sda_cnt_limit ? sda_in_synced : sda_int_reg ;
assign sda_int = sda_int_reg;  // Using the registered version to improve timing


endmodule


