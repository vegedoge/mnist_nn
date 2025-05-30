module conv1_buf #(parameter WIDTH = 28, HEIGHT = 28) (
    input clk,
    input rst_n,
    input data_in,  // 1-bit input data
    output reg pixel_0, pixel_1, pixel_2,
    pixel_3, pixel_4, pixel_5,
    pixel_6, pixel_7, pixel_8,  // 3x3 buffer for convolution
    output reg valid_out_buf  // signal to indicate buffer is full
);

    localparam FILTER_SIZE = 3; // 3x3 filter size
    
    reg line_buffer [0:WIDTH * FILTER_SIZE - 1]; // line buffer
    reg [7:0] buf_idx;
    reg [3:0] w_idx, h_idx;
    reg [1:0] buf_flag; // 0,1,2 for 3 lines as line buffer selector
    reg state;


endmodule
