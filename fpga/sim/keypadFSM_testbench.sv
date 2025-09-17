// Christian Wu
// chrwu@g.hmc.edu
// 09/17/25

// Testbench for keypadFSM module

`timescale 1ns/1ps

module keypadFSM_testbench();

    // Signals
    logic clk;
    logic reset;
    logic [3:0] col;
    logic [3:0] row;
    logic [7:0] rc;
    logic en;

    // Instantiate DUT
    keypadFSM dut (
        .clk(clk),
        .reset(reset),
        .col(col),
        .row(row),
        .rc(rc),
        .en(en)
    );

    // Clock: 50 MHz
    initial clk = 0;
    always #10 clk = ~clk;

    integer i;
    logic en_seen;
    logic [3:0] expected_col;

    initial begin
        reset = 1;
        col = 4'b0000;
        repeat (5) @(posedge clk);
        reset = 0;

        // Wait a few FSM ticks
        for (i = 0; i < 2*48_000; i = i + 1) @(posedge clk);

        // --- Test Case 1: Row0, Col0 ---
        col = 4'b0001;
        expected_col = 4'b0001;
        en_seen = 0;

        // Hold key long enough (> debounce)
        for (i = 0; i < 150*48_000; i = i + 1) begin
            @(posedge clk);
            if (en) begin
                en_seen = 1;
                // Check only column bits
                if (rc[3:0] !== expected_col)
                    $error("Error: column mismatch in Test Case 1! Expected %b, got %b", expected_col, rc[3:0]);
                // Check row is one-hot
                if (^rc[7:4] !== 1'b1)
                    $error("Error: row not one-hot in Test Case 1! rc[7:4]=%b", rc[7:4]);
            end
        end
        col = 4'b0000;
        if (!en_seen) $error("Error: en not asserted in Test Case 1");

        // --- Test Case 2: Row1, Col2 ---
        col = 4'b0100;
        expected_col = 4'b0100;
        en_seen = 0;

        for (i = 0; i < 150*48_000; i = i + 1) begin
            @(posedge clk);
            if (en) begin
                en_seen = 1;
                if (rc[3:0] !== expected_col)
                    $error("Error: column mismatch in Test Case 2! Expected %b, got %b", expected_col, rc[3:0]);
                if (^rc[7:4] !== 1'b1)
                    $error("Error: row not one-hot in Test Case 2! rc[7:4]=%b", rc[7:4]);
            end
        end
        col = 4'b0000;
        if (!en_seen) $error("Error: en not asserted in Test Case 2");

        // --- Test Case 3: Multiple keys (ignored) ---
        col = 4'b0011;
        en_seen = 0;

        for (i = 0; i < 50*48_000; i = i + 1) begin
            @(posedge clk);
            if (en) en_seen = 1;
        end
        if (en_seen)
            $error("Error: en asserted with multiple keys in Test Case 3");
        col = 4'b0000;

        $display("All tests completed successfully.");
        $stop;
    end

endmodule
