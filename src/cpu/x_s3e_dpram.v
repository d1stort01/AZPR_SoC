`timescale 1ns/1ps

module x_s3e_dpram (
    input wire          clka,
    input wire          wea,
    input wire  [11:0]  addra,
    input wire  [31:0]  dina,
    output wire [31:0]  douta,
    input wire          clkb,
    input wire          web,
    input wire  [11:0]  addrb,
    input wire  [31:0]  dinb,
    output wire [31:0]  doutb
);

    reg [31:0] mem [0:4095];

    reg [31:0] douta_r;
    reg [31:0] doutb_r;

    assign douta = douta_r;
    assign doutb = doutb_r;

    always @(posedge clka) begin
        if (wea)
            mem[addra] <= dina;
        douta_r <= mem[addra];
    end

    always @(posedge clkb) begin
        if (web)
            mem[addrb] <= dinb;
        doutb_r <= mem[addrb];
    end

endmodule
