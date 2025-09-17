// Christian Wu
// chrwu@g.hmc.edu
// 09/17/25

// testbench for synchronizer 

`timescale 1ns/1ps

module synchronizer_testbench;

    logic clk;
    logic reset;
    logic [3:0] in;
    logic [3:0] out;

    // DUT instantiation
    synchronizer dut (
        .clk   (clk),
        .reset (reset),
        .in    (in),
        .out   (out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize
        reset = 1;
        in = 4'b0000;
        #12;
        reset = 0;

        // --- Step 1 ---
        @(posedge clk); in = 4'b1010;
        @(posedge clk);        
        @(posedge clk); 
        @(posedge clk);  
        assert(out === 4'b1010) else $error("Step 1 failed: out=%b", out);

        // --- Step 2 ---
        @(posedge clk); in = 4'b1111;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        assert(out === 4'b1111) else $error("Step 2 failed: out=%b", out);

        // --- Step 3 ---
        @(posedge clk); in = 4'b0101;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        assert(out === 4'b0101) else $error("Step 3 failed: out=%b", out);

        $display("All steps completed successfully");
        $finish;
    end

endmodule
