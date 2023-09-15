// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//

module mm_ctrl_xcvr #(
    parameter NUM_LN        = 4,    // Number of transceiver serial data lanes
    parameter CMD_W         = 16,   // User command width
    parameter USER_ADDR_W   = 16,   // User address width
    parameter AVMM_ADDR_W   = 13,   // AVMM address width
    parameter DATA_W        = 32,   // Data width
    parameter ADDR_MIN      = 0,    // Minimum allowed address
    parameter ADDR_MAX      = 1024, // Maximum allowed address
    parameter SIM           = 0  
) (
    // Clocks and Reset
    input  logic                            i_usr_clk,              // User interface clock (250 MHz)
    input  logic                            i_avmm_clk,             // AVMM interface clock (100 MHz)
    input  logic                            i_avmm_rst,             // AVMM interface reset (100 MHz)
    // User Interface
    input  logic [CMD_W-1:0]                i_usr_cmd,              // User command
    input  logic [USER_ADDR_W-1:0]          i_usr_addr,             // User address
    input  logic [DATA_W-1:0]               i_usr_writedata,        // User write data
    output logic [DATA_W-1:0]               o_usr_readdata,         // User read data
    output logic                            o_usr_ack,              // User acknowledgment
    // Avalon-MM Interface
    output logic [AVMM_ADDR_W-1:0]          o_avmm_addr,            // AVMM address
    output logic                            o_avmm_read,            // AVMM read request
    output logic                            o_avmm_write,           // AVMM write request
    output logic [DATA_W-1:0]               o_avmm_writedata,       // AVMM write data
    input  logic [DATA_W-1:0]               i_avmm_readdata,        // AVMM read data
    input  logic                            i_avmm_readdata_valid,  // AVMM read data valid
    input  logic                            i_avmm_waitrequest      // AVMM wait request
);

// User commands
localparam CMD_NOOP     = 2'h0;
localparam CMD_READ     = 2'h1;
localparam CMD_WRITE    = 2'h2;

// Local signals
logic usr_rst_sync;
logic usr_ack, usr_ack_sync;
logic usr_read, usr_read_sync, usr_write, usr_write_sync;
logic [DATA_W-1:0] avmm_readdata, avmm_readdata_sync;
logic avmm_read, avmm_write;
logic avmm_finished, avmm_finished_sync;
logic avmm_waitrequest_d;
// Assign outputs
assign o_usr_ack        = usr_ack;
assign o_usr_readdata   = avmm_readdata_sync;
assign o_avmm_read      = avmm_read;
assign o_avmm_write     = avmm_write;

generate
    if (SIM == 1) // Simulation
    begin
        always_ff @(posedge i_avmm_clk)
        begin
            o_avmm_writedata    <= i_usr_writedata;
            o_avmm_addr         <= i_usr_addr[AVMM_ADDR_W-1:0];
            usr_read_sync       <= usr_read;
            usr_write_sync      <= usr_write;
            usr_ack_sync        <= usr_ack;
        end
        always_ff @(posedge i_usr_clk)
        begin
            avmm_readdata_sync  <= avmm_readdata;
            usr_rst_sync        <= i_avmm_rst;
            avmm_finished_sync  <= avmm_finished;
        end
    end
    else // Hardware
    begin
        // Synchronize writedata to 100 MHz
        fim_resync #(
            .SYNC_CHAIN_LENGTH  (2),
            .WIDTH              (DATA_W),
            .INIT_VALUE         (0),
            .NO_CUT             (1)
           ) inst_sync_writedata (
            .clk                (i_avmm_clk),
            .reset              (1'b0),
            .d                  (i_usr_writedata),
            .q                  (o_avmm_writedata)
        );
        // Synchronize address to 100 MHz
        fim_resync #(
            .SYNC_CHAIN_LENGTH  (2),
            .WIDTH              (AVMM_ADDR_W),
            .INIT_VALUE         (0),
            .NO_CUT             (1)
           ) inst_sync_addr (
            .clk                (i_avmm_clk),
            .reset              (1'b0),
            .d                  (i_usr_addr[AVMM_ADDR_W-1:0]),
            .q                  (o_avmm_addr)
        );
        // Synchronize read and write to 100 MHz
        fim_resync #(
            .SYNC_CHAIN_LENGTH  (2),
            .WIDTH              (3),
            .INIT_VALUE         (0),
            .NO_CUT             (1)
           ) inst_sync_rdwr_usrack (
            .clk                (i_avmm_clk),
            .reset              (1'b0),
            .d                  ({usr_read, usr_write, usr_ack}),
            .q                  ({usr_read_sync, usr_write_sync, usr_ack_sync})
        );
        // Synchronize readdata to 250 MHz
        fim_resync #(
            .SYNC_CHAIN_LENGTH  (2),
            .WIDTH              (DATA_W),
            .INIT_VALUE         (0),
            .NO_CUT             (1)
           ) inst_sync_readdata (
            .clk                (i_usr_clk),
            .reset              (1'b0),
            .d                  (avmm_readdata),
            .q                  (avmm_readdata_sync)
        );
        // Synchronize reset to 250 MHz
        fim_resync #(
            .SYNC_CHAIN_LENGTH  (2),
            .WIDTH              (2),
            .INIT_VALUE         (0),
            .NO_CUT             (1)
           ) inst_sync_rst_finish (
            .clk                (i_usr_clk),
            .reset              (1'b0),
            .d                  ({i_avmm_rst, avmm_finished}),
            .q                  ({usr_rst_sync, avmm_finished_sync})
        );
    end
endgenerate

always_ff @(posedge i_avmm_clk)
begin 
   avmm_waitrequest_d <= i_avmm_waitrequest;
end
      

/*
- Two state machines in their own clock domains with handshaking between the two
- User interface FSM runs at 250 MHz FME CSRs clock
- Avalon-MM interface FSM runs at 100 MHz reconfiguration interface clock
*/

// State definitions for user state machine
typedef enum logic [4:0] {
    USER_FSM_INIT,
    USER_FSM_RESET,
    USER_FSM_IDLE,
    USER_FSM_WAIT,
    USER_FSM_ACK
} t_user_state;

// State definitions for avmm state machine
typedef enum logic [5:0] {
    AVMM_FSM_INIT,
    AVMM_FSM_RESET,
    AVMM_FSM_IDLE,
    AVMM_FSM_READ,
    AVMM_FSM_WRITE,
    AVMM_FSM_ACK
} t_avmm_state;

(* syn_encoding = "one-hot" *) t_user_state user_state;
(* syn_encoding = "one-hot" *) t_avmm_state avmm_state;

// User interface state machine
always_ff @ (posedge i_usr_clk)
begin : USER_FSM
    case (user_state)
        // ---------------------------------------------------
        USER_FSM_INIT:
        begin
            user_state  <= USER_FSM_INIT;
            usr_ack     <= 1'b0;
            usr_read    <= 1'b0;
            usr_write   <= 1'b0;
            if (usr_rst_sync)
            begin
                user_state  <= USER_FSM_RESET;
            end
        end
        // ---------------------------------------------------
        USER_FSM_RESET:
        begin
            user_state  <= USER_FSM_RESET;
            usr_ack     <= 1'b0;
            usr_read    <= 1'b0;
            usr_write   <= 1'b0;
            if (~usr_rst_sync)
            begin
                user_state  <= USER_FSM_IDLE;
            end
        end
        // ---------------------------------------------------
        USER_FSM_IDLE:
        begin
            case (i_usr_cmd[1:0])
                CMD_READ:
                begin
                    user_state  <= USER_FSM_WAIT;
                    usr_read    <= 1'b1;
                    usr_write   <= 1'b0;
                end
                CMD_WRITE:
                begin
                    user_state  <= USER_FSM_WAIT;
                    usr_read    <= 1'b0;
                    usr_write   <= 1'b1;
                end
                default:
                begin
                    user_state  <= USER_FSM_IDLE;
                    usr_read    <= 1'b0;
                    usr_write   <= 1'b0;
                end
            endcase
            usr_ack <= 1'b0;
        end
        // ---------------------------------------------------
        USER_FSM_WAIT:
        begin
            user_state  <= USER_FSM_WAIT;
            if (avmm_finished_sync)
            begin
                user_state      <= USER_FSM_ACK;
                usr_read        <= 1'b0;
                usr_write       <= 1'b0;
                usr_ack         <= 1'b1;
            end
        end
        // ---------------------------------------------------
        USER_FSM_ACK:
        begin
            user_state  <= USER_FSM_ACK;
            if (i_usr_cmd[1:0] == CMD_NOOP)
            begin
                user_state  <= USER_FSM_IDLE;
                usr_ack     <= 1'b0;
            end
        end
        // ---------------------------------------------------
        default:
        begin
            // Something went wrong
            user_state <= USER_FSM_INIT;
        end
    endcase // user_state
    // Catch reset
    if (usr_rst_sync)
    begin
        user_state  <= USER_FSM_RESET;
    end
end

// Avalon-MM interface state machine
always_ff @ (posedge i_avmm_clk)
begin : AVMM_FSM
    case (avmm_state)
        // ---------------------------------------------------
        AVMM_FSM_INIT:
        begin
            avmm_state      <= AVMM_FSM_INIT;
            avmm_read       <= 1'b0;
            avmm_write      <= 1'b0;
            avmm_finished   <= 1'b0;
            if (i_avmm_rst)
            begin
                avmm_state  <= AVMM_FSM_RESET;
            end
        end
        // ---------------------------------------------------
        AVMM_FSM_RESET:
        begin
            avmm_state      <= AVMM_FSM_RESET;
            avmm_read       <= 1'b0;
            avmm_write      <= 1'b0;
            avmm_finished   <= 1'b0;
            avmm_readdata   <= '0;
            if (~i_avmm_rst)
            begin
                avmm_state  <= AVMM_FSM_IDLE;
            end
        end
        // ---------------------------------------------------
        AVMM_FSM_IDLE:
        begin
            case ({usr_read_sync, usr_write_sync})
                2'b10:
                begin
                    avmm_state  <= AVMM_FSM_READ;
                    avmm_read   <= 1'b1;
                    avmm_write  <= 1'b0;
                end
                2'b01:
                begin
                    avmm_state  <= AVMM_FSM_WRITE;
                    avmm_read   <= 1'b0;
                    avmm_write  <= 1'b1;
                end
                default:
                begin
                    avmm_state  <= AVMM_FSM_IDLE;
                    avmm_read   <= 1'b0;
                    avmm_write  <= 1'b0;
                end
            endcase
            avmm_finished <= 1'b0;
        end
        // ---------------------------------------------------
        AVMM_FSM_READ:
        begin
            avmm_state  <= AVMM_FSM_READ;
            if (avmm_waitrequest_d && ~i_avmm_waitrequest)
            begin
                avmm_state      <= AVMM_FSM_ACK;
                avmm_read       <= 1'b0;
                avmm_readdata   <= i_avmm_readdata;
                avmm_finished   <= 1'b1;
            end
        end
        // ---------------------------------------------------
        AVMM_FSM_WRITE:
        begin
            avmm_state  <= AVMM_FSM_WRITE;
            if (avmm_waitrequest_d && ~i_avmm_waitrequest)
            begin
                avmm_state      <= AVMM_FSM_ACK;
                avmm_write      <= 1'b0;
                avmm_finished   <= 1'b1;
            end
        end
        // ---------------------------------------------------
        AVMM_FSM_ACK:
        begin
            avmm_state  <= AVMM_FSM_ACK;
            if (usr_ack_sync)
            begin
                avmm_state      <= AVMM_FSM_IDLE;
                avmm_finished   <= 1'b0;
            end
        end
        // ---------------------------------------------------
        default:
        begin
            // Something went wrong
            avmm_state <= AVMM_FSM_INIT;
        end
    endcase // avmm_state
    // Catch reset
    if (i_avmm_rst)
    begin
        avmm_state      <= AVMM_FSM_RESET;
    end
end

endmodule // mm_ctrl_xcvr
