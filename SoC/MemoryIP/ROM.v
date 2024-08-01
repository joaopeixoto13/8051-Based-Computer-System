`timescale 1ns / 1ps

/*
    The ROM is the dedicated 64KB of program memory space on the 8051
    microcontroller. It contains the binary code with the instructions to be executed.
    The ROM module takes as input the 16 bits of the program counter PC, and
    gives as output the 8-bit data of instruction op-code and operands.
*/

//op_code [4:0]
`define ACALL 	8'bxxx1_0001 // absolute call
`define AJMP 	8'bxxx0_0001 // absolute jump

//op_code [7:3]
`define INC_R 	8'b0000_1xxx // increment Rn
`define DEC_R 	8'b0001_1xxx // decrement reg Rn=Rn-1
`define ADD_R 	8'b0010_1000 // add A=A+Rx
`define ADDC_R 	8'b0011_1000 // add A=A+Rx+c
`define ORL_R 	8'b0100_1000 // or A=A or Rn
`define ANL_R 	8'b0101_1000 // and A=A^Rx
`define XRL_R 	8'b0110_1000 // XOR A=A XOR Rn
`define MOV_CR 	8'b0111_1xxx // move Rn=constant
`define MOV_RD 	8'b1000_1xxx // move (direct)=Rn
`define SUBB_R 	8'b1001_1000 // substract with borrow  A=A-c-Rn
`define MOV_DR 	8'b1010_1xxx // move Rn=(direct)
`define CJNE_R 	8'b1011_1xxx // compare and jump if not equal; Rx<>constant
`define XCH_R 	8'b1100_1xxx // exchange A<->Rn
`define DJNZ_R 	8'b1101_1xxx // decrement and jump if not zero
`define MOV_R 	8'b1110_1000 // move A=Rn
`define MOV_AR 	8'b1111_1000 // move Rn=A

//op_code [7:1]
`define ADD_I 	8'b0010_011x // add A=A+@Ri
`define ADDC_I 	8'b0011_011x // add A=A+@Ri+c
`define ANL_I 	8'b0101_011x // and A=A^@Ri
`define CJNE_I 	8'b1011_011x // compare and jump if not equal; @Ri<>constant
`define DEC_I 	8'b0001_011x // decrement indirect @Ri=@Ri-1
`define INC_I 	8'b0000_011x // increment @Ri
`define MOV_I 	8'b1110_011x // move A=@Ri
`define MOV_ID 	8'b1000_011x // move (direct)=@Ri
`define MOV_AI 	8'b1111_011x // move @Ri=A
`define MOV_DI 	8'b1010_011x // move @Ri=(direct)
`define MOV_CI 	8'b0111_011x // move @Ri=constant
`define MOVX_IA 8'b1110_001x // move A=(@Ri)
`define MOVX_AI 8'b1111_001x // move (@Ri)=A
`define ORL_I 	8'b0100_011x // or A=A or @Ri
`define SUBB_I 	8'b1001_011x // substract with borrow  A=A-c-@Ri
`define XCH_I 	8'b1100_011x // exchange A<->@Ri
`define XCHD 	8'b1101_011x // exchange digit A<->Ri
`define XRL_I 	8'b0110_011x // XOR A=A XOR @Ri

//op_code [7:0]
`define ADD_D 	8'b0010_0101 // add A=A+(direct)
`define ADD_C 	8'b0010_0100 // add A=A+constant
`define ADDC_D 	8'b0011_0101 // add A=A+(direct)+c
`define ADDC_C 	8'b0011_0100 // add A=A+constant+c
`define ANL_D 	8'b0101_0101 // and A=A^(direct)
`define ANL_C 	8'b0101_0100 // and A=A^constant
`define ANL_AD 	8'b0101_0010 // and (direct)=(direct)^A
`define ANL_DC 	8'b0101_0011 // and (direct)=(direct)^constant
`define ANL_B 	8'b1000_0010 // and c=c^bit
`define ANL_NB 	8'b1011_0000 // and c=c^!bit
`define CJNE_D 	8'b1011_0101 // compare and jump if not equal; a<>(direct)
`define CJNE_C 	8'b1011_0100 // compare and jump if not equal; a<>constant
`define CLR_A 	8'b1110_0100 // clear accumulator
`define CLR_C 	8'b1100_0011 // clear carry
`define CLR_B 	8'b1100_0010 // clear bit
`define CPL_A 	8'b1111_0100 // complement accumulator
`define CPL_C 	8'b1011_0011 // complement carry
`define CPL_B 	8'b1011_0010 // complement bit
`define DA 		8'b1101_0100 // decimal adjust (A)
`define DEC_A 	8'b0001_0100 // decrement accumulator a=a-1
`define DEC_D 	8'b0001_0101 // decrement direct (direct)=(direct)-1
`define DIV 	8'b1000_0100 // divide
`define DJNZ_D 	8'b1101_0101 // decrement and jump if not zero (direct)
`define INC_A 	8'b0000_0100 // increment accumulator
`define INC_D 	8'b0000_0101 // increment (direct)
`define INC_DP 	8'b1010_0011 // increment data pointer
`define JB 		8'b0010_0000 // jump if bit set
`define JBC	 	8'b0001_0000 // jump if bit set and clear bit
`define JC 		8'b0100_0000 // jump if carry is set
`define JMP_D 	8'b0111_0011 // jump indirect
`define JNB 	8'b0011_0000 // jump if bit not set
`define JNC 	8'b0101_0000 // jump if carry not set
`define JNZ 	8'b0111_0000 // jump if accumulator not zero
`define JZ 		8'b0110_0000 // jump if accumulator zero
`define LCALL 	8'b0001_0010 // long call
`define LJMP 	8'b0000_0010 // long jump
`define MOV_D 	8'b1110_0101 // move A=(direct)
`define MOV_C 	8'b0111_0100 // move A=constant
`define MOV_AD 	8'b1111_0101 // move (direct)=A
`define MOV_DD 	8'b1000_0101 // move (direct)=(direct)
`define MOV_CD 	8'b0111_0101 // move (direct)=constant
`define MOV_BC 	8'b1010_0010 // move c=bit
`define MOV_CB 	8'b1001_0010 // move bit=c
`define MOV_DP 	8'b1001_0000 // move dptr=constant(16 bit)
`define MOVC_DP 8'b1001_0011 // move A=dptr+A
`define MOVC_PC 8'b1000_0011 // move A=pc+A
`define MOVX_PA 8'b1110_0000 // move A=(dptr)
`define MOVX_AP 8'b1111_0000 // move (dptr)=A
`define MUL 	8'b1010_0100 // multiply a*b
`define NOP 	8'b0000_0000 // no operation
`define ORL_D 	8'b0100_0101 // or A=A or (direct)
`define ORL_C 	8'b0100_0100 // or A=A or constant
`define ORL_AD 	8'b0100_0010 // or (direct)=(direct) or A
`define ORL_CD 	8'b0100_0011 // or (direct)=(direct) or constant
`define ORL_B 	8'b0111_0010 // or c = c or bit
`define ORL_NB 	8'b1010_0000 // or c = c or !bit
`define POP 	8'b1101_0000 // stack pop
`define PUSH 	8'b1100_0000 // stack push
`define RET 	8'b0010_0010 // return from subrutine
`define RETI 	8'b0011_0010 // return from interrupt
`define RL 		8'b0010_0011 // rotate left
`define RLC 	8'b0011_0011 // rotate left thrugh carry
`define RR 		8'b0000_0011 // rotate right
`define RRC 	8'b0001_0011 // rotate right thrugh carry
`define SETB_C 	8'b1101_0011 // set carry
`define SETB_B 	8'b1101_0010 // set bit
`define SJMP 	8'b1000_0000 // short jump
`define SUBB_D 	8'b1001_0101 // substract with borrow  A=A-c-(direct)
`define SUBB_C 	8'b1001_0100 // substract with borrow  A=A-c-constant
`define SWAP 	8'b1100_0100 // swap A(0-3) <-> A(4-7)
`define XCH_D 	8'b1100_0101 // exchange A<->(direct)
`define XRL_D 	8'b0110_0101 // XOR A=A XOR (direct)
`define XRL_C 	8'b0110_0100 // XOR A=A XOR constant
`define XRL_AD 	8'b0110_0010 // XOR (direct)=(direct) XOR A
`define XRL_CD 	8'b0110_0011 // XOR (direct)=(direct) XOR constant
`define INTERRUPT 8'b0110_0011

// ALU control signals
`define ALU_CS_LEN      3
`define ALU_CS_NOP      `ALU_CS_LEN'd0
`define ALU_CS_ADD      `ALU_CS_LEN'd1         // ADD control signal
`define ALU_CS_ADDC     `ALU_CS_LEN'd2         // ADDC control signal
`define ALU_CS_SUB      `ALU_CS_LEN'd3         // SUB control signal
`define ALU_CS_AND      `ALU_CS_LEN'd4         // AND control signal
`define ALU_CS_XOR      `ALU_CS_LEN'd5         // XOR control signal
`define ALU_CS_OR       `ALU_CS_LEN'd6         // OR control signal
`define ALU_CS_SHIFT_OP `ALU_CS_LEN'd7         // SHIFT_op control signal
                           
// RAM code Operations
`define RAM_OP_LEN              2
`define OP_RAM_NOP              `RAM_OP_LEN'd0
`define OP_RAM_WR_BYTE          `RAM_OP_LEN'd1
`define OP_RAM_WR_BIT           `RAM_OP_LEN'd2
`define OP_RAM_RD_BIT           `RAM_OP_LEN'd3

// SFRs code operations
`define SFR_OP_LEN              22
`define OP_DEFAULT              `SFR_OP_LEN'd0  
`define OP_ACC_WR_BYTE          `SFR_OP_LEN'd1
`define OP_ACC_WR_BIT           `SFR_OP_LEN'd2
`define OP_PSW_WR_BYTE          `SFR_OP_LEN'd4
`define OP_PSW_WR_BIT           `SFR_OP_LEN'd8
`define OP_PSW_WR_FLAGS         `SFR_OP_LEN'd16
`define OP_IE_WR_BYTE           `SFR_OP_LEN'd32
`define OP_IE_WR_BIT            `SFR_OP_LEN'd64
`define OP_SP_WR_BYTE           `SFR_OP_LEN'd128
`define OP_SP_PUSH              `SFR_OP_LEN'd256
`define OP_SP_POP               `SFR_OP_LEN'd512
`define OP_TMOD_WR_BYTE         `SFR_OP_LEN'd1024
`define OP_TH0_WR_BYTE          `SFR_OP_LEN'd2048
`define OP_TL0_WR_BYTE          `SFR_OP_LEN'd4096
`define OP_TCON_WR_BYTE         `SFR_OP_LEN'd8192
`define OP_SBUF_WR_BYTE         `SFR_OP_LEN'd16384
`define OP_SCON_WR_BYTE         `SFR_OP_LEN'd32768
`define OP_P2_WR_BYTE           `SFR_OP_LEN'd65536
`define OP_DMOD_WR_BYTE         `SFR_OP_LEN'd131072
`define OP_DBUF_WR_BYTE         `SFR_OP_LEN'd262144
`define OP_KCON_WR_BYTE         `SFR_OP_LEN'd524288
`define OP_KBUF_WR_BYTE         `SFR_OP_LEN'd1048576



// SFR's Addresses
`define SFR_ADDR_LEN  8
`define DEFAULT       `SFR_ADDR_LEN'h00
`define ACC_ADDR      `SFR_ADDR_LEN'hE0                      
`define PSW_ADDR      `SFR_ADDR_LEN'hD0              
`define IE_ADDR       `SFR_ADDR_LEN'hA8
`define TH0_ADDR      `SFR_ADDR_LEN'h8C
`define TL0_ADDR      `SFR_ADDR_LEN'h8A
`define TMOD_ADDR     `SFR_ADDR_LEN'h89
`define SP_ADDR       `SFR_ADDR_LEN'h81
`define TCON_ADDR     `SFR_ADDR_LEN'h88
`define SBUF_ADDR     `SFR_ADDR_LEN'h99
`define SCON_ADDR     `SFR_ADDR_LEN'h98
`define P2_ADDR       `SFR_ADDR_LEN'hA0
`define DMOD_ADDR     `SFR_ADDR_LEN'hA1
`define DBUF_ADDR     `SFR_ADDR_LEN'hA2
`define KCON_ADDR     `SFR_ADDR_LEN'hA3
`define KBUF_ADDR     `SFR_ADDR_LEN'hA4

// Interrupts Vector Table
`define ISR_LEN         2               // Flag that generate the interrupt  # SFR bit    # Enable Flag
`define ISR_RST         `ISR_LEN'b00    //                RST 
`define ISR_EXT0        `ISR_LEN'b01    //                IE0                  TCON.1       EX0 (IE.0)
`define ISR_TIM0        `ISR_LEN'b10    //                TF0                  TCON.5       ET0 (IE.1)
`define ISR_UART        `ISR_LEN'b11    //               RIO/TI0           SCON.0/SCON.1    ES0 (IE.4)

`define ISR_ADDR_LEN    8
`define ISR_RST_ADDR    `ISR_ADDR_LEN'h00   // 0x00
`define ISR_EXT0_ADDR   `ISR_ADDR_LEN'h03   // 0x03
`define ISR_TIM0_ADDR   `ISR_ADDR_LEN'h0b   // 0x0b
`define ISR_UART_ADDR   `ISR_ADDR_LEN'h23   // 0x23
`define ISR_KEYB_ADDR   `ISR_ADDR_LEN'h30   // 0x30
`define ISR_DISP_ADDR   `ISR_ADDR_LEN'h3E   // 0x3E

// Timer Defines
`define TIMER_MODE_0 2'b00
`define TIMER_MODE_1 2'b01
`define TIMER_MODE_2 2'b10
`define TIMER_MODE_3 2'b11

// Auxiliar
`define WIDTH 8
`define ROM_WIDTH 16
`define REL_ADDR 7:0


// Buffer
`define BUFFER_LENGTH           44          // Buffers Length
`define OPCODE_POS              43:36       // Opcode
`define OPERAND1_POS            35:28       // Operand 1
`define OPERAND2_POS            27:20       // Operand 2
`define ADDR_OPERAND1_POS       19:12       // Address Operand 1
`define ADDR_OPERAND2_POS       11:4        // Address Operand 2
`define OV_POS                  3           // Overflow
`define AC_POS                  2           // Auxiliar Carry
`define CY_POS                  1           // Carry
`define WE_POS                  0           // Write Enable


//-------------------- Keyboard Defines------------------------

`define ENTER       8'h29
`define SPACE       8'h5A
`define BACKSPACE   8'h66
`define TAB         8'h0D
`define ESC         8'h76

`define A           8'h1C
`define B           8'h32
`define C           8'h21
`define D           8'h23
`define E           8'h24
`define F           8'h2B
`define G           8'h34
`define H           8'h33
`define I           8'h43
`define J           8'h3B
`define K           8'h42
`define L           8'h4B
`define M           8'h3A
`define N           8'h31
`define O           8'h44
`define P           8'h4D
`define Q           8'h15
`define R           8'h2D
`define S           8'h1B
`define T           8'h2C
`define U           8'h3C
`define V           8'h2A
`define W           8'h1D
`define X           8'h22
`define Y           8'h35
`define Z           8'h1A
        
`define ZERO_CURVE_LEFT                     8'h45
`define ONE_ESCLAMATION                     8'h16
`define TWO_AT                              8'h1E
`define THREE_CARDINAL                      8'h26
`define FOUR_DOLAR                          8'h25
`define FIVE_PERCENT                        8'h2E
`define SIX_HAT                             8'h36
`define SEVEN_AMPERSAND                     8'h3D
`define EIGHT_ASTERISK                      8'h3E
`define NINE_CURVE_RIGHT                    8'h46
`define TILDE_GRAVE_ACCENT                  8'h0E 
`define UNDERSCORE_HIFEN                    8'h4E
`define EQUAL_SUM                           8'h55
`define STRAIGHT_RIGHT_BRACKET_RIGHT        8'h54
`define STRAIGHT_LEFT_BRACKET_LEFT          8'h5B
`define SLASH_LEFT_SLASH_VERTICAL           8'h5D
`define POINTCOMMA_TWO_POINTS               8'h4C
`define APOSTROFE_QUOTATIONMARKS            8'h52
`define COMMA_MINOR                         8'h41
`define POINT_GREATER                       8'h49
`define SLASH_RIGHT_QUESTIONMARK            8'h4A
                     
`define RIGHT_SHIFT             8'h59
`define LEFT_SHIFT              8'h12
`define BREAK_CODE              8'hf0
`define CAPS_LOCK               8'h58

module ROM(
    input i_clk_read,                       // Clock
    input i_clk_write,                      // Clock
    input [15:0] i_addr_read,               // Address to read
    input [15:0] i_addr_write,              // Address to write
    input [15:0] i_byte,                    // Word to write
    input i_wr_enable,                      // Write enable
    output o_busy,                          // Is flashing flag
    output reg [15:0] o_out                 // Value read
    );
    
    (* ram_style = "distributed" *) reg [15:0]MEM[0:1023];                  // Principal memory (byte addressble)
    
    integer k;
    
    wire [15:0] data;
    
    initial begin
    
        for (k = 0; k < 1024; k = k + 1)
        begin
            MEM[k] = 16'b0;                     
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
        
        
        // Keyboard Interrupt
        MEM[0] = {`MOV_C, 8'b1010_0000};      // MOV A, immediate, immediate = Enable EA and KEY
        MEM[1] = {`MOV_AD, `IE_ADDR};         // MOV direct, A
        MEM[2] = {`MOV_C, 8'b0000_0100};      // MOV A, immediate, immediate = Enable Keyboard Reception
        MEM[3] = {`MOV_AD, `KCON_ADDR};       // MOV direct, A
        MEM[4] = {`JNC, 8'd4};                // JNC rel, rel = #4
        
        MEM[8'h30] = {`MOV_D, `KBUF_ADDR};    // ADD A, direct, KBUF 
        MEM[8'h31] = {`MOV_AD, `P2_ADDR};     // MOV direct, A, MOV P2, A
        MEM[8'h32] = {`RETI, 8'd0};           // RETI
        
        
        /*
        MEM[0] = {`MOV_C, 8'b1010_0000};      // MOV A, immediate, immediate = Enable EA and KEY
        MEM[1] = {`MOV_AD, `IE_ADDR};         // MOV direct, A
        MEM[2] = {`MOV_C, 8'b0000_0100};      // MOV A, immediate, immediate = Enable Keyboard Reception
        MEM[3] = {`MOV_AD, `KCON_ADDR};       // MOV direct, A
        MEM[4] = {`MOV_C, 8'b0011_0000};      // MOV A, immediate, immediate = Enable text Mode
        MEM[5] = {`MOV_AD, `DMOD_ADDR};       // MOV direct, A
        MEM[6] = {`JNC, 8'd6};                // JNC rel, rel = #4 
        
        MEM[8'h30] = {`MOV_D, `KBUF_ADDR};    // ADD A, direct, Key received
        MEM[8'h31] = {`MOV_AD, `P2_ADDR};     // MOV direct, A, MOV P2, A
        MEM[8'h32] = {`MOV_AD, `DBUF_ADDR};   // Update key of display
        MEM[8'h33] = {`MOV_C, 8'b0111_0000};  // ADD A, immediate, update display
        MEM[8'h34] = {`MOV_AD, `DMOD_ADDR};   // MOV direct, A,
        MEM[8'h35] = {`RETI, 8'd0};           // RETI                      
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
    
    always @(posedge i_clk_read)
    begin
        o_out <= data;                        // Read the content from memory 
    end
    
    always @(posedge i_clk_write)
    begin
        MEM[i_addr_write] <= i_byte;
    end
    
    assign data = MEM[i_addr_read];
    assign o_busy = i_wr_enable;
       
endmodule
