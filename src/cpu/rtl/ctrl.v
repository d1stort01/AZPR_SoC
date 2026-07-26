`timescale 1ns/1ps

`include "cpu.h"
`include "isa.h"
`include "stddef.h"
`include "global_config.h"

module ctrl (
    // Clock & Reset
    input wire                   clk,
    input wire                   reset,
    // Control Register Interfac
    input wire [`RegAddrBus]     creg_rd_addr,
    output reg [`WordDataBus]    creg_rd_data,
    output reg                   exe_mode,
    // Interrupt
    input wire [`CPU_IRQ_CH-1:0] irq,
    output reg                   int_detect,
    // ID/EX Pipeline Register
    input wire [`WordAddrBus]    id_pc,
    // MEM/WB Pipeline Register
    input wire [`WordAddrBus]    mem_pc,
    input wire                   mem_en,
    input wire                   mem_br_flag,
    input wire [`CtrlOpBus]      mem_ctrl_op,
    input wire [`RegAddrBus]     mem_dst_addr,
    input wire                   mem_gpr_we_,
    input wire [`CpuExeModeBus]  mem_exp_code,
    input wire [`WordDataBus]    mem_out,
    // Pipeline Status
    input wire                   if_busy,
    input wire                   ld_hazard,
    input wire                   mem_busy,
    // Stall Signal
    output wire                  if_stall,
    output wire                  id_stall,
    output wire                  ex_stall,
    output wire                  mem_stall,
    // Flush Signal
    output wire                  if_flush,
    output wire                  id_flush,
    output wire                  ex_flush,
    output wire                  mem_flush,
    output reg [`WordAddrBus]    new_pc
);
    //
    // Control Registers
    //
    reg                   int_en;
    reg                   pre_exe_mode;
    reg                   pre_int_en;
    reg [`WordAddrBus]    epc;
    reg [`WordAddrBus]    exp_vecter;
    reg [`IsaExpBus]      exp_code;
    reg                   dly_flag;
    reg [`CPU_IRQ_CH-1:0] mask;

    reg [`WordAddrBus]    pre_pc;
    reg                   br_flag;

    //
    // Stall Signals
    //
    wire stall       = if_busy | mem_busy;
    assign if_stall  = stall;
    assign id_stall  = stall;
    assign ex_stall  = stall;
    assign mem_stall = stall;

    //
    // Flush Signals
    //
    reg flush;
    assign if_flush  = flush;
    assign id_flush  = flush | ld_hazard;
    assign ex_flush  = flush;
    assign mem_flush = flush;

    //
    // Pipeline Flush Control
    //
    always @(*) begin
        new_pc  = `WORD_ADDR_W'h0;
        flush   = `DISABLE;
        if (mem_en == `ENABLE) begin
            if (mem_exp_code != `ISA_EXP_NO_EXP) begin
                new_pc = exp_vecter;
                flush  = `ENABLE;
            end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin
                new_pc = epc;
                flush  = `ENABLE;
            end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin
                new_pc = mem_pc;
                flush  = `ENABLE;
            end
        end
    end
    
endmodule
