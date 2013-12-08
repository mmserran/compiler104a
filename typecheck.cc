
using namespace std;

#include "lyutils.h"
#include "typecheck.h"
#include "symtable.h"
#include "astree.h"

int block_count = 0;
int scope = 0;


const string* name;
const string* type;
const string* paramType;
astree* basetype;

void ast_traverse (FILE* outfile, SymbolTable symtable, astree* node) {
   dfs_rec (outfile, symtable, node);
   fflush (NULL);
}

void dfs_rec (FILE* outfile, SymbolTable currentSymTable, astree* node) {
   if (node == NULL) return;

   //do something with current node
   switch (node->symbol) {
	   case TOK_BLOCK:
		   block_count++;

		   scope++;
		   rec_over_children(outfile, currentSymTable.enterBlock(), node);
		   scope--;
		   break;

	   case TOK_FUNCTION:
		   name = node->children[0]->lexinfo;
		   basetype = node->children[1]->children[0];
		   if (basetype->symbol==TOK_ARRAY)
			   type = node->children[1]->children[1]->children[0]->lexinfo->c_str();
		   else
			   type = node->children[1]->children[0]->children[0]->lexinfo->c_str();

		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "fname: %s () {%d} %s\n", name->c_str(), block_count, type->c_str());

		   // Example: To enter the function "void add(int a, int b)",
		   //          use "currentSymbolTable->enterFunction("add", "void(int,int)");
		   scope++;
		   rec_over_children(outfile, currentSymTable.enterFunction("test", "test"), node);
		   scope--;
		   break;

	   case TOK_VARDECL:
		   name = node->children[0]->lexinfo;

		   basetype = node->children[1]->children[0];
		   if (basetype->symbol == TOK_ARRAY)
			   type = node->children[1]->children[1]->children[0]->lexinfo;
		   else
			   type = node->children[1]->children[0]->children[0]->lexinfo;

		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "varname: %s () {%d} %s\n", name->c_str(), block_count, type->c_str());


		   // Example: To add the variable declaration "int i = 23;"
		   //          use "currentSymbolTable->addSymbol("i", "int");
		   rec_over_children(outfile, currentSymTable, node);
		   break;

	   case TOK_STRUCT:
		   rec_over_children(outfile, currentSymTable, node);
		   break;

	   default:
		   //fprintf(outfile, "%s (%s)", node->symbol);
		   rec_over_children(outfile, currentSymTable, node);
   }
   return;
}

void rec_over_children(FILE* outfile, SymbolTable currentSymTable, astree* node) {
	for (size_t child = 0; child < node->children.size(); ++child) {
		dfs_rec(outfile, currentSymTable, node->children[child]);
	}
	return;
}
