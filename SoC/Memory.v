`timescale 1ns / 1ps

/*
    This module implements a dual port RAM
*/

module Memory(
    input i_clk,                              // Clock
    input i_ce0,                              // Clock Enable 
    input i_ce1,                              // Clock Enable 
    input i_we0,                              // Write Enable 
    input i_we1,                              // Write Enable 
    input [12:0] i_addr0,                     // Address 
    input [12:0] i_addr1,                     // Address 
    input [15:0] i_byte0,                     // Data to Write
    input [15:0] i_byte1,                     // Data to Write
    output reg [15:0] o_byte0,                // Out byte 
    output reg [15:0] o_byte1                 // Out byte 
    );
    
    parameter WIDTH = 16;                           // Width
    
    parameter MEMSIZE = 4800;                       // Memory dimension
    
    reg [WIDTH-1:0]MEM[0:MEMSIZE-1];                // Memory

    initial begin
        $readmemb("image.mem", MEM);
    end
    
    always @(posedge i_clk)
    begin
        if (i_ce0 == 1) begin
            o_byte0 <= MEM[i_addr0];
            if (i_we0 == 1) 
            begin
                MEM[i_addr0] <= i_byte0;
            end
        end 
    end
    
    always @(posedge i_clk)
    begin
        if (i_ce1 == 1) begin
            o_byte1 <= MEM[i_addr1];
            if (i_we1 == 1) 
            begin
                MEM[i_addr1] <= i_byte1;
            end
        end 
    end
endmodule