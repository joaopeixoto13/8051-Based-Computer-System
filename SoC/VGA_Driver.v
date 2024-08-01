`timescale 1ns / 1ps

/*
    This module is the implementation of the VGA_Driver FSM
*/

//States 
`define H_ACTIVE 0           
`define H_FRONT_PORCH 1
`define H_SYNC_PULSE 2
`define H_BACK_PORCH 3
`define H_LINE_DONE 3

`define V_ACTIVE 0
`define V_FRONT_PORCH 1
`define V_SYNC_PULSE 2
`define V_BACK_PORCH 3


module VGA_Driver(
    input i_clk,                            // Clock
    input i_rst,                            // Reset
    input i_locked,                         // PLL Lock
    input i_res,                            // Select the clock source, if 0 -> 25mhz, if 1-> 40Mhz
    output o_hsync ,                        // VGA HSYNC
    output o_vsync ,                        // VGA VSYNC
    output o_active ,                       // Active Region
    output [9:0] o_px_x,                    // X Pixel
    output [9:0] o_px_y,                    // Y Pixel
    output [12:0] o_ram_addr                // RAM Addrz
);
    
    // Counter Registers             
    reg [9:0] r_hcounter;
    reg [9:0] r_vcounter;   
    // State Registers
    reg [1:0] r_hstate; 
    reg [1:0]r_vstate ;        
    // Sync Registers
    reg r_hsync;
    reg r_vsync;     
    // Control
    reg r_line_done;
    reg [12:0] r_haddr;
    reg [12:0] r_vaddr;
    
    // Resolution wires
    wire [9:0]w_front_porch_Hmax;
    wire [9:0]w_active_area_Hmax;
    wire [9:0]w_sync_pulse_Hmax;
    wire [9:0]w_back_porch_Hmax;
    
    wire [9:0]w_front_porch_Vmax;
    wire [9:0]w_active_area_Vmax;
    wire [9:0]w_sync_pulse_Vmax;
    wire [9:0]w_back_porch_Vmax;
    
    // Initial Conditions
    initial begin
        r_hcounter <= 10'd0;
        r_vcounter <= 10'd0;
        r_hstate <= `H_ACTIVE;
        r_vstate <= `V_ACTIVE;
        r_hsync <= 1'b0;
        r_vsync <= 1'b0;
        r_line_done <= 1'b0;
        r_haddr <= 13'd0;
        r_vaddr <= 13'd0;
    end


    always @(posedge i_clk)
    begin
        if(i_rst || ~i_locked)                          // Reset or Locked
        begin
            r_vsync <= 1'b0;
            r_hsync <= 1'b0;
            r_hcounter <= 10'd0;
            r_vcounter <= 10'd0;
            r_hstate <= `H_ACTIVE;
            r_vstate <= `V_ACTIVE;
            r_line_done <= 1'b0;
            r_haddr <= 13'd0;
            r_vaddr <= 13'd0;
        end
        else 
        begin
            ////////// Horizontal update ///////////
            case(r_hstate)
                `H_ACTIVE: begin
                    r_hcounter <= (r_hcounter == w_active_area_Hmax)? 10'd0 : (r_hcounter + 10'd1);
                    r_hsync <= 1'b1;
                    r_line_done <= 1'b0;
                    r_hstate <= (r_hcounter == w_active_area_Hmax)? `H_FRONT_PORCH : `H_ACTIVE;
                    r_haddr <= (r_haddr == 79)? 13'd0 : (r_haddr + 13'd1); 
                    end
                `H_FRONT_PORCH: begin
                    r_haddr <= 13'd0;
                    r_hcounter <= (r_hcounter == w_front_porch_Hmax)? 10'd0 : (r_hcounter + 10'd1);
                    r_hsync <= 1'b1;
                    r_hstate <= (r_hcounter == w_front_porch_Hmax)? `H_SYNC_PULSE : `H_FRONT_PORCH;
                end
                `H_SYNC_PULSE: begin;
                    r_hcounter <= (r_hcounter == w_sync_pulse_Hmax)? 10'd0 : (r_hcounter + 10'd1);
                    r_hsync <= 1'b0;
                    r_hstate <= (r_hcounter == w_sync_pulse_Hmax)? `H_BACK_PORCH : `H_SYNC_PULSE;
                end
                `H_BACK_PORCH: begin
                    r_hcounter <= (r_hcounter == w_back_porch_Hmax)?10'd0:(r_hcounter + 10'd1);
                    r_hsync <= 1'b1;
                    r_hstate <= (r_hcounter == w_back_porch_Hmax)? `H_ACTIVE : `H_BACK_PORCH;
                    r_line_done <= (r_hcounter == (w_back_porch_Hmax-1)) ? 1'b1 : 1'b0;
                end
            endcase
            
            ////////// Vertical Update ///////////
            case(r_vstate)
                `V_ACTIVE: begin
                    r_vcounter <= (r_line_done) ? ((r_vcounter == w_active_area_Vmax) ? 10'd0: (r_vcounter + 10'd1)): r_vcounter;
                    r_vsync <= 1'b1;
                    r_vstate <= (r_line_done && r_vcounter == w_active_area_Vmax) ? `V_FRONT_PORCH : `V_ACTIVE;
                    r_vaddr <= (r_line_done) ? ((r_vaddr == 13'd4720)? 13'd0 : (r_vaddr + 13'd80)) : r_vaddr;
                end
                `V_FRONT_PORCH: begin
                    r_vaddr <= 13'd0;
                    r_vcounter <= (r_line_done) ? ((r_vcounter == w_front_porch_Vmax) ? 10'd0 : (r_vcounter + 10'd1)): r_vcounter;
                    r_vsync <= 1'b1;
                    r_vstate <= (r_line_done && r_vcounter == w_front_porch_Vmax) ? `V_SYNC_PULSE : `V_FRONT_PORCH;
                end
                `V_SYNC_PULSE: begin
                    r_vcounter <= (r_line_done) ? ((r_vcounter == w_sync_pulse_Vmax)? 10'd0 : (r_vcounter + 10'd1)): r_vcounter;
                    r_vsync <= 1'b0;
                    r_vstate <= (r_line_done && r_vcounter == w_sync_pulse_Vmax)? `V_BACK_PORCH:`V_SYNC_PULSE;
                end
                `V_BACK_PORCH: begin                      
                    r_vcounter <= (r_line_done) ? ((r_vcounter == w_back_porch_Vmax)? 10'd0 : (r_vcounter + 10'd1)): r_vcounter;
                    r_vsync <= 1'b1;
                    r_vstate <= (r_line_done && r_vcounter == w_back_porch_Vmax)? `V_ACTIVE : `V_BACK_PORCH;
                end
            endcase
        end
    end

    //addr to acess the RAM memory
    //Img in RAM is 80x60 so its necessary a mask
    assign o_ram_addr = r_vaddr + r_haddr;
   
    // Assign HSYNC and VSYNC
    assign o_hsync = r_hsync;
    assign o_vsync = r_vsync;
    
    // Active Region
    assign o_active = ((r_hstate == `H_ACTIVE) && (r_vstate == `V_ACTIVE) && ~i_rst && i_locked) ? 1'b1: 1'b0;

    // Resolution dependent variables
    assign w_active_area_Hmax = (i_res == 1'b1) ? 'd799 : 'd639;
    assign w_front_porch_Hmax = (i_res == 1'b1) ? 'd39 : 'd15;
    assign w_sync_pulse_Hmax  = (i_res == 1'b1) ? 'd127 : 'd95;
    assign w_back_porch_Hmax  = (i_res == 1'b1) ? 'd87 : 'd47;
    
    assign w_active_area_Vmax = (i_res == 1'b1) ? 'd599 : 'd479;
    assign w_front_porch_Vmax = (i_res == 1'b1) ? 'd0 : 'd9;
    assign w_sync_pulse_Vmax  = (i_res == 1'b1) ? 'd3 : 'd1;
    assign w_back_porch_Vmax  = (i_res == 1'b1) ? 'd22 : 'd32;
    
    // Coordinates on Display
    assign o_px_x = ((r_vstate == `V_ACTIVE == 1'b1) && (~i_rst) && i_locked) ? (r_vcounter) : 10'd0;
    assign o_px_y = ((r_hstate == `H_ACTIVE == 1'b1) && (~i_rst) && i_locked) ? (r_hcounter) : 10'd0;
    
endmodule