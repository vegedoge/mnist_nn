module comparator (
    input clk,
    input rst_n,
    input valid_in,
    input [8:0] popcount_in_1,  // 10 popcount inputs, ranging 0-400
    input [8:0] popcount_in_2,
    input [8:0] popcount_in_3,
    input [8:0] popcount_in_4,
    input [8:0] popcount_in_5,
    input [8:0] popcount_in_6,
    input [8:0] popcount_in_7,
    input [8:0] popcount_in_8,
    input [8:0] popcount_in_9,
    input [8:0] popcount_in_10,
    output reg [3:0] max_index,      // index of the maximum popcount
    output reg [11:0] confidence,
    output reg valid_out
);

    // Internal signals
    reg [11:0] max_value;
    reg [3:0] max_idx;
    reg [11:0] confidence_temp;
    reg [11:0] total_value;
    integer i;

    // Array to hold the popcount inputs
    wire [8:0] popcount_in [9:0];
    assign popcount_in[0] = popcount_in_1;
    assign popcount_in[1] = popcount_in_2;
    assign popcount_in[2] = popcount_in_3;
    assign popcount_in[3] = popcount_in_4;
    assign popcount_in[4] = popcount_in_5;
    assign popcount_in[5] = popcount_in_6;
    assign popcount_in[6] = popcount_in_7;
    assign popcount_in[7] = popcount_in_8;
    assign popcount_in[8] = popcount_in_9;
    assign popcount_in[9] = popcount_in_10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            max_value <= 12'b0;
            max_idx <= 4'b0;
            confidence_temp <= 12'b0;
            valid_out <= 1'b0;
            total_value <= 12'b0;
        end else begin
            if (valid_in) begin
                max_value <= 12'b0;
                max_idx <= 4'b0;
                confidence_temp <= 12'b0;
                total_value <= 12'b0;
                
                for (i = 0; i < 10; i = i + 1) begin
                    if (popcount_in[i] > max_value) begin
                        max_value = popcount_in[i];
                        max_idx = i[3:0];
                    end
                    total_value = total_value + popcount_in[i];
                end

                // Calculate confidence as a percentage of the maximum value (0-100%)
                if (total_value > 0) begin
                    confidence_temp = (max_value * 100) / total_value;
                end else begin
                    confidence_temp = 12'b0; 
                end

                // output
                max_index <= max_idx;
                confidence <= confidence_temp;
                valid_out <= 1'b1;
            end else begin
                // Reset outputs if valid_in is low
                max_index <= 4'b0;
                confidence <= 12'b0;
                valid_out <= 1'b0;
            end
        end
    end
    
endmodule

