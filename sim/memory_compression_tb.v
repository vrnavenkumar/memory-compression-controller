module memory_compression_top (
    input  wire        clk,
    input  wire        rst,
    input  wire [127:0] data_in,
    input  wire        valid_in,
    input  wire [1:0]  app_hint,
    output wire [1:0]  selected_mode,
    output wire [127:0] compressed_data_out,
    output wire        compressed_valid,
    output wire [127:0] decompressed_data_out,
    output wire        decompressed_valid
);

    wire [1:0] mode_sel;
    wire       mode_valid;
    wire [127:0] delta_payload;
    wire         delta_valid;
    wire [7:0]  delta_len;
    wire [127:0] rle_payload;
    wire         rle_valid;
    wire [127:0] dict_payload;
    wire         dict_valid;
    wire [7:0]  dict_id;
    reg  [127:0] selected_payload;
    reg          selected_valid;

    mode_selector u_mode_selector (
        .clk       (clk),
        .rst       (rst),
        .data_in   (data_in),
        .app_hint  (app_hint),
        .mode_out  (mode_sel),
        .mode_valid(mode_valid)
    );

    delta_compressor u_delta_compressor (
        .clk             (clk),
        .rst             (rst),
        .data_in         (data_in),
        .valid_in        (valid_in),
        .compressed_data (delta_payload),
        .compressed_valid(delta_valid),
        .compressed_len  (delta_len)
    );

    rle_compressor u_rle_compressor (
        .clk             (clk),
        .rst             (rst),
        .data_in         (data_in),
        .valid_in        (valid_in),
        .compressed_data (rle_payload),
        .compressed_valid(rle_valid)
    );

    dictionary_compressor u_dictionary_compressor (
        .clk             (clk),
        .rst             (rst),
        .data_in         (data_in),
        .valid_in        (valid_in),
        .compressed_data (dict_payload),
        .compressed_valid(dict_valid),
        .dict_id         (dict_id)
    );

    always @(*) begin
        case (mode_sel)
            2'b00: begin
                selected_payload = data_in;
                selected_valid   = valid_in;
            end
            2'b01: begin
                selected_payload = delta_payload;
                selected_valid   = delta_valid;
            end
            2'b10: begin
                selected_payload = rle_payload;
                selected_valid   = rle_valid;
            end
            2'b11: begin
                selected_payload = dict_payload;
                selected_valid   = dict_valid;
            end
            default: begin
                selected_payload = data_in;
                selected_valid   = valid_in;
            end
        endcase
    end

    memory_compression_decompressor u_decompressor (
        .clk               (clk),
        .rst               (rst),
        .mode              (mode_sel),
        .compressed_data   (selected_payload),
        .valid_in          (selected_valid),
        .decompressed_data (decompressed_data_out),
        .decompressed_valid(decompressed_valid)
    );

    assign selected_mode   = mode_sel;
    assign compressed_data_out = selected_payload;
    assign compressed_valid = selected_valid;
endmodule
