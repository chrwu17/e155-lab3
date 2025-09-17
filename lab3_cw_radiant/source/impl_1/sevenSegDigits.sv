// Christian Wu
// chrwu@g.hmc.edu 
// 09/13/25

// This module stores the last two hexadecimal digits pressed on the keypad, and outputs them to be displayed
// on a dual seven segment display. When a new key is pressed, the previous key is shifted to the left digit,
// and the new key is displayed on the right digit.

module sevenSegDigits (
    input logic clk,
    input logic reset,
    input logic en,
    input logic [3:0] key,
    output logic [3:0] s1, // Left digit
    output logic [3:0] s2  // Right digit
    );

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            s1 <= 4'b0000; // Reset left digit to 0
            s2 <= 4'b0000; // Reset right digit to 0
        end else if (en) begin
            s1 <= s2; // Shift the previous right digit to the left
            s2 <= key; // Update the right digit with the new key
        end
    end
endmodule