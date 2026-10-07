`timescale 1ns/1ps

module flow_control_credit_mgr (
    input  wire        clk,
    input  wire        rst,
    input  wire        tx_req,
    input  wire        tx_grant,
    input  wire [31:0] credit_limit,

    output reg  [31:0] credit_count,
    output reg         credit_available
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            credit_count     <= credit_limit;
            credit_available <= 1'b1;
        end else begin
            if (tx_req && tx_grant) begin
                if (credit_count > 0)
                    credit_count <= credit_count - 1;
            end

            credit_available <= (credit_count > 0);
        end
    end
endmodule
