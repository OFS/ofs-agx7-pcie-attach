// (C) 2001-2023 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


 //////////////////////////////////////////////////
   // PAM4 EN/DEC modules
   /////////////////////////////////////////////////
   /*
    * UX PAM4 encoding scheme:
    
    MSB,LSB   gray    p    n
            in0 in1  p1    p0
      11     1  0     1    z
      10     1  1     1    0
      01     0  1     0    z
      00     0  0     0    1
      pam4[1]->p : No encoding
      pam4[0]->n
   */
   
   module pam4_encoding( rx_serial_pam4,rx_serial_pam4_n,rx_serial,rx_serial_n);
   
          parameter NUM_LANES = 8;
          input  [NUM_LANES-1:0] rx_serial_pam4;
          input  [NUM_LANES-1:0] rx_serial_pam4_n;
          output logic [NUM_LANES-1:0] rx_serial;
          output logic [NUM_LANES-1:0] rx_serial_n;
   
          wire [1:0] in [NUM_LANES-1:0];
   
   
      for(genvar i=0; i<NUM_LANES;i++) begin
         assign in[i][0] = rx_serial_pam4_n[i];
         assign in[i][1] = rx_serial_pam4[i];
         assign rx_serial_n[i] = (in[i] ==2'b11)? 1'b0:(in[i]==2'b00)?1'b1:((in[i]==2'b01)||(in[i]==2'b10))?1'bz:1'bx; 
         assign rx_serial[i]   = in[i][1];
      end
   
   endmodule;
   
   module pam4_decoding(tx_serial,tx_serial_n,tx_serial_pam4,tx_serial_pam4_n);
   
   
          parameter NUM_LANES = 1;
          input  [NUM_LANES-1:0] tx_serial;
          input  [NUM_LANES-1:0] tx_serial_n;
          output logic [NUM_LANES-1:0] tx_serial_pam4;
          output logic [NUM_LANES-1:0] tx_serial_pam4_n;
          wire [1:0] pam4 [NUM_LANES-1:0];
   
   
   /*
    MSB,LSB   gray    p    n
            in1 in0  p1    p0
      11     1  0     1    z
      10     1  1     1    0
      01     0  1     0    z
      00     0  0     0    1
   pam4[0]->n :
   pam4[1]->p :  No encoding
   */  
   for(genvar i=0; i<NUM_LANES;i++) begin
   
     assign pam4[i][0] = tx_serial_n[i];
     assign pam4[i][1] = tx_serial[i];
     assign tx_serial_pam4_n[i]=((pam4[i]===2'b1z)||(pam4[i]===2'b01))? 1'b0:((pam4[i]===2'b10)||(pam4[i]===2'b0z))?1'b1:1'bx; 
     assign tx_serial_pam4[i]=pam4[i][1];
   
   end
   
   endmodule;

  
   
