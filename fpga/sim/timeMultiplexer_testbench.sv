// Christian Wu
// chrwu@g.hmc.edu
// 09/08/25

// This module tests the timeMultiplexer module by simulating clock cycles and checking if the an1, an2, and signal outputs
// toggle correctly based on the internal counter.

// timeMultiplexer_simple_tb.sv
// Simple testbench focusing only on an1 and an2 switching behavior

`timescale 1ns / 1ps

module timeMultiplexer_testbench();
    logic clk;
    logic reset;
    logic an1, an2;
    logic signal;
    
    timeMultiplexer dut (.clk(clk), .reset(reset), .an1(an1), .an2(an2), .signal(signal));
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end
    
    // Test sequence
    initial begin
        repeat(10) begin
            @(posedge signal or negedge signal);
            #1;
        end
        
        $display("Test completed successfully.");
        $stop;
    end
    
    // Assert statements for anode behavior
    always @(*) begin
        // Assert anodes are always opposite (mutually exclusive)
        assert (an1 !== an2)
        else $error("Anodes not mutually exclusive: an1=%b, an2=%b", an1, an2);
        
        // Assert correct anode control based on signal
        assert (signal ? (an1 == 1 && an2 == 0) : (an1 == 0 && an2 == 1))
        else $error("Incorrect anode control: signal=%b, an1=%b, an2=%b", signal, an1, an2);
        
        // Assert only one display is active at a time (one anode is 0)
        assert ((an1 == 0) ^ (an2 == 0))
        else $error("Neither or both displays active: an1=%b, an2=%b", an1, an2);
    end
    
endmodule