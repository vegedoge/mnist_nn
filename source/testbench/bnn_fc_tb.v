

timescale 1ns / 1ps

module bnn_fc_tb;

    reg clk;
    reg reset;
    reg in_valid;
    reg [399:0] input_vector;
    reg [399:0] weights [0:9];
    wire [9:0] out_vector;
    wire out_valid;
    wire busy;
    wire fc_ready;

    // Instantiate the FC module
    bnn_fc uut (
        .clk(clk),
        .reset(reset),
        .in_valid(in_valid),
        .input_vector(input_vector),
        .weights(weights),
        .out_valid(out_valid),
        .fc_ready(fc_ready),
        .busy(busy),
        .out_vector(out_vector)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    integer i;
    integer latency_counter;
    reg [31:0] cycle_start;
    reg [31:0] cycle_end;

    // Procedure to load input and weights and measure latency
    task apply_inputs;
        input [399:0] in_vec;
        input [399:0] weight_val;
        input [9:0] expected_output;
        begin
            input_vector = in_vec;
            for (i = 0; i < 10; i = i + 1)
                weights[i] = weight_val;

            @(posedge clk);
            if (fc_ready)
                in_valid = 1;
            cycle_start = $time;
            @(posedge clk);
            in_valid = 0;

            wait(out_valid);
            cycle_end = $time;
            latency_counter = (cycle_end - cycle_start) / 10;
            $display("Output = %b, Latency = %0d cycles", out_vector, latency_counter);
            if (out_vector !== expected_output) $fatal("Test failed. Output mismatch.");
        end
    endtask

    initial begin
        $dumpfile("fc_wave.vcd");
        $dumpvars(0, bnn_fc_tb);

        // Initial state
        reset = 1;
        in_valid = 0;
        input_vector = 400'b0;
        for (i = 0; i < 10; i = i + 1)
            weights[i] = 400'b0;

        #20;
        reset = 0;

        // Test multiple consecutive inputs with latency tracking
        $display("Running multiple input test cases with latency measurement...");

        // Test 1: all match
        apply_inputs(400'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA, 400'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA, 10'b1111111111);

        // Test 2: exact threshold
        apply_inputs(400'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA, 400'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA, 10'b1111111111);

        // Test 3: just below threshold
        apply_inputs(400'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA, 400'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8, 10'b0000000000);

        // Test 4: alternating class outputs
        input_vector = 400'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
        for (i = 0; i < 10; i = i + 1)
            weights[i] = (i % 2 == 0) ? 400'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA : 400'h00000000000000000000000000000000000000000000000000;
        @(posedge clk);
        if (fc_ready)
            in_valid = 1;
        cycle_start = $time;
        @(posedge clk);
        in_valid = 0;
        wait(out_valid);
        cycle_end = $time;
        latency_counter = (cycle_end - cycle_start) / 10;
        $display("Output = %b, Latency = %0d cycles", out_vector, latency_counter);
        if (out_vector !== 10'b0101010101) $fatal("Test 4 failed: mismatched output");

        // Final message
        $display("All tests passed successfully.");
        #20;
        $finish;
    end

endmodule