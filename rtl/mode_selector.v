module mode_selector (
    input  wire        clk,
    input  wire        rst,
    input  wire [127:0] data_in,
    input  wire [1:0]  app_hint,
    output reg  [1:0]  mode_out,
    output reg         mode_valid
);

    reg [31:0] w0, w1, w2, w3;
    reg        rle_flag, delta_flag, dict_flag;

    function automatic [31:0] abs_diff;
        input [31:0] a;
        input [31:0] b;
        begin
            abs_diff = (a >= b) ? (a - b) : (b - a);
        end
    endfunction

    always @(*) begin
        w0 = data_in[31:0];
        w1 = data_in[63:32];
        w2 = data_in[95:64];
        w3 = data_in[127:96];

        rle_flag = (w0 == w1) && (w1 == w2) && (w2 == w3);
        delta_flag = (abs_diff(w1, w0) < 32'd4096) &&
                     (abs_diff(w2, w1) < 32'd4096) &&
                     (abs_diff(w3, w2) < 32'd4096);
        dict_flag = (w0 == w1) || (w1 == w2) || (w2 == w3) || (w0 == w2) || (w1 == w3);

        mode_valid = 1'b1;

        case (app_hint)
            2'b00: mode_out = 2'b00; // BYPASS
            2'b01: mode_out = rle_flag ? 2'b10 : 2'b01; // prefer RLE if repeated, else DELTA
            2'b10: mode_out = delta_flag ? 2'b01 : 2'b11; // prefer DELTA if smooth, else DICT
            default: mode_out = dict_flag ? 2'b11 : 2'b00;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode_out   <= 2'b00;
            mode_valid <= 1'b0;
        end
    end
endmodule
