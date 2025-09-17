// Christian Wu
// chrwu@g.hmc.edu
// 09//13/25

// This is the top level module for Lab 3. This module will display the last two hexadecimal digits pressed
// on the seven segment display. 

module lab3_cw (
    input logic reset,
    input logic [3:0] col,
    output logic [3:0] row,
    output logic [6:0] seg,
    output logic an1, an2);

    logic clk;

    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk)); // 48 MHz clock

    logic [7:0] rc;
    logic [3:0] col_sync;
    logic [3:0] key;
    logic en;
    logic en_db;
    logic [3:0] s1, s2; // Digits to display
    logic signal;
    logic [3:0] current_seg;

    synchronizer sync (.clk(clk), .in(col), .out(col_sync));
    keypadFSM fsm (.clk(clk), .reset(reset), .col(col_sync), .row(row), .rc(rc), .en(en));
    keypad keypad_decode (.row(rc[7:4]), col(rc[3:0]), .key(key));
    debouncer db (.clk(clk), .in(en), .out(en_db));
    sevenSegDigits digits (.clk(clk), .en(en_db), .key(key), .s1(s1), .s2(s2));
    timeMultiplexer timeMux (.clk(clk), .an1(an1), .an2(an2), .signal(signal));
    sevenSegMux segMux (.s1(s1), .s2(s2), .enable(signal), .out(current_seg));
    sevenSegmentDisplay segDisplay (.in(current_seg), .out(seg));

endmodule