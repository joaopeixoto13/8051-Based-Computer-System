`timescale 1ns / 1ps

/*
    The ROM is the dedicated 64KB of program memory space on the 8051
    microcontroller. It contains the binary code with the instructions to be executed.
    The ROM module takes as input the 16 bits of the program counter PC, and
    gives as output the 8-bit data of instruction op-code and operands.
*/

`include "Defines.v"

module ROM(
    input i_clk,                            // Clock
    input i_rst,                            // Reset
    input [15:0] i_addr,                    // Address to read
    output reg [15:0] o_out                 // Value read
    );
    
    parameter WIDTH = 8;                         // Datapath width

    parameter MEMSIZE = (1<<10);                 // Memory dimension (32k bytes)
    
    reg [15:0]MEM[MEMSIZE-1:0];                  // Principal memory (byte addressble)
    
    integer k;
    
    wire [15:0] data;
    
    initial begin
    
        for (k = 0; k < MEMSIZE; k = k + 1)
        begin
            MEM[k] = 16'b1;                     
        end 
        o_out = 16'b0; 
        
        
        /*
        //Arithmetic instructions test: ADD
        
        MEM[0] = {`ADD_D, 8'd2};            // ADD A, direct, RAM[2] = 3            
        MEM[1] = {`ADD_C, 8'd127};          // ADD A, immediate, immediate = #127
        MEM[2] = {`ADD_R, 8'd0};            // ADD A, Rn , R0 = 1 (Bank 0 selected on PSW)
        */
        
        /*    
        //Arithmetic instructions test: ADDC, SUBB
        
        MEM[0] = {`ADDC_D, 8'd2};            // ADDC A, direct, RAM[2] = 3
        MEM[1] = {`ADDC_C, 8'd255};          // ADDC A, immediate, immediate = #255
        MEM[2] = {`ADDC_R, 8'd0};            // ADDC A, Rn , R0 = 1 (Bank 0 selected on PSW)
        MEM[3] = {`SUBB_D, 8'd2};            // SUBB A, direct, RAM[2] = 3
        MEM[4] = {`SUBB_C, 8'd126};          // SUBB A, immediate, immediate = #126
        MEM[5] = {`SUBB_R, 8'd1};            // SUBB A, Rn, R1 = 2 (Bank 0 selected on PSW)
        */
        
        /*
        //Logical instructions test: ANL, ORL, XRL
        
        MEM[0] = {`ORL_D, 8'd2};          // ORL A, direct, RAM[2] = 3
        MEM[1] = {`ANL_C, 8'd4};          // ANL A, immediate, immediate = #4
        MEM[2] = {`XRL_R, 8'd1};          // XRL A, Rn, R1 = 2 (Bank 0 selected on PSW)
        */
      
        /*
        //Data transfers instructions test: MOV A, XX
        
        MEM[0] = {`MOV_C, 8'd3};      // MOV A, #data, #3
        MEM[1] = {`MOV_D, 8'd2};      // MOV A, direct, RAM[2] = 3
        MEM[2] = {`MOV_R, 8'd1};      // MOV A, Rn, R1 = 2 (Bank 0 selected on PSW)
        */
        
        /*
        //Data transfers instructions test: MOV XX, A
        
        MEM[0] = {`MOV_R, 8'd3};        // MOV A, reg, [3] = 4
        MEM[1] = {`MOV_AD, 8'd0};       // MOV direct, A, RAM[0]    
        MEM[2] = {`MOV_D, 8'd0};        // MOV A, direct, RAM[0]     
        MEM[3] = {`MOV_AR, 8'd1};       // MOV Rn, A, R1 = A (Bank 0 selected on PSW)    
        MEM[4] = {`MOV_C, 8'h7E};       // MOV A, immediate, immediate = 0x7E  
        MEM[5] = {`MOV_AD, `SP_ADDR};   // MOV direct, A, SP (Stack Pointer) = A
        */
        
        /*
        //Jump instructions test
        
        MEM[0] = {`JZ, 8'd3};           // JZ rel = #3
        MEM[1] = {`ADD_C, 8'd127};      // ADD A, immediate, immediate = #127
        MEM[2] = {`ADD_C, 8'd127};      // ADD A, immediate, immediate = #127
        MEM[3] = {`JC, 8'd6};           // JC rel = #6
        MEM[4] = {`ADD_C, 8'd3};        // ADD A, immediate, immediate = #3
        MEM[5] = {`JNZ, 8'd0};          // JNZ rel = #0
        MEM[6] = {`MOV_C, 8'd0};        // MOV A immediate = #0
        MEM[7] = {`MOV_AD, `PSW_ADDR};  // MOV DIRECT, aA = #0
        MEM[8] = {`JZ, 8'd0};           // JZ rel = #0
        */
        
        /*
        //TIMER test
        
        MEM[0] = {`MOV_C, 8'b0000_0010};   // MOV A, immediate, immediate = Timer0 8bits AutoReload
        MEM[1] = {`MOV_AD, `TMOD_ADDR};    // MOV direct, A, TMOD = A          
        MEM[2] = {`MOV_C, 8'b0001_0000};   // MOV A, immediate, immediate = Set TR0
        MEM[3] = {`MOV_AD, `TCON_ADDR};    // MOV direct, A, Set the TR0 in TCON
        */
        
        /*
        //UART Transmission Test
        
        MEM[0] = {`ADD_C, 8'D49};            // MOV A, #data, A = 49 (ASCII 1)
        MEM[1] = {`MOV_AD, `SBUF_ADDR};      // SBUF = 49 
        MEM[2] = {`MOV_C, 8'b0000_1000};     // MOV A, #data, Enable UART Transmission (SCON[3])    
        MEM[3] = {`MOV_AD, `SCON_ADDR};      // SCON = 8 ==> Start Transmission
        */
        /*
        //UART Reception Test
        
        MEM[0] = {`MOV_C, 8'b0001_0000};      // MOV A, #data, Enable UART Reception (SCON[4])
        MEM[1] = {`MOV_AD, `SCON_ADDR};       // SCON = 16 ==> Start Reception   
        */
        
        /*
        //TIMER 0 Interrupt Test
        MEM[0] = {`MOV_C, 8'b1111_1000};      // MOV A, immediate, immediate = 0xF0
        MEM[1] = {`MOV_AD, `TL0_ADDR};        // MOV direct, A, TL0 = 0xF0          
        MEM[2] = {`MOV_AD, `TH0_ADDR};        // MOV direct, A, TH0 = 0xF0   
        MEM[3] = {`MOV_C, 8'b0000_0010};      // MOV A, immediate, immediate = Timer0 8bits AutoReload
        MEM[4] = {`MOV_AD, `TMOD_ADDR};       // MOV direct, A, TMOD = A          
        MEM[5] = {`MOV_C, 8'b0001_0000};      // MOV A, immediate, immediate = Set TR0
        MEM[6] = {`MOV_AD, `TCON_ADDR};       // MOV direct, A, Set the TR0 in TCON
        MEM[7] = {`MOV_C, 8'b1000_0010};      // MOV A, immediate
        MEM[8] = {`MOV_AD, `IE_ADDR};         // MOV direct, A, Set the IE
        MEM[9] = {`JNC, 8'd20};               // JNC

        // Timer 0 IRQ
        MEM[8'h0b] = {`ORL_C, 8'h1};          // ORL A, immediate, immediate = #1            
        MEM[8'h0c] = {`ADD_C, 8'd2};          // ADD A, immediate, immediate = #2     
        MEM[8'h0d] = {`RETI, 8'd0};           // RETI 
        
        MEM[20] = {`ORL_D, 8'd2};             // ORL A, direct, RAM[2] = 3
        MEM[21] = {`ANL_C, 8'd4};             // ANL A, immediate, immediate = #4
        MEM[22] = {`XRL_R, 8'd1};             // XRL A, Rn, R1 = 2 (Bank 0 selected on PSW)
        MEM[23] = {`JNC, 8'd20};              // JNC
        */
        
        /*
        Before use this change the EXT_ADDR to 0x13
        
        // External Interrupt 0 (.bit) 
        MEM[0] = {`MOV_C, 8'b1000_0001};      // MOV A, immediate, immediate = Enable EA and EX0
        MEM[1] = {`MOV_AD, `IE_ADDR};         // MOV direct, A, IE = Set EA and ES0
        MEM[2] = {`MOV_C, 8'd0};              // MOV A, immediate, immediate = #0
        MEM[3] = {`JNC, 8'd3};                // JNC rel, rel = #3
        
        MEM[8'h13] = {`ADD_C, 8'd1};          // ADD A, immediate, immediate = #1 
        MEM[8'h14] = {`MOV_AD, `P2_ADDR};     // MOV direct, A, MOV P2, A
        MEM[8'h15] = {`RETI, 8'd0};           // RETI
        */
        
        /*
        //UART Reception + Transmission with Interrupts (.bit)
               
        MEM[0] = {`MOV_C, 8'b1001_0000};      // MOV A, immediate, immediate = Enable EA and ES0
        MEM[1] = {`MOV_AD, `IE_ADDR};         // MOV direct, A, IE = Set EA and ES0
        MEM[2] = {`MOV_C, 8'b0001_0000};      // MOV A, immediate, immediate = Enable UART Reception (SCON[4])
        MEM[3] = {`MOV_AD, `SCON_ADDR};       // MOV direct, A, SCON = Start Reception
        MEM[4] = {`JNC, 8'd4};                // JNC rel, rel = #8
        
        /// UART ISR
        
        MEM[8'h23] = {`MOV_C, 8'd1};          // MOV A, immediate, immediate = #1
        MEM[8'h24] = {`ANL_D, `SCON_ADDR};    // ANL A, direct, direct = SCON
        MEM[8'h25] = {`JNZ, 8'h50};           // JNZ rel ==> Received data , rel = 8'h50
        MEM[8'h26] = {`MOV_C, 8'b0001_0000};  // MOV A, immediate, immediate = Clear UART transmission flag and Clear enable Transmission
        MEM[8'h27] = {`MOV_AD, `SCON_ADDR};   // MOV direct, A , SCON = A
        MEM[8'h28] = {`RETI, 8'd0};           // RETI
        
        MEM[8'h50] = {`MOV_D, `SBUF_ADDR};    // MOV A, direct, A = SBUF (data received)
        MEM[8'h51] = {`MOV_AD, `P2_ADDR};     // MOV direct, A, P2 = A (data received)
        MEM[8'h52] = {`MOV_C, 8'b0001_1000};  // MOV A, immediate, immediate = Clear UART reception flag and enable Transmission
        MEM[8'h53] = {`MOV_AD, `SCON_ADDR};   // MOV direct, A, SCON = A
        MEM[8'h54] = {`RETI, 8'd0};           // RETI
        */
        
        /*
        // Keyboard Interrupt
        MEM[0] = {`MOV_C, 8'b1010_0000};      // MOV A, immediate, immediate = Enable EA and KEY
        MEM[1] = {`MOV_AD, `IE_ADDR};         // MOV direct, A
        MEM[2] = {`MOV_C, 8'b0000_0100};      // MOV A, immediate, immediate = Enable Keyboard Reception
        MEM[3] = {`MOV_AD, `KCON_ADDR};       // MOV direct, A
        MEM[4] = {`JNC, 8'd4};                // JNC rel, rel = #4
        
        MEM[8'h30] = {`MOV_D, `KBUF_ADDR};    // ADD A, direct, KBUF 
        MEM[8'h31] = {`MOV_AD, `P2_ADDR};     // MOV direct, A, MOV P2, A
        MEM[8'h33] = {`RETI, 8'd0};           // RETI
        */
        
        
        MEM[0] = {`MOV_C, 8'b1010_0000};      // MOV A, immediate, immediate = Enable EA and KEY
        MEM[1] = {`MOV_AD, `IE_ADDR};         // MOV direct, A
        MEM[2] = {`MOV_C, 8'b0000_0100};      // MOV A, immediate, immediate = Enable Keyboard Reception
        MEM[3] = {`MOV_AD, `KCON_ADDR};       // MOV direct, A
        MEM[4] = {`MOV_C, 8'b0010_0000};      // MOV A, immediate, immediate = Enable text Mode
        MEM[5] = {`MOV_AD, `DMOD_ADDR};       // MOV direct, A
        MEM[6] = {`JNC, 8'd6};                // JNC rel, rel = #4 
        
        MEM[8'h30] = {`MOV_D, `KBUF_ADDR};    // MOV A, direct, Key received
        MEM[8'h31] = {`MOV_AD, `P2_ADDR};     // MOV direct, A, MOV P2, A
        MEM[8'h32] = {`MOV_AD, `DBUF_ADDR};   // Update key of display
        MEM[8'h33] = {`MOV_D, `DMOD_ADDR};    // ATTR
        MEM[8'h34] = {`ADD_C, 8'b0000_0001};  // ATTR
        MEM[8'h35] = {`ANL_C, 8'b0010_1111};  // 
        MEM[8'h36] = {`MOV_AD, `DMOD_ADDR};   // MOV direct, A,
        MEM[8'h37] = {`MOV_C, 8'b0000_0000};  // Clear carry
        MEM[8'h38] = {`MOV_D, `PSW_ADDR};     // Update key of display
        MEM[8'h39] = {`RETI, 8'd0};           // RETI       
        /*
        MEM[8'h30] = {`MOV_D, `KBUF_ADDR};    // MOV A, direct, Key received
        MEM[8'h31] = {`MOV_AD, `P2_ADDR};     // MOV direct, A, MOV P2, A
        MEM[8'h32] = {`MOV_AD, `DBUF_ADDR};   // Update key of display
        MEM[8'h33] = {`MOV_C, 8'b1001_1110};  // ATTR
        MEM[8'h34] = {`MOV_AD, `DTMCON_ADDR}; // ATTR
        MEM[8'h35] = {`MOV_C, 8'b0111_0000};  // 
        MEM[8'h36] = {`MOV_AD, `DMOD_ADDR};   // MOV direct, A,
        MEM[8'h37] = {`MOV_C, 8'b0000_0000};  // Clear carry
        MEM[8'h38] = {`MOV_D, `PSW_ADDR};     // Update key of display
        MEM[8'h39] = {`RETI, 8'd0};           // RETI                      
        */
        /*
        MEM[0] = {`MOV_C, 8'b1010_0000};      // MOV A, immediate, immediate = Enable EA and KEY
        MEM[1] = {`MOV_AD, `IE_ADDR};         // MOV direct, A
        MEM[2] = {`MOV_C, 8'b0000_0100};      // MOV A, immediate, immediate = Enable Keyboard Reception
        MEM[3] = {`MOV_AD, `KCON_ADDR};       // MOV direct, A
        MEM[4] = {`MOV_C, 8'b0000_0001};      // MOV A, immediate, immediate = Enable filters
        MEM[5] = {`MOV_AD, `DMOD_ADDR};       // MOV direct, A
        MEM[6] = {`JNC, 8'd6};                // JNC rel, rel = #4 
        
        MEM[8'h30] = {`MOV_D, `KBUF_ADDR};    // ADD A, direct, Key received
        MEM[8'h31] = {`MOV_AD, `P2_ADDR};     // MOV direct, A, MOV P2, A
        MEM[8'h32] = {`ADD_D, `KBUF_ADDR};    // sHIFT << 1
        MEM[8'h33] = {`ORL_C, 8'b0000_0001};    // Enable filters
        MEM[8'h34] = {`ANL_C, 8'b0000_1111};    // Clear upper nibble
        MEM[8'h35] = {`MOV_AD, `DMOD_ADDR};       // MOV direct, 
        MEM[8'h36] = {`MOV_C, 8'b0000_0000};    // Clear carry
        MEM[8'h37] = {`MOV_D, `PSW_ADDR};    // Update key of display
        MEM[8'h38] = {`RETI, 8'd0};           // RETI  */
    end
    
    always @(posedge i_clk)
    begin
        o_out <= data;                        // Read the content from memory 
    end
    
    assign data = (i_rst == 1'b1) ? 16'b0: MEM[i_addr];
       
endmodule