`timescale 1ns / 1ps
`include "Defines.v"

/*
    This modules implements the KBUF
    
    Details:
        - Write a full byte: (i_op = OP_KBUF_WR_BYTE && i_byte = 8'X)
*/

module KBUF(
    input i_clk,                    // Clock
    input i_rst,                    // Reset
    input [7:0] i_byte,             // Byte to write
    input [`SFR_OP_LEN-1:0]i_op,    // Operation to do
    output [7:0] o_kbuf             // KBUF
    );
    
    // KBUF register
    reg [7:0] kbuf;
    
    // Initial state
    initial begin
      kbuf <= 8'd0;   
    end 
    
    // Update the output value
    assign o_kbuf = kbuf;
    
    // Loop
    always @(posedge i_clk)
    begin
        if (i_rst == 1'b1) begin
            kbuf <= 8'd0;
        end
        else begin
            if (i_op & `OP_KBUF_WR_BYTE) begin
                kbuf <= i_byte;
            end
        end
    end

endmodule

