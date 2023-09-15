// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  Derived defines for HSSI SS
//
//----------------------------------------------------------------------------

`ifndef ofs_fim_eth_plat_defines
`define ofs_fim_eth_plat_defines

   // This macro is defined when ofs_fim_eth_if_pkg provides the functions
   // func_axis_hssi_ss_?x_to_string(). The functions were added mid-2023
   // for debug logging. The macro is used by the PIM for backward
   // compatibility with FIMs where the function is not available.
   `define OFS_FIM_ETH_PROVIDES_HSSI_TO_STRING 1


   `define INST_QSFP_PORT(qsfp_port) \
      inout  wire qsfp``qsfp_port``_i2c_scl, \
      inout  wire qsfp``qsfp_port``_i2c_sda, \
      output wire qsfp``qsfp_port``_resetn , \
      output wire qsfp``qsfp_port``_modeseln, \
      input  wire qsfp``qsfp_port``_modprsln, \
      output wire qsfp``qsfp_port``_lpmode, \
      input  wire qsfp``qsfp_port``_intn, \

   `define MAP_HSSI_TO_QSFP(hssi_port_num, qsfp_port_num, qsfp_idx_h, qsfp_idx_l) \
      assign serial_rx_p[PORT_``hssi_port_num``]      = qsfp_serial[``qsfp_port_num``].rx_p[``qsfp_idx_h``:``qsfp_idx_l``]; \
      assign serial_rx_n[PORT_``hssi_port_num``]      = 1'b0; \
      assign qsfp_serial[``qsfp_port_num``].tx_p[``qsfp_idx_h``:``qsfp_idx_l``]      = serial_tx_p[PORT_``hssi_port_num``];

   `define INST_LED(led_type,hssi_port_num, led_idx, operator) \
      led_``led_type``[PORT_``hssi_port_num``][``led_idx``] ``operator`` 

   `define HSSI_PORT_INST(hssi_port_num) \
     .p``hssi_port_num``_app_ss_st_tx_clk                (hssi_ss_st_tx[PORT_``hssi_port_num``].clk), \
     .p``hssi_port_num``_app_ss_st_tx_areset_n           (hssi_ss_st_tx[PORT_``hssi_port_num``].rst_n), \
     .p``hssi_port_num``_app_ss_st_tx_tvalid             (hssi_ss_st_tx[PORT_``hssi_port_num``].tx.tvalid), \
     .p``hssi_port_num``_ss_app_st_tx_tready             (hssi_ss_st_tx[PORT_``hssi_port_num``].tready), \
     .p``hssi_port_num``_app_ss_st_tx_tdata              (hssi_ss_st_tx[PORT_``hssi_port_num``].tx.tdata), \
     .p``hssi_port_num``_app_ss_st_tx_tkeep              (hssi_ss_st_tx[PORT_``hssi_port_num``].tx.tkeep), \
     .p``hssi_port_num``_app_ss_st_tx_tlast              (hssi_ss_st_tx[PORT_``hssi_port_num``].tx.tlast), \
     .p``hssi_port_num``_app_ss_st_tx_tuser_client       (hssi_ss_st_tx[PORT_``hssi_port_num``].tx.tuser.client), \
     .p``hssi_port_num``_app_ss_st_rx_clk                (hssi_ss_st_rx[PORT_``hssi_port_num``].clk), \
     .p``hssi_port_num``_app_ss_st_rx_areset_n           (hssi_ss_st_rx[PORT_``hssi_port_num``].rst_n), \
     .p``hssi_port_num``_ss_app_st_rx_tvalid             (hssi_ss_st_rx[PORT_``hssi_port_num``].rx.tvalid), \
     .p``hssi_port_num``_ss_app_st_rx_tdata              (hssi_ss_st_rx[PORT_``hssi_port_num``].rx.tdata), \
     .p``hssi_port_num``_ss_app_st_rx_tkeep              (hssi_ss_st_rx[PORT_``hssi_port_num``].rx.tkeep), \
     .p``hssi_port_num``_ss_app_st_rx_tlast              (hssi_ss_st_rx[PORT_``hssi_port_num``].rx.tlast), \
     .p``hssi_port_num``_ss_app_st_rx_tuser_client       (hssi_ss_st_rx[PORT_``hssi_port_num``].rx.tuser.client), \
     .p``hssi_port_num``_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx[PORT_``hssi_port_num``].rx.tuser.sts), \
     .p``hssi_port_num``_tx_serial                       (serial_tx_p[PORT_``hssi_port_num``]), \
     .p``hssi_port_num``_tx_serial_n                     (serial_tx_n[PORT_``hssi_port_num``]), \
     .p``hssi_port_num``_rx_serial                       (serial_rx_p[PORT_``hssi_port_num``]), \
     .p``hssi_port_num``_rx_serial_n                     (serial_rx_n[PORT_``hssi_port_num``]), \
     .p``hssi_port_num``_tx_lanes_stable                 (tx_lanes_stable[PORT_``hssi_port_num``]), \
     .p``hssi_port_num``_rx_pcs_ready                    (rx_pcs_ready[PORT_``hssi_port_num``]), \
     .i_p``hssi_port_num``_tx_pause                      (hssi_fc[PORT_``hssi_port_num``].tx_pause), \
     .i_p``hssi_port_num``_tx_pfc                        (hssi_fc[PORT_``hssi_port_num``].tx_pfc), \
     .i_p``hssi_port_num``_tx_rst_n                      (~handshaked_tx_rst[PORT_``hssi_port_num``]), \
     .i_p``hssi_port_num``_rx_rst_n                      (~handshaked_rx_rst[PORT_``hssi_port_num``]), \
     .o_p``hssi_port_num``_rx_pause                      (hssi_fc[PORT_``hssi_port_num``].rx_pause), \
     .o_p``hssi_port_num``_rx_pfc                        (hssi_fc[PORT_``hssi_port_num``].rx_pfc), \
     .o_p``hssi_port_num``_tx_pll_locked                 (tx_pll_locked[PORT_``hssi_port_num``]), \
     .o_p``hssi_port_num``_rx_rst_ack_n                  (rx_rst_ack_n[PORT_``hssi_port_num``]), \
     .o_p``hssi_port_num``_tx_rst_ack_n                  (tx_rst_ack_n[PORT_``hssi_port_num``]), \
     .o_p``hssi_port_num``_ereset_n                      (), \
     .o_p``hssi_port_num``_clk_pll                       (clk_pll[PORT_``hssi_port_num``]), \
     .o_p``hssi_port_num``_clk_tx_div                    (clk_tx_div[PORT_``hssi_port_num``]), \
     .o_p``hssi_port_num``_clk_rec_div64                 (clk_rec_div64[PORT_``hssi_port_num``]), \
     .o_p``hssi_port_num``_clk_rec_div                   (clk_rec_div[PORT_``hssi_port_num``]), \
     .port``hssi_port_num``_led_speed                     (led_speed[PORT_``hssi_port_num``]), \
     .port``hssi_port_num``_led_status                    (led_status[PORT_``hssi_port_num``]),

`endif
