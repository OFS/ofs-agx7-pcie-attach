// Copyright (C) 2023 Intel Corporation.
// SPDX-License-Identifier: MIT
//
`ifndef __HOST_BFM_TYPES_PKG__
`define __HOST_BFM_TYPES_PKG__

package host_bfm_types_pkg; 

//----------------------------------------------------------------------------------------------------
// Parameter and Enum Definitions for Host BFM.
//----------------------------------------------------------------------------------------------------

typedef bit   [9:0] packet_tag_t;
typedef logic [7:0] byte_t;
typedef bit  [23:0] dm_length_t;
typedef bit  [63:0] addr_t;
typedef bit [127:0] uint128_t;
typedef longint unsigned uint64_t;
typedef int unsigned uint32_t;
typedef byte_t byte_array_t [];

parameter TUSER_WIDTH = 10;
parameter TDATA_WIDTH = 512;
parameter HDR_WIDTH = 256;
//parameter TDATA_WIDTH = 1024;


endpackage: host_bfm_types_pkg

`endif // __HOST_BFM_TYPES_PKG__
