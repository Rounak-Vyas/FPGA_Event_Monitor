`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2026 15:18:05
// Design Name: 
// Module Name: switch_led_test
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



module switch_led_test (
    input  wire [16:1] SLIDE_SW,
    output wire [16:1] LED
);

    assign LED[16:1] = SLIDE_SW[16:1];

endmodule
