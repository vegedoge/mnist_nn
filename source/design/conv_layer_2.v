module conv_layer_2 (
    input wire clk,
    input wire rst_n,
    input wire pixel_in_1,         // 1-bit input data channel 1
    input wire pixel_in_2,         // 1-bit input data channel 2
    input wire pixel_in_3,         // 1-bit input data
    input wire pixel_in_4,         // 1-bit input data
    input wire pixel_in_5,         // 1-bit input data
    input wire pixel_in_6,         // 1-bit input data
    input wire pixel_in_7,         // 1-bit input data
    input wire pixel_in_8,         // 1-bit input data channel 8
    output conv2_out_1,      // 16 channels output signals for convolution layer 2
    output conv2_out_2,      // each clk one bit output
    output conv2_out_3,
    output conv2_out_4,
    output conv2_out_5,
    output conv2_out_6,
    output conv2_out_7,
    output conv2_out_8,
    output conv2_out_9,
    output conv2_out_10,
    output conv2_out_11,
    output conv2_out_12,
    output conv2_out_13,
    output conv2_out_14,
    output conv2_out_15,
    output conv2_out_16,
    output valid_out_conv2  // signal to indicate valid output
);
    wire [7:0] pixel_in = {
        pixel_in_8, pixel_in_7, pixel_in_6, pixel_in_5,
        pixel_in_4, pixel_in_3, pixel_in_2, pixel_in_1
    };
    
    wire [71:0] pixel_windows; // 3x3x8
    wire valid_buf;
    
    conv2_buf #(
        .WIDTH(13),
        .HEIGHT(13)
    ) conv2_buf_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_in(pixel_in),
        .pixel_windows(pixel_windows),
        .valid_out_buf(valid_buf)
      );
      
    // conv calculation
    wire [15:0] conv2_out_vec;
    
    conv2_calc_2 conv2_cal_inst (
         .clk(clk),
         .rst_n(rst_n),
         .valid_in_buf(valid_buf),
         .pixel_windows(pixel_windows),
         .conv2_out(conv2_out_vec),
         .valid_out_conv2(valid_out_conv2)
     );
     
     assign conv2_out_1 = conv2_out_vec[0];
     assign conv2_out_2 = conv2_out_vec[1];
     assign conv2_out_3 = conv2_out_vec[2];
     assign conv2_out_4 = conv2_out_vec[3];
     assign conv2_out_5 = conv2_out_vec[4];
     assign conv2_out_6 = conv2_out_vec[5];
     assign conv2_out_7 = conv2_out_vec[6];
     assign conv2_out_8 = conv2_out_vec[7];
     assign conv2_out_9 = conv2_out_vec[8];
     assign conv2_out_10 = conv2_out_vec[9];
     assign conv2_out_11 = conv2_out_vec[10];
     assign conv2_out_12 = conv2_out_vec[11];
     assign conv2_out_13 = conv2_out_vec[12];
     assign conv2_out_14 = conv2_out_vec[13];
     assign conv2_out_15 = conv2_out_vec[14];
     assign conv2_out_16 = conv2_out_vec[15];

//// === Channel 1 ===//
//// input pixel buffer for 3x3 conv
//wire pixel_1_0, pixel_1_1, pixel_1_2,
//    pixel_1_3, pixel_1_4, pixel_1_5,
//    pixel_1_6, pixel_1_7, pixel_1_8;
//wire valid_buf_1;
//wire conv2_out_1_1, conv2_out_1_2, conv2_out_1_3, conv2_out_1_4,
//    conv2_out_1_5, conv2_out_1_6, conv2_out_1_7, conv2_out_1_8,
//    conv2_out_1_9, conv2_out_1_10, conv2_out_1_11, conv2_out_1_12,
//    conv2_out_1_13, conv2_out_1_14, conv2_out_1_15, conv2_out_1_16;
//conv1_buf #(
//    .WIDTH(13), 
//    .HEIGHT(13)
//) conv2_buf_inst_1 (
//    .clk(clk),
//    .rst_n(rst_n),
//    .pixel_in(pixel_in_1),
//    .pixel_0(pixel_1_0),
//    .pixel_1(pixel_1_1),
//    .pixel_2(pixel_1_2),
//    .pixel_3(pixel_1_3),
//    .pixel_4(pixel_1_4),
//    .pixel_5(pixel_1_5),
//    .pixel_6(pixel_1_6),
//    .pixel_7(pixel_1_7),
//    .pixel_8(pixel_1_8),
//    .valid_out_buf(valid_buf_1)
//);
//conv2_calc_1 conv2_calc_1_inst (
//    .clk(clk),
//    .rst_n(rst_n),
//    .valid_out_buf(valid_buf_1),
//    .pixel_0(pixel_1_0), 
//    .pixel_1(pixel_1_1), 
//    .pixel_2(pixel_1_2),
//    .pixel_3(pixel_1_3), 
//    .pixel_4(pixel_1_4), 
//    .pixel_5(pixel_1_5),
//    .pixel_6(pixel_1_6), 
//    .pixel_7(pixel_1_7), 
//    .pixel_8(pixel_1_8),
//    .conv2_out_1(), 
//    .conv2_out_2(), 
//    .conv2_out_3(), 
//    .conv2_out_4(),
//    .conv2_out_5(), 
//    .conv2_out_6(), 
//    .conv2_out_7(), 
//    .conv2_out_8(),
//    .conv2_out_9(), 
//    .conv2_out_10(), 
//    .conv2_out_11(), 
//    .conv2_out_12(),
//    .conv2_out_13(), 
//    .conv2_out_14(), 
//    .conv2_out_15(), 
//    .conv2_out_16(),
//    .valid_out_conv2(valid_out_conv2)
//);
//// === Channel 1 ===//
endmodule