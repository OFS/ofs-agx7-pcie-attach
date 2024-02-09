// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT
`ifndef INCLUDE_CVL
`ifdef ETH_400G
   /*force hssi_if[0].rx_p = mac_ethernet_if.tx_lane[0];
   force mac_ethernet_if.rx_lane[0] = hssi_if[0].tx_p;

   force hssi_if[1].rx_p = mac_ethernet_if.tx_lane[1];
   force mac_ethernet_if.rx_lane[1] = hssi_if[1].tx_p;

   force hssi_if[2].rx_p = mac_ethernet_if.tx_lane[2];
   force mac_ethernet_if.rx_lane[2] = hssi_if[2].tx_p;

   force hssi_if[3].rx_p = mac_ethernet_if.tx_lane[3];
   force mac_ethernet_if.rx_lane[3] = hssi_if[3].tx_p;

   force hssi_if[4].rx_p = mac_ethernet_if.tx_lane[4];
   force mac_ethernet_if.rx_lane[4] = hssi_if[4].tx_p;

   force hssi_if[5].rx_p = mac_ethernet_if.tx_lane[5];
   force mac_ethernet_if.rx_lane[5] = hssi_if[5].tx_p;
   
   force hssi_if[6].rx_p = mac_ethernet_if.tx_lane[6];
   force mac_ethernet_if.rx_lane[6] = hssi_if[6].tx_p;

   force hssi_if[7].rx_p = mac_ethernet_if.tx_lane[7];
   force mac_ethernet_if.rx_lane[7] = hssi_if[7].tx_p;*/
   
    //Assuming tx_p,tx_n,rx_p,rx_n are 8 bit serial lines coming out from RTL
 


`else
  if(MODE_25G_10G)begin
   force hssi_if[0].rx_p = mac_ethernet_if[0].tx_lane[0];
   force mac_ethernet_if[0].rx_lane[0] = hssi_if[0].tx_p;

   force hssi_if[1].rx_p = mac_ethernet_if[1].tx_lane[0];
   force mac_ethernet_if[1].rx_lane[0] = hssi_if[1].tx_p;

   force hssi_if[2].rx_p = mac_ethernet_if[2].tx_lane[0];
   force mac_ethernet_if[2].rx_lane[0] = hssi_if[2].tx_p;

   force hssi_if[3].rx_p = mac_ethernet_if[3].tx_lane[0];
   force mac_ethernet_if[3].rx_lane[0] = hssi_if[3].tx_p;

   force hssi_if[4].rx_p = mac_ethernet_if[4].tx_lane[0];
   force mac_ethernet_if[4].rx_lane[0] = hssi_if[4].tx_p;

   force hssi_if[5].rx_p = mac_ethernet_if[5].tx_lane[0];
   force mac_ethernet_if[5].rx_lane[0] = hssi_if[5].tx_p;
   
   force hssi_if[6].rx_p = mac_ethernet_if[6].tx_lane[0];
   force mac_ethernet_if[6].rx_lane[0] = hssi_if[6].tx_p;

   force hssi_if[7].rx_p = mac_ethernet_if[7].tx_lane[0];
   force mac_ethernet_if[7].rx_lane[0] = hssi_if[7].tx_p;
end
`endif
`endif

`ifdef INCLUDE_CVL
 `ifdef n6000_10G
if(MODE_25G_10G)begin
   force  cvl_serial_rx_p[0]= mac_ethernet_if[0].tx_lane[0];
   force  cvl_serial_rx_n[0]= ~cvl_serial_rx_p[0];
   force  mac_ethernet_if[0].rx_lane[0]=cvl_serial_tx_p[0];

   force  cvl_serial_rx_p[1]= mac_ethernet_if[1].tx_lane[0];
   force  cvl_serial_rx_n[1]= ~cvl_serial_rx_p[1];
   force  mac_ethernet_if[1].rx_lane[0]=cvl_serial_tx_p[1];

   force  cvl_serial_rx_p[2]= mac_ethernet_if[2].tx_lane[0];
   force  cvl_serial_rx_n[2]= ~cvl_serial_rx_p[2];
   force  mac_ethernet_if[2].rx_lane[0]=cvl_serial_tx_p[2];

   force  cvl_serial_rx_p[3]= mac_ethernet_if[3].tx_lane[0];
   force  cvl_serial_rx_n[3]= ~cvl_serial_rx_p[3];
   force  mac_ethernet_if[3].rx_lane[0]=cvl_serial_tx_p[3];
   
   force  cvl_serial_rx_p[4]= mac_ethernet_if[4].tx_lane[0];
   force  cvl_serial_rx_n[4]= ~cvl_serial_rx_p[4];
   force  mac_ethernet_if[4].rx_lane[0]=cvl_serial_tx_p[4];

   force  cvl_serial_rx_p[5]= mac_ethernet_if[5].tx_lane[0];
   force  cvl_serial_rx_n[5]= ~cvl_serial_rx_p[5];
   force  mac_ethernet_if[5].rx_lane[0]=cvl_serial_tx_p[5];

   force  cvl_serial_rx_p[6]= mac_ethernet_if[6].tx_lane[0];
   force  cvl_serial_rx_n[6]= ~cvl_serial_rx_p[6];
   force  mac_ethernet_if[6].rx_lane[0]=cvl_serial_tx_p[6];

   force  cvl_serial_rx_p[7]= mac_ethernet_if[7].tx_lane[0];
   force  cvl_serial_rx_n[7]= ~cvl_serial_rx_p[7];
   force  mac_ethernet_if[7].rx_lane[0]=cvl_serial_tx_p[7];
end
 `elsif n6000_25G
if(CVL_25G)begin
   force  cvl_serial_rx_p[0]= mac_ethernet_if[0].tx_lane[0];
   force  cvl_serial_rx_n[0]= ~cvl_serial_rx_p[0];
   force  mac_ethernet_if[0].rx_lane[0]=cvl_serial_tx_p[0];

   force  cvl_serial_rx_p[1]= mac_ethernet_if[1].tx_lane[0];
   force  cvl_serial_rx_n[1]= ~cvl_serial_rx_p[1];
   force  mac_ethernet_if[1].rx_lane[0]=cvl_serial_tx_p[1];

   force  cvl_serial_rx_p[2]= mac_ethernet_if[2].tx_lane[0];
   force  cvl_serial_rx_n[2]= ~cvl_serial_rx_p[2];
   force  mac_ethernet_if[2].rx_lane[0]=cvl_serial_tx_p[2];

   force  cvl_serial_rx_p[3]= mac_ethernet_if[3].tx_lane[0];
   force  cvl_serial_rx_n[3]= ~cvl_serial_rx_p[3];
   force  mac_ethernet_if[3].rx_lane[0]=cvl_serial_tx_p[3];
end
 `elsif n6000_100G
if(CVL_100G)begin
   /*force cvl_serial_rx_p[0] = mac_ethernet_if[0].tx_lane[0];
   force cvl_serial_rx_p[1] = mac_ethernet_if[0].tx_lane[1];
   force cvl_serial_rx_p[2] = mac_ethernet_if[0].tx_lane[2];
   force cvl_serial_rx_p[3] = mac_ethernet_if[0].tx_lane[3];
   force cvl_serial_rx_n[0]= ~cvl_serial_rx_p[0];
   force cvl_serial_rx_n[1]= ~cvl_serial_rx_p[1];
   force cvl_serial_rx_n[2]= ~cvl_serial_rx_p[2];
   force cvl_serial_rx_n[3]= ~cvl_serial_rx_p[3];
   force  mac_ethernet_if[0].rx_lane[0]=cvl_serial_tx_p[0];
   force  mac_ethernet_if[0].rx_lane[1]=cvl_serial_tx_p[1];
   force  mac_ethernet_if[0].rx_lane[2]=cvl_serial_tx_p[2];
   force  mac_ethernet_if[0].rx_lane[3]=cvl_serial_tx_p[3];

   force cvl_serial_rx_p[4] = mac_ethernet_if[1].tx_lane[0];
   force cvl_serial_rx_p[5] = mac_ethernet_if[1].tx_lane[1];
   force cvl_serial_rx_p[6] = mac_ethernet_if[1].tx_lane[2];
   force cvl_serial_rx_p[7] = mac_ethernet_if[1].tx_lane[3];
   force cvl_serial_rx_n[4]= ~cvl_serial_rx_p[4];
   force cvl_serial_rx_n[5]= ~cvl_serial_rx_p[5];
   force cvl_serial_rx_n[6]= ~cvl_serial_rx_p[6];
   force cvl_serial_rx_n[7]= ~cvl_serial_rx_p[7];
   force  mac_ethernet_if[1].rx_lane[0]=cvl_serial_tx_p[4];
   force  mac_ethernet_if[1].rx_lane[1]=cvl_serial_tx_p[5];
   force  mac_ethernet_if[1].rx_lane[2]=cvl_serial_tx_p[6];
   force  mac_ethernet_if[1].rx_lane[3]=cvl_serial_tx_p[7];*/

   force hssi_if[0].rx_p = mac_ethernet_if[0].tx_lane[0];
   force hssi_if[1].rx_p = mac_ethernet_if[0].tx_lane[1];
   force hssi_if[2].rx_p = mac_ethernet_if[0].tx_lane[2];
   force hssi_if[3].rx_p = mac_ethernet_if[0].tx_lane[3];
   
   force hssi_if[0].rx_n= ~mac_ethernet_if[0].tx_lane[0];
   force hssi_if[1].rx_n= ~mac_ethernet_if[0].tx_lane[1];
   force hssi_if[2].rx_n= ~mac_ethernet_if[0].tx_lane[2];
   force hssi_if[3].rx_n= ~mac_ethernet_if[0].tx_lane[3];
   
   force  mac_ethernet_if[0].rx_lane[0]=hssi_if[0].tx_p;
   force  mac_ethernet_if[0].rx_lane[1]=hssi_if[1].tx_p;
   force  mac_ethernet_if[0].rx_lane[2]=hssi_if[2].tx_p;
   force  mac_ethernet_if[0].rx_lane[3]=hssi_if[3].tx_p;

   force hssi_if[4].rx_p = mac_ethernet_if[1].tx_lane[0];
   force hssi_if[5].rx_p = mac_ethernet_if[1].tx_lane[1];
   force hssi_if[6].rx_p = mac_ethernet_if[1].tx_lane[2];
   force hssi_if[7].rx_p = mac_ethernet_if[1].tx_lane[3];
   
   force hssi_if[4].rx_n= ~mac_ethernet_if[1].tx_lane[0];
   force hssi_if[5].rx_n= ~mac_ethernet_if[1].tx_lane[1];
   force hssi_if[6].rx_n= ~mac_ethernet_if[1].tx_lane[2];
   force hssi_if[7].rx_n= ~mac_ethernet_if[1].tx_lane[3];
   
   force  mac_ethernet_if[1].rx_lane[0]=hssi_if[4].tx_p;
   force  mac_ethernet_if[1].rx_lane[1]=hssi_if[5].tx_p;
   force  mac_ethernet_if[1].rx_lane[2]=hssi_if[6].tx_p;
   force  mac_ethernet_if[1].rx_lane[3]=hssi_if[7].tx_p;




end // if (CVL_100G)
 `elsif FIM_B
if(MODE_25G_10G)begin
   force  cvl_serial_rx_p[0]= mac_ethernet_if[0].tx_lane[0];
   force  cvl_serial_rx_n[0]= ~cvl_serial_rx_p[0];
   force  mac_ethernet_if[0].rx_lane[0]=cvl_serial_tx_p[0];

   force  cvl_serial_rx_p[1]= mac_ethernet_if[1].tx_lane[0];
   force  cvl_serial_rx_n[1]= ~cvl_serial_rx_p[1];
   force  mac_ethernet_if[1].rx_lane[0]=cvl_serial_tx_p[1];

   force  cvl_serial_rx_p[2]= mac_ethernet_if[2].tx_lane[0];
   force  cvl_serial_rx_n[2]= ~cvl_serial_rx_p[2];
   force  mac_ethernet_if[2].rx_lane[0]=cvl_serial_tx_p[2];

   force  cvl_serial_rx_p[3]= mac_ethernet_if[3].tx_lane[0];
   force  cvl_serial_rx_n[3]= ~cvl_serial_rx_p[3];
   force  mac_ethernet_if[3].rx_lane[0]=cvl_serial_tx_p[3];
   
   force  cvl_serial_rx_p[4]= mac_ethernet_if[4].tx_lane[0];
   force  cvl_serial_rx_n[4]= ~cvl_serial_rx_p[4];
   force  mac_ethernet_if[4].rx_lane[0]=cvl_serial_tx_p[4];

   force  cvl_serial_rx_p[5]= mac_ethernet_if[5].tx_lane[0];
   force  cvl_serial_rx_n[5]= ~cvl_serial_rx_p[5];
   force  mac_ethernet_if[5].rx_lane[0]=cvl_serial_tx_p[5];

   force  cvl_serial_rx_p[6]= mac_ethernet_if[6].tx_lane[0];
   force  cvl_serial_rx_n[6]= ~cvl_serial_rx_p[6];
   force  mac_ethernet_if[6].rx_lane[0]=cvl_serial_tx_p[6];

   force  cvl_serial_rx_p[7]= mac_ethernet_if[7].tx_lane[0];
   force  cvl_serial_rx_n[7]= ~cvl_serial_rx_p[7];
   force  mac_ethernet_if[7].rx_lane[0]=cvl_serial_tx_p[7];
end
 `endif // !`elsif FIM_B
`endif //  `ifdef INCLUDE_CVL

