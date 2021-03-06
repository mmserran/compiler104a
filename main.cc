//  Mark Anthony Serrano (mmserran@ucsc.edu)
//  UCSC Fall 2013 - CS104A
//  asg2/main.cc
//
//
//  Created by Mark Anthony Serrano on 10/1/13.
//
//

#include <string>
#include <vector>
using namespace std;

#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "astree.h"
#include "auxlib.h"
#include "lyutils.h"
#include "stringset.h"
#include "symtable.h"
#include "buildtable.h"
#include "typecheck.h"

//Initialize constants and variables
const string cpp_name = "/usr/bin/cpp";
const size_t LINESIZE = 1024;
string cppFlags;
string yyin_cpp_command;
SymbolTable* symtable;

FILE *tokout, *strout, *astout, *symout;
const char *outFilename;

//Open a pipe from the C preprocessor and assign to yyin
//Exit failure if can't.
void yyin_cpp_popen (const char* filename)
{
    yyin_cpp_command = cpp_name;
    yyin_cpp_command += " " + cppFlags + " ";
    yyin_cpp_command += filename;
    yyin = popen (yyin_cpp_command.c_str(), "r");
    
    // Use -@c to see command string used to call cpp
    DEBUGF('c', ("  D: CPP Command String: "+string(yyin_cpp_command)+"\n").c_str() );
    if (yyin == NULL) {
        syserrprintf (yyin_cpp_command.c_str());
        exit (get_exitstatus());
    }
    scanner_newfilename( filename );
}
//Close the yyin pipe
void yyin_cpp_pclose (void)
{
    int pclose_rc = pclose (yyin);
    eprint_status (yyin_cpp_command.c_str(), pclose_rc);
    if (pclose_rc != 0) set_exitstatus (EXIT_FAILURE);
}
//Scan arguments with getOpt() and set appropriate flags
void scan_opts (int argc, char** argv)
{
    int option;
    opterr = 0;
    yy_flex_debug = 0;
    yydebug = 0;
    while ( (option = getopt (argc, argv, "@:D:ly"))!=-1 ){
        switch (option) {
            case '@': set_debugflags (optarg);          break;
            case 'D': cppFlags = "-D" + string(optarg); break;
            case 'l': yy_flex_debug = 1;                break;
            case 'y': yydebug = 1;                      break;
            default:  errprintf ("%:bad option\n");     break;
        }
    }
}

int main (int argc, char** argv) {
    
    /*** Argument Handler and .oc Verifier ***********************************/
    int parsecode = 0;
    set_execname (argv[0]);
    
    //Check for valid filename with .oc extension
    string filename = argv[argc-1];
    if( filename.substr(filename.find_last_of('.') + 1) != "oc" ) {
        fputs ("\nerror opening file, suffix not .oc\n\n",stderr);
        abort();
    }
    //Record basename
    string basename = filename.substr(filename.find_last_of('/') + 1, string::npos);
    basename = basename.substr(0, basename.find_last_of('.'));
    
    //Handle options using getopt()
    scan_opts(argc, argv);
    /*************************************************************************/
    
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    //< Open all output file handles and yyin
    yyin_cpp_popen( filename.c_str() );
    
    outFilename = (string(basename)+".str").c_str();
    strout = fopen( outFilename, "w" );
    outFilename = (string(basename)+".tok").c_str();
    tokout = fopen( outFilename, "w" );
    outFilename = (string(basename)+".ast").c_str();
    astout = fopen( outFilename, "w" );
    outFilename = (string(basename)+".sym").c_str();
    symout = fopen( outFilename, "w" );
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    
    /*** MAGIC **************************************************************/
    parsecode = yyparse();
    if (parsecode) {
        errprintf ("%:parse failed (%d)\n", parsecode);
    }else {
        DEBUGSTMT ('a', dump_astree (stderr, yyparse_astree); );
    }

    //Write stringset data to .str file
    dump_stringset(strout);

    //Write formatted AST data to .ast file
    dump_astree(astout, yyparse_astree);

    /*************************************************************************/
    
    /*** SYMBOL TABLE CONSTRUCTION PASS **************************************/
    //Write symbol tables to .sym file
    symtable = buildSymbolTable(symout, yyparse_astree);
    /*************************************************************************/

    /*** TYPE CHECKING PASS **************************************************/
    typecheck(stderr, symtable, yyparse_astree);
    /*************************************************************************/

    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //> Close all files handles and yyin
    fclose( tokout );
    fclose( strout );
    fclose( astout );
    fclose( symout );

    free_ast (yyparse_astree);

    yyin_cpp_pclose();
    yylex_destroy();
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
   return get_exitstatus();
}
