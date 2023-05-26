// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//QSFP slave interface file
//Interface for I2C 
`ifndef QSFP_SLAVE_INTERFACE
`define QSFP_SLAVE_INTERFACE

interface qsfp_slave_interface(input wire clk , input wire rst_n);

  logic [31:0] address ;
  logic        read ;
  logic [31:0] readdata;
  logic        readdatavalid ;
  logic        waitrequest ;
  logic        write ;
  logic [3:0]  byteenable;
  logic [31:0] writedata;
  logic        i2c_data_in ;
  logic        i2c_clk_in ;
  logic        i2c_data_oe ;
  logic        i2c_clk_oe ;

endinterface
`endif // QSFP_SLAVE_INTERFACE
