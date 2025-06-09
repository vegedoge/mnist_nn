module conv1_calc_8b(
    input valid_in_buf,
    input [7:0] pixel_0, pixel_1, pixel_2,
        pixel_3, pixel_4, pixel_5,
        pixel_6, pixel_7, pixel_8,
    output reg conv1_out_1, conv1_out_2, conv1_out_3, conv1_out_4,
        conv1_out_5, conv1_out_6, conv1_out_7, conv1_out_8,
    output reg valid_out_conv1
);
    localparam KERNEL_SIZE = 3; // 3x3 filter size
    localparam WINDOW_SIZE = 9;
//    localparam [6:0] THRESH = 7'd5;
    localparam signed [11:0] THRESH = 12'sd0;
        
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
    
//    wire signed [11:0] sum1, sum2, sum3, sum4, sum5, sum6, sum7, sum8;
//    assign sum1 = 

    // expand the pixel bits
    wire signed [11:0] pix_ext [0:WINDOW_SIZE-1];
    assign pix_ext[0] = {4'b0000, pixel_0};
    assign pix_ext[1] = {4'b0000, pixel_1};
    assign pix_ext[2] = {4'b0000, pixel_2};
    assign pix_ext[3] = {4'b0000, pixel_3};
    assign pix_ext[4] = {4'b0000, pixel_4};
    assign pix_ext[5] = {4'b0000, pixel_5};
    assign pix_ext[6] = {4'b0000, pixel_6};
    assign pix_ext[7] = {4'b0000, pixel_7};
    assign pix_ext[8] = {4'b0000, pixel_8};
    
    wire signed [11:0] sum1 = (w1[0] ? pix_ext[0] : -pix_ext[0]) + (w1[1] ? pix_ext[1] : -pix_ext[1]) + (w1[2] ? pix_ext[2] : -pix_ext[2]) +
                              (w1[3] ? pix_ext[3] : -pix_ext[3]) + (w1[4] ? pix_ext[4] : -pix_ext[4]) + (w1[5] ? pix_ext[5] : -pix_ext[5]) +
                              (w1[6] ? pix_ext[6] : -pix_ext[6]) + (w1[7] ? pix_ext[7] : -pix_ext[7]) + (w1[8] ? pix_ext[8] : -pix_ext[8]);
                                 
    wire signed [11:0] sum2 = (w2[0] ? pix_ext[0] : -pix_ext[0]) + (w2[1] ? pix_ext[1] : -pix_ext[1]) + (w2[2] ? pix_ext[2] : -pix_ext[2]) +
                              (w2[3] ? pix_ext[3] : -pix_ext[3]) + (w2[4] ? pix_ext[4] : -pix_ext[4]) + (w2[5] ? pix_ext[5] : -pix_ext[5]) +
                              (w2[6] ? pix_ext[6] : -pix_ext[6]) + (w2[7] ? pix_ext[7] : -pix_ext[7]) + (w2[8] ? pix_ext[8] : -pix_ext[8]);
                                 
    wire signed [11:0] sum3 = (w3[0] ? pix_ext[0] : -pix_ext[0]) + (w3[1] ? pix_ext[1] : -pix_ext[1]) + (w3[2] ? pix_ext[2] : -pix_ext[2]) +
                              (w3[3] ? pix_ext[3] : -pix_ext[3]) + (w3[4] ? pix_ext[4] : -pix_ext[4]) + (w3[5] ? pix_ext[5] : -pix_ext[5]) +
                              (w3[6] ? pix_ext[6] : -pix_ext[6]) + (w3[7] ? pix_ext[7] : -pix_ext[7]) + (w3[8] ? pix_ext[8] : -pix_ext[8]);
    
    wire signed [11:0] sum4 = (w4[0] ? pix_ext[0] : -pix_ext[0]) + (w4[1] ? pix_ext[1] : -pix_ext[1]) + (w4[2] ? pix_ext[2] : -pix_ext[2]) +
                              (w4[3] ? pix_ext[3] : -pix_ext[3]) + (w4[4] ? pix_ext[4] : -pix_ext[4]) + (w4[5] ? pix_ext[5] : -pix_ext[5]) +
                              (w4[6] ? pix_ext[6] : -pix_ext[6]) + (w4[7] ? pix_ext[7] : -pix_ext[7]) + (w4[8] ? pix_ext[8] : -pix_ext[8]);
                              
    wire signed [11:0] sum5 = (w5[0] ? pix_ext[0] : -pix_ext[0]) + (w5[1] ? pix_ext[1] : -pix_ext[1]) + (w5[2] ? pix_ext[2] : -pix_ext[2]) +
                              (w5[3] ? pix_ext[3] : -pix_ext[3]) + (w5[4] ? pix_ext[4] : -pix_ext[4]) + (w5[5] ? pix_ext[5] : -pix_ext[5]) +
                              (w5[6] ? pix_ext[6] : -pix_ext[6]) + (w5[7] ? pix_ext[7] : -pix_ext[7]) + (w5[8] ? pix_ext[8] : -pix_ext[8]);
                              
    wire signed [11:0] sum6 = (w6[0] ? pix_ext[0] : -pix_ext[0]) + (w6[1] ? pix_ext[1] : -pix_ext[1]) + (w6[2] ? pix_ext[2] : -pix_ext[2]) +
                              (w6[3] ? pix_ext[3] : -pix_ext[3]) + (w6[4] ? pix_ext[4] : -pix_ext[4]) + (w6[5] ? pix_ext[5] : -pix_ext[5]) +
                              (w6[6] ? pix_ext[6] : -pix_ext[6]) + (w6[7] ? pix_ext[7] : -pix_ext[7]) + (w6[8] ? pix_ext[8] : -pix_ext[8]);
                              
    wire signed [11:0] sum7 = (w7[0] ? pix_ext[0] : -pix_ext[0]) + (w7[1] ? pix_ext[1] : -pix_ext[1]) + (w7[2] ? pix_ext[2] : -pix_ext[2]) +
                              (w7[3] ? pix_ext[3] : -pix_ext[3]) + (w7[4] ? pix_ext[4] : -pix_ext[4]) + (w7[5] ? pix_ext[5] : -pix_ext[5]) +
                              (w7[6] ? pix_ext[6] : -pix_ext[6]) + (w7[7] ? pix_ext[7] : -pix_ext[7]) + (w7[8] ? pix_ext[8] : -pix_ext[8]);
                              
    wire signed [11:0] sum8 = (w8[0] ? pix_ext[0] : -pix_ext[0]) + (w8[1] ? pix_ext[1] : -pix_ext[1]) + (w8[2] ? pix_ext[2] : -pix_ext[2]) +
                              (w8[3] ? pix_ext[3] : -pix_ext[3]) + (w8[4] ? pix_ext[4] : -pix_ext[4]) + (w8[5] ? pix_ext[5] : -pix_ext[5]) +
                              (w8[6] ? pix_ext[6] : -pix_ext[6]) + (w8[7] ? pix_ext[7] : -pix_ext[7]) + (w8[8] ? pix_ext[8] : -pix_ext[8]);

    
    always @(*) begin
        if (valid_in_buf) begin
            conv1_out_1 = (sum1 > THRESH) ? 1'b1 : 1'b0;
            conv1_out_2 = (sum2 > THRESH) ? 1'b1 : 1'b0;
            conv1_out_3 = (sum3 > THRESH) ? 1'b1 : 1'b0;
            conv1_out_4 = (sum4 > THRESH) ? 1'b1 : 1'b0;
            conv1_out_5 = (sum5 > THRESH) ? 1'b1 : 1'b0;
            conv1_out_6 = (sum6 > THRESH) ? 1'b1 : 1'b0;
            conv1_out_7 = (sum7 > THRESH) ? 1'b1 : 1'b0;
            conv1_out_8 = (sum8 > THRESH) ? 1'b1 : 1'b0;
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

    
    
//    always @(*) begin
//        if (valid_in_buf) begin
//            conv1_out_1 = (cnt1 >= THRESH) ? 1'b1 : 1'b0;
//            conv1_out_2 = (cnt2 >= THRESH) ? 1'b1 : 1'b0;
//            conv1_out_3 = (cnt3 >= THRESH) ? 1'b1 : 1'b0;
//            conv1_out_4 = (cnt4 >= THRESH) ? 1'b1 : 1'b0;
//            conv1_out_5 = (cnt5 >= THRESH) ? 1'b1 : 1'b0;
//            conv1_out_6 = (cnt6 >= THRESH) ? 1'b1 : 1'b0;
//            conv1_out_7 = (cnt7 >= THRESH) ? 1'b1 : 1'b0;
//            conv1_out_8 = (cnt8 >= THRESH) ? 1'b1 : 1'b0;
//            valid_out_conv1 = 1'b1;
//        end else begin
//            conv1_out_1 = 1'b0;
//            conv1_out_2 = 1'b0;
//            conv1_out_3 = 1'b0;
//            conv1_out_4 = 1'b0;
//            conv1_out_5 = 1'b0;
//            conv1_out_6 = 1'b0;
//            conv1_out_7 = 1'b0;
//            conv1_out_8 = 1'b0;
//            valid_out_conv1 = 1'b0;
//        end
//    end
endmodule