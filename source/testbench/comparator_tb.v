module comparator_tb();
    reg clk;
    reg rst_n;
    reg valid_in;
    reg [8:0] popcount_in_1, popcount_in_2, popcount_in_3, popcount_in_4;
    reg [8:0] popcount_in_5, popcount_in_6, popcount_in_7, popcount_in_8;
    reg [8:0] popcount_in_9, popcount_in_10;

    // outputs
    wire [3:0] max_index;
    wire [7:0] confidence;
    wire valid_out;

    comparator com_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .popcount_in_1(popcount_in_1),
        .popcount_in_2(popcount_in_2),
        .popcount_in_3(popcount_in_3),
        .popcount_in_4(popcount_in_4),
        .popcount_in_5(popcount_in_5),
        .popcount_in_6(popcount_in_6),
        .popcount_in_7(popcount_in_7),
        .popcount_in_8(popcount_in_8),
        .popcount_in_9(popcount_in_9),
        .popcount_in_10(popcount_in_10),
        .max_index(max_index),
        .confidence(confidence),
        .valid_out(valid_out)
    );

    initial begin
        // generate the clock
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    integer i;

    initial begin
        // initial signals
        rst_n = 0;
        valid_in = 0;
        popcount_in_1 = 0;
        popcount_in_2 = 0;
        popcount_in_3 = 0;
        popcount_in_4 = 0;
        popcount_in_5 = 0;
        popcount_in_6 = 0;
        popcount_in_7 = 0;
        popcount_in_8 = 0;
        popcount_in_9 = 0;
        popcount_in_10 = 0;

        // reset
        #10;
        rst_n = 1;
        #10;

        // case 1: single max value
        valid_in = 1;
        popcount_in_1 = 100;
        popcount_in_2 = 100;
        popcount_in_3 = 100;
        popcount_in_4 = 100;
        popcount_in_5 = 250; // max value at index 5
        popcount_in_6 = 100;
        popcount_in_7 = 100;
        popcount_in_8 = 100;
        popcount_in_9 = 100;
        popcount_in_10 = 100;
        #10;
        valid_in = 0;
        #10;

        // case 2: multiple max values
        valid_in = 1;
        popcount_in_1 = 100; 
        popcount_in_2 = 100; 
        popcount_in_3 = 200; // max value at index 3
        popcount_in_4 = 100;
        popcount_in_5 = 100;
        popcount_in_6 = 100;
        popcount_in_7 = 200; // another max value at index 7
        popcount_in_8 = 100;
        popcount_in_9 = 100;
        popcount_in_10 = 100;
        #10;
        valid_in = 0;
        #10;

        // case 3: normal random values
        valid_in = 1;
        popcount_in_1 = 50;
        popcount_in_2 = 150;
        popcount_in_3 = 200;
        popcount_in_4 = 300;
        popcount_in_5 = 100;
        popcount_in_6 = 360; // max value at index 6
        popcount_in_7 = 250;
        popcount_in_8 = 300;
        popcount_in_9 = 150;
        popcount_in_10 = 50;
        #10;
        valid_in = 0;
        #10;

        #30
        $finish;
    end

    // monitor
    initial begin
        $monitor("Time: %0t, Max Index: %d, Confidence: %d, Valid Out: %b",
                 $time, max_index, confidence, valid_out);
    end

endmodule



