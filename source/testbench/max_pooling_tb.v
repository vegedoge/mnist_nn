module max_pooling_tb();
    reg clk;
    reg rst_n;
    reg pixel_in;
    wire maxpool_out;
    wire valid_out_maxpool;

    max_pooling #(5, 5) maxPool (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_in(pixel_in),
        .maxpool_out(maxpool_out),
        .valid_out_maxpool(valid_out_maxpool)
    );

    initial begin
        // generate the clock
        clk = 1;
        forever #5 clk = ~clk;
    end

    integer i, j, idx;
    reg test_img [0:5 * 5 - 1];

    initial begin
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                test_img[i * 5 + j] = (i + j) % 2;
            end

            // for (j = 16; j < 21; j = j + 1) begin
            //     test_img[i * 26 + j] = 0;
            // end

            // for (j = 21; j < 26; j = j + 1) begin
            //     test_img[i * 26 + j] = 1;
            // end
        end
        
        // initial the signals
        pixel_in = 0;
        rst_n = 1;
        
        // reset the system
        #10;
        rst_n = 0;
        #10;
        rst_n = 1;
        
        $display("Max Pooling Test Begin");
        
        // stream the input img
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                pixel_in = test_img[i * 5 + j];
                #10;
            end
        end
        
        $display("Max Pooling Test End");

        $finish;
    end
    
endmodule