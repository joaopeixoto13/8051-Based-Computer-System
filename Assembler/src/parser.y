%{
    #include <stdio.h>
    #include "assembler.h"
    
    int yylex(void);
    void yyerror(char *);
%}

%token ADD ADDC SUBB ANL ORL XRL MOV RETI JC JNC JZ JNZ ORG END EQU DATA CSEG_AT
%token A REG IDENTIFIER NUMBER

%%
program : program stmt
        | stmt
        |
        ;

stmt :   add_stmt | addc_stmt | subb_stmt | anl_stmt | orl_stmt | xrl_stmt 
        | mov_stmt | reti_stmt | branch_stmt 
        | org_stmt | cseg_stmt | end_stmt | equ_stmt | data_stmt | label
        ;

add_stmt : ADD A',' NUMBER    { ir.add_statement(&ir, ADD_INSTRUCTION, ADD_D_OPCODE, $2, $4, DIRECT_TYPE, 2 ); }
         | ADD A',' IDENTIFIER{ ir.add_statement(&ir, ADD_INSTRUCTION, ADD_D_OPCODE, $2, $4, DATA_TYPE, 2 ); }
         | ADD A',' '#'NUMBER { ir.add_statement(&ir, ADD_INSTRUCTION, ADD_C_OPCODE, $2, $5, IMMEDIATE_TYPE, 2 ); }
         | ADD A',' REG       { ir.add_statement(&ir, ADD_INSTRUCTION, ADD_R_OPCODE, $2, $4, REG_TYPE, 2 ); }
         ;

addc_stmt : ADDC A',' NUMBER    { ir.add_statement(&ir, ADDC_INSTRUCTION, ADDC_D_OPCODE, $2, $4, DIRECT_TYPE, 2 ); }
          | ADDC A',' IDENTIFIER{ ir.add_statement(&ir, ADDC_INSTRUCTION, ADDC_D_OPCODE, $2, $4, DATA_TYPE, 2 ); }
          | ADDC A',' '#'NUMBER { ir.add_statement(&ir, ADDC_INSTRUCTION, ADDC_C_OPCODE, $2, $5, IMMEDIATE_TYPE, 2 ); }
          | ADDC A',' REG       { ir.add_statement(&ir, ADDC_INSTRUCTION, ADDC_R_OPCODE, $2, $4, REG_TYPE, 2 ); }
          ;

subb_stmt : SUBB A',' NUMBER    { ir.add_statement(&ir, SUBB_INSTRUCTION, SUBB_D_OPCODE, $2, $4, DIRECT_TYPE, 2 ); }
          | SUBB A',' IDENTIFIER{ ir.add_statement(&ir, SUBB_INSTRUCTION, SUBB_D_OPCODE, $2, $4, DATA_TYPE, 2 ); }
          | SUBB A',' '#'NUMBER { ir.add_statement(&ir, SUBB_INSTRUCTION, SUBB_C_OPCODE, $2, $5, IMMEDIATE_TYPE, 2 ); }
          | SUBB A',' REG       { ir.add_statement(&ir, SUBB_INSTRUCTION, SUBB_R_OPCODE, $2, $4, REG_TYPE, 2 ); }
          ;

anl_stmt : ANL A',' NUMBER    { ir.add_statement(&ir, ANL_INSTRUCTION, ANL_D_OPCODE, $2, $4, DIRECT_TYPE, 2 ); }
         | ANL A',' IDENTIFIER{ ir.add_statement(&ir, ANL_INSTRUCTION, ANL_D_OPCODE, $2, $4, DATA_TYPE, 2 ); }
         | ANL A',' '#'NUMBER { ir.add_statement(&ir, ANL_INSTRUCTION, ANL_C_OPCODE, $2, $5, IMMEDIATE_TYPE, 2 ); }
         | ANL A',' REG       { ir.add_statement(&ir, ANL_INSTRUCTION, ANL_R_OPCODE, $2, $4, REG_TYPE, 2 ); }
         ;

orl_stmt : ORL A',' NUMBER    { ir.add_statement(&ir, ORL_INSTRUCTION, ORL_D_OPCODE, $2, $4, DIRECT_TYPE, 2 ); }
         | ORL A',' IDENTIFIER{ ir.add_statement(&ir, ORL_INSTRUCTION, ORL_D_OPCODE, $2, $4, DATA_TYPE, 2 ); }
         | ORL A',' '#'NUMBER { ir.add_statement(&ir, ORL_INSTRUCTION, ORL_C_OPCODE, $2, $5, IMMEDIATE_TYPE, 2 ); }
         | ORL A',' REG       { ir.add_statement(&ir, ORL_INSTRUCTION, ORL_R_OPCODE, $2, $4, REG_TYPE, 2 ); }
         ;

xrl_stmt : XRL A',' NUMBER    { ir.add_statement(&ir, XRL_INSTRUCTION, XRL_D_OPCODE, $2, $4, DIRECT_TYPE, 2 ); }
         | XRL A',' IDENTIFIER{ ir.add_statement(&ir, XRL_INSTRUCTION, XRL_D_OPCODE, $2, $4, DATA_TYPE, 2 ); }
         | XRL A',' '#'NUMBER { ir.add_statement(&ir, XRL_INSTRUCTION, XRL_C_OPCODE, $2, $5, IMMEDIATE_TYPE, 2 ); }
         | XRL A',' REG       { ir.add_statement(&ir, XRL_INSTRUCTION, XRL_R_OPCODE, $2, $4, REG_TYPE, 2 ); }
         ;

mov_stmt : MOV A',' NUMBER          { ir.add_statement(&ir, MOV_INSTRUCTION, MOV_D_OPCODE, $2, $4, DIRECT_TYPE, 2 ); }
         | MOV A',' IDENTIFIER      { ir.add_statement(&ir, MOV_INSTRUCTION, MOV_D_OPCODE, $2, $4, DATA_TYPE, 2 ); }
         | MOV A',' '#'NUMBER       { ir.add_statement(&ir, MOV_INSTRUCTION, MOV_C_OPCODE, $2, $5, IMMEDIATE_TYPE, 2 ); }
         | MOV A',' REG             { ir.add_statement(&ir, MOV_INSTRUCTION, MOV_R_OPCODE, $2, $4, REG_TYPE, 2 ); }
         | MOV NUMBER',' A          { ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, $4, DIRECT_TYPE, 2 ); }
         | MOV IDENTIFIER',' A      { ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, $4, DATA_TYPE, 2 ); }
         | MOV REG',' A             { ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AR_OPCODE, $2, $4, DIRECT_TYPE, 2 );}

         // MOV EXPANSES:

            | MOV IDENTIFIER',' IDENTIFIER{ if ($2 == $4) 
                                        printf("Warning: line %d MOV instruction ignored\n",ir.number_of_lines );
                                    else{
                                        unsigned int pos = symtab.add_symbol(&symtab, "A");
                                        symtab.symbol_table[pos].value = 0xE0;
                                        ir.add_statement(&ir, MOV_INSTRUCTION, MOV_D_OPCODE, pos, $4, DATA_TYPE, 2 );
                                        ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, pos, DATA_TYPE, 2 );
                                    }
                                }

            | MOV IDENTIFIER',' REG{ 
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_R_OPCODE, pos, $4, REG_TYPE, 2 );
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, pos, DATA_TYPE, 2 );
                                }
                                
            | MOV IDENTIFIER',' '#'NUMBER{ 
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_C_OPCODE, pos, $5, IMMEDIATE_TYPE, 2 );
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, pos, DATA_TYPE, 2 );
                                }

            | MOV IDENTIFIER',' NUMBER{  
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_D_OPCODE, pos, $4, DIRECT_TYPE, 2 );
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, pos, DATA_TYPE, 2 );
                                }

            | MOV NUMBER',' NUMBER{ if ($2 == $4) 
                                        printf("Warning: line %d MOV instruction ignored\n", ir.number_of_lines );
                                    else{  
                                        unsigned int pos = symtab.add_symbol(&symtab, "A");
                                        symtab.symbol_table[pos].value = 0xE0;
                                        ir.add_statement(&ir, MOV_INSTRUCTION, MOV_D_OPCODE, pos, $4, DIRECT_TYPE, 2 );
                                        ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, pos, DIRECT_TYPE, 2 );
                                    }
                                }

            | MOV NUMBER',' REG{ 
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_R_OPCODE, pos, $4, REG_TYPE, 2 );
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, pos, DIRECT_TYPE, 2 );
                                }
                                
            | MOV NUMBER',' '#'NUMBER{ 
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_C_OPCODE, pos, $5, IMMEDIATE_TYPE, 2 );
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, pos, DIRECT_TYPE, 2 );
                                }

            | MOV NUMBER',' IDENTIFIER{ 
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_D_OPCODE, pos, $4, DATA_TYPE, 2 );
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AD_OPCODE, $2, pos, DIRECT_TYPE, 2 );
                                }

            | MOV REG',' REG    {   if ($2 == $4) 
                                        printf("Warning: line %d MOV instruction ignored\n", ir.number_of_lines );
                                    else{
                                        unsigned int pos = symtab.add_symbol(&symtab, "A");
                                        symtab.symbol_table[pos].value = 0xE0;
                                        ir.add_statement(&ir, MOV_INSTRUCTION, MOV_R_OPCODE, pos, $4, REG_TYPE, 2 );
                                        ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AR_OPCODE, $2, pos, DIRECT_TYPE, 2 );
                                    }
                                }

            | MOV REG',' '#'NUMBER {
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_C_OPCODE, pos, $5, DIRECT_TYPE, 2);
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AR_OPCODE, $2, pos, REG_TYPE, 2);
                                }

            | MOV REG',' NUMBER {
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_D_OPCODE, pos, $4, DIRECT_TYPE, 2);
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AR_OPCODE, $2, pos, REG_TYPE, 2);
                                }       
            
            | MOV REG',' IDENTIFIER    {
                                    unsigned int pos = symtab.add_symbol(&symtab, "A");
                                    symtab.symbol_table[pos].value = 0xE0;
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_D_OPCODE, pos, $4, DATA_TYPE, 2);
                                    ir.add_statement(&ir, MOV_INSTRUCTION, MOV_AR_OPCODE, $2, pos, REG_TYPE, 2);
                                } 
         ;

reti_stmt : RETI { ir.add_statement(&ir, RETI_INSTRUCTION, RETI_OPCODE, NONE, NONE, NO_TYPE, 2 ); }

branch_stmt : JC IDENTIFIER     { ir.add_statement(&ir, JC_INSTRUCTION,  JC_OPCODE,  NONE, $2, DATA_TYPE, 2 ); }
            | JNC IDENTIFIER    { ir.add_statement(&ir, JNC_INSTRUCTION, JNC_OPCODE, NONE, $2, DATA_TYPE, 2 ); }
            | JZ IDENTIFIER     { ir.add_statement(&ir, JZ_INSTRUCTION,  JZ_OPCODE,  NONE, $2, DATA_TYPE, 2 ); }
            | JNZ IDENTIFIER    { ir.add_statement(&ir, JNZ_INSTRUCTION, JNZ_OPCODE, NONE, $2, DATA_TYPE, 2 ); }
            
org_stmt : ORG NUMBER    { ir.add_statement(&ir, ORG_DIRECTIVE, NONE, NONE, $2, PSEUDO_OP_TYPE, 2 ); }

cseg_stmt : CSEG_AT NUMBER    { ir.add_statement(&ir, CSEG_DIRECTIVE, NONE, NONE, $2, PSEUDO_OP_TYPE, 2 );}
 
end_stmt : END { return 0;  }

equ_stmt : IDENTIFIER EQU equ_term { 
                                                     
                                    if(symtab.symbol_table[$1].value != 65536)
                                     {
                                         printf("In line %d : Error Constant redefinition\n", ir.number_of_lines );
                                         return 1;
                                     }
                                     symtab.symbol_table[$1].value = $3; 
                                    }

data_stmt : IDENTIFIER DATA NUMBER { 
                                     
                                    if(symtab.symbol_table[$3].value < 0 || symtab.symbol_table[$3].value > 255)
                                    {
                                        printf("In line %d: Error Data value out of range: %s", ir.number_of_lines , symtab.symbol_table[$1].name);
                                        return 1;
                                    }
                                        symtab.symbol_table[$1].value = symtab.symbol_table[$3].value;
                                    }



equ_term : REG      { $$ = $1;  }
         | term     { $$ = $1;  }

term : term '+' NUMBER   { $$ = $1+symtab.symbol_table[$3].value ; }
     | term '-' NUMBER   { $$ = $1-symtab.symbol_table[$3].value ; }
     | NUMBER            { $$ = symtab.symbol_table[$1].value; }



label : IDENTIFIER ':' { 
                         if(symtab.symbol_table[$1].value != 65536)
                         {
                             printf("In lime %d : Error Label redefinition\n", ir.number_of_lines );
                             return 1;
                         }
                         symtab.symbol_table[$1].value= ir.location_counter;
                       }
%%

void yyerror(char *s)
{
    fprintf(stderr, "Line number %d :%s \n", ir.number_of_lines ,s);
}
