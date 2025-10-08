`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
input CLOCK, 
input btnL,
input btnR, 
input  sw2,
output [7:0] JB
);
    reg [15:0] oled_Data; 
    wire frame_begin; 
    wire sending_pixels; 
    wire sample_pixels;
    wire [12:0] pixel_index;
    wire clk6p25m;
    
    wire [1:0] count;
    
    wire [6:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
    


    
    clock_6p25m(CLOCK,clk6p25m);
    
    reg [1:0] l_sync=0, r_sync=0;
    always @(posedge clk6p25m) begin
        l_sync <= {l_sync[0], btnL};
        r_sync <= {r_sync[0], btnR};
    end
    wire l_held = l_sync[1];
    wire r_held = r_sync[1];
    
    reg l_held_d=0, r_held_d=0;
    always @(posedge clk6p25m) begin
        l_held_d <= l_held;
        r_held_d <= r_held;
    end
    wire l_rise =  l_held & ~l_held_d;  
    wire r_rise =  r_held & ~r_held_d;
    
    reg show_left  = 1'b1;  
    reg show_right = 1'b1;  
    always @(posedge clk6p25m) begin
        if (l_rise) show_left  <= ~show_left;
        if (r_rise) show_right <= ~show_right;
    end
    
    integer dx;
    integer dy;
    
    wire left = (x >= 30 && x <= 36 && y >= 14 && y <= 60)
                || (x >= 11 && x <= 30 && y >= 14 && y <= 20)
                || (x >= 11 && x <= 30 && y >= 34 && y <= 40)
                || (x >= 11 && x <= 30 && y >= 54 && y <= 60);
                
    wire right = (x >= 47 + 11 && x <= 53 + 11 && y >= 14 && y <= 60)
                 || (x >= 53 + 11 && x <= 67 + 11 && y >= 14 && y <= 20)
                 || (x >= 53 + 11 && x <= 67 + 11 && y >= 34 && y <= 40)
                 || (x >= 53 + 11 && x <= 67 + 11 && y >= 54 && y <= 60)
                 || (x >= 67 + 11 && x <= 73 + 11 && y >= 14 && y <= 60);
                 
    
    always @(*) begin

    oled_Data = 16'h0000;
    
    dy = y-6;
    dx = x-6;
    
    if (dx*dx + dy*dy <= 36)
        oled_Data = (l_held || r_held) ? 16'hF81F : 16'hFFFF;
        
    if (show_left && left)
        oled_Data = 16'hF800;
        
    if (show_right && right)
        oled_Data = 16'h07E0;
    
    
            end
    
    Oled_Display(clk6p25m, btnC, frame_begin, sending_pixel, sample_pixels, pixel_index, oled_Data, JB[0], JB[1], JB[3], JB[4], JB[5], JB[6], JB[7]);
    
endmodule
