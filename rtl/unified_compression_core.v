`timescale 1ns/1ps

module unified_compression_core (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  mode_in,
    input  wire [511:0] din,
    input  wire        din_valid,
    input  wire        cfg_enable,

    output reg  [127:0] dout,
    output reg         dout_valid,
    output reg  [7:0]  dout_len
);

    localparam MODE_BYPASS = 2'b00;
    localparam MODE_DELTA  = 2'b01;
    localparam MODE_RLE    = 2'b10;
    localparam MODE_DICT   = 2'b11;

    reg [31:0] delta_data [0:3];
    reg [31:0] rle_data [0:3];
    reg [31:0] dict_data [0:3];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dout       <= 128'd0;
            dout_valid <= 1'b0;
            dout_len   <= 8'd0;
        end else if (cfg_enable && din_valid) begin
            case (mode_in)
                MODE_BYPASS: begin
                    dout       <= din[127:0];
                    dout_valid <= 1'b1;
                    dout_len   <= 8'd16;
                end

                MODE_DELTA: begin
                    delta_data[0] <= din[31:0];
                    delta_data[1] <= din[63:32];
                    delta_data[2] <= din[95:64];
                    delta_data[3] <= din[127:96];

                    dout[31:0]   <= delta_data[0];
                    dout[63:32]  <= delta_data[1] - delta_data[0];
                    dout[95:64]  <= delta_data[2] - delta_data[1];
                    dout[127:96] <= delta_data[3] - delta_data[2];
                    dout_valid   <= 1'b1;
                    dout_len     <= 8'd16;
                end

                MODE_RLE: begin
                    if ((din[31:0] == din[63:32]) && (din[63:32] == din[95:64]) &&
                        (din[95:64] == din[127:96])) begin
                        dout[31:0]   <= din[31:0];
                        dout[63:32]  <= 32'd4;
                        dout[95:64]  <= 32'd0;
                        dout[127:96] <= 32'd0;
                    end else begin
                        dout <= din[127:0];
                    end
                    dout_valid <= 1'b1;
                    dout_len   <= 8'd16;
                end

                MODE_DICT: begin
                    dout[31:0]   <= din[31:0];
                    dout[63:32]  <= din[63:32];
                    dout[95:64]  <= din[95:64];
                    dout[127:96] <= din[127:96];
                    dout_valid   <= 1'b1;
                    dout_len     <= 8'd16;
                end

                default: begin
                    dout       <= din[127:0];
                    dout_valid <= 1'b1;
                    dout_len   <= 8'd16;
                end
            endcase
        end else begin
            dout_valid <= 1'b0;
        end
    end
endmodule
