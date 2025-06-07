module max_pooling_buf #(
    parameter WIDTH = 26, 
    parameter HEIGHT = 26
) (
    input clk,
    input rst_n,
    input valid_in,
    input pixel_in,
    output reg pixel_0, pixel_1,
        pixel_2, pixel_3,
    output reg valid_out_buf
);

    localparam KERNEL_SIZE = 2;
    localparam X_BITS = $clog2(WIDTH);
    localparam Y_BITS = $clog2(HEIGHT);

    reg linebuf [0:KERNEL_SIZE-1][0:WIDTH-1]; // line buffer to store [kernel, width]
    reg window [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];

    reg [X_BITS-1:0] x;
    reg [Y_BITS-1:0] y; // current pixel's coordination
    reg [1:0] buf_cnt; // current writing row for line buffer

    reg ready_for_pooling; // flag to indicate if the buffer is ready for pooling

    integer i, j, idx_line;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset all
            x <= 0;
            y <= 0;
            buf_cnt <= 0;
            valid_out_buf <= 1'b0;
            ready_for_pooling <= 1'b0; // rst
            pixel_0 <= 0; pixel_1 <= 0;
            pixel_2 <= 0; pixel_3 <= 0;

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
                        window[i][j] <= window[i][j + 1]; // left shift the window
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

                // only ready for pooling if stride is 2 and the buffer is full
                if (x[0] == 1 && y[0] == 1 && x >= (KERNEL_SIZE - 1) && y >= (KERNEL_SIZE - 1)) begin
                    ready_for_pooling <= 1'b1;
                end else begin
                    ready_for_pooling <= 1'b0;
                end

//                if (ready_for_pooling) begin
//                    // buffer is valid only if y >= 1 && x >= 1
//                    valid_out_buf <= 1'b1;
//                    pixel_0 <= window[0][0]; pixel_1 <= window[0][1];
//                    pixel_2 <= window[1][0]; pixel_3 <= window[1][1];
//                end else begin
//                    valid_out_buf <= 1'b0;
//                    pixel_0 <= 0; pixel_1 <= 0;
//                    pixel_2 <= 0; pixel_3 <= 0;
//                end
                
                // can be updated here, now it's slo cuz the stride is 1
                if (x == WIDTH - 1) begin
                    x <= 0;
                    if (y == HEIGHT - 1) begin
                        y <= 0;
                    end else begin
                        y <= y + 1;
                    end
                    buf_cnt <= (buf_cnt + 1);
                    if (buf_cnt >= KERNEL_SIZE) begin
                        buf_cnt <= 0; // reset buf_cnt if it exceeds KERNEL_SIZE
                    end
                    
                end else begin
                    x <= x + 1;
                end
            end else begin
                // if valid_in is low, reset the output
                valid_out_buf <= 1'b0;
                ready_for_pooling <= 1'b0; // rst the state
                pixel_0 <= 0; pixel_1 <= 0;
                pixel_2 <= 0; pixel_3 <= 0;
            end
            
            if (ready_for_pooling) begin
                // buffer is valid only if y >= 1 && x >= 1
                valid_out_buf <= 1'b1;
                pixel_0 <= window[0][0]; pixel_1 <= window[0][1];
                pixel_2 <= window[1][0]; pixel_3 <= window[1][1];
            end else begin
                valid_out_buf <= 1'b0;
                pixel_0 <= 0; pixel_1 <= 0;
                pixel_2 <= 0; pixel_3 <= 0;
            end
            
        end
    end

endmodule

