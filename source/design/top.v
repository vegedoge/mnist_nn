module top (
    input wire clk,
    input wire rst_n,
    input wire data_in,             // stream input of data bits
    output wire [3:0] prediction,   // 4 bit for 0-9
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
// width not sure yet
wire fc_out_data;

// valid signals
wire valid_out_conv1, valid_out_conv2;
wire valid_out_maxpool1, valid_out_maxpool2;
wire valid_out_fc;

// convolution layer 1
conv_layer_1 conv_layer_1_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
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


// convolution layer 2


// maxpooling layer 2


// fully connected layer


// comparator for prediction





endmodule