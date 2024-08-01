`timescale 1ns / 1ps

/*
    This module implements the decode of the text attributes
*/

module Attribute_Map(
    input [7:0] i_attr,                // Attributes
    output [15:0] o_char_rgb,          // Char/ Foreground Color
    output [15:0] o_back_rgb,          // Background Color
    output o_blink                     // Blink
);
    
// Char Color
assign o_char_rgb = i_attr[3:0] == 4'h0 ? 16'h0000
    : i_attr[3:0] == 4'h1 ? 16'h0015
    : i_attr[3:0] == 4'h2 ? 16'h0540
    : i_attr[3:0] == 4'h3 ? 16'h0555
    : i_attr[3:0] == 4'h4 ? 16'hA800
    : i_attr[3:0] == 4'h5 ? 16'hA815
    : i_attr[3:0] == 4'h6 ? 16'hAAA0
    : i_attr[3:0] == 4'h7 ? 16'hAD55
    : i_attr[3:0] == 4'h8 ? 16'h52AA
    : i_attr[3:0] == 4'h9 ? 16'h52BF
    : i_attr[3:0] == 4'hA ? 16'h57EA
    : i_attr[3:0] == 4'hB ? 16'h57FF
    : i_attr[3:0] == 4'hC ? 16'hFAAA
    : i_attr[3:0] == 4'hD ? 16'hFABF
    : i_attr[3:0] == 4'hE ? 16'hFFEA
    : i_attr[3:0] == 4'hF ? 16'hFFFF
    : 16'h000000;

// Background Color
assign o_back_rgb = i_attr[6:4] == 3'b000 ? 16'h0000
    : i_attr[6:4] == 3'b001 ? 16'h0015
    : i_attr[6:4] == 3'b010 ? 16'h0540
    : i_attr[6:4] == 3'b011 ? 16'h0555
    : i_attr[6:4] == 3'b100 ? 16'hA800
    : i_attr[6:4] == 3'b101 ? 16'hA815
    : i_attr[6:4] == 3'b110 ? 16'hAAA0
    : i_attr[6:4] == 3'b111 ? 16'hAD55
    : 16'h000000;
    
// Blink    
assign o_blink = i_attr[7];

endmodule
