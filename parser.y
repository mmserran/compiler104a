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

%token  PROGRAM TOK_BLOCK
%token  TOK_PARAMS TOK_VARDECL TOK_IFELSE TOK_CALL
%token	TOK_VOID TOK_BOOL TOK_INT TOK_STRING
%token	TOK_WHILE TOK_RETURN TOK_STRUCT
%token	TOK_FALSE TOK_TRUE TOK_NULL TOK_NEW TOK_ARRAY
%token	TOK_IDENT TOK_INTCON TOK_CHARCON TOK_STRINGCON

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

start	: program	{ yyparse_astree = rename($1, "program", PROGRAM); }
		;

program : program structdef		{ $$ = adopt1($1, $2); }
		| program function		{ $$ = adopt1($1, $2); }
		| program statement		{ $$ = adopt1($1, $2); }
		|						{ $$ = new_parseroot(); }
		;
		
structdef : TOK_STRUCT TOK_IDENT '{' decls '}' 		{ free_ast2($3, $5); adopt2(rename($1, "structdef", TOK_STRUCT), $2, $4); }
		  ;
	  
decls : decls decl';'	{ free_ast($3); $$ = adopt1($1, $2); }
	  | decl ';'		{ free_ast($2); $$ = $1; }
	  ;
	  
type : basetype TOK_ARRAY { $$ = adopt1($1, $2); }
	 | basetype			  { $$ = parent("basetype", $1); }
	 ;
     
basetype : TOK_VOID		{ $$ = $1; } 
		 | TOK_BOOL		{ $$ = $1; } 
		 | TOK_CHAR		{ $$ = $1; } 
		 | TOK_INT		{ $$ = $1; } 
		 | TOK_STRING	{ $$ = $1; } 
		 | TOK_IDENT	{ $$ = $1; } 
		 ;

function : type TOK_IDENT params ')' block	{ free_ast($4); $$ = parent("function", parent("type", $1)); $$ = adopt3($$, $3, $2, $5); }
		 ;
		 
params : '(' decl			{ $$ = adopt1(rename($1, "params", TOK_PARAMS), $2); }
	     | params ',' decl	{ free_ast($2); $$ = adopt1($1, $3); }
	     | '('				{ $$ = rename($1, "params", TOK_PARAMS); }
	     ;
		 
decl : type TOK_IDENT	{ $$ = adopt1(parent("decl", parent("type", $1)), $2); }
	 ;
		   
block : '{' stmts '}'	{ free_ast($3); $$ = rename(adopt1($1, $2), "block", TOK_BLOCK); }
	  | '{' '}'			{ free_ast($2); $$ = rename($1, "block", TOK_BLOCK); }
	  | ';'				{ $$ = rename($1, "block", TOK_BLOCK); }
	  ;
	  
stmts : stmts statement	{ $$ = adopt1($1, $2); }
	  | statement		{ $$ = $1; }
	  ;
	  
statement : block  		{ $$ = rename($1, "block", TOK_BLOCK);	  }
		  | vardecl		{ $$ = rename($1, "vardecl", TOK_VARDECL); }
		  | while  		{ $$ = rename($1, "while", TOK_WHILE);   }
		  | ifelse		{ $$ = rename($1, "ifelse", TOK_IFELSE);  }
		  | return 		{ $$ = rename($1, "return", TOK_RETURN);  }
		  | expr ';'	{ free_ast($2); $$ = $1; 	  }
		  ;

vardecl : type TOK_IDENT '=' expr ';'	{ free_ast($5); $$ = adopt3($3, parent("type", $1), $2, $4); }
		;
		
while : TOK_WHILE '(' expr ')' statement	{ $$ = adopt2($1, $3, $5); free_ast2($2, $4); }
	  ;
	  
ifelse : TOK_IF '(' expr ')' statement %prec TOK_ELSE		{ free_ast2($2, $4); adopt2($1, $3, $5); }
	   | TOK_IF '(' expr ')' statement TOK_ELSE statement	{ free_ast2($2, $4); adopt3($1, $3, $5, $7); }
	   ;
	  
return : TOK_RETURN ';'			{ $$ = $1 }
	   | TOK_RETURN expr ';'	{ $$ = adopt1($1, $2); }
	   ;
	
expr : expr '+' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", '+'); }
	 | expr '-' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", '-'); }
	 | expr '=' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", '='); }
	 | expr TOK_EQ expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", TOK_EQ); }
	 | expr TOK_NE expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", TOK_NE); }
	 | expr TOK_LT expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", TOK_LT); }
	 | expr TOK_GT expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", TOK_GT); }
	 | expr TOK_LE expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", TOK_LE); }
	 | expr TOK_GE expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", TOK_GE); }
	 | expr '.' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", '.'); }
	 | expr '*' expr			{ $$ = rename(adopt2(parent("", $1), $2, $3) , "binop", '*'); }
	 | '+' expr %prec TOK_POS	{ $$ = rename(adopt1sym($1, $2, TOK_POS), "unop", TOK_POS); }
	 | '-' expr %prec TOK_NEG	{ $$ = rename(adopt1sym($1, $2, TOK_NEG), "unop", TOK_NEG); }
	 | TOK_ORD expr				{ $$ = rename(adopt1($1, $2), "unop", TOK_ORD); }
	 | TOK_CHR expr				{ $$ = rename(adopt1($1, $2), "unop", TOK_CHR); }
	 | allocator				{ $$ = parent("allocator", $1); }
	 | call						{ $$ = $1; }
	 | '(' expr ')'				{ free_ast2($1, $3); $$ = $2;   }
	 | variable					{ $$ = parent("variable", $1);  }
	 | constant					{ $$ = parent("constant", $1);  }
	 ;
			
allocator : TOK_NEW basetype '(' ')' 		{ free_ast2($3, $4); $1->symbol = TOK_TYPEID; $$ = adopt1($1, $2); }
		  | TOK_NEW basetype '(' expr ')' 	{ free_ast2($3, $5); $1->symbol = TOK_FIELD; $$ = adopt2($1, $2, $4); }
		  | TOK_NEW basetype '[' expr ']'	{ free_ast2($3, $5); $1->symbol = TOK_NEWARRAY; $$ = adopt2($1, $2, $4); }
		  ;
		 
call : TOK_IDENT exprList ')'	{ free_ast($3); $$ = adopt1($2, $1); }
	 ;
	 
exprList : '(' expr				{ $$ = rename(adopt1($1, $2), "call", TOK_CALL); }
	     | exprList ',' expr	{ free_ast($2); $$ = adopt1($1, $3); }
	     | '('					{ $$ = rename($1, "call", TOK_CALL); }
	     ;
	 
variable : TOK_IDENT			{ $$ = $1; }
		 | expr '[' expr ']'	{ free_ast2($2, $4); $$ = adopt1($1, $3); }
		 | expr '.' TOK_IDENT	{ free_ast($2); $$ = adopt1($1, $3); }
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

