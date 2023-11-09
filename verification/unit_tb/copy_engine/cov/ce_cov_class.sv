// Copyright (C) 2021 Intel Corporation
// SPDX-License-Identifier: MIT


`ifndef COVERAGE_SVH
`define COVERAGE_SVH

class ce_coverage extends uvm_component;
`uvm_component_utils(ce_coverage)
virtual coverage_intf cov_intf;

typedef enum int {cache_1=0,cache_2=1,cache_4=2}cache;
typedef enum int {loop=0,read=1,write=2,through=3}tes_mode;
typedef enum int {success=0,unsuprd_req=1,rsvd=2,abort=3}status_compl;
typedef enum int {RdwRRdWr=0,Rd2Wr2=1,Rd4Wr4=2}tput;
 cache REQ_LEN;
 tes_mode TEST_MODE;
 status_compl STAT_COMPL;
 tput TPUT;
//**************************************************RX_COVERGROUP_START*******************************************  
// PCIESS to AFU
 //covergroup RX_CHECK ;
 

 covergroup AXI_ST_RX ;
     // RX_PU_length   : coverpoint cov_intf.rx_length_pu{bins len_pu[]={[1:2]};}
      RX_Bar_num     : coverpoint cov_intf.rx_bar_num{bins bar={0};}
     
 //R1
/*`ifdef ENABLE_R1_COVERAGE

      RX_R1_PF_num       : coverpoint cov_intf.rx_pf_num{bins R1_pf={0};} 
      RX_R1_VF_num       : coverpoint cov_intf.rx_vf_num {bins R1_vf[]={0,1,2};} 
      RX_R1_Host_Address : coverpoint cov_intf.rx_host_addr_h{bins FME ={[32'hab000000:32'hab00a008]};
                                                              bins PMCI = {[32'hab010000:32'hab01002c]};
                                                              bins HE_HSSI = {[32'hab1c0000:32'hab1c4048]}; 
                                                              bins SS_HSSI = {32'hab030000,32'hab030028,32'hab03002c,32'hab030034,32'hab030038,32'hab03003c};
                                                              bins ST2MM = {32'hab080000,32'hab080008,32'hab08000c};
                                                              bins PRGAS = {32'hab090000,32'hab090008,32'hab09000c};  
                                                              bins HE_LBK = {[32'hab140000:32'hab140140],[32'hab140141:32'hab140f00],[32'hab140f01:32'hab140ff8]}; 
                                                              bins HE_MEM = {[32'hab180000:32'hab180178]};}
     `endif  */                                                 
      
//AC
  // `ifdef ENABLE_AC_COVERAGE 
   //   RX_MM_mode        : coverpoint cov_intf.rx_MM_mode{bins MM_mode={0};} 
   //   RX_SLOT_num       : coverpoint cov_intf.rx_slot_num{bins slot_num={0};}
      RX_AC_PF_num      : coverpoint cov_intf.rx_pf_num {bins AC_pf={4};} 
     // RX_AC_VF_num      : coverpoint cov_intf.rx_vf_num{bins AC_vf[]={0,1,2};}
	 // RX_AC_VF_active   : coverpoint cov_intf.rx_vf_active {bins AC_vf_active[]={1};}
    /*  RX_AC_PF_VF_num   : cross    RX_AC_PF_num,RX_AC_VF_num,RX_AC_VF_active,RX_Bar_num{bins APF       = binsof(RX_AC_PF_num)intersect{0} && binsof(RX_Bar_num)intersect{0};
                                                                                        bins PRGAS     = binsof(RX_AC_PF_num)intersect{1} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1};
                                                                                        bins HE_LBK    = binsof(RX_AC_PF_num)intersect{2} && binsof(RX_Bar_num)intersect{0};
                                                                                        bins HE_MEM    = binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1};
                                                                                        bins HE_HSSI   = binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{1} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1};
                                                                                        bins HE_MEM_TG = binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1};
                                                                                        bins virtio_lbk  = binsof(RX_AC_PF_num)intersect{3} && binsof(RX_Bar_num)intersect{0};
                                                                                        bins copy_engine = binsof(RX_AC_PF_num)intersect{4} && binsof(RX_Bar_num)intersect{0};     
                                                                                       } */
      RX_AC_Host_Address: coverpoint cov_intf.rx_host_addr_h {/*bins HE_LBK ={[32'hc000_0000:32'hc000_0020],[32'hc000_0100:32'hc000_0178]};
                                                              bins HE_LBK_unused_space={[32'hc000_0028:32'hc000_0098],[32'hc000_0180:32'hc000_ffff]};*/
                                                              bins copy_engine ={[32'he000_0000:32'he000_0020],[32'he000_0100:32'he000_0158]};
                                                             // bins copy_engine_unused_space ={[32'he000_0028:32'he000_0098],[32'he000_0160:32'he000_0fff]};
                                                            /*  bins qsfp_controller ={[32'h80012000:32'h80012040]};
                                                              bins qsfp_controller_unused_space={[32'h80012048:32'h80012fff]};
                                                              bins ST2MM={[32'h80040000:32'h80040008]};
                                                              bins ST2MM_unused_space={[32'h80040010:32'h8004ffff]}; 
                                                              bins HE_MEM ={[32'h9000_0000:32'h9000_0020],[32'h9000_0100:32'h9000_0178]};
                                                              bins HE_MEM_unused_space={[32'h9000_0028:32'h9000_0098],[32'h9000_0180:32'h9000_ffff]};
                                                              bins HE_HSSI ={[32'h90160000:32'h90160040]};
                                                              bins HE_HSSI_unused_space ={[32'h90160042:32'h9016ffff]};
                                                              bins HSSI_SS ={[32'h8006_0000:32'h8006_00a4],[32'h8006_0800:32'h8006_0828 ]};
                                                              bins HSSI_SS_unused_space ={[32'h8006_00ac:32'h8006_0800],[32'h80060830:32'h8006ffff]};
                                                              bins PMCI ={[32'h8001_0000:32'h8001_0048],[32'h8001_0400:32'h8001_2008]};
                                                              bins PMCI_unused_space ={[32'h8001_0050:32'h8001_0398],[32'h8001_2010:32'h8001_1fff]};
                                                              bins PCIE ={[32'h8001_0000:32'h8001_0030]};
                                                              bins PCIE_unused_space ={[32'h8001_0038:32'h8001_0fff]};
                                                              bins FME ={[32'h8000_0000:32'h8000_0068],[32'h8000_1000:32'h8000_4070]}; 
                                                              bins FME_unused_space ={[32'h8000_0070:32'h8000_0998],[32'h80004072:32'h8000ffff]};
                                                              bins PORT_GASKET={[32'h8007_0000:32'h8007_00b8],[32'h8007_1000:32'h8007_3008]};
                                                              bins PORT_GASKET_unused_space={[32'h8007_00c0:32'h8007_0998],[32'h8007_1008:32'h8007_ffff]};*/
                                                             }

   /*  RX_Ac_Host_Address_64 : coverpoint cov_intf.rx_host_addr_64{//bins HE_LBK_64 ={[64'hc000_0000_0000_0000:64'hc000_0000_0000_0020],[64'hc000_0000_0000_0100:64'hc000_0000_0000_178]}; 
                                                                 //bins HE_MEM_64 ={[64'h9000_0000_0000_0000:64'h9000_0000_0000_0020],[64'h9000_0000_0000_0100:64'h9000_0000_0000_178]};
                                                                 //bins qsfp_controller_64 ={[64'h8000_0000_0001_2000:64'h8000_0000_0001_2040]};
                                                                 //bins HE_LBK_unused_space_64={[64'hc000_0000_0028:64'hc000_0000_0000_0098],[64'hc000_0000_0000_0180:64'hc000_0000_0000_ffff]};
                                                                 bins copy_engine_64 ={[64'he000_0000_0000_0000:64'he000_0000_0000_0020],[64'he000_0000_0000_0100:64'he000_0000_0000_0158]};
                                                                 //bins qsfp_controller_unused_space_64={[64'h8000000000012048:64'h8000000000012fff]};
                                                                 //bins ST2MM_unused_space_64={[64'h8000000000040010:64'h800000000004ffff]}; 
                                                                 //bins HE_MEM_unused_space_64={[64'h9000_0000_0028:64'h9000_0000_0000_0098],[64'h9000_0000_0000_0180:64'h9000_0000_0000_ffff]};
                                                                 //bins HE_HSSI_unused_space_64 ={[64'h9000000000160042:64'h900000000016ffff]};
                                                                 //bins HSSI_SS_unused_space_64 ={[64'h8000_0000_0006_00ac:64'h8000_0000_0006_0800],[64'h8000_0000_0006_0830:64'h8000_0000_0006_ffff]};
                                                                 //bins PMCI ={[64'h8000_0000_0001_0000:64'h8000_0000_0001_0048],[64'h8000_0000_0001_0400:64'h8000_0000_0001_2008]};
                                                                 //bins PMCI_unused_space_64 ={[64'h8000_0000_0001_0802:64'h8000_0000_0001_1fff]};
                                                                 //bins PCIE ={[64'h8000_0000_0001_0000:64'h8000_0000_0001_0030]};
                                                                 //bins PCIE_unused_space ={[64'h8000_0000_0001_0038:64'h8000_0000_0001_0fff]};
                                                                 //bins FME_unused_space_64 ={[64'h8000_0000_0000_0070:64'h8000_0000_0000_0998],[64'h8000_0000_0000_4072:64'h8000_0000_0000_ffff]};
                                                                 //bins PORT_GASKET_unused_space_64={[64'h8000_0000_0007_0000:64'h8000_0000_0007_00b8],[64'h8000_0000_0007_1000:64'h8000_0000_0007_3008]};
                                                                 //bins PORT_GASKET_unused_space={[64'h8000_0000_0007_00c0:64'h8000_0000_0007_0998],[64'h8000_0000_0007_1008:64'h8000_0000_0007_ffff]};
                                                             } */
     
     RX_format_type        : coverpoint cov_intf.rx_fmt_type{bins format_type[]={0,64};
                                                           ignore_bins rx_format_type_igno={[1:31],32,[33:63],[65:95],96,[97:112],113,114,115,[116:255]};}  

     RX_Address_fmt_type   : cross  RX_AC_PF_num,RX_Bar_num,RX_format_type{
                                                              //    bins b1 =binsof(RX_AC_PF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{0};
                                                              //    bins b2 =binsof(RX_AC_PF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{32};
                                                              //    bins b3 =binsof(RX_AC_PF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{64};
                                                              //    bins b4 =binsof(RX_AC_PF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{96};
                                                               //   bins b5 =binsof(RX_AC_PF_num)intersect{1} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{0};
                                                               //   bins b6 =binsof(RX_AC_PF_num)intersect{1} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{32};
                                                               //   bins b7 =binsof(RX_AC_PF_num)intersect{1} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{64};
                                                              //    bins b8 =binsof(RX_AC_PF_num)intersect{1} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{96};
                                                              //    bins b9 =binsof(RX_AC_PF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{0};
                                                              //    bins b10=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{32};
                                                               //   bins b11=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{64};
                                                               //   bins b12=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{96};
                                                               //   bins b13=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{0};
                                                               //   bins b14=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{32};
                                                               //   bins b15=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{64};
                                                               //   bins b16=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{0} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{96};
                                                               //   bins b17=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{1} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{0};
                                                               //   bins b18=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{1} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{32};
                                                               //   bins b19=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{1} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{64};
                                                               //   bins b20=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{1} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{96};
                                                               //   bins b21=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{0};
                                                               //   bins b22=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{32};
                                                               //   bins b23=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{64};
                                                              //    bins b24=binsof(RX_AC_PF_num)intersect{2} && binsof(RX_AC_VF_num)intersect{2} && binsof(RX_Bar_num)intersect{0} && binsof(RX_AC_VF_active)intersect{1} && binsof(RX_format_type)intersect{96};
                                                              //    bins b25=binsof(RX_AC_PF_num)intersect{3} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{0};
                                                              //    bins b26=binsof(RX_AC_PF_num)intersect{3} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{32};
                                                              //    bins b27=binsof(RX_AC_PF_num)intersect{3} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{64};
                                                              //    bins b28=binsof(RX_AC_PF_num)intersect{3} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{96};
                                                                  bins b29=binsof(RX_AC_PF_num)intersect{4} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{0};
                                                                  //bins b30=binsof(RX_AC_PF_num)intersect{4} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{32};
                                                                  bins b31=binsof(RX_AC_PF_num)intersect{4} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{64};
                                                                  //bins b32=binsof(RX_AC_PF_num)intersect{4} && binsof(RX_Bar_num)intersect{0} && binsof(RX_format_type)intersect{96};
                                                                }                                                       
 //`endif
    
    
      RX_PU_mode     : coverpoint cov_intf.rx_tuser[0]{bins PU_mode={0};}
  
endgroup
 covergroup AXI_RX_COMPL;
    //RX_PU_cmpl_len  : coverpoint cov_intf.rx_cmpl_len_pu{bins len_pu[]={[1:2]};}
    RX_compl_status : coverpoint cov_intf.dmrx_cmpl_status{bins cmp_stat[]={[STAT_COMPL.first:STAT_COMPL.last]};
                                                          ignore_bins rx_compl_status_igno = {2,3};}
    RX_compl_type   : coverpoint cov_intf.dmrx_cmpl_type{bins cmp_typ[]={74}; //4A->74,0A->10,2A->42  
	                    ignore_bins rx_type_igno = {[0:10],[11:41],[43:73],[75:255]};}
    
    RX_DM_cmpl_len  : coverpoint cov_intf.dmrx_cmpl_len_dm iff(cov_intf.dmrx_tuser[0]==1){bins oneKB={[14'h1:14'h3FF]};}
   // RX_DM_cmpl_tag  : coverpoint cov_intf.rx_cmpl_tag_dm iff(cov_intf.rx_tuser[0]==1){bins onek={[10'h0:10'h3FF]};}

endgroup



//**************************************************TX_COVERGROUP_START*******************************************
// AFU -> PCIESS
  covergroup AXI_ST_TX ;
     // TX_PU_length   : coverpoint cov_intf.tx_length_pu{bins len_pu[]={[1:2]};} 
      TX_Bar_num     : coverpoint cov_intf.tx_bar_num{bins bar={0};}
     

            
//AC
  // `ifdef ENABLE_AC_COVERAGE  
      TX_AC_PF_num      : coverpoint cov_intf.tx_pf_num {bins AC_pf={4};} 
    //  TX_AC_VF_num      : coverpoint cov_intf.tx_vf_num{bins AC_vf[]={0,1,2};}
    //  TX_AC_VF_active   : coverpoint cov_intf.tx_vf_active {bins AC_vf_active[]={1};} 
    
	 
   //`else
   //   TX_R1_PF_num      : coverpoint cov_intf.tx_pf_num{bins R1_pf={0};} 
   //   TX_R1_VF_num      : coverpoint cov_intf.tx_vf_num {bins R1_vf[]={0,1};}



// `endif

      
     
      TX_DM_length   : coverpoint cov_intf.tx_length_dm iff(cov_intf.tx_tuser[0]==1){bins onetwentyeightB={[24'h40:24'h7F]};
                                                                                     bins twofiftysixB={[24'h80:24'hFF]};}


    
     //   TX_Host_Address: coverpoint cov_intf.tx_host_addr_h{ bins addr={[32'h0:32'hFFFFFF]};}
        
      // `ifdef ENABLE_AC_COVERAGE
       /* TX_DM_tag     : coverpoint cov_intf.tx_tag_dm iff(cov_intf.tx_tuser[0]==1){bins eightbittag={[10'h0:10'h0FF]};
                                                                                    bins tenbittag={[10'h100:10'h3FF]}; }*/
        TX_format_type: coverpoint cov_intf.tx_fmt_type{bins format_type[]={32}; 
                                          ignore_bins tx_format_type_igno={[0:31],[33:47],48,[49:95],96,[97:111],112,113,114,[115:255]};}
      /*  TX_vector_num : coverpoint cov_intf.tx_vector_num{bins user_vector_num[]={0,1,2,3};
                                                          bins fme_vector_num[]={6};
                                           ignore_bins tx_vector_num_igno={[4:5],[7:255],[256:65535]};}*/
      /*  TX_vector_num_fmt_type: cross TX_vector_num,TX_format_type{bins v0= binsof(TX_vector_num)intersect{0} && binsof(TX_format_type)intersect{48};
                                                                   bins v1= binsof(TX_vector_num)intersect{1} && binsof(TX_format_type)intersect{48};
                                                                   bins v2= binsof(TX_vector_num)intersect{2} && binsof(TX_format_type)intersect{48};
                                                                   bins v3= binsof(TX_vector_num)intersect{3} && binsof(TX_format_type)intersect{48};
                                                                   bins v6= binsof(TX_vector_num)intersect{6} && binsof(TX_format_type)intersect{48};
                                                                   ignore_bins fmt_type_ignore = binsof(TX_format_type)intersect{32,96,112,114};}*/
      //  `else
      //  TX_DM_tag      : coverpoint cov_intf.tx_tag_dm iff(cov_intf.tx_tuser[0]==1){bins eightbittag={[10'h0:10'h0FF]}; }
      /*  TX_format_type: coverpoint cov_intf.tx_fmt_type{bins format_type[]={32,96}; 
                                          ignore_bins tx_format_type_igno={[0:31],[33:47],48,[49:95],[97:114],[115:255]};} */
      // `endif
                                      
endgroup

covergroup AXI_TX_COMPL ;
    //TX_PU_cmpl_len  : coverpoint cov_intf.tx_cmpl_len_pu{bins len_pu[]={[1:2]};}
    TX_compl_status : coverpoint cov_intf.tx_cmpl_status{bins cmp_stat[]={[STAT_COMPL.first:STAT_COMPL.last]};
                                                         ignore_bins tx_compl_status_igno = {1,2,3};}
    TX_compl_type   : coverpoint cov_intf.tx_cmpl_type{bins cmp_typ[]={74};
                                                      ignore_bins tx_type_igno={[0:10],[11:42],[43:73],[75:255]};}       //tx compl-only 4A will cover

endgroup



//***************************************************CE_COVERAGE**********************************************************
covergroup CE;
        
    DATA_REQ_limit: coverpoint cov_intf.data_req_limit{bins ce2host_drl[]={1,2,3};
                                                         ignore_bins ce2host_drl_igno={0};}

    CSR_IMG_size: coverpoint cov_intf.img_size{bins image_size_0={[0:127]};
                                               bins image_size_1={[128:255]};
                                               bins image_size_2={[256:511]};
                                               bins image_size_3={[512:1023]};
                                               bins image_size_4={[1024:2048]};}

    host2hps_img_xfr: coverpoint cov_intf.host2hps_img_xfr{bins host2hps_img_xfr[]={0,1};}

    CSR_CE_sftrst: coverpoint cov_intf.ce_sftrst{bins ce_sftrst[]={0,1};}


endgroup

covergroup CE_TX;
    CE_IMG_addr_sts: coverpoint cov_intf.ce_image_addr{bins img_addr[]={0,1,2};
                                                        ignore_bins img_addr_igno={3};}

    CE_AXIST_cmpl_sts: coverpoint cov_intf.ce_axist_cmpl_sts{bins cmpl_sts[]={0,1};
                                                            ignore_bins cmpl_sts_igno={2,3,4,5,6,7};}

    CE_ACELITE_bresp_sts: coverpoint cov_intf.ce_acelite_bresp_sts{bins bresp_sts[]={0,2};
                                                                    ignore_bins bresp_sts_igno={1,3};}

    CE_DMA_sts: coverpoint cov_intf.ce_dma_sts{bins dma_sts[]={0,1,2,3};}
   
    HPS_RDY_shdw: coverpoint cov_intf.hps_rdy_shdw{bins hps_rdy_shdw[]={0,1};}

    KERNEL_vfy_shdw: coverpoint cov_intf.kernel_vfy_shdw{bins kernel_vfy_shdw[]={0,1,2};
                                                         ignore_bins kernel_shdw_igno={3};}

    SSBL_vfy_shdw: coverpoint cov_intf.ssbl_vfy_shdw{bins ssbl_vfy_shdw[]={0,1,2};
                                                     ignore_bins ssbl_shdw_igno={3};}
    
//Writing and reading from the same signal, removing this bin in functional coverage
 //  host2hps_img_xfr_shdw: coverpoint cov_intf.host2hps_img_xfr_shdw{bins host2hps_img_xfr_shdw[]={0,1};}
    

endgroup

covergroup CE_RSP;
    HPS_rdy: coverpoint cov_intf.hps_rdy{bins hps_rdy[]={0,1};}

    KERNEL_vfy: coverpoint cov_intf.kernel_vfy{bins kernel_vfy[]={0,1,2};
                                               ignore_bins kernel_igno={3};}

    SSBL_vfy: coverpoint cov_intf.ssbl_vfy{bins ssbl_vfy[]={0,1,2};
                                                ignore_bins ssbl_shdw_igno={3};}

endgroup

//**************************************************BOTH_TX_RX_COVERGROUP_END*******************************************

  function new(string name ="coverage_r1",uvm_component parent=null);
    super.new(name,parent);
    AXI_ST_TX=new();
    AXI_TX_COMPL=new();
    AXI_ST_RX=new();
    AXI_RX_COMPL=new();
    CE=new();
    CE_TX=new();
    CE_RSP=new();
     endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db#(virtual coverage_intf)::get(this,"*","cov_intf",cov_intf)))begin
       `uvm_fatal("CLSS",("virtual interface must be set for:"))
    end
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    sample_calling; 
  endtask


task sample_calling;
    

   fork 
//RX_sample:    
     forever @(posedge cov_intf.rx_clk)begin
       if((cov_intf.flag_rx==1)||(cov_intf.flag_64_rx==1)||(cov_intf.flag_dmrx==1)||(cov_intf.flag_64_rx))begin
        //   if((cov_intf.rx_tuser==1)) begin
       if(((cov_intf.rx_req_fmt==2)&&(cov_intf.rx_req_type==0))||((cov_intf.rx_req_fmt==0)&&(cov_intf.rx_req_type==0))&&(cov_intf.rx_tvalid==1))begin 
    `ifdef ENABLE_COV_MSG   
     `uvm_info("CLAS_COV",$sformatf("AC_RX_CHECK_sampling"), UVM_LOW)
 `endif
            AXI_ST_RX.sample();
        //end
       /*if((cov_intf.rx_host_addr_h==`PF4_BAR0)||(cov_intf.rx_host_addr_h==`PF4_BAR0+32'h0108)||(cov_intf.rx_host_addr_h==`PF4_BAR0+32'h0120)||(cov_intf.rx_host_addr_h==`PF4_BAR0+32'h0138)||(cov_intf.rx_host_addr_h==`PF4_BAR0+32'h0148))begin   //CE
            `ifdef ENABLE_COV_MSG
               `uvm_info("CLAS_COV",$sformatf("RX:::CE_sampling"), UVM_LOW)
           `endif
               // CE.sample();

            end */
        end
        if((cov_intf.dmrx_req_fmt==2)&&(cov_intf.dmrx_req_type==10)&&(cov_intf.dmrx_tuser==1))begin  //compl
            AXI_RX_COMPL.sample();
        `ifdef ENABLE_COV_MSG
           `uvm_info("CLAS_COV",$sformatf("AC_RX_CHECK_COMPL_Inside_sample_task"), UVM_LOW)
       `endif
        end //else end
 end //flag end
end //foreach end

       //TX_sample:    
     forever @(posedge cov_intf.tx_clk)begin
       if(cov_intf.flag_tx==1)begin
         if(((cov_intf.tx_req_fmt==2)&&(cov_intf.tx_req_type==0))||((cov_intf.tx_req_fmt==1)&&(cov_intf.tx_req_type==0))||((cov_intf.tx_req_fmt==0)&&(cov_intf.tx_req_type==0)))begin 
          `ifdef ENABLE_COV_MSG
             `uvm_info("CLAS_COV",$sformatf("TX_CHECK_sampling"), UVM_LOW)
         `endif
            AXI_ST_TX.sample();
         end 
       else  if((cov_intf.tx_req_fmt==2)&&(cov_intf.tx_req_type==10))begin  //compl
            AXI_TX_COMPL.sample();
        `ifdef ENABLE_COV_MSG
           `uvm_info("CLAS_COV",$sformatf("TX_CHECK_COMPL_sampling"), UVM_LOW)
       `endif

       if((cov_intf.tx_host_addr_h==7'h30)||(cov_intf.tx_host_addr_h==7'h40)||(cov_intf.tx_host_addr_h==7'h08)||(cov_intf.tx_host_addr_h==7'h20)||(cov_intf.tx_host_addr_h==7'h38)||(cov_intf.tx_host_addr_h==7'h48))begin   //CE
            `ifdef ENABLE_COV_MSG
               `uvm_info("CLAS_COV",$sformatf("TX:::CE_sampling"), UVM_LOW)
           `endif
                CE_TX.sample();
                CE.sample();
          end 
       end
      end
     end

     forever @(posedge cov_intf.ce_inst_clk)begin
       if(cov_intf.flag_ce==1)begin
         if((cov_intf.rx_axi4mmrx_csr_raddr==16'h158) && (cov_intf.rx_axi4mmrx_csr_ren==1'h1))begin
            `ifdef ENABLE_COV_MSG
               `uvm_info("CLAS_COV",$sformatf("RSP:::CE_sampling"), UVM_LOW)
           `endif
                CE_RSP.sample();
        end
      end
    end
   join

 endtask


endclass

`endif
