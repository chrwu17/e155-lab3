module keypad_oneshot (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        key_valid,     // From keypad scanner - high when any key detected
    input  logic [3:0]  key_code,      // From keypad scanner - current key code
    
    output logic        new_key_pulse, // Single-cycle pulse when new key registered
    output logic [3:0]  captured_key   // Stable key code output
);

    // FSM States
    typedef enum logic [1:0] {
        IDLE        = 2'b00,  // No key pressed, ready for new press
        DEBOUNCE    = 2'b01,  // Key detected, debouncing
        KEY_HELD    = 2'b10,  // Key validated and held, waiting for release
        RELEASE_DEB = 2'b11   // Key released, debouncing release
    } state_t;
    
    state_t current_state, next_state;
    
    // Debounce counter - adjust DEBOUNCE_COUNT based on your clock frequency
    // For 12MHz clock, 240 cycles = ~20us debounce time
    localparam int DEBOUNCE_COUNT = 240;
    localparam int COUNTER_WIDTH = $clog2(DEBOUNCE_COUNT + 1);
    
    logic [COUNTER_WIDTH-1:0] debounce_counter;
    logic debounce_done;
    logic [3:0] key_code_reg;
    
    // Debounce counter logic
    assign debounce_done = (debounce_counter == DEBOUNCE_COUNT);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            debounce_counter <= '0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (key_valid) begin
                        debounce_counter <= 1;  // Start counting
                    end else begin
                        debounce_counter <= '0;
                    end
                end
                
                DEBOUNCE: begin
                    if (key_valid && !debounce_done) begin
                        debounce_counter <= debounce_counter + 1;
                    end else begin
                        debounce_counter <= '0;
                    end
                end
                
                KEY_HELD: begin
                    if (!key_valid) begin
                        debounce_counter <= 1;  // Start release debounce
                    end else begin
                        debounce_counter <= '0;
                    end
                end
                
                RELEASE_DEB: begin
                    if (!key_valid && !debounce_done) begin
                        debounce_counter <= debounce_counter + 1;
                    end else begin
                        debounce_counter <= '0;
                    end
                end
                
                default: debounce_counter <= '0;
            endcase
        end
    end
    
    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // Next state logic
    always_comb begin
        next_state = current_state;  // Default: stay in current state
        
        case (current_state)
            IDLE: begin
                if (key_valid) begin
                    next_state = DEBOUNCE;
                end
            end
            
            DEBOUNCE: begin
                if (!key_valid) begin
                    next_state = IDLE;  // Glitch - go back to idle
                end else if (debounce_done) begin
                    next_state = KEY_HELD;  // Valid press confirmed
                end
            end
            
            KEY_HELD: begin
                if (!key_valid) begin
                    next_state = RELEASE_DEB;
                end
            end
            
            RELEASE_DEB: begin
                if (key_valid) begin
                    next_state = KEY_HELD;  // Key pressed again before full release
                end else if (debounce_done) begin
                    next_state = IDLE;  // Clean release confirmed
                end
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Key code capture register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_code_reg <= 4'h0;
        end else if (current_state == DEBOUNCE && debounce_done && key_valid) begin
            // Capture key code when transitioning from DEBOUNCE to KEY_HELD
            key_code_reg <= key_code;
        end
    end
    
    // Output assignments
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            new_key_pulse <= 1'b0;
        end else begin
            // Generate single-cycle pulse when transitioning to KEY_HELD
            new_key_pulse <= (current_state == DEBOUNCE) && 
                           (next_state == KEY_HELD) && 
                           debounce_done;
        end
    end
    
    // Captured key output is stable once registered
    assign captured_key = key_code_reg;

endmodule