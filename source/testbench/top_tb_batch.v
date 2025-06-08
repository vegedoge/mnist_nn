module top_tb_batch();
    reg clk;
    reg rst_n;
    reg [7:0] data_in;
    reg valid_in;
    wire [3:0] prediction;
    wire [7:0] confidence;
    wire valid_out;

    reg [7:0] test_img_set [0:783999];
    reg [0:3] test_labels [0:999]; // 1000 labels, each 4 bits

    reg [9:0] img_idx;  // pixel index in one image
    integer i;
    reg state; // state to indicate if the image is fully sent
    reg [9:0] prediction_hit;
    reg [9:0] accuracy;


    reg test_img_1[0:1567];
    reg [0:3] test_labels_1[0:1];
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
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // load test set
    initial begin
        $readmemh("../../../../../source/testbench/test_figures/test_1000_hex.txt", test_img_set);
        $readmemh("../../../../../source/testbench/test_figures/test_1000_hex_labels.txt", test_labels);
        rst_n = 0;
        data_in = 0;
        valid_in = 0;
        img_idx = 0;
        prediction_hit = 0;
        accuracy = 0;
        state = 1'b0; // Initial state is not sending an image
        i = 0;

        #20;
        rst_n = 1;

      #20000000; // Allow time for processing
        $display("=== Time out ===");
        $finish;
    end
    
    // always @(*) begin
    //     if (!rst_n) begin
    //         data_in = 0;
    //         img_idx = 0;
    //         valid_in = 0;
    //         i = 0;
    //     end else begin
    //         if (state == 1'b0) begin
    //             data_in = test_img_set[i * 784 + img_idx]; // Stream the first image
    //             valid_in = 1'b1;
    //             img_idx = img_idx + 1;

    //             if (img_idx >= 784) begin
    //                 img_idx = 0; // Reset pixel index for the next image
    //                 state = 1'b1; // Set state to indicate image is fully sent
    //                 valid_in = 1'b1;

    //                 if (i >= 1000) begin
    //                     // display final results
    //                     data_in = 0; // Stop sending data
    //                     valid_in = 1'b0; 
    //                     accuracy = (prediction_hit * 100) / 1000; // Calculate accuracy
    //                     $display("=== Test Completed ===");
    //                     $display("Total Images: 1000, Correct Predictions: %0d, Accuracy: %0d%%", prediction_hit, accuracy);
    //                     $finish;
    //                 end
    //             end
    //         end
            
    //         if (valid_out) begin
    //             if (prediction == test_labels[i]) begin
    //                 prediction_hit = prediction_hit + 1;
    //                 $display("Image %0d Prediction: %0d | Expected: %0d TRUE", i, prediction, test_labels[i]);
    //             end else begin
    //                 $display("Image %0d Prediction: %0d | Expected: %0d FALSE", i, prediction, test_labels[i]);
    //             end

    //             state = 1'b0;
    //             i = i + 1'b1;
    //         end
    //     end
    // end
//    integer j, k;
//    initial begin
//        for (j = 0; j < 2; j = j + 1) begin
//            for (k = 0; k < 784; k = k + 1) begin
//                test_img_1[j * 784 + k] = 1;
//            end
//        end

//        test_labels_1[0] = 4'b0001; // Label for first image
//        test_labels_1[1] = 4'b0001; // Label for second image
//    end

   always @(posedge clk) begin
       if (!rst_n) begin
           data_in <= 0;
           img_idx <= 0;
           valid_in <= 0;
           state <= 1'b0; // Reset state
           i <= 0;
       end else begin
           if (valid_out) begin
                if (prediction == test_labels[i]) begin
//               if (prediction == test_labels_1[i]) begin
                   prediction_hit <= prediction_hit + 1;
                   $display("Image %0d Prediction: %0d | Expected: %0d TRUE", i, prediction, test_labels[i]);
               end else begin
                   $display("Image %0d Prediction: %0d | Expected: %0d FALSE", i, prediction, test_labels[i]);
               end

//               state <= 1'b0;
//               i <= i + 1'b1;
           end

           if (state == 1'b0) begin
               data_in <= test_img_set[i * 784 + img_idx]; // Stream the first image
//               data_in <= test_img_1[i * 784 + img_idx]; // stream for test
               valid_in <= 1'b1;
               img_idx <= img_idx + 1;

               if (img_idx >= 784 - 1) begin
                   img_idx <= 0; // Reset pixel index for the next image
                   i <= i + 1'b1;
//                   state <= 1'b1; // Set state to indicate image is fully sent
                   valid_in <= 1'b0;

                    if (i >= 1000 - 1) begin
//                   if (i >= 2 - 1) begin
                       // display final results
                       data_in = 0; // Stop sending data
                       valid_in = 1'b0; 
                       accuracy = (prediction_hit * 100) / 1000; // Calculate accuracy
                       $display("=== Test Completed ===");
                       $display("Total Images: 1000, Correct Predictions: %0d, Accuracy: %0d%%", prediction_hit, accuracy);
                       $finish;
                   end
               end
           end
       end
   end

    // always @(posedge clk) begin
    //     if (!rst_n) begin
    //         data_in = 0;
    //         img_idx = 0;
    //         i = 0;
    //     end else begin
    //         if (img_idx < 784) begin
    //             data_in = test_img_set[i * 784 + img_idx]; // Stream the first image
    //             img_idx = img_idx + 1;
    //         end else begin
    //             if (i < 999) begin
    //                 // Move to the next image after one is fully sent
    //                 if (valid_out) begin
    //                     // Check prediction against the expected label
    //                     if (prediction == test_labels[i]) begin
    //                         prediction_hit = prediction_hit + 1;
    //                         $display("Image %0d Prediction: %0d | Expected: %0d TRUE", i, prediction, test_labels[i]);
    //                     end else begin
    //                         $display("Image %0d Prediction: %0d | Expected: %0d FALSE", i, prediction, test_labels[i]);
    //                     end
    //                 end
    //                 i = i + 1;
    //                 img_idx = 0; // Reset pixel index for the next image
    //             end else begin
    //                 // display final results
    //                 data_in = 0; // Stop sending data 

    //                 accuracy = (prediction_hit * 100) / 1000; // Calculate accuracy
    //                 $display("=== Test Completed ===");
    //                 $display("Total Images: 1000, Correct Predictions: %0d, Accuracy: %0d%%", prediction_hit, accuracy);
    //                 $finish;
    //             end
    //         end
    //     end
    // end
    
endmodule
