// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

 // bit reference_clk        ;
  bit serial_caui_25g_clk_tx; 
  bit serial_caui_25g_clk_rx; 
  bit gmii_rx_clk          ; 
  bit gmii_tx_clk          ; 
  bit rgmii_rx_clk         ; 
  bit rgmii_tx_clk         ; 
  bit mii_100M_tx_clk      ;
  bit mii_100M_rx_clk      ;
  bit mii_10M_tx_clk       ;
  bit mii_10M_rx_clk       ;
  bit xgmii_tx_clk         ; 
  bit xgmii_rx_clk         ;
  bit ptp_system_clk       ;
  bit xlgmii_tx_clk        ; 
  bit xlgmii_rx_clk        ;
  bit xxgmii_tx_clk        ;
  bit xxgmii_rx_clk        ;
  bit tbi_tx_clk           ; 
  bit tbi_rx_clk           ; 
  bit rmii_tx_clk          ;
  bit rmii_rx_clk          ;
  bit gmii_rmii_tx_clk     ; 
  bit gmii_rmii_rx_clk     ; 
  bit xfbi_rx_clk          ; 
  bit xfbi_tx_clk          ; 
  bit xsbi_tx_clk          ; 
  bit xsbi_rx_clk          ; 
  bit gmii_mdc             ; 
  bit serial_tx_baser_clk  ; 
  bit serial_rx_baser_clk  ;
  bit serial_tx_basex_clk  ; 
  bit serial_rx_basex_clk  ;
  bit serial_tx_base4x_clk ; 
  bit serial_rx_base4x_clk ; 
  bit vsbi_rx_clk          ; 
  bit vsbi_tx_clk          ; 
  bit cgmii_tx_clk         ; 
  bit cgmii_rx_clk         ; 
  bit clk_66t_tx           ;
  bit clk_66t_rx           ;
  bit clk_40t_tx           ;
  bit clk_40t_rx           ;
  bit caui_64b_clk_tx        ;
  bit caui_64b_clk_rx         ;
  bit mdio_clk             ;
  bit qsgmii_sync_status   ;
  bit qsgmii_sync_status_tx;
  bit qsgmii_sync_status_rx;
  bit xxvgmii_tx_clk       ;
  bit xxvgmii_rx_clk       ;
  bit lgmii_tx_clk         ;
  bit lgmii_rx_clk         ;
  bit lsbi_tx_clk          ;
  bit lsbi_rx_clk          ;
  bit xxvsbi_tx_clk        ;
  bit xxvsbi_rx_clk        ;
  bit serial_12pt5g_clk_tx ;
  bit serial_12pt5g_clk_rx ;
  bit serial_cd_tx_clk;
  bit serial_cd_rx_clk;
  bit serial_50g_tx_clk;
  bit serial_50g_rx_clk;
  bit cdmii_tx_clk   ;
  bit cdmii_rx_clk   ;
  bit ccmii_tx_clk   ;
  bit ccmii_rx_clk   ;
  bit cdxbi_tx_clk   ;
  bit cdxbi_rx_clk   ;





initial begin
    //reference_clk         = 1'b0;
    gmii_rx_clk           = 1'b0; 
    gmii_tx_clk           = 1'b0; 
    rgmii_rx_clk           = 1'b0; 
    rgmii_tx_clk           = 1'b0; 
    mii_100M_tx_clk       = 1'b0; 
    mii_100M_rx_clk       = 1'b0; 
    mii_10M_tx_clk        = 1'b0; 
    mii_10M_rx_clk        = 1'b0; 
    xgmii_tx_clk          = 1'b0; 
    xgmii_rx_clk          = 1'b0;
    ptp_system_clk        = 1'b0;
    xlgmii_tx_clk         = 1'b0; 
    xlgmii_rx_clk         = 1'b0;
    xxgmii_tx_clk         = 1'b0;
    xxgmii_rx_clk         = 1'b0;
    tbi_tx_clk            = 1'b0; 
    serial_cd_tx_clk      = 1'b0;
    serial_cd_rx_clk      = 1'b0;
    cdmii_tx_clk          = 1'b0;
    cdmii_rx_clk          = 1'b0;
    ccmii_tx_clk          = 1'b0;
    ccmii_rx_clk          = 1'b0;
    cdxbi_tx_clk          = 1'b0;
    cdxbi_rx_clk          = 1'b0;
    serial_50g_tx_clk      = 1'b0;
    serial_50g_rx_clk      = 1'b0;
    tbi_rx_clk            = 1'b0; 
    rmii_tx_clk           = 1'b0;
    rmii_rx_clk           = 1'b0;
    gmii_rmii_tx_clk      = 1'b0; 
    gmii_rmii_rx_clk      = 1'b0; 
    xfbi_rx_clk           = 1'b0; 
    xfbi_tx_clk           = 1'b0; 
    xsbi_tx_clk           = 1'b0; 
    xsbi_rx_clk           = 1'b0; 
    gmii_mdc              = 1'b0; 
    serial_tx_baser_clk   = 1'b0; 
    serial_rx_baser_clk   = 1'b0;
    serial_tx_basex_clk   = 1'b0; 
    serial_rx_basex_clk   = 1'b0;
    serial_tx_base4x_clk  = 1'b0; 
    serial_rx_base4x_clk  = 1'b0; 
    vsbi_rx_clk           = 1'b0; 
    vsbi_tx_clk           = 1'b0; 
    cgmii_tx_clk          = 1'b0; 
    cgmii_rx_clk          = 1'b0; 
    clk_66t_tx            = 1'b0;
    clk_66t_rx            = 1'b0;
    clk_40t_tx            = 1'b0;
    clk_40t_rx            = 1'b0;
    caui_64b_clk_tx          = 1'b0;
    caui_64b_clk_rx          = 1'b0;
    mdio_clk              = 1'b0;
    qsgmii_sync_status    = 1'b0;
    qsgmii_sync_status_tx = 1'b0;
    qsgmii_sync_status_rx = 1'b0;
    lgmii_tx_clk = 1'b0;
    lgmii_rx_clk = 1'b0;
    xxvgmii_tx_clk = 1'b0;
    xxvgmii_rx_clk = 1'b0;
    lsbi_tx_clk  = 1'b0; 
    lsbi_rx_clk  = 1'b0; 
    xxvsbi_tx_clk  = 1'b0; 
    xxvsbi_rx_clk  = 1'b0;
    serial_12pt5g_clk_tx = 1'b0;
    serial_12pt5g_clk_rx = 1'b0;

end
 
/** Clock Generation. */
  always #`ETHERNET_XLGMII_CLOCK                      xlgmii_tx_clk        = ~xlgmii_tx_clk        ;
  always #`ETHERNET_XLGMII_CLOCK                      xlgmii_rx_clk        = ~xlgmii_rx_clk        ;
  always #`ETHERNET_XGMII_CLOCK                       xgmii_tx_clk         = ~xgmii_tx_clk         ; 
  always #`ETHERNET_XGMII_CLOCK                       xgmii_rx_clk         = ~xgmii_rx_clk         ;
  always #`ETHERNET_PTP_SYS_CLOCK 	                   ptp_system_clk       = ~ptp_system_clk       ; 
  always #`ETHERNET_XXGMII_CLOCK                      xxgmii_tx_clk        = ~xxgmii_tx_clk        ;
  always #`ETHERNET_XXGMII_CLOCK                      xxgmii_rx_clk        = ~xxgmii_rx_clk        ;
  always #`ETHERNET_FBI_CLOCK                         xfbi_tx_clk          = ~xfbi_tx_clk          ;
  always #`ETHERNET_FBI_CLOCK                         xfbi_rx_clk          = ~xfbi_rx_clk          ;
  always #`ETHERNET_XSBI_CLOCK                        xsbi_tx_clk          = ~xsbi_tx_clk          ;
  always #`ETHERNET_XSBI_CLOCK                        xsbi_rx_clk          = ~xsbi_rx_clk          ;
  always #`ETHERNET_GMII_CLOCK                        gmii_tx_clk          = ~gmii_tx_clk          ;
  always #`ETHERNET_GMII_CLOCK                        gmii_rx_clk          = ~gmii_rx_clk          ;
  always #`ETHERNET_GMII_CLOCK                        rgmii_tx_clk         = ~rgmii_tx_clk          ;
  always #`ETHERNET_GMII_CLOCK                        rgmii_rx_clk         = ~rgmii_rx_clk          ;
  always #`ETHERNET_25MHZ_CLOCK                       mii_100M_tx_clk      = ~mii_100M_tx_clk;
  always #`ETHERNET_25MHZ_CLOCK                       mii_100M_rx_clk      = ~mii_100M_rx_clk;
  always #`ETHERNET_2PT5_MHZ_CLOCK                    mii_10M_tx_clk       = ~mii_10M_tx_clk ;
  always #`ETHERNET_2PT5_MHZ_CLOCK                    mii_10M_rx_clk       = ~mii_10M_rx_clk ;
  always #`ETHERNET_TBI_CLOCK                         tbi_tx_clk           = ~tbi_tx_clk           ;
  always #`ETHERNET_TBI_CLOCK                         tbi_rx_clk           = ~tbi_rx_clk           ;
 // always T_ETHERNET_REFERENCE_CLOCK                   reference_clk        = ~reference_clk        ;
  always #`ETHERNET_SERIAL_CAUI_25G_CLOCK             serial_caui_25g_clk_tx = ~serial_caui_25g_clk_tx;
  always #`ETHERNET_SERIAL_CAUI_25G_CLOCK             serial_caui_25g_clk_rx = ~serial_caui_25g_clk_rx;
  always #`ETHERNET_KR4_FEC_66_CLOCK                  clk_66t_tx            = ~clk_66t_tx          ;
  always #`ETHERNET_KR4_FEC_66_CLOCK                  clk_66t_rx            = ~clk_66t_rx          ;
  always #`ETHERNET_KR4_FEC_40_CLOCK                  clk_40t_tx            = ~clk_40t_tx          ;
  always #`ETHERNET_KR4_FEC_40_CLOCK                  clk_40t_rx            = ~clk_40t_rx          ;
  always #`ETHERNET_SERIAL_BASER_CLOCK                serial_tx_baser_clk  = ~serial_tx_baser_clk  ;
  always #`ETHERNET_SERIAL_BASER_CLOCK                serial_rx_baser_clk  = ~serial_rx_baser_clk  ; 
  always #`ETHERNET_SERIAL_BASE4X_CLOCK               serial_tx_base4x_clk = ~serial_tx_base4x_clk ;
  always #`ETHERNET_SERIAL_BASE4X_CLOCK               serial_rx_base4x_clk = ~serial_rx_base4x_clk ; 
  always #`ETHERNET_SERIAL_BASEX_CLOCK                serial_tx_basex_clk  = ~serial_tx_basex_clk  ;
  always #`ETHERNET_SERIAL_BASEX_CLOCK                serial_rx_basex_clk  = ~serial_rx_basex_clk  ; 
  always #`ETHERNET_RMII_CLOCK                        rmii_tx_clk          = ~rmii_tx_clk          ;
  always #`ETHERNET_RMII_CLOCK                        rmii_rx_clk          = ~rmii_rx_clk          ;
  always #`ETHERNET_GMII_RMII_CLOCK                   gmii_rmii_rx_clk     = ~gmii_rmii_rx_clk     ;
  always #`ETHERNET_GMII_RMII_CLOCK                   gmii_rmii_tx_clk     = ~gmii_rmii_tx_clk     ;
  always #`ETHERNET_VSBI_CLOCK                        vsbi_tx_clk          = ~vsbi_tx_clk          ;
  always #`ETHERNET_VSBI_CLOCK                        vsbi_rx_clk          = ~vsbi_rx_clk          ;
  always #`ETHERNET_CGMII_CLOCK                       cgmii_tx_clk         = ~cgmii_tx_clk         ;
  always #`ETHERNET_CGMII_CLOCK                       cgmii_rx_clk         = ~cgmii_rx_clk         ;
  always #`ETHERNET_MDIO_CLOCK                        mdio_clk             = ~mdio_clk             ;
  always #`ETHERNET_CAUI_64B_PARALLEL_CLOCK           caui_64b_clk_tx         = !(caui_64b_clk_tx)       ;
  always #`ETHERNET_CAUI_64B_PARALLEL_CLOCK           caui_64b_clk_rx         = !(caui_64b_clk_rx)       ;
  always #`ETHERNET_XXVGMII_CLOCK                    xxvgmii_tx_clk        = ~xxvgmii_tx_clk;
  always #`ETHERNET_XXVGMII_CLOCK                    xxvgmii_rx_clk        = ~xxvgmii_rx_clk;
  always #`ETHERNET_LGMII_CLOCK                    lgmii_tx_clk            = ~lgmii_tx_clk;
  always #`ETHERNET_LGMII_CLOCK                    lgmii_rx_clk            = ~lgmii_rx_clk;
  always #`ETHERNET_XXVSBI_CLOCK                      xxvsbi_tx_clk        = ~xxvsbi_tx_clk;
  always #`ETHERNET_XXVSBI_CLOCK                      xxvsbi_rx_clk        = ~xxvsbi_rx_clk;
  always #`ETHERNET_LSBI_CLOCK                        lsbi_tx_clk          = ~lsbi_tx_clk;
  always #`ETHERNET_LSBI_CLOCK                        lsbi_rx_clk          = ~lsbi_rx_clk;
  always #`ETHERNET_SERIAL_12pt5G_CLOCK               serial_12pt5g_clk_tx = ~serial_12pt5g_clk_tx;
  always #`ETHERNET_SERIAL_12pt5G_CLOCK               serial_12pt5g_clk_rx = ~serial_12pt5g_clk_rx;
  always #`ETHERNET_SERIAL_CD_CLOCK                    serial_cd_tx_clk    = ~serial_cd_tx_clk; 
  always #`ETHERNET_SERIAL_CD_CLOCK                    serial_cd_rx_clk    = ~serial_cd_rx_clk; 
  always #`ETHERNET_SERIAL_50G_CLOCK                    serial_50g_tx_clk    = ~serial_50g_tx_clk; 
  always #`ETHERNET_SERIAL_50G_CLOCK                    serial_50g_rx_clk    = ~serial_50g_rx_clk; 
  always #`ETHERNET_CDMII_CLOCK        cdmii_tx_clk        = ~cdmii_tx_clk;
  always #`ETHERNET_CDMII_CLOCK        cdmii_rx_clk        = ~cdmii_rx_clk;
  always #`ETHERNET_CCMII_CLOCK        ccmii_tx_clk        = ~ccmii_tx_clk;
  always #`ETHERNET_CCMII_CLOCK        ccmii_rx_clk        = ~ccmii_rx_clk;
  always #`ETHERNET_CDXBI_CLOCK        cdxbi_tx_clk        = ~cdxbi_tx_clk;
  always #`ETHERNET_CDXBI_CLOCK        cdxbi_rx_clk        = ~cdxbi_rx_clk;
`ifndef INCLUDE_CVL
generate
for(i=0;i<8;i++) begin
  assign  mac_ethernet_if[i].cgmii_tx_clk          =  cgmii_tx_clk         ;
  assign  mac_ethernet_if[i].caui_64b_clk_rx          =  caui_64b_clk_rx         ;
  assign  mac_ethernet_if[i].caui_64b_clk_tx          =  caui_64b_clk_tx         ;
  assign  mac_ethernet_if[i].xgmii_tx_clk          =  xgmii_tx_clk         ; 
  assign  mac_ethernet_if[i].vsbi_rx_clk           =  vsbi_rx_clk          ;
  assign  mac_ethernet_if[i].rmii_tx_clk           =  rmii_tx_clk          ;
  assign  mac_ethernet_if[i].xlgmii_tx_clk         =  xlgmii_tx_clk        ;
  assign  mac_ethernet_if[i].serial_rx_basex_clk   =  serial_rx_basex_clk  ; 
  assign  mac_ethernet_if[i].gmii_tx_clk           =  gmii_tx_clk          ;
  //assign  mac_ethernet_i].reference_clk         =  reference_clk        ;
  assign  mac_ethernet_if[i].serial_caui_25g_clk_tx = serial_caui_25g_clk_tx;
  assign  mac_ethernet_if[i].serial_caui_25g_clk_rx = serial_caui_25g_clk_rx;
  assign  mac_ethernet_if[i].clk_66t_tx             = clk_66t_tx;
  assign  mac_ethernet_if[i].clk_66t_rx             = clk_66t_rx;
  assign  mac_ethernet_if[i].clk_40t_tx             = clk_40t_tx;
  assign  mac_ethernet_if[i].clk_40t_rx             = clk_40t_rx;
  assign  mac_ethernet_if[i].xgmii_rx_clk          =  xgmii_rx_clk         ;
  assign  mac_ethernet_if[i].cgmii_rx_clk          =  cgmii_rx_clk         ;
  assign  mac_ethernet_if[i].vsbi_tx_clk           =  vsbi_tx_clk          ;
  assign  mac_ethernet_if[i].xsbi_rx_clk           =  xsbi_rx_clk          ;
  assign  mac_ethernet_if[i].xsbi_tx_clk           =  xsbi_tx_clk          ;
  assign  mac_ethernet_if[i].serial_tx_basex_clk   =  serial_tx_basex_clk  ;
  assign  mac_ethernet_if[i].xlgmii_rx_clk         =  xlgmii_rx_clk        ;
  assign  mac_ethernet_if[i].gmii_rx_clk           =  gmii_rx_clk          ;
  assign  mac_ethernet_if[i].rgmii_tx_clk           =  rgmii_tx_clk          ;
  assign  mac_ethernet_if[i].rgmii_rx_clk           =  rgmii_rx_clk          ;
  assign  mac_ethernet_if[i].mii_100M_tx_clk       = mii_100M_tx_clk;
  assign  mac_ethernet_if[i].mii_100M_rx_clk       = mii_100M_rx_clk;
  assign  mac_ethernet_if[i].mii_10M_tx_clk        = mii_10M_tx_clk ;
  assign  mac_ethernet_if[i].mii_10M_rx_clk        = mii_10M_rx_clk ;
  assign  mac_ethernet_if[i].serial_rx_baser_clk   =  serial_rx_baser_clk  ; 
  assign  mac_ethernet_if[i].gmii_rmii_tx_clk      =  gmii_rmii_tx_clk     ;
  assign  mac_ethernet_if[i].serial_tx_base4x_clk  =  serial_tx_base4x_clk ;
  assign  mac_ethernet_if[i].mdio_clk              =  mdio_clk             ;
  assign  mac_ethernet_if[i].rmii_rx_clk           =  rmii_rx_clk          ;
  assign  mac_ethernet_if[i].serial_rx_base4x_clk  =  serial_rx_base4x_clk ; 
  assign  mac_ethernet_if[i].serial_tx_baser_clk   =  serial_tx_baser_clk  ;
  assign  mac_ethernet_if[i].xfbi_tx_clk           =  xfbi_tx_clk          ;
  assign  mac_ethernet_if[i].gmii_rmii_rx_clk      =  gmii_rmii_rx_clk     ;
  assign  mac_ethernet_if[i].xfbi_rx_clk           =  xfbi_rx_clk          ;
  assign  mac_ethernet_if[i].xxvsbi_tx_clk         =  xxvsbi_tx_clk        ;
  assign  mac_ethernet_if[i].xxvsbi_rx_clk         =  xxvsbi_rx_clk        ;
  assign  mac_ethernet_if[i].lsbi_tx_clk           =  lsbi_tx_clk          ;
  assign  mac_ethernet_if[i].lsbi_rx_clk           =  lsbi_rx_clk          ;
  assign  mac_ethernet_if[i].xxvgmii_tx_clk        =  xxvgmii_tx_clk       ;
  assign  mac_ethernet_if[i].xxvgmii_rx_clk        =  xxvgmii_rx_clk       ;
  assign  mac_ethernet_if[i].lgmii_tx_clk          =  lgmii_tx_clk         ;
  assign  mac_ethernet_if[i].lgmii_rx_clk          =  lgmii_rx_clk         ;
  assign  mac_ethernet_if[i].serial_12pt5g_clk_tx  = serial_12pt5g_clk_tx  ;
  assign  mac_ethernet_if[i].serial_12pt5g_clk_rx  = serial_12pt5g_clk_rx  ;
  assign  mac_ethernet_if[i].serial_cd_tx_clk      = serial_cd_tx_clk     ;
  assign  mac_ethernet_if[i].serial_cd_rx_clk      = serial_cd_rx_clk     ;
  assign  mac_ethernet_if[i].serial_50g_tx_clk     = serial_50g_tx_clk     ;
  assign  mac_ethernet_if[i].serial_50g_rx_clk     = serial_50g_rx_clk     ;
  assign  mac_ethernet_if[i].cdxbi_tx_clk          = cdxbi_tx_clk;
  assign  mac_ethernet_if[i].cdxbi_rx_clk          = cdxbi_rx_clk;
  assign  mac_ethernet_if[i].ccmii_tx_clk          = ccmii_tx_clk;
  assign  mac_ethernet_if[i].ccmii_rx_clk          = ccmii_rx_clk;
  assign  mac_ethernet_if[i].cdmii_tx_clk          = cdmii_tx_clk;
  assign  mac_ethernet_if[i].cdmii_rx_clk          = cdmii_rx_clk;
 end
endgenerate
`endif

`ifdef INCLUDE_CVL
 `ifdef n6000_10G
generate
for(i=0;i<8;i++) begin
  assign  mac_ethernet_if[i].cgmii_tx_clk          =  cgmii_tx_clk         ;
  assign  mac_ethernet_if[i].caui_64b_clk_rx          =  caui_64b_clk_rx         ;
  assign  mac_ethernet_if[i].caui_64b_clk_tx          =  caui_64b_clk_tx         ;
  assign  mac_ethernet_if[i].xgmii_tx_clk          =  xgmii_tx_clk         ; 
  assign  mac_ethernet_if[i].vsbi_rx_clk           =  vsbi_rx_clk          ;
  assign  mac_ethernet_if[i].rmii_tx_clk           =  rmii_tx_clk          ;
  assign  mac_ethernet_if[i].xlgmii_tx_clk         =  xlgmii_tx_clk        ;
  assign  mac_ethernet_if[i].serial_rx_basex_clk   =  serial_rx_basex_clk  ; 
  assign  mac_ethernet_if[i].gmii_tx_clk           =  gmii_tx_clk          ;
  //assign  mac_ethernet_i].reference_clk         =  reference_clk        ;
  assign  mac_ethernet_if[i].serial_caui_25g_clk_tx = serial_caui_25g_clk_tx;
  assign  mac_ethernet_if[i].serial_caui_25g_clk_rx = serial_caui_25g_clk_rx;
  assign  mac_ethernet_if[i].clk_66t_tx             = clk_66t_tx;
  assign  mac_ethernet_if[i].clk_66t_rx             = clk_66t_rx;
  assign  mac_ethernet_if[i].clk_40t_tx             = clk_40t_tx;
  assign  mac_ethernet_if[i].clk_40t_rx             = clk_40t_rx;
  assign  mac_ethernet_if[i].xgmii_rx_clk          =  xgmii_rx_clk         ;
  assign  mac_ethernet_if[i].cgmii_rx_clk          =  cgmii_rx_clk         ;
  assign  mac_ethernet_if[i].vsbi_tx_clk           =  vsbi_tx_clk          ;
  assign  mac_ethernet_if[i].xsbi_rx_clk           =  xsbi_rx_clk          ;
  assign  mac_ethernet_if[i].xsbi_tx_clk           =  xsbi_tx_clk          ;
  assign  mac_ethernet_if[i].serial_tx_basex_clk   =  serial_tx_basex_clk  ;
  assign  mac_ethernet_if[i].xlgmii_rx_clk         =  xlgmii_rx_clk        ;
  assign  mac_ethernet_if[i].gmii_rx_clk           =  gmii_rx_clk          ;
  assign  mac_ethernet_if[i].rgmii_tx_clk           =  rgmii_tx_clk          ;
  assign  mac_ethernet_if[i].rgmii_rx_clk           =  rgmii_rx_clk          ;
  assign  mac_ethernet_if[i].mii_100M_tx_clk       = mii_100M_tx_clk;
  assign  mac_ethernet_if[i].mii_100M_rx_clk       = mii_100M_rx_clk;
  assign  mac_ethernet_if[i].mii_10M_tx_clk        = mii_10M_tx_clk ;
  assign  mac_ethernet_if[i].mii_10M_rx_clk        = mii_10M_rx_clk ;
  assign  mac_ethernet_if[i].serial_rx_baser_clk   =  serial_rx_baser_clk  ; 
  assign  mac_ethernet_if[i].gmii_rmii_tx_clk      =  gmii_rmii_tx_clk     ;
  assign  mac_ethernet_if[i].serial_tx_base4x_clk  =  serial_tx_base4x_clk ;
  assign  mac_ethernet_if[i].mdio_clk              =  mdio_clk             ;
  assign  mac_ethernet_if[i].rmii_rx_clk           =  rmii_rx_clk          ;
  assign  mac_ethernet_if[i].serial_rx_base4x_clk  =  serial_rx_base4x_clk ; 
  assign  mac_ethernet_if[i].serial_tx_baser_clk   =  serial_tx_baser_clk  ;
  assign  mac_ethernet_if[i].xfbi_tx_clk           =  xfbi_tx_clk          ;
  assign  mac_ethernet_if[i].gmii_rmii_rx_clk      =  gmii_rmii_rx_clk     ;
  assign  mac_ethernet_if[i].xfbi_rx_clk           =  xfbi_rx_clk          ;
  assign  mac_ethernet_if[i].xxvsbi_tx_clk         =  xxvsbi_tx_clk        ;
  assign  mac_ethernet_if[i].xxvsbi_rx_clk         =  xxvsbi_rx_clk        ;
  assign  mac_ethernet_if[i].lsbi_tx_clk           =  lsbi_tx_clk          ;
  assign  mac_ethernet_if[i].lsbi_rx_clk           =  lsbi_rx_clk          ;
  assign  mac_ethernet_if[i].xxvgmii_tx_clk        =  xxvgmii_tx_clk       ;
  assign  mac_ethernet_if[i].xxvgmii_rx_clk        =  xxvgmii_rx_clk       ;
  assign  mac_ethernet_if[i].lgmii_tx_clk          =  lgmii_tx_clk         ;
  assign  mac_ethernet_if[i].lgmii_rx_clk          =  lgmii_rx_clk         ;
  assign  mac_ethernet_if[i].serial_12pt5g_clk_tx  = serial_12pt5g_clk_tx  ;
  assign  mac_ethernet_if[i].serial_12pt5g_clk_rx  = serial_12pt5g_clk_rx  ;
  assign  mac_ethernet_if[i].serial_cd_tx_clk      = serial_cd_tx_clk     ;
  assign  mac_ethernet_if[i].serial_cd_rx_clk      = serial_cd_rx_clk     ;
  assign  mac_ethernet_if[i].serial_50g_tx_clk     = serial_50g_tx_clk     ;
  assign  mac_ethernet_if[i].serial_50g_rx_clk     = serial_50g_rx_clk     ;
  assign  mac_ethernet_if[i].cdxbi_tx_clk          = cdxbi_tx_clk;
  assign  mac_ethernet_if[i].cdxbi_rx_clk          = cdxbi_rx_clk;
  assign  mac_ethernet_if[i].ccmii_tx_clk          = ccmii_tx_clk;
  assign  mac_ethernet_if[i].ccmii_rx_clk          = ccmii_rx_clk;
  assign  mac_ethernet_if[i].cdmii_tx_clk          = cdmii_tx_clk;
  assign  mac_ethernet_if[i].cdmii_rx_clk          = cdmii_rx_clk;
 end
endgenerate
 `endif

 `ifndef n6000_10G
 `ifndef FIM_B   
generate
 for(i=0;i<`ETH_INST;i++) begin

  assign  mac_ethernet_if[i].cgmii_tx_clk          =  cgmii_tx_clk         ;
  assign  mac_ethernet_if[i].caui_64b_clk_rx          =  caui_64b_clk_rx         ;
  assign  mac_ethernet_if[i].caui_64b_clk_tx          =  caui_64b_clk_tx         ;
  assign  mac_ethernet_if[i].xgmii_tx_clk          =  xgmii_tx_clk         ; 
  assign  mac_ethernet_if[i].vsbi_rx_clk           =  vsbi_rx_clk          ;
  assign  mac_ethernet_if[i].rmii_tx_clk           =  rmii_tx_clk          ;
  assign  mac_ethernet_if[i].xlgmii_tx_clk         =  xlgmii_tx_clk        ;
  assign  mac_ethernet_if[i].serial_rx_basex_clk   =  serial_rx_basex_clk  ; 
  assign  mac_ethernet_if[i].gmii_tx_clk           =  gmii_tx_clk          ;
  //assign  mac_ethernet_[i]i].reference_clk         =  reference_clk        ;
  assign  mac_ethernet_if[i].serial_caui_25g_clk_tx = serial_caui_25g_clk_tx;
  assign  mac_ethernet_if[i].serial_caui_25g_clk_rx = serial_caui_25g_clk_rx;
  assign  mac_ethernet_if[i].clk_66t_tx             = clk_66t_tx;
  assign  mac_ethernet_if[i].clk_66t_rx             = clk_66t_rx;
  assign  mac_ethernet_if[i].clk_40t_tx             = clk_40t_tx;
  assign  mac_ethernet_if[i].clk_40t_rx             = clk_40t_rx;
  assign  mac_ethernet_if[i].xgmii_rx_clk          =  xgmii_rx_clk         ;
  assign  mac_ethernet_if[i].cgmii_rx_clk          =  cgmii_rx_clk         ;
  assign  mac_ethernet_if[i].vsbi_tx_clk           =  vsbi_tx_clk          ;
  assign  mac_ethernet_if[i].xsbi_rx_clk           =  xsbi_rx_clk          ;
  assign  mac_ethernet_if[i].xsbi_tx_clk           =  xsbi_tx_clk          ;
  assign  mac_ethernet_if[i].serial_tx_basex_clk   =  serial_tx_basex_clk  ;
  assign  mac_ethernet_if[i].xlgmii_rx_clk         =  xlgmii_rx_clk        ;
  assign  mac_ethernet_if[i].gmii_rx_clk           =  gmii_rx_clk          ;
  assign  mac_ethernet_if[i].rgmii_tx_clk           =  rgmii_tx_clk          ;
  assign  mac_ethernet_if[i].rgmii_rx_clk           =  rgmii_rx_clk          ;
  assign  mac_ethernet_if[i].mii_100M_tx_clk       = mii_100M_tx_clk;
  assign  mac_ethernet_if[i].mii_100M_rx_clk       = mii_100M_rx_clk;
  assign  mac_ethernet_if[i].mii_10M_tx_clk        = mii_10M_tx_clk ;
  assign  mac_ethernet_if[i].mii_10M_rx_clk        = mii_10M_rx_clk ;
  assign  mac_ethernet_if[i].serial_rx_baser_clk   =  serial_rx_baser_clk  ; 
  assign  mac_ethernet_if[i].gmii_rmii_tx_clk      =  gmii_rmii_tx_clk     ;
  assign  mac_ethernet_if[i].serial_tx_base4x_clk  =  serial_tx_base4x_clk ;
  assign  mac_ethernet_if[i].mdio_clk              =  mdio_clk             ;
  assign  mac_ethernet_if[i].rmii_rx_clk           =  rmii_rx_clk          ;
  assign  mac_ethernet_if[i].serial_rx_base4x_clk  =  serial_rx_base4x_clk ; 
  assign  mac_ethernet_if[i].serial_tx_baser_clk   =  serial_tx_baser_clk  ;
  assign  mac_ethernet_if[i].xfbi_tx_clk           =  xfbi_tx_clk          ;
  assign  mac_ethernet_if[i].gmii_rmii_rx_clk      =  gmii_rmii_rx_clk     ;
  assign  mac_ethernet_if[i].xfbi_rx_clk           =  xfbi_rx_clk          ;
  assign  mac_ethernet_if[i].xxvsbi_tx_clk         =  xxvsbi_tx_clk        ;
  assign  mac_ethernet_if[i].xxvsbi_rx_clk         =  xxvsbi_rx_clk        ;
  assign  mac_ethernet_if[i].lsbi_tx_clk           =  lsbi_tx_clk          ;
  assign  mac_ethernet_if[i].lsbi_rx_clk           =  lsbi_rx_clk          ;
  assign  mac_ethernet_if[i].xxvgmii_tx_clk        =  xxvgmii_tx_clk       ;
  assign  mac_ethernet_if[i].xxvgmii_rx_clk        =  xxvgmii_rx_clk       ;
  assign  mac_ethernet_if[i].lgmii_tx_clk          =  lgmii_tx_clk         ;
  assign  mac_ethernet_if[i].lgmii_rx_clk          =  lgmii_rx_clk         ;
  assign  mac_ethernet_if[i].serial_12pt5g_clk_tx  = serial_12pt5g_clk_tx  ;
  assign  mac_ethernet_if[i].serial_12pt5g_clk_rx  = serial_12pt5g_clk_rx  ;
  assign  mac_ethernet_if[i].serial_cd_tx_clk      = serial_cd_tx_clk     ;
  assign  mac_ethernet_if[i].serial_cd_rx_clk      = serial_cd_rx_clk     ;
  assign  mac_ethernet_if[i].serial_50g_tx_clk     = serial_50g_tx_clk     ;
  assign  mac_ethernet_if[i].serial_50g_rx_clk     = serial_50g_rx_clk     ;
  assign  mac_ethernet_if[i].cdxbi_tx_clk          = cdxbi_tx_clk;
  assign  mac_ethernet_if[i].cdxbi_rx_clk          = cdxbi_rx_clk;
  assign  mac_ethernet_if[i].ccmii_tx_clk          = ccmii_tx_clk;
  assign  mac_ethernet_if[i].ccmii_rx_clk          = ccmii_rx_clk;
  assign  mac_ethernet_if[i].cdmii_tx_clk          = cdmii_tx_clk;
  assign  mac_ethernet_if[i].cdmii_rx_clk          = cdmii_rx_clk;
end
endgenerate
 `endif //  `ifndef FIM_B
 `endif //  `ifndef n6000_10G
   

 `ifdef FIM_B
generate
for(i=0;i<8;i++) begin
  assign  mac_ethernet_if[i].cgmii_tx_clk          =  cgmii_tx_clk         ;
  assign  mac_ethernet_if[i].caui_64b_clk_rx          =  caui_64b_clk_rx         ;
  assign  mac_ethernet_if[i].caui_64b_clk_tx          =  caui_64b_clk_tx         ;
  assign  mac_ethernet_if[i].xgmii_tx_clk          =  xgmii_tx_clk         ; 
  assign  mac_ethernet_if[i].vsbi_rx_clk           =  vsbi_rx_clk          ;
  assign  mac_ethernet_if[i].rmii_tx_clk           =  rmii_tx_clk          ;
  assign  mac_ethernet_if[i].xlgmii_tx_clk         =  xlgmii_tx_clk        ;
  assign  mac_ethernet_if[i].serial_rx_basex_clk   =  serial_rx_basex_clk  ; 
  assign  mac_ethernet_if[i].gmii_tx_clk           =  gmii_tx_clk          ;
  //assign  mac_ethernet_i].reference_clk         =  reference_clk        ;
  assign  mac_ethernet_if[i].serial_caui_25g_clk_tx = serial_caui_25g_clk_tx;
  assign  mac_ethernet_if[i].serial_caui_25g_clk_rx = serial_caui_25g_clk_rx;
  assign  mac_ethernet_if[i].clk_66t_tx             = clk_66t_tx;
  assign  mac_ethernet_if[i].clk_66t_rx             = clk_66t_rx;
  assign  mac_ethernet_if[i].clk_40t_tx             = clk_40t_tx;
  assign  mac_ethernet_if[i].clk_40t_rx             = clk_40t_rx;
  assign  mac_ethernet_if[i].xgmii_rx_clk          =  xgmii_rx_clk         ;
  assign  mac_ethernet_if[i].cgmii_rx_clk          =  cgmii_rx_clk         ;
  assign  mac_ethernet_if[i].vsbi_tx_clk           =  vsbi_tx_clk          ;
  assign  mac_ethernet_if[i].xsbi_rx_clk           =  xsbi_rx_clk          ;
  assign  mac_ethernet_if[i].xsbi_tx_clk           =  xsbi_tx_clk          ;
  assign  mac_ethernet_if[i].serial_tx_basex_clk   =  serial_tx_basex_clk  ;
  assign  mac_ethernet_if[i].xlgmii_rx_clk         =  xlgmii_rx_clk        ;
  assign  mac_ethernet_if[i].gmii_rx_clk           =  gmii_rx_clk          ;
  assign  mac_ethernet_if[i].rgmii_tx_clk           =  rgmii_tx_clk          ;
  assign  mac_ethernet_if[i].rgmii_rx_clk           =  rgmii_rx_clk          ;
  assign  mac_ethernet_if[i].mii_100M_tx_clk       = mii_100M_tx_clk;
  assign  mac_ethernet_if[i].mii_100M_rx_clk       = mii_100M_rx_clk;
  assign  mac_ethernet_if[i].mii_10M_tx_clk        = mii_10M_tx_clk ;
  assign  mac_ethernet_if[i].mii_10M_rx_clk        = mii_10M_rx_clk ;
  assign  mac_ethernet_if[i].serial_rx_baser_clk   =  serial_rx_baser_clk  ; 
  assign  mac_ethernet_if[i].gmii_rmii_tx_clk      =  gmii_rmii_tx_clk     ;
  assign  mac_ethernet_if[i].serial_tx_base4x_clk  =  serial_tx_base4x_clk ;
  assign  mac_ethernet_if[i].mdio_clk              =  mdio_clk             ;
  assign  mac_ethernet_if[i].rmii_rx_clk           =  rmii_rx_clk          ;
  assign  mac_ethernet_if[i].serial_rx_base4x_clk  =  serial_rx_base4x_clk ; 
  assign  mac_ethernet_if[i].serial_tx_baser_clk   =  serial_tx_baser_clk  ;
  assign  mac_ethernet_if[i].xfbi_tx_clk           =  xfbi_tx_clk          ;
  assign  mac_ethernet_if[i].gmii_rmii_rx_clk      =  gmii_rmii_rx_clk     ;
  assign  mac_ethernet_if[i].xfbi_rx_clk           =  xfbi_rx_clk          ;
  assign  mac_ethernet_if[i].xxvsbi_tx_clk         =  xxvsbi_tx_clk        ;
  assign  mac_ethernet_if[i].xxvsbi_rx_clk         =  xxvsbi_rx_clk        ;
  assign  mac_ethernet_if[i].lsbi_tx_clk           =  lsbi_tx_clk          ;
  assign  mac_ethernet_if[i].lsbi_rx_clk           =  lsbi_rx_clk          ;
  assign  mac_ethernet_if[i].xxvgmii_tx_clk        =  xxvgmii_tx_clk       ;
  assign  mac_ethernet_if[i].xxvgmii_rx_clk        =  xxvgmii_rx_clk       ;
  assign  mac_ethernet_if[i].lgmii_tx_clk          =  lgmii_tx_clk         ;
  assign  mac_ethernet_if[i].lgmii_rx_clk          =  lgmii_rx_clk         ;
  assign  mac_ethernet_if[i].serial_12pt5g_clk_tx  = serial_12pt5g_clk_tx  ;
  assign  mac_ethernet_if[i].serial_12pt5g_clk_rx  = serial_12pt5g_clk_rx  ;
  assign  mac_ethernet_if[i].serial_cd_tx_clk      = serial_cd_tx_clk     ;
  assign  mac_ethernet_if[i].serial_cd_rx_clk      = serial_cd_rx_clk     ;
  assign  mac_ethernet_if[i].serial_50g_tx_clk     = serial_50g_tx_clk     ;
  assign  mac_ethernet_if[i].serial_50g_rx_clk     = serial_50g_rx_clk     ;
  assign  mac_ethernet_if[i].cdxbi_tx_clk          = cdxbi_tx_clk;
  assign  mac_ethernet_if[i].cdxbi_rx_clk          = cdxbi_rx_clk;
  assign  mac_ethernet_if[i].ccmii_tx_clk          = ccmii_tx_clk;
  assign  mac_ethernet_if[i].ccmii_rx_clk          = ccmii_rx_clk;
  assign  mac_ethernet_if[i].cdmii_tx_clk          = cdmii_tx_clk;
  assign  mac_ethernet_if[i].cdmii_rx_clk          = cdmii_rx_clk;
 end
endgenerate
 `endif //  `ifdef FIM_B
   
`endif //  `ifdef INCLUDE_CVL
   
