`timescale 1ns / 1ps

/*
    This module implements the Hazard unit module
        - Here is performed the detections of data hazards and is 
        select the serpective data forward (operands and flags)
        - Also is verified the branch conditions
*/

module Hazard_Unit(
		input [7:0] i_Ra_addr,                            // Adress of operand 1
		input [7:0] i_Rb_addr,                            // Adress of operand 2
		input [`BUFFER_LENGTH-1:0] i_Buffer1,             // Buffer 1
		input [`BUFFER_LENGTH-1:0] i_Buffer2,             // Buffer 2
		input [15:0] i_ir,                                // Instruction Register
		input [7:0] i_psw_rf,                             // PSW from Register file
	    input [7:0] i_acc_rf,                             // ACC from Register file 
	    input [7:0] i_res_alu,                            // ALU result 
		input i_cy_alu,                                   // Carry from ALU
		output [1:0] o_forward_data_a,                    // Forward signal
		output [1:0] o_forward_data_b,                    // Forward signal
		output [1:0] o_forward_flags,                     // Forward flags signal
		output o_pc_load                                  // PC load signal
);

	parameter alu_mov_instruction = 2'd0;
	parameter other_instruction = 2'd1;
	parameter mov_acc_instruction = 2'd2;
	parameter alu_instruction = 2'd3;

	wire Ra_eq_Rd_exec;                                   // Adress of first operand equal to operand in Execution stage 
	wire Rb_eq_Rd_exec;                                   // Adress of second operand equal to operand in Execution stage      
	wire Ra_eq_Rd_wb;                                     // Adress of first operand equal to operand in Write Back stage       
	wire Rb_eq_Rd_wb;                                     // Adress of second operand equal to operand in Write Back stage       
	wire[1:0] instruction_type;                           // Type of instruction on stage 1
	wire[1:0] instruction_type_s2;                        // Type of instruction on stage 2
	wire[1:0] instruction_type_s3;                        // Type of instruction on stage 3
	wire[1:0] instruction_type_aux;                       // Type of instruction on stage 1  
	wire[1:0] instruction_type_s2_aux;                    // Type of instruction on stage 2
	wire[1:0] instruction_type_s3_aux;                    // Type of instruction on stage 3  
	wire[1:0] previous_instruction;                       // Type of instruction on stage 2 
	wire[1:0] previous_previous_instruction;              // Type of instruction on stage 3 
	wire[7:0] opcode;                                     // Opcode of new instruction 
	wire[7:0] Rd_exec_addr;                               // Adress of first operand in Execution stage 
	wire[7:0] Rd_wb_addr;                                 // Adress of first operand in Write Back stage  
    
    // Assign necessary fields
	assign opcode 		= i_ir[15:8];                     
    assign Rd_exec_addr = i_Buffer1[`ADDR_OPERAND1_POS];
	assign Rd_wb_addr 	= i_Buffer2[`ADDR_OPERAND1_POS];
	
	// Detect occurence of data hazards
	assign Ra_eq_Rd_exec = (i_Ra_addr == Rd_exec_addr) ? 1'b1 : 1'b0;
	assign Rb_eq_Rd_exec = (i_Rb_addr == Rd_exec_addr) ? 1'b1 : 1'b0;
	assign Ra_eq_Rd_wb 	= (i_Ra_addr == Rd_wb_addr) ? 1'b1 : 1'b0;
	assign Rb_eq_Rd_wb 	= (i_Rb_addr == Rd_wb_addr) ? 1'b1 : 1'b0;
    
    
    // Extract the the instruction type on stage 1
    // 1) ALU
    // 2) Other
	assign instruction_type_aux = (opcode == `ADD_R || opcode == `ADD_D || opcode == `ADD_C
							|| opcode == `SUBB_R || opcode == `SUBB_D || opcode == `SUBB_C
							|| opcode == `ADDC_R || opcode == `ADDC_D || opcode == `ADDC_C
							|| opcode == `ANL_R || opcode == `ANL_D || opcode == `ANL_C
							|| opcode == `ORL_R || opcode == `ORL_D || opcode == `ORL_C
                            || opcode == `XRL_R || opcode == `XRL_D || opcode == `XRL_C) ? alu_instruction :
                            other_instruction;
                            
    // Extract the the instruction type on stage 2
    // 1) ALU
    // 2) Other
	assign instruction_type_s2_aux = (i_Buffer1[`OPCODE_POS] == `ADD_R || i_Buffer1[`OPCODE_POS] == `ADD_D || i_Buffer1[`OPCODE_POS] == `ADD_C
							|| i_Buffer1[`OPCODE_POS] == `SUBB_R || i_Buffer1[`OPCODE_POS] == `SUBB_D || i_Buffer1[`OPCODE_POS] == `SUBB_C
							|| i_Buffer1[`OPCODE_POS] == `ADDC_R || i_Buffer1[`OPCODE_POS] == `ADDC_D || i_Buffer1[`OPCODE_POS] == `ADDC_C
							|| i_Buffer1[`OPCODE_POS] == `ANL_R || i_Buffer1[`OPCODE_POS] == `ANL_D || i_Buffer1[`OPCODE_POS] == `ANL_C
							|| i_Buffer1[`OPCODE_POS] == `ORL_R || i_Buffer1[`OPCODE_POS] == `ORL_D || i_Buffer1[`OPCODE_POS] == `ORL_C
                            || i_Buffer1[`OPCODE_POS] == `XRL_R || i_Buffer1[`OPCODE_POS] == `XRL_D || i_Buffer1[`OPCODE_POS] == `XRL_C) ? alu_instruction :
                            other_instruction;
    
    // Extract the the instruction type on stage 3
    // 1) ALU
    // 2) Other
	assign instruction_type_s3_aux = (i_Buffer2[`OPCODE_POS] == `ADD_R || i_Buffer2[`OPCODE_POS] == `ADD_D || i_Buffer2[`OPCODE_POS] == `ADD_C
							|| i_Buffer2[`OPCODE_POS] == `SUBB_R || i_Buffer2[`OPCODE_POS] == `SUBB_D || i_Buffer2[`OPCODE_POS] == `SUBB_C
							|| i_Buffer2[`OPCODE_POS] == `ADDC_R || i_Buffer2[`OPCODE_POS] == `ADDC_D || i_Buffer2[`OPCODE_POS] == `ADDC_C
							|| i_Buffer2[`OPCODE_POS] == `ANL_R || i_Buffer2[`OPCODE_POS] == `ANL_D || i_Buffer2[`OPCODE_POS] == `ANL_C
							|| i_Buffer2[`OPCODE_POS] == `ORL_R || i_Buffer2[`OPCODE_POS] == `ORL_D || i_Buffer2[`OPCODE_POS] == `ORL_C
                            || i_Buffer2[`OPCODE_POS] == `XRL_R || i_Buffer2[`OPCODE_POS] == `XRL_D || i_Buffer2[`OPCODE_POS] == `XRL_C) ? alu_instruction :
                            other_instruction;
                            
    // Extract the the instruction type on stage 1
    // 1) ALU/MOV
    // 2) Other
    assign instruction_type = ((instruction_type_aux ==  alu_instruction)|| opcode == `MOV_R 
                                || opcode == `MOV_D || opcode == `MOV_AR
                                || opcode == `MOV_AD) ? alu_mov_instruction : other_instruction;
                           
    // Extract the the instruction type on stage 2
    // 1) ALU/MOV
    // 2) Other
    assign instruction_type_s2 = ((instruction_type_s2_aux ==  alu_instruction) || i_Buffer1[`OPCODE_POS] == `MOV_R 
                             || i_Buffer1[`OPCODE_POS] == `MOV_D || i_Buffer1[`OPCODE_POS] == `MOV_C || i_Buffer1[`OPCODE_POS] == `MOV_AR
                             || i_Buffer1[`OPCODE_POS] == `MOV_AD) ? alu_mov_instruction : other_instruction;
    
    // Extract the the instruction type on stage 3
    // 1) ALU/MOV
    // 2) Other
    assign instruction_type_s3 = ((instruction_type_s3_aux ==  alu_instruction) || i_Buffer2[`OPCODE_POS] == `MOV_R 
                             || i_Buffer2[`OPCODE_POS] == `MOV_D || i_Buffer2[`OPCODE_POS] == `MOV_C || i_Buffer2[`OPCODE_POS] == `MOV_AR
                             || i_Buffer2[`OPCODE_POS] == `MOV_AD) ? alu_mov_instruction : other_instruction;          
    

    // Extract the the previous instruction type
    // 1) ALU
    // 2) MOV to A
    // 3) Other
	assign previous_instruction = (instruction_type_s2_aux == alu_instruction) ? alu_instruction :
							(i_Buffer1[`OPCODE_POS] == `MOV_R || i_Buffer1[`OPCODE_POS] == `MOV_D || i_Buffer1[`OPCODE_POS] == `MOV_C) ? mov_acc_instruction :
							other_instruction;
	
	// Extract the the previous previous instruction type
    // 1) ALU
    // 2) MOV to A
    // 3) Other						
	assign previous_previous_instruction = (instruction_type_s3_aux == alu_instruction) ? alu_instruction :
							(i_Buffer2[`OPCODE_POS] == `MOV_R || i_Buffer2[`OPCODE_POS] == `MOV_D || i_Buffer2[`OPCODE_POS] == `MOV_C) ? mov_acc_instruction :
							other_instruction;
							
    // Assign pc load signal
    // 1) JC ≃ JNC -> 
    //      1) Check the if the previous instruction can affet the carry if it is active
    //      2) Check the if the previous previous instruction can affet the carry if it is active
    //      3) If none of the above is true check the carry from register file
    // 2) JZ ≃ JNZ
    //      The same of the carry but for the accumulator
	assign o_pc_load = ((opcode == `JC) && (previous_instruction == alu_instruction ) && (i_cy_alu == 1'b1)) ? 1'b1 :
	                   ((opcode == `JC) && (i_Buffer1[`OPCODE_POS] == `MOV_AD) && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR) && (i_cy_alu == 1'b1)) ? 1'b1 :
	                  ((opcode == `JC) && !(i_Buffer1[`OPCODE_POS] == `MOV_AD && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR)) && (previous_instruction != alu_instruction) && (previous_previous_instruction == alu_instruction) && (i_Buffer2[`CY_POS] == 1'b1)) ? 1'b1:
	                  ((opcode == `JC) && !(i_Buffer1[`OPCODE_POS] == `MOV_AD && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR)) && (previous_instruction != alu_instruction) && (i_Buffer2[`OPCODE_POS] == `MOV_AD) && (i_Buffer2[`ADDR_OPERAND1_POS] == `PSW_ADDR) && (i_Buffer2[`CY_POS] == 1'b1)) ? 1'b1 :
					  ((opcode == `JC) && !(i_Buffer1[`OPCODE_POS] == `MOV_AD && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR)) && !(i_Buffer2[`OPCODE_POS] == `MOV_AD && (i_Buffer2[`ADDR_OPERAND1_POS] == `PSW_ADDR)) && (previous_previous_instruction != alu_instruction) && (previous_instruction != alu_instruction ) && (i_psw_rf[7] == 1'b1)) ? 1'b1 :
                      ((opcode == `JNC) && (previous_instruction == alu_instruction ) && (i_cy_alu != 1'b1)) ? 1'b1 :
                      ((opcode == `JNC) && (i_Buffer1[`OPCODE_POS] == `MOV_AD) && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR) && (i_cy_alu != 1'b1)) ? 1'b1 :
                      ((opcode == `JNC) && !(i_Buffer1[`OPCODE_POS] == `MOV_AD && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR)) && (previous_instruction != alu_instruction) && (previous_previous_instruction == alu_instruction) && (i_Buffer2[`CY_POS] != 1'b1)) ? 1'b1:
                      ((opcode == `JNC) && !(i_Buffer1[`OPCODE_POS] == `MOV_AD && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR)) && (previous_instruction != alu_instruction) && (i_Buffer2[`OPCODE_POS] == `MOV_AD) && (i_Buffer2[`ADDR_OPERAND1_POS] == `PSW_ADDR) && (i_Buffer2[`CY_POS] != 1'b1)) ? 1'b1 :
                      ((opcode == `JNC) && !(i_Buffer1[`OPCODE_POS] == `MOV_AD && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR)) && !(i_Buffer2[`OPCODE_POS] == `MOV_AD && (i_Buffer2[`ADDR_OPERAND1_POS] == `PSW_ADDR)) && (previous_previous_instruction != alu_instruction) && (previous_instruction != alu_instruction ) && (i_psw_rf[7] != 1'b1)) ? 1'b1 :
                      ((opcode == `JZ) && (previous_instruction == mov_acc_instruction) && (i_Buffer1[`OPERAND2_POS] == 8'd0)) ? 1'b1 :
					  ((opcode == `JZ) && (previous_instruction == alu_instruction) && (i_res_alu == 8'd0)) ? 1'b1 :
					  ((opcode == `JZ) && (previous_instruction == other_instruction) && (previous_previous_instruction != other_instruction) && (i_Buffer2[`OPERAND1_POS] == 8'd0)) ? 1'b1 :
					  ((opcode == `JZ) && (previous_previous_instruction == other_instruction) &&
					  (previous_instruction == other_instruction ) && (i_acc_rf == 8'd0)) ? 1'b1 :
                      ((opcode == `JNZ) && (previous_instruction == mov_acc_instruction) && (i_Buffer1[`OPERAND2_POS] != 8'd0)) ? 1'b1 :
					  ((opcode == `JNZ) && (previous_instruction == alu_instruction) && (i_res_alu != 8'd0)) ? 1'b1 :
					  ((opcode == `JNZ) && (previous_instruction == other_instruction) && (previous_previous_instruction != other_instruction) && (i_Buffer2[`OPERAND1_POS] != 8'd0)) ? 1'b1 :
					  ((opcode == `JNZ) && (previous_previous_instruction == other_instruction) &&
					  (previous_instruction == other_instruction ) && (i_acc_rf != 8'd0)) ? 1'b1 :
	                  1'b0;
	
	// Assign forward flags signal
	// 1) Chech if the previous intruction is ALU type and if yes forward the flags from ALU
	// 1) Chech if the previous previous intruction is ALU type and if yes forward the flags from Buffer 2                  
	assign o_forward_flags =  ((instruction_type_aux == alu_instruction) && (((i_Buffer1[`OPCODE_POS] == `MOV_AD) 
	                        && (i_Buffer1[`ADDR_OPERAND1_POS] == `PSW_ADDR)) || (previous_instruction == alu_instruction ))) ? 2'd1 :
	                        ((instruction_type_aux == alu_instruction) && (((i_Buffer2[`OPCODE_POS] == `MOV_AD) 
	                        && (i_Buffer2[`ADDR_OPERAND1_POS] == `PSW_ADDR)) || previous_previous_instruction == alu_instruction)) ? 2'd2 : 2'd0;               
	
	// Assign forward data signal with the logic explain above 
    assign o_forward_data_a = ((instruction_type == alu_mov_instruction) && (instruction_type_s2 == alu_mov_instruction) && (Ra_eq_Rd_exec == 1'b1)) ? 2'd2:
                            ((instruction_type == alu_mov_instruction) && (instruction_type_s3 == alu_mov_instruction) && (Ra_eq_Rd_wb == 1'b1)) ? 2'd1:
                            2'd0;
                            
    // Assign forward data signal with the logic explain above 
    assign o_forward_data_b = ((instruction_type == alu_mov_instruction && opcode != `ADD_C && opcode != `SUBB_C
                              && opcode != `ADDC_C && opcode != `ANL_C && opcode != `ORL_C && opcode != `XRL_C) 
                              && (instruction_type_s2 == alu_mov_instruction) && (Rb_eq_Rd_exec == 1'b1)) ? 3'd2:
                              ((instruction_type == alu_mov_instruction && opcode != `ADD_C && opcode != `SUBB_C
                              && opcode != `ADDC_C && opcode != `ANL_C && opcode != `ORL_C && opcode != `XRL_C) 
                              && (instruction_type_s3 == alu_mov_instruction) && (Rb_eq_Rd_wb == 1'b1)) ? 3'd1:
                            3'd0;
endmodule