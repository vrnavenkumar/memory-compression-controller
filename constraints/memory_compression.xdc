module memory_compression_tb;

    reg        clk;
    reg        rst;
    reg [127:0] data_in;
    reg        valid_in;
    reg [1:0]  app_hint;

    wire [1:0] selected_mode;
    wire [127:0] compressed_data;
    wire        compressed_valid;
    wire [127:0] decompressed_data;
    wire        decompressed_valid;

    memory_compression_top uut (
        .clk                 (clk),
        .rst                 (rst),
        .data_in             (data_in),
        .valid_in            (valid_in),
        .app_hint            (app_hint),
        .selected_mode       (selected_mode),
        .compressed_data_out (compressed_data),
        .compressed_valid    (compressed_valid),
        .decompressed_data_out(decompressed_data),
        .decompressed_valid  (decompressed_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        valid_in = 0;
        app_hint = 2'b00;
        data_in = 128'h00000000_00000000_00000000_00000000;

        #20;
        rst = 0;

        // Test 1: bypass mode
        app_hint = 2'b00;
        data_in = 128'h11223344_55667788_99AABBCC_DDEEFF00;
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;

        // Test 2: run-length / repeated data
        app_hint = 2'b01;
        data_in = 128'hAAAAAAAA_BBBBBBBB_CCCCCCCC_DDDDDDDD;
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #20;

        // Test 3: delta-like stream
        app_hint = 2'b10;
        data_in = 128'h00000010_00000020_00000030_00000040;
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #30;

        $display("mode=%b comp_valid=%b decomp_valid=%b", selected_mode, compressed_valid, decompressed_valid);
        $display("compressed=%h", compressed_data);
        $display("decompressed=%h", decompressed_data);
        $finish;
    end
endmodule
