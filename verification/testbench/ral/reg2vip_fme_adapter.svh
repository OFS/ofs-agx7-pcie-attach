// Copyright (C) 2017, 2020 Intel Corporation
// SPDX-License-Identifier: MIT

//-----------------------------------------------------------------------------
// Description: REG2PCIE Adapter class
//-----------------------------------------------------------------------------

`ifndef reg2vip_fme_adapter_SVH
`define reg2vip_fme_adapter_SVH



class reg2vip_fme_adapter extends uvm_reg_adapter;
string                 msgid;
bit[15:0]              rid;   //Config by env  
bit[63:0]               bar;
static local bit[7:0]  gtag;
uvm_reg_map            reg_map;
uvm_reg                curr_reg;
int                    ral_trk_file;
bit   [63:0] le_ep;



  `uvm_object_utils(reg2vip_fme_adapter)

 virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    
    uvm_reg_item item = get_item();
    `PCIE_DRIVER_TRANSACTION_CLASS avl =  `PCIE_DRIVER_TRANSACTION_CLASS::type_id::create("`PCIE_DRIVER_TRANSACTION_CLASS");

      // avl_sequence_item  avl = avl_sequence_item::type_id::create("avl_sequence_item");
    avl.transaction_type = (rw.kind == UVM_READ) ? 0 : 2;
     avl.address = bar + rw.addr;
    avl.first_dw_be = 4'b1111;
      	avl.traffic_class = 0;
	avl.ep = 0;
	 avl.ph = 1;
         avl.block = 0;
	 
        //curr_reg=reg_map.get_reg_by_offset(rw.addr);
	avl.length = rw.n_bits >> 5;
	if(avl.length == 1) begin
	    avl.last_dw_be  = 4'b0000;
	end
	else if(avl.length == 2) begin
	    avl.last_dw_be  = 4'b1111;
	end
	else begin
            `uvm_fatal(get_name(), "RAL PCIe TLP length is not 1 or 2")
	end

        if(rw.kind == UVM_WRITE) begin
	    avl.payload = new[avl.length];
	    avl.payload[0] = changeEndian(rw.data[31:0]);
	    if(avl.length == 2)
	        avl.payload[1] = changeEndian(rw.data[63:32]);
	end

 
    return avl;
  endfunction


  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
   // avl_sequence_item  avl;
    `PCIE_DRIVER_TRANSACTION_CLASS avl;

    if (!$cast(avl,bus_item)) begin
        `uvm_error(msgid,"avl_item cast failed on bus2reg call...");
        return;
    end
    rw.kind = (avl.transaction_type == 0) ? UVM_READ : UVM_WRITE;
    rw.status = UVM_IS_OK;
    rw.data[31:0]   = changeEndian (avl.payload[0]);
    if(avl.payload.size == 2)   
    rw.data[63:32]  = changeEndian (avl.payload[1]);
  endfunction


  function new(string name="reg2vip_fme_adapter");
     super.new(name);
     //supports_byte_enable = 1;
     provides_responses = 1;
     msgid=get_type_name();
  endfunction


   function [31:0] changeEndian;   //transform data from the memory to big-endian form
    input [31:0] value;
    changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
   endfunction





  
endclass: reg2vip_fme_adapter

`endif
