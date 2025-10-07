`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 10:58:17 PM
// Design Name: 
// Module Name: clk_40
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


module clk_40(
    input clk6p25m,
    output reg clk_40
    );
    reg [17:0] counter;
    
    initial begin
        counter = 0;
        clk_40 = 0;
    end
    always @(posedge clk6p25m) begin
        counter <= (counter == 156250) ? 0 : counter + 1;
        clk_40 <= (counter == 0) ? ~clk_40 : clk_40;
    end
endmodule
