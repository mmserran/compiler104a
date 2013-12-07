
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

void ast_traverse (FILE* outfile, SymbolTable symtable, astree* root) {
   dfs_rec (outfile, symtable, root, 0);
   fflush (NULL);
}

void dfs_rec (FILE* outfile, SymbolTable currentSymTable, astree* root, int depth) {
   if (root == NULL) return;

   //do something with current node
   switch (root->symbol) {




	   /*
   	   case IGNORE:
		   for (size_t child = 0; child < root->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable, root->children[child], depth + 1);
		   }
		   break;

	   case TOK_BLOCK:
		   block_count++;
		   scope++;
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "%s (%s)\n", get_yytname(root->symbol), root->lexinfo->c_str());

		   for (size_t child = 0; child < root->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), root->children[child], depth + 1);
		   }

		   scope--;
		   break;

	   case TOK_VARDECL:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "%s (%s)\n", get_yytname(root->symbol), root->lexinfo->c_str());

		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "%s (%s)\n", get_yytname(root->symbol), root->lexinfo->c_str());

		   for (size_t child = 0; child < root->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), root->children[child], depth + 1);
		   }
		   break;


		   type = ignore_rec(root->children[0]);
		   name = ignore_rec(root->children[1]);

		   // Do something with type and name
		   fprintf (outfile, "%*s ", scope * 3, ""); fprintf (outfile, "type: %s\n", type->c_str());
		   fprintf (outfile, "%*s ", scope * 3, ""); fprintf (outfile, "name: %s\n", name->c_str());

	   case TOK_FUNCTION:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "%s (%s)\n", get_yytname(root->symbol), root->lexinfo->c_str());

		   type = root->children[0]->lexinfo;
		   //name = root->children[2]->lexinfo;

		   // Do something with type and name
		   for (size_t child = 0; child < root->children.size(); ++child) {
			   fprintf (outfile, "%*s ", scope * 3, ""); fprintf (outfile, "functChildren: %s\n", root->children[child]->lexinfo->c_str());
		   }
		   break;
	   case TOK_STRUCT:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "%s (%s)\n", get_yytname(root->symbol), root->lexinfo->c_str());
		   for (size_t child = 0; child < root->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), root->children[child], depth + 1);
		   }
		   break;
	   case TOK_PARAMS:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "%s (%s)\n", get_yytname(root->symbol), root->lexinfo->c_str());
		   for (size_t child = 0; child < root->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), root->children[child], depth + 1);
		   }
		   break;

	   case TOK_IDENT:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", root->lexinfo->c_str());
		   break;


	   case TOK_NEW:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", root->lexinfo->c_str());
		   break;
	   case TOK_INTCON:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", root->lexinfo->c_str());
		   break;
	   case TOK_STRINGCON:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", root->lexinfo->c_str());
		   break;
	   case TOK_CHARCON:
		   fprintf (outfile, "%*s ", scope * 3, "");
		   fprintf (outfile, "(%s)\n", root->lexinfo->c_str());
		   break;
	   */
	   default:

		   fprintf (outfile, "%*s ", depth * 3, "");
		   if (root->terminal)
			   fprintf (outfile, "%s (%s)\n", get_yytname(root->symbol), root->lexinfo->c_str());
		   else
			   fprintf (outfile, "%s (%s)\n", root->lexinfo->c_str(), get_yytname(root->symbol));


		   for (size_t child = 0; child < root->children.size(); ++child) {
			   dfs_rec(outfile, currentSymTable.enterBlock(), root->children[child], depth + 1);
		   }
   }
   return;
}


const string* ignore_rec(astree* node) {
	   if (node->symbol == IGNORE)
		   return ignore_rec(node->children[0]);

	   else if (node->symbol == TOK_INT
			   || node->symbol == TOK_STRING
			   || node->symbol == TOK_CHAR
			   || node->symbol == TOK_BOOL) {
		   string temp="";
		   if (node->children[0])
			   temp = *node->lexinfo + *node->children[0]->lexinfo;
		   return &temp;
	   }
	   else
		   return node->lexinfo;
}
