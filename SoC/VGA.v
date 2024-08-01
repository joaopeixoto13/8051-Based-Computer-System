`timescale 1ns / 1ps

/*
    This module implements VGA controler
    This module is divided in:
        - Clock generation throw PLL 
        - FSM that manages the VGA interface
        - Image Mode(Read from memory (RAM) an image (60x80) and repeat it)
        - Text Mode(Mode 17)
*/

module VGA(
    input i_clk,                            // Clock
    input i_rst,                            // Reset
    input i_res,                            // Resolution, if 0 -> 25mhz, if 1-> 40Mhz
    input i_mode,                           // Image Mode / Text Mode
    output o_hsync,                         // HSYNC
    output o_vsync,                         // VSYNC
    output  tri[4:0] o_red,                 // Red
    output  tri[5:0] o_green,               // Green
    output  tri[4:0] o_blue,                // Blue
    input [7:0] i_text,                     // New char / codepoint
    input i_new_text,                       // Flag that indicates that a new char was received
    input [7:0] i_text_attr,                // New char attributes (blink, background color, foreground color)
    output [12:0] o_ram_addr,               // RAM address to read new pixel
    input [15:0] i_ram_pixel,               // Pixel readed from RAM
    output o_text_done                      // Flag to clear the update flag on SFR
);
    
    wire clk_40Mhz;
    wire clk_25Mhz;
    wire clk_vga;
    wire active;
    wire [9:0] px_x;
    wire [9:0] px_y;
    reg previous_res;
    reg rst_res;

    // Reset after resolution change
    always @(posedge clk_25Mhz) 
    begin
        rst_res <= i_res ^ previous_res;
        previous_res <= i_res;
    end
    
    // PLL
    clk_wiz_0 pll_block
    (
      .o_clk_25Mhz(clk_25Mhz),              // 25 Mhz Clock
      .o_clk_40Mhz(clk_40Mhz),              // 40 Mhz Clock 
      .reset(i_rst),                        // Reset
      .locked(w_locked),                    // Lock
      .clk_in1(i_clk)                       // Reference Clock
    );
    
    // Clock Multiplexer
    BUFGMUX #() BUFGMUX_inst (
       .O(clk_vga),                         // 1-bit output: Clock output
       .I0(clk_25Mhz),                      // 1-bit input: Clock input (S=0)
       .I1(clk_40Mhz),                      // 1-bit input: Clock input (S=1)
       .S(i_res)                            // 1-bit input: Clock select
    );
    
    // VGA Driver FSM    
    VGA_Driver VGA_Driver(      
        .i_clk(clk_vga),                    // Clock                                               
        .i_rst(i_rst | rst_res),            // Reset                                               
        .i_locked(w_locked),                // PLL Lock                                            
        .i_res(i_res),                      // Resolution, if 0 -> 25mhz, if 1-> 40Mhz
        .o_hsync(o_hsync),                  // VGA HSYNC                                           
        .o_vsync(o_vsync),                  // VGA VSYNC                                           
        .o_active(active),                  // Active Region                                       
        .o_px_x(px_x),                      // X Pixel                                             
        .o_px_y(px_y),                      // Y Pixel
        .o_ram_addr(o_ram_addr)             // RAM addr                                         
    );
    
    // RAM Pixel Decoder 
    Image_Mode Image_Mode(
        .i_active(active),                  // Active Region
        .i_pixel(i_ram_pixel),              // Pixel from Memory
        .o_red(o_red),                      // Red
        .o_green(o_green),                  // Green
        .o_blue(o_blue),                    // Blue
        .i_mode(i_mode)                     // Image Mode / Text Mode
    );
    
    // Text Module     
    Text_Mode Text_Mode(
      .i_clk(i_clk),                        // Clock
      .i_rst(i_rst | rst_res),              // Reset
      .i_px_x(px_x),                        // Vertical Count    
      .i_px_y(px_y),                        // Horizontal Count
      .i_mode(i_mode),                      // Text mode on/off
      .i_res(i_res),                        // Get the resolution, if 1-> 800x60
      .i_active(active),                    // VGA is in active zone
      .i_ascii(i_text),                     // Char to display
      .i_text_attr(i_text_attr),            // Text attributes
      .i_update(i_new_text),                // Display new char
      .o_display_done(o_text_done),         // Display of the key done, reset the flag 
      .o_red(o_red),                        // Red
      .o_green(o_green),                    // Green    
      .o_blue(o_blue)                       // Blue
    );
    
    
    assign o_red = active ? 'hZZ : 0; 
    assign o_green = active ? 'hZZ : 0; 
    assign o_blue = active ? 'hZZ : 0; 
    
endmodule
