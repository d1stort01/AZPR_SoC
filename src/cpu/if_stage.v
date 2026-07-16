`timescale 1ns/1ps

`include "../../include/stddef.h"

module if_stage (
    // Clock & Reset
    input wire                  clk,
    input wire                  reset,
    // Bus Busy Signal
    output wire                 busy,
    // Pipeline Control Signals
    input wire                  stall,
    input wire                  flush,
    input wire [`WordAddrBus]   new_pc,
    input wire                  br_taken,
    input wire [`WordAddrBus]   br_addr,
    // IF/ID Pipeline Registers
    output wire [`WordAddrBus]  if_pc,
    output wire [`WordDataBus]  if_insn,
    output wire                 if_en,
    // SPM Interface
    input wire [`WordDataBus]   spm_rd_data,
    output wire [`WordAddrBus]  spm_addr,
    output wire                 spm_as_,
    output wire                 spm_rw,
    output wire [`WordDataBus]  spm_wr_data,
    // Bus Interface
    input wire [`WordDataBus]   bus_rd_data,
    input wire                  bus_rdy_,
    input wire                  bus_grnt_,
    output wire                 bus_req_,
    output wire [`WordAddrBus]  bus_addr,
    output wire                 bus_as_,
    output wire                 bus_rw,
    output wire [`WordDataBus]  bus_wr_data
);
    wire [`WordDataBus] rd_data;

    bus_if bus_if (
        .clk        (clk),
        .reset      (reset),
        .stall      (stall),
        .flush      (flush),
        .busy       (busy),
        .addr       (if_pc),
        .as_        (`ENABLE_),
        .rw         (`READ),
        .wr_data    (`WORD_DATA_W'h0),
        .rd_data    (rd_data),
        .spm_rd_data(spm_rd_data),
        .spm_addr   (spm_addr),
        .spm_as_    (spm_as_),
        .spm_rw     (spm_rw),
        .spm_wr_data(spm_wr_data),
        .bus_rd_data(bus_rd_data),
        .bus_rdy_   (bus_rdy_),
        .bus_grnt_  (bus_grnt_),
        .bus_req_   (bus_req_),
        .bus_addr   (bus_addr),
        .bus_as_    (bus_as_),
        .bus_rw     (bus_rw),
        .bus_wr_data(bus_wr_data)
    );

    if_reg if_reg_0 (
        .clk     (clk),
        .reset   (reset),
        .insn    (rd_data),
        .stall   (stall),
        .flush   (flush),
        .new_pc  (new_pc),
        .br_taken(br_taken),
        .br_addr (br_addr),
        .if_pc   (if_pc),
        .if_insn (if_insn),
        .if_en   (if_en)
    );

endmodule
