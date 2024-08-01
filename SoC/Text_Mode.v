`timescale 1ns / 1ps

/*
    This module implements the text generation for the VGA text mode (Mode 17 and Mode 17 adaptation for 800x600)
    Mode 17 -> 8x16 Character with 640x480
*/
    
`define CHAR_WIDTH 8                               // Number of horizontal pixels to represent each character
`define CHAR_HEIGHT 16                             // Number of vertical pixels to represent each character
`define CHAR_WIDTH_2N 3                            // Number of horizontal pixels to represent each character
`define CHAR_HEIGHT_2N 4                           // Number of vertical pixels to represent each character

      
module Text_Mode(
    input i_clk,                // Clock
    input i_rst,                // Reset
    input [9:0] i_px_x,         // Vertical Count    
    input [9:0] i_px_y,         // Horizontal Count
    input i_mode,               // Text mode on/off
    input i_res,                // Get the resolution
    input i_active,             // VGA is in active zone
    input [7:0] i_ascii,        // Char to display
    input [7:0] i_text_attr,    // Text Atrributes    
    input i_update,             // Display new char
    output o_display_done,      // Display of the key done, reset the flag 
    output tri [4:0] o_red,     // Red
    output tri [5:0] o_green,   // Green    
    output tri [4:0] o_blue     // Blue
);
    
    wire [9:0] width;                                       // Width depending of selected resolution
    wire [9:0] height;                                      // Height depending of selected resolution
    wire [7:0] max_char_per_line;                           // Max number of characters per line
    wire [7:0] max_char_per_column;                         // Max number of characters per column
    wire [11:0] max_chars;                                  // Max number of characters
    wire [127:0] glyph;                                     // Character
    wire [15:0] glyph_char_rgb;                             // Character color
    wire [15:0] glyph_back_rgb;                             // Character background color
    wire glyph_blink;                                       // Character blink flag
    wire [15:0] text_bucket;                                // The ascii code of the char to be printed
    wire [15:0] current_pixel;                              // The current RGB pixel values to be printed
    wire [11:0] index;                                      // Index indicates what char from word should be printed
    reg [15:0] text_buffer [3800:0];                        // The array of the text_buffer to be printed (with a resolution of 800x600)
    reg [11:0] cursor;                                      // Indicates the current position where the next letter will be writted
    reg update_done;                                        // Indicates that the char was displayed
    reg [26:0] blink_count;                                 // Blink count 
    reg [8:0] r1;                                           // Aux
    reg [8:0] r2;                                           // Aux
    reg [11:0] text_addr;                                   // Text Buffer Addr
    reg [15:0] text_data;                                   // Text Data
    reg text_we;                                            // Text Write Enable
    integer i;
    
    initial
    begin
        // Initialize all the chars that will be written (or not) in the display
        for(i = 0; i <= 3800; i = i + 1)
        begin
            text_buffer[i] = 16'h0020;
        end
        cursor <= 12'd0;
        update_done <= 1'b0;
        blink_count <= 27'd0;
        r1 <= 8'd0;
        r2 <= 8'd0;
        
    end
    
    // Codepoint to Cliph translation(font)
    Gliph_Map Gliph_Map(
        .i_codepoint(text_bucket[7:0]),            // Codepoint
        .o_glyph(glyph)                            // Character
    );
    
    // Attributes
    Attribute_Map Attribute_Map(
        .i_attr(text_bucket[15:8]),                 // Attributes
        .o_char_rgb(glyph_char_rgb),                // Char/ Foreground Color
        .o_back_rgb(glyph_back_rgb),                // Background Color
        .o_blink(glyph_blink)                       // Blink
    );
    
    
    // Update   
    always @(posedge i_clk)
    begin
        if(i_rst)                                                   // Reset
        begin
            cursor <= 12'd0;
            update_done <= 1'b0;
            r1 <= 0;
            r2 <= 0; 
        end
        else
        begin
            if(i_update == 1'b1 && update_done == 1'b0)             // If a new char is received
            begin
                update_done = 1'b1;
                // Update Cursor
                cursor <= (i_ascii == 8'd8 && cursor == 12'd0) ? (max_chars - 12'd1):
                          (i_ascii == 8'd8) ? (cursor - 12'd1):
                          (i_ascii == 8'd13) ? (cursor + r2): (cursor + 12'd1);
                
                // Update Addr to write new text
                text_addr <= (i_ascii == 'd8 && cursor == 0) ? (max_chars - 12'd1):
                             (i_ascii == 'd8) ? cursor - 12'd1 :
                             (i_ascii != 8'd13) ? cursor : 12'd0;
                
                // Update data             
                text_data <= (i_ascii == 'd8) ? 16'd32:
                             (i_ascii != 8'd13) ? {i_text_attr,i_ascii} : 12'd0;  
                             
                text_we <= (i_ascii != 8'd13) ? 1'b1 : 1'b0;                                               
            end
            else
            begin
                update_done <= 0;
                cursor <= (cursor >= max_chars) ? 12'd0 : cursor;
                r1 <= cursor % max_char_per_line;
                r2 <= max_char_per_line - r1;
                if (text_we)
                    text_buffer[text_addr] <= text_data;     
                text_we <=  1'b0; 
            end
        end
    end
    
    assign o_display_done = update_done;
    
    // Blink
    always @(posedge i_clk)
    begin
        if(i_rst)                                       // Reset
            blink_count = 27'b0;
        else
        begin
            blink_count <= blink_count + 1;
        end
    end
    
    // Update the bucket 
    assign text_bucket = (index == cursor && blink_count[26]) ? 16'h0F5F : text_buffer[index];
    
    // Get the index of array chars depending of the position of count
    assign index = i_px_x[9:`CHAR_HEIGHT_2N] * max_char_per_line + i_px_y[9:`CHAR_WIDTH_2N];
     
    // Update the current pixel
    assign current_pixel = (i_active && glyph_blink == 1'b1 && blink_count[26]) ? 16'h0000 : 
                           (i_active && glyph['h7F - {(i_px_x & (`CHAR_HEIGHT - 1)),`CHAR_WIDTH_2N'd0} - (i_px_y & (`CHAR_WIDTH - 1))])? glyph_char_rgb : glyph_back_rgb;
    
    // Assign the pixel variables
    assign o_red = i_mode ? current_pixel[15:11] : 'hZZ;
    assign o_green = i_mode ? current_pixel[10:5] : 'hZZ;
    assign o_blue = i_mode ? current_pixel[4:0] : 'hZZ;
    
    // Width and Height dependent of the resolution
    assign width = i_res ? 800 : 640;
    assign height = i_res ? 600 : 480;
    
    assign max_char_per_line = i_res ? 100 : 80;
    assign max_char_per_column = i_res ? 37 : 30;
    
    assign max_chars = i_res ? 3700 : 2400;
    
endmodule