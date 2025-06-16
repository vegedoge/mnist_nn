module conv2_buf #(
    parameter WIDTH = 13,
    parameter HEIGHT = 13
) (
    input clk,
    input rst_n,
    input valid_in,
    input [7:0] pixel_in,
//    output [71:0] pixel_windows,
//    output valid_out_buf
    output reg [71:0] pixel_windows,
    output reg valid_out_buf
);
    localparam KERNEL_SIZE = 3;
    localparam NUM_CHANNELS = 8;
    
    wire [8:0] ch_windows [0:7]; // 3x3 window of 8 channels
    wire [7:0] ch_valid;
    
    genvar i;
    integer j;
    generate
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin: CH_BUF
            conv1_buf #(
                .WIDTH(WIDTH),
                .HEIGHT(HEIGHT)
            ) ch_buf_inst (
              .clk(clk),
              .rst_n(rst_n),
              .valid_in(valid_in),
              .pixel_in(pixel_in[i]),
              .pixel_0(ch_windows[i][0]),
              .pixel_1(ch_windows[i][1]),  
              .pixel_2(ch_windows[i][2]),  
              .pixel_3(ch_windows[i][3]),  
              .pixel_4(ch_windows[i][4]),  
              .pixel_5(ch_windows[i][5]),  
              .pixel_6(ch_windows[i][6]),  
              .pixel_7(ch_windows[i][7]),
              .pixel_8(ch_windows[i][8]),
              .valid_out_buf(ch_valid[i])
            );
        end
    endgenerate 
    
//    assign pixel_windows = {
//        ch_windows[7],
//        ch_windows[6],
//        ch_windows[5],
//        ch_windows[4],
//        ch_windows[3],
//        ch_windows[2],
//        ch_windows[1],
//        ch_windows[0]
//    };
    
//    assign valid_out_buf = &ch_valid;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
            pixel_windows <= 72'b0;
            valid_out_buf <= 1'b0;
        end else begin
            valid_out_buf <= ch_valid[0];
            for (j = 0; j < NUM_CHANNELS; j = j + 1) begin
                pixel_windows[j * 9 +: 9] <= ch_windows[j];
            end
        end
    end
endmodule