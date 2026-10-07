`timescale 1ns/1ps

module global_clock_gate_controller (
    input  wire  clk,
    input  wire  rst,
    input  wire  enable,
    output wire  gated_clk
);

    assign gated_clk = enable ? clk : 1'b0;

endmodule
