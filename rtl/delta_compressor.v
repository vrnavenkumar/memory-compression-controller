module delta_compressor (
    input  wire        clk,
    input  wire        rst,
    input  wire [127:0] data_in,
    input  wire        valid_in,
    output reg  [127:0] compressed_data,
    output reg         compressed_valid,
    output reg  [7:0]  compressed_len
);

    reg [31:0] prev_word;
    reg [31:0] w0, w1, w2, w3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            compressed_data  <= 128'b0;
            compressed_valid <= 1'b0;
            compressed_len   <= 8'd0;
            prev_word       <= 32'b0;
        end else if (valid_in) begin
            w0 = data_in[31:0];
            w1 = data_in[63:32];
            w2 = data_in[95:64];
            w3 = data_in[127:96];

            compressed_data[31:0]   = w0 - prev_word;
            compressed_data[63:32]  = w1 - w0;
            compressed_data[95:64]  = w2 - w1;
            compressed_data[127:96] = w3 - w2;

            compressed_valid <= 1'b1;
            compressed_len   <= 8'd16;
            prev_word       <= w3;
        end else begin
            compressed_valid <= 1'b0;
        end
    end
endmodule
