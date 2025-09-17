// Christian Wu
// chrwu@g.hmc.edu
// 09/13/25

// This module takes in a combination of row and column inputs from the keypad,
// and outputs a 4-bit binary representation of the key pressed. If no key is pressed,
// the output is 4'b1111.

module keypad (
    input logic [3:0] row,
    input logic [3:0] col,
    output logic [3:0] key);
    
    always_comb begin
        case ({row, col})
            8'b1110_1110: key = 4'b0001; // 1
            8'b1110_1101: key = 4'b0010; // 2
            8'b1110_1011: key = 4'b0011; // 3
            8'b1110_0111: key = 4'b1010; // A
            8'b1101_1110: key = 4'b0100; // 4
            8'b1101_1101: key = 4'b0101; // 5
            8'b1101_1011: key = 4'b0110; // 6
            8'b1101_0111: key = 4'b1011; // B
            8'b1011_1110: key = 4'b0111; // 7
            8'b1011_1101: key = 4'b1000; // 8
            8'b1011_1011: key = 4'b1001; // 9
            8'b1011_0111: key = 4'b1100; // C
            8'b0111_1110: key = 4'b1110; // *
            8'b0111_1101: key = 4'b0000; // 0
            8'b0111_1011: key = 4'b1111; // #
            8'b0111_0111: key = 4'b1101; // D
            default:      key = 4'b1111; // No key pressed
        endcase
    end
endmodule