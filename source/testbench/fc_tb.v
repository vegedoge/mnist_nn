`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/05 21:33:36
// Design Name: 
// Module Name: fc_tb
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


module fc_tb();
    reg clk;
    reg rst_n;
    
    reg valid_in;
    reg pixel_in_1,  pixel_in_2,  pixel_in_3,  pixel_in_4;
    reg pixel_in_5,  pixel_in_6,  pixel_in_7,  pixel_in_8;
    reg pixel_in_9,  pixel_in_10, pixel_in_11, pixel_in_12;
    reg pixel_in_13, pixel_in_14, pixel_in_15, pixel_in_16;
    
    wire [8:0] fc_out_1;
    wire [8:0] fc_out_2;
    wire [8:0] fc_out_3;
    wire [8:0] fc_out_4;
    wire [8:0] fc_out_5;
    wire [8:0] fc_out_6;
    wire [8:0] fc_out_7;
    wire [8:0] fc_out_8;
    wire [8:0] fc_out_9;
    wire [8:0] fc_out_10;
    wire valid_out_fc;
    
    fully_connected #(
        .INPUT_NUM(400),
        .OUTPUT_NUM(10)
    ) fc_test (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .pixel_in_1(pixel_in_1),
        .pixel_in_2(pixel_in_2),
        .pixel_in_3(pixel_in_3),
        .pixel_in_4(pixel_in_4),
        .pixel_in_5(pixel_in_5),
        .pixel_in_6(pixel_in_6),
        .pixel_in_7(pixel_in_7),
        .pixel_in_8(pixel_in_8),
        .pixel_in_9(pixel_in_9),
        .pixel_in_10(pixel_in_10),
        .pixel_in_11(pixel_in_11),
        .pixel_in_12(pixel_in_12),
        .pixel_in_13(pixel_in_13),
        .pixel_in_14(pixel_in_14),
        .pixel_in_15(pixel_in_15),
        .pixel_in_16(pixel_in_16),
        .fc_out_1(fc_out_1),
        .fc_out_2(fc_out_2),
        .fc_out_3(fc_out_3),
        .fc_out_4(fc_out_4),
        .fc_out_5(fc_out_5),
        .fc_out_6(fc_out_6),
        .fc_out_7(fc_out_7),
        .fc_out_8(fc_out_8),
        .fc_out_9(fc_out_9),
        .fc_out_10(fc_out_10),
        .valid_out_fc(valid_out_fc)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    integer i;
    initial begin
        $display("FC Test Begin");
        rst_n = 1'b1;
        #10;
        rst_n = 1'b0;
        valid_in = 1'b0;
        {pixel_in_1, pixel_in_2, pixel_in_3, pixel_in_4,
         pixel_in_5, pixel_in_6, pixel_in_7, pixel_in_8,
         pixel_in_9, pixel_in_10,pixel_in_11,pixel_in_12,
         pixel_in_13,pixel_in_14,pixel_in_15,pixel_in_16} = 16'b0;
        
        #25;
        rst_n = 1'b1;
        
        // All pixels input are 1
        for (i = 0; i < 25; i = i + 1) begin
            valid_in = 1;
            {pixel_in_1, pixel_in_2, pixel_in_3, pixel_in_4,
             pixel_in_5, pixel_in_6, pixel_in_7, pixel_in_8,
             pixel_in_9, pixel_in_10,pixel_in_11,pixel_in_12,
             pixel_in_13,pixel_in_14,pixel_in_15,pixel_in_16} = 16'hFFFF; // all 1
            #10;
        end
        valid_in = 0;
        {pixel_in_1, pixel_in_2, pixel_in_3, pixel_in_4,
         pixel_in_5, pixel_in_6, pixel_in_7, pixel_in_8,
         pixel_in_9, pixel_in_10,pixel_in_11,pixel_in_12,
         pixel_in_13,pixel_in_14,pixel_in_15,pixel_in_16} = 16'b0;
         
        wait(valid_out_fc == 1);
        $display("FC Test End");
        #20;
        $finish;
    end
    
endmodule
