// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//Connect HE_HSSI interface to AXISVIP to reduce runtime of RXLPBK tests
`define DUT tb_top.DUT 
`define AFU_TOP tb_top.DUT.afu_top.pg_afu.port_gasket.pr_slot.afu_main.port_afu_instances
`define HE_HSSI_TOP `AFU_TOP.afu_gen[1].heh_gen.he_hssi_inst

module HE_HSSI_AXIS(`AXI_IF axis_HSSI_if);

assign axis_HSSI_if.common_aclk          = `HE_HSSI_TOP.hssi_ss_st_rx[0].clk;
assign axis_HSSI_if.master_if[0].aresetn = `HE_HSSI_TOP.hssi_ss_st_rx[0].rst_n;
//assign axis_HSSI_if.slave_if[0].aresetn = `AFU_TOP.he_hssi_top.hssi_ss_st_tx[0].rst_n; 
//initial begin
genvar i;
generate 
  for(i=0;i<8;i++) begin
assign axis_HSSI_if.slave_if[i].aresetn = `HE_HSSI_TOP.hssi_ss_st_tx[i].rst_n;
initial begin
force `AFU_TOP.hssi_ss_st_rx[i].rx.tvalid      =  axis_HSSI_if.master_if[0].tvalid;
force `AFU_TOP.hssi_ss_st_rx[i].rx.tlast       =  axis_HSSI_if.master_if[0].tlast;
force `AFU_TOP.hssi_ss_st_rx[i].rx.tuser[11:0] =  axis_HSSI_if.master_if[0].tuser;
force `AFU_TOP.hssi_ss_st_rx[i].rx.tdata[63:0] =  axis_HSSI_if.master_if[0].tdata;
force `AFU_TOP.hssi_ss_st_rx[i].rx.tkeep[7:0]  =  axis_HSSI_if.master_if[0].tkeep;

force axis_HSSI_if.master_if[0].tready=1'b1;
force axis_HSSI_if.slave_if[i].tvalid =   `AFU_TOP.hssi_ss_st_tx[i].tx.tvalid;      
force axis_HSSI_if.slave_if[i].tlast  =   `AFU_TOP.hssi_ss_st_tx[i].tx.tlast;              
force axis_HSSI_if.slave_if[i].tuser  =   `AFU_TOP.hssi_ss_st_tx[i].tx.tuser;                
force axis_HSSI_if.slave_if[i].tdata  =   `AFU_TOP.hssi_ss_st_tx[i].tx.tdata[63:0];                
force axis_HSSI_if.slave_if[i].tkeep  =   `AFU_TOP.hssi_ss_st_tx[i].tx.tkeep[7:0]; 
force `AFU_TOP.hssi_ss_st_tx[i].tready=1'b1;              
force axis_HSSI_if.slave_if[i].tready=1'b1;
end
 end
endgenerate
//end
endmodule
