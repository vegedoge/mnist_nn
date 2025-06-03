module max_pooling #(
    parameter WIDTH = 26, 
    parameter HEIGHT = 26
) (
    input clk, 
    input rst_n,
    input pixel_in,
    output maxpool_out,
    output valid_out_maxpool
);

// internal 2x2 buffer
wire pixel_0, pixel_1,
     pixel_2, pixel_3;

wire valid_out_buf;

max_pooling_buf #(WIDTH, HEIGHT) max_pooling_buf_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_in(pixel_in),
    .pixel_0(pixel_0),
    .pixel_1(pixel_1),
    .pixel_2(pixel_2),
    .pixel_3(pixel_3),
    .valid_out_buf(valid_out_buf)
);

max_pooling_calc max_pooling_calc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_out_buf(valid_out_buf),
    .pixel_0(pixel_0),
    .pixel_1(pixel_1),
    .pixel_2(pixel_2),
    .pixel_3(pixel_3),
    .maxpool_out(maxpool_out),
    .valid_out_maxpool(valid_out_maxpool)
);

endmodule
