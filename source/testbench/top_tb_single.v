module top_single_tb();
    reg clk;
    reg rst_n;
    reg data_in;
    reg valid_in;
    wire [3:0] prediction;
    wire [7:0] confidence;
    wire valid_out;

    reg test_img [0:783];   // memory array
    reg [9:0] img_idx;

    // Instantiate the top module
    top uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .valid_in(valid_in),
        .prediction(prediction),
        .confidence(confidence),
        .valid_out(valid_out)
    );

    // Clock generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    initial begin
        $readmemb("../../../../../source/testbench/test_figures/test_7_7.txt", test_img);
        rst_n = 0;
        data_in = 0;
        valid_in = 0;

        # 20;
        rst_n = 1;

        # 20000;
        $display("=== Time out ===");
        $finish;
    end
    
    always @(*) begin
        if (!rst_n) begin
            data_in = 0;
            valid_in = 0;
            img_idx = 0;
        end else begin
            if (img_idx < 784) begin
                data_in = test_img[img_idx];
                valid_in = 1;
                img_idx = img_idx + 1;
            end else begin
                data_in = 0; // Stop sending data after 784 bits
                valid_in = 0;
            end
            #10;
        end
    end

//    always @(posedge clk) begin
//        if (!rst_n) begin
//            data_in = 0;
//            img_idx = 0;
//        end else begin
//            if (img_idx < 784) begin
//                data_in = test_img[img_idx];
//                img_idx = img_idx + 1;
//            end else begin
//                data_in = 0; // Stop sending data after 784 bits
//            end
//        end
//    end

    always @(posedge clk) begin
        if (valid_out) begin
            $display("Prediction: %0d, Confidence: %0d", prediction, confidence);
            $finish; // Stop simulation after one image
        end
    end


endmodule
