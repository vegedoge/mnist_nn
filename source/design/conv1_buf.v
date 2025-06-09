module conv1_buf #(
    parameter WIDTH = 28,    
    parameter HEIGHT = 28
) (
    input clk,
    input rst_n,
    input valid_in,
    input pixel_in,  // 1-bit input data
    output reg pixel_0, pixel_1, pixel_2,
    pixel_3, pixel_4, pixel_5,
    pixel_6, pixel_7, pixel_8,  // 3x3 buffer for convolution
    output reg valid_out_buf  // signal to indicate buffer is full
);

    localparam KERNEL_SIZE = 3; // 3x3 filter size
    localparam X_BITS = $clog2(WIDTH);
    localparam Y_BITS = $clog2(HEIGHT);
    
    reg linebuf [0:KERNEL_SIZE-1][0:WIDTH-1]; // line buffer to store [kernel, width]
    reg window  [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];
    
    reg [X_BITS-1:0] x;
    reg [X_BITS-1:0] y; // current pixel's coordination
    reg [1:0] buf_cnt; // current writing row for line buffer
    
    reg valid_d;
    
    integer i, j, idx_line;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset all the things
            x <= 0;
            y <= 0;
            buf_cnt <= 0;
            valid_out_buf <= 1'b0;
            valid_d <= 1'b0;
            pixel_0 <= 0; pixel_1 <= 0; pixel_2 <= 0; 
            pixel_3 <= 0; pixel_4 <= 0; pixel_5 <= 0; 
            pixel_6 <= 0; pixel_7 <= 0; pixel_8 <= 0;
            
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                for (j = 0; j < WIDTH; j = j + 1) begin
                    if (j < KERNEL_SIZE) begin
                        window[i][j] <= 1'b0;
                    end
                    linebuf[i][j] <= 1'b0;
                end
            end
        end else begin
            if (valid_in) begin
                linebuf[buf_cnt][x] <= pixel_in; // write to line buffer
                
                for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                    for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
                        window[i][j] <= window[i][j+1]; // left shift the window
                    end
                end
                
                for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                    // fill the last col for each row of the window
                    // not directly using % since it needs much resources in synthesis
                    idx_line = buf_cnt + i + 1;
                    if (idx_line >= KERNEL_SIZE) idx_line = idx_line - KERNEL_SIZE;
                    
                    if (idx_line == buf_cnt) begin
                        window[i][KERNEL_SIZE-1] <= pixel_in;
                    end else begin
                        window[i][KERNEL_SIZE-1] <= linebuf[idx_line][x];
                    end
                end
                
                if ((y >= KERNEL_SIZE - 1) && (x >= KERNEL_SIZE - 1)) begin
                    // output is valid only if y >= 2 && x >= 2
    //                valid_out_buf <= 1'b1;
                    valid_d <= 1'b1;
    //                pixel_0 <= window[0][0]; pixel_1 <= window[0][1]; pixel_2 <= window[0][2];
    //                pixel_3 <= window[1][0]; pixel_4 <= window[1][1]; pixel_5 <= window[1][2];
    //                pixel_6 <= window[2][0]; pixel_7 <= window[2][1]; pixel_8 <= window[2][2];
                end else begin
    //                valid_out_buf <= 1'b0;
                    valid_d <= 1'b0;                
    //                pixel_0 <= 0; pixel_1 <= 0; pixel_2 <= 0; 
    //                pixel_3 <= 0; pixel_4 <= 0; pixel_5 <= 0; 
    //                pixel_6 <= 0; pixel_7 <= 0; pixel_8 <= 0; 
                end
                
//                if (valid_d) begin
//                    valid_out_buf <= 1'b1;
//                    pixel_0 <= window[0][0]; pixel_1 <= window[0][1]; pixel_2 <= window[0][2];
//                    pixel_3 <= window[1][0]; pixel_4 <= window[1][1]; pixel_5 <= window[1][2];
//                    pixel_6 <= window[2][0]; pixel_7 <= window[2][1]; pixel_8 <= window[2][2];            
//                end else begin
//                    valid_out_buf <= 1'b0;
//                    pixel_0 <= 0; pixel_1 <= 0; pixel_2 <= 0; 
//                    pixel_3 <= 0; pixel_4 <= 0; pixel_5 <= 0; 
//                    pixel_6 <= 0; pixel_7 <= 0; pixel_8 <= 0; 
//                end
                
                if (x == WIDTH - 1) begin
                    // achieve the border, reset x, y
                    x <= 0;
                    if (y == HEIGHT - 1) begin
                        y <= 0;
                    end else begin
                        y <= y + 1;
                    end
                    buf_cnt <= buf_cnt + 1;
                    if (buf_cnt >= KERNEL_SIZE - 1) buf_cnt <= 0; // (buf_cnt + 1) % 3
                
                end else begin
                    x <= x + 1;
                end
            end else begin
                // if valid_in is low, reset the output
                valid_out_buf <= 1'b0;
                valid_d <= 1'b0; // rst
                pixel_0 <= 0; pixel_1 <= 0; pixel_2 <= 0; 
                pixel_3 <= 0; pixel_4 <= 0; pixel_5 <= 0; 
                pixel_6 <= 0; pixel_7 <= 0; pixel_8 <= 0; 
            end
            
            if (valid_d) begin
                valid_out_buf <= 1'b1;
                pixel_0 <= window[0][0]; pixel_1 <= window[0][1]; pixel_2 <= window[0][2];
                pixel_3 <= window[1][0]; pixel_4 <= window[1][1]; pixel_5 <= window[1][2];
                pixel_6 <= window[2][0]; pixel_7 <= window[2][1]; pixel_8 <= window[2][2];            
            end else begin
                valid_out_buf <= 1'b0;
                pixel_0 <= 0; pixel_1 <= 0; pixel_2 <= 0; 
                pixel_3 <= 0; pixel_4 <= 0; pixel_5 <= 0; 
                pixel_6 <= 0; pixel_7 <= 0; pixel_8 <= 0; 
            end
            
        end
    end 
    
    
    
    
    
    
//    reg line_buffer [0:WIDTH * KERNEL_SIZE - 1]; // line buffer
//    reg [7:0] buf_idx;
//    reg [3:0] w_idx, h_idx;
//    reg [1:0] buf_flag; // 0,1,2 for 3 lines as line buffer selector
//    reg state;


endmodule
