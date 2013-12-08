
using namespace std;
#include <sstream>

#include "lyutils.h"
#include "typecheck.h"
#include "symtable.h"
#include "astree.h"

// Declare variables
SymbolTable* type_symtable;

void typecheck (FILE* outfile, astree* node) {

	type_symtable = new SymbolTable(NULL);

	typecheck_rec (outfile, type_symtable, node);

	type_symtable->dump(outfile, 0);
	fflush (NULL);
}

void typecheck_rec (FILE* outfile, SymbolTable* currentSymTable, astree* node) {
	   if (node == NULL) return;

	   //do something with current node
	   switch (node->symbol) {

		   default:
			   fprintf(outfile, "%s (%s)\n", get_yytname(node->symbol), node->lexinfo->c_str());
			   rec_childrenType(outfile, currentSymTable, node);
	   }
	   return;
}

void rec_childrenType(FILE* outfile, SymbolTable* currentSymTable, astree* node) {
	for (size_t child = 0; child < node->children.size(); ++child) {
		typecheck_rec(outfile, currentSymTable, node->children[child]);
	}
	return;
}

