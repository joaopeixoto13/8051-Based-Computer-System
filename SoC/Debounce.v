`timescale 1ns / 1ps

/*
    This Module implements a Debounce 
*/

module Debounce(
    input i_clk,            // Clock
    input i_rst,            // Reset
    input i_signal,         // Signal unstable
    output o_signal         // Signal stable
    );
    
    // Variables
    wire slow_clk_en;
    wire os;
    parameter DIVISOR = 32'd25000000; // o_em -> 5 Hz
    reg [2:0] Q;
    reg out_signal;
    reg prev_out;
    integer k;
    reg[32:0] counter = 32'd0;
    
    // Initial Conditions
    initial begin
       Q <= 3'd0;  
       counter <= 32'd0;        
    end
    
    // Shift the bits along the array
    always @(posedge i_clk)
    begin
        if (i_rst) begin
            Q <= 3'd0;
            counter <= 32'd0;
        end
        else 
        begin
            counter <= counter + 32'd1;
            if(counter>=(DIVISOR-1))
                Q <= {Q[1],Q[0], i_signal};
                counter <= 32'd0;
        end
    end
    
    // One shot
    assign os = Q[0] & Q[1] & ~Q[2];
    
    // Adjust one shot to CPU clock domain
    always @(posedge i_clk)
    begin
        if (os == 1'b1 && prev_out == 1'b0) begin
            out_signal = 1'd1;
            prev_out = 1'b1;
        end
        else if (prev_out == 1'b1) begin
            out_signal = 1'b0;
        end
        if (os == 1'b0) begin
            prev_out = 1'b0;
        end
    end
    
    // Assign the output signal (Stable)
    assign o_signal = out_signal;
    
endmodule 