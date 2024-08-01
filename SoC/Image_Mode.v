`timescale 1ns / 1ps

/*
    This module implements the image mode of VGA
    Basically decodes the image in the RGB values
*/

module Image_Mode(
    input i_active,                 // Active Region
    input [15:0]i_pixel,            // Image Pixel
    output tri [4:0] o_red,         // Red
    output tri [5:0] o_green,       // Green
    output tri [4:0] o_blue,        // Blue
    input i_mode                    // Mode (0->Image ; 1->Text)
);
          
    assign o_red   = i_active && !i_mode ? i_pixel[15:11] : 'hZZ;
    assign o_green = i_active && !i_mode ? i_pixel[10:5] : 'hZZ;
    assign o_blue  = i_active && !i_mode ? i_pixel[4:0] : 'hZZ;
     
endmodule