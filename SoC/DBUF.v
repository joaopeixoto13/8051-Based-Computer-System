`timescale 1ns / 1ps
`include "Defines.v"

/*
    This modules implements the DBUF
    
    Details:
        - Write a full byte: (i_op = OP_DBUF_WR_BYTE && i_byte = 8'X)
*/

module DBUF(
    input i_clk,                    // Clock
    input i_rst,                    // Reset
    input [7:0] i_byte,             // Byte to write
    input [`SFR_OP_LEN-1:0]i_op,    // Operation to do
    output [7:0] o_dbuf             // DBUF
    );
    
    // DBUF register
    reg [7:0] dbuf;
    
    // Initial state
    initial begin
      dbuf <= 8'd0;   
    end 
    
    // Update the output value
    assign o_dbuf = dbuf;
    
    // Loop
    always @(posedge i_clk)
    begin
        if (i_rst == 1'b1) begin
            dbuf <= 8'd0;
        end
        else begin
            if (i_op & `OP_DBUF_WR_BYTE) begin
                dbuf <= i_byte;
            end
        end
    end

endmodule
