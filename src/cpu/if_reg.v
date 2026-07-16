`timescale 1ns/1ps

`include "../../include/cpu.h"
`include "../../include/isa.h"
`include "../../include/bus.h"
`include "../../include/stddef.h"
`include "../../include/global_config.h"

module if_reg (
    input wire                  clk,
    input wire                  reset,
    input wire [`WordDataBus]   insn,
    // Pipeline Control Signals
    input wire                  stall,
    input wire                  flush,
    input wire [`WordAddrBus]   new_pc,
    input wire                  br_taken,
    input wire [`WordAddrBus]   br_addr,
    // IF/ID Pipeline Registers
    output reg [`WordAddrBus]   if_pc,
    output reg [`WordDataBus]   if_insn,
    output reg                  if_en
);
    always @(posedge clk or `RESET_EDGE reset) begin
        if (reset == `RESET_ENABLE) begin
            if_pc   <= #1 `RESET_VECTOR;
            if_insn <= #1 `ISA_NOP;
            if_en   <= #1 `DISABLE;
        end else begin
            if (stall == `DISABLE) begin
                if (flush == `ENABLE) begin             // Flush
                    if_pc   <= #1 new_pc;
                    if_insn <= #1 `ISA_NOP;
                    if_en   <= #1 `DISABLE;
                end else if (br_taken == `ENABLE) begin // Branch taken
                    if_pc   <= #1 br_addr;
                    if_insn <= #1 insn;
                    if_en   <= #1 `ENABLE;
                end else begin                           // Next address
                    if_pc   <= #1 if_pc + 1'd1;
                    if_insn <= #1 insn;
                    if_en   <= #1 `ENABLE;
                end
            end
        end
    end
endmodule
