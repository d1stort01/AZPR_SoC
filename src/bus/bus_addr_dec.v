`timescale 1ns/1ps

`include "../../include/bus.h"
`include "../../include/stddef.h"
`include "../../include/global_config.h"

module bus_addr_dec (
    input wire [`WordAddrBus] s_addr,
    output reg s0_cs_,
    output reg s1_cs_,
    output reg s2_cs_,
    output reg s3_cs_,
    output reg s4_cs_,
    output reg s5_cs_,
    output reg s6_cs_,
    output reg s7_cs_
);
    // Slave Index Extraction
    wire [`BusSlaveIndexBus] s_index = s_addr[`BusSlaveIndexLoc];

    // Slave Chip-Select Decoder
    always @(*) begin
        // Deassert all chip-select signals
        s0_cs_ = `DISABLE_;
        s1_cs_ = `DISABLE_;
        s2_cs_ = `DISABLE_;
        s3_cs_ = `DISABLE_;
        s4_cs_ = `DISABLE_;
        s5_cs_ = `DISABLE_;
        s6_cs_ = `DISABLE_;
        s7_cs_ = `DISABLE_;
        // Assert ship-select for the addressed slave
        case (s_index)
            `BUS_SLAVE_0: begin
                s0_cs_ = `ENABLE_;
            end
            `BUS_SLAVE_1: begin
                s1_cs_ = `ENABLE_;
            end
            `BUS_SLAVE_2: begin
                s2_cs_ = `ENABLE_;
            end
            `BUS_SLAVE_3: begin
                s3_cs_ = `ENABLE_;
            end
            `BUS_SLAVE_4: begin
                s4_cs_ = `ENABLE_;
            end
            `BUS_SLAVE_5: begin
                s5_cs_ = `ENABLE_;
            end
            `BUS_SLAVE_6: begin
                s6_cs_ = `ENABLE_;
            end
            `BUS_SLAVE_7: begin
                s7_cs_ = `ENABLE_;
            end
        endcase
    end
    
endmodule
