//  timeMultiplexer.sv
//  Christian Wu
//  chrwu@g.hmc.edu
//  09/06/25

// This module takes in two four bit inputs, s1 and s2, and switches between them to drive a dual seven
// segment display, to utilize only one sevenSegmentDisplay module. The switching is done at a rate fast enough
// such that the human eye cannot detect the switching, and it appears that both displays are on at the same time.

module timeMultiplexer (
    input clk,
    input logic reset,
    output logic an1, 
    output logic an2,
    output logic signal);

    logic [24:0] counter;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            signal <= 0;
            an1 <= 1;    // Start with left display on
            an2 <= 0;   // Right display off
        end else begin
        counter <= counter + 1;
        
        // Timing to determine when the left and right seven segment should be on
        if(counter == 48000) begin
            counter <= 0;
            signal <= ~signal;
            
            // Assign an1 and an2 so that one is off while the other is on
            an1 <= ~signal;      // Left display control
            an2 <= signal;     // Right display control
        end
        end
    end
endmodule