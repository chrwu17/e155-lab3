// lab3_cw_tb.sv
// Working testbench for lab3_cw module

`timescale 1ns / 1ps

module lab3_cw_testbench();

    // Testbench signals
    logic reset;
    logic [3:0] col;
    logic [3:0] row;
    logic [6:0] seg;
    logic an1, an2;
    logic clk_tb;
    
    // Generate 48MHz clock
    initial begin
        clk_tb = 0;
        forever #10.416 clk_tb = ~clk_tb;  // 48MHz = 20.833ns period
    end
    
    // Instantiate DUT with testbench clock
    lab3_cw dut (
        .reset(reset),
        .col(col),
        .row(row),
        .seg(seg),
        .an1(an1),
        .an2(an2)
    );
    
    // Test sequence
    initial begin
        // Initialize
        reset = 1;
        col = 4'b1111; // No keys pressed
        
        // Reset
        #1000;
        reset = 0;
        #10000; // Let FSM start scanning
        
        // Test key '5' (row=1, col=1) -> should decode to 4'b0101
        $display("Pressing key '5'");
        wait(row[1] == 0); // Wait for row 1 scan
        #200;
        col[1] = 0; // Press key
        #100000; // Hold 100us > 50us debounce
        col[1] = 1; // Release
        #50000;
        
        // Test key '1' (row=1, col=3) -> should decode to 4'b0001  
        $display("Pressing key '1'");
        wait(row[1] == 0);
        #200;
        col[3] = 0;
        #100000;
        col[3] = 1;
        #50000;
        
        // Test key 'A' (row=0, col=3) -> should decode to 4'b1010
        $display("Pressing key 'A'");
        wait(row[0] == 0);
        #200;
        col[3] = 0;
        #100000;
        col[3] = 1;
        #50000;
        
        // Test reset
        $display("Testing reset");
        reset = 1;
        #1000;
        reset = 0;
        #50000;
        
        // Run long enough to see multiplexer
        #2000000; // 2ms
        
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time=%t: reset=%b, row=%b, col=%b, seg=%b, an1=%b, an2=%b", 
                 $time, reset, row, col, seg, an1, an2);
    end

endmodule