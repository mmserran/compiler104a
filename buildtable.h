#ifndef __BUILDTABLE_H__
#define __BUILDTABLE_H__

#include <stdio.h>
#include <string>
#include "symtable.h"
#include "astree.h"

using namespace std;


void buildSymbolTable (FILE* outfile, astree* root);

void build_rec (FILE* outfile, SymbolTable* currentSymTable, astree* root);

void rec_over_children(FILE* outfile, SymbolTable* symtable, astree* node);

const string* getType(astree* type);

#endif
