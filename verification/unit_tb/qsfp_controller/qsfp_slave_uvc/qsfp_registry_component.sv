// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//Class : qsfp_registry_component
//
class qsfp_registry_component extends uvm_component;
   `uvm_component_utils(qsfp_registry_component)

   uvm_analysis_imp#(qsfp_slave_seq_item, qsfp_registry_component) item_collected_export;

   //Associative array for Register component
   logic [7:0] qsfp_registry_lo_pg0[int];
   logic [7:0] qsfp_registry_up_pg2[int];
   logic [7:0] qsfp_registry_up_pg3[int];
   logic [7:0] qsfp_registry_up_pg20[int];
   logic [7:0] qsfp_registry_up_pg21[int];
   logic [31:0] address;
   bit [31:0] addr_count;
   bit [3:0] en_pg;
   bit [7:0] pg_nxt;
   bit config_rand;
   bit count;
   //Port: QSFP data_in_port
 
   function new(string name, uvm_component parent);
      super.new(name, parent);
      item_collected_export = new("item_collected_export", this);
   endfunction: new
 
   function write(qsfp_slave_seq_item pkt);
      qsfp_slave_seq_item _pkt;
      $cast(_pkt, pkt.clone());
      _pkt.print();
      if ($value$plusargs("CONFIG_RAND=%0d", config_rand)) begin
        `uvm_info("qsfp_registry_component", $sformatf("Value of Config rand bit for QSFP registry component : Config Rand : %h", config_rand), UVM_LOW);
        if (count == 0) begin
          `uvm_info("qsfp_registry_component", $sformatf("Value of Count bit for QSFP registry component : Config Rand : %h", count), UVM_LOW);
	  init_array();
          count=count+1;
          `uvm_info("qsfp_registry_component", $sformatf("Value of Count bit for QSFP registry component : Config Rand : %h", count), UVM_LOW);
        end	 
      end
      update_registry(_pkt);
   endfunction: write

   function init_array();
     for(int i='h00;i< 'h120;i=i+'h1) begin
       `uvm_info("qsfp_registry_component", $sformatf("Value of Config rand bit for QSFP registry component : Config Rand : %h", config_rand), UVM_LOW);
       qsfp_registry_lo_pg0[i] = $urandom;
       qsfp_registry_up_pg2[i] = $urandom;
       qsfp_registry_up_pg3[i] = $urandom;
       qsfp_registry_up_pg20[i] = $urandom;
       qsfp_registry_up_pg21[i] = $urandom;
     end
   endfunction: init_array
  
   virtual function update_registry(qsfp_slave_seq_item qsfp_pkt);
  
    //if ( qsfp_pkt.address == 'hfc && qsfp_pkt.byteenable == 'hf && qsfp_pkt.write =='h1)
    `uvm_info("qsfp_registry_component",$sformatf("addr is %d, byte enable is %d  and write is %d and wdata is %h",qsfp_pkt.address,qsfp_pkt.byteenable,qsfp_pkt.write,qsfp_pkt.writedata),UVM_LOW);
    if ( qsfp_pkt.address == 'h7c && qsfp_pkt.byteenable =='hf &&  qsfp_pkt.write =='h1)
    begin
    case(qsfp_pkt.writedata) //check the data bits value
       32'h0000_0000: en_pg = 'h1;
       32'h0200_0000: en_pg = 'h2;
       32'h0300_0000: en_pg = 'h3;
       32'h2000_0000: en_pg = 'h4;
       32'h2100_0000: en_pg = 'h5;
    endcase
    end

    if ( (qsfp_pkt.address >= 'h0 && qsfp_pkt.address <= 'h7c ) || en_pg == 1'b1) begin //------Lower page00 memory
     if(qsfp_pkt.qsfp_slv_pkt_type == QSFP_SLV_WRITE)begin  //write operation
     case(qsfp_pkt.byteenable)
       4'b0001:  qsfp_registry_lo_pg0[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
       4'b0011:  begin 
                  qsfp_registry_lo_pg0[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_lo_pg0[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                 end
       4'b0111:  begin 
                  qsfp_registry_lo_pg0[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_lo_pg0[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_lo_pg0[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                 end
       4'b1111:  begin
                  qsfp_registry_lo_pg0[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_lo_pg0[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_lo_pg0[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                  qsfp_registry_lo_pg0[(qsfp_pkt.address)+3]=qsfp_pkt.writedata[31:24];
                 end
     endcase
    `uvm_info("qsfp_reg_component", $sformatf("Data written to QSFP register array : Address= 'h%h Data0= 'h%h,Data1 ='h%h Dta2 ='h%h Dta3 ='h%h for qsfp_slv_pkt_type %s and byten is %h",
                     qsfp_pkt.address,qsfp_registry_lo_pg0[qsfp_pkt.address],qsfp_registry_lo_pg0[(qsfp_pkt.address)+1],qsfp_registry_lo_pg0[(qsfp_pkt.address)+2],qsfp_registry_lo_pg0[(qsfp_pkt.address)+3],qsfp_pkt.qsfp_slv_pkt_type,qsfp_pkt.byteenable), UVM_LOW); 
    end
    end

    if(en_pg == 'h2) begin
     //fill contents of upper page2 here
     if(qsfp_pkt.qsfp_slv_pkt_type == QSFP_SLV_WRITE)begin  //write operation
     case(qsfp_pkt.byteenable)
       4'b0001:  qsfp_registry_up_pg2[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
       4'b0011:  begin 
                  qsfp_registry_up_pg2[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg2[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                 end
       4'b0111:  begin 
                  qsfp_registry_up_pg2[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg2[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_up_pg2[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                 end
       4'b1111:  begin
                  qsfp_registry_up_pg2[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg2[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_up_pg2[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                  qsfp_registry_up_pg2[(qsfp_pkt.address)+3]=qsfp_pkt.writedata[31:24];
                 end
     endcase
    `uvm_info("qsfp_reg_component", $sformatf("Data written to QSFP register array : Address= 'h%h Data0= 'h%h,Data1 ='h%h Dta2 ='h%h Dta3 ='h%h for qsfp_slv_pkt_type %s and byten is %h",
                     qsfp_pkt.address,qsfp_registry_up_pg2[qsfp_pkt.address],qsfp_registry_up_pg2[(qsfp_pkt.address)+1],qsfp_registry_up_pg2[(qsfp_pkt.address)+2],qsfp_registry_up_pg2[(qsfp_pkt.address)+3],qsfp_pkt.qsfp_slv_pkt_type,qsfp_pkt.byteenable), UVM_LOW); 
    end
    end
    if(en_pg == 'h3) begin
     //fill contents of upper page3 here
     if(qsfp_pkt.qsfp_slv_pkt_type == QSFP_SLV_WRITE)begin  //write operation
     case(qsfp_pkt.byteenable)
       4'b0001:  qsfp_registry_up_pg3[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
       4'b0011:  begin 
                  qsfp_registry_up_pg3[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg3[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                 end
       4'b0111:  begin 
                  qsfp_registry_up_pg3[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg3[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_up_pg3[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                 end
       4'b1111:  begin
                  qsfp_registry_up_pg3[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg3[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_up_pg3[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                  qsfp_registry_up_pg3[(qsfp_pkt.address)+3]=qsfp_pkt.writedata[31:24];
                 end
     endcase
    `uvm_info("qsfp_reg_component", $sformatf("Data written to QSFP register array : Address= 'h%h Data0= 'h%h,Data1 ='h%h Dta2 ='h%h Dta3 ='h%h for qsfp_slv_pkt_type %s and byten is %h",
                     qsfp_pkt.address,qsfp_registry_up_pg3[qsfp_pkt.address],qsfp_registry_up_pg3[(qsfp_pkt.address)+1],qsfp_registry_up_pg3[(qsfp_pkt.address)+2],qsfp_registry_up_pg3[(qsfp_pkt.address)+3],qsfp_pkt.qsfp_slv_pkt_type,qsfp_pkt.byteenable), UVM_LOW); 
    end
    end
    if(en_pg == 'h4) begin
     //fill contents of upper page20 here
     if(qsfp_pkt.qsfp_slv_pkt_type == QSFP_SLV_WRITE)begin  //write operation
     case(qsfp_pkt.byteenable)
       4'b0001:  qsfp_registry_up_pg20[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
       4'b0011:  begin 
                  qsfp_registry_up_pg20[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg20[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                 end
       4'b0111:  begin 
                  qsfp_registry_up_pg20[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg20[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_up_pg20[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                 end
       4'b1111:  begin
                  qsfp_registry_up_pg20[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg20[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_up_pg20[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                  qsfp_registry_up_pg20[(qsfp_pkt.address)+3]=qsfp_pkt.writedata[31:24];
                 end
     endcase
    `uvm_info("qsfp_reg_component", $sformatf("Data written to QSFP register array : Address= 'h%h Data0= 'h%h,Data1 ='h%h Dta2 ='h%h Dta3 ='h%h for qsfp_slv_pkt_type %s and byten is %h",
                     qsfp_pkt.address,qsfp_registry_up_pg20[qsfp_pkt.address],qsfp_registry_up_pg20[(qsfp_pkt.address)+1],qsfp_registry_up_pg20[(qsfp_pkt.address)+2],qsfp_registry_up_pg20[(qsfp_pkt.address)+3],qsfp_pkt.qsfp_slv_pkt_type,qsfp_pkt.byteenable), UVM_LOW); 
    end
    end
    if(en_pg == 'h5) begin
     //fill contents of upper page21 here
     if(qsfp_pkt.qsfp_slv_pkt_type == QSFP_SLV_WRITE)begin  //write operation
     case(qsfp_pkt.byteenable)
       4'b0001:  qsfp_registry_up_pg21[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
       4'b0011:  begin 
                  qsfp_registry_up_pg21[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg21[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                 end
       4'b0111:  begin 
                  qsfp_registry_up_pg21[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg21[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_up_pg21[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                 end
       4'b1111:  begin
                  qsfp_registry_up_pg21[qsfp_pkt.address]=qsfp_pkt.writedata[7:0];
                  qsfp_registry_up_pg21[(qsfp_pkt.address)+1]=qsfp_pkt.writedata[15:8];
                  qsfp_registry_up_pg21[(qsfp_pkt.address)+2]=qsfp_pkt.writedata[23:16];
                  qsfp_registry_up_pg21[(qsfp_pkt.address)+3]=qsfp_pkt.writedata[31:24];
                 end
     endcase
    `uvm_info("qsfp_reg_component", $sformatf("Data written to QSFP register array : Address= 'h%h Data0= 'h%h,Data1 ='h%h Dta2 ='h%h Dta3 ='h%h for qsfp_slv_pkt_type %s and byten is %h",
                     qsfp_pkt.address,qsfp_registry_up_pg21[qsfp_pkt.address],qsfp_registry_up_pg21[(qsfp_pkt.address)+1],qsfp_registry_up_pg21[(qsfp_pkt.address)+2],qsfp_registry_up_pg21[(qsfp_pkt.address)+3],qsfp_pkt.qsfp_slv_pkt_type,qsfp_pkt.byteenable), UVM_LOW); 
    end
    end

   
  endfunction : update_registry


  //function logic [31:0] get_read_data(int addr,bit read,bit write,bit [7:0] writedata, bit [3:0] byteenable); //TODO
  function logic [31:0] get_read_data(int addr,bit read); 

   // if(addr == 'hfc && byteenable == 'f && writedata == 'h0000_0000 && write ==1) begin
   //     addr_count =0;
   //     pg_nxt =0;
   // end

    if(read ==1)
    begin
     addr_count = addr_count+1;
    end

   `uvm_info("qsfp_registry_component",$sformatf("addr_count is %d,addr is %h,read is %d",addr_count,addr,read),UVM_LOW);

   if (pg_nxt == 0 && addr_count <= 'd256) begin
   `uvm_info("qsfp_registry_component", $sformatf("Read value  for address is 'h%h ,Data is 'h%h,'h%h,'h%h,'h%h",addr,qsfp_registry_lo_pg0[addr],qsfp_registry_lo_pg0[addr+1],qsfp_registry_lo_pg0[addr+2],qsfp_registry_lo_pg0[addr+3]), UVM_LOW);
     if(addr_count == 'd256) begin
       addr_count = 128;
       pg_nxt ='h2;
     end
     return ({qsfp_registry_lo_pg0[addr+3],qsfp_registry_lo_pg0[addr+2],qsfp_registry_lo_pg0[addr+1],qsfp_registry_lo_pg0[addr]});
   end
   else if (pg_nxt == 8'h2 && addr_count<= 'd256) begin
   `uvm_info("qsfp_registry_component", $sformatf("Read value  for address is 'h%h ,Data is 'h%h,'h%h,'h%h,'h%h",addr,qsfp_registry_up_pg2[addr],qsfp_registry_up_pg2[addr+1],qsfp_registry_up_pg2[addr+2],qsfp_registry_up_pg2[addr+3]), UVM_LOW);
    if(addr_count == 'd256) begin
       addr_count = 'd128;
       pg_nxt='h3;
    end
     return ({qsfp_registry_up_pg2[addr+3],qsfp_registry_up_pg2[addr+2],qsfp_registry_up_pg2[addr+1],qsfp_registry_up_pg2[addr]});
   end
   else if ( pg_nxt == 8'h3 && addr_count <= 'd256) begin
   `uvm_info("qsfp_registry_component", $sformatf("Read value  for address is 'h%h ,Data is 'h%h,'h%h,'h%h,'h%h",addr,qsfp_registry_up_pg3[addr],qsfp_registry_up_pg3[addr+1],qsfp_registry_up_pg3[addr+2],qsfp_registry_up_pg3[addr+3]), UVM_LOW);
     if (addr_count =='d256) begin
         addr_count ='d128;
	 pg_nxt ='h20;
     end
     return ({qsfp_registry_up_pg3[addr+3],qsfp_registry_up_pg3[addr+2],qsfp_registry_up_pg3[addr+1],qsfp_registry_up_pg3[addr]});
   end
   else if ( pg_nxt == 8'h20 && addr_count <='d256) begin
   `uvm_info("qsfp_registry_component", $sformatf("Read value  for address is 'h%h ,Data is 'h%h,'h%h,'h%h,'h%h",addr,qsfp_registry_up_pg20[addr],qsfp_registry_up_pg20[addr+1],qsfp_registry_up_pg20[addr+2],qsfp_registry_up_pg20[addr+3]), UVM_LOW);
     if(addr_count =='d256) begin
       addr_count = 'd128;
       pg_nxt ='h21;
     end
     return ({qsfp_registry_up_pg20[addr+3],qsfp_registry_up_pg20[addr+2],qsfp_registry_up_pg20[addr+1],qsfp_registry_up_pg20[addr]});
   end
   else if ( pg_nxt == 8'h21 && addr_count <= 'd256) begin
   `uvm_info("qsfp_registry_component", $sformatf("Read value  for address is 'h%h ,Data is 'h%h,'h%h,'h%h,'h%h",addr,qsfp_registry_up_pg21[addr],qsfp_registry_up_pg21[addr+1],qsfp_registry_up_pg21[addr+2],qsfp_registry_up_pg21[addr+3]), UVM_LOW);
     if(addr_count =='d256) begin
       addr_count = 'd0;
       pg_nxt ='h0;
     end
     return ({qsfp_registry_up_pg21[addr+3],qsfp_registry_up_pg21[addr+2],qsfp_registry_up_pg21[addr+1],qsfp_registry_up_pg21[addr]});
   end
  endfunction : get_read_data




endclass: qsfp_registry_component
