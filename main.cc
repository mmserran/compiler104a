//  Mark Anthony Serrano (mmserran@ucsc.edu)
//  UCSC Fall 2013 - CS104A
//  asg1/main.cc
//  
//
//  Created by Mark Anthony Serrano on 10/1/13.
//
//

#include <errno.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>     // to use getopt()
#include <fstream>      // to use popen()
#include <string.h>     // to use c string functions i.e. strtok_r()
#include <string>       // to use std::string class
#include <vector>       // to use std::vector class
using namespace std;

#include "auxlib.h"     // Taken from class website
#include "stringset.h"  // Taken from class website

const string CPP = "/usr/bin/cpp";
string cppFlags;
const size_t LINESIZE = 1024;

int main (int argc, char **argv) {
    /*** Argument Handler ****************************************************/
    // 1. Check if filename argument suffix is .oc
    string filename = argv[argc-1];
    if( filename.substr(filename.find_last_of('.') + 1) != "oc" ) {
        fputs ("\nerror opening file, suffix not .oc\n\n",stderr);
        abort();
    }
    
    // 2. Record pwd and basename
    int dot = filename.find_last_of('.');
    int slash = filename.find_last_of('/') + 1;
    
    if( filename.find('/') == string::npos )
        // if file is in this directory, set slash to 0
        slash = 0;
    
    string basename = filename.substr(slash, dot-slash);
    
    // 3. Handle options using getopt()
    int c;
    while(  (c=getopt(argc, argv, "@:D:ly")) != -1  ){
        switch (c){
            case '@':
                // -@ﬂags Call set_debugflags, and use DEBUGF and DEBUGSTMT for debugging.
                set_debugflags (optarg);
                break;
            case 'D':
                // -Dstring Pass this option and its argument to cpp. This is mostly useful as -D__OCLIB_OH__ to suppress inclusion of the code from oclib.oh when testing a program.
                cppFlags = "-D" + string(optarg);
                break;
            case 'l':
                // -l Debug yylex() with yy_flex_debug = 1
                // set global variable yy_flex_debug to 1;
                break;
            case 'y':
                // -y Debug yyparse() with yydebug = 1
                // set global variable yydebug to 1;
                break;
            case '?':
                fprintf (stderr, "\nerror: unrecognized option\n\n");
                break;
            default:
                abort();
        }
    }
    /*************************************************************************/
    
    /*** Generating cpp output ***********************************************/
    string command = CPP + " " + cppFlags + " " + filename;
    
    FILE *pipe;;
    char currLine[LINESIZE];
    pipe = popen (command.c_str(), "r");
    
    if(pipe == NULL) {
        fputs("\nerror feeding .oc program to cpp\n\n", stderr);
        abort();
    } else {
        // Read all lines of file
        while ( fgets(currLine, LINESIZE, pipe) != NULL ) {
            char *savepos = NULL;
            char *bufptr = currLine;
            for ( int tokenct = 1;; ++tokenct ) {
                char *token = strtok_r ( bufptr, " \t\n", &savepos );
                bufptr = NULL;
                if(token == NULL) break;
                
                // Enter token into hash map using stringset.h
                intern_stringset (token);
                
            }
        }
        pclose (pipe);
    }
    
    // Use -@c to see command string used to call cpp
    DEBUGF('c', ("Command String: "+string(command)+"\n").c_str() );
    /*************************************************************************/
    
    /*** Creating output program.str file ************************************/
    const char *outFilename = (string(basename)+".str").c_str();
    
    FILE *output = fopen ( outFilename, "w" );
    dump_stringset (output);
    fclose (output);
    
    // Use -@o to see what file the output will be written to
    DEBUGF('o', ("Output File: "+string(outFilename)+"\n").c_str() );
    /*************************************************************************/
    
    return get_exitstatus();

}
