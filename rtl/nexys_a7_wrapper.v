`timescale 1ns/1ps

module nexys_a7_wrapper (
    input  wire        clk_100mhz,
    input  wire        cpu_reset,
    input  wire [15:0] sw,
    output reg  [15:0] led
);

    reg [31:0] counter;
    reg [511:0] data_word;
    reg         valid_in;
    wire [1:0]  mode_out;
    wire [127:0] comp_data;
    wire        comp_valid;
    wire [127:0] decomp_data;
    wire        decomp_valid;
    wire [15:0] congestion;

    noc_compression_engine u_core (
        .clk               (clk_100mhz),
        .rst               (cpu_reset),
        .s_axis_tdata      (data_word),
        .s_axis_tvalid     (valid_in),
        .s_axis_tready     (),
        .m_axis_tdata      (128'd0),
        .m_axis_tvalid     (1'b0),
        .m_axis_tready     (),
        .noc_tx_tdata      (comp_data),
        .noc_tx_tvalid     (comp_valid),
        .noc_tx_tready     (1'b1),
        .noc_rx_tdata      (128'd0),
        .noc_rx_tvalid     (1'b0),
        .noc_rx_tready     (),
        .apb_paddr         (32'd0),
        .apb_pwrite        (1'b0),
        .apb_pwdata        (32'd0),
        .apb_psel          (1'b0),
        .apb_penable       (1'b0),
        .apb_prdata        (),
        .apb_pready        (),
        .mode_sel          (mode_out),
        .congestion_count  (congestion),
        .comp_valid        (),
        .decomp_valid      (decomp_valid)
    );

    always @(posedge clk_100mhz or posedge cpu_reset) begin
        if (cpu_reset) begin
            counter    <= 32'd0;
            data_word  <= 512'd0;
            valid_in   <= 1'b0;
            led        <= 16'd0;
        end else begin
            counter <= counter + 32'd1;

            data_word <= {
                counter + 32'd15, counter + 32'd14, counter + 32'd13, counter + 32'd12,
                counter + 32'd11, counter + 32'd10, counter + 32'd9,  counter + 32'd8,
                counter + 32'd7,  counter + 32'd6,  counter + 32'd5,  counter + 32'd4,
                counter + 32'd3,  counter + 32'd2,  counter + 32'd1,  counter
            };

            valid_in <= 1'b1;

            led[1:0]   <= mode_out;
            led[2]     <= comp_valid;
            led[3]     <= decomp_valid;
            led[15:4]  <= congestion[11:0];
        end
    end
endmodule
