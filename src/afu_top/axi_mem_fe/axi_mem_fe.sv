// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
//-----------------------------------------------------------------------------
// Description
//-----------------------------------------------------------------------------
//
// AXI-MM front end to generate traffic switch for HE-MEM channels & passthrough
// for additional traffic generators
//
//-----------------------------------------------------------------------------

module axi_mem_fe #(
   parameter HE_MEM_CHANNEL  = 1,
   parameter AFU_MEM_CHANNEL = 4
)(
   // Sideband signal to select test channel
   input [AFU_MEM_CHANNEL-1:0] tg_en,

   // AXI-MM source interfaces
`ifdef INCLUDE_MEM_TG
   ofs_fim_emif_axi_mm_if.emif        tg_mem_if [AFU_MEM_CHANNEL-1:0],
`endif
   ofs_fim_emif_axi_mm_if.emif        he_mem_if [HE_MEM_CHANNEL-1:0],

   // External Memory I/F
   ofs_fim_emif_axi_mm_if.user        ext_mem_if [AFU_MEM_CHANNEL-1:0]
);
genvar ch;
`ifdef INCLUDE_MEM_TG
generate
   for(ch = 0; ch < HE_MEM_CHANNEL; ch = ch+1) begin : mem_mux
      axi_mem_mux mem_mux_inst (
         .sel        (tg_en[ch]),
         .in0_mem_if (he_mem_if[ch]),
         .in1_mem_if (tg_mem_if[ch]),
         .out_mem_if (ext_mem_if[ch])
      );
   end
   for(ch = HE_MEM_CHANNEL; ch < AFU_MEM_CHANNEL; ch = ch+1) begin : mem_pass
      axi_mem_pass mem_pass_inst (
         .in_mem_if  (tg_mem_if[ch]),
         .out_mem_if (ext_mem_if[ch])
      );
   end
   
endgenerate
`else 
generate
   for(ch = 0; ch < HE_MEM_CHANNEL; ch = ch+1) begin : mem_pass
      axi_mem_pass mem_pass_inst (
         .in_mem_if  (he_mem_if[ch]),
         .out_mem_if (ext_mem_if[ch])
      );
   end
endgenerate
`endif
   

   
endmodule // axi_mem_fe

