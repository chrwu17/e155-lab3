// Top-level module for 4x4 keypad scanner with dual 7-segment display
// Targets Lattice iCE40 UP5K FPGA with ~20 MHz internal oscillator
module keypad_display_top (
    input  logic       clk,           // ~20 MHz internal oscillator
    input  logic       rst_n,         // Active-low reset
    
    // Keypad interface (active-low)
    output logic [3:0] col_n,         // Column outputs (active-low)
    input  logic [3:0] row_n,         // Row inputs (active-low, pulled up)
    
    // 7-segment display interface
    output logic [6:0] seg_n,         // 7-segment outputs (active-low)
    output logic [1:0] dig_sel_n      // Digit select (active-low)
);

    // Internal signals
    logic scan_clk;                   // ~150 Hz scan clock
    logic display_clk;                // ~1 kHz display multiplex clock
    logic [3:0] key_pressed;          // Current key value (0-F)
    logic key_valid;                  // Key press event pulse
    
    // Instantiate clock divider
    clock_divider clk_div (
        .clk(clk),
        .rst_n(rst_n),
        .scan_clk(scan_clk),
        .display_clk(display_clk)
    );
    
    // Instantiate keypad scanner
    keypad_scanner scanner (
        .clk(clk),
        .rst_n(rst_n),
        .scan_clk(scan_clk),
        .col_n(col_n),
        .row_n(row_n),
        .key_pressed(key_pressed),
        .key_valid(key_valid)
    );
    
    // Instantiate display controller
    display_controller display (
        .clk(clk),
        .rst_n(rst_n),
        .display_clk(display_clk),
        .key_pressed(key_pressed),
        .key_valid(key_valid),
        .seg_n(seg_n),
        .dig_sel_n(dig_sel_n)
    );

endmodule

// Clock divider module
// Generates scan clock (~150 Hz) and display multiplex clock (~1 kHz)
module clock_divider (
    input  logic clk,           // ~20 MHz input clock
    input  logic rst_n,
    output logic scan_clk,      // ~150 Hz for keypad scanning
    output logic display_clk    // ~1 kHz for display multiplexing
);

    // Clock divider counters
    // For 20 MHz input: scan_clk = 20M / (2^17) ≈ 153 Hz
    logic [16:0] scan_counter;
    // For display_clk = 20M / (2^14) ≈ 1.2 kHz
    logic [13:0] display_counter;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scan_counter <= '0;
            display_counter <= '0;
        end else begin
            scan_counter <= scan_counter + 1;
            display_counter <= display_counter + 1;
        end
    end
    
    assign scan_clk = scan_counter[16];
    assign display_clk = display_counter[13];

endmodule

// Keypad scanner with debouncing
// Scans 4x4 matrix keypad, registers one key per press with debounce-by-design
module keypad_scanner (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       scan_clk,
    output logic [3:0] col_n,         // Active-low column outputs
    input  logic [3:0] row_n,         // Active-low row inputs
    output logic [3:0] key_pressed,   // Registered key value
    output logic       key_valid      // Key press event (single cycle pulse)
);

    // FSM states
    typedef enum logic [1:0] {
        IDLE,           // No key pressed, ready to scan
        KEY_DETECTED,   // Key detected, wait for stable reading
        KEY_HELD        // Key registered, wait for release
    } state_t;
    
    state_t state, next_state;
    
    // Scan control
    logic [1:0] col_select;           // Current column being scanned (0-3)
    logic [3:0] col_decoded;          // One-hot column select
    logic [3:0] row_sync;             // Synchronized row inputs
    
    // Key detection
    logic key_detected;
    logic [3:0] detected_key;
    
    // Column decoder: converts 2-bit select to one-hot (active-low)
    always_comb begin
        col_decoded = 4'b1111;  // Default all inactive
        col_decoded[col_select] = 1'b0;  // Activate selected column
    end
    
    assign col_n = col_decoded;
    
    // Synchronize row inputs (2 FF synchronizer)
    logic [3:0] row_sync1;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_sync1 <= 4'b1111;
            row_sync <= 4'b1111;
        end else begin
            row_sync1 <= row_n;
            row_sync <= row_sync1;
        end
    end
    
    // Key detection logic
    always_comb begin
        key_detected = 1'b0;
        detected_key = 4'h0;
        
        // Check for active row in current column
        for (int i = 0; i < 4; i++) begin
            if (!row_sync[i]) begin  // Active-low row detected
                key_detected = 1'b1;
                // Calculate key value: row * 4 + col
                detected_key = {i[1:0], col_select};
                break;  // Only register first detected key
            end
        end
    end
    
    // Column scanning counter (advances on scan_clk)
    logic scan_clk_prev;
    logic scan_edge;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scan_clk_prev <= 1'b0;
        end else begin
            scan_clk_prev <= scan_clk;
        end
    end
    
    assign scan_edge = scan_clk && !scan_clk_prev;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_select <= 2'b00;
        end else if (scan_edge) begin
            col_select <= col_select + 1;  // Cycles through 0-3
        end
    end
    
    // Main FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (key_detected) begin
                    next_state = KEY_DETECTED;
                end
            end
            
            KEY_DETECTED: begin
                if (!key_detected) begin
                    next_state = IDLE;  // False detection, go back
                end else if (scan_edge) begin
                    next_state = KEY_HELD;  // Stable for full scan cycle
                end
            end
            
            KEY_HELD: begin
                if (!key_detected) begin
                    next_state = IDLE;  // Key released
                end
            end
        endcase
    end
    
    // Output registration
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_pressed <= 4'h0;
            key_valid <= 1'b0;
        end else begin
            key_valid <= 1'b0;  // Default to no pulse
            
            if (state == KEY_DETECTED && next_state == KEY_HELD) begin
                key_pressed <= detected_key;
                key_valid <= 1'b1;  // Generate single-cycle pulse
            end
        end
    end

endmodule

// Display controller with time multiplexing
// Maintains two hex digits and drives 7-segment display without flicker
module display_controller (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       display_clk,
    input  logic [3:0] key_pressed,
    input  logic       key_valid,
    output logic [6:0] seg_n,         // 7-segment outputs (active-low)
    output logic [1:0] dig_sel_n      // Digit select (active-low)
);

    // Stored digits (older and newer)
    logic [3:0] digit_old, digit_new;
    
    // Display multiplexing
    logic display_select;             // 0 = digit_old, 1 = digit_new
    logic [3:0] current_digit;
    
    // Update stored digits on new key press
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_old <= 4'h0;
            digit_new <= 4'h0;
        end else if (key_valid) begin
            digit_old <= digit_new;     // Shift: new becomes old
            digit_new <= key_pressed;  // Store new key
        end
    end
    
    // Display multiplexer (toggles on display_clk edge)
    logic display_clk_prev;
    logic display_edge;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            display_clk_prev <= 1'b0;
        end else begin
            display_clk_prev <= display_clk;
        end
    end
    
    assign display_edge = display_clk && !display_clk_prev;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            display_select <= 1'b0;
        end else if (display_edge) begin
            display_select <= ~display_select;
        end
    end
    
    // Select current digit and digit enable
    always_comb begin
        if (display_select) begin
            current_digit = digit_new;
            dig_sel_n = 2'b01;  // Enable right digit (newer)
        end else begin
            current_digit = digit_old;
            dig_sel_n = 2'b10;  // Enable left digit (older)
        end
    end
    
    // 7-segment decoder (hex to 7-segment, active-low outputs)
    always_comb begin
        case (current_digit)
            4'h0: seg_n = 7'b1000000;  // 0
            4'h1: seg_n = 7'b1111001;  // 1
            4'h2: seg_n = 7'b0100100;  // 2
            4'h3: seg_n = 7'b0110000;  // 3
            4'h4: seg_n = 7'b0011001;  // 4
            4'h5: seg_n = 7'b0010010;  // 5
            4'h6: seg_n = 7'b0000010;  // 6
            4'h7: seg_n = 7'b1111000;  // 7
            4'h8: seg_n = 7'b0000000;  // 8
            4'h9: seg_n = 7'b0010000;  // 9
            4'hA: seg_n = 7'b0001000;  // A
            4'hB: seg_n = 7'b0000011;  // b
            4'hC: seg_n = 7'b1000110;  // C
            4'hD: seg_n = 7'b0100001;  // d
            4'hE: seg_n = 7'b0000110;  // E
            4'hF: seg_n = 7'b0001110;  // F
        endcase
    end

endmodule