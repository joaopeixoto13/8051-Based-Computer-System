`timescale 1ns / 1ps

/*
    This module implements the FSM responsible to decode if the Caps Lock / Shift is was / is pressed and 
    return the respetive feedback, if the caracter is uppercase or not and if the shift is pressed or not
*/

module Key_FSM(
    input i_clk,                        // Clock
    input i_rst,                        // Reset
    input [7:0] i_byte_code,            // Byte of the caracter
    input i_update_key,                 // Update Key
    output o_is_upper,                  // Is Uppercase
    output o_shift_on,                  // Shift is pressed
    output reg o_new_key                // Reception Signal(New Key)
);
    reg l_shift_on;                     // Left Shift State
    reg r_shift_on;                     // Right Shift State
    reg was_break;                      // Last Key Code was BreakCode
    reg caps_on;                        // Caps is pressed
    reg caps_was_on ;                   // Caps was pressed and released
    
    // Initials Conditions
    initial 
    begin
        o_new_key = 1'b0;
        l_shift_on = 1'b0;
        r_shift_on = 1'b0;
		caps_on = 1'b0;
		caps_was_on = 1'b0;
        was_break = 1'b0;
    end
    
    // Shift is on if any of the shifts is pressed
    assign o_shift_on = (l_shift_on || r_shift_on);
    
    // Is uppercase if the caps lock is pressed or set 
    // Is uppercase if the shift is on
    // Is the previous true are true the character is lowercase
    assign o_is_upper = (caps_was_on||caps_on) ^ o_shift_on;
    
    always @(posedge i_clk)
    begin
        if(i_rst == 1)                      // Reset
        begin
            o_new_key = 1'b0;
            l_shift_on = 1'b0;
            r_shift_on = 1'b0;
            caps_on = 1'b0;
            caps_was_on = 1'b0;
            was_break = 1'b0;
        end
        else if(i_update_key)               // New KeyCode to process
        begin
           case(i_byte_code)    
           `BREAK_CODE:                     // Break Code
                was_break = 1;
           `RIGHT_SHIFT:                    // Right shift
           begin
                if(!was_break)
                    r_shift_on = 1;
                else                        // If the last keycode was the BreakCode is the released condition
                begin
                    was_break = 0;
                    r_shift_on = 0;
                end
           end 
           `LEFT_SHIFT:                     // Left shift
           begin
                if(!was_break)
                    l_shift_on = 1;
                else                        // If the last keycode was the BreakCode is the released condition
                begin
                    was_break = 0;
                    l_shift_on = 0;
                end
           end    
           `CAPS_LOCK:                      // Caps Lock
           begin
                if(!was_break)
                    caps_on = 1;
                else
                begin                           // If the last keycode was the BreakCode is the released condition
                    caps_was_on = ~caps_was_on; // Release the caps lock but it is set 
                    caps_on = 0;
                    was_break = 0;
                end            
           end
           default:
           begin                        
                if(!was_break)
                    o_new_key = 1;  
                else                        // If the last keycode was the BreakCode is the released condition
                    was_break = 0;
           end        
           endcase
       end
       else
            o_new_key = 0;                  // Reset after 1 cycle(One Shot)    
    end    
endmodule