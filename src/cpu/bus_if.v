`timescale 1ns/1ps

`include "../../include/cpu.h"
`include "../../include/bus.h"
`include "../../include/stddef.h"
`include "../../include/global_config.h"

module bus_if (
    input wire                  clk,
    input wire                  reset,
    // Pipeline Control Signals
    input wire                  stall,
    input wire                  flush,
    output reg                  busy,
    // CPU Interface
    input wire [`WordAddrBus]   addr,
    input wire                  as_,
    input wire                  rw,
    input wire [`WordDataBus]   wr_data,
    output reg [`WordDataBus]   rd_data,
    // SPM Interface
    input wire [`WordDataBus]   spm_rd_data,
    output wire [`WordAddrBus]  spm_addr,
    output reg                  spm_as_,
    output wire                 spm_rw,
    output wire [`WordDataBus]  spm_wr_data,
    // Bus Interface
    input wire [`WordDataBus]   bus_rd_data,
    input wire                  bus_rdy_,
    input wire                  bus_grnt_,
    output reg                  bus_req_,
    output reg [`WordAddrBus]   bus_addr,
    output reg                  bus_as_,
    output reg                  bus_rw,
    output reg [`WordDataBus]   bus_wr_data
);
    reg [1:0]                   state;
    reg [`WordDataBus]          rd_buf;
    wire [2:0]                  s_index;

    assign s_index = addr[`BusSlaveIndexLoc];

    // Output Assignments
    assign spm_addr     = addr;
    assign spm_rw       = rw;
    assign spm_wr_data  = wr_data;
    
    // Memory Access Control
    always @(*) begin
        rd_data = `WORD_DATA_W'h0;
        spm_as_ = `DISABLE_;
        busy = `DISABLE;
        case (state)
            `BUS_IF_STATE_IDLE: begin
                if ((flush == `DISABLE) && (as_ == `ENABLE)) begin
                    if (s_index == `BUS_SLAVE_1) begin  // Destination: SPM
                        if (stall == `DISABLE) begin    // No stall, proceed
                            spm_as_ = `ENABLE_;
                            if (rw == `READ) begin
                                rd_data = spm_rd_data;
                            end
                        end
                    end else begin                      // Destination: External Bus
                        busy = `ENABLE;
                    end
                end
            end
            `BUS_IF_STATE_REQ: begin
                busy = `ENABLE;
            end
            `BUS_IF_STATE_ACCESS: begin
                if (bus_rdy_ == `ENABLE_) begin
                    if (rw == `READ) begin
                        rd_data = bus_rd_data;
                    end
                end else begin
                    busy = `ENABLE;
                end
            end
            `BUS_IF_STATE_STALL: begin
                if (rw == `READ) begin
                    rd_data = rd_buf;
                end
            end
        endcase
    end

    // Bus Interface State Control
    always @(posedge clk or `RESET_EDGE reset) begin
        if (reset == `RESET_ENABLE) begin
            state       <= #1 `BUS_IF_STATE_IDLE;
            bus_req_    <= #1 `DISABLE_;
            bus_addr    <= #1 `WORD_ADDR_W'h0;
            bus_as_     <= #1 `DISABLE_;
            bus_rw      <= #1 `READ;
            bus_wr_data <= #1 `WORD_DATA_W'h0;
            rd_buf      <= #1 `WORD_DATA_W'h0;
        end else begin
            case (state)
                `BUS_IF_STATE_IDLE: begin
                    if ((flush == `DISABLE) && (as_ == `ENABLE)) begin
                        if (s_index != `BUS_SLAVE_1) begin  // External Bus Access
                            state       <= #1 `BUS_IF_STATE_REQ;
                            bus_req_    <= #1 `ENABLE_;
                            bus_addr    <= #1 addr;
                            bus_rw      <= #1 rw;
                            bus_wr_data <= #1 wr_data;
                            end
                    end
                end
                `BUS_IF_STATE_REQ: begin                    // Wait for Bus Grant
                    if (bus_grnt_ == `ENABLE_) begin
                        state   <= #1 `BUS_IF_STATE_ACCESS;
                        bus_as_ <= #1 `ENABLE_;
                    end
                end
                `BUS_IF_STATE_ACCESS: begin
                    bus_as_     <= #1 `DISABLE_;
                    if (bus_rdy_ == `ENABLE_) begin
                        bus_req_    <= #1 `DISABLE_;
                        bus_addr    <= #1 `WORD_ADDR_W'h0;
                        bus_rw      <= #1 `READ;
                        bus_wr_data <= #1 `WORD_DATA_W'h0;
                        if (bus_rw == `READ) begin          // Store Read Data
                            rd_buf <= #1 bus_rd_data;
                        end
                        if (stall == `ENABLE) begin
                            state <= #1 `BUS_IF_STATE_STALL;
                        end else begin
                            state <= #1 `BUS_IF_STATE_IDLE;
                        end
                    end
                end
                `BUS_IF_STATE_STALL: begin
                    if (stall == `DISABLE) begin
                        state <= #1 `BUS_IF_STATE_IDLE;
                    end
                end
            endcase
        end
    end

endmodule
