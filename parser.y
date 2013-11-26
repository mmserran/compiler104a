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

start	: program	{ yyparse_astree = rename($1, "program"); }
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
	  
decl : type TOK_IDENT	{ $$ = parent("type", $1); }
	 ;
	  
type : basetype TOK_NEWARRAY { $$ = adopt1($1, $2); }
	 | basetype				 { $$ = parent("basetype", $1); }
	 ;
     
basetype : TOK_VOID		{ $$ = $1; } 
		 | TOK_BOOL		{ $$ = $1; } 
		 | TOK_CHAR		{ $$ = $1; } 
		 | TOK_INT		{ $$ = $1; } 
		 | TOK_STRING	{ $$ = $1; } 
		 | TOK_IDENT	{ $$ = $1; } 
		 ;

function : type TOK_IDENT '(' params ')' block	{ free_ast2($3, $5); 
												  $1 = parent("function", parent("type", $1)); 
												  $$ = adopt3($1, $2, $4, $6); }
		 | type TOK_IDENT '(' ')' block			{ free_ast2($3, $4);}
		 ;

params : params ',' decl
	   | decl
	   ;
		   
block : '{' stmts '}'	{ free_ast2($1, $3); $$ = $2; }
	  | '{' '}'			{ free_ast2($1, $2); }
	  | ';'				{ free_ast($1); }
	  ;
	  
stmts : stmts statement	{ $$ = adopt1($1, $2); }
	  | statement		{ $$ = parent("", $1); }
	  ;
	  
statement : block  		{ $$ = rename($1, "block");	  }
		  | vardecl		{ $$ = rename($1, "vardecl"); }
		  | while  		{ $$ = rename($1, "while");   }
		  | ifelse		{ $$ = rename($1, "ifelse");  }
		  | return 		{ $$ = rename($1, "return");  }
		  | expr ';'	{ free_ast($2); $$ = $1; 	  }
		  ;

vardecl : type TOK_IDENT '=' expr ';'	{ free_ast($5); $$ = adopt3($3, parent("type", $1), $2, $4); }
		;
		
while : TOK_WHILE '(' expr ')' statement	{ $$ = adopt2($1, $3, $5); free_ast2($2, $4); }
	  ;
	  
ifelse : TOK_IF '(' expr ')' statement %prec TOK_ELSE
	   | TOK_IF '(' expr ')' statement TOK_ELSE statement
	   ;
	  
return : TOK_RETURN ';'
	   | TOK_RETURN expr ';'
	   ;
	
expr : expr '+' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr '-' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr '=' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr TOK_EQ expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr TOK_NE expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr TOK_LT expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr TOK_GT expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr TOK_LE expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr TOK_GE expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr '.' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | expr '*' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop"); }
	 | '+' expr %prec TOK_POS	{ $$ = rename(adopt1sym($1, $2, TOK_POS), "unop"); }
	 | '-' expr %prec TOK_NEG	{ $$ = rename(adopt1sym($1, $2, TOK_NEG), "unop"); }
	 | TOK_ORD expr				{ $$ = rename(adopt1($1, $2), "unop"); }
	 | TOK_CHR expr				{ $$ = rename(adopt1($1, $2), "unop"); }
	 | allocator				{ $$ = parent("allocator", $1); }
	 | call						{ $$ = $1; 		}
	 | '(' expr ')'				{ free_ast2($1, $3); $$ = $2;   }
	 | variable					{ $$ = parent("variable", $1);  }
	 | constant					{ $$ = parent("constant", $1);  }
	 ;
			
allocator : TOK_NEW basetype '(' ')' 
		  | TOK_NEW basetype '(' expr ')' 
		  | TOK_NEW basetype '[' expr ']'
		  ;
		 
call : TOK_IDENT params ')'	{ free_ast($3); $$ = adopt1($2, $1); }
	 | TOK_IDENT '(' ')' 	{ free_ast($3); $$ = adopt1($2, $1); }
	 ;
	 
params : '(' expr			{ $$ = rename(adopt1($1, $2), "call"); }
	   | params ',' expr	{ free_ast($2); $$ = adopt1($1, $3); }
	   | '('				{ $$ = rename($1, "call"); }
	   ;
	 
variable : TOK_IDENT
		 | expr '[' expr ']'
		 | expr '.' TOK_IDENT
		 ;
		 
constant : TOK_INTCON 		{ $$ = $1; }
		 | TOK_CHARCON 		{ $$ = $1; }
		 | TOK_STRINGCON	{ $$ = $1; }
		 | TOK_FALSE  		{ $$ = $1; }
		 | TOK_TRUE 		{ $$ = $1; }
		 | TOK_NULL			{ $$ = $1; }
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

