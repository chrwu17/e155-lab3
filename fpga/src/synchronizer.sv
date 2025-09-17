// Christian Wu
// chrwu@g.hmc.edu
// 09/13/25

// This module is a simple two-stage synchronizer to safely bring an asynchronous input signal
// into the clock domain of the provided clock signal. This helps to prevent metastability issues.

module synchronizer (
    input logic clk,
    input logic reset,
    input logic [3:0] in,
    output logic [3:0] out);

    logic [3:0] mid;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mid <= 4'b0000;
            out <= 4'b0000;
        end else begin
        mid <= in;
        out <= mid;
    end
    end
endmodule
