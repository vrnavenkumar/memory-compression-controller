module memory_compression_decompressor (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  mode,
    input  wire [127:0] compressed_data,
    input  wire        valid_in,
    output reg  [127:0] decompressed_data,
    output reg         decompressed_valid
);

    reg [31:0] prev_word;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            decompressed_data   <= 128'b0;
            decompressed_valid <= 1'b0;
            prev_word          <= 32'b0;
        end else if (valid_in) begin
            case (mode)
                2'b00: begin
                    decompressed_data   <= compressed_data;
                    decompressed_valid <= 1'b1;
                end
                2'b01: begin
                    decompressed_data[31:0]   = prev_word + compressed_data[31:0];
                    decompressed_data[63:32]  = decompressed_data[31:0] + compressed_data[63:32];
                    decompressed_data[95:64]  = decompressed_data[63:32] + compressed_data[95:64];
                    decompressed_data[127:96] = decompressed_data[95:64] + compressed_data[127:96];
                    prev_word <= decompressed_data[127:96];
                    decompressed_valid <= 1'b1;
                end
                2'b10: begin
                    decompressed_data <= {compressed_data[31:0], compressed_data[31:0], compressed_data[31:0], compressed_data[31:0]};
                    decompressed_valid <= 1'b1;
                end
                default: begin
                    decompressed_data <= compressed_data;
                    decompressed_valid <= 1'b1;
                end
            endcase
        end else begin
            decompressed_valid <= 1'b0;
        end
    end
endmodule
