// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

 task mmio_pcie_read32(input bit [63:0] addr_, output bit [31:0] data_, input bit is_soc_ = 1);
     pcie_rd_mmio_seq mmio_rd;
     if(is_soc_) begin
        `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
            rd_addr == addr_;
            rlen    == 1;
            l_dw_be == 4'b0000;
            block   == 0;
        })
     end
     else begin
      `ifdef F2000x_ENABLE
        `uvm_do_on_with(mmio_rd, p_sequencer.root1_virt_seqr.driver_transaction_seqr[0], {
            rd_addr == addr_;
            rlen    == 1;
            l_dw_be == 4'b0000;
            block   == 0;
        })
      `endif
     end
     data_ = changeEndian(mmio_rd.read_tran.payload[0]);
 endtask : mmio_pcie_read32

task mmio_pcie_read64(input  bit [63:0] addr_, output bit [63:0] data_, input bit is_soc_ = 1);
    pcie_rd_mmio_seq mmio_rd;
    if(is_soc_) begin
      `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
          rd_addr == addr_;
          rlen    == 2;
          l_dw_be == 4'b1111;
          block   == 0;
      })
    end
    else begin
      `ifdef F2000x_ENABLE
      `uvm_do_on_with(mmio_rd, p_sequencer.root1_virt_seqr.driver_transaction_seqr[0], {
          rd_addr == addr_;
          rlen    == 2;
          l_dw_be == 4'b1111;
          block   == 0;
      })
      `endif
    end
    data_ = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
endtask : mmio_pcie_read64


 task mmio_pcie_write32(input bit [63:0] addr_, input bit [31:0] data_, input bit is_soc_ = 1);
     pcie_wr_mmio_seq mmio_wr;
     if(is_soc_) begin
       `uvm_do_on_with(mmio_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], { 
           wr_addr       == addr_;
           wrlen         == 'h1;
           l_dw_be       == 4'b0000;
           wr_payload[0] == changeEndian(data_);
       })
     end
     else begin
      `ifdef F2000x_ENABLE
       `uvm_do_on_with(mmio_wr, p_sequencer.root1_virt_seqr.driver_transaction_seqr[0], { 
           wr_addr       == addr_;
           wrlen         == 'h1;
           l_dw_be       == 4'b0000;
           wr_payload[0] == changeEndian(data_);

       })
      `endif
     
     end
 endtask : mmio_pcie_write32 

 task mmio_pcie_write64(input bit [63:0] addr_, input bit [63:0] data_, input bit is_soc_ = 1);
     pcie_wr_mmio_seq mmio_wr;
     if(is_soc_) begin
       `uvm_do_on_with(mmio_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], { 
           wr_addr       == addr_;
           wrlen         == 'h2;
           l_dw_be       == 4'b1111;
           wr_payload[0] == changeEndian(data_[31:0]);
           wr_payload[1] == changeEndian(data_[63:32]);
       })
     end
     else begin
      `ifdef F2000x_ENABLE
       `uvm_do_on_with(mmio_wr, p_sequencer.root1_virt_seqr.driver_transaction_seqr[0], { 
           wr_addr       == addr_;
           wrlen         == 'h2;
           l_dw_be       == 4'b1111;
           wr_payload[0] == changeEndian(data_[31:0]);
           wr_payload[1] == changeEndian(data_[63:32]);
       })
      `endif
     
     end
 endtask : mmio_pcie_write64

task mmio_pcie_read32_blocking(input bit [63:0] addr_, output bit [31:0] data_, input bit is_soc_ = 1);
    pcie_rd_mmio_seq mmio_rd;
    bit timeout;
    fork
    begin
    if(is_soc_) begin
      `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
          rd_addr == addr_;
          rlen    == 1;
          l_dw_be == 4'b0000;
          block   == 1;
      })
    end
    else begin
      `ifdef F2000x_ENABLE
      `uvm_do_on_with(mmio_rd, p_sequencer.root1_virt_seqr.driver_transaction_seqr[0], {
          rd_addr == addr_;
          rlen    == 1;
          l_dw_be == 4'b0000;
          block   == 1;
      })
      `endif
    
    end
    data_ = changeEndian(mmio_rd.read_tran.payload[0]);
    end
    begin
      #50us;
      timeout=1;
    end
   join_any
   if(timeout)
        `uvm_fatal(get_name(),$psprintf("MMIO read timed out addr =%0h",addr_))
    
endtask : mmio_pcie_read32_blocking


task mmio_pcie_read64_blocking(input  bit [63:0] addr_, output bit [63:0] data_, input bit is_soc_ = 1);
    pcie_rd_mmio_seq mmio_rd;
    bit timeout=0;
    fork
    begin
    if(is_soc_) begin
       `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
           rd_addr == addr_;
           rlen    == 2;
           l_dw_be == 4'b1111;
           block   == 1;
       })
    end
    else begin
      `ifdef F2000x_ENABLE
       `uvm_do_on_with(mmio_rd, p_sequencer.root1_virt_seqr.driver_transaction_seqr[0], {
           rd_addr == addr_;
           rlen    == 2;
           l_dw_be == 4'b1111;
           block   == 1;
       }
      `endif
    end
    data_ = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
   end
   begin
      #50us;
      timeout=1;
   end
  join_any
  if(timeout)
        `uvm_fatal(get_name(),$psprintf("MMIO read timed out addr =%0h",addr_))
endtask:mmio_pcie_read64_blocking

 task host_pcie_mem_write (input  bit [63:0] addr_, input bit [31:0] data_ [], input int unsigned len ,input bit is_soc_ = 1);
     host_pcie_mem_write_seq pcie_mem_wr_seq;
     `uvm_do_on_with(pcie_mem_wr_seq, p_sequencer.root_virt_seqr.mem_target_seqr, {
	        address           == addr_;
	        dword_length      == len;
                data_seq.size()   == len;          
                foreach(data_seq[i]) { data_seq[i] == data_[i]; }
	            })
 endtask

 task host_pcie_mem_read (input  bit [63:0] addr_, output bit [31:0] data_ [],input int unsigned len ,input bit is_soc_ = 1);
     host_pcie_mem_read_seq pcie_mem_rd_seq;
     `uvm_do_on_with(pcie_mem_rd_seq, p_sequencer.root_virt_seqr.mem_target_seqr, {
          address           == addr_;
	  dword_length      == len;
      })
     data_ = new[len] (pcie_mem_rd_seq.data_buf);
     
 endtask


 task pcie_vdm_random_msg(input bit[9:0] length_,input bit routing_type_,input bit [7:0] dest_id );
     pcie_vdm_msg_seq vdm_wr;
     if(routing_type_)begin
     `uvm_do_on_with(vdm_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
          vdm_len == length_;
          vendor_fields[63:48] == 16'h0;
          vendor_fields[47:32] == 16'h1AB4;
          vendor_fields[31:0]  == {8'h01,dest_id,16'h00C0};
          routing_type == 1;
      })
     end
     else begin 
     `uvm_do_on_with(vdm_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
          vdm_len == length_;
          vendor_fields[47:32] == 16'h1AB4;
          vendor_fields[31:0]  == {8'h01,dest_id,16'h00C0};
          routing_type == 0;
      })
     end
 endtask : pcie_vdm_random_msg


 task pcie_vdm_random_multi_msg(input bit[9:0] length_,input bit routing_type_,input bit [7:0] dest_id ,input bit [1:0] pos_pkt,input bit [1:0] num_ctr);
     pcie_vdm_msg_seq vdm_wr;
     if(routing_type_)begin
     `uvm_do_on_with(vdm_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
          vdm_len == length_;
          vendor_fields[63:48] == 16'h0;
          vendor_fields[47:32] == 16'h1AB4;
          if(pos_pkt==2'b00){ 
           vendor_fields[31:0]  == {8'h01,dest_id,8'h00,2'b00,num_ctr,4'b0};
          } 
          else if(pos_pkt==2'b10){
           vendor_fields[31:0]  == {8'h01,dest_id,8'h00,2'b10,num_ctr,4'b0};
          }
          else{ 
           vendor_fields[31:0]  == {8'h01,dest_id,8'h00,2'b01,num_ctr,4'b0};
          }
          routing_type == 1;
      })
      
     end
     else begin 
     `uvm_do_on_with(vdm_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
          vdm_len == length_;
          vendor_fields[47:32] == 16'h1AB4;
          if(pos_pkt==2'b00){ 
           vendor_fields[31:0]  == {8'h01,dest_id,8'h00,2'b00,num_ctr,4'h0};
          }
          else if(pos_pkt==2'b10){
           vendor_fields[31:0]  == {8'h01,dest_id,8'h00,2'b10,num_ctr,4'b0};
          }
          else{ 
           vendor_fields[31:0]  == {8'h01,dest_id,8'h00,2'b01,num_ctr,4'b0};
          }
          routing_type == 0;
      })
     end
 endtask : pcie_vdm_random_multi_msg 

 task pcie_vdm_err_msg(input bit[9:0] length_);
     pcie_vdm_msg_seq vdm_wr;
     `uvm_do_on_with(vdm_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
          vdm_len == length_;
          vendor_fields[63:48] == 16'h0;
          vendor_fields[47:32] == 16'h03A5; //Actual VID should be 1ab4
          vendor_fields[31:0]  == 32'h01FF00C0;
          routing_type == 1;
      })
 endtask :pcie_vdm_err_msg

 task pcie_pf_vf_bar();
    enumerate_seq   enumerate_seq2;
  `ifndef INCLUDE_CVL
    `uvm_do_on_with(enumerate_seq2, p_sequencer.root_virt_seqr.driver_transaction_seqr[0],{
    pf0_bar0     == tb_cfg0.PF0_BAR0;
    pf0_bar4     == tb_cfg0.PF0_BAR4;
    pf1_bar0     == tb_cfg0.PF1_BAR0;
    pf2_bar0     == tb_cfg0.PF2_BAR0;
    pf3_bar0     == tb_cfg0.PF3_BAR0;
    pf4_bar0     == tb_cfg0.PF4_BAR0;
    pf0_vf0_bar0 == tb_cfg0.PF0_VF0_BAR0;
    pf0_vf1_bar0 == tb_cfg0.PF0_VF1_BAR0;
    pf0_vf2_bar0 == tb_cfg0.PF0_VF2_BAR0;
    pf1_vf0_bar0 == tb_cfg0.PF1_VF0_BAR0;
    pf0_vf0_bar4 == tb_cfg0.PF0_VF0_BAR4;
     })
   `else
   `uvm_do_on_with(enumerate_seq2, p_sequencer.root_virt_seqr.driver_transaction_seqr[0],{
          pf0_bar0     == tb_cfg0.PF0_BAR0;  
          pf0_bar4     == tb_cfg0.PF0_BAR4;  
          pf1_bar0     == tb_cfg0.PF1_BAR0;
          pf2_bar0     == tb_cfg0.PF2_BAR0;
          pf2_bar4     == tb_cfg0.PF2_BAR4;
          pf3_bar0     == tb_cfg0.PF3_BAR0;
          pf4_bar0     == tb_cfg0.PF4_BAR0;
          pf0_expansion_rom_bar == tb_cfg0.PF0_EXP_ROM_BAR0;
          pf0_vf0_bar0 == tb_cfg0.PF0_VF0_BAR0;
          pf0_vf0_bar4 == tb_cfg0.PF0_VF0_BAR4;
          pf0_vf1_bar0 == tb_cfg0.PF0_VF1_BAR0;
          pf0_vf2_bar0 == tb_cfg0.PF0_VF2_BAR0;
          pf1_vf0_bar0 == tb_cfg0.PF1_VF0_BAR0;
	`ifdef FIM_B     
          pf0_vf3_bar0 == tb_cfg0.PF0_VF3_BAR0;
	`endif
    })
   `endif
    enumerate_seq2.print();
 endtask :pcie_pf_vf_bar

 task flr_pcie_cfg_rd(input bit[63:0] address_, output bit [31:0] dev_ctl_ ,input bit is_soc_=1);
        cfg_rd_flr_seq flr_rd;
        `uvm_do_on_with(flr_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
            rd_addr == address_;
        })
        dev_ctl_ = flr_rd.rd_dev_ctl;
 endtask : flr_pcie_cfg_rd

 task flr_pcie_cfg_wr(input bit[63:0] address_, input bit [31:0] dev_ctl_, input bit is_soc_=1);
        cfg_wr_flr_seq flr_wr;
        `uvm_do_on_with(flr_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
            wr_addr == address_;
            wr_dev_ctl == dev_ctl_;
        })
 
 endtask : flr_pcie_cfg_wr

 task axis_random_data();
        //axi_stream_random_sequence axi_m_seq;
        axi_master_random_sequence axi_m_seq;
     	`uvm_do_on_with(axi_m_seq ,tb_env0.axis_HSSI_env.master[0].sequencer,{
         //stream_burst_length inside {[1:10]};
         sequence_length == 'd10 ;
         } )
 endtask

task qsfp_axi_master_read (input [17:0] address,input [63:0] ex_rdata);
    
   qsfp_axi_derived_read_sequence rd_trans;
   `uvm_do_on_with(rd_trans,p_sequencer.pmci_axi4_lt_mst_seqr, { 

      rd_trans.addr                  == address;
      rd_trans.exp_data                  == ex_rdata;
      })

endtask : qsfp_axi_master_read

task qsfp_axi_master_write (input [17:0] address,input [63:0] wdata,input [7:0] wstrobe);
  qsfp_axi_derived_write_sequence wr_trans;

  `uvm_do_on_with(wr_trans,p_sequencer.pmci_axi4_lt_mst_seqr, { 

      wr_trans.addr                  == address;
      wr_trans.data                  == wdata;
      wr_trans.wstrb                 == wstrobe;
      })

endtask : qsfp_axi_master_write
 

