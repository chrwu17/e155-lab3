// Christian Wu
// chrwu@g.hmc.edu
// 09/08/25

// This module tests the sevenSegmentDisplay module by simulating all four-bit inputs
// and checking the output against the expected seven-segment display output.

`timescale 1ns/1ps

module sevenSegmentDisplay_testbench();
    logic [3:0] s;
    logic [6:0] seg;
    sevenSegmentDisplay dut (.s(s), .seg(seg));

    logic [6:0] expected_seg;
    integer i;
    integer test_cases = 0;

    // Function to get the expected seven-segment output for a given 4-bit input
    logic [6:0] get_expected_seg [16] = {
        7'b1000000, // 0
        7'b1111001, // 1
        7'b0100100, // 2
        7'b0110000, // 3
        7'b0011001, // 4
        7'b0010010, // 5
        7'b0000010, // 6
        7'b1111000, // 7
        7'b0000000, // 8
        7'b0010000, // 9
        7'b0001000, // A
        7'b0000011, // b
        7'b1000110, // C
        7'b0100001, // d
        7'b0000110, // E
        7'b0001110  // F
    };

    initial begin
        // Test all combinations of 4-bit inputs
        for (i = 0; i < 16; i++) begin
            s = i[3:0];
            expected_seg = get_expected_seg[s];
            #1; // wait for combinational logic to settle
            test_cases++;
            assert (seg === expected_seg)
                else $error("ASSERTION FAILED: s=%0d, expected seg=%b, got seg=%b", s, expected_seg, seg);
        end
        $display("All %0d test cases completed.", test_cases);
        $stop;
    end
endmodule