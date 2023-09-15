// Copyright (C) 2021 Intel Corporation
// SPDX-License-Identifier: MIT


  `define PCIE_DMRX tb_top.DUT.pcie_ss_axis_rx_if
  `define PCIE_RX tb_top.DUT.pcie_ss_axis_rxreq_if
  `define PCIE_TX tb_top.DUT.pcie_ss_axis_tx_if
  `define CE_INST tb_top.DUT.ce_top_inst.ce_csr_inst

interface coverage_intf ();
//*****************************************VARIABLE_DECLARATION*****************************
//RX 
   logic         rx_tvalid;
   logic         rx_tlast;
   logic[9:0]    rx_tuser;
   logic[9:0]    rx_tuser_vendor;
   logic[511:0]  rx_tdata;
   logic[63:0]   rx_tkeep;
   logic         rx_tready;
   logic         rx_clk;
//RXDM
   logic         dmrx_tvalid;
   logic         dmrx_tlast;
   logic[9:0]    dmrx_tuser;
   logic[9:0]    dmrx_tuser_vendor;
   logic[511:0]  dmrx_tdata;
   logic[63:0]   dmrx_tkeep;
   logic         dmrx_tready;
   logic         dmrx_clk;

   bit [9:0]  dmrx_length_1; 
   bit [2:0]  dmrx_req_fmt;
   bit [5:0]  dmrx_tag;
   bit [4:0]  dmrx_req_type;
   bit [1:0]  dmrx_length_l; 
   bit [11:0] dmrx_length_h; 
   bit [1:0]  dmrx_host_addr_1;
   bit [31:0] dmrx_host_addr_h; 
   bit [31:0] dmrx_host_addr_m;
   bit [2:0]  dmrx_pf_num;
   bit [10:0] dmrx_vf_num;
   bit        dmrx_vf_active;
   bit [4:0]  dmrx_slot_num;
   bit        dmrx_MM_mode;
   bit [6:0]  dmrx_bar_num;
   bit [255:0] dmrx_data_h;
   bit [31:0] dmrx_data_1;
   bit         dmrx_cont_mode;
   bit [3:0]  dmrx_test_mode;
   bit [1:0]  dmrx_req_len;
   bit [2:0]  dmrx_tput_intrlev;
   bit        flag_dmrx=0,flag_64_dmrx=0;
   int        count_dmrx=1;
   bit[9:0]   dmrx_cmpl_len_pu;
   bit[13:0]  dmrx_cmpl_len_dm;
   bit[7:0]   dmrx_cmpl_type;  
   bit[1:0]   dmrx_cmpl_status;
   bit[23:0]  dmrx_length_dm;
   bit [9:0]  dmrx_cmpl_tag_dm;
   bit [9:0]  dmrx_tag_dm;
   bit [9:0]  dmrx_cmpl_tag_pu;
   bit[9:0]   dmrx_length_pu;
   bit[7:0]   dmrx_fmt_type;
   event      dmrx_trig;
   bit[63:0] dmrx_host_addr_64;


//TX
   logic         tx_tvalid;
   logic         tx_tlast;
   logic[9:0]    tx_tuser;
   logic[9:0]    tx_tuser_vendor;
   logic[511:0]  tx_tdata;
   logic[63:0]   tx_tkeep;
   logic         tx_tready;
   logic         tx_clk;
logic ce_inst_clk;
bit [15:0] rx_axi4mmrx_csr_raddr;
bit        rx_axi4mmrx_csr_ren;
bit [4:0]  rx_csr_hps2host_rsp;
bit        rx_csr_host2hps_img_xfr_st;
bit [9:0]  tx_length_1,rx_length_1; 
bit [2:0]  tx_req_fmt,rx_req_fmt;
bit [5:0]  tx_tag,rx_tag;
bit [4:0]  tx_req_type,rx_req_type;
bit [1:0]  tx_length_l,rx_length_l; 
bit [11:0] tx_length_h,rx_length_h; 
bit [1:0]  tx_host_addr_1,rx_host_addr_1;
bit [31:0] tx_host_addr_h,rx_host_addr_h; 
bit [31:0] tx_host_addr_m,rx_host_addr_m;
bit [2:0]  tx_pf_num,rx_pf_num;
bit [10:0] tx_vf_num,rx_vf_num;
bit        tx_vf_active,rx_vf_active;
bit [4:0]  tx_slot_num,rx_slot_num;
bit        rx_MM_mode;
bit [6:0]  tx_bar_num,rx_bar_num;
bit [255:0] tx_data_h,rx_data_h;
bit [31:0] tx_data_1,rx_data_1;
bit        tx_cont_mode, rx_cont_mode;
bit [3:0]  tx_test_mode,rx_test_mode;
bit [1:0]  tx_req_len,rx_req_len;
bit [2:0]  tx_tput_intrlev,rx_tput_intrlev;
bit        flag_rx=0,flag_tx=0,flag_ce=0,flag_64_rx=0,flag_64_tx=0,flag_64_ce=0;
int        count_rx=1,count_tx=1;
bit[9:0]   tx_cmpl_len_pu,rx_cmpl_len_pu;
bit[13:0]  rx_cmpl_len_dm,tx_cmpl_len_dm;
bit[7:0]   tx_cmpl_type,rx_cmpl_type;  
bit[1:0]   tx_cmpl_status,rx_cmpl_status;
bit[23:0]  rx_length_dm,tx_length_dm;
bit [9:0]  rx_cmpl_tag_dm,tx_cmpl_tag_dm;
bit [9:0]  tx_tag_dm,rx_tag_dm;
bit [9:0]  tx_cmpl_tag_pu,rx_cmpl_tag_pu;
bit[9:0]   rx_length_pu,tx_length_pu;

bit[7:0]   rx_fmt_type,tx_fmt_type;
bit[31:0]  ce2host_sts;     
bit[1:0]   ce_image_addr;   
bit[2:0]   ce_axist_cmpl_sts;   
bit[1:0]   ce_acelite_bresp_sts;
bit[1:0]   ce_dma_sts;
bit[31:0]  csr_hps2host_rsp_shdw;
bit        hps_rdy_shdw;
bit[1:0]   kernel_vfy_shdw;
bit[1:0]   ssbl_vfy_shdw;
bit[31:0]  csr_hps2host_rsp;
bit        hps_rdy;
bit[1:0]   kernel_vfy;
bit[1:0]   ssbl_vfy;
bit[31:0]  csr_ce2host_data_req_limit;
bit[1:0]   data_req_limit;
bit[31:0]  csr_img_size;
bit[31:0]  img_size;
bit[31:0]  csr_host2hps_img_xfr;
bit        host2hps_img_xfr;
bit[31:0]  csr_host2hps_img_xfr_shdw;
bit        host2hps_img_xfr_shdw;
bit[31:0]  csr_ce_sftrst;
bit        ce_sftrst;
event      rx_trig,tx_trig;
bit[63:0] rx_host_addr_64;
 
assign rx_clk = `PCIE_RX.clk;
assign dmrx_clk = `PCIE_DMRX.clk;
assign tx_clk = `PCIE_TX.clk;
assign ce_inst_clk = `CE_INST.clk;
/*typedef struct {
   
    bit [63:0] pf0_bar0;
    bit [63:0] he_lb_base;
    bit [63:0] he_mem_base;
     bit[63:0] he_hssi_base;

               }st_base_addr;

st_base_addr st_addr; */

//*****************************************CODE_START*****************************

//********************************************************************RX_START(RXREQ_IF)******************************************************
always@(posedge `PCIE_RX.clk) begin

if((`PCIE_RX.tvalid==1) &&(`PCIE_RX.tready==1) && (count_rx==1))begin
 `ifdef ENABLE_COV_MSG
   `uvm_info("INTF",$sformatf("RX:::first_256_bits_of data = %0h " ,`PCIE_RX.tdata[255:0] ), UVM_LOW)  
   `uvm_info("INTF",$sformatf("RX:::next_last_256_bits_of_data = %0h " ,`PCIE_RX.tdata[511:256] ), UVM_LOW)  
`endif
//*************************new 64 bit address update**********************************



/*uvm_config_db#(bit[63:0])::get(uvm_root::get(),"*","pf0_bar0", st_addr.pf0_bar0);
uvm_config_db#(bit[63:0])::get(uvm_root::get(),"*","he_lb_base", st_addr.he_lb_base);
uvm_config_db#(bit[63:0])::get(uvm_root::get(),"*","he_mem_base", st_addr.he_mem_base);
uvm_config_db#(bit[63:0])::get(uvm_root::get(),"*","he_hssi_base", st_addr.he_hssi_base);

`ifdef ENABLE_COV_MSG
`uvm_info("", $sformatf("pf0_bar0        %8h", st_addr.pf0_bar0 )    , UVM_LOW)
`uvm_info("", $psprintf("he_lb_base      %8h", st_addr.he_lb_base)   , UVM_LOW)
`uvm_info("", $psprintf("he_mem_base     %8h", st_addr.he_mem_base)  , UVM_LOW)
`uvm_info("", $psprintf("he_hssi_base    %8h", st_addr.he_hssi_base) , UVM_LOW)
 `endif

 pf0_bar0_addr=st_addr.pf0_bar0;
 he_lb_addr   =st_addr.he_lb_base;
 he_mem_addr  =st_addr.he_mem_base;
 he_hssi_addr =st_addr.he_hssi_base;

`ifdef ENABLE_COV_MSG
`uvm_info("INTF",$sformatf("pf0_bar0 = %0h " ,pf0_bar0 ), UVM_LOW)
`uvm_info("", $psprintf("he_lb_addr     %8h", he_lb_addr)    , UVM_LOW)
`uvm_info("", $psprintf("he_mem_addr     %8h", he_mem_addr)    , UVM_LOW)
`uvm_info("", $psprintf("he_hssi_addr     %8h", he_hssi_addr)    , UVM_LOW)
`endif*/
    //RX 
    rx_tvalid =`PCIE_RX.tvalid; 
    rx_tlast  =`PCIE_RX.tlast; 
    rx_tuser  =`PCIE_RX.tuser_vendor; 
    rx_tdata  =`PCIE_RX.tdata; 
    rx_tkeep  =`PCIE_RX.tkeep;
    rx_tready =`PCIE_RX.tready;
    rx_splitting;
    flag_rx=1; 
    flag_64_rx=1;
    count_rx++;
    end else begin
   flag_rx = 0;
   flag_64_rx=0;

end


if((`PCIE_RX.tvalid==1) &&(`PCIE_RX.tready==1) && (`PCIE_RX.tlast==1))begin
  count_rx=1;
    end
 end 

//********************************************************************RX_START(RX_IF)******************************************************

always@(posedge `PCIE_DMRX.clk) begin

if((`PCIE_DMRX.tvalid==1) &&(`PCIE_DMRX.tready==1) && (count_dmrx==1))begin
 `ifdef ENABLE_COV_MSG
   `uvm_info("INTF",$sformatf("DMRX:::first_256_bits_of data = %0h " ,`PCIE_DMRX.tdata[255:0] ), UVM_LOW)  
   `uvm_info("INTF",$sformatf("DMRX:::next_last_256_bits_of_data = %0h " ,`PCIE_DMRX.tdata[511:256] ), UVM_LOW)  
`endif
//*************************new 64 bit address update**********************************



/*uvm_config_db#(bit[63:0])::get(uvm_root::get(),"*","pf0_bar0", st_addr.pf0_bar0);
uvm_config_db#(bit[63:0])::get(uvm_root::get(),"*","he_lb_base", st_addr.he_lb_base);
uvm_config_db#(bit[63:0])::get(uvm_root::get(),"*","he_mem_base", st_addr.he_mem_base);
uvm_config_db#(bit[63:0])::get(uvm_root::get(),"*","he_hssi_base", st_addr.he_hssi_base);

`ifdef ENABLE_COV_MSG
`uvm_info("", $sformatf("pf0_bar0        %8h", st_addr.pf0_bar0 )    , UVM_LOW)
`uvm_info("", $psprintf("he_lb_base      %8h", st_addr.he_lb_base)   , UVM_LOW)
`uvm_info("", $psprintf("he_mem_base     %8h", st_addr.he_mem_base)  , UVM_LOW)
`uvm_info("", $psprintf("he_hssi_base    %8h", st_addr.he_hssi_base) , UVM_LOW)
 `endif

 pf0_bar0_addr=st_addr.pf0_bar0;
 he_lb_addr   =st_addr.he_lb_base;
 he_mem_addr  =st_addr.he_mem_base;
 he_hssi_addr =st_addr.he_hssi_base;

`ifdef ENABLE_COV_MSG
`uvm_info("INTF",$sformatf("pf0_bar0 = %0h " ,pf0_bar0 ), UVM_LOW)
`uvm_info("", $psprintf("he_lb_addr     %8h", he_lb_addr)    , UVM_LOW)
`uvm_info("", $psprintf("he_mem_addr     %8h", he_mem_addr)    , UVM_LOW)
`uvm_info("", $psprintf("he_hssi_addr     %8h", he_hssi_addr)    , UVM_LOW)
`endif*/
    //RX 
    dmrx_tvalid =`PCIE_DMRX.tvalid; 
    dmrx_tlast  =`PCIE_DMRX.tlast; 
    dmrx_tuser  =`PCIE_DMRX.tuser_vendor; 
    dmrx_tdata  =`PCIE_DMRX.tdata; 
    dmrx_tkeep  =`PCIE_DMRX.tkeep;
    dmrx_tready =`PCIE_DMRX.tready;
    dmrx_splitting;
    flag_dmrx=1; 
    flag_64_dmrx=1;
    count_dmrx++;
    end else begin
   flag_dmrx = 0;
   flag_64_dmrx=0;

end


if((`PCIE_DMRX.tvalid==1) &&(`PCIE_DMRX.tready==1) && (`PCIE_DMRX.tlast==1))begin
  count_dmrx=1;
    end
 end 


//********************************************************************TX_START******************************************************
always@(posedge `PCIE_TX.clk) begin
if((`PCIE_TX.tvalid==1) &&(`PCIE_TX.tready==1) && (count_tx==1))begin

  `ifdef ENABLE_COV_MSG
    `uvm_info("INTF",$sformatf("TX:::first_256_bits_of data = %0h " ,`PCIE_TX.tdata[255:0] ), UVM_LOW)  
    `uvm_info("INTF",$sformatf("TX:::next_last_256_bits_of_data = %0h " ,`PCIE_TX.tdata[511:256] ), UVM_LOW) 
`endif


    //TX 
    tx_tvalid =`PCIE_TX.tvalid; 
    tx_tlast  =`PCIE_TX.tlast; 
    tx_tuser  =`PCIE_TX.tuser_vendor; 
    tx_tdata  =`PCIE_TX.tdata; 
    tx_tkeep  =`PCIE_TX.tkeep;
    tx_tready =`PCIE_TX.tready;
    tx_splitting;
    flag_tx=1; 
    flag_64_tx=1;
    count_tx++;
    end else begin
   flag_tx = 0;
   flag_64_tx=0;
end

if((`PCIE_TX.tvalid==1) &&(`PCIE_TX.tready==1) && (`PCIE_TX.tlast==1))begin
  count_tx=1;
   end
end 
//*****************************************CE_START********************************************
always@(posedge `CE_INST.clk) begin
if((`CE_INST.axi4mmrx_csr_raddr==16'h158) &&(`CE_INST.axi4mmrx_csr_ren==1))begin

  `ifdef ENABLE_COV_MSG
    `uvm_info("INTF",$sformatf("CE:::WR_Addr = %0h " ,`CE_INST.axi4mmrx_csr_raddr[15:0]), UVM_LOW)  
    `uvm_info("INTF",$sformatf("CE:::WR_Enable = %0h " ,`CE_INST.axi4mmrx_csr_ren), UVM_LOW) 
`endif


    //TX 
    rx_axi4mmrx_csr_raddr = `CE_INST.axi4mmrx_csr_raddr;
    rx_axi4mmrx_csr_ren = `CE_INST.axi4mmrx_csr_ren;
    rx_csr_hps2host_rsp = `CE_INST.csr_hps2host_rsp[4:0];
    rx_csr_host2hps_img_xfr_st = `CE_INST.csr_host2hps_img_xfr_st[0];
    ce_splitting;
    flag_ce=1; 
    flag_64_ce=1;
    count_tx++;
    end else begin
   flag_ce = 0;
   flag_64_ce=0;
end

//if(`CE_INST.axi4mmrx_csr_raddr==16'h0) &&(`CE_INST.axi4mmrx_csr_ren==0))begin
 // count_tx=1;
   //end
end 

//*****************************************Request_RX_TX_Splitting*****************************
task rx_splitting ; 
//byte 0,1,2,3
 rx_req_fmt   = rx_tdata[31:29];
 rx_req_type  = rx_tdata[28:24];
 rx_fmt_type  ={rx_tdata[31:29],rx_tdata[28:24]};
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("RX::Fmt_type= %0h",rx_fmt_type ),UVM_LOW)
  `endif
//*************************************new_update *************************************

if((rx_tdata[31:29]==3)||(rx_tdata[31:29]==1))begin   
rx_host_addr_64 ={rx_tdata[95:64], rx_tdata[127:96]};   // [95:64] - Host addr [63:32]  [127:96] - Host addr [31:0]
end else if ((rx_tdata[31:29]==2)||(rx_tdata[31:29]==0))begin
rx_host_addr_h ={rx_tdata[95:64]};   
end

`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("RX::Host_Addr= %0h",rx_host_addr_h ),UVM_LOW)
 `uvm_info("INTF", $sformatf("RX::Host_Addr_64= %0h",rx_host_addr_64 ),UVM_LOW)
`endif




 if(rx_tuser==0)begin  //POWER_USER_MODE
   rx_length_pu  = rx_tdata[9:0];
 end else begin //DATA_MOVER
   rx_length_dm ={rx_tdata[61:50],rx_tdata[9:0],rx_tdata[49:48]}; 
 end
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("RX:::LEN= %0d|| Format=%0d ||TYpe=%0d ", rx_length_1,rx_req_fmt,rx_req_type ),UVM_LOW)
`endif
//byte 4,5,6,7
 rx_length_l    = rx_tdata[49:48];
 rx_length_h    = rx_tdata[61:50];
 rx_host_addr_1 = rx_tdata[63:32];
 rx_tag_dm      = {rx_tdata[23],rx_tdata[19],rx_tdata[47:40]};
//byte 8,9,10,11
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("RX::Host_Addr= %0h",rx_host_addr_h ),UVM_LOW)
`endif
//byte 12,13,14,15
 rx_host_addr_m={rx_tdata[127:96]};
  `ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("RX::Host_Addr_2= %0h",rx_host_addr_m ),UVM_LOW)
`endif
//byte 16,17,18,19 -->prefix (No need to check)  
//byte 20,21,22,23
 rx_pf_num	 = rx_tdata[162:160];
 rx_vf_num	 = rx_tdata[173:163];
 rx_vf_active= rx_tdata[174];
 //rx_bar_num	 = rx_tdata [178:175]; 
 rx_slot_num = rx_tdata[183:179];
 rx_MM_mode  = rx_tdata[184];
 rx_bar_num	 = rx_tdata[191:185];
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("RX::PF_no=%0d ||VF_no=%0d ||VF_active=%0d||slot_no=%0d ||MM_mode=%0d ||bar_no=%0d",rx_pf_num,rx_vf_num,rx_vf_active,rx_slot_num,rx_MM_mode,rx_bar_num ),UVM_LOW)
`endif
//byte 24,25,26,27,28,29,30,31 -->>Reserved
//Byte 32,33,34,35
 rx_data_h=rx_tdata[511:256];
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("RX::DATA_256to511= %0h",rx_data_h ),UVM_LOW)
`endif

//*****************************************completion_RX_Splitting****************************

 rx_cmpl_type   = rx_tdata[31:24];
 rx_cmpl_status = rx_tdata[47:45];
 if(rx_tuser==0)begin
   rx_cmpl_len_pu    = rx_tdata[9:0];
 end else begin
   rx_cmpl_len_dm    = {rx_tdata[115:114],rx_tdata[9:0],rx_tdata[113:112]};
   rx_cmpl_tag_dm    = {rx_tdata[127:118]};
 end
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("RX::::::Compl_len_PU=%0d||comp_len_DM=%0d||comp_type=%0d ||compl_status=%0d",rx_cmpl_len_pu,rx_cmpl_len_dm,rx_cmpl_type,rx_cmpl_status),UVM_LOW)
`endif
endtask

//*******************************************RX_DM_INTERFACE***************************************
//*****************************************Request_DMRX_Splitting*****************************
task dmrx_splitting ; 
//byte 0,1,2,3
 dmrx_req_fmt   = dmrx_tdata[31:29];
 dmrx_req_type  = dmrx_tdata[28:24];
 dmrx_fmt_type  ={dmrx_tdata[31:29],dmrx_tdata[28:24]};
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("DMRX::Fmt_type= %0h",dmrx_fmt_type ),UVM_LOW)
  `endif
//*************************************new_update *************************************

if((dmrx_tdata[31:29]==3)||(dmrx_tdata[31:29]==1))begin   
dmrx_host_addr_64 ={dmrx_tdata[95:64], dmrx_tdata[127:96]};   // [95:64] - Host addr [63:32]  [127:96] - Host addr [31:0]
end else if ((dmrx_tdata[31:29]==2)||(dmrx_tdata[31:29]==0))begin
dmrx_host_addr_h ={dmrx_tdata[95:64]};   
end

`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("DMRX::Host_Addr= %0h",dmrx_host_addr_h ),UVM_LOW)
 `uvm_info("INTF", $sformatf("DMRX::Host_Addr_64= %0h",dmrx_host_addr_64 ),UVM_LOW)
`endif




 if(dmrx_tuser==0)begin  //POWER_USER_MODE
   dmrx_length_pu  = dmrx_tdata[9:0];
 end else begin //DATA_MOVER
   dmrx_length_dm ={dmrx_tdata[61:50],dmrx_tdata[9:0],dmrx_tdata[49:48]}; 
 end
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("DMRX:::LEN= %0d|| Format=%0d ||TYpe=%0d ", dmrx_length_1,dmrx_req_fmt,dmrx_req_type ),UVM_LOW)
`endif
//byte 4,5,6,7
 dmrx_length_l    = dmrx_tdata[49:48];
 dmrx_length_h    = dmrx_tdata[61:50];
 dmrx_host_addr_1 = dmrx_tdata[63:32];
 dmrx_tag_dm      = {dmrx_tdata[23],dmrx_tdata[19],dmrx_tdata[47:40]};
//byte 8,9,10,11
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("DMRX::Host_Addr= %0h",dmrx_host_addr_h ),UVM_LOW)
`endif
//byte 12,13,14,15
 dmrx_host_addr_m={dmrx_tdata[127:96]};
  `ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("DMRX::Host_Addr_2= %0h",dmrx_host_addr_m ),UVM_LOW)
`endif
//byte 16,17,18,19 -->prefix (No need to check)  
//byte 20,21,22,23
 dmrx_pf_num	 = dmrx_tdata[162:160];
 dmrx_vf_num	 = dmrx_tdata[173:163];
 dmrx_vf_active= dmrx_tdata[174];
 //dmrx_bar_num	 = dmrx_tdata [178:175]; 
 dmrx_slot_num = dmrx_tdata[183:179];
 dmrx_MM_mode  = dmrx_tdata[184];
 dmrx_bar_num	 = dmrx_tdata[191:185];
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("DMRX::PF_no=%0d ||VF_no=%0d ||VF_active=%0d||slot_no=%0d ||MM_mode=%0d ||bar_no=%0d",dmrx_pf_num,dmrx_vf_num,dmrx_vf_active,dmrx_slot_num,dmrx_MM_mode,dmrx_bar_num ),UVM_LOW)
`endif
//byte 24,25,26,27,28,29,30,31 -->>Reserved
//Byte 32,33,34,35
 dmrx_data_h=dmrx_tdata[511:256];
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("DMRX::DATA_256to511= %0h",dmrx_data_h ),UVM_LOW)
`endif

//*****************************************completion_DMDMRX_Splitting****************************

 dmrx_cmpl_type   = dmrx_tdata[31:24];
 dmrx_cmpl_status = dmrx_tdata[47:45];
 if(dmrx_tuser==0)begin
   dmrx_cmpl_len_pu    = dmrx_tdata[9:0];
 end else begin
   dmrx_cmpl_len_dm    = {dmrx_tdata[115:114],dmrx_tdata[9:0],dmrx_tdata[113:112]};
   dmrx_cmpl_tag_dm    = {dmrx_tdata[127:118]};
 end
`ifdef ENABLE_COV_MSG
 `uvm_info("INTF", $sformatf("DMRX::::::Compl_len_PU=%0d||comp_len_DM=%0d||comp_type=%0d ||compl_status=%0d",dmrx_cmpl_len_pu,dmrx_cmpl_len_dm,dmrx_cmpl_type,dmrx_cmpl_status),UVM_LOW)
`endif
endtask
////////////////////////////////////////////////////////////////////////////////////////////////////

//*******************************************CE_coverage***********************************
/*

    if((rx_host_addr_h==`PF4_BAR0+32'h0108) && (rx_tvalid==1))begin    
     csr_ce2host_data_req_limit =rx_tdata[287:256];
     data_req_limit      =csr_ce2host_data_req_limit[1:0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("RX::CSR_CE2HOST_DATA_REQ_LIMIT= %0h, DATA_REQ_LIMIT= %0h",csr_ce2host_data_req_limit,data_req_limit),UVM_LOW)
    `endif
     end

   else if((rx_host_addr_h==`PF4_BAR0+32'h0120) && (rx_tvalid==1))begin    
     csr_img_size =rx_tdata[287:256];
     img_size      =csr_img_size[31:0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("RX::CSR_IMG_SIZE= %0h, img_size= %0h",csr_img_size,img_size),UVM_LOW)
    `endif
     end

   else if((rx_host_addr_h==`PF4_BAR0+32'h0138) && (rx_tvalid==1))begin    
     csr_host2hps_img_xfr =rx_tdata[287:256];
     host2hps_img_xfr      =csr_host2hps_img_xfr[0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("RX::CSR_HOST2HPS_IMG_XFR= %0h, host2hps_img_xfr= %0h",csr_host2hps_img_xfr,host2hps_img_xfr),UVM_LOW)
    `endif
     end 

   else if((rx_host_addr_h==`PF4_BAR0+32'h0148) && (rx_tvalid==1))begin    
     csr_ce_sftrst =rx_tdata[287:256];
     ce_sftrst     =csr_ce_sftrst[0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("RX::CSR_CE_SFTRST= %0h, ce_sftrst= %0h",csr_ce_sftrst,ce_sftrst),UVM_LOW)
    `endif
     end */ 


//*******************************************************CE_Splitting******************
task ce_splitting;
    if((rx_axi4mmrx_csr_raddr==16'h158) && (rx_axi4mmrx_csr_ren==1'h1))begin    
     csr_hps2host_rsp =rx_csr_hps2host_rsp;
     hps_rdy      =csr_hps2host_rsp[4];
     kernel_vfy   =csr_hps2host_rsp[3:2];
     ssbl_vfy     =csr_hps2host_rsp[1:0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("CE::CSR_HPS2HOST_RSP= %0h, HPS_RDY= %0h,KERNEL_VFY= %0h, SSBL_VFY= %0h",csr_hps2host_rsp,hps_rdy,kernel_vfy,ssbl_vfy),UVM_LOW)
    `endif
    end
    else if((rx_axi4mmrx_csr_raddr==16'h154) && (rx_axi4mmrx_csr_ren==1'h1))begin     
     csr_host2hps_img_xfr_shdw  =rx_csr_host2hps_img_xfr_st;
     host2hps_img_xfr_shdw      =csr_host2hps_img_xfr_shdw[0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("CE::CSR_HOST2HPS_IMG_XFR_SHDW= %0h, host2hps_img_xfr_shdw= %0h",csr_host2hps_img_xfr_shdw,host2hps_img_xfr_shdw),UVM_LOW)
    `endif
     end
    

endtask
//*****************************************Request_TX_Splitting****************************

task tx_splitting;
 
//BYTE_0,1,2,3-1DW
     tx_req_fmt   = tx_tdata[31:29];
     tx_req_type  = tx_tdata[28:24];
     tx_fmt_type  ={tx_tdata[31:29],tx_tdata[28:24]};
     //tx_vector_num= tx_tdata[79:64];
    `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::Fmt_type= %0h",tx_fmt_type ),UVM_LOW)
 `endif
     if(tx_tuser==0)begin //POWER_USER_MODE
       tx_length_pu  = tx_tdata[9:0];
     end else begin //DATA_MOVER
       tx_length_dm ={tx_tdata[61:50],tx_tdata[9:0],tx_tdata[49:48]}; // 24 bits
       tx_tag_dm    ={tx_tdata[23],tx_tdata[19],tx_tdata[47:40]};
     end
    `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("LEN= %0d|| Format=%0d ||TYpe=%0d ", tx_length_1,tx_req_fmt,tx_req_type ),UVM_LOW)
 `endif
//byte 4,5,6,7
     tx_length_l    = tx_tdata[49:48];
     tx_length_h    = tx_tdata[61:50];
     tx_host_addr_1  =tx_tdata[63:62];
//byte 8,9,10,11
     tx_host_addr_h ={tx_tdata[70:64]};
    `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("Host_Addr= %0h",tx_host_addr_h ),UVM_LOW)
 `endif
//byte 12,13,14,15
     tx_host_addr_m={tx_tdata[127:96]};
    `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("Host_Addr_2= %0h",tx_host_addr_m ),UVM_LOW)
 `endif
//byte 20,21,22,23
     tx_pf_num	= tx_tdata[162:160];
     tx_vf_num	= tx_tdata[173:163];
     tx_vf_active	= tx_tdata[174];
     tx_slot_num = tx_tdata[183:179];
     tx_bar_num	= tx_tdata [191:185];
    `ifdef ENABLE_COV_MSG
    `uvm_info("INTF", $sformatf("PF_no=%0d ||VF_no=%0d||VF_active=%0d ||slot_no=%0d ||bar_no=%0d",tx_pf_num,tx_vf_num,tx_vf_active,tx_slot_num,tx_bar_num ),UVM_LOW)
`endif
//byte 24,25,26,27,28,29,30,31 -->>Reserved
//Byte 32 to 63
     tx_data_h=tx_tdata[511:256];
    `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::DATA_256to511= %0h",tx_data_h ),UVM_LOW)
 `endif

//*****************************************completion_TX_Splitting****************************
     if(tx_tuser==0)begin
     tx_cmpl_len_pu    = tx_tdata[9:0];
     tx_cmpl_tag_pu    = tx_tdata[80:72];
     end else begin
     tx_cmpl_len_dm    = {tx_tdata[115:114],tx_tdata[9:0],tx_tdata[113:112]};
     end
     tx_cmpl_type   = tx_tdata[31:24];;
     tx_cmpl_status = tx_tdata[47:45];
    `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::::::Compl_len_PU=%0d||comp_len_DM=%0d||comp_type=%0d ||compl_status=%0d",tx_cmpl_len_pu,tx_cmpl_len_dm,tx_cmpl_type,tx_cmpl_status),UVM_LOW)
 `endif
 

 //*******************************************CE_coverage***********************************

     if((tx_host_addr_h==7'h30) && (tx_tvalid==1))begin    
     ce2host_sts         =tx_tdata[287:256];
     ce_image_addr       =ce2host_sts[12:11];
     ce_axist_cmpl_sts   =ce2host_sts[6:4];
     ce_acelite_bresp_sts=ce2host_sts[3:2];
     ce_dma_sts          =ce2host_sts[1:0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::CE2HOST_STATUS= %0h, CE_IMAGE_ADDR_STATUS= %0h,CE_AXIST_CMPL_STATUS= %0h, CE_ACELITE_BRESP_STATUS= %0h, CE_DMA_STATUS= %0h",ce2host_sts,ce_image_addr,ce_axist_cmpl_sts,ce_acelite_bresp_sts,ce_dma_sts),UVM_LOW)
    `endif
     end

   else if((tx_host_addr_h==7'h40) && (tx_tvalid==1))begin    
     csr_hps2host_rsp_shdw =tx_tdata[287:256];
     hps_rdy_shdw      =csr_hps2host_rsp_shdw[4];
     kernel_vfy_shdw   =csr_hps2host_rsp_shdw[3:2];
     ssbl_vfy_shdw     =csr_hps2host_rsp_shdw[1:0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::CSR_HPS2HOST_RSP_SHDW= %0h, HPS_RDY_SHDW= %0h,KERNEL_VFY_SHDW= %0h, SSBL_VFY_SHDW= %0h",csr_hps2host_rsp_shdw,hps_rdy_shdw,kernel_vfy_shdw,ssbl_vfy_shdw),UVM_LOW)
    `endif
     end
     
     else if((tx_host_addr_h==7'h54) && (tx_tvalid==1))begin    
     csr_host2hps_img_xfr_shdw =tx_tdata[287:256];
     host2hps_img_xfr_shdw      =csr_host2hps_img_xfr_shdw[0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::CSR_HOST2HPS_IMG_XFR_SHDW= %0h, host2hps_img_xfr_shdw= %0h",csr_host2hps_img_xfr_shdw,host2hps_img_xfr_shdw),UVM_LOW)
    `endif
     end


    if((tx_host_addr_h==32'h08) && (tx_tvalid==1))begin    
     csr_ce2host_data_req_limit =tx_tdata[287:256];
     data_req_limit      =csr_ce2host_data_req_limit[1:0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::CSR_CE2HOST_DATA_REQ_LIMIT= %0h, DATA_REQ_LIMIT= %0h",csr_ce2host_data_req_limit,data_req_limit),UVM_LOW)
    `endif
     end

   else if((tx_host_addr_h==32'h20) && (tx_tvalid==1))begin    
     csr_img_size =tx_tdata[287:256];
     img_size      =csr_img_size[31:0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::CSR_IMG_SIZE= %0h, img_size= %0h",csr_img_size,img_size),UVM_LOW)
    `endif
     end

   else if((tx_host_addr_h==32'h38) && (tx_tvalid==1))begin    
     csr_host2hps_img_xfr =tx_tdata[287:256];
     host2hps_img_xfr      =csr_host2hps_img_xfr[0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::CSR_HOST2HPS_IMG_XFR= %0h, host2hps_img_xfr= %0h",csr_host2hps_img_xfr,host2hps_img_xfr),UVM_LOW)
    `endif
     end 

   else if((tx_host_addr_h==32'h48) && (tx_tvalid==1))begin    
     csr_ce_sftrst =tx_tdata[287:256];
     ce_sftrst     =csr_ce_sftrst[0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("TX::CSR_CE_SFTRST= %0h, ce_sftrst= %0h",csr_ce_sftrst,ce_sftrst),UVM_LOW)
    `endif
     end

     
  /* else if((tx_host_addr_h==7'h58) && (tx_tvalid==1))begin    
     csr_hps2host_rsp =tx_tdata[287:256];
     hps_rdy      =csr_hps2host_rsp[4];
     kernel_vfy   =csr_hps2host_rsp[3:2];
     ssbl_vfy     =csr_hps2host_rsp[1:0];
      `ifdef ENABLE_COV_MSG
     `uvm_info("INTF", $sformatf("RX::CSR_HPS2HOST_RSP= %0h, HPS_RDY= %0h,KERNEL_VFY= %0h, SSBL_VFY= %0h",csr_hps2host_rsp,hps_rdy,kernel_vfy,ssbl_vfy),UVM_LOW)
    `endif
     end*/
endtask


endinterface

