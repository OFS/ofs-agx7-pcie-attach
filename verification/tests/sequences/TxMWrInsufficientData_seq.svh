//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class TxMWrInsufficientData_seq is executed by TxMWrInsufficientData_test
 * 
 * This sequence verifies the Error vector mechanism of protocol-checker block  
 * To generate the error , the corrupt transactions are forced
 * The sequence monitors the error register is set or not 
 * Error is clear using the soft_reset
 *
 */
//===============================================================================================================

`ifndef TXMWRINSUFFICIENTDATA_SEQ_SVH
`define TXMWRINSUFFICIENTDATA_SEQ_SVH

class TxMWrInsufficientData_seq extends he_lpbk_wr_seq;

 `uvm_object_utils(TxMWrInsufficientData_seq)
 `uvm_declare_p_sequencer(virtual_sequencer)
    
  constraint num_lines_c { num_lines == 512; }
  constraint req_len_c { req_len == 2'b10; }
  constraint ral_mode {ral_mode_prtcl == 2'b1;}

 function new(string name = "TxMWrInsufficientData_seq");
    super.new(name); 
 endfunction    
    
 virtual task body();
    bit [63:0]   rdata, addr,rdata_s;
    pcie_rd_mmio_seq mmio_rd;
    uvm_status_e       status;
    uvm_reg_data_t     reg_data;
    int                timeout;
    time dly_after_err  = 5us;
    time dly_rst_window = 1us;
    time dly_before_read =30us; //512 timout cycle instead of 28us wating for 30us

   `uvm_info(get_name(),"Insufficient Data-Entered the sequence", UVM_LOW)

 fork 
   begin
      super.body();
   end
   begin
    wait(`AFU_TOP.afu_intf_inst.i_afu_softreset == 0)begin
       #5us;
       do begin
       mmio_read64 (.addr_(tb_cfg0.HE_LB_BASE +'h138), .data_(rdata));	
      `uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)
       end while(rdata != 64'h3);
    wait(`AFU_TOP.afu_intf_inst.afu_axis_tx.tdata[31:24]==8'h60 && `AFU_TOP.afu_intf_inst.afu_axis_tx.tvalid == 1 && `AFU_TOP.afu_intf_inst.afu_axis_tx.tuser_vendor[0] == 10'h1)
      begin
      force `AFU_TOP.afu_intf_inst.afu_axis_tx.tdata[9:0] = 10'd65;  
      `uvm_info(get_name(),"force", UVM_LOW)
      @ (negedge `AFU_TOP.afu_intf_inst.afu_axis_tx.tvalid or negedge `AFU_TOP.afu_intf_inst.afu_axis_tx.tready) begin
       #50ns;
      release {`AFU_TOP.afu_intf_inst.afu_axis_tx.tdata[9:0]};

        `uvm_info(get_name(),"release", UVM_LOW)
        #50ns;
        end
       end
     end 
   end
 join_any
    
 #dly_after_err;  


//using soft_reset

  port_rst_assert(); //write 05 
  // de-assert reset as fast as possiable.
  release_port_rst ();
  #dly_before_read; //for 512 cycle timout


// If BLOCK_TRAFFIC is not cleared after #dly_before_read (30us) than fail the test.
  `uvm_info(get_name(), $psprintf("START READ TIME."), UVM_LOW)
  mmio_read64 (.addr_(tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR + 'h10), .data_(rdata_s));
  `uvm_info(get_full_name(), $psprintf("END READ TIME. BLOCK_TRAFFIC rdata = %0h", rdata_s),UVM_LOW)
  if(rdata_s[31])
    `uvm_error(get_full_name(), $psprintf("BLOCK TRAFFIC is not de-asserted in more than 30us rdata = %0h" , rdata_s))
  else
    `uvm_info(get_name(), $psprintf("BLOCK TRAFFIC IS de-asserted, READY TO READ value of rdata = %0h", rdata_s), UVM_LOW)

`uvm_info(get_name(), "POLLING_ERR_BIT", UVM_LOW)  

// polling PORT_ERROR[11] for 5us.

rdata=0;

 fork
   begin
    while(!rdata[1]) begin
        `uvm_info(get_name(), $psprintf("value of rdata in while PORT ERROR = %0h", rdata), UVM_LOW)
    `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
     mmio_rd.rd_addr == tb_cfg0.PF0_BAR0 +  PROTOCOL_CHECKER_BASE_ADDR +'h10;
     mmio_rd.rlen    == 2;
     mmio_rd.l_dw_be == 4'b1111;
     })
     rdata = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
     end
     `uvm_info(get_name(), $psprintf("value of rdata - PORT ERROR = %0h", rdata), UVM_LOW)
   end
   begin
     #30us;
   end
 join_any

 if(!rdata[1])
   `uvm_error(get_full_name(), "PORT ERROR is not asserted for 5us")
   else
       `uvm_info(get_name(), $psprintf("value of rdata = %0h", rdata), UVM_LOW)

 if(|rdata[63:2] || |rdata[0])
   `uvm_info(get_full_name(),$sformatf("unexpected port error bit asserted! rdata = %0h", rdata),UVM_LOW);

// polling PORT_FIRST_ERROR[11] for 5us
  rdata = 0;
 fork

 begin
   while(!rdata[1]) begin
    `uvm_info(get_name(), $psprintf("value of rdata in while PORT FIRST ERROR = %0h", rdata), UVM_LOW)
    `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
     mmio_rd.rd_addr == tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR + 'h18;
     mmio_rd.rlen    == 2;
     mmio_rd.l_dw_be == 4'b1111;
     })
     rdata = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
   end
    `uvm_info(get_name(), $psprintf("value of rdata - PORT FIRST ERROR = %0h", rdata), UVM_LOW)
    end

   begin
     #30us;
   end
 join_any

 if(!rdata[1])
    `uvm_error(get_full_name(), "PORT FIRST ERROR is not asserted for 5us")
 else
      `uvm_info(get_name(), $psprintf("value of rdata = %0h", rdata), UVM_LOW)

 if(|rdata[63:2] || |rdata[0])
   `uvm_error(get_full_name(), $psprintf("unexpected port first error bit asserted! rdata = %0h", rdata))
   
 
  tb_env0.afu_intf_regs.AFU_INTF_ERROR.read(status,rdata);  //backdoor read 
 `ifdef COV tb_env0.afu_intf_regs.AFU_INTF_ERROR.cg_vals.sample();`endif
  tb_env0.afu_intf_regs.AFU_INTF_FIRST_ERROR.read(status,rdata);
 `ifdef COV tb_env0.afu_intf_regs.AFU_INTF_FIRST_ERROR.cg_vals.sample();`endif
 
 clear_port_error(64'h0000_0002); 
    
 `uvm_info(get_full_name(),$sformatf("Port Reset Done...."),UVM_LOW);

 `uvm_info(get_name(),"Insufficient Data-Exiting the sequence", UVM_LOW)

endtask

task clear_port_error(bit [63:0] wdata = 64'hffff_ffff);
  //clear the port errors
  logic [63:0] addr;
  logic [63:0] rdata;

  addr = tb_cfg0.PF0_BAR0+  PROTOCOL_CHECKER_BASE_ADDR +'h10; //PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if (rdata[1])
    mmio_write64(addr,wdata); // DW address
  else
    `uvm_error(get_full_name(),$sformatf("PORT_ERROR_0 is already clear"))
    #1
    mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
    `uvm_info(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_ERROR is not clear rdata = %0h",rdata),UVM_LOW)
   #5us;
  rdata ='h0;
  addr = tb_cfg0.PF0_BAR0+ PROTOCOL_CHECKER_BASE_ADDR +'h18; // FIRST_PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
    `uvm_error(get_full_name(),$sformatf("CHECK THIS ERROR:-FIRST_PORT_ERROR is not clear rdata = %0h",rdata))

endtask

endclass : TxMWrInsufficientData_seq

`endif
