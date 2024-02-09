// Copyright 2022 Intel Corporation
// SPDX-License-Identifier: MIT

//
// Simple sequential TLP read and/or write engine for bandwidth testing.
// No data checks are done. Most parameters are computed in software to
// keep the RTL simple, including the address pattern.
//
// For read CSRs, see the comments beginning with "AFU DFH" in the MMIO
// section. For write CSRs, see the section reading mmio_wr_valid.
//

`include "ofs_plat_if.vh"
`include "afu_json_info.vh"

module pcie_ats_query
  #(
    parameter INSTANCE_ID = 0,

    parameter pcie_ss_hdr_pkg::ReqHdr_pf_num_t PF_ID,
    parameter pcie_ss_hdr_pkg::ReqHdr_vf_num_t VF_ID,
    parameter logic VF_ACTIVE
    )  
   (
    input  logic clk,
    input  logic rst_n,

    pcie_ss_axis_if.sink   rx_mmio_port_if,
    pcie_ss_axis_if.source tx_a_port_if,

    // Read requests
    pcie_ss_axis_if.source tx_b_port_if,

    // Completions
    pcie_ss_axis_if.sink   rx_cpl_if,

    // Write commits
    pcie_ss_axis_if.sink   rx_wr_commit_if
    );

    localparam COUNTER_BITS = 40;
    typedef logic [COUNTER_BITS-1 : 0] t_counter;

    logic rd_req_arb_en;
    logic counter_rst_n;
    logic ats_query_active;
    logic page_req_active;

    // Count test cycles
    t_counter num_test_cycles;
    lib_counter_multicycle
      #(
        .NUM_BITS(COUNTER_BITS)
        )
      cycle_cnt
       (
        .clk,
        .reset_n(counter_rst_n),
        .incr_by(t_counter'((ats_query_active || page_req_active) ? 1'b1 : 1'b0)),
        .value(num_test_cycles)
        );


    // ====================================================================
    //
    //  Count host memory read completions
    //
    // ====================================================================

    pcie_ss_hdr_pkg::PCIe_OrdCplHdr_t rx_cpl_hdr;
    assign rx_cpl_hdr = pcie_ss_hdr_pkg::PCIe_OrdCplHdr_t'(rx_cpl_if.tdata);

    logic rx_cpl_sop;
    logic rx_is_fc_packet_reg;
    // All the PU-encoded reads this simple AFU generates return a single beat,
    // so any PU completion is automatically final.
    wire rx_is_fc_packet =
        rx_cpl_sop ? 
            (pcie_ss_hdr_pkg::func_is_completion(rx_cpl_hdr.fmt_type) &&
             (pcie_ss_hdr_pkg::func_hdr_is_pu_mode(rx_cpl_if.tuser_vendor) || rx_cpl_hdr.FC)) :
            rx_is_fc_packet_reg;

    // Count of read requests
    t_counter num_rd_reqs_sent;

    // Count completions
    t_counter num_rd_cpls_rcvd;
    lib_counter_multicycle
      #(
        .NUM_BITS(COUNTER_BITS)
        )
      cpl_cnt
       (
        .clk,
        .reset_n(counter_rst_n),
        .incr_by(t_counter'(rx_cpl_if.tvalid & rx_cpl_if.tready &
                            rx_cpl_if.tlast & rx_is_fc_packet)),
        .value(num_rd_cpls_rcvd)
        );

    always_ff @(posedge clk)
    begin
        if (rx_cpl_if.tvalid && rx_cpl_if.tready) begin
            rx_cpl_sop <= rx_cpl_if.tlast;

            if (rx_cpl_sop) begin
                rx_is_fc_packet_reg <=
                    pcie_ss_hdr_pkg::func_hdr_is_dm_mode(rx_cpl_if.tuser_vendor) &&
                    pcie_ss_hdr_pkg::func_is_completion(rx_cpl_hdr.fmt_type) &&
                    rx_cpl_hdr.FC;
            end
        end

        if (!rst_n) begin
            rx_cpl_sop <= 1'b1;
        end
    end

    // Store the first 64 bits of a completion. This is enough to see the response
    // from a translation request.
    logic [63:0] last_rd_cpl_data;

    always_ff @(posedge clk)
    begin
        if (rx_cpl_if.tvalid && rx_cpl_if.tready && rx_cpl_sop)
            last_rd_cpl_data <= rx_cpl_if.tdata[256 +: 64];

        if (!counter_rst_n)
            last_rd_cpl_data <= 'hdeadbeef;
    end

    assign rx_cpl_if.tready = 1'b1;


    // ====================================================================
    //
    //  Respond to ATS invalidation requests.
    //
    // ====================================================================

    pcie_ss_axis_if rx_mmio_if(clk, rst_n);
    pcie_ss_axis_if tx_a_if(clk, rst_n);
    pcie_ss_axis_if tx_b_if(clk, rst_n);

    pcie_ats_inval_cpl ats_inval
       (
        .o_tx_if(tx_a_port_if),
        .o_txreq_if(tx_b_port_if),
        .i_rxreq_if(rx_mmio_port_if),
        .i_tx_if(tx_a_if),
        .i_txreq_if(tx_b_if),
        .o_rxreq_if(rx_mmio_if)
        );


    // ====================================================================
    //
    //  Watch for MMIO requests on the RX stream.
    //
    // ====================================================================

    pcie_ss_hdr_pkg::PCIe_PUReqHdr_t rx_mmio_pu_hdr;
    assign rx_mmio_pu_hdr = pcie_ss_hdr_pkg::PCIe_PUReqHdr_t'(rx_mmio_if.tdata);

    logic rx_mmio_if_sop;
    always_ff @(posedge clk)
    begin
        if (rx_mmio_if.tvalid && rx_mmio_if.tready)
        begin
            rx_mmio_if_sop <= rx_mmio_if.tlast;
        end

        if (!rst_n)
        begin
            rx_mmio_if_sop <= 1'b1;
        end
    end

    logic mmio_rd_notFull;
    pcie_ss_hdr_pkg::PCIe_PUReqHdr_t mmio_rd_hdr;
    logic [4:0] mmio_rd_low_addr;
    logic mmio_rd_hdr_valid;
    logic mmio_rd_deq_en;

    //
    // Queue MMIO read requests from the TLP stream
    //
    ofs_plat_prim_fifo2
      #(
        .N_DATA_BITS($bits(pcie_ss_hdr_pkg::PCIe_PUReqHdr_t))
        )
      mmio_rd_fifo
       (
        .clk,
        .reset_n(rst_n),

        .enq_en(rx_mmio_if.tvalid && rx_mmio_if_sop &&
                pcie_ss_hdr_pkg::func_hdr_is_pu_mode(rx_mmio_if.tuser_vendor) &&
                pcie_ss_hdr_pkg::func_is_mrd_req(rx_mmio_pu_hdr.fmt_type)),
        .enq_data(rx_mmio_pu_hdr),
        .notFull(mmio_rd_notFull),

        .first(mmio_rd_hdr),
        .deq_en(mmio_rd_deq_en),
        .notEmpty(mmio_rd_hdr_valid)
        );

    assign mmio_rd_low_addr =
        pcie_ss_hdr_pkg::func_is_addr64(mmio_rd_hdr.fmt_type) ?
                             mmio_rd_hdr.host_addr_l[4:0] : mmio_rd_hdr.host_addr_h[6:2];


    logic mmio_wr_notFull;
    logic [4:0] mmio_wr_low_addr;
    logic [63:0] mmio_wr_data;
    logic mmio_wr_deq_en;
    logic mmio_wr_valid;

    // Queue MMIO write requests
    ofs_plat_prim_fifo_bram
      #(
        .N_ENTRIES(512),
        .N_DATA_BITS(5 + 64)
        )
      mmio_wr_fifo
       (
        .clk,
        .reset_n(rst_n),

        .enq_en(rx_mmio_if.tvalid && rx_mmio_if_sop &&
                pcie_ss_hdr_pkg::func_hdr_is_pu_mode(rx_mmio_if.tuser_vendor) &&
                pcie_ss_hdr_pkg::func_is_mwr_req(rx_mmio_pu_hdr.fmt_type)),
        .enq_data({ (pcie_ss_hdr_pkg::func_is_addr64(rx_mmio_pu_hdr.fmt_type) ?
                       rx_mmio_pu_hdr.host_addr_l[4:0] : rx_mmio_pu_hdr.host_addr_h[6:2]),
                    rx_mmio_if.tdata[$bits(pcie_ss_hdr_pkg::PCIe_PUReqHdr_t) +: 64] }),
        .notFull(mmio_wr_notFull),
        .almostFull(),

        .first({ mmio_wr_low_addr, mmio_wr_data }),
        .deq_en(mmio_wr_deq_en),
        .notEmpty(mmio_wr_valid)
        );

    assign rx_mmio_if.tready = mmio_rd_notFull && mmio_wr_notFull;


    // ====================================================================
    //
    //  Respond to MMIO read requests with completions.
    //
    // ====================================================================

    localparam MMIO_CPL_HDR_BYTES = $bits(pcie_ss_hdr_pkg::PCIe_PUCplHdr_t) / 8;
    pcie_ss_hdr_pkg::PCIe_PUCplHdr_t mmio_cpl_hdr;

    always_comb
    begin
        // Build the header -- always the same for any address
        mmio_cpl_hdr = '0;
        mmio_cpl_hdr.fmt_type = pcie_ss_hdr_pkg::ReqHdr_FmtType_e'(pcie_ss_hdr_pkg::PCIE_FMTTYPE_CPLD);
        mmio_cpl_hdr.length = mmio_rd_hdr.length;
        mmio_cpl_hdr.req_id = mmio_rd_hdr.req_id;
        mmio_cpl_hdr.tag_h = mmio_rd_hdr.tag_h;
        mmio_cpl_hdr.tag_m = mmio_rd_hdr.tag_m;
        mmio_cpl_hdr.tag_l = mmio_rd_hdr.tag_l;
        mmio_cpl_hdr.TC = mmio_rd_hdr.TC;
        mmio_cpl_hdr.byte_count = mmio_rd_hdr.length << 2;
        mmio_cpl_hdr.low_addr[6:2] = mmio_rd_low_addr;

        mmio_cpl_hdr.comp_id = { VF_ID, VF_ACTIVE, PF_ID };
        mmio_cpl_hdr.pf_num = PF_ID;
        mmio_cpl_hdr.vf_num = VF_ID;
        mmio_cpl_hdr.vf_active = VF_ACTIVE;
    end

    logic [63:0] mmio_cpl_data;
    logic [127:0] afu_id = `AFU_ACCEL_UUID;

    // Completion data. There is minimal address decoding here to keep
    // it simple. Location 0 needs a device feature header and an AFU
    // ID is set.
    always_comb
    begin
        case (mmio_rd_low_addr[4:1])
            // AFU DFH
            4'h0:
                begin
                    mmio_cpl_data[63:0] = '0;
                    // Feature type is AFU
                    mmio_cpl_data[63:60] = 4'h1;
                    // End of list
                    mmio_cpl_data[40] = 1'b1;
                end

            // AFU_ID_L
            4'h1: mmio_cpl_data[63:0] = afu_id[63:0];

            // AFU_ID_H
            4'h2: mmio_cpl_data[63:0] = afu_id[127:64];

            // System information
            4'h7: mmio_cpl_data[63:0] = { '0,
                                          16'(`OFS_PLAT_PARAM_CLOCKS_PCLK_FREQ),
                                          16'(ofs_pcie_ss_cfg_pkg::TDATA_WIDTH/8) };

            // Number of read requests sent
            4'h8: mmio_cpl_data[63:0] = { '0, num_rd_reqs_sent };
            // Number of read completions received
            4'h9: mmio_cpl_data[63:0] = { '0, num_rd_cpls_rcvd };
            // Last read completion's low 64 bits of data (including translation responses)
            4'ha: mmio_cpl_data[63:0] = { last_rd_cpl_data };

            // Number of clock cycles during active test
            4'hc: mmio_cpl_data[63:0] = { '0, num_test_cycles };

            default: mmio_cpl_data[63:0] = '0;
        endcase

        // Was the request short, asking for the high 32 bits of the 64 bit register?
        if (mmio_rd_low_addr[0])
        begin
            mmio_cpl_data[31:0] = mmio_cpl_data[63:32];
        end
    end


    // ====================================================================
    //
    //  Consume MMIO writes, which drive host memory requests
    //
    // ====================================================================

    //
    // MMIO write locations (64 bit registers):
    //   0 - PASID
    //   1 - Host memory read base address
    //   2 - Read length (DWORDs)
    //   7 - Commands
    //

    logic counter_rst_n_in;

    logic [19:0] pasid;
    logic [63:0] rd_req_base_addr;
    logic [9:0] rd_req_length;
    logic gen_rd_req, gen_rd_req_in;
    logic gen_ats_req;

    logic gen_page_req, gen_page_req_in;
    logic is_page_rsp;

    always_ff @(posedge clk)
    begin
        if (rd_req_arb_en)
            gen_rd_req_in <= 1'b0;

        gen_page_req_in <= 1'b0;
        counter_rst_n_in <= 1'b1;

        if (mmio_wr_valid)
        begin
            if (mmio_wr_low_addr[3:1] == 3'b000)
            begin
                pasid <= mmio_wr_data[19:0];
            end
            if (mmio_wr_low_addr[3:1] == 3'b001)
                rd_req_base_addr <= mmio_wr_data;

            if (mmio_wr_low_addr[3:1] == 3'b010)
                rd_req_length <= 10'(mmio_wr_data);

            // Control register
            if (mmio_wr_low_addr[3:1] == 3'b111)
            begin
                counter_rst_n_in <= 1'b0;

                // Bit 0 - enable read requests
                gen_rd_req_in <= mmio_wr_data[0] || mmio_wr_data[1];
                gen_ats_req <= mmio_wr_data[0];
                // Bit 2 - enable page request
                gen_page_req_in <= mmio_wr_data[2];
            end
        end

        if (gen_rd_req)
            ats_query_active <= 1'b1;
        if (rx_cpl_if.tvalid && rx_cpl_if.tready)
            ats_query_active <= 1'b0;

        if (gen_page_req)
            page_req_active <= 1'b1;
        if (is_page_rsp)
            page_req_active <= 1'b0;

        counter_rst_n <= counter_rst_n_in;

        if (!rst_n)
        begin
            gen_rd_req_in <= 1'b0;
            gen_page_req_in <= 1'b0;
            counter_rst_n_in <= 1'b0;
            ats_query_active <= 1'b0;
            page_req_active <= 1'b0;
            rd_req_length <= 10'd2;
        end
    end

    assign mmio_wr_deq_en = mmio_wr_valid;


    // ====================================================================
    //
    //  Page requests
    //
    // ====================================================================

    localparam MSG_HDR_BYTES = $bits(pcie_ss_hdr_pkg::PCIe_PUMsgHdr_t) / 8;
    pcie_ss_hdr_pkg::PCIe_PUMsgHdr_t page_req_hdr;
    pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t page_requestor_id;
    logic page_req_arb_en;

    assign page_requestor_id.pf_num = PF_ID;
    assign page_requestor_id.vf_num = VF_ID;
    assign page_requestor_id.vf_active = VF_ACTIVE;

    always_comb
    begin
        page_req_hdr = '0;
        page_req_hdr.fmt_type =
            pcie_ss_hdr_pkg::ReqHdr_FmtType_e'({ pcie_ss_hdr_pkg::PCIE_FMTTYPE_MSGWOD, 3'b000 });
        page_req_hdr.pf_num = PF_ID;
        page_req_hdr.vf_num = VF_ID;
        page_req_hdr.vf_active = VF_ACTIVE;
        { page_req_hdr.tag_h, page_req_hdr.tag_m, page_req_hdr.msg0 } = 1;
        page_req_hdr.req_id = page_requestor_id;
        page_req_hdr.msg_code = pcie_ss_hdr_pkg::PCIE_MSGCODE_PAGE_REQ;

        page_req_hdr.msg1 = rd_req_base_addr[63:32];
        page_req_hdr.msg2[31:12] = rd_req_base_addr[31:12];
        // Page request group index
        page_req_hdr.msg2[11:3] = 2;
        // Last in group
        page_req_hdr.msg2[2] = 1'b1;
        // Write enable
        page_req_hdr.msg2[1] = 1'b1;
        // Read enable
        page_req_hdr.msg2[0] = 1'b1;

        page_req_hdr.pref_present = 1'b1;
        page_req_hdr.pref_type = 5'b10001;
        page_req_hdr.pref = { '0, pasid };
    end

    always_ff @(posedge clk)
    begin
        if (!page_req_active)
            gen_page_req <= gen_page_req_in;

        if (gen_page_req && page_req_arb_en) begin
            gen_page_req <= 1'b0;
        end

        if (!rst_n) begin
            gen_page_req <= 1'b0;
        end
    end

    pcie_ss_hdr_pkg::PCIe_PUMsgHdr_t page_rsp_hdr;
    assign page_rsp_hdr = pcie_ss_hdr_pkg::PCIe_PUMsgHdr_t'(rx_mmio_if.tdata);

    always_ff @(posedge clk)
    begin
        is_page_rsp <= rx_mmio_if_sop && rx_mmio_if.tvalid && rx_mmio_if.tready &&
                       (page_rsp_hdr.fmt_type[7:3] == pcie_ss_hdr_pkg::PCIE_FMTTYPE_MSGWOD) &&
                       (page_rsp_hdr.msg_code == pcie_ss_hdr_pkg::PCIE_MSGCODE_PAGE_RSP);
    end


    // ====================================================================
    //
    //  Read requests
    //
    // ====================================================================

    pcie_ss_hdr_pkg::PCIe_PUReqHdr_t rd_req_hdr;
    pcie_ss_hdr_pkg::ReqHdr_pf_vf_info_t rd_requestor_id;
    logic [$clog2(ofs_pcie_ss_cfg_pkg::PCIE_EP_MAX_TAGS)-1 : 0] rd_req_tag;

    lib_counter_multicycle
      #(
        .NUM_BITS(COUNTER_BITS)
        )
      rd_req_cnt
       (
        .clk,
        .reset_n(counter_rst_n),
        .incr_by(t_counter'(gen_rd_req & rd_req_arb_en)),
        .value(num_rd_reqs_sent)
        );

    assign rd_requestor_id.pf_num = PF_ID;
    assign rd_requestor_id.vf_num = VF_ID;
    assign rd_requestor_id.vf_active = VF_ACTIVE;

    always_comb
    begin
        rd_req_hdr = '0;
        rd_req_hdr.pf_num = PF_ID;
        rd_req_hdr.vf_num = VF_ID;
        rd_req_hdr.vf_active = VF_ACTIVE;
        rd_req_hdr.length = rd_req_length;
        { rd_req_hdr.tag_h, rd_req_hdr.tag_m, rd_req_hdr.tag_l } = rd_req_tag;

        if (|rd_req_base_addr[63:32])
        begin
            rd_req_hdr.fmt_type = pcie_ss_hdr_pkg::DM_RD;
            {rd_req_hdr.host_addr_h, rd_req_hdr.host_addr_l} = {rd_req_base_addr[63:12], 10'h0};
        end
        else
        begin
            rd_req_hdr.fmt_type = pcie_ss_hdr_pkg::M_RD;
            rd_req_hdr.host_addr_h = {rd_req_base_addr[31:12], 12'h0};
        end

        rd_req_hdr.req_id = rd_requestor_id;
        rd_req_hdr.last_dw_be = 4'hf;
        rd_req_hdr.first_dw_be = 4'hf;

        rd_req_hdr.pref_present = gen_ats_req;
        rd_req_hdr.pref_type = 5'b10001;
        rd_req_hdr.pref = { '0, pasid };

        rd_req_hdr.attr.AT = (gen_ats_req ? 2'b01 : 2'b10);
    end

    always_ff @(posedge clk)
    begin
        if (!ats_query_active)
            gen_rd_req <= gen_rd_req_in;

        if (gen_rd_req && rd_req_arb_en) begin
            gen_rd_req <= 1'b0;
            rd_req_tag <= rd_req_tag + 1;
        end

        if (!rst_n) begin
            gen_rd_req <= 1'b0;
            rd_req_tag <= '0;
        end
    end


    // ====================================================================
    //
    //  TX arbitration: completions and host memory requests
    //
    // ====================================================================

    // TX-A
    always_comb
    begin
        mmio_rd_deq_en = 1'b0;
        page_req_arb_en = 1'b0;

        if (mmio_rd_hdr_valid)
        begin
            //
            // CSR read response
            //

            tx_a_if.tvalid = 1'b1;
            tx_a_if.tdata = { '0, mmio_cpl_data, mmio_cpl_hdr };
            tx_a_if.tlast = 1'b1;
            tx_a_if.tuser_vendor = '0;
            // Keep matches the data: either 8 or 4 bytes of data and the header
            tx_a_if.tkeep = { '0, {4{(mmio_cpl_hdr.length > 1)}}, {4{1'b1}}, {MMIO_CPL_HDR_BYTES{1'b1}} };

            mmio_rd_deq_en = tx_a_if.tvalid && tx_a_if.tready;
        end
        else
        begin
            //
            // Page map request
            //

            tx_a_if.tvalid = gen_page_req;
            tx_a_if.tdata = { '0, page_req_hdr };
            tx_a_if.tlast = 1'b1;
            tx_a_if.tuser_vendor = '0;
            tx_a_if.tkeep = { '0, {MSG_HDR_BYTES{1'b1}} };

            page_req_arb_en = tx_a_if.tvalid && tx_a_if.tready;
        end
    end

    // TX-B - only DMA read requests
    always_comb
    begin
        tx_b_if.tvalid = gen_rd_req;
        tx_b_if.tdata = { '0, rd_req_hdr };
        tx_b_if.tlast = 1'b1;
        tx_b_if.tuser_vendor = 0;	// PU encoding
        tx_b_if.tkeep = { '0, {MMIO_CPL_HDR_BYTES{1'b1}} };

        rd_req_arb_en = tx_b_if.tready;
    end

    assign rx_wr_commit_if.tready = 1'b1;


    // ====================================================================
    //
    //  Logging
    //
    // ====================================================================

    // synthesis translate_off
    // Log TLP AXI-S traffic
    int log_fd;

    initial
    begin : log
        log_fd = $fopen($sformatf("log_pcie_ats_query_port%0d.tsv", INSTANCE_ID), "w");

        // Write module hierarchy to the top of the log
        $fwrite(log_fd, "pcie_ats_query.sv: %m\n\n");
    end

`define LOG_PCIE_STREAM(pcie_if, fmt) \
    logic pcie_if``_log_sop; \
    always_ff @(posedge clk) begin \
        if (rst_n && pcie_if.tvalid && pcie_if.tready) begin \
            $fwrite(log_fd, fmt, \
                    pcie_ss_pkg::func_pcie_ss_flit_to_string( \
                        pcie_if``_log_sop, pcie_if.tlast, \
                        pcie_ss_hdr_pkg::func_hdr_is_pu_mode(pcie_if.tuser_vendor), \
                        pcie_if.tdata, pcie_if.tkeep)); \
            $fflush(log_fd); \
        end \
        \
        if (pcie_if.tvalid && pcie_if.tready) \
            pcie_if``_log_sop <= pcie_if.tlast; \
        \
        if (!rst_n) \
            pcie_if``_log_sop <= 1'b1; \
    end

    `LOG_PCIE_STREAM(tx_a_port_if,    "tx_a:      %s\n")
    `LOG_PCIE_STREAM(tx_b_port_if,    "tx_b:      %s\n")

    `LOG_PCIE_STREAM(rx_mmio_port_if, "rx_mmio:   %s\n")
    `LOG_PCIE_STREAM(rx_cpl_if,       "rx_cpl:    %s\n")
    `LOG_PCIE_STREAM(rx_wr_commit_if, "rx_wr_cmt: %s\n")

    // synthesis translate_on

endmodule
