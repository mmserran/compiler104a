#ifndef __TYPECHECK_H__
#define __TYPECHECK_H__

#include <stdio.h>
#include <string>
#include "symtable.h"
#include "astree.h"

using namespace std;

void typecheck (FILE* outfile, astree* node);

void typecheck_rec (FILE* outfile, SymbolTable* currentSymTable, astree* node);

void rec_childrenType(FILE* outfile, SymbolTable* currentSymTable, astree* node);

#endif
