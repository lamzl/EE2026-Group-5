`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 01:53:16 PM
// Design Name: 
// Module Name: S
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module S(clk6p25m, btnL, btnR, btnU, btnD, pixel_index, oled_display);
    
    localparam Width = 96;
    localparam Height = 64;
    localparam PixelCount = Width * Height;
    localparam PixelCountWidth = $clog2(PixelCount);
    
    input clk6p25m;
    input [PixelCountWidth-1:0] pixel_index;
    output reg [15:0] oled_display;
    input btnL, btnR, btnU, btnD;
    
    localparam width = 96; //midpt 48
    localparam height = 64; //midpt 32
    localparam pixelcount = width * height;
    
    wire [6:0] x;
    wire [6:0] y;
    assign x = pixel_index % width;
    assign y = pixel_index / width;
    
    //colours
    localparam white = 16'hFFFF;
    localparam black = 16'h0;
    localparam green = 16'h07E0;
    localparam red = 16'hF800;
    
    //corner box
    localparam sqr_x = 2;
    localparam sqr_y = 36;
    
    wire inside_sqr_bord = (x >= sqr_x && x <= sqr_x+25) &&
                           (y >= sqr_y && y <= sqr_y+25);             
    wire inside_sqr_ins = (x >= sqr_x+3 && x <= sqr_x+22) && //5 - 25
                          (y >= sqr_y+3 && y <= sqr_y+22);
                              
    //number9, 10-19, 41-56, w = 9, h =15
    wire inside_num = ( (x >= sqr_x+8 && x <= sqr_x+17) &&
                      (y >= sqr_y+5 && y <= sqr_y+8) ) ||
                      ( (y >= sqr_y+5 && y <= sqr_y+14) &&
                      (x >= sqr_x+8 && x <= sqr_x+11) ) ||
                      ( (y >= sqr_y+5 && y <= sqr_y+20) &&
                      (x >= sqr_x+14 && x <= sqr_x+17) ) ||
                      ( (x >= sqr_x+8 && x<= sqr_x+17) &&
                      (y >= sqr_y+11 && y <= sqr_y+14) ) ||
                      ( (x >= sqr_x+8 && x <= sqr_x+17) &&
                      (y >= sqr_y+17 && y <= sqr_y+20) );
    
    //direction buttons        
    wire [2:0] dir;
    enc_4t1 dir_enc (clk6p25m, btnU, btnD, btnL, btnR, dir); 
    
    //circle
    reg [6:0] cir_x; reg [6:0] cir_y;
    localparam cir_size = 10;        
    reg inside_cir;
    
    initial begin
        cir_x = 48;
        cir_y = 32;
        inside_cir = (x-cir_x)*(x-cir_x) + (y-cir_y)*(y-cir_y) <= (cir_size)*(cir_size);
    end
    
    wire clk_cir;
    clk_40 clk_for_circle (clk6p25m, clk_cir);
    
    always @(posedge clk_cir) begin  
        case (dir)
            1: begin
                if (cir_y > 10) 
                    cir_y = cir_y - 1;   
            end
            2: begin
                if (cir_x < 85) 
                    cir_x = cir_x + 1;
            end
            3: begin
                if ((cir_x > sqr_x+36 && cir_y < 53) || (cir_x <= sqr_x+34 && cir_y < sqr_y-11)) //NOT WORKING fix vars
                    cir_y = cir_y + 1;
            end
            4: begin
                if ((cir_y < sqr_y-12 && cir_x > 10) || (cir_y > sqr_y-10 && cir_x > sqr_x+36)) //NOT WORKING fix vars
                cir_x = cir_x - 1;
            end
            default: begin
                cir_x = cir_x;
                cir_y = cir_y;
               end
        endcase
    end
        
    always @(*) begin
        inside_cir = ((x-cir_x)*(x-cir_x) + (y-cir_y)*(y-cir_y) <= (cir_size)*(cir_size));        
    end                    
                          
    always @(*) begin
        if (inside_cir)
            oled_display = red;
        else if (inside_sqr_bord) begin
            if (inside_sqr_ins) begin
                if(inside_num) 
                    oled_display = green;
                else
                oled_display = black;
            end
            else
                oled_display = white;
        end
        else
            oled_display = black;
    end
    
endmodule
