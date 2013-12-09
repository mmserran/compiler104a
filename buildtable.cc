
using namespace std;
#include <sstream>

#include "lyutils.h"
#include "buildtable.h"
#include "symtable.h"
#include "astree.h"

// Declare variables
int block_count = 0;
int scope = 0;

string temp1;

SymbolTable* global_symTable;

SymbolTable* buildSymbolTable (FILE* outfile, astree* node) {

	global_symTable = new SymbolTable(NULL);

	build_rec (outfile, global_symTable, node);

	global_symTable->dump(outfile, 0);
	fflush (NULL);

	return global_symTable;
}

void build_rec (FILE* outfile, SymbolTable* currentSymTable, astree* node) {
	const string* nameStr;
	const string* typeStr;
	string typeTemp;
	string nameTemp;
	string temp;
	stringstream coords;

	if (node == NULL) return;

   //do something with current node
   switch (node->symbol) {
	   case TOK_BLOCK:

		   rec_childrenBuild(outfile, currentSymTable->enterBlock(), node);
		   break;

	   case TOK_FUNCTION:
		   coords.str("");
		   coords << '(' << node->filenr << '.' << node->linenr << '.' << node->offset << ')';

		   // Get name
		   nameStr = node->children[0]->lexinfo;
		   // Get type
		   typeStr = getType(node->children[1]);
		   // Get params
		   temp = *typeStr + "(";

		   bool needDelim;
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
			   currentSymTable->enterFunction(*nameStr, *typeStr, coords.str().c_str())->addSymbol(nameTemp, typeTemp, coords.str().c_str());
		   }

		   // Decrement block number
		   currentSymTable->N--;
		   rec_childrenBuild(outfile, currentSymTable, node);
		   break;

	   case TOK_VARDECL:
		   coords.str("");
		   coords << '(' << node->filenr << '.' << node->linenr << '.' << node->offset << ')';

		   // Get name
		   nameStr = node->children[0]->lexinfo;
		   // Get type
		   typeStr = getType(node->children[1]);

		   currentSymTable->addSymbol(*nameStr, *typeStr, coords.str().c_str());
		   rec_childrenBuild(outfile, currentSymTable, node);
		   break;

	   default:
		   rec_childrenBuild(outfile, currentSymTable, node);
   }
   return;
}

const string* getType(astree* type) {
		astree* basetype;

	   // Get type
	   basetype = type->children[0];
	   if (basetype->symbol==TOK_ARRAY) {
		   temp1 = *type->children[1]->children[0]->lexinfo;
		   temp1 = temp1 + "[]";
		   return &temp1;
	   }
	   else {
		   return type->children[0]->children[0]->lexinfo;
	   }
}

void rec_childrenBuild(FILE* outfile, SymbolTable* currentSymTable, astree* node) {
	for (size_t child = 0; child < node->children.size(); ++child) {
		build_rec(outfile, currentSymTable, node->children[child]);
	}
	return;
}
