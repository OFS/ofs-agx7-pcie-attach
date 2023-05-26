// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_B2B_WR_RD_SEQ_SVH
`define CE_B2B_WR_RD_SEQ_SVH

class ce_b2b_wr_rd_seq extends base_seq;
 `uvm_object_utils(ce_b2b_wr_rd_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "ce_b2b_wr_rd_seq");
        super.new(name);
    endfunction : new
 task body();
	bit [63:0]   wdata,rdata,mask,expdata,addr;
                          

        super.body();
        `uvm_info(get_name(), "Entering ce_b2b_wr_rd_seq...", UVM_LOW)
	         
			//write followed by a read

         wdata=64'hdead_beef;
         addr = `PF4_BAR0+'h0000;
         fork		
		   mmio_write64(.addr_(addr), .data_(wdata));
         mmio_read64(.addr_(addr), .data_(rdata));
         join

         if(rdata == wdata) begin
            `uvm_info(get_name(), $psprintf(" Details are Addr= %0h, Exp = %0h, Act = %0h", addr,wdata,rdata),UVM_LOW)
         end


         //read followed by a read
         mmio_read64(.addr_(addr), .data_(rdata));
         mmio_read64(.addr_(addr), .data_(rdata));


         //read followed by a write
         wdata=64'hFFFF_AAAA;
         mmio_read64(.addr_(addr), .data_(rdata));
         mmio_write64(.addr_(addr), .data_(wdata));

         //write_follwed by a write
         wdata=64'hdead_beef;
         mmio_write64(.addr_(addr), .data_(wdata));
         wdata=64'hFFFF_AAAA;
         mmio_write64(.addr_(addr), .data_(wdata));

endtask : body

 
endclass :  ce_b2b_wr_rd_seq

`endif //  ce_b2b_wr_rd_SEQ_SVH


