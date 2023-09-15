// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_PIO_OUTPUT_TOGGLE_PARALLEL_SEQ_SVH
`define QSFP_PIO_OUTPUT_TOGGLE_PARALLEL_SEQ_SVH

class qsfp_pio_output_toggle_parallel_seq extends qsfp_base_seq;
  `uvm_object_utils(qsfp_pio_output_toggle_parallel_seq)
  `uvm_declare_p_sequencer(qsfp_virtual_sequencer)
  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstb;

  function new(string name = "qsfp_pio_output_toggle_parallel_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();
   `uvm_info(get_name(), $psprintf("qsfp_pio_output_toggle_parallel_test START"), UVM_LOW)

   `uvm_info(get_name(), $psprintf("Writing to I2C Config Register to set SoftResetQSFPM,LPMode,ModSel=1 "), UVM_LOW)
   address = 18'h0020;
   data    = 64'h0000_000D;
   wstb    = 8'hFF;
   wr_tx_register(address,data,wstb);
  
    //Check the SoftResetQSFPM,LPMode,ModSel=1 is asserted on QSFP interface
    
   if (qsfp_if.softresetqsfm == 1 && qsfp_if.lpmode ==1 && qsfp_if.modsel ==1)
     `uvm_info(get_name(),$psprintf("ALL the PIO pins are set"),UVM_LOW)
   else
     `uvm_error("PIO_ERROR","PIO PINS ARE NOT SET---ERROR")



   `uvm_info(get_name(), $psprintf("Writing to I2C Config Register to set SoftResetQSFPM,LPMode,ModSel=0 "), UVM_LOW)
   address=18'h0020;
   data = 64'h0000_0000;
   wstb = 8'hFF;
   wr_tx_register(address,data,wstb);
  
   if (qsfp_if.softresetqsfm == 0 && qsfp_if.lpmode == 0 && qsfp_if.modsel == 0)
     `uvm_info(get_name(),$psprintf("ALL the PIO pins are cleared"),UVM_LOW)
   else
     `uvm_error("PIO_ERROR","PIO PINS ARE NOT CLEARED---ERROR")

  endtask : body

 endclass : qsfp_pio_output_toggle_parallel_seq

`endif // QSFP_PIO_OUTPUT_TOGGLE_PARALLEL_SEQ_SVH

