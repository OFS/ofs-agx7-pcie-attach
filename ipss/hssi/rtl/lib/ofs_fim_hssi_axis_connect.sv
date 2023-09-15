// Copyright 2021 Intel Corporation
// SPDX-License-Header: MIT

//
// Wire together two instances of HSSI interfaces. These modules are used
// when attaching HSSI interfaces to the Platform Interface Manager (PIM).
//

module ofs_fim_hssi_axis_connect_rx (
   ofs_fim_hssi_ss_rx_axis_if.mac to_client,
   ofs_fim_hssi_ss_rx_axis_if.client to_mac
);

   assign to_client.clk = to_mac.clk;
   assign to_client.rst_n = to_mac.rst_n;
   assign to_client.rx = to_mac.rx;

endmodule // ofs_fim_hssi_axis_connect_rx


module ofs_fim_hssi_axis_connect_tx (
   ofs_fim_hssi_ss_tx_axis_if.mac to_client,
   ofs_fim_hssi_ss_tx_axis_if.client to_mac
);

   assign to_client.clk = to_mac.clk;
   assign to_client.rst_n = to_mac.rst_n;
   assign to_client.tready = to_mac.tready;
   assign to_mac.tx = to_client.tx;

endmodule // ofs_fim_hssi_axis_connect_tx


module ofs_fim_hssi_connect_fc (
   ofs_fim_hssi_fc_if.mac to_client,
   ofs_fim_hssi_fc_if.client to_mac
);

   assign to_client.rx_pause = to_mac.rx_pause;
   assign to_client.rx_pfc = to_mac.rx_pfc;

   assign to_mac.tx_pause = to_client.tx_pause;
   assign to_mac.tx_pfc = to_client.tx_pfc;

endmodule // ofs_fim_hssi_connect_fc
