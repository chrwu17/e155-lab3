// Christian Wu
// chrwu@g.hmc.edu
// 09/13/25

// this module implements a finite state machine (FSM) to manage the states of a keypad-controlled system.
// The FSM has three states for each row: Scan, Validate, and Hold, allowing it to scan for key presses,
// validate the key presses, and hold the state until a new key is pressed.

module keypadFSM (
    input logic clk,
    input logic reset,
    input logic [3:0] col,
    output logic [3:0] row,
    output logic [7:0] rc,
    output logic en);

    logic oneButtonPressed;
    logic anyButtonPressed;

    assign oneButtonPressed = col[0] ^ col[1] ^ col[2] ^ col[3]; // True if exactly one button is pressed
    assign anyButtonPressed = |col; // True if any button is pressed

    enum logic [3:0] {s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11} state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= s0;
        end else begin
            state <= next_state;
        end
    end

    always_comb
        case (state)
            s0:
                next_state = oneButtonPressed ? s4 : s1; // Scan Row 0
            s1:
                next_state = oneButtonPressed ? s6 : s2; // Scan Row 1
            s2:
                next_state = oneButtonPressed ? s8 : s3; // Scan Row 2
            s3:
                next_state = oneButtonPressed ? s10 : s0; // Scan Row 3
            s4:
                next_state = oneButtonPressed ? s5 : s1; // Validate Row 0
            s5:
                next_state = anyButtonPressed ? s5 : s1; // Hold Row 0
            s6:
                next_state = oneButtonPressed ? s7 : s2; // Validate Row 1
            s7:
                next_state = anyButtonPressed ? s7 : s2; // Hold Row 1
            s8:
                next_state = oneButtonPressed ? s9 : s3; // Validate Row 2
            s9:
                next_state = anyButtonPressed ? s9 : s3; // Hold Row 2
            s10:
                next_state = oneButtonPressed ? s11 : s0; // Validate Row 3
            s11:
                next_state = anyButtonPressed ? s11 : s0; // Hold Row 3
            default:
                next_state = s0;
        endcase

    assign row[0] = (state == s0) || (state == s4) || (state == s5);
    assign row[1] = (state == s1) || (state == s6) || (state == s7);
    assign row[2] = (state == s2) || (state == s8) || (state == s9);
    assign row[3] = (state == s3) || (state == s10) || (state == s11);

    assign en = (state == s4) || (state == s6) || (state == s8) || (state == s10);

    assign rc = {row, col};

endmodule