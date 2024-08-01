`timescale 1ns / 1ps

/*
    This module implements the third stage of the pipeline where is 
    executed the write back operations
*/
module Stage3(
        input [`BUFFER_LENGTH-1:0] i_in,            // Buffer 2 output
        output [7:0] o_wr_psw,                      // PSW output
        output [7:0] o_wr_data,                     // Data to write
        output [7:0] o_wr_adress,                   // Adress to write
        output [`RAM_OP_LEN-1:0] o_ram_op,          // RAM operation
        output [`SFR_OP_LEN-1:0] o_sfr_op           // SFR operation
    );
    
    wire instruction_alu;                           // Intruction type
    wire [7:0] opcode;                              // Opcode
    wire [7:0] op1;                                 // Operand 1
    wire [7:0] op2;                                 // Operand 2
    wire [7:0] op1_addr;                            // Adress of operand 1
    wire [7:0] op2_addr;                            // Adress of operand 2
    wire ac;                                        // Auxiliar carry
    wire cy;                                        // Carry
    wire ov;                                        // Overflow
    wire we;                                        // Write enable
     
    // Extract buffer fields               
    assign opcode = i_in[`OPCODE_POS];
    assign op1 = i_in[`OPERAND1_POS];
    assign op2 = i_in[`OPERAND2_POS];
    assign op1_addr = i_in[`ADDR_OPERAND1_POS]; 
    assign op2_addr = i_in[`ADDR_OPERAND2_POS];
    assign ac = i_in[`AC_POS];
    assign cy = i_in[`CY_POS];
    assign ov = i_in[`OV_POS];
    assign we = i_in[`WE_POS];
    
    parameter ALU_INSTRUCTION = 1'b1;
    
    
    // Assign ALU instructions
    assign instruction_alu = (opcode == `ADD_R || opcode == `ADD_D || opcode == `ADD_C
                        || opcode == `SUBB_R || opcode == `SUBB_D || opcode == `SUBB_C
                        || opcode == `ADDC_R || opcode == `ADDC_D || opcode == `ADDC_C
                        || opcode == `ANL_R || opcode == `ANL_D || opcode == `ANL_C
                        || opcode == `ORL_R || opcode == `ORL_D || opcode == `ORL_C
                        || opcode == `XRL_R || opcode == `XRL_D || opcode == `XRL_C)
                        ? ALU_INSTRUCTION : 1'b0;
    
    // Assign the SFRs operations
    // 1) Operations that change ACC and PSW values(flags)
    // 2) Operations that change ACC
    // 3) Other SFRs
    assign o_sfr_op = (instruction_alu == ALU_INSTRUCTION) 
                        ? (`OP_ACC_WR_BYTE | `OP_PSW_WR_FLAGS):
                        (opcode == `MOV_R || opcode == `MOV_D || opcode == `MOV_C)
                        ? `OP_ACC_WR_BYTE :
                        (we == 1'b1 && op1_addr == `IE_ADDR) ? `OP_IE_WR_BYTE : 
                        (we == 1'b1 && op1_addr == `SP_ADDR) ? `OP_SP_WR_BYTE : 
                        (we == 1'b1 && op1_addr == `TH0_ADDR) ? `OP_TH0_WR_BYTE : 
                        (we == 1'b1 && op1_addr == `TL0_ADDR) ? `OP_TL0_WR_BYTE : 
                        (we == 1'b1 && op1_addr == `TMOD_ADDR) ? `OP_TMOD_WR_BYTE : 
                        (we == 1'b1 && op1_addr == `TCON_ADDR) ? `OP_TCON_WR_BYTE : 
                        (we == 1'b1 && op1_addr == `SCON_ADDR) ? `OP_SCON_WR_BYTE :
                        (we == 1'b1 && op1_addr == `SBUF_ADDR) ? `OP_SBUF_WR_BYTE : 
                        (we == 1'b1 && op1_addr == `P2_ADDR) ? `OP_P2_WR_BYTE :
                        (we == 1'b1 && op1_addr == `PSW_ADDR) ? `OP_PSW_WR_BYTE :
                        (we == 1'b1 && op1_addr == `DMOD_ADDR) ? `OP_DMOD_WR_BYTE :
                        (we == 1'b1 && op1_addr == `DBUF_ADDR) ? `OP_DBUF_WR_BYTE :
                        (we == 1'b1 && op1_addr == `KCON_ADDR) ? `OP_KCON_WR_BYTE :
                        (we == 1'b1 && op1_addr == `KBUF_ADDR) ? `OP_KBUF_WR_BYTE :
                        (we == 1'b1 && op1_addr == `DTMCON_ADDR) ? `OP_DTMCON_WR_BYTE :
                        `OP_DEFAULT;
                         
    // Set RAM operation                    
    assign o_ram_op = (we == 1'b1 && o_sfr_op == `OP_DEFAULT) ? `OP_RAM_WR_BYTE:
                        `OP_RAM_NOP;
    
    // Set PSW output                        
    assign o_wr_psw = (instruction_alu == ALU_INSTRUCTION) ? cy + ac*2 + ov*4:
                   (we == 1'b1 && op1_addr == `PSW_ADDR) ? op1: 8'b0;                    

    // Set address to write
    assign o_wr_adress = op1_addr; 

    // Set data that will be written
    assign o_wr_data = op1;                 
                       
endmodule