#ifndef __TYPECHECK_H__
#define __TYPECHECK_H__

#include <stdio.h>
#include <string>
#include "symtable.h"
#include "astree.h"

using namespace std;


void ast_traverse (FILE* outfile, SymbolTable symtable, astree* root);

void dfs_rec (FILE* outfile, SymbolTable currentSymTable, astree* root);

void rec_over_children(FILE* outfile, SymbolTable symtable, astree* node);

#endif
