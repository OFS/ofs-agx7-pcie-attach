//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class TxMWrDataPayloadOverrun_seq is executed by TxMWrDataPayloadOverrun_test
 * 
 * This sequence verifies the Error vector mechanism of protocol-checker block  
 * To generate the error , the corrupt transactions are forced
 * The sequence monitors the error register is set or not 
 * Error is clear using the soft_reset
 *
 */
//===============================================================================================================

`ifndef TXMWRDATAPAYLOADOVERRUN_SEQ_SVH
`define TXMWRDATAPAYLOADOVERRUN_SEQ_SVH

class TxMWrDataPayloadOverrun_seq extends he_lpbk_wr_seq;

`uvm_object_utils(TxMWrDataPayloadOverrun_seq)
`uvm_declare_p_sequencer(virtual_sequencer)

constraint num_lines_c { num_lines == 512; }
constraint ral_mode {ral_mode_prtcl == 2'b1;}
 
function new(string name = "TxMWrDataPayloadOverrun_seq");
  super.new(name); 
endfunction    
    
 task body();  
 
 bit [63:0] wdata, rdata,rdata_e  ;
 bit [63:0] addr;
  bit[63:0] rdata_s = 1;
 pcie_rd_mmio_seq mmio_rd;
 uvm_status_e       status;
 uvm_reg_data_t     reg_data;
 int                timeout;
 time dly_after_err  = 5us; 
 time dly_rst_window = 1us;
 time dly_before_read =30us; //512 timout cycle instead of 28us wating for 30us
 
fork 
   begin
     super.body();
   end
   begin
      wait(`AFU_TOP.afu_intf_inst.i_afu_softreset == 0)begin
      #5us;
      do begin
       mmio_read64 (.addr_(tb_cfg0.HE_LB_BASE +'h138), .data_(rdata));	
      `uvm_info(get_name(), $psprintf("payload_overrun  CSR_CTL = %0h", rdata), UVM_LOW)
       end while(rdata != 64'h3);
       wait(`AFU_TOP.afu_intf_inst.afu_axis_tx.tdata[31:24]==8'h60 && `AFU_TOP.afu_intf_inst.afu_axis_tx.tvalid == 1 && `AFU_TOP.afu_intf_inst.afu_axis_tx.tuser_vendor[0] ==10'h1)
     begin
      force `AFU_TOP.afu_intf_inst.afu_axis_tx.tdata[9:0] = 10'd10;  
      `uvm_info(get_name(),"force", UVM_LOW)
      @ (negedge `AFU_TOP.afu_intf_inst.afu_axis_tx.tvalid or negedge `AFU_TOP.afu_intf_inst.afu_axis_tx.tready) begin
       #50ns;
      release {`AFU_TOP.afu_intf_inst.afu_axis_tx.tdata[9:0]};
     `uvm_info(get_name(),"release", UVM_LOW)
      end
    end
  end
 end
join_any
disable fork;

#dly_after_err;

 port_rst_assert();
`uvm_info(get_full_name(),$sformatf("Port Reset Done...."),UVM_LOW);
#dly_rst_window; 
 
release_port_rst ();
#dly_before_read; //for 512 cycle timout


//check if block traffic is set to 0
  rdata_s[31]=1;
  mmio_read64 (.addr_(tb_cfg0.PF0_BAR0 +  PROTOCOL_CHECKER_BASE_ADDR + 'h10), .data_(rdata_s));
 `uvm_info(get_full_name(), $psprintf("BLOCK_TRAFFIC rdata = %0h", rdata_s),UVM_LOW)

  if(rdata_s[31])
   `uvm_error(get_full_name(), $psprintf("BLOCK TRAFFIC is not de-asserted in more than 15us rdata = %0h" , rdata_s))
  else
   `uvm_info(get_name(), $psprintf("BLOCK TRAFFIC IS de-asserted, READY TO READ value of rdata = %0h", rdata_s), UVM_LOW)


// polling PORT_ERROR[2] for 5us.
   if(!rdata_s[2])
   `uvm_error(get_full_name(), "PORT ERROR is not asserted for 20us")
   else 
   `uvm_info(get_name(), $psprintf("PORT ERROR = %0h", rdata_s), UVM_LOW)
   if(|rdata_s[63:3] || |rdata_s[1:0])
   `uvm_info(get_full_name(), $psprintf("unexpected port error bit asserted! rdata = %0h", rdata_s),UVM_LOW);

// polling PORT_FIRST_ERROR[2] for 5us
  rdata_e = 0;
  
  `uvm_info(get_name(), $psprintf("PORT FIRST ERROR = %0h", rdata_e), UVM_LOW)
   mmio_read64 (.addr_(tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR + 'h18), .data_(rdata_e));
  `uvm_info(get_full_name(), $psprintf(" rdata = %0h", rdata_e),UVM_LOW)

  if(!rdata_e[2])
   `uvm_error(get_full_name(), "PORT FIRST ERROR is not asserted for 15us")
  else
   `uvm_info(get_name(), $psprintf("PORT FIRST ERROR = %0h", rdata_e), UVM_LOW)

  if(|rdata_e[63:3] || |rdata_e[1:0])
   `uvm_error(get_full_name(), $psprintf("unexpected port first error bit asserted! rdata_e = %0h", rdata_e))
  else
   `uvm_info(get_name(), $psprintf("PORT FIRST ERROR = %0h", rdata_e), UVM_LOW)
  
    tb_env0.afu_intf_regs.AFU_INTF_ERROR.read(status,rdata);  //backdoor read 
   `ifdef COV tb_env0.afu_intf_regs.AFU_INTF_ERROR.cg_vals.sample();`endif
    tb_env0.afu_intf_regs.AFU_INTF_FIRST_ERROR.read(status,rdata);
   `ifdef COV tb_env0.afu_intf_regs.AFU_INTF_FIRST_ERROR.cg_vals.sample();`endif
  

  //clear port

  addr = tb_cfg0.PF0_BAR0+  PROTOCOL_CHECKER_BASE_ADDR +'h10; //PORT_ERR_REG
  wdata = 'h4; 
  mmio_write64(addr,wdata); // DW address
  #5us;
  rdata ='h0;
  addr = tb_cfg0.PF0_BAR0+ PROTOCOL_CHECKER_BASE_ADDR +'h18; // FIRST_PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
 `uvm_info(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_FIRST_ERROR  rdata = %0h",rdata),UVM_LOW);

  if(|rdata)    
    `uvm_error(get_full_name(),$sformatf("CHECK THIS ERROR:-FIRST_PORT_ERROR is not clear rdata = %0h",rdata))

// clear_port_error(64'h0000_0004);   
    
endtask

task clear_port_error(bit [63:0] wdata = 64'hffff_ffff);
  //clear the port errors
  logic [63:0] addr;
  logic [63:0] rdata;

  addr = tb_cfg0.PF0_BAR0+ PROTOCOL_CHECKER_BASE_ADDR +'h10; //PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if (rdata[2])
    mmio_write64(addr,wdata); // DW address
  else
    `uvm_error(get_full_name(),$sformatf("PORT_ERROR_0 is already clear"));
    #1
    mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
 `uvm_error(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_ERROR is not clear rdata = %0h",rdata))
 
   mmio_read64 (.addr_(addr), .data_(rdata));
  `uvm_info(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_ERROR  rdata = %0h",rdata),UVM_LOW);
   #5us;
  rdata ='h0;
  addr = tb_cfg0.PF0_BAR0+ PROTOCOL_CHECKER_BASE_ADDR + 'h18; // FIRST_PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
 `uvm_info(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_FIRST_ERROR  rdata = %0h",rdata),UVM_LOW);

  if(|rdata)    
    `uvm_error(get_full_name(),$sformatf("CHECK THIS ERROR:-FIRST_PORT_ERROR is not clear rdata = %0h",rdata))

endtask

endclass : TxMWrDataPayloadOverrun_seq 
`endif
