`timescale 1ns / 1ps

/*
    The PS/2 reception is responsible for receiving the bits read from the ps/2
    data line and outputing the respective byte key (if valid), while signaling 
    each time there is a new one.
*/

module PS2_RX(
    input i_clk,                    // Clock
    input i_rst,                    // Reset
    input i_clk_ps2,                // PS/2 clock
    input i_data_ps2,               // PS/2 incoming bit
    input i_rx_en_ps2,              // PS/2 reception enable
    output [7:0] o_byte_code,       // PS/2 resultant byte code
    output o_update_key,            // "New key" signal
    output o_idle                   // Idle State
);

    // States
	parameter s_idle = 1'b0;
	parameter s_rx   = 1'b1;
		
	// Internal 
	reg state, next_state;                 // State
	reg [7:0] clk_filter_buf;              // Shift Register (Important because of metastability and noise)
	reg clk_filtered;                      // Clock Filtered
	
	reg [3:0] bit_pos, next_bit_pos;       // Actual Bit 
	reg [10:0] data, next_data;            // PS/2 Data (Start/Data(8)/Parity/Stop)
	
	reg [19:0] timeout;                    // The transmission cannot take longer than 2ms(200 000 Clock Pulses)
	
	reg update_key;                        // "New key" signal
	
	wire [7:0] next_clk_filter_buf;        // Next state 
	wire next_clk_filtered;                // Next state 
	wire neg_edge;                         // Negative Edge
	
	
	// Update filter with clock
	assign next_clk_filter_buf = {i_clk_ps2, clk_filter_buf[7:1]};
	
	// Filter Clock
	assign next_clk_filtered = (clk_filter_buf == 8'b11111111) ? 1'b1: (clk_filter_buf == 8'b00000000) ? 1'b0 :
			                 clk_filtered;
	
	// Negative edge of filter value
	assign neg_edge = clk_filtered & ~next_clk_filtered;
	
	// Key Code 
	assign o_byte_code = data[8:1];  
	
	// Update Key
	assign o_update_key = update_key;
	
	// Idle
	assign o_idle = ~state;
	
	// Update values and sinc clocks(CDC)
	always @(posedge i_clk)
	begin
		if (i_rst)
	    begin
            clk_filter_buf <= 8'd0;
            clk_filtered <= 1'b0;
            state <= s_idle;
            bit_pos <= 3'd0;
            data <= 11'd0;
            timeout <= 20'd0;
	    end
		else
        begin
            clk_filter_buf <= next_clk_filter_buf;
            clk_filtered  <= next_clk_filtered;
            state = next_state;
            bit_pos <= next_bit_pos;
            data <= next_data;
            if(state == s_rx)
            begin
                timeout = timeout + 1;    
                if(timeout >= 200000)                       // 2ms 
                begin
                    state = s_idle;                         // Idle State 
                    timeout = 20'd0;
                end
            end
            else
                timeout = 20'd0;
        end
    end
	
	// Logic
	always @(*)
	begin
        begin	       
            // Default Values
            next_state = state;
            update_key = 1'b0;
            next_bit_pos = bit_pos;
            next_data = data;
            
            case (state)
                s_idle:
                begin
                    if (neg_edge & i_rx_en_ps2)                     // Start Bit
                    begin
                        next_bit_pos = 4'b1010;                     // 10 Bits
                        next_state = s_rx;                          // Receive Data State
                    end
                end
                    
                s_rx:                                               // Receive Data
                begin           
                    if (neg_edge)                                   // On negative edge of the clock
                    begin
                        next_data = {i_data_ps2, data[10:1]};       // Sample new bit   
                        next_bit_pos = bit_pos - 1;                      
                    end
                     
                    if (bit_pos == 0)                               // Received all data
                    begin
                        if (~^next_data[8:1] == next_data[9])       // Check Parity
                           update_key = 1'b1;                       // Update "New Key" Flag
                        next_state = s_idle;                        // Idle State
                    end
                end
            endcase
        end
	end
endmodule