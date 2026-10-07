`timescale 1ns/1ps

module congestion_monitor (
    input  wire        clk,
    input  wire        rst,
    input  wire        tx_valid,
    input  wire        rx_valid,
    input  wire        credit_status,

    output reg [15:0] congestion_count,
    output reg [15:0] congestion_val
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            congestion_count <= 16'd0;
            congestion_val   <= 16'd0;
        end else begin
            if (!credit_status) begin
                congestion_count <= congestion_count + 1;
            end

            if (tx_valid && !rx_valid) begin
                congestion_val <= congestion_val + 1;
            end else if (tx_valid && rx_valid) begin
                congestion_val <= congestion_val;
            end
        end
    end
endmodule
