//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class UnexpMMIORspErr_seq is executed by UnexpMMIORspErr_test
 * 
 * This sequence verifies the Error vector mechanism of protocol-checker block  
 * To generate the error , the corrupt transactions are forced
 * The sequence monitors the error register is set or not 
 * Error is clear using the soft_reset
 *
 */
//===============================================================================================================

`ifndef UNEXPMMIORSPERR_SVH
`define UNEXPMMIORSPERR_SVH


class UnexpMMIORspErr_seq extends base_seq;

  `uvm_object_utils(UnexpMMIORspErr_seq)

  function new(string name = "UnexpMMIORspErr_seq");
     super.new(name); 
  endfunction    
    
  virtual task body();
     pcie_rd_mmio_seq mmio_rd;
     bit[63:0] rdata,rdata_s,regdata;
     uvm_status_e       status;
     uvm_reg_data_t     reg_data;
     int                timeout;
     time dly_after_err  = 15us;
     time dly_rst_window = 1us;
     time dly_before_read =30us;  //512 timout cycle instead of 28us wating for 30us
     logic[63:0] addr;
     super.body();
  
  fork
     begin
       addr = tb_cfg0.PF0_BAR0+ HSSI_BASE_ADDR+'h68; //HSSI_PORT0_STATUS
       mmio_read32 (.addr_(addr), .data_(regdata));

     `uvm_info(get_name(), $psprintf("Data_64 addr = %0h, regdata = %0h", addr, regdata), UVM_LOW)
     end
     begin
     force {`AFU_TOP.afu_intf_inst.afu_axis_tx.tdata[79:72]} = 8'h3E; //TAG field
     @(negedge `AFU_TOP.afu_intf_inst.afu_axis_tx.tvalid);
     release {`AFU_TOP.afu_intf_inst.afu_axis_tx.tdata[79:72]};
     end
  join_any

  #dly_after_err;

  port_rst_assert(); //write 05 
  #dly_rst_window;
  release_port_rst ();
  #dly_before_read; //for 512 cycle timout
 

 //check if block traffic is set to 0
 rdata_s[31]=1;

 fork
   begin
     while(rdata_s[31]) begin
      mmio_read64 (.addr_(tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR + 'h10), .data_(rdata_s));
     `uvm_info(get_full_name(), $psprintf("BLOCK_TRAFFIC rdata = %0h", rdata_s),UVM_LOW)
     end
    `uvm_info(get_name(), $psprintf("BLOCK_TRAFFIC = %0h", rdata_s), UVM_LOW)
   end
   begin
      #15us;
   end
 join_any

 if(rdata_s[31])
   `uvm_error(get_full_name(), $psprintf("BLOCK TRAFFIC is not de-asserted in more than 15us rdata = %0h" , rdata_s))
 else
   `uvm_info(get_name(), $psprintf("BLOCK TRAFFIC IS de-asserted, READY TO READ value of rdata = %0h", rdata_s), UVM_LOW)

  // polling PORT_ERROR[8] for 5us.
  rdata = 0;
    fork
     begin
       while(!rdata[8]) begin
            `uvm_info(get_name(), $psprintf("value of rdata in while rdata= %0h", rdata), UVM_LOW)
           `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
            mmio_rd.rd_addr == tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR + 'h10;
            mmio_rd.rlen    == 2;
            mmio_rd.l_dw_be == 4'b1111;
          })
          rdata = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
           
     end
        `uvm_info(get_name(), $psprintf("value of rdata rdata= %0h", rdata), UVM_LOW)
       end
       begin
          #7us;
       end
   join_any

   if(!rdata[8])
       `uvm_error(get_full_name(), "PORT ERROR is not asserted for 7us")
   else
       `uvm_info(get_name(), $psprintf("value of rdata = %0h", rdata), UVM_LOW)

   if(|rdata[63:9] || |rdata[7:0])
       `uvm_info(get_name(), $psprintf("unexpected port error bit asserted! rdata = %0h", rdata), UVM_LOW)



   // polling PORT_FIRST_ERROR[8] for 5us
   rdata = 0;
   fork
   begin
     while(!rdata[8]) begin
          `uvm_info(get_name(), $psprintf("value of rdata after while rdata= %0h", rdata), UVM_LOW)
          `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
            mmio_rd.rd_addr == tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR + 'h18;
            mmio_rd.rlen    == 2;
            mmio_rd.l_dw_be == 4'b1111;
          })
          rdata = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
   end 
      `uvm_info(get_name(), $psprintf("value of rdata rdata= %0h", rdata), UVM_LOW)    
     end
     begin
         #7us;
     end
  join_any

  if(!rdata[8])
      `uvm_error(get_full_name(), "PORT FIRST ERROR is not asserted for 7us")
  else
      `uvm_info(get_name(), $psprintf("value of rdata = %0h", rdata), UVM_LOW)

  if(|rdata[63:9] || |rdata[6:0])
      `uvm_error(get_full_name(), $psprintf("unexpected first port error bit asserted! rdata = %0h", rdata))

	    tb_env0.afu_intf_regs.AFU_INTF_ERROR.read(status,rdata);  //backdoor read 
       `ifdef COV tb_env0.afu_intf_regs.AFU_INTF_ERROR.cg_vals.sample();`endif
        tb_env0.afu_intf_regs.AFU_INTF_FIRST_ERROR.read(status,rdata);
       `ifdef COV tb_env0.afu_intf_regs.AFU_INTF_FIRST_ERROR.cg_vals.sample();`endif

 #10us

  clear_port_error(64'h0000_0180);
   
endtask


task clear_port_error(bit [63:0] wdata = 64'hffff_ffff);
  //clear the port errors
  logic [63:0] addr;
  logic [63:0] rdata;

  addr = tb_cfg0.PF0_BAR0+ PROTOCOL_CHECKER_BASE_ADDR +'h10; //PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if (rdata[8])
    mmio_write64(addr,wdata); // DW address
  else
    `uvm_error(get_full_name(),$sformatf("PORT_ERROR_0 is already clear"))
    #1
    mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
    `uvm_info(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_ERROR is not clear rdata = %0h",rdata),UVM_LOW)
   #5us;
  rdata ='h0;
  addr = tb_cfg0.PF0_BAR0+  PROTOCOL_CHECKER_BASE_ADDR +'h18; // FIRST_PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
    `uvm_error(get_full_name(),$sformatf("CHECK THIS ERROR:-FIRST_PORT_ERROR is not clear rdata = %0h",rdata))

endtask



endclass : UnexpMMIORspErr_seq 

`endif
