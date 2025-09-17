// Christian Wu
// chrwu@g.hmc.edu
// 09/13/25

// This module takes in a combination of row and column inputs from the keypad,
// and outputs a 4-bit binary representation of the key pressed. If no key is pressed,
// the output is 4'b1111.
// Modified to work with active-high row scanning to match Max's approach.

module keypad (
    input  logic [3:0] row,
    input  logic [3:0] col,
    output logic [3:0] key
);

    always_comb begin
        case ({row, col})
            8'b0001_0010: key = 4'b0000; // 0
            8'b1000_0001: key = 4'b0001; // 1
            8'b1000_0010: key = 4'b0010; // 2
            8'b1000_0100: key = 4'b0011; // 3
            8'b0100_0001: key = 4'b0100; // 4
            8'b0100_0010: key = 4'b0101; // 5
            8'b0100_0100: key = 4'b0110; // 6
            8'b0010_0001: key = 4'b0111; // 7
            8'b0010_0010: key = 4'b1000; // 8
            8'b0010_0100: key = 4'b1001; // 9
            8'b0001_0001: key = 4'b1010; // A
            8'b0001_0100: key = 4'b1011; // B
            8'b1000_1000: key = 4'b1100; // C
            8'b0100_1000: key = 4'b1101; // D
            8'b0010_1000: key = 4'b1110; // E
            8'b0001_1000: key = 4'b1111; // F
            default:      key = 4'b1111; // No key pressed
        endcase
    end
endmodule