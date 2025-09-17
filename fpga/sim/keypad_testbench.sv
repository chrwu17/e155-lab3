// Christian Wu
// chrwu@g.hmc.edu
// 09/13/25

// This module is a testbench for the keypad decoder module. It tests all possible key presses
// and verifies that the correct key code is output. It also includes edge case tests to ensure
// robustness of the keypad decoder.

`timescale 1ns/1ps

module keypad_testbench();
    
    // Testbench signals
    logic [3:0] row;
    logic [3:0] col;
    logic [3:0] key;
    
    // Instantiate the keypad decoder
    keypad dut (
        .row(row),
        .col(col),
        .key(key)
    );
    
    // Main stimulus and test sequence
    initial begin
        
        // Test 1: Key '1' - Row 0 (0001), Col 0 (0001) -> 0001_0001
        row = 4'b1000; col = 4'b0001; #10;
        assert(key == 4'b0001) else $error("Key '1' failed: expected 4'b0001, got %b", key);
        
        // Test 2: Key '2' - Row 0 (1000), Col 1 (0010) -> 1000_0010
        row = 4'b1000; col = 4'b0010; #10;
        assert(key == 4'b0010) else $error("Key '2' failed: expected 4'b0010, got %b", key);
        
        // Test 3: Key '3' - Row 0 (1000), Col 2 (0100) -> 1000_0100
        row = 4'b1000; col = 4'b0100; #10;
        assert(key == 4'b0011) else $error("Key '3' failed: expected 4'b0011, got %b", key);
        
        // Test 4: Key 'C' - Row 0 (1000), Col 3 (1000) -> 1000_1000
        row = 4'b1000; col = 4'b1000; #10;
        assert(key == 4'b1100) else $error("Key 'C' failed: expected 4'b1100, got %b", key);
        
        // Test 5: Key '4' - Row 1 (0100), Col 0 (0001) -> 0100_0001
        row = 4'b0100; col = 4'b0001; #10;
        assert(key == 4'b0100) else $error("Key '4' failed: expected 4'b0100, got %b", key);
        
        // Test 6: Key '5' - Row 1 (0100), Col 1 (0010) -> 0100_0010
        row = 4'b0100; col = 4'b0010; #10;
        assert(key == 4'b0101) else $error("Key '5' failed: expected 4'b0101, got %b", key);
        
        // Test 7: Key '6' - Row 1 (0100), Col 2 (0100) -> 0100_0100
        row = 4'b0100; col = 4'b0100; #10;
        assert(key == 4'b0110) else $error("Key '6' failed: expected 4'b0110, got %b", key);
        
        // Test 8: Key 'D' - Row 1 (0100), Col 3 (1000) -> 0100_1000
        row = 4'b0100; col = 4'b1000; #10;
        assert(key == 4'b1101) else $error("Key 'D' failed: expected 4'b1101, got %b", key);
        
        // Test 9: Key '7' - Row 2 (0010), Col 0 (0001) -> 0010_0001
        row = 4'b0010; col = 4'b0001; #10;
        assert(key == 4'b0111) else $error("Key '7' failed: expected 4'b0111, got %b", key);
        
        // Test 10: Key '8' - Row 2 (0010), Col 1 (0010) -> 0010_0010
        row = 4'b0010; col = 4'b0010; #10;
        assert(key == 4'b1000) else $error("Key '8' failed: expected 4'b1000, got %b", key);
        
        // Test 11: Key '9' - Row 2 (0010), Col 2 (0100) -> 0010_0100
        row = 4'b0010; col = 4'b0100; #10;
        assert(key == 4'b1001) else $error("Key '9' failed: expected 4'b1001, got %b", key);
        
        // Test 12: Key 'E' - Row 2 (0010), Col 3 (1000) -> 0010_1000
        row = 4'b0010; col = 4'b1000; #10;
        assert(key == 4'b1110) else $error("Key 'E' failed: expected 4'b1110, got %b", key);
        
        // Test 13: Key 'A' - Row 3 (0001), Col 0 (0001) -> 0001_0001
        row = 4'b0001; col = 4'b0001; #10;
        assert(key == 4'b1010) else $error("Key 'A' failed: expected 4'b1010, got %b", key);
        
        // Test 14: Key '0' - Row 3 (0001), Col 1 (0010) -> 0001_0010
        row = 4'b0001; col = 4'b0010; #10;
        assert(key == 4'b0000) else $error("Key '0' failed: expected 4'b0000, got %b", key);
        
        // Test 15: Key 'B' - Row 3 (0001), Col 2 (0100) -> 0001_0100
        row = 4'b0001; col = 4'b0100; #10;
        assert(key == 4'b1011) else $error("Key 'B' failed: expected 4'b1011, got %b", key);
        
        // Test 16: Key 'F' - Row 3 (0001), Col 3 (1000) -> 0001_1000
        row = 4'b0001; col = 4'b1000; #10;
        assert(key == 4'b1111) else $error("Key 'F' failed: expected 4'b1111, got %b", key);
        
        // Edge Case Tests
        // Test 17: No key pressed
        row = 4'b0000; col = 4'b0000; #10;
        assert(key == 4'b1111) else $error("No key pressed failed: expected 4'b1111, got %b", key);
        
        // Test 18: Multiple rows active (invalid)
        row = 4'b0011; col = 4'b0001; #10;
        assert(key == 4'b1111) else $error("Multiple rows test failed: expected 4'b1111, got %b", key);
        
        // Test 19: Multiple columns active (invalid)
        row = 4'b0001; col = 4'b0011; #10;
        assert(key == 4'b1111) else $error("Multiple columns test failed: expected 4'b1111, got %b", key);
        
        // Test 20: Both multiple rows and columns (invalid)
        row = 4'b0011; col = 4'b0011; #10;
        assert(key == 4'b1111) else $error("Multiple rows and columns failed: expected 4'b1111, got %b", key);
        
        // Test 21: All ones (invalid)
        row = 4'b1111; col = 4'b1111; #10;
        assert(key == 4'b1111) else $error("All ones test failed: expected 4'b1111, got %b", key);

        // Test 22: Only one row high, no column high
        row = 4'b0001; col = 4'b0000; #10;
        assert(key == 4'b1111) else $error("Row high only failed: expected 4'b1111, got %b", key);
        
        // Test 23: Only one column high, no row high  
        row = 4'b0000; col = 4'b0001; #10;
        assert(key == 4'b1111) else $error("Column high only failed: expected 4'b1111, got %b", key);
        
        $display("\nAll tests successfully completed.");
        $stop;
    end
endmodule