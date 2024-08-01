#include "IR.h"
#include "SymTab.h"
#include "defines.h"
#include "pass2loop.h"
#include <stdio.h>

extern struct Ssym_table symtab;
extern struct Sstatements ir;

/*
* @brief Converts a char to binary
* @param c: char to be converted
* @param binary: binary string
* @param size: size of the binary string
*/
void char_to_binary(int c, char *binary, int size)
{
    int i;
    for (i = size - 1; i >= 0; --i)
    {
        binary[size - 1 - i] = (c & (1 << i)) ? '1' : '0';
    }
}

/*
* @brief Opreation routine
* @param s: statement to be converted
* @param file: output file
*/
int OP_routine(struct Sstatement *s, FILE *file)
{
    /*
    * @brief Each line of the output file has the following format:
    *   XXXXXXXXXXXXXXXXYYYYYYYYZZZZZZZZ
    * Where:
    *   XXXXXXXXXXXXXXXX: 16 bits of absolute address
    *   YYYYYYYY: 8 bits opcode
    *   ZZZZZZZZ: 8 bits operand
    */
    char binary[33] = {0};
    char *pbinary = binary;

    // Update the 16 bits of absolute address
    char_to_binary(s->local_cont, pbinary, 16);
    pbinary += 16;

    // Update the 8 bits of opcode
    char_to_binary(s->op_code, pbinary, 8);

    // Increment the pointer to the second byte
    pbinary += 8;

    // Checks if the immediate value is valid
    if((s->misc == IMMEDIATE_TYPE) && (s->op2 >= 256))
        return ERROR_IMMEDIATE;

    // Checks if the operands are valid
    if((symtab.symbol_table[s->op1].value == ERROR_NUMBER) || (symtab.symbol_table[s->op2].value == ERROR_NUMBER))
        return ERROR_INVALID_OPERAND;

    switch(s->op_type)
    {
        case JC_INSTRUCTION:
        case JNC_INSTRUCTION:
        case JZ_INSTRUCTION:
        case JNZ_INSTRUCTION:
        {
            char_to_binary((symtab.symbol_table[s->op2].value), pbinary, 8);
        }break;
       
        /*
        * If the instruction is a RETI instruction:
        * Fill the second byte with zeros
        */
        case RETI_INSTRUCTION:
        {
            char_to_binary(0, pbinary, 8);
        }break;
        /*
        * If the instruction is a MOV instruction:
        * MOV direct, A: The operand value is found in the symbol table at the index of the operand one
        * MOV Rn, A: The operand value is found in the symbol table at the index of the operand one
        * Other cases: The operand value is found in the symbol table at the index of the operand two
        */
        case MOV_INSTRUCTION:
        {
            switch(s->op_code)
            {
                case MOV_AD_OPCODE:
                case MOV_AR_OPCODE:
                    char_to_binary(symtab.symbol_table[s->op1].value, pbinary, 8);
                    break;
                default:
                    char_to_binary(symtab.symbol_table[s->op2].value, pbinary, 8);
            }
        } break;
        default:
        {
            char_to_binary(symtab.symbol_table[s->op2].value, pbinary, 8);
        }break;
    }

    // New line
    binary[32] = '\n';

    // Write the binary string to the output file
    fwrite(binary, sizeof(char), 33, file);

    return SUCCESS;
}

/*
* @brief Directive routine
* @param s: statement to be converted
* @param file: output file
*/
int directive_routine(struct Sstatement *s, FILE *file)
{
    switch(s->op_type)
    {
        case ORG_DIRECTIVE:
        {
            if(s->local_cont != 0 || symtab.symbol_table[s->op2].value < 0 || symtab.symbol_table[s->op2].value > MEMORY_SIZE)
                return ERROR_ORG;
        }break;

        case CSEG_DIRECTIVE:
        {
            if(symtab.symbol_table[s->op2].value < 0 || symtab.symbol_table[s->op2].value > MEMORY_SIZE) 
                return ERROR_CSEG;
        }break;
    }
    return SUCCESS;
}

/*
* @brief Pass 2 loop
*/
int pass2loop(void)
{
    // Array of function pointers
    int (*callbacks[2])(struct Sstatement *, FILE *);
    // Assign the function pointers
    callbacks[0] = OP_routine;
    callbacks[1] = directive_routine;
    // Get the size of the IR
    size_t size = ir.current_statement;

    // Check if the code has exceeded the memory size
    if (size > MEMORY_SIZE) {
        printf("ERROR: Code has exceeded Memory Size.\n");
        return 1;
    }
        
    // Open output file
    FILE *file = fopen("output.bin", "wb"); 
    if (file == NULL)
    {
        printf("Failed to open file for writing.\n");
        return 1;
    }

    // For each statement generate the binary code
    for (int i = 0; i < size; i++)
    {
        // Checks if instruction is valid
        if ((ir.statements[i].op_type > LAST_DIRECTIVE) || (ir.statements[i].op_type <= 0)){
            printf("In line %d: Error invalid instruction \n", ir.statements[i].line_number);
            return 1;
        }

        /*
        * Calls the specific routine for operation or directive
        * 0 => Normal instruction
        * 1 => Directive instruction
        */
        int return_value = callbacks[(ir.statements[i].op_type <= LAST_INSTRUCTION) ? 0 : 1](ir.statements + i, file);
        if (return_value != SUCCESS)
        {
            switch(return_value)
            {
                case ERROR_IMMEDIATE:
                    printf("In line %d: Error immediate has wrong value \n", ir.statements[i].line_number);
                    break;
                case ERROR_INVALID_INSTRUCTION:
                    printf("In line %d: Error invalid instruction \n", ir.statements[i].line_number);
                    break;
                case ERROR_INVALID_OPERAND:
                    printf("In line %d: Error invalid operand \n", ir.statements[i].line_number);
                    break;
                case ERROR_ORG:
                    printf("In line %d: Error instruction ORG must be the first instruction, only be used once and must be inside 0 and 4096\n", ir.statements[i].line_number);
                    break;
                case ERROR_CSEG:
                    printf("In line %d: Error instruction CSEG, value must be inside 0 and 4096\n", ir.statements[i].line_number);
                    break;
                default:
                        printf("ERROR: Unknown error\n");
                    break;
            }
            // Close output file
            fclose(file); 
            return 1;
        }   
    }

    // Close output file
    fclose(file); 
    return 0;
}
