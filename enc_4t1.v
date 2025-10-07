`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 04:52:12 PM
// Design Name: 
// Module Name: enc_4t1
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


module enc_4t1(
    input clk,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    output reg [2:0] dir
    );
    reg up, down, left, right;
   
    initial begin
        dir = 0;
        up = 0; down = 0; left = 0; right = 0;
    end
    
    always @(posedge clk) begin
        if (btnU) begin
            up <= btnU;
            down <= ~btnU; left <= ~btnU; right <= ~btnU;
        end
        if (btnD) begin
            down <= btnD;
            up <= ~btnD; left <= ~btnD; right <= ~btnD;
        end
        if (btnL) begin
            left <= btnL;
            up <= ~btnL; down <= ~btnL; right <= ~btnL;
        end
        if (btnR) begin
            right <= btnR;
            up <= ~btnR; down <= ~btnR; left <= ~btnR;
        end
    end
    
    always @(*) begin
        if (up)           
            dir = 1;
        else if (down)           
            dir = 3;
        else if (right)
            dir = 2;
        else if (left)
            dir = 4;
        else
            dir = 0;
    end
endmodule
