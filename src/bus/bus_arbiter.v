`timescale 1ns/1ps

`include "../../include/bus.h"
`include "../../include/stddef.h"
`include "../../include/global_config.h"

module bus_arbiter (
    // System Clock
    input wire clk,
    input wire reset,
    // Bus Master
    input wire m0_req_,
    output reg m0_grnt_,
    input wire m1_req_,
    output reg m1_grnt_,
    input wire m2_req_,
    output reg m2_grnt_,
    input wire m3_req_,
    output reg m3_grnt_
);
 
    reg [1:0] owner;

    // Bus Grant Logic
    always @(*) begin
        // Deassert all grant signal
        m0_grnt_ = `DISABLE;
        m1_grnt_ = `DISABLE;
        m2_grnt_ = `DISABLE;
        m3_grnt_ = `DISABLE;
        // Assert grant signal base on current owner
        case (owner)
            `BUS_OWNER_MASTER_0: begin
                m0_grnt_ = `ENABLE_;
            end
            `BUS_OWNER_MASTER_1: begin
                m1_grnt_ = `ENABLE_;
            end
            `BUS_OWNER_MASTER_2: begin
                m2_grnt_ = `ENABLE_;
            end
            `BUS_OWNER_MASTER_3: begin
                m3_grnt_ = `ENABLE_;
            end
        endcase
    end

    // Bus Arbitration Logic
    always @(posedge clk or `RESET_EDGE reset) begin
        if (reset == `RESET_ENABLE) begin
            // Asynchronous reset
            owner <= #1 `BUS_OWNER_MASTER_0;
        end else begin
            // Round robin
            case (owner)
                `BUS_OWNER_MASTER_0: begin
                    if (m0_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_0;
                    end else if (m1_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_1;
                    end else if (m2_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_2;
                    end else if (m3_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_3;
                    end
                end
                `BUS_OWNER_MASTER_1: begin
                    if (m1_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_1;
                    end else if (m2_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_2;
                    end else if (m3_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_3;
                    end else if (m0_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_0;
                    end
                end
                `BUS_OWNER_MASTER_2: begin
                    if (m2_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_2;
                    end else if (m3_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_3;
                    end else if (m0_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_0;
                    end else if (m1_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_1;
                    end
                end
                `BUS_OWNER_MASTER_3: begin
                    if (m3_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_3;
                    end else if (m0_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_0;
                    end else if (m1_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_1;
                    end else if (m2_req_ == `ENABLE_) begin
                        owner <= #1 `BUS_OWNER_MASTER_2;
                    end
                end
            endcase
        end
    end
    
endmodule
