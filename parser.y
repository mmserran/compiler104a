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


%token  TOK_TYPE TOK_BASETYPE TOK_DECL TOK_CONSTANT TOK_VARIABLE TOK_CALL
%token  TOK_BLOCK IGNORE TOK_FUNCTION
%token  TOK_PARAMS TOK_VARDECL TOK_IFELSE 
%token	TOK_VOID TOK_BOOL TOK_INT TOK_STRING
%token	TOK_WHILE TOK_RETURN TOK_STRUCT
%token	TOK_FALSE TOK_TRUE TOK_NULL TOK_NEW TOK_ARRAY
%token	TOK_IDENT TOK_INTCON TOK_CHARCON TOK_STRINGCON

%token	TOK_NEWARRAY TOK_TYPEID TOK_FIELD
%token	TOK_ORD TOK_CHR ROOT TOK_NOT

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
		
structdef : TOK_STRUCT TOK_IDENT '{' decls '}' 		{ free_ast2($3, $5); 
													  astree* temp = new_astree(0, 0, 0, 0, "structdef");
													  $$ = adopt3(temp, $1, $2, $4); }
		  ;
	  
decls : decls decl';'	{ free_ast($3); 
						  $$ = adopt1($1, $2); }
	  | decl ';'		{ free_ast($2);
	  					  $$ = $1; }
	  ;
	  
type : basetype TOK_ARRAY { astree* temp = new_astree(0, 0, 0, 0, "type");
	 					  	temp->symbol = TOK_TYPE;
							$2->symbol = TOK_ARRAY; 
							$2->terminal = true;
							$$ = adopt1(temp, adopt1($1, $2));  }
	 | basetype			  { astree* temp = new_astree(0, 0, 0, 0, "type");
	 						temp->symbol = TOK_TYPE;
	 						$$ = adopt1(temp, $1); }
	 ;
     
basetype : TOK_VOID		{ astree* temp = new_astree(0, 0, 0, 0, "basetype");
	 					  temp->symbol = TOK_BASETYPE;
						  $1->symbol = TOK_VOID;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_BOOL		{ astree* temp = new_astree(0, 0, 0, 0, "basetype");
	 					  temp->symbol = TOK_BASETYPE;
						  $1->symbol = TOK_BOOL;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_CHAR		{ astree* temp = new_astree(0, 0, 0, 0, "basetype");
	 					  temp->symbol = TOK_BASETYPE;
						  $1->symbol = TOK_CHAR;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_INT		{ astree* temp = new_astree(0, 0, 0, 0, "basetype");
	 					  temp->symbol = TOK_BASETYPE;
						  $1->symbol = TOK_INT;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_STRING	{ astree* temp = new_astree(0, 0, 0, 0, "basetype");
	 					  temp->symbol = TOK_BASETYPE;
						  $1->symbol = TOK_STRING;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_IDENT	{ astree* temp = new_astree(0, 0, 0, 0, "basetype");
	 					  temp->symbol = TOK_BASETYPE;
						  $1->symbol = TOK_IDENT;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 ;

function : type TOK_IDENT params ')' block	{ free_ast($4); 
											  astree* temp = new_astree(0, 0, 0, 0, "function");
											  temp->symbol = TOK_FUNCTION;
											  $2->symbol = TOK_IDENT;
											  $2->terminal = true;
						 					  $$ = adopt2(temp, $1, $2);
						 					  $$ = adopt2($$, $3, $5);}
		 ;
		 
params : '(' decl			{ free_ast($1);
							  astree* temp = new_astree(0, 0, 0, 0, "params");
						  	  temp->symbol = TOK_PARAMS;
							  $$ = adopt1(temp, $2); }
	     | params ',' decl	{ free_ast($2); $$ = adopt1($1, $3); }
	     | '('				{ free_ast($1);
							  astree* temp = new_astree(0, 0, 0, 0, "params");
						  	  temp->symbol = TOK_PARAMS;
							  $$ = temp; }
	     ;
		 
decl : type TOK_IDENT	{ astree* temp = new_astree(0, 0, 0, 0, "decl");
	 					  temp->symbol = TOK_DECL;
						  $2->symbol = TOK_IDENT;
						  $2->terminal = true;
	 					  $$ = adopt2(temp, $1, $2); }
	 ;
		   
block : '{' stmts '}'	{ free_ast($3); 
						  astree* temp = new_astree(0, 0, 0, 0, "block");
						  temp->symbol = TOK_BLOCK;
	 					  $$ = adopt1(temp, $2); }
	  | '{' '}'			{ free_ast($2);
	  					  astree* temp = new_astree(0, 0, 0, 0, "block");
						  temp->symbol = TOK_BLOCK;
	 					  $$ = temp; }
	  | ';'				{ astree* temp = new_astree(0, 0, 0, 0, "block");
						  temp->symbol = TOK_BLOCK;
	 					  $$ = temp; }
	  ;
	  
stmts : stmts statement	{ $$ = adopt1($1, $2); }
	  | statement		{ $$ = $1; }
	  ;
	  
statement : block  		{ $$ = $1; }
		  | vardecl		{ $$ = $1; }
		  | while  		{ $$ = $1; }
		  | ifelse		{ $$ = $1;  }
		  | return 		{ $$ = $1;  }
		  | expr ';'	{ free_ast($2); $$ = $1; 	  }
		  ;

vardecl : type TOK_IDENT '=' expr ';'	{ free_ast2($3, $5);
										  $2->symbol = TOK_FIELD;
										  $2->terminal = true;
										  astree* temp = new_astree(0, 0, 0, 0, "vardecl");
										  temp->symbol = TOK_VARDECL;
										  $$ = adopt3(temp, $1, $2, $4); }
		;
		
while : TOK_WHILE '(' expr ')' statement	{ free_ast2($2, $4);
											  $$ = adopt2($1, $3, $5);  }
	  ;
	  
ifelse : TOK_IF '(' expr ')' statement %prec TOK_ELSE		{ free_ast2($2, $4); adopt2($1, $3, $5); }
	   | TOK_IF '(' expr ')' statement TOK_ELSE statement	{ free_ast2($2, $4); adopt3($1, $3, $5, $7); }
	   ;
	  
return : TOK_RETURN ';'			{ $$ = $1 }
	   | TOK_RETURN expr ';'	{ $$ = adopt1($1, $2); }
	   ;
	
expr : expr '+' expr			{ $2->symbol = '+';
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr '-' expr			{ $2->symbol = '-';
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr '=' expr			{ $2->symbol = '=';
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_EQ expr			{ $2->symbol = TOK_EQ;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_NE expr			{ $2->symbol = TOK_NE;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_LT expr			{ $2->symbol = TOK_LT;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_GT expr			{ $2->symbol = TOK_GT;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_LE expr			{ $2->symbol = TOK_LE;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_GE expr			{ $2->symbol = TOK_GE;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr '.' expr			{ $2->symbol = '.';
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr '*' expr			{ $2->symbol = '*';
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | '+' expr %prec TOK_POS	{ $2->symbol = TOK_POS;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2); }
	 | '-' expr %prec TOK_NEG	{ $2->symbol = TOK_NEG;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2); ; }
	 | '!' expr %prec TOK_NOT	{ $2->symbol = TOK_NOT;
								  $2->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2); }
	 | TOK_ORD expr				{ $1->symbol = TOK_ORD;
								  $1->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2);  }
	 | TOK_CHR expr				{ $1->symbol = TOK_CHR;
								  $1->terminal = true;
								  astree* temp = new_astree(0, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2);   }
	 | allocator				{ $$ = $1; }
	 | call						{ $$ = $1; }
	 | '(' expr ')'				{ free_ast2($1, $3); 
	 							  $$ = $2;   }
	 | variable					{ $$ = $1;  }
	 | constant					{ $$ = $1;  }
	 ;
			
allocator : TOK_NEW basetype '(' ')' 		{ free_ast2($3, $4); 
											  astree* temp = new_astree(0, 0, 0, 0, "allocator");
											  $$ = adopt2(temp, $1, $2); }
		  | TOK_NEW basetype '(' expr ')' 	{ free_ast2($3, $5);
											  astree* temp = new_astree(0, 0, 0, 0, "allocator");
											  $$ = adopt3(temp, $1, $2, $4);  }
		  | TOK_NEW basetype '[' expr ']'	{ free_ast2($3, $5); 
											  astree* temp = new_astree(0, 0, 0, 0, "allocator");
											  astree* array = new_astree(0, 0, 0, 0, "[]");
											  array->terminal = true;
											  array->symbol = TOK_NEWARRAY;
											  $2 = adopt1($2, array);
											  $$ = adopt3(temp, $1, $2, $4); }
		  ;
		 
call : TOK_IDENT '(' args ')'		{ free_ast2($2, $4);
									  astree* temp = new_astree(0, 0, 0, 0, "call"); 
		 					  	  	  temp->symbol = TOK_CALL;
									  $1->symbol = TOK_IDENT;
									  $1->terminal = true;
									  $$ = adopt2(temp, $1, $3);}
	 ;
	 
args : expr					{ astree* temp = new_astree(0, 0, 0, 0, "args");
							  $$ = adopt1(temp, $1); }
	 | args ',' expr		{ free_ast($2);
	     					  $$ = adopt1($1, $3); }
	 |
	 ;

variable : TOK_IDENT			{ $1->terminal = true;
								  $1->symbol = TOK_IDENT;
								  astree* temp = new_astree(0, 0, 0, 0, "variable");
	 					  	  	  temp->symbol = TOK_VARIABLE;
								  $$ = adopt1(temp, $1); }
		 | expr '[' expr ']'	{ free_ast2($1, $3);
		 						  astree* temp = new_astree(0, 0, 0, 0, "variable");
	 					  	  	  temp->symbol = TOK_VARIABLE;
								  $$ = adopt2(temp, $1, $2); }
		 | expr '.' TOK_IDENT	{ free_ast($2); 
		 						  astree* temp = new_astree(0, 0, 0, 0, "variable");
	 					  	  	  temp->symbol = TOK_VARIABLE;
		 						  $$ = adopt2(temp, $1, $3); }
		 ;
		 
constant : TOK_INTCON 		{ $1->symbol = TOK_INTCON;
							  $1->terminal = true;
							  astree* temp = new_astree(0, 0, 0, 0, "constant");
	 					  	  temp->symbol = TOK_CONSTANT;
							  $$ = adopt1(temp, $1); }
		 | TOK_CHARCON 		{ $1->symbol = TOK_CHARCON;
							  $1->terminal = true;
							  astree* temp = new_astree(0, 0, 0, 0, "constant");
	 					  	  temp->symbol = TOK_CONSTANT;
							  $$ = adopt1(temp, $1); }
		 | TOK_STRINGCON	{ $1->symbol = TOK_STRINGCON;
							  $1->terminal = true;
							  astree* temp = new_astree(0, 0, 0, 0, "constant");
	 					  	  temp->symbol = TOK_CONSTANT;
							  $$ = adopt1(temp, $1); }
		 | TOK_FALSE  		{ $1->symbol = TOK_FALSE;
							  $1->terminal = true;
							  astree* temp = new_astree(0, 0, 0, 0, "constant");
	 					  	  temp->symbol = TOK_CONSTANT;
							  $$ = adopt1(temp, $1); }
		 | TOK_TRUE 		{ $1->symbol = TOK_TRUE;
							  $1->terminal = true;
							  astree* temp = new_astree(0, 0, 0, 0, "constant");
	 					  	  temp->symbol = TOK_CONSTANT;
							  $$ = adopt1(temp, $1); }
		 | TOK_NULL			{ $1->symbol = TOK_NULL;
							  $1->terminal = true;
							  astree* temp = new_astree(0, 0, 0, 0, "constant");
	 					  	  temp->symbol = TOK_CONSTANT;
							  $$ = adopt1(temp, $1); }
		 ;

%%

const char *get_yytname (int symbol) {
   return yytname [YYTRANSLATE (symbol)];
}


bool is_defined_token (int symbol) {
   return YYTRANSLATE (symbol) > YYUNDEFTOK;
}

