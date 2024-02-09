//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class pcie_csr_seq is executed by pcie_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef PCIE_CSR_SEQ_SVH
`define PCIE_CSR_SEQ_SVH

class pcie_csr_seq extends base_seq;
    `uvm_object_utils(pcie_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

     parameter PCIE_SS_CMD_CSR = 32'h10028; 
     parameter MB_NOOP = 32'h0;
     parameter MB_RD = 32'h1;
     parameter MB_WR = 32'h2;

    parameter MB_WRDATA_OFFSET  = 32'hC;
    parameter MB_ADDRESS_OFFSET = 32'h4;
    parameter MB_RDDATA_OFFSET  = 32'h8;

    uvm_reg m_regs[$];
    string m_regs_a[string];
    bit [63:0] r_array[string] ;
    bit [63:0] w_array[string] ;
                     
    function new(string name = "pcie_csr_seq");
      super.new(name);
    endfunction : new

    task body();       
       logic [63:0] cur_pf_table;
       uvm_reg_data_t wdata, rdata;
       uvm_status_e   status;
       super.body();

	m_regs_a["PCIE_STAT"] = "PCIE_STAT_REG";
	m_regs_a["PCIE_SS_CMD_CSR"] = "PCIE_SS_CMD_CSR_REG";
	m_regs_a["PCIE_SS_DATA_CSR"] = "PCIE_SS_DATA_CSR_REG";
        tb_env0.pcie_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
	wr_rd_cmp(m_regs,m_regs_a,w_array);
 
     //==================================================
     // Access PCIE_SS Registers using Mailbox Registers PCIE_SS_CMD_CSR,PCIE_SS_DATA_CSR
     //==================================================
     
     wdata='hFFFFFFFF_FFFFFFFF ;
    `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h","PCIE_SS_CMD_CSR" ,wdata), UVM_LOW)
     tb_env0.pcie_regs.PCIE_SS_CMD_CSR.write(status,wdata);
     tb_env0.pcie_regs.PCIE_SS_CMD_CSR.read(status,rdata);
      `ifdef COV tb_env0.pcie_regs.PCIE_SS_CMD_CSR.cg_vals.sample();`endif
     
     wdata='h0 ;
    `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h","PCIE_SS_CMD_CSR" ,wdata), UVM_LOW)
     tb_env0.pcie_regs.PCIE_SS_CMD_CSR.write(status,wdata);
     tb_env0.pcie_regs.PCIE_SS_CMD_CSR.read(status,rdata);
      `ifdef COV tb_env0.pcie_regs.PCIE_SS_CMD_CSR.cg_vals.sample();`endif
     
     wdata='hFFFFFFFF_FFFFFFF1 ;
    `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h","PCIE_SS_DATA_CSR" ,wdata), UVM_LOW)
     
     write_mailbox(tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00800,wdata);                      // PERFMONCTRL = 18'h00800 RW
     read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00800,rdata);      
//Compare data        
     if(rdata[10:0] !== wdata[10:0])
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE_SS_DATA_CSR",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","PCIE_SS_DATA_CSR",wdata, rdata), UVM_LOW)
          
     wdata='h0 ;
    `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h","PCIE_SS_DATA_CSR" ,wdata), UVM_LOW)
     
     write_mailbox(tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00800,wdata);                      // PERFMONCTRL = 18'h00800 RW
     read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00800,rdata);      
//Compare data        
     if(rdata[10:0] !== wdata[10:0])
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE_SS_DATA_CSR",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","PCIE_SS_DATA_CSR",wdata, rdata), UVM_LOW)
     wdata='hFFFFFFFF_FFFFFFFF ;
    `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h","PCIE_SS_DATA_CSR" ,wdata), UVM_LOW)

     read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00804,rdata);      
     write_mailbox(tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00804,wdata);                      // TX_MWR_TLP = 18'h00804 RW1C
     read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00804,rdata);      
//Compare data        
    if(rdata[31:0] !== 32'h0)
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE_SS_DATA_CSR",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","PCIE_SS_DATA_CSR",wdata, rdata), UVM_LOW)
   
     write_mailbox(tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00018,wdata);                      // ERR_TLP_HEADER = 18'h00018 RW
     read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h00018,rdata);      
//Compare data        
    if(rdata[31:0] !== wdata[63:32])
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE_SS_DATA_CSR",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","PCIE_SS_DATA_CSR",wdata, rdata), UVM_LOW)

     read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h0042C,rdata);       
     write_mailbox(tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h0042C,wdata);                      // HIP_BP_CYCLES = 18'h0042C RW1C
     read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h0042C,rdata);       
//Compare data        
    if(rdata[31:0] !== 32'h0)
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE_SS_DATA_CSR",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","PCIE_SS_DATA_CSR",wdata, rdata), UVM_LOW)
   

    endtask : body

    task write_mailbox();
        input [63:0] cmd_ctrl_addr;
	      input [63:0] addr;
	      input [63:0] write_data32;
	  begin
	     bit [63:0] rdata = 64'h0;
       uvm_status_e       status;

             mmio_write32(cmd_ctrl_addr + MB_WRDATA_OFFSET , write_data32);
             tb_env0.pcie_regs.PCIE_SS_DATA_CSR.read(status,rdata);                  
            `ifdef COV tb_env0.pcie_regs.PCIE_SS_DATA_CSR.cg_vals.sample();`endif    
             mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr      );
             mmio_write32(cmd_ctrl_addr                    , MB_WR       );  //write Cmd
	     read_ack_mailbox(cmd_ctrl_addr);
             mmio_write32(cmd_ctrl_addr                    , MB_NOOP     );
	  end
    endtask : write_mailbox

  task read_mailbox;
    input  logic [63:0] cur_pf_table;
    input  logic [31:0] bar;
    input  logic [63:0] cmd_ctrl_addr; // Start address of mailbox access reg
    input  logic [63:0] addr; //Byte address
    output logic [63:0] rd_data64;
    begin
      bit [63:0] rdata = 64'h0;
      uvm_status_e       status;
      mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr); // DW address
      mmio_write32(cmd_ctrl_addr, MB_RD); // read Cmd
      read_ack_mailbox(cmd_ctrl_addr);
      tb_env0.pcie_regs.PCIE_SS_DATA_CSR.read(status,rd_data64);                  
     `ifdef COV tb_env0.pcie_regs.PCIE_SS_DATA_CSR.cg_vals.sample();`endif    
      $display("INFO: Read MAILBOX ADDR:%x, READ_DATA64:%X", addr, rd_data64);
      mmio_write32(cmd_ctrl_addr, MB_NOOP); // no op Cmd
    end
  endtask : read_mailbox

    task read_ack_mailbox;
        input bit [63:0] cmd_ctrl_addr;
     begin
	     bit [63:0] rdata = 64'h0;
             uvm_status_e       status;
	     int        rd_attempts = 0;
	     bit        ack_done_reg = 0;
	     while(~ack_done_reg && rd_attempts < 7) begin
                      tb_env0.pcie_regs.PCIE_SS_CMD_CSR.read(status,rdata); 
		      ack_done_reg = rdata[2];
		      rd_attempts++;
	     end
            `ifdef COV tb_env0.pcie_regs.PCIE_SS_CMD_CSR.cg_vals.sample();`endif 
	     if(~ack_done_reg)
	        `uvm_error(get_name(), "Did not ACK for last transaction!")

    	end
    endtask : read_ack_mailbox

endclass : pcie_csr_seq

`endif // PCIE_CSR_SEQ_SVH
