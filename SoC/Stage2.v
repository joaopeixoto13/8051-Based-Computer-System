`timescale 1ns / 1ps

/*
    This module implements the second stage of the pipeline
    Where the ALU operations will be performed and the second operand 
    in MOV intructions will be moved to the first operand
*/

module Stage2(
    input [`BUFFER_LENGTH-1:0]	i_buf,      // Output of stage 1
    output [`BUFFER_LENGTH-1:0]	o_buf       // Output of stage 2
    );
    
    // Calculate operation
    wire [`ALU_CS_LEN:0] operation;
    wire [`WIDTH:0] opcode;
    
    
    // Extract opcode
    assign opcode = i_buf[`OPCODE_POS];     
    
    // Extract ALU operation to perform
    assign operation = ((opcode == `ADD_R) || (opcode == `ADD_D) || (opcode == `ADD_C)) ? `ALU_CS_ADD:
						((opcode == `SUBB_R) || (opcode == `SUBB_D) || (opcode == `SUBB_C)) ? `ALU_CS_SUB:
						((opcode == `ADDC_R) || (opcode == `ADDC_D) || (opcode == `ADDC_C)) ? `ALU_CS_ADDC:
						((opcode == `ANL_R) || (opcode == `ANL_D) || (opcode == `ANL_C)) ? `ALU_CS_AND:
						((opcode == `ORL_R) || (opcode == `ORL_D) || (opcode == `ORL_C)) ? `ALU_CS_OR:
                        ((opcode == `XRL_R) || (opcode == `XRL_D) || (opcode == `XRL_C)) ? `ALU_CS_XOR:
                        ((opcode == `MOV_R) || (opcode == `MOV_D) || (opcode == `MOV_C)
                        || (opcode == `MOV_AR) || (opcode == `MOV_AD))? `ALU_CS_SHIFT_OP:`ALU_CS_NOP;
                        
                    
                    
    // Output buffer
    wire [`WIDTH-1:0] alu_des;
    wire cy_des;
    wire ac_des;
    wire ov_des;
    
    assign o_buf = {i_buf[`OPCODE_POS],alu_des,i_buf[`OPERAND2_POS],i_buf[`ADDR_OPERAND1_POS],i_buf[`ADDR_OPERAND2_POS],ov_des,ac_des,cy_des,i_buf[`WE_POS]};
     
    assign cy_des = ((opcode == `MOV_AD) && (i_buf[`ADDR_OPERAND1_POS] == `PSW_ADDR))? i_buf[27]: alu_desC; 
    
    assign ac_des = ((opcode == `MOV_AD) && (i_buf[`ADDR_OPERAND1_POS] == `PSW_ADDR))? i_buf[26]: alu_desAc;
    
    assign ov_des = ((opcode == `MOV_AD) && (i_buf[`ADDR_OPERAND1_POS] == `PSW_ADDR))? i_buf[22]: alu_desOv;
                        
    // Instanciate the ALU
    ALU ALU(
        .i_operation(operation),                            // ALU operation
        .i_src1(i_buf[`OPERAND1_POS]),                      // ALU source #1
        .i_src2(i_buf[`OPERAND2_POS]),                      // ALU source #2
        .i_srcC(i_buf[`CY_POS]),                            // ALU source carry
        .i_srcAc(i_buf[`AC_POS]),                           // ALU source auxiliary carry
        .o_des1(alu_des),                                   // ALU destination value
        .o_desC(alu_desC),                                  // ALU destination carry
        .o_desAc(alu_desAc),                                // ALU destination auxiliary carry
        .o_desOv(alu_desOv)                                 // ALU destination overflow
    );
endmodule