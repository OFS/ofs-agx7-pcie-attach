//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class MMIOTimedOut_seq is executed by MMIOTimedout_test
 * 
 * This sequence verifies the Error vector mechanism of protocol-checker block  
 * To generate the error , the corrupt transactions are forced
 * The sequence monitors the error register is set or not 
 * Error is clear using the soft_reset
 *
 */
//===============================================================================================================

`ifndef MMIOTIMEDOUT_SEQ_SVH
`define MMIOTIMEDOUT_SEQ_SVH

class MMIOTimedOut_seq extends base_seq;

  `uvm_object_utils(MMIOTimedOut_seq)

   function new(string name = "MMIOTimedOut_seq");
      super.new(name); 
   endfunction    
    
   virtual task body();
      pcie_rd_mmio_seq mmio_rd;
      bit[63:0] rdata = 0;
      bit[63:0] wdata = 0;
      bit[63:0] rdata_s = 1;
      uvm_status_e       status;
      uvm_reg_data_t     reg_data;
      int                timeout;
      time dly_after_err  = 15us;
      time dly_rst_window = 1us;
      time dly_before_read =30us; //512 timout cycle instead of 28us wating for 30us
      logic[63:0] addr;
      super.body();
  
  fork
     begin
       addr = tb_cfg0.PF0_BAR0 + HSSI_BASE_ADDR +'hc0; //HSSI_PORT0_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      `uvm_info(get_name(), $psprintf("Data_64 addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     end
     begin
      force {`AFU_TOP.afu_intf_inst.afu_axis_tx.tvalid} = 0;
      #10us;
      release {`AFU_TOP.afu_intf_inst.afu_axis_tx.tvalid};
      end
  join_any
  
   #dly_after_err;


   //using soft_reset

  port_rst_assert(); //write 05 
  #dly_rst_window;  // not sure when ack will assert 
  release_port_rst ();
  #dly_before_read; //for 512 cycle timout
 

//check if block traffic is set to 0
rdata_s[31]=1;

 fork
   begin
    while(rdata_s[31]) begin
      mmio_read64 (.addr_(tb_cfg0.PF0_BAR0 +PROTOCOL_CHECKER_BASE_ADDR + 'h10), .data_(rdata_s));
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

// polling PORT_ERROR[4] for 5us.
rdata=0;
 fork
   begin
    while(!rdata[7]) begin
      mmio_read64 (.addr_(tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR+ 'h10), .data_(rdata));
     `uvm_info(get_full_name(), $psprintf("PORT0 rdata = %0h", rdata),UVM_LOW)
    end
    `uvm_info(get_name(), $psprintf("value of rdata - PORT ERROR = %0h", rdata), UVM_LOW)
  end
    begin
      #15us;
    end
 join_any

 if(!rdata[7])
   `uvm_error(get_full_name(), $psprintf("PORT ERROR is not asserted for 15us rdata = %0h" , rdata))
 else
   `uvm_info(get_name(), $psprintf("value of rdata = %0h", rdata), UVM_LOW)

 if(|rdata[63:8] || |rdata[6:0])
   `uvm_info(get_full_name(), $psprintf("unexpected port error bit asserted! rdata = %0h", rdata),UVM_LOW)

// polling PORT_FIRST_ERROR[7] for 5us
rdata = 0;
 fork
  begin
    while(!rdata[7]) begin
      mmio_read64 (.addr_(tb_cfg0.PF0_BAR0 +PROTOCOL_CHECKER_BASE_ADDR + 'h18), .data_(rdata));
     `uvm_info(get_full_name(), $psprintf("PORT1 rdata = %0h", rdata),UVM_LOW)
    end
    `uvm_info(get_name(), $psprintf("value of rdata - PORT FIRST ERROR = %0h", rdata), UVM_LOW)
  end
     begin
     #15us;
   end
 join_any

 if(!rdata[7])
   `uvm_error(get_full_name(), $psprintf("PORT FIRST ERROR is not asserted for 15us"))
 else
   `uvm_info(get_name(), $psprintf("value of rdata = %0h", rdata), UVM_LOW)

 if(|rdata[63:8] || |rdata[6:0])
   `uvm_error(get_full_name(), $psprintf("unexpected port first error bit asserted! rdata = %0h", rdata))

	    tb_env0.afu_intf_regs.AFU_INTF_ERROR.read(status,rdata);  //backdoor read 
       `ifdef COV tb_env0.afu_intf_regs.AFU_INTF_ERROR.cg_vals.sample();`endif
        tb_env0.afu_intf_regs.AFU_INTF_FIRST_ERROR.read(status,rdata);
       `ifdef COV tb_env0.afu_intf_regs.AFU_INTF_FIRST_ERROR.cg_vals.sample();`endif

 #10us
  clear_port_error(64'h0000_0080);
 
endtask

task clear_port_error(bit [63:0] wdata = 64'hffff_ffff);
  //clear the port errors
  logic [63:0] addr;
  logic [63:0] rdata;

  addr = tb_cfg0.PF0_BAR0+ PROTOCOL_CHECKER_BASE_ADDR +'h10; //PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if (rdata[7])
    mmio_write64(addr,wdata); // DW address
  else
    `uvm_error(get_full_name(),$sformatf("PORT_ERROR_0 is already clear"));
    #1
    mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
    `uvm_info(get_full_name(),$sformatf("CHECK THIS ERROR:-PORT_ERROR is not clear rdata = %0h",rdata),UVM_LOW);
   #5us;
  rdata ='h0;
  addr = tb_cfg0.PF0_BAR0+ PROTOCOL_CHECKER_BASE_ADDR +'h18; // FIRST_PORT_ERR_REG
  mmio_read64 (.addr_(addr), .data_(rdata));
  if(|rdata)    
    `uvm_error(get_full_name(),$sformatf("CHECK THIS ERROR:-FIRST_PORT_ERROR is not clear rdata = %0h",rdata));

endtask

endclass : MMIOTimedOut_seq 

`endif








