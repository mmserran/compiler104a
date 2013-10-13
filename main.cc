//
//  main.c
//  
//
//  Created by Mark Anthony Serrano on 10/1/13.
//
//

#include <string>
using namespace std;

#include <errno.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <GetOpt.h>
#include <stdio.h>
#include <vector>
#include <iostream>
#include <fstream>

#include "auxlib.h"
#include "stringset.h"

const string CPP = "/usr/bin/cpp";
const size_t LINESIZE = 1024;

int main (int argc, char **argv) {
    //cout << helloWorld();
    /*** Argument Handler ****************************************************/
    // 1. Check if filename argument suffix is .oc
    string filename = argv[argc-1];
    if ( filename.substr(filename.find_last_of('.') + 1) != "oc" ) {
        fputs ("error opening file, suffix not .oc\n",stderr);
        abort();
    }
    
    // 2. Record pwd and basename
    int dot = filename.find_last_of('.');
    int slash = filename.find_last_of('/') + 1;
    
    if ( filename.find('/') == string::npos )
        // if file is in this directory, set slash to 0
        slash = 0;
    
    string pwd = filename.substr(0, slash);
    string basename = filename.substr(slash, dot-slash);
    
    // TEMP ***************
    cout << "pwd:\t\t" << pwd << "\n";
    cout << "basename:\t" << basename << "\n";
    
    // 3. Handle options using getopt()
    int c;
    while ((c = getopt(argc, argv, "@Dly")) != -1) {
        switch (c)
        {
            case '@':
                // -@ﬂags Call set_debugflags, and use DEBUGF and DEBUGSTMT for debugging.
                //cout<< "hello world! @@@\n";//*** TEMP ***********************************
                break;
            case 'D':
                // -Dstring Pass this option and its argument to cpp. This is mostly useful as -D__OCLIB_OH__ to suppress inclusion of the code from oclib.oh when testing a program.
                //cout<< "hello world! ddd\n";//*** TEMP ***********************************
                break;
            case 'l':
                // -l Debug yylex() with yy_flex_debug = 1
                //cout<< "hello world! l l l\n";//*** TEMP ***********************************
                break;
            case 'y':
                // -y Debug yyparse() with yydebug = 1
                //cout<< "hello world! yyy\n";//*** TEMP ***********************************
                break;
            case '?':
                fprintf(stderr, "error: unrecognized option\n");
                break;
            default:
                abort();
        }
    }
    /*************************************************************************/
    
    /*** Generating cpp output ***********************************************/
    string command = CPP + " " + basename + ".oc";
    FILE *pipe;;
    char currLine[LINESIZE];
    pipe = popen (command.c_str(), "r");
    
    if (pipe == NULL) {
        fputs("error feeding .oc program to cpp\n", stderr);
        abort();
    } else {
        while ( fgets(currLine, LINESIZE, pipe) != NULL ) {
            char *savepos = NULL;
            char *bufptr = currLine;
            for (int tokenct = 1;; ++tokenct) {
                char *token = strtok_r (bufptr, " \t\n", &savepos);
                bufptr = NULL;
                if (token == NULL) break;
                cout << token << " ";
                // Creating string table using stringset
                //const string *str = intern_stringset(token);
                
            }
            cout << "\n";
        }
        //dump_stringset (stdout);
        pclose(pipe);
    }
    /*************************************************************************/
    
    
    /*** Creating output program.str file ************************************/
    ofstream myfile;
    myfile.open (basename.append(".str").c_str());
    
    // TEMP *******************
    myfile << "Writing this to a file and also hello world.\n";
    
    myfile.close();
    /*************************************************************************/
    
    return 0;

}
