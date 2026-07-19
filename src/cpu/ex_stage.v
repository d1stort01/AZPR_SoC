`timescale 1ns/1ps

`include "../../include/stddef.h"
`include "../../include/cpu.h"
`include "../../include/isa.h"

module ex_stage (
    // Clock & Reset
    input wire                  clk,
    input wire                  reset,
    // Pipeline Control Signals
    input wire                  stall,
    input wire                  flush,
    input wire                  int_detect,
    // Forwarding
    output wire [`WordDataBus]  fwd_data,
    // ID/EX Pipeline Registers
    input wire [`WordAddrBus]   id_pc,
    input wire                  id_en,
    input wire [`AluOpBus]      id_alu_op,
    input wire [`WordDataBus]   id_alu_in_0,
    input wire [`WordDataBus]   id_alu_in_1,
    input wire                  id_br_flag,
    input wire [`MemOpBus]      id_mem_op,
    input wire [`WordDataBus]   id_mem_wr_data,
    input wire [`CtrlOpBus]     id_ctrl_op,
    input wire [`RegAddrBus]    id_dst_addr,
    input wire                  id_gpr_we_,
    input wire [`IsaExpBus]     id_exp_code,
    // EX/MEM Pipeline Registers
    output wire [`WordAddrBus]  ex_pc,
    output wire                 ex_en,
    output wire                 ex_br_flag,
    output wire [`MemOpBus]     ex_mem_op,
    output wire [`WordDataBus]  ex_mem_wr_data,
    output wire [`CtrlOpBus]    ex_ctrl_op,
    output wire [`RegAddrBus]   ex_dst_addr,
    output wire                 ex_gpr_we_,
    output wire [`IsaExpBus]    ex_exp_code,
    output wire [`WordDataBus]  ex_out
);
    wire [`WordDataBus] out;
    wire of;
    assign fwd_data = out;

    alu alu (
        .in_0(id_alu_in_0),
        .in_1(id_alu_in_1),
        .op  (id_alu_op),
        .out (out),
        .of  (of)
    );

    ex_reg ex_reg (
        .clk           (clk),
        .reset         (reset),
        .alu_out       (out),
        .alu_of        (of),
        .stall         (stall),
        .flush         (flush),
        .int_detect    (int_detect),
        .id_pc         (id_pc),
        .id_en         (id_en),
        .id_br_flag    (id_br_flag),
        .id_mem_op     (id_mem_op),
        .id_mem_wr_data(id_mem_wr_data),
        .id_ctrl_op    (id_ctrl_op),
        .id_dst_addr   (id_dst_addr),
        .id_gpr_we_    (id_gpr_we_),
        .id_exp_code   (id_exp_code),
        .ex_pc         (ex_pc),
        .ex_en         (ex_en),
        .ex_br_flag    (ex_br_flag),
        .ex_mem_op     (ex_mem_op),
        .ex_mem_wr_data(ex_mem_wr_data),
        .ex_ctrl_op    (ex_ctrl_op),
        .ex_dst_addr   (ex_dst_addr),
        .ex_gpr_we_    (ex_gpr_we_),
        .ex_exp_code   (ex_exp_code),
        .ex_out        (ex_out)
    );

endmodule
