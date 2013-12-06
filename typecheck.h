#ifndef __TYPECHECK_H__
#define __TYPECHECK_H__

#include <stdio.h>
#include "symtable.h"
#include "astree.h"

using namespace std;


void ast_dfspost_traverse (FILE* outfile, SymbolTable symtable, astree* root);

static void dfs_rec (FILE* outfile, astree* root, int depth);

#endif
