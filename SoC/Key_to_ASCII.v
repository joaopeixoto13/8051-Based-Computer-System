`timescale 1ns / 1ps

/*
    This module implements the conversion from KeyCode to ASCII using wire
*/

module Key_to_ASCII(
    input wire [7:0] i_key_code,     // Keycode to transale
    input wire i_is_upper,           // Is Uppercase
    input wire i_shift_on,           // Shift is pressed
    output wire [7:0] o_ASCII        // ASCII
);

wire [7:0] upper_ASCII;        // Upper ASCII
wire [7:0] lower_ASCII;        // Lower ASCII
wire [7:0] shift_ASCII;        // Shift ASCII
wire [7:0] no_shift_ASCII;     // No Shift ASCII
                                                    
assign upper_ASCII =(i_key_code == `A) ? 8'h41:     //A
                    (i_key_code == `B) ? 8'h42:     //B
                    (i_key_code == `C) ? 8'h43:     //C
                    (i_key_code == `D) ? 8'h44:     //D
                    (i_key_code == `E) ? 8'h45:     //E
                    (i_key_code == `F) ? 8'h46:     //F
                    (i_key_code == `G) ? 8'h47:     //G
                    (i_key_code == `H) ? 8'h48:     //H
                    (i_key_code == `I) ? 8'h49:     //I
                    (i_key_code == `J) ? 8'h4A:     //J
                    (i_key_code == `K) ? 8'h4B:     //K
                    (i_key_code == `L) ? 8'h4C:     //L
                    (i_key_code == `M) ? 8'h4D:     //M
                    (i_key_code == `N) ? 8'h4E:     //N
                    (i_key_code == `O) ? 8'h4F:     //O
                    (i_key_code == `P) ? 8'h50:     //P
                    (i_key_code == `Q) ? 8'h51:     //Q
                    (i_key_code == `R) ? 8'h52:     //R
                    (i_key_code == `S) ? 8'h53:     //S
                    (i_key_code == `T) ? 8'h54:     //T
                    (i_key_code == `U) ? 8'h55:     //U
                    (i_key_code == `V) ? 8'h56:     //V
                    (i_key_code == `W) ? 8'h57:     //W
                    (i_key_code == `X) ? 8'h58:     //X
                    (i_key_code == `Y) ? 8'h59:     //Y
                    (i_key_code == `Z) ? 8'h5A:     //Z
                    8'h00;
                                                    
assign lower_ASCII =(i_key_code == `A) ? 8'h61:     //a
                    (i_key_code == `B) ? 8'h62:     //b
                    (i_key_code == `C) ? 8'h63:     //c
                    (i_key_code == `D) ? 8'h64:     //d
                    (i_key_code == `E) ? 8'h65:     //e
                    (i_key_code == `F) ? 8'h66:     //f
                    (i_key_code == `G) ? 8'h67:     //g
                    (i_key_code == `H) ? 8'h68:     //h
                    (i_key_code == `I) ? 8'h69:     //i
                    (i_key_code == `J) ? 8'h6A:     //j
                    (i_key_code == `K) ? 8'h6B:     //k
                    (i_key_code == `L) ? 8'h6C:     //l
                    (i_key_code == `M) ? 8'h6D:     //m
                    (i_key_code == `N) ? 8'h6E:     //n
                    (i_key_code == `O) ? 8'h6F:     //o
                    (i_key_code == `P) ? 8'h70:     //p
                    (i_key_code == `Q) ? 8'h71:     //q
                    (i_key_code == `R) ? 8'h72:     //r
                    (i_key_code == `S) ? 8'h73:     //s
                    (i_key_code == `T) ? 8'h74:     //t
                    (i_key_code == `U) ? 8'h75:     //u
                    (i_key_code == `V) ? 8'h76:     //v
                    (i_key_code == `W) ? 8'h77:     //w
                    (i_key_code == `X) ? 8'h78:     //x
                    (i_key_code == `Y) ? 8'h79:     //y
                    (i_key_code == `Z) ? 8'h7A:     //z
                    8'h00;

assign shift_ASCII =(i_key_code == `ZERO_CURVE_LEFT)                ? 8'h30:        //0 
                    (i_key_code == `ONE_ESCLAMATION)                ? 8'h31:        //1 
                    (i_key_code == `TWO_AT)                         ? 8'h32:        //2 
                    (i_key_code == `THREE_CARDINAL)                 ? 8'h33:        //3 
                    (i_key_code == `FOUR_DOLAR)                     ? 8'h34:        //4 
                    (i_key_code == `FIVE_PERCENT)                   ? 8'h35:        //5 
                    (i_key_code == `SIX_HAT)                        ? 8'h36:        //6 
                    (i_key_code == `SEVEN_AMPERSAND)                ? 8'h37:        //7 
                    (i_key_code == `EIGHT_ASTERISK)                 ? 8'h38:        //8 
                    (i_key_code == `NINE_CURVE_RIGHT)               ? 8'h39:        //9 
                    (i_key_code == `TILDE_GRAVE_ACCENT)             ? 8'h60:        //` 
                    (i_key_code == `UNDERSCORE_HIFEN)               ? 8'h2D:        // _
                    (i_key_code == `EQUAL_SUM)                      ? 8'h3D:        //= 
                    (i_key_code == `STRAIGHT_RIGHT_BRACKET_RIGHT)   ? 8'h5B:        //[ 
                    (i_key_code == `STRAIGHT_LEFT_BRACKET_LEFT)     ? 8'h5D:        //] 
                    (i_key_code == `SLASH_LEFT_SLASH_VERTICAL)      ? 8'h5C:        //\ 
                    (i_key_code == `POINTCOMMA_TWO_POINTS)          ? 8'h3B:        //; 
                    (i_key_code == `APOSTROFE_QUOTATIONMARKS)       ? 8'h27:        //' 
                    (i_key_code == `COMMA_MINOR)                    ? 8'h2C:        //, 
                    (i_key_code == `POINT_GREATER)                  ? 8'h2E:        //. 
                    (i_key_code == `SLASH_RIGHT_QUESTIONMARK)       ? 8'h2F:        // /
                    8'h00;

assign no_shift_ASCII = (i_key_code == `ZERO_CURVE_LEFT)                ? 8'h29:    // )
                        (i_key_code == `ONE_ESCLAMATION)                ? 8'h21:    // !
                        (i_key_code == `TWO_AT)                         ? 8'h40:    // @
                        (i_key_code == `THREE_CARDINAL)                 ? 8'h23:    // #
                        (i_key_code == `FOUR_DOLAR)                     ? 8'h24:    // $
                        (i_key_code == `FIVE_PERCENT)                   ? 8'h25:    // %
                        (i_key_code == `SIX_HAT)                        ? 8'h5E:    // ^
                        (i_key_code == `SEVEN_AMPERSAND)                ? 8'h26:    // &
                        (i_key_code == `EIGHT_ASTERISK)                 ? 8'h2A:    // *
                        (i_key_code == `NINE_CURVE_RIGHT)               ? 8'h28:    // (
                        (i_key_code == `TILDE_GRAVE_ACCENT)             ? 8'h7E:    // ~
                        (i_key_code == `UNDERSCORE_HIFEN)               ? 8'h5F:    // -
                        (i_key_code == `EQUAL_SUM)                      ? 8'h2B:    // +
                        (i_key_code == `STRAIGHT_RIGHT_BRACKET_RIGHT)   ? 8'h7B:    // {
                        (i_key_code == `STRAIGHT_LEFT_BRACKET_LEFT)     ? 8'h7D:    // }
                        (i_key_code == `SLASH_LEFT_SLASH_VERTICAL)      ? 8'h7C:    // |
                        (i_key_code == `POINTCOMMA_TWO_POINTS)          ? 8'h3A:    // :
                        (i_key_code == `APOSTROFE_QUOTATIONMARKS)       ? 8'h22:    // "
                        (i_key_code == `COMMA_MINOR)                    ? 8'h3C:    // <
                        (i_key_code == `POINT_GREATER)                  ? 8'h3E:    // >
                        (i_key_code == `SLASH_RIGHT_QUESTIONMARK)       ? 8'h3F:    // ?
                        8'h00;


assign o_ASCII =    (i_key_code == `ENTER) ? 8'h20:
                    (i_key_code == `SPACE) ? 8'h0D:
                    (i_key_code == `BACKSPACE) ? 8'h08:
                    (i_key_code == `TAB) ? 8'h09:
                    (i_key_code == `ESC) ? 8'h1B:
                    (i_is_upper && upper_ASCII != 8'h00) ? upper_ASCII:
                    (!i_is_upper && lower_ASCII != 8'h00) ? lower_ASCII:
                    (i_shift_on && shift_ASCII != 8'h00) ? shift_ASCII:
                    (!i_shift_on && no_shift_ASCII != 8'h00) ? no_shift_ASCII:
                    8'h00;

endmodule