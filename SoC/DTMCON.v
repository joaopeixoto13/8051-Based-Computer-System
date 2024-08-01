`timescale 1ns / 1ps
/*
    This modules implements the DTMCON
    
    Details:
        - Write a full byte: (i_op = OP_DTMCON_WR_BYTE && i_byte = 8'X)
*/

module DTMCON(
    input i_clk,                    // Clock
    input i_rst,                    // Reset
    input [7:0] i_byte,             // Byte to write
    input [`SFR_OP_LEN-1:0]i_op,    // Operation to do
    output [7:0] o_dtmcon           // DTMCON
    );
    
    // DTMCON register
    reg [7:0] dtmcon;
    
    // Initial state
    initial begin
      dtmcon <= 8'h0f;   
    end 
    
    // Update the output value
    assign o_dtmcon = dtmcon;
    
    // Loop
    always @(posedge i_clk)
    begin
        if (i_rst == 1'b1) begin
            dtmcon <= 8'h0f;
        end
        else begin
            if (i_op & `OP_DTMCON_WR_BYTE) begin
                dtmcon <= i_byte;
            end
        end
    end

endmodule
