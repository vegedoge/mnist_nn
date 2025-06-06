module conv1_calc_1(
//    input clk,
//    input rst_n,
    input valid_in_buf,
    input pixel_0, pixel_1, pixel_2,
        pixel_3, pixel_4, pixel_5,
        pixel_6, pixel_7, pixel_8,
    output reg conv1_out_1, conv1_out_2, conv1_out_3, conv1_out_4,
        conv1_out_5, conv1_out_6, conv1_out_7, conv1_out_8,
    output reg valid_out_conv1
);
    localparam KERNEL_SIZE = 3; // 3x3 filter size
    localparam WINDOW_SIZE = 9;
    
    reg w1 [0:WINDOW_SIZE-1]; reg w2 [0:WINDOW_SIZE-1]; reg w3 [0:WINDOW_SIZE-1]; reg w4 [0:WINDOW_SIZE-1]; 
    reg w5 [0:WINDOW_SIZE-1]; reg w6 [0:WINDOW_SIZE-1]; reg w7 [0:WINDOW_SIZE-1]; reg w8 [0:WINDOW_SIZE-1];
    initial begin
        // read the weight from txt file
        $readmemb("../../../../../source/design/weights/conv1/weight_ch1.txt", w1);
        $readmemb("../../../../../source/design/weights/conv1/weight_ch2.txt", w2);
        $readmemb("../../../../../source/design/weights/conv1/weight_ch3.txt", w3);
        $readmemb("../../../../../source/design/weights/conv1/weight_ch4.txt", w4);
        $readmemb("../../../../../source/design/weights/conv1/weight_ch5.txt", w5);
        $readmemb("../../../../../source/design/weights/conv1/weight_ch6.txt", w6);
        $readmemb("../../../../../source/design/weights/conv1/weight_ch7.txt", w7);
        $readmemb("../../../../../source/design/weights/conv1/weight_ch8.txt", w8);
    end
    
    // concatenate all the values into a 9-bit vector
    // we do this for a quick calculation with XNOR
    wire [WINDOW_SIZE-1:0] xnor1, xnor2, xnor3, xnor4, xnor5, xnor6, xnor7, xnor8;
    
    assign xnor1 = { ~(pixel_0 ^ w1[0]), ~(pixel_1 ^ w1[1]), ~(pixel_2 ^ w1[2]),
                     ~(pixel_3 ^ w1[3]), ~(pixel_4 ^ w1[4]), ~(pixel_5 ^ w1[5]),
                     ~(pixel_6 ^ w1[6]), ~(pixel_7 ^ w1[7]), ~(pixel_8 ^ w1[8]) };
                     
    assign xnor2 = { ~(pixel_0 ^ w2[0]), ~(pixel_1 ^ w2[1]), ~(pixel_2 ^ w2[2]),
                     ~(pixel_3 ^ w2[3]), ~(pixel_4 ^ w2[4]), ~(pixel_5 ^ w2[5]),
                     ~(pixel_6 ^ w2[6]), ~(pixel_7 ^ w2[7]), ~(pixel_8 ^ w2[8]) };
                     
    assign xnor3 = { ~(pixel_0 ^ w3[0]), ~(pixel_1 ^ w3[1]), ~(pixel_2 ^ w3[2]),
                     ~(pixel_3 ^ w3[3]), ~(pixel_4 ^ w3[4]), ~(pixel_5 ^ w3[5]),
                     ~(pixel_6 ^ w3[6]), ~(pixel_7 ^ w3[7]), ~(pixel_8 ^ w3[8]) };
                     
    assign xnor4 = { ~(pixel_0 ^ w4[0]), ~(pixel_1 ^ w4[1]), ~(pixel_2 ^ w4[2]),
                     ~(pixel_3 ^ w4[3]), ~(pixel_4 ^ w4[4]), ~(pixel_5 ^ w4[5]),
                     ~(pixel_6 ^ w4[6]), ~(pixel_7 ^ w4[7]), ~(pixel_8 ^ w4[8]) };
    
    assign xnor5 = { ~(pixel_0 ^ w5[0]), ~(pixel_1 ^ w5[1]), ~(pixel_2 ^ w5[2]),
                     ~(pixel_3 ^ w5[3]), ~(pixel_4 ^ w5[4]), ~(pixel_5 ^ w5[5]),
                     ~(pixel_6 ^ w5[6]), ~(pixel_7 ^ w5[7]), ~(pixel_8 ^ w5[8]) };
                     
    assign xnor6 = { ~(pixel_0 ^ w6[0]), ~(pixel_1 ^ w6[1]), ~(pixel_2 ^ w6[2]),
                     ~(pixel_3 ^ w6[3]), ~(pixel_4 ^ w6[4]), ~(pixel_5 ^ w6[5]),
                     ~(pixel_6 ^ w6[6]), ~(pixel_7 ^ w6[7]), ~(pixel_8 ^ w6[8]) };
                     
    assign xnor7 = { ~(pixel_0 ^ w7[0]), ~(pixel_1 ^ w7[1]), ~(pixel_2 ^ w7[2]),
                     ~(pixel_3 ^ w7[3]), ~(pixel_4 ^ w7[4]), ~(pixel_5 ^ w7[5]),
                     ~(pixel_6 ^ w7[6]), ~(pixel_7 ^ w7[7]), ~(pixel_8 ^ w7[8]) };
                     
    assign xnor8 = { ~(pixel_0 ^ w8[0]), ~(pixel_1 ^ w8[1]), ~(pixel_2 ^ w8[2]),
                     ~(pixel_3 ^ w8[3]), ~(pixel_4 ^ w8[4]), ~(pixel_5 ^ w8[5]),
                     ~(pixel_6 ^ w8[6]), ~(pixel_7 ^ w8[7]), ~(pixel_8 ^ w8[8]) };
                    
    // calculate the popcount
    function [3:0] popcount9;
        input [8:0] bits;
        integer idx;
        begin
            popcount9 = 0;
            for (idx = 0; idx < 9; idx = idx + 1) begin
                popcount9 = popcount9 + bits[idx];
            end
        end
    endfunction 
    
    wire [3:0] cnt1 = popcount9(xnor1);
    wire [3:0] cnt2 = popcount9(xnor2);
    wire [3:0] cnt3 = popcount9(xnor3);
    wire [3:0] cnt4 = popcount9(xnor4);
    wire [3:0] cnt5 = popcount9(xnor5);
    wire [3:0] cnt6 = popcount9(xnor6);
    wire [3:0] cnt7 = popcount9(xnor7);
    wire [3:0] cnt8 = popcount9(xnor8);
    
    always @(*) begin
        if (valid_in_buf) begin
            conv1_out_1 = (cnt1 >= 4'd5) ? 1'b1 : 1'b0;
            conv1_out_2 = (cnt2 >= 4'd5) ? 1'b1 : 1'b0;
            conv1_out_3 = (cnt3 >= 4'd5) ? 1'b1 : 1'b0;
            conv1_out_4 = (cnt4 >= 4'd5) ? 1'b1 : 1'b0;
            conv1_out_5 = (cnt5 >= 4'd5) ? 1'b1 : 1'b0;
            conv1_out_6 = (cnt6 >= 4'd5) ? 1'b1 : 1'b0;
            conv1_out_7 = (cnt7 >= 4'd5) ? 1'b1 : 1'b0;
            conv1_out_8 = (cnt8 >= 4'd5) ? 1'b1 : 1'b0;
            valid_out_conv1 = 1'b1;
        end else begin
            conv1_out_1 = 1'b0;
            conv1_out_2 = 1'b0;
            conv1_out_3 = 1'b0;
            conv1_out_4 = 1'b0;
            conv1_out_5 = 1'b0;
            conv1_out_6 = 1'b0;
            conv1_out_7 = 1'b0;
            conv1_out_8 = 1'b0;
            valid_out_conv1 = 1'b0;
        end
    end
//    always @(posedge clk or negedge rst_n) begin 
//        if (!rst_n) begin
//            conv1_out_1 <= 1'b0;
//            conv1_out_2 <= 1'b0;
//            conv1_out_3 <= 1'b0;
//            conv1_out_4 <= 1'b0;
//            conv1_out_5 <= 1'b0;
//            conv1_out_6 <= 1'b0;
//            conv1_out_7 <= 1'b0;
//            conv1_out_8 <= 1'b0;
//            valid_out_conv1 <= 1'b0;
//        end else begin
//            if (valid_in_buf) begin
//                conv1_out_1 <= (cnt1 >= 4'd5) ? 1'b1 : 1'b0;
//                conv1_out_2 <= (cnt2 >= 4'd5) ? 1'b1 : 1'b0;
//                conv1_out_3 <= (cnt3 >= 4'd5) ? 1'b1 : 1'b0;
//                conv1_out_4 <= (cnt4 >= 4'd5) ? 1'b1 : 1'b0;
//                conv1_out_5 <= (cnt5 >= 4'd5) ? 1'b1 : 1'b0;
//                conv1_out_6 <= (cnt6 >= 4'd5) ? 1'b1 : 1'b0;
//                conv1_out_7 <= (cnt7 >= 4'd5) ? 1'b1 : 1'b0;
//                conv1_out_8 <= (cnt8 >= 4'd5) ? 1'b1 : 1'b0;
//                valid_out_conv1 <= 1'b1;
//            end else begin
//                conv1_out_1 <= 1'b0;
//                conv1_out_2 <= 1'b0;
//                conv1_out_3 <= 1'b0;
//                conv1_out_4 <= 1'b0;
//                conv1_out_5 <= 1'b0;
//                conv1_out_6 <= 1'b0;
//                conv1_out_7 <= 1'b0;
//                conv1_out_8 <= 1'b0;
//                valid_out_conv1 <= 1'b0;
//            end
//        end
//    end
endmodule