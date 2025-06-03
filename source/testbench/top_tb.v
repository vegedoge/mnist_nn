`timescale 1ns/1ps

module top_tb;

reg clk, rst_n;
reg data_in;
wire [3:0] prediction;
wire valid_out;

// Instantiate the top module
top uut (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .prediction(prediction),
    .valid_out(valid_out)
);

// Clock generation
initial clk = 0;
always #5 clk = ~clk;  // 100 MHz

// Memory for input bits and labels
reg [0:0] image_data [0:7840-1];
reg [3:0] labels [0:9]; // 4 bits per label, 10 labels

integer i;
initial begin
    $readmemb("mnist_test_10.mem", image_data);
    $readmemb("mnist_test_10_labels.mem", labels);
end

// Variables
integer idx = 0;
integer image_num = 0;

initial begin
    rst_n = 0;
    data_in = 0;
    #100 rst_n = 1;

    // Stream bits one by one
    while (idx < 7840) begin
        @(posedge clk);
        data_in <= image_data[idx];
        idx = idx + 1;
    end
end

// Monitor prediction and check correctness
always @(posedge clk) begin
    if (valid_out) begin
        $display("Image %0d Prediction: %0d | Expected: %0d %s",
                 image_num, prediction, labels[image_num],
                 (prediction == labels[image_num]) ? "✔️" : "❌");
        image_num = image_num + 1;

        if (image_num == 10) begin
            $display("=== Done Testing 10 Images ===");
            $finish;
        end
    end
end

endmodule
