module conv_layer_1(
    input wire clk,
    input wire rst_n,
    input wire pixel_in,         // 1-bit input data
    output conv1_out_1,     // 8 channels output signals for convolution layer 1
    output conv1_out_2,     // each clk one bit output
    output conv1_out_3,
    output conv1_out_4,
    output conv1_out_5,
    output conv1_out_6,
    output conv1_out_7,
    output conv1_out_8,
    output valid_out_conv1  // signal to indicate valid output
);

// input pixel buffer for 3x3 conv
wire pixel_0, pixel_1, pixel_2,
    pixel_3, pixel_4, pixel_5,
    pixel_6, pixel_7, pixel_8;

// see if buffer is full now
wire valid_buf;

conv1_buf #(
    .WIDTH(28), 
    .HEIGHT(28)
) conv1_buf_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_in(pixel_in),
    .pixel_0(pixel_0),
    .pixel_1(pixel_1),
    .pixel_2(pixel_2),
    .pixel_3(pixel_3),
    .pixel_4(pixel_4),
    .pixel_5(pixel_5),
    .pixel_6(pixel_6),
    .pixel_7(pixel_7),
    .pixel_8(pixel_8),
    .valid_out_buf(valid_buf)
);

//// only to buffer the input so as to eliminate the time issue
//reg vb_d;
//reg [8:0] pix_d;
//always @(posedge clk or negedge rst_n) begin
//    if (!rst_n) begin
//        vb_d <= 1'b0;
//        pix_d <= 9'b0;
//    end else begin
//        vb_d <= valid_out_buf;
//        pix_d <= {pixel_0, pixel_1, pixel_2,
//                  pixel_3, pixel_4, pixel_5,
//                  pixel_6, pixel_7, pixel_8};
//    end
//end

// convolution calculation
conv1_calc_1 conv1_calc_1_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in_buf(valid_buf),
    .pixel_0(pixel_0), 
    .pixel_1(pixel_1), 
    .pixel_2(pixel_2),
    .pixel_3(pixel_3), 
    .pixel_4(pixel_4), 
    .pixel_5(pixel_5),
    .pixel_6(pixel_6), 
    .pixel_7(pixel_7), 
    .pixel_8(pixel_8),
//    .valid_out_buf(vb_d),
//    .pixel_0(pix_d[8]), 
//    .pixel_1(pix_d[7]), 
//    .pixel_2(pix_d[6]),
//    .pixel_3(pix_d[5]), 
//    .pixel_4(pix_d[4]), 
//    .pixel_5(pix_d[3]),
//    .pixel_6(pix_d[2]), 
//    .pixel_7(pix_d[1]), 
//    .pixel_8(pix_d[0]),
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