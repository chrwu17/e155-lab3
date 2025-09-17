// Christian Wu
// chrwu@g.hmc.edu
// 09/17/25

// Testbench for lab3_cw

`timescale 1ns/1ps

module lab3_cw_testbench(); 
    logic clk;
    logic resetInv;  
    logic [3:0] col;
    logic [3:0] row;
    logic an1, an2;
    logic [6:0] seg;

    lab3_cw dut(.resetInv(resetInv), .col(col), .row(row), .seg(seg), .an1(an1), .an2(an2));

    always begin
        clk = 0; #10.42;  // ~48MHz clock period
        clk = 1; #10.42;
    end

    initial begin
        resetInv = 0; #100;  
        resetInv = 1;    
    end
    
    initial begin
        col = 4'b0000;
        
        wait(resetInv == 1);
        #1_000_000;  // 1ms delay
        
        $display("Starting keypad test sequence...");
        
        // Test Key 1: Row 0 (4'b0001), Col 0 (4'b0001)
        wait(row == 4'b0001);  
        #1000;
        col = 4'b0001;
        $display("Time %0t: Pressing key 1 - Row: %b, Col: %b", $time, row, col);
        #60_000_000;  
        col = 4'b0000;
        $display("Time %0t: Released key 1", $time);
        #10_000_000;
        
        // Test Key 2: Row 0 (4'b0001), Col 1 (4'b0010)
        wait(row == 4'b0001);  
        #1000;
        col = 4'b0010;
        $display("Time %0t: Pressing key 2 - Row: %b, Col: %b", $time, row, col);
        #60_000_000; 
        col = 4'b0000;
        $display("Time %0t: Released key 2", $time);
        #10_000_000;
        
        // Test Key 3: Row 0 (4'b0001), Col 2 (4'b0100)
        wait(row == 4'b0001);  
        #1000;
        col = 4'b0100;
        $display("Time %0t: Pressing key 3 - Row: %b, Col: %b", $time, row, col);
        #60_000_000;
        col = 4'b0000;
        $display("Time %0t: Released key 3", $time);
        #10_000_000;
        
        // Test Key A: Row 3 (4'b1000), Col 0 (4'b0001)
        wait(row == 4'b1000);  
        #1000;
        col = 4'b0001;
        $display("Time %0t: Pressing key A - Row: %b, Col: %b", $time, row, col);
        #60_000_000;  
        col = 4'b0000;
        $display("Time %0t: Released key A", $time);
        #10_000_000;
        
        #100_000_000;
        
        $display("Tests completed");
        $finish;
    end

endmodule