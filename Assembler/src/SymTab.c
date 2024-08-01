#include "SymTab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Initialize the symbol table
void init_symtab(struct Ssym_table* self);
// Adds a symbol to the symbol table
unsigned int add_symbol(struct Ssym_table* self,char* name);
// Inserts a symbol in the symbol table
unsigned int insert_symbol(struct Ssym_table* self,char* name, int hash_value);
// Calculates the hash value of a symbol
unsigned int hash(struct Ssym_table* self,char *name);
// Frees the resources of the symbol table
void free_resources_symbol_table(struct Ssym_table* self);
// Prints the symbol table
void print_symbol_table(struct Ssym_table* self);

/**
 * @brief Initializes the symbol table
 * @param self The symbol table
 */
void init_symtab(struct Ssym_table* self)
{
    int pos; 

    /* Initialize the methods */
    self->add_symbol = add_symbol;
    self->free_resources_symbol_table = free_resources_symbol_table;
    self->print_symbol_table = print_symbol_table;

    /* Initialize the hash table */
    for (unsigned int i = 0; i < MAX_HASH_TABLE_LENGTH; i++)
        self->hash_table[i] = NULL_BUCKET;
    /* Initialize the symbol table */
    self->next_pos = 0;
    self->symbol_table = (struct Ssym_table_content*)malloc(sizeof(struct Ssym_table_content) * INITIAL_SYMBOL_TABLE_LENGTH);
    self->allocated_size = INITIAL_SYMBOL_TABLE_LENGTH;
    pos = add_symbol(self,"0");
    self->symbol_table[pos].value = NIL;

}

/**
 * @brief Adds a symbol to the symbol table
 * @param self The symbol table
 * @param name The name of the symbol
 * @return The index of the symbol in the symbol table (search for the symbol in the symbol table)
 */
unsigned int add_symbol(struct Ssym_table* self,char* name)
{
    /* Calculate the hash value */
    unsigned int hash_value = hash(self,name);
    unsigned int pos = self->hash_table[hash_value];

    /* Check if the symbol is already in the symbol table */
    while (pos != NIL)
    {
        /* If exists a symbol with the same name, return the position */
        if (strcmp(self->symbol_table[pos].name, name) == 0)
            return pos;
        /* Iterate all over the list */
        pos = self->symbol_table[pos].link;
    }

    /* Insert the symbol in the symbol table */
    return insert_symbol(self,name, hash_value);
}

/**
 * @brief Inserts a symbol in the symbol table
 * @param self The symbol table
 * @param name The name of the symbol
 * @param hash_value The hash value of the symbol
 * @return The index of the symbol in the symbol table
 */
unsigned int insert_symbol(struct Ssym_table* self,char* name, int hash_value)
{
    /* Save the next available position */
    unsigned int pos = self->next_pos;

    /* Check if the symbol table is full */
    if (pos == self->allocated_size)
    {
        self->allocated_size *= 2;
        self->symbol_table = (struct Ssym_table_content*)realloc(self->symbol_table, sizeof(struct Ssym_table_content) * self->allocated_size);
    }

    /* Insert the symbol in the symbol table */

    /* Update the name */
    strcpy(self->symbol_table[pos].name, name);
    /* Update the link value with the index of the top hash table on the 'hash_value' position */
    self->symbol_table[pos].link = self->hash_table[hash_value];
     /* Update the top of the hash table */
    self->hash_table[hash_value] = pos;
    /* Increment the next available position */
    self->next_pos++;
    /* Initialize the value with a number never readed by the 8051 */
    self->symbol_table[pos].value = UNINITIALIZED_VALUE;

    return pos;
}

/**
 * @brief Calculates the hash value of a symbol
 * @param self The symbol table
 * @param name The name of the symbol
 * @return The hash value of the symbol
 */
unsigned int hash(struct Ssym_table* self,char *name)
{
    unsigned int hash_value = 0;
    int i = 0;

    while (name[i] != '\0')
        hash_value = hash_value*31 + name[i++];

    return (unsigned int)(hash_value % MAX_HASH_TABLE_LENGTH);
}

/**
 * @brief Frees the resources of the symbol table
 * @param self The symbol table
 */
void free_resources_symbol_table(struct Ssym_table* self)
{
    free(self->symbol_table);
}

/**
 * @brief Prints the symbol table
 * @param self The symbol table
 */
void print_symbol_table(struct Ssym_table* self)
{
    printf("\n\n******************************************************************************\n"
           "\t\tBegin Symbol Table:\n");
    for (int i = 0; i < self->next_pos; i++)
    {
        printf("\tindex: %03d, name: %5s, value: 0x%03x \n", i, self->symbol_table[i].name, self->symbol_table[i].value);
    }
    printf("\n\n\t\tEnd Of Symbol Table:\n"
           "******************************************************************************\n");
}