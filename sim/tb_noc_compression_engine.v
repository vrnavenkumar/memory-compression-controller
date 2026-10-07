`timescale 1ns/1ps

module tb_noc_compression_engine;

    reg        clk;
    reg        rst;
    reg [511:0] s_axis_tdata;
    reg        s_axis_tvalid;
    wire       s_axis_tready;

    reg [127:0] noc_rx_tdata;
    reg        noc_rx_tvalid;
    wire       noc_rx_tready;

    wire [127:0] noc_tx_tdata;
    wire        noc_tx_tvalid;
    wire        noc_tx_tready;

    wire [1:0]  mode_sel;
    wire [15:0] congestion_count;
    wire        comp_valid;
    wire        decomp_valid;

    noc_compression_engine dut (
        .clk              (clk),
        .rst              (rst),
        .s_axis_tdata     (s_axis_tdata),
        .s_axis_tvalid    (s_axis_tvalid),
        .s_axis_tready    (s_axis_tready),
        .m_axis_tdata     (128'd0),
        .m_axis_tvalid    (1'b0),
        .m_axis_tready    (),
        .noc_tx_tdata     (noc_tx_tdata),
        .noc_tx_tvalid    (noc_tx_tvalid),
        .noc_tx_tready    (noc_tx_tready),
        .noc_rx_tdata     (noc_rx_tdata),
        .noc_rx_tvalid    (noc_rx_tvalid),
        .noc_rx_tready    (noc_rx_tready),
        .apb_paddr        (32'd0),
        .apb_pwrite       (1'b0),
        .apb_pwdata       (32'd0),
        .apb_psel         (1'b0),
        .apb_penable      (1'b0),
        .apb_prdata       (),
        .apb_pready       (),
        .mode_sel         (mode_sel),
        .congestion_count (congestion_count),
        .comp_valid       (comp_valid),
        .decomp_valid     (decomp_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        s_axis_tdata = 512'h0;
        s_axis_tvalid = 1'b0;
        noc_rx_tdata = 128'd0;
        noc_rx_tvalid = 1'b0;

        #20;
        rst = 0;
        #10;

        s_axis_tdata = 512'h11223344_55667788_99AABBCC_DDEEFF00_00112233_44556677_8899AABB_CCDDFF00;
        s_axis_tvalid = 1'b1;
        #10;

        s_axis_tvalid = 1'b0;
        #20;

        s_axis_tdata = 512'h00000001_00000002_00000003_00000004_00000005_00000006_00000007_00000008;
        s_axis_tvalid = 1'b1;
        #10;

        s_axis_tvalid = 1'b0;
        #50;

        noc_rx_tdata = noc_tx_tdata;
        noc_rx_tvalid = noc_tx_tvalid;
        #20;

        $display("Simulation complete");
        $display("mode=%b comp_valid=%b decomp_valid=%b congestion=%d", mode_sel, comp_valid, decomp_valid, congestion_count);
        $finish;
    end

endmodule
