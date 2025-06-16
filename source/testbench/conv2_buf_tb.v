`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/04 19:15:20
// Design Name: 
// Module Name: conv2_buf_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module conv2_buf_tb();
    reg clk;
    reg rst_n;
    
    reg [7:0] pixel_in;
    
    wire [71:0] pixel_windows;
    wire valid_out_buf;
    
    conv2_buf #(
        .WIDTH(13),
        .HEIGHT(13)
    ) conv2_buf_test (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(1'b1), // Always valid for testing
        .pixel_in(pixel_in),
        .pixel_windows(pixel_windows),
        .valid_out_buf(valid_out_buf)
    );
    
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    integer cycle_cnt;
    
    initial begin
        rst_n = 1'b1;
       
        #10;
        rst_n = 1'b0;
        pixel_in = 8'b0;
        cycle_cnt = 0;
        #20;
        rst_n = 1'b1;
//        #10;
        
        // test case : All ones window
        $display("Test Begin");
        
        forever begin
            @(posedge clk);
            cycle_cnt = cycle_cnt + 1;
            pixel_in = cycle_cnt[7:0];
            
            if (valid_out_buf) begin
                $display("[%0t] valid_out_buf=1, pixel_windows = 0x%018h", 
                          $time, pixel_windows);
            end
            
            if (cycle_cnt == 500) begin
                $display("Simulation finished after %0d cycles.", cycle_cnt);
                #20;
                $finish;
            end
        end
        
        $display("Test End");
        $finish;
        
    end
endmodule
