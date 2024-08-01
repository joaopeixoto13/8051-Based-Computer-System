#include "IR.h"
#include "defines.h"
#include "assembler.h"
#include <stdio.h>
#include <stdlib.h>

// Initialize the array
void init_statements(struct Sstatements *self);
// Adds a statement to the array
void add_statement(struct Sstatements *self, int op_type, int op_code, int op1, int op2, enum Emisc_type misc, int n_bytes);
// Frees the resources of the array
void free_resources_statements(struct Sstatements *self);
// Prints the array
void print_statements(struct Sstatements *self);

/**
 * @brief Initializes the array
 * @param self Pointer to the array
 */
void init_statements(struct Sstatements *self)
{
    /* Initialize the function pointers */
    self->add_statement             = add_statement;
    self->free_resources_statements = free_resources_statements;
    self->print_statements          = print_statements;
    
    /* Initialize the array */
    self->statements = (struct Sstatement*)malloc(sizeof(struct Sstatement) * INITIAL_STATEMENTS_LENGTH);
    self->current_statement = 0;
    self->number_of_lines   = 1;
    self->location_counter  = 0;
    self->allocated_size    = INITIAL_STATEMENTS_LENGTH;

    for (int i = 0; i < INITIAL_STATEMENTS_LENGTH; i++)
    {
        self->statements[i].op_type     = 0;
        self->statements[i].op_code     = 0;
        self->statements[i].op1         = 0;
        self->statements[i].op2         = 0;
        self->statements[i].misc        = NO_TYPE;
        self->statements[i].line_number = 0;
        self->statements[i].local_cont  = 0;
    }
}

/**
 * @brief Adds a statement to the array
 * @param self Pointer to the array
 * @param op_type Type of the operation
 * @param op_code Code of the operation
 * @param op1 First operand
 * @param op2 Second operand
 * @param misc Miscelaneous information about the statement
 * @param n_bytes Number of bytes of the statement (in this case 2 -> 2 address processor)
 */
void add_statement(struct Sstatements *self,int op_type, int op_code, int op1, int op2, enum Emisc_type misc, int n_bytes)
{
    if (self->current_statement == self->allocated_size)
    {
        self->statements = (struct Sstatement*)realloc(self->statements, sizeof(struct Sstatement) * self->allocated_size * 2);
        self->allocated_size *= 2;
    }


    self->statements[self->current_statement].op_type     = op_type;
    self->statements[self->current_statement].op_code     = op_code;
    self->statements[self->current_statement].op1         = op1;
    self->statements[self->current_statement].op2         = op2;
    self->statements[self->current_statement].misc        = misc;
    self->statements[self->current_statement].line_number = self->number_of_lines;
    self->statements[self->current_statement].local_cont  = self->location_counter;
    
    self->current_statement++;

     if (op_type == ORG_DIRECTIVE || op_type == CSEG_DIRECTIVE)
    {
        self->location_counter = symtab.symbol_table[op2].value;        // In this case op1 is empty
    }
    else
        self->location_counter ++;          // Increment the location counter by 2 (2 address processor)
    
}

/**
 * @brief Frees the resources of the array
 * @param self Pointer to the array
 */
void free_resources_statements(struct Sstatements *self)
{
    free(self->statements);
}

/**
 * @brief Prints the array
 * @param self Pointer to the array
 */
void print_statements(struct Sstatements *self)
{
    printf("\n\n******************************************************************************" 
           "\n\t\tBegin Intemediate code:\n");
    
    for (int i = 0; i < self->current_statement; i++)
    {
        printf("Line: %03d, ", self->statements[i].line_number);
        printf("Location counter: %03d, ", self->statements[i].local_cont);
        printf("op_type: %02d, ", self->statements[i].op_type);
        printf("op_code: 0x%02x, ", self->statements[i].op_code);
        printf("op1: %03d, ", self->statements[i].op1);
        printf("op2: %03d, ", self->statements[i].op2);
        printf("misc: %d;\n", self->statements[i].misc);
    }
    printf("location_counter: %02d\n", self->location_counter);
    printf("\n\n\t\tEnd Of Intemediate code:"
           "\n******************************************************************************\n");   
}