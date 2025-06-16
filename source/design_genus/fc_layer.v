module fc_layer #(
    parameter INPUT_NUM = 400, 
    parameter OUTPUT_NUM = 10
) (
   input clk,
   input rst_n,
   input valid_in,
//   input signed [11:0] data_in_1, data_in_2, data_in_3,
   input pixel_in_1, pixel_in_2, pixel_in_3, pixel_in_4, pixel_in_5, pixel_in_6, pixel_in_7, pixel_in_8,
   pixel_in_9, pixel_in_10, pixel_in_11, pixel_in_12, pixel_in_13, pixel_in_14, pixel_in_15, pixel_in_16,
   output reg [8:0] fc_out_1, fc_out_2, fc_out_3, fc_out_4, fc_out_5,
   fc_out_6, fc_out_7, fc_out_8, fc_out_9, fc_out_10,
   output reg valid_out_fc
 );
    localparam [7:0] THRESH = 8'd200; // for popcnt
    
    reg state; // state=0 fill in the buffer; state=1 output the value
    reg [4:0] cnt;
    reg [3:0] out_idx;
    
    reg buffer [0:INPUT_NUM-1]; // store the 400 pixels
    integer i, j;
//    reg w1 [0:INPUT_NUM-1];
//    reg w2 [0:INPUT_NUM-1];
//    reg w3 [0:INPUT_NUM-1];
//    reg w4 [0:INPUT_NUM-1];
//    reg w5 [0:INPUT_NUM-1];
//    reg w6 [0:INPUT_NUM-1];
//    reg w7 [0:INPUT_NUM-1];
//    reg w8 [0:INPUT_NUM-1];
//    reg w9 [0:INPUT_NUM-1];
//    reg w10 [0:INPUT_NUM-1];
    
//    initial begin
//        $readmemb("../../../../../source/design/weights/fc/weight_ch1.txt",  w1);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch2.txt",  w2);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch3.txt",  w3);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch4.txt",  w4);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch5.txt",  w5);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch6.txt",  w6);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch7.txt",  w7);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch8.txt",  w8);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch9.txt",  w9);
//        $readmemb("../../../../../source/design/weights/fc/weight_ch10.txt",  w10);
//    end
    localparam w1 = 400'b1001100110011000110001000110001100001000000100000001101001000000011001100000000101111111011111100010011110100001000010100101011101001000010000010111111111000000000001101001110110011100001100000010010110000111000110000011111001100011000000000011100111111001110011000000010000011101001000010000011101011000011010110110001100000110101111101110000010110011100011000000000111110110010001110111110011100100;
    localparam w2 = 400'b0111001110010001101101111001100001110010100100000101110010000000110011111001101110011110001100011111011000000100010001110011101110110111100100111100001100100000001110101111000010001001010010101000100001011100001001000001110001000100001000111001011100100110101011010110111110011000110010000100011000010111101100101101110011110011111110011101111010111011011100100001100011011011101101011011101111001110;
    localparam w3 = 400'b1011000000000001011111100111101111000111001010011111001111000011000010011010000001100110001100010100111111000000011001101100100000010001111101111100011111000010000110011111111000000000001111001001011010001110000011100111011010011001111111111000100100000000110111111111110000011100110000011100111110000000100011110011110100011000101111111000100010010011100110000111100111010000001000001110111100110001;
    localparam w4 = 400'b1000000011110111000110110111010011011110001110011100111111110110100010011011100110001010111100010000001010011111011001110011001111000111000100010001011100101010111101111110111011100111000111001111000110111011110111100111001101110100000111101111100110111010011100011111100000101111011111101100011000101000110000001111010000000000010000111010010011110000111011110101100011001001011110000000001100000001;
    localparam w5 = 400'b0111010110101001111100100001001101000100000010000011001111100111000001001111111100000011111111111111001000110100000000011010101111100001010011111110011000001111011110000100001011110001100000000001101010111111110000000000111100010010001100011110011100101100000010000111011111110111101111000000101000101110001000010111111011101110011000101010111100100110011001100110000000101111111000000111011111111100;
    localparam w6 = 400'b0100101101110110111100001111010001101100110001111000110111111111101111101111101010000001010011000011001110001101011111111101001101110101100100100111101111100001001101101011110011110011011000110000011100111001111100011101000101111111001001000001011111111111101100000000001110000111001111110111100111111100010000000010001000001111010000100100001110110000111111111110011101110011101011001100110001100011;
    localparam w7 = 400'b1001101111000000110011101111111000001000110001100001101001001110000001000010011100111001110011100111111101000010000010001001100111010010100011101100001111011001111000000011110110011000000000110100110010101001000100011000000001000011000011011111101111100001100000100111011110101011000001000011100000001000000011000110111111111100100111100101001000010100001001001110011000000000010000011101110111101101;
    localparam w8 = 400'b1110011111101001000100111000011011100111010001111100000000000000111101001111111111010010001100010010000001000100110111110111111111001101011000011111100000011011000111110100000111110101100110000000000111110100110111001101011110011110111101001000010001101101011110111001011001110010000111010000111111111111001110011001000000000111011011111000100011010010010001100001101111001101111100110101101000000011;
    localparam w9 = 400'b1011111001000000011110000000111111111011010000010100110111000111111111110001110010111011001111000001000011110011111010101110000000101001100100000100111101101100110101010001110000000001111011000010101100100010111000001100001111111000111110001111000111111001001001001110001101100111110001100000100100001001110011001000000110111111110011111001111110000000000110000110000000110101100100001000001000010011;
    localparam w10 = 400'b0100011101101111000011000010010111110100001000011100000001111111111010110001101111011110111000000001000100111101101111010110111111100101000011001011110000100110111100110000010001111010100100011110011101111111000000001100001100001001000111000011100011011101010010000001010001011111001110000001001111000111111100101000001000000111001100011110001111010110011001100010011001000001111111010110001000100010; 
    
    
    function [8:0] popcount400;
        input [INPUT_NUM-1:0] bits;
        integer idx;
        begin
            popcount400 = 9'd0;
            for (idx = 0; idx < INPUT_NUM; idx = idx + 1) begin
                popcount400 = popcount400 + bits[idx];
            end
        end
    endfunction
    
    wire [15:0] tmp_flat = {
        pixel_in_16, pixel_in_15, pixel_in_14, pixel_in_13,
        pixel_in_12, pixel_in_11, pixel_in_10, pixel_in_9,
        pixel_in_8,  pixel_in_7,  pixel_in_6,  pixel_in_5,
        pixel_in_4,  pixel_in_3,  pixel_in_2,  pixel_in_1
    };
    
    wire [INPUT_NUM-1:0] match1;
    wire [INPUT_NUM-1:0] match2;
    wire [INPUT_NUM-1:0] match3;
    wire [INPUT_NUM-1:0] match4;
    wire [INPUT_NUM-1:0] match5;
    wire [INPUT_NUM-1:0] match6;
    wire [INPUT_NUM-1:0] match7;
    wire [INPUT_NUM-1:0] match8;
    wire [INPUT_NUM-1:0] match9;
    wire [INPUT_NUM-1:0] match10;
    
    genvar gv;
    generate
        for (gv = 0; gv < INPUT_NUM; gv = gv + 1) begin: XNOR_LOOP
            assign match1[gv] = ~(buffer[gv] ^ w1[gv]);
            assign match2[gv] = ~(buffer[gv] ^ w2[gv]);
            assign match3[gv] = ~(buffer[gv] ^ w3[gv]);
            assign match4[gv] = ~(buffer[gv] ^ w4[gv]);
            assign match5[gv] = ~(buffer[gv] ^ w5[gv]);
            assign match6[gv] = ~(buffer[gv] ^ w6[gv]);
            assign match7[gv] = ~(buffer[gv] ^ w7[gv]);
            assign match8[gv] = ~(buffer[gv] ^ w8[gv]);
            assign match9[gv] = ~(buffer[gv] ^ w9[gv]);
            assign match10[gv] = ~(buffer[gv] ^ w10[gv]);
        end
    endgenerate 
    
    wire [8:0] cnt1 = popcount400(match1);
    wire [8:0] cnt2  = popcount400(match2);
    wire [8:0] cnt3  = popcount400(match3);
    wire [8:0] cnt4  = popcount400(match4);
    wire [8:0] cnt5  = popcount400(match5);
    wire [8:0] cnt6  = popcount400(match6);
    wire [8:0] cnt7  = popcount400(match7);
    wire [8:0] cnt8  = popcount400(match8);
    wire [8:0] cnt9  = popcount400(match9);
    wire [8:0] cnt10 = popcount400(match10);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 1'b0;
            cnt <= 5'd0;
            valid_out_fc <= 1'b0;
            for (i = 0; i < INPUT_NUM; i = i + 1) begin
                buffer[i] <= 1'b0;
            end
            fc_out_1  <= 1'b0;
            fc_out_2  <= 1'b0;
            fc_out_3  <= 1'b0;
            fc_out_4  <= 1'b0;
            fc_out_5  <= 1'b0;
            fc_out_6  <= 1'b0;
            fc_out_7  <= 1'b0;
            fc_out_8  <= 1'b0;
            fc_out_9  <= 1'b0;
            fc_out_10 <= 1'b0;
        end else begin
            valid_out_fc <= 1'b0;
            case (state)
                1'b0: begin
                    if (valid_in) begin
                        for (i = 0; i < 16; i = i + 1) begin
                            buffer[i*25 + cnt] <= tmp_flat[i];
                        end
                        
                        if (cnt == 5'd24) begin
                            // finish collecting
                            cnt <= 5'd0;
                            state <= 1'b1;
                        end else begin
                            cnt <= cnt + 5'd1;
                        end
                    end
                end
                
                1'b1: begin
                    fc_out_1 <= cnt1;
                    fc_out_2 <= cnt2;
                    fc_out_3 <= cnt3;
                    fc_out_4 <= cnt4;
                    fc_out_5 <= cnt5;
                    fc_out_6 <= cnt6;
                    fc_out_7 <= cnt7;
                    fc_out_8 <= cnt8;
                    fc_out_9 <= cnt9;
                    fc_out_10 <= cnt10;
                    
                    valid_out_fc <= 1'b1;
                    
                    state <= 1'b0;
                end
            endcase 
        end
    end
 endmodule    

// localparam INPUT_WIDTH = 16;
// localparam INPUT_NUM_DATA_BITS = 5;

// reg state;
// reg [INPUT_WIDTH - 1:0] buf_idx;
// reg [3:0] out_idx;
// reg signed [13:0] buffer [0:INPUT_NUM - 1];
// reg signed [DATA_BITS - 1:0] weight [0:INPUT_NUM * OUTPUT_NUM - 1];
// reg signed [DATA_BITS - 1:0] bias [0:OUTPUT_NUM - 1];
   
// wire signed [19:0] calc_out;
// wire signed [13:0] data1, data2, data3;

// initial begin
//   $readmemh("fc_weight.txt", weight);
//   $readmemh("fc_bias.txt", bias);
// end

// assign data1 = (data_in_1[11] == 1) ? {2'b11, data_in_1} : {2'b00, data_in_1};
// assign data2 = (data_in_2[11] == 1) ? {2'b11, data_in_2} : {2'b00, data_in_2};
// assign data3 = (data_in_3[11] == 1) ? {2'b11, data_in_3} : {2'b00, data_in_3};
 
// always @(posedge clk) begin
//   if(~rst_n) begin
//     valid_out_fc <= 0;
//     buf_idx <= 0;
//     out_idx <= 0;
//     state <= 0;
//   end

//   if(valid_out_fc == 1) begin
//     valid_out_fc <= 0;
//   end

//   if(valid_in == 1) begin
//     // Wait until 48 input data filled in buffer
//     if(!state) begin
//       buffer[buf_idx] <= data1;
//       buffer[INPUT_WIDTH + buf_idx] <= data2;
//       buffer[INPUT_WIDTH * 2 + buf_idx] <= data3;
//       buf_idx <= buf_idx + 1'b1;
//       if(buf_idx == INPUT_WIDTH - 1) begin
//         buf_idx <= 0;
//         state <= 1;
//         valid_out_fc <= 1;
//       end
//     end else begin // valid state
//       out_idx <= out_idx + 1'b1;
//       if(out_idx == OUTPUT_NUM - 1) begin
//         out_idx <= 0;
//       end
//       valid_out_fc <= 1;
//     end
//   end
// end

// assign calc_out = weight[out_idx * INPUT_NUM] * buffer[0] + weight[out_idx * INPUT_NUM + 1] * buffer[1] + 
//		  		weight[out_idx * INPUT_NUM + 2] * buffer[2] + weight[out_idx * INPUT_NUM + 3] * buffer[3] + 
//  				weight[out_idx * INPUT_NUM + 4] * buffer[4] + weight[out_idx * INPUT_NUM + 5] * buffer[5] + 
//	  			weight[out_idx * INPUT_NUM + 6] * buffer[6] + weight[out_idx * INPUT_NUM + 7] * buffer[7] + 
//		  		weight[out_idx * INPUT_NUM + 8] * buffer[8] + weight[out_idx * INPUT_NUM + 9] * buffer[9] + 
//  				weight[out_idx * INPUT_NUM + 10] * buffer[10] + weight[out_idx * INPUT_NUM + 11] * buffer[11] + 
//  				weight[out_idx * INPUT_NUM + 12] * buffer[12] + weight[out_idx * INPUT_NUM + 13] * buffer[13] + 
//	  			weight[out_idx * INPUT_NUM + 14] * buffer[14] + weight[out_idx * INPUT_NUM + 15] * buffer[15] + 
//  				weight[out_idx * INPUT_NUM + 16] * buffer[16] + weight[out_idx * INPUT_NUM + 17] * buffer[17] + 
//  				weight[out_idx * INPUT_NUM + 18] * buffer[18] + weight[out_idx * INPUT_NUM + 19] * buffer[19] + 
//  				weight[out_idx * INPUT_NUM + 20] * buffer[20] + weight[out_idx * INPUT_NUM + 21] * buffer[21] + 
//  				weight[out_idx * INPUT_NUM + 22] * buffer[22] + weight[out_idx * INPUT_NUM + 23] * buffer[23] + 
//  				weight[out_idx * INPUT_NUM + 24] * buffer[24] + weight[out_idx * INPUT_NUM + 25] * buffer[25] + 
//  				weight[out_idx * INPUT_NUM + 26] * buffer[26] + weight[out_idx * INPUT_NUM + 27] * buffer[27] + 
//  				weight[out_idx * INPUT_NUM + 28] * buffer[28] + weight[out_idx * INPUT_NUM + 29] * buffer[29] + 
//  				weight[out_idx * INPUT_NUM + 30] * buffer[30] + weight[out_idx * INPUT_NUM + 31] * buffer[31] + 
//  				weight[out_idx * INPUT_NUM + 32] * buffer[32] + weight[out_idx * INPUT_NUM + 33] * buffer[33] + 
//  				weight[out_idx * INPUT_NUM + 34] * buffer[34] + weight[out_idx * INPUT_NUM + 35] * buffer[35] + 
//  				weight[out_idx * INPUT_NUM + 36] * buffer[36] + weight[out_idx * INPUT_NUM + 37] * buffer[37] + 
//  				weight[out_idx * INPUT_NUM + 38] * buffer[38] + weight[out_idx * INPUT_NUM + 39] * buffer[39] + 
//	  			weight[out_idx * INPUT_NUM + 40] * buffer[40] + weight[out_idx * INPUT_NUM + 41] * buffer[41] + 
//	  			weight[out_idx * INPUT_NUM + 42] * buffer[42] + weight[out_idx * INPUT_NUM + 43] * buffer[43] + 
//	  			weight[out_idx * INPUT_NUM + 44] * buffer[44] + weight[out_idx * INPUT_NUM + 45] * buffer[45] + 
//  				weight[out_idx * INPUT_NUM + 46] * buffer[46] + weight[out_idx * INPUT_NUM + 47] * buffer[47] + 
//  				bias[out_idx];
// assign data_out = calc_out[18:7];

