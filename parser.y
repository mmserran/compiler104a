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
		
structdef : TOK_STRUCT TOK_IDENT '{' decls '}'
		  ;

decls : decls decl ';'
	  | decl ';'
	  ;
	  
decl : type TOK_IDENT
	 ;
	 
type : basetype TOK_ARRAY
     | basetype
     ;
     
basetype : TOK_VOID | TOK_BOOL   | TOK_CHAR 
		 | TOK_INT  | TOK_STRING | TOK_IDENT
		 ;

function : type TOK_IDENT '('  paramdecls ')' block
		 ;

paramdecls : decl ',' paramdecls
		   | decl
		   |
		   ;
		   
block : '{' stmts '}'
	  | ';'
	  ;
	  
stmts : stmts statement
	  | statement
	  ;
	  
statement : block  | vardecl
		  | while  | ifelse
		  | return | expr ';'
		  ;

vardecl : type TOK_IDENT '=' expr ';'
		;
		
while : TOK_WHILE '(' expr ')' statement
	  ;
	  
ifelse : TOK_IF '(' expr ')' statement
	   | TOK_IF '(' expr ')' statement TOK_ELSE statement
	   ;
	  
return : TOK_RETURN ';'
	   | TOK_RETURN expr ';'
	   ;
	
listexpr : listexpr ',' expr
		 | expr
		 |
		 ;
	
expr : expr '+' expr
	 | '+' expr %prec TOK_POS
	 | expr '-' expr
	 | '-' expr %prec TOK_NEG
	 | expr '=' expr
	 | expr TOK_EQ expr
	 | expr TOK_NE expr
	 | expr TOK_LT expr
	 | expr TOK_GT expr
	 | expr TOK_LE expr
	 | expr TOK_GE expr
	 | expr '.' expr
	 | expr '*' expr
	 | allocator
	 | call
	 | '(' expr ')'
	 | variable
	 | constant
	 ;
			
allocator : TOK_NEW basetype '(' ')' 
		  | TOK_NEW basetype '(' expr ')' 
		  | TOK_NEW basetype '[' expr ']'
		  ;
		 
call : TOK_IDENT '(' listexpr ')'
	 ;
	 
variable : TOK_IDENT
		 | expr '[' expr ']'
		 | expr '.' TOK_IDENT
		 ;
		 
constant : TOK_INTCON | TOK_CHARCON | TOK_STRINGCON
		 | TOK_FALSE  | TOK_TRUE 	| TOK_NULL
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

