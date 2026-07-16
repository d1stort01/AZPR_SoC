`timescale 1ns/1ps

`include "../../include/cpu.h"
`include "../../include/spm.h"
`include "../../include/stddef.h"
`include "../../include/global_config.h"

module spm (
    input wire                  clk,
    input wire [`SpmAddrBus]    if_spm_addr,
    input wire                  if_spm_as_,
    input wire                  if_spm_rw,
    input wire [`WordDataBus]   if_spm_wr_data,
    output wire [`WordDataBus]  if_spm_rd_data,
    input wire [`SpmAddrBus]    mem_spm_addr,
    input wire                  mem_spm_as_,
    input wire                  mem_spm_rw,
    input wire [`WordDataBus]   mem_spm_wr_data,
    output wire [`WordDataBus]  mem_spm_rd_data
);
    reg wea;
    reg web;
                        
    always @(*) begin
        if ((if_spm_as_ == `ENABLE_) && (if_spm_rw == `ENABLE)) begin
            wea = `MEM_ENABLE;
        end else begin
            wea = `MEM_DISABLE;
        end
        if ((mem_spm_as_ == `ENABLE_) && (mem_spm_rw == `ENABLE)) begin
            web = `MEM_ENABLE;
        end else begin
            web = `MEM_DISABLE;
        end
    end

    // Scratch Pad Memory
    x_s3e_dpram x_s3e_dpram_0 (
        .clka(clk),                 // input clka
        .wea(wea),                  // input [0 : 0] wea
        .addra(if_spm_addr),        // input [11 : 0] addra
        .dina(if_spm_wr_data),      // input [31 : 0] dina
        .douta(if_spm_rd_data),     // output [31 : 0] douta
        .clkb(clk),                 // input clkb
        .web(web),                  // input [0 : 0] web
        .addrb(mem_spm_addr),       // input [11 : 0] addrb
        .dinb(mem_spm_wr_data),     // input [31 : 0] dinb
        .doutb(mem_spm_rd_data)     // output [31 : 0] doutb
    );
    
endmodule
