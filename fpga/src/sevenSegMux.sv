// Christian Wu
// chrwu@g.hmc.edu
// 09/08/25

// This module takes in two 4-bit inputs, s1 and s2, and an enable, and outputs one 
// of the inputs to a 4-bit output based on the enable signal for the seven-segment display

module sevenSegMux (
    input logic [3:0] s1, s2,
    input logic enable,
    output logic [3:0] out);

    assign out = enable ? s2 : s1;
endmodule