`timescale 1ns/1ps

module x_s3e_sprom (
    input wire          clka,
    input wire  [10:0]  addra,
    output reg  [31:0]  douta
);

    // 2048 x 32-bit ROM
    reg [31:0] mem [0:2047];

    // Initialize ROM with zeros (or load from a hex file)
    initial begin
        $readmemh("rom.hex", mem);
    end

    // Synchronous read
    always @(posedge clka) begin
        douta <= mem[addra];
    end

endmodule
