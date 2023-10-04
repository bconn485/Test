
/*
Declare token types at the top of the bison file,
causing them to be automatically generated in parser.tab.h
for use by scanner.c.
*/

%token TOKEN_ID
%token TOKEN_INTEGER
%token TOKEN_INT
%token TOKEN_SEMI
%token TOKEN_PLUS
%token TOKEN_MINUS
%token TOKEN_MUL
%token TOKEN_DIV
%token TOKEN_LPAREN
%token TOKEN_RPAREN
%token TOKEN_SIN
%token TOKEN_COS
%{

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "expr.h"

/*
YYSTYPE is the lexical value returned by each rule in a bison grammar.
By default, it is an integer. In this example, we are returning a pointer to an expression.
*/

#define YYSTYPE struct expr *

#define YYERROR_VERBOSE 1

/*
Clunky: Manually declare the interface to the scanner generated by flex. 
*/

extern char *yytext;
extern int yylex();
extern int yyerror( char *str );

/*
Clunky: Keep the final result of the parse in a global variable,
so that it can be retrieved by main().
*/

struct expr * parser_result = 0;

%}

%%

/* Here is the grammar: program is the start symbol. */

program : expr TOKEN_SEMI
		{ parser_result = $1; return 0; }
	;


expr	: expr TOKEN_PLUS term
		{ $$ = expr_create(EXPR_ADD,$1,$3); }
	| expr TOKEN_MINUS term
		{ $$ = expr_create(EXPR_SUBTRACT,$1,$3); }
	| term
		{  $$ = $1; }
	;

term	: term TOKEN_MUL factor
		{ $$ = expr_create(EXPR_MULTIPLY,$1,$3); }
	| term TOKEN_DIV factor
		{ $$ = expr_create(EXPR_DIVIDE,$1,$3); }
	| factor
		{   $$ = $1; }
	;

factor	: TOKEN_LPAREN expr TOKEN_RPAREN
		{ $$ = $2; }
	| TOKEN_MINUS factor
		{ $$ = expr_create(EXPR_SUBTRACT,expr_create_value(0),$2); }
	| TOKEN_SIN TOKEN_LPAREN expr TOKEN_RPAREN
	   { $$ = expr_create(EXPR_SIN,0,$3); }
	| TOKEN_COS TOKEN_LPAREN expr TOKEN_RPAREN
	   { $$ = expr_create(EXPR_COS,0,$3); }
	| TOKEN_INT
		{ $$ = expr_create_value(atoi(yytext)); }
	;

%%

/*
This function will be called by bison if the parse should
encounter an error.  In principle, "str" will contain something
useful.  In practice, it often does not.
*/

int yyerror( char *str )
{
	printf("parse error: %s\n",str);
	return 0;
}
