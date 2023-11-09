// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

// TB Top which instantiates DUT, Interface,clock and reset_n generation logic.

`ifdef SIM_SERIAL
    `timescale 1ps/1ps
`else
    `timescale 1ns/1ps
`endif // SIM_SERIAL


`include "qsfp_tb_pkg.svh"
module qsfp_tb_top;

reg clk = 0;
reg reset_n = 0;

//Clock generation
//TODO multiple clocks for I2C speeds
always #5 clk = ~clk;


// Reset generation
initial
begin
  #100 reset_n = 1'b1;
end


// AXI Interface
`AXI_IF axi_if ();
ofs_fim_axi_lite_if #(21, 64, 21, 64)  csr_tb_if();

//QSFP Interface
qsfp_intf qsfpif (clk, reset_n);

qsfp_coverage_intf cov_intf();

// I2c Slave AVMM Interface
qsfp_slave_interface    qsfp_slv_if ( clk , reset_n);

// Wires declaration

wire  dut_sda_in;
wire  dut_scl_in;
wire  dut_sda_oe;
wire  dut_scl_oe;
wire  bfm_sda_in;
wire  bfm_scl_in;
wire  bfm_sda_oe;
wire  bfm_scl_oe;
tri1 sda;
tri1 scl;

assign sda = dut_sda_oe? 1'b0: 1'bz;
assign scl = dut_scl_oe? 1'b0 :1'bz;
assign dut_sda_in = sda;
assign dut_scl_in = scl;

assign sda = bfm_sda_oe? 1'b0: 1'bz;
assign scl = bfm_scl_oe? 1'b0 :1'bz;
assign bfm_sda_in = sda;
assign bfm_scl_in = scl; 
 

// 
assign axi_if.common_aclk = clk;
assign axi_if.master_if[0].aresetn      = reset_n;


assign csr_tb_if.awvalid                = axi_if.master_if[0].awvalid;
assign csr_tb_if.arvalid                = axi_if.master_if[0].arvalid;
assign csr_tb_if.awaddr                 = axi_if.master_if[0].awaddr;
assign csr_tb_if.araddr                 = axi_if.master_if[0].araddr;
assign csr_tb_if.awprot                 = axi_if.master_if[0].awprot;
assign csr_tb_if.arprot                 = axi_if.master_if[0].arprot;
assign csr_tb_if.wvalid                 = axi_if.master_if[0].wvalid;
assign csr_tb_if.wdata                  = axi_if.master_if[0].wdata;
assign csr_tb_if.wstrb                  = axi_if.master_if[0].wstrb;
assign csr_tb_if.bready                 = axi_if.master_if[0].bready;
assign csr_tb_if.rready                 = axi_if.master_if[0].rready;


assign axi_if.master_if[0].rvalid       = csr_tb_if.rvalid;
assign axi_if.master_if[0].awready      = csr_tb_if.awready;
assign axi_if.master_if[0].wready       = csr_tb_if.wready;
assign axi_if.master_if[0].arready      = csr_tb_if.arready;
assign axi_if.master_if[0].rdata        = csr_tb_if.rdata;
assign axi_if.master_if[0].rresp        = csr_tb_if.rresp;
assign axi_if.master_if[0].bresp        = csr_tb_if.bresp;
assign axi_if.master_if[0].bvalid       = csr_tb_if.bvalid; 

// QSFP DUT Instance
qsfp_top  #(12, 64, 12'h001, 4'h1, 24'h1000, 1'b0)  qsfp_dut_i  
  (
  .clk                     (clk),
  .reset                   (!reset_n),
  .modprsl                 (qsfpif.modprsl),
  .int_qsfp                (qsfpif.int_qsfp),
  .i2c_0_i2c_serial_sda_in (dut_sda_in),
  .i2c_0_i2c_serial_scl_in (dut_scl_in),
  .i2c_0_i2c_serial_sda_oe (dut_sda_oe),
  .i2c_0_i2c_serial_scl_oe (dut_scl_oe),
  .modesel                 (qsfpif.modsel),
  .lpmode                  (qsfpif.lpmode),
  .softresetqsfpm          (qsfpif.softresetqsfm),
  .csr_lite_if             (csr_tb_if.slave)
  );

//2C SLAVE AVMM BRIDGE Instance
i2c_bfm i2c_bfm_i (
      .clk                 (clk),
      .address             (qsfp_slv_if.address),
      .read                (qsfp_slv_if.read),
      .readdata            (qsfp_slv_if.readdata),
      .readdatavalid       (qsfp_slv_if.readdatavalid),
      .waitrequest         (qsfp_slv_if.waitrequest),
      .write               (qsfp_slv_if.write),
      .byteenable          (qsfp_slv_if.byteenable),
      .writedata           (qsfp_slv_if.writedata),
      .rst_n               (reset_n),
      .i2c_data_in         (bfm_sda_in),
      .i2c_clk_in          (bfm_scl_in),
      .i2c_data_oe         (bfm_sda_oe),
      .i2c_clk_oe          (bfm_scl_oe)
);


  initial 
  begin
    // config db setup for Virtual interface
      uvm_config_db#(virtual `AXI_IF)::set(uvm_root::get(), "*", "vif", axi_if);
      uvm_config_db#(virtual qsfp_intf)::set(null, "*", "qsfpif", qsfpif);
      //uvm_config_db#(virtual qsfp_slave_interface)::set(uvm_root::get(), "uvm_test_top.tb_env0.qsfp_slv_env", "vif", qsfp_slv_if);
      uvm_config_db#(virtual qsfp_slave_interface)::set(uvm_root::get(), "*", "vif", qsfp_slv_if);

      uvm_config_db#(virtual qsfp_coverage_intf)::set(uvm_root::get(), "*", "cov_intf", cov_intf);

    run_test();
  end
endmodule
