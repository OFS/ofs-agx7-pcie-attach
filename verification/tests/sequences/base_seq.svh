//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class base_seq is common base sequence all the sequences are extended from this sequence 
 * 
 * This sequence starts the config_seq ,where BAR addresses are allocated 
 * The MMIO_RD/WR , VDM PKT generation tasks are implemented in this sequence
 *
 * Sequence is running on virtual_sequencer 
 *
 */
//===============================================================================================================

`ifndef BASE_SEQ_SVH
`define BASE_SEQ_SVH

`include "tb_env.svh"
class base_seq extends uvm_sequence;
    `uvm_object_utils(base_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
    // index by start_addr, value is size of the mem blockx
    `include "VIP/vip_task.sv"
`ifdef INCLUDE_CVL
     parameter PCIE_SS_CMD_CSR = 32'h10028; 
     parameter MB_NOOP = 32'h0;
     parameter MB_RD = 32'h1;
     parameter MB_WR = 32'h2;
  
     parameter MB_WRDATA_OFFSET  = 32'hC;
     parameter MB_ADDRESS_OFFSET = 32'h4;
     parameter MB_RDDATA_OFFSET  = 32'h8;
`endif
    static int mem_pool[bit [63:0]];
      rand bit bypass_config_seq;
 
    tb_config          tb_cfg0;
    config_seq config_seq_;
    tb_env   tb_env0;

     
    typedef struct {
        bit [63:0]  pf0_bar0;
        bit [63:0]  he_lb_base;
        bit [63:0]  he_mem_base;
		bit [63:0]  he_hssi_base;

        }st_base_addr;

    st_base_addr st_addr; 

         constraint bypass_config_seq_c { soft bypass_config_seq == 0; }

    function new(string name = "base_seq");
        super.new(name);
        get_tb_env();
    endfunction : new

    task body();
        super.body();

        tb_cfg0 = new();
        tb_cfg0 = tb_env0.getCfg();
        tb_cfg0.print();
        if(!bypass_config_seq)begin
            config_seq_ = config_seq::type_id::create("config_seq_");
            config_seq_.tb_cfg0 = this.tb_cfg0;
            config_seq_.start(p_sequencer);
            cfg_port_rst_assert();  //SOFT_RESET_APPLIED
            cfg_release_port_rst(); //SOFT_RESET_RELEASED
         `ifndef INCLUDE_CVL
           tb_cfg0.PF0_VF1_BAR0 = tb_cfg0.PF0_VF0_BAR0 + (2 ** enumerate_seq::vf_size_index);
           tb_cfg0.PF0_VF2_BAR0 = tb_cfg0.PF0_VF1_BAR0 + (2 ** enumerate_seq::vf_size_index);
           tb_cfg0.HE_HSSI_BASE = tb_cfg0.PF0_VF1_BAR0;
           tb_cfg0.HE_MEM_TG_BASE = tb_cfg0.PF0_VF2_BAR0;
         `endif

            st_addr.pf0_bar0=tb_cfg0.PF0_BAR0;
            st_addr.he_lb_base=tb_cfg0.HE_LB_BASE;
            st_addr.he_mem_base=tb_cfg0.HE_MEM_BASE;
            st_addr.he_hssi_base=tb_cfg0.HE_HSSI_BASE;
            
            uvm_config_db#(bit[63:0])::set(uvm_root::get(),"*","pf0_bar0", st_addr.pf0_bar0);
            uvm_config_db#(bit[63:0])::set(uvm_root::get(),"*","he_lb_base", st_addr.he_lb_base);
            uvm_config_db#(bit[63:0])::set(uvm_root::get(),"*","he_mem_base", st_addr.he_mem_base);
            uvm_config_db#(bit[63:0])::set(uvm_root::get(),"*","he_hssi_base", st_addr.he_hssi_base);


           `uvm_info("", $psprintf("pf0_bar0       %8h", st_addr.pf0_bar0)    , UVM_LOW)
           `uvm_info("", $psprintf("he_lb_base     %8h", st_addr.he_lb_base)  , UVM_LOW)
           `uvm_info("", $psprintf("he_mem_base    %8h", st_addr.he_mem_base) , UVM_LOW)
		  `uvm_info("", $psprintf("he_hssi_base   %8h", st_addr.he_hssi_base), UVM_LOW)


        end
    endtask : body
`ifdef INCLUDE_CVL  
   task write_mailbox();
        input [63:0] cmd_ctrl_addr;
	      input [63:0] addr;
	      input [63:0] write_data32;
	  begin
	     bit [63:0] rdata = 64'h0;
       uvm_status_e       status;

             mmio_write32(cmd_ctrl_addr + MB_WRDATA_OFFSET , write_data32);
             tb_env0.pcie_regs.PCIE_SS_DATA_CSR.read(status,rdata);                  
            //`ifdef COV tb_env0.pcie_regs.PCIE_SS_DATA_CSR.cg_vals.sample();`endif    
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
      //mmio_read64(cmd_ctrl_addr + MB_RDDATA_OFFSET, rd_data64);
      tb_env0.pcie_regs.PCIE_SS_DATA_CSR.read(status,rd_data64);                  
     //`ifdef COV tb_env0.pcie_regs.PCIE_SS_DATA_CSR.cg_vals.sample();`endif    
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
          //mmio_read64(cmd_ctrl_addr, rdata);
          tb_env0.pcie_regs.PCIE_SS_CMD_CSR.read(status,rdata); 
		      ack_done_reg = rdata[2];
		      rd_attempts++;
	     end
        //  `ifdef COV tb_env0.pcie_regs.PCIE_SS_CMD_CSR.cg_vals.sample();`endif 
             
	    if(~ack_done_reg)
	        `uvm_error(get_name(), "Did not ACK for last transaction!")

    	end
    endtask : read_ack_mailbox

`endif
    // below utility tasks will be phased out when RAL is ready
   task mmio_write32(input bit [63:0] addr_, input bit [31:0] data_, input bit is_soc_ = 1);
      mmio_pcie_write32(.addr_(addr_) , .data_(data_), .is_soc_(is_soc_));       
   endtask : mmio_write32 

    task mmio_write64(input bit [63:0] addr_, input bit [63:0] data_, input bit is_soc_ = 1);
      mmio_pcie_write64(.addr_(addr_) , .data_(data_), .is_soc_(is_soc_));       
    endtask : mmio_write64


    task mmio_read32_blocking(input bit [63:0] addr_, output bit [31:0] data_, input bit is_soc_ = 1);
      mmio_pcie_read32_blocking(.addr_(addr_) , .data_(data_), .is_soc_(is_soc_));       
    endtask : mmio_read32_blocking


    task mmio_read32(input bit [63:0] addr_, output bit [31:0] data_, input bit is_soc_ = 1);
          mmio_pcie_read32(.addr_(addr_) , .data_(data_), .is_soc_(is_soc_));       
    endtask : mmio_read32

    task mmio_read64_blocking(input  bit [63:0] addr_, output bit [63:0] data_, input bit is_soc_ = 1);
      mmio_pcie_read64_blocking(.addr_(addr_) , .data_(data_), .is_soc_(is_soc_));       
    endtask:mmio_read64_blocking


    task mmio_read64(input  bit [63:0] addr_, output bit [63:0] data_, input bit is_soc_ = 1);
      mmio_pcie_read64(.addr_(addr_) , .data_(data_), .is_soc_(is_soc_));       
    endtask : mmio_read64

    task host_mem_write (input  bit [63:0] addr_,  input bit [31:0] data_ [], input int unsigned len ,input bit is_soc_ = 1);
       host_pcie_mem_write(.addr_(addr_) , .data_(data_),.len(len), .is_soc_(is_soc_));
    endtask : host_mem_write

    
    task host_mem_read (input  bit [63:0] addr_, output bit [31:0] data_ [] ,input int unsigned len , input bit is_soc_ = 1);
       host_pcie_mem_read(.addr_(addr_) , .data_(data_),.len(len), .is_soc_(is_soc_));
    endtask : host_mem_read
    
    task rd_tx_register(input [17:0] address,input [63:0] rdata);                              
      qsfp_axi_master_read(.address(address), .ex_rdata(rdata));
    endtask:rd_tx_register
  
    task wr_tx_register(input [17:0] address,input [63:0] wdata,input [7:0] wstrobe);             
      qsfp_axi_master_write(.address(address), .wdata(wdata), .wstrobe(wstrobe));
    endtask:wr_tx_register

    
//FLR

    task flr_cfg_rd(input bit[63:0] address_, output bit [31:0] dev_ctl_, input bit is_soc_ =1);
         flr_pcie_cfg_rd (.address_(address_) , .dev_ctl_(dev_ctl_), .is_soc_(is_soc_));        
    endtask : flr_cfg_rd 


    task flr_cfg_wr(input bit[63:0] address_, input bit [31:0] dev_ctl_,input bit is_soc_ =1);
         flr_pcie_cfg_wr (.address_(address_) , .dev_ctl_(dev_ctl_), .is_soc_(is_soc_));        
    endtask : flr_cfg_wr
 
   

    function [31:0] changeEndian;   //transform data from the memory to big-endian form
        input [31:0] value;
        changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
    endfunction

 //Accessing Env handle
  virtual function void get_tb_env();                
        uvm_component   comp;

        comp = uvm_top.find("uvm_test_top.tb_env0"); 
        assert(comp) else uvm_report_fatal("ofs_fpga_ac_base_seq", "failed finding tb_env0"); 
        
        assert ($cast(tb_env0, comp)) else 
        uvm_report_fatal("ofs_fpga_ac_base_seq", "failed in obtaining tb_env0!");
    endfunction

// Allocate the memory and return the start address
    function bit [63:0] alloc_mem(int size, bit low32 = 0);
        bit [63:0] m_addr;
	std::randomize(m_addr) with {
	    m_addr[11:0] == 0;

	    // Avoid addresses higher than the available physical/virtual address
	    // ranges.
	    m_addr[63:48] == 0;

	    if(low32) {
	        m_addr[63:32] == 32'h0;
	    }
	    foreach(mem_pool[i]) {
	        !(m_addr inside {[i:i+'h40*mem_pool[i]]}); 
	    }
	    (m_addr + 'h40*size) < 64'hffff_ffff_ffff_ffff;
	};
	mem_pool[m_addr] = size;
        return m_addr;
    endfunction : alloc_mem

    // De-allocate the memory with start address and size of the memory
    function void dealloc_mem(bit [63:0] start_addr);
        mem_pool.delete(start_addr);
    endfunction : dealloc_mem


// TYPE1 VDM SEQUENCE
// TARGET ID - 0
// VENDOR ID - 16'h1AB4
// MCTP HEADER - 32'h01FF00C0

   task vdm_random_msg(input bit[9:0] length_,input bit routing_type_,input bit [7:0] dest_id );
      pcie_vdm_random_msg(.length_(length_) , .routing_type_(routing_type_), .dest_id(dest_id));       
   endtask : vdm_random_msg 
   
   task vdm_random_multi_msg(input bit[9:0] length_,input bit routing_type_,input bit [7:0] dest_id ,input bit [1:0] pos_pkt,input bit [1:0] num_ctr );
      pcie_vdm_random_multi_msg(.length_(length_) , .routing_type_(routing_type_), .dest_id(dest_id), .pos_pkt(pos_pkt), .num_ctr(num_ctr));       
   endtask : vdm_random_multi_msg 

   task vdm_err_msg(input bit[9:0] length_);
      pcie_vdm_err_msg(.length_(length_));       
   endtask :vdm_err_msg 

//task used to check the reset value of accessed CSR through RAL
//uvm_reg, used to describe registers
//b_regs, used to skip/comapre the specific rdata value of the accessed CSR
//array_r, used to pass the expected default value   
   virtual task check_reset_value(uvm_reg m_regs[$],string b_regs[string], bit [63:0] array_r[string]);
      string a_var;
      uvm_reg_data_t rdata, exp_val;
      uvm_status_e   status;

      `uvm_info(get_name(),"Entering check_reset task...", UVM_LOW)
      foreach(m_regs[i]) begin
        `uvm_info(get_name(), $psprintf("Method check_reset_value: reg = %s, b_regs.size() = %0d, array_r.size() = %0d  ", m_regs[i].get_name(), b_regs.size(),array_r.size()), UVM_LOW)
        if (b_regs.exists(m_regs[i].get_name())) begin
          `uvm_info(get_name(), $psprintf(" %s is not compared to a known value ", m_regs[i].get_name()), UVM_LOW)
          b_regs.delete(m_regs[i].get_name());
        end else if (array_r.exists(m_regs[i].get_name())) begin
          m_regs[i].read(status, rdata); 
          exp_val = array_r[m_regs[i].get_name()];
          if(rdata !== exp_val)
            `uvm_error(get_name(), $psprintf("Reset value mismatch! %s: act = %0h exp = %0h", m_regs[i].get_name(), rdata, exp_val))
          else
           `uvm_info(get_name(), $psprintf("Reset value match! %s: val = %0h", m_regs[i].get_name(), rdata), UVM_LOW)
          array_r.delete(m_regs[i].get_name());
        end else begin
            m_regs[i].read(status, rdata);
            exp_val = m_regs[i].get_reset();
            if(rdata !== exp_val)
             `uvm_error(get_name(), $psprintf("Reset value mismatch! %s: act = %0h exp = %0h", m_regs[i].get_name(), rdata, exp_val))
            else
           `uvm_info(get_name(), $psprintf("Reset value match! %s: val = %0h", m_regs[i].get_name(), rdata), UVM_LOW)
        end
      end
       `uvm_info(get_name(),"exiting  check_reset task...", UVM_LOW)   
   endtask : check_reset_value

//task used to check the Write and read value of accessed CSR through RAL
//Tried  write data with 'hf, 'h0 and random values.
   virtual task wr_rd_cmp(uvm_reg m_regs[$],string b_regs[string], bit [63:0] array_w[string]);
      uvm_reg m_reg;
      uvm_status_e   status;
      string a_var;
      uvm_reg_data_t wdata, rdata, exp_val;

      `uvm_info(get_name(),"Entering wr_rd_cmp task...", UVM_LOW)
      foreach(m_regs[i]) begin
        bit [63:0] mask, field_mask;
        uvm_reg_field m_reg_fields[$];
        `uvm_info(get_name(), $psprintf("Method wr_rd_cmp : reg : %s  b_regs.size() = %0d, array_w.size() = %0d  ", m_regs[i].get_name(), b_regs.size(),array_w.size()), UVM_LOW)
        if (b_regs.exists(m_regs[i].get_name())) begin
          `uvm_info(get_name(), $psprintf(" %s is not compared to a known value ", m_regs[i].get_name()), UVM_LOW)
          b_regs.delete(m_regs[i].get_name());
        end else if (array_w.exists(m_regs[i].get_name())) begin
          wdata = array_w[m_regs[i].get_name()];
          m_regs[i].write(status, wdata);
          m_regs[i].read(status, rdata); 
          if(rdata !== wdata)
	    `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %h rdata = %h", m_regs[i].get_name(), wdata, rdata))
          else
	   `uvm_info(get_name(), $psprintf("Data match %s! wdata = %h rdata = %h", m_regs[i].get_name(), wdata, rdata), UVM_LOW)
          array_w.delete(m_regs[i].get_name());
        end else begin
          m_reg = m_regs[i];
	  m_reg.get_fields(m_reg_fields);
	  m_reg_fields.sort(p) with (p.get_lsb_pos());
	  for(int j = 0; j < m_reg_fields.size(); j++) begin
	    int unsigned n_bits;
	    int unsigned r_bits;
	    n_bits = m_reg_fields[j].get_n_bits();
	    r_bits = 64 - n_bits;
	    if(m_reg_fields[j].get_access() == "RW") begin
	      field_mask = {{n_bits{1'b1}}, {r_bits{1'b0}}};
            end else
	      field_mask = 0;
	    mask = mask >> n_bits;
	    mask |= field_mask;
	  end
	  if(m_reg.get_n_bits() == 32)
	    mask = mask >> 32;

          for(int k=0;k<=3;k++) begin    
	    if(mask) begin
	      if(k==0) begin	
                wdata= 64'h0000_0000_0000_0000;
                m_reg.write(status, wdata);
	        m_reg.read(status, rdata);
	        if((wdata & mask) !== (rdata & mask))
	          `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %h rdata = %h mask = %h", m_reg.get_name(), wdata, rdata, mask))
	        else
	          `uvm_info(get_name(), $psprintf("Data match %s! wdata = %h rdata = %h mask = %h", m_reg.get_name(), wdata,rdata, mask), UVM_LOW)
              end else if(k==1) begin   
                wdata= 64'hffff_ffff_ffff_ffff;
	        m_reg.write(status, wdata);
	        m_reg.read(status, rdata);
	        if((wdata & mask) !== (rdata & mask))
	          `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %h rdata = %h mask = %h", m_reg.get_name(), wdata, rdata, mask))
	        else
	          `uvm_info(get_name(), $psprintf("Data match %s! wdata = %h rdata = %h mask = %h", m_reg.get_name(), wdata,rdata, mask), UVM_LOW)
	      end else if(k==2) begin
                wdata= 64'h0000_0000_0000_0000;
                m_reg.write(status, wdata);
	        m_reg.read(status, rdata);
	        if((wdata & mask) !== (rdata & mask))
	          `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %h rdata = %h mask = %h", m_reg.get_name(), wdata, rdata, mask))
	        else
	          `uvm_info(get_name(), $psprintf("Data match %s! wdata = %h rdata = %h mask = %h", m_reg.get_name(), wdata, rdata, mask), UVM_LOW)
              end else begin
                std::randomize(wdata);
	        m_reg.write(status, wdata);
	        m_reg.read(status, rdata);
	        if((wdata & mask) !== (rdata & mask))
	          `uvm_error(get_name(), $psprintf("Data mismatch %s! wdata = %h rdata = %h mask = %h", m_reg.get_name(), wdata, rdata, mask))
	        else
	          `uvm_info(get_name(), $psprintf("Data match %s! wdata = %h rdata = %h mask = %h", m_reg.get_name(), wdata, rdata, mask), UVM_LOW)
              end
            end 
          end
        end
      end
   endtask : wr_rd_cmp
  
  task cfg_port_rst_assert();
       bit [63:0]    rdata, wdata, addr;
       addr = tb_cfg0.PF0_BAR0+PORT_GASKET_BASE_ADDR+'h01038;	
      `uvm_info(get_name(), $psprintf("Reset is asserted PORT_CONTROL = %0h", rdata), UVM_LOW)
       begin
        //wdata ='h5;
        mmio_read64  (.addr_(addr), .data_(rdata));
        wdata = rdata;
        if(rdata[0] != 1) 
         begin wdata[0] = 1'b1;
          mmio_write64 (.addr_(addr), .data_(wdata));
          `uvm_info(get_name(), $psprintf("Reset is asserted PORT_CONTROL = %0h", wdata), UVM_LOW)
          while(!rdata[4])  mmio_read64  (.addr_(addr), .data_(rdata));      
         `uvm_info(get_name(), $psprintf("SOFT_RESET_ACK is SET = %0h", rdata), UVM_LOW)
         end
       end
  endtask 

  task cfg_release_port_rst();
       bit [63:0]    rdata, wdata, addr;
       addr = tb_cfg0.PF0_BAR0+PORT_GASKET_BASE_ADDR+'h01038;	
       begin
       // wdata ='h4;
        mmio_read64  (.addr_(addr), .data_(rdata));
        wdata = rdata;
        if(rdata[0] == 1'b1)
	 begin
          wdata[0] = 1'b0;
          mmio_write64 (.addr_(addr), .data_(wdata));
         `uvm_info(get_name(), $psprintf("Reset is de-asserted PORT_CONTROL = %0h", wdata), UVM_LOW)
          while(rdata[4])  mmio_read64  (.addr_(addr), .data_(rdata));      
         `uvm_info(get_name(), $psprintf("SOFT_RESET_ACK is released = %0h", rdata), UVM_LOW)
         end
       end
       `uvm_info(get_name(), $psprintf("PortSoftResetAck is asserted  PORT_CONTROL = %0h", rdata), UVM_LOW)
            #1us;
  endtask : cfg_release_port_rst

 task port_rst_assert(); //Reset used for protocolchecker 
       bit [63:0]    rdata, wdata, addr;
       addr = tb_cfg0.PF0_BAR0+PORT_GASKET_BASE_ADDR+'h01038;	
      `uvm_info(get_name(), $psprintf("Reset is asserted PORT_CONTROL = %0h", rdata), UVM_LOW)
       begin
        wdata ='h5;
        mmio_write64 (.addr_(addr), .data_(wdata));
       `uvm_info(get_name(), $psprintf("Reset is asserted PORT_CONTROL = %0h", wdata), UVM_LOW)
       end
       `uvm_info(get_name(), $psprintf("PortSoftResetAck is asserted  PORT_CONTROL = %0h", rdata), UVM_LOW)
  endtask 

  task release_port_rst(); //reset used for protocolchecker
       bit [63:0]    rdata, wdata, addr;
       addr = tb_cfg0.PF0_BAR0+PORT_GASKET_BASE_ADDR+'h01038;	
       begin
        wdata ='h4;
        mmio_write64 (.addr_(addr), .data_(wdata));
       `uvm_info(get_name(), $psprintf("Reset is de-asserted PORT_CONTROL = %0h", wdata), UVM_LOW)
       end
       `uvm_info(get_name(), $psprintf("PortSoftResetAck is asserted  PORT_CONTROL = %0h", rdata), UVM_LOW)
            #1us;
  endtask : release_port_rst

 
endclass : base_seq

`endif // BASE_SEQ_SVH
