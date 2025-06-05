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
    
    reg pixel_in_1; // 8 single-bit inputs
    reg pixel_in_2;
    reg pixel_in_3;
    reg pixel_in_4;
    reg pixel_in_5;
    reg pixel_in_6;
    reg pixel_in_7;
    reg pixel_in_8;
    
    wire conv2_out_1; // output from conv2_calc
    wire conv2_out_2;
    wire conv2_out_3;
    wire conv2_out_4;
    wire conv2_out_5;
    wire conv2_out_6;
    wire conv2_out_7;
    wire conv2_out_8;
    wire conv2_out_9;
    wire conv2_out_10;
    wire conv2_out_11;
    wire conv2_out_12;
    wire conv2_out_13;
    wire conv2_out_14;
    wire conv2_out_15;
    wire conv2_out_16;
    wire valid_out_conv2;
    
    conv_layer_2 conv2_layer_test (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_in_1(pixel_in_1),
        .pixel_in_2(pixel_in_2),
        .pixel_in_3(pixel_in_3),
        .pixel_in_4(pixel_in_4),
        .pixel_in_5(pixel_in_5),
        .pixel_in_6(pixel_in_6),
        .pixel_in_7(pixel_in_7),
        .pixel_in_8(pixel_in_8),
        .conv2_out_1(conv2_out_1),
        .conv2_out_2(conv2_out_2),
        .conv2_out_3(conv2_out_3),
        .conv2_out_4(conv2_out_4),
        .conv2_out_5(conv2_out_5),
        .conv2_out_6(conv2_out_6),
        .conv2_out_7(conv2_out_7),
        .conv2_out_8(conv2_out_8),
        .conv2_out_9(conv2_out_9),
        .conv2_out_10(conv2_out_10),
        .conv2_out_11(conv2_out_11),
        .conv2_out_12(conv2_out_12),
        .conv2_out_13(conv2_out_13),
        .conv2_out_14(conv2_out_14),
        .conv2_out_15(conv2_out_15),
        .conv2_out_16(conv2_out_16),
        .valid_out_conv2(valid_out_conv2)
    );
    
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    integer cycle_cnt, i, j;
    
    initial begin
        rst_n = 1'b1;
        
        #10 // reset all things
        rst_n = 1'b0;
        pixel_in_1 = 1'b0;
        pixel_in_2 = 1'b0;
        pixel_in_3 = 1'b0;
        pixel_in_4 = 1'b0;
        pixel_in_5 = 1'b0;
        pixel_in_6 = 1'b0;
        pixel_in_7 = 1'b0;
        pixel_in_8 = 1'b0;
        cycle_cnt = 0;
        #20;
        rst_n = 1'b1;
//        #10;
        
        for (i = 0; i < 13; i = i + 1) begin
            for (j = 0; j < 13; j = j + 1) begin
                cycle_cnt = cycle_cnt + 1;
                {pixel_in_8, pixel_in_7, pixel_in_6, pixel_in_5, pixel_in_4, pixel_in_3, pixel_in_2, pixel_in_1} = cycle_cnt[7:0];
                #20;
            end
        end
        
        
        #20;
//     End simulation after 1000 cycles
        if (cycle_cnt == 168) begin
            $display("Simulation finished after %0d cycles.", cycle_cnt);
            #20;
            $finish;
        end 
        
        
//        forever begin
//            @(posedge clk);
//            cycle_cnt = cycle_cnt + 1;
//            {pixel_in_8, pixel_in_7, pixel_in_6, pixel_in_5, pixel_in_4, pixel_in_3, pixel_in_2, pixel_in_1} = cycle_cnt[7:0];
            
////            pixel_in_1 <= cycle_cnt[0]; // each bit drives one channel pixels
////            pixel_in_2 <= cycle_cnt[1];
////            pixel_in_3 <= cycle_cnt[2];
////            pixel_in_4 <= cycle_cnt[3];
////            pixel_in_5 <= cycle_cnt[4];
////            pixel_in_6 <= cycle_cnt[5];
////            pixel_in_7 <= cycle_cnt[6];
////            pixel_in_8 <= cycle_cnt[7];
            
//            // When valid_out_conv2 goes high, display the 16‐bit output vector
//            if (valid_out_conv2) begin
//                $display("[%0t] valid_out_conv2=1, conv2_out = %b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b",
//                         $time,
//                         conv2_out_16, conv2_out_15, conv2_out_14, conv2_out_13,
//                         conv2_out_12, conv2_out_11, conv2_out_10, conv2_out_9,
//                         conv2_out_8,  conv2_out_7,  conv2_out_6,  conv2_out_5,
//                         conv2_out_4,  conv2_out_3,  conv2_out_2,  conv2_out_1);
//            end

//            // End simulation after 1000 cycles
//            if (cycle_cnt == 1000) begin
//                $display("Simulation finished after %0d cycles.", cycle_cnt);
//                #20;
//                $finish;
//            end 
//        end
    end
endmodule
