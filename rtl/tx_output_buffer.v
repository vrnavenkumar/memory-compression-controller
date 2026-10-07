`timescale 1ns/1ps

module tx_output_buffer (
    input  wire        clk,
    input  wire        rst,
    input  wire [127:0] din,
    input  wire        din_valid,
    input  wire [7:0]  din_len,
    input  wire        noc_ready,

    output reg  [127:0] noc_tdata,
    output reg         noc_tvalid
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            noc_tdata  <= 128'd0;
            noc_tvalid <= 1'b0;
        end else if (din_valid && noc_ready) begin
            noc_tdata  <= din;
            noc_tvalid <= 1'b1;
        end else begin
            noc_tvalid <= 1'b0;
        end
    end
endmodule
