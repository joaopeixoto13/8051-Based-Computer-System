`timescale 1ns / 1ps

/*
    This module implements the integration between the VGA Controller and the Filters
*/

module VGA_Filters(
    input i_clk,                        // Clock
    input i_rst,                        // Reset
    input [7:0] i_dmod,                 // SFR (Enable and choose the filter)
    input [7:0] i_dtmcon,               // SFR (Text Mode Attributes)
    input [7:0] i_char,                 // Char to write in Text Mode
    output o_hsync,                     // HSYNC
    output o_vsync,                     // VSYNC
    output tri[4:0] o_red,              // Red
    output tri[5:0] o_green,            // Green
    output tri[4:0] o_blue,             // Blue    
    output o_key_done                   // Char was displayed
);                
   
    wire [12:0] vecIn_address0;
    wire [12:0] vecIn_address1;
    wire vecIn_ce0;
    wire vecIn_ce1;
    wire [15:0] vecIn_q0;
    wire [15:0] vecIn_q1;
    wire [12:0] vecOut_address0;
    wire [12:0] vecOut_address1;
    wire vecOut_ce0;
    wire vecOut_ce1;
    wire [15:0] vecOut_d0;
    wire [15:0] vecOut_d1;
    wire vecOut_we0; 
    wire vecOut_we1; 
    wire start;
    wire [15:0] RAM_out0;
    wire [15:0] RAM_out1;   
    reg start_accel;  
    wire [12:0] addr0_RAM;
    wire [12:0] addr1_RAM;     
    wire [12:0] vga_addr;
    wire [15:0] vga_pixel;
    
    initial begin
        start_accel <= 1'b0;
    end
     
    always @(posedge i_clk)
    begin
        // Enable && ~done
        if (i_dmod[0] == 1'b1 && o_ctrl_done == 1'b0)
        begin
            start_accel <= 1'b1;
        end
        // Accel && done
        else if (start_accel == 1'b1 && o_ctrl_done == 1'b1)
        begin
            start_accel <= 1'b0;
        end
    end
    
     // Assign the start command (sfr[0] is the accelerator enable)
    assign start = start_accel;
    
    // Acelerrator
    bd_0_wrapper bd_0_wrapper(
        .ap_clk(i_clk),
        .ap_ctrl_done(o_ctrl_done),
        .ap_ctrl_idle(o_ctrl_idle),
        .ap_ctrl_ready(o_ctrl_ready),
        .ap_ctrl_start(start),
        .ap_rst(i_rst),
        .sfr(i_dmod),
        .vecIn_address0(vecIn_address0),
        .vecIn_address1(vecIn_address1),
        .vecIn_ce0(vecIn_ce0),
        .vecIn_ce1(vecIn_ce1),
        .vecIn_q0(vecIn_q0),  
        .vecIn_q1(vecIn_q1),
        .vecOut_address0(vecOut_address0),
        .vecOut_address1(vecOut_address1),
        .vecOut_ce0(vecOut_ce0),
        .vecOut_ce1(vecOut_ce1),
        .vecOut_d0(vecOut_d0),
        .vecOut_d1(vecOut_d1),
        .vecOut_we0(vecOut_we0),
        .vecOut_we1(vecOut_we1)
    );
    
    // Basic Image
    Memory ROM(
        .i_clk(i_clk),                        
        .i_ce0(vecIn_ce0),  
        .i_ce1(vecIn_ce1),                                                
        .i_we0(1'b0),  
        .i_we1(1'b0),                                                 
        .i_addr0(vecIn_address0),  
        .i_addr1(vecIn_address1),                               
        .i_byte0(16'd0),    
        .i_byte1(16'd0),                          
        .o_byte0(vecIn_q0),
        .o_byte1(vecIn_q1)           
    );
    
    // Filtered Image
    Memory RAM(
        .i_clk(i_clk),                         
        .i_ce0(1'b1),  
        .i_ce1(vecOut_ce1),                                                 
        .i_we0(vecOut_we0), 
        .i_we1(vecOut_we1),                                                   
        .i_addr0(addr0_RAM),  
        .i_addr1(addr1_RAM),                                
        .i_byte0(vecOut_d0),  
        .i_byte1(vecOut_d1),                             
        .o_byte0(RAM_out0),
        .o_byte1(RAM_out1)                
    );
    
    // VGA Module
    VGA VGA(
        .i_clk(i_clk),                      // Clock                                                          
        .i_rst(i_rst | ~o_ctrl_idle),       // Reset                                                          
        .i_res(i_dmod[5]),                  // Resolution, if 0 -> 25mhz, if 1-> 40Mhz                        
        .i_mode(i_dmod[4]),                 // Image Mode / Text Mode                                         
        .o_hsync(o_hsync),                  // HSYNC                                                          
        .o_vsync(o_vsync),                  // VSYNC                                                          
        .o_red(o_red),                      // Red                                                            
        .o_green(o_green),                  // Green                                                          
        .o_blue(o_blue),                    // Blue                                                           
        .i_text(i_char),                    // New char / codepoint                                           
        .i_new_text(i_dmod[6]),             // Flag that indicates that a new char was received                 
        .i_text_attr(i_dtmcon),             // New char attributes (blink, background color, foreground color)
        .o_ram_addr(vga_addr),              // RAM address to read new pixel                                  
        .i_ram_pixel(RAM_out0),             // Pixel readed from RAM                                          
        .o_text_done(o_key_done)            // Flag to clear the update flag on SFR         
    );
      
    //Address 0 of RAM is set to VGA address when accelerator is idle.
    assign addr0_RAM = o_ctrl_idle ? vga_addr : vecOut_address0;
    assign addr1_RAM = vecOut_address1; 
        
endmodule
