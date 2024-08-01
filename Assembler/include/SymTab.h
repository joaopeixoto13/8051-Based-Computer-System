#ifndef _SYM_TAB_H_
#define _SYM_TAB_H_

#define MAX_SYMBOL_NAME_LENGTH 64 
#define MAX_HASH_TABLE_LENGTH 307
#define INITIAL_SYMBOL_TABLE_LENGTH 512
#define NULL_BUCKET 0
#define NIL 0
#define UNINITIALIZED_VALUE 0x10000

/**
 * @brief Struct that represents a symbol in the symbol table
 * @param name The name of the symbol
 * @param value The value of the symbol
 * @param link The index of the next in the chain(same hash value)
 */
struct Ssym_table_content
{
    char name[MAX_SYMBOL_NAME_LENGTH];
    int value;
    int link;
};


/**
 * @brief Struct that represents the symbol table
 * @param next_pos The pointer to the next free position in the symbol table
 * @param hash_table The hash table (array that saves the top of the chain for every hash value)
 * @param symbol_table The symbol table
 * @param allocated_size The allocated size of the symbol table
 * @param add_symbol The function that adds a symbol to the symbol table
 * @param free_resources_symbol_table The function that frees the resources of the symbol table
 * @param print_symbol_table The function that prints the symbol table
 */
struct Ssym_table
{
    unsigned int next_pos;
    unsigned int hash_table[MAX_HASH_TABLE_LENGTH];
    struct Ssym_table_content* symbol_table;
    unsigned int allocated_size;
    unsigned int (*add_symbol)(struct Ssym_table* self, char* name);
    void (*free_resources_symbol_table)(struct Ssym_table* self);
    void (*print_symbol_table)(struct Ssym_table* self);
};

// The function that initializes the symbol table
void init_symtab(struct Ssym_table* self);

#endif