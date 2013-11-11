%{
/* Mark Anthony Serrano (mmserran@ucsc.edu) */
/* UCSC Fall 2013 - CS104A; asg2/scanner.l  */
// $Id: scanner.l,v 1.3 2013-10-15 16:37:56-07 - - $

#include "auxlib.h"
#include "lyutils.h"

#define YY_USER_ACTION  { scanner_useraction (); }
#define IGNORE(THING)   { }

%}

%option 8bit
%option debug
%option ecs
%option nodefault
%option nounput
%option noyywrap
%option perf-report
%option verbose
%option warn

LETTER          [A-Za-z_]
DIGIT           [0-9]
IDENT           ({LETTER}({LETTER}|{DIGIT})*)
INTEGER         ({DIGIT}+)
CHARACTER       ('([^\\'\n]|\\[\\'"0nt])') 
STRING          (\"([^\\"\n]|\\[\\'"0nt])*\") 

BADIDENT        ({DIGIT}({LETTER}|{DIGIT})*)
BADSTRING       (\"([^\\"\n]|\\[\\'"0nt])*) 
BADCHARACTER    ('([^\\'\n]|\\[\\'"0nt])) 

%%

[ \t]+          { IGNORE (white space)                  }
\n              { scanner_newline();                    }
"#".*           { scanner_include();                    }

"[]"            { return yylval_token(TOK_ARRAY);       }
"("             { return yylval_token('(');             }
")"             { return yylval_token(')');             }
"["             { return yylval_token('[');             }
"]"             { return yylval_token(']');             }
"{"             { return yylval_token('{');             }
"}"             { return yylval_token('}');             }
";"             { return yylval_token(';');             }
","             { return yylval_token(',');             }
"."             { return yylval_token('.');             }
"="             { return yylval_token('=');             }

"=="            { return yylval_token(TOK_EQ);          }
"!="            { return yylval_token(TOK_NE);          }
"<"             { return yylval_token(TOK_LT);          }
"<="            { return yylval_token(TOK_LE);          }
">"             { return yylval_token(TOK_GT);          }
">="            { return yylval_token(TOK_GE);          }

"+"             { return yylval_token('+');             }
"-"             { return yylval_token('-');             }
"*"             { return yylval_token('*');             }
"/"             { return yylval_token('/');             }
"%"             { return yylval_token('%');             }
"!"             { return yylval_token('!');             }

"void"          { return yylval_token(TOK_VOID);        }
"bool"          { return yylval_token(TOK_BOOL);        }
"char"          { return yylval_token(TOK_CHAR);        }
"int"           { return yylval_token(TOK_INT);         }
"string"        { return yylval_token(TOK_STRING);      }
"struct"        { return yylval_token(TOK_STRUCT);      }
"if"            { return yylval_token(TOK_IF);          }
"else"          { return yylval_token(TOK_ELSE);        }
"while"         { return yylval_token(TOK_WHILE);       }
"return"        { return yylval_token(TOK_RETURN);      }
"new"           { return yylval_token(TOK_NEW);         }
"false"         { return yylval_token(TOK_FALSE);       }
"true"          { return yylval_token(TOK_TRUE);        }
"null"          { return yylval_token(TOK_NULL);        }
"ord"           { return yylval_token(TOK_ORD);         }
"chr"           { return yylval_token(TOK_CHR);         }

{IDENT}         { return yylval_token(TOK_IDENT);       }
{INTEGER}       { return yylval_token(TOK_INTCON);      }
{CHARACTER}     { return yylval_token(TOK_CHARCON);     }
{STRING}        { return yylval_token(TOK_STRINGCON);   }

{BADIDENT}      { scanner_badtoken(yytext);             }
{BADSTRING}     { scanner_badtoken(yytext);             }
{BADCHARACTER}  { scanner_badchar(yytext[0]);           }
.               { scanner_badchar(*yytext);             }
%%

RCSC("$Id: scanner.l,v 1.3 2013-10-15 16:37:56-07 - - $")

