// Christian Wu
// chrwu@g.hmc.edu
// 09/15/25

// This module is a testbench for the sevenSegDigits module. It tests the digit storage
// and shifting functionality with proper timing for synchronous reset and enable signals.

`timescale 1ns / 1ps

module sevenSegDigits_testbench();
    
    logic clk;
    logic reset;
    logic en;
    logic [3:0] key;
    logic [3:0] s1, s2;
    
    int test_count = 0;
    logic [3:0] s1_before, s2_before; // keep these at module scope
    
    initial clk = 0;
    always #10 clk = ~clk;
    
    sevenSegDigits dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .key(key),
        .s1(s1),
        .s2(s2)
    );
    
    initial begin
        
        reset = 1;
        en = 0;
        key = 4'h0;
        
        @(posedge clk);
        @(posedge clk); 
        
        // Test 1: Reset behavior
        test_count++;
        assert (s1 == 4'h0 && s2 == 4'h0) else
            $error("Test %0d FAILED: Reset should set both digits to 0. Got s1=%h, s2=%h", test_count, s1, s2);
        
        // Release reset and wait a posedge for stable operation
        reset = 0;
        @(posedge clk);
        
        // Test 2: First key press
        test_count++;
        key = 4'h5; en = 1;
        @(posedge clk); en = 0;      
        @(posedge clk);             
        assert (s1 == 4'h0 && s2 == 4'h5) else
            $error("Test %0d FAILED: First key should be s1=0, s2=5. Got s1=%h, s2=%h", test_count, s1, s2);
        
        // Test 3: Second key press
        test_count++;
        key = 4'hA; en = 1;
        @(posedge clk); en = 0;
        @(posedge clk);
        assert (s1 == 4'h5 && s2 == 4'hA) else
            $error("Test %0d FAILED: Second key should be s1=5, s2=A. Got s1=%h, s2=%h", test_count, s1, s2);
        
        // Test 4: Third key press
        test_count++;
        key = 4'hF; en = 1;
        @(posedge clk); en = 0;
        @(posedge clk);
        assert (s1 == 4'hA && s2 == 4'hF) else
            $error("Test %0d FAILED: Third key should be s1=A, s2=F. Got s1=%h, s2=%h", test_count, s1, s2);
        
        // Test 5: Enable held high (keep key stable while en is high)
        test_count++;
        key = 4'h7;
        en = 1;
        @(posedge clk);
        @(posedge clk); 
        @(posedge clk); 
        en = 0;
        @(posedge clk);
        assert (s1 == 4'hF && s2 == 4'h7) else
            $error("Test %0d FAILED: Enable high should only update once. Got s1=%h, s2=%h", test_count, s1, s2);
        
        // Test 6: No enable (change key while en==0)
        test_count++;
        s1_before = s1;
        s2_before = s2;
        key = 4'h9;   
        @(posedge clk);    
        @(posedge clk);
        assert (s1 == s1_before && s2 == s2_before) else
            $error("Test %0d FAILED: No enable should not update. Got s1=%h, s2=%h, expected s1=%h, s2=%h", 
                   test_count, s1, s2, s1_before, s2_before);
        
        // Test 7: All hex digits
        test_count++;
        for (int i = 0; i < 16; i++) begin
            key = i[3:0]; en = 1;
            @(posedge clk); en = 0; @(posedge clk); 
            assert (s2 == i[3:0]) else
                $error("Hex test FAILED: Key %h not stored correctly. Got s2=%h", i[3:0], s2);
        end
        
        $display("All %0d tests completed successfully", test_count);
        $stop;
    end
    
    // Continuous assertions - only check when not in reset and outputs are not X
    always @(posedge clk) begin
        if (!reset && s1 !== 4'bxxxx && s2 !== 4'bxxxx) begin
            assert (s1 <= 4'hF && s2 <= 4'hF) else
                $error("ASSERTION: Outputs should be valid hex (0-F). Got s1=%h, s2=%h", s1, s2);
        end
    end
    
    // Safety timeout
    initial begin
        #50000; // 50us timeout
        $display("Testbench timeout");
        $finish;
    end
    
endmodule
