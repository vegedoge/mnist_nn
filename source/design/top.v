module top (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,             // stream input of data bits
    input wire valid_in,
    output wire [3:0] prediction,   // 4 bit for 0-9
    output wire [7:0] confidence,   // 8 bit for confidence percentage
    output wire valid_out
);

// inter-connect signals
// conv1
wire conv1_out_1, conv1_out_2, conv1_out_3, conv1_out_4;
wire conv1_out_5, conv1_out_6, conv1_out_7, conv1_out_8;

// conv2
wire conv2_out_1, conv2_out_2, conv2_out_3, conv2_out_4;
wire conv2_out_5, conv2_out_6, conv2_out_7, conv2_out_8;
wire conv2_out_9, conv2_out_10, conv2_out_11, conv2_out_12;
wire conv2_out_13, conv2_out_14, conv2_out_15, conv2_out_16;

// maxpool1
wire maxpool1_out_1, maxpool1_out_2, maxpool1_out_3, maxpool1_out_4;
wire maxpool1_out_5, maxpool1_out_6, maxpool1_out_7, maxpool1_out_8;

// maxpool2
wire maxpool2_out_1, maxpool2_out_2, maxpool2_out_3, maxpool2_out_4;
wire maxpool2_out_5, maxpool2_out_6, maxpool2_out_7, maxpool2_out_8;
wire maxpool2_out_9, maxpool2_out_10, maxpool2_out_11, maxpool2_out_12;
wire maxpool2_out_13, maxpool2_out_14, maxpool2_out_15, maxpool2_out_16;

// fc
wire [8:0] fc_out_data_1, fc_out_data_2, fc_out_data_3, fc_out_data_4;
wire [8:0] fc_out_data_5, fc_out_data_6, fc_out_data_7, fc_out_data_8;
wire [8:0] fc_out_data_9, fc_out_data_10;

// valid signals
wire valid_out_conv1, valid_out_conv2;
wire valid_out_maxpool1, valid_out_maxpool2;
wire valid_out_fc;

// convolution layer 1
// 8 channels, 3x3 kernel, stride 1, padding 0
// input size 28x28x1, output size 26x26x8
conv_layer_1 conv_layer_1_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_in(data_in),
    .valid_in(valid_in),
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

// maxpooling layer 1
// 8 channels, 2x2 kernel, stride 2, padding 0
// input size 26x26x8, output size 13x13x8
max_pooling_layer_1 #(
    .WIDTH(26),
    .HEIGHT(26)
) max_pooling_layer_1_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_out_conv1),
    .pixel_in_1(conv1_out_1),
    .pixel_in_2(conv1_out_2),
    .pixel_in_3(conv1_out_3),
    .pixel_in_4(conv1_out_4),
    .pixel_in_5(conv1_out_5),
    .pixel_in_6(conv1_out_6),
    .pixel_in_7(conv1_out_7),
    .pixel_in_8(conv1_out_8),
    .maxpool_out_1(maxpool1_out_1),
    .maxpool_out_2(maxpool1_out_2),
    .maxpool_out_3(maxpool1_out_3),
    .maxpool_out_4(maxpool1_out_4),
    .maxpool_out_5(maxpool1_out_5),
    .maxpool_out_6(maxpool1_out_6),
    .maxpool_out_7(maxpool1_out_7),
    .maxpool_out_8(maxpool1_out_8),
    .valid_out_maxpool(valid_out_maxpool1)
);

// convolution layer 2
// 16 channels, 3x3 kernel, stride 1, padding 0
// input size 13x13x8, output size 11x11x16
conv_layer_2 conv_layer2_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_out_maxpool1),
    .pixel_in_1(maxpool1_out_1),
    .pixel_in_2(maxpool1_out_2),
    .pixel_in_3(maxpool1_out_3),
    .pixel_in_4(maxpool1_out_4),
    .pixel_in_5(maxpool1_out_5),
    .pixel_in_6(maxpool1_out_6),
    .pixel_in_7(maxpool1_out_7),
    .pixel_in_8(maxpool1_out_8),
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

// maxpooling layer 2
// 16 channels, 2x2 kernel, stride 2, padding 0
// input size 11x11x16, output size 5x5x16
max_pooling_layer_2 #(
    .WIDTH(11),
    .HEIGHT(11)
) max_pooling_layer_2_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_out_conv2),
    .pixel_in_1(conv2_out_1),
    .pixel_in_2(conv2_out_2),
    .pixel_in_3(conv2_out_3),
    .pixel_in_4(conv2_out_4),
    .pixel_in_5(conv2_out_5),
    .pixel_in_6(conv2_out_6),
    .pixel_in_7(conv2_out_7),
    .pixel_in_8(conv2_out_8),
    .pixel_in_9(conv2_out_9),
    .pixel_in_10(conv2_out_10),
    .pixel_in_11(conv2_out_11),
    .pixel_in_12(conv2_out_12),
    .pixel_in_13(conv2_out_13),
    .pixel_in_14(conv2_out_14),
    .pixel_in_15(conv2_out_15),
    .pixel_in_16(conv2_out_16),
    .maxpool_out_1(maxpool2_out_1),
    .maxpool_out_2(maxpool2_out_2),
    .maxpool_out_3(maxpool2_out_3),
    .maxpool_out_4(maxpool2_out_4),
    .maxpool_out_5(maxpool2_out_5),
    .maxpool_out_6(maxpool2_out_6),
    .maxpool_out_7(maxpool2_out_7),
    .maxpool_out_8(maxpool2_out_8),
    .maxpool_out_9(maxpool2_out_9),
    .maxpool_out_10(maxpool2_out_10),
    .maxpool_out_11(maxpool2_out_11),
    .maxpool_out_12(maxpool2_out_12),
    .maxpool_out_13(maxpool2_out_13),
    .maxpool_out_14(maxpool2_out_14),
    .maxpool_out_15(maxpool2_out_15),
    .maxpool_out_16(maxpool2_out_16),
    .valid_out_maxpool(valid_out_maxpool2)
);

// fully connected layer
// input size 5x5x16 = 400, output size 10
fc_layer fc_layer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_out_maxpool2),
    .pixel_in_1(maxpool2_out_1),
    .pixel_in_2(maxpool2_out_2),
    .pixel_in_3(maxpool2_out_3),
    .pixel_in_4(maxpool2_out_4),
    .pixel_in_5(maxpool2_out_5),
    .pixel_in_6(maxpool2_out_6),
    .pixel_in_7(maxpool2_out_7),
    .pixel_in_8(maxpool2_out_8),
    .pixel_in_9(maxpool2_out_9),
    .pixel_in_10(maxpool2_out_10),
    .pixel_in_11(maxpool2_out_11),
    .pixel_in_12(maxpool2_out_12),
    .pixel_in_13(maxpool2_out_13),
    .pixel_in_14(maxpool2_out_14),
    .pixel_in_15(maxpool2_out_15),
    .pixel_in_16(maxpool2_out_16),
    .fc_out_1(fc_out_data_1),
    .fc_out_2(fc_out_data_2),
    .fc_out_3(fc_out_data_3),
    .fc_out_4(fc_out_data_4),
    .fc_out_5(fc_out_data_5),
    .fc_out_6(fc_out_data_6),
    .fc_out_7(fc_out_data_7),
    .fc_out_8(fc_out_data_8),
    .fc_out_9(fc_out_data_9),
    .fc_out_10(fc_out_data_10),
    .valid_out_fc(valid_out_fc)
);

// comparator for prediction
comparator comparator_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_out_fc),
    .popcount_in_1(fc_out_data_1),
    .popcount_in_2(fc_out_data_2),
    .popcount_in_3(fc_out_data_3),
    .popcount_in_4(fc_out_data_4),
    .popcount_in_5(fc_out_data_5),
    .popcount_in_6(fc_out_data_6),
    .popcount_in_7(fc_out_data_7),
    .popcount_in_8(fc_out_data_8),
    .popcount_in_9(fc_out_data_9),
    .popcount_in_10(fc_out_data_10),
    .max_index(prediction),
    .confidence(confidence),
    .valid_out(valid_out)
);

endmodule