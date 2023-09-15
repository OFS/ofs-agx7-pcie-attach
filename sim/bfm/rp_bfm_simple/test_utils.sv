// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  Test utils package 
//
//-----------------------------------------------------------------------------

`ifndef TEST_UTILS_SV
`define TEST_UTILS_SV
package test_utils;

localparam  integer MAX_CHARS = 32;

integer logfile_handle;
integer out_handle;
integer err_count = 0;
integer assert_err_count = 0;
integer assert_count = 0;

function void init_logfile(
  input [MAX_CHARS*8-1:0] file_name
);
  out_handle = 1; // STDOUT
  logfile_handle = open_file(file_name);
  out_handle = out_handle | logfile_handle;
endfunction

  

function integer open_file(
  input [MAX_CHARS*8-1:0] file_name
);
  begin
    open_file = $fopen(file_name);
    if(open_file == 0) begin
      $fdisplay(out_handle,"ERROR: Could not open file: %0s!", file_name);
      $finish(2);
    end
  end
endfunction


function integer get_logfile_handle;
  begin
    get_logfile_handle = out_handle;
  end
endfunction

function void incr_err_count;
  begin
    if(err_count != {32{1'b1}})
      err_count = err_count + 1;
  end
endfunction

function integer get_err_count;
  begin
    get_err_count = err_count;
  end
endfunction

function void incr_assert_err_count;
  begin
    if(assert_err_count != {32{1'b1}})
      assert_err_count = assert_err_count + 1;
  end
endfunction

function integer get_assert_err_count;
  begin
    get_assert_err_count = assert_err_count;
  end
endfunction

function void incr_assert_count;
  begin
    if(assert_count != {32{1'b1}})
      assert_count = assert_count + 1;
  end
endfunction

function integer get_assert_count;
  begin
    get_assert_count = assert_count;
  end
endfunction

function [63:0] get_max_delay_count (
	input [63:0] delay_ns,
	input [63:0] clk_freq_in_hz	
);
  begin
	reg [63:0] delay_count;
	reg [63:0] delay_round_count;
	
	delay_count = (clk_freq_in_hz * delay_ns) / 1000000000;
	// Round counter limit up if needed
	delay_round_count = (((delay_count * 1000000000) / clk_freq_in_hz) < delay_ns)
							? (delay_count + 1) : delay_count;	
	get_max_delay_count = (delay_round_count > 0) ? delay_round_count - 1 : 0;	
  end
endfunction

endpackage
`endif
