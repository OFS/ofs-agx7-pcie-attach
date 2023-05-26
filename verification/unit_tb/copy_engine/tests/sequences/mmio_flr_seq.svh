// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

/////////////////////////////////////////////////////////////////////////
// Description:
//     Does PF/VF Loopback traffic across across all MMIO's
//     
//
// Author       :   Shalini Asopa 
// Create Date  :   04/3/2018
// Last Modified:   
//
// $Id: mmio_flr_seq.svh $
/////////////////////////////////////////////////////////////////////////

`ifndef MMIO_FLR_SEQ_SVH
`define MMIO_FLR_SEQ_SVH

//`include "cci_defines.svh"

parameter NUM_AFUS = 1;


class wr_flr1 extends `PCIE_DRIVER_TRANSACTION_CLASS_base_sequence;


rand bit  [63:0]        rd_addr;
rand bit[31:0] wr_payload[];
string msgid;


`uvm_object_utils_begin(wr_flr1)
      `uvm_field_int(rd_addr, UVM_DEFAULT)
      `uvm_field_array_int(wr_payload, UVM_DEFAULT)
`uvm_object_utils_end





function new(string name = "wr_flr1");
    super.new(name);
    wr_payload    =  new[4];
    msgid=get_type_name();
endfunction 

  virtual task body();
     `PCIE_DRIVER_TRANSACTION_CLASS write_tran,read_tran;
     bit[31:0]  dev_ctl;
     bit[31:0]  sf_ctl;


     `uvm_create(read_tran)
      read_tran.cfg                 = cfg;
      read_tran.transaction_type    = `PCIE_DRIVER_TRANSACTION_CLASS::CFG_RD;
      read_tran.address             = 'h1;
      read_tran.register_number     = 'h1E;
      read_tran.length              = 1;
      read_tran.traffic_class       = 0;
      read_tran.address_translation = 0;
      read_tran.first_dw_be         = 4'b1111;
      read_tran.last_dw_be          = 4'b0000;
      read_tran.ep                  = 0;
      read_tran.block               = 1;

      `uvm_send(read_tran)
      get_response(read_tran);
      dev_ctl = read_tran.payload[0];
      //enable  Error reporting 
     
      dev_ctl[15] =  1'b1;
     
      
    `uvm_create(write_tran)

      write_tran.cfg                 = cfg;
      write_tran.transaction_type    = `PCIE_DRIVER_TRANSACTION_CLASS::CFG_WR;
      write_tran.address             = 'h1;
      write_tran.register_number     = 'h1E;
      write_tran.length              = 1;
      write_tran.traffic_class       = 0;
      write_tran.address_translation = 0;
      write_tran.first_dw_be         = 4'b1111;
      write_tran.last_dw_be          = 4'b0000;
      write_tran.ep                  = 0;
      write_tran.block               = 1;
      write_tran.payload             = new[write_tran.length];
      foreach (write_tran.payload[i]) begin
         write_tran.payload[i]        = dev_ctl;
      end
      `uvm_send(write_tran)
      get_response(write_tran);


      `uvm_info("msgid", $sformatf("MSI: dev_ctl_wr1 write 0x%h", dev_ctl), UVM_LOW);

 
 

endtask: body
endclass: wr_flr1

class wr_flr0 extends `PCIE_DRIVER_TRANSACTION_CLASS_base_sequence;


rand bit  [63:0]        rd_addr;
rand bit[31:0] wr_payload[];
string msgid;


`uvm_object_utils_begin(wr_flr0)
      `uvm_field_int(rd_addr, UVM_DEFAULT)
      `uvm_field_array_int(wr_payload, UVM_DEFAULT)
`uvm_object_utils_end





function new(string name = "wr_flr0");
    super.new(name);
    wr_payload    =  new[4];
    msgid=get_type_name();
endfunction 

  virtual task body();
     `PCIE_DRIVER_TRANSACTION_CLASS write_tran,read_tran;
     bit[31:0]  dev_ctl;
     bit[31:0]  sf_ctl;


     `uvm_create(read_tran)
      read_tran.cfg                 = cfg;
      read_tran.transaction_type    = `PCIE_DRIVER_TRANSACTION_CLASS::CFG_RD;
      read_tran.address             = 'h0;
      read_tran.register_number     = 'h1E;
      read_tran.length              = 1;
      read_tran.traffic_class       = 0;
      read_tran.address_translation = 0;
      read_tran.first_dw_be         = 4'b1111;
      read_tran.last_dw_be          = 4'b0000;
      read_tran.ep                  = 0;
      read_tran.block               = 1;

      `uvm_send(read_tran)
      get_response(read_tran);
      dev_ctl = read_tran.payload[0];
      //enable  Error reporting 
     
      dev_ctl[15] =  1'b1;
     
      
    `uvm_create(write_tran)

      write_tran.cfg                 = cfg;
      write_tran.transaction_type    = `PCIE_DRIVER_TRANSACTION_CLASS::CFG_WR;
      write_tran.address             = 'h0;
      write_tran.register_number     = 'h1E;
      write_tran.length              = 1;
      write_tran.traffic_class       = 0;
      write_tran.address_translation = 0;
      write_tran.first_dw_be         = 4'b1111;
      write_tran.last_dw_be          = 4'b0000;
      write_tran.ep                  = 0;
      write_tran.block               = 1;
      write_tran.payload             = new[write_tran.length];
      foreach (write_tran.payload[i]) begin
         write_tran.payload[i]        = dev_ctl;
      end
      `uvm_send(write_tran)
      get_response(write_tran);


      `uvm_info("msgid", $sformatf("MSI: dev_ctl_wr0 write 0x%h", dev_ctl), UVM_LOW);

 
 

endtask: body
endclass: wr_flr0



class mmio_flr_seq extends base_seq;

//cci_driver      cci_driver[NUM_AFUS];
`uvm_declare_p_sequencer(virtual_sequencer)


enumerate_seq   enumerate_seq2;
pcie_device_bring_up_link_sequence bring_up_link_seq;
uvm_status_e    status;
uvm_reg_data_t  reg_data;
`PCIE_DRIVER_DRIVER_APP_MEM_REQUEST_SEQ mem_request_seq;
string msgid;

rand int test_length;
rand int loops;

typedef enum {
PF = 0,
VF = 1
} mode_t;

rand mode_t afu_mode[NUM_AFUS];
rand mode_t reset_mode[NUM_AFUS];
rand bit                length_in_dw;
rand bit  [63:0]        BAR_OFFSET ;       
rand bit  [63:0]        ADDR;
rand bit  [63:0]        FADDR;
rand bit  [63:0]        PADDR;
rand bit  [63:0]        VPADDR;
rand bit  [63:0]        AADDR;
string                  msgid;

    constraint afu_mode_constraint {
        soft test_length inside {[20:25]};
      //  soft loops       inside {[2:3]};
        soft loops       == 0;
        afu_mode[0] == PF;
        reset_mode[0] == PF;
     }


constraint _pcie_length_c {
  length_in_dw  dist {
    2 := 20,
    1 := 5,
    4 := 1
    
   };

}

constraint addr_offset_c {
        BAR_OFFSET == `PF0_BAR0;
 
constraint fme_addr_c {
     AADDR inside {'h0000,'h0008,'h0018,'h0028,'h0030,'h0038,'h0040} ;
     FADDR[63:32] == 32'h0000;
     FADDR[31:0] inside {'h0000,'h0008,'h0018,'h0028,'h0030,'h0038,'h0040,
                                                 'h0048,'h0050,'h0058,'h0060,'h0068,'h1000,'h1008,
                                                 'h1010,'h1018,'h1020,'h2000,'h2008,'h2010,'h2018,
                                                 'h2020,'h2028,'h3000,'h3020,'h3028,'h3030,'h4000,
                                                 'h4000,'h4010,'h4018,'h4020,'h4038,'h4040,'h4048,
                                                 'h4050,'h4058,'h4060,'h4068,'h4070,'h5000,'h5008,
                                                 'h5010,'h5020,'h50B0,'h6000,'h6008,'h6010,'h9000,
                                                 'h9000,'h9008,'h9010,'h9018,'h9020,'h9028,'h9030,
                                                 'h9038,'h9040,'h9048,'h9050,'h9058,'h9060,'h9068,
                                                 'h9070,'h9078,'ha000,'ha008
                                                };
}


constraint default_constraint {

       solve afu_mode[0] before BAR_OFFSET;

        (afu_mode[0]   == VF) -> {BAR_OFFSET inside {`PF1_VF0_BAR0,`PF2_VF0_BAR0,`PF2_VF1_BAR0};}
   //     (afu_mode[0]   == VF) -> {BAR_OFFSET inside {PF1_VF0_BAR0,PF2_VF0_BAR0,PF2_VF1_BAR0};}

        (afu_mode[0]   == PF) -> {BAR_OFFSET inside {`PF0_BAR0};}
       // (afu_mode[0]   == PF) -> {BAR_OFFSET inside {`PF0_BAR0,`PF1_BAR0,`PF2_BAR0,`PF3_BAR0,`PF3_BAR4};}
        
}


    `uvm_object_utils(mmio_flr_seq)
   // `uvm_declare_p_sequencer(pcie_fpga_virtual_sequencer)


// ---------------------------------------------------------------------------

function new(string name = "test_afu_mmio_vf_seq");
    super.new(name); 
    msgid=get_type_name();
endfunction    


// ---------------------------------------------------------------------------

virtual task body();   


    `uvm_info(msgid, "Entered MMIO test Sequence", UVM_LOW);

    test_action();
    
    #30us;

    `uvm_info(msgid, "Exiting MMIO test  Sequence", UVM_LOW);


endtask

// ---------------------------------------------------------------------------

task test_action();

     #10us;
 
       fork

           begin//AFU FLR Thread
                                for(int i=0;i<NUM_AFUS;i++) fork
                                automatic int afu_thread=i;

                                afu_flr_seq(afu_thread);
                                join_none
           end
      
       
           begin
                fme_seq();   //Background FME MMIO Thread
           end
         

       join

       wait fork;
       #200us; 

       
endtask: test_action

task fme_seq();
//avl_mmio_lpbk_rand_seq fme_seq;

     `uvm_info(msgid, $sformatf("Entered FME MMIO test sequence"), UVM_LOW);

        
      begin


      repeat(3) begin


      `uvm_do_on_with(mem_request_seq,p_sequencer.root_virt_seqr.driver_transaction_seqr[0],{ mem_request_seq.transaction_type == `PCIE_DRIVER_TRANSACTION_CLASS::MEM_WR;
                                                                                                              mem_request_seq.address == (`PF0_BAR0 + FADDR ) ;
                                                                                                              mem_request_seq.length == 2 ;
                                                                                                              mem_request_seq.traffic_class == 0;
                                                                                                              mem_request_seq.address_translation == 0;
                                                                                                              mem_request_seq.first_dw_be == 4'b1111;
                                                                                                              mem_request_seq.last_dw_be    == 4'b1111;
                                                                                                              mem_request_seq.ep == 0;
                                                                                                              mem_request_seq.th == 0;
                                                                                                              mem_request_seq.block == 0; });

        #1us;

        `uvm_do_on_with(mem_request_seq,p_sequencer.root_virt_seqr.driver_transaction_seqr[0],{ mem_request_seq.transaction_type == `PCIE_DRIVER_TRANSACTION_CLASS::MEM_RD;
                                                                                                              mem_request_seq.address == (`PF0_BAR0 + FADDR) ;
                                                                                                              mem_request_seq.length == 2;
                                                                                                              mem_request_seq.traffic_class == 0;
                                                                                                              mem_request_seq.first_dw_be   == 4'b1111;
                                                                                                              mem_request_seq.last_dw_be    == 4'b1111;
                                                                                                              mem_request_seq.address_translation == 0;
                                                                                                              mem_request_seq.ep == 0;
                                      									      mem_request_seq.th == 0;	
                                                                                                              mem_request_seq.block == 0; });
 
        #1us;
        
        end

      end

endtask: fme_seq



// ---------------------------------------------------------------------------

task afu_flr_seq(int port=0);
//avl_mmio_lpbk_rand_seq afu_seq0,afu_seq1;
int timeout;

    `uvm_info(msgid, $sformatf("Entered AFU%0d FLR test sequence",port), UVM_LOW);
    
    for(int i=0;i<=loops;i++) begin

        `uvm_info(msgid, $sformatf("FLR Check with AFU%0d in %s mode and %s FLR...",port,afu_mode[0],reset_mode[port]), UVM_LOW);

        `uvm_do_on_with(mem_request_seq,p_sequencer.root_virt_seqr.driver_transaction_seqr[0],{ mem_request_seq.transaction_type == `PCIE_DRIVER_TRANSACTION_CLASS::MEM_WR;
                                                                                                              mem_request_seq.address == (BAR_OFFSET + AADDR  ) ;
                                                                                                            //  mem_request_seq.address == (BAR2_RANGE + AADDR  ) ;
                                                                                                              mem_request_seq.length == 2 ;
                                                                                                              mem_request_seq.traffic_class == 0;
                                                                                                              mem_request_seq.address_translation == 0;
                                                                                                              mem_request_seq.first_dw_be == 4'b1111;
                                                                                                              mem_request_seq.last_dw_be    == 4'b1111;
                                                                                                              mem_request_seq.ep == 0;
                                                                                                              mem_request_seq.th == 0;
                                                                                                              mem_request_seq.write_payload[0] == changeEndian(32'h11111111);
       												              mem_request_seq.write_payload[1] == changeEndian(32'h11111111);
                                                                                                              mem_request_seq.block == 0; });

         #1us;

        `uvm_info(msgid, $sformatf("Before reset for AFU%0d ",port), UVM_LOW);

         afu_flr_reset(reset_mode[port],port);

         `uvm_info(msgid, $sformatf("After reset for AFU%0d ",port), UVM_LOW);
 

         `uvm_info(msgid, $sformatf("Injected downstream traffic post FLR..."), UVM_LOW);
 
    #50us;

   end

endtask: afu_flr_seq


task afu_flr_reset(mode_t afu_mode,bit afu_num=0);
wr_flr1 wr1_seq;
wr_flr0 wr0_seq;

         `uvm_info(msgid,$sformatf("Entered Primary reset task..."),UVM_LOW);

    case(afu_mode)
	PF:     begin
                `uvm_info(msgid,$sformatf("Initiating PF FLR Reset..."),UVM_LOW);

 
               `uvm_do_on(wr0_seq,p_sequencer.root_virt_seqr.driver_transaction_seqr[0]);

              
             //  #1.32us;
               #4.32us;



               `uvm_do_on(enumerate_seq2,p_sequencer.root_virt_seqr.driver_transaction_seqr[0]);


                 
            end


    VF:    begin
                `uvm_info(msgid,$sformatf("Initiating VF FLR Reset for AFU%0d...",afu_num),UVM_LOW); 


                `uvm_do_on(wr1_seq,p_sequencer.root_virt_seqr.driver_transaction_seqr[0]);
               
            // #1.32us;
             #4.32us;
           
               `uvm_do_on(enumerate_seq2,p_sequencer.root_virt_seqr.driver_transaction_seqr[0]);

                                         
           end
    endcase

    wait fork;
endtask: afu_flr_reset


endclass: mmio_flr_seq


`endif

    



