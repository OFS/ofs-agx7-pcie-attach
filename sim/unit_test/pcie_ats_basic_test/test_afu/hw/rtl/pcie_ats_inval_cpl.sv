// Copyright 2020 Intel Corporation
// SPDX-License-Identifier: MIT

//
// Respond to PCIe address translation service invalidation requests. This
// module can be used on functions that have ATS enabled but don't cache
// translations.
//

module pcie_ats_inval_cpl
  #(
    parameter TDATA_WIDTH = ofs_pcie_ss_cfg_pkg::TDATA_WIDTH,
    parameter TUSER_WIDTH = ofs_pcie_ss_cfg_pkg::TUSER_WIDTH
    )
   (
    // FIM to host
    pcie_ss_axis_if.source o_tx_if,
    pcie_ss_axis_if.source o_txreq_if,

    // Host to FIM commands
    pcie_ss_axis_if.sink   i_rxreq_if,

    // AFU to host. ATS completions will be merged into this.
    pcie_ss_axis_if.sink   i_tx_if,
    pcie_ss_axis_if.sink   i_txreq_if,

    // Host to AFU commands. ATS requests will be filtered
    // out of this.
    pcie_ss_axis_if.source o_rxreq_if
    );

    wire clk = o_tx_if.clk;
    wire rst_n = o_tx_if.rst_n;

    // Inputs to the TX MUX that merges the main TX stream and ATS invalidation
    // completions.
    pcie_ss_axis_if#(.DATA_W(TDATA_WIDTH), .USER_W(TUSER_WIDTH)) tx_mux_in[2](.clk, .rst_n);
    pcie_ss_axis_if#(.DATA_W(TDATA_WIDTH), .USER_W(TUSER_WIDTH)) txreq_mux_in[2](.clk, .rst_n);

    // Storage for a pending ATS invalidation
    logic ats_inval_req_valid;
    logic ats_inval_to_tx, ats_inval_to_txreq;
    pcie_ss_hdr_pkg::PCIe_PUMsgHdr_t ats_inval_req;

    pcie_ss_hdr_pkg::PCIe_PUMsgHdr_t rxreq_msg_hdr;
    assign rxreq_msg_hdr = pcie_ss_hdr_pkg::PCIe_PUMsgHdr_t'(i_rxreq_if.tdata);

    // Detect ATS invalidation request messages
    logic rxreq_is_sop;
    wire rxreq_is_ats_inval =
         rxreq_is_sop &&
         pcie_ss_hdr_pkg::func_hdr_is_pu_mode(i_rxreq_if.tuser_vendor) &&
         pcie_ss_hdr_pkg::func_is_msg(rxreq_msg_hdr.fmt_type) &&
         (rxreq_msg_hdr.msg_code == pcie_ss_hdr_pkg::PCIE_MSGCODE_ATS_INVAL_REQ);

    always_ff @(posedge clk) begin
        if (i_rxreq_if.tvalid && i_rxreq_if.tready)
            rxreq_is_sop <= i_rxreq_if.tlast;

        if (!rst_n)
            rxreq_is_sop <= 1'b1;
    end

    // Route requests either to the AFU or to ATS invalidation commit
    assign i_rxreq_if.tready = rxreq_is_ats_inval ? !ats_inval_req_valid : o_rxreq_if.tready;

    // Normal requests (not ATS)
    assign o_rxreq_if.tvalid = i_rxreq_if.tvalid && !rxreq_is_ats_inval;
    always_comb begin
        o_rxreq_if.tlast = i_rxreq_if.tlast;
        o_rxreq_if.tdata = i_rxreq_if.tdata;
        o_rxreq_if.tuser_vendor = i_rxreq_if.tuser_vendor;
        o_rxreq_if.tkeep = i_rxreq_if.tkeep;
    end

    (* preserve_for_debug *) logic dbg_rxreq_is_ats_inval;
    (* preserve_for_debug *) logic [511:0] dbg_rxreq_tdata;
    (* preserve_for_debug *) logic [63:0] dbg_rxreq_tkeep;
    always_ff @(posedge clk) begin
        dbg_rxreq_is_ats_inval <= i_rxreq_if.tvalid && i_rxreq_if.tready && rxreq_is_ats_inval;
        dbg_rxreq_tdata <= i_rxreq_if.tdata;
        dbg_rxreq_tkeep <= i_rxreq_if.tkeep;
    end

    // Invalidation requests
    always_ff @(posedge clk) begin
        if (ats_inval_to_tx && tx_mux_in[1].tready) begin
            ats_inval_to_tx <= 1'b0;
            ats_inval_to_txreq <= 1'b1;
        end
        if (ats_inval_to_txreq && txreq_mux_in[1].tready) begin
            ats_inval_req_valid <= 1'b0;
            ats_inval_to_txreq <= 1'b0;
        end

        if (i_rxreq_if.tvalid && rxreq_is_ats_inval && !ats_inval_req_valid) begin
            ats_inval_req_valid <= 1'b1;
            ats_inval_to_tx <= 1'b1;
            ats_inval_req <= rxreq_msg_hdr;
        end

        if (!rst_n) begin
            ats_inval_req_valid <= 1'b0;
            ats_inval_to_tx <= 1'b0;
            ats_inval_to_txreq <= 1'b0;
        end
    end

    // ATS completions are just a header
    pcie_ss_hdr_pkg::PCIe_PUMsgHdr_t ats_inval_cpl;
    always_comb begin
        ats_inval_cpl = '0;

        // No data
        ats_inval_cpl.fmt_type = ats_inval_req.fmt_type;
        ats_inval_cpl.fmt_type[6] = 1'b0;

        { ats_inval_cpl.attr_h, ats_inval_cpl.attr_l } = { ats_inval_req.attr_h, ats_inval_req.attr_l };
        ats_inval_cpl.EP = ats_inval_req.EP;
        ats_inval_cpl.TD = ats_inval_req.TD;
        ats_inval_cpl.TC = ats_inval_req.TC;

        ats_inval_cpl.msg_code = pcie_ss_hdr_pkg::PCIE_MSGCODE_ATS_INVAL_CPL;
        // Completion req_id from the target of the invalidation request
        ats_inval_cpl.req_id = ats_inval_req.msg1[31:16];
        // Target Device ID -- source of the request
        ats_inval_cpl.msg1[31:16] = ats_inval_req.req_id;
        // Completion count -- two messages, one on TX and the other on TXREQ. See below.
        ats_inval_cpl.msg1[2:0] = 3'd2;

        // ITag vector
        ats_inval_cpl.msg2[ats_inval_req.msg0[4:0]] = 1'b1;

        ats_inval_cpl.pf_num = ats_inval_req.pf_num;
        ats_inval_cpl.vf_num = ats_inval_req.vf_num;
        ats_inval_cpl.vf_active = ats_inval_req.vf_active;
    end


    //
    // AFU TX stream - inject ATS invalidation completion
    //
    assign tx_mux_in[0].tvalid = i_tx_if.tvalid;
    assign i_tx_if.tready = tx_mux_in[0].tready;
    always_comb begin
        tx_mux_in[0].tlast = i_tx_if.tlast;
        tx_mux_in[0].tdata = i_tx_if.tdata;
        tx_mux_in[0].tuser_vendor = i_tx_if.tuser_vendor;
        tx_mux_in[0].tkeep = i_tx_if.tkeep;
    end

    assign tx_mux_in[1].tvalid = ats_inval_req_valid && ats_inval_to_tx;
    always_comb begin
        tx_mux_in[1].tlast = 1'b1;
        tx_mux_in[1].tdata = { '0, ats_inval_cpl };
        tx_mux_in[1].tuser_vendor = '0;
        tx_mux_in[1].tkeep = { '0, {32{1'b1}} };
    end

    lib_axis_mux
      #(
        .NUM_CH(2)
        )
      tx_mux
       (
        .clk,
        .rst_n,
        .sink(tx_mux_in),
        .source(o_tx_if)
        );

    //
    // AFU TXREQ stream - inject ATS invalidation completion. Invalidation is sent
    //                    down TXREQ also because the FIM has a special case
    //                    for these messages on the same stream as reads, making
    //                    it easy to send invalidation completion on both TX and
    //                    TXREQ to flush them both. In that case, the count is 2.
    //
    assign txreq_mux_in[0].tvalid = i_txreq_if.tvalid;
    assign i_txreq_if.tready = txreq_mux_in[0].tready;
    always_comb begin
        txreq_mux_in[0].tlast = i_txreq_if.tlast;
        txreq_mux_in[0].tdata = i_txreq_if.tdata;
        txreq_mux_in[0].tuser_vendor = i_txreq_if.tuser_vendor;
        txreq_mux_in[0].tkeep = i_txreq_if.tkeep;
    end

    assign txreq_mux_in[1].tvalid = ats_inval_req_valid && ats_inval_to_txreq;
    always_comb begin
        txreq_mux_in[1].tlast = 1'b1;
        txreq_mux_in[1].tdata = { '0, ats_inval_cpl };
        txreq_mux_in[1].tuser_vendor = '0;
        txreq_mux_in[1].tkeep = { '0, {32{1'b1}} };
    end

    lib_axis_mux
      #(
        .NUM_CH(2)
        )
      txreq_mux
       (
        .clk,
        .rst_n,
        .sink(txreq_mux_in),
        .source(o_txreq_if)
        );

endmodule // pcie_ats_inval_cpl
