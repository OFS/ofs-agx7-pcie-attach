// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

// QSFP Interface signals
interface qsfp_intf (input logic clk, reset);
  logic modprsl;
  logic int_qsfp;
  logic modsel;
  logic lpmode;
  logic softresetqsfm;
endinterface  
