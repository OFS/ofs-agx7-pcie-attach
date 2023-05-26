// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

if(MODE_25G_10G)begin
   force qsfp_serial[0].rx_p[0] = mac_ethernet_if[0].tx_lane[0];
   //force qsfp_serial[0].rx_n[0] = ~qsfp_serial[0].rx_p[0]; 
   force mac_ethernet_if[0].rx_lane[0] = qsfp_serial[0].tx_p[0];

   force qsfp_serial[0].rx_p[1] = mac_ethernet_if[1].tx_lane[0];
   //force qsfp_serial[0].rx_n[0] = ~qsfp_serial[0].rx_p[0]; 
   force mac_ethernet_if[1].rx_lane[0] = qsfp_serial[0].tx_p[1];

   force qsfp_serial[0].rx_p[2] = mac_ethernet_if[2].tx_lane[0];
   //force qsfp_serial[0].rx_n[0] = ~qsfp_serial[0].rx_p[0]; 
   force mac_ethernet_if[2].rx_lane[0] = qsfp_serial[0].tx_p[2];

   force qsfp_serial[0].rx_p[3] = mac_ethernet_if[3].tx_lane[0];
   //force qsfp_serial[0].rx_n[0] = ~qsfp_serial[0].rx_p[0]; 
   force mac_ethernet_if[3].rx_lane[0] = qsfp_serial[0].tx_p[3];

   force qsfp_serial[1].rx_p[0] = mac_ethernet_if[4].tx_lane[0];
   //force qsfp_serial[0].rx_n[0] = ~qsfp_serial[0].rx_p[0]; 
   force mac_ethernet_if[4].rx_lane[0] = qsfp_serial[1].tx_p[0];

   force qsfp_serial[1].rx_p[1] = mac_ethernet_if[5].tx_lane[0];
   //force qsfp_serial[0].rx_n[0] = ~qsfp_serial[0].rx_p[0]; 
   force mac_ethernet_if[5].rx_lane[0] = qsfp_serial[1].tx_p[1];
   
   force qsfp_serial[1].rx_p[2] = mac_ethernet_if[6].tx_lane[0];
   //force qsfp_serial[0].rx_n[0] = ~qsfp_serial[0].rx_p[0]; 
   force mac_ethernet_if[6].rx_lane[0] = qsfp_serial[1].tx_p[2];

   force qsfp_serial[1].rx_p[3] = mac_ethernet_if[7].tx_lane[0];
   //force qsfp_serial[0].rx_n[0] = ~qsfp_serial[0].rx_p[0]; 
   force mac_ethernet_if[7].rx_lane[0] = qsfp_serial[1].tx_p[3];
end 




