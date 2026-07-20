`timescale 1ns/1ps

`include "../../include/cpu.h"
`include "../../include/isa.h"
`include "../../include/bus.h"
`include "../../include/stddef.h"
`include "../../include/global_config.h"

module mem_reg (
    input wire                  clk,
    input wire                  reset,
    // Memory Access Results
    input wire [`WordDataBus]   out,
    input wire                  miss_align,
    // Pipeline Control Signals
    input wire                  stall,
    input wire                  flush,
    // EX/MEM Pipeline Registers
    input wire [`WordAddrBus]   ex_pc,
    input wire                  ex_en,
    input wire                  ex_br_flag,
    input wire [`CtrlOpBus]     ex_ctrl_op,
    input wire [`RegAddrBus]    ex_dst_addr,
    input wire                  ex_gpr_we_,
    input wire [`IsaExpBus]     ex_exp_code,
    // MEM/WB Pipeline Registers
    output reg [`WordAddrBus]   mem_pc,
    output reg                  mem_en,
    output reg                  mem_br_flag,
    output reg [`CtrlOpBus]     mem_ctrl_op,
    output reg [`RegAddrBus]    mem_dst_addr,
    output reg                  mem_gpr_we_,
    output reg [`IsaExpBus]     mem_exp_code,
    output reg [`WordDataBus]   mem_out
);
    always @(posedge clk or `RESET_EDGE reset) begin
        if (reset == `RESET_ENABLE) begin
            mem_pc          <= #1 `WORD_ADDR_W'h0;
            mem_en          <= #1 `DISABLE;
            mem_br_flag     <= #1 `DISABLE;
            mem_ctrl_op     <= #1 `CTRL_OP_NOP;
            mem_dst_addr    <= #1 `REG_ADDR_W'd0;
            mem_gpr_we_     <= #1 `DISABLE_;
            mem_exp_code    <= #1 `ISA_EXP_NO_EXP;
            mem_out         <= #1 `WORD_DATA_W'h0;
        end else begin
            if (stall == `DISABLE) begin
                if (flush == `ENABLE) begin                 // Flush
                    mem_pc          <= #1 `WORD_ADDR_W'h0;
                    mem_en          <= #1 `DISABLE;
                    mem_br_flag     <= #1 `DISABLE;
                    mem_ctrl_op     <= #1 `CTRL_OP_NOP;
                    mem_dst_addr    <= #1 `REG_ADDR_W'd0;
                    mem_gpr_we_     <= #1 `DISABLE_;
                    mem_exp_code    <= #1 `ISA_EXP_NO_EXP;
                    mem_out         <= #1 `WORD_DATA_W'h0;
                end else if (miss_align == `ENABLE) begin   // Misalignment exception 
                    mem_pc          <= #1 ex_pc;
                    mem_en          <= #1 ex_en;
                    mem_br_flag     <= #1 ex_br_flag;
                    mem_ctrl_op     <= #1 `CTRL_OP_NOP;
                    mem_dst_addr    <= #1 `REG_ADDR_W'd0;
                    mem_gpr_we_     <= #1 `DISABLE_;
                    mem_exp_code    <= #1 `ISA_EXP_MISS_ALIGN;
                    mem_out         <= #1 `WORD_DATA_W'h0;
                end else begin                              // Next data
                    mem_pc          <= #1 ex_pc;
                    mem_en          <= #1 ex_en;
                    mem_br_flag     <= #1 ex_br_flag;
                    mem_ctrl_op     <= #1 ex_ctrl_op;
                    mem_dst_addr    <= #1 ex_dst_addr;
                    mem_gpr_we_     <= #1 ex_gpr_we_;
                    mem_exp_code    <= #1 ex_exp_code;
                    mem_out         <= #1 out;
                end
            end
        end
    end
endmodule
