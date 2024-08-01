`timescale 1ns / 1ps

/*
    This module implements the Top Module of the Keyboard responsable for receive the data via PS/2,
    and convert to ASCII
*/

module Keyboard(
    input   i_clk,              // Clock
    input   i_rst,              // Reset
    input   i_clk_ps2,          // Clock PS/2
    input   i_data_ps2,         // Data PS/2
    input   i_rx_en_ps2,        // PS/2 reception enable
    output  [7:0] o_ascii,      // Character received
    output o_key_received       // Reception Signal
);

    // Internal Connections
    wire[7:0] w_key_code;     
    wire w_update_key, w_is_upper, w_shift_on;

    
    // Instanciate the PS/2 Driver
    PS2_Controller PS2_Controller(
        .i_clk(i_clk),                      // Clock
        .i_rst(i_rst),                      // Reset
        .i_clk_ps2(i_clk_ps2),              // PS/2 clock
        .i_data_ps2(i_data_ps2),            // PS/2 incoming bit
        .i_rx_en_ps2(i_rx_en_ps2),          // PS/2 reception enable
        .o_byte_code(w_key_code),           // PS/2 resultant byte code
        .o_update_key(w_update_key)         // "New key" signal
    );
    
    // Instanciate the Keyboard 
    Key_FSM Key_FSM (
        .i_clk(i_clk),                      // Clock
        .i_rst(i_rst),                      // Reset
        .i_byte_code(w_key_code),           // Byte Code
        .i_update_key(w_update_key),        // Update Key
        .o_is_upper(w_is_upper),            // Is Uppercase
        .o_shift_on(w_shift_on),            // Shift is pressed
        .o_new_key(o_key_received)          // Reception Signal(New Key)    
    );
    
    // Instanciate the Key to ASCII Converter    
    Key_to_ASCII Key_to_ASCII(
        .i_key_code(w_key_code),            // Keycode to transale
        .i_is_upper(w_is_upper),            // Is Uppercase
        .i_shift_on(w_shift_on),            // Shift is pressed
        .o_ASCII(o_ascii)                   // ASCII
    );

endmodule