`timescale 1ns / 1ps

/*
    This module implements the stage 1 of the pipeline (Fetch, Decode and Memory Access)
    Also Branch instructions, Interrupts and pheriphrals are handled in this module
*/
module Stage1(
    input i_clk,                                    // Clock   
    input i_rst,                                    // Reset   
    input i_pc_load,                                // PC load
    input [`ROM_WIDTH-1:0] i_rom_out,               // Fetched instruction from memory
    output [7:0] o_op1_addr,                        // First Operand Address 
    output [7:0] o_op2_addr,                        // Second Operand Address
    output [7:0] o_acc,                             // Acumulator
    output [7:0] o_psw,                             // PSW
    output [`BUFFER_LENGTH-1:0] o_stage1,           // Output Buffer 
    input [1:0] i_forward_data_a,                   // Forward Data signal from H_U
    input [1:0] i_forward_data_b,                   // Forward Data signal from H_U
    input [1:0] i_forward_flags,                    // Forward Data signal from H_U
    input [`BUFFER_LENGTH-1:0] i_exec_buffer,       // Execution Buffer
    input [`BUFFER_LENGTH-1:0] i_write_back_buffer, // Write Back Buffer
    input [7:0] i_wr_psw,                           // PSW to write
    input [7:0] i_wr_data,                          // Data to write
    input [7:0] i_wr_adress,                        // Adress to write
    input [`RAM_OP_LEN-1:0] i_ram_op,               // RAM operation
    input [`SFR_OP_LEN-1:0] i_sfr_op,               // SFR operation
    input i_uart_rx,                                // UART RX Line
    input i_button,                                 // Button
    output o_uart_tx,                               // UART TX Line
    output [7:0] o_leds,                            // LED's
    input i_clk_ps2,                                // Clock PS/2
    input i_data_ps2,                               // Data PS/2
    output o_hsync,                                 // HSYNC
    output o_vsync,                                 // VSYNC
    output tri[4:0] o_red,                          // Red
    output tri[5:0] o_green,                        // Green
    output tri[4:0] o_blue,                         // Blue
    output [15:0] o_PC                              // PC 
);
    
    // Control variables
    reg [15:0] PC;								// Program Counter
    reg bubble;                                 // Bubble variable
    wire [15:0] new_PC;                         // Auxiliar variable
    wire new_bubble;                            // Auxiliar variable
    wire reti_op;                               // Auxiliar variable
    reg [15:0] PC_RETI;	                        // Save the PC to return of Interrupt   
    wire [15:0] new_PC_RETI;                    // Auxiliar variable
    
    
    // RAM variables
    wire [`WIDTH-1:0]ram_out;                   // RAM output byte
    wire [`WIDTH-1:0]ram_addr;                  // RAM address
    wire [`WIDTH-1:0]ram_data;                  // RAM write/read byte
    wire ram_bit;                               // RAM write/read bit (Bit addressable)
    wire [`RAM_OP_LEN-1:0]ram_op;               // RAM operations
    wire ram_out_bit;                           // RAM output bit
    
        // SFRs variables
    wire [`SFR_OP_LEN-1:0] sfr_op;              // SFR operation
    wire [`SFR_OP_LEN-1:0] sfr_op_aux1;         // SFR operation auxiliar 1
    wire [`SFR_OP_LEN-1:0] sfr_op_aux2;         // SFR operation auxiliar 2
    wire [`SFR_OP_LEN-1:0] sfr_op_aux3;         // SFR operation auxiliar 3
    wire [`SFR_OP_LEN-1:0] sfr_op_aux4;         // SFR operation auxiliar 4
    wire [`SFR_OP_LEN-1:0] sfr_op_aux5;         // SFR operation auxiliar 5
    wire [7:0] sfr_wr_acc;                      // SFR write ACC
    wire [7:0] sfr_wr_psw;                      // SFR write PSW
    wire [7:0] sfr_wr_ie;                       // SFR write IE
    wire [7:0] sfr_wr_sp;                       // SFR write SP
    wire [7:0] sfr_wr_tmod;                     // SFR write TMOD
    wire [7:0] sfr_wr_th0;                      // SFR write TH0
    wire [7:0] sfr_wr_tl0;                      // SFR write TL0
    wire [7:0] sfr_wr_tcon;                     // SFR write TCON
    wire [7:0] sfr_wr_scon;                     // SFR write SCON
    wire [7:0] sfr_wr_sbuf;                     // SFR write SBUF
    wire [7:0] sfr_wr_p2;                       // SFR write P2
    wire [7:0] sfr_wr_dmod;                     // SFR write DMOD
    wire [7:0] sfr_wr_dbuf;                     // SFR write DBUF
    wire [7:0] sfr_wr_dtmcon;                   // SFR write DTMCON
    wire [7:0] sfr_wr_kcon;                     // SFR write KCON
    wire [7:0] sfr_wr_kbuf;                     // SFR write KBUF
    wire [7:0] acc;                             // ACC (Acumulator)
    wire parity;                                // Parity flag
    wire [7:0] psw;                             // PSW (Program Status Word)
    wire [1:0] bank;                            // Bank selected
    wire [7:0] ie;                              // IE (Interrupt Enable)
    wire [7:0] sp;                              // SP (Stack Pointer)
    wire [7:0] tmod;                            // TMOD (Timer Mode)
    wire [7:0] th0;                             // TH0 (Timer High)
    wire [7:0] tl0;                             // TL0 (Timer Low)
    wire [7:0] tcon;                            // TCON (Timer Control)
    wire [7:0] scon;                            // SCON (Serial I/O Control)
    wire [7:0] sbuf;                            // SBUF (Serial I/O Buffer)   
    wire [7:0] p2;                              // P2
    wire [7:0] dmod;                            // DMOD (VGA / Filter Display)
    wire [7:0] dbuf;                            // DBUF (Letter to Write(VGA Text Mode))
    wire [7:0] dtmcon;                          // DTMCON (VGA Text Mode Atributtes)
    wire [7:0] kcon;                            // KCON (Keyboard)
    wire [7:0] kbuf;                            // KBUF (Letter Received)   
    
    // Map2SFR variable
    wire [7:0]addr_mapped;                      // Address mapped 
    
    // Timer 0 variables
    wire [7:0] th0_tim_out;                     // Output of TH0 in Timer module
    wire [7:0] tl0_tim_out;                     // Output of TL0 in Timer module  
    wire tf0_tim_out;                           // Output of overflow flag in Timer module
    wire tim0_en;                               // Timer0/Counter0 is running 
    
    // UART variables
    wire [7:0] rx_data;                         // UART RX data received 
    wire rx_done;                               // UART reception done
    wire tx_done;                               // UART transmission done
    
    // Keyboard variables
    wire [7:0] keyb_key_data;                   // Keyboard char received 
    wire keyb_key_received;                     // Keyboard char received signal
  
    // VGA variables
    wire vga_key_done;                          // VGA display new key complete
    
    // External Interrupt 0 variables
    wire ext0_int_en;                           // External 0 Interrupt enable
    reg ext0_int_in;                            // External 0 Interrupt in progress flag (No nested interrupts)
    wire ext0_int_status;                       // External 0 Interrupt status (1 if the interrupt is eligible to execute)
    wire ext0_button;                           // Button pressed
    
    // Timer 0 Interrupt variables
    wire tim0_int_en;                           // Timer 0 Interrupt enable
    reg tim0_int_in;                            // Timer 0 Interrupt in progress flag (No nested interrupts)
    wire tim0_int_status;                       // Timer 0 Interrupt status (1 if the interrupt is eligible to execute)
    
    // Serial I/O Interrupt variables
    wire uart_int_en;                           // Serial I/O Interrupt enable
    reg uart_int_in;                            // Serial I/O Interrupt in progress flag (No nested interrupts)
    wire uart_int_status;                       // Serial I/O Interrupt status (1 if the interrupt is eligible to execute)  
    
    // Keyboard Interrupt variables
    wire keyb_int_en;                           // Keyboard Interrupt enable
    reg keyb_int_in;                            // Keyboard Interrupt in progress flag (No nested interrupts)
    wire keyb_int_status;                       // Keyboard Interrupt status (1 if the interrupt is eligible to execute)      

    // Pipeline variables
    wire [7:0] opcode;                          // Opcode
    wire [7:0] op1;                             // First operand
    wire [7:0] op2;                             // Second operand
    wire [7:0] op1_tmp;				            // Fisrt operand default value					  					
    wire [7:0] op2_tmp;                         // Second operand default value
    wire cy;                                    // Carry
    wire ac;                                    // Auxiliar Carry
    wire ov;                                    // Overflow
    wire we;                                    // Write Enable
    wire int_pend;                              // Interrupt pendign signal  
    wire new_ext0_int_in;                       // Flag
    wire new_tim0_int_in;                       // Flag
    wire new_uart_int_in;                       // Flag
    wire new_keyb_int_in;                       // Flag
     
    // Instanciate the RAM
    RAM RAM(
        .i_clk(i_clk),                          // Clock
        .i_rst(i_rst),                          // Reset
        .i_addr(ram_addr),                      // Address to write 
        .i_wr_byte(ram_data),                   // Data to write
        .i_wr_bit(ram_bit),                     // Bit to write
        .i_op(ram_op),                          // Operation to do
        .i_addr_r(o_op2_addr),                  // Address to read
        .o_byte(ram_out),                       // Output byte
        .o_bit(ram_out_bit)                     // Output bit
    );
    
    // Instanciate the Register File (SFRs) 
    SFRs SFRs(
        .i_clk(i_clk),                          // Clock
        .i_rst(i_rst),                          // Reset
        .i_acc(sfr_wr_acc),                     // ACC to write
        .i_psw(sfr_wr_psw),                     // PSW to write
        .i_ie(sfr_wr_ie),                       // IE to write
        .i_sp(sfr_wr_sp),                       // Stack Pointer to write
        .i_tmod(sfr_wr_tmod),                   // TMOD to write
        .i_th0(sfr_wr_th0),                     // TH0 to write
        .i_tl0(sfr_wr_tl0),                     // TL0 to write
        .i_tcon(sfr_wr_tcon),                   // TCON to write
        .i_scon(sfr_wr_scon),                   // SCON to write
        .i_sbuf(sfr_wr_sbuf),                   // SBUF to write
        .i_p2(sfr_wr_p2),                       // P2 to write
        .i_dmod(sfr_wr_dmod),                   // DMOD
        .i_dbuf(sfr_wr_dbuf),                   // DBUF
        .i_dtmcon(sfr_wr_dtmcon),               // DTMCON
        .i_kcon(sfr_wr_kcon),                   // KCON
        .i_kbuf(sfr_wr_kbuf),                   // KBUF
        .i_op(sfr_op),                          // Operation
        .i_parity(parity),                      // Parity flag to feed the PSW
        .o_acc(acc),                            // ACC
        .o_parity(parity),                      // Parity flag
        .o_psw(psw),                            // PSW
        .o_ie(ie),                              // IE (Interrupt Enable)
        .o_sp(sp),                              // Stack Pointer
        .o_tmod(tmod),                          // TMOD
        .o_th0(th0),                            // TH0
        .o_tl0(tl0),                            // TL0
        .o_tcon(tcon),                          // TCON
        .o_scon(scon),                          // SCON
        .o_sbuf(sbuf),                          // SBUF
        .o_p2(p2),                              // P2
        .o_dmod(dmod),                          // DMOD
        .o_dbuf(dbuf),                          // DBUF
        .o_dtmcon(dtmcon),                      // DTMCON
        .o_kcon(kcon),                          // KCON
        .o_kbuf(kbuf)                           // KBUF
    );
    
    // Map the SFRs into the RAM
    Map2SFR Map2SFR(
        .i_ir(o_op2_addr),                      // Real Address
        .i_ram_out(ram_out),                    // RAM value in the real address
        .i_acc(acc),                            // ACC 
        .i_psw(psw),                            // PSW
        .i_ie(ie),                              // IE
        .i_sp(sp),                              // SP
        .i_tmod(tmod),                          // TMOD
        .i_th0(th0),                            // TH0
        .i_tl0(tl0),                            // TL0
        .i_tcon(tcon),                          // TCON
        .i_scon(scon),                          // SCON
        .i_sbuf(sbuf),                          // SBUF
        .i_p2(p2),                              // P2
        .i_dmod(dmod),                          // DMOD
        .i_dbuf(dbuf),                          // DBUF
        .i_dtmcon(dtmcon),                      // DTMCON
        .i_kcon(kcon),                          // KCON
        .i_kbuf(kbuf),                          // KBUF
        .o_out(addr_mapped)                     // Address mapped
    );
    
     // Instanciate the UART
    UART UART (
        .i_clk(i_clk),                          // Clock 
        .i_rst(i_rst),                          // Reset
        .i_rx_serial(i_uart_rx),                // RX line
        .i_rx_en(scon[4]),                      // RX enable
        .i_tx_data(sbuf),                       // TX data to transmit
        .i_tx_en(scon[3]),                      // TX enable flag
        .o_rx_done(rx_done),                    // RX done flag
        .o_rx_data(rx_data),                    // RX data received
        .o_tx_done(tx_done),                    // TX done flag
        .o_tx_serial(o_uart_tx)                 // TX line
    );
    
    // Instanciate the Timer 0
    Timer Timer0 (
        .i_clk(i_clk),                          // Clock        
        .i_rst(i_rst),                          // Reset       
        .i_tmod(tmod),                          // TMOD        
        .i_thx(th0),                            // TH0     
        .i_tlx(tl0),                            // TL0   
        .i_trx(tcon[4]),                        // TR0         
        .i_intx(ie[1]),                         // INT0      
        .o_thx(th0_tim_out),                    // TH0 updated 
        .o_tlx(tl0_tim_out),                    // TL0 updated 
        .o_tfx(tf0_tim_out),                    // TF0 (overflow flag)
        .o_en(tim0_en)                          // Timer is running    
    );
    
    // Instanciate the Keyboard Module
    
    Keyboard Keyboard(
        .i_clk(i_clk),                          // Clock
        .i_rst(i_rst),                          // Reset
        .i_clk_ps2(i_clk_ps2),                  // Clock PS/2
        .i_data_ps2(i_data_ps2),                // Data PS/2
        .i_rx_en_ps2(kcon[2]),                  // PS/2 Reception Enable
        .o_ascii(keyb_key_data),                // Character Received
        .o_key_received(keyb_key_received)      // Received Flag
    );
    
    // Instanciate the VGA and Filters Module
    
    VGA_Filters VGA_Filters(
        .i_clk(i_clk),                          // Clock
        .i_rst(i_rst),                          // Reset
        .i_dmod(dmod),                          // SFR 
        .i_dtmcon(dtmcon),                      // SFR
        .i_char(dbuf),                          // Char to Write(Text Mode)
        .o_hsync(o_hsync),                      // HSYNC
        .o_vsync(o_vsync),                      // VSYNC
        .o_red(o_red),                          // Red
        .o_green(o_green),                      // Green
        .o_blue(o_blue),                        // Blue
        .o_key_done(vga_key_done)               // Display Key Finish
    );  
    
    // Instanciate the External Interrupt 0
    Interrupt EXT0_ISR (
        .i_clk(i_clk),                                                      // Clock
        .i_rst(i_rst),                                                      // Reset
        .i_en(ext0_int_en),                                                 // External 0 Interrupt enable
        .i_int(uart_int_in | tim0_int_in | ext0_int_in | keyb_int_in),      // Interrupt in progress (No nested interrupts)
        .i_int_req(ext0_button),                                            // External 0 Interrupt request (Pressed by a button)
        .o_int(ext0_int_status)                                             // External 0 Interrupt status (1 if the interrupt is eligible to execute)
    );
    
    // Instanciate the Timer 0 Interrupt
    Interrupt TIM0_ISR (
        .i_clk(i_clk),                                                      // Clock
        .i_rst(i_rst),                                                      // Reset
        .i_en(tim0_int_en),                                                 // Timer 0 Interrupt enable
        .i_int(uart_int_in | tim0_int_in | ext0_int_in | keyb_int_in),      // Interrupt in progress (No nested interrupts)
        .i_int_req(tf0_tim_out),                                            // Timer 0 Interrupt request
        .o_int(tim0_int_status)                                             // Timer 0 Interrupt status (1 if the interrupt is eligible to execute)
    );
    
    // Instanciate the Serial I/O Interrupt
    Interrupt UART_ISR (
        .i_clk(i_clk),                                                      // Clock
        .i_rst(i_rst),                                                      // Reset
        .i_en(uart_int_en),                                                 // Serial I/O Interrupt enable
        .i_int(uart_int_in | tim0_int_in | ext0_int_in | keyb_int_in),      // Interrupt in progress (No nested interrupts)
        .i_int_req(rx_done | tx_done),                                      // Serial I/O Interrupt request
        .o_int(uart_int_status)                                             // Serial I/O Interrupt status (1 if the interrupt is eligible to execute)
    );
    
    // Instanciate the Keyboard Interrupt
    Interrupt KEYB_ISR (
        .i_clk(i_clk),                                                      // Clock
        .i_rst(i_rst),                                                      // Reset
        .i_en(keyb_int_en),                                                 // Keyboard Interrupt enable
        .i_int(uart_int_in | tim0_int_in | ext0_int_in | keyb_int_in),      // Interrupt in progress (No nested interrupts)
        .i_int_req(keyb_key_received),                                      // Keyboard Interrupt request
        .o_int(keyb_int_status)                                             // Keyboard Interrupt status (1 if the interrupt is eligible to execute)
    );
    
    
    /********************* Write Memory ***********************/ 
    
    // Assign the SFRs operations
    assign sfr_op_aux1 = i_sfr_op;
    
    // If the Timer0 is running ==> Update the counter registers (TH0 and TL0) and TCON (Overflow flag)        
    assign sfr_op_aux2 = (tim0_en == 1'b1) ? (sfr_op_aux1 | `OP_TH0_WR_BYTE | `OP_TL0_WR_BYTE | `OP_TCON_WR_BYTE) : sfr_op_aux1;    
    
    // If UART receives a byte or sent a byte ==> Update the R1 and T1 flags in SCON
    assign sfr_op_aux3 = (rx_done == 1'b1 || tx_done == 1'b1) ? (sfr_op_aux2 | `OP_SCON_WR_BYTE) : sfr_op_aux2;
    
    // If UART receives a byte ==> Update the SBUF with the content received
    assign sfr_op_aux4 = (scon[4] == 1'b1 && rx_done == 1'b1) ? (sfr_op_aux3 | `OP_SBUF_WR_BYTE) : sfr_op_aux3;
    
    // Update keyboard character buffer and the Received Flag and Overflow Flag      
    assign sfr_op_aux5 = (keyb_key_received == 1'b1) ? (sfr_op_aux4 | `OP_KCON_WR_BYTE | `OP_KBUF_WR_BYTE) : sfr_op_aux4; 
    
    // Update keyboard character buffer and the Received Flag and Overflow Flag      
    assign sfr_op = (vga_key_done == 1'b1) ? (sfr_op_aux5 | `OP_DMOD_WR_BYTE) : sfr_op_aux5; 
    
    // Assign the SFRs values
    assign sfr_wr_acc = i_wr_data;
                          
    assign sfr_wr_psw = i_wr_psw; 
    
    assign sfr_wr_ie = i_wr_data;
    
    assign sfr_wr_sp = i_wr_data;
    
    assign sfr_wr_th0 = (tim0_en == 1'b1) ? th0_tim_out : i_wr_data;
    
    assign sfr_wr_tl0 = (tim0_en == 1'b1) ? tl0_tim_out : i_wr_data;
    
    assign sfr_wr_tmod = i_wr_data;
    
    // If the Timer0 in running and occured an overflow ==> Set the TF0 flag in TCON
    // If the Timer0 in running and not occured an overflow ==> Reset the TF0 flag in TCON
    assign sfr_wr_tcon = (tim0_en == 1'b1 && tf0_tim_out == 1'b1) ? (tcon | 8'b0010_0000) :
                         (tim0_en == 1'b1 && tf0_tim_out == 1'b0) ? (tcon & 8'b1101_1111) : i_wr_data;
                         
    // If received one byte ==> Assign the SBUF to the data received
    assign sfr_wr_sbuf = (rx_done == 1'b1) ? rx_data : i_wr_data;
    
    // If received one byte ==> Set the R1 flag in SCON
    // If transmitted one byte ==> Set the T1 flag in SCON
    assign sfr_wr_scon = (rx_done == 1'b1) ? (scon | 8'b0000_0001) :
                         (tx_done == 1'b1) ? (scon | 8'b0000_0010) : i_wr_data;
                         
    assign sfr_wr_p2 = i_wr_data;
    
    // Update received key flag and overflow flag
    assign sfr_wr_kcon = ((keyb_key_received == 1'b1) & (kcon[0] == 1)) ? (kcon | 8'b0000_0011) :
                        (keyb_key_received == 1'b1) ? (kcon | 8'b0000_0001) : i_wr_data;
    
    // Update keyboard reception buffer
    assign sfr_wr_kbuf =  (keyb_key_received == 1'b1) ? keyb_key_data : i_wr_data;
    
    assign sfr_wr_dmod = (vga_key_done == 1'b1) ? (dmod & 8'b1011_1111) : i_wr_data;
    
    // Update VGA registers
    assign sfr_wr_dbuf =  i_wr_data;
    assign sfr_wr_dtmcon =  i_wr_data;
           
    // Assign the RAM operations
    // Fill the adress to write into RAM
    assign ram_addr = i_wr_adress;
    
    // Fill the data to write into RAM
    assign ram_data = i_wr_data;    
    assign ram_bit = 1'b0;   
    
    // RAM operations
    assign ram_op = i_ram_op;
    
    
    /********************* New instruction logic **************/
    // Assign the acc for H_U
    assign o_acc = acc;
    
    // Assign the psw for H_U
    assign o_psw = psw;
    
    // Assign the carry for H_U
    assign o_cy = psw[7];
    
    // Assign the Bank
    assign bank = 2*psw[4] + psw[3];
    
    // Extract the opcode 
    assign opcode =	(bubble == 1)? 8'b0 : i_rom_out[15:8];          
    
    // Extract the default value of fisrt operand
    // 1) ACC
    // 2) Not used (0)
    assign op1_tmp =	(opcode == `ADD_D  || opcode == `ADD_C || opcode == `ADD_R      
                        || opcode == `ADDC_D  || opcode == `ADDC_C || opcode == `ADDC_R              
                        || opcode == `SUBB_D  || opcode == `SUBB_C || opcode == `SUBB_R
                        || opcode == `ANL_D  || opcode == `ANL_C || opcode == `ANL_R
                        || opcode == `ORL_D  || opcode == `ORL_C || opcode == `ORL_R
                        || opcode == `XRL_D  || opcode == `XRL_C || opcode == `XRL_R)
                        ? acc : 8'd0;

    
    // Extract the default value of second operand 
    // 1) Instructions XXX A, #immed
    // 2) Instructions XXX A, (direct or reg)
    // 3) Instructions XXX (direct or reg), A                                                          
    assign op2_tmp =	(opcode == `ADD_C  || opcode == `ADDC_C || opcode == `SUBB_C
                        || opcode == `ANL_C  || opcode == `ORL_C || opcode == `XRL_C
                        || opcode == `MOV_C) ? i_rom_out[7:0]: 
                        (opcode == `ADD_D  || opcode == `ADD_R || opcode == `ADDC_D
                        || opcode == `ADDC_R  || opcode == `SUBB_D || opcode == `SUBB_R
                        || opcode == `ANL_R  || opcode == `ANL_D || opcode == `ORL_R
                        || opcode == `ORL_D  || opcode == `XRL_R || opcode == `XRL_D
                        || opcode == `MOV_D  || opcode == `MOV_R) ? addr_mapped:
                        (opcode == `MOV_AD  || opcode == `MOV_AR) ? acc: 8'd0;
                                       
    // Set the first operand adress
    // By default all operations take tha ACC address
    // 1) MOV direct, A
    // 2) MOV Rn, A                           
    assign o_op1_addr  = (opcode == 8'b0) ? 8'b0:
                        (opcode == `MOV_AD) ? i_rom_out[7:0]:     
                        (opcode == `MOV_AR) ? (bank*8 + i_rom_out[7:0]):     
                        `ACC_ADDR ;                              
    
    // Set the second operand adress
    // By default all operations take the ACC address
    // 1) XXX A, direct / XXX rel 
    // 2) XXX A, Rn
    assign o_op2_addr  =  (opcode == 8'b0) ? 8'b0:
                          (opcode == `ADD_D || opcode == `SUBB_D || opcode == `ADDC_D || opcode == `ANL_D
                          || opcode == `ORL_D || opcode == `XRL_D || opcode == `MOV_D || opcode == `JC
                          || opcode == `JNC || opcode == `JZ || opcode == `JNZ) ? i_rom_out[7:0]:     
                          (opcode == `ADD_R || opcode == `ADDC_R || opcode == `SUBB_R || opcode == `ANL_R 
                          || opcode == `ORL_R || opcode == `XRL_R || opcode == `MOV_R ) ? (bank*8 + i_rom_out[7:0]):       
                          `ACC_ADDR ;                            
    
    // Set the first operand with forward conditions                            
    assign op1 = (opcode == 8'b0) ? 1'b0:
                 (i_forward_data_a == 2'd2) ? i_exec_buffer[`OPERAND1_POS]:
			     (i_forward_data_a == 2'd1) ? i_write_back_buffer[`OPERAND1_POS]:op1_tmp;
    
    // Set the second operand with forward conditions
    assign op2 = (opcode == 8'b0) ? 1'b0:
                 (i_forward_data_b == 2'd2) ? i_exec_buffer[`OPERAND1_POS]:
				 (i_forward_data_b == 2'd1) ? i_write_back_buffer[`OPERAND1_POS]:op2_tmp;
       
    // Set the flags with forward conditions
    
    assign cy = (opcode == 8'b0) ? 1'b0:
                (i_forward_flags == 3'd1) ? i_exec_buffer[`CY_POS]: 
                (i_forward_flags == 3'd2) ? i_write_back_buffer[`CY_POS]:psw[7];
    
    assign ac = (opcode == 8'b0) ? 1'b0:
                (i_forward_flags == 3'd1) ? i_exec_buffer[`AC_POS]: 
                (i_forward_flags == 3'd2) ? i_write_back_buffer[`AC_POS]:psw[6];
                
    assign ov = (opcode == 8'b0) ? 1'b0:
                (i_forward_flags == 3'd1) ? i_exec_buffer[`OV_POS]: 
                (i_forward_flags == 3'd2) ? i_write_back_buffer[`OV_POS]:psw[2];
    
    assign we = (opcode == 8'b0) ? 1'b0:
                (opcode == `MOV_D  || opcode == `MOV_C || opcode == `MOV_R
                || opcode == `MOV_AD  || opcode == `MOV_AR) ? 1'b1:1'b0; 
                
    //Update output buffer
    assign o_stage1 = {opcode, op1, op2, o_op1_addr, o_op2_addr,ov,ac,cy,we};
    
    
    /******************************** Leds *******************************/ 
    
    // Assign the LEDs
    assign o_leds = p2;
    
    
    // ***************************Interrupts flags************************/
    // Assign the Interrupts flags
    
    // External 0 Interrupt is enable when:
    // EA = 1 && EX0 = 1 
    assign ext0_int_en = (ie[7] == 1'b1 && ie[0] == 1'b1) ? 1'b1 : 1'b0; 
    
    // Timer 0 Interrupt is enable when:
    // EA = 1 && ET0 = 1                     
    assign tim0_int_en = (ie[7] == 1'b1 && ie[1] == 1'b1) ? 1'b1 : 1'b0;
    
    // UART Interrupt is enable when:
    // EA = 1 && ES0 = 1 
    assign uart_int_en = (ie[7] == 1'b1 && ie[4] == 1'b1) ? 1'b1 : 1'b0; 
    
    // Keyboard Interrupt is enable when:
    // EA = 1 && Bit 5 = 1 
    assign keyb_int_en = (ie[7] == 1'b1 && ie[5] == 1'b1) ? 1'b1 : 1'b0; 
    
    // New interrupt to process
    assign int_pend = ext0_int_status | uart_int_status | tim0_int_status | keyb_int_status;
    
    // Update the button status that will connect to External Interrupt 0
    assign ext0_button = i_button;
    //assign ext0_button = 1'b0;
    
    assign reti_op = (opcode == `RETI);
    
    
    /********************* Update the Program Counter Logic **************/

    always@(posedge i_clk)
    begin
	   PC <= new_PC;
	   ext0_int_in <= new_ext0_int_in;
	   tim0_int_in <= new_tim0_int_in;
	   uart_int_in <= new_uart_int_in;
	   keyb_int_in <= new_keyb_int_in;
	   PC_RETI <= new_PC_RETI;
	   bubble <= new_bubble;
    end
    
    // Assign PC values
    assign new_PC =     (i_rst)       ? 	16'd0:			        // Reset
                        (ext0_int_status)?  `ISR_EXT0_ADDR:         // Update PC with interrupt vector table address  
						(tim0_int_status)?  `ISR_TIM0_ADDR:         // Update PC with interrupt vector table address  
						(uart_int_status)?  `ISR_UART_ADDR:         // Update PC with interrupt vector table address
						(keyb_int_status)?  `ISR_KEYB_ADDR:         // Update PC with interrupt vector table address
						(reti_op)     ?     PC_RETI:                // Return from Interrrupt  
						(bubble) 	  ? 	PC + 16'd1:			    // Insert bubble when a jump was taken
						(i_pc_load)   ? 	i_rom_out[`REL_ADDR]:   // If a jump taken, update PC, signal given by Hazard Unit
											PC + 16'd1;			    // Increment PC
    
     // If a jump is taken the next instruction is a bubble
    assign new_bubble = (bubble == 1'b1 && i_pc_load == 1'b1) ? 1'b0 :
                        (i_pc_load || ext0_int_status || tim0_int_status || uart_int_status || keyb_int_status || reti_op);
    
    // Assign Interrupt signals
    assign new_ext0_int_in = (ext0_int_status == 1'b1) ? 1'b1 : 
                            (opcode == `RETI) ? 1'b0 :
                            (i_rst) ? 1'b0 : ext0_int_in;

    assign new_tim0_int_in = (tim0_int_status == 1'b1) ? 1'b1 : 
                            (opcode == `RETI) ? 1'b0 :
                            (i_rst) ? 1'b0 : tim0_int_in;
                                
    assign new_uart_int_in = (uart_int_status == 1'b1) ? 1'b1 : 
                            (opcode == `RETI) ? 1'b0 :
                            (i_rst) ? 1'b0 : uart_int_in;
                            
    assign new_keyb_int_in = (keyb_int_status == 1'b1) ? 1'b1 : 
                            (opcode == `RETI) ? 1'b0 :
                            (i_rst) ? 1'b0 : keyb_int_in;
                            
    // Save the program counter in case of interrupt
    assign new_PC_RETI = (int_pend == 1'b1 && i_pc_load == 1'b0) ? PC :
                         (int_pend == 1'b1 && i_pc_load == 1'b1) ? {8'b0,o_op2_addr}:
                         (i_rst) ? 1'b0 :  PC_RETI;
    
    // Assign PC
    assign o_PC = PC;
    /******************** Define initials conditions *****************/
    initial begin
        bubble <= 1'b0;
        PC_RETI <= 16'd0;
        ext0_int_in <= 1'b0;
        tim0_int_in <= 1'b0;
        uart_int_in <= 1'b0;
        keyb_int_in <= 1'b0; 
    end
endmodule