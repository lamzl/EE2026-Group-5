module Q(input wire clk, btnL, btnC, btnR, input wire [12:0] pixel_idx, output reg [15:0] pixel_data);
    // debounce implementation for 200ms delay
    reg [24:0] db_l, db_c, db_r; // debounce buttons, they are counters, 25 bit as 2^25 holds the value 33000000 which can hold 20000000
    reg btnL_db,btnC_db,btnR_db; // debounce button state 
    reg btnL_prev, btnC_prev, btnR_prev; // debounce button previous state 
    localparam DEBOUNCE_MAX = 25'd20000000; //200*10^-3/(1/(100*10^6))
    reg [2:0] colour_left, colour_middle, colour_right; //reg to store the colour of the lrc block and then outputs the colour
    
    // target colour when the magenta number pops up
    localparam targetL = 3'd1; // blue
    localparam targetR = 3'd3; // green
    localparam targetC = 3'd1; // blue
    localparam fourthN = 4'd8; // 4th rightmost digit is 8

    
    // Global variables for colour numbers
    localparam RED      =16'hF800;
    localparam BLUE     =16'h001F;
    localparam YELLOW   =16'hFFE0;
    localparam GREEN    =16'h07E0;
    localparam WHITE    =16'hFFFF;
    localparam BLACK    =16'h0000;
    localparam MAGENTA  =16'hF81F;
    
    // pixel coordinates
    wire [6:0] x = pixel_idx%96; // gives the column number within the row of 96 pixels
    wire [6:0] y = pixel_idx/96; // gives the row number because there are 96 pixels in each row
    
    // square regions on the bottom of the display
    wire left_sq   = x>=9 && x<29 && y>=40 && y < 60;
    wire middle_sq = x>=38 && x<58 && y>=40 && y < 60;
    wire right_sq  = x>=67 && x<87 && y>=40 && y <60;
    
    // Digit 8 bit mapping
    wire digit_region = (x>=88 && x<94 && y>=2 && y<14); // initialise a 12 col by 6 row area to draw the number 8
    // we want to shift the coordinates to (0,0)
    wire [2:0] dx = x - 88;
    wire [3:0] dy = y - 2;
    reg [5:0] bitmap [0:11];
    
    initial begin
        bitmap[0]  = 6'b011110;
        bitmap[1]  = 6'b011110;
        bitmap[2]  = 6'b110011;
        bitmap[3]  = 6'b110011;
        bitmap[4]  = 6'b110011;
        bitmap[5]  = 6'b011110;
        bitmap[6]  = 6'b011110;
        bitmap[7]  = 6'b110011;
        bitmap[8]  = 6'b110011;
        bitmap[9]  = 6'b110011;
        bitmap[10] = 6'b011110;
        bitmap[11] = 6'b011110;
    end
    wire digit_pixel = bitmap[dy][5-dx];
    wire match = (colour_left == targetL && colour_right == targetR && colour_middle == targetC);
    // pixel data generation
    always @(*) begin 
        if (left_sq) begin
            case (colour_left)
            3'd0: pixel_data = RED;
            3'd1: pixel_data = BLUE;
            3'd2: pixel_data = YELLOW;
            3'd3: pixel_data = GREEN;
            3'd4: pixel_data = WHITE;
            default: pixel_data = BLACK;
            endcase
        end else if (middle_sq) begin
            case (colour_middle)
            3'd0: pixel_data = RED;
            3'd1: pixel_data = BLUE;
            3'd2: pixel_data = YELLOW;
            3'd3: pixel_data = GREEN;
            3'd4: pixel_data = WHITE;
            default: pixel_data = BLACK;
            endcase
        end else if (right_sq) begin
            case (colour_right)
            3'd0: pixel_data = RED;
            3'd1: pixel_data = BLUE;
            3'd2: pixel_data = YELLOW;
            3'd3: pixel_data = GREEN;
            3'd4: pixel_data = WHITE;
            default: pixel_data = BLACK;
            endcase
        end else if (digit_region && match && digit_pixel)begin
            pixel_data = MAGENTA;
        end else begin
            pixel_data = BLACK;
        end
    end
    
    // Debouncing implementation
    always @(posedge clk) begin
        // left button debouncing
        btnL_prev <= btnL; // stores the previous value of the button so that you can detect the posedge
        // if button left is 1 now, but it was 0 previously, and debounce  left counter is 0
        // means no recent presses is still being debounced
        if (btnL && !btnL_prev && db_l == 0) begin
            db_l <= DEBOUNCE_MAX; // debounce counter is reloaded to debounce max
            btnL_db <= 1'b1;      // a debounced pulse is generated for 1 cycle
        end else if (db_l > 0) begin // in the middle of a debounce countdown
            db_l <= db_l -1; //decrease the timer 
            btnL_db <= 1'b0; // output is still 0 first
        end else begin
            btnL_db <= 1'b0; // no button presses
        end
        // right button debouncing
        btnR_prev <= btnR;
        if (btnR && !btnR_prev && db_r == 0) begin
            db_r <= DEBOUNCE_MAX;
            btnR_db <= 1'b1;
        end else if (db_r > 0) begin
            db_r <= db_r -1;
            btnR_db <= 1'b0;
        end else begin
            btnR_db <= 1'b0;
        end
        // centre button debouncing
        btnC_prev <= btnC;
        if (btnC && !btnC_prev && db_c == 0) begin
            db_c <= DEBOUNCE_MAX;
            btnC_db <= 1'b1;
        end else if (db_c > 0) begin
            db_c <= db_c -1;
            btnC_db <= 1'b0;
        end else begin
            btnC_db <= 1'b0;
        end
        // logic for cycling button presses
        if (btnL_db) 
            colour_left <= (colour_left == 4)?0:colour_left + 1;
        if (btnR_db)
             colour_right <= (colour_right == 4)?0:colour_right + 1;
        if (btnC_db)
             colour_middle <= (colour_middle == 4)?0:colour_middle + 1;
    end
