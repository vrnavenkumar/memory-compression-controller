`timescale 1ns/1ps

module rx_input_depacketizer (
    input  wire        clk,
    input  wire        rst,
    input  wire [127:0] noc_tdata,
    input  wire        noc_tvalid,
    output reg         noc_tready,

    output reg  [127:0] rx_payload,
    output reg         rx_valid
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_payload <= 128'd0;
            rx_valid   <= 1'b0;
            noc_tready <= 1'b0;
        end else if (noc_tvalid) begin
            noc_tready <= 1'b1;
            rx_payload <= noc_tdata;
            rx_valid   <= 1'b1;
        end else begin
            noc_tready <= 1'b1;
            rx_valid   <= 1'b0;
        end
    end
endmodule
