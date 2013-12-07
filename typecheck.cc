
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
const string temp;

void ast_traverse (FILE* outfile, SymbolTable symtable, astree* node) {
   dfs_rec (outfile, symtable, node, 0);
   fflush (NULL);
}

void dfs_rec (FILE* outfile, SymbolTable currentSymTable, astree* node, int depth) {
   if (node == NULL) return;

   //do something with current node
   switch (node->symbol) {
   	   case ROOT:

	   case TOK_BLOCK:
		   block_count++;
		   scope++;

		   for (size_t child = 0; child < node->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), node->children[child], depth + 1);
		   }

		   scope--;
		   break;

	   case TOK_VARDECL:

		   name = node->children[0]->lexinfo;

		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "name: %s\n", name->c_str());

		   for (size_t child = 0; child < node->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), node->children[child], depth + 1);
		   }
		   break;



	   /*







	   case TOK_STRUCT:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "%s (%s)\n", get_yytname(node->symbol), node->lexinfo->c_str());
		   for (size_t child = 0; child < node->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), node->children[child], depth + 1);
		   }
		   break;
	   case TOK_PARAMS:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "%s (%s)\n", get_yytname(node->symbol), node->lexinfo->c_str());
		   for (size_t child = 0; child < node->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), node->children[child], depth + 1);
		   }
		   break;

	   case TOK_IDENT:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", node->lexinfo->c_str());
		   break;


	   case TOK_NEW:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", node->lexinfo->c_str());
		   break;
	   case TOK_INTCON:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", node->lexinfo->c_str());
		   break;
	   case TOK_STRINGCON:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", node->lexinfo->c_str());
		   break;
	   case TOK_CHARCON:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", node->lexinfo->c_str());
		   break;
	   */
	   default:
		   //fprintf(outfile, "%s (%s)", node->symbol);
		   for (size_t child = 0; child < node->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable, node->children[child], depth + 1);
		   }
   }
   return;
}


const string* ignore_rec(astree* node) {
	switch (node->symbol) {
		default:
			return node->lexinfo;
	}

}
