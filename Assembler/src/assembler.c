#include "assembler.h"
#include "stdio.h"
#include "stdlib.h"

struct Ssym_table symtab;
struct Sstatements ir;

extern FILE* yyin;

/**
 * @brief Assembler initialization 
 */
int init_assembler(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Usage: %s <filename> \r \n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");

    if (yyin == NULL)
    {
        printf("Could not open file %s \r \n", argv[1]);
        return 1;
    }
    
    init_symtab(&symtab);
    init_statements(&ir);

    return 0;
}

/**
 * @brief Assembler cleanup
 */
void cleanup_assembler()
{
    symtab.free_resources_symbol_table(&symtab);
    ir.free_resources_statements(&ir);
}