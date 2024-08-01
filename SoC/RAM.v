`timescale 1ns / 1ps

/*
The 8051 has an internal Data Memory (internal RAM) of 256 bytes. The
internal RAM is divided into 2 blocks: the first 128 byte block is the general
purpose RAM, and a second part composed by the indirect addressing only.
However, from:
- 00h to 1Fh the RAM stores the 4 banks of 8 bytes each (R0-R7)
- 20h to 2Fh bit addressable
- 30h to 7Fh Generic purpose (with stack)
- 80h to FFh Indirect Addressing Only
*/

/*
This module performs the following tasks:
- Clears the memory when reset signal is asserted
- Performs a synchronous read or write from / to the addressed memory location
- If bit data is requested, reads or writes to the addressed bit number of the addressed memory location
*/

`include "Defines.v"

module RAM(
    input i_clk,                    // Clock
    input i_rst,                    // Reset
    input [7:0] i_addr,             // Address to write 
    input [7:0] i_wr_byte,          // Data to write
    input i_wr_bit,                 // Bit to write
    input [`RAM_OP_LEN-1:0] i_op,   // Operation to do
    input [7:0] i_addr_r,           // Address to read 
    output [7:0] o_byte,            // Out byte
    output o_bit                    // Out bit
    );
    
    parameter WIDTH = 8;                            // Datapath width
    
    parameter MEMSIZE = (1<<8);                     // Memory dimension (256 bytes)
    
    (* ram_style = "distributed" *) reg [WIDTH-1:0]MEM[0:MEMSIZE-1];                // Memory
    
    integer k;
    
    wire [7:0] data;
    wire [2:0] bit_data; 
    wire [7:0]byte;
    wire bit;

    // Extract the bit adrress
    assign bit_data = i_addr[2:0];
    
    // Extract the address
    assign data = {3'b000, i_addr[7:3]};
    
    // Extract the bit adrress
    assign bit_data_r = i_addr_r[2:0];
    
    // Extract the address
    assign data_r = {3'b000, i_addr_r[7:3]};                       
    
    initial begin
        for (k = 0; k < MEMSIZE; k = k + 1)
        begin
            MEM[k] <= 8'b0;                             // Clear the memory
        end
    end
    
    always @(posedge i_clk)                            // Write at edge rise
    begin
        case (i_op)
            `OP_RAM_WR_BYTE: 
                 MEM[i_addr] <= i_wr_byte;
            `OP_RAM_WR_BIT: 
                if (i_wr_bit == 1'b1) begin
                    MEM[data] <= MEM[data] | (8'd1<<bit_data);
                end
                else begin
                    MEM[data] <= MEM[data] & ~(8'd1<<bit_data);
                end
        endcase 
    end
    
    // Read operation
    assign o_byte = (i_rst == 1'b1) ? 8'b0 : MEM[i_addr_r];
    assign o_bit = ( (i_rst == 1'b0) && i_op == `OP_RAM_RD_BIT) ? ((MEM[data_r]>>bit_data_r) & 8'd1): 1'b0;
   
endmodule