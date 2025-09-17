`timescale 1ns / 1ps

module keypadFSM_testbench();
    
    // Signals
    logic clk;
    logic reset;
    logic [3:0] col;
    logic [3:0] row;
    logic [7:0] rc;
    logic en;
    
    // Clock - 48MHz
    always #10.416 clk = ~clk;
    
    // Instantiate FSM
    keypadFSM dut (
        .clk(clk),
        .reset(reset),
        .col(col),
        .row(row),
        .rc(rc),
        .en(en)
    );
    
    // Main test sequence
    initial begin
        $display("Starting keypadFSM testbench");
        clk = 0;
        
        // Test 1: Reset functionality
        $display("\n=== Test 1: Reset ===");
        reset = 1'b1;
        col = 4'b1111;
        #100;
        reset = 1'b0;
        #100;
        assert(row != 4'b0000) else $error("Row outputs should not be all zero after reset");
        $display("PASS: Reset test");
        
        // Test 2: Single key press R0C0 (key 'A')
        $display("\n=== Test 2: Press R0C0 (key A) ===");
        wait (row == 4'b1110);
        col = 4'b1110;
        wait (en == 1'b1);
        assert(rc == 8'b1110_1110) else $error("RC mismatch: got %b, expected 11101110", rc);
        col = 4'b1111;
        #1000;
        $display("PASS: R0C0 key press");
        
        // Test 3: Different key R1C2 (key '5') 
        $display("\n=== Test 3: Press R1C2 (key 5) ===");
        wait (row == 4'b1101);
        col = 4'b1011;
        wait (en == 1'b1);
        assert(rc == 8'b1101_1011) else $error("RC mismatch: got %b, expected 11011011", rc);
        col = 4'b1111;
        #1000;
        $display("PASS: R1C2 key press");
        
        // Test 4: Key R2C1 (key '4')
        $display("\n=== Test 4: Press R2C1 (key 4) ===");
        wait (row == 4'b1011);
        col = 4'b1101;
        wait (en == 1'b1);
        assert(rc == 8'b1011_1101) else $error("RC mismatch: got %b, expected 10111101", rc);
        col = 4'b1111;
        #1000;
        $display("PASS: R2C1 key press");
        
        // Test 5: Multiple keys pressed (should be ignored)
        $display("\n=== Test 5: Multiple keys (should be ignored) ===");
        wait (row == 4'b1110);
        col = 4'b1100; // Two keys pressed
        #10000; // Wait long enough for debounce
        assert(en == 1'b0) else $error("Multiple keys should not generate enable");
        col = 4'b1111;
        #1000;
        $display("PASS: Multiple keys ignored");
        
        // Test 6: No keys pressed
        $display("\n=== Test 6: No keys pressed ===");
        col = 4'b1111;
        #5000;
        assert(en == 1'b0) else $error("No keys should not generate enable");
        $display("PASS: No keys test");
        
        $display("\n=== All tests completed successfully ===");
        $finish;
    end
    
    // Safety timeout
    initial begin
        #200000; // 200us timeout
        $error("Testbench timeout - test took too long");
        $finish;
    end
    
endmodule