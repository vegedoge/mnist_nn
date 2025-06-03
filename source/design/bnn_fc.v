// bnn_fc.v – Improved Binary Fully Connected Layer with handshake and pipelined XNOR/popcount

module bnn_fc (
    input  wire        clk,
    input  wire        reset,
    input  wire        in_valid,
    input  wire [399:0] input_vector,
    input  wire [399:0] weights [0:9],
    output reg         out_valid,
    output reg         fc_ready,
    output reg         busy,
    output reg  [9:0]  out_vector
);

    // Internal registers
    reg [399:0] input_reg;
    reg [399:0] xnor_result [0:9];
    reg [8:0]   popcnt [0:9];  // max value: 400 < 512 = 9 bits
    integer i, j;

    reg [3:0]   state;
    localparam IDLE = 0, XNOR_CALC = 1, POPCOUNT_CALC = 2, OUTPUT = 3;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            out_valid <= 0;
            fc_ready <= 1;
            busy <= 0;
            out_vector <= 0;
            input_reg <= 0;
            for (i = 0; i < 10; i = i + 1) begin
                popcnt[i] <= 0;
                xnor_result[i] <= 0;
            end
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 0;
                    busy <= 0;
                    fc_ready <= 1;
                    if (in_valid) begin
                        input_reg <= input_vector;
                        state <= XNOR_CALC;
                        busy <= 1;
                        fc_ready <= 0;
                    end
                end
                XNOR_CALC: begin
                    for (i = 0; i < 10; i = i + 1) begin
                        xnor_result[i] <= ~(input_reg ^ weights[i]);
                    end
                    state <= POPCOUNT_CALC;
                end
                POPCOUNT_CALC: begin
                    for (i = 0; i < 10; i = i + 1) begin
                        popcnt[i] = 0;
                        for (j = 0; j < 400; j = j + 1) begin
                            popcnt[i] = popcnt[i] + xnor_result[i][j];
                        end
                    end
                    state <= OUTPUT;
                end
                OUTPUT: begin
                    for (i = 0; i < 10; i = i + 1) begin
                        out_vector[i] <= (popcnt[i] >= 200) ? 1'b1 : 1'b0;
                    end
                    out_valid <= 1;
                    busy <= 0;
                    fc_ready <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule