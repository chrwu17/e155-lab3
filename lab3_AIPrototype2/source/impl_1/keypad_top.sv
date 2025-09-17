module keypad_top (
    // External connections
    input  logic [3:0]  keypad_rows,    // Active-low row inputs from keypad
    output logic [3:0]  keypad_cols,    // Active-low column drives to keypad
    output logic [6:0]  seg_cathodes,   // 7-segment cathodes (a-g, active-low)
    output logic [1:0]  seg_anodes      // 7-segment anodes (digit select, active-low)
);

    // Internal oscillator instance for iCE40 UP5K (48MHz nominal)
    logic clk_48mhz;
    
    HSOSC #(
        .CLKHF_DIV("0b10")  // Divide by 4: 48MHz/4 = 12MHz
    ) u_hfosc (
        .CLKHFPU(1'b1),     // Power up the oscillator
        .CLKHFEN(1'b1),     // Enable the oscillator
        .CLKHF(clk_48mhz)   // 48MHz output (before divider)
    );
    
    // Main system clock (12MHz after internal divider)
    logic clk;
    assign clk = clk_48mhz;
    
    // Generate reset from power-on
    logic [3:0] reset_counter = 4'h0;
    logic rst_n;
    
    always_ff @(posedge clk) begin
        if (reset_counter != 4'hF) begin
            reset_counter <= reset_counter + 1;
            rst_n <= 1'b0;
        end else begin
            rst_n <= 1'b1;
        end
    end
    
    // Inter-module signals
    logic        key_valid;
    logic [3:0]  key_code;
    logic        new_key_pulse;
    logic [3:0]  captured_key;
    
    // Key history registers - shift register for last two keys
    logic [3:0]  recent_key;     // Most recent key (rightmost digit)
    logic [3:0]  older_key;      // Older key (leftmost digit)
    
    // Seven-segment display multiplexing
    logic [3:0]  mux_counter;
    logic        digit_select;   // 0 = older digit, 1 = recent digit
    logic [3:0]  current_digit;
    logic [6:0]  seg_data;
    
    // Display refresh rate: 12MHz / 4096 ≈ 2.93kHz per digit, 1.46kHz refresh rate
    // This gives good brightness without visible flicker
    localparam int MUX_DIVIDER = 4096;
    localparam int MUX_COUNTER_WIDTH = $clog2(MUX_DIVIDER);
    
    logic [MUX_COUNTER_WIDTH-1:0] mux_div_counter;
    logic mux_tick;
    
    //==========================================================================
    // Clock divider for display multiplexing
    //==========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mux_div_counter <= '0;
            mux_tick <= 1'b0;
        end else begin
            if (mux_div_counter == MUX_DIVIDER - 1) begin
                mux_div_counter <= '0;
                mux_tick <= 1'b1;
            end else begin
                mux_div_counter <= mux_div_counter + 1;
                mux_tick <= 1'b0;
            end
        end
    end
    
    //==========================================================================
    // Display multiplexing logic
    //==========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_select <= 1'b0;
        end else if (mux_tick) begin
            digit_select <= ~digit_select;  // Toggle between digits
        end
    end
    
    // Select current digit data
    always_comb begin
        case (digit_select)
            1'b0: current_digit = older_key;   // Left digit (older key)
            1'b1: current_digit = recent_key;  // Right digit (recent key)
            default: current_digit = 4'h0;
        endcase
    end
    
    // Generate anode signals (active-low digit select)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seg_anodes <= 2'b11;  // Both digits off
        end else begin
            case (digit_select)
                1'b0: seg_anodes <= 2'b10;  // Left digit on, right digit off
                1'b1: seg_anodes <= 2'b01;  // Left digit off, right digit on
                default: seg_anodes <= 2'b11;
            endcase
        end
    end
    
    //==========================================================================
    // Key history management
    //==========================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            recent_key <= 4'h0;
            older_key <= 4'h0;
        end else if (new_key_pulse) begin
            // Shift keys: older ← recent, recent ← new
            older_key <= recent_key;
            recent_key <= captured_key;
        end
    end
    
    //==========================================================================
    // Module instantiations
    //==========================================================================
    
    // Keypad scanner
    keypad_scanner u_scanner (
        .clk         (clk),
        .rst_n       (rst_n),
        .keypad_rows (keypad_rows),
        .keypad_cols (keypad_cols),
        .key_valid   (key_valid),
        .key_code    (key_code)
    );
    
    // One-shot key registration
    keypad_oneshot u_oneshot (
        .clk           (clk),
        .rst_n         (rst_n),
        .key_valid     (key_valid),
        .key_code      (key_code),
        .new_key_pulse (new_key_pulse),
        .captured_key  (captured_key)
    );
    
    // Seven-segment decoder for current digit
    sevenSegment u_seven_seg (
        .hex_digit (current_digit),
        .segments  (seg_data)
    );
    
    // Register seven-segment outputs for clean timing
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seg_cathodes <= 7'b1111111;  // All segments off (active-low)
        end else begin
            seg_cathodes <= seg_data;
        end
    end

endmodule

//==========================================================================
// Seven-segment decoder module (as referenced in the instantiation)
//==========================================================================
module sevenSegment (
    input  logic [3:0] hex_digit,
    output logic [6:0] segments    // {g,f,e,d,c,b,a} - active low
);

    always_comb begin
        case (hex_digit)
            4'h0: segments = 7'b1000000; // '0'  
            4'h1: segments = 7'b1111001; // '1'
            4'h2: segments = 7'b0100100; // '2'
            4'h3: segments = 7'b0110000; // '3'
            4'h4: segments = 7'b0011001; // '4'
            4'h5: segments = 7'b0010010; // '5'
            4'h6: segments = 7'b0000010; // '6'
            4'h7: segments = 7'b1111000; // '7'
            4'h8: segments = 7'b0000000; // '8'
            4'h9: segments = 7'b0010000; // '9'
            4'hA: segments = 7'b0001000; // 'A'
            4'hB: segments = 7'b0000011; // 'b'
            4'hC: segments = 7'b1000110; // 'C'
            4'hD: segments = 7'b0100001; // 'd'
            4'hE: segments = 7'b0000110; // 'E'
            4'hF: segments = 7'b0001110; // 'F'
            default: segments = 7'b1111111; // All off
        endcase
    end

endmodule