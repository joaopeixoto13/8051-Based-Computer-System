#include "stdio.h"
#include "y.tab.h"
#include "assembler.h"
#include "stdlib.h"
#include "defines.h"
#include "pass2loop.h"

char error_end = 0;

int main(int argc, char *argv[]) 
{
    /**
     * @brief Frontend
    */

    // Init the simbol table and the intemediat code
    init_assembler(argc, argv);
    
    // Init the lexical and parser analyzer
    if( yyparse() == 1 || error_end == 1 )
    {
        cleanup_assembler();
        return 1;
    }

    /**
     * @brief Backend
    */
    
    int var = pass2loop();
    if(var == 1){
        cleanup_assembler();
        remove("output.bin");
        return 1;
    }

    // Print the symbol table:
    symtab.print_symbol_table(&symtab);
    
    // Print statements:
    ir.print_statements(&ir);
    
    // Cleanup
    cleanup_assembler();
    return 0;
}