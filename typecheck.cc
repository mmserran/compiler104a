
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

			   typetable->enterBlock();
			   vector<string>structTypes;
			   //structTypes = parseSignature(*typeStr);

			   needDelim = false;
			   for (size_t child = 0; child < node->children[1]->children.size(); ++child) {
				   typeStr = getType(node->children[1]->children[child]->children[1]);

				   if (needDelim) {
					   fprintf (outfile, "hello");
				   }

				   needDelim = true;
			   }

			   fprintf(outfile, "%s\n", typeStr->c_str());
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
   	   		   			   return "int";
   	   		   		   break;
   	   		   	   case '!':
   	   		   		   if (type=="bool")
   	   		   			   return "bool";
   	   		   		   break;
   	   		   	   case TOK_CHR:
   	   		   		   if (type=="char")
   	   		   			   return "char";
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
   	   	   		   		   return "bool"; "";
   	   		   		   break;
   	   		   	   case '=':
   	   		   		   if (left==right || right=="null")
   	   	   		   		   return "bool";
   	   		   		   break;
   	   		   }
   	   	   	   fprintf(outfile, "error, @binop: incompatible types, \'%s\'  \'%s\'\n",
   	   	   			   left.c_str(), right.c_str());
   	   	   	   return "";
   	   	   }

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
					   fprintf(outfile, "warning: invalid constant");
					   return "";
   	   		   }
   	   	   }
		   default:
			   rec_childrenType(outfile, symtable, typetable, node);
			   return "";
	   }
}
/*


	   	   // Structdefs

	   	   case TOK_STRUCT: {

			   coords.str("");
			   coords << '(' << node->filenr << '.' << node->linenr << '.' << node->offset << ')';

	   		   fprintf(outfile, "structdef");
			   // Get name
			   nameStr = node->children[0]->lexinfo;
			   // Get type
			   typeStr = getType(node->children[1]);
			   // Get params
			   temp = *typeStr + "(";
			   needDelim = false;
			   for (size_t child = 0; child < node->children[2]->children.size(); ++child) {
				   typeStr = getType(node->children[2]->children[child]->children[1]);

				   if (needDelim) {
					   temp = temp + ", ";
				   }

				   temp = temp + *typeStr;
				   needDelim = true;
			   }
			   temp = temp + ")";
			   typeStr = &temp;

			   for (size_t child = 0; child < node->children[2]->children.size(); ++child) {
				   typeTemp = *getType(node->children[2]->children[child]->children[1]);
				   nameTemp = *node->children[2]->children[child]->children[0]->lexinfo;

				   // >Enter argument into Function's child symbol table
				   symtable->enterFunction(*nameStr, *typeStr, coords.str().c_str())->addSymbol(nameTemp, typeTemp, coords.str().c_str());
			   }

			   // Decrement block number
			   symtable->N--;
			   rec_childrenBuild(outfile, symtable, node);

			   break;
	   	   }

   	   	   case TOK_ALLOCATOR: {

   	   		   op = node->children[1];
   	   		   switch (op->symbol) {
   	   		   	   case TOK_BASETYPE:
   	   		   		   base = typecheck_rec(outfile, symtable, node->children[1]);
   	   		   	   case TOK_NEWARRAY:
   	   		   		   base = string(*node->children[2]->children[0]->lexinfo+"[]");
   	   		   }

   	   		   lookup = symtable->lookup(base);
   	   		   if ( lookup.compare("") ) {
   	   			   fprintf(outfile, "fuck");
   	   		   	   return "";
   	   		   }
   	   		   else
   	   			   return base;
   	   	   }
*/

   	   		   //case TOK_NEW
   	   		   	   //TOK_TYPEID '(' ')'
   	   		   	   //TOK_STRING '(' int ')'

   	   		   //case TOK_IDENT '(' compatible ')'
   	   		   //case TOK_IDENT
   	   		   //case TOK_ARRAY:
   	   		   //case 'string' '[' int ']'
   	   		   //case TOK_TYPEID:

void rec_childrenType(FILE* outfile, SymbolTable* symtable, SymbolTable* typetable, astree* node) {
	for (size_t child = 0; child < node->children.size(); ++child) {
		typecheck_rec(outfile, symtable, typetable, node->children[child]);
	}
	return;
}

string arithmeticOps(FILE* outfile, SymbolTable* symtable, string compare_L, string compare_R) {

	return "int";
}
