// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_COVERAGE_COLLECTOR_SV
`define QSFP_COVERAGE_COLLECTOR_SV

//Macro declaration for multiple ports
`uvm_analysis_imp_decl( _qsfp_slave_cov )
`uvm_analysis_imp_decl( _axi4lite_master_cov )


class qsfp_coverage_collector extends uvm_component ;
 `uvm_component_utils(qsfp_coverage_collector)
 string name = "qsfp_coverage_collector";

 //Port from QSFP slave ENV monitor
 uvm_analysis_imp_qsfp_slave_cov#(qsfp_slave_seq_item, qsfp_coverage_collector) qsfp_item_collected_export;
 //Port from AXI4 LITE ENV monitor
 uvm_analysis_imp_axi4lite_master_cov#(`AXI_TRANSACTION_CLASS, qsfp_coverage_collector) axi4lite_item_collected_export;

virtual qsfp_coverage_intf cov_intf;
  

 bit coverage_enable =1'b1;//Default value can be kept as 1 
 bit _coverage_enable ;

 bit [17:0] axi_address;
 bit [31:0] qsfp_address, qsfp_address_lpage00, qsfp_address_upage00;
 bit [31:0] qsfp_address_upage02, qsfp_address_upage03, qsfp_address_upage20, qsfp_address_upage21;
 bit [31:0] qsfp_writedata;
 bit [7:0] page_byte;
 
 //Covergroups
 covergroup qsfp_covgroup ;

       LOWER_PAGE00_ADDRESS : coverpoint qsfp_address_lpage00 { bins lowerpage_addr[] = {[32'h00:32'h7C]} with (item%4==0);}
                                                 
       UPPER_PAGE00_ADDRESS : coverpoint qsfp_address_upage00 { bins upperpage00_addr[] = {[32'h80:32'hFC]} with (item%4==0);}

       UPPER_PAGE02_ADDRESS : coverpoint qsfp_address_upage02 { bins upperpage02_addr[] =  {[32'h80:32'hFC]} with (item%4==0);}
                                                              
       UPPER_PAGE03_ADDRESS : coverpoint qsfp_address_upage03 { bins upperpage03_addr[] = {[32'h80:32'hFC]} with (item%4==0);}
         
       UPPER_PAGE20_ADDRESS : coverpoint qsfp_address_upage20 { bins upperpage20_addr[] = {[32'h80:32'hFC]} with (item%4==0);}

       UPPER_PAGE21_ADDRESS : coverpoint qsfp_address_upage21 { bins upperpag21_addr[] = {[32'h80:32'hFC]} with (item%4==0);}

       //PAGE_SELECT_BYTE : coverpoint page_byte { bins page_switch[] = {8'h00, 8'h02, 8'h03, 8'h20, 8'h21};}
       
       PAGE_SELECT_BYTE : coverpoint page_byte { bins page_switch0_2 = (8'h00=>8'h02);
                                                 bins page_switch2_3 = (8'h02=>8'h03);
                                                 bins page_switch3_20 = (8'h03=>8'h20);
                                                 bins page_switch20_21 = (8'h20=>8'h21);
                                               }

       CURRENT_READ_PAGE : coverpoint cov_intf.curr_rd_page { bins page0_2 = (8'h00=>8'h02);
                                                              bins page2_3 = (8'h02=>8'h03);
                                                              bins page3_20 = (8'h03=>8'h20);
                                                              bins page20_21 = (8'h20=>8'h21);
                                                              
                                                            }

                                                                                       
       POLLER_CURRENT_STATE : coverpoint cov_intf.poller_state { bins pollstate = {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011};}
       
       CSR_CURRENT_STATE: coverpoint cov_intf.csr_state { bins csrstate = {2'b00, 2'b01, 2'b10 };}

       /*POLLER_ENABLE : coverpoint cov_intf.poll_en { bins pollerenabled0_1 = (1'h0=>1'h1); 
                                                     bins pollerenabled1_0 = (1'h1=>1'h0);
                                                   } */

       POLLER_ENABLE : coverpoint cov_intf.poll_en { bins pollerenabled0_1 = {1'h0, 1'h1}; }
       
      /* FSM_PAUSED : coverpoint cov_intf.fsm_paused { bins fsmpaused0_1 = (1'h0=>1'h1); 
                                                     bins fsmpaused1_0 = (1'h1=>1'h0);
                                                   } */

       FSM_PAUSED : coverpoint cov_intf.fsm_paused { bins fsmpaused0_1 = {1'h0, 1'h1}; }
       
       /*SOFTRESET_QSFPC : coverpoint cov_intf.softresetqsfpc { bins softreset0_1 = (1'h0=>1'h1);
                                                              bins softreset1_0 = (1'h1=>1'h0);
                                                            } */

       SOFTRESET_QSFPC : coverpoint cov_intf.softresetqsfpc { bins softreset0_1 = {1'h0, 1'h1}; }
       
       SCL_HIGH_COUNT : coverpoint cov_intf.scl_hcnt { bins sclh_countperiod = {16'h1, 16'h7d};}

       SCL_LOW_COUNT : coverpoint cov_intf.scl_lcnt { bins scll_countperiod = {16'h1, 16'h7d};}

       SDA_HOLD : coverpoint cov_intf.sda_hold { bins sda_countperiod = {16'h1,16'h3c};}

       SPEED_MODE : coverpoint cov_intf.speed_mode { bins bus_speed= {1};}

 endgroup

 covergroup axi_covgroup ;

       ADDRESS : coverpoint axi_address   { 	bins lowerpage00[]   = {[18'h100:18'h17F]} with (item%8==0);  
       	 			               	bins upperpage00[]  = {[18'h180:18'h1FF]} with (item%8==0);
       	 			               	bins upperpage02[]  = {[18'h200:18'h27F]} with (item%8==0);
       	 			               	bins upperpage03[]  = {[18'h280:18'h2FF]} with (item%8==0);
       	 			               	bins upperpage20[] = {[18'h300:18'h37F]} with (item%8==0);
       	 			               	bins upperpage21[] = {[18'h380:18'h3FF]} with (item%8==0);
                                                } 	


        endgroup

 //Covergroups_end

 function new ( string name = "qsfp_coverage_collector", uvm_component parent = null);
   super.new(name,parent);
   this.name = name;
   qsfp_item_collected_export = new("qsfp_item_collected_export", this);
   axi4lite_item_collected_export = new("axi4lite_item_collected_export", this);

   qsfp_covgroup = new();
   qsfp_covgroup.set_inst_name($sformatf("%s_%s", get_full_name(), "qsfp_covgroup"));

   axi_covgroup = new();
   axi_covgroup.set_inst_name($sformatf("%s_%s", get_full_name(), "axi_covgroup"));
 endfunction : new

 //------------------------------------------------------------------------------
 // Function : build_phase
 //------------------------------------------------------------------------------

 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   if (uvm_config_db#(int)::get(this, "", "coverage_enable", _coverage_enable))
       this.coverage_enable = _coverage_enable;
   if(!(uvm_config_db#(virtual qsfp_coverage_intf)::get(this,"*","cov_intf",cov_intf)))begin
       `uvm_fatal("CLSS",("virtual interface must be set for:"))
    end


   // 	 `uvm_fatal("QSFP_COVERAGE", "COVERAGE is not enabled.");
 endfunction


 //function void write_from_i2c_mon(TRAN, trans_inst)

 //   if(this.coverage_enable == 1) begin

 //   `uvm_info("QSP_TRANS_COV","Got qsfp coverage. ",UVM_DEBUG)
 //    this.qsfp_cov.collect_qsfp_coverage(trans);

 //   end
 //endfunction

 // Write function for AXI4 Lite Master packet
 virtual function void write_axi4lite_master_cov(`AXI_TRANSACTION_CLASS trans);
    `AXI_TRANSACTION_CLASS axi_pkt;
    $cast(axi_pkt , trans.clone());
    `uvm_info(get_type_name(),$sformatf(" COVERAGE :: Pkt received from AXI4 Lite Master ENV \n %s",axi_pkt.convert2string()),UVM_LOW)
    
    axi_address    = axi_pkt.addr;
    //data    = t.data;
    //Assign values to coverpoint variables
    
    //Sample covergroups
    axi_covgroup.sample();
 endfunction : write_axi4lite_master_cov

 // Write function for QSFP slave packet
 virtual function void write_qsfp_slave_cov(qsfp_slave_seq_item pkt);
    qsfp_slave_seq_item qsfp_pkt;
    $cast(qsfp_pkt , pkt.clone());
    `uvm_info(get_type_name(),$sformatf(" COVERAGE :: Pkt received from QSFP slave interface \n %s",qsfp_pkt.convert2string()),UVM_LOW)
    //Assign values to coverpoint variables
    
    //Sampling covergroups
    qsfp_address = qsfp_pkt.address;

    /*if(qsfp_address<='h80) begin
        qsfp_address_lpage00 = qsfp_address;
    end
    else begin
        qsfp_address_upage00 = qsfp_address;
    end */
    
    if(qsfp_address=='h7c && (qsfp_pkt.qsfp_slv_pkt_type==QSFP_SLV_WRITE)) begin
       qsfp_writedata = qsfp_pkt.writedata;
       `uvm_info(get_type_name(),$sformatf(" COVERAGE ::Writedata for QSFP : %h",qsfp_writedata),UVM_LOW)
       page_byte = qsfp_writedata[31:24];
       `uvm_info(get_type_name(),$sformatf(" COVERAGE ::Page select byte for QSFP : %h",page_byte),UVM_LOW)
    end  

    if(qsfp_address<'h80) begin
           qsfp_address_lpage00 = qsfp_address;
    end
    else if (qsfp_address>='h80 && page_byte=='h00) begin
           qsfp_address_upage00 = qsfp_address;
    end
    else begin
       if (page_byte=='h02)
         qsfp_address_upage02 = qsfp_address;
       else if (page_byte=='h03)
         qsfp_address_upage03 = qsfp_address;
       else if (page_byte=='h20)
         qsfp_address_upage20 = qsfp_address;
       else if (page_byte=='h21 && qsfp_pkt.qsfp_slv_pkt_type==QSFP_SLV_WRITE )
         qsfp_address_upage21 = qsfp_address;
       else
         `uvm_info(get_type_name(),$sformatf(" COVERAGE ::Page select byte for QSFP : %h not valid",page_byte),UVM_LOW)
    end        
    qsfp_covgroup.sample();
 endfunction : write_qsfp_slave_cov


 endclass : qsfp_coverage_collector 

`endif




