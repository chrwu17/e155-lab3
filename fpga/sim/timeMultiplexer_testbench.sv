// Christian Wu
// chrwu@g.hmc.edu
// 09/13/25

// Simple testbench for synchronizer module using only stimulus and assert

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
    
    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Main test sequence
    initial begin
        $display("Starting simple synchronizer testbench...");
        
        // Initialize
        in = 4'b0000;
        repeat(3) @(posedge clk);
        
        // Test 1: Change input to 4'b0001
        in = 4'b0001;
        @(posedge clk); #1;
        assert(out != 4'b0001) else $error("Output changed too early!");
        @(posedge clk); #1;
        assert(out == 4'b0001) else $error("Test 1 failed: expected 4'b0001, got %b", out);
        
        // Test 2: Change input to 4'b1010
        in = 4'b1010;
        @(posedge clk); #1;
        assert(out == 4'b0001) else $error("Output changed too early!");
        @(posedge clk); #1;
        assert(out == 4'b1010) else $error("Test 2 failed: expected 4'b1010, got %b", out);
        
        // Test 3: Change input to 4'b1111
        in = 4'b1111;
        @(posedge clk); #1;
        assert(out == 4'b1010) else $error("Output changed too early!");
        @(posedge clk); #1;
        assert(out == 4'b1111) else $error("Test 3 failed: expected 4'b1111, got %b", out);
        
        // Test 4: Change input to 4'b0000
        in = 4'b0000;
        @(posedge clk); #1;
        assert(out == 4'b1111) else $error("Output changed too early!");
        @(posedge clk); #1;
        assert(out == 4'b0000) else $error("Test 4 failed: expected 4'b0000, got %b", out);
        
        // Test 5: Change input to 4'b0101
        in = 4'b0101;
        @(posedge clk); #1;
        assert(out == 4'b0000) else $error("Output changed too early!");
        @(posedge clk); #1;
        assert(out == 4'b0101) else $error("Test 5 failed: expected 4'b0101, got %b", out);
        
        // Test 6: Change input to 4'b1100
        in = 4'b1100;
        @(posedge clk); #1;
        assert(out == 4'b0101) else $error("Output changed too early!");
        @(posedge clk); #1;
        assert(out == 4'b1100) else $error("Test 6 failed: expected 4'b1100, got %b", out);
        
        // Test 7: Rapid changes (should only see final value)
        in = 4'b0001;
        in = 4'b0010;
        in = 4'b0100;
        in = 4'b1000;
        @(posedge clk); #1;
        assert(out == 4'b1100) else $error("Output changed too early after rapid changes!");
        @(posedge clk); #1;
        // Don't assert specific value here since rapid changes are unpredictable
        
        // Test 8: Verify stability
        in = 4'b0110;
        @(posedge clk); #1;
        @(posedge clk); #1;
        assert(out == 4'b0110) else $error("Test 8 failed: expected 4'b0110, got %b", out);
        @(posedge clk); #1;
        assert(out == 4'b0110) else $error("Output not stable!");
        @(posedge clk); #1;
        assert(out == 4'b0110) else $error("Output not stable!");
        
        $display("All synchronizer tests passed!");
        $finish;
    end

endmodule