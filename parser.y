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

%token TOK_BINOP TOK_UNOP TOK_ALLOCATOR TOK_BASETYPE TOK_CALL TOK_VAR TOK_CONSTANT
%token TOK_TYPEID TOK_FIELD TOK_DECLID TOK_NEWARRAY TOK_FUNCTION TOK_TYPE
%token TOK_VOID TOK_BOOL TOK_CHAR TOK_INT TOK_STRING ROOT TOK_BLOCK
%token TOK_IF TOK_ELSE TOK_IFELSE TOK_WHILE TOK_RETURN TOK_STRUCT TOK_VARDECL
%token TOK_FALSE TOK_TRUE TOK_NULL TOK_NEW TOK_ARRAY
%token TOK_ORD TOK_CHR
%token TOK_EQ TOK_NE TOK_LT TOK_LE TOK_GT TOK_GE
%token TOK_IDENT TOK_INTCON TOK_CHARCON TOK_STRINGCON

%right     TOK_IF TOK_ELSE
%right     '='
%left      TOK_EQ TOK_NE TOK_LT TOK_LE TOK_GT TOK_GE
%left      '+' '-'
%left      '*' '/' '%'
%right     TOK_POS TOK_NEG '!' TOK_ORD TOK_CHR
%left      '[' '.' TOK_CALL
%nonassoc  TOK_NEW
%nonassoc  '('

%start	start

%%

start	: program	{ yyparse_astree = $1; }
		;

program : program structdef		{ $$ = adopt1($1, $2); }
		| program function		{ $$ = adopt1($1, $2); }
		| program stmt			{ $$ = adopt1($1, $2); }
		| program error '}'		{ $$ = $1; }
		| program error ';'		{ $$ = $1; }
		|						{ $$ = new_parseroot(); }
		;
		
structdef : TOK_STRUCT TOK_IDENT '{' '}'			{ free_ast2($3, $4);
													  free_ast($1);
													  $2->symbol = TOK_TYPEID;
													  $2->terminal = true;
													  astree* temp = new_astree(TOK_STRUCT, 0, 0, 0, "structdef");
													  $$ = adopt1(temp, $2); }
		  | TOK_STRUCT TOK_IDENT '{' decls '}' 		{ free_ast2($3, $5); 
													  free_ast($1);
													  $2->symbol = TOK_TYPEID;
													  $2->terminal = true;
													  astree* temp = new_astree(TOK_STRUCT, 0, 0, 0, "structdef");
													  $$ = adopt2(temp, $2, $4); }
		  ;
	  
decls : decls decl';'	{ free_ast($3); 
						  $$ = adopt1($1, $2); }
	  | decl ';'		{ free_ast($2);
	  					  astree* temp = new_astree(0, 0, 0, 0, "params");
	  					  $$ = adopt1(temp, $1); }
	  ;
	  
type : basetype TOK_ARRAY { free_ast($2);
							astree* temp = new_astree(TOK_TYPE, 0, 0, 0, "type");
							astree* array = new_astree(0, 0, 0, 0, "array");
							array->symbol = TOK_ARRAY;
							$$ = adopt2(temp, array, $1);  }
	 | basetype			  { astree* temp = new_astree(TOK_TYPE, 0, 0, 0, "type");
	 						$$ = adopt1(temp, $1); }
	 ;
     
basetype : TOK_VOID		{ astree* temp = new_astree(TOK_BASETYPE, 0, 0, 0, "basetype");
						  $1->symbol = TOK_VOID;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_BOOL		{ astree* temp = new_astree(TOK_BASETYPE, 0, 0, 0, "basetype");
						  $1->symbol = TOK_BOOL;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_CHAR		{ astree* temp = new_astree(TOK_BASETYPE, 0, 0, 0, "basetype");
						  $1->symbol = TOK_CHAR;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_INT		{ astree* temp = new_astree(TOK_BASETYPE, 0, 0, 0, "basetype");
						  $1->symbol = TOK_INT;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_STRING	{ astree* temp = new_astree(TOK_BASETYPE, 0, 0, 0, "basetype");
						  $1->symbol = TOK_STRING;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 | TOK_IDENT	{ astree* temp = new_astree(TOK_BASETYPE, 0, 0, 0, "basetype");
						  $1->symbol = TOK_IDENT;
						  $1->terminal = true;
	 					  $$ = adopt1(temp, $1); } 
		 ;

function : type TOK_IDENT '(' ')' block		{ free_ast2($3, $4);
									  		  astree* temp = new_astree(TOK_FUNCTION, $2->filenr, $2->linenr, $2->offset, "function");
											  $2->symbol = TOK_TYPEID;
											  $2->terminal = true;
									 		  $$ = adopt3(temp, $2, $1, $5); }
		 | type TOK_IDENT argList ')' block	{ free_ast($4);
				 							  astree* temp = new_astree(TOK_FUNCTION, $2->filenr, $2->linenr, $2->offset, "function");
											  $2->symbol = TOK_TYPEID;
											  $2->terminal = true;
				 							  temp = adopt2(temp, $2, $1);
				 							  $$ = adopt2(temp, $3, $5); }
		 ;
		 
argList :  argList ',' decl	{ free_ast($2); $$ = adopt1($1, $3); }
	   | '(' decl			{ free_ast($1);
							  astree* temp = new_astree(0, 0, 0, 0, "params");
							  $$ = adopt1(temp, $2); }
	   ;
		 
decl : type TOK_IDENT	{ astree* temp = new_astree(0, 0, 0, 0, "decl");
						  $2->symbol = TOK_FIELD;
						  $2->terminal = true;
	 					  $$ = adopt2(temp, $2, $1); }
	 ;
		   
block : '{' stmts '}'	{ free_ast2($1, $3); 
						  astree* temp = new_astree(TOK_BLOCK, 0, 0, 0, "block");
	 					  $$ = adopt1(temp, $2); }
	  | '{' '}'			{ free_ast2($1, $2);
	  					  astree* temp = new_astree(TOK_BLOCK, 0, 0, 0, "block");
	 					  $$ = temp; }
	  | ';'				{ astree* temp = new_astree(TOK_BLOCK, 0, 0, 0, "block");
	 					  $$ = temp; }
	  ;
	  
stmts : stmts stmt	{ $$ = adopt1($1, $2); }
	  | stmt		{ $$ = $1; }
	  ;
	  
stmt : block  		{ $$ = $1; }
	 | vardecl		{ $$ = $1; }
	 | while  		{ $$ = $1; }
	 | ifelse		{ $$ = $1;  }
	 | return 		{ $$ = $1;  }
	 | expr ';'		{ free_ast($2); $$ = $1; }
	 ;

vardecl : type TOK_IDENT '=' expr ';'	{ free_ast2($3, $5); 
										  astree* temp = new_astree(TOK_VARDECL, $2->filenr, $2->linenr, $2->offset, "vardecl");
										  $2->symbol = TOK_DECLID;
										  $2->terminal = true;
										  $$ = adopt3(temp, $2, $1, $4); }
		;
		
while : TOK_WHILE '(' expr ')' stmt		{ free_ast2($2, $4);
										  free_ast($1);
										  astree* temp = new_astree(TOK_WHILE, 0, 0, 0, "while");
										  $$ = adopt2(temp, $3, $5);  }
	  ;
	  
ifelse : TOK_IF '(' expr ')' stmt %prec TOK_ELSE		{ free_ast2($2, $4);
														  free_ast($1);
	   													  astree* temp = new_astree(TOK_IF, 0, 0, 0, "if");
														  $$ = adopt2(temp, $3, $5); }
	   | TOK_IF '(' expr ')' stmt TOK_ELSE stmt			{ free_ast2($2, $4); 
	   													  free_ast2($1, $6);
	   													  astree* temp = new_astree(TOK_IFELSE, 0, 0, 0, "ifelse");
	   													  $$ = adopt3(temp, $3, $5, $7); }
	   ;
	  
return : TOK_RETURN ';'			{ free_ast2($1, $2);
								  astree* temp = new_astree(TOK_RETURN, 0, 0, 0, "return");
								  $$ = temp; }
	   | TOK_RETURN expr ';'	{ free_ast2($1, $3);
								  astree* temp = new_astree(TOK_RETURN, 0, 0, 0, "return");
								  $$ = adopt1(temp, $2); }
	   ;
	
expr : binop					{ $$ = $1; }
	 | unop						{ $$ = $1; }
	 | allocator				{ $$ = $1; }
	 | call						{ $$ = $1; }
	 | '(' expr ')'				{ $$ = $2; free_ast2($1, $3); }
	 | variable					{ $$ = $1;  }
	 | constant					{ $$ = $1;  }
	 ;
		
binop : expr '+' expr			{ $2->symbol = '+';
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr '-' expr			{ $2->symbol = '-';
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr '/' expr			{ $2->symbol = '/';
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr '*' expr			{ $2->symbol = '*';
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr '=' expr			{ $2->symbol = '=';
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_EQ expr			{ $2->symbol = TOK_EQ;
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_NE expr			{ $2->symbol = TOK_NE;
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_LT expr			{ $2->symbol = TOK_LT;
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_GT expr			{ $2->symbol = TOK_GT;
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_LE expr			{ $2->symbol = TOK_LE;
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 | expr TOK_GE expr			{ $2->symbol = TOK_GE;
								  $2->terminal = true;
								  astree* temp = new_astree(TOK_BINOP, 0, 0, 0, "binop");
								  $$ = adopt3(temp, $1, $2, $3); }
	 ;
			
unop : '+' expr %prec TOK_POS	{ $1->symbol = TOK_POS;
								  $1->terminal = true;
								  astree* temp = new_astree(TOK_UNOP, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2); }
	 | '-' expr %prec TOK_NEG	{ $1->symbol = TOK_NEG;
								  $1->terminal = true;
								  astree* temp = new_astree(TOK_UNOP, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2); ; }
	 | '!' expr					{ $1->symbol = '!';
								  $1->terminal = true;
								  astree* temp = new_astree(TOK_UNOP, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2); }
	 | TOK_ORD expr				{ $1->symbol = TOK_ORD;
								  $1->terminal = true;
								  astree* temp = new_astree(TOK_UNOP, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2);  }
	 | TOK_CHR expr				{ $1->symbol = TOK_CHR;
								  $1->terminal = true;
								  astree* temp = new_astree(TOK_UNOP, 0, 0, 0, "unop");
								  $$ = adopt2(temp, $1, $2);   }
	 ;
			
allocator : TOK_NEW basetype '(' ')' 		{ free_ast2($3, $4); 
											  astree* temp = new_astree(TOK_ALLOCATOR, 0, 0, 0, "allocator");
											  $$ = adopt2(temp, $1, $2); }
		  | TOK_NEW basetype '(' expr ')' 	{ free_ast2($3, $5);
											  astree* temp = new_astree(TOK_ALLOCATOR, 0, 0, 0, "allocator");
											  $$ = adopt3(temp, $1, $2, $4);  }
		  | TOK_NEW basetype '[' expr ']'	{ free_ast2($3, $5); 
											  astree* temp = new_astree(TOK_ALLOCATOR, 0, 0, 0, "allocator");
											  astree* array = new_astree(0, 0, 0, 0, "array");
											  array->symbol = TOK_NEWARRAY;
											  temp = adopt1(temp, $1);
											  $$ = adopt3(temp, array, $2, $4); }
		  ;
		 
call : TOK_IDENT '(' ')'		{ free_ast2($2, $3);
								  $1->symbol = TOK_IDENT;
								  $1->terminal = true;
								  astree* temp = new_astree(TOK_CALL, 0, 0, 0, "call");
								  $$ = adopt1(temp, $1); }
	 | TOK_IDENT args ')'		{ free_ast($3);
								  $1->symbol = TOK_IDENT;
								  $1->terminal = true;
	 							  astree* temp = new_astree(TOK_CALL, 0, 0, 0, "call");
	 							  $$ = adopt2(temp, $1, $2); }
	 ;
	 
args : '(' expr					{ free_ast($1);
								  astree* temp = new_astree(0, 0, 0, 0, "args");
								  $$ = adopt1(temp, $2); }
	 | args ',' expr			{ free_ast($2);
	     						  $$ = adopt1($1, $3); }
	 ;

variable : TOK_IDENT			{ $1->symbol = TOK_IDENT;
								  $1->terminal = true;
								  astree* temp = new_astree(TOK_VAR, 0, 0, 0, "variable");
								  $$ = adopt1(temp, $1); }
		 | expr '[' expr ']'	{ free_ast2($2, $4);
		 						  astree* temp = new_astree(TOK_VAR, 0, 0, 0, "variable");
								  $$ = adopt2(temp, $1, $3); }
		 | expr '.' TOK_IDENT	{ free_ast($2); 
								  $3->symbol = TOK_IDENT;
								  $3->terminal = true;
		 						  astree* temp = new_astree(TOK_VAR, 0, 0, 0, "variable");
		 						  $$ = adopt2(temp, $3, $1); }
		 ;
		 
constant : TOK_INTCON 		{ $1->symbol = TOK_INTCON;
							  $1->terminal = true;
							  astree* temp = new_astree(TOK_CONSTANT, 0, 0, 0, "constant");
							  $$ = adopt1(temp, $1); }
		 | TOK_CHARCON 		{ $1->symbol = TOK_CHARCON;
							  $1->terminal = true;
							  astree* temp = new_astree(TOK_CONSTANT, 0, 0, 0, "constant");
							  $$ = adopt1(temp, $1); }
		 | TOK_STRINGCON	{ $1->symbol = TOK_STRINGCON;
							  $1->terminal = true;
							  astree* temp = new_astree(TOK_CONSTANT, 0, 0, 0, "constant");
							  $$ = adopt1(temp, $1); }
		 | TOK_FALSE  		{ $1->symbol = TOK_FALSE;
							  $1->terminal = true;
							  astree* temp = new_astree(TOK_CONSTANT, 0, 0, 0, "constant");
							  $$ = adopt1(temp, $1); }
		 | TOK_TRUE 		{ $1->symbol = TOK_TRUE;
							  $1->terminal = true;
							  astree* temp = new_astree(TOK_CONSTANT, 0, 0, 0, "constant");
							  $$ = adopt1(temp, $1); }
		 | TOK_NULL			{ $1->symbol = TOK_NULL;
							  $1->terminal = true;
							  astree* temp = new_astree(TOK_CONSTANT, 0, 0, 0, "constant");
							  $$ = adopt1(temp, $1); }
		 ;

%%

const char *get_yytname (int symbol) {
   return yytname [YYTRANSLATE (symbol)];
}


bool is_defined_token (int symbol) {
   return YYTRANSLATE (symbol) > YYUNDEFTOK;
}

