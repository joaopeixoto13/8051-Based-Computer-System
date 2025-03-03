`timescale 1ns / 1ps

/*
    This module manage all interrupt requests
    
    Notes:
        - 'i_en' must be connected with the SFRs bit (see ISA.v)
          (But with an AND logic port: EA & EX0 in the case of external interrupt 0)
        - 'i_int' must be put in 1 when we enter int the ISR and must be put at 0 when we call the RETI
        - 'i_int_req' when overflow ... 
*/

module Interrupt(
        input i_clk,            // Clock
        input i_rst,            // Reset
        input i_en,             // Interrupt enable
        input i_int,            // Interrupt in progress (No nested interrupts)
        input i_int_req,        // Interrupt request
        output o_int            // Interrupt status (1 if the interrupt is eligible to execute)
    );
    
    // Memorize the last interrupt status to verify if we have a high transition (signaling that it it's a interrupt)
    reg int_req_last;
    wire new_int_req_last;
    
    // Pending interrupt
    wire int_pend; 
    
    // Assign the output flag
    assign o_int = int_pend;
    
    // Initial conditions
    initial begin
        int_req_last <= 1'b0;
    end 
    
    // Always clk to memorize the last interrupt status 
    always @ (posedge i_clk)
    begin
        int_req_last <= new_int_req_last;
    end  
    
    // Clear / Memorize
    assign new_int_req_last = (i_rst == 1'b1) ? 1'b0: int_pend; 
    
    // Update the interrupt status
    // 1) Clear
    // 2) If we have a high level transition, the interrupt is enable and received a interrupt request  ==> enable the flag
    assign int_pend = (i_rst == 1'b1) ? 1'b0:
                      (i_int_req == 1'b1 && int_req_last == 1'b0 && i_en == 1'b1 && i_int == 1'b0) 
                      ? 1'b1:1'b0;  
                       
endmodule