`timescale 1ns / 1ps

/*
    The PS/2 controller is responsible for receiving the bits read from the ps/2
    data line and outputing the respective byte key (if valid), while signaling 
    each time there is a new one.
    Only the reception was implemented.
*/

module PS2_Controller(
    input i_clk,                // Clock
    input i_rst,                // Reset
    input i_clk_ps2,            // PS/2 clock
    input i_data_ps2,           // PS/2 incoming bit
    input i_rx_en_ps2,          // PS/2 reception enable
    output [7:0] o_byte_code,   // PS/2 resultant byte code
    output o_update_key         // "New key" signal
);
    
    // Instantiate the PS2 Reception
    PS2_RX PS2_RX(
        .i_clk(i_clk),                          // Clock
        .i_rst(i_rst),                          // Reset
        .i_clk_ps2(i_clk_ps2),                  // PS/2 clock
        .i_data_ps2(i_data_ps2),                // PS/2 incoming bit
        .i_rx_en_ps2(i_rx_en_ps2),              // PS/2 reception enable
        .o_byte_code(o_byte_code),              // PS/2 resultant byte code
        .o_update_key(o_update_key),            // "New key" signal
        .o_idle()                               // Not used in actual implementation
    );

endmodule
