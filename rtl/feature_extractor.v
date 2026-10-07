`timescale 1ns/1ps

module feature_extractor (
    input  wire        clk,
    input  wire        rst,
    input  wire [511:0] din,
    input  wire        valid_in,

    output reg  [31:0] zero_word_count,
    output reg  [31:0] max_delta_width,
    output reg         feature_valid
);

    integer i;
    reg [31:0] tmp_words [0:15];
    reg [31:0] local_max_delta;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            zero_word_count <= 32'd0;
            max_delta_width <= 32'd0;
            feature_valid   <= 1'b0;
            local_max_delta <= 32'd0;
        end else if (valid_in) begin
            zero_word_count <= 32'd0;
            local_max_delta <= 32'd0;

            for (i = 0; i < 16; i = i + 1) begin
                tmp_words[i] = din[32*(i+1)-1 : 32*i];

                if (tmp_words[i] == 32'd0)
                    zero_word_count <= zero_word_count + 1;
            end

            for (i = 0; i < 15; i = i + 1) begin
                if ((tmp_words[i+1] > tmp_words[i]) && ((tmp_words[i+1] - tmp_words[i]) > local_max_delta))
                    local_max_delta <= tmp_words[i+1] - tmp_words[i];
            end

            max_delta_width <= local_max_delta;
            feature_valid   <= 1'b1;
        end else begin
            feature_valid <= 1'b0;
        end
    end
endmodule
