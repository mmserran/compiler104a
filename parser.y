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
	  
decl : basetype TOK_ARRAY TOK_IDENT { $$ = adopt2($1, $2, $3); }
	 | basetype TOK_IDENT			   { $$ = adopt1($1, $2); }
	 ;
     
basetype : TOK_VOID		{ $$ = $1; } 
		 | TOK_BOOL		{ $$ = $1; } 
		 | TOK_CHAR		{ $$ = $1; } 
		 | TOK_INT		{ $$ = $1; } 
		 | TOK_STRING	{ $$ = $1; } 
		 | TOK_IDENT	{ $$ = $1; } 
		 ;

function : decl '('  paramdecls ')' block
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
	  
statement : block  		{ $$ = $1; }
		  | vardecl		{ $$ = $1; }
		  | while  		{ $$ = $1; }
		  | ifelse		{ $$ = $1; }
		  | return 		{ $$ = $1; }
		  | expr ';'	{ free_ast($2); $$ = $1; }
		  ;

vardecl : decl '=' expr ';'	{ free_ast($4); $$ = rename(adopt2($2, $1, $3), "vardecl"); }
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
	
expr : expr '+' expr			{ $$ = adopt2($2, $1, $3); }
	 | '+' expr %prec TOK_POS	{ $$ = adopt1sym($1, $2, TOK_POS); }
	 | expr '-' expr			{ $$ = adopt2($2, $1, $3); }
	 | '-' expr %prec TOK_NEG	{ $$ = adopt1sym($1, $2, TOK_NEG); }
	 | expr '=' expr			{ $$ = adopt2($2, $1, $3); }
	 | expr TOK_EQ expr			{ $$ = adopt2($2, $1, $3); }
	 | expr TOK_NE expr			{ $$ = adopt2($2, $1, $3); }
	 | expr TOK_LT expr			{ $$ = adopt2($2, $1, $3); }
	 | expr TOK_GT expr			{ $$ = adopt2($2, $1, $3); }
	 | expr TOK_LE expr			{ $$ = adopt2($2, $1, $3); }
	 | expr TOK_GE expr			{ $$ = adopt2($2, $1, $3); }
	 | expr '.' expr			{ $$ = adopt2($2, $1, $3); }
	 | expr '*' expr			{ $$ = adopt2($2, $1, $3); }
	 | allocator				{ $$ = $1; }
	 | call						{ $$ = $1; }
	 | '(' expr ')'				{ free_ast2($1, $3); $$ = $2; }
	 | variable					{ $$ = $1; }
	 | constant					{ $$ = $1; }
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

