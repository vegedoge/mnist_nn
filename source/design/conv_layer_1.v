module conv_layer_1 (
    input wire clk,
    input wire rst_n,
    input wire data_in,         // 1-bit input data
    output reg conv1_out_1,     // 8 channels output signals for convolution layer 1
    output reg conv1_out_2,     // each clk one bit output
    output reg conv1_out_3,
    output reg conv1_out_4,
    output reg conv1_out_5,
    output reg conv1_out_6,
    output reg conv1_out_7,
    output reg conv1_out_8,
    output reg valid_out_conv1  // signal to indicate valid output
);

// input pixel buffer for 3x3 conv
wire pixel_0, pixel_1, pixel_2,
    pixel_3, pixel_4, pixel_5,
    pixel_6, pixel_7, pixel_8;

// see if buffer is full now
wire valid_out_buf;

conv1_buf #(
    .WIDTH(28), 
    .HEIGHT(28)
) conv1_buf_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .pixel_0(pixel_0),
    .pixel_1(pixel_1),
    .pixel_2(pixel_2),
    .pixel_3(pixel_3),
    .pixel_4(pixel_4),
    .pixel_5(pixel_5),
    .pixel_6(pixel_6),
    .pixel_7(pixel_7),
    .pixel_8(pixel_8),
    .valid_out_buf(valid_out_buf)
);

// convolution calculation
conv1_calc_1 conv1_calc_1_inst (
    .valid_out_buf(valid_out_buf),
    .pixel_0(pixel_0), 
    .pixel_1(pixel_1), 
    .pixel_2(pixel_2),
    .pixel_3(pixel_3), 
    .pixel_4(pixel_4), 
    .pixel_5(pixel_5),
    .pixel_6(pixel_6), 
    .pixel_7(pixel_7), 
    .pixel_8(pixel_8),
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


endmodule