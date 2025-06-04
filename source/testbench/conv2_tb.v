`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/04 15:24:45
// Design Name: 
// Module Name: conv2_tb
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


module conv2_tb();

    reg clk;
    reg rst_n;
    
    reg valid_in_buf;
    reg [71:0] pixel_windows;
    
    wire [15:0] conv2_out_vec;
    wire valid_out_conv2;
    
    wire conv2_out_1;  //= conv2_out_vec[0];
    wire conv2_out_2;  //= conv2_out_vec[1];
    wire conv2_out_3;  //= conv2_out_vec[2];
    wire conv2_out_4;  //= conv2_out_vec[3];
    wire conv2_out_5;  //= conv2_out_vec[4];
    wire conv2_out_6;  //= conv2_out_vec[5];
    wire conv2_out_7;  //= conv2_out_vec[6];
    wire conv2_out_8;  //= conv2_out_vec[7];
    wire conv2_out_9;  //= conv2_out_vec[8];
    wire conv2_out_10; //= conv2_out_vec[9];
    wire conv2_out_11; //= conv2_out_vec[10];
    wire conv2_out_12; //= conv2_out_vec[11];
    wire conv2_out_13; //= conv2_out_vec[12];
    wire conv2_out_14; //= conv2_out_vec[13];
    wire conv2_out_15;//= conv2_out_vec[14];
    wire conv2_out_16; //= conv2_out_vec[15];
    
    
    conv2_calc_2 dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in_buf(valid_in_buf),
        .pixel_windows(pixel_windows),
        .conv2_out(conv2_out_vec),
//        .conv2_out_1(conv2_out_1),
//        .conv2_out_2(conv2_out_2),
//        .conv2_out_3(conv2_out_3),
//        .conv2_out_4(conv2_out_4),
//        .conv2_out_5(conv2_out_5),
//        .conv2_out_6(conv2_out_6),
//        .conv2_out_7(conv2_out_7),
//        .conv2_out_8(conv2_out_8),
//        .conv2_out_9(conv2_out_9),
//        .conv2_out_10(conv2_out_10),
//        .conv2_out_11(conv2_out_11),
//        .conv2_out_12(conv2_out_12),
//        .conv2_out_13(conv2_out_13),
//        .conv2_out_14(conv2_out_14),
//        .conv2_out_15(conv2_out_15),
//        .conv2_out_16(conv2_out_16),
        .valid_out_conv2(valid_out_conv2)
    );
    
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    
    initial begin
        rst_n = 1'b1;
        valid_in_buf = 1'b0;
        pixel_windows = 72'b0;
        
        #10;
        rst_n = 1'b0;
        #10;
        rst_n = 1'b1;
        #10;
        
        // test case : All ones window
        $display("Test Begin");
        pixel_windows = 72'hFFF_FFFF_FFFF_FFFF;
        valid_in_buf = 1'b1;
        #20;
        valid_in_buf = 1'b0;
        
        wait(valid_out_conv2 == 1'b1);
        $display("[%0t] Test1: pixel_windows = 0x%018h => conv2_out = %b",
                 $time, pixel_windows, conv2_out_vec);
        
        $display("Test End");
        $finish;
        
    end
    
    
    
//    parameter IMG_WIDTH = 13;
//    parameter IMG_HEIGHT = 13;
//    parameter NUM_IN_CH = 8;
//    parameter NUM_OUT_CH = 16;


//    reg clk;
//    reg rst_n;
//    reg [7:0] pixel_in; // for 8 channels
    
//    wire [15:0] conv2_out;
//    wire valid_out_conv2;
    
//    reg [IMG_WIDTH*IMG_HEIGHT-1:0] test_image [0:NUM_IN_CH-1];
//    reg [IMG_WIDTH*IMG_HEIGHT-1:0] output_results [0:NUM_OUT_CH-1];
    
//    conv_layer_2 conv2_test_inst (
//        .clk(clk),
//        .rst_n(rst_n),
//        .pixel_in_1(pixel_in[0]),
//        .pixel_in_2(pixel_in[1]),
//        .pixel_in_3(pixel_in[2]),
//        .pixel_in_4(pixel_in[3]),
//        .pixel_in_5(pixel_in[4]),
//        .pixel_in_6(pixel_in[5]),
//        .pixel_in_7(pixel_in[6]),
//        .pixel_in_8(pixel_in[7]),
//        .conv2_out_1(conv2_out[0]),
//        .conv2_out_2(conv2_out[1]),
//        .conv2_out_3(conv2_out[2]),
//        .conv2_out_4(conv2_out[3]),
//        .conv2_out_5(conv2_out[4]),
//        .conv2_out_6(conv2_out[5]),
//        .conv2_out_7(conv2_out[6]),
//        .conv2_out_8(conv2_out[7]),
//        .conv2_out_9(conv2_out[8]),
//        .conv2_out_10(conv2_out[9]),
//        .conv2_out_11(conv2_out[10]),
//        .conv2_out_12(conv2_out[11]),
//        .conv2_out_13(conv2_out[12]),
//        .conv2_out_14(conv2_out[13]),
//        .conv2_out_15(conv2_out[14]),
//        .conv2_out_16(conv2_out[15]),
//        .valid_out_conv2(valid_out_conv2)
//    );
    
//    initial begin
//        clk = 1;
//        forever #5 clk = ~clk;
//    end
    
//    initial begin
//        rst_n = 1;
//        // reset the system
//        #10;
//        rst_n = 0;
//        #10;
//        rst_n = 1;
//    end
    
//    integer ch, i;
//    initial begin
        
//        for (ch = 0; ch < NUM_IN_CH; ch = ch + 1) begin
//            test_image[ch] = 0;
//        end
        
//        // vertical line in channel 0
//        for (i = 2; i < IMG_HEIGHT - 2; i = i + 1) begin
//            test_image[0][i*IMG_WIDTH + 5] = 1;
//            test_image[0][i*IMG_WIDTH + 6] = 1;
//            test_image[0][i*IMG_WIDTH + 7] = 1;
//        end
//    end
    
//    integer row, col, pixel_idx;
//    initial begin
        
//        for (ch = 0; ch < NUM_OUT_CH; ch = ch + 1) begin
//            output_results[ch] = 0;
//        end
        
//        // streamming the input img
//        $display("Conv2 Test Begin");
//        for (row = 0; row < IMG_HEIGHT; row = row + 1) begin
//            for (col = 0; col < IMG_WIDTH; col = col + 1) begin
//                pixel_idx = row * IMG_WIDTH + col;
//                for (ch = 0; ch < NUM_IN_CH; ch = ch + 1) begin
//                    pixel_in[ch] = test_image[ch][pixel_idx];
//                end
//                #10;
//            end
//        end
        
//        #200;
//        $display("Conv2 Test End");
//    end
    
//    // collect the output
//    always @(posedge clk) begin
//        if (valid_out_conv2) begin
            
//        end
    
//    end
    


endmodule
