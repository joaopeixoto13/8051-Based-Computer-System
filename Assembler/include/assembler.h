#include "IR.h"
#include "SymTab.h"
#include "defines.h"

/**
 * @brief Symbol table
 */
extern struct Ssym_table symtab;

/**
 * @brief Intermediate representation
 */
extern struct Sstatements ir;

/**
 * @brief Assembler initialization
 */
int init_assembler(int argc, char *argv[]);  

/**
 * @brief Assembler cleanup
 */
void cleanup_assembler();