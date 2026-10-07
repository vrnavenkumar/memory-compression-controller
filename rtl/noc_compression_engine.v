`timescale 1ns/1ps

module noc_compression_engine (
    input  wire        clk,
    input  wire        rst,

    input  wire [511:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,

    input  wire [511:0] m_axis_tdata,
    input  wire        m_axis_tvalid,
    output wire        m_axis_tready,

    output wire [127:0] noc_tx_tdata,
    output wire        noc_tx_tvalid,
    input  wire        noc_tx_tready,

    input  wire [127:0] noc_rx_tdata,
    input  wire        noc_rx_tvalid,
    output wire        noc_rx_tready,

    input  wire [31:0] apb_paddr,
    input  wire        apb_pwrite,
    input  wire [31:0] apb_pwdata,
    input  wire        apb_psel,
    input  wire        apb_penable,
    output reg  [31:0] apb_prdata,
    output reg         apb_pready,

    output wire [1:0]  mode_sel,
    output wire [15:0] congestion_count,
    output wire        comp_valid,
    output wire        decomp_valid
);

    localparam MODE_BYPASS = 2'b00;
    localparam MODE_DELTA  = 2'b01;
    localparam MODE_RLE    = 2'b10;
    localparam MODE_DICT   = 2'b11;

    reg [31:0] cfg_threshold;
    reg [31:0] cfg_window;
    reg [7:0]  cfg_mode;
    reg        cfg_enable;
    reg        cfg_irq_enable;

    reg [7:0]  tx_packet_len;
    reg [15:0] tx_count;
    reg [15:0] congestion_val;

    wire [31:0] zero_word_count;
    wire [31:0] max_delta_width;
    wire [31:0] feature_valid;
    wire [1:0]  predicted_mode;
    wire        pred_valid;

    wire [127:0] tx_payload;
    wire        tx_payload_valid;
    wire [7:0]  tx_payload_len;

    wire [127:0] rx_payload;
    wire        rx_payload_valid;

    feature_extractor u_feature_extractor (
        .clk      (clk),
        .rst      (rst),
        .din      (s_axis_tdata),
        .valid_in (s_axis_tvalid),
        .zero_word_count(zero_word_count),
        .max_delta_width(max_delta_width),
        .feature_valid(feature_valid)
    );

    mode_predictor_fsm u_mode_predictor (
        .clk           (clk),
        .rst           (rst),
        .zero_word_cnt (zero_word_count),
        .max_delta_w   (max_delta_width),
        .congestion    (congestion_val),
        .threshold     (cfg_threshold),
        .mode_out      (predicted_mode),
        .mode_valid    (pred_valid)
    );

    unified_compression_core u_comp_core (
        .clk        (clk),
        .rst        (rst),
        .mode_in    (predicted_mode),
        .din        (s_axis_tdata),
        .din_valid  (s_axis_tvalid),
        .cfg_enable (cfg_enable),
        .dout       (tx_payload),
        .dout_valid (tx_payload_valid),
        .dout_len   (tx_payload_len)
    );

    tx_output_buffer u_tx_buf (
        .clk         (clk),
        .rst         (rst),
        .din         (tx_payload),
        .din_valid   (tx_payload_valid),
        .din_len     (tx_payload_len),
        .noc_ready   (noc_tx_tready),
        .noc_tdata   (noc_tx_tdata),
        .noc_tvalid  (noc_tx_tvalid)
    );

    rx_input_depacketizer u_rx_decode (
        .clk          (clk),
        .rst          (rst),
        .noc_tdata    (noc_rx_tdata),
        .noc_tvalid   (noc_rx_tvalid),
        .noc_tready   (noc_rx_tready),
        .rx_payload   (rx_payload),
        .rx_valid     (rx_payload_valid)
    );

    congestion_monitor u_congestion_monitor (
        .clk             (clk),
        .rst             (rst),
        .tx_valid        (noc_tx_tvalid),
        .rx_valid        (noc_rx_tvalid),
        .credit_status   (noc_tx_tready),
        .congestion_count(congestion_count),
        .congestion_val  (congestion_val)
    );

    flow_control_credit_mgr u_flow_mgr (
        .clk              (clk),
        .rst              (rst),
        .tx_req           (noc_tx_tvalid),
        .tx_grant         (noc_tx_tready),
        .credit_limit     (cfg_window),
        .credit_count     (),
        .credit_available ()
    );

    global_clock_gate_controller u_clock_gate (
        .clk        (clk),
        .rst        (rst),
        .enable     (cfg_enable),
        .gated_clk  ()
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cfg_threshold <= 32'd64;
            cfg_window    <= 32'd128;
            cfg_mode      <= 8'd0;
            cfg_enable    <= 1'b1;
            cfg_irq_enable<= 1'b0;
            tx_count      <= 16'd0;
            apb_pready    <= 1'b1;
            apb_prdata    <= 32'd0;
        end else begin
            if (apb_psel && apb_penable && apb_pwrite) begin
                case (apb_paddr[7:0])
                    8'h00: cfg_threshold <= apb_pwdata;
                    8'h04: cfg_window    <= apb_pwdata;
                    8'h08: cfg_mode      <= apb_pwdata[7:0];
                    8'h0C: cfg_enable    <= apb_pwdata[0];
                    8'h10: cfg_irq_enable<= apb_pwdata[0];
                    default: ;
                endcase
            end

            if (apb_psel && apb_penable && !apb_pwrite) begin
                case (apb_paddr[7:0])
                    8'h00: apb_prdata <= cfg_threshold;
                    8'h04: apb_prdata <= cfg_window;
                    8'h08: apb_prdata <= {24'd0, cfg_mode};
                    8'h0C: apb_prdata <= {31'd0, cfg_enable};
                    8'h10: apb_prdata <= {31'd0, cfg_irq_enable};
                    default: apb_prdata <= 32'd0;
                endcase
            end

            if (tx_payload_valid)
                tx_count <= tx_count + 1;
        end
    end

    assign mode_sel      = predicted_mode;
    assign comp_valid    = tx_payload_valid;
    assign decomp_valid  = rx_payload_valid;
    assign s_axis_tready = 1'b1;
    assign m_axis_tready = 1'b1;

endmodule
