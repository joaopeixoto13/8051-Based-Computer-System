`timescale 1ns / 1ps

/*
    This module implements the buffers of the pipeline
*/

module Buffer( 
	input i_clk,                                   // Clock
	input i_rst,                                   // Reset
	input [`BUFFER_LENGTH-1:0] i_in,               // Input Buffer
	output reg 	[`BUFFER_LENGTH-1:0] o_out         // Output Buffer
);
    // Define initial conditions
    initial begin
        o_out <= 0; 
    end

    always@(posedge i_clk)
    begin
        if(i_rst)
            o_out <= 0;                  
        else
            o_out <= i_in;
    end

endmodule 