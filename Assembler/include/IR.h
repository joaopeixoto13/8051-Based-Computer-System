#ifndef _IR_H_
#define _IR_H_

#define INITIAL_STATEMENTS_LENGTH 256

/**
 * @brief Enum for the miscelaneous types of the IR
 * @details This enum is used to specify information about the statement
 * 
 * Tells the second argumnet type of the statement
 * e.g MOV A, #3 -> IMEDIATE_TYPE
 * e.g MOV A, R0 -> REG_TYPE
 * e.g MOV A, 0x10 -> DIRECT_TYPE
 */
enum Emisc_type
{
    NO_TYPE,
    DIRECT_TYPE,
    DATA_TYPE,
    IMMEDIATE_TYPE,
    REG_TYPE,
    ACUMULATOR_TYPE,
    PSEUDO_OP_TYPE
};

/**
 * @brief Struct that represents a statement in the IR
 * @param op_type Type of the operation
 * @param op_code Code of the operation
 * @param op1 First operand
 * @param op2 Second operand
 * @param misc Miscelaneous information about the statement
 * @param line_number Line number of the statement
 * @param local_cont Local counter of the statement
 */
struct Sstatement
{
    int op_type;
    int op_code;
    int op1;
    int op2;
    enum Emisc_type misc;
    int line_number;
    unsigned int local_cont;
};

/**
 * @brief Struct that represents a list of statements
 * @param statements Array of statements
 * @param current_statement Current statement
 * @param location_counter Location counter
 * @param allocated_size Allocated size of the array
 * @param add_statement Function that adds a statement to the array
 * @param free_resources_statements Function that frees the resources of the array
 * @param print_statements Function that prints the array
 */
struct Sstatements
{
    struct Sstatement *statements;
    int current_statement;
    int location_counter;
    unsigned int number_of_lines;
    int allocated_size;
    void (*add_statement)(struct Sstatements *self, int op_type, int op_code, int op1, int op2, enum Emisc_type misc, int n_bytes);
    void (*free_resources_statements)(struct Sstatements *self);
    void (*print_statements)(struct Sstatements *self);
};

void init_statements(struct Sstatements *self);

#endif