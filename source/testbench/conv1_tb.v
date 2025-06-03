`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/02 16:22:01
// Design Name: 
// Module Name: conv1_tb
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


module conv1_tb();
    reg clk;
    reg rst_n;
    reg pixel_in;
    wire conv1_out_1, conv1_out_2, conv1_out_3, conv1_out_4;
    wire conv1_out_5, conv1_out_6, conv1_out_7, conv1_out_8;
    wire valid_out_conv1;
    
    conv_layer_1 conv1(
        .clk(clk),
        .rst_n(rst_n),
        .pixel_in(pixel_in),
        .conv1_out_1(conv1_out_1),
        .conv1_out_2(conv1_out_2),
        .conv1_out_3(conv1_out_3),
        .conv1_out_4(conv1_out_4),
        .conv1_out_5(conv1_out_5),
        .conv1_out_6(conv1_out_6),
        .conv1_out_7(conv1_out_7),
        .conv1_out_8(conv1_out_8),
        .valid_out_conv1(valid_out_conv1)
    );
    
    initial begin
        // generate the clock
        clk = 1;
        forever #5 clk = ~clk;
    end
    
    integer i, j, idx;
    reg test_img [0:28 * 28 - 1];
    initial begin
        for (i = 0; i < 28; i = i + 1) begin
            for (j = 0; j < 28; j = j + 1) begin
                test_img[i * 28 + j] = (i + j) % 2;
            end
        end
        
        // initial the signals
        pixel_in = 0;
        rst_n = 1;
        
        // reset the system
        #10;
        rst_n = 0;
        #10;
        rst_n = 1;
        
        $display("Conv1 Layer Test Begin");
        
        // stream the input img
        for (i = 0; i < 28; i = i + 1) begin
            for (j = 0; j < 28; j = j + 1) begin
                pixel_in = test_img[i * 28 + j];
                #10;
            end
        end
        
        #200;
        $display("Conv1 Layer Test End");
        $finish;
    end
    
    integer output_count = 0;
    always @(posedge clk) begin
        if (valid_out_conv1) begin
            output_count = output_count + 1;
            $display("%t ps: Output %0d | Result: %b%b%b%b%b%b%b%b",
                $time, output_count,
                conv1_out_1, conv1_out_2, conv1_out_3, conv1_out_4,
                conv1_out_5, conv1_out_6, conv1_out_7, conv1_out_8);
        end
    end
    
endmodule
