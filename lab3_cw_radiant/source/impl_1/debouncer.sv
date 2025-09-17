// Christian Wu
// chrwu@g.hmc.edu
// 09/13/25

// This module is a debouncer for a single button input. It ensures that the output signal
// only changes state after the input signal has been stable for a specified duration,
// filtering out any noise or bouncing that may occur when the button is pressed or released.

module debouncer(
    input logic clk,
    input logic reset,
    input logic en_in,
    output logic en_out);

    logic [24:0] counter;
    logic en_prev;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            en_out <= 0;
            en_prev <= 0;
        end else begin
            if (en_in != en_prev) begin
                counter <= 0; // Reset counter if input changes
                en_prev <= en_in;
            end else if (counter < 48000) begin 
                counter <= counter + 1;
            end else begin
                en_out <= en_in; // Update output after stable period
            end
        end
    end
endmodule


