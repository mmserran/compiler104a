%{
// Dummy parser for scanner project.

#include <assert.h>
#include <stdlib.h>
#include <string.h>


#include "lyutils.h"
#include "astree.h"

%}

%debug
%defines
%error-verbose
%token-table
%verbose

%token	TOK_VOID TOK_BOOL TOK_INT TOK_STRING
%token	TOK_WHILE TOK_RETURN TOK_STRUCT
%token	TOK_FALSE TOK_TRUE TOK_NULL TOK_NEW TOK_ARRAY
%token	TOK_IDENT TOK_INTCON TOK_CHARCON TOK_STRINGCON

%token	TOK_BLOCK TOK_CALL TOK_IFELSE TOK_INITDECL
%token	TOK_NEWARRAY TOK_TYPEID TOK_FIELD
%token	TOK_ORD TOK_CHR ROOT

%right	TOK_IF TOK_ELSE
%right	'='
%left	TOK_EQ TOK_NE TOK_LT TOK_LE TOK_GT TOK_GE
%left	'+' '-'
%left	'*' '/' '%'
%right	TOK_POS TOK_NEG '!' TOK_CHAR
%left	'[' ']' '.' '(' ')'

%start	start

%%

start	: program	{ yyparse_astree = $1; }
		;

program : program structdef		{ $$ = adopt1($1, $2); }
		| program function		{ $$ = adopt1($1, $2); }
		| program statement		{ $$ = adopt1($1, $2); }
		|						{ $$ = new_parseroot(); }
		;
		
structdef : structdef token | token ;

function : function token | token ;

statement : statement token | token ;
		
token   : '(' | ')' | '[' | ']' | '{' | '}' | ';' | ',' | '.'
        | '=' | '+' | '-' | '*' | '/' | '%' | '!'
        | TOK_VOID | TOK_BOOL | TOK_CHAR | TOK_INT | TOK_STRING
        | TOK_IF | TOK_ELSE | TOK_WHILE | TOK_RETURN | TOK_STRUCT
        | TOK_FALSE | TOK_TRUE | TOK_NULL | TOK_NEW | TOK_ARRAY
        | TOK_EQ | TOK_NE | TOK_LT | TOK_LE | TOK_GT | TOK_GE
        | TOK_IDENT | TOK_INTCON | TOK_CHARCON | TOK_STRINGCON
        | TOK_ORD | TOK_CHR | ROOT
        ;

%%

const char *get_yytname (int symbol) {
   return yytname [YYTRANSLATE (symbol)];
}


bool is_defined_token (int symbol) {
   return YYTRANSLATE (symbol) > YYUNDEFTOK;
}

static void* yycalloc (size_t size) {
   void* result = calloc (1, size);
   assert (result != NULL);
   return result;
}

