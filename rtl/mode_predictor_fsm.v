`timescale 1ns/1ps

module mode_predictor_fsm (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] zero_word_cnt,
    input  wire [31:0] max_delta_w,
    input  wire [15:0] congestion,
    input  wire [31:0] threshold,

    output reg  [1:0] mode_out,
    output reg        mode_valid
);

    localparam MODE_BYPASS = 2'b00;
    localparam MODE_DELTA  = 2'b01;
    localparam MODE_RLE    = 2'b10;
    localparam MODE_DICT   = 2'b11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode_out   <= MODE_BYPASS;
            mode_valid <= 1'b0;
        end else begin
            mode_valid <= 1'b1;

            if (congestion > threshold) begin
                mode_out <= MODE_BYPASS;
            end else if (zero_word_cnt > 8) begin
                mode_out <= MODE_RLE;
            end else if (max_delta_w < 32'd256) begin
                mode_out <= MODE_DELTA;
            end else begin
                mode_out <= MODE_DICT;
            end
        end
    end
endmodule
