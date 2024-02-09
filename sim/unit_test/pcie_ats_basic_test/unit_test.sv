// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

`include "ofs_ip_cfg_db.vh"

//---------------------------------------------------------
// Test module for the simulation. 
//---------------------------------------------------------

import host_bfm_types_pkg::*;

module unit_test #(
   parameter SOC_ATTACH = 0,
   parameter type pf_type = default_pfs, 
   parameter pf_type pf_list = '{1'b1}, 
   parameter type vf_type = default_vfs, 
   parameter vf_type vf_list = '{0}
)(
    input logic clk,
    input logic rst_n,
    input logic csr_clk,
    input logic csr_rst_n
);

import pfvf_class_pkg::*;
import host_memory_class_pkg::*;
import tag_manager_class_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;
import host_axis_send_class_pkg::*;
import host_axis_receive_class_pkg::*;
import host_transaction_class_pkg::*;
import host_bfm_class_pkg::*;
import host_flr_class_pkg::*;

// Configured PCIe capabilities. These parameters are read from the PCIe SS IP
// and written as macros to a header file included by ofs_ip_cfg_db.vh as
// part of the Quartus project.
localparam PCIE_NUM_PFS = `OFS_FIM_IP_CFG_PCIE_SS_NUM_PFS;
localparam logic PCIE_ATS_CAP_EN[PCIE_NUM_PFS] = { `OFS_FIM_IP_CFG_PCIE_SS_ATS_CAP_VEC };
localparam logic PCIE_VF_ATS_CAP_EN[PCIE_NUM_PFS] = { `OFS_FIM_IP_CFG_PCIE_SS_VF_ATS_CAP_VEC };
localparam logic PCIE_PRS_CAP_EN[PCIE_NUM_PFS] = { `OFS_FIM_IP_CFG_PCIE_SS_PRS_CAP_VEC };
localparam logic PCIE_PASID_CAP_EN[PCIE_NUM_PFS] = { `OFS_FIM_IP_CFG_PCIE_SS_PASID_CAP_VEC };

//---------------------------------------------------------
//  BEGIN: Test Tasks and Utilities
//---------------------------------------------------------
parameter MAX_TEST = 100;
parameter TIMEOUT = 10.0ms;
parameter RP_MAX_TAGS = 64;

typedef struct packed {
    logic result;
    logic [1024*8-1:0] name;
} t_test_info;

typedef enum bit [1:0] {MWR, MRD, CPLD, CPL} e_tlp_type;
typedef enum bit {ADDR32, ADDR64} e_addr_mode;
typedef enum bit {BIG_ENDIAN, LITTLE_ENDIAN} e_endian;

int err_count = 0;
logic [31:0] test_id;
t_test_info [MAX_TEST-1:0] test_summary;
logic reset_test;
logic [7:0] checker_err_count;
logic test_done;
logic test_result;

//---------------------------------------------------------
// PFVF Structs 
//---------------------------------------------------------
pfvf_struct pfvf;

//---------------------------------------------------------
//  Test Utilities
//---------------------------------------------------------
function void incr_err_count();
    err_count++;
endfunction


function int get_err_count();
    return err_count;
endfunction

// Return the pfvf_type_t associated with a PF/VF
//function automatic pfvf_def_pkg::pfvf_type_t pfvf_type_from_pfvf(int pf, int vf, bit vf_active);
//    pfvf_def_pkg::pfvf_type_t pfvf_idx;
function automatic pfvf_struct pfvf_type_from_pfvf(int pf, int vf, bit vf_active);
    pfvf_struct pfvf_idx;
    PFVFClass#(pf_type, vf_type, pf_list, vf_list) pfvf;

    pfvf = new(pf,vf,vf_active);

    if (pfvf.pfvf_exists(pf,vf,vf_active))
    begin
       return (pfvf.get_attr());
    end
    else
    begin
       $fatal(1, "PFVF for PF%0d, VF%0d, vf_active %0d not found!", pf, vf, vf_active);
       pfvf.get_pfvf_first(pfvf_idx);
       return (pfvf_idx);
    end
endfunction // pfvf_type_from_pfvf


//---------------------------------------------------------
//  Test Tasks
//---------------------------------------------------------
task incr_test_id;
begin
    test_id = test_id + 1;
end
endtask

task post_test_util;
    input logic [31:0] old_test_err_count;
    logic result;
begin
    if (get_err_count() > old_test_err_count) 
    begin
        result = 1'b0;
    end else begin
        result = 1'b1;
    end

    repeat (10) @(posedge clk);

    @(posedge clk);
    reset_test = 1'b1;
    repeat (5) @(posedge clk);
    reset_test = 1'b0;

    if (result) 
    begin
        $display("\nTest status: OK");
        test_summary[test_id].result = 1'b1;
    end 
    else 
    begin
        $display("\nTest status: FAILED");
        test_summary[test_id].result = 1'b0;
    end
    incr_test_id(); 
end
endtask


task print_test_header;
    input [1024*8-1:0] test_name;
    input logic        vf_active;
    input logic [2:0]  pfn;
    input logic [10:0] vfn;
begin
    $display("\n********************************************");
    $display(" Running TEST(%0d) : %0s (vf_active=%0d, pfn=%0d vfn=%0d", test_id, test_name, vf_active, pfn, vfn);
    $display("********************************************");   
    test_summary[test_id].name = test_name;
end
endtask


// Deassert AFU reset
task deassert_afu_reset;
    int count;
    logic [63:0] scratch;
    logic [31:0] wdata;
    logic        error;
    logic [31:0] PORT_CONTROL;
begin
    count = 0;
    PORT_CONTROL = 32'h71000 + 32'h38;
    $display("\nDe-asserting Port Reset...");
    pfvf = '{0,0,0}; // Set PFVF to PF0
    host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
    host_bfm_top.host_bfm.read64(PORT_CONTROL, scratch);
    wdata = scratch[31:0];
    wdata[0] = 1'b0;
    host_bfm_top.host_bfm.write32(PORT_CONTROL, wdata);
    #5000000 host_bfm_top.host_bfm.read64(PORT_CONTROL, scratch);
    if (scratch[4] != 1'b0) begin
        $display("\nERROR: Port Reset Ack Asserted!");
        incr_err_count();
        $finish;       
    end
    $display("\nAFU is out of reset ...");
    host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
end
endtask

task send_ats_inval;
   input logic [15:0] tgt_device_id;
   input logic [4:0] itag;

   byte_t payload[];
begin
    payload = new [8];
    for (int i = 0; i < 8; i = i + 1) begin
        payload[i] = 8'(i);
    end

    host_bfm_top.host_bfm.send_msg(DATA_PRESENT, ROUTED_BY_ID, 0,
                                   pcie_ss_hdr_pkg::PCIE_MSGCODE_ATS_INVAL_REQ, // code
                                   { tgt_device_id, 16'h0 }, // upper msg
                                   0,                        // lower msg
                                   itag,
                                   payload);
end
endtask // send_ats_inval

task recv_ats_inval_cpl;
    input logic [15:0] tgt_device_id;
    input logic [4:0] expected_itag;
    input logic [2:0] expected_cc;

    Packet#(pf_type, vf_type, pf_list, vf_list) p;
    logic [2:0] actual_cc;
    logic [31:0] actual_itag_vec;
begin
    // In the test, the FIM's ATS invalidation responder returns 1 message.
    // The AFU's responder returns 2, one on TX_A and the other initially 
    // on TX_B.
    for (int i = 0; i < expected_cc; i = i + 1) begin
        // Wait for a new message
        @(posedge clk iff (host_bfm_top.tx_inbound_message_queue.size() > 0));

        p = host_bfm_top.tx_inbound_message_queue.pop_front();
        actual_cc = 3'(p.get_lower_msg());
        actual_itag_vec = p.get_upper_msg();

        if (actual_cc != expected_cc) begin
            $display("\nERROR: Expected %d ATS inval responses but received %d",
                     expected_cc, actual_cc);
            incr_err_count();
            $finish;
        end

        if ((1 << expected_itag) != actual_itag_vec) begin
            $display("\nERROR: Expected ATS inval ITAG %b but received %b",
                     (1 << expected_itag), actual_itag_vec);
            incr_err_count();
        end
    end
end
endtask // recv_ats_inval_cpl


//---------------------------------------------------------
//  END: Test Tasks and Utilities
//---------------------------------------------------------

//---------------------------------------------------------
// Initials for Sim Setup
//---------------------------------------------------------
initial 
begin
    reset_test = 1'b0;
    test_id = '0;
    test_done = 1'b0;
    test_result = 1'b0;
end


initial 
begin
    fork: timeout_thread begin
        $display("Begin Timeout Thread.  Test will timeout in %0t\n", TIMEOUT);
        // timeout thread, wait for TIMEOUT period to pass
        #(TIMEOUT);
        // The test hasn't finished within TIMEOUT Period
        @(posedge clk);
        $display ("TIMEOUT, test_pass didn't go high in %0t\n", TIMEOUT);
        disable timeout_thread;
    end
        
        wait (test_done==1) begin
            // Test summary
            $display("\n********************");
            $display("  Test summary");
            $display("********************");
            for (int i=0; i < test_id; i=i+1) 
            begin
                if (test_summary[i].result)
                  $display("   %0s (id=%0d) - pass", test_summary[i].name, i);
                else
                  $display("   %0s (id=%0d) - FAILED", test_summary[i].name, i);
            end

            if(get_err_count() == 0) 
            begin
                $display("Test passed!");
            end 
            else 
            begin
                if (get_err_count() != 0) 
                begin
                    $display("Test FAILED! %d errors reported.\n", get_err_count());
                end
            end
        end
    join_any    
    $finish();  
end

always begin : main   
    #10000;
    wait (rst_n);
    $display("MAIN Always - After Wait for rst_n.");
    wait (csr_rst_n);
    $display("MAIN Always - After Wait for csr_rst_n.");

`ifndef OFS_FIM_IP_CFG_PCIE_SS_ATS_CAP
    $display("PCIe ATS not enabled - nothing to test.");
`else
    for (int pf = 0; pf < PCIE_NUM_PFS; pf = pf + 1) begin
        if (PCIE_ATS_CAP_EN[pf]) begin
            if (! PCIE_PRS_CAP_EN[pf]) begin
                $display("ERROR: ATS is enabled on PF%0d but PRS is not!", pf);
                incr_err_count();
            end

            if (! PCIE_PASID_CAP_EN[pf]) begin
                $display("ERROR: ATS is enabled on PF%0d but PASID is not!", pf);
                incr_err_count();
            end
        end
    end

    if (err_count != 0)
        $finish;

    //-------------------------
    // deassert port reset
    //-------------------------
    deassert_afu_reset();
    $display("MAIN Always - After Deassert of AFU Reset.");
    //-------------------------
    // Test scenarios 
    //-------------------------
    main_test(test_result);
    $display("MAIN Always - After Main Task.");
`endif

    test_done = 1'b1;
end


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
    output logic test_result;

    string test_name;
    //pfvf_type_t pfvf_idx;
    pfvf_struct pfvf_idx;
    PFVFClass#(pf_type, vf_type, pf_list, vf_list) pfvf;

    logic [31:0] old_test_err_count;

    int pf;
    int vf;
    bit vf_active;

    logic [63:0] scratch;
    logic [15:0] port_dev_id;
    bit [4:0] ats_inval_itag;

    logic [63:0] va, pa;
    byte_t va_to_pa[];

    uint64_t ctr_val;
    uint64_t ctr_vec[];
    ctr_vec = new [1];

    test_result = 1'b1;

    va = 'h748051000;
    pa = 'h42645d8003;
    va_to_pa = new[8];
    va_to_pa = {>>byte_t{64'h42645d8003}};
    host_bfm_top.host_memory.initialize_data(va, va_to_pa);
    pfvf = new(0,0,0);

    // The AFUs for testing are in the port gasket.
    for (int p = 0; p < top_cfg_pkg::PG_NUM_RTABLE_ENTRIES; p = p + 1) begin
        pf = top_cfg_pkg::PG_PF_VF_RTABLE[p].pf;
        vf = top_cfg_pkg::PG_PF_VF_RTABLE[p].vf;
        vf_active = top_cfg_pkg::PG_PF_VF_RTABLE[p].vf_active;
        pfvf.set_pfvf(pf,vf,vf_active);
        pfvf_idx = pfvf.get_attr();

        //pfvf_idx = pfvf_type_from_pfvf(pf, vf, vf_active);
        //port_dev_id = 16'(flr_def_pkg::flr_attr[flr_def_pkg::flr_type_t'(pfvf_idx)]);
        port_dev_id = 16'(pfvf_idx);

        // Is ATS enabled on this port?
        if (PCIE_ATS_CAP_EN[pf] && (!vf_active || PCIE_VF_ATS_CAP_EN[pf])) begin
            $sformat(test_name, "test_pf%0d_vf%0d_vfa%b_ats_basic", pf, vf, vf_active);
            print_test_header(test_name, vf_active, pf, vf);

            @(posedge clk iff (rst_n === 1'b1));
            repeat (20) @(posedge clk);

            // Set the port being tested
            host_bfm_top.host_bfm.set_pfvf_setting(pfvf_idx);

            // Reset the port -- flr_type_t and pfvf_type_t are equivalent enums
            //host_flr_top.flr_manager.send_flr(flr_def_pkg::flr_type_t'(pfvf_idx));
            host_flr_top.flr_manager.send_flr(pfvf_idx);
            while (host_flr_top.flr_manager.num_all_outstanding_flrs() > 0) @(posedge clk);

            // Check the AFU ID
            host_bfm_top.host_bfm.read64(8 * 1, scratch);
            $display("AFU_L 0x%h", scratch);
            host_bfm_top.host_bfm.read64(8 * 2, scratch);
            $display("AFU_H 0x%h", scratch);

            ats_inval_itag = $urandom_range(0, 31);
            send_ats_inval(port_dev_id, ats_inval_itag);
            recv_ats_inval_cpl(port_dev_id, ats_inval_itag, 1);

            // Set the PASID
            host_bfm_top.host_bfm.write64(8 * 0, 64'(p + 1));

            // Translate an address
            host_bfm_top.host_bfm.write64(8 * 1, va);  // Virtual address to translate
            host_bfm_top.host_bfm.write64(8 * 2, 2);   // Length of an address (DWords)
            ctr_val = host_bfm_top.host_memory.get_number_of_reads(va, ctr_vec);
            host_bfm_top.host_bfm.write64(8 * 7, 1);   // Trigger ATS request
            // Wait for the ATS request to reach the BFM
            while (ctr_val == host_bfm_top.host_memory.get_number_of_reads(va, ctr_vec)) begin
                repeat (10) @(posedge clk);
            end
            // Wait for the ATS request to complete
            do begin
                repeat (10) @(posedge clk);
                // Number of reads
                host_bfm_top.host_bfm.read64(8 * 9, scratch);
            end while (!scratch);

            // Read the ATS completion payload
            host_bfm_top.host_bfm.read64(8 * 10, scratch);
            if (pa != 64'({<<byte {scratch}})) begin
                $display("ERROR: ATS unexpected translation: 0x%h", 64'({<<byte {scratch}}));
                incr_err_count();
            end

            // Now that the AFU has made a translation request, ATS invalidation
            // completions should come from the AFU and not the FIM's responder.
            ats_inval_itag = $urandom_range(0, 31);
            send_ats_inval(port_dev_id, ats_inval_itag);
            recv_ats_inval_cpl(port_dev_id, ats_inval_itag, 2);

            // Reset only one of the ports (p == 1). Leave the others alone. This
            // will be important in the final invalidation test loop below.
            if (p == 1) begin
                //host_flr_top.flr_manager.send_flr(flr_def_pkg::flr_type_t'(pfvf_idx));
                host_flr_top.flr_manager.send_flr(pfvf_idx);
                while (host_flr_top.flr_manager.num_all_outstanding_flrs() > 0) @(posedge clk);
            end
        end
    end

    // Second loop tests that FLR on a port is handled properly by the FIM's ATS
    // invalidation responder. The loop above reset port 1, so the FIM should
    // respond for it. All other ports are still active and should handle their
    // own responses.
    for (int p = 0; p < top_cfg_pkg::PG_NUM_RTABLE_ENTRIES; p = p + 1) begin
        pf = top_cfg_pkg::PG_PF_VF_RTABLE[p].pf;
        vf = top_cfg_pkg::PG_PF_VF_RTABLE[p].vf;
        vf_active = top_cfg_pkg::PG_PF_VF_RTABLE[p].vf_active;
        pfvf.set_pfvf(pf,vf,vf_active);
        pfvf_idx = pfvf.get_attr();

        //pfvf_idx = pfvf_type_from_pfvf(pf, vf, vf_active);
        //port_dev_id = 16'(flr_def_pkg::flr_attr[flr_def_pkg::flr_type_t'(pfvf_idx)]);
        port_dev_id = 16'(pfvf_idx);

        // Is ATS enabled on this port?
        if (PCIE_ATS_CAP_EN[pf] && (!vf_active || PCIE_VF_ATS_CAP_EN[pf])) begin
            host_bfm_top.host_bfm.set_pfvf_setting(pfvf_idx);

            ats_inval_itag = $urandom_range(0, 31);
            send_ats_inval(port_dev_id, ats_inval_itag);
            recv_ats_inval_cpl(port_dev_id, ats_inval_itag, (p == 1) ? 1 : 2);
        end
    end

    repeat (10) @(posedge clk);
endtask


endmodule
