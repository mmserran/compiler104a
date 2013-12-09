#ifndef __TYPECHECK_H__
#define __TYPECHECK_H__

#include <stdio.h>
#include <string>
#include "symtable.h"
#include "astree.h"

using namespace std;

void typecheck (FILE* outfile, SymbolTable* symtable, astree* node);

string typecheck_rec (FILE* outfile, SymbolTable* symtable, SymbolTable* typetable,  astree* node);

void rec_childrenType(FILE* outfile, SymbolTable* symtable, SymbolTable* typetable, astree* node);

#endif
