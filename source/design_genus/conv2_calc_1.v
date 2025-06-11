module conv2_calc_2 (
//    input clk,
//    input rst_n,
    input valid_in_buf,
    input [71:0] pixel_windows,
    output reg [15:0] conv2_out,
    output reg valid_out_conv2
);
    localparam WINDOW_SIZE = 72; // 3x3x8 for one output channel
    localparam [6:0] THRESH = 7'd36;
    
//    reg w1 [0:WINDOW_SIZE-1]; // each stores the weights for one output channel
//    reg w2 [0:WINDOW_SIZE-1];
//    reg w3 [0:WINDOW_SIZE-1];
//    reg w4 [0:WINDOW_SIZE-1];
//    reg w5 [0:WINDOW_SIZE-1];
//    reg w6 [0:WINDOW_SIZE-1];
//    reg w7 [0:WINDOW_SIZE-1];
//    reg w8 [0:WINDOW_SIZE-1];
//    reg w9 [0:WINDOW_SIZE-1];
//    reg w10 [0:WINDOW_SIZE-1];
//    reg w11 [0:WINDOW_SIZE-1];
//    reg w12 [0:WINDOW_SIZE-1];
//    reg w13 [0:WINDOW_SIZE-1];
//    reg w14 [0:WINDOW_SIZE-1];
//    reg w15 [0:WINDOW_SIZE-1];
//    reg w16 [0:WINDOW_SIZE-1];
    
//    initial begin
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch1.txt",  w1);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch2.txt",  w2);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch3.txt",  w3);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch4.txt",  w4);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch5.txt",  w5);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch6.txt",  w6);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch7.txt",  w7);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch8.txt",  w8);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch9.txt",  w9);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch10.txt", w10);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch11.txt", w11);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch12.txt", w12);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch13.txt", w13);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch14.txt", w14);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch15.txt", w15);
//        $readmemb("../../../../../source/design/weights/conv2/weight_ch16.txt", w16);
//    end
    
    localparam w1 = 72'b011111100001000000110111110001001011110110110001000000011011010000101111;
    localparam w2 = 72'b000000111011000010100111111000000010000000000000000111000111000111111111;
    localparam w3 = 72'b111011010000010000010010110101101001011011111000001011100001001001001001;
    localparam w4 = 72'b111011010000010000010010110101101001011011111000001011100001001001001001;
    localparam w5 = 72'b111111100111101001111111101000001011110111111001010101100001001100000011;
    localparam w6 = 72'b111111100111101001111111101000001011110111111001010101100001001100000011;
    localparam w7 = 72'b111110101001001010110111111001010100100101111011110001100011110100000010;
    localparam w8 = 72'b000100100000011000011111000110000111111011000101111111111000010100111000;
    localparam w9 = 72'b111110100000000111111111000000000111011111001001111111101001000000111000;
    localparam w10 = 72'b011000011000100000111000111001110000000000010111110001000111111101000111;
    localparam w11 = 72'b100111110011000001111001101011000101001100101010011001100110111100111010;
    localparam w12 = 72'b101000001010100100111000100000111000011000001111111001010001100111011111;
    localparam w13 = 72'b110100100000000000000100100010110001111111101010000001010010010100100110;
    localparam w14 =72'b001000111100000000000000101111001000000000000011000111110111011100111111;
    localparam w15 = 72'b111111000000010110111110001000111110111000000111111000000000111111000011;
    localparam w16 = 72'b111111111000000001000000100110010011101110110110110010011010000111011010;
    
    wire [71:0] xnor1;
    wire [71:0] xnor2;
    wire [71:0] xnor3;
    wire [71:0] xnor4;
    wire [71:0] xnor5;
    wire [71:0] xnor6;
    wire [71:0] xnor7;
    wire [71:0] xnor8;
    wire [71:0] xnor9;
    wire [71:0] xnor10;
    wire [71:0] xnor11;
    wire [71:0] xnor12;
    wire [71:0] xnor13;
    wire [71:0] xnor14;
    wire [71:0] xnor15;
    wire [71:0] xnor16;
    
    genvar i;
    generate
        for (i = 0; i < WINDOW_SIZE; i = i + 1) begin: XNOR_LOOP
            assign xnor1[i]  = ~(pixel_windows[i] ^ w1[i]);
            assign xnor2[i]  = ~(pixel_windows[i] ^ w2[i]);
            assign xnor3[i]  = ~(pixel_windows[i] ^ w3[i]);
            assign xnor4[i]  = ~(pixel_windows[i] ^ w4[i]);
            assign xnor5[i]  = ~(pixel_windows[i] ^ w5[i]);
            assign xnor6[i]  = ~(pixel_windows[i] ^ w6[i]);
            assign xnor7[i]  = ~(pixel_windows[i] ^ w7[i]);
            assign xnor8[i]  = ~(pixel_windows[i] ^ w8[i]);
            assign xnor9[i]  = ~(pixel_windows[i] ^ w9[i]);
            assign xnor10[i] = ~(pixel_windows[i] ^ w10[i]);
            assign xnor11[i] = ~(pixel_windows[i] ^ w11[i]);
            assign xnor12[i] = ~(pixel_windows[i] ^ w12[i]);
            assign xnor13[i] = ~(pixel_windows[i] ^ w13[i]);
            assign xnor14[i] = ~(pixel_windows[i] ^ w14[i]);
            assign xnor15[i] = ~(pixel_windows[i] ^ w15[i]);
            assign xnor16[i] = ~(pixel_windows[i] ^ w16[i]);
        end
    endgenerate
    
    function [6:0] popcount72;
        input [71:0] bits;
        integer idx;
        begin 
            popcount72 = 7'd0;
            for (idx = 0; idx < WINDOW_SIZE; idx = idx + 1) begin
                popcount72 = popcount72 + bits[idx];
            end
        end 
    endfunction 
    
    wire [6:0] cnt1  = popcount72(xnor1); // calculatet he popcount for every output channels
    wire [6:0] cnt2  = popcount72(xnor2);
    wire [6:0] cnt3  = popcount72(xnor3);
    wire [6:0] cnt4  = popcount72(xnor4);
    wire [6:0] cnt5  = popcount72(xnor5);
    wire [6:0] cnt6  = popcount72(xnor6);
    wire [6:0] cnt7  = popcount72(xnor7);
    wire [6:0] cnt8  = popcount72(xnor8);
    wire [6:0] cnt9  = popcount72(xnor9);
    wire [6:0] cnt10 = popcount72(xnor10);
    wire [6:0] cnt11 = popcount72(xnor11);
    wire [6:0] cnt12 = popcount72(xnor12);
    wire [6:0] cnt13 = popcount72(xnor13);
    wire [6:0] cnt14 = popcount72(xnor14);
    wire [6:0] cnt15 = popcount72(xnor15);
    wire [6:0] cnt16 = popcount72(xnor16);
    
    always @(*) begin
        if (valid_in_buf) begin
            conv2_out[0] = (cnt1 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[1] = (cnt2 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[2] = (cnt3 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[3] = (cnt4 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[4] = (cnt5 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[5] = (cnt6 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[6] = (cnt7 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[7] = (cnt8 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[8] = (cnt9 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[9] = (cnt10 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[10] = (cnt11 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[11] = (cnt12 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[12] = (cnt13 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[13] = (cnt14 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[14] = (cnt15 > THRESH) ? 1'b1 : 1'b0;
            conv2_out[15] = (cnt16 > THRESH) ? 1'b1 : 1'b0;
            valid_out_conv2 = 1'b1;
        end else begin
            conv2_out = 16'b0;
            valid_out_conv2 = 1'b0;
            
        end 
    end
    
//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            conv2_out <= 16'b0;
//            valid_out_conv2 <= 1'b0;
//        end else begin
//            if (valid_in_buf) begin
//                conv2_out[0] <= (cnt1 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[1] <= (cnt2 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[2] <= (cnt3 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[3] <= (cnt4 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[4] <= (cnt5 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[5] <= (cnt6 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[6] <= (cnt7 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[7] <= (cnt8 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[8] <= (cnt9 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[9] <= (cnt10 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[10] <= (cnt11 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[11] <= (cnt12 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[12] <= (cnt13 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[13] <= (cnt14 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[14] <= (cnt15 >= THRESH) ? 1'b1 : 1'b0;
//                conv2_out[15] <= (cnt16 >= THRESH) ? 1'b1 : 1'b0;
//                valid_out_conv2 <= 1'b1;
//            end else begin
//                conv2_out <= 16'b0;
//                valid_out_conv2 <= 1'b0;
//            end
//        end
//    end

    
    
endmodule 



//    localparam NUM_IN_CH = 8;
//    localparam NUM_OUT_CH = 16;
//    localparam KERNEL_SIZE = 3;
//    localparam WINDOW_SIZE = 9;
//    localparam THRESHOLD = 40; // threshold for accumulator
    
//    reg [WINDOW_SIZE-1:0] weights [0:NUM_OUT_CH-1][0:NUM_IN_CH-1];
    
//    integer out_ch, in_ch;
//    initial begin
//        for (out_ch = 0; out_ch < NUM_OUT_CH; out_ch = out_ch + 1) begin
//            for (in_ch = 0; in_ch < NUM_IN_CH; in_ch = in_ch + 1) begin
//                $readmemb($sformat("../../../../../source/design/weights/conv2/conv2_weight_out%0d_in%0d.txt", out_ch, in_ch), weights[out_ch][in_ch]);
//            end
//        end
//    end
    
//    wire [15:0] conv_out_tmp;
//    wire [6:0] accum [0:NUM_OUT_CH-1];
    
//    genvar ch_out, ch_in;
//    generate
//        for (ch_out = 0; ch_out < NUM_OUT_CH; ch_out = ch_out + 1) begin: OUT_CH
//            wire [3:0] popcount [0:NUM_IN_CH-1]; // store the popcount of every channel
//            for (ch_in = 0; ch_in < NUM_IN_CH; ch_in = ch_in + 1) begin: IN_CH
//                wire [8:0] window = pixel_windows[ch_in*9 +: 9]; // get the current channel window
//                wire [8:0] xnor_res = ~(window ^ weights[ch_out][ch_in]);
//                assign popcount[ch_in] = xnor_res[0] + xnor_res[1] + xnor_res[2] +
//                                         xnor_res[3] + xnor_res[4] + xnor_res[5] +
//                                         xnor_res[6] + xnor_res[7] + xnor_res[8];
//            end
            
//            assign accum[ch_out] = popcount[0] + popcount[1] + popcount[2] + popcount[3] +
//                                    popcount[4] + popcount[5] + popcount[6] + popcount[7];
//            assign conv_out_tmp[ch_out] = (accum[ch_out] >= THRESHOLD);
//        end
//    endgenerate 
    
//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            conv2_out <= 16'b0;
//            valid_out_conv2 <= 1'b0;
//        end else begin
//            valid_out_conv2 <= valid_in_buf;
//            if (valid_in_buf) begin
//                conv2_out <= conv_out_tmp;
//            end else begin
//                conv2_out <= 16'b0;
//            end
//        end
//    end


//module conv2_calc_1(
//    input clk,
//    input rst_n,
//    input valid_in_buf,
//    input pixel_0, pixel_1, pixel_2,
//        pixel_3, pixel_4, pixel_5,
//        pixel_6, pixel_7, pixel_8,
//    output reg conv2_out_1, conv2_out_2, conv2_out_3, conv2_out_4,
//        conv2_out_5, conv2_out_6, conv2_out_7, conv2_out_8,
//        conv2_out_9, conv2_out_10, conv2_out_11, conv2_out_12,
//        conv2_out_13, conv2_out_14, conv2_out_15, conv2_out_16,
//    output reg valid_out_conv2
//);

//endmodule