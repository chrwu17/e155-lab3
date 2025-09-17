// Christian Wu
// chrwu@g.hmc.edu
// 09/13/25

// This module is a testbench for the synchronizer module. It tests the functionality of the synchronizer
// by providing various asynchronous input patterns and verifying that the output is correctly synchronized
// to the clock domain.

`timescale 1ns/1ps

module synchronizer_testbench();
    
    // Testbench signals
    logic clk;
    logic [3:0] in;
    logic [3:0] out;
    
    // Instantiate the synchronizer
    synchronizer dut (
        .clk(clk),
        .in(in),
        .out(out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end
    
    // Main stimulus and test sequence
    initial begin
        
        // Test 1: Basic synchronization test
        in = 4'b0000; #7; // Asynchronous change
        assert(out == 4'b0000) else $error("Test 1 failed at time %t: expected 4'b0000, got %b", $time, out);
        #3; // Wait for clock edge
        assert(out == 4'b0000) else $error("Test 1 failed at time %t: expected 4'b0000, got %b", $time, out);
        
        in = 4'b1010; #7; // Asynchronous change
        assert(out == 4'b0000) else $error("Test 2 failed at time %t: expected 4'b0000, got %b", $time, out);
        #3; // Wait for clock edge
        assert(out == 4'b1010) else $error("Test 2 failed at time %t: expected 4'b1010, got %b", $time, out);
        
        in = 4'b1111; #7; // Asynchronous change
        assert(out == 4'b1010) else $error("Test 3 failed at time %t: expected 4'b1010, got %b", $time, out);
        #3; // Wait for clock edge
        assert(out == 4'b1111) else $error("Test 3 failed at time %t: expected 4'b1111, got %b", $time, out);
        
        in = 4'b0101; #7; // Asynchronous change
        assert(out == 4'b1111) else $error("Test 4 failed at time %t: expected 4'b1111, got %b", $time, out);
        #3; // Wait for clock edge
        assert(out == 4'b0101) else $error("Test 4 failed at time %t: expected 4'b0101, got %b", $time, out);

        // Test 5: Rapid changes
        in = 4'b0001; #2; // Asynchronous change
        in = 4'b0010; #2; // Asynchronous change
        in = 4'b0011; #2; // Asynchronous change
        in = 4'b0100; #2; // Asynchronous change
        assert(out == 4'b0101) else $error("Test 5 failed at time %t: expected 4'b0101, got %b", $time, out);
        #3; // Wait for clock edge
        assert(out == 4'b0001) else $error("Test 5 failed at time %t: expected 4'b0001, got %b", $time, out);
        #10; // Wait for next clock edge
        assert(out == 4'b0010) else $error("Test 5 failed at time %t: expected 4'b0010, got %b", $time, out);
        #10; // Wait for next clock edge
        assert(out == 4'b0011) else $error("Test 5 failed at time %t: expected 4'b0011, got %b", $time, out);
        #10; // Wait for next clock edge
        assert(out == 4'b0100) else $error("Test 5 failed at time %t: expected 4'b0100, got %b", $time, out);
        #10; // Wait for next clock edge
        assert(out == 4'b0100) else $error("Test 5 failed at time %t: expected 4'b0100, got %b", $time, out);

        $display("All tests successfully completed.");
        $stop;
    end 
endmodule

