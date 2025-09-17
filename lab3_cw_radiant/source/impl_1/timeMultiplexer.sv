//  timeMultiplexer.sv
//  Christian Wu
//  chrwu@g.hmc.edu
//  09/06/25

// This module takes in two four bit inputs, s1 and s2, and switches between them to drive a dual seven
// segment display, to utilize only one sevenSegmentDisplay module. The switching is done at a rate fast enough
// such that the human eye cannot detect the switching, and it appears that both displays are on at the same time.

module timeMultiplexer (
    input clk,
    output logic an1, an2,
    output logic signal);

    logic [24:0] counter = 0;

    always_ff @(posedge clk) begin
        counter <= counter + 1;
        if (counter == 48000) begin
            counter <= 0;
            signal <= ~signal; 
            if (~signal) begin
                an1 <= 1; // turn off an1
                an2 <= 0; // turn on an2
            end else begin
                an1 <= 0; // turn on an1
                an2 <= 1; // turn off an2
            end

    end
    end
endmodule