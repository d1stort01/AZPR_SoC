`timescale 1ns/1ps

`include "../../include/cpu.h"
`include "../../include/isa.h"
`include "../../include/bus.h"
`include "../../include/stddef.h"
`include "../../include/global_config.h"

module bus_if (
    // IF/ID Pipeline Registers
    input wire [`WordAddrBus]   if_pc,
    input wire [`WordDataBus]   if_insn,
    input wire                  if_en,
    // GPR Interface
    input wire [`WordDataBus]   gpr_rd_data_0,
    input wire [`WordDataBus]   gpr_rd_data_1,
    output wire [`RegAddrBus]   gpr_rd_addr_0,
    output wire [`RegAddrBus]   gpr_rd_addr_1,
    // Data Forwarding from ID Stage
    input wire                  id_en,
    input wire [`RegAddrBus]    id_dst_addr,
    input wire                  id_gpr_we_,
    input wire [`MemOpBus]      id_mem_op,
    // Data Forwarding from EX Stage
    input wire                  ex_en,
    input wire [`RegAddrBus]    ex_dst_addr,
    input wire                  ex_gpr_we_,
    input wire [`WordDataBus]   ex_fwd_data,
    // Data Forwarding from MEM Stage
    input wire [`WordDataBus]   mem_fwd_data,
    // Control Register Interface
    input wire                  exe_mode,
    input wire [`WordDataBus]   creg_rd_data,
    output wire [`RegAddrBus]   creg_rd_addr,
    // Decoding Results
    output reg [`AluOpBus]      alu_op,
    output reg [`WordDataBus]   alu_in_0,
    output reg [`WordDataBus]   alu_in_1,
    output reg [`WordAddrBus]   br_addr,
    output reg                  br_taken,
    output reg                  br_flag,
    output reg [`MemOpBus]      mem_op,
    output wire [`WordDataBus]  mem_wr_data,
    output reg [`CtrlOpBus]     ctrl_op,
    output reg [`RegAddrBus]    dst_addr,
    output reg                  gpr_we_,
    output reg [`IsaExpBus]     exp_code,
    output reg                  ld_hazard
);
    // Instruction Fields
    wire [`IsaOpBus]    op      = if_insn[`IsaOpLoc];
    wire [`RegAddrBus]  ra_addr = if_insn[`IsaRaAddrLoc];
    wire [`RegAddrBus]  rb_addr = if_insn[`IsaRbAddrLoc];
    wire [`RegAddrBus]  rc_addr = if_insn[`IsaRcAddrLoc];
    wire [`IsaImmBus]   imm     = if_insn[`IsaImmLoc];
    // Immediate Values
    wire [`WordDataBus] imm_s = {{`ISA_EXT_W{imm[`ISA_IMM_MSB]}}, imm};
    wire [`WordDataBus] imm_u = {{`ISA_EXT_W{1'b0}}, imm};
    // Register Read Addresses
    assign gpr_rd_addr_0 = ra_addr;
    assign gpr_rd_addr_1 = rb_addr;
    assign creg_rd_addr  = ra_addr;
    // GPR Read Data
    reg [`WordDataBus]          ra_data;
    wire signed [`WordDataBus]  s_ra_data = $signed(ra_data);
    reg [`WordDataBus]          rb_data;
    wire signed [`WordDataBus]  s_rb_data = $signed(rb_data);
    // Addresses
    wire [`WordAddrBus] ret_addr = if_pc + 1'b1; // Return Address
    wire [`WordAddrBus] br_target = if_pc + imm_s[`WORD_ADDR_MSB:0]; // Branch Target
    wire [`WordAddrBus] jr_target = ra_data[`WordAddrLoc]; // Jump Target

endmodule
