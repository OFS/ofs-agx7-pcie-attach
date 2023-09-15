// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  CSR address 
//
//-----------------------------------------------------------------------------
`ifndef __TEST_CSR_DEFS__
`define __TEST_CSR_DEFS__

package test_csr_defs;

    // ******************************************************************************************
    // PORT Register Addresses
    // ******************************************************************************************
      parameter PORT_STP_DFH_ADDR              = 32'h73000;                    
      parameter PORT_STP_STATUS_ADDR           = PORT_STP_DFH_ADDR + 32'h8;    
      parameter PORT_STP_UNIMPLEMENTED_ADDR    = PORT_STP_DFH_ADDR + 32'h10;    
      parameter RSTP_DBG_IP_ADDR               = PORT_STP_DFH_ADDR + 32'h1000;
      parameter RSTP_H2T_MEM_ADDR              = PORT_STP_DFH_ADDR + 32'h2000;
      parameter RSTP_T2H_MEM_ADDR              = PORT_STP_DFH_ADDR + 32'h3000;
    
    
    
    // ******************************************************************************************
    // PORT Register Default Values
    // ******************************************************************************************
    parameter PORT_STP_DFH_VAL                  = 64'h30000000D0002013;
    parameter  PORT_STP_STATUS_VAL              = 64'h0000000000000000;


    // ******************************************************************************************
    // Debug Interface IP Register Offset Addresses (From RSTP_DBG_IP_ADDR)
    // ******************************************************************************************
    parameter DBG_IP_RDDM_VER_ADDR              = 32'h0000; //RO
    parameter DBG_IP_RDDM_REV_ADDR              = 32'h0004; //RO
    parameter DBG_IP_CTRL_ADDR                  = 32'h0020; //bit0 RCoR-reset packet transit, byte1 RW-internal AVST lpbk
    parameter DBG_IP_EXT_MEM_DEPTH_ADDR         = 32'h0024; //RO
    parameter DBG_IP_EXT_DESC_DEPTH_ADDR        = 32'h002C; //RO
    parameter DBG_IP_INTR_MASK_ADDR             = 32'h0048; //RW ([0]- h2t, [1]- t2h)

    parameter DBG_IP_H2T_SLOT_AVAIL_ADDR        = 32'h0100; //RO
    parameter DBG_IP_H2T_PKT_LEN_ADDR           = 32'h0108; //WO ([30:0]- length, [31]- last descriptor of packet)
    parameter DBG_IP_H2T_START_LOC_ADDR         = 32'h010C; //WO 
    parameter DBG_IP_H2T_CONNECTION_ID_ADDR     = 32'h0110; //WO 
    parameter DBG_IP_H2T_CHANNEL_ID_ADDR        = 32'h0114; //WO 
    
    parameter DBG_IP_T2H_PKT_LEN_ADDR           = 32'h0208; //RO ([30:0]- length, [31]- last descriptor of packet)
    parameter DBG_IP_T2H_START_LOC_ADDR         = 32'h020C; //RO 
    parameter DBG_IP_T2H_CONNECTION_ID_ADDR     = 32'h0210; //RO 
    parameter DBG_IP_T2H_CHANNEL_ID_ADDR        = 32'h0214; //RO 
    parameter DBG_IP_T2H_DESC_DONE_ADDR         = 32'h0218; //WO
    
    parameter DBG_IP_T2H_UNIMPLEMENTED_ADDR     = 32'h0300; // Not implemented 
    


    // ******************************************************************************************
    // Debug Interface IP Register Values
    // ******************************************************************************************
    parameter DBG_IP_RDDM_VER_VAL              = 32'h5244_444D;
    parameter DBG_IP_RDDM_REV_VAL              = 32'h0000_0000;
    parameter DBG_IP_EXT_MEM_DEPTH_VAL         = 32'h0000_1000;
    parameter DBG_IP_EXT_DESC_DEPTH_VAL        = 32'h0000_0020;
    parameter DBG_IP_H2T_SLOT_AVAIL_VAL        = 32'h0000_0020;
    parameter DBG_IP_T2H_PKT_LEN_VAL           = 32'h0000_0000;
    parameter DBG_IP_T2H_START_LOC_VAL         = 32'h0000_0000;
    
    parameter DBG_IP_FAULT_VAL                 = 32'hDEAD_C0DE;
    

endpackage

`endif
