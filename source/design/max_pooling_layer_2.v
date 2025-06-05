module max_pooling_layer_2 #(
    parameter WIDTH = 11, 
    parameter HEIGHT = 11
) (
    input clk, 
    input rst_n,
    input pixel_in_1, pixel_in_2, pixel_in_3, pixel_in_4,
          pixel_in_5, pixel_in_6, pixel_in_7, pixel_in_8,
          pixel_in_9, pixel_in_10, pixel_in_11, pixel_in_12,
          pixel_in_13, pixel_in_14, pixel_in_15, pixel_in_16,
    output maxpool_out_1, maxpool_out_2, maxpool_out_3, maxpool_out_4,
           maxpool_out_5, maxpool_out_6, maxpool_out_7, maxpool_out_8,
           maxpool_out_9, maxpool_out_10, maxpool_out_11, maxpool_out_12,
           maxpool_out_13, maxpool_out_14, maxpool_out_15, maxpool_out_16,
    output valid_out_maxpool
);

wire [15:0] pixel_in;
assign pixel_in = {pixel_in_16, pixel_in_15, pixel_in_14, pixel_in_13,
                    pixel_in_12, pixel_in_11, pixel_in_10, pixel_in_9,
                    pixel_in_8, pixel_in_7, pixel_in_6, pixel_in_5,
                    pixel_in_4, pixel_in_3, pixel_in_2, pixel_in_1};

wire [15:0] maxpool_out_ch;
assign {maxpool_out_16, maxpool_out_15, maxpool_out_14, maxpool_out_13,
        maxpool_out_12, maxpool_out_11, maxpool_out_10, maxpool_out_9,
        maxpool_out_8, maxpool_out_7, maxpool_out_6, maxpool_out_5,
        maxpool_out_4, maxpool_out_3, maxpool_out_2, maxpool_out_1} = maxpool_out_ch;

// internal 2x2 buffer
wire [15:0] pixel_0, pixel_1,
        pixel_2, pixel_3;

wire [15:0] valid_out_buf;
wire [15:0] valid_out_maxpool_ch;

assign valid_out_maxpool = &valid_out_maxpool_ch;

genvar i;
generate
    for(i = 0; i < 15; i = i + 1) begin: max_pooling_channels
        max_pooling_buf #(
            .WIDTH(WIDTH), 
            .HEIGHT(HEIGHT)
        ) max_pooling_buf_inst (
            .clk(clk),
            .rst_n(rst_n),
            .pixel_in(pixel_in[i]),
            .pixel_0(pixel_0[i]),
            .pixel_1(pixel_1[i]),
            .pixel_2(pixel_2[i]),
            .pixel_3(pixel_3[i]),
            .valid_out_buf(valid_out_buf[i])
        );

        max_pooling_calc max_pooling_calc_inst (
            .clk(clk),
            .rst_n(rst_n),
            .valid_out_buf(valid_out_buf[i]),
            .pixel_0(pixel_0[i]),
            .pixel_1(pixel_1[i]),
            .pixel_2(pixel_2[i]),
            .pixel_3(pixel_3[i]),
            .maxpool_out(maxpool_out_ch[i]),
            .valid_out_maxpool(valid_out_maxpool_ch[i])
        );
    end
endgenerate

endmodule
