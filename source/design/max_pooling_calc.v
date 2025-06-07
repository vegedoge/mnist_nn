module max_pooling_calc(
//    input clk,
//    input rst_n,
    input valid_out_buf,
    input pixel_0, pixel_1,
          pixel_2, pixel_3,
    output reg maxpool_out,
    output reg valid_out_maxpool
);
    always @(*) begin
        if (valid_out_buf) begin
            maxpool_out = (pixel_0 | pixel_1 | pixel_2 | pixel_3);
            valid_out_maxpool = 1'b1;
        end else begin
            maxpool_out = 1'b0;
            valid_out_maxpool = 1'b0;
        end
    end

//    always @(posedge clk or negedge rst_n) begin
//        if (!rst_n) begin
//            maxpool_out <= 1'b0;
//            valid_out_maxpool <= 1'b0;
//        end else begin
//            if (valid_out_buf) begin
//                maxpool_out <= (pixel_0 | pixel_1 | pixel_2 | pixel_3);
//                valid_out_maxpool <= 1'b1;
//            end else begin
//                maxpool_out <= 1'b0;
//                valid_out_maxpool <= 1'b0;
//            end
//        end
//    end

endmodule