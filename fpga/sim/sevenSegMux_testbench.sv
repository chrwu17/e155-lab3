// Christian Wu
// chrwu@g.hmc.edu
// 09/08/25

// This module tests the sevenSegMux module by inputing all combinations of s1, s2, and enable signals
// and checking if the output is as expected.

`timescale 1ns/1ps

module sevenSegMux_testbench();
    logic [3:0] s1, s2;
    logic enable;
    logic [3:0] out;
    sevenSegMux dut (.s1(s1), .s2(s2), .enable(enable), .out(out));

    integer i, j;
    integer errors = 0;
    integer test_cases = 0;
    logic [3:0] expected_out;

    initial begin
        // Test all combinations of 4-bit inputs and enable signal
        for (i = 0; i < 16; i++) begin
            for (j = 0; j < 16; j++) begin
                s1 = i[3:0];
                s2 = j[3:0];

                // Test with enable = 0
                enable = 0;
                #10; 
                test_cases++;
                expected_out = s1;
                assert (out === expected_out)
                    else $error("ASSERTION FAILED: s1=%0d, s2=%0d, enable=0, expected out=%0d, got out=%0d", s1, s2, expected_out, out);

                // Test with enable = 1
                enable = 1;
                #10; 
                test_cases++;
                expected_out = s2;
                assert (out === expected_out)
                    else $error("ASSERTION FAILED: s1=%0d, s2=%0d, enable=1, expected out=%0d, got out=%0d", s1, s2, expected_out, out);
            end
        end

        $display("All %0d test cases successfully completed.", test_cases);
        $stop;
    end
    endmodule