#ifndef _DEFINES_H_
#define _DEFINES_H_

//0pcode [4:0]
#define ACALL_OPCODE 	0x11 // absolute call
#define AJMP_OPCODE 	0x01 // absolute jump

// 0pcode [7:3]
#define INC_R_OPCODE 	0x08 // increment Rn
#define DEC_R_OPCODE 	0x18 // decrement reg Rn=Rn-1
#define ADD_R_OPCODE 	0x28 // add A=A+Rx
#define ADDC_R_OPCODE 	0x38 // add A=A+Rx+c
#define ORL_R_OPCODE 	0x48 // or A=A or Rn
#define ANL_R_OPCODE 	0x58 // and A=A^Rx
#define XRL_R_OPCODE 	0x68 // XOR A=A XOR Rn
#define MOV_CR_OPCODE 	0x78 // move Rn=constant
#define MOV_RD_OPCODE 	0x88 // move (direct)=Rn
#define SUBB_R_OPCODE 	0x98 // substract with borrow  A=A-c-Rn
#define MOV_DR_OPCODE 	0xA8 // move Rn=(direct)
#define CJNE_R_OPCODE 	0xB8 // compare and jump if not equal; Rx<>constant
#define XCH_R_OPCODE 	0xC8 // exchange A<->Rn
#define DJNZ_R_OPCODE 	0xD8 // decrement and jump if not zero
#define MOV_R_OPCODE 	0xE8 // move A=Rn
#define MOV_AR_OPCODE 	0xF8 // move Rn=A

// Opcode [7:1]
#define ADD_I_OPCODE    0x20 // add A=A+@Ri
#define ADDC_I_OPCODE   0x30 // add A=A+@Ri+c
#define ANL_I_OPCODE    0x56// and A=A^@Ri
#define CJNE_I_OPCODE   0xB0 // compare and jump if not equal; @Ri<>constant
#define DEC_I_OPCODE    0x10 // decrement indirect @Ri=@Ri-1
#define INC_I_OPCODE    0x00 // increment @Ri
#define MOV_I_OPCODE    0xE0 // move A=@Ri
#define MOV_ID_OPCODE   0x80 // move (direct)=@Ri
#define MOV_AI_OPCODE   0xF0 // move @Ri=A
#define MOV_DI_OPCODE   0xA0 // move @Ri=(direct)
#define MOV_CI_OPCODE   0x70 // move @Ri=constant
#define MOVX_IA_OPCODE  0xE2 // move A=(@Ri)
#define MOVX_AI_OPCODE  0xF2 // move (@Ri)=A
#define ORL_I_OPCODE    0x40 // or A=A or @Ri
#define SUBB_I_OPCODE   0x90 // substract with borrow  A=A-c-@Ri
#define XCH_I_OPCODE    0xC0 // exchange A<->@Ri
#define XCHD_OPCODE     0xD0 // exchange digit A<->Ri
#define XRL_I_OPCODE    0x67 // XOR A=A XOR @Ri

// //0pcode [7:0]
#define ADD_D_OPCODE    0x25 // add A=A+(direct)
#define ADD_C_OPCODE    0x24 // add A=A+constant
#define ADDC_D_OPCODE   0x35 // add with carry A=A+(direct)+c
#define ADDC_C_OPCODE   0x34 // add with carry A=A+constant+c
#define ANL_D_OPCODE    0x55 // and A=A^(direct)
#define ANL_C_OPCODE    0x54 // and A=A^constant
#define ANL_AD_OPCODE   0x52 // and (direct)=(direct)^A
#define ANL_DC_OPCODE   0x53 // and (direct)=(direct)^constant
#define ANL_B_OPCODE    0x82 // and c=c^bit
#define ANL_NB_OPCODE   0xB0 // and c=c^!bit
#define CJNE_D_OPCODE   0xB5 // compare and jump if not equal; a<>(direct)
#define CJNE_C_OPCODE   0xB4 // compare and jump if not equal; a<>constant
#define CLR_A_OPCODE    0xE4 // clear accumulator
#define CLR_C_OPCODE    0xC3 // clear carry
#define CLR_B_OPCODE    0xC2 // clear bit
#define CPL_A_OPCODE    0xF4 // complement accumulator
#define CPL_C_OPCODE    0xB3 // complement carry
#define CPL_B_OPCODE    0xB2 // complement bit
#define DA_OPCODE       0xD4 // decimal adjust (A)
#define DEC_A_OPCODE    0x14 // decrement accumulator a=a-1
#define DEC_D_OPCODE    0x15 // decrement direct (direct)=(direct)-1
#define DIV_OPCODE      0x84 // divide
#define DJNZ_D_OPCODE   0xD5 // decrement and jump if not zero (direct)
#define INC_A_OPCODE    0x04 // increment accumulator
#define INC_D_OPCODE    0x05 // increment (direct)
#define INC_DP_OPCODE   0xA3 // increment data pointer
#define JB_OPCODE       0x20 // jump if bit set
#define JBC_OPCODE      0x10 // jump if bit set and clear bit
#define JC_OPCODE       0x40 // jump if carry is set
#define JMP_D_OPCODE    0x73 // jump indirect
#define JNB_OPCODE      0x30 // jump if bit not set
#define JNC_OPCODE      0x50 // jump if carry not set
#define JNZ_OPCODE      0x70 // jump if accumulator not zero
#define JZ_OPCODE       0x60 // jump if accumulator zero
#define LCALL_OPCODE    0x12 // long call
#define LJMP_OPCODE     0x02 // long jump
#define MOV_D_OPCODE    0xE5 // move A=(direct)
#define MOV_C_OPCODE    0x74 // move A=constant
#define MOV_AD_OPCODE   0xF5 // move (direct)=A
#define MOV_DD_OPCODE   0x85 // move (direct)=(direct)
#define MOV_CD_OPCODE   0x75 // move (direct)=constant
#define MOV_BC_OPCODE   0xA2 // move c=bit
#define MOV_CB_OPCODE   0x92 // move bit=c
#define MOV_DP_OPCODE   0x90 // move dptr=constant(16 bit)
#define MOVC_DP_OPCODE  0x93 // move A=dptr+A
#define MOVC_PC_OPCODE  0x83 // move A=pc+A
#define MOVX_PA_OPCODE  0xE0 // move A=(dptr)
#define MOVX_AP_OPCODE  0xF0 // move (dptr)=A
#define MUL_OPCODE      0xA4 // multiply a*b
#define NOP_OPCODE      0x00 // no operation
#define ORL_D_OPCODE    0x45 // or A=A or (direct)
#define ORL_C_OPCODE    0x44 // or A=A or constant
#define ORL_AD_OPCODE   0x42 // or (direct)=(direct) or A
#define ORL_CD_OPCODE   0x43 // or (direct)=(direct) or constant
#define ORL_B_OPCODE    0x71 // or c = c or bit
#define ORL_NB_OPCODE   0xA0 // or c = c or !bit
#define POP_OPCODE      0xD0 // stack pop
#define PUSH_OPCODE     0xC0 // stack push
#define RET_OPCODE      0x22 // return from subrutine
#define RETI_OPCODE     0x32 // return from interrupt
#define RL_OPCODE       0x23 // rotate left
#define RLC_OPCODE      0x33 // rotate left thrugh carry
#define RR_OPCODE       0x03 // rotate right
#define RRC_OPCODE      0x13 // rotate right thrugh carry
#define SETB_C_OPCODE   0xD3 // set carry
#define SETB_B_OPCODE   0xD2 // set bit
#define SJMP_OPCODE     0x80 // short jump
#define SUBB_D_OPCODE   0x95 // substract with borrow  A=A-c-(direct)
#define SUBB_C_OPCODE   0x94 // substract with borrow  A=A-c-constant
#define SWAP_OPCODE     0xC4 // swap A(0-3) <-> A(4-7)
#define XCH_D_OPCODE    0xC5 // exchange A<->(direct)
#define XRL_D_OPCODE    0x65 // XOR A=A XOR (direct)
#define XRL_C_OPCODE    0x64 // XOR A=A XOR constant
#define XRL_AD_OPCODE   0x62 // XOR (direct)=(direct) XOR A
#define XRL_CD_OPCODE   0x63 // XOR (direct)=(direct) XOR constant

#define ADD_INSTRUCTION     1
#define ADDC_INSTRUCTION    2
#define SUBB_INSTRUCTION    3
#define ANL_INSTRUCTION     4
#define ORL_INSTRUCTION     5
#define XRL_INSTRUCTION     6
#define MOV_INSTRUCTION     7
#define RETI_INSTRUCTION    8
#define JC_INSTRUCTION      9
#define JNC_INSTRUCTION     10
#define JZ_INSTRUCTION      11
#define JNZ_INSTRUCTION     12
#define ORG_DIRECTIVE       13
#define END_DIRECTIVE       14
#define EQU_DIRECTIVE       15
#define DATA_DIRECTIVE      16
#define CSEG_DIRECTIVE      17

#define LAST_INSTRUCTION    12  // Used in the instruction check in pass 2 (MUST BE EQUAL TO LAST INSTRUCTION VALUE IN OP_TYPE TABLE) 
#define LAST_DIRECTIVE      17  // Used in the direct check in pass 2 (MUST BE EQUAL TO THE LAST DIRECTIVE VALUE IN OP_TYPE TABLE)

#define NONE 0
#define ERROR_IMMEDIATE -1
#define ERROR_INVALID_OPERAND -2
#define ERROR_INVALID_INSTRUCTION -3
#define ERROR_ORG -4
#define ERROR_CSEG -5

#define SUCCESS 0
#define ERROR_NUMBER 65536

#define MEMORY_SIZE 4096

#endif
