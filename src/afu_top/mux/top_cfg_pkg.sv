// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Define the parameters used in PF/VF MUX module.
//
// This reference implementation routes every function (PFs and VFs) to
// unique ports. PF0 VFs are routed to the port gasket when enabled else PF1
// is routed to the Port Gasket. All PFs and VFs on ports other than PF0 
// are routed to the static region when VFs are enabled on PF0.
// All PFs and VFs on ports other than PF0 and PF1 
// are routed to the static region when VFs are disabled on PF0.
//
// FIM developers may change the routing policy by replacing the routing
// table generated here. In general, the table only needs to be changed
// if multiple functions are going to be mapped to the same router port.
//
// NOTE: The function-level reset mapping in afu_top matches the default
//       router port mapping. If the mapping here changes then the reset
//       mapping in afu_top must also be changed!
//
//-----------------------------------------------------------------------------

// Load macros derived from the PCIe SS configuration
`include "ofs_ip_cfg_db.vh"

package top_cfg_pkg;

   localparam FIM_NUM_LINKS  = `OFS_FIM_IP_CFG_PCIE_SS_NUM_LINKS;
   localparam FIM_NUM_PF     = `OFS_FIM_IP_CFG_PCIE_SS_NUM_PFS;
   localparam FIM_NUM_VF     = `OFS_FIM_IP_CFG_PCIE_SS_TOTAL_NUM_VFS;
   localparam FIM_MAX_NUM_VF = `OFS_FIM_IP_CFG_PCIE_SS_MAX_VFS_PER_PF;
   localparam FIM_PF_WIDTH   = (FIM_NUM_PF < 2) ? 1 : $clog2(FIM_NUM_PF);
   localparam FIM_VF_WIDTH   = (FIM_NUM_VF < 2) ? 1 : $clog2(FIM_NUM_VF);

   // Number of hosts addressable in the PF/VF MUX (typically 1)
   localparam NUM_HOST = 1;
   // localparam MID_WIDTH = $clog2(NUM_HOST);// ID field width for targeting host ports
   // localparam NID_WIDTH = $clog2(NUM_PORT);// ID field width for targeting mux ports

   // Vector indicating whether a PF is enabled, extracted from the PCIe SS
   localparam MAX_PF_NUM = `OFS_FIM_IP_CFG_PCIE_SS_MAX_PF_NUM;
   localparam logic PF_ENABLED_VEC[MAX_PF_NUM+1] = '{ `OFS_FIM_IP_CFG_PCIE_SS_PF_ENABLED_VEC };
   // Vector with number of VFs per PF
   localparam int   PF_NUM_VFS_VEC[MAX_PF_NUM+1] = '{ `OFS_FIM_IP_CFG_PCIE_SS_NUM_VFS_VEC };

   `ifdef OFS_FIM_IP_CFG_PCIE_SS_PF0_NUM_VFS
      localparam PG_VFS = `OFS_FIM_IP_CFG_PCIE_SS_PF0_NUM_VFS;
   `else
      localparam PG_VFS = 0;
   `endif


   // =====================================================================
   //                Static region PF/VF MUX routing table
   // =====================================================================

   // Build the default static region routing table. The functions are in a header
   // file because the algorithm is general but the data types are dependent on
   // the parameters above.
   //
   // The included code generates a routing table as a parameter named
   // SR_PF_VF_RTABLE of type t_pf_vf_entry_info (also generated). See
   // the header file in ofs-common/src/common/lib/mux/ for more details.
   //
   // A developer building a new FIM could choose to remove this include
   // and generate a workload-specific table here. The table could be generated
   // either with a different function or with static initializers.

   // Request a shared port for PF0 VFs when VFs are enabled
   // else request port for PF1.
   localparam ENABLE_PG_SHARED_VF = (PF_NUM_VFS_VEC[0] > 0);

   // Number of ports in AFU top: 
   // PF0  : ST2MM (OFS management)
   // PF0VF: When VFs are enabled on PF0 or PF1 when VFs are disabled on PF0 : Port Gasket
   // Port Gasket is always instantiated either with PF0VFs or PF1.
   // PF1+ : When VFs are enabled on PF0 or PF2+ when VFs are disabled on PF0 : static-region afu
   localparam NUM_TOP_PORTS = int'(PF_ENABLED_VEC[0]) + 1 + (ENABLE_PG_SHARED_VF ? (MAX_PF_NUM > 0) : (MAX_PF_NUM > 1));

   // Number of ports in the static-region AFU block:
   //  - A port for each non-PF0 function when VFs are enabled on PF0 or
   //  - A port for each non-PF0 and non-PF1 function when VFs are not enabled
   //  on PF0
   localparam NUM_SR_PORTS = FIM_NUM_PF + FIM_NUM_VF - int'(PF_ENABLED_VEC[0]) - ((PF_NUM_VFS_VEC[0] > 0 ) ? (PF_NUM_VFS_VEC[0]) : (PF_ENABLED_VEC[1])) ;

   // PG mux parameters
   // routing PF0 VFs when VFs are enabled on PF0 or
   // routing PF1 when VFs are disabled on PF0
   localparam PG_NUM_PORT = (PG_VFS > 0) ? PG_VFS : 1;
   localparam PG_NUM_LINKS = FIM_NUM_LINKS;


   `include "pf_vf_mux_default_rtable.vh"


   // =====================================================================
   //               Port gasket PF/VF MUX routing table
   // ===================================================================== 
   // Port gasket routing table data structure
   localparam PG_NUM_RTABLE_ENTRIES = PG_NUM_PORT;
   typedef pf_vf_mux_pkg::t_pfvf_rtable_entry [PG_NUM_RTABLE_ENTRIES-1:0] t_prr_pf_vf_entry_info;
   localparam t_prr_pf_vf_entry_info PG_PF_VF_RTABLE = get_prr_pf_vf_entry_info();
   localparam PG_AFU_NUM_PORTS = PG_NUM_PORT;

   // The routing table in the port gasket is a
   // straight vector of PF0 VFs when enabled or PF1
   // when VFs on PF0 are disabled.
   function automatic t_prr_pf_vf_entry_info get_prr_pf_vf_entry_info();
      t_prr_pf_vf_entry_info map;
      for (int p = 0; p < PG_AFU_NUM_PORTS; p = p + 1) begin
         map[p].pf        = (PG_VFS > 0 ) ? 0 : 1; // pf0-vfs or pf1
   	 map[p].vf        = p;
         map[p].vf_active = (PG_VFS > 0 ) ? 1 : 0; // pf0-vfs or pf1
         map[p].pfvf_port = p;
      end
      return map;
   endfunction 

endpackage : top_cfg_pkg
