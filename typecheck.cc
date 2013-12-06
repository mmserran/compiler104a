
using namespace std;

#include "typecheck.h"
#include "symtable.h"
#include "astree.h"

int block_count = 0;

void ast_traverse (FILE* outfile, SymbolTable symtable, astree* root) {
   dfs_rec (outfile, root, 0);
   fflush (NULL);
}

static void dfs_rec (FILE* outfile, astree* root, int depth) {
   if (root == NULL) return;

   //do something with current node
   fprintf (outfile, "%*s ", depth * 3, root->lexinfo->c_str());
   fprintf (outfile, "\n");

   //recursive call
   for (size_t child = 0; child < root->children.size(); ++child) {
	   dfs_rec(outfile, root->children[child], depth + 1);
   }
}
