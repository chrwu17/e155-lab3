module keypad_scanner (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [3:0]  keypad_rows,    // Active-low row inputs
    
    output logic [3:0]  keypad_cols,    // Active-low column outputs  
    output logic        key_valid,      // High when any key is pressed
    output logic [3:0]  key_code        // 4-bit key code (0-F hex)
);

    // Keypad layout for reference:
    // Cols: 0   1   2   3
    // Row 0: 1   2   3   A
    // Row 1: 4   5   6   B  
    // Row 2: 7   8   9   C
    // Row 3: *   0   #   D
    
    // Standard hex encoding:
    // 1=0x1, 2=0x2, 3=0x3, A=0xA
    // 4=0x4, 5=0x5, 6=0x6, B=0xB  
    // 7=0x7, 8=0x8, 9=0x9, C=0xC
    // *=0xE, 0=0x0, #=0xF, D=0xD

    // Scan timing - divide main clock for column scanning
    // For 12MHz clock, divide by 3000 gives ~4kHz scan rate (1ms per column, 4ms full cycle)
    localparam int SCAN_DIVIDER = 3000;
    localparam int SCAN_COUNTER_WIDTH = $clog2(SCAN_DIVIDER);
    
    logic [SCAN_COUNTER_WIDTH-1:0] scan_counter;
    logic scan_tick;
    
    // Column state counter (2 bits for 4 columns)
    logic [1:0] col_select;
    
    // Key detection and encoding
    logic [3:0] current_key_code;
    logic current_key_valid;
    logic [3:0] stable_key_code;
    logic stable_key_valid;
    
    // Generate scan tick - divides clock for column scanning
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scan_counter <= '0;
            scan_tick <= 1'b0;
        end else begin
            if (scan_counter == SCAN_DIVIDER - 1) begin
                scan_counter <= '0;
                scan_tick <= 1'b1;
            end else begin
                scan_counter <= scan_counter + 1;
                scan_tick <= 1'b0;
            end
        end
    end
    
    // Column selection counter - advances on scan_tick
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_select <= 2'b00;
        end else if (scan_tick) begin
            col_select <= col_select + 1;  // Auto-wraps at 4
        end
    end
    
    // Generate column outputs - active low, one-hot
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            keypad_cols <= 4'b1111;  // All high (inactive)
        end else begin
            case (col_select)
                2'b00: keypad_cols <= 4'b1110;  // Column 0 active
                2'b01: keypad_cols <= 4'b1101;  // Column 1 active  
                2'b10: keypad_cols <= 4'b1011;  // Column 2 active
                2'b11: keypad_cols <= 4'b0111;  // Column 3 active
                default: keypad_cols <= 4'b1111;
            endcase
        end
    end
    
    // Key detection and encoding logic
    always_comb begin
        current_key_valid = 1'b0;
        current_key_code = 4'h0;
        
        // Check for key press in current column
        // Rows are active-low, so look for 0 bits
        case (col_select)
            2'b00: begin // Column 0: 1, 4, 7, *
                case (keypad_rows)
                    4'b1110: begin current_key_valid = 1'b1; current_key_code = 4'h1; end // Row 0: '1'
                    4'b1101: begin current_key_valid = 1'b1; current_key_code = 4'h4; end // Row 1: '4'  
                    4'b1011: begin current_key_valid = 1'b1; current_key_code = 4'h7; end // Row 2: '7'
                    4'b0111: begin current_key_valid = 1'b1; current_key_code = 4'hE; end // Row 3: '*'
                    default: begin current_key_valid = 1'b0; current_key_code = 4'h0; end
                endcase
            end
            
            2'b01: begin // Column 1: 2, 5, 8, 0
                case (keypad_rows)
                    4'b1110: begin current_key_valid = 1'b1; current_key_code = 4'h2; end // Row 0: '2'
                    4'b1101: begin current_key_valid = 1'b1; current_key_code = 4'h5; end // Row 1: '5'
                    4'b1011: begin current_key_valid = 1'b1; current_key_code = 4'h8; end // Row 2: '8' 
                    4'b0111: begin current_key_valid = 1'b1; current_key_code = 4'h0; end // Row 3: '0'
                    default: begin current_key_valid = 1'b0; current_key_code = 4'h0; end
                endcase
            end
            
            2'b10: begin // Column 2: 3, 6, 9, #
                case (keypad_rows)
                    4'b1110: begin current_key_valid = 1'b1; current_key_code = 4'h3; end // Row 0: '3'
                    4'b1101: begin current_key_valid = 1'b1; current_key_code = 4'h6; end // Row 1: '6'
                    4'b1011: begin current_key_valid = 1'b1; current_key_code = 4'h9; end // Row 2: '9'
                    4'b0111: begin current_key_valid = 1'b1; current_key_code = 4'hF; end // Row 3: '#' 
                    default: begin current_key_valid = 1'b0; current_key_code = 4'h0; end
                endcase
            end
            
            2'b11: begin // Column 3: A, B, C, D
                case (keypad_rows)
                    4'b1110: begin current_key_valid = 1'b1; current_key_code = 4'hA; end // Row 0: 'A'
                    4'b1101: begin current_key_valid = 1'b1; current_key_code = 4'hB; end // Row 1: 'B'
                    4'b1011: begin current_key_valid = 1'b1; current_key_code = 4'hC; end // Row 2: 'C' 
                    4'b0111: begin current_key_valid = 1'b1; current_key_code = 4'hD; end // Row 3: 'D'
                    default: begin current_key_valid = 1'b0; current_key_code = 4'h0; end
                endcase
            end
            
            default: begin
                current_key_valid = 1'b0;
                current_key_code = 4'h0;
            end
        endcase
    end
    
    // Stable key output registers - hold value while key is pressed
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stable_key_valid <= 1'b0;
            stable_key_code <= 4'h0;
        end else begin
            if (current_key_valid) begin
                // Key detected - capture and hold
                stable_key_valid <= 1'b1;
                stable_key_code <= current_key_code;
            end else if (!current_key_valid && scan_tick && col_select == 2'b11) begin
                // End of scan cycle with no key detected - clear outputs
                stable_key_valid <= 1'b0;
                stable_key_code <= 4'h0;
            end
            // Otherwise maintain previous values
        end
    end
    
    // Output assignments
    assign key_valid = stable_key_valid;
    assign key_code = stable_key_code;

endmodule