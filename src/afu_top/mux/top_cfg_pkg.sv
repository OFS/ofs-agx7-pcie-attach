// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Define the parameters used in PF/VF MUX module.
//
// This reference implementation routes every function (PFs and VFs) to
// unique ports. PF0 VFs are routed to the port gasket. All PFs and
// VFs on ports other than PF0 are routed to the static region.
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

   // Number of ports in the main static-region:
   //  - One port for PF0, used for FIM fabric
   //  - A port for each non-PF0 function
   localparam NUM_SR_PORTS =
      // Sum of all PFs/VFs
      `OFS_FIM_IP_CFG_PCIE_SS_NUM_PFS + `OFS_FIM_IP_CFG_PCIE_SS_TOTAL_NUM_VFS
      // Exclude PF0 VFs (their MUX is inside the port gasket)
      - `OFS_FIM_IP_CFG_PCIE_SS_PF0_NUM_VFS;

   // The static region PF/VF MUX has an additional port for PF0 VFs, which
   // will all be routed through a single port toward the port gasket.
   localparam NUM_PORT = NUM_SR_PORTS + 1;

   localparam FIM_NUM_PF     = `OFS_FIM_IP_CFG_PCIE_SS_NUM_PFS;
   localparam FIM_NUM_VF     = `OFS_FIM_IP_CFG_PCIE_SS_TOTAL_NUM_VFS;
   localparam FIM_MAX_NUM_VF = `OFS_FIM_IP_CFG_PCIE_SS_MAX_VFS_PER_PF;
   localparam FIM_PF_WIDTH   = (FIM_NUM_PF < 2) ? 1 : $clog2(FIM_NUM_PF);
   localparam FIM_VF_WIDTH   = (FIM_NUM_VF < 2) ? 1 : $clog2(FIM_NUM_VF);

   // Number of hosts addressable in the PF/VF MUX (typically 1)
   localparam NUM_HOST = 1;
   localparam MID_WIDTH = $clog2(NUM_HOST);// ID field width for targeting host ports
   localparam NID_WIDTH = $clog2(NUM_PORT);// ID field width for targeting mux ports

   // Vector indicating whether a PF is enabled, extracted from the PCIe SS
   localparam MAX_PF_NUM = `OFS_FIM_IP_CFG_PCIE_SS_MAX_PF_NUM;
   localparam logic PF_ENABLED_VEC[MAX_PF_NUM+1] = '{ `OFS_FIM_IP_CFG_PCIE_SS_PF_ENABLED_VEC };
   // Vector with number of VFs per PF
   localparam int   PF_NUM_VFS_VEC[MAX_PF_NUM+1] = '{ `OFS_FIM_IP_CFG_PCIE_SS_NUM_VFS_VEC };


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

   // Request a shared port for PF0 VFs
   localparam ENABLE_PG_SHARED_VF = 1;

   `include "pf_vf_mux_default_rtable.vh"


   // =====================================================================
   //               Port gasket PF/VF MUX routing table
   // =====================================================================

   // PG mux parameters -- routing just the PF0 VFs
   localparam PG_NUM_PORT = `OFS_FIM_IP_CFG_PCIE_SS_PF0_NUM_VFS;

   // Port gasket routing table data structure
   localparam PG_NUM_RTABLE_ENTRIES = PG_NUM_PORT;
   typedef pf_vf_mux_pkg::t_pfvf_rtable_entry [PG_NUM_RTABLE_ENTRIES-1:0] t_prr_pf_vf_entry_info;
   localparam t_prr_pf_vf_entry_info PG_PF_VF_RTABLE = get_prr_pf_vf_entry_info();
   localparam PG_AFU_NUM_PORTS = PG_NUM_PORT;

   // The routing table in the port gasket is simple. It is just a
   // straight vector of the PF0 VFs.
   function automatic t_prr_pf_vf_entry_info get_prr_pf_vf_entry_info();
      t_prr_pf_vf_entry_info map;
      for (int p = 0; p < PG_AFU_NUM_PORTS; p = p + 1) begin
         map[p].pf        = 0;
   	 map[p].vf        = p;
         map[p].vf_active = 1;
         map[p].pfvf_port = p;
      end
      return map;
   endfunction 

endpackage : top_cfg_pkg
