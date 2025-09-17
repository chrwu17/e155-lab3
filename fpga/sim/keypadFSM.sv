// Christian Wu
// chrwu@g.hmc.edu
// 09/15/25

// This module implements a finite state machine (FSM) to scan a 4x4 keypad.
// It drives the rows and reads the columns to detect key presses, with
// debouncing and single key press detection. The FSM operates at 1kHz,
// with a debounce period of 50ms. The design ensures that only one key
// press is registered at a time, and it waits for the key to be released
// before allowing another key press to be detected.

module keypadFSM (
    input  logic clk,
    input  logic reset,
    input  logic [3:0] col,
    output logic [3:0] row,
    output logic [7:0] rc,
    output logic en);

    typedef enum logic [3:0] {
        S0,       // Row0 scan
        S1,       // Row1 scan
        S2,       // Row2 scan
        S3,       // Row3 scan
        S4,       // Row0 debounce
        S5,       // Row0 hold
        S6,       // Row1 debounce
        S7,       // Row1 hold
        S8,       // Row2 debounce
        S9,       // Row2 hold
        S10,      // Row3 debounce
        S11       // Row3 hold
    } state_t;

    state_t state, nextState;
    logic [3:0] activeCol;
    logic buttonPressed, oneButtonPressed;
    logic [3:0] rowPressed;
    logic [3:0] originalButton; 
    logic originalStillPressed; 
    logic [7:0] counter;
    logic [18:0] fsm_counter;
    logic fsm_tick;

    parameter FSM_TICK_COUNT = 19'd48_000;    
    parameter DEBOUNCE_COUNT = 8'd50;        

    // 1kHz tick generator for FSM state transitions
    always_ff @(posedge clk) begin
        if (reset) begin
            fsm_counter <= 0;
            fsm_tick <= 0;
        end else begin
            if (fsm_counter >= FSM_TICK_COUNT - 1) begin
                fsm_counter <= 0;
                fsm_tick <= 1;
            end else begin
                fsm_counter <= fsm_counter + 1;
                fsm_tick <= 0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            state <= S0;
            counter <= 0;
            originalButton <= 4'b0000;
        end else if (fsm_tick) begin
            state <= nextState;
            
            // Store original button when entering debounce states
            if ((state inside {S0,S1,S2,S3}) && (nextState inside {S4,S6,S8,S10}) && oneButtonPressed) begin
                originalButton <= activeCol;
            end
            
            // Clear original button when returning to scanning
            if (nextState inside {S0,S1,S2,S3}) begin
                originalButton <= 4'b0000;
            end
            
            // Debounce counter (only in debounce states)
            if (state inside {S4,S6,S8,S10}) begin
                if (buttonPressed && counter < DEBOUNCE_COUNT)
                    counter <= counter + 1;
                else if (!buttonPressed)
                    counter <= 0;
            end else begin
                counter <= 0;
            end
        end
    end

    always_comb begin
        case (state)
            S0, S4, S5:     row = 4'b0001; // Row0 active
            S1, S6, S7:     row = 4'b0010; // Row1 active
            S2, S8, S9:     row = 4'b0100; // Row2 active
            S3, S10, S11:   row = 4'b1000; // Row3 active
            default:        row = 4'b0001; // Default to Row0
        endcase
    end

    assign activeCol = col & {4{row[0] | row[1] | row[2] | row[3]}};

    assign buttonPressed    = |activeCol;
    assign oneButtonPressed = (activeCol != 0) &&
                              ((activeCol & (activeCol - 1)) == 0);
    
    // Check if the original button is still pressed
    assign originalStillPressed = (originalButton != 4'b0000) && 
                                  ((activeCol & originalButton) == originalButton);

    assign rowPressed[0] = (state inside {S0, S4, S5});
    assign rowPressed[1] = (state inside {S1, S6, S7});
    assign rowPressed[2] = (state inside {S2, S8, S9});
    assign rowPressed[3] = (state inside {S3, S10, S11});

    assign en = fsm_tick && (
                (nextState == S5 && state == S4) ||
                (nextState == S7 && state == S6) ||
                (nextState == S9 && state == S8) ||
                (nextState == S11 && state == S10)
              );

    always_comb begin
        case (state)
            S0:  nextState = buttonPressed && oneButtonPressed ? S4 : S1;
            S1:  nextState = buttonPressed && oneButtonPressed ? S6 : S2;
            S2:  nextState = buttonPressed && oneButtonPressed ? S8 : S3;
            S3:  nextState = buttonPressed && oneButtonPressed ? S10 : S0;

            S4:  nextState = (!buttonPressed || !oneButtonPressed) ? S1 :
                            (counter >= DEBOUNCE_COUNT ? S5 : S4);
            S5:  nextState = !originalStillPressed ? S1 : S5; 

            S6:  nextState = (!buttonPressed || !oneButtonPressed) ? S2 :
                            (counter >= DEBOUNCE_COUNT ? S7 : S6);
            S7:  nextState = !originalStillPressed ? S2 : S7; 

            S8:  nextState = (!buttonPressed || !oneButtonPressed) ? S3 :
                            (counter >= DEBOUNCE_COUNT ? S9 : S8);
            S9:  nextState = !originalStillPressed ? S3 : S9; 

            S10: nextState = (!buttonPressed || !oneButtonPressed) ? S0 :
                            (counter >= DEBOUNCE_COUNT ? S11 : S10);
            S11: nextState = !originalStillPressed ? S0 : S11;

            default: nextState = S0;
        endcase
    end

    assign rc = {rowPressed, col};
endmodule