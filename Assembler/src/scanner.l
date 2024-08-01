%{
    #include <stdio.h>
    #include "y.tab.h"
    #include "assembler.h"

    extern char error_end; 
    char error_msg[100];
    void yyerror(char *);
%}  

%%

"ADD"   {
            yylval = NONE;
            return ADD;
        }

"ADDC"  {
            yylval = NONE;
            return ADDC;
        }

"SUBB"  {
            yylval = NONE;
            return SUBB;
        }

"ANL"   {
            yylval = NONE;
            return ANL;
        }

"ORL"   {
            yylval = NONE;
            return ORL;
        }

"XRL"   {
            yylval = NONE;
            return XRL;
        }

"MOV"   {
            yylval = NONE;
            return MOV;
        }

"RETI"  {
            yylval = NONE;
            return RETI;
        }

"JC"    {
            yylval = NONE;
            return JC;
        }

"JNC"   {
            yylval = NONE;
            return JNC;
        }

"JZ"    {
            yylval = NONE;
            return JZ;
        }

"JNZ"   {
            yylval = NONE;
            return JNZ;
        }

"ORG"   {
            yylval = NONE;
            return ORG;
        }

"CSEG_AT" {
            yylval = NONE;
            return CSEG_AT;
        }

"END"   {
            yylval = NONE;
            ir.number_of_lines++;
            return END;
        }

"EQU"   {
            yylval = NONE;
            return EQU;
        }

"DATA"  {
            yylval = NONE;
            return DATA;
        }  

"A"     {
            yylval = symtab.add_symbol(&symtab, yytext);
            symtab.symbol_table[yylval].value = 0xE0;
            return A;
        }

R[0-7]  {

            yylval = symtab.add_symbol(&symtab, yytext);
            sscanf(yytext, "R%d", &symtab.symbol_table[yylval].value);
            return REG;    
        }

"0"[x][0-9A-F]+   {
            yylval = symtab.add_symbol(&symtab, yytext);
            sscanf(yytext, "0x%x", &symtab.symbol_table[yylval].value);
            return NUMBER;
        }

[0-9]+  {
            yylval = symtab.add_symbol(&symtab, yytext);
            sscanf(yytext, "%d", &symtab.symbol_table[yylval].value);
            return NUMBER;
        }

(_|[A-Z])([A-Z]|[0-9]|_)* {
            yylval = symtab.add_symbol(&symtab, yytext);
            return IDENTIFIER;
        }

[,+-:#]  {
            return *yytext;
        } 

[ \t] { };

[ \n] { ir.number_of_lines++; };


"//".*  ;


.       {
            sprintf(error_msg, "Error: Unknown token %s\n", yytext);
            yyerror(error_msg);
        }

%%              

int yywrap()
{
    yyerror("Missing END statement\n");
    error_end = 1;
    return 1;
}