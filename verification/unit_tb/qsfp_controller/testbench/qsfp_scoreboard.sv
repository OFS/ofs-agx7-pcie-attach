// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//Class : QSFP scoreboard
//
//Macro declaration for multiple ports
`uvm_analysis_imp_decl( _qsfp_slave )
`uvm_analysis_imp_decl( _axi4lite_master )

class qsfp_scoreboard extends uvm_scoreboard;
 
  `uvm_component_utils(qsfp_scoreboard)
  //Port from QSFP slave ENV monitor
  uvm_analysis_imp_qsfp_slave#(qsfp_slave_seq_item, qsfp_scoreboard) qsfp_item_collected_export;
  //Port from AXI4 LITE ENV monitor
  uvm_analysis_imp_axi4lite_master#(`AXI_TRANSACTION_CLASS, qsfp_scoreboard) axi4lite_item_collected_export;
  
  qsfp_registry_component qsfp_sb_mem;

 //TLM FIFO for AXI and QSFP 
  uvm_tlm_analysis_fifo #(qsfp_slave_seq_item) qsfp_fifo;
  uvm_tlm_analysis_fifo #(`AXI_TRANSACTION_CLASS) axilite_fifo;

  //QSFP_Registry element for storing READ data from I2C 
  logic [31:0] shadow_register_comp[int];
  logic [31:0] address;

  bit [63:0] shadow_register_data;
  bit [63:0] axi_pkt_data;
  bit [63:0] axi_cmp_pkt_data;
  bit [63:0] qsfp_pkt_data;

  bit [3:0] axi_wr_cnt;
  logic [31:0] axi_wr_data,axi_wdata,qsfp_wdata;
  logic [63:0] axi_rdata,qsfp_rdata;
  logic [7:0]  axi_wr_data_byte0,axi_wr_data_byte1,axi_wr_data_byte2,axi_wr_data_byte3;
  logic [17:0] axi_wr_addr,axi_rd_addr;

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    qsfp_item_collected_export = new("qsfp_item_collected_export", this);
    axi4lite_item_collected_export = new("axi4lite_item_collected_export", this);
    qsfp_fifo = new("qsfp_fifo",this);
    axilite_fifo = new("axilite_fifo",this);
  endfunction: build_phase
   
  // Write function for QSFP slave packet
  virtual function void write_qsfp_slave(qsfp_slave_seq_item pkt);
    qsfp_slave_seq_item qsfp_pkt;
    $cast(qsfp_pkt , pkt.clone());
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from QSFP slave ENV \n %s",qsfp_pkt.sprint()),UVM_LOW)

    if (qsfp_pkt.qsfp_slv_pkt_type == QSFP_SLV_WRITE )begin   //QSFP write 
     qsfp_fifo.write(qsfp_pkt);
    end 
    else if (qsfp_pkt.qsfp_slv_pkt_type == QSFP_SLV_READ )begin  //QSFP read
     shadow_register_comp[qsfp_pkt.address] = qsfp_pkt.readdata ;  
    end 
  endfunction : write_qsfp_slave

  // Write function for AXI 4 LITE master packet
  virtual function void write_axi4lite_master(`AXI_TRANSACTION_CLASS trans);
    `AXI_TRANSACTION_CLASS axi_pkt;
    $cast(axi_pkt , trans.clone());
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from AXI4 Lite Master ENV \n %s",axi_pkt.sprint()),UVM_LOW)
    
    if(axi_pkt.xact_type == (`AXI_TRANSACTION_CLASS::WRITE))begin
      if((axi_pkt.addr == 32'h40))begin
        axilite_fifo.write(axi_pkt); 
      end
    end
    
    if(axi_pkt.xact_type == (`AXI_TRANSACTION_CLASS::READ))begin
      if((axi_pkt.addr >= 32'h100))begin
        axilite_fifo.write(axi_pkt); 
      end
    end

  endfunction : write_axi4lite_master

  task run_phase(uvm_phase phase) ;
    qsfp_slave_seq_item qsfp_cmp_pkt;
    `AXI_TRANSACTION_CLASS axi_cmp_pkt;
    super.run_phase(phase);
    forever begin
         axilite_fifo.get(axi_cmp_pkt);
	 if (axi_cmp_pkt.xact_type == (`AXI_TRANSACTION_CLASS::WRITE)) begin
	   axi_wr_cnt = axi_wr_cnt+1;
           if (axi_wr_cnt == 2) begin
              axi_wr_addr = axi_cmp_pkt.data[0];
             `uvm_info("qsfp_scoreboard", $sformatf("axi address 'h %h",axi_wr_addr),UVM_LOW);
	      
           end
           if (axi_wr_cnt == 3 || axi_wr_cnt ==4 || axi_wr_cnt ==5 || axi_wr_cnt ==6) begin

              case ( axi_wr_cnt) 

                     'h3:  axi_wr_data_byte0 = axi_cmp_pkt.data[0];
                     'h4:  axi_wr_data_byte1 = axi_cmp_pkt.data[0];
                     'h5:  axi_wr_data_byte2 = axi_cmp_pkt.data[0];
                     'h6:  axi_wr_data_byte3 = axi_cmp_pkt.data[0];

              endcase

              axi_wr_data = {axi_wr_data_byte3,axi_wr_data_byte2,axi_wr_data_byte1,axi_wr_data_byte0};
             `uvm_info("qsfp_scoreboard", $sformatf("axidata is  %h",axi_wr_data),UVM_LOW);
              if( axi_wr_cnt ==6) begin
                axi_wr_cnt=0;
                qsfp_fifo.get(qsfp_cmp_pkt);
	        qsfp_wdata = qsfp_cmp_pkt.writedata;
               `uvm_info("qsfp_scoreboard", $sformatf("qsfpdata is  %h",qsfp_wdata),UVM_LOW);
               `uvm_info("qsfp_scoreboard", $sformatf("axidata is  %h",axi_wr_data),UVM_LOW);
                compare_write_data(qsfp_wdata,axi_wr_data);
              end

           end
	 end
	 if  (axi_cmp_pkt.xact_type == (`AXI_TRANSACTION_CLASS::READ)) begin

	  if (axi_cmp_pkt.addr < 'h200) begin
            qsfp_rdata = {qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+7)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+6)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+5)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+4)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+3)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+2)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+1)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[axi_cmp_pkt.addr-'h100]};
	  end
	  else if ( axi_cmp_pkt.addr >='h200 && axi_cmp_pkt.addr <'h280) begin
            qsfp_rdata = {qsfp_sb_mem.qsfp_registry_up_pg2[(axi_cmp_pkt.addr+7)-'h180],qsfp_sb_mem.qsfp_registry_up_pg2[(axi_cmp_pkt.addr+6)-'h180],qsfp_sb_mem.qsfp_registry_up_pg2[(axi_cmp_pkt.addr+5)-'h180],qsfp_sb_mem.qsfp_registry_up_pg2[(axi_cmp_pkt.addr+4)-'h180],qsfp_sb_mem.qsfp_registry_up_pg2[(axi_cmp_pkt.addr+3)-'h180],qsfp_sb_mem.qsfp_registry_up_pg2[(axi_cmp_pkt.addr+2)-'h180],qsfp_sb_mem.qsfp_registry_up_pg2[(axi_cmp_pkt.addr+1)-'h180],qsfp_sb_mem.qsfp_registry_up_pg2[axi_cmp_pkt.addr-'h180]};
	  end
	  else if (axi_cmp_pkt.addr >='h280 && axi_cmp_pkt.addr <'h300) begin
            qsfp_rdata = {qsfp_sb_mem.qsfp_registry_up_pg3[(axi_cmp_pkt.addr+7)-'h200],qsfp_sb_mem.qsfp_registry_up_pg3[(axi_cmp_pkt.addr+6)-'h200],qsfp_sb_mem.qsfp_registry_up_pg3[(axi_cmp_pkt.addr+5)-'h200],qsfp_sb_mem.qsfp_registry_up_pg3[(axi_cmp_pkt.addr+4)-'h200],qsfp_sb_mem.qsfp_registry_up_pg3[(axi_cmp_pkt.addr+3)-'h200],qsfp_sb_mem.qsfp_registry_up_pg3[(axi_cmp_pkt.addr+2)-'h200],qsfp_sb_mem.qsfp_registry_up_pg3[(axi_cmp_pkt.addr+1)-'h200],qsfp_sb_mem.qsfp_registry_up_pg3[axi_cmp_pkt.addr-'h200]};
	  end
	  else if (axi_cmp_pkt.addr >='h300 && axi_cmp_pkt.addr <'h380) begin
            qsfp_rdata = {qsfp_sb_mem.qsfp_registry_up_pg20[(axi_cmp_pkt.addr+7)-'h280],qsfp_sb_mem.qsfp_registry_up_pg20[(axi_cmp_pkt.addr+6)-'h280],qsfp_sb_mem.qsfp_registry_up_pg20[(axi_cmp_pkt.addr+5)-'h280],qsfp_sb_mem.qsfp_registry_up_pg20[(axi_cmp_pkt.addr+4)-'h280],qsfp_sb_mem.qsfp_registry_up_pg20[(axi_cmp_pkt.addr+3)-'h280],qsfp_sb_mem.qsfp_registry_up_pg20[(axi_cmp_pkt.addr+2)-'h280],qsfp_sb_mem.qsfp_registry_up_pg20[(axi_cmp_pkt.addr+1)-'h280],qsfp_sb_mem.qsfp_registry_up_pg20[axi_cmp_pkt.addr-'h280]};
	  end
	  else if (axi_cmp_pkt.addr >='h380 && axi_cmp_pkt.addr <'h400) begin
            qsfp_rdata = {qsfp_sb_mem.qsfp_registry_up_pg21[(axi_cmp_pkt.addr+7)-'h300],qsfp_sb_mem.qsfp_registry_up_pg21[(axi_cmp_pkt.addr+6)-'h300],qsfp_sb_mem.qsfp_registry_up_pg21[(axi_cmp_pkt.addr+5)-'h300],qsfp_sb_mem.qsfp_registry_up_pg21[(axi_cmp_pkt.addr+4)-'h300],qsfp_sb_mem.qsfp_registry_up_pg21[(axi_cmp_pkt.addr+3)-'h300],qsfp_sb_mem.qsfp_registry_up_pg21[(axi_cmp_pkt.addr+2)-'h300],qsfp_sb_mem.qsfp_registry_up_pg21[(axi_cmp_pkt.addr+1)-'h300],qsfp_sb_mem.qsfp_registry_up_pg21[axi_cmp_pkt.addr-'h300]};
	  end

           wait ( axi_cmp_pkt.port_cfg.master_if.rvalid == 1 && axi_cmp_pkt.port_cfg.master_if.rready==1) begin
	     axi_rdata  = axi_cmp_pkt.port_cfg.master_if.rdata;
	   end
	   axi_rd_addr  = axi_cmp_pkt.addr;
	   `uvm_info("qsfp_scoreboard", $sformatf("qsfp_read_data is  %h",qsfp_rdata),UVM_LOW);
	   if(axi_cmp_pkt.addr =='h178) begin
	     `uvm_info("qsfp_scoreboard", $psprintf("No Read comparison for Page select byte 127"),UVM_LOW);
	   end
	   else if(axi_cmp_pkt.addr == 'h170) begin
           qsfp_rdata = {8'hFF,qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+6)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+5)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+4)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+3)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+2)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[(axi_cmp_pkt.addr+1)-'h100],qsfp_sb_mem.qsfp_registry_lo_pg0[axi_cmp_pkt.addr-'h100]};
	   end
	   else begin
             compare_read_data(qsfp_rdata,axi_rdata);
           end
	 end
       end

  endtask : run_phase

  virtual function void compare_read_data(logic [63:0] qsfp_rdata, logic [63:0] axi_rdata);

    if (axi_rdata == qsfp_rdata )begin
     `uvm_info("qsfp_scoreboard", $sformatf("Read data comparison successful  for address 'h %h: AXI read data = `h%h , QSFP SLAVE read data = `h%h ",axi_rd_addr,
      axi_rdata,qsfp_rdata), UVM_LOW);  
    end 
    else begin
         `uvm_error("qsfp_scoreboard", $sformatf("Read data comparison ERROR : AXI read data = `h%h , QSFP SLAVE read data = `h%h for address 'h%h",
          axi_rdata,qsfp_rdata,axi_rd_addr)); 
    end

  endfunction : compare_read_data

  virtual function void compare_write_data(logic [31:0] qsfp_wdata,logic [31:0] axi_wdata);


    if (axi_wdata == qsfp_wdata )begin
     `uvm_info("qsfp_scoreboard", $sformatf("Write data comparison successful  for address 'h %h: AXI write data = `h%h , QSFP SLAVE write data = `h%h ",axi_wr_addr,
      axi_wdata,qsfp_wdata), UVM_LOW);  
    end 
    else begin
         `uvm_error("qsfp_scoreboard", $sformatf("Write data comparison ERROR : AXI write data = `h%h , QSFP SLAVE write data = `h%h ",
          axi_wdata,qsfp_wdata)); 
         end
   
  endfunction:compare_write_data


endclass : qsfp_scoreboard
