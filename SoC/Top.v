`timescale 1ns / 1ps

/*
    This module implements the 8051 with pipeline
    
    #######################
    ## Brief description ##
    #######################
    
    This version of 8051 ISA (Instruction Set Architecture) is composed by 27 instructions:
        - 9 Arithmetic instructions
        - 9 Logic instructions
        - 5 Data transfer instructions
        - 5 jump instructions
    Also, this version has:
        - 1 Timer with four modes:
            - MODE 1: 13bits timer/counter
            - MODE 2: 16bits timer/counter
            - MODE 3: 8 bits timer/counter with Autoreload
            - MODE 4: Same as above but with same differences
        - UART
        - PS/2 and Keyboard Reception
        - 5 Interrupts 
            - Triggered by Timer when overflow
            - Triggered by an external event
            - Triggered by a reception of UART
            - Triggered by a transmission of UART
            - Triggered by a reception of a new key from the Keyboard
            
        ########################
    ## Detail description ##
    ########################
    
    System Overview
    - 8051
        - Stage_1               Stage 1 of pipeline (Fetch, Decode and Memory Access) 
            - ROM               Implement the program code memory
            - RAM               Implement the RAM memory
            - SFRs              Pack all the system SFRs
                - ACC           Acumulator
                - PSW           Program Status Word
                - IE            Interrupt Enable
                - SP            Stack Pointer
                - TMOD          Timer Mode
                - TH0           Timer High
                - TL0           Timer Low
                - TCON          Timer Control
                - SCON          Serial I/O Control
                - SBUF          Serial Buffer
                - DMOD          Display/Filters Control
                - DBUF          Display Text Mode Buffer
                - KCON          Keyboard Control
                - KBUF          Keyboard Buffer
            - Map2SFR           Map the SFRs in the RAM
            - Timer             Implements the Timer
            - UART              Implements the UART (Universal Asynchronous Receiver Transmitter)
                - UART_RX       Implements the UART Receiver
                - UART_TX       Implements the UART Transmitter
            - Keyboard          Implements the PS/2 Reception and handles the key decodification
                - PS2_ControllerImplements the PS/2 Protocol
                    - PS2_RX    Implements the PS/2 Reception
                - Key_FSM       Implements the key decodification from the state of the Shifts and CapsLocks
                - Key_to_ASCII  Implements the conversion Keycode to ASCII
            - Interrupt         Implements the system Interrupts
                - EXT0_ISR      Handles the External 0 Interrupt 
                - TIM0_ISR      Handles the Timer 0 Interrupt 
                - UART_ISR      Handles the UART Interrupt
                - KEYB_ISR      Handles the Keyboard Reception Interrupt
            - OneShot           Implements a One Shot circuit
         - Buffer_1             Buffer 1 of the pipeline
         - Stage 2              Stage 2 of pipeline (Execution) 
            - ALU               Aritmetic and Logic Unit, responsible to perform all aritmetic and logic operations
         - Buffer_2             Buffer 2 of the pipeline
         - Stage_3              Stage 3 of pipeline (Write Back)
         - Hazard_Unit          Implemnets the hazard unit, responsible to detect hazard occurence and lead with the condtions of the branch instructions  
         - EXT0_Debounce        Debounce for button
         - LEDS_Controller      Implements the Zybo-Z7 LEDS Controller
*/       

module Top(
    input i_clk,                        // Zybo Clock
    input i_rst_ext,                    // Reset
    input i_rx,                         // RX line
    input i_button,                     // Button (Connected to External Interrupt 0)
    input i_clk_ps2,                    // Clock PS/2
    input i_data_ps2,                   // Data PS/2
    input [`ROM_WIDTH-1:0] ir,          // IR  
    input i_is_flashing,                // Is flahsing flag
    output o_tx,                        // TX line
    output [7:0] o_leds,                // LEDS 
    output o_hsync,                     // HSYNC
    output o_vsync,                     // VSYNC
    output tri[4:0] o_red,              // Red
    output tri[5:0] o_green,            // Green
    output tri[4:0] o_blue,             // Blue 
    output [15:0] o_PC                  // PC
);
    
    /* Declarations used in Stage 1 */
    wire	[`BUFFER_LENGTH-1:0]	o_stage1;      // Output of stage 1
    wire 	[`BUFFER_LENGTH-1:0] 	o_buf1;        // Second buffer
    
    /* Declarations used in Stage 2 */
    wire	[`BUFFER_LENGTH-1:0]	o_stage2;      // Output of stage 2
    wire 	[`BUFFER_LENGTH-1:0] 	o_buf2;        // Second buffer
    
    /* Declarations used in Stage 3 */
    wire    [7:0] wr_psw_data;                     // PSW data to write
    wire    [7:0] wr_adress;                       // Address to write     
    wire    [7:0] wr_data;                         // Data to write 
    wire    [`SFR_OP_LEN-1:0] sfr_op;              // SFR operations
    wire    [`RAM_OP_LEN-1:0] ram_op;              // RAM operations 
    
    
    /* Hazard unit */
    wire    [7:0] Ra_addr;                         // First Operand address                 
    wire    [7:0] Rb_addr;                         // Second Operand address
    wire    [7:0] acc_rf;                          // Second Operand address
    wire    [7:0] psw_rf;                          // Second Operand address
    wire    pc_load;                               // Jump is taken                                                           
    wire    [1:0]forward_data_a;                   // Forward data variable
    wire    [1:0]forward_data_b;                   // Forward data variable
    wire    [1:0]forward_flags;                    // Forward flags variable 
    
    /* Pheriphrals */
    //wire [7:0] o_leds_in;                          // Leds interconnect wire 
    wire button;                                   // Button wire 
    
    // Update Reset
    wire i_rst;
    
    assign i_rst = i_is_flashing | i_rst_ext;
    
    // Instantiate the Stage 1 of the Pipeline(Fetch, Decode, Memory Access)  
    Stage1 stage1(
            .i_clk(i_clk),                         // Clock 
            .i_rst(i_rst),                         // Reset 
            .i_pc_load(pc_load),                   // Pcload signal(Jump taken) 
            .i_rom_out(ir),                        // Instruction register     
            .o_op1_addr(Ra_addr),                  // Adress of first operand 
            .o_op2_addr(Rb_addr),                  // Adress of second operand
            .o_acc(acc_rf),                        // Acumulator value for jump decisions    
            .o_psw(psw_rf),                        // PSW value for jump decisions                               
            .o_stage1(o_stage1),                   // Output buffer 
            .i_forward_data_a(forward_data_a),     // Forward Data signal from H_U
            .i_forward_data_b(forward_data_b),     // Forward Data signal from H_U
            .i_forward_flags(forward_flags),       // Forward Data(CC) signal from H_U 
            .i_exec_buffer(o_stage2),              // Execution Buffer  
            .i_write_back_buffer(o_buf2),          // Write Back Buffer     
            .i_wr_psw(wr_psw_data),                // PSW data 
            .i_wr_data(wr_data),                   // Write data
            .i_wr_adress(wr_adress),               // Write adress 
            .i_ram_op(ram_op),                     // RAM operation 
            .i_sfr_op(sfr_op),                     // SFR operation 
            .i_uart_rx(i_rx),                      // UART Rx Line 
            .i_button(button),                     // Button 
            .o_uart_tx(o_tx),                      // UART Tx Line
            .o_leds(o_leds),                       // Leds value
            .i_clk_ps2(i_clk_ps2),                 // Clock PS/2 
            .i_data_ps2(i_data_ps2),               // Data PS/2
            .o_hsync(o_hsync),                     // HSYNC
            .o_vsync(o_vsync),                     // VSYNC
            .o_red(o_red),                         // Red
            .o_green(o_green),                     // Green
            .o_blue(o_blue),                       // Blue
            .o_PC(o_PC)                            // PC
    );                            
    
    // Instantiate the Buffer 1 of the Pipeline  
    Buffer buf1(                                   
            .i_clk(i_clk),                         // Clock 
            .i_rst(i_rst),                         // Reset 
            .i_in(o_stage1),                       // (Input)Output of stage 1 
            .o_out(o_buf1)                         // Output buffer 
    );
    
    // Instantiate the Stage 2 of the Pipeline(Execute)  
    Stage2 stage2(                               
            .i_buf(o_buf1),                        // Input of buffer 1 
            .o_buf(o_stage2)                       // Output buffer 
    );       
    
    // Instantiate the Buffer 2 of the Pipeline  
    Buffer buf2(                                  
            .i_clk(i_clk),                         // Clock    
            .i_rst(i_rst),                         // Reset
            .i_in(o_stage2),                       // (Input)Output of stage 2 
            .o_out(o_buf2)                         // Output buffer
    );
    
    // Instantiate the Stage 3 of the Pipeline(Write Back) 
    Stage3 stage3(
            .i_in(o_buf2),                         // Input of buffer 2 
            .o_wr_psw(wr_psw_data),                // PSW data   
            .o_wr_data(wr_data),                   // Write data 
            .o_wr_adress(wr_adress),               // Write adress 
            .o_ram_op(ram_op),                     // RAM operation 
            .o_sfr_op(sfr_op)                      // SFR operation
    );
    
    // Instanciate the Hazard Unit
    Hazard_Unit Hazard_Unit(                                 
        .i_Ra_addr(Ra_addr),                       // Adress of first operand 
		.i_Rb_addr(Rb_addr),                       // Adress of second operand 
		.i_Buffer1(o_buf1),                        // Buffer 1
		.i_Buffer2(o_buf2),                        // Buffer 2
		.i_ir(ir),                                 // Instruction register
		.i_psw_rf(psw_rf),                         // PSW value from Register file
	    .i_acc_rf(acc_rf),                         // ACC value from Register file
	    .i_res_alu(o_stage2[`OPERAND1_POS]),       // ALU result    
		.i_cy_alu(o_stage2[`CY_POS]),              // Carry result from ALU
		.o_forward_data_a(forward_data_a),         // Forward data signal
		.o_forward_data_b(forward_data_b),         // Forward data signal
		.o_forward_flags(forward_flags),           // Forward flags signal
		.o_pc_load(pc_load)                        // PC load signal (Jump taken)
    );
    
    // Instantiate the LEDS Controller
    /*LEDS_Controller LEDS_Controller(
        .i_clk(i_clk),                  // Zybo Clock
        .i_rst(i_rst),                  // Reset 
        .i_en(1'b1),                    // Enable the LEDS
        .i_data(o_leds_in),             // Data
        .o_leds(o_leds)                 // LEDS mapped in Zybo-Z7 constraints file
    );*/
    
    // Instantiate the Debounce module to debounce the Button connected to EXT0
    Debounce EXT0_Debounce (
        .i_clk(i_clk),                  // Clock
        .i_rst(i_rst),                  // Reset
        .i_signal(i_button),            // Signal unstable
        .o_signal(button)               // Signal stable
    ); 
       
endmodule