
using namespace std;
#include <sstream>

#include "lyutils.h"
#include "typecheck.h"
#include "symtable.h"
#include "astree.h"
#include "buildtable.h"

// Declare variables
SymbolTable* type_symtable;

void typecheck (FILE* outfile, SymbolTable* symtable, astree* node) {

	type_symtable = new SymbolTable(NULL);

	typecheck_rec (outfile, symtable, type_symtable, node);

	type_symtable->dump(outfile, 0);
	fflush (NULL);
}

string typecheck_rec (FILE* outfile, SymbolTable* symtable, SymbolTable* typetable, astree* node) {

	   const string* typeStr;
	   const string* nameStr;
	   string temp;
	   string left;
	   string right;
	   string type;
	   string base;
	   astree* op;
	   if (node == NULL) return "invalid node";

	   switch (node->symbol) {

   	   	   case TOK_STRUCT: {
			   // Get name of struct
			   nameStr = node->children[0]->lexinfo;
			   // Get type
			   typeStr = node->children[0]->lexinfo;
			   // Get params
			   temp = *typeStr + "(";

			   bool needDelim;
			   needDelim = false;
			   for (size_t child = 0; child < node->children[1]->children.size(); ++child) {
				   typeStr = getType(node->children[1]->children[child]->children[1]);

				   if (needDelim) {
					   temp = temp + ", ";
				   }

				   temp = temp + *typeStr;
				   needDelim = true;
			   }
			   temp = temp + ")";
			   typeStr = &temp;

			   return typeStr->c_str();
	   	   }

   	   	   // Unop expressions
   	   	   case TOK_UNOP: {
   	   		   op = node->children[0];
   	   		   type = typecheck_rec(outfile, symtable, typetable, node->children[1]);
   	   		   if (type=="")
   	   			   return "";

   	   		   switch (op->symbol) {
   	   		   	   case '+':
   	   		   	   case '-':
   	   		   	   case TOK_ORD:
   	   		   		   if (type=="int")
   	   		   			   return "char";
   	   		   		   break;
   	   		   	   case '!':
   	   		   		   if (type=="bool")
   	   		   			   return "bool";
   	   		   		   break;
   	   		   	   case TOK_CHR:
   	   		   		   if (type=="char")
   	   		   			   return "int";
   	   		   		   break;
   	   		   }
   	   		   fprintf(outfile, "error, @unop \'%s\': invalid type \'%s\'\n",
   	   				   op->lexinfo->c_str(), type.c_str());
   	   		   return "";
   	   	   }
	   	   // Binop expressions
   	   	   case TOK_BINOP: {
   	   		   op = node->children[1];
   	   		   left = typecheck_rec(outfile, symtable, typetable, node->children[0]);
   	   		   right = typecheck_rec(outfile, symtable, typetable, node->children[2]);
   	   		   if (left=="" || right=="")
   	   			   return "";

   	   		   switch (op->symbol) {
   	   		   	   case '+':
   	   		   	   case '-':
   	   		   	   case '*':
   	   		   	   case '/':
   	   		   	   case '%':
   	   		   		   if (left==right && right=="int")
   	   	   		   		   return "int";
   	   		   		   break;
   	   		   	   case TOK_LT:
   	   		   	   case TOK_GT:
   	   		   	   case TOK_LE:
   	   		   	   case TOK_GE:
   	   		   		   if (left==right)
   	   	   		   		   return "bool";
   	   		   		   break;
   	   		   	   case TOK_EQ:
   	   		   	   case TOK_NE:
   	   		   		   if (left==right || left=="null" || right=="null")
   	   	   		   		   return "bool";
   	   		   		   break;
   	   		   	   case '=':
   	   		   		   if (left==right || right=="null")
   	   	   		   		   return left;
   	   		   		   break;
   	   		   }
   	   	   	   fprintf(outfile, "error, @binop: incompatible types, \'%s\'  \'%s\'\n",
   	   	   			   left.c_str(), right.c_str());
   	   	   	   return "";
   	   	   }
   	   	   // Constants
   	   	   case TOK_CONSTANT: {
   	   		   switch (node->children[0]->symbol) {
				   case TOK_INTCON:
					   return "int";
				   case TOK_CHARCON:
					   return "char";
				   case TOK_STRINGCON:
					   return "string";
				   case TOK_FALSE:
				   case TOK_TRUE:
					   return "bool";
				   case TOK_NULL:
					   return "null";
				   default :
					   fprintf(outfile, "error: invalid constant");
					   return "";
   	   		   }
   	   	   }
		   default:
			   rec_childrenType(outfile, symtable, typetable, node);
			   return "";
	   }
}

void rec_childrenType(FILE* outfile, SymbolTable* symtable, SymbolTable* typetable, astree* node) {
	for (size_t child = 0; child < node->children.size(); ++child) {
		typecheck_rec(outfile, symtable, typetable, node->children[child]);
	}
	return;
}
