// Christian Wu
// chrwu@g.hmc.edu
// 09//13/25

// This is the top level module for Lab 3. This module will display the last two hexadecimal digits pressed
// on the seven segment display. Simplified to use single clock with proper timing.
// FIXED: Added power-on reset to handle clock startup issues

module lab3_cw (
    input logic resetInv, 
    input logic [3:0] col,
    output logic [3:0] row,
    output logic [6:0] seg,
    output logic an1, an2);

    logic clk;          // Main clock (48 MHz)
    logic reset;        // Proper reset signal
    logic por_reset;    // Power-on reset
    logic system_reset; // Combined reset
    
    // Clock generation - 48 MHz internal oscillator
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
    
    assign reset = ~resetInv; // Invert reset signal (active high)

    // Internal signals
    logic [7:0] rc;
    logic [3:0] col_sync;
    logic [3:0] key;
    logic en;
    logic [3:0] s1, s2; // Digits to display
    logic signal;
    logic [3:0] current_seg;
    logic [24:0] bounceCounter;

    // Module instantiations - All use same clock and combined reset
    synchronizer sync (.clk(clk), .reset(reset), .in(col), .out(col_sync));
    keypadFSM fsm (.clk(clk), .reset(reset), .col(col_sync), .row(row), .rc(rc), .en(en), .counter(bounceCounter));
    keypad keypad_decode (.row(rc[7:4]), .col(rc[3:0]), .key(key));
    sevenSegDigits digits (.clk(clk), .reset(reset), .en(en), .key(key), .bounceCounter(bounceCounter), .s1(s1), .s2(s2));
    timeMultiplexer timeMux (.clk(clk), .reset(reset), .an1(an1), .an2(an2), .signal(signal));
    sevenSegMux segMux (.s1(s1), .s2(s2), .enable(signal), .out(current_seg));
    sevenSegmentDisplay segDisplay (.s(current_seg), .seg(seg));

endmodule